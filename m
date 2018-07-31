From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:04 -0400
Subject: [lustre-devel] [PATCH 12/31] lustre: obdclass: obdclass module
 cleanup upon load error
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

Fix obdclass_init() error paths to proceed with cleanup.
This will particularly allow to no longer crash upon next
load attempt and this due to previous miscdevice not been
deregistered and thus still referenced in misc_list when
unmapped.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-6499
Reviewed-on: https://review.whamcloud.com/22544
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/obd_support.h    |  1 +
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 53 ++++++++++++++++++----
 2 files changed, 46 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 87806e8..726cc4d 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -359,6 +359,7 @@
 #define OBD_FAIL_OBD_IDX_READ_NET	0x607
 #define OBD_FAIL_OBD_IDX_READ_BREAK	 0x608
 #define OBD_FAIL_OBD_NO_LRU		 0x609
+#define OBD_FAIL_OBDCLASS_MODULE_LOAD	 0x60a
 
 #define OBD_FAIL_TGT_REPLY_NET	   0x700
 #define OBD_FAIL_TGT_CONN_RACE	   0x701
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 87327ef..04e55fc 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -469,19 +469,19 @@ static int __init obdclass_init(void)
 
 	err = obd_init_checks();
 	if (err)
-		return err;
+		goto cleanup_zombie_impexp;
 
 	class_init_uuidlist();
 	err = class_handle_init();
 	if (err)
-		return err;
+		goto cleanup_uuidlist;
 
 	INIT_LIST_HEAD(&obd_types);
 
 	err = misc_register(&obd_psdev);
 	if (err) {
 		CERROR("cannot register OBD miscdevices: err %d\n", err);
-		return err;
+		goto cleanup_class_handle;
 	}
 
 	/* This struct is already zeroed for us (static global) */
@@ -499,25 +499,62 @@ static int __init obdclass_init(void)
 
 	err = obd_init_caches();
 	if (err)
-		return err;
+		goto cleanup_deregister;
 
 	err = class_procfs_init();
 	if (err)
-		return err;
+		goto cleanup_caches;
 
 	err = obd_sysctl_init();
 	if (err)
-		return err;
+		goto cleanup_class_procfs;
 
 	err = lu_global_init();
 	if (err)
-		return err;
+		goto cleanup_class_procfs;
 
 	err = cl_global_init();
 	if (err != 0)
-		return err;
+		goto cleanup_lu_global;
 
 	err = llog_info_init();
+	if (err)
+		goto cleanup_cl_global;
+
+	/* simulate a late OOM situation now to require all
+	 * alloc'ed/initialized resources to be freed
+	 */
+	if (!OBD_FAIL_CHECK(OBD_FAIL_OBDCLASS_MODULE_LOAD))
+		return 0;
+
+	/* force error to ensure module will be unloaded/cleaned */
+	err = -ENOMEM;
+
+	llog_info_fini();
+
+cleanup_cl_global:
+	cl_global_fini();
+
+cleanup_lu_global:
+	lu_global_fini();
+
+cleanup_class_procfs:
+	class_procfs_clean();
+
+cleanup_caches:
+	obd_cleanup_caches();
+
+cleanup_deregister:
+	misc_deregister(&obd_psdev);
+
+cleanup_class_handle:
+	class_handle_cleanup();
+
+cleanup_uuidlist:
+	class_exit_uuidlist();
+
+cleanup_zombie_impexp:
+	obd_zombie_impexp_stop();
 
 	return err;
 }
-- 
1.8.3.1
