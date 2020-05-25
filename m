From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:42 -0400
Subject: [lustre-devel] [PATCH 05/45] lnet: always put a page list into
 struct lnet_libmd
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

'struct lnet_libmd' is only created in lnet_md_build().  It can be
given a list of pages or a virtual address.  In the latter case, the
memory will eventually be split into a list of pages.  It is cleaner
to split it into a list of pages early so that all lower levels only
need to handle one type: a page list.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13004
Lustre-commit: 857f11169fc8 ("LU-13004 lnet: always put a page list into struct lnet_libmd")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37842
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-md.c | 38 +++++++++++++++++++++++++-------------
 1 file changed, 25 insertions(+), 13 deletions(-)

diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index a9a83c3..e1b8a06 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -173,13 +173,12 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	struct lnet_libmd *lmd;
 	unsigned int size;
 
-	if ((umd->options & LNET_MD_KIOV) != 0) {
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
 
 	if (size <= LNET_SMALL_MD_SIZE) {
 		lmd = kmem_cache_zalloc(lnet_small_mds_cachep, GFP_NOFS);
@@ -200,7 +199,6 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 	lmd->md_niov = niov;
 	INIT_LIST_HEAD(&lmd->md_list);
-
 	lmd->md_me = NULL;
 	lmd->md_start = umd->start;
 	lmd->md_offset = 0;
@@ -238,19 +236,33 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 			lnet_md_free(lmd);
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
 
+		lmd->md_length = len;
+		i = 0;
+		while (len) {
+			int plen;
+
+			plen = min_t(int, len, PAGE_SIZE - offset_in_page(pa));
+
+			lmd->md_iov.kiov[i].bv_page =
+				lnet_kvaddr_to_page((unsigned long) pa);
+			lmd->md_iov.kiov[i].bv_offset = offset_in_page(pa);
+			lmd->md_iov.kiov[i].bv_len = plen;
+
+			len -= plen;
+			pa += plen;
+			i += 1;
+		}
 		if ((umd->options & LNET_MD_MAX_SIZE) && /* max size used */
 		    (umd->max_size < 0 ||
 		     umd->max_size > (int)umd->length)) { /* illegal max_size */
 			lnet_md_free(lmd);
 			return ERR_PTR(-EINVAL);
 		}
+		lmd->md_options |= LNET_MD_KIOV;
 	}
 
 	return lmd;
-- 
1.8.3.1
