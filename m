From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:49:54 -0500
Subject: [lustre-devel] [PATCH 06/25] staging/lustre: Convert
	ptlrpc_at_check_timed to void
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

The only caller was not looking at the return value,
and liblustre, that cared about it is not part of the kernel client.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/service.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 6f71ecc..89039bf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1137,7 +1137,7 @@ out_free:
 /* Send early replies to everybody expiring within at_early_margin
  * asking for at_extra time
  */
-static int ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
+static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 {
 	struct ptlrpc_at_array *array = &svcpt->scp_at_array;
 	struct ptlrpc_request *rq, *n;
@@ -1151,14 +1151,14 @@ static int ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	spin_lock(&svcpt->scp_at_lock);
 	if (svcpt->scp_at_check == 0) {
 		spin_unlock(&svcpt->scp_at_lock);
-		return 0;
+		return;
 	}
 	delay = cfs_time_sub(cfs_time_current(), svcpt->scp_at_checktime);
 	svcpt->scp_at_check = 0;
 
 	if (array->paa_count == 0) {
 		spin_unlock(&svcpt->scp_at_lock);
-		return 0;
+		return;
 	}
 
 	/* The timer went off, but maybe the nearest rpc already completed. */
@@ -1167,7 +1167,7 @@ static int ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 		/* We've still got plenty of time.  Reset the timer. */
 		ptlrpc_at_set_timer(svcpt);
 		spin_unlock(&svcpt->scp_at_lock);
-		return 0;
+		return;
 	}
 
 	/* We're close to a timeout, and we don't know how much longer the
@@ -1237,8 +1237,6 @@ static int ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 
 		ptlrpc_server_drop_request(rq);
 	}
-
-	return 1; /* return "did_something" for liblustre */
 }
 
 /**
-- 
2.1.0
