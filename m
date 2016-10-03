From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:27 -0400
Subject: [lustre-devel] [PATCH 31/41] staging: lustre: obd: remove destroy
	cookie handling
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Clients no longer need to track the max and default MDS cookiesizes
so remove
 the obsolete obod o_valid flag OBD_MD_FLCOOKIE,
 the struct client_obd members cl_{default,max}_mds_cookiesize,
 the struct obd_trans_info and parameters of this type,
 the cookiesize parameters from md_init_ea_size(),
 the files llite/*/{default,max}_cookiesize, and
 any code that needlessly handled these values.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6017
Reviewed-on: http://review.whamcloud.com/12922
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    7 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   20 ++-----
 drivers/staging/lustre/lustre/include/obd.h        |   46 ++------------
 drivers/staging/lustre/lustre/include/obd_class.h  |   31 ++++------
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    3 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   13 +---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   23 ++-----
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    1 -
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    2 -
 drivers/staging/lustre/lustre/lov/lov_request.c    |    1 -
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    2 -
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    4 -
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   15 +----
 .../staging/lustre/lustre/obdecho/echo_client.c    |   58 ++++++-------------
 drivers/staging/lustre/lustre/osc/osc_request.c    |   62 ++++---------------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   10 +--
 17 files changed, 79 insertions(+), 223 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 7645ed9..5d2f845 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1664,7 +1664,7 @@ lov_mds_md_max_stripe_count(size_t buf_size, __u32 lmm_magic)
 #define OBD_MD_FLCKSUM     (0x00100000ULL) /* bulk data checksum */
 #define OBD_MD_FLQOS       (0x00200000ULL) /* quality of service stats */
 /*#define OBD_MD_FLOSCOPQ    (0x00400000ULL) osc opaque data, never used */
-#define OBD_MD_FLCOOKIE    (0x00800000ULL) /* log cancellation cookie */
+/*	OBD_MD_FLCOOKIE    (0x00800000ULL) obsolete in 2.8 */
 #define OBD_MD_FLGROUP     (0x01000000ULL) /* group */
 #define OBD_MD_FLFID       (0x02000000ULL) /* ->ost write inline fid */
 #define OBD_MD_FLEPOCH     (0x04000000ULL) /* ->ost write with ioepoch */
@@ -2091,7 +2091,7 @@ struct mdt_body {
 	__u32	mbo_eadatasize;
 	__u32	mbo_aclsize;
 	__u32	mbo_max_mdsize;
-	__u32	mbo_max_cookiesize;
+	__u32	mbo_unused3;	/* was max_cookiesize until 2.8 */
 	__u32	mbo_uid_h;	/* high 32-bits of uid, for FUID */
 	__u32	mbo_gid_h;	/* high 32-bits of gid, for FUID */
 	__u32	mbo_padding_5;	/* also fix lustre_swab_mdt_body */
@@ -3226,7 +3226,8 @@ struct obdo {
 	__u32		   o_parent_ver;
 	struct lustre_handle    o_handle;  /* brw: lock handle to prolong locks
 					    */
-	struct llog_cookie      o_lcookie; /* destroy: unlink cookie from MDS
+	struct llog_cookie      o_lcookie; /* destroy: unlink cookie from MDS,
+					    * obsolete in 2.8, reused in OSP
 					    */
 	__u32			o_uid_h;
 	__u32			o_gid_h;
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 8fc2d3f..92a5c0f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -157,15 +157,14 @@ static inline void mdc_put_rpc_lock(struct mdc_rpc_lock *lck,
 }
 
 /**
- * Update the maximum possible easize and cookiesize.
+ * Update the maximum possible easize.
  *
- * The values are learned from ptlrpc replies sent by the MDT.  The
- * default easize and cookiesize is initialized to the minimum value but
- * allowed to grow up to a single page in size if required to handle the
+ * This value is learned from ptlrpc replies sent by the MDT. The
+ * default easize is initialized to the minimum value but allowed
+ * to grow up to a single page in size if required to handle the
  * common case.
  *
- * \see client_obd::cl_default_mds_easize and
- * client_obd::cl_default_mds_cookiesize
+ * \see client_obd::cl_default_mds_easize
  *
  * \param[in] exp	export for MDC device
  * \param[in] body	body of ptlrpc reply from MDT
@@ -176,7 +175,7 @@ static inline void mdc_update_max_ea_from_body(struct obd_export *exp,
 {
 	if (body->mbo_valid & OBD_MD_FLMODEASIZE) {
 		struct client_obd *cli = &exp->exp_obd->u.cli;
-		u32 def_cookiesize, def_easize;
+		u32 def_easize;
 
 		if (cli->cl_max_mds_easize < body->mbo_max_mdsize)
 			cli->cl_max_mds_easize = body->mbo_max_mdsize;
@@ -184,13 +183,6 @@ static inline void mdc_update_max_ea_from_body(struct obd_export *exp,
 		def_easize = min_t(__u32, body->mbo_max_mdsize,
 				   OBD_MAX_DEFAULT_EA_SIZE);
 		cli->cl_default_mds_easize = def_easize;
-
-		if (cli->cl_max_mds_cookiesize < body->mbo_max_cookiesize)
-			cli->cl_max_mds_cookiesize = body->mbo_max_cookiesize;
-
-		def_cookiesize = min_t(__u32, body->mbo_max_cookiesize,
-				       OBD_MAX_DEFAULT_COOKIE_SIZE);
-		cli->cl_default_mds_cookiesize = def_cookiesize;
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 2811901..4691121 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -204,7 +204,6 @@ enum obd_cl_sem_lock_class {
  * on the MDS.
  */
 #define OBD_MAX_DEFAULT_EA_SIZE		4096
-#define OBD_MAX_DEFAULT_COOKIE_SIZE	4096
 
 struct mdc_rpc_lock;
 struct obd_import;
@@ -214,7 +213,7 @@ struct client_obd {
 	struct obd_import       *cl_import; /* ptlrpc connection state */
 	size_t			 cl_conn_count;
 	/*
-	 * Cache maximum and default values for easize and cookiesize. This is
+	 * Cache maximum and default values for easize. This is
 	 * strictly a performance optimization to minimize calls to
 	 * obd_size_diskmd(). The default values are used to calculate the
 	 * initial size of a request buffer. The ptlrpc layer will resize the
@@ -235,18 +234,6 @@ struct client_obd {
 	 * run-time if a larger observed size is advertised by the MDT.
 	 */
 	u32			 cl_max_mds_easize;
-	/* Default cookie size for llog cookies (see struct llog_cookie). It is
-	 * initialized to zero at mount-time, then it tracks the largest
-	 * observed cookie size advertised by the MDT, up to a maximum value of
-	 * OBD_MAX_DEFAULT_COOKIE_SIZE. Note that llog_cookies are not
-	 * used by clients communicating with MDS versions 2.4.0 and later.
-	 */
-	u32			 cl_default_mds_cookiesize;
-	/* Maximum possible cookie size computed at mount-time based on
-	 * the number of OSTs in the filesystem. May be increased at
-	 * run-time if a larger observed size is advertised by the MDT.
-	 */
-	u32			 cl_max_mds_cookiesize;
 
 	enum lustre_sec_part     cl_sp_me;
 	enum lustre_sec_part     cl_sp_to;
@@ -447,8 +434,6 @@ struct lmv_obd {
 	int			connected;
 	int			max_easize;
 	int			max_def_easize;
-	int			max_cookiesize;
-	int			max_def_cookiesize;
 
 	u32			tgts_size; /* size of tgts array */
 	struct lmv_tgt_desc	**tgts;
@@ -505,21 +490,6 @@ struct niobuf_local {
 /* Don't conflict with on-wire flags OBD_BRW_WRITE, etc */
 #define N_LOCAL_TEMP_PAGE 0x10000000
 
-struct obd_trans_info {
-	__u64		    oti_xid;
-	/* Only used on the server side for tracking acks. */
-	struct oti_req_ack_lock {
-		struct lustre_handle lock;
-		__u32		mode;
-	}			oti_ack_locks[4];
-	void		    *oti_handle;
-	struct llog_cookie       oti_onecookie;
-	struct llog_cookie      *oti_logcookies;
-
-	/** VBR: versions */
-	__u64		    oti_pre_version;
-};
-
 /*
  * Events signalled through obd_notify() upcall-chain.
  */
@@ -891,24 +861,22 @@ struct obd_ops {
 			struct lov_stripe_md **mem_tgt,
 			struct lov_mds_md *disk_src, int disk_len);
 	int (*create)(const struct lu_env *env, struct obd_export *exp,
-		      struct obdo *oa, struct obd_trans_info *oti);
+		      struct obdo *oa);
 	int (*destroy)(const struct lu_env *env, struct obd_export *exp,
-		       struct obdo *oa, struct obd_trans_info *oti);
+		       struct obdo *oa);
 	int (*setattr)(const struct lu_env *, struct obd_export *exp,
-		       struct obd_info *oinfo, struct obd_trans_info *oti);
+		       struct obd_info *oinfo);
 	int (*getattr)(const struct lu_env *env, struct obd_export *exp,
 		       struct obd_info *oinfo);
 	int (*preprw)(const struct lu_env *env, int cmd,
 		      struct obd_export *exp, struct obdo *oa, int objcount,
 		      struct obd_ioobj *obj, struct niobuf_remote *remote,
-		      int *nr_pages, struct niobuf_local *local,
-		      struct obd_trans_info *oti);
+		      int *nr_pages, struct niobuf_local *local);
 	int (*commitrw)(const struct lu_env *env, int cmd,
 			struct obd_export *exp, struct obdo *oa,
 			int objcount, struct obd_ioobj *obj,
 			struct niobuf_remote *remote, int pages,
-			struct niobuf_local *local,
-			struct obd_trans_info *oti, int rc);
+			struct niobuf_local *local, int rc);
 	int (*init_export)(struct obd_export *exp);
 	int (*destroy_export)(struct obd_export *exp);
 
@@ -1018,7 +986,7 @@ struct md_ops {
 			u64, const char *, const char *, int, int, int,
 			struct ptlrpc_request **);
 
-	int (*init_ea_size)(struct obd_export *, u32, u32, u32, u32);
+	int (*init_ea_size)(struct obd_export *, u32, u32);
 
 	int (*get_lustre_md)(struct obd_export *, struct ptlrpc_request *,
 			     struct obd_export *, struct obd_export *,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 8f1d681..a27dbc8 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -686,26 +686,26 @@ static inline int obd_free_memmd(struct obd_export *exp,
 }
 
 static inline int obd_create(const struct lu_env *env, struct obd_export *exp,
-			     struct obdo *obdo, struct obd_trans_info *oti)
+			     struct obdo *obdo)
 {
 	int rc;
 
 	EXP_CHECK_DT_OP(exp, create);
 	EXP_COUNTER_INCREMENT(exp, create);
 
-	rc = OBP(exp->exp_obd, create)(env, exp, obdo, oti);
+	rc = OBP(exp->exp_obd, create)(env, exp, obdo);
 	return rc;
 }
 
 static inline int obd_destroy(const struct lu_env *env, struct obd_export *exp,
-			      struct obdo *obdo, struct obd_trans_info *oti)
+			      struct obdo *obdo)
 {
 	int rc;
 
 	EXP_CHECK_DT_OP(exp, destroy);
 	EXP_COUNTER_INCREMENT(exp, destroy);
 
-	rc = OBP(exp->exp_obd, destroy)(env, exp, obdo, oti);
+	rc = OBP(exp->exp_obd, destroy)(env, exp, obdo);
 	return rc;
 }
 
@@ -722,15 +722,14 @@ static inline int obd_getattr(const struct lu_env *env, struct obd_export *exp,
 }
 
 static inline int obd_setattr(const struct lu_env *env, struct obd_export *exp,
-			      struct obd_info *oinfo,
-			      struct obd_trans_info *oti)
+			      struct obd_info *oinfo)
 {
 	int rc;
 
 	EXP_CHECK_DT_OP(exp, setattr);
 	EXP_COUNTER_INCREMENT(exp, setattr);
 
-	rc = OBP(exp->exp_obd, setattr)(env, exp, oinfo, oti);
+	rc = OBP(exp->exp_obd, setattr)(env, exp, oinfo);
 	return rc;
 }
 
@@ -1056,8 +1055,7 @@ static inline int obd_preprw(const struct lu_env *env, int cmd,
 			     struct obd_export *exp, struct obdo *oa,
 			     int objcount, struct obd_ioobj *obj,
 			     struct niobuf_remote *remote, int *pages,
-			     struct niobuf_local *local,
-			     struct obd_trans_info *oti)
+			     struct niobuf_local *local)
 {
 	int rc;
 
@@ -1065,7 +1063,7 @@ static inline int obd_preprw(const struct lu_env *env, int cmd,
 	EXP_COUNTER_INCREMENT(exp, preprw);
 
 	rc = OBP(exp->exp_obd, preprw)(env, cmd, exp, oa, objcount, obj, remote,
-				       pages, local, oti);
+				       pages, local);
 	return rc;
 }
 
@@ -1073,14 +1071,13 @@ static inline int obd_commitrw(const struct lu_env *env, int cmd,
 			       struct obd_export *exp, struct obdo *oa,
 			       int objcount, struct obd_ioobj *obj,
 			       struct niobuf_remote *rnb, int pages,
-			       struct niobuf_local *local,
-			       struct obd_trans_info *oti, int rc)
+			       struct niobuf_local *local, int rc)
 {
 	EXP_CHECK_DT_OP(exp, commitrw);
 	EXP_COUNTER_INCREMENT(exp, commitrw);
 
 	rc = OBP(exp->exp_obd, commitrw)(env, cmd, exp, oa, objcount, obj,
-					 rnb, pages, local, oti, rc);
+					 rnb, pages, local, rc);
 	return rc;
 }
 
@@ -1507,14 +1504,12 @@ static inline enum ldlm_mode md_lock_match(struct obd_export *exp, __u64 flags,
 					     policy, mode, lockh);
 }
 
-static inline int md_init_ea_size(struct obd_export *exp, int easize,
-				  int def_asize, int cookiesize,
-				  int def_cookiesize)
+static inline int md_init_ea_size(struct obd_export *exp, u32 easize,
+				  u32 def_asize)
 {
 	EXP_CHECK_MD_OP(exp, init_ea_size);
 	EXP_MD_COUNTER_INCREMENT(exp, init_ea_size);
-	return MDP(exp->exp_obd, init_ea_size)(exp, easize, def_asize,
-					       cookiesize, def_cookiesize);
+	return MDP(exp->exp_obd, init_ea_size)(exp, easize, def_asize);
 }
 
 static inline int md_intent_getattr_async(struct obd_export *exp,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index f3128b6..4f9480e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -399,9 +399,8 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	}
 
 	cli->cl_import = imp;
-	/* cli->cl_max_mds_{easize,cookiesize} updated by mdc_init_ea_size() */
+	/* cli->cl_max_mds_easize updated by mdc_init_ea_size() */
 	cli->cl_max_mds_easize = sizeof(struct lov_mds_md_v3);
-	cli->cl_max_mds_cookiesize = sizeof(struct llog_cookie);
 
 	if (LUSTRE_CFG_BUFLEN(lcfg, 3) > 0) {
 		if (!strcmp(lustre_cfg_string(lcfg, 3), "inactive")) {
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index 07d38e5..4562643 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -49,7 +49,7 @@ int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
 {
 	struct lov_stripe_md lsm = { .lsm_magic = LOV_MAGIC_V3 };
 	__u32 valsize = sizeof(struct lov_desc);
-	int rc, easize, def_easize, cookiesize;
+	int rc, easize, def_easize;
 	struct lov_desc desc;
 	__u16 stripes, def_stripes;
 
@@ -67,16 +67,9 @@ int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
 	lsm.lsm_stripe_count = def_stripes;
 	def_easize = obd_size_diskmd(dt_exp, &lsm);
 
-	cookiesize = stripes * sizeof(struct llog_cookie);
+	CDEBUG(D_HA, "updating def/max_easize: %d/%d\n", def_easize, easize);
 
-	/* default cookiesize is 0 because from 2.4 server doesn't send
-	 * llog cookies to client.
-	 */
-	CDEBUG(D_HA,
-	       "updating def/max_easize: %d/%d def/max_cookiesize: 0/%d\n",
-	       def_easize, easize, cookiesize);
-
-	rc = md_init_ea_size(md_exp, easize, def_easize, cookiesize, 0);
+	rc = md_init_ea_size(md_exp, easize, def_easize);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 67969a8..75f5958 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -245,8 +245,7 @@ static int lmv_connect(const struct lu_env *env,
 	return rc;
 }
 
-static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize,
-			    u32 cookiesize, u32 def_cookiesize)
+static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 {
 	struct obd_device   *obd = exp->exp_obd;
 	struct lmv_obd      *lmv = &obd->u.lmv;
@@ -262,14 +261,7 @@ static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize,
 		lmv->max_def_easize = def_easize;
 		change = 1;
 	}
-	if (lmv->max_cookiesize < cookiesize) {
-		lmv->max_cookiesize = cookiesize;
-		change = 1;
-	}
-	if (lmv->max_def_cookiesize < def_cookiesize) {
-		lmv->max_def_cookiesize = def_cookiesize;
-		change = 1;
-	}
+
 	if (change == 0)
 		return 0;
 
@@ -284,8 +276,7 @@ static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize,
 			continue;
 		}
 
-		rc = md_init_ea_size(tgt->ltd_exp, easize, def_easize,
-				     cookiesize, def_cookiesize);
+		rc = md_init_ea_size(tgt->ltd_exp, easize, def_easize);
 		if (rc) {
 			CERROR("%s: obd_init_ea_size() failed on MDT target %d: rc = %d\n",
 			       obd->obd_name, i, rc);
@@ -368,8 +359,7 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 	tgt->ltd_exp = mdc_exp;
 	lmv->desc.ld_active_tgt_count++;
 
-	md_init_ea_size(tgt->ltd_exp, lmv->max_easize, lmv->max_def_easize,
-			lmv->max_cookiesize, lmv->max_def_cookiesize);
+	md_init_ea_size(tgt->ltd_exp, lmv->max_easize, lmv->max_def_easize);
 
 	CDEBUG(D_CONFIG, "Connected to %s(%s) successfully (%d)\n",
 	       mdc_obd->obd_name, mdc_obd->obd_uuid.uuid,
@@ -483,7 +473,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		} else {
 			int easize = sizeof(struct lmv_stripe_md) +
 				lmv->desc.ld_tgt_count * sizeof(struct lu_fid);
-			lmv_init_ea_size(obd->obd_self_export, easize, 0, 0, 0);
+			lmv_init_ea_size(obd->obd_self_export, easize, 0);
 		}
 	}
 
@@ -538,7 +528,7 @@ int lmv_check_connect(struct obd_device *obd)
 	class_export_put(lmv->exp);
 	lmv->connected = 1;
 	easize = lmv_mds_md_size(lmv->desc.ld_tgt_count, LMV_MAGIC);
-	lmv_init_ea_size(obd->obd_self_export, easize, 0, 0, 0);
+	lmv_init_ea_size(obd->obd_self_export, easize, 0);
 	mutex_unlock(&lmv->lmv_init_mutex);
 	return 0;
 
@@ -1282,7 +1272,6 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	obd_str2uuid(&lmv->desc.ld_uuid, desc->ld_uuid.uuid);
 	lmv->desc.ld_tgt_count = 0;
 	lmv->desc.ld_active_tgt_count = 0;
-	lmv->max_cookiesize = 0;
 	lmv->max_def_easize = 0;
 	lmv->max_easize = 0;
 	lmv->lmv_placement = PLACEMENT_CHAR_POLICY;
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 4d2b7d3..2b03938 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -412,7 +412,6 @@ struct lov_io_sub {
 	int		  sub_refcheck;
 	int		  sub_refcheck2;
 	int		  sub_reenter;
-	void		*sub_cookie;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 60397a2..bd105d9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -110,8 +110,6 @@ struct lov_request_set {
 	atomic_t			set_completes;
 	atomic_t			set_success;
 	atomic_t			set_finish_checked;
-	struct llog_cookie		*set_cookies;
-	int				set_cookie_sent;
 	struct list_head			set_list;
 	wait_queue_head_t			set_waitq;
 };
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 42e66d1..c8734a6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -44,7 +44,6 @@ static void lov_init_set(struct lov_request_set *set)
 	atomic_set(&set->set_completes, 0);
 	atomic_set(&set->set_success, 0);
 	atomic_set(&set->set_finish_checked, 0);
-	set->set_cookies = NULL;
 	INIT_LIST_HEAD(&set->set_list);
 	atomic_set(&set->set_refcount, 1);
 	init_waitqueue_head(&set->set_waitq);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index f1f6c08..5b3d0ba 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -386,8 +386,6 @@ static struct ptlrpc_request *mdc_intent_unlink_pack(struct obd_export *exp,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obddev->u.cli.cl_default_mds_easize);
-	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
-			     obddev->u.cli.cl_default_mds_cookiesize);
 	ptlrpc_request_set_replen(req);
 	return req;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 6f62a95..1847e5a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -288,8 +288,6 @@ int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obd->u.cli.cl_default_mds_easize);
-	req_capsule_set_size(&req->rq_pill, &RMF_LOGCOOKIES, RCL_SERVER,
-			     obd->u.cli.cl_default_mds_cookiesize);
 	ptlrpc_request_set_replen(req);
 
 	*request = req;
@@ -398,8 +396,6 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obd->u.cli.cl_default_mds_easize);
-	req_capsule_set_size(&req->rq_pill, &RMF_LOGCOOKIES, RCL_SERVER,
-			     obd->u.cli.cl_default_mds_cookiesize);
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_reint(req, obd->u.cli.cl_rpc_lock, LUSTRE_IMP_FULL);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index b62b29f..34ccff8 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -787,8 +787,6 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obd->u.cli.cl_default_mds_easize);
-	req_capsule_set_size(&req->rq_pill, &RMF_LOGCOOKIES, RCL_SERVER,
-			     obd->u.cli.cl_default_mds_cookiesize);
 
 	ptlrpc_request_set_replen(req);
 
@@ -2646,16 +2644,15 @@ err_rpc_lock:
 	return rc;
 }
 
-/* Initialize the default and maximum LOV EA and cookie sizes.  This allows
+/* Initialize the default and maximum LOV EA sizes. This allows
  * us to make MDS RPCs with large enough reply buffers to hold a default
- * sized EA and cookie without having to calculate this (via a call into the
+ * sized EA without having to calculate this (via a call into the
  * LOV + OSCs) each time we make an RPC.  The maximum size is also tracked
  * but not used to avoid wastefully vmalloc()'ing large reply buffers when
  * a large number of stripes is possible.  If a larger reply buffer is
  * required it will be reallocated in the ptlrpc layer due to overflow.
  */
-static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize,
-			    u32 cookiesize, u32 def_cookiesize)
+static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct client_obd *cli = &obd->u.cli;
@@ -2666,12 +2663,6 @@ static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize,
 	if (cli->cl_default_mds_easize < def_easize)
 		cli->cl_default_mds_easize = def_easize;
 
-	if (cli->cl_max_mds_cookiesize < cookiesize)
-		cli->cl_max_mds_cookiesize = cookiesize;
-
-	if (cli->cl_default_mds_cookiesize < def_cookiesize)
-		cli->cl_default_mds_cookiesize = def_cookiesize;
-
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 505582f..df6fbed 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1100,7 +1100,7 @@ out:
 static u64 last_object_id;
 
 static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
-			      struct obdo *oa, struct obd_trans_info *oti)
+			      struct obdo *oa)
 {
 	struct echo_object     *eco;
 	struct echo_client_obd *ec = ed->ed_ec;
@@ -1117,7 +1117,7 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 	if (!ostid_id(&oa->o_oi))
 		ostid_set_id(&oa->o_oi, ++last_object_id);
 
-	rc = obd_create(env, ec->ec_exp, oa, oti);
+	rc = obd_create(env, ec->ec_exp, oa);
 	if (rc != 0) {
 		CERROR("Cannot create objects: rc = %d\n", rc);
 		goto failed;
@@ -1137,7 +1137,7 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 
  failed:
 	if (created && rc)
-		obd_destroy(env, ec->ec_exp, oa, oti);
+		obd_destroy(env, ec->ec_exp, oa);
 	if (rc)
 		CERROR("create object failed with: rc = %d\n", rc);
 	return rc;
@@ -1237,8 +1237,7 @@ static int echo_client_page_debug_check(struct page *page, u64 id,
 
 static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 			    struct echo_object *eco, u64 offset,
-			    u64 count, int async,
-			    struct obd_trans_info *oti)
+			    u64 count, int async)
 {
 	u32	       npages;
 	struct brw_page	*pga;
@@ -1332,8 +1331,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 				   struct obd_export *exp, int rw,
 				   struct obdo *oa, struct echo_object *eco,
 				   u64 offset, u64 count,
-				   u64 batch, struct obd_trans_info *oti,
-				   int async)
+				   u64 batch, int async)
 {
 	struct obd_ioobj ioo;
 	struct niobuf_local *lnb;
@@ -1378,8 +1376,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 		ioo.ioo_bufcnt = npages;
 
 		lpages = npages;
-		ret = obd_preprw(env, rw, exp, oa, 1, &ioo, rnb, &lpages,
-				 lnb, oti);
+		ret = obd_preprw(env, rw, exp, oa, 1, &ioo, rnb, &lpages, lnb);
 		if (ret != 0)
 			goto out;
 		LASSERT(lpages == npages);
@@ -1411,14 +1408,11 @@ static int echo_client_prep_commit(const struct lu_env *env,
 							     rnb[i].rnb_len);
 		}
 
-		ret = obd_commitrw(env, rw, exp, oa, 1, &ioo,
-				   rnb, npages, lnb, oti, ret);
+		ret = obd_commitrw(env, rw, exp, oa, 1, &ioo, rnb, npages, lnb,
+				   ret);
 		if (ret != 0)
 			goto out;
 
-		/* Reset oti otherwise it would confuse ldiskfs. */
-		memset(oti, 0, sizeof(*oti));
-
 		/* Reuse env context. */
 		lu_context_exit((struct lu_context *)&env->le_ctx);
 		lu_context_enter((struct lu_context *)&env->le_ctx);
@@ -1432,8 +1426,7 @@ out:
 
 static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 				 struct obd_export *exp,
-				 struct obd_ioctl_data *data,
-				 struct obd_trans_info *dummy_oti)
+				 struct obd_ioctl_data *data)
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct echo_device *ed = obd2echo_dev(obd);
@@ -1470,15 +1463,13 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 	case 1:
 		/* fall through */
 	case 2:
-		rc = echo_client_kbrw(ed, rw, oa,
-				      eco, data->ioc_offset,
-				      data->ioc_count, async, dummy_oti);
+		rc = echo_client_kbrw(ed, rw, oa, eco, data->ioc_offset,
+				      data->ioc_count, async);
 		break;
 	case 3:
-		rc = echo_client_prep_commit(env, ec->ec_exp, rw, oa,
-					     eco, data->ioc_offset,
-					     data->ioc_count, data->ioc_plen1,
-					     dummy_oti, async);
+		rc = echo_client_prep_commit(env, ec->ec_exp, rw, oa, eco,
+					     data->ioc_offset, data->ioc_count,
+					     data->ioc_plen1, async);
 		break;
 	default:
 		rc = -EINVAL;
@@ -1496,16 +1487,11 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	struct echo_client_obd *ec = ed->ed_ec;
 	struct echo_object     *eco;
 	struct obd_ioctl_data  *data = karg;
-	struct obd_trans_info   dummy_oti;
 	struct lu_env	  *env;
-	struct oti_req_ack_lock *ack_lock;
 	struct obdo	    *oa;
 	struct lu_fid	   fid;
 	int		     rw = OBD_BRW_READ;
 	int		     rc = 0;
-	int		     i;
-
-	memset(&dummy_oti, 0, sizeof(dummy_oti));
 
 	oa = &data->ioc_obdo1;
 	if (!(oa->o_valid & OBD_MD_FLGROUP)) {
@@ -1535,7 +1521,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			goto out;
 		}
 
-		rc = echo_create_object(env, ed, oa, &dummy_oti);
+		rc = echo_create_object(env, ed, oa);
 		goto out;
 
 	case OBD_IOC_DESTROY:
@@ -1546,7 +1532,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 		rc = echo_get_object(&eco, ed, oa);
 		if (rc == 0) {
-			rc = obd_destroy(env, ec->ec_exp, oa, &dummy_oti);
+			rc = obd_destroy(env, ec->ec_exp, oa);
 			if (rc == 0)
 				eco->eo_deleted = 1;
 			echo_put_object(eco);
@@ -1577,7 +1563,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 				.oi_oa = oa,
 			};
 
-			rc = obd_setattr(env, ec->ec_exp, &oinfo, NULL);
+			rc = obd_setattr(env, ec->ec_exp, &oinfo);
 			echo_put_object(eco);
 		}
 		goto out;
@@ -1591,7 +1577,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		rw = OBD_BRW_WRITE;
 		/* fall through */
 	case OBD_IOC_BRW_READ:
-		rc = echo_client_brw_ioctl(env, rw, exp, data, &dummy_oti);
+		rc = echo_client_brw_ioctl(env, rw, exp, data);
 		goto out;
 
 	default:
@@ -1604,14 +1590,6 @@ out:
 	lu_env_fini(env);
 	kfree(env);
 
-	/* XXX this should be in a helper also called by target_send_reply */
-	for (ack_lock = dummy_oti.oti_ack_locks, i = 0; i < 4;
-	     i++, ack_lock++) {
-		if (!ack_lock->mode)
-			break;
-		ldlm_lock_decref(&ack_lock->lock, ack_lock->mode);
-	}
-
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index ab7f82d..64d95c1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -221,7 +221,7 @@ static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 }
 
 static int osc_setattr(const struct lu_env *env, struct obd_export *exp,
-		       struct obd_info *oinfo, struct obd_trans_info *oti)
+		       struct obd_info *oinfo)
 {
 	struct ptlrpc_request *req;
 	struct ost_body *body;
@@ -329,7 +329,7 @@ int osc_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
 }
 
 static int osc_create(const struct lu_env *env, struct obd_export *exp,
-		      struct obdo *oa, struct obd_trans_info *oti)
+		      struct obdo *oa)
 {
 	struct ptlrpc_request *req;
 	struct ost_body *body;
@@ -358,15 +358,6 @@ static int osc_create(const struct lu_env *env, struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 
-	if ((oa->o_valid & OBD_MD_FLFLAGS) &&
-	    oa->o_flags == OBD_FL_DELORPHAN) {
-		DEBUG_REQ(D_HA, req,
-			  "delorphan from OST integration");
-		/* Don't resend the delorphan req */
-		req->rq_no_resend = 1;
-		req->rq_no_delay = 1;
-	}
-
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
 		goto out_req;
@@ -383,12 +374,6 @@ static int osc_create(const struct lu_env *env, struct obd_export *exp,
 	oa->o_blksize = cli_brw_size(exp->exp_obd);
 	oa->o_valid |= OBD_MD_FLBLKSZ;
 
-	if (oti && oa->o_valid & OBD_MD_FLCOOKIE) {
-		if (!oti->oti_logcookies)
-			oti->oti_logcookies = &oti->oti_onecookie;
-		*oti->oti_logcookies = oa->o_lcookie;
-	}
-
 	CDEBUG(D_HA, "transno: %lld\n",
 	       lustre_msg_get_transno(req->rq_repmsg));
 out_req:
@@ -569,19 +554,8 @@ static int osc_can_send_destroy(struct client_obd *cli)
 	return 0;
 }
 
-/* Destroy requests can be async always on the client, and we don't even really
- * care about the return code since the client cannot do anything at all about
- * a destroy failure.
- * When the MDS is unlinking a filename, it saves the file objects into a
- * recovery llog, and these object records are cancelled when the OST reports
- * they were destroyed and sync'd to disk (i.e. transaction committed).
- * If the client dies, or the OST is down when the object should be destroyed,
- * the records are not cancelled, and when the OST reconnects to the MDS next,
- * it will retrieve the llog unlink logs and then sends the log cancellation
- * cookies to the MDS after committing destroy transactions.
- */
 static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
-		       struct obdo *oa, struct obd_trans_info *oti)
+		       struct obdo *oa)
 {
 	struct client_obd *cli = &exp->exp_obd->u.cli;
 	struct ptlrpc_request *req;
@@ -613,32 +587,22 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 	req->rq_request_portal = OST_IO_PORTAL; /* bug 7198 */
 	ptlrpc_at_set_req_timeout(req);
 
-	if (oti && oa->o_valid & OBD_MD_FLCOOKIE)
-		oa->o_lcookie = *oti->oti_logcookies;
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
 	LASSERT(body);
 	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa, oa);
 
 	ptlrpc_request_set_replen(req);
 
-	/* If osc_destroy is for destroying the unlink orphan,
-	 * sent from MDT to OST, which should not be blocked here,
-	 * because the process might be triggered by ptlrpcd, and
-	 * it is not good to block ptlrpcd thread (b=16006
-	 **/
-	if (!(oa->o_flags & OBD_FL_DELORPHAN)) {
-		req->rq_interpret_reply = osc_destroy_interpret;
-		if (!osc_can_send_destroy(cli)) {
-			struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP,
-							  NULL);
-
-			/*
-			 * Wait until the number of on-going destroy RPCs drops
-			 * under max_rpc_in_flight
-			 */
-			l_wait_event_exclusive(cli->cl_destroy_waitq,
-					       osc_can_send_destroy(cli), &lwi);
-		}
+	req->rq_interpret_reply = osc_destroy_interpret;
+	if (!osc_can_send_destroy(cli)) {
+		struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
+
+		/*
+		 * Wait until the number of on-going destroy RPCs drops
+		 * under max_rpc_in_flight
+		 */
+		l_wait_event_exclusive(cli->cl_destroy_waitq,
+				       osc_can_send_destroy(cli), &lwi);
 	}
 
 	/* Do not wait for response */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index bca781a..1c06b4e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1706,7 +1706,7 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 	__swab32s(&b->mbo_eadatasize);
 	__swab32s(&b->mbo_aclsize);
 	__swab32s(&b->mbo_max_mdsize);
-	__swab32s(&b->mbo_max_cookiesize);
+	CLASSERT(offsetof(typeof(*b), mbo_unused3));
 	__swab32s(&b->mbo_uid_h);
 	__swab32s(&b->mbo_gid_h);
 	CLASSERT(offsetof(typeof(*b), mbo_padding_5) != 0);
@@ -2103,8 +2103,6 @@ static void dump_obdo(struct obdo *oa)
 	if (valid & OBD_MD_FLHANDLE)
 		CDEBUG(D_RPCTRACE, "obdo: o_handle = %lld\n",
 		       oa->o_handle.cookie);
-	if (valid & OBD_MD_FLCOOKIE)
-		CDEBUG(D_RPCTRACE, "obdo: o_lcookie = (llog_cookie dumping not yet implemented)\n");
 }
 
 void dump_ost_body(struct ost_body *ob)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 391e83e..a6edc8d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1245,8 +1245,6 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLCKSUM);
 	LASSERTF(OBD_MD_FLQOS == (0x00200000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLQOS);
-	LASSERTF(OBD_MD_FLCOOKIE == (0x00800000ULL), "found 0x%.16llxULL\n",
-		 OBD_MD_FLCOOKIE);
 	LASSERTF(OBD_MD_FLGROUP == (0x01000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLGROUP);
 	LASSERTF(OBD_MD_FLFID == (0x02000000ULL), "found 0x%.16llxULL\n",
@@ -1823,10 +1821,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_body, mbo_max_mdsize));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_max_mdsize) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_max_mdsize));
-	LASSERTF((int)offsetof(struct mdt_body, mbo_max_cookiesize) == 160, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, mbo_max_cookiesize));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_max_cookiesize) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_max_cookiesize));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_unused3) == 160, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_unused3));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_unused3) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_unused3));
 	LASSERTF((int)offsetof(struct mdt_body, mbo_uid_h) == 164, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_body, mbo_uid_h));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_uid_h) == 4, "found %lld\n",
-- 
1.7.1
