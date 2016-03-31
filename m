From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Mar 2016 10:18:37 -0400
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: libcfs: remove
	page_index() macro
In-Reply-To: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
References: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459433920-23644-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Just use the index field directly for struct page.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13841
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/linux/linux-mem.h  |    2 --
 drivers/staging/lustre/lustre/llite/vvp_page.c     |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
index c50ef83..12fde3c 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
@@ -57,8 +57,6 @@
 #include "../libcfs_cpu.h"
 #endif
 
-#define page_index(p)       ((p)->index)
-
 #if BITS_PER_LONG == 32
 /* limit to lowmem on 32-bit systems */
 #define NUM_CACHEPAGES \
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 69316c1..0c92293 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -394,7 +394,7 @@ static int vvp_page_print(const struct lu_env *env,
 		(*printer)(env, cookie, "%lx %d:%d %lx %lu %slru",
 			   (long)vmpage->flags, page_count(vmpage),
 			   page_mapcount(vmpage), vmpage->private,
-			   page_index(vmpage),
+			   vmpage->index,
 			   list_empty(&vmpage->lru) ? "not-" : "");
 	}
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 4d3eed6..547539c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1934,7 +1934,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		pga[i] = &oap->oap_brw_page;
 		pga[i]->off = oap->oap_obj_off + oap->oap_page_off;
 		CDEBUG(0, "put page %p index %lu oap %p flg %x to pga\n",
-		       pga[i]->pg, page_index(oap->oap_page), oap,
+		       pga[i]->pg, oap->oap_page->index, oap,
 		       pga[i]->flag);
 		i++;
 		cl_req_page_add(env, clerq, page);
-- 
1.7.1
