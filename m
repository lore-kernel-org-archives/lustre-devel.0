From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:07 -0500
Subject: [lustre-devel] [PATCH 39/60] staging: libcfs: remove integer types
	abstraction from libcfs
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Replace the ulong_ptr_t and long_ptr_t with standard
kernel types.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/20204
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h | 4 ----
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c        | 2 +-
 drivers/staging/lustre/lnet/libcfs/debug.c                 | 2 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c                | 4 ++--
 4 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
index e8695e4..fa0808d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
@@ -125,10 +125,6 @@
 
 #include <linux/capability.h>
 
-/* long integer with size equal to pointer */
-typedef unsigned long ulong_ptr_t;
-typedef long long_ptr_t;
-
 #ifndef WITH_WATCHDOG
 #define WITH_WATCHDOG
 #endif
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 2181c67..8aab001 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2507,7 +2507,7 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 
 		snprintf(name, sizeof(name), "socknal_cd%02d", i);
 		rc = ksocknal_thread_start(ksocknal_connd,
-					   (void *)((ulong_ptr_t)i), name);
+					   (void *)((uintptr_t)i), name);
 		if (rc) {
 			spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
 			ksocknal_data.ksnd_connd_starting--;
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index a38db23..3408041 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -343,7 +343,7 @@ void libcfs_debug_dumplog_internal(void *arg)
 		last_dump_time = current_time;
 		snprintf(debug_file_name, sizeof(debug_file_name) - 1,
 			 "%s.%lld.%ld", libcfs_debug_file_path_arr,
-			 (s64)current_time, (long_ptr_t)arg);
+			 (s64)current_time, (long)arg);
 		pr_alert("LustreError: dumping log to %s\n", debug_file_name);
 		cfs_tracefile_dump_all_pages(debug_file_name);
 		libcfs_run_debug_log_upcall(debug_file_name);
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index a55c6cd..b43a994 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -330,7 +330,7 @@
 	__u32 magic;
 	__u32 peer_ip;
 	int peer_port;
-	int secure = (int)((long_ptr_t)arg);
+	int secure = (int)((long)arg);
 
 	LASSERT(!lnet_acceptor_state.pta_sock);
 
@@ -459,7 +459,7 @@
 	if (!lnet_count_acceptor_nis())  /* not required */
 		return 0;
 
-	task = kthread_run(lnet_acceptor, (void *)(ulong_ptr_t)secure,
+	task = kthread_run(lnet_acceptor, (void *)(uintptr_t)secure,
 			   "acceptor_%03ld", secure);
 	if (IS_ERR(task)) {
 		rc2 = PTR_ERR(task);
-- 
1.8.3.1
