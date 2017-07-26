From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:31 -0400
Subject: [lustre-devel] [PATCH 15/20] staging: lustre: ptlrpc: print times
	in microseconds
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bob Glosman <bob.glossman@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bob Glosman <bob.glossman@intel.com>

report times and time diffs in seconds.microseconds instead of seconds

Signed-off-by: Bob Glosman <bob.glossman@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7733
Reviewed-on: http://review.whamcloud.com/18335
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Minh Diep <minh.diep@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index f874781..c429613 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -905,11 +905,18 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 	rc = ptlrpc_lprocfs_svc_req_history_seek(svcpt, srhi, srhi->srhi_seq);
 
 	if (rc == 0) {
+		struct timespec64 arrival, sent, arrivaldiff;
 		char nidstr[LNET_NIDSTR_SIZE];
 
 		req = srhi->srhi_req;
 
 		libcfs_nid2str_r(req->rq_self, nidstr, sizeof(nidstr));
+		arrival.tv_sec = req->rq_arrival_time.tv_sec;
+		arrival.tv_nsec = req->rq_arrival_time.tv_nsec;
+		sent.tv_sec = req->rq_sent;
+		sent.tv_nsec = 0;
+		arrivaldiff = timespec64_sub(sent, arrival);
+
 		/* Print common req fields.
 		 * CAVEAT EMPTOR: we're racing with the service handler
 		 * here.  The request could contain any old crap, so you
@@ -917,13 +924,15 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 		 * parser. Currently I only print stuff here I know is OK
 		 * to look at coz it was set up in request_in_callback()!!!
 		 */
-		seq_printf(s, "%lld:%s:%s:x%llu:%d:%s:%lld:%lds(%+lds) ",
+		seq_printf(s, "%lld:%s:%s:x%llu:%d:%s:%lld.%06lld:%lld.%06llds(%+lld.0s) ",
 			   req->rq_history_seq, nidstr,
 			   libcfs_id2str(req->rq_peer), req->rq_xid,
 			   req->rq_reqlen, ptlrpc_rqphase2str(req),
 			   (s64)req->rq_arrival_time.tv_sec,
-			   (long)(req->rq_sent - req->rq_arrival_time.tv_sec),
-			   (long)(req->rq_sent - req->rq_deadline));
+			   (s64)req->rq_arrival_time.tv_nsec / NSEC_PER_USEC,
+			   (s64)arrivaldiff.tv_sec,
+			   (s64)(arrivaldiff.tv_nsec / NSEC_PER_USEC),
+			   (s64)(req->rq_sent - req->rq_deadline));
 		if (!svc->srv_ops.so_req_printer)
 			seq_putc(s, '\n');
 		else
-- 
1.8.3.1
