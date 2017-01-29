From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:46 -0500
Subject: [lustre-devel] [PATCH 18/60] staging: lustre: ptlrpc: skip lock if
	export failed
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander.boyko@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Boyko <alexander.boyko@seagate.com>

This patch resolves IO vs eviction race.
After eviction failed export stayed at stale list,
a client had IO processing and reconnected during it.
A client sent brw rpc with last lock cookie and new connection.
The lock with failed export was found and assert was happened.
 (ost_handler.c:1812:ost_prolong_lock_one())
  ASSERTION( lock->l_export == opd->opd_exp ) failed:

 1. Skip the lock at ldlm_handle2lock if lock export failed.
 2. Validation of lock for IO was added at hpreq_check(). The lock
    searching is based on granted interval tree. If server doesn`t
    have a valid lock, it reply to client with ESTALE.

Signed-off-by: Alexander Boyko <alexander.boyko@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7702
Seagate-bug-id: MRP-2787
Reviewed-on: http://review.whamcloud.com/18120
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Vitaly Fertman <vitaly.fertman@seagate.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c |  7 +++++++
 drivers/staging/lustre/lustre/ptlrpc/service.c | 21 ++++++++-------------
 2 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index afef5a2..5a94265 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -533,6 +533,13 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 	if (!lock)
 		return NULL;
 
+	if (lock->l_export && lock->l_export->exp_failed) {
+		CDEBUG(D_INFO, "lock export failed: lock %p, exp %p\n",
+		       lock, lock->l_export);
+		LDLM_LOCK_PUT(lock);
+		return NULL;
+	}
+
 	/* It's unlikely but possible that someone marked the lock as
 	 * destroyed after we did handle2object on it
 	 */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 70c7055..b8091c1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1264,20 +1264,15 @@ static int ptlrpc_server_hpreq_init(struct ptlrpc_service_part *svcpt,
 		 */
 		if (req->rq_ops->hpreq_check) {
 			rc = req->rq_ops->hpreq_check(req);
-			/**
-			 * XXX: Out of all current
-			 * ptlrpc_hpreq_ops::hpreq_check(), only
-			 * ldlm_cancel_hpreq_check() can return an error code;
-			 * other functions assert in similar places, which seems
-			 * odd. What also does not seem right is that handlers
-			 * for those RPCs do not assert on the same checks, but
-			 * rather handle the error cases. e.g. see
-			 * ost_rw_hpreq_check(), and ost_brw_read(),
-			 * ost_brw_write().
+			if (rc == -ESTALE) {
+				req->rq_status = rc;
+				ptlrpc_error(req);
+			}
+			/** can only return error,
+			 * 0 for normal request,
+			 *  or 1 for high priority request
 			 */
-			if (rc < 0)
-				return rc;
-			LASSERT(rc == 0 || rc == 1);
+			LASSERT(rc <= 1);
 		}
 
 		spin_lock_bh(&req->rq_export->exp_rpc_lock);
-- 
1.8.3.1
