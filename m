From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:56 -0400
Subject: [lustre-devel] [PATCH 06/28] lustre: ldlm: ELC shouldn't wait on
 lock flush
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

The commit 08fd034670b5 ("staging: lustre: ldlm: revert the changes
for lock canceling policy") removed the fix for LU-4300 when lru_resize
is disabled.

Introduce ldlm_cancel_aged_no_wait_policy to be used by ELC.

Signed-off-by: Andriy Skulysh <c17819@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8578
Seagate-bug-id: MRP-3662
Reviewed-on: https://review.whamcloud.com/22286
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 51 +++++++++++++++-------
 2 files changed, 35 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 1d7c727..709c527 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -96,7 +96,6 @@ enum {
 	LDLM_LRU_FLAG_NO_WAIT	= BIT(4), /* Cancel locks w/o blocking (neither
 					   * sending nor waiting for any rpcs)
 					   */
-	LDLM_LRU_FLAG_LRUR_NO_WAIT = BIT(5), /* LRUR + NO_WAIT */
 };
 
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 80260b07..3eb5036 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -579,8 +579,8 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		req_capsule_filled_sizes(pill, RCL_CLIENT);
 		avail = ldlm_capsule_handles_avail(pill, RCL_CLIENT, canceloff);
 
-		flags = ns_connect_lru_resize(ns) ?
-			LDLM_LRU_FLAG_LRUR_NO_WAIT : LDLM_LRU_FLAG_AGED;
+		flags = LDLM_LRU_FLAG_NO_WAIT | ns_connect_lru_resize(ns) ?
+			LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED;
 		to_free = !ns_connect_lru_resize(ns) &&
 			  opc == LDLM_ENQUEUE ? 1 : 0;
 
@@ -1254,6 +1254,20 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 	return ldlm_cancel_no_wait_policy(ns, lock, unused, added, count);
 }
 
+static enum ldlm_policy_res
+ldlm_cancel_aged_no_wait_policy(struct ldlm_namespace *ns,
+				struct ldlm_lock *lock,
+				int unused, int added, int count)
+{
+	enum ldlm_policy_res result;
+
+	result = ldlm_cancel_aged_policy(ns, lock, unused, added, count);
+	if (result == LDLM_POLICY_KEEP_LOCK)
+		return result;
+
+	return ldlm_cancel_no_wait_policy(ns, lock, unused, added, count);
+}
+
 /**
  * Callback function for default policy. Makes decision whether to keep \a lock
  * in LRU for current LRU size \a unused, added in current scan \a added and
@@ -1280,26 +1294,32 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
 						      int, int);
 
 static ldlm_cancel_lru_policy_t
-ldlm_cancel_lru_policy(struct ldlm_namespace *ns, int flags)
+ldlm_cancel_lru_policy(struct ldlm_namespace *ns, int lru_flags)
 {
-	if (flags & LDLM_LRU_FLAG_NO_WAIT)
-		return ldlm_cancel_no_wait_policy;
-
 	if (ns_connect_lru_resize(ns)) {
-		if (flags & LDLM_LRU_FLAG_SHRINK)
+		if (lru_flags & LDLM_LRU_FLAG_SHRINK) {
 			/* We kill passed number of old locks. */
 			return ldlm_cancel_passed_policy;
-		else if (flags & LDLM_LRU_FLAG_LRUR)
-			return ldlm_cancel_lrur_policy;
-		else if (flags & LDLM_LRU_FLAG_PASSED)
+		} else if (lru_flags & LDLM_LRU_FLAG_LRUR) {
+			if (lru_flags & LDLM_LRU_FLAG_NO_WAIT)
+				return ldlm_cancel_lrur_no_wait_policy;
+			else
+				return ldlm_cancel_lrur_policy;
+		} else if (lru_flags & LDLM_LRU_FLAG_PASSED) {
 			return ldlm_cancel_passed_policy;
-		else if (flags & LDLM_LRU_FLAG_LRUR_NO_WAIT)
-			return ldlm_cancel_lrur_no_wait_policy;
+		}
 	} else {
-		if (flags & LDLM_LRU_FLAG_AGED)
-			return ldlm_cancel_aged_policy;
+		if (lru_flags & LDLM_LRU_FLAG_AGED) {
+			if (lru_flags & LDLM_LRU_FLAG_NO_WAIT)
+				return ldlm_cancel_aged_no_wait_policy;
+			else
+				return ldlm_cancel_aged_policy;
+		}
 	}
 
+	if (lru_flags & LDLM_LRU_FLAG_NO_WAIT)
+		return ldlm_cancel_no_wait_policy;
+
 	return ldlm_cancel_default_policy;
 }
 
@@ -1344,8 +1364,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 	ldlm_cancel_lru_policy_t pf;
 	struct ldlm_lock *lock, *next;
 	int added = 0, unused, remained;
-	int no_wait = flags &
-		(LDLM_LRU_FLAG_NO_WAIT | LDLM_LRU_FLAG_LRUR_NO_WAIT);
+	int no_wait = flags & LDLM_LRU_FLAG_NO_WAIT;
 
 	spin_lock(&ns->ns_lock);
 	unused = ns->ns_nr_unused;
-- 
1.8.3.1
