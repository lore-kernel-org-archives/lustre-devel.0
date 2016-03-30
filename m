From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:15 -0400
Subject: [lustre-devel] [PATCH 43/43] staging/lustre/ldlm: restore the ELC
	for enqueue
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-44-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly.fertman@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Vitaly Fertman <vitaly.fertman@seagate.com>

after LU-4300 enqueue does not ELC anymore, however if enqueue is
agressive (ls -la of a large dir) we may exceed lru-resize limit
quickly because LRUR shrinker and recalc are called not so often.

ELC is to be restored in enqueue.
ELC also should check for the lock weight, in addition to LRUR.
ELC can also keep "skipped" locks, i.e. once checked for the weight
and left in the lru - let LRUR take care about them later.
LRUR is to be left untouched, no weight logic, otherwise LU-5727
appears and OPEN locks do not get canceled.

Xyratex-bug-id: MRP-2550
Signed-off-by: Vitaly Fertman <vitaly.fertman@seagate.com>
Reviewed-on: http://review.whamcloud.com/14342
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6390
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  7 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 25 ++++++++++++++++++----
 drivers/staging/lustre/lustre/osc/osc_request.c    |  4 ++--
 3 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index e21373e..e31d84a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -95,9 +95,10 @@ enum {
 	LDLM_CANCEL_PASSED = 1 << 1, /* Cancel passed number of locks. */
 	LDLM_CANCEL_SHRINK = 1 << 2, /* Cancel locks from shrinker. */
 	LDLM_CANCEL_LRUR   = 1 << 3, /* Cancel locks from lru resize. */
-	LDLM_CANCEL_NO_WAIT = 1 << 4 /* Cancel locks w/o blocking (neither
-				      * sending nor waiting for any rpcs)
-				      */
+	LDLM_CANCEL_NO_WAIT = 1 << 4, /* Cancel locks w/o blocking (neither
+				       * sending nor waiting for any rpcs)
+				       */
+	LDLM_CANCEL_LRUR_NO_WAIT = 1 << 5, /* LRUR + NO_WAIT */
 };
 
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 48e9828..9aa4c2d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -601,7 +601,7 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		avail = ldlm_capsule_handles_avail(pill, RCL_CLIENT, canceloff);
 
 		flags = ns_connect_lru_resize(ns) ?
-			LDLM_CANCEL_LRUR : LDLM_CANCEL_AGED;
+			LDLM_CANCEL_LRUR_NO_WAIT : LDLM_CANCEL_AGED;
 		to_free = !ns_connect_lru_resize(ns) &&
 			  opc == LDLM_ENQUEUE ? 1 : 0;
 
@@ -1146,7 +1146,7 @@ static ldlm_policy_res_t ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns,
 	switch (lock->l_resource->lr_type) {
 	case LDLM_EXTENT:
 	case LDLM_IBITS:
-			if (ns->ns_cancel && ns->ns_cancel(lock) != 0)
+		if (ns->ns_cancel && ns->ns_cancel(lock) != 0)
 			break;
 	default:
 		result = LDLM_POLICY_SKIP_LOCK;
@@ -1251,6 +1251,21 @@ static ldlm_policy_res_t ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 	return LDLM_POLICY_CANCEL_LOCK;
 }
 
+static ldlm_policy_res_t
+ldlm_cancel_lrur_no_wait_policy(struct ldlm_namespace *ns,
+				struct ldlm_lock *lock,
+				int unused, int added,
+				int count)
+{
+	ldlm_policy_res_t result;
+
+	result = ldlm_cancel_lrur_policy(ns, lock, unused, added, count);
+	if (result == LDLM_POLICY_KEEP_LOCK)
+		return result;
+
+	return ldlm_cancel_no_wait_policy(ns, lock, unused, added, count);
+}
+
 /**
  * Callback function for default policy. Makes decision whether to keep \a lock
  * in LRU for current LRU size \a unused, added in current scan \a added and
@@ -1290,6 +1305,8 @@ ldlm_cancel_lru_policy(struct ldlm_namespace *ns, int flags)
 			return ldlm_cancel_lrur_policy;
 		else if (flags & LDLM_CANCEL_PASSED)
 			return ldlm_cancel_passed_policy;
+		else if (flags & LDLM_CANCEL_LRUR_NO_WAIT)
+			return ldlm_cancel_lrur_no_wait_policy;
 	} else {
 		if (flags & LDLM_CANCEL_AGED)
 			return ldlm_cancel_aged_policy;
@@ -1338,6 +1355,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 	ldlm_cancel_lru_policy_t pf;
 	struct ldlm_lock *lock, *next;
 	int added = 0, unused, remained;
+	int no_wait = flags & (LDLM_CANCEL_NO_WAIT | LDLM_CANCEL_LRUR_NO_WAIT);
 
 	spin_lock(&ns->ns_lock);
 	unused = ns->ns_nr_unused;
@@ -1365,8 +1383,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 			/* No locks which got blocking requests. */
 			LASSERT(!(lock->l_flags & LDLM_FL_BL_AST));
 
-			if (flags & LDLM_CANCEL_NO_WAIT &&
-			    lock->l_flags & LDLM_FL_SKIPPED)
+			if (no_wait && lock->l_flags & LDLM_FL_SKIPPED)
 				/* already processed */
 				continue;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index a6dc517..5b9f72c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2297,8 +2297,8 @@ no_match:
 		if (!req)
 			return -ENOMEM;
 
-		rc = ptlrpc_request_pack(req, LUSTRE_DLM_VERSION, LDLM_ENQUEUE);
-		if (rc < 0) {
+		rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
+		if (rc) {
 			ptlrpc_request_free(req);
 			return rc;
 		}
-- 
2.1.0
