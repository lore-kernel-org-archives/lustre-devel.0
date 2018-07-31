From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:05 -0400
Subject: [lustre-devel] [PATCH 13/31] lustre: config: don't attach sub logs
 for LWP
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

Lustre target processes client log to retrieve MDT NIDs and start
LWPs, it goes the same code path of mgc_process_config() just like
processing the target config log, so that sub clds for security,
nodemap, param & recovery will be attached unnecessarily.

The mgc subsystem is used by both server and client. This change
allows us to cleanly handle the future case when the mgc layer
would be built with server code. This way server specific config
logs will only be processed when a server mount occurs.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-9081
Reviewed-on: https://review.whamcloud.com/25293
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h | 19 +++++++-----
 drivers/staging/lustre/lustre/llite/llite_lib.c   |  1 +
 drivers/staging/lustre/lustre/mgc/mgc_request.c   | 37 +++++++++++++----------
 3 files changed, 34 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index adfe2ab..e772e3d 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -153,17 +153,22 @@ struct config_llog_instance {
 	llog_cb_t	    cfg_callback;
 	int		    cfg_last_idx; /* for partial llog processing */
 	int		    cfg_flags;
+	u32		    cfg_sub_clds;
 };
 
 int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
 			    char *name, struct config_llog_instance *cfg);
-enum {
-	CONFIG_T_CONFIG  = 0,
-	CONFIG_T_SPTLRPC = 1,
-	CONFIG_T_RECOVER = 2,
-	CONFIG_T_PARAMS  = 3,
-	CONFIG_T_MAX     = 4
-};
+
+#define CONFIG_T_CONFIG		BIT(0)
+#define CONFIG_T_SPTLRPC	BIT(1)
+#define CONFIG_T_RECOVER	BIT(2)
+#define CONFIG_T_PARAMS		BIT(3)
+
+/* Sub clds should be attached to the config_llog_data when processing
+ * config log for client or server target.
+ */
+#define CONFIG_SUB_CLIENT	(CONFIG_T_SPTLRPC | CONFIG_T_RECOVER | \
+				 CONFIG_T_PARAMS)
 
 #define PARAMS_FILENAME	"params"
 #define LCTL_UPCALL	"lctl"
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 72b118a..71eb42d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -949,6 +949,7 @@ int ll_fill_super(struct super_block *sb)
 	cfg->cfg_instance = sb;
 	cfg->cfg_uuid = lsi->lsi_llsbi->ll_sb_uuid;
 	cfg->cfg_callback = class_config_llog_handler;
+	cfg->cfg_sub_clds = CONFIG_SUB_CLIENT;
 	/* set up client obds */
 	err = lustre_process_log(sb, profilenm, cfg);
 	if (err < 0)
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 82acac0..06fcc7e 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -293,8 +293,8 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct config_llog_data *cld;
-	struct config_llog_data *sptlrpc_cld;
-	struct config_llog_data *params_cld;
+	struct config_llog_data *sptlrpc_cld = NULL;
+	struct config_llog_data *params_cld = NULL;
 	struct config_llog_data *recover_cld = NULL;
 	char			seclogname[32];
 	char			*ptr;
@@ -315,21 +315,25 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	memcpy(seclogname, logname, ptr - logname);
 	strcpy(seclogname + (ptr - logname), "-sptlrpc");
 
-	sptlrpc_cld = config_log_find_or_add(obd, seclogname, NULL,
-					     CONFIG_T_SPTLRPC, cfg);
-	if (IS_ERR(sptlrpc_cld)) {
-		CERROR("can't create sptlrpc log: %s\n", seclogname);
-		rc = PTR_ERR(sptlrpc_cld);
-		goto out_err;
+	if (cfg->cfg_sub_clds & CONFIG_T_SPTLRPC) {
+		sptlrpc_cld = config_log_find_or_add(obd, seclogname, NULL,
+						     CONFIG_T_SPTLRPC, cfg);
+		if (IS_ERR(sptlrpc_cld)) {
+			CERROR("can't create sptlrpc log: %s\n", seclogname);
+			rc = PTR_ERR(sptlrpc_cld);
+			goto out_err;
+		}
 	}
 
-	params_cld = config_log_find_or_add(obd, PARAMS_FILENAME, sb,
-					    CONFIG_T_PARAMS, cfg);
-	if (IS_ERR(params_cld)) {
-		rc = PTR_ERR(params_cld);
-		CERROR("%s: can't create params log: rc = %d\n",
-		       obd->obd_name, rc);
-		goto out_sptlrpc;
+	if (cfg->cfg_sub_clds & CONFIG_T_PARAMS) {
+		params_cld = config_log_find_or_add(obd, PARAMS_FILENAME, sb,
+						    CONFIG_T_PARAMS, cfg);
+		if (IS_ERR(params_cld)) {
+			rc = PTR_ERR(params_cld);
+			CERROR("%s: can't create params log: rc = %d\n",
+			       obd->obd_name, rc);
+			goto out_sptlrpc;
+		}
 	}
 
 	cld = do_config_log_add(obd, logname, CONFIG_T_CONFIG, cfg, sb);
@@ -340,7 +344,8 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	}
 
 	LASSERT(lsi->lsi_lmd);
-	if (!(lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR)) {
+	if (!(lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR) &&
+	    cfg->cfg_sub_clds & CONFIG_T_RECOVER) {
 		ptr = strrchr(seclogname, '-');
 		if (ptr) {
 			*ptr = 0;
-- 
1.8.3.1
