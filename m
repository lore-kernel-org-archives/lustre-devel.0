From: James Simmons <jsimmons@infradead.org>
Date: Sun, 19 Aug 2018 22:40:23 -0400
Subject: [lustre-devel] [PATCH v2 32/38] lustre: osc: restore
 cl_loi_list_lock
Message-ID: <1534732823-23115-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Access to struct client_obd should be protected with the spinlock
cl_loi_list_lock. This was dropped during the port to sysfs so
restore the proper locking.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog)
v1) Initial patch
v2) remove unneeded spin lock for max_rpcs_in_flight_show
 drivers/staging/lustre/lustre/osc/lproc_osc.c | 36 +++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 3c31e98..5fb7a16 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -136,7 +141,10 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj,
 	long val;
 	int mult;
 
+	spin_lock(&cli->cl_loi_list_lock);
 	val = cli->cl_dirty_max_pages;
+	spin_unlock(&cli->cl_loi_list_lock);
+
 	mult = 1 << (20 - PAGE_SHIFT);
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, val, mult);
 }
@@ -247,9 +255,13 @@ static ssize_t cur_dirty_bytes_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
+	ssize_t len;
 
-	return sprintf(buf, "%lu\n", cli->cl_dirty_pages << PAGE_SHIFT);
+	spin_lock(&cli->cl_loi_list_lock);
+	len = sprintf(buf, "%lu\n", cli->cl_dirty_pages << PAGE_SHIFT);
+	spin_unlock(&cli->cl_loi_list_lock);
 
+	return len;
 }
 LUSTRE_RO_ATTR(cur_dirty_bytes);
 
@@ -260,8 +272,13 @@ static ssize_t cur_grant_bytes_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
+	ssize_t len;
 
-	return sprintf(buf, "%lu\n", cli->cl_avail_grant);
+	spin_lock(&cli->cl_loi_list_lock);
+	len = sprintf(buf, "%lu\n", cli->cl_avail_grant);
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	return len;
 }
 
 static ssize_t cur_grant_bytes_store(struct kobject *kobj,
@@ -280,8 +297,12 @@ static ssize_t cur_grant_bytes_store(struct kobject *kobj,
 		return rc;
 
 	/* this is only for shrinking grant */
-	if (val >= cli->cl_avail_grant)
+	spin_lock(&cli->cl_loi_list_lock);
+	if (val >= cli->cl_avail_grant) {
+		spin_unlock(&cli->cl_loi_list_lock);
 		return -EINVAL;
+	}
+	spin_unlock(&cli->cl_loi_list_lock);
 
 	if (cli->cl_import->imp_state == LUSTRE_IMP_FULL)
 		rc = osc_shrink_grant_to_target(cli, val);
@@ -298,8 +319,13 @@ static ssize_t cur_lost_grant_bytes_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
+	ssize_t len;
 
-	return sprintf(buf, "%lu\n", cli->cl_lost_grant);
+	spin_lock(&cli->cl_loi_list_lock);
+	len = sprintf(buf, "%lu\n", cli->cl_lost_grant);
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	return len;
 }
 LUSTRE_RO_ATTR(cur_lost_grant_bytes);
 
-- 
1.8.3.1
