From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:41 -0400
Subject: [lustre-devel] [PATCH 07/29] staging: lustre: lov: remove LSM from
	struct lustre_md
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In struct lustre_md replace the struct lov_stripe_md *lsm member with
an opaque struct lu_buf layout which holds the layout metadata
returned by the server. Refactor the LOV object initialization and
layout change code to accommodate this. Simplify lov_unpackmd() and
supporting functions according to the reduced number of use cases.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/13722
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h |    2 +-
 drivers/staging/lustre/lustre/include/obd.h       |    2 +-
 drivers/staging/lustre/lustre/llite/file.c        |   29 +----
 drivers/staging/lustre/lustre/llite/lcommon_cl.c  |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c   |   11 +--
 drivers/staging/lustre/lustre/llite/namei.c       |    7 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c        |    9 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h  |   15 +--
 drivers/staging/lustre/lustre/lov/lov_obd.c       |    1 -
 drivers/staging/lustre/lustre/lov/lov_object.c    |  120 ++++++++++++---------
 drivers/staging/lustre/lustre/lov/lov_pack.c      |  100 +++++++-----------
 drivers/staging/lustre/lustre/mdc/mdc_request.c   |   19 +---
 12 files changed, 134 insertions(+), 183 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index dfef4bc..514d650 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -267,7 +267,7 @@ struct cl_object_conf {
 		/**
 		 * Object layout. This is consumed by lov.
 		 */
-		struct lustre_md *coc_md;
+		struct lu_buf	  coc_layout;
 		/**
 		 * Description of particular stripe location in the
 		 * cluster. This is consumed by osc.
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ebb3012..c8a6e23 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -864,7 +864,7 @@ struct obd_ops {
 /* lmv structures */
 struct lustre_md {
 	struct mdt_body	 *body;
-	struct lov_stripe_md    *lsm;
+	struct lu_buf		 layout;
 	struct lmv_stripe_md    *lmv;
 #ifdef CONFIG_FS_POSIX_ACL
 	struct posix_acl	*posix_acl;
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 2c8df43..0ae78c7 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3275,7 +3275,6 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info    *sbi = ll_i2sbi(inode);
 	struct ldlm_lock *lock;
-	struct lustre_md md = { NULL };
 	struct cl_object_conf conf;
 	int rc = 0;
 	bool lvb_ready;
@@ -3310,37 +3309,19 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 
 	/* for layout lock, lmm is returned in lock's lvb.
 	 * lvb_data is immutable if the lock is held so it's safe to access it
-	 * without res lock. See the description in ldlm_lock_decref_internal()
-	 * for the condition to free lvb_data of layout lock
-	 */
-	if (lock->l_lvb_data) {
-		rc = obd_unpackmd(sbi->ll_dt_exp, &md.lsm,
-				  lock->l_lvb_data, lock->l_lvb_len);
-		if (rc < 0) {
-			CERROR("%s: file " DFID " unpackmd error: %d\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0),
-			       PFID(&lli->lli_fid), rc);
-			goto out;
-		}
-
-		LASSERTF(md.lsm, "lvb_data = %p, lvb_len = %u\n",
-			 lock->l_lvb_data, lock->l_lvb_len);
-		rc = 0;
-	}
-
-	/* set layout to file. Unlikely this will fail as old layout was
+	 * without res lock.
+	 *
+	 * set layout to file. Unlikely this will fail as old layout was
 	 * surely eliminated
 	 */
 	memset(&conf, 0, sizeof(conf));
 	conf.coc_opc = OBJECT_CONF_SET;
 	conf.coc_inode = inode;
 	conf.coc_lock = lock;
-	conf.u.coc_md = &md;
+	conf.u.coc_layout.lb_buf = lock->l_lvb_data;
+	conf.u.coc_layout.lb_len = lock->l_lvb_len;
 	rc = ll_layout_conf(inode, &conf);
 
-	if (md.lsm)
-		obd_free_memmd(sbi->ll_dt_exp, &md.lsm);
-
 	/* refresh layout failed, need to wait */
 	wait_layout = rc == -EBUSY;
 
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 4087db0..56e414b 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -150,7 +150,7 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 	struct cl_object_conf conf = {
 		.coc_inode = inode,
 		.u = {
-			.coc_md    = md
+			.coc_layout = md->layout,
 		}
 	};
 	int result = 0;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index fba1499..b896ac1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -469,8 +469,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	ptlrpc_req_finished(request);
 
 	if (IS_ERR(root)) {
-		if (lmd.lsm)
-			obd_free_memmd(sbi->ll_dt_exp, &lmd.lsm);
 #ifdef CONFIG_FS_POSIX_ACL
 		if (lmd.posix_acl) {
 			posix_acl_release(lmd.posix_acl);
@@ -1688,11 +1686,9 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct mdt_body *body = md->body;
-	struct lov_stripe_md *lsm = md->lsm;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 
-	LASSERT((lsm != NULL) == ((body->mbo_valid & OBD_MD_FLEASIZE) != 0));
-	if (lsm)
+	if (body->mbo_valid & OBD_MD_FLEASIZE)
 		cl_file_inode_init(inode, md);
 
 	if (S_ISDIR(inode->i_mode)) {
@@ -2135,17 +2131,14 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 			conf.coc_opc = OBJECT_CONF_SET;
 			conf.coc_inode = *inode;
 			conf.coc_lock = lock;
-			conf.u.coc_md = &md;
+			conf.u.coc_layout = md.layout;
 			(void)ll_layout_conf(*inode, &conf);
 		}
 		LDLM_LOCK_PUT(lock);
 	}
 
 out:
-	if (md.lsm)
-		obd_free_memmd(sbi->ll_dt_exp, &md.lsm);
 	md_free_lustre_md(sbi->ll_md_exp, &md);
-
 cleanup:
 	if (rc != 0 && it && it->it_op & IT_OPEN)
 		ll_open_cleanup(sb ? sb : (*inode)->i_sb, req);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 9b4095f..89fd441 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -113,12 +113,9 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 	if (inode->i_state & I_NEW) {
 		rc = ll_read_inode2(inode, md);
 		if (!rc && S_ISREG(inode->i_mode) &&
-		    !ll_i2info(inode)->lli_clob) {
-			CDEBUG(D_INODE, "%s: apply lsm %p to inode "DFID"\n",
-			       ll_get_fsname(sb, NULL, 0), md->lsm,
-			       PFID(ll_inode2fid(inode)));
+		    !ll_i2info(inode)->lli_clob)
 			rc = cl_file_inode_init(inode, md);
-		}
+
 		if (rc) {
 			make_bad_inode(inode);
 			unlock_new_inode(inode);
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index d7dc0aa..53db170 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -76,18 +76,19 @@ static int lsm_lmm_verify_common(struct lov_mds_md *lmm, int lmm_bytes,
 	return 0;
 }
 
-struct lov_stripe_md *lsm_alloc_plain(__u16 stripe_count, int *size)
+struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
 {
+	size_t oinfo_ptrs_size, lsm_size;
 	struct lov_stripe_md *lsm;
 	struct lov_oinfo     *loi;
-	int		   i, oinfo_ptrs_size;
+	unsigned int i;
 
 	LASSERT(stripe_count <= LOV_MAX_STRIPE_COUNT);
 
 	oinfo_ptrs_size = sizeof(struct lov_oinfo *) * stripe_count;
-	*size = sizeof(struct lov_stripe_md) + oinfo_ptrs_size;
+	lsm_size = sizeof(*lsm) + oinfo_ptrs_size;
 
-	lsm = libcfs_kvzalloc(*size, GFP_NOFS);
+	lsm = libcfs_kvzalloc(lsm_size, GFP_NOFS);
 	if (!lsm)
 		return NULL;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 41e7c5f..5b151bb 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -79,13 +79,6 @@ static inline bool lsm_has_objects(struct lov_stripe_md *lsm)
 	return true;
 }
 
-static inline int lov_stripe_md_size(unsigned int stripe_count)
-{
-	struct lov_stripe_md lsm;
-
-	return sizeof(lsm) + stripe_count * sizeof(lsm.lsm_oinfo[0]);
-}
-
 struct lsm_operations {
 	void (*lsm_free)(struct lov_stripe_md *);
 	void (*lsm_stripe_by_index)(struct lov_stripe_md *, int *, loff_t *,
@@ -254,10 +247,8 @@ int lov_del_target(struct obd_device *obd, __u32 index,
 /* lov_pack.c */
 ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 		     size_t buf_size);
-int lov_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
-		 struct lov_mds_md *lmm, int lmm_bytes);
-int lov_alloc_memmd(struct lov_stripe_md **lsmp, __u16 stripe_count,
-		    int pattern, int magic);
+struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
+				   size_t lmm_size);
 int lov_free_memmd(struct lov_stripe_md **lsmp);
 
 void lov_dump_lmm_v1(int level, struct lov_mds_md_v1 *lmm);
@@ -265,7 +256,7 @@ int lov_alloc_memmd(struct lov_stripe_md **lsmp, __u16 stripe_count,
 void lov_dump_lmm_common(int level, void *lmmp);
 
 /* lov_ea.c */
-struct lov_stripe_md *lsm_alloc_plain(__u16 stripe_count, int *size);
+struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count);
 void lsm_free_plain(struct lov_stripe_md *lsm);
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 621f66e..421a0e2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1406,7 +1406,6 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	.disconnect     = lov_disconnect,
 	.statfs         = lov_statfs,
 	.statfs_async   = lov_statfs_async,
-	.unpackmd       = lov_unpackmd,
 	.iocontrol      = lov_iocontrol,
 	.get_info       = lov_get_info,
 	.set_info_async = lov_set_info_async,
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 82b99e0..711a3b9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -39,6 +39,11 @@
 
 #include "lov_cl_internal.h"
 
+static inline struct lov_device *lov_object_dev(struct lov_object *obj)
+{
+	return lu2lov_dev(obj->lo_cl.co_lu.lo_dev);
+}
+
 /** \addtogroup lov
  *  @{
  */
@@ -51,7 +56,7 @@
 
 struct lov_layout_operations {
 	int (*llo_init)(const struct lu_env *env, struct lov_device *dev,
-			struct lov_object *lov,
+			struct lov_object *lov, struct lov_stripe_md *lsm,
 			const struct cl_object_conf *conf,
 			union lov_layout_state *state);
 	int (*llo_delete)(const struct lu_env *env, struct lov_object *lov,
@@ -96,17 +101,17 @@ static void lov_install_empty(const struct lu_env *env,
 	 */
 }
 
-static int lov_init_empty(const struct lu_env *env,
-			  struct lov_device *dev, struct lov_object *lov,
+static int lov_init_empty(const struct lu_env *env, struct lov_device *dev,
+			  struct lov_object *lov, struct lov_stripe_md *lsm,
 			  const struct cl_object_conf *conf,
-			  union  lov_layout_state *state)
+			  union lov_layout_state *state)
 {
 	return 0;
 }
 
 static void lov_install_raid0(const struct lu_env *env,
 			      struct lov_object *lov,
-			      union  lov_layout_state *state)
+			      union lov_layout_state *state)
 {
 }
 
@@ -211,8 +216,8 @@ static int lov_page_slice_fixup(struct lov_object *lov,
 	return cl_object_header(stripe)->coh_page_bufsize;
 }
 
-static int lov_init_raid0(const struct lu_env *env,
-			  struct lov_device *dev, struct lov_object *lov,
+static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
+			  struct lov_object *lov, struct lov_stripe_md *lsm,
 			  const struct cl_object_conf *conf,
 			  union  lov_layout_state *state)
 {
@@ -222,7 +227,6 @@ static int lov_init_raid0(const struct lu_env *env,
 	struct cl_object	*stripe;
 	struct lov_thread_info  *lti     = lov_env_info(env);
 	struct cl_object_conf   *subconf = &lti->lti_stripe_conf;
-	struct lov_stripe_md    *lsm     = conf->u.coc_md->lsm;
 	struct lu_fid	   *ofid    = &lti->lti_fid;
 	struct lov_layout_raid0 *r0      = &state->raid0;
 
@@ -297,13 +301,11 @@ static int lov_init_raid0(const struct lu_env *env,
 	return result;
 }
 
-static int lov_init_released(const struct lu_env *env,
-			     struct lov_device *dev, struct lov_object *lov,
+static int lov_init_released(const struct lu_env *env, struct lov_device *dev,
+			     struct lov_object *lov, struct lov_stripe_md *lsm,
 			     const struct cl_object_conf *conf,
 			     union  lov_layout_state *state)
 {
-	struct lov_stripe_md *lsm = conf->u.coc_md->lsm;
-
 	LASSERT(lsm);
 	LASSERT(lsm_is_released(lsm));
 	LASSERT(!lov->lo_lsm);
@@ -720,25 +722,20 @@ static int lov_layout_wait(const struct lu_env *env, struct lov_object *lov)
 }
 
 static int lov_layout_change(const struct lu_env *unused,
-			     struct lov_object *lov,
+			     struct lov_object *lov, struct lov_stripe_md *lsm,
 			     const struct cl_object_conf *conf)
 {
-	int result;
-	enum lov_layout_type llt = LLT_EMPTY;
+	enum lov_layout_type llt = lov_type(lsm);
 	union lov_layout_state *state = &lov->u;
 	const struct lov_layout_operations *old_ops;
 	const struct lov_layout_operations *new_ops;
-
 	void *cookie;
 	struct lu_env *env;
 	int refcheck;
+	int rc;
 
 	LASSERT(0 <= lov->lo_type && lov->lo_type < ARRAY_SIZE(lov_dispatch));
 
-	if (conf->u.coc_md)
-		llt = lov_type(conf->u.coc_md->lsm);
-	LASSERT(0 <= llt && llt < ARRAY_SIZE(lov_dispatch));
-
 	cookie = cl_env_reenter();
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env)) {
@@ -746,6 +743,8 @@ static int lov_layout_change(const struct lu_env *unused,
 		return PTR_ERR(env);
 	}
 
+	LASSERT(0 <= llt && llt < ARRAY_SIZE(lov_dispatch));
+
 	CDEBUG(D_INODE, DFID" from %s to %s\n",
 	       PFID(lu_object_fid(lov2lu(lov))),
 	       llt2str(lov->lo_type), llt2str(llt));
@@ -753,38 +752,38 @@ static int lov_layout_change(const struct lu_env *unused,
 	old_ops = &lov_dispatch[lov->lo_type];
 	new_ops = &lov_dispatch[llt];
 
-	result = cl_object_prune(env, &lov->lo_cl);
-	if (result != 0)
+	rc = cl_object_prune(env, &lov->lo_cl);
+	if (rc)
 		goto out;
 
-	result = old_ops->llo_delete(env, lov, &lov->u);
-	if (result == 0) {
-		old_ops->llo_fini(env, lov, &lov->u);
+	rc = old_ops->llo_delete(env, lov, &lov->u);
+	if (rc)
+		goto out;
 
-		LASSERT(atomic_read(&lov->lo_active_ios) == 0);
+	old_ops->llo_fini(env, lov, &lov->u);
 
-		lov->lo_type = LLT_EMPTY;
-		/* page bufsize fixup */
-		cl_object_header(&lov->lo_cl)->coh_page_bufsize -=
+	LASSERT(!atomic_read(&lov->lo_active_ios));
+
+	lov->lo_type = LLT_EMPTY;
+
+	/* page bufsize fixup */
+	cl_object_header(&lov->lo_cl)->coh_page_bufsize -=
 			lov_page_slice_fixup(lov, NULL);
 
-		result = new_ops->llo_init(env,
-					lu2lov_dev(lov->lo_cl.co_lu.lo_dev),
-					lov, conf, state);
-		if (result == 0) {
-			new_ops->llo_install(env, lov, state);
-			lov->lo_type = llt;
-		} else {
-			new_ops->llo_delete(env, lov, state);
-			new_ops->llo_fini(env, lov, state);
-			/* this file becomes an EMPTY file. */
-		}
+	rc = new_ops->llo_init(env, lov_object_dev(lov), lov, lsm, conf, state);
+	if (rc) {
+		new_ops->llo_delete(env, lov, state);
+		new_ops->llo_fini(env, lov, state);
+		/* this file becomes an EMPTY file. */
+		goto out;
 	}
 
+	new_ops->llo_install(env, lov, state);
+	lov->lo_type = llt;
 out:
 	cl_env_put(env, &refcheck);
 	cl_env_reexit(cookie);
-	return result;
+	return rc;
 }
 
 /*****************************************************************************
@@ -795,26 +794,37 @@ static int lov_layout_change(const struct lu_env *unused,
 int lov_object_init(const struct lu_env *env, struct lu_object *obj,
 		    const struct lu_object_conf *conf)
 {
-	struct lov_device	    *dev   = lu2lov_dev(obj->lo_dev);
 	struct lov_object	    *lov   = lu2lov(obj);
+	struct lov_device *dev = lov_object_dev(lov);
 	const struct cl_object_conf  *cconf = lu2cl_conf(conf);
 	union  lov_layout_state      *set   = &lov->u;
 	const struct lov_layout_operations *ops;
-	int result;
+	struct lov_stripe_md *lsm = NULL;
+	int rc;
 
 	init_rwsem(&lov->lo_type_guard);
 	atomic_set(&lov->lo_active_ios, 0);
 	init_waitqueue_head(&lov->lo_waitq);
-
 	cl_object_page_init(lu2cl(obj), sizeof(struct lov_page));
 
+	if (cconf->u.coc_layout.lb_buf) {
+		lsm = lov_unpackmd(dev->ld_lov,
+				   cconf->u.coc_layout.lb_buf,
+				   cconf->u.coc_layout.lb_len);
+		if (IS_ERR(lsm))
+			return PTR_ERR(lsm);
+	}
+
 	/* no locking is necessary, as object is being created */
-	lov->lo_type = lov_type(cconf->u.coc_md->lsm);
+	lov->lo_type = lov_type(lsm);
 	ops = &lov_dispatch[lov->lo_type];
-	result = ops->llo_init(env, dev, lov, cconf, set);
-	if (result == 0)
+	rc = ops->llo_init(env, dev, lov, lsm, cconf, set);
+	if (!rc)
 		ops->llo_install(env, lov, set);
-	return result;
+
+	lov_lsm_put(lsm);
+
+	return rc;
 }
 
 static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
@@ -824,6 +834,15 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 	struct lov_object	*lov = cl2lov(obj);
 	int			 result = 0;
 
+	if (conf->coc_opc == OBJECT_CONF_SET &&
+	    conf->u.coc_layout.lb_buf) {
+		lsm = lov_unpackmd(lov_object_dev(lov)->ld_lov,
+				   conf->u.coc_layout.lb_buf,
+				   conf->u.coc_layout.lb_len);
+		if (IS_ERR(lsm))
+			return PTR_ERR(lsm);
+	}
+
 	lov_conf_lock(lov);
 	if (conf->coc_opc == OBJECT_CONF_INVALIDATE) {
 		lov->lo_layout_invalid = true;
@@ -843,8 +862,6 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 
 	LASSERT(conf->coc_opc == OBJECT_CONF_SET);
 
-	if (conf->u.coc_md)
-		lsm = conf->u.coc_md->lsm;
 	if ((!lsm && !lov->lo_lsm) ||
 	    ((lsm && lov->lo_lsm) &&
 	     (lov->lo_lsm->lsm_layout_gen == lsm->lsm_layout_gen) &&
@@ -862,11 +879,12 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 		goto out;
 	}
 
-	result = lov_layout_change(env, lov, conf);
+	result = lov_layout_change(env, lov, lsm, conf);
 	lov->lo_layout_invalid = result != 0;
 
 out:
 	lov_conf_unlock(lov);
+	lov_lsm_put(lsm);
 	CDEBUG(D_INODE, DFID" lo_layout_invalid=%d\n",
 	       PFID(lu_object_fid(lov2lu(lov))), lov->lo_layout_invalid);
 	return result;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index ccc1fae..9ba87d2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -195,34 +195,34 @@ static int lov_verify_lmm(void *lmm, int lmm_bytes, __u16 *stripe_count)
 	return rc;
 }
 
-int lov_alloc_memmd(struct lov_stripe_md **lsmp, __u16 stripe_count,
-		    int pattern, int magic)
+struct lov_stripe_md *lov_lsm_alloc(u16 stripe_count, u32 pattern, u32 magic)
 {
-	int i, lsm_size;
+	struct lov_stripe_md *lsm;
+	unsigned int i;
 
-	CDEBUG(D_INFO, "alloc lsm, stripe_count %d\n", stripe_count);
+	CDEBUG(D_INFO, "alloc lsm, stripe_count %u\n", stripe_count);
 
-	*lsmp = lsm_alloc_plain(stripe_count, &lsm_size);
-	if (!*lsmp) {
-		CERROR("can't allocate lsmp stripe_count %d\n", stripe_count);
-		return -ENOMEM;
+	lsm = lsm_alloc_plain(stripe_count);
+	if (!lsm) {
+		CERROR("cannot allocate LSM stripe_count %u\n", stripe_count);
+		return ERR_PTR(-ENOMEM);
 	}
 
-	atomic_set(&(*lsmp)->lsm_refc, 1);
-	spin_lock_init(&(*lsmp)->lsm_lock);
-	(*lsmp)->lsm_magic = magic;
-	(*lsmp)->lsm_stripe_count = stripe_count;
-	(*lsmp)->lsm_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES * stripe_count;
-	(*lsmp)->lsm_pattern = pattern;
-	(*lsmp)->lsm_pool_name[0] = '\0';
-	(*lsmp)->lsm_layout_gen = 0;
+	atomic_set(&lsm->lsm_refc, 1);
+	spin_lock_init(&lsm->lsm_lock);
+	lsm->lsm_magic = magic;
+	lsm->lsm_stripe_count = stripe_count;
+	lsm->lsm_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES * stripe_count;
+	lsm->lsm_pattern = pattern;
+	lsm->lsm_pool_name[0] = '\0';
+	lsm->lsm_layout_gen = 0;
 	if (stripe_count > 0)
-		(*lsmp)->lsm_oinfo[0]->loi_ost_idx = ~0;
+		lsm->lsm_oinfo[0]->loi_ost_idx = ~0;
 
 	for (i = 0; i < stripe_count; i++)
-		loi_init((*lsmp)->lsm_oinfo[i]);
+		loi_init(lsm->lsm_oinfo[i]);
 
-	return lsm_size;
+	return lsm;
 }
 
 int lov_free_memmd(struct lov_stripe_md **lsmp)
@@ -242,56 +242,34 @@ int lov_free_memmd(struct lov_stripe_md **lsmp)
 /* Unpack LOV object metadata from disk storage.  It is packed in LE byte
  * order and is opaque to the networking layer.
  */
-int lov_unpackmd(struct obd_export *exp,  struct lov_stripe_md **lsmp,
-		 struct lov_mds_md *lmm, int lmm_bytes)
+struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
+				   size_t lmm_size)
 {
-	struct obd_device *obd = class_exp2obd(exp);
-	struct lov_obd *lov = &obd->u.lov;
-	int rc = 0, lsm_size;
-	__u16 stripe_count;
-	__u32 magic;
-	__u32 pattern;
-
-	/* If passed an MDS struct use values from there, otherwise defaults */
-	if (lmm) {
-		rc = lov_verify_lmm(lmm, lmm_bytes, &stripe_count);
-		if (rc)
-			return rc;
-		magic = le32_to_cpu(lmm->lmm_magic);
-		pattern = le32_to_cpu(lmm->lmm_pattern);
-	} else {
-		magic = LOV_MAGIC;
-		stripe_count = lov_get_stripecnt(lov, magic, 0);
-		pattern = LOV_PATTERN_RAID0;
-	}
+	struct lov_stripe_md *lsm;
+	u16 stripe_count;
+	u32 pattern;
+	u32 magic;
+	int rc;
 
-	/* If we aren't passed an lsmp struct, we just want the size */
-	if (!lsmp) {
-		/* XXX LOV STACKING call into osc for sizes */
-		LBUG();
-		return lov_stripe_md_size(stripe_count);
-	}
-	/* If we are passed an allocated struct but nothing to unpack, free */
-	if (*lsmp && !lmm) {
-		lov_free_memmd(lsmp);
-		return 0;
-	}
+	rc = lov_verify_lmm(lmm, lmm_size, &stripe_count);
+	if (rc)
+		return ERR_PTR(rc);
 
-	lsm_size = lov_alloc_memmd(lsmp, stripe_count, pattern, magic);
-	if (lsm_size < 0)
-		return lsm_size;
+	magic = le32_to_cpu(lmm->lmm_magic);
+	pattern = le32_to_cpu(lmm->lmm_pattern);
 
-	/* If we are passed a pointer but nothing to unpack, we only alloc */
-	if (!lmm)
-		return lsm_size;
+	lsm = lov_lsm_alloc(stripe_count, pattern, magic);
+	if (IS_ERR(lsm))
+		return lsm;
 
-	rc = lsm_op_find(magic)->lsm_unpackmd(lov, *lsmp, lmm);
+	LASSERT(lsm_op_find(magic));
+	rc = lsm_op_find(magic)->lsm_unpackmd(lov, lsm, lmm);
 	if (rc) {
-		lov_free_memmd(lsmp);
-		return rc;
+		lov_free_memmd(&lsm);
+		return ERR_PTR(rc);
 	}
 
-	return lsm_size;
+	return lsm;
 }
 
 /* Retrieve object striping information.
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 4c30ab6..c620f5c 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -420,9 +420,6 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 	md->body = req_capsule_server_get(pill, &RMF_MDT_BODY);
 
 	if (md->body->mbo_valid & OBD_MD_FLEASIZE) {
-		int lmmsize;
-		struct lov_mds_md *lmm;
-
 		if (!S_ISREG(md->body->mbo_mode)) {
 			CDEBUG(D_INFO,
 			       "OBD_MD_FLEASIZE set, should be a regular file, but is not\n");
@@ -436,17 +433,15 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 			rc = -EPROTO;
 			goto out;
 		}
-		lmmsize = md->body->mbo_eadatasize;
-		lmm = req_capsule_server_sized_get(pill, &RMF_MDT_MD, lmmsize);
-		if (!lmm) {
+
+		md->layout.lb_len = md->body->mbo_eadatasize;
+		md->layout.lb_buf = req_capsule_server_sized_get(pill,
+								 &RMF_MDT_MD,
+								 md->layout.lb_len);
+		if (!md->layout.lb_buf) {
 			rc = -EPROTO;
 			goto out;
 		}
-
-		rc = obd_unpackmd(dt_exp, &md->lsm, lmm, lmmsize);
-		if (rc < 0)
-			goto out;
-
 	} else if (md->body->mbo_valid & OBD_MD_FLDIREA) {
 		int lmvsize;
 		struct lov_mds_md *lmv;
@@ -509,8 +504,6 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 #ifdef CONFIG_FS_POSIX_ACL
 		posix_acl_release(md->posix_acl);
 #endif
-		if (md->lsm)
-			obd_free_memmd(dt_exp, &md->lsm);
 	}
 	return rc;
 }
-- 
1.7.1
