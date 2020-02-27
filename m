From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:53 -0500
Subject: [lustre-devel] [PATCH 245/622] lustre: obd: make health_check sysfs
 compliant
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-246-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The patch http://review.whamcloud.com/16721 was
ported to the upstream client but was rejected
since it violating the sysfs one item rule. Change
the reporting of LBUG plus unhealthy to just
reporting LBUG. Move the reporting of which device
is unhealthy to a new debugfs file that mirrors
the sysfs file.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: 5d368bd0b203 ("LU-8066 obd: make health_check sysfs compliant")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/25631
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_sysfs.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index 73e44e7..ca15936 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -194,8 +194,12 @@ static ssize_t pinger_show(struct kobject *kobj, struct attribute *attr,
 
 		if (obd_health_check(NULL, obd))
 			healthy = false;
+
 		class_decref(obd, __func__, current);
 		read_lock(&obd_dev_lock);
+
+		if (!healthy)
+			break;
 	}
 	read_unlock(&obd_dev_lock);
 
@@ -363,6 +367,40 @@ static int obd_device_list_open(struct inode *inode, struct file *file)
 	.release = seq_release,
 };
 
+static int
+health_check_seq_show(struct seq_file *m, void *unused)
+{
+	int i;
+
+	read_lock(&obd_dev_lock);
+	for (i = 0; i < class_devno_max(); i++) {
+		struct obd_device *obd;
+
+		obd = class_num2obd(i);
+		if (!obd || !obd->obd_attached || !obd->obd_set_up)
+			continue;
+
+		LASSERT(obd->obd_magic == OBD_DEVICE_MAGIC);
+		if (obd->obd_stopping)
+			continue;
+
+		class_incref(obd, __func__, current);
+		read_unlock(&obd_dev_lock);
+
+		if (obd_health_check(NULL, obd)) {
+			seq_printf(m, "device %s reported unhealthy\n",
+				   obd->obd_name);
+		}
+		class_decref(obd, __func__, current);
+		read_lock(&obd_dev_lock);
+	}
+	read_unlock(&obd_dev_lock);
+
+	return 0;
+}
+
+LPROC_SEQ_FOPS_RO(health_check);
+
 struct kset *lustre_kset;
 EXPORT_SYMBOL_GPL(lustre_kset);
 
@@ -407,6 +445,9 @@ int class_procfs_init(void)
 
 	debugfs_create_file("devices", 0444, debugfs_lustre_root, NULL,
 			    &obd_device_list_fops);
+
+	debugfs_create_file("health_check", 0444, debugfs_lustre_root,
+			    NULL, &health_check_fops);
 out:
 	return rc;
 }
-- 
1.8.3.1
