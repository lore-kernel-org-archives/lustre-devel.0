From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:35 -0500
Subject: [lustre-devel] [PATCH 03/45] staging/lustre/libcfs: Get rid of
	/proc references in comments
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Now that the sysfs conversion is complete, also convert all the
remaining comments

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c | 4 ++--
 drivers/staging/lustre/lustre/libcfs/module.c            | 4 ----
 drivers/staging/lustre/lustre/libcfs/tracefile.c         | 7 ++++---
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
index 59c7bf3..3358c3b 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
@@ -87,7 +87,7 @@ void libcfs_run_debug_log_upcall(char *file)
 
 	rc = call_usermodehelper(argv[0], argv, envp, 1);
 	if (rc < 0 && rc != -ENOENT) {
-		CERROR("Error %d invoking LNET debug log upcall %s %s; check /proc/sys/lnet/debug_log_upcall\n",
+		CERROR("Error %d invoking LNET debug log upcall %s %s; check /sys/kernel/debug/lnet/debug_log_upcall\n",
 		       rc, argv[0], argv[1]);
 	} else {
 		CDEBUG(D_HA, "Invoked LNET debug log upcall %s %s\n",
@@ -113,7 +113,7 @@ void libcfs_run_upcall(char **argv)
 
 	rc = call_usermodehelper(argv[0], argv, envp, 1);
 	if (rc < 0 && rc != -ENOENT) {
-		CERROR("Error %d invoking LNET upcall %s %s%s%s%s%s%s%s%s; check /proc/sys/lnet/upcall\n",
+		CERROR("Error %d invoking LNET upcall %s %s%s%s%s%s%s%s%s; check /sys/kernel/debug/lnet/upcall\n",
 		       rc, argv[0], argv[1],
 		       argc < 3 ? "" : ",", argc < 3 ? "" : argv[2],
 		       argc < 4 ? "" : ",", argc < 4 ? "" : argv[3],
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 611607a..45838b5 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -368,10 +368,6 @@ static int proc_cpt_table(struct ctl_table *table, int write,
 }
 
 static struct ctl_table lnet_table[] = {
-	/*
-	 * NB No .strategy entries have been provided since sysctl(8) prefers
-	 * to go via /proc for portability.
-	 */
 	{
 		.procname = "debug",
 		.data     = &libcfs_debug,
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index 65c4f1a..a7d9b78 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -771,9 +771,10 @@ EXPORT_SYMBOL(cfs_trace_copyin_string);
 int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 			     const char *knl_buffer, char *append)
 {
-	/* NB if 'append' != NULL, it's a single character to append to the
-	 * copied out string - usually "\n", for /proc entries and "" (i.e. a
-	 * terminating zero byte) for sysctl entries */
+	/*
+	 * NB if 'append' != NULL, it's a single character to append to the
+	 * copied out string - usually "\n" or "" (i.e. a terminating zero byte)
+	 */
 	int   nob = strlen(knl_buffer);
 
 	if (nob > usr_buffer_nob)
-- 
2.1.0
