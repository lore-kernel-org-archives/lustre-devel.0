From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:38 -0400
Subject: [lustre-devel] [PATCH 35/38] lustre: osc: update sysfs handling
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Move sysfs/debugfs handling to lproc_osc.c. Do proper cleanup if
any of the sysfs handling code fails. Fix up the style issues.
Move to class_modify_params().

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/30962
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c    | 68 ++++++++++++++++--------
 drivers/staging/lustre/lustre/osc/osc_internal.h |  3 +-
 drivers/staging/lustre/lustre/osc/osc_request.c  | 26 +++------
 3 files changed, 56 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 89dadba..284ceed 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -50,8 +50,7 @@ static ssize_t active_show(struct kobject *kobj, struct attribute *attr,
 }
 
 static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
-			    const char *buffer,
-			    size_t count)
+			    const char *buffer, size_t count)
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
@@ -157,8 +156,8 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
-	int rc;
 	unsigned long pages_number;
+	int rc;
 
 	rc = kstrtoul(buffer, 10, &pages_number);
 	if (rc)
@@ -180,6 +179,9 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(max_dirty_mb);
 
+#define ost_conn_uuid_show conn_uuid_show
+LUSTRE_RO_ATTR(ost_conn_uuid);
+
 static int osc_cached_mb_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *dev = m->private;
@@ -407,9 +409,8 @@ static ssize_t checksums_store(struct kobject *kobj,
 static int osc_checksum_type_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *obd = m->private;
-	int i;
-
 	DECLARE_CKSUM_NAME;
+	int i;
 
 	if (!obd)
 		return 0;
@@ -431,10 +432,9 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 					   size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
-	int i;
-
 	DECLARE_CKSUM_NAME;
 	char kernbuf[10];
+	int i;
 
 	if (!obd)
 		return 0;
@@ -665,7 +665,6 @@ static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 
 LPROC_SEQ_FOPS_RO_TYPE(osc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(osc, server_uuid);
-LPROC_SEQ_FOPS_RO_TYPE(osc, conn_uuid);
 LPROC_SEQ_FOPS_RO_TYPE(osc, timeouts);
 LPROC_SEQ_FOPS_RO_TYPE(osc, state);
 
@@ -675,17 +674,24 @@ static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 LPROC_SEQ_FOPS_RW_TYPE(osc, pinger_recov);
 
 static struct lprocfs_vars lprocfs_osc_obd_vars[] = {
-	{ "ping",	     &osc_ping_fops,    NULL, 0222 },
-	{ "connect_flags",   &osc_connect_flags_fops, NULL, 0 },
-	/*{ "filegroups",      lprocfs_rd_filegroups,  NULL, 0 },*/
-	{ "ost_server_uuid", &osc_server_uuid_fops, NULL, 0 },
-	{ "ost_conn_uuid",   &osc_conn_uuid_fops, NULL, 0 },
-	{ "osc_cached_mb",   &osc_cached_mb_fops, NULL },
-	{ "checksum_type",   &osc_checksum_type_fops, NULL },
-	{ "timeouts",	     &osc_timeouts_fops, NULL, 0 },
-	{ "import",		&osc_import_fops, NULL },
-	{ "state",		&osc_state_fops, NULL, 0 },
-	{ "pinger_recov",	&osc_pinger_recov_fops, NULL },
+	{ .name	=	"ping",
+	  .fops =	&osc_ping_fops			},
+	{ .name	=	"connect_flags",
+	  .fops	=	&osc_connect_flags_fops		},
+	{ .name	=	"ost_server_uuid",
+	  .fops	=	&osc_server_uuid_fops		},
+	{ .name	=	"osc_cached_mb",
+	  .fops =	&osc_cached_mb_fops		},
+	{ .name	=	"checksum_type",
+	  .fops	=	&osc_checksum_type_fops		},
+	{ .name	=	"timeouts",
+	  .fops	=	&osc_timeouts_fops		},
+	{ .name	=	"import",
+	  .fops	=	&osc_import_fops		},
+	{ .name	=	"state",
+	  .fops	=	&osc_state_fops			},
+	{ .name	=	"pinger_recov",
+	  .fops	=	&osc_pinger_recov_fops		},
 	{ .name	=	"unstable_stats",
 	  .fops	=	&osc_unstable_stats_fops	},
 	{ NULL }
@@ -871,11 +877,31 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	&lustre_attr_max_pages_per_rpc.attr,
 	&lustre_attr_max_rpcs_in_flight.attr,
 	&lustre_attr_resend_count.attr,
+	&lustre_attr_ost_conn_uuid.attr,
 	NULL,
 };
 
-void lprocfs_osc_init_vars(struct obd_device *obd)
+int osc_tunables_init(struct obd_device *obd)
 {
-	obd->obd_ktype.default_attrs = osc_attrs;
+	int rc;
+
 	obd->obd_vars = lprocfs_osc_obd_vars;
+	obd->obd_ktype.default_attrs = osc_attrs;
+	rc = lprocfs_obd_setup(obd, false);
+	if (rc)
+		return rc;
+
+	rc = sptlrpc_lprocfs_cliobd_attach(obd);
+	if (rc) {
+		lprocfs_obd_cleanup(obd);
+		return rc;
+	}
+
+	debugfs_create_file("osc_stats", 0644, obd->obd_debugfs_entry, obd,
+			    &osc_stats_fops);
+	debugfs_create_file("rpc_stats", 0644, obd->obd_debugfs_entry, obd,
+			    &osc_rpc_stats_fops);
+
+	ptlrpc_lprocfs_register_obd(obd);
+	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 6caabdb..55054d7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -145,8 +145,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 
 int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg);
 
-void lproc_osc_attach_seqstat(struct obd_device *dev);
-void lprocfs_osc_init_vars(struct obd_device *obd);
+int osc_tunables_init(struct obd_device *obd);
 
 extern struct lu_device_type osc_device_type;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index a7a4a53..7c91c4b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2885,12 +2885,9 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	cli->cl_grant_shrink_interval = GRANT_SHRINK_INTERVAL;
 
-	lprocfs_osc_init_vars(obd);
-	if (lprocfs_obd_setup(obd, false) == 0) {
-		lproc_osc_attach_seqstat(obd);
-		sptlrpc_lprocfs_cliobd_attach(obd);
-		ptlrpc_lprocfs_register_obd(obd);
-	}
+	rc = osc_tunables_init(obd);
+	if (rc)
+		goto out_quota;
 
 	/*
 	 * We try to control the total number of requests with a upper limit
@@ -2916,6 +2913,8 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	return rc;
 
+out_quota:
+	osc_quota_cleanup(obd);
 out_ptlrpcd_work:
 	if (cli->cl_writeback_work) {
 		ptlrpcd_destroy_work(cli->cl_writeback_work);
@@ -2993,18 +2992,9 @@ static int osc_cleanup(struct obd_device *obd)
 
 int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
-	int rc = 0;
-
-	switch (lcfg->lcfg_command) {
-	default:
-		rc = class_process_proc_param(PARAM_OSC, obd->obd_vars,
-					      lcfg, obd);
-		if (rc > 0)
-			rc = 0;
-		break;
-	}
-
-	return rc;
+	ssize_t count  = class_modify_config(lcfg, PARAM_OSC,
+					     &obd->obd_kset.kobj);
+	return count > 0 ? 0 : count;
 }
 
 static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
-- 
1.8.3.1
