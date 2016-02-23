From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:53:57 -0500
Subject: [lustre-devel] [PATCH 19/56] staging/lustre: Get rid of
	ldlm_error_t typedef
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-20-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum ldlm_error

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 8 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    | 4 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 4 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      | 4 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 6 +++---
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 87806a6..924e68f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -69,7 +69,7 @@ struct obd_device;
 /**
  * LDLM non-error return states
  */
-typedef enum {
+enum ldlm_error {
 	ELDLM_OK = 0,
 
 	ELDLM_LOCK_CHANGED = 300,
@@ -80,7 +80,7 @@ typedef enum {
 
 	ELDLM_NAMESPACE_EXISTS = 400,
 	ELDLM_BAD_NAMESPACE    = 401
-} ldlm_error_t;
+};
 
 /**
  * LDLM namespace type.
@@ -1019,7 +1019,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 } while (0)
 
 typedef int (*ldlm_processing_policy)(struct ldlm_lock *lock, __u64 *flags,
-				      int first_enq, ldlm_error_t *err,
+				      int first_enq, enum ldlm_error *err,
 				      struct list_head *work_list);
 
 /**
@@ -1105,7 +1105,7 @@ static inline int ldlm_res_lvbo_update(struct ldlm_resource *res,
 	return 0;
 }
 
-int ldlm_error2errno(ldlm_error_t error);
+int ldlm_error2errno(enum ldlm_error error);
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 void ldlm_dump_export_locks(struct obd_export *exp);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 699e81d..8bd6a18 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -133,7 +133,7 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
  *     would be collected and ASTs sent.
  */
 static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
-				   int first_enq, ldlm_error_t *err,
+				   int first_enq, enum ldlm_error *err,
 				   struct list_head *work_list)
 {
 	struct ldlm_resource *res = req->l_resource;
@@ -449,7 +449,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 	struct obd_import	      *imp = NULL;
 	struct ldlm_flock_wait_data     fwd;
 	struct l_wait_info	      lwi;
-	ldlm_error_t		    err;
+	enum ldlm_error		    err;
 	int			     rc = 0;
 
 	CDEBUG(D_DLMTRACE, "flags: 0x%llx data: %p getlk: %p\n",
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 6d4f324..ed27822 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -136,8 +136,8 @@ ldlm_lock_create(struct ldlm_namespace *ns, const struct ldlm_res_id *,
 		 enum ldlm_type type, enum ldlm_mode mode,
 		 const struct ldlm_callback_suite *cbs,
 		 void *data, __u32 lvb_len, enum lvb_type lvb_type);
-ldlm_error_t ldlm_lock_enqueue(struct ldlm_namespace *, struct ldlm_lock **,
-			       void *cookie, __u64 *flags);
+enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *, struct ldlm_lock **,
+				  void *cookie, __u64 *flags);
 void ldlm_lock_addref_internal(struct ldlm_lock *, __u32 mode);
 void ldlm_lock_addref_internal_nolock(struct ldlm_lock *, __u32 mode);
 void ldlm_lock_decref_internal(struct ldlm_lock *, __u32 mode);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 68bf57b..c22370b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -733,7 +733,7 @@ enum ldlm_mode lck_compat_array[] = {
  * Rather arbitrary mapping from LDLM error codes to errno values. This should
  * not escape to the user level.
  */
-int ldlm_error2errno(ldlm_error_t error)
+int ldlm_error2errno(enum ldlm_error error)
 {
 	int result;
 
@@ -761,7 +761,7 @@ int ldlm_error2errno(ldlm_error_t error)
 		break;
 	default:
 		if (((int)error) < 0)  /* cast to signed type */
-			result = error; /* as ldlm_error_t can be unsigned */
+			result = error; /* as enum ldlm_error can be unsigned */
 		else {
 			CERROR("Invalid DLM result code: %d\n", error);
 			result = -EPROTO;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 073dcf8..07e83e5 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1512,9 +1512,9 @@ out:
  * Does not block. As a result of enqueue the lock would be put
  * into granted or waiting list.
  */
-ldlm_error_t ldlm_lock_enqueue(struct ldlm_namespace *ns,
-			       struct ldlm_lock **lockp,
-			       void *cookie, __u64 *flags)
+enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
+				  struct ldlm_lock **lockp,
+				  void *cookie, __u64 *flags)
 {
 	struct ldlm_lock *lock = *lockp;
 	struct ldlm_resource *res = lock->l_resource;
-- 
2.1.0
