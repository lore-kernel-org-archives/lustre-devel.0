From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:15 -0400
Subject: [lustre-devel] [PATCH 36/42] lustre: don't take spinlock to read a
 'long'.
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Reading a 'long' (or unsigned long) is always an atomic operation.
There is never a need to take a spinlock to just read a single 'long'.

There are several procfs/debugfs/sysfs handlers which needlessly take
a spinlock for this purpose.

This patch:
 - removes the taking of the spinlock
 - changes the printf to scnprintf() as appropriate
 - directly returns the value returned by scnprintf rather than
   storing it in a variable
 - accesses the 'long' as an arg to the scnprintf(), rather than
   introducing a variabe to hold it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 023a9e4cde5498 ("LU-6142 lustre: don't take spinlock to read a 'long'.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39743
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lproc_llite.c | 24 ++++++------------------
 fs/lustre/mdc/lproc_mdc.c     |  7 +------
 fs/lustre/osc/lproc_osc.c     | 23 ++++++++---------------
 3 files changed, 15 insertions(+), 39 deletions(-)

diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 54db7eb..9b1c392 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -326,13 +326,9 @@ static ssize_t max_read_ahead_mb_show(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
-	unsigned long ra_max_mb;
 
-	spin_lock(&sbi->ll_lock);
-	ra_max_mb = PAGES_TO_MiB(sbi->ll_ra_info.ra_max_pages);
-	spin_unlock(&sbi->ll_lock);
-
-	return scnprintf(buf, PAGE_SIZE, "%lu\n", ra_max_mb);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n",
+			 PAGES_TO_MiB(sbi->ll_ra_info.ra_max_pages));
 }
 
 static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
@@ -374,13 +370,9 @@ static ssize_t max_read_ahead_per_file_mb_show(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
-	unsigned long ra_max_file_mb;
 
-	spin_lock(&sbi->ll_lock);
-	ra_max_file_mb = PAGES_TO_MiB(sbi->ll_ra_info.ra_max_pages_per_file);
-	spin_unlock(&sbi->ll_lock);
-
-	return scnprintf(buf, PAGE_SIZE, "%lu\n", ra_max_file_mb);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n",
+			 PAGES_TO_MiB(sbi->ll_ra_info.ra_max_pages_per_file));
 }
 
 static ssize_t max_read_ahead_per_file_mb_store(struct kobject *kobj,
@@ -419,13 +411,9 @@ static ssize_t max_read_ahead_whole_mb_show(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
-	unsigned long ra_max_whole_mb;
-
-	spin_lock(&sbi->ll_lock);
-	ra_max_whole_mb = PAGES_TO_MiB(sbi->ll_ra_info.ra_max_read_ahead_whole_pages);
-	spin_unlock(&sbi->ll_lock);
 
-	return scnprintf(buf, PAGE_SIZE, "%lu\n", ra_max_whole_mb);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n",
+			 PAGES_TO_MiB(sbi->ll_ra_info.ra_max_read_ahead_whole_pages));
 }
 
 static ssize_t max_read_ahead_whole_mb_store(struct kobject *kobj,
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index d7506ea..662be42 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -44,13 +44,8 @@ static int mdc_max_dirty_mb_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *obd = m->private;
 	struct client_obd *cli = &obd->u.cli;
-	unsigned long val;
 
-	spin_lock(&cli->cl_loi_list_lock);
-	val = PAGES_TO_MiB(cli->cl_dirty_max_pages);
-	spin_unlock(&cli->cl_loi_list_lock);
-
-	seq_printf(m, "%lu\n", val);
+	seq_printf(m, "%lu\n", PAGES_TO_MiB(cli->cl_dirty_max_pages));
 	return 0;
 }
 
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 14cbe54..7ea9530 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -87,7 +87,7 @@ static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
 					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
 
-	return sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
+	return scnprintf(buf, PAGE_SIZE, "%u\n", cli->cl_max_rpcs_in_flight);
 }
 
 static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
@@ -139,13 +139,9 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
-	unsigned long val;
 
-	spin_lock(&cli->cl_loi_list_lock);
-	val = PAGES_TO_MiB(cli->cl_dirty_max_pages);
-	spin_unlock(&cli->cl_loi_list_lock);
-
-	return scnprintf(buf, PAGE_SIZE, "%lu\n", val);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n",
+			 PAGES_TO_MiB(cli->cl_dirty_max_pages));
 }
 
 static ssize_t max_dirty_mb_store(struct kobject *kobj,
@@ -252,7 +248,8 @@ static ssize_t cur_dirty_bytes_show(struct kobject *kobj,
 					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
 
-	return sprintf(buf, "%lu\n", cli->cl_dirty_pages << PAGE_SHIFT);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n",
+			 cli->cl_dirty_pages << PAGE_SHIFT);
 }
 LUSTRE_RO_ATTR(cur_dirty_bytes);
 
@@ -264,7 +261,7 @@ static ssize_t cur_grant_bytes_show(struct kobject *kobj,
 					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
 
-	return sprintf(buf, "%lu\n", cli->cl_avail_grant);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n", cli->cl_avail_grant);
 }
 
 static ssize_t cur_grant_bytes_store(struct kobject *kobj,
@@ -284,12 +281,8 @@ static ssize_t cur_grant_bytes_store(struct kobject *kobj,
 		return rc;
 
 	/* this is only for shrinking grant */
-	spin_lock(&cli->cl_loi_list_lock);
-	if (val >= cli->cl_avail_grant) {
-		spin_unlock(&cli->cl_loi_list_lock);
+	if (val >= cli->cl_avail_grant)
 		return -EINVAL;
-	}
-	spin_unlock(&cli->cl_loi_list_lock);
 
 	with_imp_locked(obd, imp, rc)
 		if (imp->imp_state == LUSTRE_IMP_FULL)
@@ -307,7 +300,7 @@ static ssize_t cur_lost_grant_bytes_show(struct kobject *kobj,
 					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
 
-	return sprintf(buf, "%lu\n", cli->cl_lost_grant);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n", cli->cl_lost_grant);
 }
 LUSTRE_RO_ATTR(cur_lost_grant_bytes);
 
-- 
1.8.3.1
