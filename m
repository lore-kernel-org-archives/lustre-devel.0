From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 Jun 2018 17:42:51 -0400
Subject: [lustre-devel] [PATCH v2 2/7] lustre: libcfs: open code
 cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
In-Reply-To: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
References: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529962976-15048-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This function in used twice.
In libcfs_debug_init() the usage is pointless as
the only place that set libcfs_debug_mb ensures
that it does not exceed the maximum.  So checking
again can never help.

So open-code the small function into the only
other place that it is used - in cfs_trace_set_debug_mb(),
which is used to set libcfs_debug_mb.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/debug.c           | 6 +++---
 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c | 7 -------
 drivers/staging/lustre/lnet/libcfs/tracefile.c       | 3 ++-
 3 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 06f694f..71effcf 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -411,10 +411,10 @@ int libcfs_debug_init(unsigned long bufsize)
 			sizeof(libcfs_debug_file_path_arr));
 	}
 
-	/* If libcfs_debug_mb is set to an invalid value or uninitialized
-	 * then just make the total buffers smp_num_cpus * TCD_MAX_PAGES
+	/* If libcfs_debug_mb is uninitialized then just make the
+	 * total buffers smp_num_cpus * TCD_MAX_PAGES
 	 */
-	if (max > cfs_trace_max_debug_mb() || max < num_possible_cpus()) {
+	if (max < num_possible_cpus()) {
 		max = TCD_MAX_PAGES;
 	} else {
 		max = max / num_possible_cpus();
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
index 9e72220..64a5bc1 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
@@ -227,10 +227,3 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 			hdr->ph_line_num, fn, len, buf);
 	}
 }
-
-int cfs_trace_max_debug_mb(void)
-{
-	int  total_mb = (totalram_pages >> (20 - PAGE_SHIFT));
-
-	return max(512, (total_mb * 80) / 100);
-}
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 5f31933..72321ce 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -933,7 +933,8 @@ int cfs_trace_set_debug_mb(int mb)
 	int i;
 	int j;
 	int pages;
-	int limit = cfs_trace_max_debug_mb();
+	int total_mb = (totalram_pages >> (20 - PAGE_SHIFT));
+	int limit = max(512, (total_mb * 80) / 100);
 	struct cfs_trace_cpu_data *tcd;
 
 	if (mb < num_possible_cpus()) {
-- 
1.8.3.1
