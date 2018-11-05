From: NeilBrown <neilb@suse.com>
Date: Mon, 05 Nov 2018 16:52:53 +1100
Subject: [lustre-devel] drivers/staging updated to 4.20-rc1
Message-ID: <87k1lsyssq.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hi,
 I've just pushed out new lustre/lustre, lustre/lustre-testing, lustre/lustre-wip
 to github.com:neilbrown/linux.git

 lustre is updated to 4.20-rc1 and doesn't compile because of some
 changes.
 The patch below makes it compile and (probably) work.

 I'd appreciate a review, especially of the iov_for_each change.

Thanks,
NeilBrown


Subject: [PATCH] lustre: fixes for 4.20-rc1

Most are trivial.
iov_for_each() is broken upstream and there are no users in mainline,
so it seem to make sense to just open-code it in the one place
we use it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h | 4 ++--
 drivers/staging/lustre/lustre/llite/vvp_io.c        | 5 ++++-
 drivers/staging/lustre/lustre/mdc/mdc_request.c     | 2 +-
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index c882345226e1..7f81fe24c5eb 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -478,7 +478,7 @@ struct kib_rx {					/* receive message */
 	enum ib_wc_status      rx_status;     /* completion status */
 	struct kib_msg		*rx_msg;	/* message buffer (host vaddr) */
 	__u64                  rx_msgaddr;    /* message buffer (I/O addr) */
-	DECLARE_PCI_UNMAP_ADDR(rx_msgunmap);  /* for dma_unmap_single() */
+	DEFINE_DMA_UNMAP_ADDR(rx_msgunmap);  /* for dma_unmap_single() */
 	struct ib_recv_wr      rx_wrq;        /* receive work item... */
 	struct ib_sge          rx_sge;        /* ...and its memory */
 };
@@ -501,7 +501,7 @@ struct kib_tx {					/* transmit message */
 	struct lnet_msg		*tx_lntmsg[2];	/* lnet msgs to finalize on completion */
 	struct kib_msg	      *tx_msg;        /* message buffer (host vaddr) */
 	__u64                 tx_msgaddr;     /* message buffer (I/O addr) */
-	DECLARE_PCI_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
+	DEFINE_DMA_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
 	/** sge for tx_msgaddr */
 	struct ib_sge		tx_msgsge;
 	int                   tx_nwrq;        /* # send work items */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 70d23874b674..524f3f4feec8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -388,7 +388,10 @@ static int vvp_mmap_locks(const struct lu_env *env,
 	if (!mm)
 		return 0;
 
-	iov_for_each(iov, i, *vio->vui_iter) {
+	for (i = *vio->vui_iter;
+	     i.count;
+	     iov_iter_advance(&i, iov.iov_len)) {
+		iov = iov_iter_iovec(&i);
 		addr = (unsigned long)iov.iov_base;
 		count = iov.iov_len;
 		if (count == 0)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 8f8e3d220dc8..2242204f3c9e 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -993,7 +993,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
 	xa_lock_irq(&mapping->i_pages);
 	found = radix_tree_gang_lookup(&mapping->i_pages,
 				       (void **)&page, offset, 1);
-	if (found > 0 && !radix_tree_exceptional_entry(page)) {
+	if (found > 0 && !xa_is_value(page)) {
 		struct lu_dirpage *dp;
 
 		get_page(page);
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181105/0932c5fa/attachment.sig>
