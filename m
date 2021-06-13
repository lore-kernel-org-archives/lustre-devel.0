Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48E8FC48BDF
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:59 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 07C4B61363
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07C4B61363
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 25C3921F745;
	Sun, 13 Jun 2021 16:12:26 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CF42221E063
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:43 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C288E100B036;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BF4E89C306; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:21 -0400
Message-Id: <1623625897-17706-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/27] lustre: vvp: wait for nrpages to be
 updated
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
Cc: Vitaly Fertman <c17818@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <c17818@cray.com>

truncate_inode_pages() says there still may be a page in a process
of deletion upon return. wait for another thread which is doing
__delete_from_page_cache() to get nrpages updated.

HPE-bug-id: LUS-8842
WC-bug-id: https://jira.whamcloud.com/browse/LU-14644
Lustre-commit: 7d5d004506650c37 ("LU-14644 vvp: wait for nrpages to be updated")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://es-gerrit.dev.cray.com/158557
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/43464
Reviewed-by: Andriy Skulysh <askulysh@gmail.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  1 +
 fs/lustre/llite/llite_lib.c      | 51 ++++++++++++++++++++++------------------
 fs/lustre/llite/vvp_object.c     |  9 ++-----
 3 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 72aa564..a1e5e468 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1204,6 +1204,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 int ll_update_inode(struct inode *inode, struct lustre_md *md);
 void ll_update_inode_flags(struct inode *inode, unsigned int ext_flags);
 int ll_read_inode2(struct inode *inode, void *opaque);
+void ll_truncate_inode_pages_final(struct inode *inode);
 void ll_delete_inode(struct inode *inode);
 int ll_iocontrol(struct inode *inode, struct file *file,
 		 unsigned int cmd, unsigned long arg);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 66444fe..fe49030 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2471,6 +2471,33 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	return 0;
 }
 
+void ll_truncate_inode_pages_final(struct inode *inode)
+{
+	struct address_space *mapping = &inode->i_data;
+	unsigned long nrpages;
+	unsigned long flags;
+
+	truncate_inode_pages_final(mapping);
+
+	/* Workaround for LU-118: Note nrpages may not be totally updated when
+	 * truncate_inode_pages() returns, as there can be a page in the process
+	 * of deletion (inside __delete_from_page_cache()) in the specified
+	 * range. Thus mapping->nrpages can be non-zero when this function
+	 * returns even after truncation of the whole mapping.  Only do this if
+	 * npages isn't already zero.
+	 */
+	nrpages = mapping->nrpages;
+	if (nrpages) {
+		xa_lock_irqsave(&mapping->i_pages, flags);
+		nrpages = mapping->nrpages;
+		xa_unlock_irqrestore(&mapping->i_pages, flags);
+	} /* Workaround end */
+
+	LASSERTF(nrpages == 0, "%s: inode="DFID"(%p) nrpages=%lu, see https://jira.whamcloud.com/browse/LU-118\n",
+		 ll_i2sbi(inode)->ll_fsname,
+		 PFID(ll_inode2fid(inode)), inode, nrpages);
+}
+
 int ll_read_inode2(struct inode *inode, void *opaque)
 {
 	struct lustre_md *md = opaque;
@@ -2519,9 +2546,6 @@ int ll_read_inode2(struct inode *inode, void *opaque)
 void ll_delete_inode(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct address_space *mapping = &inode->i_data;
-	unsigned long nrpages;
-	unsigned long flags;
 
 	if (S_ISREG(inode->i_mode) && lli->lli_clob) {
 		/* It is last chance to write out dirty pages,
@@ -2534,27 +2558,8 @@ void ll_delete_inode(struct inode *inode)
 		cl_sync_file_range(inode, 0, OBD_OBJECT_EOF, inode->i_nlink ?
 				   CL_FSYNC_LOCAL : CL_FSYNC_DISCARD, 1);
 	}
-	truncate_inode_pages_final(mapping);
-
-	/* Workaround for LU-118: Note nrpages may not be totally updated when
-	 * truncate_inode_pages() returns, as there can be a page in the process
-	 * of deletion (inside __delete_from_page_cache()) in the specified
-	 * range. Thus mapping->nrpages can be non-zero when this function
-	 * returns even after truncation of the whole mapping.  Only do this if
-	 * npages isn't already zero.
-	 */
-	nrpages = mapping->nrpages;
-	if (nrpages) {
-		xa_lock_irqsave(&mapping->i_pages, flags);
-		nrpages = mapping->nrpages;
-		xa_unlock_irqrestore(&mapping->i_pages, flags);
-	} /* Workaround end */
-
-	LASSERTF(nrpages == 0,
-		 "%s: inode="DFID"(%p) nrpages=%lu, see https://jira.whamcloud.com/browse/LU-118\n",
-		 ll_i2sbi(inode)->ll_fsname,
-		 PFID(ll_inode2fid(inode)), inode, nrpages);
 
+	ll_truncate_inode_pages_final(inode);
 	ll_clear_inode(inode);
 	clear_inode(inode);
 }
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index e999caa..096d996 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -164,13 +164,8 @@ static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 		return rc;
 	}
 
-	truncate_inode_pages(inode->i_mapping, 0);
-	if (inode->i_mapping->nrpages) {
-		CDEBUG(D_VFSTRACE, DFID ": still has %lu pages remaining\n",
-		       PFID(lu_object_fid(&obj->co_lu)),
-		       inode->i_mapping->nrpages);
-		return -EIO;
-	}
+	ll_truncate_inode_pages_final(inode);
+	clear_bit(AS_EXITING, &inode->i_mapping->flags);
 
 	return 0;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
