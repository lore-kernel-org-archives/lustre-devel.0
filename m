From: James Simmons <jsimmons@infradead.org>
Date: Sat,  2 Mar 2019 14:12:21 -0500
Subject: [lustre-devel] [PATCH 4/7] ldlm: move comments to sphinix format
In-Reply-To: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
References: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1551553944-6419-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre comments was written for DocBook which is no longer used
by the Linux kernel. Move all the DocBook handling to sphinix.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    | 14 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 90 ++++++++++----------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 22 ++---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 99 +++++++++++-----------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 18 ++--
 7 files changed, 127 insertions(+), 130 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 4fc380d2..4316b2b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -100,7 +100,7 @@
  * Process a granting attempt for flock lock.
  * Must be called under ns lock held.
  *
- * This function looks for any conflicts for \a lock in the granted or
+ * This function looks for any conflicts for @lock in the granted or
  * waiting queues. The lock is granted if no conflicts are found in
  * either queue.
  *
@@ -291,7 +291,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 
 	/* In case we're reprocessing the requested lock we can't destroy
 	 * it until after calling ldlm_add_ast_work_item() above so that laawi()
-	 * can bump the reference count on \a req. Otherwise \a req
+	 * can bump the reference count on @req. Otherwise @req
 	 * could be freed before the completion AST can be sent.
 	 */
 	if (added)
@@ -304,12 +304,12 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 /**
  * Flock completion callback function.
  *
- * \param lock [in,out]: A lock to be handled
- * \param flags    [in]: flags
- * \param *data    [in]: ldlm_work_cp_ast_lock() will use ldlm_cb_set_arg
+ * @lock	A lock to be handled
+ * @flags	flags
+ * @data	ldlm_work_cp_ast_lock() will use ldlm_cb_set_arg
  *
- * \retval 0    : success
- * \retval <0   : failure
+ * Return:	0 success
+ *		<0 failure
  */
 int
 ldlm_flock_completion_ast(struct ldlm_lock *lock, u64 flags, void *data)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index aef83ff..e0d2851 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -99,7 +99,7 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 			goto out_free;
 		}
 	}
-	/* No existing import connection found for \a uuid. */
+	/* No existing import connection found for @uuid. */
 	if (create) {
 		imp_conn->oic_conn = ptlrpc_conn;
 		imp_conn->oic_uuid = *uuid;
@@ -198,8 +198,8 @@ int client_import_del_conn(struct obd_import *imp, struct obd_uuid *uuid)
 EXPORT_SYMBOL(client_import_del_conn);
 
 /**
- * Find conn UUID by peer NID. \a peer is a server NID. This function is used
- * to find a conn uuid of \a imp which can reach \a peer.
+ * Find conn UUID by peer NID. @peer is a server NID. This function is used
+ * to find a conn uuid of @imp which can reach @peer.
  */
 int client_import_find_conn(struct obd_import *imp, lnet_nid_t peer,
 			    struct obd_uuid *uuid)
@@ -654,7 +654,7 @@ int client_disconnect_export(struct obd_export *exp)
 EXPORT_SYMBOL(client_disconnect_export);
 
 /**
- * Packs current SLV and Limit into \a req.
+ * Packs current SLV and Limit into @req.
  */
 int target_pack_pool_reply(struct ptlrpc_request *req)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index f2433dc..ba28011 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -192,7 +192,7 @@ void ldlm_lock_put(struct ldlm_lock *lock)
 EXPORT_SYMBOL(ldlm_lock_put);
 
 /**
- * Removes LDLM lock \a lock from LRU. Assumes LRU is already locked.
+ * Removes LDLM lock @lock from LRU. Assumes LRU is already locked.
  */
 int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock)
 {
@@ -211,15 +211,16 @@ int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock)
 }
 
 /**
- * Removes LDLM lock \a lock from LRU. Obtains the LRU lock first.
+ * Removes LDLM lock @lock from LRU. Obtains the LRU lock first.
  *
- * If \a last_use is non-zero, it will remove the lock from LRU only if
+ * If @last_use is non-zero, it will remove the lock from LRU only if
  * it matches lock's l_last_used.
  *
- * \retval 0 if \a last_use is set, the lock is not in LRU list or \a last_use
- *           doesn't match lock's l_last_used;
- *           otherwise, the lock hasn't been in the LRU list.
- * \retval 1 the lock was in LRU list and removed.
+ * Return:	0 if @last_use is set, the lock is not in LRU list or
+ *		@last_use doesn't match lock's l_last_used;
+ *		otherwise, the lock hasn't been in the LRU list.
+ *
+ *		1 the lock was in LRU list and removed.
  */
 int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use)
 {
@@ -235,7 +236,7 @@ int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use)
 }
 
 /**
- * Adds LDLM lock \a lock to namespace LRU. Assumes LRU is already locked.
+ * Adds LDLM lock @lock to namespace LRU. Assumes LRU is already locked.
  */
 static void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
 {
@@ -251,7 +252,7 @@ static void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
 }
 
 /**
- * Adds LDLM lock \a lock to namespace LRU. Obtains necessary LRU locks
+ * Adds LDLM lock @lock to namespace LRU. Obtains necessary LRU locks
  * first.
  */
 static void ldlm_lock_add_to_lru(struct ldlm_lock *lock)
@@ -264,7 +265,7 @@ static void ldlm_lock_add_to_lru(struct ldlm_lock *lock)
 }
 
 /**
- * Moves LDLM lock \a lock that is already in namespace LRU to the tail of
+ * Moves LDLM lock @lock that is already in namespace LRU to the tail of
  * the LRU. Performs necessary LRU locking
  */
 static void ldlm_lock_touch_in_lru(struct ldlm_lock *lock)
@@ -323,7 +324,7 @@ static int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
 }
 
 /**
- * Destroys a LDLM lock \a lock. Performs necessary locking first.
+ * Destroys a LDLM lock @lock. Performs necessary locking first.
  */
 static void ldlm_lock_destroy(struct ldlm_lock *lock)
 {
@@ -341,7 +342,7 @@ static void ldlm_lock_destroy(struct ldlm_lock *lock)
 }
 
 /**
- * Destroys a LDLM lock \a lock that is already locked.
+ * Destroys a LDLM lock @lock that is already locked.
  */
 void ldlm_lock_destroy_nolock(struct ldlm_lock *lock)
 {
@@ -426,7 +427,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 }
 
 /**
- * Moves LDLM lock \a lock to another resource.
+ * Moves LDLM lock @lock to another resource.
  * This is used on client when server returns some other lock than requested
  * (typically as a result of intent operation)
  */
@@ -492,7 +493,7 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
  */
 
 /**
- * Fills in handle for LDLM lock \a lock into supplied \a lockh
+ * Fills in handle for LDLM lock @lock into supplied @lockh
  * Does not take any references.
  */
 void ldlm_lock2handle(const struct ldlm_lock *lock, struct lustre_handle *lockh)
@@ -504,7 +505,7 @@ void ldlm_lock2handle(const struct ldlm_lock *lock, struct lustre_handle *lockh)
 /**
  * Obtain a lock reference by handle.
  *
- * if \a flags: atomically get the lock and set the flags.
+ * if @flags: atomically get the lock and set the flags.
  *	      Return NULL if flag already set
  */
 struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
@@ -563,7 +564,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 
 /**
  * Fill in "on the wire" representation for given LDLM lock into supplied
- * lock descriptor \a desc structure.
+ * lock descriptor @desc structure.
  */
 void ldlm_lock2desc(struct ldlm_lock *lock, struct ldlm_lock_desc *desc)
 {
@@ -632,8 +633,8 @@ static void ldlm_add_ast_work_item(struct ldlm_lock *lock,
 }
 
 /**
- * Add specified reader/writer reference to LDLM lock with handle \a lockh.
- * r/w reference type is determined by \a mode
+ * Add specified reader/writer reference to LDLM lock with handle @lockh.
+ * r/w reference type is determined by @mode
  * Calls ldlm_lock_addref_internal.
  */
 void ldlm_lock_addref(const struct lustre_handle *lockh, enum ldlm_mode mode)
@@ -649,8 +650,8 @@ void ldlm_lock_addref(const struct lustre_handle *lockh, enum ldlm_mode mode)
 
 /**
  * Helper function.
- * Add specified reader/writer reference to LDLM lock \a lock.
- * r/w reference type is determined by \a mode
+ * Add specified reader/writer reference to LDLM lock @lock.
+ * r/w reference type is determined by @mode
  * Removes lock from LRU if it is there.
  * Assumes the LDLM lock is already locked.
  */
@@ -672,12 +673,11 @@ void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
 }
 
 /**
- * Attempts to add reader/writer reference to a lock with handle \a lockh, and
+ * Attempts to add reader/writer reference to a lock with handle @lockh, and
  * fails if lock is already LDLM_FL_CBPENDING or destroyed.
  *
- * \retval 0 success, lock was addref-ed
- *
- * \retval -EAGAIN lock is being canceled.
+ * Return:	0 success, lock was addref-ed
+ *		-EAGAIN lock is being canceled.
  */
 int ldlm_lock_addref_try(const struct lustre_handle *lockh, enum ldlm_mode mode)
 {
@@ -701,7 +701,7 @@ int ldlm_lock_addref_try(const struct lustre_handle *lockh, enum ldlm_mode mode)
 EXPORT_SYMBOL(ldlm_lock_addref_try);
 
 /**
- * Add specified reader/writer reference to LDLM lock \a lock.
+ * Add specified reader/writer reference to LDLM lock @lock.
  * Locks LDLM lock and calls ldlm_lock_addref_internal_nolock to do the work.
  * Only called for local locks.
  */
@@ -713,7 +713,7 @@ void ldlm_lock_addref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 }
 
 /**
- * Removes reader/writer reference for LDLM lock \a lock.
+ * Removes reader/writer reference for LDLM lock @lock.
  * Assumes LDLM lock is already locked.
  * only called in ldlm_flock_destroy and for local locks.
  * Does NOT add lock to LRU if no r/w references left to accommodate flock locks
@@ -739,7 +739,7 @@ void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
 }
 
 /**
- * Removes reader/writer reference for LDLM lock \a lock.
+ * Removes reader/writer reference for LDLM lock @lock.
  * Locks LDLM lock first.
  * If the lock is determined to be client lock on a client and r/w refcount
  * drops to zero and the lock is not blocked, the lock is added to LRU lock
@@ -814,7 +814,7 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 }
 
 /**
- * Decrease reader/writer refcount for LDLM lock with handle \a lockh
+ * Decrease reader/writer refcount for LDLM lock with handle @lockh
  */
 void ldlm_lock_decref(const struct lustre_handle *lockh, enum ldlm_mode mode)
 {
@@ -828,7 +828,7 @@ void ldlm_lock_decref(const struct lustre_handle *lockh, enum ldlm_mode mode)
 
 /**
  * Decrease reader/writer refcount for LDLM lock with handle
- * \a lockh and mark it for subsequent cancellation once r/w refcount
+ * @lockh and mark it for subsequent cancellation once r/w refcount
  * drops to zero instead of putting into LRU.
  */
 void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh,
@@ -942,7 +942,7 @@ static void search_granted_lock(struct list_head *queue,
 
 /**
  * Add a lock into resource granted list after a position described by
- * \a prev.
+ * @prev.
  */
 static void ldlm_granted_list_add_lock(struct ldlm_lock *lock,
 				       struct sl_insert_point *prev)
@@ -1051,8 +1051,8 @@ struct lock_match_data {
  * Check if the given @lock meets the criteria for a match.
  * A reference on the lock is taken if matched.
  *
- * \param lock	test-against this lock
- * \param data	parameters
+ * @lock	test-against this lock
+ * @data	parameters
  */
 static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 {
@@ -1140,10 +1140,10 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 /**
  * Search for a lock with given parameters in interval trees.
  *
- * \param res	search for a lock in this resource
- * \param data	parameters
+ * @res		search for a lock in this resource
+ * @data	parameters
  *
- * \retval	a referenced lock or NULL.
+ * Return:	a referenced lock or NULL.
  */
 static struct ldlm_lock *search_itree(struct ldlm_resource *res,
 				      struct lock_match_data *data)
@@ -1170,10 +1170,10 @@ static struct ldlm_lock *search_itree(struct ldlm_resource *res,
 /**
  * Search for a lock with given properties in a queue.
  *
- * \param queue	search for a lock in this queue
- * \param data	parameters
+ * @queue	search for a lock in this queue
+ * @data	parameters
  *
- * \retval	a referenced lock or NULL.
+ * Return:	a referenced lock or NULL.
  */
 static struct ldlm_lock *search_queue(struct list_head *queue,
 				      struct lock_match_data *data)
@@ -1224,7 +1224,7 @@ void ldlm_lock_allow_match(struct ldlm_lock *lock)
  * Attempt to find a lock with specified properties.
  *
  * Typically returns a reference to matched lock unless LDLM_FL_TEST_LOCK is
- * set in \a flags
+ * set in @flags
  *
  * Can be called in two ways:
  *
@@ -1243,8 +1243,8 @@ void ldlm_lock_allow_match(struct ldlm_lock *lock)
  * If 'flags' contains LDLM_FL_TEST_LOCK, then don't actually reference a lock,
  *     just tell us if we would have matched.
  *
- * \retval 1 if it finds an already-existing lock that is compatible; in this
- * case, lockh is filled in with a addref()ed lock
+ * Return:	1 if it finds an already-existing lock that is compatible;
+ *		in this case, lockh is filled in with a addref()ed lock
  *
  * We also check security context, and if that fails we simply return 0 (to
  * keep caller code unchanged), the context failure will be discovered by
@@ -1831,7 +1831,7 @@ int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 }
 
 /**
- * Helper function to call blocking AST for LDLM lock \a lock in a
+ * Helper function to call blocking AST for LDLM lock @lock in a
  * "cancelling" mode.
  */
 void ldlm_cancel_callback(struct ldlm_lock *lock)
@@ -1862,7 +1862,7 @@ void ldlm_cancel_callback(struct ldlm_lock *lock)
 }
 
 /**
- * Remove skiplist-enabled LDLM lock \a req from granted list
+ * Remove skiplist-enabled LDLM lock @req from granted list
  */
 void ldlm_unlink_lock_skiplist(struct ldlm_lock *req)
 {
@@ -1875,7 +1875,7 @@ void ldlm_unlink_lock_skiplist(struct ldlm_lock *req)
 }
 
 /**
- * Attempts to cancel LDLM lock \a lock that has no reader/writer references.
+ * Attempts to cancel LDLM lock @lock that has no reader/writer references.
  */
 void ldlm_lock_cancel(struct ldlm_lock *lock)
 {
@@ -1937,7 +1937,7 @@ struct export_cl_data {
 };
 
 /**
- * Print lock with lock handle \a lockh description into debug log.
+ * Print lock with lock handle @lockh description into debug log.
  *
  * Used when printing all locks on a resource for debug purposes.
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index bae67ac..589b89d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -382,9 +382,9 @@ static inline void init_blwi(struct ldlm_bl_work_item *blwi,
 }
 
 /**
- * Queues a list of locks \a cancels containing \a count locks
- * for later processing by a blocking thread.  If \a count is zero,
- * then the lock referenced as \a lock is queued instead.
+ * Queues a list of locks @cancels containing @count locks
+ * for later processing by a blocking thread. If @count is zero,
+ * then the lock referenced as @lock is queued instead.
  *
  * The blocking thread would then call ->l_blocking_ast callback in the lock.
  * If list addition fails an error is returned and caller is supposed to
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 5b23767f..1f81795 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -175,7 +175,7 @@ enum {
 
 /**
  * Calculates suggested grant_step in % of available locks for passed
- * \a period. This is later used in grant_plan calculations.
+ * @period. This is later used in grant_plan calculations.
  */
 static inline int ldlm_pool_t2gsp(unsigned int t)
 {
@@ -205,7 +205,7 @@ static inline int ldlm_pool_t2gsp(unsigned int t)
 }
 
 /**
- * Recalculates next stats on passed \a pl.
+ * Recalculates next stats on passed @pl.
  *
  * \pre ->pl_lock is locked.
  */
@@ -231,7 +231,7 @@ static void ldlm_pool_recalc_stats(struct ldlm_pool *pl)
 
 /**
  * Sets SLV and Limit from container_of(pl, struct ldlm_namespace,
- * ns_pool)->ns_obd tp passed \a pl.
+ * ns_pool)->ns_obd tp passed @pl.
  */
 static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
 {
@@ -250,7 +250,7 @@ static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
 }
 
 /**
- * Recalculates client size pool \a pl according to current SLV and Limit.
+ * Recalculates client size pool @pl according to current SLV and Limit.
  */
 static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 {
@@ -312,7 +312,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 /**
  * This function is main entry point for memory pressure handling on client
  * side.  Main goal of this function is to cancel some number of locks on
- * passed \a pl according to \a nr and \a gfp_mask.
+ * passed @pl according to @nr and @gfp_mask.
  */
 static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
 				int nr, gfp_t gfp_mask)
@@ -350,7 +350,7 @@ static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
 
 /**
  * Pool recalc wrapper. Will call either client or server pool recalc callback
- * depending what pool \a pl is used.
+ * depending what pool @pl is used.
  */
 static int ldlm_pool_recalc(struct ldlm_pool *pl)
 {
@@ -691,7 +691,7 @@ void ldlm_pool_fini(struct ldlm_pool *pl)
 }
 
 /**
- * Add new taken ldlm lock \a lock into pool \a pl accounting.
+ * Add new taken ldlm lock @lock into pool @pl accounting.
  */
 void ldlm_pool_add(struct ldlm_pool *pl, struct ldlm_lock *lock)
 {
@@ -716,7 +716,7 @@ void ldlm_pool_add(struct ldlm_pool *pl, struct ldlm_lock *lock)
 }
 
 /**
- * Remove ldlm lock \a lock from pool \a pl accounting.
+ * Remove ldlm lock @lock from pool @pl accounting.
  */
 void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock)
 {
@@ -734,7 +734,7 @@ void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock)
 }
 
 /**
- * Returns current \a pl SLV.
+ * Returns current @pl SLV.
  *
  * \pre ->pl_lock is not locked.
  */
@@ -749,7 +749,7 @@ u64 ldlm_pool_get_slv(struct ldlm_pool *pl)
 }
 
 /**
- * Sets passed \a clv to \a pl.
+ * Sets passed @clv to @pl.
  *
  * \pre ->pl_lock is not locked.
  */
@@ -761,7 +761,7 @@ void ldlm_pool_set_clv(struct ldlm_pool *pl, u64 clv)
 }
 
 /**
- * Returns current LVF from \a pl.
+ * Returns current LVF from @pl.
  */
 u32 ldlm_pool_get_lvf(struct ldlm_pool *pl)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index b819ade..a614d74 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -143,9 +143,9 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, u32 conn_cnt)
  * lock cancel, and their replies). Used for lock completion timeout on the
  * client side.
  *
- * \param[in] lock	lock which is waiting the completion callback
+ * @lock:	lock which is waiting the completion callback
  *
- * \retval		timeout in seconds to wait for the server reply
+ * Return:	timeout in seconds to wait for the server reply
  */
 /* We use the same basis for both server side and client side functions
  * from a single node.
@@ -555,7 +555,7 @@ static inline int ldlm_format_handles_avail(struct obd_import *imp,
 
 /**
  * Cancel LRU locks and pack them into the enqueue request. Pack there the given
- * \a count locks in \a cancels.
+ * @count locks in @cancels.
  *
  * This is to be called by functions preparing their own requests that
  * might contain lists of locks to cancel in addition to actual operation
@@ -660,12 +660,12 @@ static struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp,
 /**
  * Client-side lock enqueue.
  *
- * If a request has some specific initialisation it is passed in \a reqp,
+ * If a request has some specific initialisation it is passed in @reqp,
  * otherwise it is created in ldlm_cli_enqueue.
  *
- * Supports sync and async requests, pass \a async flag accordingly. If a
+ * Supports sync and async requests, pass @async flag accordingly. If a
  * request was created in ldlm_cli_enqueue and it is the async request,
- * pass it to the caller in \a reqp.
+ * pass it to the caller in @reqp.
  */
 int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		     struct ldlm_enqueue_info *einfo,
@@ -787,10 +787,11 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 
 /**
  * Cancel locks locally.
- * Returns:
- * \retval LDLM_FL_LOCAL_ONLY if there is no need for a CANCEL RPC to the server
- * \retval LDLM_FL_CANCELING otherwise;
- * \retval LDLM_FL_BL_AST if there is a need for a separate CANCEL RPC.
+ *
+ * Returns:	LDLM_FL_LOCAL_ONLY if there is no need for a CANCEL RPC
+ *		to the server
+ *		LDLM_FL_CANCELING otherwise;
+ *		LDLM_FL_BL_AST if there is a need for a separate CANCEL RPC.
  */
 static u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 {
@@ -824,7 +825,7 @@ static u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 }
 
 /**
- * Pack \a count locks in \a head into ldlm_request buffer of request \a req.
+ * Pack @count locks in @head into ldlm_request buffer of request @req.
  */
 static void ldlm_cancel_pack(struct ptlrpc_request *req,
 			     struct list_head *head, int count)
@@ -860,8 +861,8 @@ static void ldlm_cancel_pack(struct ptlrpc_request *req,
 }
 
 /**
- * Prepare and send a batched cancel RPC. It will include \a count lock
- * handles of locks given in \a cancels list.
+ * Prepare and send a batched cancel RPC. It will include @count lock
+ * handles of locks given in @cancels list.
  */
 static int ldlm_cli_cancel_req(struct obd_export *exp,
 			       struct list_head *cancels,
@@ -955,7 +956,7 @@ static inline struct ldlm_pool *ldlm_imp2pl(struct obd_import *imp)
 }
 
 /**
- * Update client's OBD pool related fields with new SLV and Limit from \a req.
+ * Update client's OBD pool related fields with new SLV and Limit from @req.
  */
 int ldlm_cli_update_pool(struct ptlrpc_request *req)
 {
@@ -1071,7 +1072,7 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 EXPORT_SYMBOL(ldlm_cli_cancel);
 
 /**
- * Locally cancel up to \a count locks in list \a cancels.
+ * Locally cancel up to @count locks in list @cancels.
  * Return the number of cancelled locks.
  */
 int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
@@ -1155,12 +1156,11 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 
 /**
  * Callback function for LRU-resize policy. Decides whether to keep
- * \a lock in LRU for current \a LRU size \a unused, added in current
- * scan \a added and number of locks to be preferably canceled \a count.
- *
- * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ * @lock in LRU for current @LRU size @unused, added in current
+ * scan @added and number of locks to be preferably canceled @count.
  *
- * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
+ * Retun:	LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ *		LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
 static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 						    struct ldlm_lock *lock,
@@ -1204,12 +1204,11 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 
 /**
  * Callback function for debugfs used policy. Makes decision whether to keep
- * \a lock in LRU for current \a LRU size \a unused, added in current scan \a
- * added and number of locks to be preferably canceled \a count.
- *
- * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ * @lock in LRU for current @LRU size @unused, added in current scan
+ * @added and number of locks to be preferably canceled @count.
  *
- * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
+ * Return:	LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ *		LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
 static enum ldlm_policy_res ldlm_cancel_passed_policy(struct ldlm_namespace *ns,
 						      struct ldlm_lock *lock,
@@ -1224,13 +1223,12 @@ static enum ldlm_policy_res ldlm_cancel_passed_policy(struct ldlm_namespace *ns,
 }
 
 /**
- * Callback function for aged policy. Makes decision whether to keep \a lock in
- * LRU for current LRU size \a unused, added in current scan \a added and
- * number of locks to be preferably canceled \a count.
+ * Callback function for aged policy. Makes decision whether to keep @lock in
+ * LRU for current LRU size @unused, added in current scan @added and
+ * number of locks to be preferably canceled @count.
  *
- * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
- *
- * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
+ * Return:	LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ *		LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
 static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 						    struct ldlm_lock *lock,
@@ -1274,13 +1272,12 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 }
 
 /**
- * Callback function for default policy. Makes decision whether to keep \a lock
- * in LRU for current LRU size \a unused, added in current scan \a added and
- * number of locks to be preferably canceled \a count.
- *
- * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ * Callback function for default policy. Makes decision whether to keep @lock
+ * in LRU for current LRU size @unused, added in current scan @added and
+ * number of locks to be preferably canceled @count.
  *
- * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
+ * Return:	LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ *		LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
  */
 static enum ldlm_policy_res
 ldlm_cancel_default_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
@@ -1329,11 +1326,11 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
 }
 
 /**
- * - Free space in LRU for \a count new locks,
+ * - Free space in LRU for @count new locks,
  *   redundant unused locks are canceled locally;
  * - also cancel locally unused aged locks;
- * - do not cancel more than \a max locks;
- * - GET the found locks and add them into the \a cancels list.
+ * - do not cancel more than @max locks;
+ * - GET the found locks and add them into the @cancels list.
  *
  * A client lock can be added to the l_bl_ast list only when it is
  * marked LDLM_FL_CANCELING. Otherwise, somebody is already doing
@@ -1346,15 +1343,15 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
  * Calling policies for enabled LRU resize:
  * ----------------------------------------
  * flags & LDLM_LRU_FLAG_LRUR	- use LRU resize policy (SLV from server) to
- *				  cancel not more than \a count locks;
+ *				  cancel not more than @count locks;
  *
- * flags & LDLM_LRU_FLAG_PASSED - cancel \a count number of old locks (located
+ * flags & LDLM_LRU_FLAG_PASSED - cancel @count number of old locks (located
  *				  at the beginning of LRU list);
  *
- * flags & LDLM_LRU_FLAG_SHRINK - cancel not more than \a count locks according
+ * flags & LDLM_LRU_FLAG_SHRINK - cancel not more than @count locks according
  *				  to memory pressure policy function;
  *
- * flags & LDLM_LRU_FLAG_AGED   - cancel \a count locks according to
+ * flags & LDLM_LRU_FLAG_AGED   - cancel @count locks according to
  *				  "aged policy".
  *
  * flags & LDLM_LRU_FLAG_NO_WAIT - cancel as many unused locks as possible
@@ -1529,7 +1526,7 @@ int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
 }
 
 /**
- * Cancel at least \a nr locks from given namespace LRU.
+ * Cancel at least @nr locks from given namespace LRU.
  *
  * When called with LCF_ASYNC the blocking callback will be handled
  * in a thread and this function will return after the thread has been
@@ -1556,7 +1553,7 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 
 /**
  * Find and cancel locally unused locks found on resource, matched to the
- * given policy, mode. GET the found locks and add them into the \a cancels
+ * given policy, mode. GET the found locks and add them into the @cancels
  * list.
  */
 int ldlm_cancel_resource_local(struct ldlm_resource *res,
@@ -1615,12 +1612,12 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 /**
  * Cancel client-side locks from a list and send/prepare cancel RPCs to the
  * server.
- * If \a req is NULL, send CANCEL request to server with handles of locks
- * in the \a cancels. If EARLY_CANCEL is not supported, send CANCEL requests
+ * If @req is NULL, send CANCEL request to server with handles of locks
+ * in the @cancels. If EARLY_CANCEL is not supported, send CANCEL requests
  * separately per lock.
- * If \a req is not NULL, put handles of locks in \a cancels into the request
- * buffer at the offset \a off.
- * Destroy \a cancels at the end.
+ * If @req is not NULL, put handles of locks in @cancels into the request
+ * buffer at the offset @off.
+ * Destroy @cancels at the end.
  */
 int ldlm_cli_cancel_list(struct list_head *cancels, int count,
 			 struct ptlrpc_request *req,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 74c7644..c1f585a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -557,7 +557,7 @@ struct ldlm_ns_hash_def {
 	},
 };
 
-/** Register \a ns in the list of namespaces */
+/** Register @ns in the list of namespaces */
 static void ldlm_namespace_register(struct ldlm_namespace *ns,
 				    enum ldlm_side client)
 {
@@ -859,13 +859,13 @@ static int __ldlm_namespace_free(struct ldlm_namespace *ns, int force)
 }
 
 /**
- * Performs various cleanups for passed \a ns to make it drop refc and be
+ * Performs various cleanups for passed @ns to make it drop refc and be
  * ready for freeing. Waits for refc == 0.
  *
  * The following is done:
- * (0) Unregister \a ns from its list to make inaccessible for potential
+ * (0) Unregister @ns from its list to make inaccessible for potential
  * users like pools thread and others;
- * (1) Clear all locks in \a ns.
+ * (1) Clear all locks in @ns.
  */
 void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
 			       struct obd_import *imp,
@@ -899,7 +899,7 @@ void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
 	}
 }
 
-/** Unregister \a ns from the list of namespaces. */
+/** Unregister @ns from the list of namespaces. */
 static void ldlm_namespace_unregister(struct ldlm_namespace *ns,
 				      enum ldlm_side client)
 {
@@ -915,9 +915,9 @@ static void ldlm_namespace_unregister(struct ldlm_namespace *ns,
 }
 
 /**
- * Performs freeing memory structures related to \a ns. This is only done
+ * Performs freeing memory structures related to @ns. This is only done
  * when ldlm_namespce_free_prior() successfully removed all resources
- * referencing \a ns and its refc == 0.
+ * referencing @ns and its refc == 0.
  */
 void ldlm_namespace_free_post(struct ldlm_namespace *ns)
 {
@@ -936,8 +936,8 @@ void ldlm_namespace_free_post(struct ldlm_namespace *ns)
 	ldlm_namespace_sysfs_unregister(ns);
 	cfs_hash_putref(ns->ns_rs_hash);
 	kfree(ns->ns_name);
-	/* Namespace \a ns should be not on list at this time, otherwise
-	 * this will cause issues related to using freed \a ns in poold
+	/* Namespace @ns should be not on list at this time, otherwise
+	 * this will cause issues related to using freed @ns in poold
 	 * thread.
 	 */
 	LASSERT(list_empty(&ns->ns_list_chain));
-- 
1.8.3.1
