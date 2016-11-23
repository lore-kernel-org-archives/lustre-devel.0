From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 Nov 2016 17:59:51 -0500
Subject: [lustre-devel] [PATCH 5/5] staging: lustre: ldlm: change "int" to
	proper enum type
In-Reply-To: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
References: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479941991-30059-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Fix users of flags that were using "int" instead of named enum.
Rename some "flags" variables to distinguish between different flags.

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
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   14 ++++++++------
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    8 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   19 +++++++++++--------
 3 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 62304ba..dfef4fa 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -965,8 +965,8 @@ struct ldlm_ast_work {
  * Common ldlm_enqueue parameters
  */
 struct ldlm_enqueue_info {
-	__u32 ei_type;   /** Type of the lock being enqueued. */
-	__u32 ei_mode;   /** Mode of the lock being enqueued. */
+	enum ldlm_type	ei_type;  /** Type of the lock being enqueued. */
+	enum ldlm_mode	ei_mode;  /** Mode of the lock being enqueued. */
 	void *ei_cb_bl;  /** blocking lock callback */
 	void *ei_cb_cp;  /** lock completion callback */
 	void *ei_cb_gl;  /** lock glimpse callback */
@@ -1166,10 +1166,12 @@ static inline int ldlm_res_lvbo_update(struct ldlm_resource *res,
 struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
 void ldlm_lock_put(struct ldlm_lock *lock);
 void ldlm_lock2desc(struct ldlm_lock *lock, struct ldlm_lock_desc *desc);
-void ldlm_lock_addref(const struct lustre_handle *lockh, __u32 mode);
-int  ldlm_lock_addref_try(const struct lustre_handle *lockh, __u32 mode);
-void ldlm_lock_decref(const struct lustre_handle *lockh, __u32 mode);
-void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh, __u32 mode);
+void ldlm_lock_addref(const struct lustre_handle *lockh, enum ldlm_mode mode);
+int  ldlm_lock_addref_try(const struct lustre_handle *lockh,
+			  enum ldlm_mode mode);
+void ldlm_lock_decref(const struct lustre_handle *lockh, enum ldlm_mode mode);
+void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh,
+				 enum ldlm_mode mode);
 void ldlm_lock_fail_match_locked(struct ldlm_lock *lock);
 void ldlm_lock_allow_match(struct ldlm_lock *lock);
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 49f74db..5c02501 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -138,10 +138,10 @@ struct ldlm_lock *
 		 void *data, __u32 lvb_len, enum lvb_type lvb_type);
 enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *, struct ldlm_lock **,
 				  void *cookie, __u64 *flags);
-void ldlm_lock_addref_internal(struct ldlm_lock *, __u32 mode);
-void ldlm_lock_addref_internal_nolock(struct ldlm_lock *, __u32 mode);
-void ldlm_lock_decref_internal(struct ldlm_lock *, __u32 mode);
-void ldlm_lock_decref_internal_nolock(struct ldlm_lock *, __u32 mode);
+void ldlm_lock_addref_internal(struct ldlm_lock *, enum ldlm_mode mode);
+void ldlm_lock_addref_internal_nolock(struct ldlm_lock *, enum ldlm_mode mode);
+void ldlm_lock_decref_internal(struct ldlm_lock *, enum ldlm_mode mode);
+void ldlm_lock_decref_internal_nolock(struct ldlm_lock *, enum ldlm_mode mode);
 int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 		      enum ldlm_desc_ast_t ast_type);
 int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 15eeb2b..d03e6d4 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -643,7 +643,7 @@ static void ldlm_add_ast_work_item(struct ldlm_lock *lock,
  * r/w reference type is determined by \a mode
  * Calls ldlm_lock_addref_internal.
  */
-void ldlm_lock_addref(const struct lustre_handle *lockh, __u32 mode)
+void ldlm_lock_addref(const struct lustre_handle *lockh, enum ldlm_mode mode)
 {
 	struct ldlm_lock *lock;
 
@@ -661,7 +661,8 @@ void ldlm_lock_addref(const struct lustre_handle *lockh, __u32 mode)
  * Removes lock from LRU if it is there.
  * Assumes the LDLM lock is already locked.
  */
-void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock, __u32 mode)
+void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
+				      enum ldlm_mode mode)
 {
 	ldlm_lock_remove_from_lru(lock);
 	if (mode & (LCK_NL | LCK_CR | LCK_PR)) {
@@ -685,7 +686,7 @@ void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock, __u32 mode)
  *
  * \retval -EAGAIN lock is being canceled.
  */
-int ldlm_lock_addref_try(const struct lustre_handle *lockh, __u32 mode)
+int ldlm_lock_addref_try(const struct lustre_handle *lockh, enum ldlm_mode mode)
 {
 	struct ldlm_lock *lock;
 	int	       result;
@@ -711,7 +712,7 @@ int ldlm_lock_addref_try(const struct lustre_handle *lockh, __u32 mode)
  * Locks LDLM lock and calls ldlm_lock_addref_internal_nolock to do the work.
  * Only called for local locks.
  */
-void ldlm_lock_addref_internal(struct ldlm_lock *lock, __u32 mode)
+void ldlm_lock_addref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 {
 	lock_res_and_lock(lock);
 	ldlm_lock_addref_internal_nolock(lock, mode);
@@ -725,7 +726,8 @@ void ldlm_lock_addref_internal(struct ldlm_lock *lock, __u32 mode)
  * Does NOT add lock to LRU if no r/w references left to accommodate flock locks
  * that cannot be placed in LRU.
  */
-void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock, __u32 mode)
+void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
+				      enum ldlm_mode mode)
 {
 	LDLM_DEBUG(lock, "ldlm_lock_decref(%s)", ldlm_lockname[mode]);
 	if (mode & (LCK_NL | LCK_CR | LCK_PR)) {
@@ -751,7 +753,7 @@ void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock, __u32 mode)
  * on the namespace.
  * For blocked LDLM locks if r/w count drops to zero, blocking_ast is called.
  */
-void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
+void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 {
 	struct ldlm_namespace *ns;
 
@@ -822,7 +824,7 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
 /**
  * Decrease reader/writer refcount for LDLM lock with handle \a lockh
  */
-void ldlm_lock_decref(const struct lustre_handle *lockh, __u32 mode)
+void ldlm_lock_decref(const struct lustre_handle *lockh, enum ldlm_mode mode)
 {
 	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
 
@@ -837,7 +839,8 @@ void ldlm_lock_decref(const struct lustre_handle *lockh, __u32 mode)
  * \a lockh and mark it for subsequent cancellation once r/w refcount
  * drops to zero instead of putting into LRU.
  */
-void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh, __u32 mode)
+void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh,
+				 enum ldlm_mode mode)
 {
 	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
 
-- 
1.7.1
