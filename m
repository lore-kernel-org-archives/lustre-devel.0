From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:12:00 -0400
Subject: [lustre-devel] [PATCH 26/29] staging: lustre: ptlrpc: do not switch
	out-of-date context
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sebastien.buisson@bull.net>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sebastien.buisson@bull.net>

When trying to replace a dead sec context with a new one, we must
ensure the new context is already up-to-date.
If it is not the case, just return from sptlrpc_req_replace_dead_ctx()
and come later when the new context has been updated.

Signed-off-by: Sebastien Buisson <sebastien.buisson@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6536
Reviewed-on: http://review.whamcloud.com/15708
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/sec.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 12f02ed..e860df7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -515,6 +515,13 @@ static int sptlrpc_req_replace_dead_ctx(struct ptlrpc_request *req)
 
 		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(msecs_to_jiffies(MSEC_PER_SEC));
+	} else if (unlikely(!test_bit(PTLRPC_CTX_UPTODATE_BIT, &newctx->cc_flags))) {
+		/*
+		 * new ctx not up to date yet
+		 */
+		CDEBUG(D_SEC,
+		       "ctx (%p, fl %lx) doesn't switch, not up to date yet\n",
+		       newctx, newctx->cc_flags);
 	} else {
 		/*
 		 * it's possible newctx == oldctx if we're switching
-- 
1.7.1
