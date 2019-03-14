From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 12/32] lustre: lnet: merge lnet_md_alloc into
 lnet_md_build.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230996.26912.15547976644328023498.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lnet_md_alloc is only called twice, each time immediately before a
call to lnet_md_build, and these are the only calls to
lnet_md_build().

So simplify the code by merging lnet_md_alloc into lnet_md_build.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   26 --------
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   63 ++++++++++++--------
 2 files changed, 38 insertions(+), 51 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 7275d517df5a..fca1c19a3c84 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -189,32 +189,6 @@ lnet_net_lock_current(void)
 
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
-	md = kzalloc(size, GFP_NOFS);
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
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index fdca4655206e..26c560a1e8b9 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -171,12 +171,29 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
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
+	if (umd->options & LNET_MD_KIOV) {
+		niov = umd->length;
+		size = offsetof(struct lnet_libmd, md_iov.kiov[niov]);
+	} else {
+		niov = 1;
+		size = offsetof(struct lnet_libmd, md_iov.iov[niov]);
+	}
+
+	lmd = kzalloc(size, GFP_NOFS);
+	if (!lmd)
+		return ERR_PTR(-ENOMEM);
+
+	lmd->md_niov = niov;
+	INIT_LIST_HEAD(&lmd->md_list);
 
 	lmd->md_me = NULL;
 	lmd->md_start = umd->start;
@@ -199,8 +216,10 @@ lnet_md_build(struct lnet_libmd *lmd, struct lnet_md *umd, int unlink)
 		for (i = 0; i < (int)niov; i++) {
 			/* We take the page pointer on trust */
 			if (lmd->md_iov.kiov[i].bv_offset +
-			    lmd->md_iov.kiov[i].bv_len > PAGE_SIZE)
-				return -EINVAL; /* invalid length */
+			    lmd->md_iov.kiov[i].bv_len > PAGE_SIZE) {
+				kfree(lmd);
+				return ERR_PTR(-EINVAL); /* invalid length */
+			}
 
 			total_length += lmd->md_iov.kiov[i].bv_len;
 		}
@@ -209,8 +228,10 @@ lnet_md_build(struct lnet_libmd *lmd, struct lnet_md *umd, int unlink)
 
 		if ((umd->options & LNET_MD_MAX_SIZE) && /* max size used */
 		    (umd->max_size < 0 ||
-		     umd->max_size > total_length)) /* illegal max_size */
-			return -EINVAL;
+		     umd->max_size > total_length)) { /* illegal max_size */
+			kfree(lmd);
+			return ERR_PTR(-EINVAL);
+		}
 	} else {   /* contiguous */
 		lmd->md_length = umd->length;
 		niov = 1;
@@ -220,11 +241,13 @@ lnet_md_build(struct lnet_libmd *lmd, struct lnet_md *umd, int unlink)
 
 		if ((umd->options & LNET_MD_MAX_SIZE) && /* max size used */
 		    (umd->max_size < 0 ||
-		     umd->max_size > (int)umd->length)) /* illegal max_size */
-			return -EINVAL;
+		     umd->max_size > (int)umd->length)) { /* illegal max_size */
+			kfree(lmd);
+			return ERR_PTR(-EINVAL);
+		}
 	}
 
-	return 0;
+	return lmd;
 }
 
 /* must be called with resource lock held */
@@ -341,13 +364,9 @@ LNetMDAttach(struct lnet_handle_me meh, struct lnet_md umd,
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
 
 	cpt = lnet_cpt_of_cookie(meh.cookie);
 
@@ -381,7 +400,6 @@ LNetMDAttach(struct lnet_handle_me meh, struct lnet_md umd,
 
 out_unlock:
 	lnet_res_unlock(cpt);
-out_free:
 	kfree(md);
 	return rc;
 }
@@ -421,13 +439,9 @@ LNetMDBind(struct lnet_md umd, enum lnet_unlink unlink,
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
 
 	cpt = lnet_res_lock_current();
 
@@ -442,7 +456,6 @@ LNetMDBind(struct lnet_md umd, enum lnet_unlink unlink,
 
 out_unlock:
 	lnet_res_unlock(cpt);
-out_free:
 	kfree(md);
 
 	return rc;
