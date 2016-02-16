From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:15 -0500
Subject: [lustre-devel] [PATCH 43/45] staging/lustre/libcfs: Replace use of
	printk with pr_<level>
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-44-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This pacifies checkpatch amongst other things, also is shorter to write
and avoiding calls to printk_ratelimit() is also good.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/libcfs/linux/linux-tracefile.c   | 10 ++--
 drivers/staging/lustre/lustre/libcfs/tracefile.c   | 53 +++++++++-------------
 2 files changed, 27 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
index 809ea50..5aba132 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
@@ -89,7 +89,7 @@ int cfs_tracefile_init_arch(void)
 
 out:
 	cfs_tracefile_fini_arch();
-	printk(KERN_ERR "lnet: Not enough memory\n");
+	pr_err("lnet: Not enough memory\n");
 	return -ENOMEM;
 }
 
@@ -244,11 +244,11 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 	}
 
 	if ((mask & D_CONSOLE) != 0) {
-		printk("%s%s: %.*s", ptype, prefix, len, buf);
+		pr_err("%s%s: %.*s", ptype, prefix, len, buf);
 	} else {
-		printk("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
-		       hdr->ph_pid, hdr->ph_extern_pid, file, hdr->ph_line_num,
-		       fn, len, buf);
+		pr_warn("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
+			hdr->ph_pid, hdr->ph_extern_pid, file, hdr->ph_line_num,
+			fn, len, buf);
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index 53c1dd6..7df8f0a 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -194,11 +194,9 @@ cfs_trace_get_tage_try(struct cfs_trace_cpu_data *tcd, unsigned long len)
 		} else {
 			tage = cfs_tage_alloc(GFP_ATOMIC);
 			if (unlikely(!tage)) {
-				if ((!memory_pressure_get() ||
-				     in_interrupt()) && printk_ratelimit())
-					printk(KERN_WARNING
-					       "cannot allocate a tage (%ld)\n",
-					       tcd->tcd_cur_pages);
+				if ((!memory_pressure_get() || in_interrupt()))
+					pr_warn_ratelimited("cannot allocate a tage (%ld)\n",
+							    tcd->tcd_cur_pages);
 				return NULL;
 			}
 		}
@@ -233,9 +231,8 @@ static void cfs_tcd_shrink(struct cfs_trace_cpu_data *tcd)
 	 * from here: this will lead to infinite recursion.
 	 */
 
-	if (printk_ratelimit())
-		printk(KERN_WARNING "debug daemon buffer overflowed; discarding 10%% of pages (%d of %ld)\n",
-		       pgcount + 1, tcd->tcd_cur_pages);
+	pr_warn_ratelimited("debug daemon buffer overflowed; discarding 10%% of pages (%d of %ld)\n",
+			    pgcount + 1, tcd->tcd_cur_pages);
 
 	INIT_LIST_HEAD(&pc.pc_pages);
 
@@ -362,8 +359,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 
 		max_nob = PAGE_CACHE_SIZE - tage->used - known_size;
 		if (max_nob <= 0) {
-			printk(KERN_EMERG "negative max_nob: %d\n",
-			       max_nob);
+			pr_emerg("negative max_nob: %d\n", max_nob);
 			mask |= D_ERROR;
 			cfs_trace_put_tcd(tcd);
 			tcd = NULL;
@@ -393,8 +389,8 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	}
 
 	if (*(string_buf + needed - 1) != '\n')
-		printk(KERN_INFO "format@%s:%d:%s doesn't end in newline\n",
-		       file, msgdata->msg_line, msgdata->msg_fn);
+		pr_info("format at %s:%d:%s doesn't end in newline\n",
+			file, msgdata->msg_line, msgdata->msg_fn);
 
 	header.ph_len = known_size + needed;
 	debug_buf = (char *)page_address(tage->page) + tage->used;
@@ -743,8 +739,8 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		kunmap(tage->page);
 
 		if (rc != (int)tage->used) {
-			printk(KERN_WARNING "wanted to write %u but wrote %d\n",
-			       tage->used, rc);
+			pr_warn("wanted to write %u but wrote %d\n",
+				tage->used, rc);
 			put_pages_back(&pc);
 			__LASSERT(list_empty(&pc.pc_pages));
 			break;
@@ -895,10 +891,8 @@ int cfs_trace_daemon_command(char *str)
 	} else {
 		strcpy(cfs_tracefile, str);
 
-		printk(KERN_INFO
-		       "Lustre: debug daemon will attempt to start writing to %s (%lukB max)\n",
-		       cfs_tracefile,
-		       (long)(cfs_tracefile_size >> 10));
+		pr_info("Lustre: debug daemon will attempt to start writing to %s (%lukB max)\n",
+			cfs_tracefile, (long)(cfs_tracefile_size >> 10));
 
 		cfs_trace_start_thread();
 	}
@@ -934,16 +928,14 @@ int cfs_trace_set_debug_mb(int mb)
 	struct cfs_trace_cpu_data *tcd;
 
 	if (mb < num_possible_cpus()) {
-		printk(KERN_WARNING
-		       "Lustre: %d MB is too small for debug buffer size, setting it to %d MB.\n",
-		       mb, num_possible_cpus());
+		pr_warn("Lustre: %d MB is too small for debug buffer size, setting it to %d MB.\n",
+			mb, num_possible_cpus());
 		mb = num_possible_cpus();
 	}
 
 	if (mb > limit) {
-		printk(KERN_WARNING
-		       "Lustre: %d MB is too large for debug buffer size, setting it to %d MB.\n",
-		       mb, limit);
+		pr_warn("Lustre: %d MB is too large for debug buffer size, setting it to %d MB.\n",
+			mb, limit);
 		mb = limit;
 	}
 
@@ -1012,8 +1004,8 @@ static int tracefiled(void *arg)
 			if (IS_ERR(filp)) {
 				rc = PTR_ERR(filp);
 				filp = NULL;
-				printk(KERN_WARNING "couldn't open %s: %d\n",
-				       cfs_tracefile, rc);
+				pr_warn("couldn't open %s: %d\n",
+					cfs_tracefile, rc);
 			}
 		}
 		cfs_tracefile_read_unlock();
@@ -1041,8 +1033,8 @@ static int tracefiled(void *arg)
 			kunmap(tage->page);
 
 			if (rc != (int)tage->used) {
-				printk(KERN_WARNING "wanted to write %u but wrote %d\n",
-				       tage->used, rc);
+				pr_warn("wanted to write %u but wrote %d\n",
+					tage->used, rc);
 				put_pages_back(&pc);
 				__LASSERT(list_empty(&pc.pc_pages));
 				break;
@@ -1055,7 +1047,7 @@ static int tracefiled(void *arg)
 		if (!list_empty(&pc.pc_pages)) {
 			int i;
 
-			printk(KERN_ALERT "Lustre: trace pages aren't empty\n");
+			pr_alert("Lustre: trace pages aren't empty\n");
 			pr_err("total cpus(%d): ", num_possible_cpus());
 			for (i = 0; i < num_possible_cpus(); i++)
 				if (cpu_online(i))
@@ -1123,8 +1115,7 @@ void cfs_trace_stop_thread(void)
 
 	mutex_lock(&cfs_trace_thread_mutex);
 	if (thread_running) {
-		printk(KERN_INFO
-		       "Lustre: shutting down debug daemon thread...\n");
+		pr_info("Lustre: shutting down debug daemon thread...\n");
 		atomic_set(&tctl->tctl_shutdown, 1);
 		wait_for_completion(&tctl->tctl_stop);
 		thread_running = 0;
-- 
2.1.0
