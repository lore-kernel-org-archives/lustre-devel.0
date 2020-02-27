From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:08 -0500
Subject: [lustre-devel] [PATCH 560/622] lustre: all: prefer sizeof(*var) for
 alloc
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-561-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The construct
   var = kzalloc(sizeof(*var, GFP...)
is more obviously correct than
   var = kzalloc(sizeof(struct something), GFP...);
and is preferred

So convert allocations and frees that use sizeof(struct..)
to use one of the simpler constructs.

For cfs_percpt_alloc() allocations, we are allocating
a array of pointers. so sizeof(*var[0]) is best.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 11f2c86650fd ("LU-9679 all: prefer sizeof(*var) for ALLOC/FREE")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36661
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c | 2 +-
 fs/lustre/obdecho/echo_client.c     | 2 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c    | 9 +++++----
 net/lnet/libcfs/libcfs_lock.c       | 2 +-
 net/lnet/lnet/api-ni.c              | 7 +++----
 net/lnet/lnet/lib-eq.c              | 2 +-
 net/lnet/lnet/lib-ptl.c             | 2 +-
 net/lnet/lnet/router.c              | 2 +-
 net/lnet/selftest/rpc.c             | 2 +-
 9 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 9772194..4fc35c5 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1137,7 +1137,7 @@ struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 
 	/* alloc num of counter headers */
 	stats->ls_cnt_header = kvmalloc_array(stats->ls_num,
-					      sizeof(struct lprocfs_counter_header),
+					      sizeof(*stats->ls_cnt_header),
 					      GFP_KERNEL | __GFP_ZERO);
 	if (!stats->ls_cnt_header)
 		goto fail;
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index c473f547..84dea56 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1367,7 +1367,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	npages = batch >> PAGE_SHIFT;
 	tot_pages = count >> PAGE_SHIFT;
 
-	lnb = kvmalloc_array(npages, sizeof(struct niobuf_local),
+	lnb = kvmalloc_array(npages, sizeof(*lnb),
 			     GFP_NOFS | __GFP_ZERO);
 	if (!lnb) {
 		ret = -ENOMEM;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 1cc5358..04e121b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -852,7 +852,8 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 
 	kfree(init_qp_attr);
 
-	conn->ibc_rxs = kzalloc_cpt(IBLND_RX_MSGS(conn) * sizeof(struct kib_rx),
+	conn->ibc_rxs = kzalloc_cpt(IBLND_RX_MSGS(conn) *
+				    sizeof(*conn->ibc_rxs),
 				    GFP_NOFS, cpt);
 	if (!conn->ibc_rxs) {
 		CERROR("Cannot allocate RX buffers\n");
@@ -2119,7 +2120,7 @@ static int kiblnd_create_tx_pool(struct kib_poolset *ps, int size,
 		return -ENOMEM;
 	}
 
-	tpo->tpo_tx_descs = kzalloc_cpt(size * sizeof(struct kib_tx),
+	tpo->tpo_tx_descs = kzalloc_cpt(size * sizeof(*tpo->tpo_tx_descs),
 					GFP_NOFS, ps->ps_cpt);
 	if (!tpo->tpo_tx_descs) {
 		CERROR("Can't allocate %d tx descriptors\n", size);
@@ -2251,7 +2252,7 @@ static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
 	 * number of CPTs that exist, i.e net->ibn_fmr_ps[cpt].
 	 */
 	net->ibn_fmr_ps = cfs_percpt_alloc(lnet_cpt_table(),
-					   sizeof(struct kib_fmr_poolset));
+					   sizeof(*net->ibn_fmr_ps[0]));
 	if (!net->ibn_fmr_ps) {
 		CERROR("Failed to allocate FMR pool array\n");
 		rc = -ENOMEM;
@@ -2278,7 +2279,7 @@ static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
 	 * number of CPTs that exist, i.e net->ibn_tx_ps[cpt].
 	 */
 	net->ibn_tx_ps = cfs_percpt_alloc(lnet_cpt_table(),
-					  sizeof(struct kib_tx_poolset));
+					  sizeof(*net->ibn_tx_ps[0]));
 	if (!net->ibn_tx_ps) {
 		CERROR("Failed to allocate tx pool array\n");
 		rc = -ENOMEM;
diff --git a/net/lnet/libcfs/libcfs_lock.c b/net/lnet/libcfs/libcfs_lock.c
index 3d5157f..313aa95 100644
--- a/net/lnet/libcfs/libcfs_lock.c
+++ b/net/lnet/libcfs/libcfs_lock.c
@@ -66,7 +66,7 @@ struct cfs_percpt_lock *
 		return NULL;
 
 	pcl->pcl_cptab = cptab;
-	pcl->pcl_locks = cfs_percpt_alloc(cptab, sizeof(*lock));
+	pcl->pcl_locks = cfs_percpt_alloc(cptab, sizeof(*pcl->pcl_locks[0]));
 	if (!pcl->pcl_locks) {
 		kfree(pcl);
 		return NULL;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 6c913b5..0020ffd 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -970,7 +970,7 @@ static void lnet_assert_wire_constants(void)
 	int rc;
 	int i;
 
-	recs = cfs_percpt_alloc(lnet_cpt_table(), sizeof(*rec));
+	recs = cfs_percpt_alloc(lnet_cpt_table(), sizeof(*recs[0]));
 	if (!recs) {
 		CERROR("Failed to allocate %s resource containers\n",
 		       lnet_res_type2str(type));
@@ -1033,8 +1033,7 @@ struct list_head **
 	struct list_head *q;
 	int i;
 
-	qs = cfs_percpt_alloc(lnet_cpt_table(),
-			      sizeof(struct list_head));
+	qs = cfs_percpt_alloc(lnet_cpt_table(), sizeof(*qs[0]));
 	if (!qs) {
 		CERROR("Failed to allocate queues\n");
 		return NULL;
@@ -1096,7 +1095,7 @@ struct list_head **
 	the_lnet.ln_interface_cookie = ktime_get_real_ns();
 
 	the_lnet.ln_counters = cfs_percpt_alloc(lnet_cpt_table(),
-						sizeof(struct lnet_counters));
+						sizeof(*the_lnet.ln_counters[0]));
 	if (!the_lnet.ln_counters) {
 		CERROR("Failed to allocate counters for LNet\n");
 		rc = -ENOMEM;
diff --git a/net/lnet/lnet/lib-eq.c b/net/lnet/lnet/lib-eq.c
index 01b8ee3..25af2bd 100644
--- a/net/lnet/lnet/lib-eq.c
+++ b/net/lnet/lnet/lib-eq.c
@@ -95,7 +95,7 @@
 		return -ENOMEM;
 
 	if (count) {
-		eq->eq_events = kvmalloc_array(count, sizeof(struct lnet_event),
+		eq->eq_events = kvmalloc_array(count, sizeof(*eq->eq_events),
 					       GFP_KERNEL | __GFP_ZERO);
 		if (!eq->eq_events)
 			goto failed;
diff --git a/net/lnet/lnet/lib-ptl.c b/net/lnet/lnet/lib-ptl.c
index bb92f37..ae38bc3 100644
--- a/net/lnet/lnet/lib-ptl.c
+++ b/net/lnet/lnet/lib-ptl.c
@@ -793,7 +793,7 @@ struct list_head *
 	int j;
 
 	ptl->ptl_mtables = cfs_percpt_alloc(lnet_cpt_table(),
-					    sizeof(struct lnet_match_table));
+					    sizeof(*ptl->ptl_mtables[0]));
 	if (!ptl->ptl_mtables) {
 		CERROR("Failed to create match table for portal %d\n", index);
 		return -ENOMEM;
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 71ba951..b8f7aba0 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1386,7 +1386,7 @@ bool lnet_router_checker_active(void)
 
 	the_lnet.ln_rtrpools = cfs_percpt_alloc(lnet_cpt_table(),
 						LNET_NRBPOOLS *
-						sizeof(struct lnet_rtrbufpool));
+						sizeof(*the_lnet.ln_rtrpools[0]));
 	if (!the_lnet.ln_rtrpools) {
 		LCONSOLE_ERROR_MSG(0x10c,
 				   "Failed to initialize router buffe pool\n");
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index 4645f04..7a8226c 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -256,7 +256,7 @@ struct srpc_bulk *
 	svc->sv_shuttingdown = 0;
 
 	svc->sv_cpt_data = cfs_percpt_alloc(lnet_cpt_table(),
-					    sizeof(**svc->sv_cpt_data));
+					    sizeof(*svc->sv_cpt_data[0]));
 	if (!svc->sv_cpt_data)
 		return -ENOMEM;
 
-- 
1.8.3.1
