From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:32 +1100
Subject: [lustre-devel] [PATCH 05/21] lustre: use list_first_entry() in
 lustre subdirectory.
In-Reply-To: <154949776249.10620.1215070753973826063.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
Message-ID: <154949781279.10620.5804477141390456723.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Convert
  list_entry(foo->next .....)
to
  list_first_entry(foo, ....)

in 'lustre'

In several cases the call is combined with
a list_empty() test and list_first_entry_or_null() is used

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    2 -
 drivers/staging/lustre/lustre/llite/statahead.c    |   23 ++++----
 drivers/staging/lustre/lustre/lov/lov_io.c         |    9 +--
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    9 +--
 drivers/staging/lustre/lustre/obdclass/genops.c    |   22 ++++---
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |    5 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   17 +++---
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    5 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |   17 +++---
 drivers/staging/lustre/lustre/osc/osc_request.c    |    8 +--
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    8 +--
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    6 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    4 +
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    6 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   59 ++++++++++----------
 15 files changed, 101 insertions(+), 99 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 13d79810dd39..53fd8d469e55 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2335,7 +2335,7 @@ static inline struct cl_page *cl_page_list_last(struct cl_page_list *plist)
 static inline struct cl_page *cl_page_list_first(struct cl_page_list *plist)
 {
 	LASSERT(plist->pl_nr > 0);
-	return list_entry(plist->pl_pages.next, struct cl_page, cp_batch);
+	return list_first_entry(&plist->pl_pages, struct cl_page, cp_batch);
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 0c305ba2b178..de7586d11d14 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -643,8 +643,8 @@ static void sa_handle_callback(struct ll_statahead_info *sai)
 			spin_unlock(&lli->lli_sa_lock);
 			break;
 		}
-		entry = list_entry(sai->sai_interim_entries.next,
-				   struct sa_entry, se_list);
+		entry = list_first_entry(&sai->sai_interim_entries,
+					 struct sa_entry, se_list);
 		list_del_init(&entry->se_list);
 		spin_unlock(&lli->lli_sa_lock);
 
@@ -893,9 +893,10 @@ static int ll_agl_thread(void *arg)
 		/* The statahead thread maybe help to process AGL entries,
 		 * so check whether list empty again.
 		 */
-		if (!list_empty(&sai->sai_agls)) {
-			clli = list_entry(sai->sai_agls.next,
-					  struct ll_inode_info, lli_agl_list);
+		clli = list_first_entry_or_null(&sai->sai_agls,
+						struct ll_inode_info,
+						lli_agl_list);
+		if (clli) {
 			list_del_init(&clli->lli_agl_list);
 			spin_unlock(&plli->lli_agl_lock);
 			ll_agl_trigger(&clli->lli_vfs_inode, sai);
@@ -912,9 +913,9 @@ static int ll_agl_thread(void *arg)
 
 	spin_lock(&plli->lli_agl_lock);
 	sai->sai_agl_valid = 0;
-	while (!list_empty(&sai->sai_agls)) {
-		clli = list_entry(sai->sai_agls.next,
-				  struct ll_inode_info, lli_agl_list);
+	while ((clli = list_first_entry_or_null(&sai->sai_agls,
+						struct ll_inode_info,
+						lli_agl_list)) != NULL) {
 		list_del_init(&clli->lli_agl_list);
 		spin_unlock(&plli->lli_agl_lock);
 		clli->lli_agl_index = 0;
@@ -1055,9 +1056,9 @@ static int ll_statahead_thread(void *arg)
 				       !agl_list_empty(sai)) {
 					struct ll_inode_info *clli;
 
-					clli = list_entry(sai->sai_agls.next,
-							  struct ll_inode_info,
-							  lli_agl_list);
+					clli = list_first_entry(&sai->sai_agls,
+								struct ll_inode_info,
+								lli_agl_list);
 					list_del_init(&clli->lli_agl_list);
 					spin_unlock(&lli->lli_agl_lock);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index de43f47d455e..77efb86d8683 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -270,14 +270,13 @@ static void lov_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_object *lov = cl2lov(ios->cis_obj);
+	struct lov_io_sub *sub;
 
 	LASSERT(list_empty(&lio->lis_active));
 
-	while (!list_empty(&lio->lis_subios)) {
-		struct lov_io_sub *sub = list_entry(lio->lis_subios.next,
-						    struct lov_io_sub,
-						    sub_list);
-
+	while ((sub = list_first_entry_or_null(&lio->lis_subios,
+					       struct lov_io_sub,
+					       sub_list)) != NULL) {
 		list_del_init(&sub->sub_list);
 		lio->lis_nr_subios--;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index d025ea55818f..057318deaa4e 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -96,16 +96,15 @@ cl_page_at_trusted(const struct cl_page *page,
 static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 {
 	struct cl_object *obj = page->cp_obj;
+	struct cl_page_slice *slice;
 
 	PASSERT(env, page, list_empty(&page->cp_batch));
 	PASSERT(env, page, !page->cp_owner);
 	PASSERT(env, page, page->cp_state == CPS_FREEING);
 
-	while (!list_empty(&page->cp_layers)) {
-		struct cl_page_slice *slice;
-
-		slice = list_entry(page->cp_layers.next,
-				   struct cl_page_slice, cpl_linkage);
+	while ((slice = list_first_entry_or_null(&page->cp_layers,
+						 struct cl_page_slice,
+						 cpl_linkage)) != NULL) {
 		list_del_init(page->cp_layers.next);
 		if (unlikely(slice->cpl_ops->cpo_fini))
 			slice->cpl_ops->cpo_fini(env, slice);
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index cee144c0ac6c..382eaf519a79 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -939,6 +939,8 @@ void class_unlink_export(struct obd_export *exp)
 /* Import management functions */
 static void class_import_destroy(struct obd_import *imp)
 {
+	struct obd_import_conn *imp_conn;
+
 	CDEBUG(D_IOCTL, "destroying import %p for %s\n", imp,
 	       imp->imp_obd->obd_name);
 
@@ -946,11 +948,9 @@ static void class_import_destroy(struct obd_import *imp)
 
 	ptlrpc_put_connection_superhack(imp->imp_connection);
 
-	while (!list_empty(&imp->imp_conn_list)) {
-		struct obd_import_conn *imp_conn;
-
-		imp_conn = list_entry(imp->imp_conn_list.next,
-				      struct obd_import_conn, oic_item);
+	while ((imp_conn = list_first_entry_or_null(&imp->imp_conn_list,
+						    struct obd_import_conn,
+						    oic_item)) != NULL) {
 		list_del_init(&imp_conn->oic_item);
 		ptlrpc_put_connection_superhack(imp_conn->oic_conn);
 		kfree(imp_conn);
@@ -1356,8 +1356,9 @@ void obd_put_request_slot(struct client_obd *cli)
 	/* If there is free slot, wakeup the first waiter. */
 	if (!list_empty(&cli->cl_loi_read_list) &&
 	    likely(cli->cl_r_in_flight < cli->cl_max_rpcs_in_flight)) {
-		orsw = list_entry(cli->cl_loi_read_list.next,
-				  struct obd_request_slot_waiter, orsw_entry);
+		orsw = list_first_entry(&cli->cl_loi_read_list,
+					struct obd_request_slot_waiter,
+					orsw_entry);
 		list_del_init(&orsw->orsw_entry);
 		cli->cl_r_in_flight++;
 		wake_up(&orsw->orsw_waitq);
@@ -1409,11 +1410,12 @@ int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max)
 
 	/* We increase the max_rpcs_in_flight, then wakeup some waiters. */
 	for (i = 0; i < diff; i++) {
-		if (list_empty(&cli->cl_loi_read_list))
+		orsw = list_first_entry_or_null(&cli->cl_loi_read_list,
+						struct obd_request_slot_waiter,
+						orsw_entry);
+		if (!orsw)
 			break;
 
-		orsw = list_entry(cli->cl_loi_read_list.next,
-				  struct obd_request_slot_waiter, orsw_entry);
 		list_del_init(&orsw->orsw_entry);
 		cli->cl_r_in_flight++;
 		wake_up(&orsw->orsw_waitq);
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index 0c3e0ca8c03c..69a3b322119d 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -156,9 +156,8 @@ int class_del_uuid(const char *uuid)
 		return -EINVAL;
 	}
 
-	while (!list_empty(&deathrow)) {
-		data = list_entry(deathrow.next, struct uuid_nid_data,
-				  un_list);
+	while ((data = list_first_entry_or_null(&deathrow, struct uuid_nid_data,
+						un_list)) != NULL) {
 		list_del(&data->un_list);
 
 		CDEBUG(D_INFO, "del uuid %s %s/%d\n",
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 673e139bff82..4359a9320f37 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2000,9 +2000,9 @@ static unsigned int get_write_extents(struct osc_object *obj,
 		EASSERT(ext->oe_nr_pages <= data.erd_max_pages, ext);
 	}
 
-	while (!list_empty(&obj->oo_urgent_exts)) {
-		ext = list_entry(obj->oo_urgent_exts.next,
-				 struct osc_extent, oe_link);
+	while ((ext = list_first_entry_or_null(&obj->oo_urgent_exts,
+					       struct osc_extent,
+					       oe_link)) != NULL) {
 		if (!try_to_add_extent_for_io(cli, ext, &data))
 			return data.erd_page_count;
 	}
@@ -2014,9 +2014,9 @@ static unsigned int get_write_extents(struct osc_object *obj,
 	 * is so we don't miss adding extra extents to an RPC containing high
 	 * priority or urgent extents.
 	 */
-	while (!list_empty(&obj->oo_full_exts)) {
-		ext = list_entry(obj->oo_full_exts.next,
-				 struct osc_extent, oe_link);
+	while ((ext = list_first_entry_or_null(&obj->oo_full_exts,
+					       struct osc_extent,
+					       oe_link)) != NULL) {
 		if (!try_to_add_extent_for_io(cli, ext, &data))
 			break;
 	}
@@ -2751,10 +2751,11 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
 
 	osc_list_maint(cli, obj);
 
-	while (!list_empty(&list)) {
+	while ((ext = list_first_entry_or_null(&list,
+					       struct osc_extent,
+					       oe_link)) != NULL) {
 		int rc;
 
-		ext = list_entry(list.next, struct osc_extent, oe_link);
 		list_del_init(&ext->oe_link);
 
 		/* extent may be in OES_ACTIVE state because inode mutex
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index da8c3978fab8..75b5dedd4fbb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -834,8 +834,9 @@ static void osc_lock_wake_waiters(const struct lu_env *env,
 	while (!list_empty(&oscl->ols_waiting_list)) {
 		struct osc_lock *scan;
 
-		scan = list_entry(oscl->ols_waiting_list.next, struct osc_lock,
-				  ols_wait_entry);
+		scan = list_first_entry(&oscl->ols_waiting_list,
+					struct osc_lock,
+					ols_wait_entry);
 		list_del_init(&scan->ols_wait_entry);
 
 		cl_sync_io_note(env, scan->ols_owner, 0);
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 71f548570fec..135bfe5e1b37 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -572,8 +572,8 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		if (--maxscan < 0)
 			break;
 
-		opg = list_entry(cli->cl_lru_list.next, struct osc_page,
-				 ops_lru);
+		opg = list_first_entry(&cli->cl_lru_list, struct osc_page,
+				       ops_lru);
 		page = opg->ops_cl.cpl_page;
 		if (lru_page_busy(cli, page)) {
 			list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
@@ -708,9 +708,10 @@ static long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
 	list_move_tail(&cli->cl_lru_osc, &cache->ccc_lru);
 
 	max_scans = atomic_read(&cache->ccc_users) - 2;
-	while (--max_scans > 0 && !list_empty(&cache->ccc_lru)) {
-		cli = list_entry(cache->ccc_lru.next, struct client_obd,
-				 cl_lru_osc);
+	while (--max_scans > 0 &&
+	       (cli = list_first_entry_or_null(&cache->ccc_lru,
+					       struct client_obd,
+					       cl_lru_osc)) != NULL) {
 
 		CDEBUG(D_CACHE, "%s: cli %p LRU pages: %ld, busy: %ld.\n",
 		       cli_name(cli), cli,
@@ -1047,9 +1048,9 @@ unsigned long osc_cache_shrink_scan(struct shrinker *sk,
 		return SHRINK_STOP;
 
 	spin_lock(&osc_shrink_lock);
-	while (!list_empty(&osc_shrink_list)) {
-		cli = list_entry(osc_shrink_list.next, struct client_obd,
-				 cl_shrink_list);
+	while ((cli = list_first_entry_or_null(&osc_shrink_list,
+					       struct client_obd,
+					       cl_shrink_list)) != NULL) {
 
 		if (!stop_anchor)
 			stop_anchor = cli;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 86f9de611221..9e72fa8f68b3 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1936,7 +1936,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	}
 
 	/* first page in the list */
-	oap = list_entry(rpc_list.next, typeof(*oap), oap_rpc_item);
+	oap = list_first_entry(&rpc_list, typeof(*oap), oap_rpc_item);
 
 	crattr = &osc_env_info(env)->oti_req_attr;
 	memset(crattr, 0, sizeof(*crattr));
@@ -2019,9 +2019,9 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		/* this should happen rarely and is pretty bad, it makes the
 		 * pending list not follow the dirty order
 		 */
-		while (!list_empty(ext_list)) {
-			ext = list_entry(ext_list->next, struct osc_extent,
-					 oe_link);
+		while ((ext = list_first_entry_or_null(ext_list,
+						       struct osc_extent,
+						       oe_link)) != NULL) {
 			list_del_init(&ext->oe_link);
 			osc_extent_finish(env, ext, 0, rc);
 		}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 2c519ad6f7cc..a78d49621c42 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -625,8 +625,8 @@ ptlrpc_prep_req_from_pool(struct ptlrpc_request_pool *pool)
 		return NULL;
 	}
 
-	request = list_entry(pool->prp_req_list.next, struct ptlrpc_request,
-			     rq_list);
+	request = list_first_entry(&pool->prp_req_list, struct ptlrpc_request,
+				   rq_list);
 	list_del_init(&request->rq_list);
 	spin_unlock(&pool->prp_lock);
 
@@ -1274,8 +1274,8 @@ u64 ptlrpc_known_replied_xid(struct obd_import *imp)
 	if (list_empty(&imp->imp_unreplied_list))
 		return 0;
 
-	req = list_entry(imp->imp_unreplied_list.next, struct ptlrpc_request,
-			 rq_unreplied_list);
+	req = list_first_entry(&imp->imp_unreplied_list, struct ptlrpc_request,
+			       rq_unreplied_list);
 	LASSERTF(req->rq_xid >= 1, "XID:%llu\n", req->rq_xid);
 
 	if (imp->imp_known_replied_xid < req->rq_xid - 1)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index 7fe8aeeff428..ab186d84aefe 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -163,9 +163,9 @@ struct ptlrpc_nrs_request *nrs_fifo_req_get(struct ptlrpc_nrs_policy *policy,
 	struct nrs_fifo_head *head = policy->pol_private;
 	struct ptlrpc_nrs_request *nrq;
 
-	nrq = unlikely(list_empty(&head->fh_list)) ? NULL :
-	      list_entry(head->fh_list.next, struct ptlrpc_nrs_request,
-			 nr_u.fifo.fr_list);
+	nrq = list_first_entry_or_null(&head->fh_list,
+				       struct ptlrpc_nrs_request,
+				       nr_u.fifo.fr_list);
 
 	if (likely(!peek && nrq)) {
 		struct ptlrpc_request *req = container_of(nrq,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 1fadba2be16b..c7cc86c3fbc3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -272,8 +272,8 @@ lustre_get_emerg_rs(struct ptlrpc_service_part *svcpt)
 		spin_lock(&svcpt->scp_rep_lock);
 	}
 
-	rs = list_entry(svcpt->scp_rep_idle.next,
-			struct ptlrpc_reply_state, rs_list);
+	rs = list_first_entry(&svcpt->scp_rep_idle,
+			      struct ptlrpc_reply_state, rs_list);
 	list_del(&rs->rs_list);
 
 	spin_unlock(&svcpt->scp_rep_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 2c8bad7b7877..c4dba675db52 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -101,9 +101,9 @@ static void sec_process_ctx_list(void)
 
 	spin_lock(&sec_gc_ctx_list_lock);
 
-	while (!list_empty(&sec_gc_ctx_list)) {
-		ctx = list_entry(sec_gc_ctx_list.next,
-				 struct ptlrpc_cli_ctx, cc_gc_chain);
+	while ((ctx = list_first_entry_or_null(&sec_gc_ctx_list,
+					       struct ptlrpc_cli_ctx,
+					       cc_gc_chain)) != NULL) {
 		list_del_init(&ctx->cc_gc_chain);
 		spin_unlock(&sec_gc_ctx_list_lock);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 5b97f2a1fea1..a69736dfe8b7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -299,9 +299,9 @@ ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
 			return posted;
 		}
 
-		rqbd = list_entry(svcpt->scp_rqbd_idle.next,
-				  struct ptlrpc_request_buffer_desc,
-				  rqbd_list);
+		rqbd = list_first_entry(&svcpt->scp_rqbd_idle,
+					struct ptlrpc_request_buffer_desc,
+					rqbd_list);
 		list_del(&rqbd->rqbd_list);
 
 		/* assume we will post successfully */
@@ -769,9 +769,9 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 		 * I expect only about 1 or 2 rqbds need to be recycled here
 		 */
 		while (svcpt->scp_hist_nrqbds > svc->srv_hist_nrqbds_cpt_max) {
-			rqbd = list_entry(svcpt->scp_hist_rqbds.next,
-					  struct ptlrpc_request_buffer_desc,
-					  rqbd_list);
+			rqbd = list_first_entry(&svcpt->scp_hist_rqbds,
+						struct ptlrpc_request_buffer_desc,
+						rqbd_list);
 
 			list_del(&rqbd->rqbd_list);
 			svcpt->scp_hist_nrqbds--;
@@ -1240,9 +1240,9 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	/* we took additional refcount so entries can't be deleted from list, no
 	 * locking is needed
 	 */
-	while (!list_empty(&work_list)) {
-		rq = list_entry(work_list.next, struct ptlrpc_request,
-				rq_timed_list);
+	while ((rq = list_first_entry_or_null(&work_list,
+					      struct ptlrpc_request,
+					      rq_timed_list)) != NULL) {
 		list_del_init(&rq->rq_timed_list);
 
 		if (ptlrpc_at_send_early_reply(rq) == 0)
@@ -1485,8 +1485,8 @@ ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 		return 0;
 	}
 
-	req = list_entry(svcpt->scp_req_incoming.next,
-			 struct ptlrpc_request, rq_list);
+	req = list_first_entry(&svcpt->scp_req_incoming,
+			       struct ptlrpc_request, rq_list);
 	list_del_init(&req->rq_list);
 	svcpt->scp_nreqs_incoming--;
 	/* Consider this still a "queued" request as far as stats are
@@ -2345,9 +2345,9 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 
 	wake_up_all(&svcpt->scp_waitq);
 
-	while (!list_empty(&svcpt->scp_threads)) {
-		thread = list_entry(svcpt->scp_threads.next,
-				    struct ptlrpc_thread, t_link);
+	while ((thread = list_first_entry_or_null(&svcpt->scp_threads,
+						  struct ptlrpc_thread,
+						  t_link)) != NULL) {
 		if (thread_is_stopped(thread)) {
 			list_del(&thread->t_link);
 			list_add(&thread->t_link, &zombie);
@@ -2365,9 +2365,9 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 
 	spin_unlock(&svcpt->scp_lock);
 
-	while (!list_empty(&zombie)) {
-		thread = list_entry(zombie.next,
-				    struct ptlrpc_thread, t_link);
+	while ((thread = list_first_entry(&zombie,
+					  struct ptlrpc_thread,
+					  t_link)) != NULL) {
 		list_del(&thread->t_link);
 		kfree(thread);
 	}
@@ -2707,9 +2707,9 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 			break;
 
 		spin_lock(&svcpt->scp_rep_lock);
-		while (!list_empty(&svcpt->scp_rep_active)) {
-			rs = list_entry(svcpt->scp_rep_active.next,
-					struct ptlrpc_reply_state, rs_list);
+		while ((rs = list_first_entry_or_null(&svcpt->scp_rep_active,
+						      struct ptlrpc_reply_state,
+						      rs_list)) != NULL) {
 			spin_lock(&rs->rs_lock);
 			ptlrpc_schedule_difficult_reply(rs);
 			spin_unlock(&rs->rs_lock);
@@ -2720,10 +2720,9 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 		 * all unlinked) and no service threads, so I'm the only
 		 * thread noodling the request queue now
 		 */
-		while (!list_empty(&svcpt->scp_req_incoming)) {
-			req = list_entry(svcpt->scp_req_incoming.next,
-					 struct ptlrpc_request, rq_list);
-
+		while ((req = list_first_entry_or_null(&svcpt->scp_req_incoming,
+						       struct ptlrpc_request,
+						       rq_list)) != NULL) {
 			list_del(&req->rq_list);
 			svcpt->scp_nreqs_incoming--;
 			ptlrpc_server_finish_request(svcpt, req);
@@ -2747,17 +2746,17 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 		 */
 
 		while (!list_empty(&svcpt->scp_rqbd_idle)) {
-			rqbd = list_entry(svcpt->scp_rqbd_idle.next,
-					  struct ptlrpc_request_buffer_desc,
-					  rqbd_list);
+			rqbd = list_first_entry(&svcpt->scp_rqbd_idle,
+						struct ptlrpc_request_buffer_desc,
+						rqbd_list);
 			ptlrpc_free_rqbd(rqbd);
 		}
 		ptlrpc_wait_replies(svcpt);
 
 		while (!list_empty(&svcpt->scp_rep_idle)) {
-			rs = list_entry(svcpt->scp_rep_idle.next,
-					struct ptlrpc_reply_state,
-					rs_list);
+			rs = list_first_entry(&svcpt->scp_rep_idle,
+					      struct ptlrpc_reply_state,
+					      rs_list);
 			list_del(&rs->rs_list);
 			kvfree(rs);
 		}
