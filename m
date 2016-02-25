From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:05 -0500
Subject: [lustre-devel] [PATCH v2 22/84] staging/lustre: Get rid of
	ldlm_cancel_flags_t typedef
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-23-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum ldlm_cancel_flags

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 18 ++++++++++--------
 drivers/staging/lustre/lustre/include/obd.h        |  2 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  6 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 10 +++++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 20 +++++++++++---------
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  2 +-
 9 files changed, 34 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index ab40bc7..4ab34dd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -533,12 +533,12 @@ struct ldlm_interval_tree {
 #define LUSTRE_TRACKS_LOCK_EXP_REFS (0)
 
 /** Cancel flags. */
-typedef enum {
+enum ldlm_cancel_flags {
 	LCF_ASYNC      = 0x1, /* Cancel locks asynchronously. */
 	LCF_LOCAL      = 0x2, /* Cancel locks locally, not notifing server */
 	LCF_BL_AST     = 0x4, /* Cancel locks marked as LDLM_FL_BL_AST
 			       * in the same RPC */
-} ldlm_cancel_flags_t;
+};
 
 struct ldlm_flock {
 	__u64 start;
@@ -1245,24 +1245,26 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  struct lustre_handle *lockh, int rc);
 int ldlm_cli_update_pool(struct ptlrpc_request *req);
 int ldlm_cli_cancel(struct lustre_handle *lockh,
-		    ldlm_cancel_flags_t cancel_flags);
+		    enum ldlm_cancel_flags cancel_flags);
 int ldlm_cli_cancel_unused(struct ldlm_namespace *, const struct ldlm_res_id *,
-			   ldlm_cancel_flags_t flags, void *opaque);
+			   enum ldlm_cancel_flags flags, void *opaque);
 int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 				    const struct ldlm_res_id *res_id,
 				    ldlm_policy_data_t *policy,
 				    enum ldlm_mode mode,
-				    ldlm_cancel_flags_t flags,
+				    enum ldlm_cancel_flags flags,
 				    void *opaque);
 int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			       struct list_head *cancels,
 			       ldlm_policy_data_t *policy,
 			       enum ldlm_mode mode, __u64 lock_flags,
-			       ldlm_cancel_flags_t cancel_flags, void *opaque);
+			       enum ldlm_cancel_flags cancel_flags,
+			       void *opaque);
 int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
-			       ldlm_cancel_flags_t flags);
+			       enum ldlm_cancel_flags flags);
 int ldlm_cli_cancel_list(struct list_head *head, int count,
-			 struct ptlrpc_request *req, ldlm_cancel_flags_t flags);
+			 struct ptlrpc_request *req,
+			 enum ldlm_cancel_flags flags);
 /** @} ldlm_cli_api */
 
 /* mds/handler.c */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 802d867..1d9207b 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1167,7 +1167,7 @@ struct md_ops {
 
 	int (*cancel_unused)(struct obd_export *, const struct lu_fid *,
 			     ldlm_policy_data_t *, enum ldlm_mode,
-			     ldlm_cancel_flags_t flags, void *opaque);
+			     enum ldlm_cancel_flags flags, void *opaque);
 
 	int (*get_remote_perm)(struct obd_export *, const struct lu_fid *,
 			       __u32, struct ptlrpc_request **);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index c161a66..163dd55 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1657,7 +1657,7 @@ static inline int md_cancel_unused(struct obd_export *exp,
 				   const struct lu_fid *fid,
 				   ldlm_policy_data_t *policy,
 				   enum ldlm_mode mode,
-				   ldlm_cancel_flags_t flags,
+				   enum ldlm_cancel_flags flags,
 				   void *opaque)
 {
 	int rc;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index ed27822..2139a3a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -100,10 +100,10 @@ enum {
 };
 
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
-		    ldlm_cancel_flags_t sync, int flags);
+		    enum ldlm_cancel_flags sync, int flags);
 int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
 			 struct list_head *cancels, int count, int max,
-			 ldlm_cancel_flags_t cancel_flags, int flags);
+			 enum ldlm_cancel_flags cancel_flags, int flags);
 extern int ldlm_enqueue_min;
 
 /* ldlm_resource.c */
@@ -154,7 +154,7 @@ int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
 int ldlm_bl_to_thread_list(struct ldlm_namespace *ns,
 			   struct ldlm_lock_desc *ld,
 			   struct list_head *cancels, int count,
-			   ldlm_cancel_flags_t cancel_flags);
+			   enum ldlm_cancel_flags cancel_flags);
 
 void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 0737ded..209db5d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -107,7 +107,7 @@ struct ldlm_bl_work_item {
 	struct list_head	      blwi_head;
 	int		     blwi_count;
 	struct completion	blwi_comp;
-	ldlm_cancel_flags_t     blwi_flags;
+	enum ldlm_cancel_flags  blwi_flags;
 	int		     blwi_mem_pressure;
 };
 
@@ -353,7 +353,7 @@ static int ldlm_callback_reply(struct ptlrpc_request *req, int rc)
 }
 
 static int __ldlm_bl_to_thread(struct ldlm_bl_work_item *blwi,
-			       ldlm_cancel_flags_t cancel_flags)
+			       enum ldlm_cancel_flags cancel_flags)
 {
 	struct ldlm_bl_pool *blp = ldlm_state->ldlm_bl_pool;
 
@@ -383,7 +383,7 @@ static inline void init_blwi(struct ldlm_bl_work_item *blwi,
 			     struct ldlm_lock_desc *ld,
 			     struct list_head *cancels, int count,
 			     struct ldlm_lock *lock,
-			     ldlm_cancel_flags_t cancel_flags)
+			     enum ldlm_cancel_flags cancel_flags)
 {
 	init_completion(&blwi->blwi_comp);
 	INIT_LIST_HEAD(&blwi->blwi_head);
@@ -417,7 +417,7 @@ static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
 			     struct ldlm_lock_desc *ld,
 			     struct ldlm_lock *lock,
 			     struct list_head *cancels, int count,
-			     ldlm_cancel_flags_t cancel_flags)
+			     enum ldlm_cancel_flags cancel_flags)
 {
 	if (cancels && count == 0)
 		return 0;
@@ -451,7 +451,7 @@ int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
 
 int ldlm_bl_to_thread_list(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
 			   struct list_head *cancels, int count,
-			   ldlm_cancel_flags_t cancel_flags)
+			   enum ldlm_cancel_flags cancel_flags)
 {
 	return ldlm_bl_to_thread(ns, ld, NULL, cancels, count, cancel_flags);
 }
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 05aa8bb..718e3c3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -860,7 +860,7 @@ static void ldlm_cancel_pack(struct ptlrpc_request *req,
  * handles of locks given in \a cancels list. */
 static int ldlm_cli_cancel_req(struct obd_export *exp,
 			       struct list_head *cancels,
-			       int count, ldlm_cancel_flags_t flags)
+			       int count, enum ldlm_cancel_flags flags)
 {
 	struct ptlrpc_request *req = NULL;
 	struct obd_import *imp;
@@ -1003,7 +1003,7 @@ EXPORT_SYMBOL(ldlm_cli_update_pool);
  * Lock must not have any readers or writers by this time.
  */
 int ldlm_cli_cancel(struct lustre_handle *lockh,
-		    ldlm_cancel_flags_t cancel_flags)
+		    enum ldlm_cancel_flags cancel_flags)
 {
 	struct obd_export *exp;
 	int avail, flags, count = 1;
@@ -1053,7 +1053,7 @@ EXPORT_SYMBOL(ldlm_cli_cancel);
  * Return the number of cancelled locks.
  */
 int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
-			       ldlm_cancel_flags_t flags)
+			       enum ldlm_cancel_flags flags)
 {
 	LIST_HEAD(head);
 	struct ldlm_lock *lock, *next;
@@ -1423,7 +1423,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 
 int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
 			  struct list_head *cancels, int count, int max,
-			  ldlm_cancel_flags_t cancel_flags, int flags)
+			  enum ldlm_cancel_flags cancel_flags, int flags)
 {
 	int added;
 
@@ -1442,7 +1442,7 @@ int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
  * callback will be performed in this function.
  */
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
-		    ldlm_cancel_flags_t cancel_flags,
+		    enum ldlm_cancel_flags cancel_flags,
 		    int flags)
 {
 	LIST_HEAD(cancels);
@@ -1467,7 +1467,8 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			       struct list_head *cancels,
 			       ldlm_policy_data_t *policy,
 			       enum ldlm_mode mode, __u64 lock_flags,
-			       ldlm_cancel_flags_t cancel_flags, void *opaque)
+			       enum ldlm_cancel_flags cancel_flags,
+			       void *opaque)
 {
 	struct ldlm_lock *lock;
 	int count = 0;
@@ -1525,7 +1526,8 @@ EXPORT_SYMBOL(ldlm_cancel_resource_local);
  * Destroy \a cancels at the end.
  */
 int ldlm_cli_cancel_list(struct list_head *cancels, int count,
-			 struct ptlrpc_request *req, ldlm_cancel_flags_t flags)
+			 struct ptlrpc_request *req,
+			 enum ldlm_cancel_flags flags)
 {
 	struct ldlm_lock *lock;
 	int res = 0;
@@ -1580,7 +1582,7 @@ int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 				    const struct ldlm_res_id *res_id,
 				    ldlm_policy_data_t *policy,
 				    enum ldlm_mode mode,
-				    ldlm_cancel_flags_t flags,
+				    enum ldlm_cancel_flags flags,
 				    void *opaque)
 {
 	struct ldlm_resource *res;
@@ -1636,7 +1638,7 @@ static int ldlm_cli_hash_cancel_unused(struct cfs_hash *hs,
  * to notify the server. */
 int ldlm_cli_cancel_unused(struct ldlm_namespace *ns,
 			   const struct ldlm_res_id *res_id,
-			   ldlm_cancel_flags_t flags, void *opaque)
+			   enum ldlm_cancel_flags flags, void *opaque)
 {
 	struct ldlm_cli_cancel_arg arg = {
 		.lc_flags       = flags,
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index a405bc7..eb1c85f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2491,7 +2491,7 @@ static int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 
 static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 			     ldlm_policy_data_t *policy, enum ldlm_mode mode,
-			     ldlm_cancel_flags_t flags, void *opaque)
+			     enum ldlm_cancel_flags flags, void *opaque)
 {
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 095f3b5..54f4ca6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -120,7 +120,7 @@ int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	       struct ptlrpc_request **request);
 int mdc_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 		      ldlm_policy_data_t *policy, enum ldlm_mode mode,
-		      ldlm_cancel_flags_t flags, void *opaque);
+		      enum ldlm_cancel_flags flags, void *opaque);
 
 int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 			struct lu_fid *fid, __u64 *bits);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index f785eb6..ae648d0 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -171,7 +171,7 @@ int mdc_cancel_unused(struct obd_export *exp,
 		      const struct lu_fid *fid,
 		      ldlm_policy_data_t *policy,
 		      enum ldlm_mode mode,
-		      ldlm_cancel_flags_t flags,
+		      enum ldlm_cancel_flags flags,
 		      void *opaque)
 {
 	struct ldlm_res_id res_id;
-- 
2.1.0
