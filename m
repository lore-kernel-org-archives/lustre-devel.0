From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:52 -0500
Subject: [lustre-devel] [PATCH 18/28] lustre: pfl: dynamic layout
 modification with write/truncate
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

* in lov_init_composite(), skip init sub object without LCME_FL_INIT
  layout component.
* issue layout intent RPC during write/trunc ops when try to write to
  an un-init-ed component (even if at the lock stage).
* After layout intent RPC issued, restart the IO.
* get rid of unused lov_layout_operations::llo_install() interface.
* add an empty mdt_layout_change() interface to handle intent layout
  write RPC.

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9008
Reviewed-on: https://review.whamcloud.com/25317
WC-bug-id: https://jira.whamcloud.com/browse/LU-9307
Reviewed-on: https://review.whamcloud.com/26456
WC-bug-id: https://jira.whamcloud.com/browse/LU-9311
Reviewed-on: https://review.whamcloud.com/26474
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  18 ++--
 drivers/staging/lustre/lustre/include/cl_object.h  |   5 +
 drivers/staging/lustre/lustre/include/lustre_sec.h |   4 +-
 drivers/staging/lustre/lustre/llite/file.c         | 104 ++++++++++++++-------
 .../staging/lustre/lustre/llite/llite_internal.h   |   1 +
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  36 ++++++-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  51 +++++++---
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  22 +++++
 drivers/staging/lustre/lustre/lov/lov_io.c         |  49 ++++++++--
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  11 ++-
 drivers/staging/lustre/lustre/lov/lov_object.c     |  53 +++++------
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  19 ++--
 drivers/staging/lustre/lustre/lov/lov_page.c       |   2 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  79 +++++++++-------
 drivers/staging/lustre/lustre/obdclass/genops.c    |  16 +++-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   6 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |   7 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   5 +-
 18 files changed, 338 insertions(+), 150 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index f7a065e..d1693e3 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -2772,22 +2772,22 @@ struct getparent {
 } __packed;
 
 enum {
-	LAYOUT_INTENT_ACCESS    = 0,
-	LAYOUT_INTENT_READ      = 1,
-	LAYOUT_INTENT_WRITE     = 2,
-	LAYOUT_INTENT_GLIMPSE   = 3,
-	LAYOUT_INTENT_TRUNC     = 4,
-	LAYOUT_INTENT_RELEASE   = 5,
-	LAYOUT_INTENT_RESTORE   = 6
+	LAYOUT_INTENT_ACCESS    = 0,	/** generic access */
+	LAYOUT_INTENT_READ      = 1,	/** not used */
+	LAYOUT_INTENT_WRITE     = 2,	/** write file, for comp layout */
+	LAYOUT_INTENT_GLIMPSE   = 3,	/** not used */
+	LAYOUT_INTENT_TRUNC     = 4,	/** truncate file, for comp layout */
+	LAYOUT_INTENT_RELEASE   = 5,	/** reserved for HSM release */
+	LAYOUT_INTENT_RESTORE   = 6	/** reserved for HSM restore */
 };
 
 /* enqueue layout lock with intent */
 struct layout_intent {
-	__u32 li_opc; /* intent operation for enqueue, read, write etc */
+	__u32 li_opc;	/* intent operation for enqueue, read, write etc */
 	__u32 li_flags;
 	__u64 li_start;
 	__u64 li_end;
-};
+} __packed;
 
 /**
  * On the wire version of hsm_progress structure.
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index d0edeb7c..57ced0f 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1843,6 +1843,11 @@ struct cl_io {
 	 */
 			     ci_ignore_layout:1,
 	/**
+	 * Need MDS intervention to complete a write. This usually means the
+	 * corresponding component is not initialized for the writing extent.
+	 */
+			ci_need_write_intent:1,
+	/**
 	 * Check if layout changed after the IO finishes. Mainly for HSM
 	 * requirement. If IO occurs to openning files, it doesn't need to
 	 * verify layout because HSM won't release openning files.
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index d35bcbc..43ff594 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -65,6 +65,7 @@
 struct ptlrpc_svc_ctx;
 struct ptlrpc_cli_ctx;
 struct ptlrpc_ctx_ops;
+struct req_msg_field;
 
 /**
  * \addtogroup flavor flavor
@@ -976,7 +977,8 @@ int cli_ctx_is_eternal(struct ptlrpc_cli_ctx *ctx)
 int sptlrpc_cli_alloc_repbuf(struct ptlrpc_request *req, int msgsize);
 void sptlrpc_cli_free_repbuf(struct ptlrpc_request *req);
 int sptlrpc_cli_enlarge_reqbuf(struct ptlrpc_request *req,
-			       int segment, int newsize);
+			       const struct req_msg_field *field,
+			       int newsize);
 int  sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 				    struct ptlrpc_request **req_ret);
 void sptlrpc_cli_finish_early_reply(struct ptlrpc_request *early_req);
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 8d67d1a..009e9e8 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3680,6 +3680,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	lock_res_and_lock(lock);
 	lvb_ready = ldlm_is_lvb_ready(lock);
 	unlock_res_and_lock(lock);
+
 	/* checking lvb_ready is racy but this is okay. The worst case is
 	 * that multi processes may configure the file on the same time.
 	 */
@@ -3709,7 +3710,6 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 
 	/* refresh layout failed, need to wait */
 	wait_layout = rc == -EBUSY;
-
 out:
 	LDLM_LOCK_PUT(lock);
 	ldlm_lock_decref(lockh, mode);
@@ -3735,38 +3735,37 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	return rc;
 }
 
-static int ll_layout_refresh_locked(struct inode *inode)
+/**
+ * Issue layout intent RPC to MDS.
+ * @inode	file inode
+ * @intent	layout intent
+ *
+ * RETURNS:
+ * 0		on success
+ * retval < 0	error code
+ */
+static int ll_layout_intent(struct inode *inode, struct layout_intent *intent)
 {
 	struct ll_inode_info  *lli = ll_i2info(inode);
 	struct ll_sb_info     *sbi = ll_i2sbi(inode);
 	struct md_op_data     *op_data;
 	struct lookup_intent   it;
-	struct lustre_handle   lockh;
-	enum ldlm_mode	       mode;
 	struct ptlrpc_request *req;
 	int rc;
 
-again:
-	/* mostly layout lock is caching on the local side, so try to match
-	 * it before grabbing layout lock mutex.
-	 */
-	mode = ll_take_md_lock(inode, MDS_INODELOCK_LAYOUT, &lockh, 0,
-			       LCK_CR | LCK_CW | LCK_PR | LCK_PW);
-	if (mode != 0) { /* hit cached lock */
-		rc = ll_layout_lock_set(&lockh, mode, inode);
-		if (rc == -EAGAIN)
-			goto again;
-		return rc;
-	}
-
 	op_data = ll_prep_md_op_data(NULL, inode, inode, NULL,
 				     0, 0, LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	/* have to enqueue one */
+	op_data->op_data = intent;
+	op_data->op_data_size = sizeof(*intent);
+
 	memset(&it, 0, sizeof(it));
 	it.it_op = IT_LAYOUT;
+	if (intent->li_opc == LAYOUT_INTENT_WRITE ||
+	    intent->li_opc == LAYOUT_INTENT_TRUNC)
+		it.it_flags = FMODE_WRITE;
 
 	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file " DFID "(%p)",
 			  ll_get_fsname(inode->i_sb, NULL, 0),
@@ -3779,18 +3778,11 @@ static int ll_layout_refresh_locked(struct inode *inode)
 
 	ll_finish_md_op_data(op_data);
 
-	mode = it.it_lock_mode;
-	it.it_lock_mode = 0;
-	ll_intent_drop_lock(&it);
-
-	if (rc == 0) {
-		/* set lock data in case this is a new lock */
+	/* set lock data in case this is a new lock */
+	if (!rc)
 		ll_set_lock_data(sbi->ll_md_exp, inode, &it, NULL);
-		lockh.cookie = it.it_lock_handle;
-		rc = ll_layout_lock_set(&lockh, mode, inode);
-		if (rc == -EAGAIN)
-			goto again;
-	}
+
+	ll_intent_drop_lock(&it);
 
 	return rc;
 }
@@ -3812,6 +3804,11 @@ int ll_layout_refresh(struct inode *inode, __u32 *gen)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct layout_intent intent = {
+		.li_opc = LAYOUT_INTENT_ACCESS,
+	};
+	struct lustre_handle lockh;
+	enum ldlm_mode mode;
 	int rc;
 
 	*gen = ll_layout_version_get(lli);
@@ -3825,18 +3822,57 @@ int ll_layout_refresh(struct inode *inode, __u32 *gen)
 	/* take layout lock mutex to enqueue layout lock exclusively. */
 	mutex_lock(&lli->lli_layout_mutex);
 
-	rc = ll_layout_refresh_locked(inode);
-	if (rc < 0)
-		goto out;
+	while (1) {
+		/* mostly layout lock is caching on the local side, so try to
+		 * match it before grabbing layout lock mutex.
+		 */
+		mode = ll_take_md_lock(inode, MDS_INODELOCK_LAYOUT, &lockh, 0,
+				       LCK_CR | LCK_CW | LCK_PR | LCK_PW);
+		if (mode != 0) { /* hit cached lock */
+			rc = ll_layout_lock_set(&lockh, mode, inode);
+			if (rc == -EAGAIN)
+				continue;
+			break;
+		}
 
-	*gen = ll_layout_version_get(lli);
-out:
+		rc = ll_layout_intent(inode, &intent);
+		if (rc != 0)
+			break;
+	}
+
+	if (rc == 0)
+		*gen = ll_layout_version_get(lli);
 	mutex_unlock(&lli->lli_layout_mutex);
 
 	return rc;
 }
 
 /**
+ * Issue layout intent RPC indicating where in a file an IO is about to write.
+ *
+ * \param[in] inode    file inode.
+ * \param[in] start    start offset of fille in bytes where an IO is about to
+ *                     write.
+ * \param[in] end      exclusive end offset in bytes of the write range.
+ *
+ * \retval 0   on success
+ * \retval < 0 error code
+ */
+int ll_layout_write_intent(struct inode *inode, u64 start, u64 end)
+{
+	struct layout_intent intent = {
+		.li_opc = LAYOUT_INTENT_WRITE,
+		.li_start = start,
+		.li_end = end,
+	};
+	int rc;
+
+	rc = ll_layout_intent(inode, &intent);
+
+	return rc;
+}
+
+/**
  *  This function send a restore request to the MDT
  */
 int ll_layout_restore(struct inode *inode, loff_t offset, __u64 length)
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index e3f5450..b2a1f54 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1320,6 +1320,7 @@ static inline void d_lustre_revalidate(struct dentry *dentry)
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf);
 int ll_layout_refresh(struct inode *inode, __u32 *gen);
 int ll_layout_restore(struct inode *inode, loff_t start, __u64 length);
+int ll_layout_write_intent(struct inode *inode, u64 start, u64 end);
 
 int ll_xattr_init(void);
 void ll_xattr_fini(void);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index d6b27ba..5323fea 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -281,18 +281,18 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	struct cl_object *obj = io->ci_obj;
 	struct vvp_io    *vio = cl2vvp_io(env, ios);
 	struct inode *inode = vvp_object_inode(obj);
+	int rc;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	CDEBUG(D_VFSTRACE, DFID
-	       " ignore/verify layout %d/%d, layout version %d restore needed %d\n",
+	       " ignore/verify layout %d/%d, layout version %d need write layout %d, restore needed %d\n",
 	       PFID(lu_object_fid(&obj->co_lu)),
 	       io->ci_ignore_layout, io->ci_verify_layout,
-	       vio->vui_layout_gen, io->ci_restore_needed);
+	       vio->vui_layout_gen, io->ci_need_write_intent,
+	       io->ci_restore_needed);
 
 	if (io->ci_restore_needed) {
-		int	rc;
-
 		/* file was detected release, we need to restore it
 		 * before finishing the io
 		 */
@@ -318,6 +318,34 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		}
 	}
 
+	/**
+	 * dynamic layout change needed, send layout intent
+	 * RPC.
+	 */
+	if (io->ci_need_write_intent) {
+		loff_t start = 0;
+		loff_t end = 0;
+
+		LASSERT(io->ci_type == CIT_WRITE || cl_io_is_trunc(io));
+
+		io->ci_need_write_intent = 0;
+
+		if (io->ci_type == CIT_WRITE) {
+			start = io->u.ci_rw.crw_pos;
+			end = io->u.ci_rw.crw_pos + io->u.ci_rw.crw_count;
+		} else {
+			end = io->u.ci_setattr.sa_attr.lvb_size;
+		}
+
+		CDEBUG(D_VFSTRACE, DFID" type %d [%llx, %llx)\n",
+		       PFID(lu_object_fid(&obj->co_lu)), io->ci_type,
+		       start, end);
+		rc = ll_layout_write_intent(inode, start, end);
+		io->ci_result = rc;
+		if (!rc)
+			io->ci_need_restart = 1;
+	}
+
 	if (!io->ci_ignore_layout && io->ci_verify_layout) {
 		__u32 gen = 0;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 124c12d..fd67fc9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -117,6 +117,10 @@ static void lsme_free(struct lov_stripe_md_entry *lsme)
 	unsigned int stripe_count = lsme->lsme_stripe_count;
 	unsigned int i;
 
+	if (!lsme_inited(lsme) ||
+	    lsme->lsme_pattern & LOV_PATTERN_F_RELEASED)
+		stripe_count = 0;
+
 	for (i = 0; i < stripe_count; i++)
 		kmem_cache_free(lov_oinfo_slab, lsme->lsme_oinfo[i]);
 
@@ -141,7 +145,7 @@ void lsm_free(struct lov_stripe_md *lsm)
  */
 static struct lov_stripe_md_entry *
 lsme_unpack(struct lov_obd *lov, struct lov_mds_md *lmm, size_t buf_size,
-	    const char *pool_name, struct lov_ost_data_v1 *objects,
+	    const char *pool_name, bool inited, struct lov_ost_data_v1 *objects,
 	    loff_t *maxbytes)
 {
 	struct lov_stripe_md_entry *lsme;
@@ -159,7 +163,7 @@ void lsm_free(struct lov_stripe_md *lsm)
 		return ERR_PTR(-EINVAL);
 
 	pattern = le32_to_cpu(lmm->lmm_pattern);
-	if (pattern & LOV_PATTERN_F_RELEASED)
+	if (pattern & LOV_PATTERN_F_RELEASED || !inited)
 		stripe_count = 0;
 	else
 		stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
@@ -185,8 +189,10 @@ void lsm_free(struct lov_stripe_md *lsm)
 
 	lsme->lsme_magic = magic;
 	lsme->lsme_pattern = pattern;
+	lsme->lsme_flags = 0;
 	lsme->lsme_stripe_size = le32_to_cpu(lmm->lmm_stripe_size);
-	lsme->lsme_stripe_count = stripe_count;
+	/* preserve the possible -1 stripe count for uninstantiated component */
+	lsme->lsme_stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
 	lsme->lsme_layout_gen = le16_to_cpu(lmm->lmm_layout_gen);
 
 	if (pool_name) {
@@ -282,10 +288,12 @@ void lsm_free(struct lov_stripe_md *lsm)
 
 	pattern = le32_to_cpu(lmm->lmm_pattern);
 
-	lsme = lsme_unpack(lov, lmm, buf_size, pool_name, objects, &maxbytes);
+	lsme = lsme_unpack(lov, lmm, buf_size, pool_name, true, objects,
+			   &maxbytes);
 	if (IS_ERR(lsme))
 		return ERR_CAST(lsme);
 
+	lsme->lsme_flags = LCME_FL_INIT;
 	lsme->lsme_extent.e_start = 0;
 	lsme->lsme_extent.e_end = LUSTRE_EOF;
 
@@ -371,7 +379,7 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 
 static struct lov_stripe_md_entry *
 lsme_unpack_comp(struct lov_obd *lov, struct lov_mds_md *lmm,
-		 size_t lmm_buf_size, loff_t *maxbytes)
+		 size_t lmm_buf_size, bool inited, loff_t *maxbytes)
 {
 	unsigned int stripe_count;
 	unsigned int magic;
@@ -380,6 +388,10 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 	if (stripe_count == 0)
 		return ERR_PTR(-EINVAL);
 
+	/* un-instantiated lmm contains no ost id info, i.e. lov_ost_data_v1 */
+	if (!inited)
+		stripe_count = 0;
+
 	magic = le32_to_cpu(lmm->lmm_magic);
 	if (magic != LOV_MAGIC_V1 && magic != LOV_MAGIC_V3)
 		return ERR_PTR(-EINVAL);
@@ -389,12 +401,12 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 
 	if (magic == LOV_MAGIC_V1) {
 		return lsme_unpack(lov, lmm, lmm_buf_size, NULL,
-				   lmm->lmm_objects, maxbytes);
+				   inited, lmm->lmm_objects, maxbytes);
 	} else {
 		struct lov_mds_md_v3 *lmm3 = (struct lov_mds_md_v3 *)lmm;
 
 		return lsme_unpack(lov, lmm, lmm_buf_size, lmm3->lmm_pool_name,
-				   lmm3->lmm_objects, maxbytes);
+				   inited, lmm3->lmm_objects, maxbytes);
 	}
 }
 
@@ -440,6 +452,7 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 		blob = (char *)lcm + blob_offset;
 
 		lsme = lsme_unpack_comp(lov, blob, blob_size,
+					le32_to_cpu(lcme->lcme_flags) & LCME_FL_INIT,
 					(i == entry_count - 1) ? &maxbytes :
 					NULL);
 		if (IS_ERR(lsme)) {
@@ -452,6 +465,7 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 
 		lsm->lsm_entries[i] = lsme;
 		lsme->lsme_id = le32_to_cpu(lcme->lcme_id);
+		lsme->lsme_flags = le32_to_cpu(lcme->lcme_flags);
 		lu_extent_le_to_cpu(&lsme->lsme_extent, &lcme->lcme_extent);
 
 		if (i == entry_count - 1) {
@@ -507,7 +521,7 @@ const struct lsm_operations *lsm_op_find(int magic)
 
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 {
-	int i;
+	int i, j;
 
 	CDEBUG(level,
 	       "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, refc: %d, entry: %u, layout_gen %u\n",
@@ -519,10 +533,23 @@ void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 		struct lov_stripe_md_entry *lse = lsm->lsm_entries[i];
 
 		CDEBUG(level,
-		       DEXT ": id: %u, magic 0x%08X, stripe count %u, size %u, layout_gen %u, pool: [" LOV_POOLNAMEF "]\n",
-		       PEXT(&lse->lsme_extent), lse->lsme_id, lse->lsme_magic,
-		       lse->lsme_stripe_count, lse->lsme_stripe_size,
-		       lse->lsme_layout_gen, lse->lsme_pool_name);
+		       DEXT ": id: %u, flags: %x, magic 0x%08X, layout_gen %u, stripe count %u, sstripe size %u, pool: [" LOV_POOLNAMEF "]\n",
+		       PEXT(&lse->lsme_extent), lse->lsme_id, lse->lsme_flags,
+		       lse->lsme_magic, lse->lsme_layout_gen,
+                       lse->lsme_stripe_count, lse->lsme_stripe_size,
+		       lse->lsme_pool_name);
+		if (!lsme_inited(lse) ||
+		    lse->lsme_pattern & LOV_PATTERN_F_RELEASED)
+			continue;
+
+		for (j = 0; j < lse->lsme_stripe_count; j++) {
+			CDEBUG(level,
+			       "   oinfo:%p: ostid: " DOSTID " ost idx: %d gen: %d\n",
+			       lse->lsme_oinfo[j],
+			       POSTID(&lse->lsme_oinfo[j]->loi_oi),
+			       lse->lsme_oinfo[j]->loi_ost_idx,
+			       lse->lsme_oinfo[j]->loi_ost_gen);
+		}
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index e8102df..5e3eae7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -48,6 +48,7 @@ struct lov_stripe_md_entry {
 	struct lu_extent	lsme_extent;
 	u32			lsme_id;
 	u32			lsme_magic;
+	u32			lsme_flags;
 	u32			lsme_pattern;
 	u32			lsme_stripe_size;
 	u16			lsme_stripe_count;
@@ -56,6 +57,17 @@ struct lov_stripe_md_entry {
 	struct lov_oinfo       *lsme_oinfo[];
 };
 
+static inline void copy_lsm_entry(struct lov_stripe_md_entry *dst,
+				  struct lov_stripe_md_entry *src)
+{
+	unsigned int i;
+
+	for (i = 0; i < src->lsme_stripe_count; i++)
+		*dst->lsme_oinfo[i] = *src->lsme_oinfo[i];
+
+	memcpy(dst, src, offsetof(typeof(*src), lsme_oinfo));
+}
+
 struct lov_stripe_md {
 	atomic_t	lsm_refc;
 	spinlock_t	lsm_lock;
@@ -74,6 +86,16 @@ struct lov_stripe_md {
 	struct lov_stripe_md_entry *lsm_entries[];
 };
 
+static inline bool lsme_inited(const struct lov_stripe_md_entry *lsme)
+{
+	return lsme->lsme_flags & LCME_FL_INIT;
+}
+
+static inline bool lsm_entry_inited(const struct lov_stripe_md *lsm, int index)
+{
+	return lsme_inited(lsm->lsm_entries[index]);
+}
+
 static inline size_t lov_comp_md_size(const struct lov_stripe_md *lsm)
 {
 	struct lov_stripe_md_entry *lsme;
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 70908b1..8a1bb85 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -394,6 +394,11 @@ static int lov_io_iter_init(const struct lu_env *env,
 		u64 start;
 		u64 end;
 
+		CDEBUG(D_VFSTRACE, "component[%d] flags %#x\n",
+		       index, lsm->lsm_entries[index]->lsme_flags);
+		if (!lsm_entry_inited(lsm, index))
+			break;
+
 		index++;
 		if (!lu_extent_is_overlapped(&ext, &le->lle_extent))
 			continue;
@@ -442,6 +447,7 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
 	struct lov_io	*lio = cl2lov_io(env, ios);
+	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	struct cl_io	 *io  = ios->cis_io;
 	u64 start = io->u.ci_rw.crw_pos;
 	struct lov_stripe_md_entry *lse;
@@ -454,7 +460,7 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 	if (cl_io_is_append(io))
 		return lov_io_iter_init(env, ios);
 
-	index = lov_lsm_entry(lio->lis_object->lo_lsm, io->u.ci_rw.crw_pos);
+	index = lov_lsm_entry(lsm, io->u.ci_rw.crw_pos);
 	if (index < 0) { /* non-existing layout component */
 		if (io->ci_type == CIT_READ) {
 			/* TODO: it needs to detect the next component and
@@ -476,7 +482,9 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 	if (next <= start * ssize)
 		next = ~0ull;
 
-	LASSERT(io->u.ci_rw.crw_pos >= lse->lsme_extent.e_start);
+	LASSERTF(io->u.ci_rw.crw_pos >= lse->lsme_extent.e_start,
+		 "pos %lld, [%lld, %lld]\n", io->u.ci_rw.crw_pos,
+		 lse->lsme_extent.e_start, lse->lsme_extent.e_end);
 	next = min_t(u64, next, lse->lsme_extent.e_end);
 	next = min_t(u64, next, lio->lis_io_endpos);
 
@@ -486,9 +494,16 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 	lio->lis_endpos = io->u.ci_rw.crw_pos + io->u.ci_rw.crw_count;
 
 	CDEBUG(D_VFSTRACE,
-	       "stripe: %llu chunk: [%llu, %llu) %llu\n",
-	       (u64)start, lio->lis_pos, lio->lis_endpos,
-	       (u64)lio->lis_io_endpos);
+	       "stripe: %llu chunk: [%llu, %llu] %llu\n",
+	       start, lio->lis_pos, lio->lis_endpos,
+	       lio->lis_io_endpos);
+
+	index = lov_lsm_entry(lsm, lio->lis_endpos - 1);
+	if (index > 0 && !lsm_entry_inited(lsm, index)) {
+		io->ci_need_write_intent = 1;
+		io->ci_result = -ENODATA;
+		return io->ci_result;
+	}
 
 	/*
 	 * XXX The following call should be optimized: we know, that
@@ -497,6 +512,26 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 	return lov_io_iter_init(env, ios);
 }
 
+static int lov_io_setattr_iter_init(const struct lu_env *env,
+				    const struct cl_io_slice *ios)
+{
+	struct lov_io *lio = cl2lov_io(env, ios);
+	struct cl_io *io = ios->cis_io;
+	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
+	int index;
+
+	if (cl_io_is_trunc(io) && lio->lis_pos) {
+		index = lov_lsm_entry(lsm, lio->lis_pos - 1);
+		if (index > 0 && !lsm_entry_inited(lsm, index)) {
+			io->ci_need_write_intent = 1;
+			io->ci_result = -ENODATA;
+			return io->ci_result;
+		}
+	}
+
+	return lov_io_iter_init(env, ios);
+}
+
 static int lov_io_call(const struct lu_env *env, struct lov_io *lio,
 		       int (*iofunc)(const struct lu_env *, struct cl_io *))
 {
@@ -617,7 +652,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 
 	offset = cl_offset(obj, start);
 	index = lov_lsm_entry(loo->lo_lsm, offset);
-	if (index < 0)
+	if (index < 0 || !lsm_entry_inited(loo->lo_lsm, index))
 		return -ENODATA;
 
 	stripe = lov_stripe_number(loo->lo_lsm, index, offset);
@@ -870,7 +905,7 @@ static void lov_io_fsync_end(const struct lu_env *env,
 		},
 		[CIT_SETATTR] = {
 			.cio_fini      = lov_io_fini,
-			.cio_iter_init = lov_io_iter_init,
+			.cio_iter_init = lov_io_setattr_iter_init,
 			.cio_iter_fini = lov_io_iter_fini,
 			.cio_lock      = lov_io_lock,
 			.cio_unlock    = lov_io_unlock,
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index ba31be4..9a46424 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -132,7 +132,7 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 
 	nr = 0;
 	for (index = lov_lsm_entry(lov->lo_lsm, ext.e_start);
-	     index != -1 && index < lov->lo_lsm->lsm_entry_count; index++) {
+	     index >= 0 && index < lov->lo_lsm->lsm_entry_count; index++) {
 		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
 
 		/* assume lsm entries are sorted. */
@@ -147,8 +147,11 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 				nr++;
 		}
 	}
-	if (nr == 0)
-		return ERR_PTR(-EINVAL);
+	/**
+	 * Aggressive lock request (from cl_setattr_ost) which asks for
+	 * [eof, -1) lock, could come across uninstantiated layout extent,
+	 * hence a 0 nr is possible.
+	 */
 
 	lovlck = kvzalloc(offsetof(struct lov_lock, lls_sub[nr]),
 				 GFP_NOFS);
@@ -158,7 +161,7 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 	lovlck->lls_nr = nr;
 	nr = 0;
 	for (index = lov_lsm_entry(lov->lo_lsm, ext.e_start);
-	     index < lov->lo_lsm->lsm_entry_count; index++) {
+	     index >= 0 && index < lov->lo_lsm->lsm_entry_count; index++) {
 		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
 
 		/* assume lsm entries are sorted. */
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 66fb6f5..680d232 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -64,8 +64,6 @@ struct lov_layout_operations {
 			  union lov_layout_state *state);
 	void (*llo_fini)(const struct lu_env *env, struct lov_object *lov,
 			 union lov_layout_state *state);
-	void (*llo_install)(const struct lu_env *env, struct lov_object *lov,
-			    union lov_layout_state *state);
 	int  (*llo_print)(const struct lu_env *env, void *cookie,
 			  lu_printer_t p, const struct lu_object *o);
 	int  (*llo_page_init)(const struct lu_env *env, struct cl_object *obj,
@@ -92,16 +90,6 @@ static void lov_lsm_put(struct lov_stripe_md *lsm)
  * Lov object layout operations.
  *
  */
-
-static void lov_install_empty(const struct lu_env *env,
-			      struct lov_object *lov,
-			      union  lov_layout_state *state)
-{
-	/*
-	 * File without objects.
-	 */
-}
-
 static int lov_init_empty(const struct lu_env *env, struct lov_device *dev,
 			  struct lov_object *lov, struct lov_stripe_md *lsm,
 			  const struct cl_object_conf *conf,
@@ -110,12 +98,6 @@ static int lov_init_empty(const struct lu_env *env, struct lov_device *dev,
 	return 0;
 }
 
-static void lov_install_composite(const struct lu_env *env,
-				  struct lov_object *lov,
-				  union lov_layout_state *state)
-{
-}
-
 static struct cl_object *lov_sub_find(const struct lu_env *env,
 				      struct cl_device *dev,
 				      const struct lu_fid *fid,
@@ -328,6 +310,14 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		struct lov_layout_entry *le = &comp->lo_entries[i];
 
 		le->lle_extent = lsm->lsm_entries[i]->lsme_extent;
+		/**
+		 * If the component has not been init-ed on MDS side, for
+		 * PFL layout, we'd know that the components beyond this one
+		 * will be dynamically init-ed later on file write/trunc ops.
+		 */
+		if (!lsm_entry_inited(lsm, i))
+			continue;
+
 		result = lov_init_raid0(env, dev, lov, i, &le->lle_raid0);
 		if (result < 0)
 			break;
@@ -471,13 +461,15 @@ static int lov_delete_composite(const struct lu_env *env,
 				struct lov_object *lov,
 				union lov_layout_state *state)
 {
+	struct lov_layout_composite *comp = &state->composite;
 	struct lov_layout_entry *entry;
 
 	dump_lsm(D_INODE, lov->lo_lsm);
 
 	lov_layout_wait(env, lov);
-	lov_foreach_layout_entry(lov, entry)
-		lov_delete_raid0(env, lov, &entry->lle_raid0);
+	if (comp->lo_entries)
+		lov_foreach_layout_entry(lov, entry)
+			lov_delete_raid0(env, lov, &entry->lle_raid0);
 
 	return 0;
 }
@@ -565,9 +557,9 @@ static int lov_print_composite(const struct lu_env *env, void *cookie,
 	for (i = 0; i < lsm->lsm_entry_count; i++) {
 		struct lov_stripe_md_entry *lse = lsm->lsm_entries[i];
 
-		(*p)(env, cookie, DEXT ": { 0x%08X, %u, %u, %u, %u }\n",
+		(*p)(env, cookie, DEXT ": { 0x%08X, %u, %u, %#x, %u, %u }\n",
 		     PEXT(&lse->lsme_extent), lse->lsme_magic,
-		     lse->lsme_id, lse->lsme_layout_gen,
+		     lse->lsme_id, lse->lsme_layout_gen, lse->lsme_flags,
 		     lse->lsme_stripe_count, lse->lsme_stripe_size);
 		lov_print_raid0(env, cookie, p, lov_r0(lov, i));
 	}
@@ -664,6 +656,10 @@ static int lov_attr_get_composite(const struct lu_env *env,
 		struct lov_layout_raid0 *r0 = &entry->lle_raid0;
 		struct cl_attr *lov_attr = &r0->lo_attr;
 
+		/* PFL: This component has not been init-ed. */
+		if (!lsm_entry_inited(lov->lo_lsm, index))
+			break;
+
 		result = lov_attr_get_raid0(env, lov, index, r0);
 		if (result != 0)
 			break;
@@ -691,7 +687,6 @@ static int lov_attr_get_composite(const struct lu_env *env,
 		.llo_init      = lov_init_empty,
 		.llo_delete    = lov_delete_empty,
 		.llo_fini      = lov_fini_empty,
-		.llo_install   = lov_install_empty,
 		.llo_print     = lov_print_empty,
 		.llo_page_init = lov_page_init_empty,
 		.llo_lock_init = lov_lock_init_empty,
@@ -702,7 +697,6 @@ static int lov_attr_get_composite(const struct lu_env *env,
 		.llo_init      = lov_init_released,
 		.llo_delete    = lov_delete_empty,
 		.llo_fini      = lov_fini_released,
-		.llo_install   = lov_install_empty,
 		.llo_print     = lov_print_released,
 		.llo_page_init = lov_page_init_empty,
 		.llo_lock_init = lov_lock_init_empty,
@@ -713,7 +707,6 @@ static int lov_attr_get_composite(const struct lu_env *env,
 		.llo_init	= lov_init_composite,
 		.llo_delete	= lov_delete_composite,
 		.llo_fini	= lov_fini_composite,
-		.llo_install	= lov_install_composite,
 		.llo_print	= lov_print_composite,
 		.llo_page_init	= lov_page_init_composite,
 		.llo_lock_init	= lov_lock_init_composite,
@@ -894,7 +887,6 @@ static int lov_layout_change(const struct lu_env *unused,
 		goto out;
 	}
 
-	new_ops->llo_install(env, lov, state);
 	lov->lo_type = llt;
 out:
 	cl_env_put(env, &refcheck);
@@ -937,8 +929,6 @@ int lov_object_init(const struct lu_env *env, struct lu_object *obj,
 	lov->lo_type = lov_type(lsm);
 	ops = &lov_dispatch[lov->lo_type];
 	rc = ops->llo_init(env, dev, lov, lsm, cconf, set);
-	if (!rc)
-		ops->llo_install(env, lov, set);
 
 	lov_lsm_put(lsm);
 
@@ -959,6 +949,7 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 				   conf->u.coc_layout.lb_len);
 		if (IS_ERR(lsm))
 			return PTR_ERR(lsm);
+		dump_lsm(D_INODE, lsm);
 	}
 
 	lov_conf_lock(lov);
@@ -1541,6 +1532,9 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	for (entry = start_entry; entry <= end_entry; entry++) {
 		lsme = lsm->lsm_entries[entry];
 
+		if (!lsme_inited(lsme))
+			break;
+
 		if (entry == start_entry)
 			fs.fs_ext.e_start = whole_start;
 		else
@@ -1751,6 +1745,9 @@ int lov_read_and_clear_async_rc(struct cl_object *clob)
 				int j;
 
 				lse = lsm->lsm_entries[i];
+				if (!lsme_inited(lse))
+					break;
+
 				for (j = 0; j < lse->lsme_stripe_count; j++) {
 					struct lov_oinfo *loi;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 79d8a32..32e4b33 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -146,6 +146,9 @@ ssize_t lov_lsm_pack_v1v3(const struct lov_stripe_md *lsm, void *buf,
 		lmm_objects = lmmv1->lmm_objects;
 	}
 
+	if (lsm->lsm_is_released)
+		return lmm_size;
+
 	for (i = 0; i < lsm->lsm_entries[0]->lsme_stripe_count; i++) {
 		struct lov_oinfo *loi = lsm->lsm_entries[0]->lsme_oinfo[i];
 
@@ -189,11 +192,13 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	for (entry = 0; entry < lsm->lsm_entry_count; entry++) {
 		struct lov_stripe_md_entry *lsme;
 		struct lov_mds_md *lmm;
+		u16 stripecnt;
 
 		lsme = lsm->lsm_entries[entry];
 		lcme = &lcmv1->lcm_entries[entry];
 
 		lcme->lcme_id = cpu_to_le32(lsme->lsme_id);
+		lcme->lcme_flags = cpu_to_le32(lsme->lsme_flags);
 		lcme->lcme_extent.e_start =
 			cpu_to_le64(lsme->lsme_extent.e_start);
 		lcme->lcme_extent.e_end =
@@ -220,7 +225,13 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 			lmm_objects = ((struct lov_mds_md_v1 *)lmm)->lmm_objects;
 		}
 
-		for (i = 0; i < lsme->lsme_stripe_count; i++) {
+		if (lsme_inited(lsme) &&
+		    !(lsme->lsme_pattern & LOV_PATTERN_F_RELEASED))
+			stripecnt = lsme->lsme_stripe_count;
+		else
+			stripecnt = 0;
+
+		for (i = 0; i < stripecnt; i++) {
 			struct lov_oinfo *loi = lsme->lsme_oinfo[i];
 
 			ostid_cpu_to_le(&loi->loi_oi, &lmm_objects[i].l_ost_oi);
@@ -230,8 +241,7 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 				cpu_to_le32(loi->loi_ost_idx);
 		}
 
-		size = lov_mds_md_size(lsme->lsme_stripe_count,
-				       lsme->lsme_magic);
+		size = lov_mds_md_size(stripecnt, lsme->lsme_magic);
 		lcme->lcme_size = cpu_to_le32(size);
 		offset += size;
 	} /* for each layout component */
@@ -314,9 +324,6 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 	size_t lmmk_size;
 	int rc = 0;
 
-	if (!lsm)
-		return -ENODATA;
-
 	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3 &&
 	    lsm->lsm_magic != LOV_MAGIC_COMP_V1) {
 		CERROR("bad LSM MAGIC: 0x%08X != 0x%08X nor 0x%08X\n",
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index f53379a..8b68d3c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -81,7 +81,7 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 
 	offset = cl_offset(obj, index);
 	entry = lov_lsm_entry(loo->lo_lsm, offset);
-	if (entry < 0) {
+	if (entry < 0 || !lsm_entry_inited(loo->lo_lsm, entry)) {
 		/* non-existing layout component */
 		lov_page_init_empty(env, obj, page, index);
 		return 0;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 7d4ba9c..0abe426 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -214,20 +214,32 @@ static inline void mdc_clear_replay_flag(struct ptlrpc_request *req, int rc)
  * but this is incredibly unlikely, and questionable whether the client
  * could do MDS recovery under OOM anyways...
  */
-static void mdc_realloc_openmsg(struct ptlrpc_request *req,
-				struct mdt_body *body)
+static int mdc_save_lovea(struct ptlrpc_request *req,
+			  const struct req_msg_field *field,
+			  void *data, u32 size)
 {
-	int     rc;
-
-	/* FIXME: remove this explicit offset. */
-	rc = sptlrpc_cli_enlarge_reqbuf(req, DLM_INTENT_REC_OFF + 4,
-					body->mbo_eadatasize);
-	if (rc) {
-		CERROR("Can't enlarge segment %d size to %d\n",
-		       DLM_INTENT_REC_OFF + 4, body->mbo_eadatasize);
-		body->mbo_valid &= ~OBD_MD_FLEASIZE;
-		body->mbo_eadatasize = 0;
+	struct req_capsule *pill = &req->rq_pill;
+	int rc = 0;
+	void *lmm;
+
+	if (req_capsule_get_size(pill, field, RCL_CLIENT) < size) {
+		rc = sptlrpc_cli_enlarge_reqbuf(req, field, size);
+		if (rc) {
+			CERROR("%s: Can't enlarge ea size to %d: rc = %d\n",
+			       req->rq_export->exp_obd->obd_name,
+			       size, rc);
+			return rc;
+		}
+	} else {
+		req_capsule_shrink(pill, field, size, RCL_CLIENT);
 	}
+
+	req_capsule_set_size(pill, field, RCL_CLIENT, size);
+	lmm = req_capsule_client_get(pill, field);
+	if (lmm)
+		memcpy(lmm, data, size);
+
+	return rc;
 }
 
 static struct ptlrpc_request *
@@ -470,7 +482,7 @@ static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
 
 static struct ptlrpc_request *mdc_intent_layout_pack(struct obd_export *exp,
 						     struct lookup_intent *it,
-						     struct md_op_data *unused)
+						     struct md_op_data *op_data)
 {
 	struct obd_device     *obd = class_exp2obd(exp);
 	struct ptlrpc_request *req;
@@ -496,10 +508,9 @@ static struct ptlrpc_request *mdc_intent_layout_pack(struct obd_export *exp,
 
 	/* pack the layout intent request */
 	layout = req_capsule_client_get(&req->rq_pill, &RMF_LAYOUT_INTENT);
-	/* LAYOUT_INTENT_ACCESS is generic, specific operation will be
-	 * set for replication
-	 */
-	layout->li_opc = LAYOUT_INTENT_ACCESS;
+	LASSERT(op_data->op_data);
+	LASSERT(op_data->op_data_size == sizeof(*layout));
+	memcpy(layout, op_data->op_data, sizeof(*layout));
 
 	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER,
 			     obd->u.cli.cl_default_mds_easize);
@@ -649,24 +660,13 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			 * (for example error one).
 			 */
 			if ((it->it_op & IT_OPEN) && req->rq_replay) {
-				void *lmm;
-
-				if (req_capsule_get_size(pill, &RMF_EADATA,
-							 RCL_CLIENT) <
-				    body->mbo_eadatasize)
-					mdc_realloc_openmsg(req, body);
-				else
-					req_capsule_shrink(pill, &RMF_EADATA,
-							   body->mbo_eadatasize,
-							   RCL_CLIENT);
-
-				req_capsule_set_size(pill, &RMF_EADATA,
-						     RCL_CLIENT,
-						     body->mbo_eadatasize);
-
-				lmm = req_capsule_client_get(pill, &RMF_EADATA);
-				if (lmm)
-					memcpy(lmm, eadata, body->mbo_eadatasize);
+				rc = mdc_save_lovea(req, &RMF_EADATA, eadata,
+						    body->mbo_eadatasize);
+				if (rc) {
+					body->mbo_valid &= ~OBD_MD_FLEASIZE;
+					body->mbo_eadatasize = 0;
+					rc = 0;
+				}
 			}
 		}
 	} else if (it->it_op & IT_LAYOUT) {
@@ -680,6 +680,15 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 								lvb_len);
 			if (!lvb_data)
 				return -EPROTO;
+
+			/**
+			 * save replied layout data to the request buffer for
+			 * recovery consideration (lest MDS reinitialize
+			 * another set of OST objects).
+			 */
+			if (req->rq_transno)
+				(void)mdc_save_lovea(req, &RMF_EADATA, lvb_data,
+						     lvb_len);
 		}
 	}
 
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 76bc73f..03df181 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -1546,6 +1546,16 @@ static inline bool obd_mod_rpc_slot_avail(struct client_obd *cli,
 	return avail;
 }
 
+static inline bool obd_skip_mod_rpc_slot(const struct lookup_intent *it)
+{
+	if (it &&
+	    (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
+	     it->it_op == IT_READDIR ||
+	     (it->it_op == IT_LAYOUT && !(it->it_flags & FMODE_WRITE))))
+		return true;
+	return false;
+}
+
 /* Get a modify RPC slot from the obd client @cli according
  * to the kind of operation @opc that is going to be sent
  * and the intent @it of the operation if it applies.
@@ -1563,8 +1573,7 @@ u16 obd_get_mod_rpc_slot(struct client_obd *cli, __u32 opc,
 	/* read-only metadata RPCs don't consume a slot on MDT
 	 * for reply reconstruction
 	 */
-	if (it && (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
-		   it->it_op == IT_LAYOUT || it->it_op == IT_READDIR))
+	if (obd_skip_mod_rpc_slot(it))
 		return 0;
 
 	if (opc == MDS_CLOSE)
@@ -1610,8 +1619,7 @@ void obd_put_mod_rpc_slot(struct client_obd *cli, u32 opc,
 {
 	bool close_req = false;
 
-	if (it && (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
-		   it->it_op == IT_LAYOUT || it->it_op == IT_READDIR))
+	if (obd_skip_mod_rpc_slot(it))
 		return;
 
 	if (opc == MDS_CLOSE)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index d3c0dd6..a155200 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1797,9 +1797,9 @@ int req_capsule_server_pack(struct req_capsule *pill)
  * Returns the PTLRPC request or reply (\a loc) buffer offset of a \a pill
  * corresponding to the given RMF (\a field).
  */
-static u32 __req_capsule_offset(const struct req_capsule *pill,
-				const struct req_msg_field *field,
-				enum req_location loc)
+u32 __req_capsule_offset(const struct req_capsule *pill,
+			 const struct req_msg_field *field,
+			 enum req_location loc)
 {
 	u32 offset;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 0e4a215..177010c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -88,7 +88,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 void ptlrpc_initiate_recovery(struct obd_import *imp);
 
 int lustre_unpack_req_ptlrpc_body(struct ptlrpc_request *req, int offset);
-int lustre_unpack_rep_ptlrpc_body(struct ptlrpc_request *req, int offset);
+int lustre_unpack_rep_ptlrpc_body(struct ptlrpc_request *req, int effset);
 
 int ptlrpc_sysfs_register_service(struct kset *parent,
 				  struct ptlrpc_service *svc);
@@ -284,6 +284,11 @@ void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 int  sptlrpc_init(void);
 void sptlrpc_fini(void);
 
+/* layout.c */
+u32 __req_capsule_offset(const struct req_capsule *pill,
+			 const struct req_msg_field *field,
+			 enum req_location loc);
+
 static inline bool ptlrpc_recoverable_error(int rc)
 {
 	return (rc == -ENOTCONN || rc == -ENODEV);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 9c59871..53f4d4f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -1611,11 +1611,14 @@ void _sptlrpc_enlarge_msg_inplace(struct lustre_msg *msg,
  * so caller should refresh its local pointers if needed.
  */
 int sptlrpc_cli_enlarge_reqbuf(struct ptlrpc_request *req,
-			       int segment, int newsize)
+			       const struct req_msg_field *field,
+			       int newsize)
 {
+	struct req_capsule *pill = &req->rq_pill;
 	struct ptlrpc_cli_ctx *ctx = req->rq_cli_ctx;
 	struct ptlrpc_sec_cops *cops;
 	struct lustre_msg *msg = req->rq_reqmsg;
+	int segment = __req_capsule_offset(pill, field, RCL_CLIENT);
 
 	LASSERT(ctx);
 	LASSERT(msg);
-- 
1.8.3.1
