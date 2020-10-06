From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:48 -0400
Subject: [lustre-devel] [PATCH 09/42] lnet: libcfs: don't save journal_info
 in dumplog thread.
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

As this thread is started by kthread, it must have
a clean environment and cannot possibly be in a
filesystem transaction.  So current->journal_info
must be NULL, and preserving it serves no purpose.

Also change libcfs_debug_dumplog_internal() to 'static'
to make it clear that it shouldn't be called from
anywhere but this thread.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: 2eba3f9c3de50 ("LU-9859 libcfs: don't save journal_info in dumplog thread.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39294
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/debug.c     | 7 +------
 net/lnet/libcfs/tracefile.h | 1 -
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index dd03520..ba32a99 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -372,14 +372,11 @@ static void libcfs_run_debug_log_upcall(char *file)
 /**
  * Dump Lustre log to ::debug_file_path by calling tracefile_dump_all_pages()
  */
-void libcfs_debug_dumplog_internal(void *arg)
+static void libcfs_debug_dumplog_internal(void *arg)
 {
 	static time64_t last_dump_time;
 	time64_t current_time;
-	void *journal_info;
 
-	journal_info = current->journal_info;
-	current->journal_info = NULL;
 	current_time = ktime_get_real_seconds();
 
 	if (strncmp(libcfs_debug_file_path_arr, "NONE", 4) &&
@@ -392,8 +389,6 @@ void libcfs_debug_dumplog_internal(void *arg)
 		cfs_tracefile_dump_all_pages(debug_file_name);
 		libcfs_run_debug_log_upcall(debug_file_name);
 	}
-
-	current->journal_info = journal_info;
 }
 
 static int libcfs_debug_dumplog_thread(void *arg)
diff --git a/net/lnet/libcfs/tracefile.h b/net/lnet/libcfs/tracefile.h
index 88ff0d1..5b90c1b 100644
--- a/net/lnet/libcfs/tracefile.h
+++ b/net/lnet/libcfs/tracefile.h
@@ -69,7 +69,6 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 int cfs_trace_set_debug_mb(int mb);
 int cfs_trace_get_debug_mb(void);
 
-void libcfs_debug_dumplog_internal(void *arg);
 extern int libcfs_panic_in_progress;
 
 #define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
-- 
1.8.3.1
