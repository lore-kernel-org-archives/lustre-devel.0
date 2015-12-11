From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Fri, 11 Dec 2015 18:04:25 -0500
Subject: [lustre-devel] [PATCH v2 6/6] Nuke another unsigned >= 0 assert
In-Reply-To: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
References: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
Message-ID: <1449875065-35182-7-git-send-email-Valdis.Kletnieks@vt.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Clean up another case of the compiler remininding the programmer they
are an idiot:

drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c:308:34: warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]
  LASSERT(page_pools.epp_waitqlen >= 0);

Just lose the assert, and save a page of compiler spew.

Signed-off-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
---
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index cd8a9987f7ac..1f326673f089 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -304,7 +304,6 @@ static unsigned long enc_pools_cleanup(struct page ***pools, int npools)
 static inline void enc_pools_wakeup(void)
 {
 	assert_spin_locked(&page_pools.epp_lock);
-	LASSERT(page_pools.epp_waitqlen >= 0);
 
 	if (unlikely(page_pools.epp_waitqlen)) {
 		LASSERT(waitqueue_active(&page_pools.epp_waitq));
-- 
2.6.3
