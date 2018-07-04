From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 02/11] lustre: osc: don't take spinlock to
 read a "long"
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943061.30111.10303681433910918365.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reading a long is always atomic, so there is no
need to take a spinlock - the value read will always
be internally consistent and in none of these places
is consistency with another value relevant.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c |   36 +++----------------------
 1 file changed, 5 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 81adf548f426..54a303e4e046 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -138,10 +138,7 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj,
 	long val;
 	int mult;
 
-	spin_lock(&cli->cl_loi_list_lock);
 	val = cli->cl_dirty_max_pages;
-	spin_unlock(&cli->cl_loi_list_lock);
-
 	mult = 1 << (20 - PAGE_SHIFT);
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, val, mult);
 }
@@ -252,13 +249,9 @@ static ssize_t cur_dirty_bytes_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kobj);
 	struct client_obd *cli = &dev->u.cli;
-	int len;
 
-	spin_lock(&cli->cl_loi_list_lock);
-	len = sprintf(buf, "%lu\n", cli->cl_dirty_pages << PAGE_SHIFT);
-	spin_unlock(&cli->cl_loi_list_lock);
+	return sprintf(buf, "%lu\n", cli->cl_dirty_pages << PAGE_SHIFT);
 
-	return len;
 }
 LUSTRE_RO_ATTR(cur_dirty_bytes);
 
@@ -269,13 +262,8 @@ static ssize_t cur_grant_bytes_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kobj);
 	struct client_obd *cli = &dev->u.cli;
-	int len;
 
-	spin_lock(&cli->cl_loi_list_lock);
-	len = sprintf(buf, "%lu\n", cli->cl_avail_grant);
-	spin_unlock(&cli->cl_loi_list_lock);
-
-	return len;
+	return sprintf(buf, "%lu\n", cli->cl_avail_grant);
 }
 
 static ssize_t cur_grant_bytes_store(struct kobject *kobj,
@@ -294,12 +282,8 @@ static ssize_t cur_grant_bytes_store(struct kobject *kobj,
 		return rc;
 
 	/* this is only for shrinking grant */
-	spin_lock(&cli->cl_loi_list_lock);
-	if (val >= cli->cl_avail_grant) {
-		spin_unlock(&cli->cl_loi_list_lock);
+	if (val >= cli->cl_avail_grant)
 		return -EINVAL;
-	}
-	spin_unlock(&cli->cl_loi_list_lock);
 
 	if (cli->cl_import->imp_state == LUSTRE_IMP_FULL)
 		rc = osc_shrink_grant_to_target(cli, val);
@@ -316,13 +300,8 @@ static ssize_t cur_lost_grant_bytes_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kobj);
 	struct client_obd *cli = &dev->u.cli;
-	int len;
-
-	spin_lock(&cli->cl_loi_list_lock);
-	len = sprintf(buf, "%lu\n", cli->cl_lost_grant);
-	spin_unlock(&cli->cl_loi_list_lock);
 
-	return len;
+	return sprintf(buf, "%lu\n", cli->cl_lost_grant);
 }
 LUSTRE_RO_ATTR(cur_lost_grant_bytes);
 
@@ -333,13 +312,8 @@ static ssize_t cur_dirty_grant_bytes_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kobj);
 	struct client_obd *cli = &dev->u.cli;
-	int len;
 
-	spin_lock(&cli->cl_loi_list_lock);
-	len = sprintf(buf, "%lu\n", cli->cl_dirty_grant);
-	spin_unlock(&cli->cl_loi_list_lock);
-
-	return len;
+	return sprintf(buf, "%lu\n", cli->cl_dirty_grant);
 }
 LUSTRE_RO_ATTR(cur_dirty_grant_bytes);
 
