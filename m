From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:00 -0500
Subject: [lustre-devel] [PATCH 32/60] staging: lustre: osc: limits the
	number of chunks in write RPC
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

OSC has to make sure that it won't issue write RPCs with too many
chunks otherwise it will casue ZFS to create transactions much
bigger than DMU_MAX_ACCESS in size, which will end up with write
failure.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8135
Reviewed-on: http://review.whamcloud.com/22369
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8632
Reviewed-on: http://review.whamcloud.com/22654
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c | 124 ++++++++++++++++++--------
 1 file changed, 87 insertions(+), 37 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 72dd554..0490478 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1882,16 +1882,32 @@ static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 		       oap, osc, rc);
 }
 
+struct extent_rpc_data {
+	struct list_head       *erd_rpc_list;
+	unsigned int		erd_page_count;
+	unsigned int		erd_max_pages;
+	unsigned int		erd_max_chunks;
+};
+
+static inline unsigned osc_extent_chunks(const struct osc_extent *ext)
+{
+	struct client_obd *cli = osc_cli(ext->oe_obj);
+	unsigned ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
+
+	return (ext->oe_end >> ppc_bits) - (ext->oe_start >> ppc_bits) + 1;
+}
+
 /**
  * Try to add extent to one RPC. We need to think about the following things:
  * - # of pages must not be over max_pages_per_rpc
  * - extent must be compatible with previous ones
  */
 static int try_to_add_extent_for_io(struct client_obd *cli,
-				    struct osc_extent *ext, struct list_head *rpclist,
-				    unsigned int *pc, unsigned int *max_pages)
+				    struct osc_extent *ext,
+				    struct extent_rpc_data *data)
 {
 	struct osc_extent *tmp;
+	unsigned int chunk_count;
 	struct osc_async_page *oap = list_first_entry(&ext->oe_pages,
 						      struct osc_async_page,
 						      oap_pending_item);
@@ -1899,19 +1915,22 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 	EASSERT((ext->oe_state == OES_CACHE || ext->oe_state == OES_LOCK_DONE),
 		ext);
 
-	*max_pages = max(ext->oe_mppr, *max_pages);
-	if (*pc + ext->oe_nr_pages > *max_pages)
+	chunk_count = osc_extent_chunks(ext);
+	if (chunk_count > data->erd_max_chunks)
+		return 0;
+
+	data->erd_max_pages = max(ext->oe_mppr, data->erd_max_pages);
+	if (data->erd_page_count + ext->oe_nr_pages > data->erd_max_pages)
 		return 0;
 
-	list_for_each_entry(tmp, rpclist, oe_link) {
+	list_for_each_entry(tmp, data->erd_rpc_list, oe_link) {
 		struct osc_async_page *oap2;
 
 		oap2 = list_first_entry(&tmp->oe_pages, struct osc_async_page,
 					oap_pending_item);
 		EASSERT(tmp->oe_owner == current, tmp);
 		if (oap2cl_page(oap)->cp_type != oap2cl_page(oap2)->cp_type) {
-			CDEBUG(D_CACHE, "Do not permit different type of IO"
-					" for a same RPC\n");
+			CDEBUG(D_CACHE, "Do not permit different type of IO in one RPC\n");
 			return 0;
 		}
 
@@ -1924,12 +1943,41 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 		break;
 	}
 
-	*pc += ext->oe_nr_pages;
-	list_move_tail(&ext->oe_link, rpclist);
+	data->erd_max_chunks -= chunk_count;
+	data->erd_page_count += ext->oe_nr_pages;
+	list_move_tail(&ext->oe_link, data->erd_rpc_list);
 	ext->oe_owner = current;
 	return 1;
 }
 
+static inline unsigned osc_max_write_chunks(const struct client_obd *cli)
+{
+	/*
+	 * LU-8135:
+	 *
+	 * The maximum size of a single transaction is about 64MB in ZFS.
+	 * #define DMU_MAX_ACCESS (64 * 1024 * 1024)
+	 *
+	 * Since ZFS is a copy-on-write file system, a single dirty page in
+	 * a chunk will result in the rewrite of the whole chunk, therefore
+	 * an RPC shouldn't be allowed to contain too many chunks otherwise
+	 * it will make transaction size much bigger than 64MB, especially
+	 * with big block size for ZFS.
+	 *
+	 * This piece of code is to make sure that OSC won't send write RPCs
+	 * with too many chunks. The maximum chunk size that an RPC can cover
+	 * is set to PTLRPC_MAX_BRW_SIZE, which is defined to 16MB. Ideally
+	 * OST should tell the client what the biggest transaction size is,
+	 * but it's good enough for now.
+	 *
+	 * This limitation doesn't apply to ldiskfs, which allows as many
+	 * chunks in one RPC as we want. However, it won't have any benefits
+	 * to have too many discontiguous pages in one RPC. Therefore, it
+	 * can only have 256 chunks at most in one RPC.
+	 */
+	return min(PTLRPC_MAX_BRW_SIZE >> cli->cl_chunkbits, 256);
+}
+
 /**
  * In order to prevent multiple ptlrpcd from breaking contiguous extents,
  * get_write_extent() takes all appropriate extents in atomic.
@@ -1949,26 +1997,28 @@ static unsigned int get_write_extents(struct osc_object *obj,
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_extent *ext;
 	struct osc_extent *temp;
-	unsigned int page_count = 0;
-	unsigned int max_pages = cli->cl_max_pages_per_rpc;
+	struct extent_rpc_data data = {
+		.erd_rpc_list = rpclist,
+		.erd_page_count = 0,
+		.erd_max_pages = cli->cl_max_pages_per_rpc,
+		.erd_max_chunks = osc_max_write_chunks(cli),
+	};
 
 	LASSERT(osc_object_is_locked(obj));
 	list_for_each_entry_safe(ext, temp, &obj->oo_hp_exts, oe_link) {
 		LASSERT(ext->oe_state == OES_CACHE);
-		if (!try_to_add_extent_for_io(cli, ext, rpclist, &page_count,
-					      &max_pages))
-			return page_count;
-		EASSERT(ext->oe_nr_pages <= max_pages, ext);
+		if (!try_to_add_extent_for_io(cli, ext, &data))
+			return data.erd_page_count;
+		EASSERT(ext->oe_nr_pages <= data.erd_max_pages, ext);
 	}
-	if (page_count == max_pages)
-		return page_count;
+	if (data.erd_page_count == data.erd_max_pages)
+		return data.erd_page_count;
 
 	while (!list_empty(&obj->oo_urgent_exts)) {
 		ext = list_entry(obj->oo_urgent_exts.next,
 				 struct osc_extent, oe_link);
-		if (!try_to_add_extent_for_io(cli, ext, rpclist, &page_count,
-					      &max_pages))
-			return page_count;
+		if (!try_to_add_extent_for_io(cli, ext, &data))
+			return data.erd_page_count;
 
 		if (!ext->oe_intree)
 			continue;
@@ -1979,13 +2029,12 @@ static unsigned int get_write_extents(struct osc_object *obj,
 			     ext->oe_owner))
 				continue;
 
-			if (!try_to_add_extent_for_io(cli, ext, rpclist,
-						      &page_count, &max_pages))
-				return page_count;
+			if (!try_to_add_extent_for_io(cli, ext, &data))
+				return data.erd_page_count;
 		}
 	}
-	if (page_count == max_pages)
-		return page_count;
+	if (data.erd_page_count == data.erd_max_pages)
+		return data.erd_page_count;
 
 	ext = first_extent(obj);
 	while (ext) {
@@ -1996,13 +2045,12 @@ static unsigned int get_write_extents(struct osc_object *obj,
 			continue;
 		}
 
-		if (!try_to_add_extent_for_io(cli, ext, rpclist, &page_count,
-					      &max_pages))
-			return page_count;
+		if (!try_to_add_extent_for_io(cli, ext, &data))
+			return data.erd_page_count;
 
 		ext = next_extent(ext);
 	}
-	return page_count;
+	return data.erd_page_count;
 }
 
 static int
@@ -2087,27 +2135,29 @@ static unsigned int get_write_extents(struct osc_object *obj,
 	struct osc_extent *ext;
 	struct osc_extent *next;
 	LIST_HEAD(rpclist);
-	unsigned int page_count = 0;
-	unsigned int max_pages = cli->cl_max_pages_per_rpc;
+	struct extent_rpc_data data = {
+		.erd_rpc_list = &rpclist,
+		.erd_page_count = 0,
+		.erd_max_pages = cli->cl_max_pages_per_rpc,
+		.erd_max_chunks = UINT_MAX,
+	};
 	int rc = 0;
 
 	LASSERT(osc_object_is_locked(osc));
 	list_for_each_entry_safe(ext, next, &osc->oo_reading_exts, oe_link) {
 		EASSERT(ext->oe_state == OES_LOCK_DONE, ext);
-		if (!try_to_add_extent_for_io(cli, ext, &rpclist, &page_count,
-					      &max_pages))
+		if (!try_to_add_extent_for_io(cli, ext, &data))
 			break;
 		osc_extent_state_set(ext, OES_RPC);
-		EASSERT(ext->oe_nr_pages <= max_pages, ext);
+		EASSERT(ext->oe_nr_pages <= data.erd_max_pages, ext);
 	}
-	LASSERT(page_count <= max_pages);
+	LASSERT(data.erd_page_count <= data.erd_max_pages);
 
-	osc_update_pending(osc, OBD_BRW_READ, -page_count);
+	osc_update_pending(osc, OBD_BRW_READ, -data.erd_page_count);
 
 	if (!list_empty(&rpclist)) {
 		osc_object_unlock(osc);
 
-		LASSERT(page_count > 0);
 		rc = osc_build_rpc(env, cli, &rpclist, OBD_BRW_READ);
 		LASSERT(list_empty(&rpclist));
 
-- 
1.8.3.1
