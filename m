From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:28 -0400
Subject: [lustre-devel] [PATCH 11/18] lustre: osc: max_pages_per_rpc should
 be chunk size aligned
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

max_pages_per_rpc should be chunk size aligned.

obd_brw_size need to be at least one block size.

Improve the LASSERT() to an LASSERTF() that prints the related
parameters to help debug problem.

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8460
Reviewed-on: http://review.whamcloud.com/21825
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c   | 11 ++++++++---
 drivers/staging/lustre/lustre/osc/osc_request.c |  5 +++++
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 8d3f501..15a4817 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -681,15 +681,20 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	descr = &olck->ols_cl.cls_lock->cll_descr;
 	LASSERT(descr->cld_mode >= CLM_WRITE);
 
-	LASSERT(cli->cl_chunkbits >= PAGE_SHIFT);
+	LASSERTF(cli->cl_chunkbits >= PAGE_SHIFT,
+		 "chunkbits: %u\n", cli->cl_chunkbits);
 	ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
 	chunk_mask = ~((1 << ppc_bits) - 1);
 	chunksize = 1 << cli->cl_chunkbits;
 	chunk = index >> ppc_bits;
 
-	/* align end to rpc edge, rpc size may not be a power 2 integer. */
+	/* align end to RPC edge */
 	max_pages = cli->cl_max_pages_per_rpc;
-	LASSERT((max_pages & ~chunk_mask) == 0);
+	if ((max_pages & ~chunk_mask) != 0) {
+		CERROR("max_pages: %#x chunkbits: %u chunk_mask: %#lx\n",
+		       max_pages, cli->cl_chunkbits, chunk_mask);
+		return ERR_PTR(-EINVAL);
+	}
 	max_end = index - (index % max_pages) + max_pages - 1;
 	max_end = min_t(pgoff_t, max_end, descr->cld_end);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0286f25..2d05387 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -931,6 +931,7 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	}
 
 	if (OCD_HAS_FLAG(ocd, GRANT_PARAM)) {
+		int chunk_mask;
 		u64 size;
 
 		/* overhead for each extent insertion */
@@ -938,6 +939,10 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 		/* determine the appropriate chunk size used by osc_extent. */
 		cli->cl_chunkbits = max_t(int, PAGE_SHIFT,
 					  ocd->ocd_grant_blkbits);
+		/* max_pages_per_rpc must be chunk aligned */
+		chunk_mask = ~((1 << (cli->cl_chunkbits - PAGE_SHIFT)) - 1);
+		cli->cl_max_pages_per_rpc = (cli->cl_max_pages_per_rpc +
+					     ~chunk_mask) & chunk_mask;
 		/* determine maximum extent size, in #pages */
 		size = (u64)ocd->ocd_grant_max_blks << ocd->ocd_grant_blkbits;
 		cli->cl_max_extent_pages = size >> PAGE_SHIFT;
-- 
1.8.3.1
