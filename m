From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:42 -0400
Subject: [lustre-devel] [PATCH 02/18] lnet: o2ib: fix page mapping error
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

IB DMA mapping can merge a physically continues page region into
single one.
It's confused a kiblnd_fmr_pool_map function who expect to see all
fragments mapped.
It's generate a error
 (o2iblnd.c:1926:kiblnd_fmr_pool_map()) Failed to map mr 1/16 elements

By study an IB code, it looks ib_map_mr_sg return code should checked
against of result of ib_dma_map_sg instead of original fragments
count, same data should be used as argument of ib_map_mr_sg function.

Cray-bug-id: LUS-8139
WC-bug-id: https://jira.whamcloud.com/browse/LU-13181
Lustre-commit: 40385cda7afbd ("LU-13181 o2ib: fix page mapping error")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/37388
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    | 7 ++++---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 3 ++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 3a76447..16edfba 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1737,10 +1737,11 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 				}
 
 				n = ib_map_mr_sg(mr, tx->tx_frags,
-						 tx->tx_nfrags, NULL, PAGE_SIZE);
-				if (unlikely(n != tx->tx_nfrags)) {
+						 rd->rd_nfrags, NULL,
+						 PAGE_SIZE);
+				if (unlikely(n != rd->rd_nfrags)) {
 					CERROR("Failed to map mr %d/%d elements\n",
-					       n, tx->tx_nfrags);
+					       n, rd->rd_nfrags);
 					return n < 0 ? n : -EINVAL;
 				}
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 40e196d..3b9d10d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -595,7 +595,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	fps = net->ibn_fmr_ps[cpt];
 	rc = kiblnd_fmr_pool_map(fps, tx, rd, nob, 0, &tx->tx_fmr);
 	if (rc) {
-		CERROR("Can't map %u bytes: %d\n", nob, rc);
+		CERROR("Can't map %u bytes (%u/%u)s: %d\n", nob,
+		       tx->tx_nfrags, rd->rd_nfrags, rc);
 		return rc;
 	}
 
-- 
1.8.3.1
