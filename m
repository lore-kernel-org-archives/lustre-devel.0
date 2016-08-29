From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 29 Aug 2016 14:20:00 +0200
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: fix unstable pages
	tracking
Message-ID: <20160829122023.3018966-1-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Lai Siyao <lai.siyao@intel.com>, Bobi Jam <bobijam.xu@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

A patch to change to page accounting code (in v4.8-rc1) conflicts with
a change to lustre (in staging-next for v4.9), and fortunately gets
detected using a gcc warning:

In file included from /git/arm-soc/include/linux/mm.h:1001:0,
                 from /git/arm-soc/include/linux/highmem.h:7,
                 from /git/arm-soc/drivers/staging/lustre/lustre/osc/../../include/linux/libcfs/linux/libcfs.h:46,
                 from /git/arm-soc/drivers/staging/lustre/lustre/osc/../../include/linux/libcfs/libcfs.h:36,
                 from /git/arm-soc/drivers/staging/lustre/lustre/osc/osc_cl_internal.h:45,
                 from /git/arm-soc/drivers/staging/lustre/lustre/osc/osc_page.c:40:
drivers/staging/lustre/lustre/osc/osc_page.c: In function 'unstable_page_accounting':
include/linux/vmstat.h:117:2: error: array subscript is above array bounds [-Werror=array-bounds]
  atomic_long_add(x, &vm_zone_stat[item]);
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
include/linux/vmstat.h:117:2: error: array subscript is above array bounds [-Werror=array-bounds]
  atomic_long_add(x, &vm_zone_stat[item]);
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This changes the function to use the correct interface for accounting in the
"node" rather than the "zone".

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: d806f30e639b ("staging: lustre: osc: revise unstable pages accounting")
Fixes: 11fb998986a7 ("mm: move most file-based accounting to the node")
---
 drivers/staging/lustre/lustre/osc/osc_page.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 583a0af2d388..c8889eabc402 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -789,7 +789,7 @@ out:
 
 /**
  * Atomic operations are expensive. We accumulate the accounting for the
- * same page zone to get better performance.
+ * same page pgdat to get better performance.
  * In practice this can work pretty good because the pages in the same RPC
  * are likely from the same page zone.
  */
@@ -797,28 +797,28 @@ static inline void unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
 					    int factor)
 {
 	int page_count = desc->bd_iov_count;
-	void *zone = NULL;
+	pg_data_t *last = NULL;
 	int count = 0;
 	int i;
 
 	for (i = 0; i < page_count; i++) {
-		void *pz = page_zone(desc->bd_iov[i].bv_page);
+		pg_data_t *pgdat = page_pgdat(desc->bd_iov[i].bv_page);
 
-		if (likely(pz == zone)) {
+		if (likely(pgdat == last)) {
 			++count;
 			continue;
 		}
 
 		if (count > 0) {
-			mod_zone_page_state(zone, NR_UNSTABLE_NFS,
+			mod_node_page_state(pgdat, NR_UNSTABLE_NFS,
 					    factor * count);
 			count = 0;
 		}
-		zone = pz;
+		last = pgdat;
 		++count;
 	}
 	if (count > 0)
-		mod_zone_page_state(zone, NR_UNSTABLE_NFS, factor * count);
+		mod_node_page_state(last, NR_UNSTABLE_NFS, factor * count);
 }
 
 static inline void add_unstable_page_accounting(struct ptlrpc_bulk_desc *desc)
-- 
2.9.0
