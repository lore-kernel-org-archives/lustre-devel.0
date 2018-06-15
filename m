From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 07/24] lustre: merge libcfs module into lnet.
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669029.10587.7251524855971260363.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We want to ultimately make libcfs disappear.  This step
makes the module disappear - all libcfs code is now included
in the lnet module.
This mean the lnet module_init function needs to call lnet_init().
Also the module parameters have changed names so we need to update
the links from debugs.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/Makefile        |    7 ++++++-
 drivers/staging/lustre/lnet/libcfs/Makefile |    5 ++---
 drivers/staging/lustre/lnet/libcfs/module.c |   26 +++++++++-----------------
 drivers/staging/lustre/lnet/lnet/Makefile   |   11 +++++------
 drivers/staging/lustre/lnet/lnet/module.c   |    9 +++++++++
 5 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lnet/Makefile b/drivers/staging/lustre/lnet/Makefile
index 0a380fe88ce8..e28be81e36cf 100644
--- a/drivers/staging/lustre/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/Makefile
@@ -1 +1,6 @@
-obj-$(CONFIG_LNET) += libcfs/ lnet/ klnds/ selftest/
+# SPDX-License-Identifier: GPL-2.0
+
+obj-$(CONFIG_LNET) += klnds/ selftest/
+obj-$(CONFIG_LNET) += lnet.o
+
+lnet-y = libcfs/ lnet/
diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index 5b13edc72837..1b6937c3deee 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -1,8 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
 ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
-
-obj-$(CONFIG_LNET) += libcfs.o
+ccflags-y += -DKBUILD_MODNAME='"lnet"'
 
 libcfs-obj-y += linux-tracefile.o linux-debug.o
 libcfs-obj-y += linux-crypto.o
@@ -13,4 +12,4 @@ libcfs-obj-y += libcfs_string.o hash.o
 libcfs-obj-$(CONFIG_SMP) += libcfs_cpu.o
 libcfs-obj-y += libcfs_mem.o libcfs_lock.o
 
-libcfs-objs := $(libcfs-obj-y)
+modobj-$(CONFIG_LNET) += $(libcfs-obj-y)
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 02c404c6738e..b3eb0789425b 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -513,19 +513,19 @@ static struct ctl_table lnet_table[] = {
 
 static const struct lnet_debugfs_symlink_def lnet_debugfs_symlinks[] = {
 	{ "console_ratelimit",
-	  "/sys/module/libcfs/parameters/libcfs_console_ratelimit"},
+	  "/sys/module/lnet/parameters/libcfs_console_ratelimit"},
 	{ "debug_path",
-	  "/sys/module/libcfs/parameters/libcfs_debug_file_path"},
+	  "/sys/module/lnet/parameters/libcfs_debug_file_path"},
 	{ "panic_on_lbug",
-	  "/sys/module/libcfs/parameters/libcfs_panic_on_lbug"},
+	  "/sys/module/lnet/parameters/libcfs_panic_on_lbug"},
 	{ "libcfs_console_backoff",
-	  "/sys/module/libcfs/parameters/libcfs_console_backoff"},
+	  "/sys/module/lnet/parameters/libcfs_console_backoff"},
 	{ "debug_mb",
-	  "/sys/module/libcfs/parameters/libcfs_debug_mb"},
+	  "/sys/module/lnet/parameters/libcfs_debug_mb"},
 	{ "console_min_delay_centisecs",
-	  "/sys/module/libcfs/parameters/libcfs_console_min_delay"},
+	  "/sys/module/lnet/parameters/libcfs_console_min_delay"},
 	{ "console_max_delay_centisecs",
-	  "/sys/module/libcfs/parameters/libcfs_console_max_delay"},
+	  "/sys/module/lnet/parameters/libcfs_console_max_delay"},
 	{},
 };
 
@@ -688,7 +688,7 @@ int libcfs_setup(void)
 }
 EXPORT_SYMBOL(libcfs_setup);
 
-static int libcfs_init(void)
+int libcfs_init(void)
 {
 	int rc;
 
@@ -700,7 +700,7 @@ static int libcfs_init(void)
 	return rc;
 }
 
-static void libcfs_exit(void)
+void libcfs_exit(void)
 {
 	int rc;
 
@@ -720,11 +720,3 @@ static void libcfs_exit(void)
 	if (rc)
 		pr_err("LustreError: libcfs_debug_cleanup: %d\n", rc);
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre helper library");
-MODULE_VERSION(LIBCFS_VERSION);
-MODULE_LICENSE("GPL");
-
-module_init(libcfs_init);
-module_exit(libcfs_exit);
diff --git a/drivers/staging/lustre/lnet/lnet/Makefile b/drivers/staging/lustre/lnet/lnet/Makefile
index cbbb52133591..8323d98a9a1a 100644
--- a/drivers/staging/lustre/lnet/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/lnet/Makefile
@@ -1,10 +1,9 @@
 # SPDX-License-Identifier: GPL-2.0
 ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+ccflags-y += -DKBUILD_MODNAME='"lnet"'
 
-obj-$(CONFIG_LNET) += lnet.o
-
-lnet-y := api-ni.o config.o nidstrings.o net_fault.o		\
-	  lib-me.o lib-msg.o lib-eq.o lib-md.o lib-ptl.o	\
-	  lib-socket.o lib-move.o module.o lo.o			\
-	  router.o router_proc.o acceptor.o peer.o
+modobj-$(CONFIG_LNET) += api-ni.o config.o nidstrings.o net_fault.o
+modobj-$(CONFIG_LNET) += lib-me.o lib-msg.o lib-eq.o lib-md.o lib-ptl.o
+modobj-$(CONFIG_LNET) += lib-socket.o lib-move.o module.o lo.o
+modobj-$(CONFIG_LNET) += router.o router_proc.o acceptor.o peer.o
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 9d06664f0c17..52bbe4524bb2 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -36,6 +36,9 @@
 #include <linux/lnet/lib-lnet.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
 
+int libcfs_init(void);
+void libcfs_exit(void);
+
 static int config_on_load;
 module_param(config_on_load, int, 0444);
 MODULE_PARM_DESC(config_on_load, "configure network at module load");
@@ -192,6 +195,10 @@ static int __init lnet_init(void)
 {
 	int rc;
 
+	rc = libcfs_init();
+	if (rc)
+		return rc;
+
 	mutex_init(&lnet_config_mutex);
 
 	rc = libcfs_setup();
@@ -228,12 +235,14 @@ static void __exit lnet_exit(void)
 	LASSERT(!rc);
 
 	lnet_lib_exit();
+	libcfs_exit();
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Networking layer");
 MODULE_VERSION(LNET_VERSION);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("libcfs");
 
 module_init(lnet_init);
 module_exit(lnet_exit);
