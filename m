From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 Nov 2016 17:59:47 -0500
Subject: [lustre-devel] [PATCH 1/5] staging: lustre: ldlm: remove
	ldlm_policy_data_t typedef usage from code
In-Reply-To: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
References: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479941991-30059-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Replace usage of ldlm_policy_data_t with named enums
to conform to upstream coding style.

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
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   16 ++++++------
 drivers/staging/lustre/lustre/include/obd.h        |    6 ++--
 drivers/staging/lustre/lustre/include/obd_class.h  |    6 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |    4 +-
 .../staging/lustre/lustre/ldlm/ldlm_inodebits.c    |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   20 +++++++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   10 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c    |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    6 ++--
 drivers/staging/lustre/lustre/llite/file.c         |   10 ++++---
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   11 ++++----
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    7 +++--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   26 ++++++++++----------
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    2 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    5 ++-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    4 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    6 ++--
 drivers/staging/lustre/lustre/osc/osc_object.c     |    2 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |    3 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    4 +-
 25 files changed, 87 insertions(+), 81 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index d94237d..02921bf 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -553,15 +553,15 @@ struct ldlm_flock {
 	__u32 pid;
 };
 
-typedef union {
+union ldlm_policy_data {
 	struct ldlm_extent l_extent;
 	struct ldlm_flock l_flock;
 	struct ldlm_inodebits l_inodebits;
-} ldlm_policy_data_t;
+};
 
 void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
 				  const ldlm_wire_policy_data_t *wpolicy,
-				  ldlm_policy_data_t *lpolicy);
+				  union ldlm_policy_data *lpolicy);
 
 enum lvb_type {
 	LVB_T_NONE	= 0,
@@ -690,7 +690,7 @@ struct ldlm_lock {
 	 * Representation of private data specific for a lock type.
 	 * Examples are: extent range for extent lock or bitmask for ibits locks
 	 */
-	ldlm_policy_data_t	l_policy_data;
+	union ldlm_policy_data	l_policy_data;
 
 	/**
 	 * Lock state flags. Protected by lr_lock.
@@ -1175,7 +1175,7 @@ static inline int ldlm_res_lvbo_update(struct ldlm_resource *res,
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock);
 enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 			       const struct ldlm_res_id *,
-			       enum ldlm_type type, ldlm_policy_data_t *,
+			       enum ldlm_type type, union ldlm_policy_data *,
 			       enum ldlm_mode mode, struct lustre_handle *,
 			       int unref);
 enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
@@ -1239,7 +1239,7 @@ int ldlm_lock_change_resource(struct ldlm_namespace *, struct ldlm_lock *,
 int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		     struct ldlm_enqueue_info *einfo,
 		     const struct ldlm_res_id *res_id,
-		     ldlm_policy_data_t const *policy, __u64 *flags,
+		     union ldlm_policy_data const *policy, __u64 *flags,
 		     void *lvb, __u32 lvb_len, enum lvb_type lvb_type,
 		     struct lustre_handle *lockh, int async);
 int ldlm_prep_enqueue_req(struct obd_export *exp,
@@ -1263,13 +1263,13 @@ int ldlm_cli_cancel_unused(struct ldlm_namespace *, const struct ldlm_res_id *,
 			   enum ldlm_cancel_flags flags, void *opaque);
 int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 				    const struct ldlm_res_id *res_id,
-				    ldlm_policy_data_t *policy,
+				    union ldlm_policy_data *policy,
 				    enum ldlm_mode mode,
 				    enum ldlm_cancel_flags flags,
 				    void *opaque);
 int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			       struct list_head *cancels,
-			       ldlm_policy_data_t *policy,
+			       union ldlm_policy_data *policy,
 			       enum ldlm_mode mode, __u64 lock_flags,
 			       enum ldlm_cancel_flags cancel_flags,
 			       void *opaque);
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 60efaaa..d4d2ffa 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -879,7 +879,7 @@ struct md_ops {
 		      const void *, size_t, umode_t, uid_t, gid_t,
 		      cfs_cap_t, __u64, struct ptlrpc_request **);
 	int (*enqueue)(struct obd_export *, struct ldlm_enqueue_info *,
-		       const ldlm_policy_data_t *,
+		       const union ldlm_policy_data *,
 		       struct lookup_intent *, struct md_op_data *,
 		       struct lustre_handle *, __u64);
 	int (*getattr)(struct obd_export *, struct md_op_data *,
@@ -935,11 +935,11 @@ struct md_ops {
 
 	enum ldlm_mode (*lock_match)(struct obd_export *, __u64,
 				     const struct lu_fid *, enum ldlm_type,
-				     ldlm_policy_data_t *, enum ldlm_mode,
+				     union ldlm_policy_data *, enum ldlm_mode,
 				     struct lustre_handle *);
 
 	int (*cancel_unused)(struct obd_export *, const struct lu_fid *,
-			     ldlm_policy_data_t *, enum ldlm_mode,
+			     union ldlm_policy_data *, enum ldlm_mode,
 			     enum ldlm_cancel_flags flags, void *opaque);
 
 	int (*get_fid_from_lsm)(struct obd_export *,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 9099b51..7ec2520 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1208,7 +1208,7 @@ static inline int md_create(struct obd_export *exp, struct md_op_data *op_data,
 
 static inline int md_enqueue(struct obd_export *exp,
 			     struct ldlm_enqueue_info *einfo,
-			     const ldlm_policy_data_t *policy,
+			     const union ldlm_policy_data *policy,
 			     struct lookup_intent *it,
 			     struct md_op_data *op_data,
 			     struct lustre_handle *lockh,
@@ -1407,7 +1407,7 @@ static inline int md_set_lock_data(struct obd_export *exp,
 
 static inline int md_cancel_unused(struct obd_export *exp,
 				   const struct lu_fid *fid,
-				   ldlm_policy_data_t *policy,
+				   union ldlm_policy_data *policy,
 				   enum ldlm_mode mode,
 				   enum ldlm_cancel_flags flags,
 				   void *opaque)
@@ -1425,7 +1425,7 @@ static inline int md_cancel_unused(struct obd_export *exp,
 static inline enum ldlm_mode md_lock_match(struct obd_export *exp, __u64 flags,
 					   const struct lu_fid *fid,
 					   enum ldlm_type type,
-					   ldlm_policy_data_t *policy,
+					   union ldlm_policy_data *policy,
 					   enum ldlm_mode mode,
 					   struct lustre_handle *lockh)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index a7b34e4..78cd70d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -241,7 +241,7 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 }
 
 void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				      ldlm_policy_data_t *lpolicy)
+				      union ldlm_policy_data *lpolicy)
 {
 	memset(lpolicy, 0, sizeof(*lpolicy));
 	lpolicy->l_extent.start = wpolicy->l_extent.start;
@@ -249,7 +249,7 @@ void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
 	lpolicy->l_extent.gid = wpolicy->l_extent.gid;
 }
 
-void ldlm_extent_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
+void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				      ldlm_wire_policy_data_t *wpolicy)
 {
 	memset(wpolicy, 0, sizeof(*wpolicy));
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 98838e7..2683a7b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -613,7 +613,7 @@ struct ldlm_flock_wait_data {
 EXPORT_SYMBOL(ldlm_flock_completion_ast);
 
 void ldlm_flock_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy)
+				     union ldlm_policy_data *lpolicy)
 {
 	memset(lpolicy, 0, sizeof(*lpolicy));
 	lpolicy->l_flock.start = wpolicy->l_flock.lfw_start;
@@ -622,7 +622,7 @@ void ldlm_flock_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
 	lpolicy->l_flock.owner = wpolicy->l_flock.lfw_owner;
 }
 
-void ldlm_flock_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
+void ldlm_flock_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				     ldlm_wire_policy_data_t *wpolicy)
 {
 	memset(wpolicy, 0, sizeof(*wpolicy));
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
index 79f4e6f..11b45ae 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
@@ -55,13 +55,13 @@
 #include "ldlm_internal.h"
 
 void ldlm_ibits_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy)
+				     union ldlm_policy_data *lpolicy)
 {
 	memset(lpolicy, 0, sizeof(*lpolicy));
 	lpolicy->l_inodebits.bits = wpolicy->l_inodebits.bits;
 }
 
-void ldlm_ibits_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
+void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				     ldlm_wire_policy_data_t *wpolicy)
 {
 	memset(wpolicy, 0, sizeof(*wpolicy));
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 0099ff3..1a98a31 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -312,24 +312,24 @@ static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
 }
 
 typedef void (*ldlm_policy_wire_to_local_t)(const ldlm_wire_policy_data_t *,
-					    ldlm_policy_data_t *);
+					    union ldlm_policy_data *);
 
-typedef void (*ldlm_policy_local_to_wire_t)(const ldlm_policy_data_t *,
+typedef void (*ldlm_policy_local_to_wire_t)(const union ldlm_policy_data *,
 					    ldlm_wire_policy_data_t *);
 
 void ldlm_plain_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy);
-void ldlm_plain_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
+				     union ldlm_policy_data *lpolicy);
+void ldlm_plain_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				     ldlm_wire_policy_data_t *wpolicy);
 void ldlm_ibits_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy);
-void ldlm_ibits_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
+				     union ldlm_policy_data *lpolicy);
+void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				     ldlm_wire_policy_data_t *wpolicy);
 void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				      ldlm_policy_data_t *lpolicy);
-void ldlm_extent_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
+				      union ldlm_policy_data *lpolicy);
+void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				      ldlm_wire_policy_data_t *wpolicy);
 void ldlm_flock_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy);
-void ldlm_flock_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
+				     union ldlm_policy_data *lpolicy);
+void ldlm_flock_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				     ldlm_wire_policy_data_t *wpolicy);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 17d532e..3dc0a06 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -81,7 +81,7 @@
  * Converts lock policy from local format to on the wire lock_desc format
  */
 static void ldlm_convert_policy_to_wire(enum ldlm_type type,
-					const ldlm_policy_data_t *lpolicy,
+					const union ldlm_policy_data *lpolicy,
 					ldlm_wire_policy_data_t *wpolicy)
 {
 	ldlm_policy_local_to_wire_t convert;
@@ -96,7 +96,7 @@ static void ldlm_convert_policy_to_wire(enum ldlm_type type,
  */
 void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
 				  const ldlm_wire_policy_data_t *wpolicy,
-				  ldlm_policy_data_t *lpolicy)
+				  union ldlm_policy_data *lpolicy)
 {
 	ldlm_policy_wire_to_local_t convert;
 
@@ -1049,7 +1049,7 @@ struct lock_match_data {
 	struct ldlm_lock	*lmd_old;
 	struct ldlm_lock	*lmd_lock;
 	enum ldlm_mode		*lmd_mode;
-	ldlm_policy_data_t	*lmd_policy;
+	union ldlm_policy_data	*lmd_policy;
 	__u64			 lmd_flags;
 	int			 lmd_unref;
 };
@@ -1063,7 +1063,7 @@ struct lock_match_data {
  */
 static int lock_matches(struct ldlm_lock *lock, struct lock_match_data *data)
 {
-	ldlm_policy_data_t *lpol = &lock->l_policy_data;
+	union ldlm_policy_data *lpol = &lock->l_policy_data;
 	enum ldlm_mode match;
 
 	if (lock == data->lmd_old)
@@ -1280,7 +1280,7 @@ void ldlm_lock_allow_match(struct ldlm_lock *lock)
 enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 			       const struct ldlm_res_id *res_id,
 			       enum ldlm_type type,
-			       ldlm_policy_data_t *policy,
+			       union ldlm_policy_data *policy,
 			       enum ldlm_mode mode,
 			       struct lustre_handle *lockh, int unref)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
index 0aed39c..2603293 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
@@ -55,12 +55,12 @@
 #include "ldlm_internal.h"
 
 void ldlm_plain_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy)
+				     union ldlm_policy_data *lpolicy)
 {
 	/* No policy for plain locks */
 }
 
-void ldlm_plain_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
+void ldlm_plain_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				     ldlm_wire_policy_data_t *wpolicy)
 {
 	/* No policy for plain locks */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 836789f..b772982 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -682,7 +682,7 @@ int ldlm_prep_enqueue_req(struct obd_export *exp, struct ptlrpc_request *req,
 int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		     struct ldlm_enqueue_info *einfo,
 		     const struct ldlm_res_id *res_id,
-		     ldlm_policy_data_t const *policy, __u64 *flags,
+		     union ldlm_policy_data const *policy, __u64 *flags,
 		     void *lvb, __u32 lvb_len, enum lvb_type lvb_type,
 		     struct lustre_handle *lockh, int async)
 {
@@ -1528,7 +1528,7 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
  */
 int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			       struct list_head *cancels,
-			       ldlm_policy_data_t *policy,
+			       union ldlm_policy_data *policy,
 			       enum ldlm_mode mode, __u64 lock_flags,
 			       enum ldlm_cancel_flags cancel_flags,
 			       void *opaque)
@@ -1645,7 +1645,7 @@ int ldlm_cli_cancel_list(struct list_head *cancels, int count,
  */
 int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 				    const struct ldlm_res_id *res_id,
-				    ldlm_policy_data_t *policy,
+				    union ldlm_policy_data *policy,
 				    enum ldlm_mode mode,
 				    enum ldlm_cancel_flags flags,
 				    void *opaque)
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 28c2501..6c2abb3 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -265,7 +265,9 @@ static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
 	int lockmode;
 	__u64 flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_TEST_LOCK;
 	struct lustre_handle lockh;
-	ldlm_policy_data_t policy = {.l_inodebits = {MDS_INODELOCK_OPEN} };
+	union ldlm_policy_data policy = {
+		.l_inodebits = { MDS_INODELOCK_OPEN }
+	};
 	int rc = 0;
 
 	/* clear group lock, if present */
@@ -2427,7 +2429,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	};
 	struct md_op_data *op_data;
 	struct lustre_handle lockh = {0};
-	ldlm_policy_data_t flock = { {0} };
+	union ldlm_policy_data flock = { { 0 } };
 	int fl_type = file_lock->fl_type;
 	__u64 flags = 0;
 	int rc;
@@ -2676,7 +2678,7 @@ int ll_have_md_lock(struct inode *inode, __u64 *bits,
 		    enum ldlm_mode l_req_mode)
 {
 	struct lustre_handle lockh;
-	ldlm_policy_data_t policy;
+	union ldlm_policy_data policy;
 	enum ldlm_mode mode = (l_req_mode == LCK_MINMODE) ?
 			      (LCK_CR | LCK_CW | LCK_PR | LCK_PW) : l_req_mode;
 	struct lu_fid *fid;
@@ -2717,7 +2719,7 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
 			       struct lustre_handle *lockh, __u64 flags,
 			       enum ldlm_mode mode)
 {
-	ldlm_policy_data_t policy = { .l_inodebits = {bits} };
+	union ldlm_policy_data policy = { .l_inodebits = { bits } };
 	struct lu_fid *fid;
 
 	fid = &ll_i2info(inode)->lli_fid;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index c0513bf..50bb328 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -905,7 +905,7 @@ struct ll_thread_info {
 
 int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last);
 int ll_file_mmap(struct file *file, struct vm_area_struct *vma);
-void policy_from_vma(ldlm_policy_data_t *policy, struct vm_area_struct *vma,
+void policy_from_vma(union ldlm_policy_data *policy, struct vm_area_struct *vma,
 		     unsigned long addr, size_t count);
 struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 			       size_t count);
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index ad2a699..b56203b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -47,7 +47,7 @@
 
 static const struct vm_operations_struct ll_file_vm_ops;
 
-void policy_from_vma(ldlm_policy_data_t *policy,
+void policy_from_vma(union ldlm_policy_data *policy,
 		     struct vm_area_struct *vma, unsigned long addr,
 		     size_t count)
 {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 33b38bd..2bf3e47 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -370,7 +370,7 @@ static int vvp_mmap_locks(const struct lu_env *env,
 	struct mm_struct       *mm = current->mm;
 	struct vm_area_struct  *vma;
 	struct cl_lock_descr   *descr = &cti->vti_descr;
-	ldlm_policy_data_t      policy;
+	union ldlm_policy_data policy;
 	unsigned long	   addr;
 	ssize_t		 count;
 	int		 result = 0;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 0e94a58..f124f6c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1720,7 +1720,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 
 static int
 lmv_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
-	    const ldlm_policy_data_t *policy,
+	    const union ldlm_policy_data *policy,
 	    struct lookup_intent *it, struct md_op_data *op_data,
 	    struct lustre_handle *lockh, __u64 extra_lock_flags)
 {
@@ -1816,7 +1816,7 @@ static int lmv_early_cancel(struct obd_export *exp, struct lmv_tgt_desc *tgt,
 	struct lu_fid	  *fid = md_op_data_fid(op_data, flag);
 	struct obd_device      *obd = exp->exp_obd;
 	struct lmv_obd	 *lmv = &obd->u.lmv;
-	ldlm_policy_data_t      policy = { {0} };
+	union ldlm_policy_data policy = { { 0 } };
 	int		     rc = 0;
 
 	if (!fid_is_sane(fid))
@@ -2890,8 +2890,9 @@ void lmv_free_memmd(struct lmv_stripe_md *lsm)
 EXPORT_SYMBOL(lmv_free_memmd);
 
 static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
-			     ldlm_policy_data_t *policy, enum ldlm_mode mode,
-			     enum ldlm_cancel_flags flags, void *opaque)
+			     union ldlm_policy_data *policy,
+			     enum ldlm_mode mode, enum ldlm_cancel_flags flags,
+			     void *opaque)
 {
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
@@ -2933,7 +2934,7 @@ static int lmv_set_lock_data(struct obd_export *exp,
 static enum ldlm_mode lmv_lock_match(struct obd_export *exp, __u64 flags,
 				     const struct lu_fid *fid,
 				     enum ldlm_type type,
-				     ldlm_policy_data_t *policy,
+				     union ldlm_policy_data *policy,
 				     enum ldlm_mode mode,
 				     struct lustre_handle *lockh)
 {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index d2af8e7..881c6a0 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -75,7 +75,7 @@ int mdc_intent_lock(struct obd_export *exp,
 		    __u64 extra_lock_flags);
 
 int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
-		const ldlm_policy_data_t *policy,
+		const union ldlm_policy_data *policy,
 		struct lookup_intent *it, struct md_op_data *op_data,
 		struct lustre_handle *lockh, __u64 extra_lock_flags);
 
@@ -109,7 +109,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	       struct ptlrpc_request **request);
 int mdc_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
-		      ldlm_policy_data_t *policy, enum ldlm_mode mode,
+		      union ldlm_policy_data *policy, enum ldlm_mode mode,
 		      enum ldlm_cancel_flags flags, void *opaque);
 
 int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
@@ -121,7 +121,8 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 
 enum ldlm_mode mdc_lock_match(struct obd_export *exp, __u64 flags,
 			      const struct lu_fid *fid, enum ldlm_type type,
-			      ldlm_policy_data_t *policy, enum ldlm_mode mode,
+			      union ldlm_policy_data *policy,
+			      enum ldlm_mode mode,
 			      struct lustre_handle *lockh);
 
 static inline int mdc_prep_elc_req(struct obd_export *exp,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 42a128f..6494c5b 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -131,7 +131,8 @@ int mdc_set_lock_data(struct obd_export *exp, const struct lustre_handle *lockh,
 
 enum ldlm_mode mdc_lock_match(struct obd_export *exp, __u64 flags,
 			      const struct lu_fid *fid, enum ldlm_type type,
-			      ldlm_policy_data_t *policy, enum ldlm_mode mode,
+			      union ldlm_policy_data *policy,
+			      enum ldlm_mode mode,
 			      struct lustre_handle *lockh)
 {
 	struct ldlm_res_id res_id;
@@ -147,7 +148,7 @@ enum ldlm_mode mdc_lock_match(struct obd_export *exp, __u64 flags,
 
 int mdc_cancel_unused(struct obd_export *exp,
 		      const struct lu_fid *fid,
-		      ldlm_policy_data_t *policy,
+		      union ldlm_policy_data *policy,
 		      enum ldlm_mode mode,
 		      enum ldlm_cancel_flags flags,
 		      void *opaque)
@@ -686,20 +687,20 @@ static int mdc_finish_enqueue(struct obd_export *exp,
  * we don't know in advance the file type.
  */
 int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
-		const ldlm_policy_data_t *policy,
+		const union ldlm_policy_data *policy,
 		struct lookup_intent *it, struct md_op_data *op_data,
 		struct lustre_handle *lockh, u64 extra_lock_flags)
 {
-	static const ldlm_policy_data_t lookup_policy = {
+	static const union ldlm_policy_data lookup_policy = {
 		.l_inodebits = { MDS_INODELOCK_LOOKUP }
 	};
-	static const ldlm_policy_data_t update_policy = {
+	static const union ldlm_policy_data update_policy = {
 		.l_inodebits = { MDS_INODELOCK_UPDATE }
 	};
-	static const ldlm_policy_data_t layout_policy = {
+	static const union ldlm_policy_data layout_policy = {
 		.l_inodebits = { MDS_INODELOCK_LAYOUT }
 	};
-	static const ldlm_policy_data_t getxattr_policy = {
+	static const union ldlm_policy_data getxattr_policy = {
 		.l_inodebits = { MDS_INODELOCK_XATTR }
 	};
 	struct obd_device *obddev = class_exp2obd(exp);
@@ -925,7 +926,7 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	 */
 	lock = ldlm_handle2lock(lockh);
 	if (lock) {
-		ldlm_policy_data_t policy = lock->l_policy_data;
+		union ldlm_policy_data policy = lock->l_policy_data;
 
 		LDLM_DEBUG(lock, "matching against this");
 
@@ -961,7 +962,7 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	 */
 	struct ldlm_res_id res_id;
 	struct lustre_handle lockh;
-	ldlm_policy_data_t policy;
+	union ldlm_policy_data policy;
 	enum ldlm_mode mode;
 
 	if (it->it_lock_handle) {
@@ -1163,10 +1164,9 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	 *     for statahead currently. Consider CMD in future, such two bits
 	 *     maybe managed by different MDS, should be adjusted then.
 	 */
-	ldlm_policy_data_t       policy = {
-					.l_inodebits = { MDS_INODELOCK_LOOKUP |
-							 MDS_INODELOCK_UPDATE }
-				 };
+	union ldlm_policy_data policy = {
+		.l_inodebits = { MDS_INODELOCK_LOOKUP | MDS_INODELOCK_UPDATE }
+	};
 	int		      rc = 0;
 	__u64		    flags = LDLM_FL_HAS_INTENT;
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index b551c57..5119588 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -66,7 +66,7 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 			    __u64 bits)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
-	ldlm_policy_data_t policy = {};
+	union ldlm_policy_data policy = {};
 	struct ldlm_res_id res_id;
 	struct ldlm_resource *res;
 	int count;
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index a2cd5dd..23600fb 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -886,7 +886,7 @@ static int mgc_set_mgs_param(struct obd_export *exp,
 
 /* Take a config lock so we can get cancel notifications */
 static int mgc_enqueue(struct obd_export *exp, __u32 type,
-		       ldlm_policy_data_t *policy, __u32 mode,
+		       union ldlm_policy_data *policy, __u32 mode,
 		       __u64 *flags, void *bl_cb, void *cp_cb, void *gl_cb,
 		       void *data, __u32 lvb_len, void *lvb_swabber,
 		       struct lustre_handle *lockh)
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index c9470d1..bf05a2d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -95,7 +95,7 @@ struct osc_session {
 #define OTI_PVEC_SIZE 256
 struct osc_thread_info {
 	struct ldlm_res_id      oti_resname;
-	ldlm_policy_data_t      oti_policy;
+	union ldlm_policy_data	oti_policy;
 	struct cl_lock_descr    oti_descr;
 	struct cl_attr	  oti_attr;
 	struct lustre_handle    oti_handle;
@@ -394,7 +394,8 @@ struct lu_object *osc_object_alloc(const struct lu_env *env,
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, pgoff_t ind);
 
-void osc_index2policy(ldlm_policy_data_t *policy, const struct cl_object *obj,
+void osc_index2policy(union ldlm_policy_data *policy,
+		      const struct cl_object *obj,
 		      pgoff_t start, pgoff_t end);
 int osc_lvb_print(const struct lu_env *env, void *cookie,
 		  lu_printer_t p, const struct ost_lvb *lvb);
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 12d3b58..981b7e1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -107,14 +107,14 @@ typedef int (*osc_enqueue_upcall_f)(void *cookie, struct lustre_handle *lockh,
 				    int rc);
 
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
-		     __u64 *flags, ldlm_policy_data_t *policy,
+		     __u64 *flags, union ldlm_policy_data *policy,
 		     struct ost_lvb *lvb, int kms_valid,
 		     osc_enqueue_upcall_f upcall,
 		     void *cookie, struct ldlm_enqueue_info *einfo,
 		     struct ptlrpc_request_set *rqset, int async, int agl);
 
 int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
-		   __u32 type, ldlm_policy_data_t *policy, __u32 mode,
+		   __u32 type, union ldlm_policy_data *policy, __u32 mode,
 		   __u64 *flags, void *data, struct lustre_handle *lockh,
 		   int unref);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index bfc8d38..130460d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -145,7 +145,7 @@ static void osc_lock_fini(const struct lu_env *env,
 
 static void osc_lock_build_policy(const struct lu_env *env,
 				  const struct cl_lock *lock,
-				  ldlm_policy_data_t *policy)
+				  union ldlm_policy_data *policy)
 {
 	const struct cl_lock_descr *d = &lock->cll_descr;
 
@@ -914,7 +914,7 @@ static int osc_lock_enqueue(const struct lu_env *env,
 	struct osc_lock *oscl = cl2osc_lock(slice);
 	struct cl_lock *lock = slice->cls_lock;
 	struct ldlm_res_id *resname = &info->oti_resname;
-	ldlm_policy_data_t *policy = &info->oti_policy;
+	union ldlm_policy_data *policy = &info->oti_policy;
 	osc_enqueue_upcall_f upcall = osc_lock_upcall;
 	void *cookie = oscl;
 	bool async = false;
@@ -1186,7 +1186,7 @@ struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct ldlm_res_id *resname = &info->oti_resname;
-	ldlm_policy_data_t *policy  = &info->oti_policy;
+	union ldlm_policy_data *policy = &info->oti_policy;
 	struct lustre_handle lockh;
 	struct ldlm_lock *lock = NULL;
 	enum ldlm_mode mode;
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index ab1c11c..3592796 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -223,7 +223,7 @@ static int osc_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 			     struct fiemap *fiemap, size_t *buflen)
 {
 	struct obd_export *exp = osc_export(cl2osc(obj));
-	ldlm_policy_data_t policy;
+	union ldlm_policy_data policy;
 	struct ptlrpc_request *req;
 	struct lustre_handle lockh;
 	struct ldlm_res_id resid;
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 93248d1..7a1f102 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -109,7 +109,8 @@ int osc_page_cache_add(const struct lu_env *env,
 	return result;
 }
 
-void osc_index2policy(ldlm_policy_data_t *policy, const struct cl_object *obj,
+void osc_index2policy(union ldlm_policy_data *policy,
+		      const struct cl_object *obj,
 		      pgoff_t start, pgoff_t end)
 {
 	memset(policy, 0, sizeof(*policy));
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 7f19cfa..4d4d3eb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1953,7 +1953,7 @@ static int osc_enqueue_interpret(const struct lu_env *env,
  * release locks just after they are obtained.
  */
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
-		     __u64 *flags, ldlm_policy_data_t *policy,
+		     __u64 *flags, union ldlm_policy_data *policy,
 		     struct ost_lvb *lvb, int kms_valid,
 		     osc_enqueue_upcall_f upcall, void *cookie,
 		     struct ldlm_enqueue_info *einfo,
@@ -2104,7 +2104,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 }
 
 int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
-		   __u32 type, ldlm_policy_data_t *policy, __u32 mode,
+		   __u32 type, union ldlm_policy_data *policy, __u32 mode,
 		   __u64 *flags, void *data, struct lustre_handle *lockh,
 		   int unref)
 {
-- 
1.7.1
