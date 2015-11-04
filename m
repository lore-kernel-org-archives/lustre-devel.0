From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 Nov 2015 13:40:02 -0500
Subject: [lustre-devel] [PATCH 06/10] staging: lustre: Update module author
	to OpenSFS
In-Reply-To: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
References: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446662406-4590-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The modinfo data has gone stale for the author information.
This patch changes all the MODULE_AUTHOR to OpenSFS.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6204
Reviewed-on: http://review.whamcloud.com/16132
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    2 +-
 drivers/staging/lustre/lnet/lnet/module.c          |    2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c    |    2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |    2 +-
 drivers/staging/lustre/lustre/libcfs/module.c      |    2 +-
 drivers/staging/lustre/lustre/llite/lloop.c        |    2 +-
 drivers/staging/lustre/lustre/llite/super25.c      |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_module.c   |    2 +-
 16 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 7c730e3..de0f85f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2865,7 +2865,7 @@ static int __init kiblnd_module_init(void)
 	return 0;
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Kernel OpenIB gen2 LND v2.00");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 46a24b4..ebde036 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2869,7 +2869,7 @@ ksocknal_module_init(void)
 	return 0;
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Kernel TCP Socket LND v3.0.0");
 MODULE_LICENSE("GPL");
 MODULE_VERSION("3.0.0");
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 576201a..ac2fdf0 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -146,7 +146,7 @@ fini_lnet(void)
 	lnet_fini();
 }
 
-MODULE_AUTHOR("Peter J. Braam <braam@clusterfs.com>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("LNet v3.1");
 MODULE_LICENSE("GPL");
 MODULE_VERSION("1.0.0");
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index e817628..fe7c39a 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -462,7 +462,7 @@ static void __exit fid_mod_exit(void)
 		ldebugfs_remove(&seq_debugfs_dir);
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre FID Module");
 MODULE_LICENSE("GPL");
 MODULE_VERSION("0.1.0");
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 3fd91bc..469df68 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -501,7 +501,7 @@ static void __exit fld_mod_exit(void)
 		ldebugfs_remove(&fld_debugfs_dir);
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre FLD");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 50e8fd2..50659c6 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -62,7 +62,7 @@
 #include "../../include/linux/lnet/lnet.h"
 #include "tracefile.h"
 
-MODULE_AUTHOR("Peter J. Braam <braam@clusterfs.com>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Portals v3.1");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index e6974c3..8abfba2 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -876,6 +876,6 @@ module_exit(lloop_exit);
 
 module_param(max_loop, int, 0444);
 MODULE_PARM_DESC(max_loop, "maximum of lloop_device");
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre virtual block device");
 MODULE_LICENSE("GPL");
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 0131368..7a9fafc 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -205,7 +205,7 @@ static void __exit exit_lustre_lite(void)
 	kmem_cache_destroy(ll_file_data_slab);
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Lite Client File System");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 55f801b..a4de9a3 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2812,7 +2812,7 @@ static void lmv_exit(void)
 	class_unregister_type(LUSTRE_LMV_NAME);
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Logical Metadata Volume OBD driver");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 6bd4ac0..b52609a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -2352,7 +2352,7 @@ static void /*__exit*/ lov_exit(void)
 	lu_kmem_fini(lov_caches);
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Logical Object Volume OBD driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 3dd0d01..294c050 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2532,7 +2532,7 @@ static void /*__exit*/ mdc_exit(void)
 	class_unregister_type(LUSTRE_MDC_NAME);
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Metadata Client");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index d17bf51..69b2364 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1725,7 +1725,7 @@ static void /*__exit*/ mgc_exit(void)
 	class_unregister_type(LUSTRE_MGC_NAME);
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Management Client");
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 3e9c246..beb59f0 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -576,7 +576,7 @@ static void cleanup_obdclass(void)
 	obd_zombie_impexp_stop();
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Class Driver Build Version: " BUILD_VERSION);
 MODULE_LICENSE("GPL");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 82fd8cd..35a2f59 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -2170,7 +2170,7 @@ static void /*__exit*/ obdecho_exit(void)
 
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Testing Echo OBD driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index cfb3ce2..d6c1447 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -3358,7 +3358,7 @@ static void /*__exit*/ osc_exit(void)
 	ptlrpc_free_rq_pool(osc_rq_pool);
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Object Storage Client (OSC)");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
index 9deeb24..c4f1d0f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
@@ -160,7 +160,7 @@ static void __exit ptlrpc_exit(void)
 	ptlrpc_connection_fini();
 }
 
-MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Request Processor and Lock Management");
 MODULE_LICENSE("GPL");
 MODULE_VERSION("1.0.0");
-- 
1.7.1
