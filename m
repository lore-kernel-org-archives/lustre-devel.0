Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8AC8BC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:16 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7BE5D201127;
	Sun, 28 Nov 2021 15:28:10 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 036F62010C8
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:03 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C9846276;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C7804C1AC9; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:54 -0500
Message-Id: <1638142074-5945-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/19] lnet: libcfs: separate daemon_list
 from cfs_trace_data
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

cfs_trace_data provides a fifo for trace messages.  To minimize
locking, there is a separate fifo for each CPU, and even for different
interrupt levels per-cpu.

When a page is remove from the fifo to br written to a file, the page
is added to a "daemon_list".  Trace message on the daemon_list have
already been logged to a file, but can be easily dumped to the console
when a bug occurs.

The daemon_list is always accessed from a single thread at a time, so
the per-CPU facilities for cfs_trace_data are not needed.  However
daemon_list is currently managed per-cpu as part of cfs_trace_data.

This patch moves the daemon_list of pages out to a separate structure
- a simple linked list, protected by cfs_tracefile_sem.

Rather than using a 'cfs_trace_page' to hold linkage information and
content size, we use page->lru for linkage and page->private for
the size of the content in each page.

This is a step towards replacing cfs_trace_data with the Linux
ring_buffer which provides similar functionality with even less
locking.

In the current code, if the daemon which writes trace data to a file
cannot keep up with load, excess pages are moved to the daemon_list
temporarily before being discarded.  With the patch, these page are
simply discarded immediately.
If the daemon thread cannot keep up, that is a configuration problem
and temporarily preserving a few pages is unlikely to really help.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14428
Lustre-commit: 848738a85d82bb71c ("LU-14428 libcfs: separate daemon_list from cfs_trace_data")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41493
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/tracefile.c | 213 +++++++++++++++++++++++---------------------
 net/lnet/libcfs/tracefile.h |  17 +---
 2 files changed, 112 insertions(+), 118 deletions(-)

diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index e0ef234..b27732a 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -58,6 +58,13 @@ enum cfs_trace_buf_type {
 
 union cfs_trace_data_union (*cfs_trace_data[CFS_TCD_TYPE_CNT])[NR_CPUS] __cacheline_aligned;
 
+/* Pages containing records already processed by daemon.
+ * Link via ->lru, use size in ->private
+ */
+static LIST_HEAD(daemon_pages);
+static long daemon_pages_count;
+static long daemon_pages_max;
+
 char cfs_tracefile[TRACEFILE_NAME_SIZE];
 long long cfs_tracefile_size = CFS_TRACEFILE_SIZE;
 
@@ -68,12 +75,6 @@ enum cfs_trace_buf_type {
 
 struct page_collection {
 	struct list_head	pc_pages;
-	/*
-	 * if this flag is set, collect_pages() will spill both
-	 * ->tcd_daemon_pages and ->tcd_pages to the ->pc_pages. Otherwise,
-	 * only ->tcd_pages are spilled.
-	 */
-	int			pc_want_daemon_pages;
 };
 
 /*
@@ -103,9 +104,6 @@ struct cfs_trace_page {
 	unsigned short		type;
 };
 
-static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
-					 struct cfs_trace_cpu_data *tcd);
-
 /* trace file lock routines */
 /*
  * The walking argument indicates the locking comes from all tcd types
@@ -296,10 +294,10 @@ static void cfs_tcd_shrink(struct cfs_trace_cpu_data *tcd)
 		if (!pgcount--)
 			break;
 
-		list_move_tail(&tage->linkage, &pc.pc_pages);
+		list_del(&tage->linkage);
+		cfs_tage_free(tage);
 		tcd->tcd_cur_pages--;
 	}
-	put_pages_on_tcd_daemon_list(&pc, tcd);
 }
 
 /* return a page that has 'len' bytes left at the end */
@@ -678,11 +676,6 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 	cfs_tcd_for_each(tcd, i, j) {
 		list_splice_init(&tcd->tcd_pages, &pc->pc_pages);
 		tcd->tcd_cur_pages = 0;
-
-		if (pc->pc_want_daemon_pages) {
-			list_splice_init(&tcd->tcd_daemon_pages, &pc->pc_pages);
-			tcd->tcd_cur_daemon_pages = 0;
-		}
 	}
 }
 
@@ -695,11 +688,6 @@ static void collect_pages_on_all_cpus(struct page_collection *pc)
 		cfs_tcd_for_each_type_lock(tcd, i, cpu) {
 			list_splice_init(&tcd->tcd_pages, &pc->pc_pages);
 			tcd->tcd_cur_pages = 0;
-			if (pc->pc_want_daemon_pages) {
-				list_splice_init(&tcd->tcd_daemon_pages,
-						 &pc->pc_pages);
-				tcd->tcd_cur_daemon_pages = 0;
-			}
 		}
 	}
 }
@@ -746,64 +734,17 @@ static void put_pages_back(struct page_collection *pc)
 		put_pages_back_on_all_cpus(pc);
 }
 
-/* Add pages to a per-cpu debug daemon ringbuffer. This buffer makes sure that
- * we have a good amount of data at all times for dumping during an LBUG, even
- * if we have been steadily writing (and otherwise discarding) pages via the
- * debug daemon.
- */
-static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
-					 struct cfs_trace_cpu_data *tcd)
-{
-	struct cfs_trace_page *tage;
-	struct cfs_trace_page *tmp;
-
-	list_for_each_entry_safe(tage, tmp, &pc->pc_pages, linkage) {
-		__LASSERT_TAGE_INVARIANT(tage);
-
-		if (tage->cpu != tcd->tcd_cpu || tage->type != tcd->tcd_type)
-			continue;
-
-		cfs_tage_to_tail(tage, &tcd->tcd_daemon_pages);
-		tcd->tcd_cur_daemon_pages++;
-
-		if (tcd->tcd_cur_daemon_pages > tcd->tcd_max_pages) {
-			struct cfs_trace_page *victim;
-
-			__LASSERT(!list_empty(&tcd->tcd_daemon_pages));
-			victim = cfs_tage_from_list(tcd->tcd_daemon_pages.next);
-
-			__LASSERT_TAGE_INVARIANT(victim);
-
-			list_del(&victim->linkage);
-			cfs_tage_free(victim);
-			tcd->tcd_cur_daemon_pages--;
-		}
-	}
-}
-
-static void put_pages_on_daemon_list(struct page_collection *pc)
-{
-	struct cfs_trace_cpu_data *tcd;
-	int i, cpu;
-
-	for_each_possible_cpu(cpu) {
-		cfs_tcd_for_each_type_lock(tcd, i, cpu)
-			put_pages_on_tcd_daemon_list(pc, tcd);
-	}
-}
-
 #ifdef CONFIG_LNET_DUMP_ON_PANIC
 void cfs_trace_debug_print(void)
 {
 	struct page_collection pc;
 	struct cfs_trace_page *tage;
 	struct cfs_trace_page *tmp;
+	struct page *page;
 
-	pc.pc_want_daemon_pages = 1;
 	collect_pages(&pc);
 	list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
 		char *p, *file, *fn;
-		struct page *page;
 
 		__LASSERT_TAGE_INVARIANT(tage);
 
@@ -830,6 +771,34 @@ void cfs_trace_debug_print(void)
 		list_del(&tage->linkage);
 		cfs_tage_free(tage);
 	}
+	down_write(&cfs_tracefile_sem);
+	while ((page = list_first_entry_or_null(&daemon_pages,
+						struct page, lru)) != NULL) {
+		char *p, *file, *fn;
+
+		p = page_address(page);
+		while (p < ((char *)page_address(page) + page->private)) {
+			struct ptldebug_header *hdr;
+			int len;
+
+			hdr = (void *)p;
+			p += sizeof(*hdr);
+			file = p;
+			p += strlen(file) + 1;
+			fn = p;
+			p += strlen(fn) + 1;
+			len = hdr->ph_len - (int)(p - (char *)hdr);
+
+			cfs_print_to_console(hdr, D_EMERG, file, fn,
+					     "%.*s", len, p);
+
+			p += len;
+		}
+		list_del_init(&page->lru);
+		daemon_pages_count -= 1;
+		put_page(page);
+	}
+	up_write(&cfs_tracefile_sem);
 }
 #endif /* CONFIG_LNET_DUMP_ON_PANIC */
 
@@ -840,6 +809,7 @@ int cfs_tracefile_dump_all_pages(char *filename)
 	struct cfs_trace_page *tage;
 	struct cfs_trace_page *tmp;
 	char *buf;
+	struct page *page;
 	int rc;
 
 	down_write(&cfs_tracefile_sem);
@@ -854,7 +824,6 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		goto out;
 	}
 
-	pc.pc_want_daemon_pages = 1;
 	collect_pages(&pc);
 	if (list_empty(&pc.pc_pages)) {
 		rc = 0;
@@ -881,8 +850,20 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		list_del(&tage->linkage);
 		cfs_tage_free(tage);
 	}
-
-	rc = vfs_fsync(filp, 1);
+	while ((page = list_first_entry_or_null(&daemon_pages,
+						struct page, lru)) != NULL) {
+		buf = page_address(page);
+		rc = kernel_write(filp, buf, page->private, &filp->f_pos);
+		if (rc != (int)page->private) {
+			pr_warn("Lustre: wanted to write %u but wrote %d\n",
+				(int)page->private, rc);
+			break;
+		}
+		list_del(&page->lru);
+		daemon_pages_count -= 1;
+		put_page(page);
+	}
+	rc = vfs_fsync_range(filp, 0, LLONG_MAX, 1);
 	if (rc)
 		pr_err("LustreError: sync returns: rc = %d\n", rc);
 close:
@@ -896,8 +877,8 @@ void cfs_trace_flush_pages(void)
 {
 	struct page_collection pc;
 	struct cfs_trace_page *tage;
+	struct page *page;
 
-	pc.pc_want_daemon_pages = 1;
 	collect_pages(&pc);
 	while (!list_empty(&pc.pc_pages)) {
 		tage = list_first_entry(&pc.pc_pages,
@@ -907,6 +888,15 @@ void cfs_trace_flush_pages(void)
 		list_del(&tage->linkage);
 		cfs_tage_free(tage);
 	}
+
+	down_write(&cfs_tracefile_sem);
+	while ((page = list_first_entry_or_null(&daemon_pages,
+						struct page, lru)) != NULL) {
+		list_del(&page->lru);
+		daemon_pages_count -= 1;
+		put_page(page);
+	}
+	up_write(&cfs_tracefile_sem);
 }
 
 int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
@@ -1039,6 +1029,7 @@ int cfs_trace_set_debug_mb(int mb)
 	cfs_tcd_for_each(tcd, i, j)
 		tcd->tcd_max_pages = (pages * tcd->tcd_pages_factor) / 100;
 
+	daemon_pages_max = pages;
 	up_write(&cfs_tracefile_sem);
 
 	return mb;
@@ -1071,9 +1062,10 @@ static int tracefiled(void *arg)
 	int last_loop = 0;
 	int rc;
 
-	pc.pc_want_daemon_pages = 0;
-
 	while (!last_loop) {
+		LIST_HEAD(for_daemon_pages);
+		int for_daemon_pages_count = 0;
+
 		schedule_timeout_interruptible(HZ);
 		if (kthread_should_stop())
 			last_loop = 1;
@@ -1095,38 +1087,55 @@ static int tracefiled(void *arg)
 			}
 		}
 		up_read(&cfs_tracefile_sem);
-		if (!filp) {
-			put_pages_on_daemon_list(&pc);
-			__LASSERT(list_empty(&pc.pc_pages));
-			continue;
-		}
 
 		list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
-			struct dentry *de = file_dentry(filp);
-			static loff_t f_pos;
-
 			__LASSERT_TAGE_INVARIANT(tage);
 
-			if (f_pos >= (off_t)cfs_tracefile_size)
-				f_pos = 0;
-			else if (f_pos > i_size_read(de->d_inode))
-				f_pos = i_size_read(de->d_inode);
-
-			buf = kmap(tage->page);
-			rc = kernel_write(filp, buf, tage->used, &f_pos);
-			kunmap(tage->page);
-
-			if (rc != (int)tage->used) {
-				pr_warn("Lustre: wanted to write %u but wrote %d\n",
-					tage->used, rc);
-				put_pages_back(&pc);
-				__LASSERT(list_empty(&pc.pc_pages));
-				break;
+			if (filp) {
+				struct dentry *de = file_dentry(filp);
+				static loff_t f_pos;
+
+				if (f_pos >= (off_t)cfs_tracefile_size)
+					f_pos = 0;
+				else if (f_pos > i_size_read(de->d_inode))
+					f_pos = i_size_read(de->d_inode);
+
+				buf = kmap(tage->page);
+				rc = kernel_write(filp, buf, tage->used,
+						  &f_pos);
+				kunmap(tage->page);
+				if (rc != (int)tage->used) {
+					pr_warn("Lustre: wanted to write %u but wrote %d\n",
+						tage->used, rc);
+					put_pages_back(&pc);
+					__LASSERT(list_empty(&pc.pc_pages));
+					break;
+				}
 			}
+			list_del_init(&tage->linkage);
+			list_add_tail(&tage->page->lru, &for_daemon_pages);
+			for_daemon_pages_count += 1;
+
+			tage->page->private = (int)tage->used;
+			kfree(tage);
+			atomic_dec(&cfs_tage_allocated);
 		}
 
-		filp_close(filp, NULL);
-		put_pages_on_daemon_list(&pc);
+		if (filp)
+			filp_close(filp, NULL);
+
+		down_write(&cfs_tracefile_sem);
+		list_splice_tail(&for_daemon_pages, &daemon_pages);
+		daemon_pages_count += for_daemon_pages_count;
+		while (daemon_pages_count > daemon_pages_max) {
+			struct page *p = list_first_entry(&daemon_pages,
+							  struct page, lru);
+			list_del(&p->lru);
+			put_page(p);
+			daemon_pages_count -= 1;
+		}
+		up_write(&cfs_tracefile_sem);
+
 		if (!list_empty(&pc.pc_pages)) {
 			int i;
 
@@ -1233,14 +1242,13 @@ int cfs_tracefile_init(int max_pages)
 		tcd->tcd_cpu = j;
 		INIT_LIST_HEAD(&tcd->tcd_pages);
 		INIT_LIST_HEAD(&tcd->tcd_stock_pages);
-		INIT_LIST_HEAD(&tcd->tcd_daemon_pages);
 		tcd->tcd_cur_pages = 0;
 		tcd->tcd_cur_stock_pages = 0;
-		tcd->tcd_cur_daemon_pages = 0;
 		tcd->tcd_max_pages = (max_pages * factor) / 100;
 		LASSERT(tcd->tcd_max_pages > 0);
 		tcd->tcd_shutting_down = 0;
 	}
+	daemon_pages_max = max_pages;
 
 	return 0;
 
@@ -1299,5 +1307,6 @@ static void cfs_trace_cleanup(void)
 void cfs_tracefile_exit(void)
 {
 	cfs_trace_stop_thread();
+	cfs_trace_flush_pages();
 	cfs_trace_cleanup();
 }
diff --git a/net/lnet/libcfs/tracefile.h b/net/lnet/libcfs/tracefile.h
index af21e4a..6293a9c 100644
--- a/net/lnet/libcfs/tracefile.h
+++ b/net/lnet/libcfs/tracefile.h
@@ -92,22 +92,7 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 		unsigned long		tcd_cur_pages;
 
 		/*
-		 * pages with trace records already processed by
-		 * tracefiled. These pages are kept in memory, so that some
-		 * portion of log can be written in the event of LBUG. This
-		 * list is maintained in LRU order.
-		 *
-		 * Pages are moved to ->tcd_daemon_pages by tracefiled()
-		 * (put_pages_on_daemon_list()). LRU pages from this list are
-		 * discarded when list grows too large.
-		 */
-		struct list_head	tcd_daemon_pages;
-		/* number of pages on ->tcd_daemon_pages */
-		unsigned long		tcd_cur_daemon_pages;
-
-		/*
-		 * Maximal number of pages allowed on ->tcd_pages and
-		 * ->tcd_daemon_pages each.
+		 * Maximal number of pages allowed on ->tcd_pages
 		 * Always TCD_MAX_PAGES * tcd_pages_factor / 100 in current
 		 * implementation.
 		 */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
