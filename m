From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:51:06 -0400
Subject: [lustre-devel] [PATCH v2 24/29] lustre: obd_sysfs: error-check
 value stored in jobid_var
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

The jobid_var sysfs attribute only has 3 meaningful values.
Other values cause lustre_get_jobid() to return an error
which is uniformly ignored.

To improve usability and resilience, check that the value
written is acceptable before storing it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/obdclass/obd_sysfs.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index e9e0bcf..d5cf5d0 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -216,16 +216,25 @@ static ssize_t jobid_var_store(struct kobject *kobj, struct attribute *attr,
 			       const char *buffer,
 			       size_t count)
 {
+	static const char * const valid[] = {
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
-- 
1.8.3.1
