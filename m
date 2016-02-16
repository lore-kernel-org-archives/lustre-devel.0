From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:57 -0500
Subject: [lustre-devel] [PATCH 25/45] staging/lustre/osc: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-26-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Also remove some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   4 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 120 ++++++++++---------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   4 +-
 drivers/staging/lustre/lustre/osc/osc_dev.c        |   6 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  19 ++-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  61 +++++-----
 drivers/staging/lustre/lustre/osc/osc_object.c     |   4 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  22 ++--
 drivers/staging/lustre/lustre/osc/osc_quota.c      |  16 +--
 drivers/staging/lustre/lustre/osc/osc_request.c    | 130 ++++++++++-----------
 10 files changed, 189 insertions(+), 197 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index b69ec0f..cb9edaf 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -381,7 +381,7 @@ static int osc_checksum_type_seq_show(struct seq_file *m, void *v)
 
 	DECLARE_CKSUM_NAME;
 
-	if (obd == NULL)
+	if (!obd)
 		return 0;
 
 	for (i = 0; i < ARRAY_SIZE(cksum_name); i++) {
@@ -406,7 +406,7 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 	DECLARE_CKSUM_NAME;
 	char kernbuf[10];
 
-	if (obd == NULL)
+	if (!obd)
 		return 0;
 
 	if (count > sizeof(kernbuf) - 1)
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 6b5f8d0..4704231 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -140,7 +140,7 @@ static const char *oes_strings[] = {
 
 static inline struct osc_extent *rb_extent(struct rb_node *n)
 {
-	if (n == NULL)
+	if (!n)
 		return NULL;
 
 	return container_of(n, struct osc_extent, oe_node);
@@ -148,7 +148,7 @@ static inline struct osc_extent *rb_extent(struct rb_node *n)
 
 static inline struct osc_extent *next_extent(struct osc_extent *ext)
 {
-	if (ext == NULL)
+	if (!ext)
 		return NULL;
 
 	LASSERT(ext->oe_intree);
@@ -157,7 +157,7 @@ static inline struct osc_extent *next_extent(struct osc_extent *ext)
 
 static inline struct osc_extent *prev_extent(struct osc_extent *ext)
 {
-	if (ext == NULL)
+	if (!ext)
 		return NULL;
 
 	LASSERT(ext->oe_intree);
@@ -240,7 +240,7 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 		goto out;
 	}
 
-	if (ext->oe_osclock == NULL && ext->oe_grants > 0) {
+	if (!ext->oe_osclock && ext->oe_grants > 0) {
 		rc = 90;
 		goto out;
 	}
@@ -319,7 +319,7 @@ static int osc_extent_is_overlapped(struct osc_object *obj,
 	if (!extent_debug)
 		return 0;
 
-	for (tmp = first_extent(obj); tmp != NULL; tmp = next_extent(tmp)) {
+	for (tmp = first_extent(obj); tmp; tmp = next_extent(tmp)) {
 		if (tmp == ext)
 			continue;
 		if (tmp->oe_end >= ext->oe_start &&
@@ -347,7 +347,7 @@ static struct osc_extent *osc_extent_alloc(struct osc_object *obj)
 	struct osc_extent *ext;
 
 	ext = kmem_cache_alloc(osc_extent_kmem, GFP_NOFS | __GFP_ZERO);
-	if (ext == NULL)
+	if (!ext)
 		return NULL;
 
 	RB_CLEAR_NODE(&ext->oe_node);
@@ -415,7 +415,7 @@ static struct osc_extent *osc_extent_search(struct osc_object *obj,
 	struct osc_extent *tmp, *p = NULL;
 
 	LASSERT(osc_object_is_locked(obj));
-	while (n != NULL) {
+	while (n) {
 		tmp = rb_extent(n);
 		if (index < tmp->oe_start) {
 			n = n->rb_left;
@@ -439,7 +439,7 @@ static struct osc_extent *osc_extent_lookup(struct osc_object *obj,
 	struct osc_extent *ext;
 
 	ext = osc_extent_search(obj, index);
-	if (ext != NULL && ext->oe_start <= index && index <= ext->oe_end)
+	if (ext && ext->oe_start <= index && index <= ext->oe_end)
 		return osc_extent_get(ext);
 	return NULL;
 }
@@ -454,7 +454,7 @@ static void osc_extent_insert(struct osc_object *obj, struct osc_extent *ext)
 	LASSERT(ext->oe_intree == 0);
 	LASSERT(ext->oe_obj == obj);
 	LASSERT(osc_object_is_locked(obj));
-	while (*n != NULL) {
+	while (*n) {
 		tmp = rb_extent(*n);
 		parent = *n;
 
@@ -533,7 +533,7 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 
 	LASSERT(cur->oe_state == OES_CACHE);
 	LASSERT(osc_object_is_locked(obj));
-	if (victim == NULL)
+	if (!victim)
 		return -EINVAL;
 
 	if (victim->oe_state != OES_CACHE || victim->oe_fsync_wait)
@@ -639,11 +639,10 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	int rc;
 
 	cur = osc_extent_alloc(obj);
-	if (cur == NULL)
+	if (!cur)
 		return ERR_PTR(-ENOMEM);
 
 	lock = cl_lock_at_pgoff(env, osc2cl(obj), index, NULL, 1, 0);
-	LASSERT(lock != NULL);
 	LASSERT(lock->cll_descr.cld_mode >= CLM_WRITE);
 
 	LASSERT(cli->cl_chunkbits >= PAGE_CACHE_SHIFT);
@@ -678,9 +677,9 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 restart:
 	osc_object_lock(obj);
 	ext = osc_extent_search(obj, cur->oe_start);
-	if (ext == NULL)
+	if (!ext)
 		ext = first_extent(obj);
-	while (ext != NULL) {
+	while (ext) {
 		loff_t ext_chk_start = ext->oe_start >> ppc_bits;
 		loff_t ext_chk_end = ext->oe_end >> ppc_bits;
 
@@ -775,21 +774,21 @@ restart:
 
 			found = osc_extent_hold(ext);
 		}
-		if (found != NULL)
+		if (found)
 			break;
 
 		ext = next_extent(ext);
 	}
 
 	osc_extent_tree_dump(D_CACHE, obj);
-	if (found != NULL) {
-		LASSERT(conflict == NULL);
+	if (found) {
+		LASSERT(!conflict);
 		if (!IS_ERR(found)) {
 			LASSERT(found->oe_osclock == cur->oe_osclock);
 			OSC_EXTENT_DUMP(D_CACHE, found,
 					"found caching ext for %lu.\n", index);
 		}
-	} else if (conflict == NULL) {
+	} else if (!conflict) {
 		/* create a new extent */
 		EASSERT(osc_extent_is_overlapped(obj, cur) == 0, cur);
 		cur->oe_grants = chunksize + cli->cl_extent_tax;
@@ -804,8 +803,8 @@ restart:
 	}
 	osc_object_unlock(obj);
 
-	if (conflict != NULL) {
-		LASSERT(found == NULL);
+	if (conflict) {
+		LASSERT(!found);
 
 		/* waiting for IO to finish. Please notice that it's impossible
 		 * to be an OES_TRUNC extent. */
@@ -1074,13 +1073,13 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	LASSERT(sanity_check(ext) == 0);
 	/* in locking state, any process should not touch this extent. */
 	EASSERT(ext->oe_state == OES_LOCKING, ext);
-	EASSERT(ext->oe_owner != NULL, ext);
+	EASSERT(ext->oe_owner, ext);
 
 	OSC_EXTENT_DUMP(D_CACHE, ext, "make ready\n");
 
 	list_for_each_entry(oap, &ext->oe_pages, oap_pending_item) {
 		++page_count;
-		if (last == NULL || last->oap_obj_off < oap->oap_obj_off)
+		if (!last || last->oap_obj_off < oap->oap_obj_off)
 			last = oap;
 
 		/* checking ASYNC_READY is race safe */
@@ -1103,7 +1102,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	}
 
 	LASSERT(page_count == ext->oe_nr_pages);
-	LASSERT(last != NULL);
+	LASSERT(last);
 	/* the last page is the only one we need to refresh its count by
 	 * the size of file. */
 	if (!(last->oap_async_flags & ASYNC_COUNT_STABLE)) {
@@ -1167,7 +1166,7 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index, int *grants)
 	end_index = min(ext->oe_max_end, ((chunk + 1) << ppc_bits) - 1);
 
 	next = next_extent(ext);
-	if (next != NULL && next->oe_start <= end_index) {
+	if (next && next->oe_start <= end_index) {
 		/* complex mode - overlapped with the next extent,
 		 * this case will be handled by osc_extent_find() */
 		rc = -EAGAIN;
@@ -1197,7 +1196,7 @@ static void osc_extent_tree_dump0(int level, struct osc_object *obj,
 
 	/* osc_object_lock(obj); */
 	cnt = 1;
-	for (ext = first_extent(obj); ext != NULL; ext = next_extent(ext))
+	for (ext = first_extent(obj); ext; ext = next_extent(ext))
 		OSC_EXTENT_DUMP(level, ext, "in tree %d.\n", cnt++);
 
 	cnt = 1;
@@ -1262,7 +1261,6 @@ static int osc_refresh_count(const struct lu_env *env,
 
 	/* readpage queues with _COUNT_STABLE, shouldn't get here. */
 	LASSERT(!(cmd & OBD_BRW_READ));
-	LASSERT(opg != NULL);
 	obj = opg->ops_cl.cpl_obj;
 
 	cl_object_attr_lock(obj);
@@ -1299,16 +1297,16 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	 * page->cp_req can be NULL if io submission failed before
 	 * cl_req was allocated.
 	 */
-	if (page->cp_req != NULL)
+	if (page->cp_req)
 		cl_req_page_done(env, page);
-	LASSERT(page->cp_req == NULL);
+	LASSERT(!page->cp_req);
 
 	crt = cmd == OBD_BRW_READ ? CRT_READ : CRT_WRITE;
 	/* Clear opg->ops_transfer_pinned before VM lock is released. */
 	opg->ops_transfer_pinned = 0;
 
 	spin_lock(&obj->oo_seatbelt);
-	LASSERT(opg->ops_submitter != NULL);
+	LASSERT(opg->ops_submitter);
 	LASSERT(!list_empty(&opg->ops_inflight));
 	list_del_init(&opg->ops_inflight);
 	opg->ops_submitter = NULL;
@@ -1650,7 +1648,7 @@ static int osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
 	 * by forcing them through rpcs that immediately fail and complete
 	 * the pages.  recovery relies on this to empty the queued pages
 	 * before canceling the locks and evicting down the llite pages */
-	if ((cli->cl_import == NULL || cli->cl_import->imp_invalid))
+	if (!cli->cl_import || cli->cl_import->imp_invalid)
 		invalid_import = 1;
 
 	if (cmd & OBD_BRW_WRITE) {
@@ -1788,7 +1786,7 @@ static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 	struct lov_oinfo *loi = osc->oo_oinfo;
 	__u64 xid = 0;
 
-	if (oap->oap_request != NULL) {
+	if (oap->oap_request) {
 		xid = ptlrpc_req_xid(oap->oap_request);
 		ptlrpc_req_finished(oap->oap_request);
 		oap->oap_request = NULL;
@@ -1906,7 +1904,7 @@ static int get_write_extents(struct osc_object *obj, struct list_head *rpclist)
 		while ((ext = next_extent(ext)) != NULL) {
 			if ((ext->oe_state != OES_CACHE) ||
 			    (!list_empty(&ext->oe_link) &&
-			     ext->oe_owner != NULL))
+			     ext->oe_owner))
 				continue;
 
 			if (!try_to_add_extent_for_io(cli, ext, rpclist,
@@ -1918,10 +1916,10 @@ static int get_write_extents(struct osc_object *obj, struct list_head *rpclist)
 		return page_count;
 
 	ext = first_extent(obj);
-	while (ext != NULL) {
+	while (ext) {
 		if ((ext->oe_state != OES_CACHE) ||
 		    /* this extent may be already in current rpclist */
-		    (!list_empty(&ext->oe_link) && ext->oe_owner != NULL)) {
+		    (!list_empty(&ext->oe_link) && ext->oe_owner)) {
 			ext = next_extent(ext);
 			continue;
 		}
@@ -1980,7 +1978,7 @@ osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
 				continue;
 			}
 		}
-		if (first == NULL) {
+		if (!first) {
 			first = ext;
 			srvlock = ext->oe_srvlock;
 		} else {
@@ -2074,7 +2072,7 @@ static struct osc_object *osc_next_obj(struct client_obd *cli)
 
 	/* then return all queued objects when we have an invalid import
 	 * so that they get flushed */
-	if (cli->cl_import == NULL || cli->cl_import->imp_invalid) {
+	if (!cli->cl_import || cli->cl_import->imp_invalid) {
 		if (!list_empty(&cli->cl_loi_write_list))
 			return list_to_obj(&cli->cl_loi_write_list, write_item);
 		if (!list_empty(&cli->cl_loi_read_list))
@@ -2158,7 +2156,7 @@ static int osc_io_unplug0(const struct lu_env *env, struct client_obd *cli,
 {
 	int rc = 0;
 
-	if (osc != NULL && osc_list_maint(cli, osc) == 0)
+	if (osc && osc_list_maint(cli, osc) == 0)
 		return 0;
 
 	if (!async) {
@@ -2171,7 +2169,7 @@ static int osc_io_unplug0(const struct lu_env *env, struct client_obd *cli,
 		atomic_dec(&cli->cl_lru_shrinkers);
 	} else {
 		CDEBUG(D_CACHE, "Queue writeback work for client %p.\n", cli);
-		LASSERT(cli->cl_writeback_work != NULL);
+		LASSERT(cli->cl_writeback_work);
 		rc = ptlrpcd_queue_work(cli->cl_writeback_work);
 	}
 	return rc;
@@ -2236,7 +2234,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	if (oap->oap_magic != OAP_MAGIC)
 		return -EINVAL;
 
-	if (cli->cl_import == NULL || cli->cl_import->imp_invalid)
+	if (!cli->cl_import || cli->cl_import->imp_invalid)
 		return -EIO;
 
 	if (!list_empty(&oap->oap_pending_item) ||
@@ -2290,7 +2288,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	 * 2. otherwise, a new extent will be allocated. */
 
 	ext = oio->oi_active;
-	if (ext != NULL && ext->oe_start <= index && ext->oe_max_end >= index) {
+	if (ext && ext->oe_start <= index && ext->oe_max_end >= index) {
 		/* one chunk plus extent overhead must be enough to write this
 		 * page */
 		grants = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
@@ -2319,7 +2317,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 			}
 		}
 		rc = 0;
-	} else if (ext != NULL) {
+	} else if (ext) {
 		/* index is located outside of active extent */
 		need_release = 1;
 	}
@@ -2329,11 +2327,11 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		ext = NULL;
 	}
 
-	if (ext == NULL) {
+	if (!ext) {
 		int tmp = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
 
 		/* try to find new extent to cover this page */
-		LASSERT(oio->oi_active == NULL);
+		LASSERT(!oio->oi_active);
 		/* we may have allocated grant for this page if we failed
 		 * to expand the previous active extent. */
 		LASSERT(ergo(grants > 0, grants >= tmp));
@@ -2362,8 +2360,8 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 			osc_unreserve_grant(cli, grants, tmp);
 	}
 
-	LASSERT(ergo(rc == 0, ext != NULL));
-	if (ext != NULL) {
+	LASSERT(ergo(rc == 0, ext));
+	if (ext) {
 		EASSERTF(ext->oe_end >= index && ext->oe_start <= index,
 			 ext, "index = %lu.\n", index);
 		LASSERT((oap->oap_brw_flags & OBD_BRW_FROM_GRANT) != 0);
@@ -2401,14 +2399,14 @@ int osc_teardown_async_page(const struct lu_env *env,
 		/* only truncated pages are allowed to be taken out.
 		 * See osc_extent_truncate() and osc_cache_truncate_start()
 		 * for details. */
-		if (ext != NULL && ext->oe_state != OES_TRUNC) {
+		if (ext && ext->oe_state != OES_TRUNC) {
 			OSC_EXTENT_DUMP(D_ERROR, ext, "trunc at %lu.\n",
 					oap2cl_page(oap)->cp_index);
 			rc = -EBUSY;
 		}
 	}
 	osc_object_unlock(obj);
-	if (ext != NULL)
+	if (ext)
 		osc_extent_put(env, ext);
 	return rc;
 }
@@ -2433,7 +2431,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 
 	osc_object_lock(obj);
 	ext = osc_extent_lookup(obj, index);
-	if (ext == NULL) {
+	if (!ext) {
 		osc_extent_tree_dump(D_ERROR, obj);
 		LASSERTF(0, "page index %lu is NOT covered.\n", index);
 	}
@@ -2535,7 +2533,7 @@ int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops)
 			break;
 		}
 	}
-	if (found != NULL) {
+	if (found) {
 		list_del_init(&found->oe_link);
 		osc_update_pending(obj, cmd, -found->oe_nr_pages);
 		osc_object_unlock(obj);
@@ -2547,7 +2545,7 @@ int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops)
 		osc_object_unlock(obj);
 		/* ok, it's been put in an rpc. only one oap gets a request
 		 * reference */
-		if (oap->oap_request != NULL) {
+		if (oap->oap_request) {
 			ptlrpc_mark_interrupted(oap->oap_request);
 			ptlrpcd_wake(oap->oap_request);
 			ptlrpc_req_finished(oap->oap_request);
@@ -2582,7 +2580,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 	}
 
 	ext = osc_extent_alloc(obj);
-	if (ext == NULL) {
+	if (!ext) {
 		list_for_each_entry_safe(oap, tmp, list, oap_pending_item) {
 			list_del_init(&oap->oap_pending_item);
 			osc_ap_completion(env, cli, oap, 0, -ENOMEM);
@@ -2637,11 +2635,11 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_io *oio,
 again:
 	osc_object_lock(obj);
 	ext = osc_extent_search(obj, index);
-	if (ext == NULL)
+	if (!ext)
 		ext = first_extent(obj);
 	else if (ext->oe_end < index)
 		ext = next_extent(ext);
-	while (ext != NULL) {
+	while (ext) {
 		EASSERT(ext->oe_state != OES_TRUNC, ext);
 
 		if (ext->oe_state > OES_CACHE || ext->oe_urgent) {
@@ -2714,14 +2712,14 @@ again:
 			/* we need to hold this extent in OES_TRUNC state so
 			 * that no writeback will happen. This is to avoid
 			 * BUG 17397. */
-			LASSERT(oio->oi_trunc == NULL);
+			LASSERT(!oio->oi_trunc);
 			oio->oi_trunc = osc_extent_get(ext);
 			OSC_EXTENT_DUMP(D_CACHE, ext,
 					"trunc at %llu\n", size);
 		}
 		osc_extent_put(env, ext);
 	}
-	if (waiting != NULL) {
+	if (waiting) {
 		int rc;
 
 		/* ignore the result of osc_extent_wait the write initiator
@@ -2746,7 +2744,7 @@ void osc_cache_truncate_end(const struct lu_env *env, struct osc_io *oio,
 	struct osc_extent *ext = oio->oi_trunc;
 
 	oio->oi_trunc = NULL;
-	if (ext != NULL) {
+	if (ext) {
 		bool unplug = false;
 
 		EASSERT(ext->oe_nr_pages > 0, ext);
@@ -2789,11 +2787,11 @@ int osc_cache_wait_range(const struct lu_env *env, struct osc_object *obj,
 again:
 	osc_object_lock(obj);
 	ext = osc_extent_search(obj, index);
-	if (ext == NULL)
+	if (!ext)
 		ext = first_extent(obj);
 	else if (ext->oe_end < index)
 		ext = next_extent(ext);
-	while (ext != NULL) {
+	while (ext) {
 		int rc;
 
 		if (ext->oe_start > end)
@@ -2844,11 +2842,11 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 
 	osc_object_lock(obj);
 	ext = osc_extent_search(obj, start);
-	if (ext == NULL)
+	if (!ext)
 		ext = first_extent(obj);
 	else if (ext->oe_end < start)
 		ext = next_extent(ext);
-	while (ext != NULL) {
+	while (ext) {
 		if (ext->oe_start > end)
 			break;
 
@@ -2867,7 +2865,7 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 					ext->oe_urgent = 1;
 					list = &obj->oo_urgent_exts;
 				}
-				if (list != NULL)
+				if (list)
 					list_move_tail(&ext->oe_link, list);
 				unplug = true;
 			} else {
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 415c27e..73d43ab 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -472,7 +472,7 @@ static inline struct osc_thread_info *osc_env_info(const struct lu_env *env)
 	struct osc_thread_info *info;
 
 	info = lu_context_key_get(&env->le_ctx, &osc_key);
-	LASSERT(info != NULL);
+	LASSERT(info);
 	return info;
 }
 
@@ -481,7 +481,7 @@ static inline struct osc_session *osc_env_session(const struct lu_env *env)
 	struct osc_session *ses;
 
 	ses = lu_context_key_get(env->le_ses, &osc_session_key);
-	LASSERT(ses != NULL);
+	LASSERT(ses);
 	return ses;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
index 7078cc5..67cb6e4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_dev.c
+++ b/drivers/staging/lustre/lustre/osc/osc_dev.c
@@ -123,7 +123,7 @@ static void *osc_key_init(const struct lu_context *ctx,
 	struct osc_thread_info *info;
 
 	info = kmem_cache_alloc(osc_thread_kmem, GFP_NOFS | __GFP_ZERO);
-	if (info == NULL)
+	if (!info)
 		info = ERR_PTR(-ENOMEM);
 	return info;
 }
@@ -148,7 +148,7 @@ static void *osc_session_init(const struct lu_context *ctx,
 	struct osc_session *info;
 
 	info = kmem_cache_alloc(osc_session_kmem, GFP_NOFS | __GFP_ZERO);
-	if (info == NULL)
+	if (!info)
 		info = ERR_PTR(-ENOMEM);
 	return info;
 }
@@ -228,7 +228,7 @@ static struct lu_device *osc_device_alloc(const struct lu_env *env,
 
 	/* Setup OSC OBD */
 	obd = class_name2obd(lustre_cfg_string(cfg, 0));
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 	rc = osc_setup(obd, cfg);
 	if (rc) {
 		osc_device_free(env, d);
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index abd0beb..9dfcc26 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -73,7 +73,7 @@ static struct osc_page *osc_cl_page_osc(struct cl_page *page)
 	const struct cl_page_slice *slice;
 
 	slice = cl_page_at(page, &osc_device_type);
-	LASSERT(slice != NULL);
+	LASSERT(slice);
 
 	return cl2osc_page(slice);
 }
@@ -135,7 +135,7 @@ static int osc_io_submit(const struct lu_env *env,
 
 		/* Top level IO. */
 		io = page->cp_owner;
-		LASSERT(io != NULL);
+		LASSERT(io);
 
 		opg = osc_cl_page_osc(page);
 		oap = &opg->ops_oap;
@@ -266,7 +266,7 @@ static int osc_io_prepare_write(const struct lu_env *env,
 	 * This implements OBD_BRW_CHECK logic from old client.
 	 */
 
-	if (imp == NULL || imp->imp_invalid)
+	if (!imp || imp->imp_invalid)
 		result = -EIO;
 	if (result == 0 && oio->oi_lockless)
 		/* this page contains `invalid' data, but who cares?
@@ -349,7 +349,7 @@ static int trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 	__u64 start = *(__u64 *)cbdata;
 
 	slice = cl_page_at(page, &osc_device_type);
-	LASSERT(slice != NULL);
+	LASSERT(slice);
 	ops = cl2osc_page(slice);
 	oap = &ops->ops_oap;
 
@@ -500,7 +500,7 @@ static void osc_io_setattr_end(const struct lu_env *env,
 		__u64 size = io->u.ci_setattr.sa_attr.lvb_size;
 
 		osc_trunc_check(env, io, oio, size);
-		if (oio->oi_trunc != NULL) {
+		if (oio->oi_trunc) {
 			osc_cache_truncate_end(env, oio, cl2osc(obj));
 			oio->oi_trunc = NULL;
 		}
@@ -754,7 +754,7 @@ static void osc_req_attr_set(const struct lu_env *env,
 		opg = osc_cl_page_osc(apage);
 		apage = opg->ops_cl.cpl_page; /* now apage is a sub-page */
 		lock = cl_lock_at_page(env, apage->cp_obj, apage, NULL, 1, 1);
-		if (lock == NULL) {
+		if (!lock) {
 			struct cl_object_header *head;
 			struct cl_lock *scan;
 
@@ -770,10 +770,9 @@ static void osc_req_attr_set(const struct lu_env *env,
 		}
 
 		olck = osc_lock_at(lock);
-		LASSERT(olck != NULL);
-		LASSERT(ergo(opg->ops_srvlock, olck->ols_lock == NULL));
+		LASSERT(ergo(opg->ops_srvlock, !olck->ols_lock));
 		/* check for lockless io. */
-		if (olck->ols_lock != NULL) {
+		if (olck->ols_lock) {
 			oa->o_handle = olck->ols_lock->l_remote_handle;
 			oa->o_valid |= OBD_MD_FLHANDLE;
 		}
@@ -804,7 +803,7 @@ int osc_req_init(const struct lu_env *env, struct cl_device *dev,
 	int result;
 
 	or = kmem_cache_alloc(osc_req_kmem, GFP_NOFS | __GFP_ZERO);
-	if (or != NULL) {
+	if (or) {
 		cl_req_slice_add(req, &or->or_cl, dev, &osc_req_ops);
 		result = 0;
 	} else
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 71f2810..cc9d7ea 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -79,7 +79,7 @@ static struct ldlm_lock *osc_handle_ptr(struct lustre_handle *handle)
 	struct ldlm_lock *lock;
 
 	lock = ldlm_handle2lock(handle);
-	if (lock != NULL)
+	if (lock)
 		LDLM_LOCK_PUT(lock);
 	return lock;
 }
@@ -94,42 +94,40 @@ static int osc_lock_invariant(struct osc_lock *ols)
 	int handle_used = lustre_handle_is_used(&ols->ols_handle);
 
 	if (ergo(osc_lock_is_lockless(ols),
-		 ols->ols_locklessable && ols->ols_lock == NULL))
+		 ols->ols_locklessable && !ols->ols_lock))
 		return 1;
 
 	/*
 	 * If all the following "ergo"s are true, return 1, otherwise 0
 	 */
-	if (!ergo(olock != NULL, handle_used))
+	if (!ergo(olock, handle_used))
 		return 0;
 
-	if (!ergo(olock != NULL,
-		   olock->l_handle.h_cookie == ols->ols_handle.cookie))
+	if (!ergo(olock, olock->l_handle.h_cookie == ols->ols_handle.cookie))
 		return 0;
 
 	if (!ergo(handle_used,
-		   ergo(lock != NULL && olock != NULL, lock == olock) &&
-		   ergo(lock == NULL, olock == NULL)))
+		  ergo(lock && olock, lock == olock) &&
+		  ergo(!lock, !olock)))
 		return 0;
 	/*
 	 * Check that ->ols_handle and ->ols_lock are consistent, but
 	 * take into account that they are set at the different time.
 	 */
 	if (!ergo(ols->ols_state == OLS_CANCELLED,
-		   olock == NULL && !handle_used))
+		  !olock && !handle_used))
 		return 0;
 	/*
 	 * DLM lock is destroyed only after we have seen cancellation
 	 * ast.
 	 */
-	if (!ergo(olock != NULL && ols->ols_state < OLS_CANCELLED,
-		   ((olock->l_flags & LDLM_FL_DESTROYED) == 0)))
+	if (!ergo(olock && ols->ols_state < OLS_CANCELLED,
+		  ((olock->l_flags & LDLM_FL_DESTROYED) == 0)))
 		return 0;
 
 	if (!ergo(ols->ols_state == OLS_GRANTED,
-		   olock != NULL &&
-		   olock->l_req_mode == olock->l_granted_mode &&
-		   ols->ols_hold))
+		  olock && olock->l_req_mode == olock->l_granted_mode &&
+		  ols->ols_hold))
 		return 0;
 	return 1;
 }
@@ -149,7 +147,7 @@ static void osc_lock_detach(const struct lu_env *env, struct osc_lock *olck)
 
 	spin_lock(&osc_ast_guard);
 	dlmlock = olck->ols_lock;
-	if (dlmlock == NULL) {
+	if (!dlmlock) {
 		spin_unlock(&osc_ast_guard);
 		return;
 	}
@@ -247,7 +245,7 @@ static void osc_lock_fini(const struct lu_env *env,
 	 * lock is destroyed immediately after upcall.
 	 */
 	osc_lock_unhold(ols);
-	LASSERT(ols->ols_lock == NULL);
+	LASSERT(!ols->ols_lock);
 	LASSERT(atomic_read(&ols->ols_pageref) == 0 ||
 		atomic_read(&ols->ols_pageref) == _PAGEREF_MAGIC);
 
@@ -292,7 +290,7 @@ static struct osc_lock *osc_ast_data_get(struct ldlm_lock *dlm_lock)
 	lock_res_and_lock(dlm_lock);
 	spin_lock(&osc_ast_guard);
 	olck = dlm_lock->l_ast_data;
-	if (olck != NULL) {
+	if (olck) {
 		struct cl_lock *lock = olck->ols_cl.cls_lock;
 		/*
 		 * If osc_lock holds a reference on ldlm lock, return it even
@@ -359,7 +357,6 @@ static void osc_lock_lvb_update(const struct lu_env *env, struct osc_lock *olck,
 		__u64 size;
 
 		dlmlock = olck->ols_lock;
-		LASSERT(dlmlock != NULL);
 
 		/* re-grab LVB from a dlm lock under DLM spin-locks. */
 		*lvb = *(struct ost_lvb *)dlmlock->l_lvb_data;
@@ -444,12 +441,12 @@ static void osc_lock_upcall0(const struct lu_env *env, struct osc_lock *olck)
 	struct ldlm_lock *dlmlock;
 
 	dlmlock = ldlm_handle2lock_long(&olck->ols_handle, 0);
-	LASSERT(dlmlock != NULL);
+	LASSERT(dlmlock);
 
 	lock_res_and_lock(dlmlock);
 	spin_lock(&osc_ast_guard);
 	LASSERT(dlmlock->l_ast_data == olck);
-	LASSERT(olck->ols_lock == NULL);
+	LASSERT(!olck->ols_lock);
 	olck->ols_lock = dlmlock;
 	spin_unlock(&osc_ast_guard);
 
@@ -508,10 +505,10 @@ static int osc_lock_upcall(void *cookie, int errcode)
 			struct ldlm_lock *dlmlock;
 
 			dlmlock = ldlm_handle2lock(&olck->ols_handle);
-			if (dlmlock != NULL) {
+			if (dlmlock) {
 				lock_res_and_lock(dlmlock);
 				spin_lock(&osc_ast_guard);
-				LASSERT(olck->ols_lock == NULL);
+				LASSERT(!olck->ols_lock);
 				dlmlock->l_ast_data = NULL;
 				olck->ols_handle.cookie = 0ULL;
 				spin_unlock(&osc_ast_guard);
@@ -634,7 +631,7 @@ static int osc_dlm_blocking_ast0(const struct lu_env *env,
 
 	cancel = 0;
 	olck = osc_ast_data_get(dlmlock);
-	if (olck != NULL) {
+	if (olck) {
 		lock = olck->ols_cl.cls_lock;
 		cl_lock_mutex_get(env, lock);
 		LINVRNT(osc_lock_invariant(olck));
@@ -786,17 +783,17 @@ static int osc_ldlm_completion_ast(struct ldlm_lock *dlmlock,
 	env = cl_env_nested_get(&nest);
 	if (!IS_ERR(env)) {
 		olck = osc_ast_data_get(dlmlock);
-		if (olck != NULL) {
+		if (olck) {
 			lock = olck->ols_cl.cls_lock;
 			cl_lock_mutex_get(env, lock);
 			/*
 			 * ldlm_handle_cp_callback() copied LVB from request
 			 * to lock->l_lvb_data, store it in osc_lock.
 			 */
-			LASSERT(dlmlock->l_lvb_data != NULL);
+			LASSERT(dlmlock->l_lvb_data);
 			lock_res_and_lock(dlmlock);
 			olck->ols_lvb = *(struct ost_lvb *)dlmlock->l_lvb_data;
-			if (olck->ols_lock == NULL) {
+			if (!olck->ols_lock) {
 				/*
 				 * upcall (osc_lock_upcall()) hasn't yet been
 				 * called. Do nothing now, upcall will bind
@@ -850,7 +847,7 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 		 * environment.
 		 */
 		olck = osc_ast_data_get(dlmlock);
-		if (olck != NULL) {
+		if (olck) {
 			lock = olck->ols_cl.cls_lock;
 			/* Do not grab the mutex of cl_lock for glimpse.
 			 * See LU-1274 for details.
@@ -1074,7 +1071,7 @@ static int osc_lock_enqueue_wait(const struct lu_env *env,
 		} else {
 			CDEBUG(D_DLMTRACE, "lock %p is conflicted with %p, will wait\n",
 			       lock, conflict);
-			LASSERT(lock->cll_conflict == NULL);
+			LASSERT(!lock->cll_conflict);
 			lu_ref_add(&conflict->cll_reference, "cancel-wait",
 				   lock);
 			lock->cll_conflict = conflict;
@@ -1197,7 +1194,7 @@ static int osc_lock_wait(const struct lu_env *env,
 	}
 
 	LASSERT(equi(olck->ols_state >= OLS_UPCALL_RECEIVED &&
-		     lock->cll_error == 0, olck->ols_lock != NULL));
+		     lock->cll_error == 0, olck->ols_lock));
 
 	return lock->cll_error ?: olck->ols_state >= OLS_GRANTED ? 0 : CLO_WAIT;
 }
@@ -1306,7 +1303,7 @@ static void osc_lock_cancel(const struct lu_env *env,
 	LASSERT(cl_lock_is_mutexed(lock));
 	LINVRNT(osc_lock_invariant(olck));
 
-	if (dlmlock != NULL) {
+	if (dlmlock) {
 		int do_cancel;
 
 		discard = !!(dlmlock->l_flags & LDLM_FL_DISCARD_DATA);
@@ -1382,7 +1379,7 @@ static void osc_lock_state(const struct lu_env *env,
 	if (state == CLS_HELD && slice->cls_lock->cll_state != CLS_HELD) {
 		struct osc_io *oio = osc_env_io(env);
 
-		LASSERT(lock->ols_owner == NULL);
+		LASSERT(!lock->ols_owner);
 		lock->ols_owner = oio;
 	} else if (state != CLS_HELD)
 		lock->ols_owner = NULL;
@@ -1556,7 +1553,7 @@ int osc_lock_init(const struct lu_env *env,
 	int result;
 
 	clk = kmem_cache_alloc(osc_lock_kmem, GFP_NOFS | __GFP_ZERO);
-	if (clk != NULL) {
+	if (clk) {
 		__u32 enqflags = lock->cll_descr.cld_enq_flags;
 
 		osc_lock_build_einfo(env, lock, clk, &clk->ols_einfo);
@@ -1599,7 +1596,7 @@ int osc_dlm_lock_pageref(struct ldlm_lock *dlm)
 	 * doesn't matter because in the worst case we don't cancel a lock
 	 * which we actually can, that's no harm.
 	 */
-	if (olock != NULL &&
+	if (olock &&
 	    atomic_add_return(_PAGEREF_MAGIC,
 				  &olock->ols_pageref) != _PAGEREF_MAGIC) {
 		atomic_sub(_PAGEREF_MAGIC, &olock->ols_pageref);
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index fdd6219..60d8230 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -113,7 +113,7 @@ static void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 	LASSERT(list_empty(&osc->oo_write_item));
 	LASSERT(list_empty(&osc->oo_read_item));
 
-	LASSERT(osc->oo_root.rb_node == NULL);
+	LASSERT(!osc->oo_root.rb_node);
 	LASSERT(list_empty(&osc->oo_hp_exts));
 	LASSERT(list_empty(&osc->oo_urgent_exts));
 	LASSERT(list_empty(&osc->oo_rpc_exts));
@@ -256,7 +256,7 @@ struct lu_object *osc_object_alloc(const struct lu_env *env,
 	struct lu_object *obj;
 
 	osc = kmem_cache_alloc(osc_object_kmem, GFP_NOFS | __GFP_ZERO);
-	if (osc != NULL) {
+	if (osc) {
 		obj = osc2lu(osc);
 		lu_object_init(obj, NULL, dev);
 		osc->oo_cl.co_ops = &osc_ops;
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 99d5b56..5cb0ccc 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -69,7 +69,7 @@ static void osc_page_fini(const struct lu_env *env,
 	struct osc_page *opg = cl2osc_page(slice);
 
 	CDEBUG(D_TRACE, "%p\n", opg);
-	LASSERT(opg->ops_lock == NULL);
+	LASSERT(!opg->ops_lock);
 }
 
 static void osc_page_transfer_get(struct osc_page *opg, const char *label)
@@ -135,7 +135,7 @@ static int osc_page_cache_add(const struct lu_env *env,
 	 * osc_io_end() is called, so release it earlier.
 	 * for mkwrite(), it's known there is no further pages. */
 	if (cl_io_is_sync_write(io) || cl_io_is_mkwrite(io)) {
-		if (oio->oi_active != NULL) {
+		if (oio->oi_active) {
 			osc_extent_release(env, oio->oi_active);
 			oio->oi_active = NULL;
 		}
@@ -159,7 +159,7 @@ static int osc_page_addref_lock(const struct lu_env *env,
 	struct osc_lock *olock;
 	int rc;
 
-	LASSERT(opg->ops_lock == NULL);
+	LASSERT(!opg->ops_lock);
 
 	olock = osc_lock_at(lock);
 	if (atomic_inc_return(&olock->ols_pageref) <= 0) {
@@ -179,7 +179,7 @@ static void osc_page_putref_lock(const struct lu_env *env,
 	struct cl_lock *lock = opg->ops_lock;
 	struct osc_lock *olock;
 
-	LASSERT(lock != NULL);
+	LASSERT(lock);
 	olock = osc_lock_at(lock);
 
 	atomic_dec(&olock->ols_pageref);
@@ -197,7 +197,7 @@ static int osc_page_is_under_lock(const struct lu_env *env,
 
 	lock = cl_lock_at_page(env, slice->cpl_obj, slice->cpl_page,
 			       NULL, 1, 0);
-	if (lock != NULL) {
+	if (lock) {
 		if (osc_page_addref_lock(env, cl2osc_page(slice), lock) == 0)
 			result = -EBUSY;
 		cl_lock_put(env, lock);
@@ -325,7 +325,7 @@ static void osc_page_delete(const struct lu_env *env,
 	}
 
 	spin_lock(&obj->oo_seatbelt);
-	if (opg->ops_submitter != NULL) {
+	if (opg->ops_submitter) {
 		LASSERT(!list_empty(&opg->ops_inflight));
 		list_del_init(&opg->ops_inflight);
 		opg->ops_submitter = NULL;
@@ -589,14 +589,14 @@ int osc_lru_shrink(struct client_obd *cli, int target)
 			continue;
 		}
 
-		LASSERT(page->cp_obj != NULL);
+		LASSERT(page->cp_obj);
 		if (clobj != page->cp_obj) {
 			struct cl_object *tmp = page->cp_obj;
 
 			cl_object_get(tmp);
 			client_obd_list_unlock(&cli->cl_lru_list_lock);
 
-			if (clobj != NULL) {
+			if (clobj) {
 				count -= discard_pagevec(env, io, pvec, index);
 				index = 0;
 
@@ -641,7 +641,7 @@ int osc_lru_shrink(struct client_obd *cli, int target)
 	}
 	client_obd_list_unlock(&cli->cl_lru_list_lock);
 
-	if (clobj != NULL) {
+	if (clobj) {
 		count -= discard_pagevec(env, io, pvec, index);
 
 		cl_io_fini(env, io);
@@ -720,7 +720,7 @@ static int osc_lru_reclaim(struct client_obd *cli)
 	int max_scans;
 	int rc;
 
-	LASSERT(cache != NULL);
+	LASSERT(cache);
 
 	rc = osc_lru_shrink(cli, lru_shrink_min);
 	if (rc != 0) {
@@ -776,7 +776,7 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 	struct client_obd *cli = osc_cli(obj);
 	int rc = 0;
 
-	if (cli->cl_cache == NULL) /* shall not be in LRU */
+	if (!cli->cl_cache) /* shall not be in LRU */
 		return 0;
 
 	LASSERT(atomic_read(cli->cl_lru_left) >= 0);
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index e70e796..d6731c5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -36,7 +36,7 @@ static inline struct osc_quota_info *osc_oqi_alloc(u32 id)
 	struct osc_quota_info *oqi;
 
 	oqi = kmem_cache_alloc(osc_quota_kmem, GFP_NOFS | __GFP_ZERO);
-	if (oqi != NULL)
+	if (oqi)
 		oqi->oqi_id = id;
 
 	return oqi;
@@ -90,11 +90,11 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 		if ((flags & FL_QUOTA_FLAG(type)) != 0) {
 			/* This ID is getting close to its quota limit, let's
 			 * switch to sync I/O */
-			if (oqi != NULL)
+			if (oqi)
 				continue;
 
 			oqi = osc_oqi_alloc(qid[type]);
-			if (oqi == NULL) {
+			if (!oqi) {
 				rc = -ENOMEM;
 				break;
 			}
@@ -114,7 +114,7 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 		} else {
 			/* This ID is now off the hook, let's remove it from
 			 * the hash table */
-			if (oqi == NULL)
+			if (!oqi)
 				continue;
 
 			oqi = cfs_hash_del_key(cli->cl_quota_hash[type],
@@ -147,7 +147,7 @@ oqi_keycmp(const void *key, struct hlist_node *hnode)
 	struct osc_quota_info *oqi;
 	u32 uid;
 
-	LASSERT(key != NULL);
+	LASSERT(key);
 	uid = *((u32 *)key);
 	oqi = hlist_entry(hnode, struct osc_quota_info, oqi_hash);
 
@@ -218,7 +218,7 @@ int osc_quota_setup(struct obd_device *obd)
 							   CFS_HASH_MAX_THETA,
 							   &quota_hash_ops,
 							   CFS_HASH_DEFAULT);
-		if (cli->cl_quota_hash[type] == NULL)
+		if (!cli->cl_quota_hash[type])
 			break;
 	}
 
@@ -252,7 +252,7 @@ int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_OST_QUOTACTL, LUSTRE_OST_VERSION,
 					OST_QUOTACTL);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	oqc = req_capsule_client_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
@@ -294,7 +294,7 @@ int osc_quotacheck(struct obd_device *unused, struct obd_export *exp,
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_OST_QUOTACHECK, LUSTRE_OST_VERSION,
 					OST_QUOTACHECK);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 3ae00fc..23a11c4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -113,18 +113,18 @@ static int osc_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 	int lmm_size;
 
 	lmm_size = sizeof(**lmmp);
-	if (lmmp == NULL)
+	if (!lmmp)
 		return lmm_size;
 
-	if (*lmmp != NULL && lsm == NULL) {
+	if (*lmmp && !lsm) {
 		kfree(*lmmp);
 		*lmmp = NULL;
 		return 0;
-	} else if (unlikely(lsm != NULL && ostid_id(&lsm->lsm_oi) == 0)) {
+	} else if (unlikely(lsm && ostid_id(&lsm->lsm_oi) == 0)) {
 		return -EBADF;
 	}
 
-	if (*lmmp == NULL) {
+	if (!*lmmp) {
 		*lmmp = kzalloc(lmm_size, GFP_NOFS);
 		if (!*lmmp)
 			return -ENOMEM;
@@ -143,7 +143,7 @@ static int osc_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 	int lsm_size;
 	struct obd_import *imp = class_exp2cliimp(exp);
 
-	if (lmm != NULL) {
+	if (lmm) {
 		if (lmm_bytes < sizeof(*lmm)) {
 			CERROR("%s: lov_mds_md too small: %d, need %d\n",
 			       exp->exp_obd->obd_name, lmm_bytes,
@@ -160,23 +160,23 @@ static int osc_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 	}
 
 	lsm_size = lov_stripe_md_size(1);
-	if (lsmp == NULL)
+	if (!lsmp)
 		return lsm_size;
 
-	if (*lsmp != NULL && lmm == NULL) {
+	if (*lsmp && !lmm) {
 		kfree((*lsmp)->lsm_oinfo[0]);
 		kfree(*lsmp);
 		*lsmp = NULL;
 		return 0;
 	}
 
-	if (*lsmp == NULL) {
+	if (!*lsmp) {
 		*lsmp = kzalloc(lsm_size, GFP_NOFS);
-		if (unlikely(*lsmp == NULL))
+		if (unlikely(!*lsmp))
 			return -ENOMEM;
 		(*lsmp)->lsm_oinfo[0] = kzalloc(sizeof(struct lov_oinfo),
 						GFP_NOFS);
-		if (unlikely((*lsmp)->lsm_oinfo[0] == NULL)) {
+		if (unlikely(!(*lsmp)->lsm_oinfo[0])) {
 			kfree(*lsmp);
 			return -ENOMEM;
 		}
@@ -185,11 +185,11 @@ static int osc_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 		return -EBADF;
 	}
 
-	if (lmm != NULL)
+	if (lmm)
 		/* XXX zero *lsmp? */
 		ostid_le_to_cpu(&lmm->lmm_oi, &(*lsmp)->lsm_oi);
 
-	if (imp != NULL &&
+	if (imp &&
 	    (imp->imp_connect_data.ocd_connect_flags & OBD_CONNECT_MAXBYTES))
 		(*lsmp)->lsm_maxbytes = imp->imp_connect_data.ocd_maxbytes;
 	else
@@ -246,7 +246,7 @@ static int osc_getattr_async(struct obd_export *exp, struct obd_info *oinfo,
 	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_GETATTR);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_GETATTR);
@@ -276,7 +276,7 @@ static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_GETATTR);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_GETATTR);
@@ -294,7 +294,7 @@ static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 		goto out;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -321,7 +321,7 @@ static int osc_setattr(const struct lu_env *env, struct obd_export *exp,
 	LASSERT(oinfo->oi_oa->o_valid & OBD_MD_FLGROUP);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_SETATTR);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_SETATTR);
@@ -339,7 +339,7 @@ static int osc_setattr(const struct lu_env *env, struct obd_export *exp,
 		goto out;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -362,7 +362,7 @@ static int osc_setattr_interpret(const struct lu_env *env,
 		goto out;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -384,7 +384,7 @@ int osc_setattr_async_base(struct obd_export *exp, struct obd_info *oinfo,
 	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_SETATTR);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_SETATTR);
@@ -451,7 +451,7 @@ static int osc_real_create(struct obd_export *exp, struct obdo *oa,
 	}
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_CREATE);
-	if (req == NULL) {
+	if (!req) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -482,7 +482,7 @@ static int osc_real_create(struct obd_export *exp, struct obdo *oa,
 		goto out_req;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EPROTO;
 		goto out_req;
 	}
@@ -500,7 +500,7 @@ static int osc_real_create(struct obd_export *exp, struct obdo *oa,
 	lsm->lsm_oi = oa->o_oi;
 	*ea = lsm;
 
-	if (oti != NULL) {
+	if (oti) {
 		oti->oti_transno = lustre_msg_get_transno(req->rq_repmsg);
 
 		if (oa->o_valid & OBD_MD_FLCOOKIE) {
@@ -530,7 +530,7 @@ int osc_punch_base(struct obd_export *exp, struct obd_info *oinfo,
 	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_PUNCH);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_PUNCH);
@@ -573,7 +573,7 @@ static int osc_sync_interpret(const struct lu_env *env,
 		goto out;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
-	if (body == NULL) {
+	if (!body) {
 		CERROR("can't unpack ost_body\n");
 		rc = -EPROTO;
 		goto out;
@@ -595,7 +595,7 @@ int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
 	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_SYNC);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_SYNC);
@@ -650,7 +650,7 @@ static int osc_resource_get_unused(struct obd_export *exp, struct obdo *oa,
 
 	ostid_build_res_name(&oa->o_oi, &res_id);
 	res = ldlm_resource_get(ns, NULL, &res_id, 0, 0);
-	if (res == NULL)
+	if (!res)
 		return 0;
 
 	LDLM_RESOURCE_ADDREF(res);
@@ -743,7 +743,7 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 					LDLM_FL_DISCARD_DATA);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_DESTROY);
-	if (req == NULL) {
+	if (!req) {
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return -ENOMEM;
 	}
@@ -758,7 +758,7 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 	req->rq_request_portal = OST_IO_PORTAL; /* bug 7198 */
 	ptlrpc_at_set_req_timeout(req);
 
-	if (oti != NULL && oa->o_valid & OBD_MD_FLCOOKIE)
+	if (oti && oa->o_valid & OBD_MD_FLCOOKIE)
 		oa->o_lcookie = *oti->oti_logcookies;
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
 	LASSERT(body);
@@ -1106,7 +1106,7 @@ static int check_write_rcs(struct ptlrpc_request *req,
 	remote_rcs = req_capsule_server_sized_get(&req->rq_pill, &RMF_RCS,
 						  sizeof(*remote_rcs) *
 						  niocount);
-	if (remote_rcs == NULL) {
+	if (!remote_rcs) {
 		CDEBUG(D_INFO, "Missing/short RC vector on BRW_WRITE reply\n");
 		return -EPROTO;
 	}
@@ -1244,7 +1244,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		opc = OST_READ;
 		req = ptlrpc_request_alloc(cli->cl_import, &RQF_OST_BRW_READ);
 	}
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	for (niocount = i = 1; i < page_count; i++) {
@@ -1274,7 +1274,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		opc == OST_WRITE ? BULK_GET_SOURCE : BULK_PUT_SINK,
 		OST_BULK_PORTAL);
 
-	if (desc == NULL) {
+	if (!desc) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1283,7 +1283,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	body = req_capsule_client_get(pill, &RMF_OST_BODY);
 	ioobj = req_capsule_client_get(pill, &RMF_OBD_IOOBJ);
 	niobuf = req_capsule_client_get(pill, &RMF_NIOBUF_REMOTE);
-	LASSERT(body != NULL && ioobj != NULL && niobuf != NULL);
+	LASSERT(body && ioobj && niobuf);
 
 	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa, oa);
 
@@ -1472,9 +1472,9 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		return rc;
 	}
 
-	LASSERTF(req->rq_repmsg != NULL, "rc = %d\n", rc);
+	LASSERTF(req->rq_repmsg, "rc = %d\n", rc);
 	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
-	if (body == NULL) {
+	if (!body) {
 		DEBUG_REQ(D_INFO, req, "Can't unpack body\n");
 		return -EPROTO;
 	}
@@ -1627,7 +1627,7 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 		return rc;
 
 	list_for_each_entry(oap, &aa->aa_oaps, oap_rpc_item) {
-		if (oap->oap_request != NULL) {
+		if (oap->oap_request) {
 			LASSERTF(request == oap->oap_request,
 				 "request %p != oap_request %p\n",
 				 request, oap->oap_request);
@@ -1709,7 +1709,7 @@ static void sort_brw_pages(struct brw_page **array, int num)
 
 static void osc_release_ppga(struct brw_page **ppga, u32 count)
 {
-	LASSERT(ppga != NULL);
+	LASSERT(ppga);
 	kfree(ppga);
 }
 
@@ -1748,7 +1748,7 @@ static int brw_interpret(const struct lu_env *env,
 	}
 
 	list_for_each_entry_safe(ext, tmp, &aa->aa_exts, oe_link) {
-		if (obj == NULL && rc == 0) {
+		if (!obj && rc == 0) {
 			obj = osc2cl(ext->oe_obj);
 			cl_object_get(obj);
 		}
@@ -1759,7 +1759,7 @@ static int brw_interpret(const struct lu_env *env,
 	LASSERT(list_empty(&aa->aa_exts));
 	LASSERT(list_empty(&aa->aa_oaps));
 
-	if (obj != NULL) {
+	if (obj) {
 		struct obdo *oa = aa->aa_oa;
 		struct cl_attr *attr  = &osc_env_info(env)->oti_attr;
 		unsigned long valid = 0;
@@ -1871,13 +1871,13 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	}
 
 	pga = kcalloc(page_count, sizeof(*pga), GFP_NOFS);
-	if (pga == NULL) {
+	if (!pga) {
 		rc = -ENOMEM;
 		goto out;
 	}
 
 	oa = kmem_cache_alloc(obdo_cachep, GFP_NOFS | __GFP_ZERO);
-	if (oa == NULL) {
+	if (!oa) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1886,7 +1886,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	list_for_each_entry(oap, &rpc_list, oap_rpc_item) {
 		struct cl_page *page = oap2cl_page(oap);
 
-		if (clerq == NULL) {
+		if (!clerq) {
 			clerq = cl_req_alloc(env, page, crt,
 					     1 /* only 1-object rpcs for now */);
 			if (IS_ERR(clerq)) {
@@ -1907,7 +1907,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	}
 
 	/* always get the data for the obdo for the rpc */
-	LASSERT(clerq != NULL);
+	LASSERT(clerq);
 	crattr->cra_oa = oa;
 	cl_req_attr_set(env, clerq, crattr, ~0ULL);
 	if (lock) {
@@ -1959,7 +1959,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	tmp = NULL;
 	list_for_each_entry(oap, &aa->aa_oaps, oap_rpc_item) {
 		/* only one oap gets a request reference */
-		if (tmp == NULL)
+		if (!tmp)
 			tmp = oap;
 		if (oap->oap_interrupted && !req->rq_intr) {
 			CDEBUG(D_INODE, "oap %p in req %p interrupted\n",
@@ -1967,7 +1967,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 			ptlrpc_mark_interrupted(req);
 		}
 	}
-	if (tmp != NULL)
+	if (tmp)
 		tmp->oap_request = ptlrpc_request_addref(req);
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
@@ -2001,7 +2001,7 @@ out:
 	kfree(crattr);
 
 	if (rc != 0) {
-		LASSERT(req == NULL);
+		LASSERT(!req);
 
 		if (oa)
 			kmem_cache_free(obdo_cachep, oa);
@@ -2026,7 +2026,6 @@ static int osc_set_lock_data_with_check(struct ldlm_lock *lock,
 	void *data = einfo->ei_cbdata;
 	int set = 0;
 
-	LASSERT(lock != NULL);
 	LASSERT(lock->l_blocking_ast == einfo->ei_cb_bl);
 	LASSERT(lock->l_resource->lr_type == einfo->ei_type);
 	LASSERT(lock->l_completion_ast == einfo->ei_cb_cp);
@@ -2035,7 +2034,7 @@ static int osc_set_lock_data_with_check(struct ldlm_lock *lock,
 	lock_res_and_lock(lock);
 	spin_lock(&osc_ast_guard);
 
-	if (lock->l_ast_data == NULL)
+	if (!lock->l_ast_data)
 		lock->l_ast_data = data;
 	if (lock->l_ast_data == data)
 		set = 1;
@@ -2052,7 +2051,7 @@ static int osc_set_data_with_check(struct lustre_handle *lockh,
 	struct ldlm_lock *lock = ldlm_handle2lock(lockh);
 	int set = 0;
 
-	if (lock != NULL) {
+	if (lock) {
 		set = osc_set_lock_data_with_check(lock, einfo);
 		LDLM_LOCK_PUT(lock);
 	} else
@@ -2095,7 +2094,6 @@ static int osc_enqueue_fini(struct ptlrpc_request *req, struct ost_lvb *lvb,
 			rep = req_capsule_server_get(&req->rq_pill,
 						     &RMF_DLM_REP);
 
-			LASSERT(rep != NULL);
 			rep->lock_policy_res1 =
 				ptlrpc_status_ntoh(rep->lock_policy_res1);
 			if (rep->lock_policy_res1)
@@ -2170,7 +2168,7 @@ static int osc_enqueue_interpret(const struct lu_env *env,
 		 */
 		ldlm_lock_decref(&handle, mode);
 
-	LASSERTF(lock != NULL, "lockh %p, req %p, aa %p - client evicted?\n",
+	LASSERTF(lock, "lockh %p, req %p, aa %p - client evicted?\n",
 		 aa->oa_lockh, req, aa);
 	ldlm_lock_decref(&handle, mode);
 	LDLM_LOCK_PUT(lock);
@@ -2281,7 +2279,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 
 		req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 					   &RQF_LDLM_ENQUEUE_LVB);
-		if (req == NULL)
+		if (!req)
 			return -ENOMEM;
 
 		rc = ldlm_prep_enqueue_req(exp, req, &cancels, 0);
@@ -2361,7 +2359,7 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	rc = ldlm_lock_match(obd->obd_namespace, lflags,
 			     res_id, type, policy, rc, lockh, unref);
 	if (rc) {
-		if (data != NULL) {
+		if (data) {
 			if (!osc_set_data_with_check(lockh, data)) {
 				if (!(lflags & LDLM_FL_TEST_LOCK))
 					ldlm_lock_decref(lockh, rc);
@@ -2411,7 +2409,7 @@ static int osc_statfs_interpret(const struct lu_env *env,
 		goto out;
 
 	msfs = req_capsule_server_get(&req->rq_pill, &RMF_OBD_STATFS);
-	if (msfs == NULL) {
+	if (!msfs) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -2438,7 +2436,7 @@ static int osc_statfs_async(struct obd_export *exp,
 	 * is not so great if request processing is slow, while absolute
 	 * timestamps are not ideal because they need time synchronization. */
 	req = ptlrpc_request_alloc(obd->u.cli.cl_import, &RQF_OST_STATFS);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_STATFS);
@@ -2493,7 +2491,7 @@ static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
 
 	class_import_put(imp);
 
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_STATFS);
@@ -2516,7 +2514,7 @@ static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
 		goto out;
 
 	msfs = req_capsule_server_get(&req->rq_pill, &RMF_OBD_STATFS);
-	if (msfs == NULL) {
+	if (!msfs) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -2701,7 +2699,7 @@ static int osc_get_info(const struct lu_env *env, struct obd_export *exp,
 
 		req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 					   &RQF_OST_GET_INFO_LAST_ID);
-		if (req == NULL)
+		if (!req)
 			return -ENOMEM;
 
 		req_capsule_set_size(&req->rq_pill, &RMF_SETINFO_KEY,
@@ -2722,7 +2720,7 @@ static int osc_get_info(const struct lu_env *env, struct obd_export *exp,
 			goto out;
 
 		reply = req_capsule_server_get(&req->rq_pill, &RMF_OBD_ID);
-		if (reply == NULL) {
+		if (!reply) {
 			rc = -EPROTO;
 			goto out;
 		}
@@ -2775,7 +2773,7 @@ out:
 skip_locking:
 		req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 					   &RQF_OST_GET_INFO_FIEMAP);
-		if (req == NULL) {
+		if (!req) {
 			rc = -ENOMEM;
 			goto drop_lock;
 		}
@@ -2804,7 +2802,7 @@ skip_locking:
 			goto fini_req;
 
 		reply = req_capsule_server_get(&req->rq_pill, &RMF_FIEMAP_VAL);
-		if (reply == NULL) {
+		if (!reply) {
 			rc = -EPROTO;
 			goto fini_req;
 		}
@@ -2853,7 +2851,7 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	if (KEY_IS(KEY_CACHE_SET)) {
 		struct client_obd *cli = &obd->u.cli;
 
-		LASSERT(cli->cl_cache == NULL); /* only once */
+		LASSERT(!cli->cl_cache); /* only once */
 		cli->cl_cache = val;
 		atomic_inc(&cli->cl_cache->ccc_users);
 		cli->cl_lru_left = &cli->cl_cache->ccc_lru_left;
@@ -2890,7 +2888,7 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	req = ptlrpc_request_alloc(imp, KEY_IS(KEY_GRANT_SHRINK) ?
 						&RQF_OST_SET_GRANT_INFO :
 						&RQF_OBD_SET_INFO);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	req_capsule_set_size(&req->rq_pill, &RMF_SETINFO_KEY,
@@ -2929,7 +2927,7 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 	if (!KEY_IS(KEY_GRANT_SHRINK)) {
-		LASSERT(set != NULL);
+		LASSERT(set);
 		ptlrpc_set_add_req(set, req);
 		ptlrpc_check_set(NULL, set);
 	} else {
@@ -2947,7 +2945,7 @@ static int osc_reconnect(const struct lu_env *env,
 {
 	struct client_obd *cli = &obd->u.cli;
 
-	if (data != NULL && (data->ocd_connect_flags & OBD_CONNECT_GRANT)) {
+	if (data && (data->ocd_connect_flags & OBD_CONNECT_GRANT)) {
 		long lost_grant;
 
 		client_obd_list_lock(&cli->cl_loi_list_lock);
@@ -2988,7 +2986,7 @@ static int osc_disconnect(struct obd_export *exp)
 	 * So the osc should be disconnected from the shrink list, after we
 	 * are sure the import has been destroyed. BUG18662
 	 */
-	if (obd->u.cli.cl_import == NULL)
+	if (!obd->u.cli.cl_import)
 		osc_del_shrink_grant(&obd->u.cli);
 	return rc;
 }
@@ -3213,7 +3211,7 @@ int osc_cleanup(struct obd_device *obd)
 	int rc;
 
 	/* lru cleanup */
-	if (cli->cl_cache != NULL) {
+	if (cli->cl_cache) {
 		LASSERT(atomic_read(&cli->cl_cache->ccc_users) > 0);
 		spin_lock(&cli->cl_cache->ccc_lru_lock);
 		list_del_init(&cli->cl_lru_osc);
-- 
2.1.0
