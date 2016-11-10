From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:55 -0500
Subject: [lustre-devel] [PATCH 25/35] staging: lustre: osc: Do not merge
	extents with partial pages
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

After range lock is introduced to Lustre, it's possible for
multiple threads to submit osc_extents with partial pages, and
finally I/O engine may try to merge these extents, which will
end up with assert in osc_build_rpc().

In this patch, osc_extent::oe_no_merge is introduced, and this flag
is set if osc_extent submitted via osc_io_submit() includes partial
pages. This flag is used by I/O engine to stop merging this kind
of extents.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6666
Reviewed-on: http://review.whamcloud.com/15468
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   11 +++++++++--
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    4 ++++
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 0ca01b1..b0f030c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1918,7 +1918,8 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 		}
 
 		if (tmp->oe_srvlock != ext->oe_srvlock ||
-		    !tmp->oe_grants != !ext->oe_grants)
+		    !tmp->oe_grants != !ext->oe_grants ||
+		    tmp->oe_no_merge || ext->oe_no_merge)
 			return 0;
 
 		/* remove break for strict check */
@@ -2649,11 +2650,13 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 	struct osc_async_page *oap, *tmp;
 	int page_count = 0;
 	int mppr = cli->cl_max_pages_per_rpc;
+	bool can_merge = true;
 	pgoff_t start = CL_PAGE_EOF;
 	pgoff_t end = 0;
 
 	list_for_each_entry(oap, list, oap_pending_item) {
-		pgoff_t index = osc_index(oap2osc(oap));
+		struct osc_page *opg = oap2osc_page(oap);
+		pgoff_t index = osc_index(opg);
 
 		if (index > end)
 			end = index;
@@ -2661,6 +2664,9 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 			start = index;
 		++page_count;
 		mppr <<= (page_count > mppr);
+
+		if (unlikely(opg->ops_from > 0 || opg->ops_to < PAGE_SIZE))
+			can_merge = false;
 	}
 
 	ext = osc_extent_alloc(obj);
@@ -2674,6 +2680,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 
 	ext->oe_rw = !!(cmd & OBD_BRW_READ);
 	ext->oe_sync = 1;
+	ext->oe_no_merge = !can_merge;
 	ext->oe_urgent = 1;
 	ext->oe_start = start;
 	ext->oe_end = end;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index e525110..e4a214d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -596,6 +596,10 @@ struct osc_extent {
 			   oe_rw:1,
 	/** sync extent, queued by osc_queue_sync_pages() */
 				oe_sync:1,
+	/** set if this extent has partial, sync pages.
+	 * Extents with partial page(s) can't merge with others in RPC
+	 */
+				oe_no_merge:1,
 			   oe_srvlock:1,
 			   oe_memalloc:1,
 	/** an ACTIVE extent is going to be truncated, so when this extent
-- 
1.7.1
