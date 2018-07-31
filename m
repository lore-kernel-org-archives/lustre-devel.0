From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:25:58 -0400
Subject: [lustre-devel] [PATCH 06/31] lustre: llite: reduce jobstats race
 window
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

In the current code, lli_jobid is set to zero on every call
to lustre_get_jobid.  This causes problems, because it's
used asynchronously to set the job id in RPCs, and some
RPCs will falsely get no jobid set.  (For small IO sizes,
this can be up to 60% of RPCs.)

It would be very expensive to put hard synchronization
between this and every outbound RPC, and it's OK to very
rarely get an RPC without correct job stats info.

This patch only updates the lli_jobid when the job id has
changed, which leaves only a very small window for reading
an inconsistent job id.

Signed-off-by: Patrick Farrell <paf@cray.com>
WC-id: https://jira.whamcloud.com/browse/LU-8926
Reviewed-on: https://review.whamcloud.com/24253
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  1 +
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 20 ++++++++++++++------
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index c0861b9..72b118a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -894,6 +894,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		lli->lli_async_rc = 0;
 	}
 	mutex_init(&lli->lli_layout_mutex);
+	memset(lli->lli_jobid, 0, LUSTRE_JOBID_SIZE);
 }
 
 int ll_fill_super(struct super_block *sb)
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index cdaf729..87327ef 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -95,26 +95,34 @@
  */
 int lustre_get_jobid(char *jobid)
 {
-	memset(jobid, 0, LUSTRE_JOBID_SIZE);
+	char tmp_jobid[LUSTRE_JOBID_SIZE] = { 0 };
+
 	/* Jobstats isn't enabled */
 	if (strcmp(obd_jobid_var, JOBSTATS_DISABLE) == 0)
-		return 0;
+		goto out_cache_jobid;
 
 	/* Use process name + fsuid as jobid */
 	if (strcmp(obd_jobid_var, JOBSTATS_PROCNAME_UID) == 0) {
-		snprintf(jobid, LUSTRE_JOBID_SIZE, "%s.%u",
+		snprintf(tmp_jobid, LUSTRE_JOBID_SIZE, "%s.%u",
 			 current->comm,
 			 from_kuid(&init_user_ns, current_fsuid()));
-		return 0;
+		goto out_cache_jobid;
 	}
 
 	/* Whole node dedicated to single job */
 	if (strcmp(obd_jobid_var, JOBSTATS_NODELOCAL) == 0) {
-		strcpy(jobid, obd_jobid_node);
-		return 0;
+		strcpy(tmp_jobid, obd_jobid_node);
+		goto out_cache_jobid;
 	}
 
 	return -ENOENT;
+
+out_cache_jobid:
+	/* Only replace the job ID if it changed. */
+	if (strcmp(jobid, tmp_jobid) != 0)
+		strcpy(jobid, tmp_jobid);
+
+	return 0;
 }
 EXPORT_SYMBOL(lustre_get_jobid);
 
-- 
1.8.3.1
