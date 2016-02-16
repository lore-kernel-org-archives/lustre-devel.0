From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:05 -0500
Subject: [lustre-devel] [PATCH 33/45] staging/lustre/libcfs: Shortened too
	long lines
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-34-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Lines that were too long for not good reason were shortened in this patch.
Found with checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c | 6 ++++--
 drivers/staging/lustre/lustre/libcfs/tracefile.c         | 6 +++---
 drivers/staging/lustre/lustre/libcfs/workitem.c          | 3 ++-
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
index 3f3c2d9..638e4b3 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
@@ -189,10 +189,12 @@ static struct notifier_block libcfs_panic_notifier = {
 
 void libcfs_register_panic_notifier(void)
 {
-	atomic_notifier_chain_register(&panic_notifier_list, &libcfs_panic_notifier);
+	atomic_notifier_chain_register(&panic_notifier_list,
+				       &libcfs_panic_notifier);
 }
 
 void libcfs_unregister_panic_notifier(void)
 {
-	atomic_notifier_chain_unregister(&panic_notifier_list, &libcfs_panic_notifier);
+	atomic_notifier_chain_unregister(&panic_notifier_list,
+					 &libcfs_panic_notifier);
 }
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index d9bb2b5..9191f38 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -399,9 +399,9 @@ console:
 			return 1;
 		}
 
-		if (cfs_time_after(cfs_time_current(), cdls->cdls_next +
-						       libcfs_console_max_delay
-						       + cfs_time_seconds(10))) {
+		if (cfs_time_after(cfs_time_current(),
+				   cdls->cdls_next + libcfs_console_max_delay +
+				   cfs_time_seconds(10))) {
 			/* last timeout was a long time ago */
 			cdls->cdls_delay /= libcfs_console_backoff * 4;
 		} else {
diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index 9d80cfb..e234dfe 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -46,7 +46,8 @@
 #define CFS_WS_NAME_LEN	 16
 
 struct cfs_wi_sched {
-	struct list_head		ws_list;	/* chain on global list */
+	/* chain on global list */
+	struct list_head		ws_list;
 	/** serialised workitems */
 	spinlock_t		ws_lock;
 	/** where schedulers sleep */
-- 
2.1.0
