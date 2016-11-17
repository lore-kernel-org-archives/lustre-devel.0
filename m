From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:53 -0500
Subject: [lustre-devel] [PATCH 15/19] staging: lustre: libcfs: Make char *
	array envp static constant
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The envp char array can be made static constant.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/libcfs/linux/linux-debug.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
index 8d37938..d8a9894 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
@@ -69,10 +69,11 @@ void libcfs_run_debug_log_upcall(char *file)
 {
 	char *argv[3];
 	int rc;
-	char *envp[] = {
+	static const char * const envp[] = {
 		"HOME=/",
 		"PATH=/sbin:/bin:/usr/sbin:/usr/bin",
-		NULL};
+		NULL
+	};
 
 	argv[0] = lnet_debug_log_upcall;
 
@@ -81,7 +82,7 @@ void libcfs_run_debug_log_upcall(char *file)
 
 	argv[2] = NULL;
 
-	rc = call_usermodehelper(argv[0], argv, envp, 1);
+	rc = call_usermodehelper(argv[0], argv, (char **)envp, 1);
 	if (rc < 0 && rc != -ENOENT) {
 		CERROR("Error %d invoking LNET debug log upcall %s %s; check /sys/kernel/debug/lnet/debug_log_upcall\n",
 		       rc, argv[0], argv[1]);
@@ -95,10 +96,11 @@ void libcfs_run_upcall(char **argv)
 {
 	int rc;
 	int argc;
-	char *envp[] = {
+	static const char * const envp[] = {
 		"HOME=/",
 		"PATH=/sbin:/bin:/usr/sbin:/usr/bin",
-		NULL};
+		NULL
+	};
 
 	argv[0] = lnet_upcall;
 	argc = 1;
@@ -107,7 +109,7 @@ void libcfs_run_upcall(char **argv)
 
 	LASSERT(argc >= 2);
 
-	rc = call_usermodehelper(argv[0], argv, envp, 1);
+	rc = call_usermodehelper(argv[0], argv, (char **)envp, 1);
 	if (rc < 0 && rc != -ENOENT) {
 		CERROR("Error %d invoking LNET upcall %s %s%s%s%s%s%s%s%s; check /sys/kernel/debug/lnet/upcall\n",
 		       rc, argv[0], argv[1],
-- 
1.7.1
