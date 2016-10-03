From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:22 -0400
Subject: [lustre-devel] [PATCH 26/41] staging: lustre: llite: remove
	lli_has_smd
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Remove the lli_has_smd flag from struct ll_inode_info. The empty
layout case will be handled by the LOV layer. Remove the unused
function cl_local_size().

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/13690
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         |    7 -
 drivers/staging/lustre/lustre/llite/glimpse.c      |  134 +++++++-------------
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    1 -
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    8 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |    4 -
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   19 ---
 drivers/staging/lustre/lustre/lov/lov_io.c         |    9 ++-
 8 files changed, 55 insertions(+), 129 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 73ea446..94caf4f 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -632,12 +632,6 @@ restart:
 	if (!S_ISREG(inode->i_mode))
 		goto out_och_free;
 
-	if (!lli->lli_has_smd &&
-	    (cl_is_lov_delay_create(file->f_flags) ||
-	     (file->f_mode & FMODE_WRITE) == 0)) {
-		CDEBUG(D_INODE, "object creation was delayed\n");
-		goto out_och_free;
-	}
 	cl_lov_delay_create_clear(&file->f_flags);
 	goto out_och_free;
 
@@ -3227,7 +3221,6 @@ int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
 		       PFID(&lli->lli_fid), ll_layout_version_get(lli),
 		       cl.cl_layout_gen);
 		ll_layout_version_set(lli, cl.cl_layout_gen);
-		lli->lli_has_smd = lsm_has_objects(conf->u.coc_md->lsm);
 	}
 out:
 	cl_env_nested_put(&nest, env);
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 0d1ffad..504498d 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -80,66 +80,60 @@ blkcnt_t dirty_cnt(struct inode *inode)
 int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 		    struct inode *inode, struct cl_object *clob, int agl)
 {
-	struct ll_inode_info *lli   = ll_i2info(inode);
 	const struct lu_fid  *fid   = lu_object_fid(&clob->co_lu);
+	struct cl_lock *lock = vvp_env_lock(env);
+	struct cl_lock_descr *descr = &lock->cll_descr;
 	int result = 0;
 
 	CDEBUG(D_DLMTRACE, "Glimpsing inode " DFID "\n", PFID(fid));
-	if (lli->lli_has_smd) {
-		struct cl_lock *lock = vvp_env_lock(env);
-		struct cl_lock_descr *descr = &lock->cll_descr;
-
-		/* NOTE: this looks like DLM lock request, but it may
-		 *       not be one. Due to CEF_ASYNC flag (translated
-		 *       to LDLM_FL_HAS_INTENT by osc), this is
-		 *       glimpse request, that won't revoke any
-		 *       conflicting DLM locks held. Instead,
-		 *       ll_glimpse_callback() will be called on each
-		 *       client holding a DLM lock against this file,
-		 *       and resulting size will be returned for each
-		 *       stripe. DLM lock on [0, EOF] is acquired only
-		 *       if there were no conflicting locks. If there
-		 *       were conflicting locks, enqueuing or waiting
-		 *       fails with -ENAVAIL, but valid inode
-		 *       attributes are returned anyway.
-		 */
-		*descr = whole_file;
-		descr->cld_obj = clob;
-		descr->cld_mode = CLM_READ;
-		descr->cld_enq_flags = CEF_ASYNC | CEF_MUST;
-		if (agl)
-			descr->cld_enq_flags |= CEF_AGL;
-		/*
-		 * CEF_ASYNC is used because glimpse sub-locks cannot
-		 * deadlock (because they never conflict with other
-		 * locks) and, hence, can be enqueued out-of-order.
-		 *
-		 * CEF_MUST protects glimpse lock from conversion into
-		 * a lockless mode.
-		 */
-		result = cl_lock_request(env, io, lock);
-		if (result < 0)
-			return result;
-
-		if (!agl) {
-			ll_merge_attr(env, inode);
-			if (i_size_read(inode) > 0 && !inode->i_blocks) {
-				/*
-				 * LU-417: Add dirty pages block count
-				 * lest i_blocks reports 0, some "cp" or
-				 * "tar" may think it's a completely
-				 * sparse file and skip it.
-				 */
-				inode->i_blocks = dirty_cnt(inode);
-			}
-		}
 
-		cl_lock_release(env, lock);
-	} else {
-		CDEBUG(D_DLMTRACE, "No objects for inode\n");
+	/* NOTE: this looks like DLM lock request, but it may
+	 *       not be one. Due to CEF_ASYNC flag (translated
+	 *       to LDLM_FL_HAS_INTENT by osc), this is
+	 *       glimpse request, that won't revoke any
+	 *       conflicting DLM locks held. Instead,
+	 *       ll_glimpse_callback() will be called on each
+	 *       client holding a DLM lock against this file,
+	 *       and resulting size will be returned for each
+	 *       stripe. DLM lock on [0, EOF] is acquired only
+	 *       if there were no conflicting locks. If there
+	 *       were conflicting locks, enqueuing or waiting
+	 *       fails with -ENAVAIL, but valid inode
+	 *       attributes are returned anyway.
+	 */
+	*descr = whole_file;
+	descr->cld_obj = clob;
+	descr->cld_mode = CLM_READ;
+	descr->cld_enq_flags = CEF_ASYNC | CEF_MUST;
+	if (agl)
+		descr->cld_enq_flags |= CEF_AGL;
+	/*
+	 * CEF_ASYNC is used because glimpse sub-locks cannot
+	 * deadlock (because they never conflict with other
+	 * locks) and, hence, can be enqueued out-of-order.
+	 *
+	 * CEF_MUST protects glimpse lock from conversion into
+	 * a lockless mode.
+	 */
+	result = cl_lock_request(env, io, lock);
+	if (result < 0)
+		return result;
+
+	if (!agl) {
 		ll_merge_attr(env, inode);
+		if (i_size_read(inode) > 0 && !inode->i_blocks) {
+			/*
+			 * LU-417: Add dirty pages block count
+			 * lest i_blocks reports 0, some "cp" or
+			 * "tar" may think it's a completely
+			 * sparse file and skip it.
+			 */
+			inode->i_blocks = dirty_cnt(inode);
+		}
 	}
 
+	cl_lock_release(env, lock);
+
 	return result;
 }
 
@@ -209,39 +203,3 @@ again:
 	}
 	return result;
 }
-
-int cl_local_size(struct inode *inode)
-{
-	struct lu_env	   *env = NULL;
-	struct cl_io	    *io  = NULL;
-	struct cl_object	*clob;
-	int		      result;
-	int		      refcheck;
-
-	if (!ll_i2info(inode)->lli_has_smd)
-		return 0;
-
-	result = cl_io_get(inode, &env, &io, &refcheck);
-	if (result <= 0)
-		return result;
-
-	clob = io->ci_obj;
-	result = cl_io_init(env, io, CIT_MISC, clob);
-	if (result > 0) {
-		result = io->ci_result;
-	} else if (result == 0) {
-		struct cl_lock *lock = vvp_env_lock(env);
-
-		lock->cll_descr = whole_file;
-		lock->cll_descr.cld_enq_flags = CEF_PEEK;
-		lock->cll_descr.cld_obj = clob;
-		result = cl_lock_request(env, io, lock);
-		if (result == 0) {
-			ll_merge_attr(env, inode);
-			cl_lock_release(env, lock);
-		}
-	}
-	cl_io_fini(env, io);
-	cl_env_put(env, &refcheck);
-	return result;
-}
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index bd98ec2..4087db0 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -184,7 +184,6 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 			 * locked by I_NEW bit.
 			 */
 			lli->lli_clob = clob;
-			lli->lli_has_smd = lsm_has_objects(md->lsm);
 			lu_object_ref_add(&clob->co_lu, "inode", inode);
 		} else {
 			result = PTR_ERR(clob);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index c89e1b8..913e532 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -226,7 +226,6 @@ struct ll_inode_info {
 	 *      In the future, if more members are added only for directory,
 	 *      some of the following members can be moved into u.f.
 	 */
-	bool			    lli_has_smd;
 	struct cl_object	       *lli_clob;
 
 	/* mutex to request for layout lock exclusively. */
@@ -1348,7 +1347,6 @@ extern int cl_inode_fini_refcheck;
 
 int cl_file_inode_init(struct inode *inode, struct lustre_md *md);
 void cl_inode_fini(struct inode *inode);
-int cl_local_size(struct inode *inode);
 
 __u64 cl_fid_build_ino(const struct lu_fid *fid, int api32);
 __u32 cl_fid_build_gen(const struct lu_fid *fid);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 4b53119..5400cbe 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -798,7 +798,6 @@ void ll_lli_init(struct ll_inode_info *lli)
 	lli->lli_open_fd_exec_count = 0;
 	mutex_init(&lli->lli_och_mutex);
 	spin_lock_init(&lli->lli_agl_lock);
-	lli->lli_has_smd = false;
 	spin_lock_init(&lli->lli_layout_lock);
 	ll_layout_version_set(lli, CL_LAYOUT_GEN_NONE);
 	lli->lli_clob = NULL;
@@ -1290,7 +1289,6 @@ void ll_clear_inode(struct inode *inode)
 	 * cl_object still uses inode lsm.
 	 */
 	cl_inode_fini(inode);
-	lli->lli_has_smd = false;
 }
 
 #define TIMES_SET_FLAGS (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)
@@ -1688,9 +1686,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 
 	LASSERT((lsm != NULL) == ((body->mbo_valid & OBD_MD_FLEASIZE) != 0));
 	if (lsm) {
-		if (!lli->lli_has_smd &&
-		    !(sbi->ll_flags & LL_SBI_LAYOUT_LOCK))
-			cl_file_inode_init(inode, md);
+		cl_file_inode_init(inode, md);
 
 		lli->lli_maxbytes = lsm->lsm_maxbytes;
 		if (lli->lli_maxbytes > MAX_LFS_FILESIZE)
@@ -1802,8 +1798,6 @@ int ll_read_inode2(struct inode *inode, void *opaque)
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
 	       PFID(&lli->lli_fid), inode);
 
-	LASSERT(!lli->lli_has_smd);
-
 	/* Core attributes from the MDS first.  This is a new inode, and
 	 * the VFS doesn't zero times in the core inode so we have to do
 	 * it ourselves.  They will be overwritten by either MDS or OST
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 26f3a37..67010be 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -347,13 +347,9 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
 	loff_t file_offset = iocb->ki_pos;
 	ssize_t count = iov_iter_count(iter);
 	ssize_t tot_bytes = 0, result = 0;
-	struct ll_inode_info *lli = ll_i2info(inode);
 	long size = MAX_DIO_SIZE;
 	int refcheck;
 
-	if (!lli->lli_has_smd)
-		return -EBADF;
-
 	/* FIXME: io smaller than PAGE_SIZE is broken on ia64 ??? */
 	if ((file_offset & ~PAGE_MASK) || (count & ~PAGE_MASK))
 		return -EINVAL;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 420a649..cc0f3da 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -145,27 +145,8 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 		 */
 		unmap_mapping_range(conf->coc_inode->i_mapping,
 				    0, OBD_OBJECT_EOF, 0);
-
-		return 0;
 	}
 
-	if (conf->coc_opc != OBJECT_CONF_SET)
-		return 0;
-
-	if (conf->u.coc_md && conf->u.coc_md->lsm) {
-		CDEBUG(D_VFSTRACE, DFID ": layout version change: %u -> %u\n",
-		       PFID(&lli->lli_fid), lli->lli_layout_gen,
-		       conf->u.coc_md->lsm->lsm_layout_gen);
-
-		lli->lli_has_smd = lsm_has_objects(conf->u.coc_md->lsm);
-		ll_layout_version_set(lli, conf->u.coc_md->lsm->lsm_layout_gen);
-	} else {
-		CDEBUG(D_VFSTRACE, DFID ": layout nuked: %u.\n",
-		       PFID(&lli->lli_fid), lli->lli_layout_gen);
-
-		lli->lli_has_smd = false;
-		ll_layout_version_set(lli, CL_LAYOUT_GEN_EMPTY);
-	}
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index d6be613..a1d1ec9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -918,6 +918,13 @@ static void lov_empty_io_fini(const struct lu_env *env,
 		wake_up_all(&lov->lo_waitq);
 }
 
+static int lov_empty_io_submit(const struct lu_env *env,
+			       const struct cl_io_slice *ios,
+			       enum cl_req_type crt, struct cl_2queue *queue)
+{
+	return -EBADF;
+}
+
 static void lov_empty_impossible(const struct lu_env *env,
 				 struct cl_io_slice *ios)
 {
@@ -968,7 +975,7 @@ static const struct cl_io_operations lov_empty_io_ops = {
 			.cio_fini   = lov_empty_io_fini
 		}
 	},
-	.cio_submit                    = LOV_EMPTY_IMPOSSIBLE,
+	.cio_submit			= lov_empty_io_submit,
 	.cio_commit_async              = LOV_EMPTY_IMPOSSIBLE
 };
 
-- 
1.7.1
