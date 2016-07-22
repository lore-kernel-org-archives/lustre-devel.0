From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:30 -0400
Subject: [lustre-devel] [PATCH 37/58] staging: lustre: libcfs: Only dump log
	once per sec. to avoid EEXIST
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ryan Haasken <haasken@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ryan Haasken <haasken@cray.com>

Since the log file name contains the current time in seconds, dumping
the logs more than once per second causes EEXIST errors to be emitted.
Add a static variable to libcfs_debug_dumplog_internal that records
the time of the last Lustre log dump.  If the current time in seconds
is equal to the last time, do not dump logs again.

Note that this is not thread-safe.  However, in the rare case that two
threads try to access last_dump_time simultaneously, the worst thing
that could happen is that one of the threads will get an EEXIST error
when trying to write the log file.  This is no worse than the current
situation, and it is not likely to happen.

Signed-off-by: Ryan Haasken <haasken@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4129
Reviewed-on: http://review.whamcloud.com/8964
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/debug.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 42b15a7..23b36b8 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -328,15 +328,20 @@ libcfs_debug_str2mask(int *mask, const char *str, int is_subsys)
  */
 void libcfs_debug_dumplog_internal(void *arg)
 {
+	static time64_t last_dump_time;
+	time64_t current_time;
 	void *journal_info;
 
 	journal_info = current->journal_info;
 	current->journal_info = NULL;
+	current_time = ktime_get_real_seconds();
 
-	if (strncmp(libcfs_debug_file_path_arr, "NONE", 4) != 0) {
+	if (strncmp(libcfs_debug_file_path_arr, "NONE", 4) &&
+	    current_time > last_dump_time) {
+		last_dump_time = current_time;
 		snprintf(debug_file_name, sizeof(debug_file_name) - 1,
 			 "%s.%lld.%ld", libcfs_debug_file_path_arr,
-			 (s64)ktime_get_real_seconds(), (long_ptr_t)arg);
+			 (s64)current_time, (long_ptr_t)arg);
 		pr_alert("LustreError: dumping log to %s\n", debug_file_name);
 		cfs_tracefile_dump_all_pages(debug_file_name);
 		libcfs_run_debug_log_upcall(debug_file_name);
-- 
1.7.1
