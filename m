From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:51 -0400
Subject: [lustre-devel] [PATCH 17/29] staging: lustre: ptlrpc: replay bulk
	request
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Even though the server might already got the bulk
replay request, but bulk transfer timeout, let's
replay the bulk request, i.e. treat such replay as
same as no replied replay request (See
ptlrpc_replay_interpret()).

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6924
Reviewed-on: http://review.whamcloud.com/15793
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index e4fbdd0..bda925e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2762,8 +2762,15 @@ static int ptlrpc_replay_interpret(const struct lu_env *env,
 
 	atomic_dec(&imp->imp_replay_inflight);
 
-	if (!ptlrpc_client_replied(req)) {
-		CERROR("request replay timed out, restarting recovery\n");
+	/*
+	 * Note: if it is bulk replay (MDS-MDS replay), then even if
+	 * server got the request, but bulk transfer timeout, let's
+	 * replay the bulk req again
+	 */
+	if (!ptlrpc_client_replied(req) ||
+	    (req->rq_bulk &&
+	     lustre_msg_get_status(req->rq_repmsg) == -ETIMEDOUT)) {
+		DEBUG_REQ(D_ERROR, req, "request replay timed out.\n");
 		rc = -ETIMEDOUT;
 		goto out;
 	}
-- 
1.7.1
