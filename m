From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:01 -0500
Subject: [lustre-devel] [PATCH 193/622] lustre: sysfs: make ping sysfs file
 read and writable
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-194-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Starting with 4.15 kernels any sysfs read only is limited to
root access only. To retain the ability for non root users
to detect if a remote server is alive using the 'ping' sysfs
file we need to change it to writable. Retain the read ability
so older tools will work.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: 6bbae72c6900 ("LU-8066 sysfs: make ping sysfs file read and writable")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33776
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h | 3 ++-
 fs/lustre/mdc/lproc_mdc.c          | 2 +-
 fs/lustre/mgc/lproc_mgc.c          | 2 +-
 fs/lustre/osc/lproc_osc.c          | 2 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c    | 9 +++++++++
 5 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 1ef548ae..c1079f1 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -462,7 +462,8 @@ int lprocfs_wr_uint(struct file *file, const char __user *buffer,
 struct adaptive_timeout;
 int lprocfs_at_hist_helper(struct seq_file *m, struct adaptive_timeout *at);
 int lprocfs_rd_timeouts(struct seq_file *m, void *data);
-
+ssize_t ping_store(struct kobject *kobj, struct attribute *attr,
+		   const char *buffer, size_t count);
 ssize_t ping_show(struct kobject *kobj, struct attribute *attr,
 		  char *buffer);
 
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 746dd21..70c9eaf 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -306,7 +306,7 @@ static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
 LUSTRE_ATTR(mds_conn_uuid, 0444, conn_uuid_show, NULL);
 LUSTRE_RO_ATTR(conn_uuid);
 
-LUSTRE_RO_ATTR(ping);
+LUSTRE_RW_ATTR(ping);
 
 static ssize_t mdc_rpc_stats_seq_write(struct file *file,
 				       const char __user *buf,
diff --git a/fs/lustre/mgc/lproc_mgc.c b/fs/lustre/mgc/lproc_mgc.c
index 676d479..0c716df 100644
--- a/fs/lustre/mgc/lproc_mgc.c
+++ b/fs/lustre/mgc/lproc_mgc.c
@@ -69,7 +69,7 @@ struct lprocfs_vars lprocfs_mgc_obd_vars[] = {
 LUSTRE_ATTR(mgs_conn_uuid, 0444, conn_uuid_show, NULL);
 LUSTRE_RO_ATTR(conn_uuid);
 
-LUSTRE_RO_ATTR(ping);
+LUSTRE_RW_ATTR(ping);
 
 static struct attribute *mgc_attrs[] = {
 	&lustre_attr_mgs_conn_uuid.attr,
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index ac64724..ea67d20 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -176,7 +176,7 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 LUSTRE_ATTR(ost_conn_uuid, 0444, conn_uuid_show, NULL);
 LUSTRE_RO_ATTR(conn_uuid);
 
-LUSTRE_RO_ATTR(ping);
+LUSTRE_RW_ATTR(ping);
 
 static int osc_cached_mb_seq_show(struct seq_file *m, void *v)
 {
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index eb0ecc0..700e109 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1234,6 +1234,7 @@ void ptlrpc_lprocfs_unregister_obd(struct obd_device *obd)
 }
 EXPORT_SYMBOL(ptlrpc_lprocfs_unregister_obd);
 
+/* Kept for older tools */
 ssize_t ping_show(struct kobject *kobj, struct attribute *attr,
 		  char *buffer)
 {
@@ -1260,6 +1261,14 @@ ssize_t ping_show(struct kobject *kobj, struct attribute *attr,
 }
 EXPORT_SYMBOL(ping_show);
 
+ssize_t ping_store(struct kobject *kobj, struct attribute *attr,
+		   const char *buffer, size_t count)
+{
+	return ping_show(kobj, attr, (char *)buffer);
+}
+EXPORT_SYMBOL(ping_store);
+
+
 #undef BUFLEN
 
 /* Write the connection UUID to this file to attempt to connect to that node.
-- 
1.8.3.1
