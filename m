From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri,  1 Apr 2016 15:18:03 -0400
Subject: [lustre-devel] [PATCH 3/3] staging/lustre: Get rid of
	ldlm_policy_res_t typedef
In-Reply-To: <1459538283-3031249-1-git-send-email-green@linuxhacker.ru>
References: <1459538283-3031249-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459538283-3031249-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Directly use enum ldlm_policy_res everywhere.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 49 +++++++++++-----------
 2 files changed, 24 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 351f8b4..ba643e6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -218,8 +218,6 @@ enum ldlm_policy_res {
 	LDLM_POLICY_SKIP_LOCK
 };
 
-typedef enum ldlm_policy_res ldlm_policy_res_t;
-
 #define LDLM_POOL_SYSFS_PRINT_int(v) sprintf(buf, "%d\n", v)
 #define LDLM_POOL_SYSFS_SET_int(a, b) { a = b; }
 #define LDLM_POOL_SYSFS_PRINT_u64(v) sprintf(buf, "%lld\n", v)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 9ff5ad0..9de9fa0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1131,12 +1131,11 @@ EXPORT_SYMBOL(ldlm_cli_cancel_list_local);
  * dirty data, to close a file, ...) or waiting for any RPCs in-flight (e.g.
  * readahead requests, ...)
  */
-static ldlm_policy_res_t ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns,
-						    struct ldlm_lock *lock,
-						    int unused, int added,
-						    int count)
+static enum ldlm_policy_res
+ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
+			   int unused, int added, int count)
 {
-	ldlm_policy_res_t result = LDLM_POLICY_CANCEL_LOCK;
+	enum ldlm_policy_res result = LDLM_POLICY_CANCEL_LOCK;
 
 	/* don't check added & count since we want to process all locks
 	 * from unused list.
@@ -1168,10 +1167,10 @@ static ldlm_policy_res_t ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns,
  *
  * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
-static ldlm_policy_res_t ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
-						 struct ldlm_lock *lock,
-						 int unused, int added,
-						 int count)
+static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
+						    struct ldlm_lock *lock,
+						    int unused, int added,
+						    int count)
 {
 	unsigned long cur = cfs_time_current();
 	struct ldlm_pool *pl = &ns->ns_pool;
@@ -1214,10 +1213,10 @@ static ldlm_policy_res_t ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
  *
  * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
-static ldlm_policy_res_t ldlm_cancel_passed_policy(struct ldlm_namespace *ns,
-						   struct ldlm_lock *lock,
-						   int unused, int added,
-						   int count)
+static enum ldlm_policy_res ldlm_cancel_passed_policy(struct ldlm_namespace *ns,
+						      struct ldlm_lock *lock,
+						      int unused, int added,
+						      int count)
 {
 	/* Stop LRU processing when we reach past @count or have checked all
 	 * locks in LRU.
@@ -1235,10 +1234,10 @@ static ldlm_policy_res_t ldlm_cancel_passed_policy(struct ldlm_namespace *ns,
  *
  * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
-static ldlm_policy_res_t ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
-						 struct ldlm_lock *lock,
-						 int unused, int added,
-						 int count)
+static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
+						    struct ldlm_lock *lock,
+						    int unused, int added,
+						    int count)
 {
 	if ((added >= count) &&
 	    time_before(cfs_time_current(),
@@ -1251,13 +1250,13 @@ static ldlm_policy_res_t ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 	return LDLM_POLICY_CANCEL_LOCK;
 }
 
-static ldlm_policy_res_t
+static enum ldlm_policy_res
 ldlm_cancel_lrur_no_wait_policy(struct ldlm_namespace *ns,
 				struct ldlm_lock *lock,
 				int unused, int added,
 				int count)
 {
-	ldlm_policy_res_t result;
+	enum ldlm_policy_res result;
 
 	result = ldlm_cancel_lrur_policy(ns, lock, unused, added, count);
 	if (result == LDLM_POLICY_KEEP_LOCK)
@@ -1275,10 +1274,9 @@ ldlm_cancel_lrur_no_wait_policy(struct ldlm_namespace *ns,
  *
  * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
-static ldlm_policy_res_t ldlm_cancel_default_policy(struct ldlm_namespace *ns,
-						    struct ldlm_lock *lock,
-						    int unused, int added,
-						    int count)
+static enum ldlm_policy_res
+ldlm_cancel_default_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
+			   int unused, int added, int count)
 {
 	/* Stop LRU processing when we reach past count or have checked all
 	 * locks in LRU.
@@ -1287,7 +1285,8 @@ static ldlm_policy_res_t ldlm_cancel_default_policy(struct ldlm_namespace *ns,
 		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
 }
 
-typedef ldlm_policy_res_t (*ldlm_cancel_lru_policy_t)(struct ldlm_namespace *,
+typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
+						      struct ldlm_namespace *,
 						      struct ldlm_lock *, int,
 						      int, int);
 
@@ -1368,7 +1367,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 	LASSERT(pf);
 
 	while (!list_empty(&ns->ns_unused_list)) {
-		ldlm_policy_res_t result;
+		enum ldlm_policy_res result;
 		time_t last_use = 0;
 
 		/* all unused locks */
-- 
2.1.0
