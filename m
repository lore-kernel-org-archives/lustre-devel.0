Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DDA83C77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:14:03 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T81250Rz22Wp;
	Mon, 17 Apr 2023 06:54:57 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T3J2nd2z21KN
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:50:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C69F1100849C;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C5203375; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:22 -0400
Message-Id: <1681739243-29375-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/27] lustre: llite: fix LSOM blocks for
 ftruncate and close
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

From: Etienne AUJAMES <eaujames@ddn.com>

LSOM is updated on close and setattr request.
For the setattr, clients do not know the numbers blocks yet (OSTs
setattr requests have to finish). So the blocks number is set to 1 by
the server.

The close request send after a ftruncate() will wrongly update LSOM
back to its old blocks number. This is because clients do not update
the inode.i_blocks after an OST setattr.

Then the MDS will denied a client close request to update LSOM to its
correct blocks number. Only truncates are allowed to decrease the
blocks number (server side).

This patch force the client inode update at the end of an OST setattr.
And it tries (if no contention on the inode_size) to update the inode
at the end of an OST fsync or a sync IO.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16465
Lustre-commit: dfb08bbf77a1362f79 ("LU-16465 llite: fix LSOM blocks for ftruncate and close")
Signed-off-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49675
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c           | 36 +++++++++++++++++++++++++++---------
 fs/lustre/llite/llite_internal.h |  2 ++
 fs/lustre/llite/llite_lib.c      | 10 ++++++++++
 fs/lustre/llite/vvp_io.c         | 34 ++++++++++++++++++++++++++++++++--
 4 files changed, 71 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 0186db4..05a75ae 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1417,7 +1417,7 @@ static int ll_lease_file_resync(struct obd_client_handle *och,
 	return rc;
 }
 
-int ll_merge_attr(const struct lu_env *env, struct inode *inode)
+static int ll_merge_attr_nolock(const struct lu_env *env, struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct cl_object *obj = lli->lli_clob;
@@ -1427,10 +1427,7 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	s64 ctime;
 	int rc = 0;
 
-	ll_inode_size_lock(inode);
-
-	/*
-	 * merge timestamps the most recently obtained from MDS with
+	/* merge timestamps the most recently obtained from MDS with
 	 * timestamps obtained from OSTSs.
 	 *
 	 * Do not overwrite atime of inode because it may be refreshed
@@ -1463,7 +1460,7 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	if (rc != 0) {
 		if (rc == -ENODATA)
 			rc = 0;
-		goto out_size_unlock;
+		goto out;
 	}
 
 	if (atime < attr->cat_atime)
@@ -1475,8 +1472,8 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	if (mtime < attr->cat_mtime)
 		mtime = attr->cat_mtime;
 
-	CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
-	       PFID(&lli->lli_fid), attr->cat_size);
+	CDEBUG(D_VFSTRACE, DFID" updating i_size %llu i_block %llu\n",
+	       PFID(&lli->lli_fid), attr->cat_size, attr->cat_blocks);
 
 	if (fscrypt_require_key(inode) == -ENOKEY) {
 		/* Without the key, round up encrypted file size to next
@@ -1495,13 +1492,34 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	inode->i_mtime.tv_sec = mtime;
 	inode->i_atime.tv_sec = atime;
 	inode->i_ctime.tv_sec = ctime;
+out:
+	return rc;
+}
 
-out_size_unlock:
+int ll_merge_attr(const struct lu_env *env, struct inode *inode)
+{
+	int rc;
+
+	ll_inode_size_lock(inode);
+	rc = ll_merge_attr_nolock(env, inode);
 	ll_inode_size_unlock(inode);
 
 	return rc;
 }
 
+/* Use to update size and blocks on inode for LSOM if there is no contention */
+int ll_merge_attr_try(const struct lu_env *env, struct inode *inode)
+{
+	int rc = 0;
+
+	if (ll_inode_size_trylock(inode)) {
+		rc = ll_merge_attr_nolock(env, inode);
+		ll_inode_size_unlock(inode);
+	}
+
+	return rc;
+}
+
 /**
  * Set designated mirror for I/O.
  *
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 6088da08..88dbd6c 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -551,6 +551,7 @@ static inline void obd_connect_set_enc_fid2path(struct obd_connect_data *data)
 
 void ll_inode_size_lock(struct inode *inode);
 void ll_inode_size_unlock(struct inode *inode);
+int ll_inode_size_trylock(struct inode *inode);
 
 static inline struct ll_inode_info *ll_i2info(struct inode *inode)
 {
@@ -1248,6 +1249,7 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 		     struct ptlrpc_request **request, u64 valid);
 int ll_fsync(struct file *file, loff_t start, loff_t end, int data);
 int ll_merge_attr(const struct lu_env *env, struct inode *inode);
+int ll_merge_attr_try(const struct lu_env *env, struct inode *inode);
 int ll_fid2path(struct inode *inode, void __user *arg);
 int __ll_fid2path(struct inode *inode, struct getinfo_fid2path *gfout,
 		  size_t outsize, u32 pathlen_orig);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index b1bbeb3..2c286e8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2558,6 +2558,16 @@ void ll_inode_size_unlock(struct inode *inode)
 	mutex_unlock(&lli->lli_size_mutex);
 }
 
+int ll_inode_size_trylock(struct inode *inode)
+{
+	struct ll_inode_info *lli;
+
+	LASSERT(!S_ISDIR(inode->i_mode));
+
+	lli = ll_i2info(inode);
+	return mutex_trylock(&lli->lli_size_mutex);
+}
+
 void ll_update_inode_flags(struct inode *inode, unsigned int ext_flags)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 50c2872..31a3992 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -763,6 +763,10 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 		vvp_do_vmtruncate(inode, size);
 		mutex_unlock(&lli->lli_setattr_mutex);
 		trunc_sem_up_write(&lli->lli_trunc_sem);
+
+		/* Update size and blocks for LSOM */
+		if (!io->ci_ignore_layout)
+			ll_merge_attr(env, inode);
 	} else if (cl_io_is_fallocate(io)) {
 		int mode = io->u.ci_setattr.sa_falloc_mode;
 
@@ -1306,6 +1310,20 @@ static void vvp_io_rw_end(const struct lu_env *env,
 	trunc_sem_up_read(&lli->lli_trunc_sem);
 }
 
+static void vvp_io_write_end(const struct lu_env *env,
+			     const struct cl_io_slice *ios)
+{
+	struct inode *inode = vvp_object_inode(ios->cis_obj);
+	struct cl_io *io = ios->cis_io;
+
+	vvp_io_rw_end(env, ios);
+
+	/* Update size and blocks for LSOM (best effort) */
+	if (!io->ci_ignore_layout && cl_io_is_sync_write(io))
+		ll_merge_attr_try(env, inode);
+}
+
+
 static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 {
 	struct vm_fault *vmf = cfio->ft_vmf;
@@ -1559,6 +1577,17 @@ static int vvp_io_fsync_start(const struct lu_env *env,
 	return 0;
 }
 
+static void vvp_io_fsync_end(const struct lu_env *env,
+			     const struct cl_io_slice *ios)
+{
+	struct inode *inode = vvp_object_inode(ios->cis_obj);
+	struct cl_io *io = ios->cis_io;
+
+	/* Update size and blocks for LSOM (best effort) */
+	if (!io->ci_ignore_layout)
+		ll_merge_attr_try(env, inode);
+}
+
 static int vvp_io_read_ahead(const struct lu_env *env,
 			     const struct cl_io_slice *ios,
 			     pgoff_t start, struct cl_read_ahead *ra)
@@ -1639,7 +1668,7 @@ static void vvp_io_lseek_end(const struct lu_env *env,
 			.cio_iter_fini	= vvp_io_write_iter_fini,
 			.cio_lock	= vvp_io_write_lock,
 			.cio_start	= vvp_io_write_start,
-			.cio_end	= vvp_io_rw_end,
+			.cio_end	= vvp_io_write_end,
 			.cio_advance	= vvp_io_advance,
 		},
 		[CIT_SETATTR] = {
@@ -1658,7 +1687,8 @@ static void vvp_io_lseek_end(const struct lu_env *env,
 		},
 		[CIT_FSYNC] = {
 			.cio_start	= vvp_io_fsync_start,
-			.cio_fini	= vvp_io_fini
+			.cio_fini	= vvp_io_fini,
+			.cio_end	= vvp_io_fsync_end,
 		},
 		[CIT_GLIMPSE] = {
 			.cio_fini	= vvp_io_fini
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
