From: James Simmons <jsimmons@infradead.org>
Date: Thu, 25 Feb 2016 20:07:11 -0500
Subject: [lustre-devel] [PATCH v2 5/6] staging: lustre: make
	module_init/exit naming consistent
In-Reply-To: <1456448832-959-1-git-send-email-jsimmons@infradead.org>
References: <1456448832-959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456448832-959-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Make the name of the module_init()/_exit() functions consistently
{module_name}_init and {module_name}_exit.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6204
Reviewed-on: http://review.whamcloud.com/16787
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    4 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    8 ++++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   10 ++++------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   10 ++++------
 drivers/staging/lustre/lnet/lnet/module.c          |   16 +++++++---------
 drivers/staging/lustre/lnet/selftest/module.c      |    6 +++---
 drivers/staging/lustre/lustre/fid/fid_request.c    |    8 ++++----
 drivers/staging/lustre/lustre/fld/fld_request.c    |    8 ++++----
 drivers/staging/lustre/lustre/libcfs/module.c      |    8 ++++----
 drivers/staging/lustre/lustre/llite/lloop.c        |    6 +++---
 drivers/staging/lustre/lustre/llite/super25.c      |    8 ++++----
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    8 ++++----
 12 files changed, 47 insertions(+), 53 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index a5f1aec..d78360d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -450,8 +450,8 @@ lnet_ni_t *lnet_net2ni(__u32 net);
 
 extern int portal_rotor;
 
-int lnet_init(void);
-void lnet_fini(void);
+int lnet_lib_init(void);
+void lnet_lib_exit(void);
 
 int lnet_notify(lnet_ni_t *ni, lnet_nid_t peer, int alive, unsigned long when);
 void lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index b883b67..56e5784 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2840,12 +2840,12 @@ net_failed:
 	return -ENETDOWN;
 }
 
-static void __exit kiblnd_module_fini(void)
+static void __exit ko2iblnd_exit(void)
 {
 	lnet_unregister_lnd(&the_o2iblnd);
 }
 
-static int __init kiblnd_module_init(void)
+static int __init ko2iblnd_init(void)
 {
 	int rc;
 
@@ -2871,5 +2871,5 @@ MODULE_DESCRIPTION("OpenIB gen2 LNet Network Driver");
 MODULE_VERSION("2.7.0");
 MODULE_LICENSE("GPL");
 
-module_init(kiblnd_module_init);
-module_exit(kiblnd_module_fini);
+module_init(ko2iblnd_init);
+module_exit(ko2iblnd_exit);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 9b9eb0f..d843082 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2889,14 +2889,12 @@ ksocknal_startup(lnet_ni_t *ni)
 	return -ENETDOWN;
 }
 
-static void __exit
-ksocknal_module_fini(void)
+static void __exit ksocklnd_exit(void)
 {
 	lnet_unregister_lnd(&the_ksocklnd);
 }
 
-static int __init
-ksocknal_module_init(void)
+static int __init ksocklnd_init(void)
 {
 	int rc;
 
@@ -2929,5 +2927,5 @@ MODULE_DESCRIPTION("TCP Socket LNet Network Driver");
 MODULE_VERSION("2.7.0");
 MODULE_LICENSE("GPL");
 
-module_init(ksocknal_module_init);
-module_exit(ksocknal_module_fini);
+module_init(ksocklnd_init);
+module_exit(ksocklnd_exit);
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 3ecc96a..a911aef 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1386,13 +1386,12 @@ failed:
  * Initialize LNet library.
  *
  * Automatically called at module loading time. Caller has to call
- * lnet_exit() after a call to lnet_init(), if and only if the
+ * lnet_lib_exit() after a call to lnet_lib_init(), if and only if the
  * latter returned 0. It must be called exactly once.
  *
  * \return 0 on success, and -ve on failures.
  */
-int
-lnet_init(void)
+int lnet_lib_init(void)
 {
 	int rc;
 
@@ -1451,11 +1450,10 @@ lnet_init(void)
 /**
  * Finalize LNet library.
  *
- * \pre lnet_init() called with success.
+ * \pre lnet_lib_init() called with success.
  * \pre All LNet users called LNetNIFini() for matching LNetNIInit() calls.
  */
-void
-lnet_fini(void)
+void lnet_lib_exit(void)
 {
 	LASSERT(!the_lnet.ln_refcount);
 
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index da3eb33..93037c1 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -185,16 +185,15 @@ lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 
 static DECLARE_IOCTL_HANDLER(lnet_ioctl_handler, lnet_ioctl);
 
-static int __init
-init_lnet(void)
+static int __init lnet_init(void)
 {
 	int rc;
 
 	mutex_init(&lnet_config_mutex);
 
-	rc = lnet_init();
+	rc = lnet_lib_init();
 	if (rc) {
-		CERROR("lnet_init: error %d\n", rc);
+		CERROR("lnet_lib_init: error %d\n", rc);
 		return rc;
 	}
 
@@ -212,15 +211,14 @@ init_lnet(void)
 	return 0;
 }
 
-static void __exit
-fini_lnet(void)
+static void __exit lnet_exit(void)
 {
 	int rc;
 
 	rc = libcfs_deregister_ioctl(&lnet_ioctl_handler);
 	LASSERT(!rc);
 
-	lnet_fini();
+	lnet_lib_exit();
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
@@ -228,5 +226,5 @@ MODULE_DESCRIPTION("Lustre Networking layer");
 MODULE_VERSION(LNET_VERSION);
 MODULE_LICENSE("GPL");
 
-module_init(init_lnet);
-module_exit(fini_lnet);
+module_init(lnet_init);
+module_exit(lnet_exit);
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 05c1de1..55082ce 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -54,7 +54,7 @@ struct cfs_wi_sched *lst_sched_serial;
 struct cfs_wi_sched **lst_sched_test;
 
 static void
-lnet_selftest_fini(void)
+lnet_selftest_exit(void)
 {
 	int i;
 
@@ -144,7 +144,7 @@ lnet_selftest_init(void)
 	lst_init_step = LST_INIT_CONSOLE;
 	return 0;
 error:
-	lnet_selftest_fini();
+	lnet_selftest_exit();
 	return rc;
 }
 
@@ -154,4 +154,4 @@ MODULE_VERSION("2.7.0");
 MODULE_LICENSE("GPL");
 
 module_init(lnet_selftest_init);
-module_exit(lnet_selftest_fini);
+module_exit(lnet_selftest_exit);
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index a20b8ea..39269c3 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -450,7 +450,7 @@ int client_fid_fini(struct obd_device *obd)
 }
 EXPORT_SYMBOL(client_fid_fini);
 
-static int __init fid_mod_init(void)
+static int __init fid_init(void)
 {
 	seq_debugfs_dir = ldebugfs_register(LUSTRE_SEQ_NAME,
 					    debugfs_lustre_root,
@@ -458,7 +458,7 @@ static int __init fid_mod_init(void)
 	return PTR_ERR_OR_ZERO(seq_debugfs_dir);
 }
 
-static void __exit fid_mod_exit(void)
+static void __exit fid_exit(void)
 {
 	if (!IS_ERR_OR_NULL(seq_debugfs_dir))
 		ldebugfs_remove(&seq_debugfs_dir);
@@ -469,5 +469,5 @@ MODULE_DESCRIPTION("Lustre File IDentifier");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
-module_init(fid_mod_init);
-module_exit(fid_mod_exit);
+module_init(fid_init);
+module_exit(fid_exit);
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index b4f6c4f..a3d122d 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -485,7 +485,7 @@ void fld_client_flush(struct lu_client_fld *fld)
 }
 EXPORT_SYMBOL(fld_client_flush);
 
-static int __init fld_mod_init(void)
+static int __init fld_init(void)
 {
 	fld_debugfs_dir = ldebugfs_register(LUSTRE_FLD_NAME,
 					    debugfs_lustre_root,
@@ -493,7 +493,7 @@ static int __init fld_mod_init(void)
 	return PTR_ERR_OR_ZERO(fld_debugfs_dir);
 }
 
-static void __exit fld_mod_exit(void)
+static void __exit fld_exit(void)
 {
 	if (!IS_ERR_OR_NULL(fld_debugfs_dir))
 		ldebugfs_remove(&fld_debugfs_dir);
@@ -504,5 +504,5 @@ MODULE_DESCRIPTION("Lustre FID Location Database");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
-module_init(fld_mod_init)
-module_exit(fld_mod_exit)
+module_init(fld_init)
+module_exit(fld_exit)
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index d856b55..5d52673 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -585,7 +585,7 @@ static void lustre_remove_debugfs(void)
 	lnet_debugfs_root = NULL;
 }
 
-static int init_libcfs_module(void)
+static int libcfs_init(void)
 {
 	int rc;
 
@@ -641,7 +641,7 @@ cleanup_cpu:
 	return rc;
 }
 
-static void exit_libcfs_module(void)
+static void libcfs_exit(void)
 {
 	int rc;
 
@@ -669,5 +669,5 @@ MODULE_DESCRIPTION("Lustre helper library");
 MODULE_VERSION(LIBCFS_VERSION);
 MODULE_LICENSE("GPL");
 
-module_init(init_libcfs_module);
-module_exit(exit_libcfs_module);
+module_init(libcfs_init);
+module_exit(libcfs_exit);
diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index 8550a9b..b725fc1 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -871,12 +871,12 @@ static void lloop_exit(void)
 	kfree(loop_dev);
 }
 
-module_init(lloop_init);
-module_exit(lloop_exit);
-
 module_param(max_loop, int, 0444);
 MODULE_PARM_DESC(max_loop, "maximum of lloop_device");
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre virtual block device");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
+
+module_init(lloop_init);
+module_exit(lloop_exit);
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 1337f69..5c20804 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -89,7 +89,7 @@ MODULE_ALIAS_FS("lustre");
 
 void lustre_register_client_process_config(int (*cpc)(struct lustre_cfg *lcfg));
 
-static int __init init_lustre_lite(void)
+static int __init lustre_init(void)
 {
 	lnet_process_id_t lnet_id;
 	struct timespec64 ts;
@@ -188,7 +188,7 @@ out_cache:
 	return rc;
 }
 
-static void __exit exit_lustre_lite(void)
+static void __exit lustre_exit(void)
 {
 	lustre_register_client_fill_super(NULL);
 	lustre_register_kill_super_cb(NULL);
@@ -213,5 +213,5 @@ MODULE_DESCRIPTION("Lustre Client File System");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
-module_init(init_lustre_lite);
-module_exit(exit_lustre_lite);
+module_init(lustre_init);
+module_exit(lustre_exit);
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index ca407a2..1a938e1 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -473,7 +473,7 @@ static int obd_init_checks(void)
 extern int class_procfs_init(void);
 extern int class_procfs_clean(void);
 
-static int __init init_obdclass(void)
+static int __init obdclass_init(void)
 {
 	int i, err;
 
@@ -543,7 +543,7 @@ static int __init init_obdclass(void)
 	return err;
 }
 
-static void cleanup_obdclass(void)
+static void obdclass_exit(void)
 {
 	int i;
 
@@ -580,5 +580,5 @@ MODULE_DESCRIPTION("Lustre Class Driver");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
-module_init(init_obdclass);
-module_exit(cleanup_obdclass);
+module_init(obdclass_init);
+module_exit(obdclass_exit);
-- 
1.7.1
