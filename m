From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:19 -0500
Subject: [lustre-devel] [PATCH 15/26] mgc: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The mgc code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 85 +++++++++++++------------
 1 file changed, 43 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index dc80081..a4dfdc0 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -193,7 +193,7 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 					   struct super_block *sb)
 {
 	struct config_llog_data *cld;
-	int		      rc;
+	int rc;
 
 	CDEBUG(D_MGC, "do adding config log %s:%p\n", logname,
 	       cfg ? cfg->cfg_instance : NULL);
@@ -267,8 +267,8 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 		       struct super_block *sb, int type,
 		       struct config_llog_instance *cfg)
 {
-	struct config_llog_instance	lcfg = *cfg;
-	struct config_llog_data		*cld;
+	struct config_llog_instance lcfg = *cfg;
+	struct config_llog_data	*cld;
 
 	lcfg.cfg_instance = sb ? (void *)sb : (void *)obd;
 
@@ -296,9 +296,9 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	struct config_llog_data *sptlrpc_cld = NULL;
 	struct config_llog_data *params_cld = NULL;
 	struct config_llog_data *recover_cld = NULL;
-	char			seclogname[32];
-	char			*ptr;
-	int			rc;
+	char seclogname[32];
+	char *ptr;
+	int rc;
 
 	CDEBUG(D_MGC, "adding config log %s:%p\n", logname, cfg->cfg_instance);
 
@@ -459,8 +459,8 @@ static int config_log_end(char *logname, struct config_llog_instance *cfg)
 
 int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data)
 {
-	struct obd_device       *obd = data;
-	struct obd_import       *imp;
+	struct obd_device *obd = data;
+	struct obd_import *imp;
 	struct obd_connect_data *ocd;
 	struct config_llog_data *cld;
 	int rc;
@@ -491,13 +491,14 @@ int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data)
 }
 
 /* reenqueue any lost locks */
-#define RQ_RUNNING 0x1
-#define RQ_NOW     0x2
-#define RQ_LATER   0x4
-#define RQ_STOP    0x8
-#define RQ_PRECLEANUP  0x10
+#define RQ_RUNNING	0x01
+#define RQ_NOW		0x02
+#define RQ_LATER	0x04
+#define RQ_STOP		0x08
+#define RQ_PRECLEANUP	0x10
+
 static int rq_state;
-static wait_queue_head_t	    rq_waitq;
+static wait_queue_head_t rq_waitq;
 static DECLARE_COMPLETION(rq_exit);
 static DECLARE_COMPLETION(rq_start);
 
@@ -620,7 +621,7 @@ static int mgc_requeue_thread(void *data)
 	return 0;
 }
 
-/* Add a cld to the list to requeue.  Start the requeue thread if needed.
+/* Add a cld to the list to requeue. Start the requeue thread if needed.
  * We are responsible for dropping the config log reference from here on out.
  */
 static void mgc_requeue_add(struct config_llog_data *cld)
@@ -647,8 +648,8 @@ static void mgc_requeue_add(struct config_llog_data *cld)
 
 static int mgc_llog_init(const struct lu_env *env, struct obd_device *obd)
 {
-	struct llog_ctxt	*ctxt;
-	int			 rc;
+	struct llog_ctxt *ctxt;
+	int rc;
 
 	/* setup only remote ctxt, the local disk context is switched per each
 	 * filesystem during mgc_fs_setup()
@@ -941,9 +942,9 @@ static void mgc_notify_active(struct obd_device *unused)
 static int mgc_target_register(struct obd_export *exp,
 			       struct mgs_target_info *mti)
 {
-	struct ptlrpc_request  *req;
+	struct ptlrpc_request *req;
 	struct mgs_target_info *req_mti, *rep_mti;
-	int		     rc;
+	int rc;
 
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_MGS_TARGET_REG, LUSTRE_MGS_VERSION,
@@ -1009,8 +1010,8 @@ static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		return rc;
 	}
 	if (KEY_IS(KEY_MGSSEC)) {
-		struct client_obd     *cli = &exp->exp_obd->u.cli;
-		struct sptlrpc_flavor  flvr;
+		struct client_obd *cli = &exp->exp_obd->u.cli;
+		struct sptlrpc_flavor flvr;
 
 		/*
 		 * empty string means using current flavor, if which haven't
@@ -1040,7 +1041,7 @@ static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 			cli->cl_flvr_mgc = flvr;
 		} else if (memcmp(&cli->cl_flvr_mgc, &flvr,
 				  sizeof(flvr)) != 0) {
-			char    str[20];
+			char str[20];
 
 			sptlrpc_flavor2name(&cli->cl_flvr_mgc,
 					    str, sizeof(str));
@@ -1125,15 +1126,15 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 {
 	struct config_llog_instance *cfg = &cld->cld_cfg;
 	struct mgs_nidtbl_entry *entry;
-	struct lustre_cfg       *lcfg;
-	struct lustre_cfg_bufs   bufs;
-	u64   prev_version = 0;
+	struct lustre_cfg *lcfg;
+	struct lustre_cfg_bufs bufs;
+	u64 prev_version = 0;
 	char *inst;
 	char *buf;
-	int   bufsz;
-	int   pos;
-	int   rc  = 0;
-	int   off = 0;
+	int bufsz;
+	int pos;
+	int rc = 0;
+	int off = 0;
 
 	LASSERT(cfg->cfg_instance);
 	LASSERT(cfg->cfg_sb == cfg->cfg_instance);
@@ -1149,11 +1150,11 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 	}
 
 	++pos;
-	buf   = inst + pos;
+	buf = inst + pos;
 	bufsz = PAGE_SIZE - pos;
 
 	while (datalen > 0) {
-		int   entry_len = sizeof(*entry);
+		int entry_len = sizeof(*entry);
 		int is_ost, i;
 		struct obd_device *obd;
 		char *obdname;
@@ -1191,7 +1192,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		if (entry->mne_length < entry_len)
 			break;
 
-		off     += entry->mne_length;
+		off += entry->mne_length;
 		datalen -= entry->mne_length;
 		if (datalen < 0)
 			break;
@@ -1323,7 +1324,7 @@ static int mgc_process_recover_log(struct obd_device *obd,
 	struct ptlrpc_request *req = NULL;
 	struct config_llog_instance *cfg = &cld->cld_cfg;
 	struct mgs_config_body *body;
-	struct mgs_config_res  *res;
+	struct mgs_config_res *res;
 	struct ptlrpc_bulk_desc *desc;
 	struct page **pages;
 	int nrpages;
@@ -1380,9 +1381,9 @@ static int mgc_process_recover_log(struct obd_device *obd,
 		goto out;
 	}
 	body->mcb_offset = cfg->cfg_last_idx + 1;
-	body->mcb_type   = cld->cld_type;
-	body->mcb_bits   = PAGE_SHIFT;
-	body->mcb_units  = nrpages;
+	body->mcb_type = cld->cld_type;
+	body->mcb_bits = PAGE_SHIFT;
+	body->mcb_units = nrpages;
 
 	/* allocate bulk transfer descriptor */
 	desc = ptlrpc_prep_bulk_imp(req, nrpages, 1,
@@ -1483,11 +1484,11 @@ static int mgc_process_recover_log(struct obd_device *obd,
 static int mgc_process_cfg_log(struct obd_device *mgc,
 			       struct config_llog_data *cld, int local_only)
 {
-	struct llog_ctxt	*ctxt;
-	struct lustre_sb_info	*lsi = NULL;
-	int			 rc = 0;
-	bool			 sptlrpc_started = false;
-	struct lu_env		*env;
+	struct llog_ctxt *ctxt;
+	struct lustre_sb_info *lsi = NULL;
+	int rc = 0;
+	bool sptlrpc_started = false;
+	struct lu_env *env;
 
 	LASSERT(cld);
 	LASSERT(mutex_is_locked(&cld->cld_lock));
@@ -1570,7 +1571,7 @@ static bool mgc_import_in_recovery(struct obd_import *imp)
  * Get a configuration log from the MGS and process it.
  *
  * This function is called for both clients and servers to process the
- * configuration log from the MGS.  The MGC enqueues a DLM lock on the
+ * configuration log from the MGS. The MGC enqueues a DLM lock on the
  * log from the MGS, and if the lock gets revoked the MGC will be notified
  * by the lock cancellation callback that the config log has changed,
  * and will enqueue another MGS lock on it, and then continue processing
-- 
1.8.3.1
