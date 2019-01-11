From: NeilBrown <neilb@suse.com>
Date: Fri, 11 Jan 2019 11:48:56 +1100
Subject: [lustre-devel] [PATCH 27/29] lustre: osc_cache: white-space and
 other checkpatch fixes.
In-Reply-To: <058406C4-B01E-4DD5-8EBB-3014A23CA963@whamcloud.com>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504274.26726.6932313520085605572.stgit@noble>
 <058406C4-B01E-4DD5-8EBB-3014A23CA963@whamcloud.com>
Message-ID: <87d0p4ggsn.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jan 10 2019, Andreas Dilger wrote:

> On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
>> 
>> Assorted minor checkpatch issues fixed.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> drivers/staging/lustre/lustre/osc/osc_cache.c |   25 +++++++++++++------------
>> 1 file changed, 13 insertions(+), 12 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
>> index e01f3815978c..019854b78277 100644
>> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
>> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
>> @@ -962,7 +962,6 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
>> 
>> 		wait_event_idle(ext->oe_waitq,
>> 				smp_load_acquire(&ext->oe_state) == state);
>> -
>> 	}
>> 	return ext->oe_rc < 0 ? ext->oe_rc : 0;
>> }
>
> Typically we prefer a blank line before return.  Otherwise fine.

Interesting ... I had a look through osc_cache.c and I can find some
evidence of this preference, but also many cases of the opposite.

While I do see the value in a lot of places, this is one place where I
I'm not so sure.  Specifically, if the line before "return" is a lone "}", it
seems (visually) close enough to a blank line, that adding another line
looks wasteful.
After some debate I have added blank lines there, but not when the
'return' is followed by an 'LASSERT' or other debugging code.

Here is the new version.

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Subject: [PATCH] lustre: osc_cache: white-space and other checkpatch fixes.

Assorted minor checkpatch issues fixed.

Also add some blank links to help 'return' lines to stand out.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c | 61 +++++++++++++++++++++------
 1 file changed, 49 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d89edad9fbc5..902e5fd3f501 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -91,6 +91,7 @@ static inline char *ext_flags(struct osc_extent *ext, char *flags)
 	if (ext->oe_fsync_wait)
 		*buf++ = 'Y';
 	*buf = 0;
+
 	return flags;
 }
 
@@ -101,7 +102,7 @@ static inline char list_empty_marker(struct list_head *list)
 
 #define EXTSTR       "[%lu -> %lu/%lu]"
 #define EXTPARA(ext) (ext)->oe_start, (ext)->oe_end, (ext)->oe_max_end
-static const char *oes_strings[] = {
+static const char * const oes_strings[] = {
 	"inv", "active", "cache", "locking", "lockdone", "rpc", "trunc", NULL };
 
 #define OSC_EXTENT_DUMP(lvl, extent, fmt, ...) do {			      \
@@ -337,6 +338,7 @@ static int osc_extent_is_overlapped(struct osc_object *obj,
 		if (overlapped(tmp, ext))
 			return 1;
 	}
+
 	return 0;
 }
 
@@ -404,6 +406,7 @@ static struct osc_extent *osc_extent_get(struct osc_extent *ext)
 {
 	LASSERT(kref_read(&ext->oe_refc) >= 0);
 	kref_get(&ext->oe_refc);
+
 	return ext;
 }
 
@@ -454,6 +457,7 @@ static struct osc_extent *osc_extent_search(struct osc_object *obj,
 			return tmp;
 		}
 	}
+
 	return p;
 }
 
@@ -469,6 +473,7 @@ static struct osc_extent *osc_extent_lookup(struct osc_object *obj,
 	ext = osc_extent_search(obj, index);
 	if (ext && ext->oe_start <= index && index <= ext->oe_end)
 		return osc_extent_get(ext);
+
 	return NULL;
 }
 
@@ -524,6 +529,7 @@ static struct osc_extent *osc_extent_hold(struct osc_extent *ext)
 	}
 	refcount_inc(&ext->oe_users);
 	list_del_init(&ext->oe_link);
+
 	return osc_extent_get(ext);
 }
 
@@ -668,7 +674,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 					  unsigned int *grants)
 {
 	struct client_obd *cli = osc_cli(obj);
-	struct osc_lock   *olck;
+	struct osc_lock *olck;
 	struct cl_lock_descr *descr;
 	struct osc_extent *cur;
 	struct osc_extent *ext;
@@ -705,6 +711,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	if ((max_pages & ~chunk_mask) != 0) {
 		CERROR("max_pages: %#x chunkbits: %u chunk_mask: %#lx\n",
 		       max_pages, cli->cl_chunkbits, chunk_mask);
+
 		return ERR_PTR(-EINVAL);
 	}
 	max_end = index - (index % max_pages) + max_pages - 1;
@@ -858,6 +865,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 
 out:
 	osc_extent_put(env, cur);
+
 	return found;
 }
 
@@ -919,6 +927,7 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 	osc_extent_remove(ext);
 	/* put the refcount for RPC */
 	osc_extent_put(env, ext);
+
 	return 0;
 }
 
@@ -962,8 +971,8 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 
 		wait_event_idle(ext->oe_waitq,
 				smp_load_acquire(&ext->oe_state) == state);
-
 	}
+
 	return ext->oe_rc < 0 ? ext->oe_rc : 0;
 }
 
@@ -1020,7 +1029,8 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 		if (index < trunc_index ||
 		    (index == trunc_index && partial)) {
 			/* accounting how many pages remaining in the chunk
-			 * so that we can calculate grants correctly. */
+			 * so that we can calculate grants correctly.
+			 */
 			if (index >> ppc_bits == trunc_chunk)
 				++pages_in_chunk;
 			continue;
@@ -1087,6 +1097,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 out:
 	cl_io_fini(env, io);
 	cl_env_put(env, &refcheck);
+
 	return rc;
 }
 
@@ -1141,7 +1152,8 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	 * the size of file.
 	 */
 	if (!(last->oap_async_flags & ASYNC_COUNT_STABLE)) {
-		int last_oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
+		int last_oap_count = osc_refresh_count(env, last,
+						       OBD_BRW_WRITE);
 
 		LASSERT(last_oap_count > 0);
 		LASSERT(last->oap_page_off + last_oap_count <= PAGE_SIZE);
@@ -1233,6 +1245,7 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index,
 
 out:
 	osc_object_unlock(obj);
+
 	return rc;
 }
 
@@ -1299,6 +1312,7 @@ static int osc_make_ready(const struct lu_env *env, struct osc_async_page *oap,
 	result = cl_page_make_ready(env, page, CRT_WRITE);
 	if (result == 0)
 		opg->ops_submit_time = jiffies;
+
 	return result;
 }
 
@@ -1322,6 +1336,7 @@ static int osc_refresh_count(const struct lu_env *env,
 	cl_object_attr_unlock(obj);
 	if (result < 0)
 		return result;
+
 	kms = attr->cat_kms;
 	if (cl_offset(obj, index) >= kms)
 		/* catch race with truncate */
@@ -1337,7 +1352,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 			  int cmd, int rc)
 {
 	struct osc_page *opg = oap2osc_page(oap);
-	struct cl_page    *page = oap2cl_page(oap);
+	struct cl_page *page = oap2cl_page(oap);
 	enum cl_req_type crt;
 	int srvlock;
 
@@ -1441,6 +1456,7 @@ static int osc_reserve_grant(struct client_obd *cli, unsigned int bytes)
 		cli->cl_reserved_grant += bytes;
 		rc = 0;
 	}
+
 	return rc;
 }
 
@@ -1641,6 +1657,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	}
 out:
 	spin_unlock(&cli->cl_loi_list_lock);
+
 	return rc;
 }
 
@@ -1731,7 +1748,8 @@ static void osc_update_pending(struct osc_object *obj, int cmd, int delta)
 	OSC_IO_DEBUG(obj, "update pending cmd %d delta %d.\n", cmd, delta);
 }
 
-static void on_list(struct list_head *item, struct list_head *list, int should_be_on)
+static void on_list(struct list_head *item, struct list_head *list,
+		    int should_be_on)
 {
 	if (list_empty(item) && should_be_on)
 		list_add_tail(item, list);
@@ -1790,6 +1808,7 @@ static void osc_process_ar(struct osc_async_rc *ar, __u64 xid,
 
 		ar->ar_force_sync = 1;
 		ar->ar_min_xid = ptlrpc_sample_next_xid();
+
 		return;
 	}
 
@@ -1893,7 +1912,8 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 					oap_pending_item);
 		EASSERT(tmp->oe_owner == current, tmp);
 		if (oap2cl_page(oap)->cp_type != oap2cl_page(oap2)->cp_type) {
-			CDEBUG(D_CACHE, "Do not permit different type of IO in one RPC\n");
+			CDEBUG(D_CACHE,
+			       "Do not permit different type of IO in one RPC\n");
 			return 0;
 		}
 
@@ -1911,6 +1931,7 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 	data->erd_page_count += ext->oe_nr_pages;
 	list_move_tail(&ext->oe_link, data->erd_rpc_list);
 	ext->oe_owner = current;
+
 	return 1;
 }
 
@@ -2012,6 +2033,7 @@ static unsigned int get_write_extents(struct osc_object *obj,
 		if (!try_to_add_extent_for_io(cli, ext, &data))
 			return data.erd_page_count;
 	}
+
 	return data.erd_page_count;
 }
 
@@ -2035,6 +2057,7 @@ osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
 
 	if (list_empty(&rpclist)) {
 		osc_object_unlock(osc);
+
 		return 0;
 	}
 
@@ -2109,6 +2132,7 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 	osc_object_lock(osc);
 	if (!osc_makes_rpc(cli, osc, OBD_BRW_READ)) {
 		osc_object_unlock(osc);
+
 		return rc;
 	}
 
@@ -2125,11 +2149,10 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 
 	osc_object_unlock(osc);
 	if (!list_empty(&rpclist)) {
-
 		rc = osc_build_rpc(env, cli, &rpclist, OBD_BRW_READ);
 		LASSERT(list_empty(&rpclist));
-
 	}
+
 	return rc;
 }
 
@@ -2150,6 +2173,7 @@ static struct osc_object *osc_next_obj(struct client_obd *cli)
 	 */
 	if (!list_empty(&cli->cl_loi_hp_ready_list))
 		return list_to_obj(&cli->cl_loi_hp_ready_list, hp_ready_item);
+
 	if (!list_empty(&cli->cl_loi_ready_list))
 		return list_to_obj(&cli->cl_loi_ready_list, ready_item);
 
@@ -2168,9 +2192,11 @@ static struct osc_object *osc_next_obj(struct client_obd *cli)
 	if (!cli->cl_import || cli->cl_import->imp_invalid) {
 		if (!list_empty(&cli->cl_loi_write_list))
 			return list_to_obj(&cli->cl_loi_write_list, write_item);
+
 		if (!list_empty(&cli->cl_loi_read_list))
 			return list_to_obj(&cli->cl_loi_read_list, read_item);
 	}
+
 	return NULL;
 }
 
@@ -2254,6 +2280,7 @@ static int __osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 		LASSERT(cli->cl_writeback_work);
 		rc = ptlrpcd_queue_work(cli->cl_writeback_work);
 	}
+
 	return rc;
 }
 
@@ -2295,6 +2322,7 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 	spin_lock_init(&oap->oap_lock);
 	CDEBUG(D_INFO, "oap %p page %p obj off %llu\n",
 	       oap, page, oap->oap_obj_off);
+
 	return 0;
 }
 
@@ -2464,6 +2492,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		list_add_tail(&oap->oap_pending_item, &ext->oe_pages);
 		osc_object_unlock(osc);
 	}
+
 	return rc;
 }
 
@@ -2499,6 +2528,7 @@ int osc_teardown_async_page(const struct lu_env *env,
 		if (ext)
 			osc_extent_put(env, ext);
 	}
+
 	return rc;
 }
 
@@ -2582,6 +2612,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 	osc_extent_put(env, ext);
 	if (unplug)
 		osc_io_unplug_async(env, osc_cli(obj), obj);
+
 	return rc;
 }
 
@@ -2620,6 +2651,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 			list_del_init(&oap->oap_pending_item);
 			osc_ap_completion(env, cli, oap, 0, -ENOMEM);
 		}
+
 		return -ENOMEM;
 	}
 
@@ -2649,6 +2681,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 	osc_object_unlock(obj);
 
 	osc_io_unplug_async(env, cli, obj);
+
 	return 0;
 }
 
@@ -2777,6 +2810,7 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
 		waiting = NULL;
 		goto again;
 	}
+
 	return result;
 }
 
@@ -3070,6 +3104,7 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 	}
 	if (tree_lock)
 		spin_unlock(&osc->oo_tree_lock);
+
 	return res;
 }
 
@@ -3077,7 +3112,7 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
  * Check if page @page is covered by an extra lock or discard it.
  */
 static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
-				struct osc_page *ops, void *cbdata)
+				 struct osc_page *ops, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct osc_object *osc = cbdata;
@@ -3112,11 +3147,12 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 	}
 
 	info->oti_next_index = index + 1;
+
 	return true;
 }
 
 static bool discard_cb(const struct lu_env *env, struct cl_io *io,
-		      struct osc_page *ops, void *cbdata)
+		       struct osc_page *ops, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct cl_page *page = ops->ops_cl.cpl_page;
@@ -3170,6 +3206,7 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 				   info->oti_next_index, end, cb, osc);
 out:
 	cl_io_fini(env, io);
+
 	return result;
 }
 
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190111/3edabe33/attachment-0001.sig>
