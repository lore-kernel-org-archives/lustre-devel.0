From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:35 -0400
Subject: [lustre-devel] [PATCH 39/41] staging: lustre: osc: remove remaining
	bits for capa support
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

With capa support removed from the OSC layer a few more bits
can be cleaned up. Convert the OBD getattr and setattr paths
to use struct obdo rather than struct obd_info. Remove
the oi_policy, oi_oa, and oi_capa members from struct obd_info.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3105
Reviewed-on: http://review.whamcloud.com/14640
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |   13 +----
 drivers/staging/lustre/lustre/include/obd_class.h  |   17 ++++----
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    1 -
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    7 ++-
 drivers/staging/lustre/lustre/lov/lov_request.c    |    2 -
 .../staging/lustre/lustre/obdecho/echo_client.c    |   12 +----
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    1 -
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    6 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   11 +----
 drivers/staging/lustre/lustre/osc/osc_request.c    |   45 ++++++++++----------
 10 files changed, 46 insertions(+), 69 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index a977388..f63336f 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -126,17 +126,10 @@ typedef int (*obd_enqueue_update_f)(void *cookie, int rc);
 
 /* obd info for a particular level (lov, osc). */
 struct obd_info {
-	/* Flags used for set request specific flags:
-	   - while lock handling, the flags obtained on the enqueue
-	   request are set here.
-	   - while stats, the flags used for control delay/resend.
-	   - while setattr, the flags used for distinguish punch operation
-	 */
+	/* OBD_STATFS_* flags */
 	__u64		   oi_flags;
 	/* lsm data specific for every OSC. */
 	struct lov_stripe_md   *oi_md;
-	/* obdo data specific for every OSC, if needed at all. */
-	struct obdo	    *oi_oa;
 	/* statfs data specific for every OSC, if needed at all. */
 	struct obd_statfs      *oi_osfs;
 	/* An update callback which is called to update some data on upper
@@ -871,9 +864,9 @@ struct obd_ops {
 	int (*destroy)(const struct lu_env *env, struct obd_export *exp,
 		       struct obdo *oa);
 	int (*setattr)(const struct lu_env *, struct obd_export *exp,
-		       struct obd_info *oinfo);
+		       struct obdo *oa);
 	int (*getattr)(const struct lu_env *env, struct obd_export *exp,
-		       struct obd_info *oinfo);
+		       struct obdo *oa);
 	int (*preprw)(const struct lu_env *env, int cmd,
 		      struct obd_export *exp, struct obdo *oa, int objcount,
 		      struct obd_ioobj *obj, struct niobuf_remote *remote,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 7d8f062..0eaea54 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -705,26 +705,26 @@ static inline int obd_destroy(const struct lu_env *env, struct obd_export *exp,
 }
 
 static inline int obd_getattr(const struct lu_env *env, struct obd_export *exp,
-			      struct obd_info *oinfo)
+			      struct obdo *oa)
 {
 	int rc;
 
 	EXP_CHECK_DT_OP(exp, getattr);
 	EXP_COUNTER_INCREMENT(exp, getattr);
 
-	rc = OBP(exp->exp_obd, getattr)(env, exp, oinfo);
+	rc = OBP(exp->exp_obd, getattr)(env, exp, oa);
 	return rc;
 }
 
 static inline int obd_setattr(const struct lu_env *env, struct obd_export *exp,
-			      struct obd_info *oinfo)
+			      struct obdo *oa)
 {
 	int rc;
 
 	EXP_CHECK_DT_OP(exp, setattr);
 	EXP_COUNTER_INCREMENT(exp, setattr);
 
-	rc = OBP(exp->exp_obd, setattr)(env, exp, oinfo);
+	rc = OBP(exp->exp_obd, setattr)(env, exp, oa);
 	return rc;
 }
 
@@ -991,15 +991,16 @@ static inline int obd_statfs_rqset(struct obd_export *exp,
 				   __u32 flags)
 {
 	struct ptlrpc_request_set *set = NULL;
-	struct obd_info oinfo = { };
+	struct obd_info oinfo = {
+		.oi_osfs = osfs,
+		.oi_flags = flags,
+	};
 	int rc = 0;
 
-	set =  ptlrpc_prep_set();
+	set = ptlrpc_prep_set();
 	if (!set)
 		return -ENOMEM;
 
-	oinfo.oi_osfs = osfs;
-	oinfo.oi_flags = flags;
 	rc = obd_statfs_async(exp, &oinfo, max_age, set);
 	if (rc == 0)
 		rc = ptlrpc_set_wait(set);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index a025b35..09fa357 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -44,7 +44,6 @@ enum obd_notify_event;
 struct inode;
 struct lov_stripe_md;
 struct lustre_md;
-struct obd_capa;
 struct obd_device;
 struct obd_export;
 struct page;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 18cb92d..6530187 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1033,7 +1033,10 @@ static int lov_statfs(const struct lu_env *env, struct obd_export *exp,
 		      struct obd_statfs *osfs, __u64 max_age, __u32 flags)
 {
 	struct ptlrpc_request_set *set = NULL;
-	struct obd_info oinfo = { };
+	struct obd_info oinfo = {
+		.oi_osfs = osfs,
+		.oi_flags = flags,
+	};
 	int rc = 0;
 
 	/* for obdclass we forbid using obd_statfs_rqset, but prefer using async
@@ -1043,8 +1046,6 @@ static int lov_statfs(const struct lu_env *env, struct obd_export *exp,
 	if (!set)
 		return -ENOMEM;
 
-	oinfo.oi_osfs = osfs;
-	oinfo.oi_flags = flags;
 	rc = lov_statfs_async(exp, &oinfo, max_age, set);
 	if (rc == 0)
 		rc = ptlrpc_set_wait(set);
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index c8734a6..d43cc88 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -60,8 +60,6 @@ void lov_finish_set(struct lov_request_set *set)
 							 rq_link);
 		list_del_init(&req->rq_link);
 
-		if (req->rq_oi.oi_oa)
-			kmem_cache_free(obdo_cachep, req->rq_oi.oi_oa);
 		kfree(req->rq_oi.oi_osfs);
 		kfree(req);
 	}
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index df6fbed..d8e3e96 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1542,11 +1542,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	case OBD_IOC_GETATTR:
 		rc = echo_get_object(&eco, ed, oa);
 		if (rc == 0) {
-			struct obd_info oinfo = {
-				.oi_oa = oa,
-			};
-
-			rc = obd_getattr(env, ec->ec_exp, &oinfo);
+			rc = obd_getattr(env, ec->ec_exp, oa);
 			echo_put_object(eco);
 		}
 		goto out;
@@ -1559,11 +1555,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 		rc = echo_get_object(&eco, ed, oa);
 		if (rc == 0) {
-			struct obd_info oinfo = {
-				.oi_oa = oa,
-			};
-
-			rc = obd_setattr(env, ec->ec_exp, &oinfo);
+			rc = obd_setattr(env, ec->ec_exp, oa);
 			echo_put_object(eco);
 		}
 		goto out;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 9c8de15..8a55412 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -77,7 +77,6 @@ struct osc_io {
 
 	/** write osc_lock for this IO, used by osc_extent_find(). */
 	struct osc_lock   *oi_write_osclock;
-	struct obd_info    oi_info;
 	struct obdo	oi_oa;
 	struct osc_async_cbargs {
 		bool		  opc_rpc_sent;
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 61bfacb..dc708ea 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -118,13 +118,13 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		   __u64 *flags, void *data, struct lustre_handle *lockh,
 		   int unref);
 
-int osc_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
+int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		      obd_enqueue_update_f upcall, void *cookie,
 		      struct ptlrpc_request_set *rqset);
-int osc_punch_base(struct obd_export *exp, struct obd_info *oinfo,
+int osc_punch_base(struct obd_export *exp, struct obdo *oa,
 		   obd_enqueue_update_f upcall, void *cookie,
 		   struct ptlrpc_request_set *rqset);
-int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
+int osc_sync_base(struct obd_export *exp, struct obdo *oa,
 		  obd_enqueue_update_f upcall, void *cookie,
 		  struct ptlrpc_request_set *rqset);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index b4e062d..8eb4275 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -484,7 +484,6 @@ static int osc_io_setattr_start(const struct lu_env *env,
 	__u64 size = io->u.ci_setattr.sa_attr.lvb_size;
 	unsigned int ia_valid = io->u.ci_setattr.sa_valid;
 	int result = 0;
-	struct obd_info oinfo = { };
 
 	/* truncate cache dirty pages first */
 	if (cl_io_is_trunc(io))
@@ -554,16 +553,15 @@ static int osc_io_setattr_start(const struct lu_env *env,
 			oa->o_valid |= OBD_MD_FLFLAGS;
 		}
 
-		oinfo.oi_oa = oa;
 		init_completion(&cbargs->opc_sync);
 
 		if (ia_valid & ATTR_SIZE)
 			result = osc_punch_base(osc_export(cl2osc(obj)),
-						&oinfo, osc_async_upcall,
+						oa, osc_async_upcall,
 						cbargs, PTLRPCD_SET);
 		else
 			result = osc_setattr_async(osc_export(cl2osc(obj)),
-						   &oinfo, osc_async_upcall,
+						   oa, osc_async_upcall,
 						   cbargs, PTLRPCD_SET);
 		cbargs->opc_rpc_sent = result == 0;
 	}
@@ -745,7 +743,6 @@ static int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 {
 	struct osc_io *oio = osc_env_io(env);
 	struct obdo *oa = &oio->oi_oa;
-	struct obd_info *oinfo = &oio->oi_info;
 	struct lov_oinfo *loi = obj->oo_oinfo;
 	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
 	int rc = 0;
@@ -761,11 +758,9 @@ static int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 
 	obdo_set_parent_fid(oa, fio->fi_fid);
 
-	memset(oinfo, 0, sizeof(*oinfo));
-	oinfo->oi_oa = oa;
 	init_completion(&cbargs->opc_sync);
 
-	rc = osc_sync_base(osc_export(obj), oinfo, osc_async_upcall, cbargs,
+	rc = osc_sync_base(osc_export(obj), oa, osc_async_upcall, cbargs,
 			   PTLRPCD_SET);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 64d95c1..0985bda 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -82,7 +82,7 @@ struct osc_setattr_args {
 };
 
 struct osc_fsync_args {
-	struct obd_info     *fa_oi;
+	struct obdo		*fa_oa;
 	obd_enqueue_update_f fa_upcall;
 	void		*fa_cookie;
 };
@@ -166,19 +166,18 @@ static int osc_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 }
 
 static inline void osc_pack_req_body(struct ptlrpc_request *req,
-				     struct obd_info *oinfo)
+				     struct obdo *oa)
 {
 	struct ost_body *body;
 
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
 	LASSERT(body);
 
-	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa,
-			     oinfo->oi_oa);
+	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa, oa);
 }
 
 static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
-		       struct obd_info *oinfo)
+		       struct obdo *oa)
 {
 	struct ptlrpc_request *req;
 	struct ost_body *body;
@@ -194,7 +193,7 @@ static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 		return rc;
 	}
 
-	osc_pack_req_body(req, oinfo);
+	osc_pack_req_body(req, oa);
 
 	ptlrpc_request_set_replen(req);
 
@@ -209,11 +208,11 @@ static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 	}
 
 	CDEBUG(D_INODE, "mode: %o\n", body->oa.o_mode);
-	lustre_get_wire_obdo(&req->rq_import->imp_connect_data, oinfo->oi_oa,
+	lustre_get_wire_obdo(&req->rq_import->imp_connect_data, oa,
 			     &body->oa);
 
-	oinfo->oi_oa->o_blksize = cli_brw_size(exp->exp_obd);
-	oinfo->oi_oa->o_valid |= OBD_MD_FLBLKSZ;
+	oa->o_blksize = cli_brw_size(exp->exp_obd);
+	oa->o_valid |= OBD_MD_FLBLKSZ;
 
  out:
 	ptlrpc_req_finished(req);
@@ -221,13 +220,13 @@ static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 }
 
 static int osc_setattr(const struct lu_env *env, struct obd_export *exp,
-		       struct obd_info *oinfo)
+		       struct obdo *oa)
 {
 	struct ptlrpc_request *req;
 	struct ost_body *body;
 	int rc;
 
-	LASSERT(oinfo->oi_oa->o_valid & OBD_MD_FLGROUP);
+	LASSERT(oa->o_valid & OBD_MD_FLGROUP);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_SETATTR);
 	if (!req)
@@ -239,7 +238,7 @@ static int osc_setattr(const struct lu_env *env, struct obd_export *exp,
 		return rc;
 	}
 
-	osc_pack_req_body(req, oinfo);
+	osc_pack_req_body(req, oa);
 
 	ptlrpc_request_set_replen(req);
 
@@ -253,7 +252,7 @@ static int osc_setattr(const struct lu_env *env, struct obd_export *exp,
 		goto out;
 	}
 
-	lustre_get_wire_obdo(&req->rq_import->imp_connect_data, oinfo->oi_oa,
+	lustre_get_wire_obdo(&req->rq_import->imp_connect_data, oa,
 			     &body->oa);
 
 out:
@@ -283,7 +282,7 @@ out:
 	return rc;
 }
 
-int osc_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
+int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		      obd_enqueue_update_f upcall, void *cookie,
 		      struct ptlrpc_request_set *rqset)
 {
@@ -301,7 +300,7 @@ int osc_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
 		return rc;
 	}
 
-	osc_pack_req_body(req, oinfo);
+	osc_pack_req_body(req, oa);
 
 	ptlrpc_request_set_replen(req);
 
@@ -315,7 +314,7 @@ int osc_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
 
 		CLASSERT(sizeof(*sa) <= sizeof(req->rq_async_args));
 		sa = ptlrpc_req_async_args(req);
-		sa->sa_oa = oinfo->oi_oa;
+		sa->sa_oa = oa;
 		sa->sa_upcall = upcall;
 		sa->sa_cookie = cookie;
 
@@ -382,7 +381,7 @@ out:
 	return rc;
 }
 
-int osc_punch_base(struct obd_export *exp, struct obd_info *oinfo,
+int osc_punch_base(struct obd_export *exp, struct obdo *oa,
 		   obd_enqueue_update_f upcall, void *cookie,
 		   struct ptlrpc_request_set *rqset)
 {
@@ -406,14 +405,14 @@ int osc_punch_base(struct obd_export *exp, struct obd_info *oinfo,
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
 	LASSERT(body);
 	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa,
-			     oinfo->oi_oa);
+			     oa);
 
 	ptlrpc_request_set_replen(req);
 
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_setattr_interpret;
 	CLASSERT(sizeof(*sa) <= sizeof(req->rq_async_args));
 	sa = ptlrpc_req_async_args(req);
-	sa->sa_oa = oinfo->oi_oa;
+	sa->sa_oa = oa;
 	sa->sa_upcall = upcall;
 	sa->sa_cookie = cookie;
 	if (rqset == PTLRPCD_SET)
@@ -441,13 +440,13 @@ static int osc_sync_interpret(const struct lu_env *env,
 		goto out;
 	}
 
-	*fa->fa_oi->oi_oa = body->oa;
+	*fa->fa_oa = body->oa;
 out:
 	rc = fa->fa_upcall(fa->fa_cookie, rc);
 	return rc;
 }
 
-int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
+int osc_sync_base(struct obd_export *exp, struct obdo *oa,
 		  obd_enqueue_update_f upcall, void *cookie,
 		  struct ptlrpc_request_set *rqset)
 {
@@ -470,14 +469,14 @@ int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
 	LASSERT(body);
 	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa,
-			     oinfo->oi_oa);
+			     oa);
 
 	ptlrpc_request_set_replen(req);
 	req->rq_interpret_reply = osc_sync_interpret;
 
 	CLASSERT(sizeof(*fa) <= sizeof(req->rq_async_args));
 	fa = ptlrpc_req_async_args(req);
-	fa->fa_oi = oinfo;
+	fa->fa_oa = oa;
 	fa->fa_upcall = upcall;
 	fa->fa_cookie = cookie;
 
-- 
1.7.1
