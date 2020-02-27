From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:53 -0500
Subject: [lustre-devel] [PATCH 065/622] lustre: osc: fix idle_timeout
 handling
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-66-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The patch that landed for LU-7236 introduced new sysfs entries
which were done wrong.

1) For idle_timeout it returns -ERANGE for
   any value passed in expect setting idle_timeout to zero. This
   does not match what the commit message said for LU-7236. So
   I changed lprocfs_str_with_units_to_s64() into kstrtouint()
   since a signed 64 bit timeout is not needed. Using kstrtouint()
   ensures that negative values are not possible and also cap the
   value to CONNECTION_SWITCH_MAX since the max of 4 billion
   seconds is over kill.

2) For the next procfs idle_connect it is really a write only file
   but it was treated as both read and write. There is no need for
   the osc_idle_connect_seq_show() function.

3) Lastly no more stuffing new entries into proc or debugfs. For
   this patch convert these new proc entries to sysfs. It seems
   to be a common occurrence so add LPROC_SEQ_* to spelling.txt
   so checkpatch will complain about using LPROC_SEQ_* which will
   go away.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: 406cd8a74d84 ("LU-8066 osc: fix idle_timeout handling")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/32719
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/lproc_osc.c | 42 ++++++++++++++++++------------------------
 1 file changed, 18 insertions(+), 24 deletions(-)

diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index fd84393..0a12079 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -598,26 +598,27 @@ static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 
 LPROC_SEQ_FOPS_RO(osc_unstable_stats);
 
-static int osc_idle_timeout_seq_show(struct seq_file *m, void *v)
+static ssize_t idle_timeout_show(struct kobject *kobj, struct attribute *attr,
+				 char *buf)
 {
-	struct obd_device *obd = m->private;
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
 
-	seq_printf(m, "%u\n", cli->cl_import->imp_idle_timeout);
-	return 0;
+	return sprintf(buf, "%u\n", cli->cl_import->imp_idle_timeout);
 }
 
-static ssize_t osc_idle_timeout_seq_write(struct file *f,
-					  const char __user *buffer,
-					  size_t count, loff_t *off)
+static ssize_t idle_timeout_store(struct kobject *kobj, struct attribute *attr,
+				  const char *buffer, size_t count)
 {
-	struct obd_device *obd = ((struct seq_file *)f->private_data)->private;
+	struct obd_device *obd = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
 	struct ptlrpc_request *req;
 	unsigned int val;
 	int rc;
 
-	rc = kstrtouint_from_user(buffer, count, 0, &val);
+	rc = kstrtouint(buffer, 0, &val);
 	if (rc)
 		return rc;
 
@@ -635,18 +636,13 @@ static ssize_t osc_idle_timeout_seq_write(struct file *f,
 
 	return count;
 }
-LPROC_SEQ_FOPS(osc_idle_timeout);
+LUSTRE_RW_ATTR(idle_timeout);
 
-static int osc_idle_connect_seq_show(struct seq_file *m, void *v)
+static ssize_t idle_connect_store(struct kobject *kobj, struct attribute *attr,
+				  const char *buffer, size_t count)
 {
-	return 0;
-}
-
-static ssize_t osc_idle_connect_seq_write(struct file *f,
-					  const char __user *buffer,
-					  size_t count, loff_t *off)
-{
-	struct obd_device *dev = ((struct seq_file *)f->private_data)->private;
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
 	struct ptlrpc_request *req;
 
@@ -658,7 +654,7 @@ static ssize_t osc_idle_connect_seq_write(struct file *f,
 
 	return count;
 }
-LPROC_SEQ_FOPS(osc_idle_connect);
+LUSTRE_WO_ATTR(idle_connect);
 
 LPROC_SEQ_FOPS_RO_TYPE(osc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(osc, server_uuid);
@@ -687,10 +683,6 @@ static ssize_t osc_idle_connect_seq_write(struct file *f,
 	  .fops	=	&osc_pinger_recov_fops		},
 	{ .name	=	"unstable_stats",
 	  .fops	=	&osc_unstable_stats_fops	},
-	{ .name	=	"idle_timeout",
-	  .fops	=	&osc_idle_timeout_fops		},
-	{ .name	=	"idle_connect",
-	  .fops	=	&osc_idle_connect_fops		},
 	{ NULL }
 };
 
@@ -877,6 +869,8 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	&lustre_attr_resend_count.attr,
 	&lustre_attr_ost_conn_uuid.attr,
 	&lustre_attr_ping.attr,
+	&lustre_attr_idle_timeout.attr,
+	&lustre_attr_idle_connect.attr,
 	NULL,
 };
 
-- 
1.8.3.1
