From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:47 -0500
Subject: [lustre-devel] [PATCH 17/35] staging: lustre: obd: Remove dead code
	in precleanup
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

There used to be several pre-cleanup phases, but
only OBD_CLEANUP_EXPORTS is actually used.  Thus
remove the whole notion of precleanup phases.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7034
Reviewed-on: http://review.whamcloud.com/16061
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |   10 +---
 drivers/staging/lustre/lustre/include/obd_class.h  |   17 ++---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   19 +-----
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   24 --------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   25 +++-----
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   46 +++++++--------
 .../staging/lustre/lustre/obdclass/obd_config.c    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   62 ++++++++------------
 8 files changed, 67 insertions(+), 138 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 2ab7560..ffe09a3 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -625,13 +625,6 @@ struct obd_device {
 	struct completion	obd_kobj_unregister;
 };
 
-enum obd_cleanup_stage {
-/* Special case hack for MDS LOVs */
-	OBD_CLEANUP_EARLY,
-/* can be directly mapped to .ldto_device_fini() */
-	OBD_CLEANUP_EXPORTS,
-};
-
 /* get/set_info keys */
 #define KEY_ASYNC	       "async"
 #define KEY_CHANGELOG_CLEAR     "changelog_clear"
@@ -794,8 +787,7 @@ struct obd_ops {
 			      __u32 vallen, void *val,
 			      struct ptlrpc_request_set *set);
 	int (*setup)(struct obd_device *dev, struct lustre_cfg *cfg);
-	int (*precleanup)(struct obd_device *dev,
-			  enum obd_cleanup_stage cleanup_stage);
+	int (*precleanup)(struct obd_device *dev);
 	int (*cleanup)(struct obd_device *dev);
 	int (*process_config)(struct obd_device *dev, u32 len, void *data);
 	int (*postrecov)(struct obd_device *dev);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index f82f37b..01cd489 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -505,8 +505,7 @@ static inline int obd_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 	return rc;
 }
 
-static inline int obd_precleanup(struct obd_device *obd,
-				 enum obd_cleanup_stage cleanup_stage)
+static inline int obd_precleanup(struct obd_device *obd)
 {
 	int rc;
 	DECLARE_LU_VARS(ldt, d);
@@ -517,20 +516,18 @@ static inline int obd_precleanup(struct obd_device *obd,
 	ldt = obd->obd_type->typ_lu;
 	d = obd->obd_lu_dev;
 	if (ldt && d) {
-		if (cleanup_stage == OBD_CLEANUP_EXPORTS) {
-			struct lu_env env;
+		struct lu_env env;
 
-			rc = lu_env_init(&env, ldt->ldt_ctx_tags);
-			if (rc == 0) {
-				ldt->ldt_ops->ldto_device_fini(&env, d);
-				lu_env_fini(&env);
-			}
+		rc = lu_env_init(&env, ldt->ldt_ctx_tags);
+		if (!rc) {
+			ldt->ldt_ops->ldto_device_fini(&env, d);
+			lu_env_fini(&env);
 		}
 	}
 	OBD_CHECK_DT_OP(obd, precleanup, 0);
 	OBD_COUNTER_INCREMENT(obd, precleanup);
 
-	rc = OBP(obd, precleanup)(obd, cleanup_stage);
+	rc = OBP(obd, precleanup)(obd);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 2338556..9335ffe 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2623,23 +2623,10 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	goto retry_unlink;
 }
 
-static int lmv_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
+static int lmv_precleanup(struct obd_device *obd)
 {
-	struct lmv_obd *lmv = &obd->u.lmv;
-
-	switch (stage) {
-	case OBD_CLEANUP_EARLY:
-		/* XXX: here should be calling obd_precleanup() down to
-		 * stack.
-		 */
-		break;
-	case OBD_CLEANUP_EXPORTS:
-		fld_client_debugfs_fini(&lmv->lmv_fld);
-		lprocfs_obd_cleanup(obd);
-		break;
-	default:
-		break;
-	}
+	fld_client_debugfs_fini(&obd->u.lmv.lmv_fld);
+	lprocfs_obd_cleanup(obd);
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 421a0e2..5bae584 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -825,29 +825,6 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	return rc;
 }
 
-static int lov_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
-{
-	struct lov_obd *lov = &obd->u.lov;
-
-	switch (stage) {
-	case OBD_CLEANUP_EARLY: {
-		int i;
-
-		for (i = 0; i < lov->desc.ld_tgt_count; i++) {
-			if (!lov->lov_tgts[i] || !lov->lov_tgts[i]->ltd_active)
-				continue;
-			obd_precleanup(class_exp2obd(lov->lov_tgts[i]->ltd_exp),
-				       OBD_CLEANUP_EARLY);
-		}
-		break;
-	}
-	default:
-		break;
-	}
-
-	return 0;
-}
-
 static int lov_cleanup(struct obd_device *obd)
 {
 	struct lov_obd *lov = &obd->u.lov;
@@ -1399,7 +1376,6 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 static struct obd_ops lov_obd_ops = {
 	.owner          = THIS_MODULE,
 	.setup          = lov_setup,
-	.precleanup     = lov_precleanup,
 	.cleanup        = lov_cleanup,
 	/*.process_config       = lov_process_config,*/
 	.connect        = lov_connect,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 8bf0c5b..eee848d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2659,23 +2659,16 @@ static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 	return 0;
 }
 
-static int mdc_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
+static int mdc_precleanup(struct obd_device *obd)
 {
-	switch (stage) {
-	case OBD_CLEANUP_EARLY:
-		break;
-	case OBD_CLEANUP_EXPORTS:
-		/* Failsafe, ok if racy */
-		if (obd->obd_type->typ_refcnt <= 1)
-			libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
-
-		obd_cleanup_client_import(obd);
-		ptlrpc_lprocfs_unregister_obd(obd);
-		lprocfs_obd_cleanup(obd);
+	/* Failsafe, ok if racy */
+	if (obd->obd_type->typ_refcnt <= 1)
+		libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
 
-		mdc_llog_finish(obd);
-		break;
-	}
+	obd_cleanup_client_import(obd);
+	ptlrpc_lprocfs_unregister_obd(obd);
+	lprocfs_obd_cleanup(obd);
+	mdc_llog_finish(obd);
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index e248f33..a2cd5dd 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -684,35 +684,33 @@ static int mgc_llog_fini(const struct lu_env *env, struct obd_device *obd)
 }
 
 static atomic_t mgc_count = ATOMIC_INIT(0);
-static int mgc_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
+static int mgc_precleanup(struct obd_device *obd)
 {
 	int rc = 0;
 	int temp;
 
-	switch (stage) {
-	case OBD_CLEANUP_EARLY:
-		break;
-	case OBD_CLEANUP_EXPORTS:
-		if (atomic_dec_and_test(&mgc_count)) {
-			LASSERT(rq_state & RQ_RUNNING);
-			/* stop requeue thread */
-			temp = RQ_STOP;
-		} else {
-			/* wakeup requeue thread to clean our cld */
-			temp = RQ_NOW | RQ_PRECLEANUP;
-		}
-		spin_lock(&config_list_lock);
-		rq_state |= temp;
-		spin_unlock(&config_list_lock);
-		wake_up(&rq_waitq);
-		if (temp & RQ_STOP)
-			wait_for_completion(&rq_exit);
-		obd_cleanup_client_import(obd);
-		rc = mgc_llog_fini(NULL, obd);
-		if (rc != 0)
-			CERROR("failed to cleanup llogging subsystems\n");
-		break;
+	if (atomic_dec_and_test(&mgc_count)) {
+		LASSERT(rq_state & RQ_RUNNING);
+		/* stop requeue thread */
+		temp = RQ_STOP;
+	} else {
+		/* wakeup requeue thread to clean our cld */
+		temp = RQ_NOW | RQ_PRECLEANUP;
 	}
+
+	spin_lock(&config_list_lock);
+	rq_state |= temp;
+	spin_unlock(&config_list_lock);
+	wake_up(&rq_waitq);
+
+	if (temp & RQ_STOP)
+		wait_for_completion(&rq_exit);
+	obd_cleanup_client_import(obd);
+
+	rc = mgc_llog_fini(NULL, obd);
+	if (rc)
+		CERROR("failed to cleanup llogging subsystems\n");
+
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 017bdac..9d5530c 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -446,7 +446,7 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	LASSERT(obd->obd_self_export);
 
 	/* Precleanup, we must make sure all exports get destroyed. */
-	err = obd_precleanup(obd, OBD_CLEANUP_EXPORTS);
+	err = obd_precleanup(obd);
 	if (err)
 		CERROR("Precleanup %s returned %d\n",
 		       obd->obd_name, err);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 9b0b94b..c1f5e24 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2686,47 +2686,33 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	return rc;
 }
 
-static int osc_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
+static int osc_precleanup(struct obd_device *obd)
 {
-	switch (stage) {
-	case OBD_CLEANUP_EARLY: {
-		struct obd_import *imp;
-
-		imp = obd->u.cli.cl_import;
-		CDEBUG(D_HA, "Deactivating import %s\n", obd->obd_name);
-		/* ptlrpc_abort_inflight to stop an mds_lov_synchronize */
-		ptlrpc_deactivate_import(imp);
-		spin_lock(&imp->imp_lock);
-		imp->imp_pingable = 0;
-		spin_unlock(&imp->imp_lock);
-		break;
+	struct client_obd *cli = &obd->u.cli;
+
+	/* LU-464
+	 * for echo client, export may be on zombie list, wait for
+	 * zombie thread to cull it, because cli.cl_import will be
+	 * cleared in client_disconnect_export():
+	 *   class_export_destroy() -> obd_cleanup() ->
+	 *   echo_device_free() -> echo_client_cleanup() ->
+	 *   obd_disconnect() -> osc_disconnect() ->
+	 *   client_disconnect_export()
+	 */
+	obd_zombie_barrier();
+	if (cli->cl_writeback_work) {
+		ptlrpcd_destroy_work(cli->cl_writeback_work);
+		cli->cl_writeback_work = NULL;
 	}
-	case OBD_CLEANUP_EXPORTS: {
-		struct client_obd *cli = &obd->u.cli;
-		/* LU-464
-		 * for echo client, export may be on zombie list, wait for
-		 * zombie thread to cull it, because cli.cl_import will be
-		 * cleared in client_disconnect_export():
-		 *   class_export_destroy() -> obd_cleanup() ->
-		 *   echo_device_free() -> echo_client_cleanup() ->
-		 *   obd_disconnect() -> osc_disconnect() ->
-		 *   client_disconnect_export()
-		 */
-		obd_zombie_barrier();
-		if (cli->cl_writeback_work) {
-			ptlrpcd_destroy_work(cli->cl_writeback_work);
-			cli->cl_writeback_work = NULL;
-		}
-		if (cli->cl_lru_work) {
-			ptlrpcd_destroy_work(cli->cl_lru_work);
-			cli->cl_lru_work = NULL;
-		}
-		obd_cleanup_client_import(obd);
-		ptlrpc_lprocfs_unregister_obd(obd);
-		lprocfs_obd_cleanup(obd);
-		break;
-		}
+
+	if (cli->cl_lru_work) {
+		ptlrpcd_destroy_work(cli->cl_lru_work);
+		cli->cl_lru_work = NULL;
 	}
+
+	obd_cleanup_client_import(obd);
+	ptlrpc_lprocfs_unregister_obd(obd);
+	lprocfs_obd_cleanup(obd);
 	return 0;
 }
 
-- 
1.7.1
