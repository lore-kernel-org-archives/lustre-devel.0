From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:30 -0500
Subject: [lustre-devel] [PATCH 102/622] lustre: osc: enable/disable OSC
 grant shrink
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-103-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

Add an OSC sysfs interface to enable/disable client's grant shrink
feature.

lctl get_param osc.*.grant_shrink
lctl set_param osc.*.grant_shrink={0,1}

WC-bug-id: https://jira.whamcloud.com/browse/LU-8708
Lustre-commit: 3e070e30a98d ("LU-8708 osc: enable/disable OSC grant shrink")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/23203
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/lproc_osc.c | 67 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index efb4998..16de266 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -674,6 +674,72 @@ static ssize_t idle_connect_store(struct kobject *kobj, struct attribute *attr,
 }
 LUSTRE_WO_ATTR(idle_connect);
 
+static ssize_t grant_shrink_show(struct kobject *kobj, struct attribute *attr,
+				 char *buf)
+{
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct client_obd *cli = &obd->u.cli;
+	struct obd_connect_data *ocd;
+	ssize_t len;
+
+	len = lprocfs_climp_check(obd);
+	if (len)
+		return len;
+
+	ocd = &cli->cl_import->imp_connect_data;
+
+	len = snprintf(buf, PAGE_SIZE, "%d\n",
+		       !!OCD_HAS_FLAG(ocd, GRANT_SHRINK));
+	up_read(&obd->u.cli.cl_sem);
+
+	return len;
+}
+
+static ssize_t grant_shrink_store(struct kobject *kobj, struct attribute *attr,
+				  const char *buffer, size_t count)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
+	struct client_obd *cli = &dev->u.cli;
+	struct obd_connect_data *ocd;
+	bool val;
+	int rc;
+
+	if (!dev)
+		return 0;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	rc = lprocfs_climp_check(dev);
+	if (rc)
+		return rc;
+
+	ocd = &cli->cl_import->imp_connect_data;
+
+	if (!val) {
+		if (OCD_HAS_FLAG(ocd, GRANT_SHRINK))
+			ocd->ocd_connect_flags &= ~OBD_CONNECT_GRANT_SHRINK;
+	} else {
+		/**
+		 * server replied obd_connect_data is always bigger, so
+		 * client's imp_connect_flags_orig are always supported
+		 * by the server
+		 */
+		if (!OCD_HAS_FLAG(ocd, GRANT_SHRINK) &&
+		    cli->cl_import->imp_connect_flags_orig &
+		    OBD_CONNECT_GRANT_SHRINK)
+			ocd->ocd_connect_flags |= OBD_CONNECT_GRANT_SHRINK;
+	}
+
+	up_read(&dev->u.cli.cl_sem);
+
+	return count;
+}
+LUSTRE_RW_ATTR(grant_shrink);
+
 LPROC_SEQ_FOPS_RO_TYPE(osc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(osc, server_uuid);
 LPROC_SEQ_FOPS_RO_TYPE(osc, timeouts);
@@ -889,6 +955,7 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	&lustre_attr_ping.attr,
 	&lustre_attr_idle_timeout.attr,
 	&lustre_attr_idle_connect.attr,
+	&lustre_attr_grant_shrink.attr,
 	NULL,
 };
 
-- 
1.8.3.1
