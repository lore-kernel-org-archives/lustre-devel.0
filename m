From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 Nov 2015 13:40:05 -0500
Subject: [lustre-devel] [PATCH 09/10] staging: lustre: remove
	page_collection::pc_lock in libcfs
In-Reply-To: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
References: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446662406-4590-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Liang Zhen <liang.zhen@intel.com>

page_collection::pc_lock is supposed to protect race between
functions called by smp_call_function(), however we don't have
this use-case for ages and page_collection only lives in stack
of thread, so it is safe to remove it.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3055
Reviewed-on: http://review.whamcloud.com/7660
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Sebastien Buisson <sebastien.buisson@bull.net>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/libcfs/tracefile.c |   14 --------------
 drivers/staging/lustre/lustre/libcfs/tracefile.h |    8 --------
 2 files changed, 0 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index 973c7c2..6fe7dfb 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -199,7 +199,6 @@ static void cfs_tcd_shrink(struct cfs_trace_cpu_data *tcd)
 		       pgcount + 1, tcd->tcd_cur_pages);
 
 	INIT_LIST_HEAD(&pc.pc_pages);
-	spin_lock_init(&pc.pc_lock);
 
 	list_for_each_entry_safe(tage, tmp, &tcd->tcd_pages, linkage) {
 		if (pgcount-- == 0)
@@ -522,7 +521,6 @@ static void collect_pages_on_all_cpus(struct page_collection *pc)
 	struct cfs_trace_cpu_data *tcd;
 	int i, cpu;
 
-	spin_lock(&pc->pc_lock);
 	for_each_possible_cpu(cpu) {
 		cfs_tcd_for_each_type_lock(tcd, i, cpu) {
 			list_splice_init(&tcd->tcd_pages, &pc->pc_pages);
@@ -534,7 +532,6 @@ static void collect_pages_on_all_cpus(struct page_collection *pc)
 			}
 		}
 	}
-	spin_unlock(&pc->pc_lock);
 }
 
 static void collect_pages(struct page_collection *pc)
@@ -555,7 +552,6 @@ static void put_pages_back_on_all_cpus(struct page_collection *pc)
 	struct cfs_trace_page *tmp;
 	int i, cpu;
 
-	spin_lock(&pc->pc_lock);
 	for_each_possible_cpu(cpu) {
 		cfs_tcd_for_each_type_lock(tcd, i, cpu) {
 			cur_head = tcd->tcd_pages.next;
@@ -573,7 +569,6 @@ static void put_pages_back_on_all_cpus(struct page_collection *pc)
 			}
 		}
 	}
-	spin_unlock(&pc->pc_lock);
 }
 
 static void put_pages_back(struct page_collection *pc)
@@ -592,7 +587,6 @@ static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
 	struct cfs_trace_page *tage;
 	struct cfs_trace_page *tmp;
 
-	spin_lock(&pc->pc_lock);
 	list_for_each_entry_safe(tage, tmp, &pc->pc_pages, linkage) {
 
 		__LASSERT_TAGE_INVARIANT(tage);
@@ -616,7 +610,6 @@ static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
 			tcd->tcd_cur_daemon_pages--;
 		}
 	}
-	spin_unlock(&pc->pc_lock);
 }
 
 static void put_pages_on_daemon_list(struct page_collection *pc)
@@ -636,8 +629,6 @@ void cfs_trace_debug_print(void)
 	struct cfs_trace_page *tage;
 	struct cfs_trace_page *tmp;
 
-	spin_lock_init(&pc.pc_lock);
-
 	pc.pc_want_daemon_pages = 1;
 	collect_pages(&pc);
 	list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
@@ -692,7 +683,6 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		goto out;
 	}
 
-	spin_lock_init(&pc.pc_lock);
 	pc.pc_want_daemon_pages = 1;
 	collect_pages(&pc);
 	if (list_empty(&pc.pc_pages)) {
@@ -739,8 +729,6 @@ void cfs_trace_flush_pages(void)
 	struct cfs_trace_page *tage;
 	struct cfs_trace_page *tmp;
 
-	spin_lock_init(&pc.pc_lock);
-
 	pc.pc_want_daemon_pages = 1;
 	collect_pages(&pc);
 	list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
@@ -970,7 +958,6 @@ static int tracefiled(void *arg)
 	/* we're started late enough that we pick up init's fs context */
 	/* this is so broken in uml?  what on earth is going on? */
 
-	spin_lock_init(&pc.pc_lock);
 	complete(&tctl->tctl_start);
 
 	while (1) {
@@ -1170,7 +1157,6 @@ static void cfs_trace_cleanup(void)
 	struct page_collection pc;
 
 	INIT_LIST_HEAD(&pc.pc_pages);
-	spin_lock_init(&pc.pc_lock);
 
 	trace_cleanup_on_all_cpus();
 
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index cb7a396..de37fb7 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -196,14 +196,6 @@ extern union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS];
 struct page_collection {
 	struct list_head	pc_pages;
 	/*
-	 * spin-lock protecting ->pc_pages. It is taken by smp_call_function()
-	 * call-back functions. XXX nikita: Which is horrible: all processors
-	 * receive NMI at the same time only to be serialized by this
-	 * lock. Probably ->pc_pages should be replaced with an array of
-	 * NR_CPUS elements accessed locklessly.
-	 */
-	spinlock_t	pc_lock;
-	/*
 	 * if this flag is set, collect_pages() will spill both
 	 * ->tcd_daemon_pages and ->tcd_pages to the ->pc_pages. Otherwise,
 	 * only ->tcd_pages are spilled.
-- 
1.7.1
