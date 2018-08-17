From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:34 -0400
Subject: [lustre-devel] [PATCH 31/38] lustre: osc: fixup kstrto* for sysfs
 handling
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Some of the osc sysfs files only allow 1 or 0 which was
retrieved with kstrtoul(). A much better fit would be to
use kstrtobool(). This adds 'Y' or 'N' as valid options
as well. Instead of using kstrtoull() for everything with
additional range checking we can change to a different
kstrtoxxx() so the range checking can be removed.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9325
Reviewed-on: https://review.whamcloud.com/30539
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c | 43 ++++++++++++---------------
 1 file changed, 19 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 4ed289b..3c31e98 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -55,20 +55,18 @@ static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
+	bool val;
 	int rc;
-	unsigned long val;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtobool(buffer, &val);
 	if (rc)
 		return rc;
-	if (val > 1)
-		return -ERANGE;
 
 	/* opposite senses */
 	if (dev->u.cli.cl_import->imp_deactive == val)
 		rc = ptlrpc_set_import_active(dev->u.cli.cl_import, val);
 	else
-		CDEBUG(D_CONFIG, "activate %ld: ignoring repeat request\n",
+		CDEBUG(D_CONFIG, "activate %u: ignoring repeat request\n",
 		       val);
 
 	return count;
@@ -94,15 +92,15 @@ static ssize_t max_rpcs_in_flight_store(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
-	int rc;
-	unsigned long val;
 	int adding, added, req_count;
+	unsigned int val;
+	int rc;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtouint(buffer, 10, &val);
 	if (rc)
 		return rc;
 
-	if (val < 1 || val > OSC_MAX_RIF_MAX)
+	if (val == 0 || val > OSC_MAX_RIF_MAX)
 		return -ERANGE;
 
 	adding = val - cli->cl_max_rpcs_in_flight;
@@ -334,14 +332,14 @@ static ssize_t grant_shrink_interval_store(struct kobject *kobj,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
+	unsigned int val;
 	int rc;
-	unsigned long val;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtouint(buffer, 10, &val);
 	if (rc)
 		return rc;
 
-	if (val <= 0)
+	if (val == 0)
 		return -ERANGE;
 
 	obd->u.cli.cl_grant_shrink_interval = val;
@@ -367,14 +365,14 @@ static ssize_t checksums_store(struct kobject *kobj,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
+	bool val;
 	int rc;
-	unsigned long val;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtobool(buffer, &val);
 	if (rc)
 		return rc;
 
-	obd->u.cli.cl_checksum = (val ? 1 : 0);
+	obd->u.cli.cl_checksum = val;
 
 	return count;
 }
@@ -454,10 +452,10 @@ static ssize_t resend_count_store(struct kobject *kobj,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
+	unsigned int val;
 	int rc;
-	unsigned long val;
 
-	rc = kstrtoul(buffer, 10, &val);
+	rc = kstrtouint(buffer, 10, &val);
 	if (rc)
 		return rc;
 
@@ -486,16 +484,13 @@ static ssize_t contention_seconds_store(struct kobject *kobj,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct osc_device *od  = obd2osc_dev(obd);
+	unsigned int val;
 	int rc;
-	int val;
 
-	rc = kstrtoint(buffer, 10, &val);
+	rc = kstrtouint(buffer, 10, &val);
 	if (rc)
 		return rc;
 
-	if (val < 0)
-		return -EINVAL;
-
 	od->od_contention_time = val;
 
 	return count;
@@ -521,10 +516,10 @@ static ssize_t lockless_truncate_store(struct kobject *kobj,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct osc_device *od  = obd2osc_dev(obd);
+	bool val;
 	int rc;
-	unsigned int val;
 
-	rc = kstrtouint(buffer, 10, &val);
+	rc = kstrtobool(buffer, &val);
 	if (rc)
 		return rc;
 
-- 
1.8.3.1
