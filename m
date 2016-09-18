From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:36 -0400
Subject: [lustre-devel] [PATCH 037/124] staging: lustre: cleanup lustre_lib.h
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove some unused declarations from lustre_lib.h and move
some others to more natural headers.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/11500
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_lib.h |   36 --------------------
 drivers/staging/lustre/lustre/include/obd.h        |   17 +++++++++
 drivers/staging/lustre/lustre/include/obd_class.h  |    5 +++
 3 files changed, 22 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index adb8c47..6b23191 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -51,7 +51,6 @@
 #include "lustre_cfg.h"
 
 /* target.c */
-struct kstatfs;
 struct ptlrpc_request;
 struct obd_export;
 struct lu_target;
@@ -74,43 +73,8 @@ int do_set_info_async(struct obd_import *imp,
 		      u32 vallen, void *val,
 		      struct ptlrpc_request_set *set);
 
-#define OBD_RECOVERY_MAX_TIME (obd_timeout * 18) /* b13079 */
-
 void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id);
 
-/* client.c */
-
-int client_sanobd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg);
-struct client_obd *client_conn2cli(struct lustre_handle *conn);
-
-struct md_open_data;
-struct obd_client_handle {
-	struct lustre_handle	 och_fh;
-	struct lu_fid		 och_fid;
-	struct md_open_data	*och_mod;
-	struct lustre_handle	 och_lease_handle; /* open lock for lease */
-	__u32			 och_magic;
-	fmode_t			 och_flags;
-};
-
-#define OBD_CLIENT_HANDLE_MAGIC 0xd15ea5ed
-
-/* statfs_pack.c */
-void statfs_unpack(struct kstatfs *sfs, struct obd_statfs *osfs);
-
-/* Until such time as we get_info the per-stripe maximum from the OST,
- * we define this to be 2T - 4k, which is the ext3 maxbytes.
- */
-#define LUSTRE_STRIPE_MAXBYTES 0x1fffffff000ULL
-
-/* Special values for remove LOV EA from disk */
-#define LOVEA_DELETE_VALUES(size, count, offset) (size == 0 && count == 0 && \
-						 offset == (typeof(offset))(-1))
-
-#define LMVEA_DELETE_VALUES(count, offset) ((count) == 0 && \
-					    (offset) == (typeof(offset))(-1))
-/* #define POISON_BULK 0 */
-
 /*
  * l_wait_event is a flexible sleeping function, permitting simple caller
  * configuration of interrupt and timeout sensitivity along with actions to
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 89633f7..0917aaa 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -41,6 +41,7 @@
 #include "lustre_export.h"
 #include "lustre_fid.h"
 #include "lustre_fld.h"
+#include "lustre_handles.h"
 #include "lustre_intent.h"
 
 #define MAX_OBD_DEVICES 8192
@@ -72,6 +73,11 @@ static inline void loi_init(struct lov_oinfo *loi)
 {
 }
 
+/* Until such time as we get_info the per-stripe maximum from the OST,
+ * we define this to be 2T - 4k, which is the ext3 maxbytes.
+ */
+#define LUSTRE_STRIPE_MAXBYTES 0x1fffffff000ULL
+
 struct lov_stripe_md {
 	atomic_t     lsm_refc;
 	spinlock_t	lsm_lock;
@@ -949,6 +955,17 @@ struct md_open_data {
 	bool			  mod_is_create;
 };
 
+struct obd_client_handle {
+	struct lustre_handle	 och_fh;
+	struct lu_fid		 och_fid;
+	struct md_open_data	*och_mod;
+	struct lustre_handle	 och_lease_handle; /* open lock for lease */
+	__u32			 och_magic;
+	int			 och_flags;
+};
+
+#define OBD_CLIENT_HANDLE_MAGIC 0xd15ea5ed
+
 struct lookup_intent;
 struct cl_attr;
 
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 8e8df08..6fc54bd 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1725,6 +1725,11 @@ int class_procfs_clean(void);
 /* prng.c */
 #define ll_generate_random_uuid(uuid_out) cfs_get_random_bytes(uuid_out, sizeof(class_uuid_t))
 
+/* statfs_pack.c */
+struct kstatfs;
+void statfs_pack(struct obd_statfs *osfs, struct kstatfs *sfs);
+void statfs_unpack(struct kstatfs *sfs, struct obd_statfs *osfs);
+
 /* root squash info */
 struct rw_semaphore;
 struct root_squash_info {
-- 
1.7.1
