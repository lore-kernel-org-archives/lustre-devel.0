From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:12 -0400
Subject: [lustre-devel] [PATCH 16/41] staging: lustre: ldlm: Do not use
	cbpending for group locks
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Patrick Farrell <paf@cray.com>, James Simmons <jsimmons@infradead.org>

From: Patrick Farrell <paf@cray.com>

Currently, the CBPENDING flag is set on group locks when
the osc lock above them is released (osc_cancel_base).

This results in a situation where a new group lock request
on a resource does not match an existing group lock because
LDLM_FL_CBPENDING is set on the existing lock.

So two group locks are granted on the same resource, which
is not valid, since a given client can only have one group
lock on a particular resource.

Since group locks are manually released and not called back
like other LDLM locks, the CBPENDING flag doesn't make
sense. Since they must be manually released, they also
cannot go in the LDLM LRU cache and must be fully released
immediately once they are no longer in use.

This was previously accomplished by setting CBPENDING when
the corresponding osc lock is released, but as noted above,
this prevents the group lock matching some future lock
requests.

This patch uses the fact that group locks have an l_writers
reference which they keep until they are manually released,
so we remove them when they have no more reader or writer
references, without checking cbpending.

Signed-off-by: Patrick Farrell <paf@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6368
Reviewed-on: http://review.whamcloud.com/14093
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c   |   11 +++++++----
 drivers/staging/lustre/lustre/osc/osc_internal.h |    1 -
 drivers/staging/lustre/lustre/osc/osc_lock.c     |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c  |   10 ----------
 4 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index ace8cb2..cc116ba 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -784,11 +784,16 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
 	}
 
 	if (!lock->l_readers && !lock->l_writers &&
-	    ldlm_is_cbpending(lock)) {
+	    (ldlm_is_cbpending(lock) || lock->l_req_mode == LCK_GROUP)) {
 		/* If we received a blocked AST and this was the last reference,
 		 * run the callback.
+		 * Group locks are special:
+		 * They must not go in LRU, but they are not called back
+		 * like non-group locks, instead they are manually released.
+		 * They have an l_writers reference which they keep until
+		 * they are manually released, so we remove them when they have
+		 * no more reader or writer references. - LU-6368
 		 */
-
 		LDLM_DEBUG(lock, "final decref done on cbpending lock");
 
 		LDLM_LOCK_GET(lock); /* dropped by bl thread */
@@ -844,8 +849,6 @@ EXPORT_SYMBOL(ldlm_lock_decref);
  * Decrease reader/writer refcount for LDLM lock with handle
  * \a lockh and mark it for subsequent cancellation once r/w refcount
  * drops to zero instead of putting into LRU.
- *
- * Typical usage is for GROUP locks which we cannot allow to be cached.
  */
 void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh, __u32 mode)
 {
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 90ea0d1..64684c4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -112,7 +112,6 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     osc_enqueue_upcall_f upcall,
 		     void *cookie, struct ldlm_enqueue_info *einfo,
 		     struct ptlrpc_request_set *rqset, int async, int agl);
-int osc_cancel_base(struct lustre_handle *lockh, __u32 mode);
 
 int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		   __u32 type, ldlm_policy_data_t *policy, __u32 mode,
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index a42cb98..45d5e6d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -1009,7 +1009,7 @@ static void osc_lock_detach(const struct lu_env *env, struct osc_lock *olck)
 
 	if (olck->ols_hold) {
 		olck->ols_hold = 0;
-		osc_cancel_base(&olck->ols_handle, olck->ols_einfo.ei_mode);
+		ldlm_lock_decref(&olck->ols_handle, olck->ols_einfo.ei_mode);
 		olck->ols_handle.cookie = 0ULL;
 	}
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index de2f522..21cd48b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2336,16 +2336,6 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	return rc;
 }
 
-int osc_cancel_base(struct lustre_handle *lockh, __u32 mode)
-{
-	if (unlikely(mode == LCK_GROUP))
-		ldlm_lock_decref_and_cancel(lockh, mode);
-	else
-		ldlm_lock_decref(lockh, mode);
-
-	return 0;
-}
-
 static int osc_statfs_interpret(const struct lu_env *env,
 				struct ptlrpc_request *req,
 				struct osc_async_args *aa, int rc)
-- 
1.7.1
