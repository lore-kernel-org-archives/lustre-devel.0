From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:25:53 -0400
Subject: [lustre-devel] [PATCH 01/31] lustre: osc: Send RPCs when extents
 are full
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

Currently, Lustre decides to send an RPC under a number of
conditions (such as memory pressure or lock cancellcation);
one of the conditions it looks for is "enough dirty pages
to fill an RPC". This worked fine when only one process
could be dirtying pages at a time, but in newer Lustre
versions, more than one process can write to the same
file (and the same osc object) at once.

In this case, the "count dirty pages method" will see there
are enough dirty pages to fill an RPC, but since the dirty
pages are being created by multiple writers, they are not
contiguous and will not fit in to one RPC. This resulted in
many RPCs of less than full size being sent, despite a
good I/O pattern. (Earlier versions of Lustre usually
send only full RPCs when presented with this pattern.)

Instead, we remove this check and add extents to a special
full extent list when they reach max pages per RPC, then
send from that list. (This is similar to high priority
and urgent extents.)

With a good I/O pattern, like usually used in benchmarking,
it should be possible to send only full size RPCs. This
patch achieves that without degrading performance in other
cases.

In IOR tests with multiple writers to a single file,
this patch improves performance by several times, and
returns performance to equal levels (single striped files)
or much greater levels (very high speed OSTs, files
with many stripes) vs earlier versions.

Supporting data is provided in LU-8515.

Signed-off-by: Patrick Farrell <paf@cray.com>
Intel-bug-id: https://jira.whamcloud.com/browse/LU-8515
Reviewed-on: https://review.whamcloud.com/22012
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 45 ++++++++++++++--------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  2 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |  4 +-
 3 files changed, 32 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 87d0d16..e44822a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -634,6 +634,10 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext)
 			if (ext->oe_urgent)
 				list_move_tail(&ext->oe_link,
 					       &obj->oo_urgent_exts);
+			else if (ext->oe_nr_pages == ext->oe_mppr) {
+				list_move_tail(&ext->oe_link,
+					       &obj->oo_full_exts);
+			}
 		}
 		osc_object_unlock(obj);
 
@@ -1790,9 +1794,10 @@ static int osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
 			CDEBUG(D_CACHE, "cache waiters forcing RPC\n");
 			return 1;
 		}
-		if (atomic_read(&osc->oo_nr_writes) >=
-		    cli->cl_max_pages_per_rpc)
+		if (!list_empty(&osc->oo_full_exts)) {
+			CDEBUG(D_CACHE, "full extent ready, make an RPC\n");
 			return 1;
+		}
 	} else {
 		if (atomic_read(&osc->oo_nr_reads) == 0)
 			return 0;
@@ -1963,6 +1968,7 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 
 	EASSERT((ext->oe_state == OES_CACHE || ext->oe_state == OES_LOCK_DONE),
 		ext);
+	OSC_EXTENT_DUMP(D_CACHE, ext, "trying to add this extent\n");
 
 	if (!data->erd_max_extents)
 		return 0;
@@ -2085,19 +2091,22 @@ static unsigned int get_write_extents(struct osc_object *obj,
 				 struct osc_extent, oe_link);
 		if (!try_to_add_extent_for_io(cli, ext, &data))
 			return data.erd_page_count;
+	}
+	if (data.erd_page_count == data.erd_max_pages)
+		return data.erd_page_count;
 
-		if (!ext->oe_intree)
-			continue;
-
-		while ((ext = next_extent(ext)) != NULL) {
-			if ((ext->oe_state != OES_CACHE) ||
-			    (!list_empty(&ext->oe_link) &&
-			     ext->oe_owner))
-				continue;
-
-			if (!try_to_add_extent_for_io(cli, ext, &data))
-				return data.erd_page_count;
-		}
+	/*
+	 * One key difference between full extents and other extents: full
+	 * extents can usually only be added if the rpclist was empty, so if we
+	 * can't add one, we continue on to trying to add normal extents.  This
+	 * is so we don't miss adding extra extents to an RPC containing high
+	 * priority or urgent extents.
+	 */
+	while (!list_empty(&obj->oo_full_exts)) {
+		ext = list_entry(obj->oo_full_exts.next,
+				 struct osc_extent, oe_link);
+		if (!try_to_add_extent_for_io(cli, ext, &data))
+			break;
 	}
 	if (data.erd_page_count == data.erd_max_pages)
 		return data.erd_page_count;
@@ -2879,8 +2888,12 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
 			osc_update_pending(obj, OBD_BRW_WRITE,
 					   -ext->oe_nr_pages);
 		}
-		EASSERT(list_empty(&ext->oe_link), ext);
-		list_add_tail(&ext->oe_link, &list);
+		/* This extent could be on the full extents list, that's OK */
+		EASSERT(!ext->oe_hp && !ext->oe_urgent, ext);
+		if (!list_empty(&ext->oe_link))
+			list_move_tail(&ext->oe_link, &list);
+		else
+			list_add_tail(&ext->oe_link, &list);
 
 		ext = next_extent(ext);
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index d86d3f7..da04c2c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -139,7 +139,7 @@ struct osc_object {
 	 */
 	struct list_head	   oo_hp_exts; /* list of hp extents */
 	struct list_head	   oo_urgent_exts; /* list of writeback extents */
-	struct list_head	   oo_rpc_exts;
+	struct list_head	   oo_full_exts;
 
 	struct list_head	   oo_reading_exts;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 8424018..b9bf2b8 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -85,7 +85,7 @@ static int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 	osc->oo_root.rb_node = NULL;
 	INIT_LIST_HEAD(&osc->oo_hp_exts);
 	INIT_LIST_HEAD(&osc->oo_urgent_exts);
-	INIT_LIST_HEAD(&osc->oo_rpc_exts);
+	INIT_LIST_HEAD(&osc->oo_full_exts);
 	INIT_LIST_HEAD(&osc->oo_reading_exts);
 	atomic_set(&osc->oo_nr_reads, 0);
 	atomic_set(&osc->oo_nr_writes, 0);
@@ -111,7 +111,7 @@ static void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 	LASSERT(!osc->oo_root.rb_node);
 	LASSERT(list_empty(&osc->oo_hp_exts));
 	LASSERT(list_empty(&osc->oo_urgent_exts));
-	LASSERT(list_empty(&osc->oo_rpc_exts));
+	LASSERT(list_empty(&osc->oo_full_exts));
 	LASSERT(list_empty(&osc->oo_reading_exts));
 	LASSERT(atomic_read(&osc->oo_nr_reads) == 0);
 	LASSERT(atomic_read(&osc->oo_nr_writes) == 0);
-- 
1.8.3.1
