From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:02 -0500
Subject: [lustre-devel] [PATCH 30/45] staging/lustre/libcfs: style change to
	add missing spaces for operations
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-31-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This fixes checkpatch messages about
"spaces preferred around that '-' (ctx:VxV)"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/debug.c                 | 2 +-
 drivers/staging/lustre/lustre/libcfs/linux/linux-mem.c       | 2 +-
 drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c | 2 +-
 drivers/staging/lustre/lustre/libcfs/tracefile.c             | 7 ++++---
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/debug.c b/drivers/staging/lustre/lustre/libcfs/debug.c
index 9bb31f9..fa81582 100644
--- a/drivers/staging/lustre/lustre/libcfs/debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/debug.c
@@ -418,7 +418,7 @@ libcfs_debug_str2mask(int *mask, const char *str, int is_subsys)
 	/* Allow a number for backwards compatibility */
 
 	for (n = strlen(str); n > 0; n--)
-		if (!isspace(str[n-1]))
+		if (!isspace(str[n - 1]))
 			break;
 	matched = n;
 	t = sscanf(str, "%i%n", &m, &matched);
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-mem.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-mem.c
index 025e2f0..86f32ff 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-mem.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-mem.c
@@ -50,7 +50,7 @@ void *libcfs_kvzalloc_cpt(struct cfs_cpt_table *cptab, int cpt, size_t size,
 	ret = kzalloc_node(size, flags | __GFP_NOWARN,
 			   cfs_cpt_spread_node(cptab, cpt));
 	if (!ret) {
-		WARN_ON(!(flags & (__GFP_FS|__GFP_HIGH)));
+		WARN_ON(!(flags & (__GFP_FS | __GFP_HIGH)));
 		ret = vmalloc_node(size, cfs_cpt_spread_node(cptab, cpt));
 	}
 
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
index 89944c0..5e3c400 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
@@ -268,5 +268,5 @@ int cfs_trace_max_debug_mb(void)
 {
 	int  total_mb = (totalram_pages >> (20 - PAGE_SHIFT));
 
-	return max(512, (total_mb * 80)/100);
+	return max(512, (total_mb * 80) / 100);
 }
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index 28a11b5..967f8d7 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -346,7 +346,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 			break;
 	}
 
-	if (*(string_buf+needed-1) != '\n')
+	if (*(string_buf + needed - 1) != '\n')
 		printk(KERN_INFO "format at %s:%d:%s doesn't end in newline\n",
 		       file, msgdata->msg_line, msgdata->msg_fn);
 
@@ -436,7 +436,7 @@ console:
 			remain = CFS_TRACE_CONSOLE_BUFFER_SIZE - needed;
 			if (remain > 0) {
 				va_start(ap, format2);
-				needed += vsnprintf(string_buf+needed, remain,
+				needed += vsnprintf(string_buf + needed, remain,
 						    format2, ap);
 				va_end(ap);
 			}
@@ -667,7 +667,8 @@ int cfs_tracefile_dump_all_pages(char *filename)
 
 	cfs_tracefile_write_lock();
 
-	filp = filp_open(filename, O_CREAT|O_EXCL|O_WRONLY|O_LARGEFILE, 0600);
+	filp = filp_open(filename, O_CREAT | O_EXCL | O_WRONLY | O_LARGEFILE,
+			 0600);
 	if (IS_ERR(filp)) {
 		rc = PTR_ERR(filp);
 		filp = NULL;
-- 
2.1.0
