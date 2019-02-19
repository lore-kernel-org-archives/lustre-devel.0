From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:06 +1100
Subject: [lustre-devel] [PATCH 26/37] lustre: remove libcfs_debug_vmsg2
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494624.24125.18162964077735119291.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Now that libcfs_debug_vmsg2 has no (external) users, we can remove it.
It is used to implement libcfs_debug_msg(), so simply move
the body of the function (suitably modified) into that one caller.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     |    5 --
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   63 +++++---------------
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |    2 -
 3 files changed, 18 insertions(+), 52 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index ba5d5ba2dac2..911fd35b81b5 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -192,11 +192,6 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 		     const char *format1, ...)
 	__printf(2, 3);
 
-int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
-		       const char *format1,
-		       va_list args, const char *format2, ...)
-	__printf(4, 5);
-
 /* other external symbols that tracefile provides: */
 int cfs_trace_copyin_string(char *knl_buffer, int knl_buffer_nob,
 			    const char __user *usr_buffer, int usr_buffer_nob);
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 40440ce13050..45da892cf276 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -409,22 +409,7 @@ static void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 }
 
 int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
-		     const char *format, ...)
-{
-	va_list args;
-	int rc;
-
-	va_start(args, format);
-	rc = libcfs_debug_vmsg2(msgdata, format, args, NULL);
-	va_end(args);
-
-	return rc;
-}
-EXPORT_SYMBOL(libcfs_debug_msg);
-
-int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
-		       const char *format1, va_list args,
-		       const char *format2, ...)
+		       const char *format, ...)
 {
 	struct cfs_trace_cpu_data *tcd = NULL;
 	struct ptldebug_header header = { 0 };
@@ -488,7 +473,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 		}
 
 		string_buf = (char *)page_address(tage->page) +
-			     tage->used + known_size;
+			tage->used + known_size;
 
 		max_nob = PAGE_SIZE - tage->used - known_size;
 		if (max_nob <= 0) {
@@ -500,22 +485,15 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 		}
 
 		needed = 0;
-		if (format1) {
-			va_copy(ap, args);
-			needed = vsnprintf(string_buf, max_nob, format1, ap);
-			va_end(ap);
-		}
 
-		if (format2) {
-			remain = max_nob - needed;
-			if (remain < 0)
-				remain = 0;
+		remain = max_nob - needed;
+		if (remain < 0)
+			remain = 0;
 
-			va_start(ap, format2);
-			needed += vsnprintf(string_buf + needed, remain,
-					    format2, ap);
-			va_end(ap);
-		}
+		va_start(ap, format);
+		needed += vsnprintf(string_buf + needed, remain,
+				    format, ap);
+		va_end(ap);
 
 		if (needed < max_nob) /* well. printing ok.. */
 			break;
@@ -600,22 +578,15 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 		string_buf = cfs_trace_get_console_buffer();
 
 		needed = 0;
-		if (format1) {
-			va_copy(ap, args);
-			needed = vsnprintf(string_buf,
-					   CFS_TRACE_CONSOLE_BUFFER_SIZE,
-					   format1, ap);
+
+		remain = CFS_TRACE_CONSOLE_BUFFER_SIZE - needed;
+		if (remain > 0) {
+			va_start(ap, format);
+			needed += vsnprintf(string_buf + needed, remain,
+					    format, ap);
 			va_end(ap);
 		}
-		if (format2) {
-			remain = CFS_TRACE_CONSOLE_BUFFER_SIZE - needed;
-			if (remain > 0) {
-				va_start(ap, format2);
-				needed += vsnprintf(string_buf + needed, remain,
-						    format2, ap);
-				va_end(ap);
-			}
-		}
+
 		cfs_print_to_console(&header, mask,
 				     string_buf, needed, file, msgdata->msg_fn);
 
@@ -639,7 +610,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 
 	return 0;
 }
-EXPORT_SYMBOL(libcfs_debug_vmsg2);
+EXPORT_SYMBOL(libcfs_debug_msg);
 
 void
 cfs_trace_assertion_failed(const char *str,
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 71a031d12f42..3a00a6c60653 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -82,7 +82,7 @@ union cfs_trace_data_union {
 		 * Even though this structure is meant to be per-CPU, locking
 		 * is needed because in some places the data may be accessed
 		 * from other CPUs. This lock is directly used in trace_get_tcd
-		 * and trace_put_tcd, which are called in libcfs_debug_vmsg2 and
+		 * and trace_put_tcd, which are called in libcfs_debug_msg and
 		 * tcd_for_each_type_lock
 		 */
 		spinlock_t		tcd_lock;
