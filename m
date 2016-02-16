From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:54 -0500
Subject: [lustre-devel] [PATCH 22/45] staging/lustre/mgc: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-23-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Also remove some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 41 ++++++++++++-------------
 1 file changed, 20 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index ab4800c..bd34ab3 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -162,7 +162,7 @@ struct config_llog_data *config_log_find(char *logname,
 	struct config_llog_data *found = NULL;
 	void *instance;
 
-	LASSERT(logname != NULL);
+	LASSERT(logname);
 
 	instance = cfg ? cfg->cfg_instance : NULL;
 	spin_lock(&config_list_lock);
@@ -300,7 +300,7 @@ static int config_log_add(struct obd_device *obd, char *logname,
 	 * <fsname>-sptlrpc. multiple regular logs may share one sptlrpc log.
 	 */
 	ptr = strrchr(logname, '-');
-	if (ptr == NULL || ptr - logname > 8) {
+	if (!ptr || ptr - logname > 8) {
 		CERROR("logname %s is too long\n", logname);
 		return -EINVAL;
 	}
@@ -309,7 +309,7 @@ static int config_log_add(struct obd_device *obd, char *logname,
 	strcpy(seclogname + (ptr - logname), "-sptlrpc");
 
 	sptlrpc_cld = config_log_find(seclogname, NULL);
-	if (sptlrpc_cld == NULL) {
+	if (!sptlrpc_cld) {
 		sptlrpc_cld = do_config_log_add(obd, seclogname,
 						CONFIG_T_SPTLRPC, NULL, NULL);
 		if (IS_ERR(sptlrpc_cld)) {
@@ -376,7 +376,7 @@ static int config_log_end(char *logname, struct config_llog_instance *cfg)
 	int rc = 0;
 
 	cld = config_log_find(logname, cfg);
-	if (cld == NULL)
+	if (!cld)
 		return -ENOENT;
 
 	mutex_lock(&cld->cld_lock);
@@ -455,7 +455,7 @@ int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data)
 
 	spin_lock(&config_list_lock);
 	list_for_each_entry(cld, &config_llog_list, cld_list_chain) {
-		if (cld->cld_recover == NULL)
+		if (!cld->cld_recover)
 			continue;
 		seq_printf(m,  "    - { client: %s, nidtbl_version: %u }\n",
 			       cld->cld_logname,
@@ -883,7 +883,7 @@ static int mgc_enqueue(struct obd_export *exp, struct lov_stripe_md *lsm,
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_LDLM_ENQUEUE, LUSTRE_DLM_VERSION,
 					LDLM_ENQUEUE);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER, 0);
@@ -921,7 +921,7 @@ static int mgc_target_register(struct obd_export *exp,
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_MGS_TARGET_REG, LUSTRE_MGS_VERSION,
 					MGS_TARGET_REG);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	req_mti = req_capsule_client_get(&req->rq_pill, &RMF_MGS_TARGET_INFO);
@@ -1109,7 +1109,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 	int   rc  = 0;
 	int   off = 0;
 
-	LASSERT(cfg->cfg_instance != NULL);
+	LASSERT(cfg->cfg_instance);
 	LASSERT(cfg->cfg_sb == cfg->cfg_instance);
 
 	inst = kzalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
@@ -1195,7 +1195,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		/* lustre-OST0001-osc-<instance #> */
 		strcpy(obdname, cld->cld_logname);
 		cname = strrchr(obdname, '-');
-		if (cname == NULL) {
+		if (!cname) {
 			CERROR("mgc %s: invalid logname %s\n",
 			       mgc->obd_name, obdname);
 			break;
@@ -1212,7 +1212,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 
 		/* find the obd by obdname */
 		obd = class_name2obd(obdname);
-		if (obd == NULL) {
+		if (!obd) {
 			CDEBUG(D_INFO, "mgc %s: cannot find obdname %s\n",
 			       mgc->obd_name, obdname);
 			rc = 0;
@@ -1227,7 +1227,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		uuid = buf + pos;
 
 		down_read(&obd->u.cli.cl_sem);
-		if (obd->u.cli.cl_import == NULL) {
+		if (!obd->u.cli.cl_import) {
 			/* client does not connect to the OST yet */
 			up_read(&obd->u.cli.cl_sem);
 			rc = 0;
@@ -1257,7 +1257,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 
 		rc = -ENOMEM;
 		lcfg = lustre_cfg_new(LCFG_PARAM, &bufs);
-		if (lcfg == NULL) {
+		if (!lcfg) {
 			CERROR("mgc: cannot allocate memory\n");
 			break;
 		}
@@ -1309,14 +1309,14 @@ static int mgc_process_recover_log(struct obd_device *obd,
 		nrpages = CONFIG_READ_NRPAGES_INIT;
 
 	pages = kcalloc(nrpages, sizeof(*pages), GFP_KERNEL);
-	if (pages == NULL) {
+	if (!pages) {
 		rc = -ENOMEM;
 		goto out;
 	}
 
 	for (i = 0; i < nrpages; i++) {
 		pages[i] = alloc_page(GFP_KERNEL);
-		if (pages[i] == NULL) {
+		if (!pages[i]) {
 			rc = -ENOMEM;
 			goto out;
 		}
@@ -1327,7 +1327,7 @@ again:
 	LASSERT(mutex_is_locked(&cld->cld_lock));
 	req = ptlrpc_request_alloc(class_exp2cliimp(cld->cld_mgcexp),
 				   &RQF_MGS_CONFIG_READ);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1338,7 +1338,6 @@ again:
 
 	/* pack request */
 	body = req_capsule_client_get(&req->rq_pill, &RMF_MGS_CONFIG_BODY);
-	LASSERT(body != NULL);
 	LASSERT(sizeof(body->mcb_name) > strlen(cld->cld_logname));
 	if (strlcpy(body->mcb_name, cld->cld_logname, sizeof(body->mcb_name))
 	    >= sizeof(body->mcb_name)) {
@@ -1353,7 +1352,7 @@ again:
 	/* allocate bulk transfer descriptor */
 	desc = ptlrpc_prep_bulk_imp(req, nrpages, 1, BULK_PUT_SINK,
 				    MGS_BULK_PORTAL);
-	if (desc == NULL) {
+	if (!desc) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1434,7 +1433,7 @@ out:
 
 	if (pages) {
 		for (i = 0; i < nrpages; i++) {
-			if (pages[i] == NULL)
+			if (!pages[i])
 				break;
 			__free_page(pages[i]);
 		}
@@ -1635,7 +1634,7 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 		if (rc)
 			break;
 		cld = config_log_find(logname, cfg);
-		if (cld == NULL) {
+		if (!cld) {
 			rc = -ENOENT;
 			break;
 		}
@@ -1646,7 +1645,7 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 		cld->cld_cfg.cfg_flags |= CFG_F_COMPAT146;
 
 		rc = mgc_process_log(obd, cld);
-		if (rc == 0 && cld->cld_recover != NULL) {
+		if (rc == 0 && cld->cld_recover) {
 			if (OCD_HAS_FLAG(&obd->u.cli.cl_import->
 					 imp_connect_data, IMP_RECOV)) {
 				rc = mgc_process_log(obd, cld->cld_recover);
@@ -1660,7 +1659,7 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 				CERROR("Cannot process recover llog %d\n", rc);
 		}
 
-		if (rc == 0 && cld->cld_params != NULL) {
+		if (rc == 0 && cld->cld_params) {
 			rc = mgc_process_log(obd, cld->cld_params);
 			if (rc == -ENOENT) {
 				CDEBUG(D_MGC,
-- 
2.1.0
