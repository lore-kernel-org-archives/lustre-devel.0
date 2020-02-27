From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:18 -0500
Subject: [lustre-devel] [PATCH 030/622] lustre: obd: create ping sysfs file
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We have ping in the lustre debugfs tree. Its a perfect
fit for sysfs. Create a sysfs equivalent so we can in time
remove the debugfs file.

WC-bug-id: https://jira.hpdd.intel.com/browse/LU-8066
Lustre-commit: 0100ab268c31 ("LU-8066 obd: final pieces for sysfs/debugfs support")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/28108
Lustre-commit: 6bbae72c6900 ("LU-8066 sysfs: make ping sysfs file read and writable")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33776
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h |  6 ++++--
 fs/lustre/mdc/lproc_mdc.c          |  7 +++----
 fs/lustre/mgc/lproc_mgc.c          |  7 +++----
 fs/lustre/osc/lproc_osc.c          |  7 +++----
 fs/lustre/ptlrpc/lproc_ptlrpc.c    | 18 ++++++++----------
 5 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 965f8a1..32d43fb 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -457,8 +457,10 @@ int lprocfs_wr_uint(struct file *file, const char __user *buffer,
 struct adaptive_timeout;
 int lprocfs_at_hist_helper(struct seq_file *m, struct adaptive_timeout *at);
 int lprocfs_rd_timeouts(struct seq_file *m, void *data);
-int lprocfs_wr_ping(struct file *file, const char __user *buffer,
-		    size_t count, loff_t *off);
+
+ssize_t ping_show(struct kobject *kobj, struct attribute *attr,
+		  char *buffer);
+
 int lprocfs_wr_import(struct file *file, const char __user *buffer,
 		      size_t count, loff_t *off);
 int lprocfs_rd_pinger_recov(struct seq_file *m, void *n);
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index f09292e..6b87e76 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -306,6 +306,8 @@ static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
 #define mdc_conn_uuid_show conn_uuid_show
 LUSTRE_RO_ATTR(mdc_conn_uuid);
 
+LUSTRE_RO_ATTR(ping);
+
 static ssize_t mdc_rpc_stats_seq_write(struct file *file,
 				       const char __user *buf,
 				       size_t len, loff_t *off)
@@ -454,8 +456,6 @@ static ssize_t mdc_stats_seq_write(struct file *file,
 }
 LPROC_SEQ_FOPS(mdc_stats);
 
-LPROC_SEQ_FOPS_WR_ONLY(mdc, ping);
-
 LPROC_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(mdc, server_uuid);
 LPROC_SEQ_FOPS_RO_TYPE(mdc, timeouts);
@@ -465,8 +465,6 @@ static ssize_t mdc_stats_seq_write(struct file *file,
 LPROC_SEQ_FOPS_RW_TYPE(mdc, pinger_recov);
 
 static struct lprocfs_vars lprocfs_mdc_obd_vars[] = {
-	{ .name	=	"ping",
-	  .fops	=	&mdc_ping_fops			},
 	{ .name	=	"connect_flags",
 	  .fops	=	&mdc_connect_flags_fops		},
 	{ .name	=	"mds_server_uuid",
@@ -500,6 +498,7 @@ static ssize_t mdc_stats_seq_write(struct file *file,
 	&lustre_attr_max_mod_rpcs_in_flight.attr,
 	&lustre_attr_max_pages_per_rpc.attr,
 	&lustre_attr_mdc_conn_uuid.attr,
+	&lustre_attr_ping.attr,
 	NULL,
 };
 
diff --git a/fs/lustre/mgc/lproc_mgc.c b/fs/lustre/mgc/lproc_mgc.c
index d977d51..4c276f9 100644
--- a/fs/lustre/mgc/lproc_mgc.c
+++ b/fs/lustre/mgc/lproc_mgc.c
@@ -45,8 +45,6 @@
 
 LPROC_SEQ_FOPS_RO_TYPE(mgc, state);
 
-LPROC_SEQ_FOPS_WR_ONLY(mgc, ping);
-
 static int mgc_ir_state_seq_show(struct seq_file *m, void *v)
 {
 	return lprocfs_mgc_rd_ir_state(m, m->private);
@@ -55,8 +53,6 @@ static int mgc_ir_state_seq_show(struct seq_file *m, void *v)
 LPROC_SEQ_FOPS_RO(mgc_ir_state);
 
 struct lprocfs_vars lprocfs_mgc_obd_vars[] = {
-	{ .name	=	"ping",
-	  .fops =	&mgc_ping_fops		},
 	{ .name =	"connect_flags",
 	  .fops =	&mgc_connect_flags_fops	},
 	{ .name =	"mgs_server_uuid",
@@ -73,8 +69,11 @@ struct lprocfs_vars lprocfs_mgc_obd_vars[] = {
 #define mgs_conn_uuid_show conn_uuid_show
 LUSTRE_RO_ATTR(mgs_conn_uuid);
 
+LUSTRE_RO_ATTR(ping);
+
 static struct attribute *mgc_attrs[] = {
 	&lustre_attr_mgs_conn_uuid.attr,
+	&lustre_attr_ping.attr,
 	NULL,
 };
 
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index df48138..605a236 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -176,6 +176,8 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 #define ost_conn_uuid_show conn_uuid_show
 LUSTRE_RO_ATTR(ost_conn_uuid);
 
+LUSTRE_RO_ATTR(ping);
+
 static int osc_cached_mb_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *dev = m->private;
@@ -601,14 +603,10 @@ static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 LPROC_SEQ_FOPS_RO_TYPE(osc, timeouts);
 LPROC_SEQ_FOPS_RO_TYPE(osc, state);
 
-LPROC_SEQ_FOPS_WR_ONLY(osc, ping);
-
 LPROC_SEQ_FOPS_RW_TYPE(osc, import);
 LPROC_SEQ_FOPS_RW_TYPE(osc, pinger_recov);
 
 static struct lprocfs_vars lprocfs_osc_obd_vars[] = {
-	{ .name	=	"ping",
-	  .fops =	&osc_ping_fops			},
 	{ .name	=	"connect_flags",
 	  .fops	=	&osc_connect_flags_fops		},
 	{ .name	=	"ost_server_uuid",
@@ -812,6 +810,7 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	&lustre_attr_short_io_bytes.attr,
 	&lustre_attr_resend_count.attr,
 	&lustre_attr_ost_conn_uuid.attr,
+	&lustre_attr_ping.attr,
 	NULL,
 };
 
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 3dc99d4..e48a4e8 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1227,13 +1227,11 @@ void ptlrpc_lprocfs_unregister_obd(struct obd_device *obd)
 }
 EXPORT_SYMBOL(ptlrpc_lprocfs_unregister_obd);
 
-#undef BUFLEN
-
-int lprocfs_wr_ping(struct file *file, const char __user *buffer,
-		    size_t count, loff_t *off)
+ssize_t ping_show(struct kobject *kobj, struct attribute *attr,
+		  char *buffer)
 {
-	struct seq_file *m = file->private_data;
-	struct obd_device *obd = m->private;
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
 	struct ptlrpc_request *req;
 	int rc;
 
@@ -1249,13 +1247,13 @@ int lprocfs_wr_ping(struct file *file, const char __user *buffer,
 	req->rq_send_state = LUSTRE_IMP_FULL;
 
 	rc = ptlrpc_queue_wait(req);
-
 	ptlrpc_req_finished(req);
-	if (rc >= 0)
-		return count;
+
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_wr_ping);
+EXPORT_SYMBOL(ping_show);
+
+#undef BUFLEN
 
 /* Write the connection UUID to this file to attempt to connect to that node.
  * The connection UUID is a node's primary NID. For example,
-- 
1.8.3.1
