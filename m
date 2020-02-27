From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:29 -0500
Subject: [lustre-devel] [PATCH 161/622] lustre: obd: remove portals handle
 from OBD import
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-162-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

OBD imports are never looked up using the portals handle (imp_handle)
they contain, so remove it. Also remove the unused functions
class_conn2obd() and class_conn2cliimp().

WC-bug-id: https://jira.whamcloud.com/browse/LU-11445
Lustre-commit: 59729e4c0867 ("LU-11445 obd: remove portals handle from OBD import")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33250
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h | 10 +++++++---
 fs/lustre/obdclass/genops.c       | 21 +++------------------
 2 files changed, 10 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 1fd6246..f16d621 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -43,9 +43,15 @@
  *
  * @{
  */
+#include <linux/atomic.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/spinlock.h>
+#include <linux/time.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
 
 #include <linux/libcfs/libcfs.h>
-#include <lustre_handles.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 
 /**
@@ -154,8 +160,6 @@ struct import_state_hist {
  * Imports are representing client-side view to remote target.
  */
 struct obd_import {
-	/** Local handle (== id) for this import. */
-	struct portals_handle		imp_handle;
 	/** Reference counter */
 	atomic_t			imp_refcount;
 	struct lustre_handle		imp_dlm_handle; /* client's ldlm export */
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 4465dd9..2254943 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -863,7 +863,6 @@ static struct obd_export *__class_new_export(struct obd_device *obd,
 
 exit_unlock:
 	spin_unlock(&obd->obd_dev_lock);
-	class_handle_unhash(&export->exp_handle);
 	obd_destroy_export(export);
 	kfree(export);
 	return ERR_PTR(rc);
@@ -903,7 +902,7 @@ void class_unlink_export(struct obd_export *exp)
 }
 
 /* Import management functions */
-static void class_import_destroy(struct obd_import *imp)
+static void obd_zombie_import_free(struct obd_import *imp)
 {
 	struct obd_import_conn *imp_conn;
 
@@ -924,19 +923,9 @@ static void class_import_destroy(struct obd_import *imp)
 
 	LASSERT(!imp->imp_sec);
 	class_decref(imp->imp_obd, "import", imp);
-	OBD_FREE_RCU(imp, sizeof(*imp), &imp->imp_handle);
+	kfree(imp);
 }
 
-static void import_handle_addref(void *import)
-{
-	class_import_get(import);
-}
-
-static struct portals_handle_ops import_handle_ops = {
-	.hop_addref	= import_handle_addref,
-	.hop_free	= NULL,
-};
-
 struct obd_import *class_import_get(struct obd_import *import)
 {
 	atomic_inc(&import->imp_refcount);
@@ -985,7 +974,7 @@ static void obd_zombie_imp_cull(struct work_struct *ws)
 	struct obd_import *import = container_of(ws, struct obd_import,
 						 imp_zombie_work);
 
-	class_import_destroy(import);
+	obd_zombie_import_free(import);
 }
 
 struct obd_import *class_new_import(struct obd_device *obd)
@@ -1018,8 +1007,6 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	atomic_set(&imp->imp_replay_inflight, 0);
 	atomic_set(&imp->imp_inval_count, 0);
 	INIT_LIST_HEAD(&imp->imp_conn_list);
-	INIT_LIST_HEAD_RCU(&imp->imp_handle.h_link);
-	class_handle_hash(&imp->imp_handle, &import_handle_ops);
 	init_imp_at(&imp->imp_at);
 
 	/* the default magic is V2, will be used in connect RPC, and
@@ -1036,8 +1023,6 @@ void class_destroy_import(struct obd_import *import)
 	LASSERT(import);
 	LASSERT(import != LP_POISON);
 
-	class_handle_unhash(&import->imp_handle);
-
 	spin_lock(&import->imp_lock);
 	import->imp_generation++;
 	spin_unlock(&import->imp_lock);
-- 
1.8.3.1
