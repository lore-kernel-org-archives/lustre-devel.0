From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 12:19:38 +1100
Subject: [lustre-devel] [PATCH 13/14] staging: lustre: replace
 LIBCFS_CPT_ALLOC()
In-Reply-To: <151546052331.9776.7408338350463291753.stgit@noble>
References: <151546052331.9776.7408338350463291753.stgit@noble>
Message-ID: <151546077863.9776.14166250328540990773.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

LIBCFS_APT_ALLOC() calls kvmalloc_node() with GFP_NOFS
which is not permitted.
Mostly, a kmalloc_node(GFP_NOFS) is appropriate, though occasionally
the allocation is large and GFP_KERNEL is acceptable, so
kvmalloc_node() can be used.

This patch introduces 4 alternatives to LIBCFS_CPT_ALLOC():
 kmalloc_cpt()
 kzalloc_cpt()
 kvmalloc_cpt()
 kvzalloc_cpt().

Each takes a size, gfp flags, and cpt number.

Almost every call to LIBCFS_CPT_ALLOC() passes lnet_cpt_table()
as the table.  This patch embeds that choice in the k*alloc_cpt()
macros, and opencode kzalloc_node(..., cfs_cpt_spread_node(..))
in the one case that lnet_cpt_table() isn't used.

When LIBCFS_CPT_ALLOC() is replaced, the matching LIBCFS_FREE()
is also replaced, with with kfree() or kvfree() as appropriate.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |   19 ++++
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   99 +++++++-------------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   15 +--
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |    9 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   11 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   14 +--
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    6 +
 drivers/staging/lustre/lnet/lnet/peer.c            |    8 +-
 drivers/staging/lustre/lnet/lnet/router.c          |    8 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |    9 +-
 10 files changed, 88 insertions(+), 110 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index d230c7f7cced..50a600564fb2 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -126,6 +126,25 @@ do {								    \
 	kvfree(ptr);					  \
 } while (0)
 
+/*
+ * Use #define rather than inline, as lnet_cpt_table() might
+ * not be defined yet
+ */
+#define kmalloc_cpt(size, flags, cpt) \
+	kmalloc_node(size, flags,  cfs_cpt_spread_node(lnet_cpt_table(), cpt))
+
+#define kzalloc_cpt(size, flags, cpt) \
+	kmalloc_node(size, flags | __GFP_ZERO,				\
+		     cfs_cpt_spread_node(lnet_cpt_table(), cpt))
+
+#define kvmalloc_cpt(size, flags, cpt) \
+	kvmalloc_node(size, flags,					\
+		      cfs_cpt_spread_node(lnet_cpt_table(), cpt))
+
+#define kvzalloc_cpt(size, flags, cpt) \
+	kvmalloc_node(size, flags | __GFP_ZERO,				\
+		      cfs_cpt_spread_node(lnet_cpt_table(), cpt))
+
 /******************************************************************************/
 
 void libcfs_debug_dumplog(void);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index bb7b19473e3a..2ebc484385b3 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -325,7 +325,7 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer **peerp,
 	LASSERT(net);
 	LASSERT(nid != LNET_NID_ANY);
 
-	LIBCFS_CPT_ALLOC(peer, lnet_cpt_table(), cpt, sizeof(*peer));
+	peer = kzalloc_cpt(sizeof(*peer), GFP_NOFS, cpt);
 	if (!peer) {
 		CERROR("Cannot allocate peer\n");
 		return -ENOMEM;
@@ -656,15 +656,14 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm
 
 	LASSERT(sched->ibs_nthreads > 0);
 
-	LIBCFS_CPT_ALLOC(init_qp_attr, lnet_cpt_table(), cpt,
-			 sizeof(*init_qp_attr));
+	init_qp_attr = kzalloc_cpt(sizeof(*init_qp_attr), GFP_NOFS, cpt);
 	if (!init_qp_attr) {
 		CERROR("Can't allocate qp_attr for %s\n",
 		       libcfs_nid2str(peer->ibp_nid));
 		goto failed_0;
 	}
 
-	LIBCFS_CPT_ALLOC(conn, lnet_cpt_table(), cpt, sizeof(*conn));
+	conn = kzalloc_cpt(sizeof(*conn), GFP_NOFS, cpt);
 	if (!conn) {
 		CERROR("Can't allocate connection for %s\n",
 		       libcfs_nid2str(peer->ibp_nid));
@@ -687,8 +686,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm
 	INIT_LIST_HEAD(&conn->ibc_active_txs);
 	spin_lock_init(&conn->ibc_lock);
 
-	LIBCFS_CPT_ALLOC(conn->ibc_connvars, lnet_cpt_table(), cpt,
-			 sizeof(*conn->ibc_connvars));
+	conn->ibc_connvars = kzalloc_cpt(sizeof(*conn->ibc_connvars), GFP_NOFS, cpt);
 	if (!conn->ibc_connvars) {
 		CERROR("Can't allocate in-progress connection state\n");
 		goto failed_2;
@@ -722,8 +720,8 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm
 
 	write_unlock_irqrestore(glock, flags);
 
-	LIBCFS_CPT_ALLOC(conn->ibc_rxs, lnet_cpt_table(), cpt,
-			 IBLND_RX_MSGS(conn) * sizeof(struct kib_rx));
+	conn->ibc_rxs = kzalloc_cpt(IBLND_RX_MSGS(conn) * sizeof(struct kib_rx),
+				    GFP_NOFS, cpt);
 	if (!conn->ibc_rxs) {
 		CERROR("Cannot allocate RX buffers\n");
 		goto failed_2;
@@ -877,11 +875,7 @@ void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn)
 	if (conn->ibc_rx_pages)
 		kiblnd_unmap_rx_descs(conn);
 
-	if (conn->ibc_rxs) {
-		LIBCFS_FREE(conn->ibc_rxs,
-			    IBLND_RX_MSGS(conn) * sizeof(struct kib_rx));
-	}
-
+	kfree(conn->ibc_rxs);
 	kfree(conn->ibc_connvars);
 
 	if (conn->ibc_hdev)
@@ -1088,7 +1082,7 @@ static void kiblnd_free_pages(struct kib_pages *p)
 			__free_page(p->ibp_pages[i]);
 	}
 
-	LIBCFS_FREE(p, offsetof(struct kib_pages, ibp_pages[npages]));
+	kfree(p);
 }
 
 int kiblnd_alloc_pages(struct kib_pages **pp, int cpt, int npages)
@@ -1096,14 +1090,13 @@ int kiblnd_alloc_pages(struct kib_pages **pp, int cpt, int npages)
 	struct kib_pages *p;
 	int i;
 
-	LIBCFS_CPT_ALLOC(p, lnet_cpt_table(), cpt,
-			 offsetof(struct kib_pages, ibp_pages[npages]));
+	p = kzalloc_cpt(offsetof(struct kib_pages, ibp_pages[npages]),
+			GFP_NOFS, cpt);
 	if (!p) {
 		CERROR("Can't allocate descriptor for %d pages\n", npages);
 		return -ENOMEM;
 	}
 
-	memset(p, 0, offsetof(struct kib_pages, ibp_pages[npages]));
 	p->ibp_npages = npages;
 
 	for (i = 0; i < npages; i++) {
@@ -1375,8 +1368,7 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_po
 	INIT_LIST_HEAD(&fpo->fast_reg.fpo_pool_list);
 	fpo->fast_reg.fpo_pool_size = 0;
 	for (i = 0; i < fps->fps_pool_size; i++) {
-		LIBCFS_CPT_ALLOC(frd, lnet_cpt_table(), fps->fps_cpt,
-				 sizeof(*frd));
+		frd = kzalloc_cpt(sizeof(*frd), GFP_NOFS, fps->fps_cpt);
 		if (!frd) {
 			CERROR("Failed to allocate a new fast_reg descriptor\n");
 			rc = -ENOMEM;
@@ -1425,7 +1417,7 @@ static int kiblnd_create_fmr_pool(struct kib_fmr_poolset *fps,
 	struct kib_fmr_pool *fpo;
 	int rc;
 
-	LIBCFS_CPT_ALLOC(fpo, lnet_cpt_table(), fps->fps_cpt, sizeof(*fpo));
+	fpo = kzalloc_cpt(sizeof(*fpo), GFP_NOFS, fps->fps_cpt);
 	if (!fpo)
 		return -ENOMEM;
 
@@ -1984,30 +1976,14 @@ static void kiblnd_destroy_tx_pool(struct kib_pool *pool)
 		struct kib_tx *tx = &tpo->tpo_tx_descs[i];
 
 		list_del(&tx->tx_list);
-		if (tx->tx_pages)
-			LIBCFS_FREE(tx->tx_pages,
-				    LNET_MAX_IOV *
-				    sizeof(*tx->tx_pages));
-		if (tx->tx_frags)
-			LIBCFS_FREE(tx->tx_frags,
-				    (1 + IBLND_MAX_RDMA_FRAGS) *
-				     sizeof(*tx->tx_frags));
-		if (tx->tx_wrq)
-			LIBCFS_FREE(tx->tx_wrq,
-				    (1 + IBLND_MAX_RDMA_FRAGS) *
-				    sizeof(*tx->tx_wrq));
-		if (tx->tx_sge)
-			LIBCFS_FREE(tx->tx_sge,
-				    (1 + IBLND_MAX_RDMA_FRAGS) *
-				    sizeof(*tx->tx_sge));
-		if (tx->tx_rd)
-			LIBCFS_FREE(tx->tx_rd,
-				    offsetof(struct kib_rdma_desc,
-					     rd_frags[IBLND_MAX_RDMA_FRAGS]));
-	}
-
-	LIBCFS_FREE(tpo->tpo_tx_descs,
-		    pool->po_size * sizeof(struct kib_tx));
+		kfree(tx->tx_pages);
+		kfree(tx->tx_frags);
+		kfree(tx->tx_wrq);
+		kfree(tx->tx_sge);
+		kfree(tx->tx_rd);
+	}
+
+	kfree(tpo->tpo_tx_descs);
 out:
 	kiblnd_fini_pool(pool);
 	kfree(tpo);
@@ -2028,7 +2004,7 @@ static int kiblnd_create_tx_pool(struct kib_poolset *ps, int size,
 	struct kib_pool *pool;
 	struct kib_tx_pool *tpo;
 
-	LIBCFS_CPT_ALLOC(tpo, lnet_cpt_table(), ps->ps_cpt, sizeof(*tpo));
+	tpo = kzalloc_cpt(sizeof(*tpo), GFP_NOFS, ps->ps_cpt);
 	if (!tpo) {
 		CERROR("Failed to allocate TX pool\n");
 		return -ENOMEM;
@@ -2046,8 +2022,8 @@ static int kiblnd_create_tx_pool(struct kib_poolset *ps, int size,
 		return -ENOMEM;
 	}
 
-	LIBCFS_CPT_ALLOC(tpo->tpo_tx_descs, lnet_cpt_table(), ps->ps_cpt,
-			 size * sizeof(struct kib_tx));
+	tpo->tpo_tx_descs = kzalloc_cpt(size * sizeof(struct kib_tx),
+					GFP_NOFS, ps->ps_cpt);
 	if (!tpo->tpo_tx_descs) {
 		CERROR("Can't allocate %d tx descriptors\n", size);
 		ps->ps_pool_destroy(pool);
@@ -2061,36 +2037,35 @@ static int kiblnd_create_tx_pool(struct kib_poolset *ps, int size,
 
 		tx->tx_pool = tpo;
 		if (ps->ps_net->ibn_fmr_ps) {
-			LIBCFS_CPT_ALLOC(tx->tx_pages,
-					 lnet_cpt_table(), ps->ps_cpt,
-					 LNET_MAX_IOV * sizeof(*tx->tx_pages));
+			tx->tx_pages = kzalloc_cpt(LNET_MAX_IOV * sizeof(*tx->tx_pages),
+						   GFP_NOFS, ps->ps_cpt);
 			if (!tx->tx_pages)
 				break;
 		}
 
-		LIBCFS_CPT_ALLOC(tx->tx_frags, lnet_cpt_table(), ps->ps_cpt,
-				 (1 + IBLND_MAX_RDMA_FRAGS) *
-				 sizeof(*tx->tx_frags));
+		tx->tx_frags = kzalloc_cpt((1 + IBLND_MAX_RDMA_FRAGS) *
+					   sizeof(*tx->tx_frags),
+					   GFP_NOFS, ps->ps_cpt);
 		if (!tx->tx_frags)
 			break;
 
 		sg_init_table(tx->tx_frags, IBLND_MAX_RDMA_FRAGS + 1);
 
-		LIBCFS_CPT_ALLOC(tx->tx_wrq, lnet_cpt_table(), ps->ps_cpt,
-				 (1 + IBLND_MAX_RDMA_FRAGS) *
-				 sizeof(*tx->tx_wrq));
+		tx->tx_wrq = kzalloc_cpt((1 + IBLND_MAX_RDMA_FRAGS) *
+					 sizeof(*tx->tx_wrq),
+					 GFP_NOFS, ps->ps_cpt);
 		if (!tx->tx_wrq)
 			break;
 
-		LIBCFS_CPT_ALLOC(tx->tx_sge, lnet_cpt_table(), ps->ps_cpt,
-				 (1 + IBLND_MAX_RDMA_FRAGS) *
-				 sizeof(*tx->tx_sge));
+		tx->tx_sge = kzalloc_cpt((1 + IBLND_MAX_RDMA_FRAGS) *
+					 sizeof(*tx->tx_sge),
+					 GFP_NOFS, ps->ps_cpt);
 		if (!tx->tx_sge)
 			break;
 
-		LIBCFS_CPT_ALLOC(tx->tx_rd, lnet_cpt_table(), ps->ps_cpt,
-				 offsetof(struct kib_rdma_desc,
-					  rd_frags[IBLND_MAX_RDMA_FRAGS]));
+		tx->tx_rd = kzalloc_cpt(offsetof(struct kib_rdma_desc,
+						 rd_frags[IBLND_MAX_RDMA_FRAGS]),
+					GFP_NOFS, ps->ps_cpt);
 		if (!tx->tx_rd)
 			break;
 	}
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 7dba949a95a7..ff292216290d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -108,7 +108,7 @@ ksocknal_create_peer(struct ksock_peer **peerp, struct lnet_ni *ni,
 	LASSERT(id.pid != LNET_PID_ANY);
 	LASSERT(!in_interrupt());
 
-	LIBCFS_CPT_ALLOC(peer, lnet_cpt_table(), cpt, sizeof(*peer));
+	peer = kzalloc_cpt(sizeof(*peer), GFP_NOFS, cpt);
 	if (!peer)
 		return -ENOMEM;
 
@@ -2257,13 +2257,8 @@ ksocknal_free_buffers(void)
 		struct ksock_sched_info *info;
 		int i;
 
-		cfs_percpt_for_each(info, i, ksocknal_data.ksnd_sched_info) {
-			if (info->ksi_scheds) {
-				LIBCFS_FREE(info->ksi_scheds,
-					    info->ksi_nthreads_max *
-					    sizeof(info->ksi_scheds[0]));
-			}
-		}
+		cfs_percpt_for_each(info, i, ksocknal_data.ksnd_sched_info)
+			kfree(info->ksi_scheds);
 		cfs_percpt_free(ksocknal_data.ksnd_sched_info);
 	}
 
@@ -2452,8 +2447,8 @@ ksocknal_base_startup(void)
 		info->ksi_nthreads_max = nthrs;
 		info->ksi_cpt = i;
 
-		LIBCFS_CPT_ALLOC(info->ksi_scheds, lnet_cpt_table(), i,
-				 info->ksi_nthreads_max * sizeof(*sched));
+		info->ksi_scheds = kzalloc_cpt(info->ksi_nthreads_max * sizeof(*sched),
+					       GFP_NOFS, i);
 		if (!info->ksi_scheds)
 			goto failed;
 
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
index 8e2b4f1db0a1..7faed94994ea 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
@@ -49,10 +49,8 @@ cfs_percpt_free(void *vars)
 
 	arr = container_of(vars, struct cfs_var_array, va_ptrs[0]);
 
-	for (i = 0; i < arr->va_count; i++) {
-		if (arr->va_ptrs[i])
-			LIBCFS_FREE(arr->va_ptrs[i], arr->va_size);
-	}
+	for (i = 0; i < arr->va_count; i++)
+		kfree(arr->va_ptrs[i]);
 
 	kvfree(arr);
 }
@@ -89,7 +87,8 @@ cfs_percpt_alloc(struct cfs_cpt_table *cptab, unsigned int size)
 	arr->va_cptab = cptab;
 
 	for (i = 0; i < count; i++) {
-		LIBCFS_CPT_ALLOC(arr->va_ptrs[i], cptab, i, size);
+		arr->va_ptrs[i] = kzalloc_node(size, GFP_KERNEL,
+					       cfs_cpt_spread_node(cptab, i));
 		if (!arr->va_ptrs[i]) {
 			cfs_percpt_free((void *)&arr->va_ptrs[0]);
 			return NULL;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 6a1fb0397604..2c7abad57104 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -404,11 +404,8 @@ lnet_res_container_cleanup(struct lnet_res_container *rec)
 		       count, lnet_res_type2str(rec->rec_type));
 	}
 
-	if (rec->rec_lh_hash) {
-		LIBCFS_FREE(rec->rec_lh_hash,
-			    LNET_LH_HASH_SIZE * sizeof(rec->rec_lh_hash[0]));
-		rec->rec_lh_hash = NULL;
-	}
+	kfree(rec->rec_lh_hash);
+	rec->rec_lh_hash = NULL;
 
 	rec->rec_type = 0; /* mark it as finalized */
 }
@@ -426,8 +423,8 @@ lnet_res_container_setup(struct lnet_res_container *rec, int cpt, int type)
 	rec->rec_lh_cookie = (cpt << LNET_COOKIE_TYPE_BITS) | type;
 
 	/* Arbitrary choice of hash table size */
-	LIBCFS_CPT_ALLOC(rec->rec_lh_hash, lnet_cpt_table(), cpt,
-			 LNET_LH_HASH_SIZE * sizeof(rec->rec_lh_hash[0]));
+	rec->rec_lh_hash = kvmalloc_cpt(LNET_LH_HASH_SIZE * sizeof(rec->rec_lh_hash[0]),
+					GFP_KERNEL, cpt);
 	if (!rec->rec_lh_hash) {
 		rc = -ENOMEM;
 		goto out;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index ff6c43323fb5..0091273c04b9 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -553,12 +553,8 @@ lnet_msg_container_cleanup(struct lnet_msg_container *container)
 	if (count > 0)
 		CERROR("%d active msg on exit\n", count);
 
-	if (container->msc_finalizers) {
-		LIBCFS_FREE(container->msc_finalizers,
-			    container->msc_nfinalizers *
-			    sizeof(*container->msc_finalizers));
-		container->msc_finalizers = NULL;
-	}
+	kvfree(container->msc_finalizers);
+	container->msc_finalizers = NULL;
 	container->msc_init = 0;
 }
 
@@ -573,9 +569,9 @@ lnet_msg_container_setup(struct lnet_msg_container *container, int cpt)
 	/* number of CPUs */
 	container->msc_nfinalizers = cfs_cpt_weight(lnet_cpt_table(), cpt);
 
-	LIBCFS_CPT_ALLOC(container->msc_finalizers, lnet_cpt_table(), cpt,
-			 container->msc_nfinalizers *
-			 sizeof(*container->msc_finalizers));
+	container->msc_finalizers = kvzalloc_cpt(container->msc_nfinalizers *
+						 sizeof(*container->msc_finalizers),
+						 GFP_KERNEL, cpt);
 
 	if (!container->msc_finalizers) {
 		CERROR("Failed to allocate message finalizers\n");
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 519cfebaaa88..471f2f6c86f4 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -775,7 +775,7 @@ lnet_ptl_cleanup(struct lnet_portal *ptl)
 			}
 		}
 		/* the extra entry is for MEs with ignore bits */
-		LIBCFS_FREE(mhash, sizeof(*mhash) * (LNET_MT_HASH_SIZE + 1));
+		kvfree(mhash);
 	}
 
 	cfs_percpt_free(ptl->ptl_mtables);
@@ -803,8 +803,8 @@ lnet_ptl_setup(struct lnet_portal *ptl, int index)
 	spin_lock_init(&ptl->ptl_lock);
 	cfs_percpt_for_each(mtable, i, ptl->ptl_mtables) {
 		/* the extra entry is for MEs with ignore bits */
-		LIBCFS_CPT_ALLOC(mhash, lnet_cpt_table(), i,
-				 sizeof(*mhash) * (LNET_MT_HASH_SIZE + 1));
+		mhash = kvzalloc_cpt(sizeof(*mhash) * (LNET_MT_HASH_SIZE + 1),
+				     GFP_KERNEL, i);
 		if (!mhash) {
 			CERROR("Failed to create match hash for portal %d\n",
 			       index);
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 19fcbcf0f642..3e157c10fec4 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -56,8 +56,8 @@ lnet_peer_tables_create(void)
 	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
 		INIT_LIST_HEAD(&ptable->pt_deathrow);
 
-		LIBCFS_CPT_ALLOC(hash, lnet_cpt_table(), i,
-				 LNET_PEER_HASH_SIZE * sizeof(*hash));
+		hash = kvmalloc_cpt(LNET_PEER_HASH_SIZE * sizeof(*hash),
+				    GFP_KERNEL, i);
 		if (!hash) {
 			CERROR("Failed to create peer hash table\n");
 			lnet_peer_tables_destroy();
@@ -94,7 +94,7 @@ lnet_peer_tables_destroy(void)
 		for (j = 0; j < LNET_PEER_HASH_SIZE; j++)
 			LASSERT(list_empty(&hash[j]));
 
-		LIBCFS_FREE(hash, LNET_PEER_HASH_SIZE * sizeof(*hash));
+		kvfree(hash);
 	}
 
 	cfs_percpt_free(the_lnet.ln_peer_tables);
@@ -297,7 +297,7 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
 	if (lp)
 		memset(lp, 0, sizeof(*lp));
 	else
-		LIBCFS_CPT_ALLOC(lp, lnet_cpt_table(), cpt2, sizeof(*lp));
+		lp = kzalloc_cpt(sizeof(*lp), GFP_NOFS, cpt2);
 
 	if (!lp) {
 		rc = -ENOMEM;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 476d6d296037..6504761ca598 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1296,12 +1296,10 @@ lnet_router_checker(void *arg)
 void
 lnet_destroy_rtrbuf(struct lnet_rtrbuf *rb, int npages)
 {
-	int sz = offsetof(struct lnet_rtrbuf, rb_kiov[npages]);
-
 	while (--npages >= 0)
 		__free_page(rb->rb_kiov[npages].bv_page);
 
-	LIBCFS_FREE(rb, sz);
+	kfree(rb);
 }
 
 static struct lnet_rtrbuf *
@@ -1313,7 +1311,7 @@ lnet_new_rtrbuf(struct lnet_rtrbufpool *rbp, int cpt)
 	struct lnet_rtrbuf *rb;
 	int i;
 
-	LIBCFS_CPT_ALLOC(rb, lnet_cpt_table(), cpt, sz);
+	rb = kzalloc_cpt(sz, GFP_NOFS, cpt);
 	if (!rb)
 		return NULL;
 
@@ -1327,7 +1325,7 @@ lnet_new_rtrbuf(struct lnet_rtrbufpool *rbp, int cpt)
 			while (--i >= 0)
 				__free_page(rb->rb_kiov[i].bv_page);
 
-			LIBCFS_FREE(rb, sz);
+			kfree(rb);
 			return NULL;
 		}
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 4ebb5a1107be..b6c9ab92c288 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -113,7 +113,7 @@ srpc_free_bulk(struct srpc_bulk *bk)
 		__free_page(pg);
 	}
 
-	LIBCFS_FREE(bk, offsetof(struct srpc_bulk, bk_iovs[bk->bk_niov]));
+	kfree(bk);
 }
 
 struct srpc_bulk *
@@ -125,8 +125,8 @@ srpc_alloc_bulk(int cpt, unsigned int bulk_off, unsigned int bulk_npg,
 
 	LASSERT(bulk_npg > 0 && bulk_npg <= LNET_MAX_IOV);
 
-	LIBCFS_CPT_ALLOC(bk, lnet_cpt_table(), cpt,
-			 offsetof(struct srpc_bulk, bk_iovs[bulk_npg]));
+	bk = kzalloc_cpt(offsetof(struct srpc_bulk, bk_iovs[bulk_npg]),
+			 GFP_KERNEL, cpt);
 	if (!bk) {
 		CERROR("Can't allocate descriptor for %d pages\n", bulk_npg);
 		return NULL;
@@ -294,8 +294,7 @@ srpc_service_init(struct srpc_service *svc)
 		}
 
 		for (j = 0; j < nrpcs; j++) {
-			LIBCFS_CPT_ALLOC(rpc, lnet_cpt_table(),
-					 i, sizeof(*rpc));
+			rpc = kzalloc_cpt(sizeof(*rpc), GFP_NOFS, i);
 			if (!rpc) {
 				srpc_service_fini(svc);
 				return -ENOMEM;
