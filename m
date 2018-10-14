From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:51 -0400
Subject: [lustre-devel] [PATCH 01/28] lustre: osc: osc_extent_tree_dump0()
 implementation is suboptimal
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andrew Perepechko <c17827@cray.com>

Avoid looping in osc_extent_tree_dump() if debugging is disabled.
This helps us save some cpu ticks.

Signed-off-by: Andrew Perepechko <c17827@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9716
Seagate-bug-id: MRP-4469
Reviewed-on: https://review.whamcloud.com/27866
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 326f663..92d292d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1283,6 +1283,9 @@ static void osc_extent_tree_dump0(int level, struct osc_object *obj,
 	struct osc_extent *ext;
 	int cnt;
 
+	if (!cfs_cdebug_show(level, DEBUG_SUBSYSTEM))
+		return;
+
 	CDEBUG(level, "Dump object %p extents at %s:%d, mppr: %u.\n",
 	       obj, func, line, osc_cli(obj)->cl_max_pages_per_rpc);
 
-- 
1.8.3.1
