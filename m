From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:43 -0400
Subject: [lustre-devel] [PATCH 06/45] lnet: discard kvec option from
 lnet_libmd.
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The 'struct kvec' field in 'struct lnet_libmd' is no longer set - the
memory is always presented as pages.  So remove that option and the
union that contained iov and kiov.

Rename md_iov.kiov to md_kiov.
Discard all code that made use of md_iov.iov.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13004
Lustre-commit: 4775d52439f4f ("LU-13004 lnet: discard kvec option from lnet_libmd.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37843
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  7 +---
 include/linux/lnet/lib-types.h      |  5 +--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 14 ++-----
 net/lnet/lnet/lib-md.c              | 79 +++++++++----------------------------
 net/lnet/lnet/lib-move.c            |  5 +--
 5 files changed, 27 insertions(+), 83 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 66e01a0..03ac3f9 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -89,7 +89,7 @@
 
 bool lnet_is_route_alive(struct lnet_route *route);
 
-#define LNET_SMALL_MD_SIZE	offsetof(struct lnet_libmd, md_iov.iov[1])
+#define LNET_SMALL_MD_SIZE	offsetof(struct lnet_libmd, md_kiov[1])
 extern struct kmem_cache *lnet_mes_cachep;	 /* MEs kmem_cache */
 extern struct kmem_cache *lnet_small_mds_cachep; /* <= LNET_SMALL_MD_SIZE bytes
 						  * MDs kmem_cache
@@ -165,10 +165,7 @@ static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 
 	LASSERTF(md->md_rspt_ptr == NULL, "md %p rsp %p\n", md, md->md_rspt_ptr);
 
-	if ((md->md_options & LNET_MD_KIOV) != 0)
-		size = offsetof(struct lnet_libmd, md_iov.kiov[md->md_niov]);
-	else
-		size = offsetof(struct lnet_libmd, md_iov.iov[md->md_niov]);
+	size = offsetof(struct lnet_libmd, md_kiov[md->md_niov]);
 
 	if (size <= LNET_SMALL_MD_SIZE) {
 		CDEBUG(D_MALLOC, "slab-freed 'md'@%p.\n", md);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 0629f20..9a11aa5 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -208,10 +208,7 @@ struct lnet_libmd {
 	struct lnet_rsp_tracker	*md_rspt_ptr;
 	lnet_handler_t		 md_handler;
 	struct lnet_handle_md	 md_bulk_handle;
-	union {
-		struct kvec	iov[LNET_MAX_IOV];
-		struct bio_vec	kiov[LNET_MAX_IOV];
-	} md_iov;
+	struct bio_vec		 md_kiov[LNET_MAX_IOV];
 };
 
 #define LNET_MD_FLAG_ZOMBIE		BIT(0)
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 087657c..7f782fb 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1626,16 +1626,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
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
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index e1b8a06..cfa285a 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -91,6 +91,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 {
 	int cpt = CFS_CPT_ANY;
 	unsigned int niov;
+	struct bio_vec *kiov;
 
 	/*
 	 * if the md_options has a bulk handle then we want to look at the
@@ -103,63 +104,21 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	if (!md || md->md_niov == 0)
 		return CFS_CPT_ANY;
 
+	kiov = md->md_kiov;
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
+			CERROR("offset %d goes beyond iov\n", offset);
 			goto out;
 		}
-		cpt = cfs_cpt_of_node(lnet_cpt_table(), page_to_nid(page));
 	}
 
+	cpt = cfs_cpt_of_node(lnet_cpt_table(),
+			      page_to_nid(kiov->bv_page));
 out:
 	return cpt;
 }
@@ -178,7 +137,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	else
 		niov = DIV_ROUND_UP(offset_in_page(umd->start) + umd->length,
 				    PAGE_SIZE);
-	size = offsetof(struct lnet_libmd, md_iov.kiov[niov]);
+	size = offsetof(struct lnet_libmd, md_kiov[niov]);
 
 	if (size <= LNET_SMALL_MD_SIZE) {
 		lmd = kmem_cache_zalloc(lnet_small_mds_cachep, GFP_NOFS);
@@ -214,18 +173,18 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	if (umd->options & LNET_MD_KIOV) {
 		niov = umd->length;
 		lmd->md_niov = umd->length;
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
 				lnet_md_free(lmd);
 				return ERR_PTR(-EINVAL); /* invalid length */
 			}
 
-			total_length += lmd->md_iov.kiov[i].bv_len;
+			total_length += lmd->md_kiov[i].bv_len;
 		}
 
 		lmd->md_length = total_length;
@@ -247,10 +206,10 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 			plen = min_t(int, len, PAGE_SIZE - offset_in_page(pa));
 
-			lmd->md_iov.kiov[i].bv_page =
+			lmd->md_kiov[i].bv_page =
 				lnet_kvaddr_to_page((unsigned long) pa);
-			lmd->md_iov.kiov[i].bv_offset = offset_in_page(pa);
-			lmd->md_iov.kiov[i].bv_len = plen;
+			lmd->md_kiov[i].bv_offset = offset_in_page(pa);
+			lmd->md_kiov[i].bv_len = plen;
 
 			len -= plen;
 			pa += plen;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 9f815c1..dc49e60 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -538,10 +538,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	LASSERT(!msg->msg_kiov);
 
 	msg->msg_niov = md->md_niov;
-	if (md->md_options & LNET_MD_KIOV)
-		msg->msg_kiov = md->md_iov.kiov;
-	else
-		msg->msg_iov = md->md_iov.iov;
+	msg->msg_kiov = md->md_kiov;
 }
 
 void
-- 
1.8.3.1
