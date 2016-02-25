From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:54 -0500
Subject: [lustre-devel] [PATCH v2 11/84] staging/lustre: Remove ldlm
	type/mode typedefs
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-12-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace ldlm_mode_t with enum ldlm_mode,
ldlm_type_t with enum ldlm_type

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      | 14 ++++----
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 39 ++++++++++++----------
 drivers/staging/lustre/lustre/include/lustre_net.h |  2 +-
 drivers/staging/lustre/lustre/include/obd.h        | 10 +++---
 drivers/staging/lustre/lustre/include/obd_class.h  | 14 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  4 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 28 ++++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  7 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  3 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  2 +-
 drivers/staging/lustre/lustre/llite/file.c         | 19 ++++++-----
 .../staging/lustre/lustre/llite/llite_internal.h   |  8 ++---
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  2 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 17 ++++++----
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   | 12 +++----
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      | 14 ++++----
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  2 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  4 +--
 drivers/staging/lustre/lustre/osc/osc_request.c    |  8 ++---
 23 files changed, 114 insertions(+), 103 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 938f91b..d3fb6f9 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2687,7 +2687,7 @@ static inline int ldlm_res_eq(const struct ldlm_res_id *res0,
 }
 
 /* lock types */
-typedef enum {
+enum ldlm_mode {
 	LCK_MINMODE = 0,
 	LCK_EX      = 1,
 	LCK_PW      = 2,
@@ -2698,17 +2698,17 @@ typedef enum {
 	LCK_GROUP   = 64,
 	LCK_COS     = 128,
 	LCK_MAXMODE
-} ldlm_mode_t;
+};
 
 #define LCK_MODE_NUM    8
 
-typedef enum {
+enum ldlm_type {
 	LDLM_PLAIN     = 10,
 	LDLM_EXTENT    = 11,
 	LDLM_FLOCK     = 12,
 	LDLM_IBITS     = 13,
 	LDLM_MAX_TYPE
-} ldlm_type_t;
+};
 
 #define LDLM_MIN_TYPE LDLM_PLAIN
 
@@ -2768,15 +2768,15 @@ struct ldlm_intent {
 void lustre_swab_ldlm_intent(struct ldlm_intent *i);
 
 struct ldlm_resource_desc {
-	ldlm_type_t lr_type;
+	enum ldlm_type lr_type;
 	__u32 lr_padding;       /* also fix lustre_swab_ldlm_resource_desc */
 	struct ldlm_res_id lr_name;
 };
 
 struct ldlm_lock_desc {
 	struct ldlm_resource_desc l_resource;
-	ldlm_mode_t l_req_mode;
-	ldlm_mode_t l_granted_mode;
+	enum ldlm_mode l_req_mode;
+	enum ldlm_mode l_granted_mode;
 	ldlm_wire_policy_data_t l_policy_data;
 };
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 4aeaac9..87806a6 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -145,14 +145,15 @@ typedef enum {
 #define LCK_COMPAT_COS (LCK_COS)
 /** @} Lock Compatibility Matrix */
 
-extern ldlm_mode_t lck_compat_array[];
+extern enum ldlm_mode lck_compat_array[];
 
-static inline void lockmode_verify(ldlm_mode_t mode)
+static inline void lockmode_verify(enum ldlm_mode mode)
 {
        LASSERT(mode > LCK_MINMODE && mode < LCK_MAXMODE);
 }
 
-static inline int lockmode_compat(ldlm_mode_t exist_mode, ldlm_mode_t new_mode)
+static inline int lockmode_compat(enum ldlm_mode exist_mode,
+				  enum ldlm_mode new_mode)
 {
        return (lck_compat_array[exist_mode] & new_mode);
 }
@@ -524,7 +525,7 @@ struct ldlm_interval {
 struct ldlm_interval_tree {
 	/** Tree size. */
 	int			lit_size;
-	ldlm_mode_t		lit_mode;  /* lock mode */
+	enum ldlm_mode		lit_mode;  /* lock mode */
 	struct interval_node	*lit_root; /* actual ldlm_interval */
 };
 
@@ -556,7 +557,7 @@ typedef union {
 	struct ldlm_inodebits l_inodebits;
 } ldlm_policy_data_t;
 
-void ldlm_convert_policy_to_local(struct obd_export *exp, ldlm_type_t type,
+void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
 				  const ldlm_wire_policy_data_t *wpolicy,
 				  ldlm_policy_data_t *lpolicy);
 
@@ -634,11 +635,11 @@ struct ldlm_lock {
 	 * Requested mode.
 	 * Protected by lr_lock.
 	 */
-	ldlm_mode_t		l_req_mode;
+	enum ldlm_mode		l_req_mode;
 	/**
 	 * Granted mode, also protected by lr_lock.
 	 */
-	ldlm_mode_t		l_granted_mode;
+	enum ldlm_mode		l_granted_mode;
 	/** Lock completion handler pointer. Called when lock is granted. */
 	ldlm_completion_callback l_completion_ast;
 	/**
@@ -848,7 +849,7 @@ struct ldlm_resource {
 	/** @} */
 
 	/** Type of locks this resource can hold. Only one type per resource. */
-	ldlm_type_t		lr_type; /* LDLM_{PLAIN,EXTENT,FLOCK,IBITS} */
+	enum ldlm_type		lr_type; /* LDLM_{PLAIN,EXTENT,FLOCK,IBITS} */
 
 	/** Resource name */
 	struct ldlm_res_id	lr_name;
@@ -1161,12 +1162,13 @@ void ldlm_lock_decref_and_cancel(struct lustre_handle *lockh, __u32 mode);
 void ldlm_lock_fail_match_locked(struct ldlm_lock *lock);
 void ldlm_lock_allow_match(struct ldlm_lock *lock);
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock);
-ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
-			    const struct ldlm_res_id *, ldlm_type_t type,
-			    ldlm_policy_data_t *, ldlm_mode_t mode,
-			    struct lustre_handle *, int unref);
-ldlm_mode_t ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
-					__u64 *bits);
+enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
+			       const struct ldlm_res_id *,
+			       enum ldlm_type type, ldlm_policy_data_t *,
+			       enum ldlm_mode mode, struct lustre_handle *,
+			       int unref);
+enum ldlm_mode ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
+					   __u64 *bits);
 void ldlm_lock_cancel(struct ldlm_lock *lock);
 void ldlm_lock_dump_handle(int level, struct lustre_handle *);
 void ldlm_unlink_lock_skiplist(struct ldlm_lock *req);
@@ -1186,7 +1188,7 @@ void ldlm_debugfs_cleanup(void);
 struct ldlm_resource *ldlm_resource_get(struct ldlm_namespace *ns,
 					struct ldlm_resource *parent,
 					const struct ldlm_res_id *,
-					ldlm_type_t type, int create);
+					enum ldlm_type type, int create);
 int ldlm_resource_putref(struct ldlm_resource *res);
 void ldlm_resource_add_lock(struct ldlm_resource *res,
 			    struct list_head *head,
@@ -1237,7 +1239,8 @@ int ldlm_prep_elc_req(struct obd_export *exp,
 		      struct list_head *cancels, int count);
 
 int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
-			  ldlm_type_t type, __u8 with_policy, ldlm_mode_t mode,
+			  enum ldlm_type type, __u8 with_policy,
+			  enum ldlm_mode mode,
 			  __u64 *flags, void *lvb, __u32 lvb_len,
 			  struct lustre_handle *lockh, int rc);
 int ldlm_cli_update_pool(struct ptlrpc_request *req);
@@ -1248,13 +1251,13 @@ int ldlm_cli_cancel_unused(struct ldlm_namespace *, const struct ldlm_res_id *,
 int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 				    const struct ldlm_res_id *res_id,
 				    ldlm_policy_data_t *policy,
-				    ldlm_mode_t mode,
+				    enum ldlm_mode mode,
 				    ldlm_cancel_flags_t flags,
 				    void *opaque);
 int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			       struct list_head *cancels,
 			       ldlm_policy_data_t *policy,
-			       ldlm_mode_t mode, __u64 lock_flags,
+			       enum ldlm_mode mode, __u64 lock_flags,
 			       ldlm_cancel_flags_t cancel_flags, void *opaque);
 int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 			       ldlm_cancel_flags_t flags);
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index c4a0b00..2105a95 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -463,7 +463,7 @@ struct ptlrpc_reply_state {
 	/** Handles of locks awaiting client reply ACK */
 	struct lustre_handle   rs_locks[RS_MAX_LOCKS];
 	/** Lock modes of locks in \a rs_locks */
-	ldlm_mode_t	    rs_modes[RS_MAX_LOCKS];
+	enum ldlm_mode	    rs_modes[RS_MAX_LOCKS];
 };
 
 struct ptlrpc_thread;
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 09f1a5b..802d867 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1160,13 +1160,13 @@ struct md_ops {
 				      struct obd_client_handle *);
 	int (*set_lock_data)(struct obd_export *, __u64 *, void *, __u64 *);
 
-	ldlm_mode_t (*lock_match)(struct obd_export *, __u64,
-				  const struct lu_fid *, ldlm_type_t,
-				  ldlm_policy_data_t *, ldlm_mode_t,
-				  struct lustre_handle *);
+	enum ldlm_mode (*lock_match)(struct obd_export *, __u64,
+				     const struct lu_fid *, enum ldlm_type,
+				     ldlm_policy_data_t *, enum ldlm_mode,
+				     struct lustre_handle *);
 
 	int (*cancel_unused)(struct obd_export *, const struct lu_fid *,
-			     ldlm_policy_data_t *, ldlm_mode_t,
+			     ldlm_policy_data_t *, enum ldlm_mode,
 			     ldlm_cancel_flags_t flags, void *opaque);
 
 	int (*get_remote_perm)(struct obd_export *, const struct lu_fid *,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index a4d3600..c161a66 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1656,7 +1656,7 @@ static inline int md_set_lock_data(struct obd_export *exp,
 static inline int md_cancel_unused(struct obd_export *exp,
 				   const struct lu_fid *fid,
 				   ldlm_policy_data_t *policy,
-				   ldlm_mode_t mode,
+				   enum ldlm_mode mode,
 				   ldlm_cancel_flags_t flags,
 				   void *opaque)
 {
@@ -1670,12 +1670,12 @@ static inline int md_cancel_unused(struct obd_export *exp,
 	return rc;
 }
 
-static inline ldlm_mode_t md_lock_match(struct obd_export *exp, __u64 flags,
-					const struct lu_fid *fid,
-					ldlm_type_t type,
-					ldlm_policy_data_t *policy,
-					ldlm_mode_t mode,
-					struct lustre_handle *lockh)
+static inline enum ldlm_mode md_lock_match(struct obd_export *exp, __u64 flags,
+					   const struct lu_fid *fid,
+					   enum ldlm_type type,
+					   ldlm_policy_data_t *policy,
+					   enum ldlm_mode mode,
+					   struct lustre_handle *lockh)
 {
 	EXP_CHECK_MD_OP(exp, lock_match);
 	EXP_MD_COUNTER_INCREMENT(exp, lock_match);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index aa92682..f07a077 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -144,7 +144,7 @@ struct ldlm_interval *ldlm_interval_detach(struct ldlm_lock *l)
 	return list_empty(&n->li_group) ? n : NULL;
 }
 
-static inline int lock_mode_to_index(ldlm_mode_t mode)
+static inline int lock_mode_to_index(enum ldlm_mode mode)
 {
 	int index;
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 7c671e3..699e81d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -92,7 +92,7 @@ ldlm_flocks_overlap(struct ldlm_lock *lock, struct ldlm_lock *new)
 }
 
 static inline void
-ldlm_flock_destroy(struct ldlm_lock *lock, ldlm_mode_t mode, __u64 flags)
+ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
 {
 	LDLM_DEBUG(lock, "ldlm_flock_destroy(mode: %d, flags: 0x%llx)",
 		   mode, flags);
@@ -143,7 +143,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
 	struct ldlm_lock *lock = NULL;
 	struct ldlm_lock *new = req;
 	struct ldlm_lock *new2 = NULL;
-	ldlm_mode_t mode = req->l_req_mode;
+	enum ldlm_mode mode = req->l_req_mode;
 	int added = (mode == LCK_NL);
 	int overlaps = 0;
 	int splitted = 0;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 849cc98..6d4f324 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -133,7 +133,7 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 		  enum req_location loc, void *data, int size);
 struct ldlm_lock *
 ldlm_lock_create(struct ldlm_namespace *ns, const struct ldlm_res_id *,
-		 ldlm_type_t type, ldlm_mode_t,
+		 enum ldlm_type type, enum ldlm_mode mode,
 		 const struct ldlm_callback_suite *cbs,
 		 void *data, __u32 lvb_len, enum lvb_type lvb_type);
 ldlm_error_t ldlm_lock_enqueue(struct ldlm_namespace *, struct ldlm_lock **,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 0e25c45..68bf57b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -718,7 +718,7 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 }
 EXPORT_SYMBOL(target_send_reply);
 
-ldlm_mode_t lck_compat_array[] = {
+enum ldlm_mode lck_compat_array[] = {
 	[LCK_EX]	= LCK_COMPAT_EX,
 	[LCK_PW]	= LCK_COMPAT_PW,
 	[LCK_PR]	= LCK_COMPAT_PR,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 8f75139..073dcf8 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -91,7 +91,7 @@ static ldlm_policy_local_to_wire_t ldlm_policy_local_to_wire[] = {
 /**
  * Converts lock policy from local format to on the wire lock_desc format
  */
-static void ldlm_convert_policy_to_wire(ldlm_type_t type,
+static void ldlm_convert_policy_to_wire(enum ldlm_type type,
 					const ldlm_policy_data_t *lpolicy,
 					ldlm_wire_policy_data_t *wpolicy)
 {
@@ -105,7 +105,7 @@ static void ldlm_convert_policy_to_wire(ldlm_type_t type,
 /**
  * Converts lock policy from on the wire lock_desc format to local format
  */
-void ldlm_convert_policy_to_local(struct obd_export *exp, ldlm_type_t type,
+void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
 				  const ldlm_wire_policy_data_t *wpolicy,
 				  ldlm_policy_data_t *lpolicy)
 {
@@ -1046,7 +1046,7 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
  * comment above ldlm_lock_match
  */
 static struct ldlm_lock *search_queue(struct list_head *queue,
-				      ldlm_mode_t *mode,
+				      enum ldlm_mode *mode,
 				      ldlm_policy_data_t *policy,
 				      struct ldlm_lock *old_lock,
 				      __u64 flags, int unref)
@@ -1055,7 +1055,7 @@ static struct ldlm_lock *search_queue(struct list_head *queue,
 	struct list_head       *tmp;
 
 	list_for_each(tmp, queue) {
-		ldlm_mode_t match;
+		enum ldlm_mode match;
 
 		lock = list_entry(tmp, struct ldlm_lock, l_res_link);
 
@@ -1188,10 +1188,12 @@ EXPORT_SYMBOL(ldlm_lock_allow_match);
  * keep caller code unchanged), the context failure will be discovered by
  * caller sometime later.
  */
-ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
-			    const struct ldlm_res_id *res_id, ldlm_type_t type,
-			    ldlm_policy_data_t *policy, ldlm_mode_t mode,
-			    struct lustre_handle *lockh, int unref)
+enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
+			       const struct ldlm_res_id *res_id,
+			       enum ldlm_type type,
+			       ldlm_policy_data_t *policy,
+			       enum ldlm_mode mode,
+			       struct lustre_handle *lockh, int unref)
 {
 	struct ldlm_resource *res;
 	struct ldlm_lock *lock, *old_lock = NULL;
@@ -1313,11 +1315,11 @@ ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 }
 EXPORT_SYMBOL(ldlm_lock_match);
 
-ldlm_mode_t ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
-					__u64 *bits)
+enum ldlm_mode ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
+					   __u64 *bits)
 {
 	struct ldlm_lock *lock;
-	ldlm_mode_t mode = 0;
+	enum ldlm_mode mode = 0;
 
 	lock = ldlm_handle2lock(lockh);
 	if (lock) {
@@ -1449,8 +1451,8 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
  */
 struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 				   const struct ldlm_res_id *res_id,
-				   ldlm_type_t type,
-				   ldlm_mode_t mode,
+				   enum ldlm_type type,
+				   enum ldlm_mode mode,
 				   const struct ldlm_callback_suite *cbs,
 				   void *data, __u32 lvb_len,
 				   enum lvb_type lvb_type)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index de276af..05aa8bb 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -331,7 +331,8 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
  * Called after receiving reply from server.
  */
 int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
-			  ldlm_type_t type, __u8 with_policy, ldlm_mode_t mode,
+			  enum ldlm_type type, __u8 with_policy,
+			  enum ldlm_mode mode,
 			  __u64 *flags, void *lvb, __u32 lvb_len,
 			  struct lustre_handle *lockh, int rc)
 {
@@ -1465,7 +1466,7 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			       struct list_head *cancels,
 			       ldlm_policy_data_t *policy,
-			       ldlm_mode_t mode, __u64 lock_flags,
+			       enum ldlm_mode mode, __u64 lock_flags,
 			       ldlm_cancel_flags_t cancel_flags, void *opaque)
 {
 	struct ldlm_lock *lock;
@@ -1578,7 +1579,7 @@ EXPORT_SYMBOL(ldlm_cli_cancel_list);
 int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 				    const struct ldlm_res_id *res_id,
 				    ldlm_policy_data_t *policy,
-				    ldlm_mode_t mode,
+				    enum ldlm_mode mode,
 				    ldlm_cancel_flags_t flags,
 				    void *opaque)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index fede185..f9d0383 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1065,7 +1065,8 @@ static struct ldlm_resource *ldlm_resource_new(void)
  */
 struct ldlm_resource *
 ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
-		  const struct ldlm_res_id *name, ldlm_type_t type, int create)
+		  const struct ldlm_res_id *name, enum ldlm_type type,
+		  int create)
 {
 	struct hlist_node     *hnode;
 	struct ldlm_resource *res;
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index d7dc264..c2ee7fc 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -332,7 +332,7 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 	struct lustre_handle lockh;
 	struct lu_dirpage *dp;
 	struct page *page;
-	ldlm_mode_t mode;
+	enum ldlm_mode mode;
 	int rc;
 	__u64 start = 0;
 	__u64 end = 0;
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index c4f3edc..bbe6ebf 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2780,11 +2780,12 @@ ll_file_noflock(struct file *file, int cmd, struct file_lock *file_lock)
  * \param l_req_mode [IN] searched lock mode
  * \retval boolean, true iff all bits are found
  */
-int ll_have_md_lock(struct inode *inode, __u64 *bits,  ldlm_mode_t l_req_mode)
+int ll_have_md_lock(struct inode *inode, __u64 *bits,
+		    enum ldlm_mode l_req_mode)
 {
 	struct lustre_handle lockh;
 	ldlm_policy_data_t policy;
-	ldlm_mode_t mode = (l_req_mode == LCK_MINMODE) ?
+	enum ldlm_mode mode = (l_req_mode == LCK_MINMODE) ?
 				(LCK_CR|LCK_CW|LCK_PR|LCK_PW) : l_req_mode;
 	struct lu_fid *fid;
 	__u64 flags;
@@ -2820,13 +2821,13 @@ int ll_have_md_lock(struct inode *inode, __u64 *bits,  ldlm_mode_t l_req_mode)
 	return *bits == 0;
 }
 
-ldlm_mode_t ll_take_md_lock(struct inode *inode, __u64 bits,
-			    struct lustre_handle *lockh, __u64 flags,
-			    ldlm_mode_t mode)
+enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
+			       struct lustre_handle *lockh, __u64 flags,
+			       enum ldlm_mode mode)
 {
 	ldlm_policy_data_t policy = { .l_inodebits = {bits} };
 	struct lu_fid *fid;
-	ldlm_mode_t rc;
+	enum ldlm_mode rc;
 
 	fid = &ll_i2info(inode)->lli_fid;
 	CDEBUG(D_INFO, "trying to match res "DFID"\n", PFID(fid));
@@ -3356,8 +3357,8 @@ out:
  * Apply the layout to the inode. Layout lock is held and will be released
  * in this function.
  */
-static int ll_layout_lock_set(struct lustre_handle *lockh, ldlm_mode_t mode,
-				struct inode *inode, __u32 *gen, bool reconf)
+static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
+			      struct inode *inode, __u32 *gen, bool reconf)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info    *sbi = ll_i2sbi(inode);
@@ -3479,7 +3480,7 @@ int ll_layout_refresh(struct inode *inode, __u32 *gen)
 	struct md_op_data     *op_data;
 	struct lookup_intent   it;
 	struct lustre_handle   lockh;
-	ldlm_mode_t	       mode;
+	enum ldlm_mode	       mode;
 	struct ldlm_enqueue_info einfo = {
 		.ei_type = LDLM_IBITS,
 		.ei_mode = LCK_CR,
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 7dbe86a..46144ff 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -705,10 +705,10 @@ extern struct file_operations ll_file_operations_flock;
 extern struct file_operations ll_file_operations_noflock;
 extern const struct inode_operations ll_file_inode_operations;
 int ll_have_md_lock(struct inode *inode, __u64 *bits,
-		    ldlm_mode_t l_req_mode);
-ldlm_mode_t ll_take_md_lock(struct inode *inode, __u64 bits,
-			    struct lustre_handle *lockh, __u64 flags,
-			    ldlm_mode_t mode);
+		    enum ldlm_mode l_req_mode);
+enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
+			       struct lustre_handle *lockh, __u64 flags,
+			       enum ldlm_mode mode);
 int ll_file_open(struct inode *inode, struct file *file);
 int ll_file_release(struct inode *inode, struct file *file);
 int ll_glimpse_ioctl(struct ll_sb_info *sbi,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 2440b07..67b4b80 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1598,7 +1598,7 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 		if (exp_connect_som(ll_i2mdexp(inode)) &&
 		    S_ISREG(inode->i_mode)) {
 			struct lustre_handle lockh;
-			ldlm_mode_t mode;
+			enum ldlm_mode mode;
 
 			/* As it is possible a blocking ast has been processed
 			 * by this time, we need to check there is an UPDATE
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index ed6e073..fe8df91 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -266,7 +266,7 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 				  struct lookup_intent *oit,
 				  struct ptlrpc_request **req)
 {
-	ldlm_mode_t mode;
+	enum ldlm_mode mode;
 	struct lustre_handle lockh = { 0 };
 	struct md_op_data *op_data;
 	struct ll_inode_info *lli = ll_i2info(inode);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 2df369a..a405bc7 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1846,7 +1846,8 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 	 NULL)
 
 static int lmv_early_cancel(struct obd_export *exp, struct md_op_data *op_data,
-			    int op_tgt, ldlm_mode_t mode, int bits, int flag)
+			    int op_tgt, enum ldlm_mode mode, int bits,
+			    int flag)
 {
 	struct lu_fid	  *fid = md_op_data_fid(op_data, flag);
 	struct obd_device      *obd = exp->exp_obd;
@@ -2489,7 +2490,7 @@ static int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 }
 
 static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
-			     ldlm_policy_data_t *policy, ldlm_mode_t mode,
+			     ldlm_policy_data_t *policy, enum ldlm_mode mode,
 			     ldlm_cancel_flags_t flags, void *opaque)
 {
 	struct obd_device       *obd = exp->exp_obd;
@@ -2523,14 +2524,16 @@ static int lmv_set_lock_data(struct obd_export *exp, __u64 *lockh, void *data,
 	return rc;
 }
 
-static ldlm_mode_t lmv_lock_match(struct obd_export *exp, __u64 flags,
-				  const struct lu_fid *fid, ldlm_type_t type,
-				  ldlm_policy_data_t *policy, ldlm_mode_t mode,
-				  struct lustre_handle *lockh)
+static enum ldlm_mode lmv_lock_match(struct obd_export *exp, __u64 flags,
+				     const struct lu_fid *fid,
+				     enum ldlm_type type,
+				     ldlm_policy_data_t *policy,
+				     enum ldlm_mode mode,
+				     struct lustre_handle *lockh)
 {
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
-	ldlm_mode_t	      rc;
+	enum ldlm_mode	      rc;
 	int		      i;
 
 	CDEBUG(D_INODE, "Lock match for "DFID"\n", PFID(fid));
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 3d2997a..095f3b5 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -90,7 +90,7 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		struct ptlrpc_request **req, __u64 extra_lock_flags);
 
 int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
-			    struct list_head *cancels, ldlm_mode_t mode,
+			    struct list_head *cancels, enum ldlm_mode  mode,
 			    __u64 bits);
 /* mdc/mdc_request.c */
 int mdc_fid_alloc(struct obd_export *exp, struct lu_fid *fid,
@@ -119,7 +119,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	       struct ptlrpc_request **request);
 int mdc_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
-		      ldlm_policy_data_t *policy, ldlm_mode_t mode,
+		      ldlm_policy_data_t *policy, enum ldlm_mode mode,
 		      ldlm_cancel_flags_t flags, void *opaque);
 
 int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
@@ -129,10 +129,10 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 			     struct md_enqueue_info *minfo,
 			     struct ldlm_enqueue_info *einfo);
 
-ldlm_mode_t mdc_lock_match(struct obd_export *exp, __u64 flags,
-			   const struct lu_fid *fid, ldlm_type_t type,
-			   ldlm_policy_data_t *policy, ldlm_mode_t mode,
-			   struct lustre_handle *lockh);
+enum ldlm_mode mdc_lock_match(struct obd_export *exp, __u64 flags,
+			      const struct lu_fid *fid, enum ldlm_type type,
+			      ldlm_policy_data_t *policy, enum ldlm_mode mode,
+			      struct lustre_handle *lockh);
 
 static inline int mdc_prep_elc_req(struct obd_export *exp,
 				   struct ptlrpc_request *req, int opc,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 09dd2b3..f785eb6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -151,13 +151,13 @@ int mdc_set_lock_data(struct obd_export *exp, __u64 *lockh, void *data,
 	return 0;
 }
 
-ldlm_mode_t mdc_lock_match(struct obd_export *exp, __u64 flags,
-			   const struct lu_fid *fid, ldlm_type_t type,
-			   ldlm_policy_data_t *policy, ldlm_mode_t mode,
-			   struct lustre_handle *lockh)
+enum ldlm_mode mdc_lock_match(struct obd_export *exp, __u64 flags,
+			      const struct lu_fid *fid, enum ldlm_type type,
+			      ldlm_policy_data_t *policy, enum ldlm_mode mode,
+			      struct lustre_handle *lockh)
 {
 	struct ldlm_res_id res_id;
-	ldlm_mode_t rc;
+	enum ldlm_mode rc;
 
 	fid_build_reg_res_name(fid, &res_id);
 	/* LU-4405: Clear bits not supported by server */
@@ -170,7 +170,7 @@ ldlm_mode_t mdc_lock_match(struct obd_export *exp, __u64 flags,
 int mdc_cancel_unused(struct obd_export *exp,
 		      const struct lu_fid *fid,
 		      ldlm_policy_data_t *policy,
-		      ldlm_mode_t mode,
+		      enum ldlm_mode mode,
 		      ldlm_cancel_flags_t flags,
 		      void *opaque)
 {
@@ -1036,7 +1036,7 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	struct ldlm_res_id res_id;
 	struct lustre_handle lockh;
 	ldlm_policy_data_t policy;
-	ldlm_mode_t mode;
+	enum ldlm_mode mode;
 
 	if (it->d.lustre.it_lock_handle) {
 		lockh.cookie = it->d.lustre.it_lock_handle;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index ddeb4b4..dd87914 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -67,7 +67,7 @@ static int mdc_reint(struct ptlrpc_request *request,
  * found by @fid. Found locks are added into @cancel list. Returns the amount of
  * locks added to @cancels list. */
 int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
-			    struct list_head *cancels, ldlm_mode_t mode,
+			    struct list_head *cancels, enum ldlm_mode mode,
 			    __u64 bits)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 73d43ab..861642b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -522,7 +522,7 @@ static inline struct cl_object *osc2cl(const struct osc_object *obj)
 	return (struct cl_object *)&obj->oo_cl;
 }
 
-static inline ldlm_mode_t osc_cl_lock2ldlm(enum cl_lock_mode mode)
+static inline enum ldlm_mode osc_cl_lock2ldlm(enum cl_lock_mode mode)
 {
 	LASSERT(mode == CLM_READ || mode == CLM_WRITE || mode == CLM_GROUP);
 	if (mode == CLM_READ)
@@ -533,7 +533,7 @@ static inline ldlm_mode_t osc_cl_lock2ldlm(enum cl_lock_mode mode)
 		return LCK_GROUP;
 }
 
-static inline enum cl_lock_mode osc_ldlm2cl_lock(ldlm_mode_t mode)
+static inline enum cl_lock_mode osc_ldlm2cl_lock(enum ldlm_mode mode)
 {
 	LASSERT(mode == LCK_PR || mode == LCK_PW || mode == LCK_GROUP);
 	if (mode == LCK_PR)
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index cb9587f..c98e951 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -631,7 +631,7 @@ int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
  * locks added to @cancels list. */
 static int osc_resource_get_unused(struct obd_export *exp, struct obdo *oa,
 				   struct list_head *cancels,
-				   ldlm_mode_t mode, __u64 lock_flags)
+				   enum ldlm_mode mode, __u64 lock_flags)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
 	struct ldlm_res_id res_id;
@@ -2195,7 +2195,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	struct ptlrpc_request *req = NULL;
 	int intent = *flags & LDLM_FL_HAS_INTENT;
 	__u64 match_lvb = (agl != 0 ? 0 : LDLM_FL_LVB_READY);
-	ldlm_mode_t mode;
+	enum ldlm_mode mode;
 	int rc;
 
 	/* Filesystem lock extents are extended to page boundaries so that
@@ -2338,7 +2338,7 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 {
 	struct obd_device *obd = exp->exp_obd;
 	__u64 lflags = *flags;
-	ldlm_mode_t rc;
+	enum ldlm_mode rc;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_MATCH))
 		return -EIO;
@@ -2733,7 +2733,7 @@ out:
 		struct ldlm_res_id res_id;
 		ldlm_policy_data_t policy;
 		struct lustre_handle lockh;
-		ldlm_mode_t mode = 0;
+		enum ldlm_mode mode = 0;
 		struct ptlrpc_request *req;
 		struct ll_user_fiemap *reply;
 		char *tmp;
-- 
2.1.0
