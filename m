From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:57 -0500
Subject: [lustre-devel] [PATCH 609/622] lnet: libcfs: Cleanup use of bare
 printk
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-610-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <stancheff@cray.com>

Some users of printk(<LEVEL> "fmt" can be converted to
pr_level("fmt" equivalents

WC-bug-id: https://jira.whamcloud.com/browse/LU-12861
Lustre-commit: b4c8a5180dec ("LU-12861 libcfs: Cleanup use of bare printk")
Signed-off-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-on: https://review.whamcloud.com/37046
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/debug.c     |  2 +-
 net/lnet/libcfs/module.c    |  4 ++--
 net/lnet/libcfs/tracefile.c | 43 +++++++++++++++++++++++++------------------
 3 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index c6b92df..d7747e7 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -418,7 +418,7 @@ void libcfs_debug_dumplog(void)
 			     "libcfs_debug_dumper");
 	set_current_state(TASK_INTERRUPTIBLE);
 	if (IS_ERR(dumper))
-		pr_err("LustreError: cannot start log dump thread: %ld\n",
+		pr_err("LustreError: cannot start log dump thread: rc = %ld\n",
 		       PTR_ERR(dumper));
 	else
 		schedule();
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index 20d4302..a53efcc 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -720,7 +720,7 @@ int libcfs_setup(void)
 
 	rc = libcfs_debug_init(5 * 1024 * 1024);
 	if (rc < 0) {
-		pr_err("LustreError: libcfs_debug_init: %d\n", rc);
+		pr_err("LustreError: libcfs_debug_init: rc = %d\n", rc);
 		goto err;
 	}
 
@@ -794,7 +794,7 @@ static void libcfs_exit(void)
 	/* the below message is checked in test-framework.sh check_mem_leak() */
 	rc = libcfs_debug_cleanup();
 	if (rc)
-		pr_err("LustreError: libcfs_debug_cleanup: %d\n", rc);
+		pr_err("LustreError: libcfs_debug_cleanup: rc = %d\n", rc);
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index bda3523..1eb5397 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -332,7 +332,8 @@ static struct cfs_trace_page *cfs_trace_get_tage(struct cfs_trace_cpu_data *tcd,
 	 * from here: this will lead to infinite recursion.
 	 */
 	if (len > PAGE_SIZE) {
-		pr_err("cowardly refusing to write %lu bytes in a page\n", len);
+		pr_err("LustreError: cowardly refusing to write %lu bytes in a page\n",
+		       len);
 		return NULL;
 	}
 
@@ -477,7 +478,8 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 
 		max_nob = PAGE_SIZE - tage->used - known_size;
 		if (max_nob <= 0) {
-			pr_emerg("negative max_nob: %d\n", max_nob);
+			pr_emerg("LustreError: negative max_nob: %d\n",
+				 max_nob);
 			mask |= D_ERROR;
 			cfs_trace_put_tcd(tcd);
 			tcd = NULL;
@@ -499,10 +501,15 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 			break;
 	}
 
-	if (*(string_buf + needed - 1) != '\n')
-		pr_info("format@%s:%d:%s doesn't end in newline\n", file,
-			msgdata->msg_line, msgdata->msg_fn);
-
+	if (*(string_buf + needed - 1) != '\n') {
+		pr_info("Lustre: format at %s:%d:%s doesn't end in newline\n",
+			file, msgdata->msg_line, msgdata->msg_fn);
+	} else if (mask & D_TTY) {
+		/* TTY needs '\r\n' to move carriage to leftmost position */
+		if (needed < 2 || *(string_buf + needed - 2) != '\r')
+			pr_info("Lustre: format@%s:%d:%s doesn't end in '\\r\\n'\n",
+				file, msgdata->msg_line, msgdata->msg_fn);
+	}
 	header.ph_len = known_size + needed;
 	debug_buf = (char *)page_address(tage->page) + tage->used;
 
@@ -816,7 +823,7 @@ int cfs_tracefile_dump_all_pages(char *filename)
 	if (IS_ERR(filp)) {
 		rc = PTR_ERR(filp);
 		filp = NULL;
-		pr_err("LustreError: can't open %s for dump: rc %d\n",
+		pr_err("LustreError: can't open %s for dump: rc = %d\n",
 		       filename, rc);
 		goto out;
 	}
@@ -839,8 +846,8 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		kunmap(tage->page);
 
 		if (rc != (int)tage->used) {
-			pr_warn("wanted to write %u but wrote %d\n", tage->used,
-				rc);
+			pr_warn("Lustre: wanted to write %u but wrote %d\n",
+				tage->used, rc);
 			put_pages_back(&pc);
 			__LASSERT(list_empty(&pc.pc_pages));
 			break;
@@ -851,7 +858,7 @@ int cfs_tracefile_dump_all_pages(char *filename)
 
 	rc = vfs_fsync(filp, 1);
 	if (rc)
-		pr_err("sync returns %d\n", rc);
+		pr_err("LustreError: sync returns: rc = %d\n", rc);
 close:
 	filp_close(filp, NULL);
 out:
@@ -985,7 +992,7 @@ int cfs_trace_daemon_command(char *str)
 	} else {
 		strcpy(cfs_tracefile, str);
 
-		pr_info("debug daemon will attempt to start writing to %s (%lukB max)\n",
+		pr_info("Lustre: debug daemon will attempt to start writing to %s (%lukB max)\n",
 			cfs_tracefile,
 			(long)(cfs_tracefile_size >> 10));
 
@@ -1100,8 +1107,8 @@ static int tracefiled(void *arg)
 			if (IS_ERR(filp)) {
 				rc = PTR_ERR(filp);
 				filp = NULL;
-				pr_warn("couldn't open %s: %d\n", cfs_tracefile,
-					rc);
+				pr_warn("Lustre: couldn't open %s: rc = %d\n",
+					cfs_tracefile, rc);
 			}
 		}
 		up_read(&cfs_tracefile_sem);
@@ -1126,7 +1133,7 @@ static int tracefiled(void *arg)
 			kunmap(tage->page);
 
 			if (rc != (int)tage->used) {
-				pr_warn("wanted to write %u but wrote %d\n",
+				pr_warn("Lustre: wanted to write %u but wrote %d\n",
 					tage->used, rc);
 				put_pages_back(&pc);
 				__LASSERT(list_empty(&pc.pc_pages));
@@ -1139,8 +1146,8 @@ static int tracefiled(void *arg)
 		if (!list_empty(&pc.pc_pages)) {
 			int i;
 
-			pr_alert("trace pages aren't empty\n");
-			pr_err("total cpus(%d): ", num_possible_cpus());
+			pr_alert("Lustre: trace pages aren't empty\n");
+			pr_err("Lustre: total cpus(%d): ", num_possible_cpus());
 			for (i = 0; i < num_possible_cpus(); i++)
 				if (cpu_online(i))
 					pr_cont("%d(on) ", i);
@@ -1151,9 +1158,9 @@ static int tracefiled(void *arg)
 			i = 0;
 			list_for_each_entry_safe(tage, tmp, &pc.pc_pages,
 						 linkage)
-				pr_err("page %d belongs to cpu %d\n",
+				pr_err("Lustre: page %d belongs to cpu %d\n",
 				       ++i, tage->cpu);
-			pr_err("There are %d pages unwritten\n", i);
+			pr_err("Lustre: There are %d pages unwritten\n", i);
 		}
 		__LASSERT(list_empty(&pc.pc_pages));
 end_loop:
-- 
1.8.3.1
