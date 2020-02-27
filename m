From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:47 -0500
Subject: [lustre-devel] [PATCH 179/622] lustre: osc: limit chunk number of
 write submit
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-180-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

Don't queue too many pages in an extent for a write RPC, we need
to take care of the chunk limit in write submit as well (refers to
LU-8135 for more details).

WC-bug-id: https://jira.whamcloud.com/browse/LU-10239
Lustre-commit: 93ef6e7863b4 ("LU-10239 osc: limit chunk number of write submit")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30627
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c    | 30 ------------------------------
 fs/lustre/osc/osc_internal.h | 30 ++++++++++++++++++++++++++++++
 fs/lustre/osc/osc_io.c       | 27 +++++++++++++++++++++++++--
 3 files changed, 55 insertions(+), 32 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 47aee99..1ff258c 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1937,36 +1937,6 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 	return 1;
 }
 
-static inline unsigned int osc_max_write_chunks(const struct client_obd *cli)
-{
-	/*
-	 * LU-8135:
-	 *
-	 * The maximum size of a single transaction is about 64MB in ZFS.
-	 * #define DMU_MAX_ACCESS (64 * 1024 * 1024)
-	 *
-	 * Since ZFS is a copy-on-write file system, a single dirty page in
-	 * a chunk will result in the rewrite of the whole chunk, therefore
-	 * an RPC shouldn't be allowed to contain too many chunks otherwise
-	 * it will make transaction size much bigger than 64MB, especially
-	 * with big block size for ZFS.
-	 *
-	 * This piece of code is to make sure that OSC won't send write RPCs
-	 * with too many chunks. The maximum chunk size that an RPC can cover
-	 * is set to PTLRPC_MAX_BRW_SIZE, which is defined to 16MB. Ideally
-	 * OST should tell the client what the biggest transaction size is,
-	 * but it's good enough for now.
-	 *
-	 * This limitation doesn't apply to ldiskfs, which allows as many
-	 * chunks in one RPC as we want. However, it won't have any benefits
-	 * to have too many discontiguous pages in one RPC.
-	 *
-	 * An osc_extent won't cover over a RPC size, so the chunks in an
-	 * osc_extent won't bigger than PTLRPC_MAX_BRW_SIZE >> chunkbits.
-	 */
-	return PTLRPC_MAX_BRW_SIZE >> cli->cl_chunkbits;
-}
-
 /**
  * In order to prevent multiple ptlrpcd from breaking contiguous extents,
  * get_write_extent() takes all appropriate extents in atomic.
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 3ba209f..2cb737b 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -162,6 +162,36 @@ unsigned long osc_cache_shrink_count(struct shrinker *sk,
 unsigned long osc_cache_shrink_scan(struct shrinker *sk,
 				    struct shrink_control *sc);
 
+static inline unsigned int osc_max_write_chunks(const struct client_obd *cli)
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
+	 * to have too many discontiguous pages in one RPC.
+	 *
+	 * An osc_extent won't cover over a RPC size, so the chunks in an
+	 * osc_extent won't bigger than PTLRPC_MAX_BRW_SIZE >> chunkbits.
+	 */
+	return PTLRPC_MAX_BRW_SIZE >> cli->cl_chunkbits;
+}
+
 static inline void osc_set_io_portal(struct ptlrpc_request *req)
 {
 	struct obd_import *imp = req->rq_import;
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 1485962..56f30cb 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -122,6 +122,9 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 	int result = 0;
 	int brw_flags;
 	unsigned int max_pages;
+	unsigned int ppc_bits; /* pages per chunk bits */
+	unsigned int ppc;
+	bool sync_queue = false;
 
 	LASSERT(qin->pl_nr > 0);
 
@@ -130,6 +133,8 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 	osc = cl2osc(ios->cis_obj);
 	cli = osc_cli(osc);
 	max_pages = cli->cl_max_pages_per_rpc;
+	ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
+	ppc = 1 << ppc_bits;
 
 	brw_flags = osc_io_srvlock(cl2osc_io(env, ios)) ? OBD_BRW_SRVLOCK : 0;
 	brw_flags |= crt == CRT_WRITE ? OBD_BRW_WRITE : OBD_BRW_READ;
@@ -186,12 +191,30 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 		else /* async IO */
 			cl_page_list_del(env, qin, page);
 
-		if (++queued == max_pages) {
-			queued = 0;
+		queued++;
+		if (queued == max_pages) {
+			sync_queue = true;
+		} else if (crt == CRT_WRITE) {
+			unsigned int chunks;
+			unsigned int next_chunks;
+
+			chunks = (queued + ppc - 1) >> ppc_bits;
+			/* chunk number if add another page */
+			next_chunks = (queued + ppc) >> ppc_bits;
+
+			/* next page will excceed write chunk limit */
+			if (chunks == osc_max_write_chunks(cli) &&
+			    next_chunks > chunks)
+				sync_queue = true;
+		}
+
+		if (sync_queue) {
 			result = osc_queue_sync_pages(env, io, osc, &list,
 						      brw_flags);
 			if (result < 0)
 				break;
+			queued = 0;
+			sync_queue = false;
 		}
 	}
 
-- 
1.8.3.1
