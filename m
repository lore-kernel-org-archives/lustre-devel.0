Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 460BCC433F5
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 10F4D60EB6
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 10F4D60EB6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 128E9381322;
	Mon, 11 Oct 2021 10:41:27 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CECF921FD2C
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B857E26F;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B1BFCA9502; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:37 -0400
Message-Id: <1633974049-26490-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/20] lustre: sec: access to enc file's
 xattrs
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

Encryption context is stored in 'security.c' xattr. This is put in the
xattr cache via ll_xattr_cache_insert() to avoid sending a getxattr
request to the server. But this operation declares the xattr cache for
the inode as 'valid', with two consequences. It prevents any further
filling with other xattrs, and trying to read an xattr value will
directly return -ENODATA, without any attempt to fetch the xattr from
the server.
This is solved by adding a new ll_file_flags 'LLIF_XATTR_CACHE_FILLED'
that tells if the xattr cache for the inode has been filled. This bit
is set only by ll_xattr_cache_refill(), and 'valid' now just means the
xattr cache for the inode has been initialized.

Fixes: 71d77bbe7e ("lustre: sec: atomicity of encryption context getting/setting")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14989
Lustre-commit: 1faf54e8bf19c28a4 ("LU-14989 sec: access to enc file's xattrs")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/44855
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  2 ++
 fs/lustre/llite/statahead.c      | 24 +++++++++++++++
 fs/lustre/llite/xattr_cache.c    | 65 +++++++++++++++++++++++++++++-----------
 3 files changed, 73 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index e0fda00..afd5c7a 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -109,6 +109,8 @@ enum ll_file_flags {
 	LLIF_FOREIGN_REMOVABLE	= 5,
 	/* setting encryption context in progress */
 	LLIF_SET_ENC_CTX	= 6,
+	/* Xattr cache is filled */
+	LLIF_XATTR_CACHE_FILLED	= 7,
 };
 
 /* See comment on trunc_sem_down_read_nowait */
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index cb435d5..15b95b7 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -666,6 +666,30 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 	if (rc)
 		goto out;
 
+	/* If encryption context was returned by MDT, put it in
+	 * inode now to save an extra getxattr.
+	 */
+	if (body->mbo_valid & OBD_MD_ENCCTX) {
+		void *encctx = req_capsule_server_get(&req->rq_pill,
+						      &RMF_FILE_ENCCTX);
+		u32 encctxlen = req_capsule_get_size(&req->rq_pill,
+						     &RMF_FILE_ENCCTX,
+						     RCL_SERVER);
+
+		if (encctxlen) {
+			CDEBUG(D_SEC,
+			       "server returned encryption ctx for "DFID"\n",
+			       PFID(ll_inode2fid(child)));
+			rc = ll_xattr_cache_insert(child,
+						   LL_XATTR_NAME_ENCRYPTION_CONTEXT,
+						   encctx, encctxlen);
+			if (rc)
+				CWARN("%s: cannot set enc ctx for "DFID": rc = %d\n",
+				      ll_i2sbi(child)->ll_fsname,
+				      PFID(ll_inode2fid(child)), rc);
+		}
+	}
+
 	CDEBUG(D_READA, "%s: setting %.*s" DFID " l_data to inode %p\n",
 	       ll_i2sbi(dir)->ll_fsname, entry->se_qstr.len,
 	       entry->se_qstr.name, PFID(ll_inode2fid(child)), child);
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index fee1cf5..0641f73 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -109,6 +109,12 @@ static int ll_xattr_cache_add(struct list_head *cache,
 	struct ll_xattr_entry *xattr;
 
 	if (ll_xattr_cache_find(cache, xattr_name, &xattr) == 0) {
+		if (!strcmp(xattr_name, LL_XATTR_NAME_ENCRYPTION_CONTEXT))
+			/* it means enc ctx was already in cache,
+			 * ignore error as it cannot be modified
+			 */
+			return 0;
+
 		CDEBUG(D_CACHE, "duplicate xattr: [%s]\n", xattr_name);
 		return -EPROTO;
 	}
@@ -211,7 +217,7 @@ static int ll_xattr_cache_list(struct list_head *cache,
 }
 
 /**
- * Check if the xattr cache is initialized (filled).
+ * Check if the xattr cache is initialized.
  *
  * Return:	0 @cache is not initialized
  *		1 @cache is initialized
@@ -222,6 +228,17 @@ static int ll_xattr_cache_valid(struct ll_inode_info *lli)
 }
 
 /**
+ * Check if the xattr cache is filled.
+ *
+ * \retval 0 @cache is not filled
+ * \retval 1 @cache is filled
+ */
+static int ll_xattr_cache_filled(struct ll_inode_info *lli)
+{
+	return test_bit(LLIF_XATTR_CACHE_FILLED, &lli->lli_flags);
+}
+
+/**
  * This finalizes the xattr cache.
  *
  * Free all xattr memory. @lli is the inode info pointer.
@@ -236,6 +253,7 @@ static int ll_xattr_cache_destroy_locked(struct ll_inode_info *lli)
 	while (ll_xattr_cache_del(&lli->lli_xattrs, NULL) == 0)
 		; /* empty loop */
 
+	clear_bit(LLIF_XATTR_CACHE_FILLED, &lli->lli_flags);
 	clear_bit(LLIF_XATTR_CACHE, &lli->lli_flags);
 
 	return 0;
@@ -259,7 +277,8 @@ int ll_xattr_cache_destroy(struct inode *inode)
  * Find or request an LDLM lock with xattr data.
  * Since LDLM does not provide API for atomic match_or_enqueue,
  * the function handles it with a separate enq lock.
- * If successful, the function exits with the list lock held.
+ * If successful, the function exits with a write lock held
+ * on lli_xattrs_list_rwsem.
  *
  * Return:	0 no error occurred
  *		-ENOMEM not enough memory
@@ -280,7 +299,7 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 	/* inode may have been shrunk and recreated, so data is gone, match lock
 	 * only when data exists.
 	 */
-	if (ll_xattr_cache_valid(lli)) {
+	if (ll_xattr_cache_filled(lli)) {
 		/* Try matching first. */
 		mode = ll_take_md_lock(inode, MDS_INODELOCK_XATTR, &lockh, 0,
 				       LCK_PR);
@@ -324,7 +343,9 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 /**
  * Refill the xattr cache.
  *
- * Fetch and cache the whole of xattrs for @inode, acquiring a read lock.
+ * Fetch and cache the whole of xattrs for @inode, thanks to the write lock
+ * on lli_xattrs_list_rwsem obtained from ll_xattr_find_get_lock().
+ * If successful, this write lock is kept.
  *
  * Return:		0 no error occurred
  *			-EPROTO network protocol error
@@ -346,7 +367,7 @@ static int ll_xattr_cache_refill(struct inode *inode)
 		goto err_req;
 
 	/* Do we have the data at this point? */
-	if (ll_xattr_cache_valid(lli)) {
+	if (ll_xattr_cache_filled(lli)) {
 		ll_stats_ops_tally(sbi, LPROC_LL_GETXATTR_HITS, 1);
 		ll_intent_drop_lock(&oit);
 		rc = 0;
@@ -385,7 +406,8 @@ static int ll_xattr_cache_refill(struct inode *inode)
 
 	CDEBUG(D_CACHE, "caching: xdata=%p xtail=%p\n", xdata, xtail);
 
-	ll_xattr_cache_init(lli);
+	if (!ll_xattr_cache_valid(lli))
+		ll_xattr_cache_init(lli);
 
 	for (i = 0; i < body->mbo_max_mdsize; i++) {
 		CDEBUG(D_CACHE, "caching [%s]=%.*s\n", xdata, *xsizes, xval);
@@ -422,6 +444,8 @@ static int ll_xattr_cache_refill(struct inode *inode)
 
 	if (xdata != xtail || xval != xvtail)
 		CERROR("a hole in xattr data\n");
+	else
+		set_bit(LLIF_XATTR_CACHE_FILLED, &lli->lli_flags);
 
 	ll_set_lock_data(sbi->ll_md_exp, inode, &oit, NULL);
 	ll_intent_drop_lock(&oit);
@@ -466,16 +490,29 @@ int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
 	LASSERT(!!(valid & OBD_MD_FLXATTR) ^ !!(valid & OBD_MD_FLXATTRLS));
 
 	down_read(&lli->lli_xattrs_list_rwsem);
-	if (!ll_xattr_cache_valid(lli)) {
+	/* For performance reasons, we do not want to refill complete xattr
+	 * cache if we are just interested in encryption context.
+	 */
+	if ((valid & OBD_MD_FLXATTRLS ||
+	     strcmp(name, LL_XATTR_NAME_ENCRYPTION_CONTEXT) != 0) &&
+	    !ll_xattr_cache_valid(lli)) {
 		up_read(&lli->lli_xattrs_list_rwsem);
 		rc = ll_xattr_cache_refill(inode);
 		if (rc)
 			return rc;
+		/* Turn the write lock obtained in ll_xattr_cache_refill()
+		 * into a read lock.
+		 */
 		downgrade_write(&lli->lli_xattrs_list_rwsem);
 	} else {
 		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR_HITS, 1);
 	}
 
+	if (!ll_xattr_cache_valid(lli)) {
+		rc = -ENODATA;
+		goto out;
+	}
+
 	if (valid & OBD_MD_FLXATTR) {
 		struct ll_xattr_entry *xattr;
 
@@ -521,18 +558,10 @@ int ll_xattr_cache_insert(struct inode *inode,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int rc;
 
-	down_read(&lli->lli_xattrs_list_rwsem);
+	down_write(&lli->lli_xattrs_list_rwsem);
 	if (!ll_xattr_cache_valid(lli))
 		ll_xattr_cache_init(lli);
-	rc = ll_xattr_cache_add(&lli->lli_xattrs, name, buffer,
-				size);
-	up_read(&lli->lli_xattrs_list_rwsem);
-
-	if (rc == -EPROTO &&
-	    strcmp(name, LL_XATTR_NAME_ENCRYPTION_CONTEXT) == 0)
-		/* it means enc ctx was already in cache,
-		 * ignore error as it cannot be modified
-		 */
-		rc = 0;
+	rc = ll_xattr_cache_add(&lli->lli_xattrs, name, buffer, size);
+	up_write(&lli->lli_xattrs_list_rwsem);
 	return rc;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
