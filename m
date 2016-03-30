From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:37 -0400
Subject: [lustre-devel] [PATCH v2 16/46] staging/lustre/llite: remove some
	cl wrappers
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-17-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

In llite remove the wrapper functions and macros:
  cl_i2info()
  cl_i2sbi()
  cl_iattr2fd()
  cl_inode_info
  cl_inode_mode()
  cl_inode_{a,m,c}time()
  cl_isize_{read,write,write_nolock}()

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/12850
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/dir.c          |  2 +-
 drivers/staging/lustre/lustre/llite/file.c         |  8 ++--
 drivers/staging/lustre/lustre/llite/glimpse.c      | 10 ++---
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 45 +++++++++++-----------
 .../staging/lustre/lustre/llite/llite_internal.h   | 32 ---------------
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  4 +-
 7 files changed, 35 insertions(+), 68 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 4e0a3e5..2ca4b0e 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -191,7 +191,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
 		/* Checked by mdc_readpage() */
 		if (body->valid & OBD_MD_FLSIZE)
-			cl_isize_write(inode, body->size);
+			i_size_write(inode, body->size);
 
 		nrdpgs = (request->rq_bulk->bd_nob_transferred+PAGE_CACHE_SIZE-1)
 			 >> PAGE_CACHE_SHIFT;
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 8fc9da0..c3c258f 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1036,7 +1036,7 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
 	       PFID(&lli->lli_fid), attr->cat_size);
 
-	cl_isize_write_nolock(inode, attr->cat_size);
+	i_size_write(inode, attr->cat_size);
 
 	inode->i_blocks = attr->cat_blocks;
 
@@ -1592,7 +1592,7 @@ ll_get_grouplock(struct inode *inode, struct file *file, unsigned long arg)
 	LASSERT(!fd->fd_grouplock.cg_lock);
 	spin_unlock(&lli->lli_lock);
 
-	rc = cl_get_grouplock(cl_i2info(inode)->lli_clob,
+	rc = cl_get_grouplock(ll_i2info(inode)->lli_clob,
 			      arg, (file->f_flags & O_NONBLOCK), &grouplock);
 	if (rc)
 		return rc;
@@ -2614,7 +2614,7 @@ int cl_sync_file_range(struct inode *inode, loff_t start, loff_t end,
 		return PTR_ERR(env);
 
 	io = ccc_env_thread_io(env);
-	io->ci_obj = cl_i2info(inode)->lli_clob;
+	io->ci_obj = ll_i2info(inode)->lli_clob;
 	io->ci_ignore_layout = ignore_layout;
 
 	/* initialize parameters for sync */
@@ -3629,7 +3629,7 @@ int ll_layout_restore(struct inode *inode)
 	       sizeof(hur->hur_user_item[0].hui_fid));
 	hur->hur_user_item[0].hui_extent.length = -1;
 	hur->hur_request.hr_itemcount = 1;
-	rc = obd_iocontrol(LL_IOC_HSM_REQUEST, cl_i2sbi(inode)->ll_md_exp,
+	rc = obd_iocontrol(LL_IOC_HSM_REQUEST, ll_i2sbi(inode)->ll_md_exp,
 			   len, hur, NULL);
 	kfree(hur);
 	return rc;
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 88bc7c9..9b0e2ec 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -87,7 +87,7 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 		    struct inode *inode, struct cl_object *clob, int agl)
 {
 	struct cl_lock_descr *descr = &ccc_env_info(env)->cti_descr;
-	struct cl_inode_info *lli   = cl_i2info(inode);
+	struct ll_inode_info *lli   = ll_i2info(inode);
 	const struct lu_fid  *fid   = lu_object_fid(&clob->co_lu);
 	struct ccc_io	*cio   = ccc_env_io(env);
 	struct cl_lock       *lock;
@@ -140,7 +140,7 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 			result = cl_wait(env, lock);
 			if (result == 0) {
 				ll_merge_attr(env, inode);
-				if (cl_isize_read(inode) > 0 &&
+				if (i_size_read(inode) > 0 &&
 				    inode->i_blocks == 0) {
 					/*
 					 * LU-417: Add dirty pages block count
@@ -167,11 +167,11 @@ static int cl_io_get(struct inode *inode, struct lu_env **envout,
 {
 	struct lu_env	  *env;
 	struct cl_io	   *io;
-	struct cl_inode_info   *lli = cl_i2info(inode);
+	struct ll_inode_info	*lli = ll_i2info(inode);
 	struct cl_object       *clob = lli->lli_clob;
 	int result;
 
-	if (S_ISREG(cl_inode_mode(inode))) {
+	if (S_ISREG(inode->i_mode)) {
 		env = cl_env_get(refcheck);
 		if (!IS_ERR(env)) {
 			io = ccc_env_thread_io(env);
@@ -240,7 +240,7 @@ int cl_local_size(struct inode *inode)
 	int		      result;
 	int		      refcheck;
 
-	if (!cl_i2info(inode)->lli_has_smd)
+	if (!ll_i2info(inode)->lli_has_smd)
 		return 0;
 
 	result = cl_io_get(inode, &env, &io, &refcheck);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 4871d0f..fde96d3 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -417,9 +417,9 @@ int ccc_object_glimpse(const struct lu_env *env,
 {
 	struct inode *inode = ccc_object_inode(obj);
 
-	lvb->lvb_mtime = cl_inode_mtime(inode);
-	lvb->lvb_atime = cl_inode_atime(inode);
-	lvb->lvb_ctime = cl_inode_ctime(inode);
+	lvb->lvb_mtime = LTIME_S(inode->i_mtime);
+	lvb->lvb_atime = LTIME_S(inode->i_atime);
+	lvb->lvb_ctime = LTIME_S(inode->i_ctime);
 	/*
 	 * LU-417: Add dirty pages block count lest i_blocks reports 0, some
 	 * "cp" or "tar" on remote node may think it's a completely sparse file
@@ -731,7 +731,7 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 				 * linux-2.6.18-128.1.1 miss to do that.
 				 * --bug 17336
 				 */
-				loff_t size = cl_isize_read(inode);
+				loff_t size = i_size_read(inode);
 				loff_t cur_index = start >> PAGE_CACHE_SHIFT;
 				loff_t size_index = (size - 1) >>
 						    PAGE_CACHE_SHIFT;
@@ -752,11 +752,11 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 		 * which will always be >= the kms value here.
 		 * b=11081
 		 */
-		if (cl_isize_read(inode) < kms) {
-			cl_isize_write_nolock(inode, kms);
+		if (i_size_read(inode) < kms) {
+			i_size_write(inode, kms);
 			CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
 			       PFID(lu_object_fid(&obj->co_lu)),
-			       (__u64)cl_isize_read(inode));
+			       (__u64)i_size_read(inode));
 		}
 	}
 	ccc_object_size_unlock(obj);
@@ -816,14 +816,14 @@ void ccc_req_attr_set(const struct lu_env *env,
 	if (slice->crs_req->crq_type == CRT_WRITE) {
 		if (flags & OBD_MD_FLEPOCH) {
 			oa->o_valid |= OBD_MD_FLEPOCH;
-			oa->o_ioepoch = cl_i2info(inode)->lli_ioepoch;
+			oa->o_ioepoch = ll_i2info(inode)->lli_ioepoch;
 			valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME |
 				       OBD_MD_FLUID | OBD_MD_FLGID;
 		}
 	}
 	obdo_from_inode(oa, inode, valid_flags & flags);
-	obdo_set_parent_fid(oa, &cl_i2info(inode)->lli_fid);
-	memcpy(attr->cra_jobid, cl_i2info(inode)->lli_jobid,
+	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
+	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid,
 	       JOBSTATS_JOBID_SIZE);
 }
 
@@ -844,7 +844,7 @@ int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
 		return PTR_ERR(env);
 
 	io = ccc_env_thread_io(env);
-	io->ci_obj = cl_i2info(inode)->lli_clob;
+	io->ci_obj = ll_i2info(inode)->lli_clob;
 
 	io->u.ci_setattr.sa_attr.lvb_atime = LTIME_S(attr->ia_atime);
 	io->u.ci_setattr.sa_attr.lvb_mtime = LTIME_S(attr->ia_mtime);
@@ -860,7 +860,7 @@ again:
 			/* populate the file descriptor for ftruncate to honor
 			 * group lock - see LU-787
 			 */
-			cio->cui_fd = cl_iattr2fd(inode, attr);
+			cio->cui_fd = LUSTRE_FPRIVATE(attr->ia_file);
 
 		result = cl_io_loop(env, io);
 	} else {
@@ -949,11 +949,10 @@ struct page *cl2vm_page(const struct cl_page_slice *slice)
 int ccc_object_invariant(const struct cl_object *obj)
 {
 	struct inode	 *inode = ccc_object_inode(obj);
-	struct cl_inode_info *lli   = cl_i2info(inode);
+	struct ll_inode_info	*lli	= ll_i2info(inode);
 
-	return (S_ISREG(cl_inode_mode(inode)) ||
-		/* i_mode of unlinked inode is zeroed. */
-		cl_inode_mode(inode) == 0) && lli->lli_clob == obj;
+	return (S_ISREG(inode->i_mode) || inode->i_mode == 0) &&
+	       lli->lli_clob == obj;
 }
 
 struct inode *ccc_object_inode(const struct cl_object *obj)
@@ -973,7 +972,7 @@ struct inode *ccc_object_inode(const struct cl_object *obj)
 int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 {
 	struct lu_env	*env;
-	struct cl_inode_info *lli;
+	struct ll_inode_info *lli;
 	struct cl_object     *clob;
 	struct lu_site       *site;
 	struct lu_fid	*fid;
@@ -987,14 +986,14 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 	int refcheck;
 
 	LASSERT(md->body->valid & OBD_MD_FLID);
-	LASSERT(S_ISREG(cl_inode_mode(inode)));
+	LASSERT(S_ISREG(inode->i_mode));
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	site = cl_i2sbi(inode)->ll_site;
-	lli  = cl_i2info(inode);
+	site = ll_i2sbi(inode)->ll_site;
+	lli  = ll_i2info(inode);
 	fid  = &lli->lli_fid;
 	LASSERT(fid_is_sane(fid));
 
@@ -1071,7 +1070,7 @@ static void cl_object_put_last(struct lu_env *env, struct cl_object *obj)
 void cl_inode_fini(struct inode *inode)
 {
 	struct lu_env	   *env;
-	struct cl_inode_info    *lli  = cl_i2info(inode);
+	struct ll_inode_info    *lli  = ll_i2info(inode);
 	struct cl_object	*clob = lli->lli_clob;
 	int refcheck;
 	int emergency;
@@ -1168,10 +1167,10 @@ __u32 cl_fid_build_gen(const struct lu_fid *fid)
  */
 struct lov_stripe_md *ccc_inode_lsm_get(struct inode *inode)
 {
-	return lov_lsm_get(cl_i2info(inode)->lli_clob);
+	return lov_lsm_get(ll_i2info(inode)->lli_clob);
 }
 
 inline void ccc_inode_lsm_put(struct inode *inode, struct lov_stripe_md *lsm)
 {
-	lov_lsm_put(cl_i2info(inode)->lli_clob, lsm);
+	lov_lsm_put(ll_i2info(inode)->lli_clob, lsm);
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index c1d747a..ffed507 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1293,38 +1293,6 @@ typedef enum llioc_iter (*llioc_callback_t)(struct inode *inode,
 void *ll_iocontrol_register(llioc_callback_t cb, int count, unsigned int *cmd);
 void ll_iocontrol_unregister(void *magic);
 
-/* lclient compat stuff */
-#define cl_inode_info ll_inode_info
-#define cl_i2info(info) ll_i2info(info)
-#define cl_inode_mode(inode) ((inode)->i_mode)
-#define cl_i2sbi ll_i2sbi
-
-static inline struct ll_file_data *cl_iattr2fd(struct inode *inode,
-					       const struct iattr *attr)
-{
-	LASSERT(attr->ia_valid & ATTR_FILE);
-	return LUSTRE_FPRIVATE(attr->ia_file);
-}
-
-static inline void cl_isize_write_nolock(struct inode *inode, loff_t kms)
-{
-	LASSERT(mutex_is_locked(&ll_i2info(inode)->lli_size_mutex));
-	i_size_write(inode, kms);
-}
-
-static inline void cl_isize_write(struct inode *inode, loff_t kms)
-{
-	ll_inode_size_lock(inode);
-	i_size_write(inode, kms);
-	ll_inode_size_unlock(inode);
-}
-
-#define cl_isize_read(inode)	     i_size_read(inode)
-
-#define cl_inode_atime(inode) LTIME_S((inode)->i_atime)
-#define cl_inode_ctime(inode) LTIME_S((inode)->i_ctime)
-#define cl_inode_mtime(inode) LTIME_S((inode)->i_mtime)
-
 int cl_sync_file_range(struct inode *inode, loff_t start, loff_t end,
 		       enum cl_fsync_mode mode, int ignore_layout);
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 0b4e0db..041d221 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1698,7 +1698,7 @@ void ll_read_inode2(struct inode *inode, void *opaque)
 
 void ll_delete_inode(struct inode *inode)
 {
-	struct cl_inode_info *lli = cl_i2info(inode);
+	struct ll_inode_info *lli = ll_i2info(inode);
 
 	if (S_ISREG(inode->i_mode) && lli->lli_clob)
 		/* discard all dirty pages before truncating them, required by
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index b9a1d01..d03eb2b 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -112,7 +112,7 @@ static int vvp_attr_set(const struct lu_env *env, struct cl_object *obj,
 	if (valid & CAT_CTIME)
 		inode->i_ctime.tv_sec = attr->cat_ctime;
 	if (0 && valid & CAT_SIZE)
-		cl_isize_write_nolock(inode, attr->cat_size);
+		i_size_write(inode, attr->cat_size);
 	/* not currently necessary */
 	if (0 && valid & (CAT_UID|CAT_GID|CAT_SIZE))
 		mark_inode_dirty(inode);
@@ -196,7 +196,7 @@ static const struct lu_object_operations vvp_lu_obj_ops = {
 
 struct ccc_object *cl_inode2ccc(struct inode *inode)
 {
-	struct cl_inode_info *lli = cl_i2info(inode);
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct cl_object     *obj = lli->lli_clob;
 	struct lu_object     *lu;
 
-- 
2.1.0
