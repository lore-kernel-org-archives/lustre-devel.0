From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:10 -0500
Subject: [lustre-devel] [PATCH 42/60] staging: lustre: ptlrpc: allow
	blocking asts to be delayed
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-43-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vladimir Saveliev <vladimir.saveliev@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Vladimir Saveliev <vladimir.saveliev@seagate.com>

ptlrpc_import_delay_req() refuses to delay blocking asts when import
is not in LUSTRE_IMP_FULL yet. That leads to client eviction assuming
that it failed to respond.

Allow delays for blocking asts being resent.

Signed-off-by: Vladimir Saveliev <vladimir.saveliev@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8351
Seagate-bug-id: MRP-3500
Reviewed-on: https://review.whamcloud.com/21065
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c  | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 3c18ab6..332b360 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1160,7 +1160,7 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 		if (atomic_read(&imp->imp_inval_count) != 0) {
 			DEBUG_REQ(D_ERROR, req, "invalidate in flight");
 			*status = -EIO;
-		} else if (imp->imp_dlm_fake || req->rq_no_delay) {
+		} else if (req->rq_no_delay) {
 			*status = -EWOULDBLOCK;
 		} else if (req->rq_allow_replay &&
 			  (imp->imp_state == LUSTRE_IMP_REPLAY ||
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index c004490..c03e113 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -221,6 +221,7 @@ int ptlrpc_resend(struct obd_import *imp)
 	}
 	spin_unlock(&imp->imp_lock);
 
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_ENQUEUE_OLD_EXPORT, 2);
 	return 0;
 }
 
-- 
1.8.3.1
