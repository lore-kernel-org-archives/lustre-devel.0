From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:38 +1100
Subject: [lustre-devel] [PATCH 19/28] lustre: obd_sysfs: error-check value
 stored in jobid_var
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109876.31333.9752731889345878238.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The jobid_var sysfs attribute only has 3 meaningful values.
Other values cause lustre_get_jobid() to return an error
which is uniformly ignored.

To improve usability and resilience, check that the value
written is acceptable before storing it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |   21 ++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
index e9e0bcf39d4e..1431ea02f144 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
@@ -216,16 +216,25 @@ static ssize_t jobid_var_store(struct kobject *kobj, struct attribute *attr,
 			       const char *buffer,
 			       size_t count)
 {
+	static char *valid[] = {
+		JOBSTATS_DISABLE,
+		JOBSTATS_PROCNAME_UID,
+		JOBSTATS_NODELOCAL,
+		NULL
+	};
+	int i;
+
 	if (!count || count > JOBSTATS_JOBID_VAR_MAX_LEN)
 		return -EINVAL;
 
-	memset(obd_jobid_var, 0, JOBSTATS_JOBID_VAR_MAX_LEN + 1);
-
-	memcpy(obd_jobid_var, buffer, count);
+	for (i = 0; valid[i]; i++)
+		if (sysfs_streq(buffer, valid[i]))
+			break;
+	if (!valid[i])
+		return -EINVAL;
 
-	/* Trim the trailing '\n' if any */
-	if (obd_jobid_var[count - 1] == '\n')
-		obd_jobid_var[count - 1] = 0;
+	memset(obd_jobid_var, 0, JOBSTATS_JOBID_VAR_MAX_LEN + 1);
+	strcpy(obd_jobid_var, valid[i]);
 
 	return count;
 }
