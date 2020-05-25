From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:41 -0400
Subject: [lustre-devel] [PATCH 04/45] lnet: merge lnet_md_alloc into
 lnet_md_build.
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

lnet_md_alloc is only called twice, each time immediately before a
call to lnet_md_build(), and these are the only calls to
lnet_md_build().

So simplify the code by merging lnet_md_alloc into lnet_md_build.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13004
Lustre-commit: c0598f15dd502 ("LU-13004 lnet: merge lnet_md_alloc into lnet_md_build.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37841
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 39 ----------------------
 net/lnet/lnet/lib-md.c        | 75 +++++++++++++++++++++++++++++--------------
 2 files changed, 51 insertions(+), 63 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index d64c9bf..66e01a0 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -215,45 +215,6 @@ static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 
 #define MAX_PORTALS		64
 
-static inline struct lnet_libmd *
-lnet_md_alloc(struct lnet_md *umd)
-{
-	struct lnet_libmd *md;
-	unsigned int size;
-	unsigned int niov;
-
-	if (umd->options & LNET_MD_KIOV) {
-		niov = umd->length;
-		size = offsetof(struct lnet_libmd, md_iov.kiov[niov]);
-	} else {
-		niov = 1;
-		size = offsetof(struct lnet_libmd, md_iov.iov[niov]);
-	}
-
-	if (size <= LNET_SMALL_MD_SIZE) {
-		md = kmem_cache_alloc(lnet_small_mds_cachep,
-				      GFP_NOFS | __GFP_ZERO);
-		if (md) {
-			CDEBUG(D_MALLOC,
-			       "slab-alloced 'md' of size %u@%p.\n",
-			       size, md);
-		} else {
-			CDEBUG(D_MALLOC, "failed to allocate 'md' of size %u\n",
-			       size);
-		}
-	} else {
-		md = kzalloc(size, GFP_NOFS);
-	}
-	if (md) {
-		/* Set here in case of early free */
-		md->md_options = umd->options;
-		md->md_niov = niov;
-		INIT_LIST_HEAD(&md->md_list);
-	}
-
-	return md;
-}
-
 struct lnet_libhandle *lnet_res_lh_lookup(struct lnet_res_container *rec,
 					  u64 cookie);
 void lnet_res_lh_initialize(struct lnet_res_container *rec,
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index d745b91..a9a83c3 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -164,12 +164,42 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	return cpt;
 }
 
-static int
-lnet_md_build(struct lnet_libmd *lmd, struct lnet_md *umd, int unlink)
+static struct lnet_libmd *
+lnet_md_build(struct lnet_md *umd, int unlink)
 {
 	int i;
 	unsigned int niov;
 	int total_length = 0;
+	struct lnet_libmd *lmd;
+	unsigned int size;
+
+	if ((umd->options & LNET_MD_KIOV) != 0) {
+		niov = umd->length;
+		size = offsetof(struct lnet_libmd, md_iov.kiov[niov]);
+	} else {
+		niov = 1;
+		size = offsetof(struct lnet_libmd, md_iov.iov[niov]);
+	}
+
+	if (size <= LNET_SMALL_MD_SIZE) {
+		lmd = kmem_cache_zalloc(lnet_small_mds_cachep, GFP_NOFS);
+		if (lmd) {
+			CDEBUG(D_MALLOC,
+			       "slab-alloced 'md' of size %u@%p.\n",
+			       size, lmd);
+		} else {
+			CDEBUG(D_MALLOC, "failed to allocate 'md' of size %u\n",
+			       size);
+		}
+	} else {
+		lmd = kzalloc(size, GFP_NOFS);
+	}
+
+	if (!lmd)
+		return ERR_PTR(-ENOMEM);
+
+	lmd->md_niov = niov;
+	INIT_LIST_HEAD(&lmd->md_list);
 
 	lmd->md_me = NULL;
 	lmd->md_start = umd->start;
@@ -192,8 +222,10 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 		for (i = 0; i < (int)niov; i++) {
 			/* We take the page pointer on trust */
 			if (lmd->md_iov.kiov[i].bv_offset +
-			    lmd->md_iov.kiov[i].bv_len > PAGE_SIZE)
-				return -EINVAL; /* invalid length */
+			    lmd->md_iov.kiov[i].bv_len > PAGE_SIZE) {
+				lnet_md_free(lmd);
+				return ERR_PTR(-EINVAL); /* invalid length */
+			}
 
 			total_length += lmd->md_iov.kiov[i].bv_len;
 		}
@@ -202,8 +234,10 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 		if ((umd->options & LNET_MD_MAX_SIZE) && /* max size used */
 		    (umd->max_size < 0 ||
-		     umd->max_size > total_length)) /* illegal max_size */
-			return -EINVAL;
+		     umd->max_size > total_length)) { /* illegal max_size */
+			lnet_md_free(lmd);
+			return ERR_PTR(-EINVAL);
+		}
 	} else {   /* contiguous */
 		lmd->md_length = umd->length;
 		niov = 1;
@@ -213,11 +247,13 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 		if ((umd->options & LNET_MD_MAX_SIZE) && /* max size used */
 		    (umd->max_size < 0 ||
-		     umd->max_size > (int)umd->length)) /* illegal max_size */
-			return -EINVAL;
+		     umd->max_size > (int)umd->length)) { /* illegal max_size */
+			lnet_md_free(lmd);
+			return ERR_PTR(-EINVAL);
+		}
 	}
 
-	return 0;
+	return lmd;
 }
 
 /* must be called with resource lock held */
@@ -326,13 +362,9 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 		return -EINVAL;
 	}
 
-	md = lnet_md_alloc(&umd);
-	if (!md)
-		return -ENOMEM;
-
-	rc = lnet_md_build(md, &umd, unlink);
-	if (rc)
-		goto out_free;
+	md = lnet_md_build(&umd, unlink);
+	if (IS_ERR(md))
+		return PTR_ERR(md);
 
 	cpt = me->me_cpt;
 
@@ -363,7 +395,6 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 out_unlock:
 	lnet_res_unlock(cpt);
-out_free:
 	kfree(md);
 	return rc;
 }
@@ -403,13 +434,9 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 		return -EINVAL;
 	}
 
-	md = lnet_md_alloc(&umd);
-	if (!md)
-		return -ENOMEM;
-
-	rc = lnet_md_build(md, &umd, unlink);
-	if (rc)
-		goto out_free;
+	md = lnet_md_build(&umd, unlink);
+	if (IS_ERR(md))
+		return PTR_ERR(md);
 
 	if (md->md_length > LNET_MTU) {
 		CERROR("Invalid length: too big transfer size %u, %d max\n",
-- 
1.8.3.1
