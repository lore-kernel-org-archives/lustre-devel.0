From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:07 -0500
Subject: [lustre-devel] [PATCH 35/45] staging/lustre/libcfs: Move private
	tracefile structs out of header
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-36-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

the struct page_collection, struct cfs_trace_page and
struct tracefiled_ctl are only used by tracefile.c, so move them
there.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/tracefile.c | 45 +++++++++++++++++++++
 drivers/staging/lustre/lustre/libcfs/tracefile.h | 51 ------------------------
 2 files changed, 45 insertions(+), 51 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index 9191f38..298135f 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -56,6 +56,51 @@ static int thread_running;
 
 static atomic_t cfs_tage_allocated = ATOMIC_INIT(0);
 
+struct page_collection {
+	struct list_head	pc_pages;
+	/*
+	 * if this flag is set, collect_pages() will spill both
+	 * ->tcd_daemon_pages and ->tcd_pages to the ->pc_pages. Otherwise,
+	 * only ->tcd_pages are spilled.
+	 */
+	int		pc_want_daemon_pages;
+};
+
+struct tracefiled_ctl {
+	struct completion	tctl_start;
+	struct completion	tctl_stop;
+	wait_queue_head_t		tctl_waitq;
+	pid_t			tctl_pid;
+	atomic_t		tctl_shutdown;
+};
+
+/*
+ * small data-structure for each page owned by tracefiled.
+ */
+struct cfs_trace_page {
+	/*
+	 * page itself
+	 */
+	struct page	  *page;
+	/*
+	 * linkage into one of the lists in trace_data_union or
+	 * page_collection
+	 */
+	struct list_head	   linkage;
+	/*
+	 * number of bytes used within this page
+	 */
+	unsigned int	 used;
+	/*
+	 * cpu that owns this page
+	 */
+	unsigned short       cpu;
+	/*
+	 * type(context) of this page
+	 */
+	unsigned short       type;
+};
+
 static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
 					 struct cfs_trace_cpu_data *tcd);
 
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index 0995da1..2d4dc73 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -195,57 +195,6 @@ extern union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS];
 	     (tcd = &(*cfs_trace_data[i])[cpu].tcd) &&			\
 	     cfs_trace_lock_tcd(tcd, 1); cfs_trace_unlock_tcd(tcd, 1), i++)
 
-/* XXX nikita: this declaration is internal to tracefile.c and should probably
- * be moved there */
-struct page_collection {
-	struct list_head	pc_pages;
-	/*
-	 * if this flag is set, collect_pages() will spill both
-	 * ->tcd_daemon_pages and ->tcd_pages to the ->pc_pages. Otherwise,
-	 * only ->tcd_pages are spilled.
-	 */
-	int		pc_want_daemon_pages;
-};
-
-/* XXX nikita: this declaration is internal to tracefile.c and should probably
- * be moved there */
-struct tracefiled_ctl {
-	struct completion	tctl_start;
-	struct completion	tctl_stop;
-	wait_queue_head_t		tctl_waitq;
-	pid_t			tctl_pid;
-	atomic_t		tctl_shutdown;
-};
-
-/*
- * small data-structure for each page owned by tracefiled.
- */
-/* XXX nikita: this declaration is internal to tracefile.c and should probably
- * be moved there */
-struct cfs_trace_page {
-	/*
-	 * page itself
-	 */
-	struct page	  *page;
-	/*
-	 * linkage into one of the lists in trace_data_union or
-	 * page_collection
-	 */
-	struct list_head	   linkage;
-	/*
-	 * number of bytes used within this page
-	 */
-	unsigned int	 used;
-	/*
-	 * cpu that owns this page
-	 */
-	unsigned short       cpu;
-	/*
-	 * type(context) of this page
-	 */
-	unsigned short       type;
-};
-
 void cfs_set_ptldebug_header(struct ptldebug_header *header,
 			     struct libcfs_debug_msg_data *m,
 			     unsigned long stack);
-- 
2.1.0
