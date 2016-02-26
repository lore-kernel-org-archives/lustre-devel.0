From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:50:07 -0500
Subject: [lustre-devel] [PATCH 19/25] staging/lustre/mgc: Fix style vs open
	parenthesis alignment
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-20-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 28 ++++++++++++-------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 6fc8225..68c3c84 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -245,10 +245,10 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	return cld;
 }
 
-static struct config_llog_data *config_recover_log_add(struct obd_device *obd,
-	char *fsname,
-	struct config_llog_instance *cfg,
-	struct super_block *sb)
+static struct config_llog_data *
+config_recover_log_add(struct obd_device *obd, char *fsname,
+		       struct config_llog_instance *cfg,
+		       struct super_block *sb)
 {
 	struct config_llog_instance lcfg = *cfg;
 	struct config_llog_data *cld;
@@ -266,8 +266,9 @@ static struct config_llog_data *config_recover_log_add(struct obd_device *obd,
 	return cld;
 }
 
-static struct config_llog_data *config_params_log_add(struct obd_device *obd,
-	struct config_llog_instance *cfg, struct super_block *sb)
+static struct config_llog_data *
+config_params_log_add(struct obd_device *obd,
+		      struct config_llog_instance *cfg, struct super_block *sb)
 {
 	struct config_llog_instance	lcfg = *cfg;
 	struct config_llog_data		*cld;
@@ -454,16 +455,16 @@ int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data)
 	ocd = &imp->imp_connect_data;
 
 	seq_printf(m, "imperative_recovery: %s\n",
-		      OCD_HAS_FLAG(ocd, IMP_RECOV) ? "ENABLED" : "DISABLED");
+		   OCD_HAS_FLAG(ocd, IMP_RECOV) ? "ENABLED" : "DISABLED");
 	seq_printf(m, "client_state:\n");
 
 	spin_lock(&config_list_lock);
 	list_for_each_entry(cld, &config_llog_list, cld_list_chain) {
 		if (!cld->cld_recover)
 			continue;
-		seq_printf(m,  "    - { client: %s, nidtbl_version: %u }\n",
-			       cld->cld_logname,
-			       cld->cld_recover->cld_cfg.cfg_last_idx);
+		seq_printf(m, "    - { client: %s, nidtbl_version: %u }\n",
+			   cld->cld_logname,
+			   cld->cld_recover->cld_cfg.cfg_last_idx);
 	}
 	spin_unlock(&config_list_lock);
 
@@ -555,8 +556,7 @@ static int mgc_requeue_thread(void *data)
 
 		spin_lock(&config_list_lock);
 		rq_state &= ~RQ_PRECLEANUP;
-		list_for_each_entry(cld, &config_llog_list,
-					cld_list_chain) {
+		list_for_each_entry(cld, &config_llog_list, cld_list_chain) {
 			if (!cld->cld_lostlock)
 				continue;
 
@@ -966,8 +966,8 @@ static int mgc_target_register(struct obd_export *exp,
 }
 
 static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
-		       u32 keylen, void *key, u32 vallen,
-		       void *val, struct ptlrpc_request_set *set)
+			      u32 keylen, void *key, u32 vallen,
+			      void *val, struct ptlrpc_request_set *set)
 {
 	int rc = -EINVAL;
 
-- 
2.1.0
