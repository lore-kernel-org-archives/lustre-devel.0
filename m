From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:01 -0500
Subject: [lustre-devel] [PATCH 29/45] staging/lustre/libcfs: Move
	EXPORT_SYMBOLs under function/variable
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-30-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Found with checkpatch

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/debug.c               | 4 ++--
 drivers/staging/lustre/lustre/libcfs/hash.c                | 1 -
 drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c | 7 +++----
 drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c   | 5 ++---
 4 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/debug.c b/drivers/staging/lustre/lustre/libcfs/debug.c
index 9cb8f04..9bb31f9 100644
--- a/drivers/staging/lustre/lustre/libcfs/debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/debug.c
@@ -47,15 +47,15 @@
 static char debug_file_name[1024];
 
 unsigned int libcfs_subsystem_debug = ~0;
+EXPORT_SYMBOL(libcfs_subsystem_debug);
 module_param(libcfs_subsystem_debug, int, 0644);
 MODULE_PARM_DESC(libcfs_subsystem_debug, "Lustre kernel debug subsystem mask");
-EXPORT_SYMBOL(libcfs_subsystem_debug);
 
 unsigned int libcfs_debug = (D_CANTMASK |
 			     D_NETERROR | D_HA | D_CONFIG | D_IOCTL);
+EXPORT_SYMBOL(libcfs_debug);
 module_param(libcfs_debug, int, 0644);
 MODULE_PARM_DESC(libcfs_debug, "Lustre kernel debug mask");
-EXPORT_SYMBOL(libcfs_debug);
 
 static int libcfs_param_debug_mb_set(const char *val,
 				     const struct kernel_param *kp)
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 51d72f0..414577c 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -1702,7 +1702,6 @@ out:
 	cfs_hash_unlock(hs, 0);
 	cfs_hash_for_each_exit(hs);
 }
-
 EXPORT_SYMBOL(cfs_hash_hlist_for_each);
 
 /*
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c
index 68515d9..13d31e8 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c
@@ -65,6 +65,7 @@ void cfs_cap_raise(cfs_cap_t cap)
 		commit_creds(cred);
 	}
 }
+EXPORT_SYMBOL(cfs_cap_raise);
 
 void cfs_cap_lower(cfs_cap_t cap)
 {
@@ -76,11 +77,13 @@ void cfs_cap_lower(cfs_cap_t cap)
 		commit_creds(cred);
 	}
 }
+EXPORT_SYMBOL(cfs_cap_lower);
 
 int cfs_cap_raised(cfs_cap_t cap)
 {
 	return cap_raised(current_cap(), cap);
 }
+EXPORT_SYMBOL(cfs_cap_raised);
 
 static void cfs_kernel_cap_pack(kernel_cap_t kcap, cfs_cap_t *cap)
 {
@@ -95,10 +98,6 @@ cfs_cap_t cfs_curproc_cap_pack(void)
 	cfs_kernel_cap_pack(current_cap(), &cap);
 	return cap;
 }
-
-EXPORT_SYMBOL(cfs_cap_raise);
-EXPORT_SYMBOL(cfs_cap_lower);
-EXPORT_SYMBOL(cfs_cap_raised);
 EXPORT_SYMBOL(cfs_curproc_cap_pack);
 
 /*
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
index 565f990..04203b3 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
@@ -144,6 +144,7 @@ void libcfs_run_lbug_upcall(struct libcfs_debug_msg_data *msgdata)
 
 	libcfs_run_upcall (argv);
 }
+EXPORT_SYMBOL(libcfs_run_lbug_upcall);
 
 /* coverity[+kill] */
 void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
@@ -166,6 +167,7 @@ void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
 	while (1)
 		schedule();
 }
+EXPORT_SYMBOL(lbug_with_loc);
 
 static int panic_notifier(struct notifier_block *self, unsigned long unused1,
 			  void *unused2)
@@ -194,6 +196,3 @@ void libcfs_unregister_panic_notifier(void)
 {
 	atomic_notifier_chain_unregister(&panic_notifier_list, &libcfs_panic_notifier);
 }
-
-EXPORT_SYMBOL(libcfs_run_lbug_upcall);
-EXPORT_SYMBOL(lbug_with_loc);
-- 
2.1.0
