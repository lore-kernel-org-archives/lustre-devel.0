From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:10 -0400
Subject: [lustre-devel] [PATCH 111/151] lustre: obd: remove s2dhms time
 function
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-112-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre created the s2dhms function to report a time
lapse in a days:hour:minute:seconds format. This is
over kill so remove s2dhms and just report the number
of seconds that has lapse.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Lustre-commit: 5ed38cca120f ("LU-9019 obd: remove s2dhms time function")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/23269
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h  | 19 -------------------
 fs/lustre/obdclass/lprocfs_status.c | 19 ++++++++-----------
 fs/lustre/ptlrpc/lproc_ptlrpc.c     |  8 +++-----
 3 files changed, 11 insertions(+), 35 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 10d541f..c3644f9 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -348,25 +348,6 @@ enum {
 struct obd_device;
 struct obd_histogram;
 
-/* Days / hours / mins / seconds format */
-struct dhms {
-	int d, h, m, s;
-};
-
-static inline void s2dhms(struct dhms *ts, time64_t secs64)
-{
-	unsigned int secs;
-
-	ts->d = div_u64_rem(secs64, 86400, &secs);
-	ts->h = secs / 3600;
-	secs = secs % 3600;
-	ts->m = secs / 60;
-	ts->s = secs % 60;
-}
-
-#define DHMS_FMT "%dd%dh%02dm%02ds"
-#define DHMS_VARS(x) (x)->d, (x)->h, (x)->m, (x)->s
-
 #define JOBSTATS_JOBID_VAR_MAX_LEN	20
 #define JOBSTATS_DISABLE		"disable"
 #define JOBSTATS_PROCNAME_UID		"procname_uid"
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 135926e..0e7fc70 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -943,7 +943,6 @@ int lprocfs_rd_timeouts(struct seq_file *m, void *data)
 	struct obd_import *imp;
 	unsigned int cur, worst;
 	time64_t now, worstt;
-	struct dhms ts;
 	int i, rc;
 
 	LASSERT(obd);
@@ -956,16 +955,15 @@ int lprocfs_rd_timeouts(struct seq_file *m, void *data)
 	now = ktime_get_real_seconds();
 
 	/* Some network health info for kicks */
-	s2dhms(&ts, now - imp->imp_last_reply_time);
-	seq_printf(m, "%-10s : %lld, " DHMS_FMT " ago\n",
-		   "last reply", (s64)imp->imp_last_reply_time, DHMS_VARS(&ts));
+	seq_printf(m, "%-10s : %lld, %llds ago\n",
+		   "last reply", (s64)imp->imp_last_reply_time,
+		   (s64)(now - imp->imp_last_reply_time));
 
 	cur = at_get(&imp->imp_at.iat_net_latency);
 	worst = imp->imp_at.iat_net_latency.at_worst_ever;
 	worstt = imp->imp_at.iat_net_latency.at_worst_time;
-	s2dhms(&ts, now - worstt);
-	seq_printf(m, "%-10s : cur %3u  worst %3u (at %lld, " DHMS_FMT " ago) ",
-		   "network", cur, worst, (s64)worstt, DHMS_VARS(&ts));
+	seq_printf(m, "%-10s : cur %3u  worst %3u (at %lld, %llds ago) ",
+		   "network", cur, worst, (s64)worstt, (s64)(now - worstt));
 	lprocfs_at_hist_helper(m, &imp->imp_at.iat_net_latency);
 
 	for (i = 0; i < IMP_AT_MAX_PORTALS; i++) {
@@ -974,10 +972,9 @@ int lprocfs_rd_timeouts(struct seq_file *m, void *data)
 		cur = at_get(&imp->imp_at.iat_service_estimate[i]);
 		worst = imp->imp_at.iat_service_estimate[i].at_worst_ever;
 		worstt = imp->imp_at.iat_service_estimate[i].at_worst_time;
-		s2dhms(&ts, now - worstt);
-		seq_printf(m, "portal %-2d  : cur %3u  worst %3u (at %lld, "
-			   DHMS_FMT " ago) ", imp->imp_at.iat_portal[i],
-			   cur, worst, (s64)worstt, DHMS_VARS(&ts));
+		seq_printf(m, "portal %-2d  : cur %3u  worst %3u (at %lld, %llds ago) ",
+			   imp->imp_at.iat_portal[i], cur, worst, (s64)worstt,
+			   (s64)(now - worstt));
 		lprocfs_at_hist_helper(m, &imp->imp_at.iat_service_estimate[i]);
 	}
 
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 2239680..3dc99d4 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1009,7 +1009,6 @@ static int ptlrpc_lprocfs_timeouts_seq_show(struct seq_file *m, void *n)
 {
 	struct ptlrpc_service *svc = m->private;
 	struct ptlrpc_service_part *svcpt;
-	struct dhms ts;
 	time64_t worstt;
 	unsigned int cur;
 	unsigned int worst;
@@ -1025,11 +1024,10 @@ static int ptlrpc_lprocfs_timeouts_seq_show(struct seq_file *m, void *n)
 		cur = at_get(&svcpt->scp_at_estimate);
 		worst = svcpt->scp_at_estimate.at_worst_ever;
 		worstt = svcpt->scp_at_estimate.at_worst_time;
-		s2dhms(&ts, ktime_get_real_seconds() - worstt);
 
-		seq_printf(m, "%10s : cur %3u  worst %3u (at %lld, "
-			   DHMS_FMT " ago) ", "service",
-			   cur, worst, (s64)worstt, DHMS_VARS(&ts));
+		seq_printf(m, "%10s : cur %3u  worst %3u (at %lld, %llds ago) ",
+			   "service", cur, worst, (s64)worstt,
+			   (s64)(ktime_get_real_seconds() - worstt));
 
 		lprocfs_at_hist_helper(m, &svcpt->scp_at_estimate);
 	}
-- 
1.8.3.1
