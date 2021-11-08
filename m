Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE176C433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 746B961027
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 746B961027
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F41FC21F3BF;
	Mon,  8 Nov 2021 07:08:09 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2402321C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:48 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0AFC52220;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0150CE07E4; Mon,  8 Nov 2021 10:07:45 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:29 -0500
Message-Id: <1636384063-13838-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/15] lustre: sec: keep encryption context
 in xattr cache
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

When an inode is being cleared, its xattr cache must be completely
wiped. But in case of lock cancel, we want to keep the encryption
context, as further processing might need to check it.

Fixes: b5de088eb4 ("lustre: sec: access to enc file's xattrs")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14989
Lustre-commit: 14b37c763c5751faf ("LU-14989 sec: keep encryption context in xattr cache")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/45148
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  1 +
 fs/lustre/llite/namei.c          |  2 +-
 fs/lustre/llite/xattr_cache.c    | 36 +++++++++++++++++++++++++++++++++++-
 3 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index bd49228..bed0443 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -416,6 +416,7 @@ static inline void ll_layout_version_set(struct ll_inode_info *lli, u32 gen)
 }
 
 int ll_xattr_cache_destroy(struct inode *inode);
+int ll_xattr_cache_empty(struct inode *inode);
 
 int ll_xattr_cache_get(struct inode *inode, const char *name,
 		       char *buffer, size_t size, u64 valid);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index f942179..fe7fdbb 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -248,7 +248,7 @@ static void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 	}
 
 	if (bits & MDS_INODELOCK_XATTR) {
-		ll_xattr_cache_destroy(inode);
+		ll_xattr_cache_empty(inode);
 		bits &= ~MDS_INODELOCK_XATTR;
 	}
 
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index 0641f73..b044c89 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -272,6 +272,40 @@ int ll_xattr_cache_destroy(struct inode *inode)
 }
 
 /**
+ * ll_xattr_cache_empty - empty xattr cache for @ino
+ *
+ * Similar to ll_xattr_cache_destroy(), but preserves encryption context.
+ * So only LLIF_XATTR_CACHE_FILLED flag is cleared, but not LLIF_XATTR_CACHE.
+ */
+int ll_xattr_cache_empty(struct inode *inode)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_xattr_entry *entry, *n;
+
+	down_write(&lli->lli_xattrs_list_rwsem);
+	if (!ll_xattr_cache_valid(lli) ||
+	    !ll_xattr_cache_filled(lli))
+		goto out_empty;
+
+	list_for_each_entry_safe(entry, n, &lli->lli_xattrs, xe_list) {
+		if (strcmp(entry->xe_name,
+			   LL_XATTR_NAME_ENCRYPTION_CONTEXT) == 0)
+			continue;
+
+		CDEBUG(D_CACHE, "delete: %s\n", entry->xe_name);
+		list_del(&entry->xe_list);
+		kfree(entry->xe_name);
+		kfree(entry->xe_value);
+		kmem_cache_free(xattr_kmem, entry);
+	}
+	clear_bit(LLIF_XATTR_CACHE_FILLED, &lli->lli_flags);
+
+out_empty:
+	up_write(&lli->lli_xattrs_list_rwsem);
+	return 0;
+}
+
+/**
  * Match or enqueue a PR lock.
  *
  * Find or request an LDLM lock with xattr data.
@@ -495,7 +529,7 @@ int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
 	 */
 	if ((valid & OBD_MD_FLXATTRLS ||
 	     strcmp(name, LL_XATTR_NAME_ENCRYPTION_CONTEXT) != 0) &&
-	    !ll_xattr_cache_valid(lli)) {
+	    !ll_xattr_cache_filled(lli)) {
 		up_read(&lli->lli_xattrs_list_rwsem);
 		rc = ll_xattr_cache_refill(inode);
 		if (rc)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
