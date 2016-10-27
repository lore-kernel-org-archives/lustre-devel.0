From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:12:02 -0400
Subject: [lustre-devel] [PATCH 28/29] staging: lustre: ptlrpc:
	imp_peer_committed_transno should increase
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alex Zhuravlev <alexey.zhuravlev@intel.com>, James Simmons <jsimmons@infradead.org>

From: Alex Zhuravlev <alexey.zhuravlev@intel.com>

imp_peer_committed_transno should not decrease as this can
confuse the users if imp_peer_committed_transno is used to
check commit status.

Signed-off-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7079
Reviewed-on: http://review.whamcloud.com/16161
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index cc4b129..7cbfb4c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1242,6 +1242,7 @@ static int after_reply(struct ptlrpc_request *req)
 	int rc;
 	struct timespec64 work_start;
 	long timediff;
+	u64 committed;
 
 	LASSERT(obd);
 	/* repbuf must be unlinked */
@@ -1400,10 +1401,9 @@ static int after_reply(struct ptlrpc_request *req)
 		}
 
 		/* Replay-enabled imports return commit-status information. */
-		if (lustre_msg_get_last_committed(req->rq_repmsg)) {
-			imp->imp_peer_committed_transno =
-				lustre_msg_get_last_committed(req->rq_repmsg);
-		}
+		committed = lustre_msg_get_last_committed(req->rq_repmsg);
+		if (likely(committed > imp->imp_peer_committed_transno))
+			imp->imp_peer_committed_transno = committed;
 
 		ptlrpc_free_committed(imp);
 
-- 
1.7.1
