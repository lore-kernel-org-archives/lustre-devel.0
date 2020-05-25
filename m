From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:45 -0400
Subject: [lustre-devel] [PATCH 08/45] lnet: o2iblnd: discard
 kiblnd_setup_rd_iov
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The 'to' passed to lnd_recv is *always* ITER_BVEC, so
we can discard kiblnd_setup_rd_iov().

WC-bug-id: https://jira.whamcloud.com/browse/LU-13004
Lustre-commit: e35b7751f49fb ("LU-13004 lnet: remove the 'struct kvec' arg from lnd_send")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37845
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h      |  6 +--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 80 ++-----------------------------------
 2 files changed, 5 insertions(+), 81 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 1a71483..f78b372 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -239,11 +239,7 @@ struct lnet_lnd {
 
 	/*
 	 * In data movement APIs below, payload buffers are described as a set
-	 * of 'niov' fragments which are...
-	 * EITHER
-	 *    in virtual memory (struct iovec *iov != NULL)
-	 * OR
-	 *    in pages (kernel only: plt_kiov_t *kiov != NULL).
+	 * of 'niov' fragments which are in pages.
 	 * The LND may NOT overwrite these fragment descriptors.
 	 * An 'offset' and may specify a byte offset within the set of
 	 * fragments to start from
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 18edb1e..f7c802f 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -675,71 +675,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 }
 
 static int
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
-static int
 kiblnd_setup_rd_kiov(struct lnet_ni *ni, struct kib_tx *tx,
 		     struct kib_rdma_desc *rd, int nkiov,
 		     const struct bio_vec *kiov, int offset, int nob)
@@ -1787,7 +1722,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	LASSERT(iov_iter_count(to) <= rlen);
 	LASSERT(!in_interrupt());
-	/* Either all pages or all vaddrs */
 
 	switch (rxmsg->ibm_type) {
 	default:
@@ -1836,16 +1770,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
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
-- 
1.8.3.1
