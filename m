From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:27 -0400
Subject: [lustre-devel] [PATCH 24/38] lustre: obd: create conn_uuid sysfs
 file
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Change conn_uuid from a debugfs file to sysfs file.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/28108
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lprocfs_status.h |  1 +
 .../lustre/lustre/obdclass/lprocfs_status.c        | 23 ++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 3863fff..bc7a390 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -463,6 +463,7 @@ int lprocfs_wr_uint(struct file *file, const char __user *buffer,
 		    unsigned long count, void *data);
 int lprocfs_rd_server_uuid(struct seq_file *m, void *data);
 int lprocfs_rd_conn_uuid(struct seq_file *m, void *data);
+ssize_t conn_uuid_show(struct kobject *kobj, struct attribute *attr, char *buf);
 int lprocfs_rd_import(struct seq_file *m, void *data);
 int lprocfs_rd_state(struct seq_file *m, void *data);
 int lprocfs_rd_connect_flags(struct seq_file *m, void *data);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index f889fb8..3fbf10b 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -476,6 +476,29 @@ static ssize_t filesfree_show(struct kobject *kobj, struct attribute *attr,
 }
 LUSTRE_RO_ATTR(filesfree);
 
+ssize_t conn_uuid_show(struct kobject *kobj, struct attribute *attr, char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct ptlrpc_connection *conn;
+	ssize_t count;
+	int rc;
+
+	rc = lprocfs_climp_check(obd);
+	if (rc)
+		return rc;
+
+	conn = obd->u.cli.cl_import->imp_connection;
+	if (conn && obd->u.cli.cl_import)
+		count = sprintf(buf, "%s\n", conn->c_remote_uuid.uuid);
+	else
+		count = sprintf(buf, "%s\n", "<none>");
+
+	up_read(&obd->u.cli.cl_sem);
+	return count;
+}
+EXPORT_SYMBOL(conn_uuid_show);
+
 int lprocfs_rd_server_uuid(struct seq_file *m, void *data)
 {
 	struct obd_device *obd = data;
-- 
1.8.3.1
