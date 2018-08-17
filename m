From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:33 -0400
Subject: [lustre-devel] [PATCH 30/38] lustre: mgc: update sysfs handling
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Move mgc to using the new sysfs conn_uuid. Move all
sysfs/debugfs handling to lprocfs_mgc.c and implement proper
error handling.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.hpdd.intel.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/29250
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mgc/lproc_mgc.c    | 43 ++++++++++++++++++------
 drivers/staging/lustre/lustre/mgc/mgc_internal.h |  2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c  | 10 +++---
 3 files changed, 40 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
index 7951ec6..574233e 100644
--- a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
+++ b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
@@ -38,9 +38,11 @@
 #include "mgc_internal.h"
 
 LPROC_SEQ_FOPS_RO_TYPE(mgc, connect_flags);
+
 LPROC_SEQ_FOPS_RO_TYPE(mgc, server_uuid);
-LPROC_SEQ_FOPS_RO_TYPE(mgc, conn_uuid);
+
 LPROC_SEQ_FOPS_RO_TYPE(mgc, import);
+
 LPROC_SEQ_FOPS_RO_TYPE(mgc, state);
 
 LPROC_SEQ_FOPS_WR_ONLY(mgc, ping);
@@ -52,18 +54,39 @@ static int mgc_ir_state_seq_show(struct seq_file *m, void *v)
 
 LPROC_SEQ_FOPS_RO(mgc_ir_state);
 
-static struct lprocfs_vars lprocfs_mgc_obd_vars[] = {
-	{ "ping",	     &mgc_ping_fops,      NULL, 0222 },
-	{ "connect_flags",   &mgc_connect_flags_fops, NULL, 0 },
-	{ "mgs_server_uuid", &mgc_server_uuid_fops,   NULL, 0 },
-	{ "mgs_conn_uuid",   &mgc_conn_uuid_fops,     NULL, 0 },
-	{ "import",	     &mgc_import_fops,	NULL, 0 },
-	{ "state",	     &mgc_state_fops,	 NULL, 0 },
-	{ "ir_state",	     &mgc_ir_state_fops,  NULL, 0 },
+struct lprocfs_vars lprocfs_mgc_obd_vars[] = {
+	{ .name	=	"ping",
+	  .fops =	&mgc_ping_fops		},
+	{ .name =	"connect_flags",
+	  .fops =	&mgc_connect_flags_fops	},
+	{ .name =	"mgs_server_uuid",
+	  .fops =	&mgc_server_uuid_fops	},
+	{ .name =	"import",
+	  .fops =	&mgc_import_fops	},
+	{ .name =	"state",
+	  .fops =	&mgc_state_fops		},
+	{ .name =	"ir_state",
+	  .fops =	&mgc_ir_state_fops	},
 	{ NULL }
 };
 
-void lprocfs_mgc_init_vars(struct obd_device *obd)
+#define mgs_conn_uuid_show conn_uuid_show
+LUSTRE_RO_ATTR(mgs_conn_uuid);
+
+static struct attribute *mgc_attrs[] = {
+	&lustre_attr_mgs_conn_uuid.attr,
+	NULL,
+};
+
+int mgc_tunables_init(struct obd_device *obd)
 {
+	int rc;
+
+	obd->obd_ktype.default_attrs = mgc_attrs;
 	obd->obd_vars = lprocfs_mgc_obd_vars;
+	rc = lprocfs_obd_setup(obd, true);
+	if (rc)
+		return rc;
+
+	return sptlrpc_lprocfs_cliobd_attach(obd);
 }
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index 5385d91..0a91624 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -39,7 +39,7 @@
 #include <lustre_log.h>
 #include <lustre_export.h>
 
-void lprocfs_mgc_init_vars(struct obd_device *obd);
+int mgc_tunables_init(struct obd_device *obd);
 int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data);
 
 int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld);
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 50da9cf..4552cc5 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -747,9 +747,9 @@ static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		goto err_cleanup;
 	}
 
-	lprocfs_mgc_init_vars(obd);
-	lprocfs_obd_setup(obd, true);
-	sptlrpc_lprocfs_cliobd_attach(obd);
+	rc = mgc_tunables_init(obd);
+	if (rc)
+		goto err_sysfs;
 
 	if (atomic_inc_return(&mgc_count) == 1) {
 		rq_state = 0;
@@ -761,7 +761,7 @@ static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 			rc = PTR_ERR(task);
 			CERROR("%s: cannot start requeue thread: rc = %d; no more log updates\n",
 			       obd->obd_name, rc);
-			goto err_cleanup;
+			goto err_sysfs;
 		}
 		/* rc is the task_struct pointer of mgc_requeue_thread. */
 		rc = 0;
@@ -770,6 +770,8 @@ static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	return rc;
 
+err_sysfs:
+	lprocfs_obd_cleanup(obd);
 err_cleanup:
 	client_obd_cleanup(obd);
 err_decref:
-- 
1.8.3.1
