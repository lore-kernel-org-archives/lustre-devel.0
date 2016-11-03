From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:24:58 -0400
Subject: [lustre-devel] [PATCH 08/14] staging/lustre/ldlm: engage ELC for
	all ldlm enqueue req
In-Reply-To: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1478136304-867780-9-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Hongchao Zhang <hongchao.zhang@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Hongchao Zhang <hongchao.zhang@intel.com>

If there is no request passed into ldlm_cli_enqueue, the enqueue
request will not engage ELC to drop unneeded locks. currently,
this kind of request is mainly related to EXTENT locks enqueue
requests (except for glimpse EXTENT lock for it has an intent).

Signed-off-by: Hongchao Zhang <hongchao.zhang@intel.com>
Reviewed-on: http://review.whamcloud.com/21739
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8209
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Vitaly Fertman <vitaly.fertman@seagate.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c | 21 ++++-----------------
 1 file changed, 4 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 1b9ae77..c5d00d1 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -748,17 +748,14 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	lock->l_last_activity = ktime_get_real_seconds();
 
 	/* lock not sent to server yet */
-
 	if (!reqp || !*reqp) {
-		req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
-						&RQF_LDLM_ENQUEUE,
-						LUSTRE_DLM_VERSION,
-						LDLM_ENQUEUE);
-		if (!req) {
+		req = ldlm_enqueue_pack(exp, lvb_len);
+		if (IS_ERR(req)) {
 			failed_lock_cleanup(ns, lock, einfo->ei_mode);
 			LDLM_LOCK_RELEASE(lock);
-			return -ENOMEM;
+			return PTR_ERR(req);
 		}
+
 		req_passed_in = 0;
 		if (reqp)
 			*reqp = req;
@@ -778,16 +775,6 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	body->lock_flags = ldlm_flags_to_wire(*flags);
 	body->lock_handle[0] = *lockh;
 
-	/* Continue as normal. */
-	if (!req_passed_in) {
-		if (lvb_len > 0)
-			req_capsule_extend(&req->rq_pill,
-					   &RQF_LDLM_ENQUEUE_LVB);
-		req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER,
-				     lvb_len);
-		ptlrpc_request_set_replen(req);
-	}
-
 	/*
 	 * Liblustre client doesn't get extent locks, except for O_APPEND case
 	 * where [0, OBD_OBJECT_EOF] lock is taken, or truncate, where
-- 
2.7.4
