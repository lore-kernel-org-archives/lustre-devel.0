From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:17 -0400
Subject: [lustre-devel] [PATCH 01/20] staging: lustre: osc: soft lock -
	osc_makes_rpc()
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

It is possible that an osc_extent contains more than 256 chunks, and
the IO engine won't add this extent in one RPC
(try_to_add_extent_for_io) so that osc_check_rpcs() run into a loop
upon this extent and never break.

This patch changes osc_max_write_chunks() to make sure the value
can cover all possible osc_extent, so that all osc_extent will be
added into one RPC.

This patch also add another field erd_max_extents in extent_rpc_data
to make sure not to add too many fragments in a single RPC.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8680
Reviewed-on: http://review.whamcloud.com/23326
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d8a95f8..0100d27 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1887,6 +1887,7 @@ struct extent_rpc_data {
 	unsigned int		erd_page_count;
 	unsigned int		erd_max_pages;
 	unsigned int		erd_max_chunks;
+	unsigned int		erd_max_extents;
 };
 
 static inline unsigned int osc_extent_chunks(const struct osc_extent *ext)
@@ -1915,11 +1916,23 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 	EASSERT((ext->oe_state == OES_CACHE || ext->oe_state == OES_LOCK_DONE),
 		ext);
 
+	if (!data->erd_max_extents)
+		return 0;
+
 	chunk_count = osc_extent_chunks(ext);
+	EASSERTF(data->erd_page_count != 0 ||
+		 chunk_count <= data->erd_max_chunks, ext,
+		 "The first extent to be fit in a RPC contains %u chunks, which is over the limit %u.\n",
+		 chunk_count, data->erd_max_chunks);
+
 	if (chunk_count > data->erd_max_chunks)
 		return 0;
 
 	data->erd_max_pages = max(ext->oe_mppr, data->erd_max_pages);
+	EASSERTF(data->erd_page_count != 0 ||
+		 ext->oe_nr_pages <= data->erd_max_pages, ext,
+		 "The first extent to be fit in a RPC contains %u pages, which is over the limit %u.\n",
+		 ext->oe_nr_pages, data->erd_max_pages);
 	if (data->erd_page_count + ext->oe_nr_pages > data->erd_max_pages)
 		return 0;
 
@@ -1943,6 +1956,7 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 		break;
 	}
 
+	data->erd_max_extents--;
 	data->erd_max_chunks -= chunk_count;
 	data->erd_page_count += ext->oe_nr_pages;
 	list_move_tail(&ext->oe_link, data->erd_rpc_list);
@@ -1972,10 +1986,12 @@ static inline unsigned int osc_max_write_chunks(const struct client_obd *cli)
 	 *
 	 * This limitation doesn't apply to ldiskfs, which allows as many
 	 * chunks in one RPC as we want. However, it won't have any benefits
-	 * to have too many discontiguous pages in one RPC. Therefore, it
-	 * can only have 256 chunks at most in one RPC.
+	 * to have too many discontiguous pages in one RPC.
+	 *
+	 * An osc_extent won't cover over a RPC size, so the chunks in an
+	 * osc_extent won't bigger than PTLRPC_MAX_BRW_SIZE >> chunkbits.
 	 */
-	return min(PTLRPC_MAX_BRW_SIZE >> cli->cl_chunkbits, 256);
+	return PTLRPC_MAX_BRW_SIZE >> cli->cl_chunkbits;
 }
 
 /**
@@ -2002,6 +2018,7 @@ static unsigned int get_write_extents(struct osc_object *obj,
 		.erd_page_count = 0,
 		.erd_max_pages = cli->cl_max_pages_per_rpc,
 		.erd_max_chunks = osc_max_write_chunks(cli),
+		.erd_max_extents = 256,
 	};
 
 	LASSERT(osc_object_is_locked(obj));
@@ -2140,6 +2157,7 @@ static unsigned int get_write_extents(struct osc_object *obj,
 		.erd_page_count = 0,
 		.erd_max_pages = cli->cl_max_pages_per_rpc,
 		.erd_max_chunks = UINT_MAX,
+		.erd_max_extents = UINT_MAX,
 	};
 	int rc = 0;
 
-- 
1.8.3.1
