From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:41 +1000
Subject: [lustre-devel] [PATCH 16/22] lustre: tracefile: convert
 list_for_each_entry_safe() to while(!list_empty())
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186126.13840.13964285941561581566.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These loops are removing all elements from a list.
So using while(!list_empty()) makes the intent clearer.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 07242d4ed41b..a4768e930021 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -896,11 +896,12 @@ void cfs_trace_flush_pages(void)
 {
 	struct page_collection pc;
 	struct cfs_trace_page *tage;
-	struct cfs_trace_page *tmp;
 
 	pc.pc_want_daemon_pages = 1;
 	collect_pages(&pc);
-	list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
+	while (!list_empty(&pc.pc_pages)) {
+		tage = list_first_entry(&pc.pc_pages,
+					struct cfs_trace_page, linkage);
 		__LASSERT_TAGE_INVARIANT(tage);
 
 		list_del(&tage->linkage);
@@ -1331,7 +1332,6 @@ static void trace_cleanup_on_all_cpus(void)
 {
 	struct cfs_trace_cpu_data *tcd;
 	struct cfs_trace_page *tage;
-	struct cfs_trace_page *tmp;
 	int i, cpu;
 
 	for_each_possible_cpu(cpu) {
@@ -1341,8 +1341,10 @@ static void trace_cleanup_on_all_cpus(void)
 				continue;
 			tcd->tcd_shutting_down = 1;
 
-			list_for_each_entry_safe(tage, tmp, &tcd->tcd_pages,
-						 linkage) {
+			while (!list_empty(&tcd->tcd_pages)) {
+				tage = list_first_entry(&tcd->tcd_pages,
+							struct cfs_trace_page,
+							linkage);
 				__LASSERT_TAGE_INVARIANT(tage);
 
 				list_del(&tage->linkage);
