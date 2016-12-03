From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:29 -0500
Subject: [lustre-devel] [PATCH 22/22] staging: lustre: libcfs: remove lnet
	upcall code
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Zarochentsev <alexander.zarochentsev@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Zarochentsev <alexander.zarochentsev@seagate.com>

Removing lnet upcall infrastructure completely
as nobody uses it anymore. The upcall causes a delay
before calling BUG() and might even cause a hang
making getting a crash dump unreliable or containing
outdated info.

Signed-off-by: Alexander Zarochentsev <alexander.zarochentsev@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8418
Seagate-bug-id: MRP-2939
Reviewed-on: http://review.whamcloud.com/21440
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 .../lustre/include/linux/libcfs/libcfs_private.h   |    2 -
 .../staging/lustre/lnet/libcfs/linux/linux-debug.c |   54 --------------------
 drivers/staging/lustre/lnet/libcfs/module.c        |    8 ---
 4 files changed, 0 insertions(+), 65 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 70eb08e..cc2c0e9 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -125,7 +125,6 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 /**
  * The path of debug log dump upcall script.
  */
-extern char lnet_upcall[1024];
 extern char lnet_debug_log_upcall[1024];
 
 extern struct cfs_wi_sched *cfs_sched_rehash;
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 41a651f..aab15d8 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -169,8 +169,6 @@
 #define ntohs(x) ___ntohs(x)
 #endif
 
-void libcfs_run_upcall(char **argv);
-void libcfs_run_lbug_upcall(struct libcfs_debug_msg_data *msg);
 void libcfs_debug_dumplog(void);
 int libcfs_debug_init(unsigned long bufsize);
 int libcfs_debug_cleanup(void);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
index d8a9894..39a72e3 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
@@ -57,7 +57,6 @@
 
 #include <linux/kallsyms.h>
 
-char lnet_upcall[1024] = "/usr/lib/lustre/lnet_upcall";
 char lnet_debug_log_upcall[1024] = "/usr/lib/lustre/lnet_debug_log_upcall";
 
 /**
@@ -92,58 +91,6 @@ void libcfs_run_debug_log_upcall(char *file)
 	}
 }
 
-void libcfs_run_upcall(char **argv)
-{
-	int rc;
-	int argc;
-	static const char * const envp[] = {
-		"HOME=/",
-		"PATH=/sbin:/bin:/usr/sbin:/usr/bin",
-		NULL
-	};
-
-	argv[0] = lnet_upcall;
-	argc = 1;
-	while (argv[argc])
-		argc++;
-
-	LASSERT(argc >= 2);
-
-	rc = call_usermodehelper(argv[0], argv, (char **)envp, 1);
-	if (rc < 0 && rc != -ENOENT) {
-		CERROR("Error %d invoking LNET upcall %s %s%s%s%s%s%s%s%s; check /sys/kernel/debug/lnet/upcall\n",
-		       rc, argv[0], argv[1],
-		       argc < 3 ? "" : ",", argc < 3 ? "" : argv[2],
-		       argc < 4 ? "" : ",", argc < 4 ? "" : argv[3],
-		       argc < 5 ? "" : ",", argc < 5 ? "" : argv[4],
-		       argc < 6 ? "" : ",...");
-	} else {
-		CDEBUG(D_HA, "Invoked LNET upcall %s %s%s%s%s%s%s%s%s\n",
-		       argv[0], argv[1],
-		       argc < 3 ? "" : ",", argc < 3 ? "" : argv[2],
-		       argc < 4 ? "" : ",", argc < 4 ? "" : argv[3],
-		       argc < 5 ? "" : ",", argc < 5 ? "" : argv[4],
-		       argc < 6 ? "" : ",...");
-	}
-}
-
-void libcfs_run_lbug_upcall(struct libcfs_debug_msg_data *msgdata)
-{
-	char *argv[6];
-	char buf[32];
-
-	snprintf(buf, sizeof(buf), "%d", msgdata->msg_line);
-
-	argv[1] = "LBUG";
-	argv[2] = (char *)msgdata->msg_file;
-	argv[3] = (char *)msgdata->msg_fn;
-	argv[4] = buf;
-	argv[5] = NULL;
-
-	libcfs_run_upcall(argv);
-}
-EXPORT_SYMBOL(libcfs_run_lbug_upcall);
-
 /* coverity[+kill] */
 void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
 {
@@ -158,7 +105,6 @@ void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
 	dump_stack();
 	if (!libcfs_panic_on_lbug)
 		libcfs_debug_dumplog();
-	libcfs_run_lbug_upcall(msgdata);
 	if (libcfs_panic_on_lbug)
 		panic("LBUG");
 	set_task_state(current, TASK_UNINTERRUPTIBLE);
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 5884a33..161e042 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -365,14 +365,6 @@ static int proc_cpt_table(struct ctl_table *table, int write,
 		.mode     = 0444,
 		.proc_handler = &proc_cpt_table,
 	},
-
-	{
-		.procname = "upcall",
-		.data     = lnet_upcall,
-		.maxlen   = sizeof(lnet_upcall),
-		.mode     = 0644,
-		.proc_handler = &proc_dostring,
-	},
 	{
 		.procname = "debug_log_upcall",
 		.data     = lnet_debug_log_upcall,
-- 
1.7.1
