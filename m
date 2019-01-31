From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:18 -0500
Subject: [lustre-devel] [PATCH 14/26] mdc: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The mdc code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_lib.c     | 126 ++++++-------
 drivers/staging/lustre/lustre/mdc/mdc_locks.c   |  80 ++++-----
 drivers/staging/lustre/lustre/mdc/mdc_reint.c   |   2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 228 ++++++++++++------------
 4 files changed, 218 insertions(+), 218 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 3dfc863..55d2ea1 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -153,30 +153,30 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     uid_t uid, gid_t gid, kernel_cap_t cap_effective,
 		     u64 rdev)
 {
-	struct mdt_rec_create	*rec;
-	char			*tmp;
-	u64			 flags;
+	struct mdt_rec_create *rec;
+	char *tmp;
+	u64 flags;
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_create));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
-	rec->cr_opcode   = REINT_CREATE;
-	rec->cr_fsuid    = uid;
-	rec->cr_fsgid    = gid;
-	rec->cr_cap      = cap_effective.cap[0];
-	rec->cr_fid1     = op_data->op_fid1;
-	rec->cr_fid2     = op_data->op_fid2;
-	rec->cr_mode     = mode;
-	rec->cr_rdev     = rdev;
-	rec->cr_time     = op_data->op_mod_time;
+	rec->cr_opcode = REINT_CREATE;
+	rec->cr_fsuid = uid;
+	rec->cr_fsgid = gid;
+	rec->cr_cap = cap_effective.cap[0];
+	rec->cr_fid1 = op_data->op_fid1;
+	rec->cr_fid2 = op_data->op_fid2;
+	rec->cr_mode = mode;
+	rec->cr_rdev = rdev;
+	rec->cr_time = op_data->op_mod_time;
 	rec->cr_suppgid1 = op_data->op_suppgids[0];
 	rec->cr_suppgid2 = op_data->op_suppgids[1];
 	flags = 0;
 	if (op_data->op_bias & MDS_CREATE_VOLATILE)
 		flags |= MDS_OPEN_VOLATILE;
 	set_mrc_cr_flags(rec, flags);
-	rec->cr_bias     = op_data->op_bias;
-	rec->cr_umask    = current_umask();
+	rec->cr_bias = op_data->op_bias;
+	rec->cr_umask = current_umask();
 
 	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 	if (data) {
@@ -229,21 +229,21 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
-	rec->cr_opcode   = REINT_OPEN;
-	rec->cr_fsuid    = from_kuid(&init_user_ns, current_fsuid());
-	rec->cr_fsgid    = from_kgid(&init_user_ns, current_fsgid());
-	rec->cr_cap      = current_cap().cap[0];
+	rec->cr_opcode = REINT_OPEN;
+	rec->cr_fsuid = from_kuid(&init_user_ns, current_fsuid());
+	rec->cr_fsgid = from_kgid(&init_user_ns, current_fsgid());
+	rec->cr_cap = current_cap().cap[0];
 	rec->cr_fid1 = op_data->op_fid1;
 	rec->cr_fid2 = op_data->op_fid2;
 
-	rec->cr_mode     = mode;
+	rec->cr_mode = mode;
 	cr_flags = mds_pack_open_flags(flags);
-	rec->cr_rdev     = rdev;
-	rec->cr_time     = op_data->op_mod_time;
+	rec->cr_rdev = rdev;
+	rec->cr_time = op_data->op_mod_time;
 	rec->cr_suppgid1 = op_data->op_suppgids[0];
 	rec->cr_suppgid2 = op_data->op_suppgids[1];
-	rec->cr_bias     = op_data->op_bias;
-	rec->cr_umask    = current_umask();
+	rec->cr_bias = op_data->op_bias;
+	rec->cr_umask = current_umask();
 	rec->cr_old_handle = op_data->op_handle;
 
 	if (op_data->op_name) {
@@ -313,24 +313,24 @@ static inline u64 attr_pack(unsigned int ia_valid, enum op_xvalid ia_xvalid)
 static void mdc_setattr_pack_rec(struct mdt_rec_setattr *rec,
 				 struct md_op_data *op_data)
 {
-	rec->sa_opcode  = REINT_SETATTR;
-	rec->sa_fsuid   = from_kuid(&init_user_ns, current_fsuid());
-	rec->sa_fsgid   = from_kgid(&init_user_ns, current_fsgid());
-	rec->sa_cap     = current_cap().cap[0];
+	rec->sa_opcode = REINT_SETATTR;
+	rec->sa_fsuid = from_kuid(&init_user_ns, current_fsuid());
+	rec->sa_fsgid = from_kgid(&init_user_ns, current_fsgid());
+	rec->sa_cap = current_cap().cap[0];
 	rec->sa_suppgid = -1;
 
-	rec->sa_fid    = op_data->op_fid1;
+	rec->sa_fid = op_data->op_fid1;
 	rec->sa_valid  = attr_pack(op_data->op_attr.ia_valid,
 				   op_data->op_xvalid);
-	rec->sa_mode   = op_data->op_attr.ia_mode;
-	rec->sa_uid    = from_kuid(&init_user_ns, op_data->op_attr.ia_uid);
-	rec->sa_gid    = from_kgid(&init_user_ns, op_data->op_attr.ia_gid);
+	rec->sa_mode = op_data->op_attr.ia_mode;
+	rec->sa_uid = from_kuid(&init_user_ns, op_data->op_attr.ia_uid);
+	rec->sa_gid = from_kgid(&init_user_ns, op_data->op_attr.ia_gid);
 	rec->sa_projid = op_data->op_projid;
-	rec->sa_size   = op_data->op_attr.ia_size;
+	rec->sa_size = op_data->op_attr.ia_size;
 	rec->sa_blocks = op_data->op_attr_blocks;
-	rec->sa_atime  = op_data->op_attr.ia_atime.tv_sec;
-	rec->sa_mtime  = op_data->op_attr.ia_mtime.tv_sec;
-	rec->sa_ctime  = op_data->op_attr.ia_ctime.tv_sec;
+	rec->sa_atime = op_data->op_attr.ia_atime.tv_sec;
+	rec->sa_mtime = op_data->op_attr.ia_mtime.tv_sec;
+	rec->sa_ctime = op_data->op_attr.ia_ctime.tv_sec;
 	rec->sa_attr_flags = op_data->op_attr_flags;
 	if ((op_data->op_attr.ia_valid & ATTR_GID) &&
 	    in_group_p(op_data->op_attr.ia_gid))
@@ -383,18 +383,18 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_unlink));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
-	rec->ul_opcode   = op_data->op_cli_flags & CLI_RM_ENTRY ?
-					REINT_RMENTRY : REINT_UNLINK;
-	rec->ul_fsuid    = op_data->op_fsuid;
-	rec->ul_fsgid    = op_data->op_fsgid;
-	rec->ul_cap      = op_data->op_cap.cap[0];
-	rec->ul_mode     = op_data->op_mode;
+	rec->ul_opcode = op_data->op_cli_flags & CLI_RM_ENTRY ?
+			 REINT_RMENTRY : REINT_UNLINK;
+	rec->ul_fsuid = op_data->op_fsuid;
+	rec->ul_fsgid = op_data->op_fsgid;
+	rec->ul_cap = op_data->op_cap.cap[0];
+	rec->ul_mode = op_data->op_mode;
 	rec->ul_suppgid1 = op_data->op_suppgids[0];
 	rec->ul_suppgid2 = -1;
-	rec->ul_fid1     = op_data->op_fid1;
-	rec->ul_fid2     = op_data->op_fid2;
-	rec->ul_time     = op_data->op_mod_time;
-	rec->ul_bias     = op_data->op_bias;
+	rec->ul_fid1 = op_data->op_fid1;
+	rec->ul_fid2 = op_data->op_fid2;
+	rec->ul_time = op_data->op_mod_time;
+	rec->ul_bias = op_data->op_bias;
 
 	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 }
@@ -406,16 +406,16 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_link));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
-	rec->lk_opcode   = REINT_LINK;
-	rec->lk_fsuid    = op_data->op_fsuid; /* current->fsuid; */
-	rec->lk_fsgid    = op_data->op_fsgid; /* current->fsgid; */
-	rec->lk_cap      = op_data->op_cap.cap[0]; /* current->cap_effective; */
+	rec->lk_opcode = REINT_LINK;
+	rec->lk_fsuid = op_data->op_fsuid; /* current->fsuid; */
+	rec->lk_fsgid = op_data->op_fsgid; /* current->fsgid; */
+	rec->lk_cap = op_data->op_cap.cap[0]; /* current->cap_effective; */
 	rec->lk_suppgid1 = op_data->op_suppgids[0];
 	rec->lk_suppgid2 = op_data->op_suppgids[1];
-	rec->lk_fid1     = op_data->op_fid1;
-	rec->lk_fid2     = op_data->op_fid2;
-	rec->lk_time     = op_data->op_mod_time;
-	rec->lk_bias     = op_data->op_bias;
+	rec->lk_fid1 = op_data->op_fid1;
+	rec->lk_fid2 = op_data->op_fid2;
+	rec->lk_time = op_data->op_mod_time;
+	rec->lk_bias = op_data->op_bias;
 
 	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 }
@@ -455,18 +455,18 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
-	rec->rn_opcode	 = op_data->op_cli_flags & CLI_MIGRATE ?
-				REINT_MIGRATE : REINT_RENAME;
-	rec->rn_fsuid    = op_data->op_fsuid;
-	rec->rn_fsgid    = op_data->op_fsgid;
-	rec->rn_cap      = op_data->op_cap.cap[0];
+	rec->rn_opcode = op_data->op_cli_flags & CLI_MIGRATE ?
+			 REINT_MIGRATE : REINT_RENAME;
+	rec->rn_fsuid = op_data->op_fsuid;
+	rec->rn_fsgid = op_data->op_fsgid;
+	rec->rn_cap = op_data->op_cap.cap[0];
 	rec->rn_suppgid1 = op_data->op_suppgids[0];
 	rec->rn_suppgid2 = op_data->op_suppgids[1];
-	rec->rn_fid1     = op_data->op_fid1;
-	rec->rn_fid2     = op_data->op_fid2;
-	rec->rn_time     = op_data->op_mod_time;
-	rec->rn_mode     = op_data->op_mode;
-	rec->rn_bias     = op_data->op_bias;
+	rec->rn_fid1 = op_data->op_fid1;
+	rec->rn_fid2 = op_data->op_fid2;
+	rec->rn_time = op_data->op_mod_time;
+	rec->rn_mode = op_data->op_mode;
+	rec->rn_bias = op_data->op_bias;
 
 	mdc_pack_name(req, &RMF_NAME, old, oldlen);
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index e16dce6..430c422 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -203,7 +203,7 @@ static inline void mdc_clear_replay_flag(struct ptlrpc_request *req, int rc)
 }
 
 /* Save a large LOV EA into the request buffer so that it is available
- * for replay.  We don't do this in the initial request because the
+ * for replay. We don't do this in the initial request because the
  * original request doesn't need this buffer (at most it sends just the
  * lov_mds_md) and it is a waste of RAM/bandwidth to send the empty
  * buffer and may also be difficult to allocate and save a very large
@@ -247,14 +247,14 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 		     struct md_op_data *op_data)
 {
 	struct ptlrpc_request *req;
-	struct obd_device     *obddev = class_exp2obd(exp);
-	struct ldlm_intent    *lit;
+	struct obd_device *obddev = class_exp2obd(exp);
+	struct ldlm_intent *lit;
 	const void *lmm = op_data->op_data;
 	u32 lmmsize = op_data->op_data_size;
 	LIST_HEAD(cancels);
-	int		    count = 0;
-	int		    mode;
-	int		    rc;
+	int count = 0;
+	int mode;
+	int rc;
 
 	it->it_create_mode = (it->it_create_mode & ~S_IFMT) | S_IFREG;
 
@@ -344,8 +344,8 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 			 struct md_op_data *op_data)
 {
 	u32 ea_vals_buf_size = GA_DEFAULT_EA_VAL_LEN * GA_DEFAULT_EA_NUM;
-	struct ptlrpc_request	*req;
-	struct ldlm_intent	*lit;
+	struct ptlrpc_request *req;
+	struct ldlm_intent *lit;
 	int rc, count = 0;
 	LIST_HEAD(cancels);
 
@@ -403,9 +403,9 @@ static struct ptlrpc_request *mdc_intent_unlink_pack(struct obd_export *exp,
 						     struct md_op_data *op_data)
 {
 	struct ptlrpc_request *req;
-	struct obd_device     *obddev = class_exp2obd(exp);
-	struct ldlm_intent    *lit;
-	int		    rc;
+	struct obd_device *obddev = class_exp2obd(exp);
+	struct ldlm_intent *lit;
+	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_LDLM_INTENT_UNLINK);
@@ -439,12 +439,12 @@ static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
 						     struct md_op_data *op_data)
 {
 	struct ptlrpc_request *req;
-	struct obd_device     *obddev = class_exp2obd(exp);
-	u64		       valid = OBD_MD_FLGETATTR | OBD_MD_FLEASIZE |
-				       OBD_MD_FLMODEASIZE | OBD_MD_FLDIREA |
-				       OBD_MD_MEA | OBD_MD_FLACL;
-	struct ldlm_intent    *lit;
-	int		    rc;
+	struct obd_device *obddev = class_exp2obd(exp);
+	u64 valid = OBD_MD_FLGETATTR | OBD_MD_FLEASIZE |
+		    OBD_MD_FLMODEASIZE | OBD_MD_FLDIREA |
+		    OBD_MD_MEA | OBD_MD_FLACL;
+	struct ldlm_intent *lit;
+	int rc;
 	u32 easize;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
@@ -484,10 +484,10 @@ static struct ptlrpc_request *mdc_intent_layout_pack(struct obd_export *exp,
 						     struct lookup_intent *it,
 						     struct md_op_data *op_data)
 {
-	struct obd_device     *obd = class_exp2obd(exp);
+	struct obd_device *obd = class_exp2obd(exp);
 	struct ptlrpc_request *req;
-	struct ldlm_intent    *lit;
-	struct layout_intent  *layout;
+	struct ldlm_intent *lit;
+	struct layout_intent *layout;
 	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
@@ -546,11 +546,11 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			      struct lustre_handle *lockh,
 			      int rc)
 {
-	struct req_capsule  *pill = &req->rq_pill;
+	struct req_capsule *pill = &req->rq_pill;
 	struct ldlm_request *lockreq;
-	struct ldlm_reply   *lockrep;
-	struct ldlm_lock    *lock;
-	void		*lvb_data = NULL;
+	struct ldlm_reply *lockrep;
+	struct ldlm_lock *lock;
+	void *lvb_data = NULL;
 	u32 lvb_len = 0;
 
 	LASSERT(rc >= 0);
@@ -985,7 +985,7 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 
 matching_lock:
 	/* If we already have a matching lock, then cancel the new
-	 * one.  We have to set the data here instead of in
+	 * one. We have to set the data here instead of in
 	 * mdc_enqueue, because we need to use the child's inode as
 	 * the l_ast_data to match, and that's not available until
 	 * intent_finish has performed the iget().)
@@ -1185,16 +1185,16 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 					      void *args, int rc)
 {
 	struct mdc_getattr_args  *ga = args;
-	struct obd_export	*exp = ga->ga_exp;
-	struct md_enqueue_info   *minfo = ga->ga_minfo;
+	struct obd_export *exp = ga->ga_exp;
+	struct md_enqueue_info *minfo = ga->ga_minfo;
 	struct ldlm_enqueue_info *einfo = &minfo->mi_einfo;
-	struct lookup_intent     *it;
-	struct lustre_handle     *lockh;
-	struct obd_device	*obddev;
-	struct ldlm_reply	 *lockrep;
-	u64		     flags = LDLM_FL_HAS_INTENT;
+	struct lookup_intent *it;
+	struct lustre_handle *lockh;
+	struct obd_device *obddev;
+	struct ldlm_reply *lockrep;
+	u64 flags = LDLM_FL_HAS_INTENT;
 
-	it    = &minfo->mi_it;
+	it = &minfo->mi_it;
 	lockh = &minfo->mi_lockh;
 
 	obddev = class_exp2obd(exp);
@@ -1230,17 +1230,17 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 int mdc_intent_getattr_async(struct obd_export *exp,
 			     struct md_enqueue_info *minfo)
 {
-	struct md_op_data       *op_data = &minfo->mi_data;
-	struct lookup_intent    *it = &minfo->mi_it;
-	struct ptlrpc_request   *req;
+	struct md_op_data *op_data = &minfo->mi_data;
+	struct lookup_intent *it = &minfo->mi_it;
+	struct ptlrpc_request *req;
 	struct mdc_getattr_args *ga;
-	struct obd_device       *obddev = class_exp2obd(exp);
-	struct ldlm_res_id       res_id;
+	struct obd_device *obddev = class_exp2obd(exp);
+	struct ldlm_res_id res_id;
 	union ldlm_policy_data policy = {
 		.l_inodebits = { MDS_INODELOCK_LOOKUP | MDS_INODELOCK_UPDATE }
 	};
-	int		      rc = 0;
-	u64		    flags = LDLM_FL_HAS_INTENT;
+	int rc = 0;
+	u64 flags = LDLM_FL_HAS_INTENT;
 
 	CDEBUG(D_DLMTRACE,
 	       "name: %.*s in inode " DFID ", intent: %s flags %#Lo\n",
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 765c908..e0e7b00 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -223,7 +223,7 @@ int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 		req->rq_sent = ktime_get_real_seconds() + resends;
 	}
 	level = LUSTRE_IMP_FULL;
- resend:
+resend:
 	rc = mdc_reint(req, level);
 
 	/* Resend if we were told to. */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 1aee1c5..3eb89ec 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -33,12 +33,12 @@
 
 #define DEBUG_SUBSYSTEM S_MDC
 
-# include <linux/module.h>
-# include <linux/pagemap.h>
-# include <linux/init.h>
-# include <linux/utsname.h>
-# include <linux/file.h>
-# include <linux/kthread.h>
+#include <linux/module.h>
+#include <linux/pagemap.h>
+#include <linux/init.h>
+#include <linux/utsname.h>
+#include <linux/file.h>
+#include <linux/kthread.h>
 #include <linux/prefetch.h>
 
 #include <lustre_errno.h>
@@ -96,8 +96,8 @@ static int mdc_get_root(struct obd_export *exp, const char *fileset,
 			struct lu_fid *rootfid)
 {
 	struct ptlrpc_request *req;
-	struct mdt_body       *body;
-	int		    rc;
+	struct mdt_body *body;
+	int rc;
 
 	if (fileset && !(exp_connect_flags(exp) & OBD_CONNECT_SUBTREE))
 		return -ENOTSUPP;
@@ -160,9 +160,9 @@ static int mdc_getattr_common(struct obd_export *exp,
 			      struct ptlrpc_request *req)
 {
 	struct req_capsule *pill = &req->rq_pill;
-	struct mdt_body    *body;
-	void	       *eadata;
-	int		 rc;
+	struct mdt_body *body;
+	void *eadata;
+	int rc;
 
 	/* Request message already built. */
 	rc = ptlrpc_queue_wait(req);
@@ -191,7 +191,7 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 		       struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
-	int		    rc;
+	int rc;
 
 	/* Single MDS without an LMV case */
 	if (op_data->op_flags & MF_GET_MDT_IDX) {
@@ -230,7 +230,7 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 			    struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
-	int		    rc;
+	int rc;
 
 	*request = NULL;
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
@@ -281,9 +281,9 @@ static int mdc_xattr_common(struct obd_export *exp,
 			    u32 suppgid, struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
-	int   xattr_namelen = 0;
+	int xattr_namelen = 0;
 	char *tmp;
-	int   rc;
+	int rc;
 
 	*request = NULL;
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), fmt);
@@ -333,19 +333,19 @@ static int mdc_xattr_common(struct obd_export *exp,
 		struct mdt_rec_setxattr *rec;
 
 		BUILD_BUG_ON(sizeof(struct mdt_rec_setxattr) !=
-			 sizeof(struct mdt_rec_reint));
+			     sizeof(struct mdt_rec_reint));
 		rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 		rec->sx_opcode = REINT_SETXATTR;
-		rec->sx_fsuid  = from_kuid(&init_user_ns, current_fsuid());
-		rec->sx_fsgid  = from_kgid(&init_user_ns, current_fsgid());
-		rec->sx_cap    = current_cap().cap[0];
+		rec->sx_fsuid = from_kuid(&init_user_ns, current_fsuid());
+		rec->sx_fsgid = from_kgid(&init_user_ns, current_fsgid());
+		rec->sx_cap = current_cap().cap[0];
 		rec->sx_suppgid1 = suppgid;
 		rec->sx_suppgid2 = -1;
-		rec->sx_fid    = *fid;
-		rec->sx_valid  = valid | OBD_MD_FLCTIME;
-		rec->sx_time   = ktime_get_real_seconds();
-		rec->sx_size   = output_size;
-		rec->sx_flags  = flags;
+		rec->sx_fid = *fid;
+		rec->sx_valid = valid | OBD_MD_FLCTIME;
+		rec->sx_time = ktime_get_real_seconds();
+		rec->sx_size = output_size;
+		rec->sx_flags = flags;
 
 	} else {
 		mdc_pack_body(req, fid, valid, output_size, suppgid, flags);
@@ -411,11 +411,11 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 #ifdef CONFIG_FS_POSIX_ACL
 static int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
 {
-	struct req_capsule     *pill = &req->rq_pill;
+	struct req_capsule *pill = &req->rq_pill;
 	struct mdt_body	*body = md->body;
-	struct posix_acl       *acl;
-	void		   *buf;
-	int		     rc;
+	struct posix_acl *acl;
+	void *buf;
+	int rc;
 
 	if (!body->mbo_aclsize)
 		return 0;
@@ -643,11 +643,11 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 			     struct obd_client_handle *och,
 			     struct lookup_intent *it)
 {
-	struct md_open_data   *mod;
+	struct md_open_data *mod;
 	struct mdt_rec_create *rec;
-	struct mdt_body       *body;
+	struct mdt_body *body;
 	struct ptlrpc_request *open_req = it->it_request;
-	struct obd_import     *imp = open_req->rq_import;
+	struct obd_import *imp = open_req->rq_import;
 
 	if (!open_req->rq_replay)
 		return 0;
@@ -758,11 +758,11 @@ static int mdc_clear_open_replay_data(struct obd_export *exp,
 static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		     struct md_open_data *mod, struct ptlrpc_request **request)
 {
-	struct obd_device     *obd = class_exp2obd(exp);
+	struct obd_device *obd = class_exp2obd(exp);
 	struct ptlrpc_request *req;
-	struct req_format     *req_fmt;
-	int                    rc;
-	int		       saved_rc = 0;
+	struct req_format *req_fmt;
+	int rc;
+	int saved_rc = 0;
 
 	if (op_data->op_bias & MDS_HSM_RELEASE) {
 		req_fmt = &RQF_MDS_INTENT_CLOSE;
@@ -1056,7 +1056,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, u64 *hash,
  *
  * A lu_dirpage is laid out as follows, where s = ldp_hash_start,
  * e = ldp_hash_end, f = ldp_flags, p = padding, and each "ent" is a
- * struct lu_dirent.  It has size up to LU_PAGE_SIZE. The ldp_hash_end
+ * struct lu_dirent. It has size up to LU_PAGE_SIZE. The ldp_hash_end
  * value is used as a cookie to request the next lu_dirpage in a
  * directory listing that spans multiple pages (two in this example):
  *   ________
@@ -1420,11 +1420,11 @@ static int mdc_statfs(const struct lu_env *env,
 		      struct obd_export *exp, struct obd_statfs *osfs,
 		      u64 max_age, u32 flags)
 {
-	struct obd_device     *obd = class_exp2obd(exp);
+	struct obd_device *obd = class_exp2obd(exp);
 	struct ptlrpc_request *req;
-	struct obd_statfs     *msfs;
-	struct obd_import     *imp = NULL;
-	int		    rc;
+	struct obd_statfs *msfs;
+	struct obd_import *imp = NULL;
+	int rc;
 
 	/*
 	 * Since the request might also come from lprocfs, so we need
@@ -1487,7 +1487,7 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 
 	/* Key is KEY_FID2PATH + getinfo_fid2path description */
 	keylen = cfs_size_round(sizeof(KEY_FID2PATH)) + sizeof(*gf) +
-		 sizeof(struct lu_fid);
+				sizeof(struct lu_fid);
 	key = kzalloc(keylen, GFP_NOFS);
 	if (!key)
 		return -ENOMEM;
@@ -1533,10 +1533,10 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 static int mdc_ioc_hsm_progress(struct obd_export *exp,
 				struct hsm_progress_kernel *hpk)
 {
-	struct obd_import		*imp = class_exp2cliimp(exp);
-	struct hsm_progress_kernel	*req_hpk;
-	struct ptlrpc_request		*req;
-	int				 rc;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	struct hsm_progress_kernel *req_hpk;
+	struct ptlrpc_request *req;
+	int rc;
 
 	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_HSM_PROGRESS,
 					LUSTRE_MDS_VERSION, MDS_HSM_PROGRESS);
@@ -1569,9 +1569,9 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 
 static int mdc_ioc_hsm_ct_register(struct obd_import *imp, u32 archives)
 {
-	u32			*archive_mask;
-	struct ptlrpc_request	*req;
-	int			 rc;
+	u32 *archive_mask;
+	struct ptlrpc_request *req;
+	int rc;
 
 	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_HSM_CT_REGISTER,
 					LUSTRE_MDS_VERSION,
@@ -1604,10 +1604,10 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, u32 archives)
 static int mdc_ioc_hsm_current_action(struct obd_export *exp,
 				      struct md_op_data *op_data)
 {
-	struct hsm_current_action	*hca = op_data->op_data;
-	struct hsm_current_action	*req_hca;
-	struct ptlrpc_request		*req;
-	int				 rc;
+	struct hsm_current_action *hca = op_data->op_data;
+	struct hsm_current_action *req_hca;
+	struct ptlrpc_request *req;
+	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_HSM_ACTION);
@@ -1645,8 +1645,8 @@ static int mdc_ioc_hsm_current_action(struct obd_export *exp,
 
 static int mdc_ioc_hsm_ct_unregister(struct obd_import *imp)
 {
-	struct ptlrpc_request	*req;
-	int			 rc;
+	struct ptlrpc_request *req;
+	int rc;
 
 	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_HSM_CT_UNREGISTER,
 					LUSTRE_MDS_VERSION,
@@ -1669,10 +1669,10 @@ static int mdc_ioc_hsm_ct_unregister(struct obd_import *imp)
 static int mdc_ioc_hsm_state_get(struct obd_export *exp,
 				 struct md_op_data *op_data)
 {
-	struct hsm_user_state	*hus = op_data->op_data;
-	struct hsm_user_state	*req_hus;
-	struct ptlrpc_request	*req;
-	int			 rc;
+	struct hsm_user_state *hus = op_data->op_data;
+	struct hsm_user_state *req_hus;
+	struct ptlrpc_request *req;
+	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_HSM_STATE_GET);
@@ -1710,10 +1710,10 @@ static int mdc_ioc_hsm_state_get(struct obd_export *exp,
 static int mdc_ioc_hsm_state_set(struct obd_export *exp,
 				 struct md_op_data *op_data)
 {
-	struct hsm_state_set	*hss = op_data->op_data;
-	struct hsm_state_set	*req_hss;
-	struct ptlrpc_request	*req;
-	int			 rc;
+	struct hsm_state_set *hss = op_data->op_data;
+	struct hsm_state_set *req_hss;
+	struct ptlrpc_request *req;
+	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_HSM_STATE_SET);
@@ -1750,12 +1750,12 @@ static int mdc_ioc_hsm_state_set(struct obd_export *exp,
 static int mdc_ioc_hsm_request(struct obd_export *exp,
 			       struct hsm_user_request *hur)
 {
-	struct obd_import	*imp = class_exp2cliimp(exp);
-	struct ptlrpc_request	*req;
-	struct hsm_request	*req_hr;
-	struct hsm_user_item	*req_hui;
-	char			*req_opaque;
-	int			 rc;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	struct ptlrpc_request *req;
+	struct hsm_request *req_hr;
+	struct hsm_user_item *req_hui;
+	char *req_opaque;
+	int rc;
 
 	req = ptlrpc_request_alloc(imp, &RQF_MDS_HSM_REQUEST);
 	if (!req) {
@@ -1818,9 +1818,9 @@ static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
 static int mdc_quotactl(struct obd_device *unused, struct obd_export *exp,
 			struct obd_quotactl *oqctl)
 {
-	struct ptlrpc_request   *req;
-	struct obd_quotactl     *oqc;
-	int		      rc;
+	struct ptlrpc_request *req;
+	struct obd_quotactl *oqc;
+	int rc;
 
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_MDS_QUOTACTL, LUSTRE_MDS_VERSION,
@@ -1860,8 +1860,8 @@ static int mdc_ioc_swap_layouts(struct obd_export *exp,
 				struct md_op_data *op_data)
 {
 	LIST_HEAD(cancels);
-	struct ptlrpc_request	*req;
-	int			 rc, count;
+	struct ptlrpc_request *req;
+	int rc, count;
 	struct mdc_swap_layouts *msl, *payload;
 
 	msl = op_data->op_data;
@@ -1965,7 +1965,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	 * bz20731, LU-592.
 	 */
 	case IOC_OBD_STATFS: {
-		struct obd_statfs stat_buf = {0};
+		struct obd_statfs stat_buf = { 0 };
 
 		if (*((u32 *)data->ioc_inlbuf2) != 0) {
 			rc = -ENODEV;
@@ -2044,10 +2044,10 @@ static int mdc_get_info_rpc(struct obd_export *exp,
 			    u32 keylen, void *key,
 			    int vallen, void *val)
 {
-	struct obd_import      *imp = class_exp2cliimp(exp);
-	struct ptlrpc_request  *req;
-	char		   *tmp;
-	int		     rc = -EINVAL;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	struct ptlrpc_request *req;
+	char *tmp;
+	int rc = -EINVAL;
 
 	req = ptlrpc_request_alloc(imp, &RQF_MDS_GET_INFO);
 	if (!req)
@@ -2104,7 +2104,7 @@ static void lustre_swab_hai(struct hsm_action_item *h)
 
 static void lustre_swab_hal(struct hsm_action_list *h)
 {
-	struct hsm_action_item	*hai;
+	struct hsm_action_item *hai;
 	u32 i;
 
 	__swab32s(&h->hal_version);
@@ -2127,9 +2127,9 @@ static void lustre_swab_kuch(struct kuc_hdr *l)
 static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
 				struct lustre_kernelcomm *lk)
 {
-	struct obd_import  *imp = class_exp2cliimp(exp);
-	u32		    archive = lk->lk_data;
-	int		    rc = 0;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	u32 archive = lk->lk_data;
+	int rc = 0;
 
 	if (lk->lk_group != KUC_GRP_HSM) {
 		CERROR("Bad copytool group %d\n", lk->lk_group);
@@ -2156,8 +2156,8 @@ static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
  */
 static int mdc_hsm_copytool_send(size_t len, void *val)
 {
-	struct kuc_hdr		*lh = (struct kuc_hdr *)val;
-	struct hsm_action_list	*hal = (struct hsm_action_list *)(lh + 1);
+	struct kuc_hdr *lh = (struct kuc_hdr *)val;
+	struct hsm_action_list *hal = (struct hsm_action_list *)(lh + 1);
 
 	if (len < sizeof(*lh) + sizeof(*hal)) {
 		CERROR("Short HSM message %zu < %zu\n", len,
@@ -2189,9 +2189,9 @@ static int mdc_hsm_copytool_send(size_t len, void *val)
  */
 static int mdc_hsm_ct_reregister(void *data, void *cb_arg)
 {
-	struct kkuc_ct_data	*kcd = data;
-	struct obd_import	*imp = (struct obd_import *)cb_arg;
-	int			 rc;
+	struct kkuc_ct_data *kcd = data;
+	struct obd_import *imp = (struct obd_import *)cb_arg;
+	int rc;
 
 	if (!kcd || kcd->kcd_magic != KKUC_CT_DATA_MAGIC)
 		return -EPROTO;
@@ -2213,8 +2213,8 @@ static int mdc_set_info_async(const struct lu_env *env,
 			      u32 vallen, void *val,
 			      struct ptlrpc_request_set *set)
 {
-	struct obd_import	*imp = class_exp2cliimp(exp);
-	int			 rc;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	int rc;
 
 	if (KEY_IS(KEY_READ_ONLY)) {
 		if (vallen != sizeof(int))
@@ -2310,7 +2310,7 @@ static int mdc_fsync(struct obd_export *exp, const struct lu_fid *fid,
 		     struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
-	int		    rc;
+	int rc;
 
 	*request = NULL;
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_SYNC);
@@ -2437,14 +2437,14 @@ static int mdc_resource_inode_free(struct ldlm_resource *res)
 }
 
 static struct ldlm_valblock_ops inode_lvbo = {
-	.lvbo_free = mdc_resource_inode_free,
+	.lvbo_free	= mdc_resource_inode_free,
 };
 
 static int mdc_llog_init(struct obd_device *obd)
 {
-	struct obd_llog_group	*olg = &obd->obd_olg;
-	struct llog_ctxt	*ctxt;
-	int			 rc;
+	struct obd_llog_group *olg = &obd->obd_olg;
+	struct llog_ctxt *ctxt;
+	int rc;
 
 	rc = llog_setup(NULL, obd, olg, LLOG_CHANGELOG_REPL_CTXT, obd,
 			&llog_client_ops);
@@ -2570,25 +2570,25 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 }
 
 static struct obd_ops mdc_obd_ops = {
-	.owner          = THIS_MODULE,
-	.setup          = mdc_setup,
-	.precleanup     = mdc_precleanup,
-	.cleanup        = mdc_cleanup,
-	.add_conn       = client_import_add_conn,
-	.del_conn       = client_import_del_conn,
-	.connect        = client_connect_import,
-	.disconnect     = client_disconnect_export,
-	.iocontrol      = mdc_iocontrol,
-	.set_info_async = mdc_set_info_async,
-	.statfs         = mdc_statfs,
-	.fid_init       = client_fid_init,
-	.fid_fini       = client_fid_fini,
-	.fid_alloc      = mdc_fid_alloc,
-	.import_event   = mdc_import_event,
-	.get_info       = mdc_get_info,
-	.process_config = mdc_process_config,
-	.get_uuid       = mdc_get_uuid,
-	.quotactl       = mdc_quotactl,
+	.owner			= THIS_MODULE,
+	.setup			= mdc_setup,
+	.precleanup		= mdc_precleanup,
+	.cleanup		= mdc_cleanup,
+	.add_conn		= client_import_add_conn,
+	.del_conn		= client_import_del_conn,
+	.connect		= client_connect_import,
+	.disconnect		= client_disconnect_export,
+	.iocontrol		= mdc_iocontrol,
+	.set_info_async		= mdc_set_info_async,
+	.statfs			= mdc_statfs,
+	.fid_init		= client_fid_init,
+	.fid_fini		= client_fid_fini,
+	.fid_alloc		= mdc_fid_alloc,
+	.import_event		= mdc_import_event,
+	.get_info		= mdc_get_info,
+	.process_config		= mdc_process_config,
+	.get_uuid		= mdc_get_uuid,
+	.quotactl		= mdc_quotactl,
 };
 
 static struct md_ops mdc_md_ops = {
@@ -2629,7 +2629,7 @@ static int __init mdc_init(void)
 		return rc;
 
 	return class_register_type(&mdc_obd_ops, &mdc_md_ops,
-				 LUSTRE_MDC_NAME, NULL);
+				   LUSTRE_MDC_NAME, NULL);
 }
 
 static void /*__exit*/ mdc_exit(void)
-- 
1.8.3.1
