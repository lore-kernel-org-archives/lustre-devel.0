From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:54 -0500
Subject: [lustre-devel] [PATCH 606/622] lnet: avoid extra memory consumption
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-607-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

use slab allocation for the rsp_tracker and lnet_message
structs to avoid memory fragmnetation.

Cray-bug-id: LUS-8190
WC-bug-id: https://jira.whamcloud.com/browse/LU-13036
Lustre-commit: a3ce59ae2c62 ("LU-13036 lnet: avoid extra memory consumption")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/36897
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 13 ++++++++++---
 net/lnet/lnet/api-ni.c        | 28 ++++++++++++++++++++++++----
 net/lnet/lnet/lib-move.c      | 11 ++++++-----
 3 files changed, 40 insertions(+), 12 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index a8051fe..de0cef0 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -83,13 +83,17 @@
 
 /* default timeout */
 #define DEFAULT_PEER_TIMEOUT    180
+#define LNET_LND_DEFAULT_TIMEOUT 5
+
+bool lnet_is_route_alive(struct lnet_route *route);
 
 #define LNET_SMALL_MD_SIZE	offsetof(struct lnet_libmd, md_iov.iov[1])
 extern struct kmem_cache *lnet_mes_cachep;	 /* MEs kmem_cache */
 extern struct kmem_cache *lnet_small_mds_cachep; /* <= LNET_SMALL_MD_SIZE bytes
 						  * MDs kmem_cache
 						  */
-#define LNET_LND_DEFAULT_TIMEOUT 5
+extern struct kmem_cache *lnet_rspt_cachep;
+extern struct kmem_cache *lnet_msg_cachep;
 
 bool lnet_is_route_alive(struct lnet_route *route);
 bool lnet_is_gateway_alive(struct lnet_peer *gw);
@@ -417,19 +421,22 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 {
 	struct lnet_rsp_tracker *rspt;
 
-	rspt = kzalloc(sizeof(*rspt), GFP_NOFS);
+	rspt = kmem_cache_zalloc(lnet_rspt_cachep, GFP_NOFS);
 	if (rspt) {
 		lnet_net_lock(cpt);
 		the_lnet.ln_counters[cpt]->lct_health.lch_rst_alloc++;
 		lnet_net_unlock(cpt);
 	}
+	CDEBUG(D_MALLOC, "rspt alloc %p\n", rspt);
 	return rspt;
 }
 
 static inline void
 lnet_rspt_free(struct lnet_rsp_tracker *rspt, int cpt)
 {
-	kfree(rspt);
+	CDEBUG(D_MALLOC, "rspt free %p\n", rspt);
+
+	kmem_cache_free(lnet_rspt_cachep, rspt);
 	lnet_net_lock(cpt);
 	the_lnet.ln_counters[cpt]->lct_health.lch_rst_alloc--;
 	lnet_net_unlock(cpt);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 852bb0c..b9c38f3 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -494,9 +494,11 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 struct kmem_cache *lnet_small_mds_cachep;  /* <= LNET_SMALL_MD_SIZE bytes
 					    *  MDs kmem_cache
 					    */
+struct kmem_cache *lnet_rspt_cachep;	   /* response tracker cache */
+struct kmem_cache *lnet_msg_cachep;
 
 static int
-lnet_descriptor_setup(void)
+lnet_slab_setup(void)
 {
 	/* create specific kmem_cache for MEs and small MDs (i.e., originally
 	 * allocated in <size-xxx> kmem_cache).
@@ -512,12 +514,30 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	if (!lnet_small_mds_cachep)
 		return -ENOMEM;
 
+	lnet_rspt_cachep = kmem_cache_create("lnet_rspt",
+					     sizeof(struct lnet_rsp_tracker),
+					     0, 0, NULL);
+	if (!lnet_rspt_cachep)
+		return -ENOMEM;
+
+	lnet_msg_cachep = kmem_cache_create("lnet_msg",
+					    sizeof(struct lnet_msg),
+					    0, 0, NULL);
+	if (!lnet_msg_cachep)
+		return -ENOMEM;
+
 	return 0;
 }
 
 static void
-lnet_descriptor_cleanup(void)
+lnet_slab_cleanup(void)
 {
+	kmem_cache_destroy(lnet_msg_cachep);
+	lnet_msg_cachep = NULL;
+
+	kmem_cache_destroy(lnet_rspt_cachep);
+	lnet_rspt_cachep = NULL;
+
 	kmem_cache_destroy(lnet_small_mds_cachep);
 	lnet_small_mds_cachep = NULL;
 
@@ -1081,7 +1101,7 @@ struct list_head **
 	LNetInvalidateEQHandle(&the_lnet.ln_mt_eqh);
 	init_completion(&the_lnet.ln_started);
 
-	rc = lnet_descriptor_setup();
+	rc = lnet_slab_setup();
 	if (rc != 0)
 		goto failed;
 
@@ -1188,7 +1208,7 @@ struct list_head **
 		the_lnet.ln_counters = NULL;
 	}
 	lnet_destroy_remote_nets_table();
-	lnet_descriptor_cleanup();
+	lnet_slab_cleanup();
 
 	return 0;
 }
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 47d5389..cd36d52 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4186,7 +4186,7 @@ void lnet_monitor_thr_stop(void)
 		}
 	}
 
-	msg = kzalloc(sizeof(*msg), GFP_NOFS);
+	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("%s, src %s: Dropping %s (out of memory)\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
@@ -4194,7 +4194,7 @@ void lnet_monitor_thr_stop(void)
 		goto drop;
 	}
 
-	/* msg zeroed by kzalloc()
+	/* msg zeroed by kmem_cache_zalloc().
 	 * i.e. flags all clear, pointers NULL etc
 	 */
 	msg->msg_type = type;
@@ -4475,7 +4475,7 @@ void lnet_monitor_thr_stop(void)
 		return -EIO;
 	}
 
-	msg = kzalloc(sizeof(*msg), GFP_NOFS);
+	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("Dropping PUT to %s: ENOMEM on struct lnet_msg\n",
 		       libcfs_id2str(target));
@@ -4571,7 +4571,7 @@ struct lnet_msg *
 	 * CAVEAT EMPTOR: 'getmsg' is the original GET, which is freed when
 	 * lnet_finalize() is called on it, so the LND must call this first
 	 */
-	struct lnet_msg *msg = kzalloc(sizeof(*msg), GFP_NOFS);
+	struct lnet_msg *msg;
 	struct lnet_libmd *getmd = getmsg->msg_md;
 	struct lnet_process_id peer_id = getmsg->msg_target;
 	int cpt;
@@ -4579,6 +4579,7 @@ struct lnet_msg *
 	LASSERT(!getmsg->msg_target_is_router);
 	LASSERT(!getmsg->msg_routing);
 
+	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("%s: Dropping REPLY from %s: can't allocate msg\n",
 		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id));
@@ -4708,7 +4709,7 @@ struct lnet_msg *
 		return -EIO;
 	}
 
-	msg = kzalloc(sizeof(*msg), GFP_NOFS);
+	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("Dropping GET to %s: ENOMEM on struct lnet_msg\n",
 		       libcfs_id2str(target));
-- 
1.8.3.1
