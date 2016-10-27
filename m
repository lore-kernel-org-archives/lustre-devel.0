From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:46 -0400
Subject: [lustre-devel] [PATCH 12/29] staging: lustre: mdc: manage number of
	modify RPCs in flight
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Gregoire Pichon <gregoire.pichon@bull.net>, James Simmons <jsimmons@infradead.org>

From: Gregoire Pichon <gregoire.pichon@bull.net>

This patch is the main client part of a new feature that supports
multiple modify metadata RPCs in parallel. Its goal is to improve
metadata operations performance of a single client, while maintening
the consistency of MDT reply reconstruction and MDT recovery
mechanisms.

It allows to manage the number of modify RPCs in flight within
the client obd structure and to assign a virtual index (the tag) to
each modify RPC to help server side cleaning of reply data.

The mdc component uses this feature to send multiple modify RPCs
in parallel.

Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5319
Reviewed-on: http://review.whamcloud.com/14374
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_request.c    |    4 -
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   24 +++
 drivers/staging/lustre/lustre/include/obd.h        |    7 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |    6 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   37 +++++
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   23 +++
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   13 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   23 +--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   50 ++-----
 drivers/staging/lustre/lustre/obdclass/genops.c    |  171 +++++++++++++++++++-
 10 files changed, 293 insertions(+), 65 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index edd72b9..dfef3ca 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -112,11 +112,7 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 
 	ptlrpc_at_set_req_timeout(req);
 
-	if (opc != SEQ_ALLOC_SUPER && seq->lcs_type == LUSTRE_SEQ_METADATA)
-		mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
 	rc = ptlrpc_queue_wait(req);
-	if (opc != SEQ_ALLOC_SUPER && seq->lcs_type == LUSTRE_SEQ_METADATA)
-		mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
 	if (rc)
 		goto out_req;
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 92a5c0f..198ceb0 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -156,6 +156,30 @@ static inline void mdc_put_rpc_lock(struct mdc_rpc_lock *lck,
 	mutex_unlock(&lck->rpcl_mutex);
 }
 
+static inline void mdc_get_mod_rpc_slot(struct ptlrpc_request *req,
+					struct lookup_intent *it)
+{
+	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
+	u32 opc;
+	u16 tag;
+
+	opc = lustre_msg_get_opc(req->rq_reqmsg);
+	tag = obd_get_mod_rpc_slot(cli, opc, it);
+	lustre_msg_set_tag(req->rq_reqmsg, tag);
+}
+
+static inline void mdc_put_mod_rpc_slot(struct ptlrpc_request *req,
+					struct lookup_intent *it)
+{
+	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
+	u32 opc;
+	u16 tag;
+
+	opc = lustre_msg_get_opc(req->rq_reqmsg);
+	tag = lustre_msg_get_tag(req->rq_reqmsg);
+	obd_put_mod_rpc_slot(cli, opc, it, tag);
+}
+
 /**
  * Update the maximum possible easize.
  *
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index c8a6e23..09e3e71 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -263,14 +263,17 @@ struct client_obd {
 	wait_queue_head_t	      cl_destroy_waitq;
 
 	struct mdc_rpc_lock     *cl_rpc_lock;
-	struct mdc_rpc_lock     *cl_close_lock;
 
 	/* modify rpcs in flight
 	 * currently used for metadata only
 	 */
 	spinlock_t		 cl_mod_rpcs_lock;
 	u16			 cl_max_mod_rpcs_in_flight;
-
+	u16			 cl_mod_rpcs_in_flight;
+	u16			 cl_close_rpcs_in_flight;
+	wait_queue_head_t	 cl_mod_rpcs_waitq;
+	unsigned long		*cl_mod_tag_bitmap;
+	struct obd_histogram	 cl_mod_rpcs_hist;
 
 	/* mgc datastruct */
 	atomic_t	     cl_mgc_refcount;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index aba96c3..476b1e4 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -101,6 +101,12 @@ struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid,
 __u32 obd_get_max_rpcs_in_flight(struct client_obd *cli);
 int obd_set_max_rpcs_in_flight(struct client_obd *cli, __u32 max);
 int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max);
+int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq);
+
+u16 obd_get_mod_rpc_slot(struct client_obd *cli, u32 opc,
+			 struct lookup_intent *it);
+void obd_put_mod_rpc_slot(struct client_obd *cli, u32 opc,
+			  struct lookup_intent *it, u16 tag);
 
 struct llog_handle;
 struct llog_rec_hdr;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 4f9480e..ee4bb56 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -372,6 +372,25 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	} else {
 		cli->cl_max_rpcs_in_flight = OBD_MAX_RIF_DEFAULT;
 	}
+
+	spin_lock_init(&cli->cl_mod_rpcs_lock);
+	spin_lock_init(&cli->cl_mod_rpcs_hist.oh_lock);
+	cli->cl_max_mod_rpcs_in_flight = 0;
+	cli->cl_mod_rpcs_in_flight = 0;
+	cli->cl_close_rpcs_in_flight = 0;
+	init_waitqueue_head(&cli->cl_mod_rpcs_waitq);
+	cli->cl_mod_tag_bitmap = NULL;
+
+	if (connect_op == MDS_CONNECT) {
+		cli->cl_max_mod_rpcs_in_flight = cli->cl_max_rpcs_in_flight - 1;
+		cli->cl_mod_tag_bitmap = kcalloc(BITS_TO_LONGS(OBD_MAX_RIF_MAX),
+						 sizeof(long), GFP_NOFS);
+		if (!cli->cl_mod_tag_bitmap) {
+			rc = -ENOMEM;
+			goto err;
+		}
+	}
+
 	rc = ldlm_get_ref();
 	if (rc) {
 		CERROR("ldlm_get_ref failed: %d\n", rc);
@@ -431,12 +450,16 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 err_ldlm:
 	ldlm_put_ref();
 err:
+	kfree(cli->cl_mod_tag_bitmap);
+	cli->cl_mod_tag_bitmap = NULL;
 	return rc;
 }
 EXPORT_SYMBOL(client_obd_setup);
 
 int client_obd_cleanup(struct obd_device *obddev)
 {
+	struct client_obd *cli = &obddev->u.cli;
+
 	ldlm_namespace_free_post(obddev->obd_namespace);
 	obddev->obd_namespace = NULL;
 
@@ -444,6 +467,10 @@ int client_obd_cleanup(struct obd_device *obddev)
 	LASSERT(!obddev->u.cli.cl_import);
 
 	ldlm_put_ref();
+
+	kfree(cli->cl_mod_tag_bitmap);
+	cli->cl_mod_tag_bitmap = NULL;
+
 	return 0;
 }
 EXPORT_SYMBOL(client_obd_cleanup);
@@ -458,6 +485,7 @@ int client_connect_import(const struct lu_env *env,
 	struct obd_import       *imp    = cli->cl_import;
 	struct obd_connect_data *ocd;
 	struct lustre_handle    conn    = { 0 };
+	bool is_mdc = false;
 	int		     rc;
 
 	*exp = NULL;
@@ -484,6 +512,10 @@ int client_connect_import(const struct lu_env *env,
 	ocd = &imp->imp_connect_data;
 	if (data) {
 		*ocd = *data;
+		is_mdc = !strncmp(imp->imp_obd->obd_type->typ_name,
+				  LUSTRE_MDC_NAME, 3);
+		if (is_mdc)
+			data->ocd_connect_flags |= OBD_CONNECT_MULTIMODRPCS;
 		imp->imp_connect_flags_orig = data->ocd_connect_flags;
 	}
 
@@ -499,6 +531,11 @@ int client_connect_import(const struct lu_env *env,
 			 ocd->ocd_connect_flags, "old %#llx, new %#llx\n",
 			 data->ocd_connect_flags, ocd->ocd_connect_flags);
 		data->ocd_connect_flags = ocd->ocd_connect_flags;
+		/* clear the flag as it was not set and is not known
+		 * by upper layers
+		 */
+		if (is_mdc)
+			data->ocd_connect_flags &= ~OBD_CONNECT_MULTIMODRPCS;
 	}
 
 	ptlrpc_pinger_add_import(imp);
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 5fdee9e..c89003a 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -110,6 +110,27 @@ static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(max_mod_rpcs_in_flight);
 
+static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
+{
+	struct obd_device *dev = seq->private;
+
+	return obd_mod_rpc_stats_seq_show(&dev->u.cli, seq);
+}
+
+static ssize_t mdc_rpc_stats_seq_write(struct file *file,
+				       const char __user *buf,
+				       size_t len, loff_t *off)
+{
+	struct seq_file *seq = file->private_data;
+	struct obd_device *dev = seq->private;
+	struct client_obd *cli = &dev->u.cli;
+
+	lprocfs_oh_clear(&cli->cl_mod_rpcs_hist);
+
+	return len;
+}
+LPROC_SEQ_FOPS(mdc_rpc_stats);
+
 LPROC_SEQ_FOPS_WR_ONLY(mdc, ping);
 
 LPROC_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
@@ -149,6 +170,8 @@ static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
 	{ "import",		&mdc_import_fops,		NULL, 0 },
 	{ "state",		&mdc_state_fops,		NULL, 0 },
 	{ "pinger_recov",	&mdc_pinger_recov_fops,		NULL, 0 },
+	{ .name =	"rpc_stats",
+	  .fops =	&mdc_rpc_stats_fops		},
 	{ NULL }
 };
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 5b3d0ba..9bc5314 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -772,15 +772,16 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		req->rq_sent = ktime_get_real_seconds() + resends;
 	}
 
-	/* It is important to obtain rpc_lock first (if applicable), so that
-	 * threads that are serialised with rpc_lock are not polluting our
-	 * rpcs in flight counter. We do not do flock request limiting, though
+	/* It is important to obtain modify RPC slot first (if applicable), so
+	 * that threads that are waiting for a modify RPC slot are not polluting
+	 * our rpcs in flight counter.
+	 * We do not do flock request limiting, though
 	 */
 	if (it) {
-		mdc_get_rpc_lock(obddev->u.cli.cl_rpc_lock, it);
+		mdc_get_mod_rpc_slot(req, it);
 		rc = obd_get_request_slot(&obddev->u.cli);
 		if (rc != 0) {
-			mdc_put_rpc_lock(obddev->u.cli.cl_rpc_lock, it);
+			mdc_put_mod_rpc_slot(req, it);
 			mdc_clear_replay_flag(req, 0);
 			ptlrpc_req_finished(req);
 			return rc;
@@ -807,7 +808,7 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	}
 
 	obd_put_request_slot(&obddev->u.cli);
-	mdc_put_rpc_lock(obddev->u.cli.cl_rpc_lock, it);
+	mdc_put_mod_rpc_slot(req, it);
 
 	if (rc < 0) {
 		CDEBUG(D_INFO, "%s: ldlm_cli_enqueue failed: rc = %d\n",
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 1847e5a..b551c57 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -40,17 +40,15 @@
 #include "../include/lustre_fid.h"
 
 /* mdc_setattr does its own semaphore handling */
-static int mdc_reint(struct ptlrpc_request *request,
-		     struct mdc_rpc_lock *rpc_lock,
-		     int level)
+static int mdc_reint(struct ptlrpc_request *request, int level)
 {
 	int rc;
 
 	request->rq_send_state = level;
 
-	mdc_get_rpc_lock(rpc_lock, NULL);
+	mdc_get_mod_rpc_slot(request, NULL);
 	rc = ptlrpc_queue_wait(request);
-	mdc_put_rpc_lock(rpc_lock, NULL);
+	mdc_put_mod_rpc_slot(request, NULL);
 	if (rc)
 		CDEBUG(D_INFO, "error in handling %d\n", rc);
 	else if (!req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY))
@@ -103,8 +101,6 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 {
 	LIST_HEAD(cancels);
 	struct ptlrpc_request *req;
-	struct mdc_rpc_lock *rpc_lock;
-	struct obd_device *obd = exp->exp_obd;
 	int count = 0, rc;
 	__u64 bits;
 
@@ -131,8 +127,6 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 	}
 
-	rpc_lock = obd->u.cli.cl_rpc_lock;
-
 	if (op_data->op_attr.ia_valid & (ATTR_MTIME | ATTR_CTIME))
 		CDEBUG(D_INODE, "setting mtime %ld, ctime %ld\n",
 		       LTIME_S(op_data->op_attr.ia_mtime),
@@ -141,7 +135,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 
 	ptlrpc_request_set_replen(req);
 
-	rc = mdc_reint(req, rpc_lock, LUSTRE_IMP_FULL);
+	rc = mdc_reint(req, LUSTRE_IMP_FULL);
 
 	if (rc == -ERESTARTSYS)
 		rc = 0;
@@ -220,7 +214,7 @@ int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 	}
 	level = LUSTRE_IMP_FULL;
  resend:
-	rc = mdc_reint(req, exp->exp_obd->u.cli.cl_rpc_lock, level);
+	rc = mdc_reint(req, level);
 
 	/* Resend if we were told to. */
 	if (rc == -ERESTARTSYS) {
@@ -292,7 +286,7 @@ int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 
 	*request = req;
 
-	rc = mdc_reint(req, obd->u.cli.cl_rpc_lock, LUSTRE_IMP_FULL);
+	rc = mdc_reint(req, LUSTRE_IMP_FULL);
 	if (rc == -ERESTARTSYS)
 		rc = 0;
 	return rc;
@@ -302,7 +296,6 @@ int mdc_link(struct obd_export *exp, struct md_op_data *op_data,
 	     struct ptlrpc_request **request)
 {
 	LIST_HEAD(cancels);
-	struct obd_device *obd = exp->exp_obd;
 	struct ptlrpc_request *req;
 	int count = 0, rc;
 
@@ -334,7 +327,7 @@ int mdc_link(struct obd_export *exp, struct md_op_data *op_data,
 	mdc_link_pack(req, op_data);
 	ptlrpc_request_set_replen(req);
 
-	rc = mdc_reint(req, obd->u.cli.cl_rpc_lock, LUSTRE_IMP_FULL);
+	rc = mdc_reint(req, LUSTRE_IMP_FULL);
 	*request = req;
 	if (rc == -ERESTARTSYS)
 		rc = 0;
@@ -398,7 +391,7 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 			     obd->u.cli.cl_default_mds_easize);
 	ptlrpc_request_set_replen(req);
 
-	rc = mdc_reint(req, obd->u.cli.cl_rpc_lock, LUSTRE_IMP_FULL);
+	rc = mdc_reint(req, LUSTRE_IMP_FULL);
 	*request = req;
 	if (rc == -ERESTARTSYS)
 		rc = 0;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index c620f5c..e3a167a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -327,12 +327,12 @@ static int mdc_xattr_common(struct obd_export *exp,
 
 	/* make rpc */
 	if (opcode == MDS_REINT)
-		mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+		mdc_get_mod_rpc_slot(req, NULL);
 
 	rc = ptlrpc_queue_wait(req);
 
 	if (opcode == MDS_REINT)
-		mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+		mdc_put_mod_rpc_slot(req, NULL);
 
 	if (rc)
 		ptlrpc_req_finished(req);
@@ -775,9 +775,9 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 
 	ptlrpc_request_set_replen(req);
 
-	mdc_get_rpc_lock(obd->u.cli.cl_close_lock, NULL);
+	mdc_get_mod_rpc_slot(req, NULL);
 	rc = ptlrpc_queue_wait(req);
-	mdc_put_rpc_lock(obd->u.cli.cl_close_lock, NULL);
+	mdc_put_mod_rpc_slot(req, NULL);
 
 	if (!req->rq_repmsg) {
 		CDEBUG(D_RPCTRACE, "request failed to send: %p, %d\n", req,
@@ -1490,9 +1490,9 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 
-	mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+	mdc_get_mod_rpc_slot(req, NULL);
 	rc = ptlrpc_queue_wait(req);
-	mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+	mdc_put_mod_rpc_slot(req, NULL);
 out:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -1670,9 +1670,9 @@ static int mdc_ioc_hsm_state_set(struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 
-	mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+	mdc_get_mod_rpc_slot(req, NULL);
 	rc = ptlrpc_queue_wait(req);
-	mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+	mdc_put_mod_rpc_slot(req, NULL);
 out:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -1735,9 +1735,9 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 
-	mdc_get_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+	mdc_get_mod_rpc_slot(req, NULL);
 	rc = ptlrpc_queue_wait(req);
-	mdc_put_rpc_lock(exp->exp_obd->u.cli.cl_rpc_lock, NULL);
+	mdc_put_mod_rpc_slot(req, NULL);
 out:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -2582,29 +2582,17 @@ static void mdc_llog_finish(struct obd_device *obd)
 
 static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 {
-	struct client_obd *cli = &obd->u.cli;
 	struct lprocfs_static_vars lvars = { NULL };
 	int rc;
 
-	cli->cl_rpc_lock = kzalloc(sizeof(*cli->cl_rpc_lock), GFP_NOFS);
-	if (!cli->cl_rpc_lock)
-		return -ENOMEM;
-	mdc_init_rpc_lock(cli->cl_rpc_lock);
-
 	rc = ptlrpcd_addref();
 	if (rc < 0)
-		goto err_rpc_lock;
-
-	cli->cl_close_lock = kzalloc(sizeof(*cli->cl_close_lock), GFP_NOFS);
-	if (!cli->cl_close_lock) {
-		rc = -ENOMEM;
-		goto err_ptlrpcd_decref;
-	}
-	mdc_init_rpc_lock(cli->cl_close_lock);
+		return rc;
 
 	rc = client_obd_setup(obd, cfg);
 	if (rc)
-		goto err_close_lock;
+		goto err_ptlrpcd_decref;
+
 	lprocfs_mdc_init_vars(&lvars);
 	lprocfs_obd_setup(obd, lvars.obd_vars, lvars.sysfs_vars);
 	sptlrpc_lprocfs_cliobd_attach(obd);
@@ -2621,17 +2609,10 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 		return rc;
 	}
 
-	spin_lock_init(&cli->cl_mod_rpcs_lock);
-	cli->cl_max_mod_rpcs_in_flight = OBD_MAX_RIF_DEFAULT - 1;
-
 	return rc;
 
-err_close_lock:
-	kfree(cli->cl_close_lock);
 err_ptlrpcd_decref:
 	ptlrpcd_decref();
-err_rpc_lock:
-	kfree(cli->cl_rpc_lock);
 	return rc;
 }
 
@@ -2679,11 +2660,6 @@ static int mdc_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
 
 static int mdc_cleanup(struct obd_device *obd)
 {
-	struct client_obd *cli = &obd->u.cli;
-
-	kfree(cli->cl_rpc_lock);
-	kfree(cli->cl_close_lock);
-
 	ptlrpcd_decref();
 
 	return client_obd_cleanup(obd);
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 62e6636..c7e7374 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -1461,6 +1461,7 @@ int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, __u16 max)
 {
 	struct obd_connect_data *ocd;
 	u16 maxmodrpcs;
+	u16 prev;
 
 	if (max > OBD_MAX_RIF_MAX || max < 1)
 		return -ERANGE;
@@ -1486,10 +1487,178 @@ int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, __u16 max)
 		return -ERANGE;
 	}
 
+	spin_lock(&cli->cl_mod_rpcs_lock);
+
+	prev = cli->cl_max_mod_rpcs_in_flight;
 	cli->cl_max_mod_rpcs_in_flight = max;
 
-	/* will have to wakeup waiters if max has been increased */
+	/* wakeup waiters if limit has been increased */
+	if (cli->cl_max_mod_rpcs_in_flight > prev)
+		wake_up(&cli->cl_mod_rpcs_waitq);
+
+	spin_unlock(&cli->cl_mod_rpcs_lock);
 
 	return 0;
 }
 EXPORT_SYMBOL(obd_set_max_mod_rpcs_in_flight);
+
+#define pct(a, b) (b ? (a * 100) / b : 0)
+
+int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
+{
+	unsigned long mod_tot = 0, mod_cum;
+	struct timespec64 now;
+	int i;
+
+	ktime_get_real_ts64(&now);
+
+	spin_lock(&cli->cl_mod_rpcs_lock);
+
+	seq_printf(seq, "snapshot_time:         %lu.%lu (secs.usecs)\n",
+		   now.tv_sec, now.tv_nsec / 1000);
+	seq_printf(seq, "modify_RPCs_in_flight:  %hu\n",
+		   cli->cl_mod_rpcs_in_flight);
+
+	seq_puts(seq, "\n\t\t\tmodify\n");
+	seq_puts(seq, "rpcs in flight        rpcs   %% cum %%\n");
+
+	mod_tot = lprocfs_oh_sum(&cli->cl_mod_rpcs_hist);
+
+	mod_cum = 0;
+	for (i = 0; i < OBD_HIST_MAX; i++) {
+		unsigned long mod = cli->cl_mod_rpcs_hist.oh_buckets[i];
+
+		mod_cum += mod;
+		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu\n",
+			   i, mod, pct(mod, mod_tot),
+			   pct(mod_cum, mod_tot));
+		if (mod_cum == mod_tot)
+			break;
+	}
+
+	spin_unlock(&cli->cl_mod_rpcs_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(obd_mod_rpc_stats_seq_show);
+#undef pct
+
+/*
+ * The number of modify RPCs sent in parallel is limited
+ * because the server has a finite number of slots per client to
+ * store request result and ensure reply reconstruction when needed.
+ * On the client, this limit is stored in cl_max_mod_rpcs_in_flight
+ * that takes into account server limit and cl_max_rpcs_in_flight
+ * value.
+ * On the MDC client, to avoid a potential deadlock (see Bugzilla 3462),
+ * one close request is allowed above the maximum.
+ */
+static inline bool obd_mod_rpc_slot_avail_locked(struct client_obd *cli,
+						 bool close_req)
+{
+	bool avail;
+
+	/* A slot is available if
+	 * - number of modify RPCs in flight is less than the max
+	 * - it's a close RPC and no other close request is in flight
+	 */
+	avail = cli->cl_mod_rpcs_in_flight < cli->cl_max_mod_rpcs_in_flight ||
+		(close_req && !cli->cl_close_rpcs_in_flight);
+
+	return avail;
+}
+
+static inline bool obd_mod_rpc_slot_avail(struct client_obd *cli,
+					  bool close_req)
+{
+	bool avail;
+
+	spin_lock(&cli->cl_mod_rpcs_lock);
+	avail = obd_mod_rpc_slot_avail_locked(cli, close_req);
+	spin_unlock(&cli->cl_mod_rpcs_lock);
+	return avail;
+}
+
+/* Get a modify RPC slot from the obd client @cli according
+ * to the kind of operation @opc that is going to be sent
+ * and the intent @it of the operation if it applies.
+ * If the maximum number of modify RPCs in flight is reached
+ * the thread is put to sleep.
+ * Returns the tag to be set in the request message. Tag 0
+ * is reserved for non-modifying requests.
+ */
+u16 obd_get_mod_rpc_slot(struct client_obd *cli, __u32 opc,
+			 struct lookup_intent *it)
+{
+	struct l_wait_info lwi = LWI_INTR(NULL, NULL);
+	bool close_req = false;
+	u16 i, max;
+
+	/* read-only metadata RPCs don't consume a slot on MDT
+	 * for reply reconstruction
+	 */
+	if (it && (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
+		   it->it_op == IT_LAYOUT || it->it_op == IT_READDIR))
+		return 0;
+
+	if (opc == MDS_CLOSE)
+		close_req = true;
+
+	do {
+		spin_lock(&cli->cl_mod_rpcs_lock);
+		max = cli->cl_max_mod_rpcs_in_flight;
+		if (obd_mod_rpc_slot_avail_locked(cli, close_req)) {
+			/* there is a slot available */
+			cli->cl_mod_rpcs_in_flight++;
+			if (close_req)
+				cli->cl_close_rpcs_in_flight++;
+			lprocfs_oh_tally(&cli->cl_mod_rpcs_hist,
+					 cli->cl_mod_rpcs_in_flight);
+			/* find a free tag */
+			i = find_first_zero_bit(cli->cl_mod_tag_bitmap,
+						max + 1);
+			LASSERT(i < OBD_MAX_RIF_MAX);
+			LASSERT(!test_and_set_bit(i, cli->cl_mod_tag_bitmap));
+			spin_unlock(&cli->cl_mod_rpcs_lock);
+			/* tag 0 is reserved for non-modify RPCs */
+			return i + 1;
+		}
+		spin_unlock(&cli->cl_mod_rpcs_lock);
+
+		CDEBUG(D_RPCTRACE, "%s: sleeping for a modify RPC slot opc %u, max %hu\n",
+		       cli->cl_import->imp_obd->obd_name, opc, max);
+
+		l_wait_event(cli->cl_mod_rpcs_waitq,
+			     obd_mod_rpc_slot_avail(cli, close_req), &lwi);
+	} while (true);
+}
+EXPORT_SYMBOL(obd_get_mod_rpc_slot);
+
+/*
+ * Put a modify RPC slot from the obd client @cli according
+ * to the kind of operation @opc that has been sent and the
+ * intent @it of the operation if it applies.
+ */
+void obd_put_mod_rpc_slot(struct client_obd *cli, u32 opc,
+			  struct lookup_intent *it, u16 tag)
+{
+	bool close_req = false;
+
+	if (it && (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
+		   it->it_op == IT_LAYOUT || it->it_op == IT_READDIR))
+		return;
+
+	if (opc == MDS_CLOSE)
+		close_req = true;
+
+	spin_lock(&cli->cl_mod_rpcs_lock);
+	cli->cl_mod_rpcs_in_flight--;
+	if (close_req)
+		cli->cl_close_rpcs_in_flight--;
+	/* release the tag in the bitmap */
+	LASSERT(tag - 1 < OBD_MAX_RIF_MAX);
+	LASSERT(test_and_clear_bit(tag - 1, cli->cl_mod_tag_bitmap) != 0);
+	spin_unlock(&cli->cl_mod_rpcs_lock);
+	wake_up(&cli->cl_mod_rpcs_waitq);
+}
+EXPORT_SYMBOL(obd_put_mod_rpc_slot);
-- 
1.7.1
