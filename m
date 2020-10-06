From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:21 -0400
Subject: [lustre-devel] [PATCH 42/42] lustre: obdclass: fixes and
 improvements for jobid.
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-43-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

1/ When lustre_get_jobid() uses jobid_current(), it should
   copy into tmp_jobid, not into jobid.
2/ A '%j' in jobname should use jobid_current()
3/ If there is a %j in jobid_name, then it should
   be used even if  jobid_var is 'session'.

Fixes: 2646ff0b3509 ("lustre: obdclass: allow per-session jobids.")
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/lustre/obdclass/jobid.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/obdclass/jobid.c b/fs/lustre/obdclass/jobid.c
index 98b3f39..3ee9d40 100644
--- a/fs/lustre/obdclass/jobid.c
+++ b/fs/lustre/obdclass/jobid.c
@@ -206,7 +206,7 @@ static void jobid_prune_expedite(void)
  *   %e = executable
  *   %g = gid
  *   %h = hostname
- *   %j = jobid from environment
+ *   %j = per-session
  *   %p = pid
  *   %u = uid
  *
@@ -247,10 +247,9 @@ static int jobid_interpret_string(const char *jobfmt, char *jobid,
 			l = snprintf(jobid, joblen, "%s",
 				     init_utsname()->nodename);
 			break;
-		case 'j': /* jobid requested by process
-			   * - currently not supported
-			   */
-			l = snprintf(jobid, joblen, "%s", "jobid");
+		case 'j': /* jobid requested by process */
+			l = snprintf(jobid, joblen, "%s",
+				     jobid_current() ?: "jobid");
 			break;
 		case 'p': /* process ID */
 			l = snprintf(jobid, joblen, "%u", current->pid);
@@ -306,7 +305,8 @@ int lustre_get_jobid(char *jobid, size_t joblen)
 		goto out_cache_jobid;
 
 	/* Whole node dedicated to single job */
-	if (strcmp(obd_jobid_var, JOBSTATS_NODELOCAL) == 0) {
+	if (strcmp(obd_jobid_var, JOBSTATS_NODELOCAL) == 0 ||
+	    strnstr(obd_jobid_name, "%j", LUSTRE_JOBID_SIZE)) {
 		int rc2 = jobid_interpret_string(obd_jobid_name,
 						 tmp_jobid, joblen);
 		if (!rc2)
@@ -327,7 +327,7 @@ int lustre_get_jobid(char *jobid, size_t joblen)
 		rcu_read_lock();
 		jid = jobid_current();
 		if (jid)
-			strlcpy(jobid, jid, sizeof(jobid));
+			strlcpy(tmp_jobid, jid, sizeof(tmp_jobid));
 		rcu_read_unlock();
 		goto out_cache_jobid;
 	}
-- 
1.8.3.1
