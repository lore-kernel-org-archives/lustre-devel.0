From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:33 -0400
Subject: [lustre-devel] [PATCH 18/28] staging/lustre/ldlm: const qualify
	struct lustre_handle * params
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-19-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Add a const qualifier to several struct lustre_handle * parameters in
the LDLM interface.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/17071
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7403
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 18 +++++++++---------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 14 +++++++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  4 ++--
 4 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 63085a0..60051a5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1073,7 +1073,7 @@ void ldlm_lock2handle(const struct ldlm_lock *lock,
 struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *, __u64 flags);
 void ldlm_cancel_callback(struct ldlm_lock *);
 int ldlm_lock_remove_from_lru(struct ldlm_lock *);
-int ldlm_lock_set_data(struct lustre_handle *, void *);
+int ldlm_lock_set_data(const struct lustre_handle *lockh, void *data);
 
 /**
  * Obtain a lock reference by its handle.
@@ -1162,10 +1162,10 @@ do {					    \
 struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
 void ldlm_lock_put(struct ldlm_lock *lock);
 void ldlm_lock2desc(struct ldlm_lock *lock, struct ldlm_lock_desc *desc);
-void ldlm_lock_addref(struct lustre_handle *lockh, __u32 mode);
-int  ldlm_lock_addref_try(struct lustre_handle *lockh, __u32 mode);
-void ldlm_lock_decref(struct lustre_handle *lockh, __u32 mode);
-void ldlm_lock_decref_and_cancel(struct lustre_handle *lockh, __u32 mode);
+void ldlm_lock_addref(const struct lustre_handle *lockh, __u32 mode);
+int  ldlm_lock_addref_try(const struct lustre_handle *lockh, __u32 mode);
+void ldlm_lock_decref(const struct lustre_handle *lockh, __u32 mode);
+void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh, __u32 mode);
 void ldlm_lock_fail_match_locked(struct ldlm_lock *lock);
 void ldlm_lock_allow_match(struct ldlm_lock *lock);
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock);
@@ -1174,10 +1174,10 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 			       enum ldlm_type type, ldlm_policy_data_t *,
 			       enum ldlm_mode mode, struct lustre_handle *,
 			       int unref);
-enum ldlm_mode ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
+enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
 					   __u64 *bits);
 void ldlm_lock_cancel(struct ldlm_lock *lock);
-void ldlm_lock_dump_handle(int level, struct lustre_handle *);
+void ldlm_lock_dump_handle(int level, const struct lustre_handle *);
 void ldlm_unlink_lock_skiplist(struct ldlm_lock *req);
 
 /* resource.c */
@@ -1251,9 +1251,9 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  enum ldlm_type type, __u8 with_policy,
 			  enum ldlm_mode mode,
 			  __u64 *flags, void *lvb, __u32 lvb_len,
-			  struct lustre_handle *lockh, int rc);
+			  const struct lustre_handle *lockh, int rc);
 int ldlm_cli_update_pool(struct ptlrpc_request *req);
-int ldlm_cli_cancel(struct lustre_handle *lockh,
+int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		    enum ldlm_cancel_flags cancel_flags);
 int ldlm_cli_cancel_unused(struct ldlm_namespace *, const struct ldlm_res_id *,
 			   enum ldlm_cancel_flags flags, void *opaque);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index b7254eb..a5993f7 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -658,7 +658,7 @@ static void ldlm_add_ast_work_item(struct ldlm_lock *lock,
  * r/w reference type is determined by \a mode
  * Calls ldlm_lock_addref_internal.
  */
-void ldlm_lock_addref(struct lustre_handle *lockh, __u32 mode)
+void ldlm_lock_addref(const struct lustre_handle *lockh, __u32 mode)
 {
 	struct ldlm_lock *lock;
 
@@ -700,7 +700,7 @@ void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock, __u32 mode)
  *
  * \retval -EAGAIN lock is being canceled.
  */
-int ldlm_lock_addref_try(struct lustre_handle *lockh, __u32 mode)
+int ldlm_lock_addref_try(const struct lustre_handle *lockh, __u32 mode)
 {
 	struct ldlm_lock *lock;
 	int	       result;
@@ -832,7 +832,7 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
 /**
  * Decrease reader/writer refcount for LDLM lock with handle \a lockh
  */
-void ldlm_lock_decref(struct lustre_handle *lockh, __u32 mode)
+void ldlm_lock_decref(const struct lustre_handle *lockh, __u32 mode)
 {
 	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
 
@@ -849,7 +849,7 @@ EXPORT_SYMBOL(ldlm_lock_decref);
  *
  * Typical usage is for GROUP locks which we cannot allow to be cached.
  */
-void ldlm_lock_decref_and_cancel(struct lustre_handle *lockh, __u32 mode)
+void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh, __u32 mode)
 {
 	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
 
@@ -1318,7 +1318,7 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 }
 EXPORT_SYMBOL(ldlm_lock_match);
 
-enum ldlm_mode ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
+enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
 					   __u64 *bits)
 {
 	struct ldlm_lock *lock;
@@ -1849,7 +1849,7 @@ EXPORT_SYMBOL(ldlm_lock_cancel);
 /**
  * Set opaque data into the lock that only makes sense to upper layer.
  */
-int ldlm_lock_set_data(struct lustre_handle *lockh, void *data)
+int ldlm_lock_set_data(const struct lustre_handle *lockh, void *data)
 {
 	struct ldlm_lock *lock = ldlm_handle2lock(lockh);
 	int rc = -EINVAL;
@@ -1875,7 +1875,7 @@ struct export_cl_data {
  *
  * Used when printing all locks on a resource for debug purposes.
  */
-void ldlm_lock_dump_handle(int level, struct lustre_handle *lockh)
+void ldlm_lock_dump_handle(int level, const struct lustre_handle *lockh)
 {
 	struct ldlm_lock *lock;
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 8294703..821939f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -499,7 +499,7 @@ static int ldlm_handle_setinfo(struct ptlrpc_request *req)
 
 static inline void ldlm_callback_errmsg(struct ptlrpc_request *req,
 					const char *msg, int rc,
-					struct lustre_handle *handle)
+					const struct lustre_handle *handle)
 {
 	DEBUG_REQ((req->rq_no_reply || rc) ? D_WARNING : D_DLMTRACE, req,
 		  "%s: [nid %s] [rc %d] [lock %#llx]",
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index d3a376e..af487f9 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -336,7 +336,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  enum ldlm_type type, __u8 with_policy,
 			  enum ldlm_mode mode,
 			  __u64 *flags, void *lvb, __u32 lvb_len,
-			  struct lustre_handle *lockh, int rc)
+			  const struct lustre_handle *lockh, int rc)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
 	int is_replay = *flags & LDLM_FL_REPLAY;
@@ -1023,7 +1023,7 @@ EXPORT_SYMBOL(ldlm_cli_update_pool);
  *
  * Lock must not have any readers or writers by this time.
  */
-int ldlm_cli_cancel(struct lustre_handle *lockh,
+int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		    enum ldlm_cancel_flags cancel_flags)
 {
 	struct obd_export *exp;
-- 
2.7.4
