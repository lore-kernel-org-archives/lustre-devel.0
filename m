From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 14/32] lustre: lnet: discard kvec option from
 lnet_libmd.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231020.26912.16806897942018431304.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The 'struct kvec' field in 'struct lnet_libmd' is no
longer set - the memory is always presented as pages.
So remove that option and the union that contained
iov and kiov.

Rename md_iov.kiov to  md_kiov.
Discard all code that made use of md_iov.iov.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    5 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   14 +---
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   79 +++++---------------
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    5 -
 4 files changed, 25 insertions(+), 78 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 60f9c286fe8c..e4a3e747389a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -168,10 +168,7 @@ struct lnet_libmd {
 	struct lnet_eq		*md_eq;
 	unsigned int		 md_niov;	/* # frags */
 	struct lnet_handle_md	 md_bulk_handle;
-	union {
-		struct kvec	iov[LNET_MAX_IOV];
-		struct bio_vec	kiov[LNET_MAX_IOV];
-	} md_iov;
+	struct bio_vec		 md_kiov[LNET_MAX_IOV];
 };
 
 #define LNET_MD_FLAG_ZOMBIE		BIT(0)
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 3579d90df98d..bd9810652d09 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1584,16 +1584,10 @@ kiblnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 
 		ibmsg = tx->tx_msg;
 		rd = &ibmsg->ibm_u.get.ibgm_rd;
-		if (!(lntmsg->msg_md->md_options & LNET_MD_KIOV))
-			rc = kiblnd_setup_rd_iov(ni, tx, rd,
-						 lntmsg->msg_md->md_niov,
-						 lntmsg->msg_md->md_iov.iov,
-						 0, lntmsg->msg_md->md_length);
-		else
-			rc = kiblnd_setup_rd_kiov(ni, tx, rd,
-						  lntmsg->msg_md->md_niov,
-						  lntmsg->msg_md->md_iov.kiov,
-						  0, lntmsg->msg_md->md_length);
+		rc = kiblnd_setup_rd_kiov(ni, tx, rd,
+					  lntmsg->msg_md->md_niov,
+					  lntmsg->msg_md->md_kiov,
+					  0, lntmsg->msg_md->md_length);
 		if (rc) {
 			CERROR("Can't setup GET sink for %s: %d\n",
 			       libcfs_nid2str(target.nid), rc);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 970db903552d..4c6d14aa2139 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -98,6 +98,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 {
 	int cpt = CFS_CPT_ANY;
 	unsigned int niov;
+	struct bio_vec *kiov = md->md_kiov;
 
 	/*
 	 * if the md_options has a bulk handle then we want to look at the
@@ -112,61 +113,19 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 	niov = md->md_niov;
 
-	/*
-	 * There are three cases to handle:
-	 *  1. The MD is using lnet_kiov_t
-	 *  2. The MD is using struct kvec
-	 *  3. Contiguous buffer allocated via vmalloc
-	 *
-	 *  in case 2 we can use virt_to_page() macro to get the page
-	 *  address of the memory kvec describes.
-	 *
-	 *  in case 3 use is_vmalloc_addr() and vmalloc_to_page()
-	 *
-	 * The offset provided can be within the first iov/kiov entry or
-	 * it could go beyond it. In that case we need to make sure to
-	 * look at the page which actually contains the data that will be
-	 * DMAed.
-	 */
-	if ((md->md_options & LNET_MD_KIOV) != 0) {
-		struct bio_vec *kiov = md->md_iov.kiov;
-
-		while (offset >= kiov->bv_len) {
-			offset -= kiov->bv_len;
-			niov--;
-			kiov++;
-			if (niov == 0) {
-				CERROR("offset %d goes beyond kiov\n", offset);
-				goto out;
-			}
-		}
-
-		cpt = cfs_cpt_of_node(lnet_cpt_table(),
-				      page_to_nid(kiov->bv_page));
-	} else {
-		struct kvec *iov = md->md_iov.iov;
-		unsigned long vaddr;
-		struct page *page;
-
-		while (offset >= iov->iov_len) {
-			offset -= iov->iov_len;
-			niov--;
-			iov++;
-			if (niov == 0) {
-				CERROR("offset %d goes beyond iov\n", offset);
-				goto out;
-			}
-		}
-
-		vaddr = ((unsigned long)iov->iov_base) + offset;
-		page = lnet_kvaddr_to_page(vaddr);
-		if (!page) {
-			CERROR("Couldn't resolve vaddr 0x%lx to page\n", vaddr);
+	while (offset >= kiov->bv_len) {
+		offset -= kiov->bv_len;
+		niov--;
+		kiov++;
+		if (niov == 0) {
+			CERROR("offset %d goes beyond kiov\n", offset);
 			goto out;
 		}
-		cpt = cfs_cpt_of_node(lnet_cpt_table(), page_to_nid(page));
 	}
 
+	cpt = cfs_cpt_of_node(lnet_cpt_table(),
+			      page_to_nid(kiov->bv_page));
+
 out:
 	return cpt;
 }
@@ -186,7 +145,7 @@ lnet_md_build(struct lnet_md *umd, int unlink)
 		niov = DIV_ROUND_UP(offset_in_page(umd->start) + umd->length,
 				    PAGE_SIZE);
 
-	size = offsetof(struct lnet_libmd, md_iov.kiov[niov]);
+	size = offsetof(struct lnet_libmd, md_kiov[niov]);
 	lmd = kzalloc(size, GFP_NOFS);
 	if (!lmd)
 		return ERR_PTR(-ENOMEM);
@@ -207,18 +166,18 @@ lnet_md_build(struct lnet_md *umd, int unlink)
 	lmd->md_bulk_handle = umd->bulk_handle;
 
 	if (umd->options & LNET_MD_KIOV) {
-		memcpy(lmd->md_iov.kiov, umd->start,
-		       niov * sizeof(lmd->md_iov.kiov[0]));
+		memcpy(lmd->md_kiov, umd->start,
+		       niov * sizeof(lmd->md_kiov[0]));
 
 		for (i = 0; i < (int)niov; i++) {
 			/* We take the page pointer on trust */
-			if (lmd->md_iov.kiov[i].bv_offset +
-			    lmd->md_iov.kiov[i].bv_len > PAGE_SIZE) {
+			if (lmd->md_kiov[i].bv_offset +
+			    lmd->md_kiov[i].bv_len > PAGE_SIZE) {
 				kfree(lmd);
 				return ERR_PTR(-EINVAL); /* invalid length */
 			}
 
-			total_length += lmd->md_iov.kiov[i].bv_len;
+			total_length += lmd->md_kiov[i].bv_len;
 		}
 
 		lmd->md_length = total_length;
@@ -245,9 +204,9 @@ lnet_md_build(struct lnet_md *umd, int unlink)
 				p = virt_to_page(pa);
 			plen = min_t(int, len, PAGE_SIZE - offset_in_page(pa));
 
-			lmd->md_iov.kiov[i].bv_page = p;
-			lmd->md_iov.kiov[i].bv_offset = offset_in_page(pa);
-			lmd->md_iov.kiov[i].bv_len = plen;
+			lmd->md_kiov[i].bv_page = p;
+			lmd->md_kiov[i].bv_offset = offset_in_page(pa);
+			lmd->md_kiov[i].bv_len = plen;
 			len -= plen;
 			pa += plen;
 			i += 1;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 17f1c4a1029c..2938a56cee02 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -519,10 +519,7 @@ lnet_setpayloadbuffer(struct lnet_msg *msg)
 	LASSERT(!msg->msg_kiov);
 
 	msg->msg_niov = md->md_niov;
-	if (md->md_options & LNET_MD_KIOV)
-		msg->msg_kiov = md->md_iov.kiov;
-	else
-		msg->msg_iov = md->md_iov.iov;
+	msg->msg_kiov = md->md_kiov;
 }
 
 void
