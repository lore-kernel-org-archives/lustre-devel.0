From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:42 -0500
Subject: [lustre-devel] [PATCH 414/622] lustre: mdc: polling mode for
 changelog reader
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-415-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

this allows the user (like lsom_sync and similar) to follow
the changelog and don't rescan getting duplicates.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12553
Lustre-commit: e215002883d5 ("LU-12553  mdc: polling mode for changelog reader")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35262
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c            | 37 +++++++++++++++++++++++++++++++-
 include/uapi/linux/lustre/lustre_ioctl.h |  1 +
 2 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index fb0de68..ea74bab 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -37,6 +37,7 @@
 #include <linux/miscdevice.h>
 
 #include <lustre_log.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
 
 #include "mdc_internal.h"
 
@@ -88,6 +89,9 @@ struct chlg_reader_state {
 	u64			 crs_rec_count;
 	/* List of prefetched enqueued_record::enq_linkage_items */
 	struct list_head	 crs_rec_queue;
+	unsigned int		 crs_last_catidx;
+	unsigned int		 crs_last_idx;
+	bool			 crs_poll;
 };
 
 struct chlg_rec_entry {
@@ -132,6 +136,9 @@ static int chlg_read_cat_process_cb(const struct lu_env *env,
 
 	rec = container_of(hdr, struct llog_changelog_rec, cr_hdr);
 
+	crs->crs_last_catidx = llh->lgh_hdr->llh_cat_idx;
+	crs->crs_last_idx = hdr->lrh_index;
+
 	if (rec->cr_hdr.lrh_type != CHANGELOG_REC) {
 		rc = -EINVAL;
 		CERROR("%s: not a changelog rec %x/%d in llog : rc = %d\n",
@@ -225,6 +232,10 @@ static int chlg_load(void *args)
 		goto err_out;
 	}
 
+	crs->crs_last_catidx = -1;
+	crs->crs_last_idx = 0;
+
+again:
 	rc = llog_open(NULL, ctx, &llh, NULL, CHANGELOG_CATALOG,
 		       LLOG_OPEN_EXISTS);
 	if (rc) {
@@ -248,12 +259,18 @@ static int chlg_load(void *args)
 		goto err_out;
 	}
 
-	rc = llog_cat_process(NULL, llh, chlg_read_cat_process_cb, crs, 0, 0);
+	rc = llog_cat_process(NULL, llh, chlg_read_cat_process_cb, crs,
+				crs->crs_last_catidx, crs->crs_last_idx);
 	if (rc < 0) {
 		CERROR("%s: fail to process llog: rc = %d\n",
 		       obd->obd_name, rc);
 		goto err_out;
 	}
+	if (!kthread_should_stop() && crs->crs_poll) {
+		llog_cat_close(NULL, llh);
+		schedule_timeout_interruptible(HZ);
+		goto again;
+	}
 
 	crs->crs_eof = true;
 
@@ -602,6 +619,23 @@ static unsigned int chlg_poll(struct file *file, poll_table *wait)
 	return mask;
 }
 
+static long chlg_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
+{
+	struct chlg_reader_state *crs = file->private_data;
+	int rc;
+
+	switch (cmd) {
+	case OBD_IOC_CHLG_POLL:
+		crs->crs_poll = !!arg;
+		rc = 0;
+		break;
+	default:
+		rc = -EINVAL;
+		break;
+	}
+	return rc;
+}
+
 static const struct file_operations chlg_fops = {
 	.owner		= THIS_MODULE,
 	.llseek		= chlg_llseek,
@@ -610,6 +644,7 @@ static unsigned int chlg_poll(struct file *file, poll_table *wait)
 	.open		= chlg_open,
 	.release	= chlg_release,
 	.poll		= chlg_poll,
+	.unlocked_ioctl	= chlg_ioctl,
 };
 
 /**
diff --git a/include/uapi/linux/lustre/lustre_ioctl.h b/include/uapi/linux/lustre/lustre_ioctl.h
index b067cc6..53dd34f 100644
--- a/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/include/uapi/linux/lustre/lustre_ioctl.h
@@ -221,6 +221,7 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 #define OBD_IOC_START_LFSCK	_IOWR('f', 230, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_STOP_LFSCK	_IOW('f', 231, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_QUERY_LFSCK	_IOR('f', 232, struct obd_ioctl_data)
+#define OBD_IOC_CHLG_POLL	_IOR('f', 233, long)
 /*	lustre/lustre_user.h	240-249 */
 /* was LIBCFS_IOC_DEBUG_MASK   _IOWR('f', 250, long) until 2.11 */
 
-- 
1.8.3.1
