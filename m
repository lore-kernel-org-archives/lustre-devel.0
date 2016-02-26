From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:50:03 -0500
Subject: [lustre-devel] [PATCH 15/25] staging/lustre/osc: Fix style vs open
	parenthesis alignment
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-16-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c   | 20 ++++++-------
 drivers/staging/lustre/lustre/osc/osc_cache.c   | 18 +++++-------
 drivers/staging/lustre/lustre/osc/osc_io.c      |  5 ++--
 drivers/staging/lustre/lustre/osc/osc_lock.c    | 27 +++++++++---------
 drivers/staging/lustre/lustre/osc/osc_page.c    | 37 ++++++++++++-------------
 drivers/staging/lustre/lustre/osc/osc_request.c | 17 ++++++------
 6 files changed, 59 insertions(+), 65 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index b5df5e6..57c43c5 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -397,8 +397,8 @@ static int osc_checksum_type_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_checksum_type_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+					   const char __user *buffer,
+					   size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	int i;
@@ -652,10 +652,10 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 		read_cum += r;
 		write_cum += w;
 		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
-				 1 << i, r, pct(r, read_tot),
-				 pct(read_cum, read_tot), w,
-				 pct(w, write_tot),
-				 pct(write_cum, write_tot));
+			   1 << i, r, pct(r, read_tot),
+			   pct(read_cum, read_tot), w,
+			   pct(w, write_tot),
+			   pct(write_cum, write_tot));
 		if (read_cum == read_tot && write_cum == write_tot)
 			break;
 	}
@@ -676,10 +676,10 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 		read_cum += r;
 		write_cum += w;
 		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
-				 i, r, pct(r, read_tot),
-				 pct(read_cum, read_tot), w,
-				 pct(w, write_tot),
-				 pct(write_cum, write_tot));
+			   i, r, pct(r, read_tot),
+			   pct(read_cum, read_tot), w,
+			   pct(w, write_tot),
+			   pct(write_cum, write_tot));
 		if (read_cum == read_tot && write_cum == write_tot)
 			break;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index c6623c1..031746a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -603,7 +603,7 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 
 			if (ext->oe_urgent)
 				list_move_tail(&ext->oe_link,
-						   &obj->oo_urgent_exts);
+					       &obj->oo_urgent_exts);
 		}
 		osc_object_unlock(obj);
 
@@ -855,8 +855,7 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 
 	ext->oe_rc = rc ?: ext->oe_nr_pages;
 	EASSERT(ergo(rc == 0, ext->oe_state == OES_RPC), ext);
-	list_for_each_entry_safe(oap, tmp, &ext->oe_pages,
-				     oap_pending_item) {
+	list_for_each_entry_safe(oap, tmp, &ext->oe_pages, oap_pending_item) {
 		list_del_init(&oap->oap_rpc_item);
 		list_del_init(&oap->oap_pending_item);
 		if (last_off <= oap->oap_obj_off) {
@@ -989,8 +988,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 		goto out;
 
 	/* discard all pages with index greater then trunc_index */
-	list_for_each_entry_safe(oap, tmp, &ext->oe_pages,
-				     oap_pending_item) {
+	list_for_each_entry_safe(oap, tmp, &ext->oe_pages, oap_pending_item) {
 		struct cl_page *sub = oap2cl_page(oap);
 		struct cl_page *page = cl_page_top(sub);
 
@@ -1912,7 +1910,7 @@ static int get_write_extents(struct osc_object *obj, struct list_head *rpclist)
 	LASSERT(osc_object_is_locked(obj));
 	while (!list_empty(&obj->oo_hp_exts)) {
 		ext = list_entry(obj->oo_hp_exts.next, struct osc_extent,
-				     oe_link);
+				 oe_link);
 		LASSERT(ext->oe_state == OES_CACHE);
 		if (!try_to_add_extent_for_io(cli, ext, rpclist, &page_count,
 					      &max_pages))
@@ -1924,7 +1922,7 @@ static int get_write_extents(struct osc_object *obj, struct list_head *rpclist)
 
 	while (!list_empty(&obj->oo_urgent_exts)) {
 		ext = list_entry(obj->oo_urgent_exts.next,
-				     struct osc_extent, oe_link);
+				 struct osc_extent, oe_link);
 		if (!try_to_add_extent_for_io(cli, ext, rpclist, &page_count,
 					      &max_pages))
 			return page_count;
@@ -2051,8 +2049,7 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 	int rc = 0;
 
 	LASSERT(osc_object_is_locked(osc));
-	list_for_each_entry_safe(ext, next,
-				     &osc->oo_reading_exts, oe_link) {
+	list_for_each_entry_safe(ext, next, &osc->oo_reading_exts, oe_link) {
 		EASSERT(ext->oe_state == OES_LOCK_DONE, ext);
 		if (!try_to_add_extent_for_io(cli, ext, &rpclist, &page_count,
 					      &max_pages))
@@ -2928,8 +2925,7 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 					ext->oe_max_end <= end, ext);
 				osc_extent_state_set(ext, OES_LOCKING);
 				ext->oe_owner = current;
-				list_move_tail(&ext->oe_link,
-						   &discard_list);
+				list_move_tail(&ext->oe_link, &discard_list);
 				osc_update_pending(obj, OBD_BRW_WRITE,
 						   -ext->oe_nr_pages);
 			}
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 2d8d93c..add94a2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -357,7 +357,7 @@ static int trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 	if (oap->oap_cmd & OBD_BRW_WRITE &&
 	    !list_empty(&oap->oap_pending_item))
 		CL_PAGE_DEBUG(D_ERROR, env, page, "exists %llu/%s.\n",
-				start, current->comm);
+			      start, current->comm);
 
 	{
 		struct page *vmpage = cl_page_vmpage(env, page);
@@ -761,8 +761,7 @@ static void osc_req_attr_set(const struct lu_env *env,
 			struct cl_lock *scan;
 
 			head = cl_object_header(apage->cp_obj);
-			list_for_each_entry(scan, &head->coh_locks,
-						cll_linkage)
+			list_for_each_entry(scan, &head->coh_locks, cll_linkage)
 				CL_LOCK_DEBUG(D_ERROR, env, scan,
 					      "no cover page!\n");
 			CL_PAGE_DEBUG(D_ERROR, env, apage,
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index cc308149..6fcdf91 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -1117,7 +1117,7 @@ static int osc_lock_enqueue(const struct lu_env *env,
 		 "Impossible state: %d\n", ols->ols_state);
 
 	LASSERTF(ergo(ols->ols_glimpse, lock->cll_descr.cld_mode <= CLM_READ),
-		"lock = %p, ols = %p\n", lock, ols);
+		 "lock = %p, ols = %p\n", lock, ols);
 
 	result = osc_lock_enqueue_wait(env, ols);
 	if (result == 0) {
@@ -1144,12 +1144,12 @@ static int osc_lock_enqueue(const struct lu_env *env,
 			ostid_build_res_name(&obj->oo_oinfo->loi_oi, resname);
 			osc_lock_build_policy(env, lock, policy);
 			result = osc_enqueue_base(osc_export(obj), resname,
-					  &ols->ols_flags, policy,
-					  &ols->ols_lvb,
-					  obj->oo_oinfo->loi_kms_valid,
-					  osc_lock_upcall,
-					  ols, einfo, &ols->ols_handle,
-					  PTLRPCD_SET, 1, ols->ols_agl);
+						  &ols->ols_flags, policy,
+						  &ols->ols_lvb,
+						  obj->oo_oinfo->loi_kms_valid,
+						  osc_lock_upcall,
+						  ols, einfo, &ols->ols_handle,
+						  PTLRPCD_SET, 1, ols->ols_agl);
 			if (result != 0) {
 				cl_lock_user_del(env, lock);
 				cl_lock_unhold(env, lock, "upcall", lock);
@@ -1266,11 +1266,12 @@ static int osc_lock_flush(struct osc_lock *ols, int discard)
 
 		if (descr->cld_mode >= CLM_WRITE) {
 			result = osc_cache_writeback_range(env, obj,
-					descr->cld_start, descr->cld_end,
-					1, discard);
+							   descr->cld_start,
+							   descr->cld_end,
+							   1, discard);
 			LDLM_DEBUG(ols->ols_lock,
-				"lock %p: %d pages were %s.\n", lock, result,
-				discard ? "discarded" : "written");
+				   "lock %p: %d pages were %s.\n", lock, result,
+				   discard ? "discarded" : "written");
 			if (result > 0)
 				result = 0;
 		}
@@ -1590,7 +1591,7 @@ int osc_lock_init(const struct lu_env *env,
 			clk->ols_flags |= LDLM_FL_DENY_ON_CONTENTION;
 
 		LDLM_DEBUG_NOLOCK("lock %p, osc lock %p, flags %llx\n",
-				lock, clk, clk->ols_flags);
+				  lock, clk, clk->ols_flags);
 
 		result = 0;
 	} else
@@ -1612,7 +1613,7 @@ int osc_dlm_lock_pageref(struct ldlm_lock *dlm)
 	 */
 	if (olock &&
 	    atomic_add_return(_PAGEREF_MAGIC,
-				  &olock->ols_pageref) != _PAGEREF_MAGIC) {
+			      &olock->ols_pageref) != _PAGEREF_MAGIC) {
 		atomic_sub(_PAGEREF_MAGIC, &olock->ols_pageref);
 		rc = 1;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index d11582a..537107c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -403,7 +403,7 @@ static const struct cl_page_operations osc_page_ops = {
 };
 
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
-		struct cl_page *page, struct page *vmpage)
+		  struct cl_page *page, struct page *vmpage)
 {
 	struct osc_object *osc = cl2osc(obj);
 	struct osc_page *opg = cl_object_page_slice(obj, page);
@@ -413,13 +413,12 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 	opg->ops_to = PAGE_CACHE_SIZE;
 
 	result = osc_prep_async_page(osc, opg, vmpage,
-					cl_offset(obj, page->cp_index));
+				     cl_offset(obj, page->cp_index));
 	if (result == 0) {
 		struct osc_io *oio = osc_env_io(env);
 
 		opg->ops_srvlock = osc_io_srvlock(oio);
-		cl_page_slice_add(page, &opg->ops_cl, obj,
-				&osc_page_ops);
+		cl_page_slice_add(page, &opg->ops_cl, obj, &osc_page_ops);
 	}
 	/*
 	 * Cannot assert osc_page_protected() here as read-ahead
@@ -462,7 +461,7 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	oap->oap_brw_flags = brw_flags | OBD_BRW_SYNC;
 
 	if (!client_is_remote(osc_export(obj)) &&
-			capable(CFS_CAP_SYS_RESOURCE)) {
+	    capable(CFS_CAP_SYS_RESOURCE)) {
 		oap->oap_brw_flags |= OBD_BRW_NOQUOTA;
 		oap->oap_cmd |= OBD_BRW_NOQUOTA;
 	}
@@ -590,7 +589,7 @@ int osc_lru_shrink(struct client_obd *cli, int target)
 			break;
 
 		opg = list_entry(cli->cl_lru_list.next, struct osc_page,
-				     ops_lru);
+				 ops_lru);
 		page = cl_page_top(opg->ops_cl.cpl_page);
 		if (cl_page_in_use_noref(page)) {
 			list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
@@ -737,14 +736,14 @@ static int osc_lru_reclaim(struct client_obd *cli)
 	rc = osc_lru_shrink(cli, lru_shrink_min);
 	if (rc != 0) {
 		CDEBUG(D_CACHE, "%s: Free %d pages from own LRU: %p.\n",
-			cli->cl_import->imp_obd->obd_name, rc, cli);
+		       cli->cl_import->imp_obd->obd_name, rc, cli);
 		return rc;
 	}
 
 	CDEBUG(D_CACHE, "%s: cli %p no free slots, pages: %d, busy: %d.\n",
-		cli->cl_import->imp_obd->obd_name, cli,
-		atomic_read(&cli->cl_lru_in_list),
-		atomic_read(&cli->cl_lru_busy));
+	       cli->cl_import->imp_obd->obd_name, cli,
+	       atomic_read(&cli->cl_lru_in_list),
+	       atomic_read(&cli->cl_lru_busy));
 
 	/* Reclaim LRU slots from other client_obd as it can't free enough
 	 * from its own. This should rarely happen.
@@ -758,12 +757,12 @@ static int osc_lru_reclaim(struct client_obd *cli)
 	max_scans = atomic_read(&cache->ccc_users);
 	while (--max_scans > 0 && !list_empty(&cache->ccc_lru)) {
 		cli = list_entry(cache->ccc_lru.next, struct client_obd,
-					cl_lru_osc);
+				 cl_lru_osc);
 
 		CDEBUG(D_CACHE, "%s: cli %p LRU pages: %d, busy: %d.\n",
-			cli->cl_import->imp_obd->obd_name, cli,
-			atomic_read(&cli->cl_lru_in_list),
-			atomic_read(&cli->cl_lru_busy));
+		       cli->cl_import->imp_obd->obd_name, cli,
+		       atomic_read(&cli->cl_lru_in_list),
+		       atomic_read(&cli->cl_lru_busy));
 
 		list_move_tail(&cli->cl_lru_osc, &cache->ccc_lru);
 		if (atomic_read(&cli->cl_lru_in_list) > 0) {
@@ -778,7 +777,7 @@ static int osc_lru_reclaim(struct client_obd *cli)
 	spin_unlock(&cache->ccc_lru_lock);
 
 	CDEBUG(D_CACHE, "%s: cli %p freed %d pages.\n",
-		cli->cl_import->imp_obd->obd_name, cli, rc);
+	       cli->cl_import->imp_obd->obd_name, cli, rc);
 	return rc;
 }
 
@@ -812,10 +811,10 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 
 		gen = atomic_read(&cli->cl_lru_in_list);
 		rc = l_wait_event(osc_lru_waitq,
-				atomic_read(cli->cl_lru_left) > 0 ||
-				(atomic_read(&cli->cl_lru_in_list) > 0 &&
-				 gen != atomic_read(&cli->cl_lru_in_list)),
-				&lwi);
+				  atomic_read(cli->cl_lru_left) > 0 ||
+				  (atomic_read(&cli->cl_lru_in_list) > 0 &&
+				   gen != atomic_read(&cli->cl_lru_in_list)),
+				  &lwi);
 
 		atomic_dec(&osc_lru_waiters);
 		if (rc < 0)
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 10f262f..770d6fc 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -993,8 +993,7 @@ static int osc_grant_shrink_grant_cb(struct timeout_item *item, void *data)
 {
 	struct client_obd *client;
 
-	list_for_each_entry(client, &item->ti_obd_list,
-				cl_grant_shrink_list) {
+	list_for_each_entry(client, &item->ti_obd_list, cl_grant_shrink_list) {
 		if (osc_should_shrink_grant(client))
 			osc_shrink_grant(client);
 	}
@@ -1011,7 +1010,7 @@ static int osc_add_shrink_grant(struct client_obd *client)
 				       &client->cl_grant_shrink_list);
 	if (rc) {
 		CERROR("add grant client %s error %d\n",
-			client->cl_import->imp_obd->obd_name, rc);
+		       client->cl_import->imp_obd->obd_name, rc);
 		return rc;
 	}
 	CDEBUG(D_CACHE, "add grant client %s\n",
@@ -1127,7 +1126,7 @@ static int check_write_rcs(struct ptlrpc_request *req,
 
 		if (remote_rcs[i] != 0) {
 			CDEBUG(D_INFO, "rc[%d] invalid (%d) req %p\n",
-				i, remote_rcs[i], req);
+			       i, remote_rcs[i], req);
 			return -EPROTO;
 		}
 	}
@@ -1195,7 +1194,7 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 			kunmap(pga[i]->pg);
 		}
 		cfs_crypto_hash_update_page(hdesc, pga[i]->pg,
-				  pga[i]->off & ~CFS_PAGE_MASK,
+					    pga[i]->off & ~CFS_PAGE_MASK,
 				  count);
 		CDEBUG(D_PAGE,
 		       "page %p map %p index %lu flags %lx count %u priv %0lx: off %d\n",
@@ -1554,7 +1553,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 
 	if (rc != req->rq_bulk->bd_nob_transferred) {
 		CERROR("Unexpected rc %d (%d transferred)\n",
-			rc, req->rq_bulk->bd_nob_transferred);
+		       rc, req->rq_bulk->bd_nob_transferred);
 		return -EPROTO;
 	}
 
@@ -1944,7 +1943,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 
 	sort_brw_pages(pga, page_count);
 	rc = osc_brw_prep_request(cmd, cli, oa, NULL, page_count,
-			pga, &req, 1, 0);
+				  pga, &req, 1, 0);
 	if (rc != 0) {
 		CERROR("prep_req failed: %d\n", rc);
 		goto out;
@@ -1986,7 +1985,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 			tmp = oap;
 		if (oap->oap_interrupted && !req->rq_intr) {
 			CDEBUG(D_INODE, "oap %p in req %p interrupted\n",
-					oap, req);
+			       oap, req);
 			ptlrpc_mark_interrupted(req);
 		}
 	}
@@ -2034,7 +2033,7 @@ out:
 		 */
 		while (!list_empty(ext_list)) {
 			ext = list_entry(ext_list->next, struct osc_extent,
-					     oe_link);
+					 oe_link);
 			list_del_init(&ext->oe_link);
 			osc_extent_finish(env, ext, 0, rc);
 		}
-- 
2.1.0
