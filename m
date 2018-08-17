From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:41 -0400
Subject: [lustre-devel] [PATCH 38/38] lustre: mdc: update sysfs handling
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Move all the sysfs/debugfs handling to lproc_mdc.c. Properly
handle failure cases for sysfs/debugfs bring up.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/30961
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Sonia Sharma <sonia.sharma@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c    | 72 ++++++++++++++----------
 drivers/staging/lustre/lustre/mdc/mdc_internal.h |  3 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c  | 31 ++++------
 3 files changed, 55 insertions(+), 51 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 47f23d6..3bff8b5 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -51,23 +51,20 @@ static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	unsigned long val;
+	bool val;
 	int rc;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtobool(buffer, &val);
 	if (rc)
 		return rc;
 
-	if (val > 1)
-		return -ERANGE;
-
 	/* opposite senses */
 	if (dev->u.cli.cl_import->imp_deactive == val) {
 		rc = ptlrpc_set_import_active(dev->u.cli.cl_import, val);
 		if (rc)
 			count = rc;
 	} else {
-		CDEBUG(D_CONFIG, "activate %lu: ignoring repeat request\n", val);
+		CDEBUG(D_CONFIG, "activate %u: ignoring repeat request\n", val);
 	}
 	return count;
 }
@@ -77,15 +74,10 @@ static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
 				       struct attribute *attr,
 				       char *buf)
 {
-	int len;
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	__u32 max;
-
-	max = obd_get_max_rpcs_in_flight(&dev->u.cli);
-	len = sprintf(buf, "%u\n", max);
 
-	return len;
+	return sprintf(buf, "%u\n", obd_get_max_rpcs_in_flight(&dev->u.cli));
 }
 
 static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
@@ -95,10 +87,10 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
+	unsigned int val;
 	int rc;
-	unsigned long val;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtouint(buffer, 10, &val);
 	if (rc)
 		return rc;
 
@@ -116,13 +108,8 @@ static ssize_t max_mod_rpcs_in_flight_show(struct kobject *kobj,
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	u16 max;
-	int len;
-
-	max = dev->u.cli.cl_max_mod_rpcs_in_flight;
-	len = sprintf(buf, "%hu\n", max);
 
-	return len;
+	return sprintf(buf, "%hu\n", dev->u.cli.cl_max_mod_rpcs_in_flight);
 }
 
 static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
@@ -147,6 +134,9 @@ static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(max_mod_rpcs_in_flight);
 
+#define mdc_conn_uuid_show conn_uuid_show
+LUSTRE_RO_ATTR(mdc_conn_uuid);
+
 static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct obd_device *dev = seq->private;
@@ -172,7 +162,6 @@ static ssize_t mdc_rpc_stats_seq_write(struct file *file,
 
 LPROC_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(mdc, server_uuid);
-LPROC_SEQ_FOPS_RO_TYPE(mdc, conn_uuid);
 LPROC_SEQ_FOPS_RO_TYPE(mdc, timeouts);
 LPROC_SEQ_FOPS_RO_TYPE(mdc, state);
 
@@ -198,15 +187,20 @@ static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
 LPROC_SEQ_FOPS_RW_TYPE(mdc, pinger_recov);
 
 static struct lprocfs_vars lprocfs_mdc_obd_vars[] = {
-	{ "ping",		&mdc_ping_fops,			NULL, 0222 },
-	{ "connect_flags",	&mdc_connect_flags_fops,	NULL, 0 },
-	/*{ "filegroups",	lprocfs_rd_filegroups,		NULL, 0 },*/
-	{ "mds_server_uuid",	&mdc_server_uuid_fops,		NULL, 0 },
-	{ "mds_conn_uuid",	&mdc_conn_uuid_fops,		NULL, 0 },
-	{ "timeouts",		&mdc_timeouts_fops,		NULL, 0 },
-	{ "import",		&mdc_import_fops,		NULL, 0 },
-	{ "state",		&mdc_state_fops,		NULL, 0 },
-	{ "pinger_recov",	&mdc_pinger_recov_fops,		NULL, 0 },
+	{ .name	=	"ping",
+	  .fops	=	&mdc_ping_fops			},
+	{ .name	=	"connect_flags",
+	  .fops	=	&mdc_connect_flags_fops		},
+	{ .name	=	"mds_server_uuid",
+	  .fops	=	&mdc_server_uuid_fops,		},
+	{ .name	=	"timeouts",
+	  .fops	=	&mdc_timeouts_fops		},
+	{ .name	=	"import",
+	  .fops	=	&mdc_import_fops		},
+	{ .name	=	"state",
+	  .fops	=	&mdc_state_fops			},
+	{ .name	=	"pinger_recov",
+	  .fops	=	&mdc_pinger_recov_fops		},
 	{ .name =	"rpc_stats",
 	  .fops =	&mdc_rpc_stats_fops		},
 	{ NULL }
@@ -217,11 +211,27 @@ static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
 	&lustre_attr_max_rpcs_in_flight.attr,
 	&lustre_attr_max_mod_rpcs_in_flight.attr,
 	&lustre_attr_max_pages_per_rpc.attr,
+	&lustre_attr_mdc_conn_uuid.attr,
 	NULL,
 };
 
-void lprocfs_mdc_init_vars(struct obd_device *obd)
+int mdc_tunables_init(struct obd_device *obd)
 {
+	int rc;
+
 	obd->obd_ktype.default_attrs = mdc_attrs;
 	obd->obd_vars = lprocfs_mdc_obd_vars;
+
+	rc = lprocfs_obd_setup(obd, false);
+	if (rc)
+		return rc;
+
+	rc = sptlrpc_lprocfs_cliobd_attach(obd);
+	if (rc) {
+		lprocfs_obd_cleanup(obd);
+		return rc;
+	}
+	ptlrpc_lprocfs_register_obd(obd);
+
+	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index d66663f..941a896 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -36,7 +36,8 @@
 
 #include <lustre_mdc.h>
 
-void lprocfs_mdc_init_vars(struct obd_device *obd);
+int mdc_tunables_init(struct obd_device *obd);
+
 void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
 		   __u64 valid, size_t ea_size, __u32 suppgid, u32 flags);
 void mdc_swap_layouts_pack(struct ptlrpc_request *req,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index fcba599..f3c0722 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -60,8 +60,6 @@
 
 #define REQUEST_MINOR 244
 
-static int mdc_cleanup(struct obd_device *obd);
-
 static inline int mdc_queue_wait(struct ptlrpc_request *req)
 {
 	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
@@ -2647,10 +2645,9 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 	if (rc)
 		goto err_ptlrpcd_decref;
 
-	lprocfs_mdc_init_vars(obd);
-	lprocfs_obd_setup(obd, false);
-	sptlrpc_lprocfs_cliobd_attach(obd);
-	ptlrpc_lprocfs_register_obd(obd);
+	rc = mdc_tunables_init(obd);
+	if (rc)
+		goto err_osc_cleanup;
 
 	ns_register_cancel(obd->obd_namespace, mdc_cancel_weight);
 
@@ -2658,13 +2655,16 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 
 	rc = mdc_llog_init(obd);
 	if (rc) {
-		mdc_cleanup(obd);
 		CERROR("failed to setup llogging subsystems\n");
-		return rc;
+		goto err_llog_cleanup;
 	}
 
-	return rc;
+	return 0;
 
+err_llog_cleanup:
+	ptlrpc_lprocfs_unregister_obd(obd);
+err_osc_cleanup:
+	client_obd_cleanup(obd);
 err_ptlrpcd_decref:
 	ptlrpcd_decref();
 	return rc;
@@ -2715,17 +2715,10 @@ static int mdc_cleanup(struct obd_device *obd)
 static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 {
 	struct lustre_cfg *lcfg = buf;
-	int rc = 0;
+	size_t count  = class_modify_config(lcfg, PARAM_MDC,
+					    &obd->obd_kset.kobj);
 
-	switch (lcfg->lcfg_command) {
-	default:
-		rc = class_process_proc_param(PARAM_MDC, obd->obd_vars,
-					      lcfg, obd);
-		if (rc > 0)
-			rc = 0;
-		break;
-	}
-	return rc;
+	return count > 0 ? 0 : count;
 }
 
 static struct obd_ops mdc_obd_ops = {
-- 
1.8.3.1
