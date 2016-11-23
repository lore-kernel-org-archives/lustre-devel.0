From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 Nov 2016 17:59:50 -0500
Subject: [lustre-devel] [PATCH 4/5] staging: lustre: ldlm: rename
	LDLM_CANCEL_* flags
In-Reply-To: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
References: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479941991-30059-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Rename LDLM_CANCEL_* flags (used with enum ldlm_lru_flags) to
LDLM_LRU_FLAGS_* to avoid confusion with enum ldlm_cancel_flags.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: http://review.whamcloud.com/15300
Reviewed-on: http://review.whamcloud.com/15301
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   16 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   44 ++++++++++----------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    8 ++--
 4 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 9085ee5..49f74db 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -88,14 +88,14 @@ void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *,
 /* ldlm_request.c */
 /* Cancel lru flag, it indicates we cancel aged locks. */
 enum {
-	LDLM_CANCEL_AGED   = 1 << 0, /* Cancel aged locks (non lru resize). */
-	LDLM_CANCEL_PASSED = 1 << 1, /* Cancel passed number of locks. */
-	LDLM_CANCEL_SHRINK = 1 << 2, /* Cancel locks from shrinker. */
-	LDLM_CANCEL_LRUR   = 1 << 3, /* Cancel locks from lru resize. */
-	LDLM_CANCEL_NO_WAIT = 1 << 4, /* Cancel locks w/o blocking (neither
-				       * sending nor waiting for any rpcs)
-				       */
-	LDLM_CANCEL_LRUR_NO_WAIT = 1 << 5, /* LRUR + NO_WAIT */
+	LDLM_LRU_FLAG_AGED	= BIT(0), /* Cancel aged locks (non lru resize). */
+	LDLM_LRU_FLAG_PASSED	= BIT(1), /* Cancel passed number of locks. */
+	LDLM_LRU_FLAG_SHRINK	= BIT(2), /* Cancel locks from shrinker. */
+	LDLM_LRU_FLAG_LRUR	= BIT(3), /* Cancel locks from lru resize. */
+	LDLM_LRU_FLAG_NO_WAIT	= BIT(4), /* Cancel locks w/o blocking (neither
+					   * sending nor waiting for any rpcs)
+					   */
+	LDLM_LRU_FLAG_LRUR_NO_WAIT = BIT(5), /* LRUR + NO_WAIT */
 };
 
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 252bddb..8dfb3c8 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -293,7 +293,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	 * take into account pl->pl_recalc_time here.
 	 */
 	ret = ldlm_cancel_lru(container_of(pl, struct ldlm_namespace, ns_pool),
-			      0, LCF_ASYNC, LDLM_CANCEL_LRUR);
+			      0, LCF_ASYNC, LDLM_LRU_FLAG_LRUR);
 
 out:
 	spin_lock(&pl->pl_lock);
@@ -339,7 +339,7 @@ static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
 	if (nr == 0)
 		return (unused / 100) * sysctl_vfs_cache_pressure;
 	else
-		return ldlm_cancel_lru(ns, nr, LCF_ASYNC, LDLM_CANCEL_SHRINK);
+		return ldlm_cancel_lru(ns, nr, LCF_ASYNC, LDLM_LRU_FLAG_SHRINK);
 }
 
 static const struct ldlm_pool_ops ldlm_cli_pool_ops = {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index b772982..c1f8693 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -593,7 +593,7 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		avail = ldlm_capsule_handles_avail(pill, RCL_CLIENT, canceloff);
 
 		flags = ns_connect_lru_resize(ns) ?
-			LDLM_CANCEL_LRUR_NO_WAIT : LDLM_CANCEL_AGED;
+			LDLM_LRU_FLAG_LRUR_NO_WAIT : LDLM_LRU_FLAG_AGED;
 		to_free = !ns_connect_lru_resize(ns) &&
 			  opc == LDLM_ENQUEUE ? 1 : 0;
 
@@ -1057,7 +1057,7 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 
 		ns = ldlm_lock_to_ns(lock);
 		flags = ns_connect_lru_resize(ns) ?
-			LDLM_CANCEL_LRUR : LDLM_CANCEL_AGED;
+			LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED;
 		count += ldlm_cancel_lru_local(ns, &cancels, 0, avail - 1,
 					       LCF_BL_AST, flags);
 	}
@@ -1284,21 +1284,21 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
 static ldlm_cancel_lru_policy_t
 ldlm_cancel_lru_policy(struct ldlm_namespace *ns, int flags)
 {
-	if (flags & LDLM_CANCEL_NO_WAIT)
+	if (flags & LDLM_LRU_FLAG_NO_WAIT)
 		return ldlm_cancel_no_wait_policy;
 
 	if (ns_connect_lru_resize(ns)) {
-		if (flags & LDLM_CANCEL_SHRINK)
+		if (flags & LDLM_LRU_FLAG_SHRINK)
 			/* We kill passed number of old locks. */
 			return ldlm_cancel_passed_policy;
-		else if (flags & LDLM_CANCEL_LRUR)
+		else if (flags & LDLM_LRU_FLAG_LRUR)
 			return ldlm_cancel_lrur_policy;
-		else if (flags & LDLM_CANCEL_PASSED)
+		else if (flags & LDLM_LRU_FLAG_PASSED)
 			return ldlm_cancel_passed_policy;
-		else if (flags & LDLM_CANCEL_LRUR_NO_WAIT)
+		else if (flags & LDLM_LRU_FLAG_LRUR_NO_WAIT)
 			return ldlm_cancel_lrur_no_wait_policy;
 	} else {
-		if (flags & LDLM_CANCEL_AGED)
+		if (flags & LDLM_LRU_FLAG_AGED)
 			return ldlm_cancel_aged_policy;
 	}
 
@@ -1322,21 +1322,21 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
  *
  * Calling policies for enabled LRU resize:
  * ----------------------------------------
- * flags & LDLM_CANCEL_LRUR - use LRU resize policy (SLV from server) to
- *			    cancel not more than \a count locks;
+ * flags & LDLM_LRU_FLAG_LRUR	- use LRU resize policy (SLV from server) to
+ *				  cancel not more than \a count locks;
  *
- * flags & LDLM_CANCEL_PASSED - cancel \a count number of old locks (located at
- *			      the beginning of LRU list);
+ * flags & LDLM_LRU_FLAG_PASSED - cancel \a count number of old locks (located at
+ *				  the beginning of LRU list);
  *
- * flags & LDLM_CANCEL_SHRINK - cancel not more than \a count locks according to
- *			      memory pressure policy function;
+ * flags & LDLM_LRU_FLAG_SHRINK - cancel not more than \a count locks according to
+ *				  memory pressure policy function;
  *
- * flags & LDLM_CANCEL_AGED - cancel \a count locks according to "aged policy".
+ * flags & LDLM_LRU_FLAG_AGED   - cancel \a count locks according to "aged policy".
  *
- * flags & LDLM_CANCEL_NO_WAIT - cancel as many unused locks as possible
- *			       (typically before replaying locks) w/o
- *			       sending any RPCs or waiting for any
- *			       outstanding RPC to complete.
+ * flags & LDLM_LRU_FLAG_NO_WAIT - cancel as many unused locks as possible
+ *				   (typically before replaying locks) w/o
+ *				   sending any RPCs or waiting for any
+ *				   outstanding RPC to complete.
  */
 static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 				 struct list_head *cancels, int count, int max,
@@ -1345,7 +1345,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 	ldlm_cancel_lru_policy_t pf;
 	struct ldlm_lock *lock, *next;
 	int added = 0, unused, remained;
-	int no_wait = flags & (LDLM_CANCEL_NO_WAIT | LDLM_CANCEL_LRUR_NO_WAIT);
+	int no_wait = flags & (LDLM_LRU_FLAG_NO_WAIT | LDLM_LRU_FLAG_LRUR_NO_WAIT);
 
 	spin_lock(&ns->ns_lock);
 	unused = ns->ns_nr_unused;
@@ -2000,11 +2000,11 @@ static void ldlm_cancel_unused_locks_for_replay(struct ldlm_namespace *ns)
 	       ldlm_ns_name(ns), ns->ns_nr_unused);
 
 	/* We don't need to care whether or not LRU resize is enabled
-	 * because the LDLM_CANCEL_NO_WAIT policy doesn't use the
+	 * because the LDLM_LRU_FLAG_NO_WAIT policy doesn't use the
 	 * count parameter
 	 */
 	canceled = ldlm_cancel_lru_local(ns, &cancels, ns->ns_nr_unused, 0,
-					 LCF_LOCAL, LDLM_CANCEL_NO_WAIT);
+					 LCF_LOCAL, LDLM_LRU_FLAG_NO_WAIT);
 
 	CDEBUG(D_DLMTRACE, "Canceled %d unused locks from namespace %s\n",
 	       canceled, ldlm_ns_name(ns));
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index ca2cd4a..1095331 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -226,7 +226,7 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 
 			/* Try to cancel all @ns_nr_unused locks. */
 			canceled = ldlm_cancel_lru(ns, unused, 0,
-						   LDLM_CANCEL_PASSED);
+						   LDLM_LRU_FLAG_PASSED);
 			if (canceled < unused) {
 				CDEBUG(D_DLMTRACE,
 				       "not all requested locks are canceled, requested: %d, canceled: %d\n",
@@ -237,7 +237,7 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 		} else {
 			tmp = ns->ns_max_unused;
 			ns->ns_max_unused = 0;
-			ldlm_cancel_lru(ns, 0, 0, LDLM_CANCEL_PASSED);
+			ldlm_cancel_lru(ns, 0, 0, LDLM_LRU_FLAG_PASSED);
 			ns->ns_max_unused = tmp;
 		}
 		return count;
@@ -262,7 +262,7 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 		       "changing namespace %s unused locks from %u to %u\n",
 		       ldlm_ns_name(ns), ns->ns_nr_unused,
 		       (unsigned int)tmp);
-		ldlm_cancel_lru(ns, tmp, LCF_ASYNC, LDLM_CANCEL_PASSED);
+		ldlm_cancel_lru(ns, tmp, LCF_ASYNC, LDLM_LRU_FLAG_PASSED);
 
 		if (!lru_resize) {
 			CDEBUG(D_DLMTRACE,
@@ -276,7 +276,7 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 		       ldlm_ns_name(ns), ns->ns_max_unused,
 		       (unsigned int)tmp);
 		ns->ns_max_unused = (unsigned int)tmp;
-		ldlm_cancel_lru(ns, 0, LCF_ASYNC, LDLM_CANCEL_PASSED);
+		ldlm_cancel_lru(ns, 0, LCF_ASYNC, LDLM_LRU_FLAG_PASSED);
 
 		/* Make sure that LRU resize was originally supported before
 		 * turning it on here.
-- 
1.7.1
