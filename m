From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:15 -0400
Subject: [lustre-devel] [PATCH 19/41] staging: lustre: ptlrpc: dont take
	unwrap in req_waittime calculation
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sebastien.buisson@bull.net>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sebastien.buisson@bull.net>

Do not take unwrap time in req_waittime calculation on client part
as decryption is not related to request service time.

Signed-off-by: Sebastien Buisson <sebastien.buisson@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6356
Reviewed-on: http://review.whamcloud.com/14404
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 8c51d51..fa4d3c9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1206,6 +1206,10 @@ static int after_reply(struct ptlrpc_request *req)
 		return 0;
 	}
 
+	ktime_get_real_ts64(&work_start);
+	timediff = (work_start.tv_sec - req->rq_sent_tv.tv_sec) * USEC_PER_SEC +
+		   (work_start.tv_nsec - req->rq_sent_tv.tv_nsec) /
+								 NSEC_PER_USEC;
 	/*
 	 * NB Until this point, the whole of the incoming message,
 	 * including buflens, status etc is in the sender's byte order.
@@ -1258,10 +1262,6 @@ static int after_reply(struct ptlrpc_request *req)
 		return 0;
 	}
 
-	ktime_get_real_ts64(&work_start);
-	timediff = (work_start.tv_sec - req->rq_sent_tv.tv_sec) * USEC_PER_SEC +
-		   (work_start.tv_nsec - req->rq_sent_tv.tv_nsec) /
-								 NSEC_PER_USEC;
 	if (obd->obd_svc_stats) {
 		lprocfs_counter_add(obd->obd_svc_stats, PTLRPC_REQWAIT_CNTR,
 				    timediff);
-- 
1.7.1
