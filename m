From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:14 -0500
Subject: [lustre-devel] [PATCH 146/622] lustre: obd: use correct names for
 conn_uuid
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-147-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The LUSTRE_R[OW]_ATTR() macros assume that the name of the sysfs
file to create matches the beginning of the function names. In
the case of LUSTRE_RO_ATTR(conn_uuid) this maps to the function
conn_uuid_show() and generated sysfs files "conn_uuid". While it
makes sense to standardize this interface we need to keep the
old xxx_conn_uuid. We can create these xxx_conn_uuid sysfs files
by using the base sysfs attr macro LUSTRE_ATTR().

WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: f2bf876ef77e ("LU-8066 obd: use correct names for conn_uuid")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33213
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/lproc_mdc.c           |  7 ++++---
 fs/lustre/mgc/lproc_mgc.c           |  5 +++--
 fs/lustre/obdclass/lprocfs_status.c | 24 ------------------------
 fs/lustre/osc/lproc_osc.c           |  5 +++--
 4 files changed, 10 insertions(+), 31 deletions(-)

diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 0c52bcf..746dd21 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -303,8 +303,8 @@ static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
 
 LUSTRE_RW_ATTR(max_pages_per_rpc);
 
-#define mdc_conn_uuid_show conn_uuid_show
-LUSTRE_RO_ATTR(mdc_conn_uuid);
+LUSTRE_ATTR(mds_conn_uuid, 0444, conn_uuid_show, NULL);
+LUSTRE_RO_ATTR(conn_uuid);
 
 LUSTRE_RO_ATTR(ping);
 
@@ -529,7 +529,8 @@ static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
 	&lustre_attr_max_rpcs_in_flight.attr,
 	&lustre_attr_max_mod_rpcs_in_flight.attr,
 	&lustre_attr_max_pages_per_rpc.attr,
-	&lustre_attr_mdc_conn_uuid.attr,
+	&lustre_attr_mds_conn_uuid.attr,
+	&lustre_attr_conn_uuid.attr,
 	&lustre_attr_ping.attr,
 	NULL,
 };
diff --git a/fs/lustre/mgc/lproc_mgc.c b/fs/lustre/mgc/lproc_mgc.c
index 4c276f9..676d479 100644
--- a/fs/lustre/mgc/lproc_mgc.c
+++ b/fs/lustre/mgc/lproc_mgc.c
@@ -66,13 +66,14 @@ struct lprocfs_vars lprocfs_mgc_obd_vars[] = {
 	{ NULL }
 };
 
-#define mgs_conn_uuid_show conn_uuid_show
-LUSTRE_RO_ATTR(mgs_conn_uuid);
+LUSTRE_ATTR(mgs_conn_uuid, 0444, conn_uuid_show, NULL);
+LUSTRE_RO_ATTR(conn_uuid);
 
 LUSTRE_RO_ATTR(ping);
 
 static struct attribute *mgc_attrs[] = {
 	&lustre_attr_mgs_conn_uuid.attr,
+	&lustre_attr_conn_uuid.attr,
 	&lustre_attr_ping.attr,
 	NULL,
 };
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index b3dbe85..cce9bec 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -524,30 +524,6 @@ int lprocfs_rd_server_uuid(struct seq_file *m, void *data)
 }
 EXPORT_SYMBOL(lprocfs_rd_server_uuid);
 
-int lprocfs_rd_conn_uuid(struct seq_file *m, void *data)
-{
-	struct obd_device *obd = data;
-	struct ptlrpc_connection *conn;
-	int rc;
-
-	LASSERT(obd);
-
-	rc = lprocfs_climp_check(obd);
-	if (rc)
-		return rc;
-
-	conn = obd->u.cli.cl_import->imp_connection;
-	if (conn && obd->u.cli.cl_import)
-		seq_printf(m, "%s\n", conn->c_remote_uuid.uuid);
-	else
-		seq_puts(m, "<none>\n");
-
-	up_read(&obd->u.cli.cl_sem);
-
-	return 0;
-}
-EXPORT_SYMBOL(lprocfs_rd_conn_uuid);
-
 /**
  * Lock statistics structure for access, possibly only on this CPU.
  *
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index f025275..d9030b7 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -173,8 +173,8 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(max_dirty_mb);
 
-#define ost_conn_uuid_show conn_uuid_show
-LUSTRE_RO_ATTR(ost_conn_uuid);
+LUSTRE_ATTR(ost_conn_uuid, 0444, conn_uuid_show, NULL);
+LUSTRE_RO_ATTR(conn_uuid);
 
 LUSTRE_RO_ATTR(ping);
 
@@ -962,6 +962,7 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	&lustre_attr_short_io_bytes.attr,
 	&lustre_attr_resend_count.attr,
 	&lustre_attr_ost_conn_uuid.attr,
+	&lustre_attr_conn_uuid.attr,
 	&lustre_attr_ping.attr,
 	&lustre_attr_idle_timeout.attr,
 	&lustre_attr_idle_connect.attr,
-- 
1.8.3.1
