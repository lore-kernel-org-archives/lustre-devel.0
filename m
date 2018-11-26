From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:24 -0500
Subject: [lustre-devel] [PATCH 08/12] lustre: mdc: propagate changelog
 errors to readers
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Store errors encountered by the changelog llog reader thread in the
crs_err field of struct changelog_reader_state so that they can be
propageted to changelog readers. In chlg_read() improve the error and
EOF reporting. Return -ERESTARTSYS when the blocked reader is
interrupted. Replace uses of wait_event_idle() with
ait_event_interruptible().

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10218
Reviewed-on: https://review.whamcloud.com/30040
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_changelog.c | 45 ++++++++++++++---------
 1 file changed, 28 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
index becdee8..811a36a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
@@ -71,7 +71,7 @@ struct chlg_reader_state {
 	/* Producer thread (if any) */
 	struct task_struct	*crs_prod_task;
 	/* An error occurred that prevents from reading further */
-	bool			 crs_err;
+	int			 crs_err;
 	/* EOF, no more records available */
 	bool			 crs_eof;
 	/* Desired start position */
@@ -148,9 +148,9 @@ static int chlg_read_cat_process_cb(const struct lu_env *env,
 	       PFID(&rec->cr.cr_tfid), PFID(&rec->cr.cr_pfid),
 	       rec->cr.cr_namelen, changelog_rec_name(&rec->cr));
 
-	wait_event_idle(crs->crs_waitq_prod,
-			(crs->crs_rec_count < CDEV_CHLG_MAX_PREFETCH ||
-			 kthread_should_stop()));
+	wait_event_interruptible(crs->crs_waitq_prod,
+				 crs->crs_rec_count < CDEV_CHLG_MAX_PREFETCH ||
+				 kthread_should_stop());
 
 	if (kthread_should_stop())
 		return LLOG_PROC_BREAK;
@@ -231,7 +231,7 @@ static int chlg_load(void *args)
 
 err_out:
 	if (rc < 0)
-		crs->crs_err = true;
+		crs->crs_err = rc;
 
 	wake_up_all(&crs->crs_waitq_cons);
 
@@ -241,7 +241,7 @@ static int chlg_load(void *args)
 	if (ctx)
 		llog_ctxt_put(ctx);
 
-	wait_event_idle(crs->crs_waitq_prod, kthread_should_stop());
+	wait_event_interruptible(crs->crs_waitq_prod, kthread_should_stop());
 
 	return rc;
 }
@@ -264,13 +264,20 @@ static ssize_t chlg_read(struct file *file, char __user *buff, size_t count,
 	struct chlg_reader_state *crs = file->private_data;
 	struct chlg_rec_entry *rec;
 	struct chlg_rec_entry *tmp;
-	ssize_t  written_total = 0;
+	ssize_t written_total = 0;
 	LIST_HEAD(consumed);
+	size_t rc;
+
+	if (file->f_flags & O_NONBLOCK && crs->crs_rec_count == 0) {
+		if (crs->crs_err < 0)
+			return crs->crs_err;
+		else if (crs->crs_eof)
+			return 0;
+		else
+			return -EAGAIN;
+	}
 
-	if (file->f_flags & O_NONBLOCK && crs->crs_rec_count == 0)
-		return -EAGAIN;
-
-	wait_event_idle(crs->crs_waitq_cons,
+	rc = wait_event_interruptible(crs->crs_waitq_cons,
 			crs->crs_rec_count > 0 || crs->crs_eof || crs->crs_err);
 
 	mutex_lock(&crs->crs_lock);
@@ -279,8 +286,7 @@ static ssize_t chlg_read(struct file *file, char __user *buff, size_t count,
 			break;
 
 		if (copy_to_user(buff, rec->enq_record, rec->enq_length)) {
-			if (written_total == 0)
-				written_total = -EFAULT;
+			rc = -EFAULT;
 			break;
 		}
 
@@ -294,15 +300,19 @@ static ssize_t chlg_read(struct file *file, char __user *buff, size_t count,
 	}
 	mutex_unlock(&crs->crs_lock);
 
-	if (written_total > 0)
+	if (written_total > 0) {
+		rc = written_total;
 		wake_up_all(&crs->crs_waitq_prod);
+	} else if (rc == 0) {
+		rc = crs->crs_err;
+	}
 
 	list_for_each_entry_safe(rec, tmp, &consumed, enq_linkage)
 		enq_record_delete(rec);
 
 	*ppos = crs->crs_start_offset;
 
-	return written_total;
+	return rc;
 }
 
 /**
@@ -509,15 +519,16 @@ static int chlg_release(struct inode *inode, struct file *file)
 	struct chlg_reader_state *crs = file->private_data;
 	struct chlg_rec_entry *rec;
 	struct chlg_rec_entry *tmp;
+	int rc = 0;
 
 	if (crs->crs_prod_task)
-		kthread_stop(crs->crs_prod_task);
+		rc = kthread_stop(crs->crs_prod_task);
 
 	list_for_each_entry_safe(rec, tmp, &crs->crs_rec_queue, enq_linkage)
 		enq_record_delete(rec);
 
 	kfree(crs);
-	return 0;
+	return rc;
 }
 
 /**
-- 
1.8.3.1
