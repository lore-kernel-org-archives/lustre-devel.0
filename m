From: James Simmons <jsimmons@infradead.org>
Date: Fri, 26 Feb 2016 11:36:03 -0500
Subject: [lustre-devel] [PATCH v3 2/6] staging: lustre: add missing
	MODULE_AUTHOR for LNet selftest module
In-Reply-To: <1456504566-21176-1-git-send-email-jsimmons@infradead.org>
References: <1456504566-21176-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456504566-21176-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <uja.ornl@yahoo.com>

For several lustre modules the MODULE_VERSION has the wrong value,
located in the wrong place in the source code, or completely missing.
This patch brings it up to date.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6204
Reviewed-on: http://review.whamcloud.com/16729
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 ++
 drivers/staging/lustre/include/linux/lnet/types.h  |    2 ++
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    1 +
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    2 +-
 drivers/staging/lustre/lnet/lnet/module.c          |    2 +-
 drivers/staging/lustre/lnet/selftest/module.c      |    2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c    |    2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |    1 +
 drivers/staging/lustre/lustre/libcfs/module.c      |    2 +-
 drivers/staging/lustre/lustre/llite/lloop.c        |    1 +
 drivers/staging/lustre/lustre/llite/super25.c      |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    1 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    1 +
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    1 +
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_module.c   |    2 +-
 17 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 5c598c8..1eab0eb 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -42,6 +42,8 @@
 
 #include "curproc.h"
 
+#define LIBCFS_VERSION "0.7.0"
+
 #define LOWEST_BIT_SET(x)       ((x) & ~((x) - 1))
 
 /*
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 81d01f1..08f193c 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -39,6 +39,8 @@
  * @{
  */
 
+#define LNET_VERSION		"0.6.0"
+
 /** \addtogroup lnet_addr
  * @{
  */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 98570b3..80f7985 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2868,6 +2868,7 @@ static int __init kiblnd_module_init(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Kernel OpenIB gen2 LND v2.00");
+MODULE_VERSION("2.7.0");
 MODULE_LICENSE("GPL");
 
 module_init(kiblnd_module_init);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 854814c..c37ebcf 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2926,8 +2926,8 @@ ksocknal_module_init(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Kernel TCP Socket LND v3.0.0");
+MODULE_VERSION("2.7.0");
 MODULE_LICENSE("GPL");
-MODULE_VERSION("3.0.0");
 
 module_init(ksocknal_module_init);
 module_exit(ksocknal_module_fini);
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index e12fe37..4923339 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -225,8 +225,8 @@ fini_lnet(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("LNet v3.1");
+MODULE_VERSION(LNET_VERSION);
 MODULE_LICENSE("GPL");
-MODULE_VERSION("1.0.0");
 
 module_init(init_lnet);
 module_exit(fini_lnet);
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 3e48b0a..05c1de1 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -150,8 +150,8 @@ error:
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("LNet Selftest");
+MODULE_VERSION("2.7.0");
 MODULE_LICENSE("GPL");
-MODULE_VERSION("0.9.0");
 
 module_init(lnet_selftest_init);
 module_exit(lnet_selftest_fini);
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 70400aa..d832796 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -466,8 +466,8 @@ static void __exit fid_mod_exit(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre FID Module");
+MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
-MODULE_VERSION("0.1.0");
 
 module_init(fid_mod_init);
 module_exit(fid_mod_exit);
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 19b81c9..f3f95b8 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -501,6 +501,7 @@ static void __exit fld_mod_exit(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre FLD");
+MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
 module_init(fld_mod_init)
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index de6688e..778cfe3 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -666,7 +666,7 @@ static void exit_libcfs_module(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Portals v3.1");
-MODULE_VERSION("1.0.0");
+MODULE_VERSION(LIBCFS_VERSION);
 MODULE_LICENSE("GPL");
 
 module_init(init_libcfs_module);
diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index 3f53292..8550a9b 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -878,4 +878,5 @@ module_param(max_loop, int, 0444);
 MODULE_PARM_DESC(max_loop, "maximum of lloop_device");
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre virtual block device");
+MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 79e1322..3fb9f62 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -210,6 +210,7 @@ static void __exit exit_lustre_lite(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Lite Client File System");
+MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
 module_init(init_lustre_lite);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 68afc29..7102cbf 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2784,6 +2784,7 @@ static void lmv_exit(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Logical Metadata Volume OBD driver");
+MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
 module_init(lmv_init);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 7bdb205..a4f3e70 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2537,6 +2537,7 @@ static void /*__exit*/ mdc_exit(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Metadata Client");
+MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
 module_init(mdc_init);
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 68c3c84..f5a85bb 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1748,6 +1748,7 @@ static void /*__exit*/ mgc_exit(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Management Client");
+MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
 
 module_init(mgc_init);
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 06b04d2..8e6b8c9 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -577,8 +577,8 @@ static void cleanup_obdclass(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Class Driver Build Version: " LUSTRE_VERSION_STRING);
-MODULE_LICENSE("GPL");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
+MODULE_LICENSE("GPL");
 
 module_init(init_obdclass);
 module_exit(cleanup_obdclass);
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index ab56e67..77e0196 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1890,8 +1890,8 @@ static void /*__exit*/ obdecho_exit(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Testing Echo OBD driver");
-MODULE_LICENSE("GPL");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
+MODULE_LICENSE("GPL");
 
 module_init(obdecho_init);
 module_exit(obdecho_exit);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
index c4f1d0f..a8ec0e9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
@@ -162,8 +162,8 @@ static void __exit ptlrpc_exit(void)
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Request Processor and Lock Management");
+MODULE_VERSION(LUSTRE_VERSION_STRING);
 MODULE_LICENSE("GPL");
-MODULE_VERSION("1.0.0");
 
 module_init(ptlrpc_init);
 module_exit(ptlrpc_exit);
-- 
1.7.1
