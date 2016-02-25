From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:37 -0500
Subject: [lustre-devel] [PATCH v2 54/84] staging/lustre/osc: Adjust comments
	to better conform to coding style
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-55-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 168 ++++++++++++++-------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  33 ++--
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   8 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   6 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  45 ++++--
 drivers/staging/lustre/lustre/osc/osc_page.c       |  42 ++++--
 drivers/staging/lustre/lustre/osc/osc_quota.c      |  16 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 151 +++++++++++-------
 8 files changed, 310 insertions(+), 159 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d006566..c6623c1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -262,7 +262,8 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 	}
 
 	/* Do not verify page list if extent is in RPC. This is because an
-	 * in-RPC extent is supposed to be exclusively accessible w/o lock. */
+	 * in-RPC extent is supposed to be exclusively accessible w/o lock.
+	 */
 	if (ext->oe_state > OES_CACHE) {
 		rc = 0;
 		goto out;
@@ -587,7 +588,8 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 		if (ext->oe_trunc_pending) {
 			/* a truncate process is waiting for this extent.
 			 * This may happen due to a race, check
-			 * osc_cache_truncate_start(). */
+			 * osc_cache_truncate_start().
+			 */
 			osc_extent_state_set(ext, OES_TRUNC);
 			ext->oe_trunc_pending = 0;
 		} else {
@@ -704,18 +706,21 @@ restart:
 
 		/* ok, from now on, ext and cur have these attrs:
 		 * 1. covered by the same lock
-		 * 2. contiguous at chunk level or overlapping. */
+		 * 2. contiguous at chunk level or overlapping.
+		 */
 
 		if (overlapped(ext, cur)) {
 			/* cur is the minimum unit, so overlapping means
-			 * full contain. */
+			 * full contain.
+			 */
 			EASSERTF((ext->oe_start <= cur->oe_start &&
 				  ext->oe_end >= cur->oe_end),
 				 ext, EXTSTR, EXTPARA(cur));
 
 			if (ext->oe_state > OES_CACHE || ext->oe_fsync_wait) {
 				/* for simplicity, we wait for this extent to
-				 * finish before going forward. */
+				 * finish before going forward.
+				 */
 				conflict = osc_extent_get(ext);
 				break;
 			}
@@ -728,17 +733,20 @@ restart:
 		if (ext->oe_state != OES_CACHE || ext->oe_fsync_wait) {
 			/* we can't do anything for a non OES_CACHE extent, or
 			 * if there is someone waiting for this extent to be
-			 * flushed, try next one. */
+			 * flushed, try next one.
+			 */
 			ext = next_extent(ext);
 			continue;
 		}
 
 		/* check if they belong to the same rpc slot before trying to
 		 * merge. the extents are not overlapped and contiguous at
-		 * chunk level to get here. */
+		 * chunk level to get here.
+		 */
 		if (ext->oe_max_end != max_end) {
 			/* if they don't belong to the same RPC slot or
-			 * max_pages_per_rpc has ever changed, do not merge. */
+			 * max_pages_per_rpc has ever changed, do not merge.
+			 */
 			ext = next_extent(ext);
 			continue;
 		}
@@ -747,7 +755,8 @@ restart:
 		 * level so that we know the whole extent is covered by grant
 		 * (the pages in the extent are NOT required to be contiguous).
 		 * Otherwise, it will be too much difficult to know which
-		 * chunks have grants allocated. */
+		 * chunks have grants allocated.
+		 */
 
 		/* try to do front merge - extend ext's start */
 		if (chunk + 1 == ext_chk_start) {
@@ -767,7 +776,8 @@ restart:
 			*grants -= chunksize;
 
 			/* try to merge with the next one because we just fill
-			 * in a gap */
+			 * in a gap
+			 */
 			if (osc_extent_merge(env, ext, next_extent(ext)) == 0)
 				/* we can save extent tax from next extent */
 				*grants += cli->cl_extent_tax;
@@ -807,7 +817,8 @@ restart:
 		LASSERT(!found);
 
 		/* waiting for IO to finish. Please notice that it's impossible
-		 * to be an OES_TRUNC extent. */
+		 * to be an OES_TRUNC extent.
+		 */
 		rc = osc_extent_wait(env, conflict, OES_INV);
 		osc_extent_put(env, conflict);
 		conflict = NULL;
@@ -864,7 +875,8 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 		   last_count != PAGE_CACHE_SIZE) {
 		/* For short writes we shouldn't count parts of pages that
 		 * span a whole chunk on the OST side, or our accounting goes
-		 * wrong.  Should match the code in filter_grant_check. */
+		 * wrong.  Should match the code in filter_grant_check.
+		 */
 		int offset = oap->oap_page_off & ~CFS_PAGE_MASK;
 		int count = oap->oap_count + (offset & (blocksize - 1));
 		int end = (offset + oap->oap_count) & (blocksize - 1);
@@ -908,7 +920,8 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 	osc_object_lock(obj);
 	LASSERT(sanity_check_nolock(ext) == 0);
 	/* `Kick' this extent only if the caller is waiting for it to be
-	 * written out. */
+	 * written out.
+	 */
 	if (state == OES_INV && !ext->oe_urgent && !ext->oe_hp &&
 	    !ext->oe_trunc_pending) {
 		if (ext->oe_state == OES_ACTIVE) {
@@ -966,7 +979,8 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 
 	/* Request new lu_env.
 	 * We can't use that env from osc_cache_truncate_start() because
-	 * it's from lov_io_sub and not fully initialized. */
+	 * it's from lov_io_sub and not fully initialized.
+	 */
 	env = cl_env_nested_get(&nest);
 	io  = &osc_env_info(env)->oti_io;
 	io->ci_obj = cl_object_top(osc2cl(obj));
@@ -983,7 +997,8 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 		LASSERT(list_empty(&oap->oap_rpc_item));
 
 		/* only discard the pages with their index greater than
-		 * trunc_index, and ... */
+		 * trunc_index, and ...
+		 */
 		if (sub->cp_index < trunc_index ||
 		    (sub->cp_index == trunc_index && partial)) {
 			/* accounting how many pages remaining in the chunk
@@ -1027,11 +1042,13 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 		pgoff_t last_index;
 
 		/* if there is no pages in this chunk, we can also free grants
-		 * for the last chunk */
+		 * for the last chunk
+		 */
 		if (pages_in_chunk == 0) {
 			/* if this is the 1st chunk and no pages in this chunk,
 			 * ext->oe_nr_pages must be zero, so we should be in
-			 * the other if-clause. */
+			 * the other if-clause.
+			 */
 			LASSERT(trunc_chunk > 0);
 			--trunc_chunk;
 			++chunks;
@@ -1104,7 +1121,8 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	LASSERT(page_count == ext->oe_nr_pages);
 	LASSERT(last);
 	/* the last page is the only one we need to refresh its count by
-	 * the size of file. */
+	 * the size of file.
+	 */
 	if (!(last->oap_async_flags & ASYNC_COUNT_STABLE)) {
 		last->oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
 		LASSERT(last->oap_count > 0);
@@ -1113,7 +1131,8 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	}
 
 	/* for the rest of pages, we don't need to call osf_refresh_count()
-	 * because it's known they are not the last page */
+	 * because it's known they are not the last page
+	 */
 	list_for_each_entry(oap, &ext->oe_pages, oap_pending_item) {
 		if (!(oap->oap_async_flags & ASYNC_COUNT_STABLE)) {
 			oap->oap_count = PAGE_CACHE_SIZE - oap->oap_page_off;
@@ -1168,7 +1187,8 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index, int *grants)
 	next = next_extent(ext);
 	if (next && next->oe_start <= end_index) {
 		/* complex mode - overlapped with the next extent,
-		 * this case will be handled by osc_extent_find() */
+		 * this case will be handled by osc_extent_find()
+		 */
 		rc = -EAGAIN;
 		goto out;
 	}
@@ -1365,7 +1385,8 @@ static void osc_consume_write_grant(struct client_obd *cli,
 }
 
 /* the companion to osc_consume_write_grant, called when a brw has completed.
- * must be called with the loi lock held. */
+ * must be called with the loi lock held.
+ */
 static void osc_release_write_grant(struct client_obd *cli,
 				    struct brw_page *pga)
 {
@@ -1408,7 +1429,8 @@ static void __osc_unreserve_grant(struct client_obd *cli,
 	/* it's quite normal for us to get more grant than reserved.
 	 * Thinking about a case that two extents merged by adding a new
 	 * chunk, we can save one extent tax. If extent tax is greater than
-	 * one chunk, we can save more grant by adding a new chunk */
+	 * one chunk, we can save more grant by adding a new chunk
+	 */
 	cli->cl_reserved_grant -= reserved;
 	if (unused > reserved) {
 		cli->cl_avail_grant += reserved;
@@ -1452,7 +1474,8 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 	cli->cl_lost_grant += lost_grant;
 	if (cli->cl_avail_grant < grant && cli->cl_lost_grant >= grant) {
 		/* borrow some grant from truncate to avoid the case that
-		 * truncate uses up all avail grant */
+		 * truncate uses up all avail grant
+		 */
 		cli->cl_lost_grant -= grant;
 		cli->cl_avail_grant += grant;
 	}
@@ -1537,7 +1560,8 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	client_obd_list_lock(&cli->cl_loi_list_lock);
 
 	/* force the caller to try sync io.  this can jump the list
-	 * of queued writes and create a discontiguous rpc stream */
+	 * of queued writes and create a discontiguous rpc stream
+	 */
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_NO_GRANT) ||
 	    cli->cl_dirty_max < PAGE_CACHE_SIZE     ||
 	    cli->cl_ar.ar_force_sync || loi->loi_ar.ar_force_sync) {
@@ -1556,7 +1580,8 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	 * Adding a cache waiter will trigger urgent write-out no matter what
 	 * RPC size will be.
 	 * The exiting condition is no avail grants and no dirty pages caching,
-	 * that really means there is no space on the OST. */
+	 * that really means there is no space on the OST.
+	 */
 	init_waitqueue_head(&ocw.ocw_waitq);
 	ocw.ocw_oap   = oap;
 	ocw.ocw_grant = bytes;
@@ -1638,7 +1663,8 @@ static int osc_max_rpc_in_flight(struct client_obd *cli, struct osc_object *osc)
 
 /* This maintains the lists of pending pages to read/write for a given object
  * (lop).  This is used by osc_check_rpcs->osc_next_obj() and osc_list_maint()
- * to quickly find objects that are ready to send an RPC. */
+ * to quickly find objects that are ready to send an RPC.
+ */
 static int osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
 			 int cmd)
 {
@@ -1647,7 +1673,8 @@ static int osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
 	/* if we have an invalid import we want to drain the queued pages
 	 * by forcing them through rpcs that immediately fail and complete
 	 * the pages.  recovery relies on this to empty the queued pages
-	 * before canceling the locks and evicting down the llite pages */
+	 * before canceling the locks and evicting down the llite pages
+	 */
 	if (!cli->cl_import || cli->cl_import->imp_invalid)
 		invalid_import = 1;
 
@@ -1668,7 +1695,8 @@ static int osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
 		}
 		/* trigger a write rpc stream as long as there are dirtiers
 		 * waiting for space.  as they're waiting, they're not going to
-		 * create more pages to coalesce with what's waiting.. */
+		 * create more pages to coalesce with what's waiting..
+		 */
 		if (!list_empty(&cli->cl_cache_waiters)) {
 			CDEBUG(D_CACHE, "cache waiters forcing RPC\n");
 			return 1;
@@ -1721,7 +1749,8 @@ static void on_list(struct list_head *item, struct list_head *list, int should_b
 }
 
 /* maintain the osc's cli list membership invariants so that osc_send_oap_rpc
- * can find pages to build into rpcs quickly */
+ * can find pages to build into rpcs quickly
+ */
 static int __osc_list_maint(struct client_obd *cli, struct osc_object *osc)
 {
 	if (osc_makes_hprpc(osc)) {
@@ -1759,7 +1788,8 @@ static int osc_list_maint(struct client_obd *cli, struct osc_object *osc)
  * application.  As an async write fails we record the error code for later if
  * the app does an fsync.  As long as errors persist we force future rpcs to be
  * sync so that the app can get a sync error and break the cycle of queueing
- * pages for which writeback will fail. */
+ * pages for which writeback will fail.
+ */
 static void osc_process_ar(struct osc_async_rc *ar, __u64 xid,
 			   int rc)
 {
@@ -1778,7 +1808,8 @@ static void osc_process_ar(struct osc_async_rc *ar, __u64 xid,
 }
 
 /* this must be called holding the loi list lock to give coverage to exit_cache,
- * async_flag maintenance, and oap_request */
+ * async_flag maintenance, and oap_request
+ */
 static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 			      struct osc_async_page *oap, int sent, int rc)
 {
@@ -1966,7 +1997,8 @@ osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
 	}
 
 	/* we're going to grab page lock, so release object lock because
-	 * lock order is page lock -> object lock. */
+	 * lock order is page lock -> object lock.
+	 */
 	osc_object_unlock(osc);
 
 	list_for_each_entry_safe(ext, tmp, &rpclist, oe_link) {
@@ -2051,12 +2083,14 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 })
 
 /* This is called by osc_check_rpcs() to find which objects have pages that
- * we could be sending.  These lists are maintained by osc_makes_rpc(). */
+ * we could be sending.  These lists are maintained by osc_makes_rpc().
+ */
 static struct osc_object *osc_next_obj(struct client_obd *cli)
 {
 	/* First return objects that have blocked locks so that they
 	 * will be flushed quickly and other clients can get the lock,
-	 * then objects which have pages ready to be stuffed into RPCs */
+	 * then objects which have pages ready to be stuffed into RPCs
+	 */
 	if (!list_empty(&cli->cl_loi_hp_ready_list))
 		return list_to_obj(&cli->cl_loi_hp_ready_list, hp_ready_item);
 	if (!list_empty(&cli->cl_loi_ready_list))
@@ -2065,13 +2099,15 @@ static struct osc_object *osc_next_obj(struct client_obd *cli)
 	/* then if we have cache waiters, return all objects with queued
 	 * writes.  This is especially important when many small files
 	 * have filled up the cache and not been fired into rpcs because
-	 * they don't pass the nr_pending/object threshold */
+	 * they don't pass the nr_pending/object threshold
+	 */
 	if (!list_empty(&cli->cl_cache_waiters) &&
 	    !list_empty(&cli->cl_loi_write_list))
 		return list_to_obj(&cli->cl_loi_write_list, write_item);
 
 	/* then return all queued objects when we have an invalid import
-	 * so that they get flushed */
+	 * so that they get flushed
+	 */
 	if (!cli->cl_import || cli->cl_import->imp_invalid) {
 		if (!list_empty(&cli->cl_loi_write_list))
 			return list_to_obj(&cli->cl_loi_write_list, write_item);
@@ -2109,7 +2145,8 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 		 * would be redundant if we were getting read/write work items
 		 * instead of objects.  we don't want send_oap_rpc to drain a
 		 * partial read pending queue when we're given this object to
-		 * do io on writes while there are cache waiters */
+		 * do io on writes while there are cache waiters
+		 */
 		osc_object_lock(osc);
 		if (osc_makes_rpc(cli, osc, OBD_BRW_WRITE)) {
 			rc = osc_send_write_rpc(env, cli, osc);
@@ -2131,7 +2168,8 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 				 * because it might be blocked at grabbing
 				 * the page lock as we mentioned.
 				 *
-				 * Anyway, continue to drain pages. */
+				 * Anyway, continue to drain pages.
+				 */
 				/* break; */
 			}
 		}
@@ -2161,7 +2199,8 @@ static int osc_io_unplug0(const struct lu_env *env, struct client_obd *cli,
 
 	if (!async) {
 		/* disable osc_lru_shrink() temporarily to avoid
-		 * potential stack overrun problem. LU-2859 */
+		 * potential stack overrun problem. LU-2859
+		 */
 		atomic_inc(&cli->cl_lru_shrinkers);
 		client_obd_list_lock(&cli->cl_loi_list_lock);
 		osc_check_rpcs(env, cli);
@@ -2285,12 +2324,14 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	 * 1. if there exists an active extent for this IO, mostly this page
 	 *    can be added to the active extent and sometimes we need to
 	 *    expand extent to accommodate this page;
-	 * 2. otherwise, a new extent will be allocated. */
+	 * 2. otherwise, a new extent will be allocated.
+	 */
 
 	ext = oio->oi_active;
 	if (ext && ext->oe_start <= index && ext->oe_max_end >= index) {
 		/* one chunk plus extent overhead must be enough to write this
-		 * page */
+		 * page
+		 */
 		grants = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
 		if (ext->oe_end >= index)
 			grants = 0;
@@ -2333,7 +2374,8 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		/* try to find new extent to cover this page */
 		LASSERT(!oio->oi_active);
 		/* we may have allocated grant for this page if we failed
-		 * to expand the previous active extent. */
+		 * to expand the previous active extent.
+		 */
 		LASSERT(ergo(grants > 0, grants >= tmp));
 
 		rc = 0;
@@ -2398,7 +2440,8 @@ int osc_teardown_async_page(const struct lu_env *env,
 		ext = osc_extent_lookup(obj, oap2cl_page(oap)->cp_index);
 		/* only truncated pages are allowed to be taken out.
 		 * See osc_extent_truncate() and osc_cache_truncate_start()
-		 * for details. */
+		 * for details.
+		 */
 		if (ext && ext->oe_state != OES_TRUNC) {
 			OSC_EXTENT_DUMP(D_ERROR, ext, "trunc at %lu.\n",
 					oap2cl_page(oap)->cp_index);
@@ -2449,7 +2492,8 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 		 * exists a deadlock problem because other process can wait for
 		 * page writeback bit holding page lock; and meanwhile in
 		 * vvp_page_make_ready(), we need to grab page lock before
-		 * really sending the RPC. */
+		 * really sending the RPC.
+		 */
 	case OES_TRUNC:
 		/* race with truncate, page will be redirtied */
 	case OES_ACTIVE:
@@ -2457,7 +2501,8 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 		 * re-dirty the page. If we continued on here, and we were the
 		 * one making the extent active, we could deadlock waiting for
 		 * the page writeback to clear but it won't because the extent
-		 * is active and won't be written out. */
+		 * is active and won't be written out.
+		 */
 		rc = -EAGAIN;
 		goto out;
 	default:
@@ -2528,7 +2573,8 @@ int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops)
 		if (ext->oe_start <= index && ext->oe_end >= index) {
 			LASSERT(ext->oe_state == OES_LOCK_DONE);
 			/* For OES_LOCK_DONE state extent, it has already held
-			 * a refcount for RPC. */
+			 * a refcount for RPC.
+			 */
 			found = osc_extent_get(ext);
 			break;
 		}
@@ -2544,7 +2590,8 @@ int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops)
 	} else {
 		osc_object_unlock(obj);
 		/* ok, it's been put in an rpc. only one oap gets a request
-		 * reference */
+		 * reference
+		 */
 		if (oap->oap_request) {
 			ptlrpc_mark_interrupted(oap->oap_request);
 			ptlrpcd_wake(oap->oap_request);
@@ -2646,7 +2693,8 @@ again:
 			/* if ext is in urgent state, it means there must exist
 			 * a page already having been flushed by write_page().
 			 * We have to wait for this extent because we can't
-			 * truncate that page. */
+			 * truncate that page.
+			 */
 			LASSERT(!ext->oe_hp);
 			OSC_EXTENT_DUMP(D_CACHE, ext,
 					"waiting for busy extent\n");
@@ -2661,7 +2709,8 @@ again:
 			/* though we grab inode mutex for write path, but we
 			 * release it before releasing extent(in osc_io_end()),
 			 * so there is a race window that an extent is still
-			 * in OES_ACTIVE when truncate starts. */
+			 * in OES_ACTIVE when truncate starts.
+			 */
 			LASSERT(!ext->oe_trunc_pending);
 			ext->oe_trunc_pending = 1;
 		} else {
@@ -2686,7 +2735,8 @@ again:
 		list_del_init(&ext->oe_link);
 
 		/* extent may be in OES_ACTIVE state because inode mutex
-		 * is released before osc_io_end() in file write case */
+		 * is released before osc_io_end() in file write case
+		 */
 		if (ext->oe_state != OES_TRUNC)
 			osc_extent_wait(env, ext, OES_TRUNC);
 
@@ -2711,7 +2761,8 @@ again:
 
 			/* we need to hold this extent in OES_TRUNC state so
 			 * that no writeback will happen. This is to avoid
-			 * BUG 17397. */
+			 * BUG 17397.
+			 */
 			LASSERT(!oio->oi_trunc);
 			oio->oi_trunc = osc_extent_get(ext);
 			OSC_EXTENT_DUMP(D_CACHE, ext,
@@ -2723,7 +2774,8 @@ again:
 		int rc;
 
 		/* ignore the result of osc_extent_wait the write initiator
-		 * should take care of it. */
+		 * should take care of it.
+		 */
 		rc = osc_extent_wait(env, waiting, OES_INV);
 		if (rc < 0)
 			OSC_EXTENT_DUMP(D_CACHE, waiting, "error: %d.\n", rc);
@@ -2870,7 +2922,8 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 				unplug = true;
 			} else {
 				/* the only discarder is lock cancelling, so
-				 * [start, end] must contain this extent */
+				 * [start, end] must contain this extent
+				 */
 				EASSERT(ext->oe_start >= start &&
 					ext->oe_max_end <= end, ext);
 				osc_extent_state_set(ext, OES_LOCKING);
@@ -2885,14 +2938,16 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 			/* It's pretty bad to wait for ACTIVE extents, because
 			 * we don't know how long we will wait for it to be
 			 * flushed since it may be blocked@awaiting more
-			 * grants. We do this for the correctness of fsync. */
+			 * grants. We do this for the correctness of fsync.
+			 */
 			LASSERT(hp == 0 && discard == 0);
 			ext->oe_urgent = 1;
 			break;
 		case OES_TRUNC:
 			/* this extent is being truncated, can't do anything
 			 * for it now. it will be set to urgent after truncate
-			 * is finished in osc_cache_truncate_end(). */
+			 * is finished in osc_cache_truncate_end().
+			 */
 		default:
 			break;
 		}
@@ -2911,7 +2966,8 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 			EASSERT(ext->oe_state == OES_LOCKING, ext);
 
 			/* Discard caching pages. We don't actually write this
-			 * extent out but we complete it as if we did. */
+			 * extent out but we complete it as if we did.
+			 */
 			rc = osc_extent_make_ready(env, ext);
 			if (unlikely(rc < 0)) {
 				OSC_EXTENT_DUMP(D_ERROR, ext,
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 861642b..d55d04d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -69,10 +69,12 @@ struct osc_io {
 	/** true if this io is lockless. */
 	int		oi_lockless;
 	/** active extents, we know how many bytes is going to be written,
-	 * so having an active extent will prevent it from being fragmented */
+	 * so having an active extent will prevent it from being fragmented
+	 */
 	struct osc_extent *oi_active;
 	/** partially truncated extent, we need to hold this extent to prevent
-	 * page writeback from happening. */
+	 * page writeback from happening.
+	 */
 	struct osc_extent *oi_trunc;
 
 	struct obd_info    oi_info;
@@ -154,7 +156,8 @@ struct osc_object {
 	atomic_t	 oo_nr_writes;
 
 	/** Protect extent tree. Will be used to protect
-	 * oo_{read|write}_pages soon. */
+	 * oo_{read|write}_pages soon.
+	 */
 	spinlock_t	    oo_lock;
 };
 
@@ -627,22 +630,26 @@ struct osc_extent {
 			   oe_srvlock:1,
 			   oe_memalloc:1,
 	/** an ACTIVE extent is going to be truncated, so when this extent
-	 * is released, it will turn into TRUNC state instead of CACHE. */
+	 * is released, it will turn into TRUNC state instead of CACHE.
+	 */
 			   oe_trunc_pending:1,
 	/** this extent should be written asap and someone may wait for the
 	 * write to finish. This bit is usually set along with urgent if
 	 * the extent was CACHE state.
 	 * fsync_wait extent can't be merged because new extent region may
-	 * exceed fsync range. */
+	 * exceed fsync range.
+	 */
 			   oe_fsync_wait:1,
 	/** covering lock is being canceled */
 			   oe_hp:1,
 	/** this extent should be written back asap. set if one of pages is
-	 * called by page WB daemon, or sync write or reading requests. */
+	 * called by page WB daemon, or sync write or reading requests.
+	 */
 			   oe_urgent:1;
 	/** how many grants allocated for this extent.
 	 *  Grant allocated for this extent. There is no grant allocated
-	 *  for reading extents and sync write extents. */
+	 *  for reading extents and sync write extents.
+	 */
 	unsigned int       oe_grants;
 	/** # of dirty pages in this extent */
 	unsigned int       oe_nr_pages;
@@ -655,21 +662,25 @@ struct osc_extent {
 	struct osc_page   *oe_next_page;
 	/** start and end index of this extent, include start and end
 	 * themselves. Page offset here is the page index of osc_pages.
-	 * oe_start is used as keyword for red-black tree. */
+	 * oe_start is used as keyword for red-black tree.
+	 */
 	pgoff_t	    oe_start;
 	pgoff_t	    oe_end;
 	/** maximum ending index of this extent, this is limited by
-	 * max_pages_per_rpc, lock extent and chunk size. */
+	 * max_pages_per_rpc, lock extent and chunk size.
+	 */
 	pgoff_t	    oe_max_end;
 	/** waitqueue - for those who want to be notified if this extent's
-	 * state has changed. */
+	 * state has changed.
+	 */
 	wait_queue_head_t	oe_waitq;
 	/** lock covering this extent */
 	struct cl_lock    *oe_osclock;
 	/** terminator of this extent. Must be true if this extent is in IO. */
 	struct task_struct	*oe_owner;
 	/** return value of writeback. If somebody is waiting for this extent,
-	 * this value can be known by outside world. */
+	 * this value can be known by outside world.
+	 */
 	int		oe_rc;
 	/** max pages per rpc when this extent was created */
 	unsigned int       oe_mppr;
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index a4c6146..ea695c2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -47,11 +47,13 @@ struct lu_env;
 
 enum async_flags {
 	ASYNC_READY = 0x1, /* ap_make_ready will not be called before this
-			      page is added to an rpc */
+			    * page is added to an rpc
+			    */
 	ASYNC_URGENT = 0x2, /* page must be put into an RPC before return */
 	ASYNC_COUNT_STABLE = 0x4, /* ap_refresh_count will not be called
-				     to give the caller a chance to update
-				     or cancel the size of the io */
+				   * to give the caller a chance to update
+				   * or cancel the size of the io
+				   */
 	ASYNC_HP = 0x10,
 };
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 9dfcc26..2d8d93c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -272,7 +272,8 @@ static int osc_io_prepare_write(const struct lu_env *env,
 		/* this page contains `invalid' data, but who cares?
 		 * nobody can access the invalid data.
 		 * in osc_io_commit_write(), we're going to write exact
-		 * [from, to) bytes of this page to OST. -jay */
+		 * [from, to) bytes of this page to OST. -jay
+		 */
 		cl_page_export(env, slice->cpl_page, 1);
 
 	return result;
@@ -596,7 +597,8 @@ static int osc_io_fsync_start(const struct lu_env *env,
 		 * send OST_SYNC RPC. This is bad because it causes extents
 		 * to be written osc by osc. However, we usually start
 		 * writeback before CL_FSYNC_ALL so this won't have any real
-		 * problem. */
+		 * problem.
+		 */
 		rc = osc_cache_wait_range(env, osc, start, end);
 		if (result == 0)
 			result = rc;
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index cc9d7ea..87f3522 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -154,7 +154,8 @@ static void osc_lock_detach(const struct lu_env *env, struct osc_lock *olck)
 
 	olck->ols_lock = NULL;
 	/* wb(); --- for all who checks (ols->ols_lock != NULL) before
-	 * call to osc_lock_detach() */
+	 * call to osc_lock_detach()
+	 */
 	dlmlock->l_ast_data = NULL;
 	olck->ols_handle.cookie = 0ULL;
 	spin_unlock(&osc_ast_guard);
@@ -169,7 +170,8 @@ static void osc_lock_detach(const struct lu_env *env, struct osc_lock *olck)
 		/* Must get the value under the lock to avoid possible races. */
 		old_kms = cl2osc(obj)->oo_oinfo->loi_kms;
 		/* Update the kms. Need to loop all granted locks.
-		 * Not a problem for the client */
+		 * Not a problem for the client
+		 */
 		attr->cat_kms = ldlm_extent_shift_kms(dlmlock, old_kms);
 
 		cl_object_attr_set(env, obj, attr, CAT_KMS);
@@ -362,7 +364,8 @@ static void osc_lock_lvb_update(const struct lu_env *env, struct osc_lock *olck,
 		*lvb = *(struct ost_lvb *)dlmlock->l_lvb_data;
 		size = lvb->lvb_size;
 		/* Extend KMS up to the end of this lock and no further
-		 * A lock on [x,y] means a KMS of up to y + 1 bytes! */
+		 * A lock on [x,y] means a KMS of up to y + 1 bytes!
+		 */
 		if (size > dlmlock->l_policy_data.l_extent.end)
 			size = dlmlock->l_policy_data.l_extent.end + 1;
 		if (size >= oinfo->loi_kms) {
@@ -426,7 +429,8 @@ static void osc_lock_granted(const struct lu_env *env, struct osc_lock *olck,
 		 * to take a semaphore on a parent lock. This is safe, because
 		 * spin-locks are needed to protect consistency of
 		 * dlmlock->l_*_mode and LVB, and we have finished processing
-		 * them. */
+		 * them.
+		 */
 		unlock_res_and_lock(dlmlock);
 		cl_lock_modify(env, lock, descr);
 		cl_lock_signal(env, lock);
@@ -467,7 +471,8 @@ static void osc_lock_upcall0(const struct lu_env *env, struct osc_lock *olck)
 	olck->ols_hold = 1;
 
 	/* lock reference taken by ldlm_handle2lock_long() is owned by
-	 * osc_lock and released in osc_lock_detach() */
+	 * osc_lock and released in osc_lock_detach()
+	 */
 	lu_ref_add(&dlmlock->l_reference, "osc_lock", olck);
 	olck->ols_has_ref = 1;
 }
@@ -545,7 +550,8 @@ static int osc_lock_upcall(void *cookie, int errcode)
 			/* For AGL case, the RPC sponsor may exits the cl_lock
 			*  processing without wait() called before related OSC
 			*  lock upcall(). So update the lock status according
-			*  to the enqueue result inside AGL upcall(). */
+			*  to the enqueue result inside AGL upcall().
+			*/
 			if (olck->ols_agl) {
 				lock->cll_flags |= CLF_FROM_UPCALL;
 				cl_wait_try(env, lock);
@@ -568,7 +574,8 @@ static int osc_lock_upcall(void *cookie, int errcode)
 
 		lu_ref_del(&lock->cll_reference, "upcall", lock);
 		/* This maybe the last reference, so must be called after
-		 * cl_lock_mutex_put(). */
+		 * cl_lock_mutex_put().
+		 */
 		cl_lock_put(env, lock);
 
 		cl_env_nested_put(&nest, env);
@@ -854,7 +861,8 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 			 * BTW, it's okay for cl_lock to be cancelled during
 			 * this period because server can handle this race.
 			 * See ldlm_server_glimpse_ast() for details.
-			 * cl_lock_mutex_get(env, lock); */
+			 * cl_lock_mutex_get(env, lock);
+			 */
 			cap = &req->rq_pill;
 			req_capsule_extend(cap, &RQF_LDLM_GL_CALLBACK);
 			req_capsule_set_size(cap, &RMF_DLM_LVB, RCL_SERVER,
@@ -1014,7 +1022,8 @@ static int osc_lock_enqueue_wait(const struct lu_env *env,
 	LASSERT(cl_lock_is_mutexed(lock));
 
 	/* make it enqueue anyway for glimpse lock, because we actually
-	 * don't need to cancel any conflicting locks. */
+	 * don't need to cancel any conflicting locks.
+	 */
 	if (olck->ols_glimpse)
 		return 0;
 
@@ -1048,7 +1057,8 @@ static int osc_lock_enqueue_wait(const struct lu_env *env,
 		 * imagine that client has PR lock on [0, 1000], and thread T0
 		 * is doing lockless IO in [500, 1500] region. Concurrent
 		 * thread T1 can see lockless data in [500, 1000], which is
-		 * wrong, because these data are possibly stale. */
+		 * wrong, because these data are possibly stale.
+		 */
 		if (!lockless && osc_lock_compatible(olck, scan_ols))
 			continue;
 
@@ -1120,7 +1130,8 @@ static int osc_lock_enqueue(const struct lu_env *env,
 			struct ldlm_enqueue_info *einfo = &ols->ols_einfo;
 
 			/* lock will be passed as upcall cookie,
-			 * hold ref to prevent to be released. */
+			 * hold ref to prevent to be released.
+			 */
 			cl_lock_hold_add(env, lock, "upcall", lock);
 			/* a user for lock also */
 			cl_lock_user_add(env, lock);
@@ -1171,7 +1182,8 @@ static int osc_lock_wait(const struct lu_env *env,
 		} else if (olck->ols_agl) {
 			if (lock->cll_flags & CLF_FROM_UPCALL)
 				/* It is from enqueue RPC reply upcall for
-				 * updating state. Do not re-enqueue. */
+				 * updating state. Do not re-enqueue.
+				 */
 				return -ENAVAIL;
 			olck->ols_state = OLS_NEW;
 		} else {
@@ -1232,7 +1244,8 @@ static int osc_lock_use(const struct lu_env *env,
 		LASSERT(lock->cll_state == CLS_INTRANSIT);
 		LASSERT(lock->cll_users > 0);
 		/* set a flag for osc_dlm_blocking_ast0() to signal the
-		 * lock.*/
+		 * lock.
+		 */
 		olck->ols_ast_wait = 1;
 		rc = CLO_WAIT;
 	}
@@ -1315,7 +1328,8 @@ static void osc_lock_cancel(const struct lu_env *env,
 		/* Now that we're the only user of dlm read/write reference,
 		 * mostly the ->l_readers + ->l_writers should be zero.
 		 * However, there is a corner case.
-		 * See bug 18829 for details.*/
+		 * See bug 18829 for details.
+		 */
 		do_cancel = (dlmlock->l_readers == 0 &&
 			     dlmlock->l_writers == 0);
 		dlmlock->l_flags |= LDLM_FL_CBPENDING;
@@ -1514,7 +1528,8 @@ static void osc_lock_lockless_state(const struct lu_env *env,
 		lock->ols_owner = oio;
 
 		/* set the io to be lockless if this lock is for io's
-		 * host object */
+		 * host object
+		 */
 		if (cl_object_same(oio->oi_cl.cis_obj, slice->cls_obj))
 			oio->oi_lockless = 1;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 5cb0ccc..d11582a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -105,7 +105,8 @@ static void osc_page_transfer_add(const struct lu_env *env,
 	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 
 	/* ops_lru and ops_inflight share the same field, so take it from LRU
-	 * first and then use it as inflight. */
+	 * first and then use it as inflight.
+	 */
 	osc_lru_del(osc_cli(obj), opg, false);
 
 	spin_lock(&obj->oo_seatbelt);
@@ -133,7 +134,8 @@ static int osc_page_cache_add(const struct lu_env *env,
 
 	/* for sync write, kernel will wait for this page to be flushed before
 	 * osc_io_end() is called, so release it earlier.
-	 * for mkwrite(), it's known there is no further pages. */
+	 * for mkwrite(), it's known there is no further pages.
+	 */
 	if (cl_io_is_sync_write(io) || cl_io_is_mkwrite(io)) {
 		if (oio->oi_active) {
 			osc_extent_release(env, oio->oi_active);
@@ -359,7 +361,8 @@ static int osc_page_cancel(const struct lu_env *env,
 	LINVRNT(osc_page_protected(env, opg, CLM_READ, 0));
 
 	/* Check if the transferring against this page
-	 * is completed, or not even queued. */
+	 * is completed, or not even queued.
+	 */
 	if (opg->ops_transfer_pinned)
 		/* FIXME: may not be interrupted.. */
 		rc = osc_cancel_async_page(env, opg);
@@ -423,7 +426,8 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 	 * creates temporary pages outside of a lock.
 	 */
 	/* ops_inflight and ops_lru are the same field, but it doesn't
-	 * hurt to initialize it twice :-) */
+	 * hurt to initialize it twice :-)
+	 */
 	INIT_LIST_HEAD(&opg->ops_inflight);
 	INIT_LIST_HEAD(&opg->ops_lru);
 
@@ -482,7 +486,8 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 static DECLARE_WAIT_QUEUE_HEAD(osc_lru_waitq);
 static atomic_t osc_lru_waiters = ATOMIC_INIT(0);
 /* LRU pages are freed in batch mode. OSC should at least free this
- * number of pages to avoid running out of LRU budget, and.. */
+ * number of pages to avoid running out of LRU budget, and..
+ */
 static const int lru_shrink_min = 2 << (20 - PAGE_CACHE_SHIFT);  /* 2M */
 /* free this number@most otherwise it will take too long time to finish. */
 static const int lru_shrink_max = 32 << (20 - PAGE_CACHE_SHIFT); /* 32M */
@@ -491,7 +496,8 @@ static const int lru_shrink_max = 32 << (20 - PAGE_CACHE_SHIFT); /* 32M */
  * we should free slots aggressively. In this way, slots are freed in a steady
  * step to maintain fairness among OSCs.
  *
- * Return how many LRU pages should be freed. */
+ * Return how many LRU pages should be freed.
+ */
 static int osc_cache_too_much(struct client_obd *cli)
 {
 	struct cl_client_cache *cache = cli->cl_cache;
@@ -503,7 +509,8 @@ static int osc_cache_too_much(struct client_obd *cli)
 		return min(pages, lru_shrink_max);
 
 	/* if it's going to run out LRU slots, we should free some, but not
-	 * too much to maintain fairness among OSCs. */
+	 * too much to maintain fairness among OSCs.
+	 */
 	if (atomic_read(cli->cl_lru_left) < cache->ccc_lru_max >> 4) {
 		unsigned long tmp;
 
@@ -531,7 +538,8 @@ static int discard_pagevec(const struct lu_env *env, struct cl_io *io,
 			/* free LRU page only if nobody is using it.
 			 * This check is necessary to avoid freeing the pages
 			 * having already been removed from LRU and pinned
-			 * for IO. */
+			 * for IO.
+			 */
 			if (!cl_page_in_use(page)) {
 				cl_page_unmap(env, io, page);
 				cl_page_discard(env, io, page);
@@ -621,11 +629,13 @@ int osc_lru_shrink(struct client_obd *cli, int target)
 
 		/* move this page to the end of list as it will be discarded
 		 * soon. The page will be finally removed from LRU list in
-		 * osc_page_delete().  */
+		 * osc_page_delete().
+		 */
 		list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
 
 		/* it's okay to grab a refcount here w/o holding lock because
-		 * it has to grab cl_lru_list_lock to delete the page. */
+		 * it has to grab cl_lru_list_lock to delete the page.
+		 */
 		cl_page_get(page);
 		pvec[index++] = page;
 		if (++count >= target)
@@ -676,7 +686,8 @@ static void osc_lru_add(struct client_obd *cli, struct osc_page *opg)
 }
 
 /* delete page from LRUlist. The page can be deleted from LRUlist for two
- * reasons: redirtied or deleted from page cache. */
+ * reasons: redirtied or deleted from page cache.
+ */
 static void osc_lru_del(struct client_obd *cli, struct osc_page *opg, bool del)
 {
 	if (opg->ops_in_lru) {
@@ -698,7 +709,8 @@ static void osc_lru_del(struct client_obd *cli, struct osc_page *opg, bool del)
 			 * this osc occupies too many LRU pages and kernel is
 			 * stealing one of them.
 			 * cl_lru_shrinkers is to avoid recursive call in case
-			 * we're already in the context of osc_lru_shrink(). */
+			 * we're already in the context of osc_lru_shrink().
+			 */
 			if (atomic_read(&cli->cl_lru_shrinkers) == 0 &&
 			    !memory_pressure_get())
 				osc_lru_shrink(cli, osc_cache_too_much(cli));
@@ -735,7 +747,8 @@ static int osc_lru_reclaim(struct client_obd *cli)
 		atomic_read(&cli->cl_lru_busy));
 
 	/* Reclaim LRU slots from other client_obd as it can't free enough
-	 * from its own. This should rarely happen. */
+	 * from its own. This should rarely happen.
+	 */
 	spin_lock(&cache->ccc_lru_lock);
 	LASSERT(!list_empty(&cache->ccc_lru));
 
@@ -793,7 +806,8 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 		cond_resched();
 
 		/* slowest case, all of caching pages are busy, notifying
-		 * other OSCs that we're lack of LRU slots. */
+		 * other OSCs that we're lack of LRU slots.
+		 */
 		atomic_inc(&osc_lru_waiters);
 
 		gen = atomic_read(&cli->cl_lru_in_list);
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index 508fcf2..208f72b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -47,10 +47,12 @@ int osc_quota_chkdq(struct client_obd *cli, const unsigned int qid[])
 		oqi = cfs_hash_lookup(cli->cl_quota_hash[type], &qid[type]);
 		if (oqi) {
 			/* do not try to access oqi here, it could have been
-			 * freed by osc_quota_setdq() */
+			 * freed by osc_quota_setdq()
+			 */
 
 			/* the slot is busy, the user is about to run out of
-			 * quota space on this OST */
+			 * quota space on this OST
+			 */
 			CDEBUG(D_QUOTA, "chkdq found noquota for %s %d\n",
 			       type == USRQUOTA ? "user" : "grout", qid[type]);
 			return NO_QUOTA;
@@ -84,7 +86,8 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 		oqi = cfs_hash_lookup(cli->cl_quota_hash[type], &qid[type]);
 		if ((flags & FL_QUOTA_FLAG(type)) != 0) {
 			/* This ID is getting close to its quota limit, let's
-			 * switch to sync I/O */
+			 * switch to sync I/O
+			 */
 			if (oqi)
 				continue;
 
@@ -108,7 +111,8 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 			       qid[type], rc);
 		} else {
 			/* This ID is now off the hook, let's remove it from
-			 * the hash table */
+			 * the hash table
+			 */
 			if (!oqi)
 				continue;
 
@@ -297,8 +301,8 @@ int osc_quotacheck(struct obd_device *unused, struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 
-	/* the next poll will find -ENODATA, that means quotacheck is
-	 * going on */
+	/* the next poll will find -ENODATA, that means quotacheck is going on
+	 */
 	cli->cl_qchk_stat = -ENODATA;
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index c98e951..6f0c4e0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -628,7 +628,8 @@ int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
 
 /* Find and cancel locally locks matched by @mode in the resource found by
  * @objid. Found locks are added into @cancel list. Returns the amount of
- * locks added to @cancels list. */
+ * locks added to @cancels list.
+ */
 static int osc_resource_get_unused(struct obd_export *exp, struct obdo *oa,
 				   struct list_head *cancels,
 				   enum ldlm_mode mode, __u64 lock_flags)
@@ -643,7 +644,8 @@ static int osc_resource_get_unused(struct obd_export *exp, struct obdo *oa,
 	 *
 	 * This distinguishes from a case when ELC is not supported originally,
 	 * when we still want to cancel locks in advance and just cancel them
-	 * locally, without sending any RPC. */
+	 * locally, without sending any RPC.
+	 */
 	if (exp_connect_cancelset(exp) && !ns_connect_cancelset(ns))
 		return 0;
 
@@ -722,7 +724,8 @@ static int osc_create(const struct lu_env *env, struct obd_export *exp,
  * If the client dies, or the OST is down when the object should be destroyed,
  * the records are not cancelled, and when the OST reconnects to the MDS next,
  * it will retrieve the llog unlink logs and then sends the log cancellation
- * cookies to the MDS after committing destroy transactions. */
+ * cookies to the MDS after committing destroy transactions.
+ */
 static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 		       struct obdo *oa, struct lov_stripe_md *ea,
 		       struct obd_trans_info *oti, struct obd_export *md_export)
@@ -768,7 +771,8 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 	/* If osc_destroy is for destroying the unlink orphan,
 	 * sent from MDT to OST, which should not be blocked here,
 	 * because the process might be triggered by ptlrpcd, and
-	 * it is not good to block ptlrpcd thread (b=16006)*/
+	 * it is not good to block ptlrpcd thread (b=16006
+	 **/
 	if (!(oa->o_flags & OBD_FL_DELORPHAN)) {
 		req->rq_interpret_reply = osc_destroy_interpret;
 		if (!osc_can_send_destroy(cli)) {
@@ -809,7 +813,8 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 			    (long)(obd_max_dirty_pages + 1))) {
 		/* The atomic_read() allowing the atomic_inc() are
 		 * not covered by a lock thus they may safely race and trip
-		 * this CERROR() unless we add in a small fudge factor (+1). */
+		 * this CERROR() unless we add in a small fudge factor (+1).
+		 */
 		CERROR("dirty %d - %d > system dirty_max %d\n",
 		       atomic_read(&obd_dirty_pages),
 		       atomic_read(&obd_dirty_transit_pages),
@@ -899,7 +904,8 @@ static void osc_shrink_grant_local(struct client_obd *cli, struct obdo *oa)
 /* Shrink the current grant, either from some large amount to enough for a
  * full set of in-flight RPCs, or if we have already shrunk to that limit
  * then to enough for a single RPC.  This avoids keeping more grant than
- * needed, and avoids shrinking the grant piecemeal. */
+ * needed, and avoids shrinking the grant piecemeal.
+ */
 static int osc_shrink_grant(struct client_obd *cli)
 {
 	__u64 target_bytes = (cli->cl_max_rpcs_in_flight + 1) *
@@ -921,7 +927,8 @@ int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes)
 	client_obd_list_lock(&cli->cl_loi_list_lock);
 	/* Don't shrink if we are already above or below the desired limit
 	 * We don't want to shrink below a single RPC, as that will negatively
-	 * impact block allocation and long-term performance. */
+	 * impact block allocation and long-term performance.
+	 */
 	if (target_bytes < cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT)
 		target_bytes = cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
 
@@ -969,7 +976,8 @@ static int osc_should_shrink_grant(struct client_obd *client)
 	if (cfs_time_aftereq(time, next_shrink - 5 * CFS_TICK)) {
 		/* Get the current RPC size directly, instead of going via:
 		 * cli_brw_size(obd->u.cli.cl_import->imp_obd->obd_self_export)
-		 * Keep comment here so that it can be found by searching. */
+		 * Keep comment here so that it can be found by searching.
+		 */
 		int brw_size = client->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
 
 		if (client->cl_import->imp_state == LUSTRE_IMP_FULL &&
@@ -1039,7 +1047,8 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 		      cli->cl_import->imp_obd->obd_name, cli->cl_avail_grant,
 		      ocd->ocd_grant, cli->cl_dirty);
 		/* workaround for servers which do not have the patch from
-		 * LU-2679 */
+		 * LU-2679
+		 */
 		cli->cl_avail_grant = ocd->ocd_grant;
 	}
 
@@ -1059,7 +1068,8 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 /* We assume that the reason this OSC got a short read is because it read
  * beyond the end of a stripe file; i.e. lustre is reading a sparse file
  * via the LOV, and it _knows_ it's reading inside the file, it's just that
- * this stripe never got written at or beyond this stripe offset yet. */
+ * this stripe never got written at or beyond this stripe offset yet.
+ */
 static void handle_short_read(int nob_read, u32 page_count,
 			      struct brw_page **pga)
 {
@@ -1138,7 +1148,8 @@ static inline int can_merge_pages(struct brw_page *p1, struct brw_page *p2)
 				  OBD_BRW_SYNC | OBD_BRW_ASYNC|OBD_BRW_NOQUOTA);
 
 		/* warn if we try to combine flags that we don't know to be
-		 * safe to combine */
+		 * safe to combine
+		 */
 		if (unlikely((p1->flag & mask) != (p2->flag & mask))) {
 			CWARN("Saw flags 0x%x and 0x%x in the same brw, please report this at http://bugs.whamcloud.com/\n",
 			      p1->flag, p2->flag);
@@ -1173,7 +1184,8 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 		int count = pga[i]->count > nob ? nob : pga[i]->count;
 
 		/* corrupt the data before we compute the checksum, to
-		 * simulate an OST->client data error */
+		 * simulate an OST->client data error
+		 */
 		if (i == 0 && opc == OST_READ &&
 		    OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE)) {
 			unsigned char *ptr = kmap(pga[i]->pg);
@@ -1204,7 +1216,8 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 		cfs_crypto_hash_final(hdesc, NULL, NULL);
 
 	/* For sending we only compute the wrong checksum instead
-	 * of corrupting the data so it is still correct on a redo */
+	 * of corrupting the data so it is still correct on a redo
+	 */
 	if (opc == OST_WRITE && OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND))
 		cksum++;
 
@@ -1265,7 +1278,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	req->rq_request_portal = OST_IO_PORTAL; /* bug 7198 */
 	ptlrpc_at_set_req_timeout(req);
 	/* ask ptlrpc not to resend on EINPROGRESS since BRWs have their own
-	 * retry logic */
+	 * retry logic
+	 */
 	req->rq_no_retry_einprogress = 1;
 
 	desc = ptlrpc_prep_bulk_imp(req, page_count,
@@ -1292,7 +1306,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	 * that might be send for this request.  The actual number is decided
 	 * when the RPC is finally sent in ptlrpc_register_bulk(). It sends
 	 * "max - 1" for old client compatibility sending "0", and also so the
-	 * the actual maximum is a power-of-two number, not one less. LU-1431 */
+	 * the actual maximum is a power-of-two number, not one less. LU-1431
+	 */
 	ioobj_max_brw_set(ioobj, desc->bd_md_max_brw);
 	LASSERT(page_count > 0);
 	pg_prev = pga[0];
@@ -1354,7 +1369,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		if (cli->cl_checksum &&
 		    !sptlrpc_flavor_has_bulk(&req->rq_flvr)) {
 			/* store cl_cksum_type in a local variable since
-			 * it can be changed via lprocfs */
+			 * it can be changed via lprocfs
+			 */
 			enum cksum_type cksum_type = cli->cl_cksum_type;
 
 			if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0) {
@@ -1374,7 +1390,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			oa->o_flags |= cksum_type_pack(cksum_type);
 		} else {
 			/* clear out the checksum flag, in case this is a
-			 * resend but cl_checksum is no longer set. b=11238 */
+			 * resend but cl_checksum is no longer set. b=11238
+			 */
 			oa->o_valid &= ~OBD_MD_FLCKSUM;
 		}
 		oa->o_cksum = body->oa.o_cksum;
@@ -1637,12 +1654,14 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 		}
 	}
 	/* New request takes over pga and oaps from old request.
-	 * Note that copying a list_head doesn't work, need to move it... */
+	 * Note that copying a list_head doesn't work, need to move it...
+	 */
 	aa->aa_resends++;
 	new_req->rq_interpret_reply = request->rq_interpret_reply;
 	new_req->rq_async_args = request->rq_async_args;
 	/* cap resend delay to the current request timeout, this is similar to
-	 * what ptlrpc does (see after_reply()) */
+	 * what ptlrpc does (see after_reply())
+	 */
 	if (aa->aa_resends > new_req->rq_timeout)
 		new_req->rq_sent = ktime_get_real_seconds() + new_req->rq_timeout;
 	else
@@ -1668,7 +1687,8 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 	/* XXX: This code will run into problem if we're going to support
 	 * to add a series of BRW RPCs into a self-defined ptlrpc_request_set
 	 * and wait for all of them to be finished. We should inherit request
-	 * set from old request. */
+	 * set from old request.
+	 */
 	ptlrpcd_add_req(new_req);
 
 	DEBUG_REQ(D_INFO, new_req, "new request");
@@ -1724,7 +1744,8 @@ static int brw_interpret(const struct lu_env *env,
 	rc = osc_brw_fini_request(req, rc);
 	CDEBUG(D_INODE, "request %p aa %p rc %d\n", req, aa, rc);
 	/* When server return -EINPROGRESS, client should always retry
-	 * regardless of the number of times the bulk was resent already. */
+	 * regardless of the number of times the bulk was resent already.
+	 */
 	if (osc_recoverable_error(rc)) {
 		if (req->rq_import_generation !=
 		    req->rq_import->imp_generation) {
@@ -1797,7 +1818,8 @@ static int brw_interpret(const struct lu_env *env,
 	client_obd_list_lock(&cli->cl_loi_list_lock);
 	/* We need to decrement before osc_ap_completion->osc_wake_cache_waiters
 	 * is called so we know whether to go to sync BRWs or wait for more
-	 * RPCs to complete */
+	 * RPCs to complete
+	 */
 	if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE)
 		cli->cl_w_in_flight--;
 	else
@@ -1937,7 +1959,8 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	 * we race with setattr (locally or in queue at OST).  If OST gets
 	 * later setattr before earlier BRW (as determined by the request xid),
 	 * the OST will not use BRW timestamps.  Sadly, there is no obvious
-	 * way to do this in a single call.  bug 10150 */
+	 * way to do this in a single call.  bug 10150
+	 */
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
 	crattr->cra_oa = &body->oa;
 	cl_req_attr_set(env, clerq, crattr,
@@ -1954,7 +1977,8 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	aa->aa_clerq = clerq;
 
 	/* queued sync pages can be torn down while the pages
-	 * were between the pending list and the rpc */
+	 * were between the pending list and the rpc
+	 */
 	tmp = NULL;
 	list_for_each_entry(oap, &aa->aa_oaps, oap_rpc_item) {
 		/* only one oap gets a request reference */
@@ -2006,7 +2030,8 @@ out:
 			kmem_cache_free(obdo_cachep, oa);
 		kfree(pga);
 		/* this should happen rarely and is pretty bad, it makes the
-		 * pending list not follow the dirty order */
+		 * pending list not follow the dirty order
+		 */
 		while (!list_empty(ext_list)) {
 			ext = list_entry(ext_list->next, struct osc_extent,
 					     oe_link);
@@ -2062,7 +2087,8 @@ static int osc_set_data_with_check(struct lustre_handle *lockh,
 /* find any ldlm lock of the inode in osc
  * return 0    not find
  *	1    find one
- *      < 0    error */
+ *      < 0    error
+ */
 static int osc_find_cbdata(struct obd_export *exp, struct lov_stripe_md *lsm,
 			   ldlm_iterator_t replace, void *data)
 {
@@ -2124,18 +2150,21 @@ static int osc_enqueue_interpret(const struct lu_env *env,
 	__u64 *flags = aa->oa_flags;
 
 	/* Make a local copy of a lock handle and a mode, because aa->oa_*
-	 * might be freed anytime after lock upcall has been called. */
+	 * might be freed anytime after lock upcall has been called.
+	 */
 	lustre_handle_copy(&handle, aa->oa_lockh);
 	mode = aa->oa_ei->ei_mode;
 
 	/* ldlm_cli_enqueue is holding a reference on the lock, so it must
-	 * be valid. */
+	 * be valid.
+	 */
 	lock = ldlm_handle2lock(&handle);
 
 	/* Take an additional reference so that a blocking AST that
 	 * ldlm_cli_enqueue_fini() might post for a failed lock, is guaranteed
 	 * to arrive after an upcall has been executed by
-	 * osc_enqueue_fini(). */
+	 * osc_enqueue_fini().
+	 */
 	ldlm_lock_addref(&handle, mode);
 
 	/* Let CP AST to grant the lock first. */
@@ -2182,7 +2211,8 @@ struct ptlrpc_request_set *PTLRPCD_SET = (void *)1;
  * others may take a considerable amount of time in a case of ost failure; and
  * when other sync requests do not get released lock from a client, the client
  * is excluded from the cluster -- such scenarious make the life difficult, so
- * release locks just after they are obtained. */
+ * release locks just after they are obtained.
+ */
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     __u64 *flags, ldlm_policy_data_t *policy,
 		     struct ost_lvb *lvb, int kms_valid,
@@ -2199,7 +2229,8 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	int rc;
 
 	/* Filesystem lock extents are extended to page boundaries so that
-	 * dealing with the page cache is a little smoother.  */
+	 * dealing with the page cache is a little smoother.
+	 */
 	policy->l_extent.start -= policy->l_extent.start & ~CFS_PAGE_MASK;
 	policy->l_extent.end |= ~CFS_PAGE_MASK;
 
@@ -2223,7 +2254,8 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	 *
 	 * At some point we should cancel the read lock instead of making them
 	 * send us a blocking callback, but there are problems with canceling
-	 * locks out from other users right now, too. */
+	 * locks out from other users right now, too.
+	 */
 	mode = einfo->ei_mode;
 	if (einfo->ei_mode == LCK_PR)
 		mode |= LCK_PW;
@@ -2235,7 +2267,8 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		if ((agl != 0) && !(matched->l_flags & LDLM_FL_LVB_READY)) {
 			/* For AGL, if enqueue RPC is sent but the lock is not
 			 * granted, then skip to process this strpe.
-			 * Return -ECANCELED to tell the caller. */
+			 * Return -ECANCELED to tell the caller.
+			 */
 			ldlm_lock_decref(lockh, mode);
 			LDLM_LOCK_PUT(matched);
 			return -ECANCELED;
@@ -2244,19 +2277,22 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		if (osc_set_lock_data_with_check(matched, einfo)) {
 			*flags |= LDLM_FL_LVB_READY;
 			/* addref the lock only if not async requests and PW
-			 * lock is matched whereas we asked for PR. */
+			 * lock is matched whereas we asked for PR.
+			 */
 			if (!rqset && einfo->ei_mode != mode)
 				ldlm_lock_addref(lockh, LCK_PR);
 			if (intent) {
 				/* I would like to be able to ASSERT here that
 				 * rss <= kms, but I can't, for reasons which
-				 * are explained in lov_enqueue() */
+				 * are explained in lov_enqueue()
+				 */
 			}
 
 			/* We already have a lock, and it's referenced.
 			 *
 			 * At this point, the cl_lock::cll_state is CLS_QUEUING,
-			 * AGL upcall may change it to CLS_HELD directly. */
+			 * AGL upcall may change it to CLS_HELD directly.
+			 */
 			(*upcall)(cookie, ELDLM_OK);
 
 			if (einfo->ei_mode != mode)
@@ -2344,14 +2380,16 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		return -EIO;
 
 	/* Filesystem lock extents are extended to page boundaries so that
-	 * dealing with the page cache is a little smoother */
+	 * dealing with the page cache is a little smoother
+	 */
 	policy->l_extent.start -= policy->l_extent.start & ~CFS_PAGE_MASK;
 	policy->l_extent.end |= ~CFS_PAGE_MASK;
 
 	/* Next, search for already existing extent locks that will cover us */
 	/* If we're trying to read, we also search for an existing PW lock.  The
 	 * VFS and page cache already protect us locally, so lots of readers/
-	 * writers can share a single PW lock. */
+	 * writers can share a single PW lock.
+	 */
 	rc = mode;
 	if (mode == LCK_PR)
 		rc |= LCK_PW;
@@ -2395,7 +2433,8 @@ static int osc_statfs_interpret(const struct lu_env *env,
 		 * due to issues at a higher level (LOV).
 		 * Exit immediately since the caller is
 		 * aware of the problem and takes care
-		 * of the clean up */
+		 * of the clean up
+		 */
 		 return rc;
 
 	if ((rc == -ENOTCONN || rc == -EAGAIN) &&
@@ -2433,7 +2472,8 @@ static int osc_statfs_async(struct obd_export *exp,
 	 * extra calls into the filesystem if that isn't necessary (e.g.
 	 * during mount that would help a bit).  Having relative timestamps
 	 * is not so great if request processing is slow, while absolute
-	 * timestamps are not ideal because they need time synchronization. */
+	 * timestamps are not ideal because they need time synchronization.
+	 */
 	req = ptlrpc_request_alloc(obd->u.cli.cl_import, &RQF_OST_STATFS);
 	if (!req)
 		return -ENOMEM;
@@ -2471,8 +2511,9 @@ static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
 	struct obd_import *imp = NULL;
 	int rc;
 
-	/*Since the request might also come from lprocfs, so we need
-	 *sync this with client_disconnect_export Bug15684*/
+	/* Since the request might also come from lprocfs, so we need
+	 * sync this with client_disconnect_export Bug15684
+	 */
 	down_read(&obd->u.cli.cl_sem);
 	if (obd->u.cli.cl_import)
 		imp = class_import_get(obd->u.cli.cl_import);
@@ -2485,7 +2526,8 @@ static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
 	 * extra calls into the filesystem if that isn't necessary (e.g.
 	 * during mount that would help a bit).  Having relative timestamps
 	 * is not so great if request processing is slow, while absolute
-	 * timestamps are not ideal because they need time synchronization. */
+	 * timestamps are not ideal because they need time synchronization.
+	 */
 	req = ptlrpc_request_alloc(imp, &RQF_OST_STATFS);
 
 	class_import_put(imp);
@@ -2543,7 +2585,8 @@ static int osc_getstripe(struct lov_stripe_md *lsm,
 		return -ENODATA;
 
 	/* we only need the header part from user space to get lmm_magic and
-	 * lmm_stripe_count, (the header part is common to v1 and v3) */
+	 * lmm_stripe_count, (the header part is common to v1 and v3)
+	 */
 	lum_size = sizeof(struct lov_user_md_v1);
 	if (copy_from_user(&lum, lump, lum_size))
 		return -EFAULT;
@@ -2558,7 +2601,8 @@ static int osc_getstripe(struct lov_stripe_md *lsm,
 	LASSERT(sizeof(lum.lmm_objects[0]) == sizeof(lumk->lmm_objects[0]));
 
 	/* we can use lov_mds_md_size() to compute lum_size
-	 * because lov_user_md_vX and lov_mds_md_vX have the same size */
+	 * because lov_user_md_vX and lov_mds_md_vX have the same size
+	 */
 	if (lum.lmm_stripe_count > 0) {
 		lum_size = lov_mds_md_size(lum.lmm_stripe_count, lum.lmm_magic);
 		lumk = kzalloc(lum_size, GFP_NOFS);
@@ -2878,11 +2922,12 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		return -EINVAL;
 
 	/* We pass all other commands directly to OST. Since nobody calls osc
-	   methods directly and everybody is supposed to go through LOV, we
-	   assume lov checked invalid values for us.
-	   The only recognised values so far are evict_by_nid and mds_conn.
-	   Even if something bad goes through, we'd get a -EINVAL from OST
-	   anyway. */
+	 * methods directly and everybody is supposed to go through LOV, we
+	 * assume lov checked invalid values for us.
+	 * The only recognised values so far are evict_by_nid and mds_conn.
+	 * Even if something bad goes through, we'd get a -EINVAL from OST
+	 * anyway.
+	 */
 
 	req = ptlrpc_request_alloc(imp, KEY_IS(KEY_GRANT_SHRINK) ?
 						&RQF_OST_SET_GRANT_INFO :
@@ -3022,7 +3067,8 @@ static int osc_import_event(struct obd_device *obd,
 			/* Reset grants */
 			cli = &obd->u.cli;
 			/* all pages go to failing rpcs due to the invalid
-			 * import */
+			 * import
+			 */
 			osc_io_unplug(env, cli, NULL);
 
 			ldlm_namespace_cleanup(ns, LDLM_FL_LOCAL_ONLY);
@@ -3296,7 +3342,8 @@ static int __init osc_init(void)
 
 	/* print an address of _any_ initialized kernel symbol from this
 	 * module, to allow debugging with gdb that doesn't support data
-	 * symbols from modules.*/
+	 * symbols from modules.
+	 */
 	CDEBUG(D_INFO, "Lustre OSC module (%p).\n", &osc_caches);
 
 	rc = lu_kmem_init(osc_caches);
-- 
2.1.0
