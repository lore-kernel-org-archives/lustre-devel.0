From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 19/32] lustre: socklnd: discard
 kiblnd_setup_rd_iov
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231077.26912.12353786712327541336.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The 'to' passed to lnd_recv is *always* ITER_BVEC, so
we can discard kiblnd_setup_rd_iov().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   79 +-------------------
 1 file changed, 4 insertions(+), 75 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 51eb20ed3326..9f6879046b72 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -664,71 +664,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	return -EINVAL;
 }
 
-static int
-kiblnd_setup_rd_iov(struct lnet_ni *ni, struct kib_tx *tx,
-		    struct kib_rdma_desc *rd, unsigned int niov,
-		    const struct kvec *iov, int offset, int nob)
-{
-	struct kib_net *net = ni->ni_data;
-	struct page *page;
-	struct scatterlist *sg;
-	unsigned long vaddr;
-	int fragnob;
-	int page_offset;
-
-	LASSERT(nob > 0);
-	LASSERT(niov > 0);
-	LASSERT(net);
-
-	while (offset >= iov->iov_len) {
-		offset -= iov->iov_len;
-		niov--;
-		iov++;
-		LASSERT(niov > 0);
-	}
-
-	sg = tx->tx_frags;
-	do {
-		LASSERT(niov > 0);
-
-		vaddr = ((unsigned long)iov->iov_base) + offset;
-		page_offset = vaddr & (PAGE_SIZE - 1);
-		page = lnet_kvaddr_to_page(vaddr);
-		if (!page) {
-			CERROR("Can't find page\n");
-			return -EFAULT;
-		}
-
-		fragnob = min((int)(iov->iov_len - offset), nob);
-		fragnob = min(fragnob, (int)PAGE_SIZE - page_offset);
-
-		if ((fragnob < (int)PAGE_SIZE - page_offset) && (niov > 1)) {
-			CDEBUG(D_NET,
-			       "fragnob %d < available page %d: with remaining %d iovs\n",
-			       fragnob, (int)PAGE_SIZE - page_offset, niov);
-			tx->tx_gaps = true;
-		}
-
-		sg_set_page(sg, page, fragnob, page_offset);
-		sg = sg_next(sg);
-		if (!sg) {
-			CERROR("lacking enough sg entries to map tx\n");
-			return -EFAULT;
-		}
-
-		if (offset + fragnob < iov->iov_len) {
-			offset += fragnob;
-		} else {
-			offset = 0;
-			iov++;
-			niov--;
-		}
-		nob -= fragnob;
-	} while (nob > 0);
-
-	return kiblnd_map_tx(ni, tx, rd, sg - tx->tx_frags);
-}
-
 static int
 kiblnd_setup_rd_kiov(struct lnet_ni *ni, struct kib_tx *tx,
 		     struct kib_rdma_desc *rd, int nkiov,
@@ -1795,16 +1730,10 @@ kiblnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 
 		txmsg = tx->tx_msg;
 		rd = &txmsg->ibm_u.putack.ibpam_rd;
-		if (!(to->type & ITER_BVEC))
-			rc = kiblnd_setup_rd_iov(ni, tx, rd,
-						 to->nr_segs, to->kvec,
-						 to->iov_offset,
-						 iov_iter_count(to));
-		else
-			rc = kiblnd_setup_rd_kiov(ni, tx, rd,
-						  to->nr_segs, to->bvec,
-						  to->iov_offset,
-						  iov_iter_count(to));
+		rc = kiblnd_setup_rd_kiov(ni, tx, rd,
+					  to->nr_segs, to->bvec,
+					  to->iov_offset,
+					  iov_iter_count(to));
 		if (rc) {
 			CERROR("Can't setup PUT sink for %s: %d\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid), rc);
