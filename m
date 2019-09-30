From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:26 -0400
Subject: [lustre-devel] [PATCH 007/151] lnet: Allocate MEs and small MDs in
 own kmem_caches
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

As part of LU-3848 and LU-4330, it has been discovered that LNET
MEs and small MDs (<=128 Bytes) are allocated in <size-128> kmem_cache
and thus can suffer quite frequent corruptions, from other modules or
Kernel parts, that occur there. To avoid this, MEs and small-MDs
specific kmem_cache have been created.

Also, lnet_libmd struct fields have been re-ordered to optimize its
memory foot-print.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4330
Lustre-commit: 9d9bb678d6b3 ("LU-4330 lnet: Allocate MEs and small MDs in own kmem_caches")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: http://review.whamcloud.com/18586
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  | 39 ++++++++++++++++++++++++++++++++++++++-
 include/linux/lnet/lib-types.h |  2 +-
 net/lnet/lnet/api-ni.c         | 40 ++++++++++++++++++++++++++++++++++++++++
 net/lnet/lnet/lib-md.c         |  2 +-
 net/lnet/lnet/lib-me.c         |  2 +-
 net/lnet/lnet/lib-ptl.c        |  2 +-
 6 files changed, 82 insertions(+), 5 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 776896a..538d457 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -80,6 +80,12 @@
 /* default timeout */
 #define DEFAULT_PEER_TIMEOUT    180
 
+#define LNET_SMALL_MD_SIZE	offsetof(struct lnet_libmd, md_iov.iov[1])
+extern struct kmem_cache *lnet_mes_cachep;	 /* MEs kmem_cache */
+extern struct kmem_cache *lnet_small_mds_cachep; /* <= LNET_SMALL_MD_SIZE bytes
+						  * MDs kmem_cache
+						  */
+
 static inline int lnet_is_route_alive(struct lnet_route *route)
 {
 	/* gateway is down */
@@ -151,6 +157,24 @@ static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 	cfs_percpt_unlock(the_lnet.ln_res_lock, cpt);
 }
 
+static inline void
+lnet_md_free(struct lnet_libmd *md)
+{
+	unsigned int size;
+
+	if ((md->md_options & LNET_MD_KIOV) != 0)
+		size = offsetof(struct lnet_libmd, md_iov.kiov[md->md_niov]);
+	else
+		size = offsetof(struct lnet_libmd, md_iov.iov[md->md_niov]);
+
+	if (size <= LNET_SMALL_MD_SIZE) {
+		CDEBUG(D_MALLOC, "slab-freed 'md' at %p.\n", md);
+		kmem_cache_free(lnet_small_mds_cachep, md);
+	} else {
+		kfree(md);
+	}
+}
+
 static inline int
 lnet_res_lock_current(void)
 {
@@ -205,7 +229,20 @@ static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 		size = offsetof(struct lnet_libmd, md_iov.iov[niov]);
 	}
 
-	md = kzalloc(size, GFP_NOFS);
+	if (size <= LNET_SMALL_MD_SIZE) {
+		md = kmem_cache_alloc(lnet_small_mds_cachep,
+				      GFP_NOFS | __GFP_ZERO);
+		if (md) {
+			CDEBUG(D_MALLOC,
+			       "slab-alloced 'md' of size %u@%p.\n",
+			       size, md);
+		} else {
+			CDEBUG(D_MALLOC, "failed to allocate 'md' of size %u\n",
+			       size);
+		}
+	} else {
+		md = kzalloc(size, GFP_NOFS);
+	}
 	if (md) {
 		/* Set here in case of early free */
 		md->md_options = umd->options;
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 60f9c28..6d2d83a 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -164,9 +164,9 @@ struct lnet_libmd {
 	int			 md_refcount;
 	unsigned int		 md_options;
 	unsigned int		 md_flags;
+	unsigned int		 md_niov;	/* # frags at end of struct */
 	void			*md_user_ptr;
 	struct lnet_eq		*md_eq;
-	unsigned int		 md_niov;	/* # frags */
 	struct lnet_handle_md	 md_bulk_handle;
 	union {
 		struct kvec	iov[LNET_MAX_IOV];
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 12b3c44..c33cd1f 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -216,6 +216,41 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	mutex_init(&the_lnet.ln_lnd_mutex);
 }
 
+struct kmem_cache *lnet_mes_cachep;	   /* MEs kmem_cache */
+struct kmem_cache *lnet_small_mds_cachep;  /* <= LNET_SMALL_MD_SIZE bytes
+					    *  MDs kmem_cache
+					    */
+
+static int
+lnet_descriptor_setup(void)
+{
+	/* create specific kmem_cache for MEs and small MDs (i.e., originally
+	 * allocated in <size-xxx> kmem_cache).
+	 */
+	lnet_mes_cachep = kmem_cache_create("lnet_MEs", sizeof(struct lnet_me),
+					    0, 0, NULL);
+	if (!lnet_mes_cachep)
+		return -ENOMEM;
+
+	lnet_small_mds_cachep = kmem_cache_create("lnet_small_MDs",
+						  LNET_SMALL_MD_SIZE, 0, 0,
+						  NULL);
+	if (!lnet_small_mds_cachep)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void
+lnet_descriptor_cleanup(void)
+{
+	kmem_cache_destroy(lnet_small_mds_cachep);
+	lnet_small_mds_cachep = NULL;
+
+	kmem_cache_destroy(lnet_mes_cachep);
+	lnet_mes_cachep = NULL;
+}
+
 static int
 lnet_create_remote_nets_table(void)
 {
@@ -701,6 +736,10 @@ struct lnet_libhandle *
 	INIT_LIST_HEAD(&the_lnet.ln_dc_expired);
 	init_waitqueue_head(&the_lnet.ln_dc_waitq);
 
+	rc = lnet_descriptor_setup();
+	if (rc != 0)
+		goto failed;
+
 	rc = lnet_create_remote_nets_table();
 	if (rc)
 		goto failed;
@@ -798,6 +837,7 @@ struct lnet_libhandle *
 		the_lnet.ln_counters = NULL;
 	}
 	lnet_destroy_remote_nets_table();
+	lnet_descriptor_cleanup();
 
 	return 0;
 }
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index 33a59fb..8fe3564 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -82,7 +82,7 @@
 
 	LASSERT(!list_empty(&md->md_list));
 	list_del_init(&md->md_list);
-	kfree(md);
+	lnet_md_free(md);
 }
 
 struct page *lnet_kvaddr_to_page(unsigned long vaddr)
diff --git a/net/lnet/lnet/lib-me.c b/net/lnet/lnet/lib-me.c
index f0365ea..4fe6991 100644
--- a/net/lnet/lnet/lib-me.c
+++ b/net/lnet/lnet/lib-me.c
@@ -91,7 +91,7 @@
 	if (!mtable) /* can't match portal type */
 		return -EPERM;
 
-	me = kzalloc(sizeof(*me), GFP_NOFS);
+	me = kmem_cache_alloc(lnet_mes_cachep, GFP_NOFS | __GFP_ZERO);
 	if (!me)
 		return -ENOMEM;
 
diff --git a/net/lnet/lnet/lib-ptl.c b/net/lnet/lnet/lib-ptl.c
index ae061e8..83548f5 100644
--- a/net/lnet/lnet/lib-ptl.c
+++ b/net/lnet/lnet/lib-ptl.c
@@ -773,7 +773,7 @@ struct list_head *
 			       != NULL) {
 				CERROR("Active ME %p on exit\n", me);
 				list_del(&me->me_list);
-				kfree(me);
+				kmem_cache_free(lnet_mes_cachep, me);
 			}
 		}
 		/* the extra entry is for MEs with ignore bits */
-- 
1.8.3.1
