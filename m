From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 13/32] lustre: lnet: always put a page list
 into struct lnet_libmd.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231013.26912.8330785791899165016.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

'struct lnet_libmd' is only created in lnet_md_build().
It can be given a list of pages or a virtual address.
In the latter case, the memory will eventually be
split into a list of pages.
It is cleaner to split it into a list of pages early
so that all lower levels only need to handle one type: a page list.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/lib-md.c |   43 ++++++++++++++++++++---------
 1 file changed, 29 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 26c560a1e8b9..970db903552d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -180,14 +180,13 @@ lnet_md_build(struct lnet_md *umd, int unlink)
 	struct lnet_libmd *lmd;
 	unsigned int size;
 
-	if (umd->options & LNET_MD_KIOV) {
+	if (umd->options & LNET_MD_KIOV)
 		niov = umd->length;
-		size = offsetof(struct lnet_libmd, md_iov.kiov[niov]);
-	} else {
-		niov = 1;
-		size = offsetof(struct lnet_libmd, md_iov.iov[niov]);
-	}
+	else
+		niov = DIV_ROUND_UP(offset_in_page(umd->start) + umd->length,
+				    PAGE_SIZE);
 
+	size = offsetof(struct lnet_libmd, md_iov.kiov[niov]);
 	lmd = kzalloc(size, GFP_NOFS);
 	if (!lmd)
 		return ERR_PTR(-ENOMEM);
@@ -208,8 +207,6 @@ lnet_md_build(struct lnet_md *umd, int unlink)
 	lmd->md_bulk_handle = umd->bulk_handle;
 
 	if (umd->options & LNET_MD_KIOV) {
-		niov = umd->length;
-		lmd->md_niov = umd->length;
 		memcpy(lmd->md_iov.kiov, umd->start,
 		       niov * sizeof(lmd->md_iov.kiov[0]));
 
@@ -232,12 +229,29 @@ lnet_md_build(struct lnet_md *umd, int unlink)
 			kfree(lmd);
 			return ERR_PTR(-EINVAL);
 		}
-	} else {   /* contiguous */
-		lmd->md_length = umd->length;
-		niov = 1;
-		lmd->md_niov = 1;
-		lmd->md_iov.iov[0].iov_base = umd->start;
-		lmd->md_iov.iov[0].iov_len = umd->length;
+	} else {   /* contiguous - split into pages */
+		void *pa = umd->start;
+		int len = umd->length;
+
+		lmd->md_length = len;
+		i = 0;
+		while (len) {
+			struct page *p;
+			int plen;
+
+			if (is_vmalloc_addr(pa))
+				p = vmalloc_to_page(pa);
+			else
+				p = virt_to_page(pa);
+			plen = min_t(int, len, PAGE_SIZE - offset_in_page(pa));
+
+			lmd->md_iov.kiov[i].bv_page = p;
+			lmd->md_iov.kiov[i].bv_offset = offset_in_page(pa);
+			lmd->md_iov.kiov[i].bv_len = plen;
+			len -= plen;
+			pa += plen;
+			i += 1;
+		}
 
 		if ((umd->options & LNET_MD_MAX_SIZE) && /* max size used */
 		    (umd->max_size < 0 ||
@@ -245,6 +259,7 @@ lnet_md_build(struct lnet_md *umd, int unlink)
 			kfree(lmd);
 			return ERR_PTR(-EINVAL);
 		}
+		lmd->md_options |= LNET_MD_KIOV;
 	}
 
 	return lmd;
