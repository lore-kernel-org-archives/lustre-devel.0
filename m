From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:07 -0400
Subject: [lustre-devel] [PATCH 17/28] lustre: ldlm: Make lru clear always
 discard read lock pages
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

A significant amount of time is sometimes spent during
lru clearing (IE, echo 'clear' > lru_size) checking
pages to see if they are covered by another read lock.
Since all unused read locks will be destroyed by this
operation, the pages will be freed momentarily anyway,
and this is a waste of time.

This patch sets the LDLM_FL_DISCARD_DATA flag on all the PR
locks which are slated for cancellation by
ldlm_prepare_lru_list when it is called from
ldlm_ns_drop_cache.

The case where another lock covers those pages (and is in
use and so does not get cancelled by lru clear) is safe for
a few reasons:

1. When discarding pages, we wait (discard_cb->cl_page_own)
   until they are in the cached state before invalidating.
   So if they are actively in use, we'll wait until that use
   is done.

2. Removal of pages under a read lock is something that can
   happen due to memory pressure, since these are VFS cache
   pages. If a client reads something which is then removed
   from the cache and goes to read it again, this will simply
   generate a new read request.

This has a performance cost for that reader, but if anyone
is clearing the ldlm lru while actively doing I/O in that
namespace, then they cannot expect good performance.

In the case of many read locks on a single resource, this
improves cleanup time dramatically.  In internal testing at
Cray with ~80,000 read locks on a single file, this improves
cleanup time from ~60 seconds to ~0.5 seconds.  This also
slightly improves cleanup speed in the case of 1 or a few
read locks on a file.

Signed-off-by: Patrick Farrell <paf@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8276
Reviewed-on: https://review.whamcloud.com/20785
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_dlm_flags.h |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h       |  6 ++++++
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c        |  9 +++++++++
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c       |  6 ++++--
 drivers/staging/lustre/lustre/osc/osc_cache.c            |  4 ++--
 drivers/staging/lustre/lustre/osc/osc_cl_internal.h      |  2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c             | 10 +++++-----
 drivers/staging/lustre/lustre/osc/osc_object.c           |  2 +-
 8 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index 53db031..487ea17 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -95,7 +95,7 @@
 #define ldlm_set_flock_deadlock(_l)     LDLM_SET_FLAG((_l), 1ULL << 15)
 #define ldlm_clear_flock_deadlock(_l)   LDLM_CLEAR_FLAG((_l), 1ULL << 15)
 
-/** discard (no writeback) on cancel */
+/** discard (no writeback) (PW locks) or page retention (PR locks)) on cancel */
 #define LDLM_FL_DISCARD_DATA            0x0000000000010000ULL /* bit 16 */
 #define ldlm_is_discard_data(_l)        LDLM_TEST_FLAG((_l), 1ULL << 16)
 #define ldlm_set_discard_data(_l)       LDLM_SET_FLAG((_l), 1ULL << 16)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 46b2b64..b64e2be0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -96,6 +96,12 @@ enum {
 	LDLM_LRU_FLAG_NO_WAIT	= BIT(4), /* Cancel locks w/o blocking (neither
 					   * sending nor waiting for any rpcs)
 					   */
+	LDLM_LRU_FLAG_CLEANUP	= BIT(5), /* Used when clearing lru, tells
+					   * prepare_lru_list to set discard
+					   * flag on PR extent locks so we
+					   * don't waste time saving pages
+					   * that will be discarded momentarily
+					   */
 };
 
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index a208c99..ab089e8 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1360,6 +1360,10 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
  *				   (typically before replaying locks) w/o
  *				   sending any RPCs or waiting for any
  *				   outstanding RPC to complete.
+ *
+ * flags & LDLM_CANCEL_CLEANUP - when cancelling read locks, do not check for
+ *				 other read locks covering the same pages, just
+ *				 discard those pages.
  */
 static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 				 struct list_head *cancels, int count, int max,
@@ -1487,6 +1491,11 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		 */
 		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_CANCELING;
 
+		if ((flags & LDLM_LRU_FLAG_CLEANUP) &&
+		    lock->l_resource->lr_type == LDLM_EXTENT &&
+		    lock->l_granted_mode == LCK_PR)
+			ldlm_set_discard_data(lock);
+
 		/* We can't re-add to l_lru as it confuses the
 		 * refcounting in ldlm_lock_remove_from_lru() if an AST
 		 * arrives after we drop lr_lock below. We use l_bl_ast
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index bd5622d..5028db7 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -197,7 +197,8 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 
 			/* Try to cancel all @ns_nr_unused locks. */
 			canceled = ldlm_cancel_lru(ns, unused, 0,
-						   LDLM_LRU_FLAG_PASSED);
+						   LDLM_LRU_FLAG_PASSED |
+						   LDLM_LRU_FLAG_CLEANUP);
 			if (canceled < unused) {
 				CDEBUG(D_DLMTRACE,
 				       "not all requested locks are canceled, requested: %d, canceled: %d\n",
@@ -208,7 +209,8 @@ static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
 		} else {
 			tmp = ns->ns_max_unused;
 			ns->ns_max_unused = 0;
-			ldlm_cancel_lru(ns, 0, 0, LDLM_LRU_FLAG_PASSED);
+			ldlm_cancel_lru(ns, 0, 0, LDLM_LRU_FLAG_PASSED |
+					LDLM_LRU_FLAG_CLEANUP);
 			ns->ns_max_unused = tmp;
 		}
 		return count;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 92d292d..5d09a4f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -3339,7 +3339,7 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
  * behind this being that lock cancellation cannot be delayed indefinitely).
  */
 int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
-			   pgoff_t start, pgoff_t end, enum cl_lock_mode mode)
+			   pgoff_t start, pgoff_t end, bool discard)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct cl_io *io = &info->oti_io;
@@ -3353,7 +3353,7 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 	if (result != 0)
 		goto out;
 
-	cb = mode == CLM_READ ? check_and_discard_cb : discard_cb;
+	cb = discard ? discard_cb : check_and_discard_cb;
 	info->oti_fn_index = start;
 	info->oti_next_index = start;
 	do {
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index da04c2c..4b01809 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -670,7 +670,7 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 void osc_extent_release(const struct lu_env *env, struct osc_extent *ext);
 
 int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
-			   pgoff_t start, pgoff_t end, enum cl_lock_mode mode);
+			   pgoff_t start, pgoff_t end, bool discard_pages);
 
 typedef int (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
 				 struct osc_page *, void *);
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 6059dba..4cc813d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -380,7 +380,7 @@ static int osc_lock_upcall_agl(void *cookie, struct lustre_handle *lockh,
 }
 
 static int osc_lock_flush(struct osc_object *obj, pgoff_t start, pgoff_t end,
-			  enum cl_lock_mode mode, int discard)
+			  enum cl_lock_mode mode, bool discard)
 {
 	struct lu_env *env;
 	u16 refcheck;
@@ -401,7 +401,7 @@ static int osc_lock_flush(struct osc_object *obj, pgoff_t start, pgoff_t end,
 			rc = 0;
 	}
 
-	rc2 = osc_lock_discard_pages(env, obj, start, end, mode);
+	rc2 = osc_lock_discard_pages(env, obj, start, end, discard);
 	if (rc == 0 && rc2 < 0)
 		rc = rc2;
 
@@ -417,10 +417,10 @@ static int osc_dlm_blocking_ast0(const struct lu_env *env,
 				 struct ldlm_lock *dlmlock,
 				 void *data, int flag)
 {
+	enum cl_lock_mode mode = CLM_READ;
 	struct cl_object *obj = NULL;
 	int result = 0;
-	int discard;
-	enum cl_lock_mode mode = CLM_READ;
+	bool discard;
 
 	LASSERT(flag == LDLM_CB_CANCELING);
 
@@ -1098,7 +1098,7 @@ static void osc_lock_lockless_cancel(const struct lu_env *env,
 
 	LASSERT(!ols->ols_dlmlock);
 	result = osc_lock_flush(osc, descr->cld_start, descr->cld_end,
-				descr->cld_mode, 0);
+				descr->cld_mode, false);
 	if (result)
 		CERROR("Pages for lockless lock %p were not purged(%d)\n",
 		       ols, result);
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index a86d4c2..e9ecb77 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -462,7 +462,7 @@ int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc)
 	osc_cache_truncate_start(env, osc, 0, NULL);
 
 	/* Discard all caching pages */
-	osc_lock_discard_pages(env, osc, 0, CL_PAGE_EOF, CLM_WRITE);
+	osc_lock_discard_pages(env, osc, 0, CL_PAGE_EOF, true);
 
 	/* Clear ast data of dlm lock. Do this after discarding all pages */
 	osc_object_prune(env, osc2cl(osc));
-- 
1.8.3.1
