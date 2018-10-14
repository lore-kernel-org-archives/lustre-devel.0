From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:04 -0400
Subject: [lustre-devel] [PATCH 14/28] lustre: ptlrpc: handle case of
 epp_free_pages <= PTLRPC_MAX_BRW_PAGES
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bob Glossman <bob.glossman@intel.com>

Current code where page_pools.epp_free_pages is too small isn't
handled correctly. This mod fixes those instances.

Signed-off-by: Bob Glossman <bob.glossman@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9458
Reviewed-on: https://review.whamcloud.com/27016
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 3d336d9..03bc95f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -232,7 +232,8 @@ static unsigned long enc_pools_shrink_count(struct shrinker *s,
 	}
 
 	LASSERT(page_pools.epp_idle_idx <= IDLE_IDX_MAX);
-	return max(page_pools.epp_free_pages - PTLRPC_MAX_BRW_PAGES, 0UL) *
+	return (page_pools.epp_free_pages <= PTLRPC_MAX_BRW_PAGES) ? 0 :
+		(page_pools.epp_free_pages - PTLRPC_MAX_BRW_PAGES) *
 		(IDLE_IDX_MAX - page_pools.epp_idle_idx) / IDLE_IDX_MAX;
 }
 
@@ -243,8 +244,12 @@ static unsigned long enc_pools_shrink_scan(struct shrinker *s,
 					   struct shrink_control *sc)
 {
 	spin_lock(&page_pools.epp_lock);
-	sc->nr_to_scan = min_t(unsigned long, sc->nr_to_scan,
-			      page_pools.epp_free_pages - PTLRPC_MAX_BRW_PAGES);
+	if (page_pools.epp_free_pages > PTLRPC_MAX_BRW_PAGES)
+		sc->nr_to_scan = min_t(unsigned long, sc->nr_to_scan,
+				       page_pools.epp_free_pages -
+				       PTLRPC_MAX_BRW_PAGES);
+	else
+		sc->nr_to_scan = 0;
 	if (sc->nr_to_scan > 0) {
 		enc_pools_release_free_pages(sc->nr_to_scan);
 		CDEBUG(D_SEC, "released %ld pages, %ld left\n",
-- 
1.8.3.1
