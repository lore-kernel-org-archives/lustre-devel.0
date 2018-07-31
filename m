From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:01 -0400
Subject: [lustre-devel] [PATCH 09/31] lustre: mgc: relate sptlrpc & param to
 MGC
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

If sptlrpc or params config logs come from different MGC,
it should be regarded as different logs, this patch binds
these config logs with MGC obd device to separate them.

The fix for a bug discovered later is also included for
this patch. Since sb is NULL for config_log_find_or_add
the cfs_instance field was being set to the obd device.
This confused the sptlrpc layer so for now cfg_instance
is set to NULl in the sptlrpc case. This will be resolved
with the move to kobjects.

Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Intel-bug-id: https://jira.whamcloud.com/browse/LU-9034
Reviewed-on: https://review.whamcloud.com/24988
Intel-bug-id: https://jira.whamcloud.com/browse/LU-9567
Reviewed-on: https://review.whamcloud.com/27320
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 36 ++++++++++++++-----------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 32df804..82acac0 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -263,18 +263,23 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 }
 
 static struct config_llog_data *
-config_params_log_add(struct obd_device *obd,
-		      struct config_llog_instance *cfg, struct super_block *sb)
+config_log_find_or_add(struct obd_device *obd, char *logname,
+		       struct super_block *sb, int type,
+		       struct config_llog_instance *cfg)
 {
 	struct config_llog_instance	lcfg = *cfg;
 	struct config_llog_data		*cld;
 
-	lcfg.cfg_instance = sb;
+	lcfg.cfg_instance = sb ? (void *)sb : (void *)obd;
 
-	cld = do_config_log_add(obd, PARAMS_FILENAME, CONFIG_T_PARAMS,
-				&lcfg, sb);
+	if (type == CONFIG_T_SPTLRPC)
+		lcfg.cfg_instance = NULL;
 
-	return cld;
+	cld = config_log_find(logname, &lcfg);
+	if (unlikely(cld))
+		return cld;
+
+	return do_config_log_add(obd, logname, type, &lcfg, sb);
 }
 
 /** Add this log to the list of active logs watched by an MGC.
@@ -310,17 +315,16 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	memcpy(seclogname, logname, ptr - logname);
 	strcpy(seclogname + (ptr - logname), "-sptlrpc");
 
-	sptlrpc_cld = config_log_find(seclogname, NULL);
-	if (!sptlrpc_cld) {
-		sptlrpc_cld = do_config_log_add(obd, seclogname,
-						CONFIG_T_SPTLRPC, NULL, NULL);
-		if (IS_ERR(sptlrpc_cld)) {
-			CERROR("can't create sptlrpc log: %s\n", seclogname);
-			rc = PTR_ERR(sptlrpc_cld);
-			goto out_err;
-		}
+	sptlrpc_cld = config_log_find_or_add(obd, seclogname, NULL,
+					     CONFIG_T_SPTLRPC, cfg);
+	if (IS_ERR(sptlrpc_cld)) {
+		CERROR("can't create sptlrpc log: %s\n", seclogname);
+		rc = PTR_ERR(sptlrpc_cld);
+		goto out_err;
 	}
-	params_cld = config_params_log_add(obd, cfg, sb);
+
+	params_cld = config_log_find_or_add(obd, PARAMS_FILENAME, sb,
+					    CONFIG_T_PARAMS, cfg);
 	if (IS_ERR(params_cld)) {
 		rc = PTR_ERR(params_cld);
 		CERROR("%s: can't create params log: rc = %d\n",
-- 
1.8.3.1
