Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D2483C77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:54:49 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T1L3crmz21BM;
	Mon, 17 Apr 2023 06:49:10 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0SzS6Bbtz1y87
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:47:32 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 686A11005FA6;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 65E9B37D; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:02 -0400
Message-Id: <1681739243-29375-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/27] lustre: llite: call
 truncate_inode_pages() under inode lock
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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

From: Bobi Jam <bobijam@whamcloud.com>

truncate_inode_pages() is required to be called under (and serialised
by) inode lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16637
Lustre-commit: ef9be34478036db05 ("LU-16637 llite: call truncate_inode_pages() under inode lock")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50284
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  2 +-
 fs/lustre/llite/llite_lib.c      | 12 ++++++++----
 fs/lustre/llite/vvp_object.c     |  9 ++++++++-
 3 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index d8eee75..fdc0f89 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1287,7 +1287,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 void ll_update_inode_flags(struct inode *inode, unsigned int ext_flags);
 void ll_update_dir_depth(struct inode *dir, struct inode *inode);
 int ll_read_inode2(struct inode *inode, void *opaque);
-void ll_truncate_inode_pages_final(struct inode *inode);
+void ll_truncate_inode_pages_final(struct inode *inode, struct cl_io *io);
 void ll_delete_inode(struct inode *inode);
 int ll_iocontrol(struct inode *inode, struct file *file,
 		 unsigned int cmd, unsigned long arg);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 5a9bc61..049cd23 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2755,12 +2755,15 @@ void ll_update_dir_depth(struct inode *dir, struct inode *inode)
 	       PFID(&lli->lli_fid), lli->lli_dir_depth, lli->lli_inherit_depth);
 }
 
-void ll_truncate_inode_pages_final(struct inode *inode)
+void ll_truncate_inode_pages_final(struct inode *inode, struct cl_io *io)
 {
 	struct address_space *mapping = &inode->i_data;
 	unsigned long nrpages;
 	unsigned long flags;
 
+	LASSERTF(io == NULL || inode_is_locked(inode), "io %p (type %d)\n",
+		 io, io ? io->ci_type : 0);
+
 	truncate_inode_pages_final(mapping);
 
 	/* Workaround for LU-118: Note nrpages may not be totally updated when
@@ -2777,9 +2780,10 @@ void ll_truncate_inode_pages_final(struct inode *inode)
 		xa_unlock_irqrestore(&mapping->i_pages, flags);
 	} /* Workaround end */
 
-	LASSERTF(nrpages == 0, "%s: inode="DFID"(%p) nrpages=%lu, see https://jira.whamcloud.com/browse/LU-118\n",
+	LASSERTF(nrpages == 0, "%s: inode="DFID"(%p) nrpages=%lu io %p (io_type %d), see https://jira.whamcloud.com/browse/LU-118\n",
 		 ll_i2sbi(inode)->ll_fsname,
-		 PFID(ll_inode2fid(inode)), inode, nrpages);
+		 PFID(ll_inode2fid(inode)), inode, nrpages,
+		 io, io  ? io->ci_type : 0);
 }
 
 int ll_read_inode2(struct inode *inode, void *opaque)
@@ -2843,7 +2847,7 @@ void ll_delete_inode(struct inode *inode)
 				   CL_FSYNC_LOCAL : CL_FSYNC_DISCARD, 1);
 	}
 
-	ll_truncate_inode_pages_final(inode);
+	ll_truncate_inode_pages_final(inode, NULL);
 	ll_clear_inode(inode);
 	clear_inode(inode);
 }
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 0ef055f..302f900 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -153,6 +153,7 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 
 static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 {
+	struct cl_io *io = vvp_env_io(env)->vui_cl.cis_io;
 	struct inode *inode = vvp_object_inode(obj);
 	int rc;
 
@@ -163,9 +164,15 @@ static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 		return rc;
 	}
 
-	ll_truncate_inode_pages_final(inode);
+	if (io != NULL)
+		inode_lock(inode);
+
+	ll_truncate_inode_pages_final(inode, io);
 	mapping_clear_exiting(inode->i_mapping);
 
+	if (io != NULL)
+		inode_unlock(inode);
+
 	return 0;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
