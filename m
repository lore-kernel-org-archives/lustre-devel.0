Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7BCDC48BE8
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:44 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AA1EB611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA1EB611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D187B21F6CC;
	Sun, 13 Jun 2021 16:12:18 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 60EAD21F157
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:45 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D36BD100B059;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D20DA9C306; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:27 -0400
Message-Id: <1623625897-17706-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/27] lustre: mdc: start changelog thread
 upon first access
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alex Zhuravlev <bzzz@whamcloud.com>

thus leaving the caller a chance to set CHANGELOG_FLAG_FOLLOW,
otherwise the thread (started from open()) can reach the end
of the changelog and exit early.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14663
Lustre-commit: 72a08ea547dceb54 ("LU-14663 mdc: start changelog thread upon first access")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43513
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c | 54 +++++++++++++++++++++++++++++--------------
 1 file changed, 37 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index 31c6c8a..d366720 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -363,6 +363,33 @@ static int chlg_load(void *args)
 	return rc;
 }
 
+static int chlg_start_thread(struct file *file)
+{
+	struct chlg_reader_state *crs = file->private_data;
+	struct task_struct *task;
+	int rc = 0;
+
+	if (likely(crs->crs_prod_task))
+		return 0;
+	if (unlikely(file->f_mode & FMODE_READ) == 0)
+		return 0;
+
+	mutex_lock(&crs->crs_lock);
+	if (!crs->crs_prod_task) {
+		task = kthread_run(chlg_load, crs, "chlg_load_thread");
+		if (IS_ERR(task)) {
+			rc = PTR_ERR(task);
+			CERROR("%s: cannot start changelog thread: rc = %d\n",
+			       crs->crs_ced->ced_name, rc);
+			goto out;
+		}
+		crs->crs_prod_task = task;
+	}
+out:
+	mutex_unlock(&crs->crs_lock);
+	return rc;
+}
+
 /**
  * Read handler, dequeues records from the chlg_reader_state if any.
  * No partial records are copied to userland so this function can return less
@@ -396,6 +423,10 @@ static ssize_t chlg_read(struct file *file, char __user *buff, size_t count,
 			return -EAGAIN;
 	}
 
+	rc = chlg_start_thread(file);
+	if (rc)
+		return rc;
+
 	rc = wait_event_interruptible(crs->crs_waitq_cons,
 			crs->crs_rec_count > 0 || crs->crs_eof || crs->crs_err);
 
@@ -601,8 +632,6 @@ static int chlg_open(struct inode *inode, struct file *file)
 {
 	struct chlg_reader_state *crs;
 	struct chlg_registered_dev *dev;
-	struct task_struct *task;
-	int rc;
 
 	dev = container_of(inode->i_cdev, struct chlg_registered_dev, ced_cdev);
 
@@ -620,24 +649,10 @@ static int chlg_open(struct inode *inode, struct file *file)
 	init_waitqueue_head(&crs->crs_waitq_prod);
 	init_waitqueue_head(&crs->crs_waitq_cons);
 
-	if (file->f_mode & FMODE_READ) {
-		task = kthread_run(chlg_load, crs, "chlg_load_thread");
-		if (IS_ERR(task)) {
-			rc = PTR_ERR(task);
-			CERROR("%s: cannot start changelog thread: rc = %d\n",
-			       dev->ced_name, rc);
-			goto err_crs;
-		}
-		crs->crs_prod_task = task;
-	}
+	crs->crs_prod_task = NULL;
 
 	file->private_data = crs;
 	return 0;
-
-err_crs:
-	kref_put(&dev->ced_refs, chlg_dev_clear);
-	kfree(crs);
-	return rc;
 }
 
 /**
@@ -679,6 +694,11 @@ static unsigned int chlg_poll(struct file *file, poll_table *wait)
 {
 	struct chlg_reader_state *crs = file->private_data;
 	unsigned int mask = 0;
+	int rc;
+
+	rc = chlg_start_thread(file);
+	if (rc)
+		return rc;
 
 	mutex_lock(&crs->crs_lock);
 	poll_wait(file, &crs->crs_waitq_cons, wait);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
