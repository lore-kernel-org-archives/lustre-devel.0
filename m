From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:00 -0500
Subject: [lustre-devel] [PATCH 28/45] staging/lustre/libcfs: Cleanup:
	parenthesis alignment adjustments
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-29-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Adjust alignment of argments that were pushed to next lines
to conform to kernel code style.
Found with checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/debug.c        |  3 +--
 drivers/staging/lustre/lustre/libcfs/hash.c         | 18 +++++++++---------
 .../staging/lustre/lustre/libcfs/libcfs_string.c    | 19 +++++++------------
 .../lustre/lustre/libcfs/linux/linux-debug.c        |  2 +-
 .../lustre/lustre/libcfs/linux/linux-module.c       |  4 ++--
 drivers/staging/lustre/lustre/libcfs/module.c       |  8 ++++----
 drivers/staging/lustre/lustre/libcfs/tracefile.c    | 21 +++++++++------------
 drivers/staging/lustre/lustre/libcfs/workitem.c     |  6 +++---
 8 files changed, 36 insertions(+), 45 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/debug.c b/drivers/staging/lustre/lustre/libcfs/debug.c
index 589b548..9cb8f04 100644
--- a/drivers/staging/lustre/lustre/libcfs/debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/debug.c
@@ -448,8 +448,7 @@ void libcfs_debug_dumplog_internal(void *arg)
 		snprintf(debug_file_name, sizeof(debug_file_name) - 1,
 			 "%s.%lld.%ld", libcfs_debug_file_path_arr,
 			 (s64)ktime_get_real_seconds(), (long_ptr_t)arg);
-		pr_alert("LustreError: dumping log to %s\n",
-		       debug_file_name);
+		pr_alert("LustreError: dumping log to %s\n", debug_file_name);
 		cfs_tracefile_dump_all_pages(debug_file_name);
 		libcfs_run_debug_log_upcall(debug_file_name);
 	}
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index ad831fa..51d72f0 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -2040,15 +2040,15 @@ void cfs_hash_debug_str(struct cfs_hash *hs, struct seq_file *m)
 	theta = __cfs_hash_theta(hs);
 
 	seq_printf(m, "%-*s %5d %5d %5d %d.%03d %d.%03d %d.%03d  0x%02x %6d ",
-		      CFS_HASH_BIGNAME_LEN, hs->hs_name,
-		      1 << hs->hs_cur_bits, 1 << hs->hs_min_bits,
-		      1 << hs->hs_max_bits,
-		      __cfs_hash_theta_int(theta), __cfs_hash_theta_frac(theta),
-		      __cfs_hash_theta_int(hs->hs_min_theta),
-		      __cfs_hash_theta_frac(hs->hs_min_theta),
-		      __cfs_hash_theta_int(hs->hs_max_theta),
-		      __cfs_hash_theta_frac(hs->hs_max_theta),
-		      hs->hs_flags, hs->hs_rehash_count);
+		   CFS_HASH_BIGNAME_LEN, hs->hs_name,
+		   1 << hs->hs_cur_bits, 1 << hs->hs_min_bits,
+		   1 << hs->hs_max_bits,
+		   __cfs_hash_theta_int(theta), __cfs_hash_theta_frac(theta),
+		   __cfs_hash_theta_int(hs->hs_min_theta),
+		   __cfs_hash_theta_frac(hs->hs_min_theta),
+		   __cfs_hash_theta_int(hs->hs_max_theta),
+		   __cfs_hash_theta_frac(hs->hs_max_theta),
+		   hs->hs_flags, hs->hs_rehash_count);
 
 	/*
 	 * The distribution is a summary of the chained hash depth in
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index f3bcf20..f7cda59 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -343,11 +343,10 @@ cfs_range_expr_print(char *buffer, int count, struct cfs_range_expr *expr,
 		i = scnprintf(buffer, count, "%u", expr->re_lo);
 	else if (expr->re_stride == 1)
 		i = scnprintf(buffer, count, "%s%u-%u%s",
-				s, expr->re_lo, expr->re_hi, e);
+			      s, expr->re_lo, expr->re_hi, e);
 	else
 		i = scnprintf(buffer, count, "%s%u-%u/%u%s",
-				s, expr->re_lo, expr->re_hi,
-				expr->re_stride, e);
+			      s, expr->re_lo, expr->re_hi, expr->re_stride, e);
 	return i;
 }
 
@@ -469,7 +468,7 @@ cfs_expr_list_free(struct cfs_expr_list *expr_list)
 		struct cfs_range_expr *expr;
 
 		expr = list_entry(expr_list->el_exprs.next,
-				      struct cfs_range_expr, re_link);
+				  struct cfs_range_expr, re_link);
 		list_del(&expr->re_link);
 		LIBCFS_FREE(expr, sizeof(*expr));
 	}
@@ -520,15 +519,12 @@ cfs_expr_list_parse(char *str, int len, unsigned min, unsigned max,
 			if (rc != 0)
 				break;
 
-			list_add_tail(&expr->re_link,
-					  &expr_list->el_exprs);
+			list_add_tail(&expr->re_link, &expr_list->el_exprs);
 		}
 	} else {
 		rc = cfs_range_expr_parse(&src, min, max, 0, &expr);
-		if (rc == 0) {
-			list_add_tail(&expr->re_link,
-					  &expr_list->el_exprs);
-		}
+		if (rc == 0)
+			list_add_tail(&expr->re_link, &expr_list->el_exprs);
 	}
 
 	if (rc != 0)
@@ -554,8 +550,7 @@ cfs_expr_list_free_list(struct list_head *list)
 	struct cfs_expr_list *el;
 
 	while (!list_empty(list)) {
-		el = list_entry(list->next,
-				    struct cfs_expr_list, el_link);
+		el = list_entry(list->next, struct cfs_expr_list, el_link);
 		list_del(&el->el_link);
 		cfs_expr_list_free(el);
 	}
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
index 85deec9..565f990 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
@@ -168,7 +168,7 @@ void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
 }
 
 static int panic_notifier(struct notifier_block *self, unsigned long unused1,
-			 void *unused2)
+			  void *unused2)
 {
 	if (libcfs_panic_in_progress)
 		return 0;
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
index cbb44d7..ff90772 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
@@ -134,8 +134,8 @@ static long libcfs_ioctl(struct file *file,
 		return -EACCES;
 
 	if (_IOC_TYPE(cmd) != IOC_LIBCFS_TYPE ||
-	     _IOC_NR(cmd) < IOC_LIBCFS_MIN_NR  ||
-	     _IOC_NR(cmd) > IOC_LIBCFS_MAX_NR) {
+	    _IOC_NR(cmd) < IOC_LIBCFS_MIN_NR  ||
+	    _IOC_NR(cmd) > IOC_LIBCFS_MAX_NR) {
 		CDEBUG(D_IOCTL, "invalid ioctl ( type %d, nr %d, size %d )\n",
 		       _IOC_TYPE(cmd), _IOC_NR(cmd), _IOC_SIZE(cmd));
 		return -EINVAL;
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index cf1498a..b8b69bb 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -192,9 +192,9 @@ struct cfs_psdev_ops libcfs_psdev_ops = {
 };
 
 static int proc_call_handler(void *data, int write, loff_t *ppos,
-		void __user *buffer, size_t *lenp,
-		int (*handler)(void *data, int write,
-		loff_t pos, void __user *buffer, int len))
+			     void __user *buffer, size_t *lenp,
+			     int (*handler)(void *data, int write, loff_t pos,
+					    void __user *buffer, int len))
 {
 	int rc = handler(data, write, *ppos, buffer, *lenp);
 
@@ -361,7 +361,7 @@ static int __proc_cpt_table(void *data, int write,
 }
 
 static int proc_cpt_table(struct ctl_table *table, int write,
-			   void __user *buffer, size_t *lenp, loff_t *ppos)
+			  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	return proc_call_handler(table->data, write, ppos, buffer, lenp,
 				 __proc_cpt_table);
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index c8f6a07..28a11b5 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -503,8 +503,7 @@ panic_collect_pages(struct page_collection *pc)
 		tcd->tcd_cur_pages = 0;
 
 		if (pc->pc_want_daemon_pages) {
-			list_splice_init(&tcd->tcd_daemon_pages,
-					     &pc->pc_pages);
+			list_splice_init(&tcd->tcd_daemon_pages, &pc->pc_pages);
 			tcd->tcd_cur_daemon_pages = 0;
 		}
 	}
@@ -521,7 +520,7 @@ static void collect_pages_on_all_cpus(struct page_collection *pc)
 			tcd->tcd_cur_pages = 0;
 			if (pc->pc_want_daemon_pages) {
 				list_splice_init(&tcd->tcd_daemon_pages,
-						     &pc->pc_pages);
+						 &pc->pc_pages);
 				tcd->tcd_cur_daemon_pages = 0;
 			}
 		}
@@ -673,7 +672,7 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		rc = PTR_ERR(filp);
 		filp = NULL;
 		pr_err("LustreError: can't open %s for dump: rc %d\n",
-			filename, rc);
+		       filename, rc);
 		goto out;
 	}
 
@@ -872,7 +871,7 @@ int cfs_trace_daemon_command_usrstr(void __user *usr_str, int usr_str_nob)
 		return rc;
 
 	rc = cfs_trace_copyin_string(str, usr_str_nob + 1,
-				 usr_str, usr_str_nob);
+				     usr_str, usr_str_nob);
 	if (rc == 0)
 		rc = cfs_trace_daemon_command(str);
 
@@ -980,8 +979,7 @@ static int tracefiled(void *arg)
 
 		MMSPACE_OPEN;
 
-		list_for_each_entry_safe(tage, tmp, &pc.pc_pages,
-						   linkage) {
+		list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
 			static loff_t f_pos;
 
 			__LASSERT_TAGE_INVARIANT(tage);
@@ -1012,8 +1010,7 @@ static int tracefiled(void *arg)
 			int i;
 
 			printk(KERN_ALERT "Lustre: trace pages aren't empty\n");
-			pr_err("total cpus(%d): ",
-				num_possible_cpus());
+			pr_err("total cpus(%d): ", num_possible_cpus());
 			for (i = 0; i < num_possible_cpus(); i++)
 				if (cpu_online(i))
 					pr_cont("%d(on) ", i);
@@ -1023,9 +1020,9 @@ static int tracefiled(void *arg)
 
 			i = 0;
 			list_for_each_entry_safe(tage, tmp, &pc.pc_pages,
-						     linkage)
+						 linkage)
 				pr_err("page %d belongs to cpu %d\n",
-					++i, tage->cpu);
+				       ++i, tage->cpu);
 			pr_err("There are %d pages unwritten\n", i);
 		}
 		__LASSERT(list_empty(&pc.pc_pages));
@@ -1130,7 +1127,7 @@ static void trace_cleanup_on_all_cpus(void)
 			tcd->tcd_shutting_down = 1;
 
 			list_for_each_entry_safe(tage, tmp, &tcd->tcd_pages,
-							   linkage) {
+						 linkage) {
 				__LASSERT_TAGE_INVARIANT(tage);
 
 				list_del(&tage->linkage);
diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index 97ae5c1..24400df 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -234,8 +234,8 @@ cfs_wi_scheduler (void *arg)
 
 		while (!list_empty(&sched->ws_runq) &&
 		       nloops < CFS_WI_RESCHED) {
-			wi = list_entry(sched->ws_runq.next,
-					    cfs_workitem_t, wi_list);
+			wi = list_entry(sched->ws_runq.next, cfs_workitem_t,
+					wi_list);
 			LASSERT(wi->wi_scheduled && !wi->wi_running);
 
 			list_del_init(&wi->wi_list);
@@ -455,7 +455,7 @@ cfs_wi_shutdown(void)
 	}
 	while (!list_empty(&cfs_wi_data.wi_scheds)) {
 		sched = list_entry(cfs_wi_data.wi_scheds.next,
-				       struct cfs_wi_sched, ws_list);
+				   struct cfs_wi_sched, ws_list);
 		list_del(&sched->ws_list);
 		LIBCFS_FREE(sched, sizeof(*sched));
 	}
-- 
2.1.0
