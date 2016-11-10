From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:41 -0500
Subject: [lustre-devel] [PATCH 11/35] staging: lustre: ptlrpc: race at req
	processing
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander_boyko@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Boyko <alexander_boyko@xyratex.com>

Fix: 5c689e689baa ("staging/lustre/ptlrpc: race at req processing")
decreased the race window, but does not remove it. Disable rq_resend
right after MSG_REPLAY flag set. Import lock protects two threads
from race between set/clear MSG_REPLAY and rq_resend flags.

Signed-off-by: Alexander Boyko <alexander_boyko@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5554
Xyratex-bug-id: MRP-1888
Reviewed-on: http://review.whamcloud.com/10735
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index b940e24..d2f4cd5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2690,6 +2690,10 @@ void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 
 	lustre_msg_add_flags(req->rq_reqmsg, MSG_REPLAY);
 
+	spin_lock(&req->rq_lock);
+	req->rq_resend = 0;
+	spin_unlock(&req->rq_lock);
+
 	LASSERT(imp->imp_replayable);
 	/* Balanced in ptlrpc_free_committed, usually. */
 	ptlrpc_request_addref(req);
-- 
1.7.1
