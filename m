From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:36 -0400
Subject: [lustre-devel] [PATCH 097/124] staging: lustre: osc: change
	cl_extent_tax and *grants to unsigned
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-98-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change the type accordant usage and remove warnings.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/12386
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   46 ++++++++++---------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |    4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    4 +-
 5 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 8e426b8..5f0f1e3 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -237,7 +237,7 @@ struct client_obd {
 	 * the extent size. A chunk is max(PAGE_SIZE, OST block size)
 	 */
 	int		  cl_chunkbits;
-	int		  cl_extent_tax; /* extent overhead, by bytes */
+	unsigned int	  cl_extent_tax; /* extent overhead, by bytes */
 
 	/* keep track of objects that have lois that contain pages which
 	 * have been queued for async brw.  this lock also protects the
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 31deab0..8152cc7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -44,7 +44,7 @@ static int extent_debug; /* set it to be true for more debug */
 
 static void osc_update_pending(struct osc_object *obj, int cmd, int delta);
 static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
-			   int state);
+			   enum osc_extent_state state);
 static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 			      struct osc_async_page *oap, int sent, int rc);
 static int osc_make_ready(const struct lu_env *env, struct osc_async_page *oap,
@@ -177,7 +177,7 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 {
 	struct osc_object *obj = ext->oe_obj;
 	struct osc_async_page *oap;
-	int page_count;
+	size_t page_count;
 	int rc = 0;
 
 	if (!osc_object_is_locked(obj)) {
@@ -632,7 +632,7 @@ static inline int overlapped(struct osc_extent *ex1, struct osc_extent *ex2)
  */
 static struct osc_extent *osc_extent_find(const struct lu_env *env,
 					  struct osc_object *obj, pgoff_t index,
-					  int *grants)
+					  unsigned int *grants)
 {
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_lock   *olck;
@@ -643,10 +643,10 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	struct osc_extent *found = NULL;
 	pgoff_t chunk;
 	pgoff_t max_end;
-	int max_pages; /* max_pages_per_rpc */
-	int chunksize;
+	unsigned int max_pages; /* max_pages_per_rpc */
+	unsigned int chunksize;
 	int ppc_bits; /* pages per chunk bits */
-	int chunk_mask;
+	pgoff_t chunk_mask;
 	int rc;
 
 	cur = osc_extent_alloc(obj);
@@ -700,8 +700,8 @@ restart:
 	if (!ext)
 		ext = first_extent(obj);
 	while (ext) {
-		loff_t ext_chk_start = ext->oe_start >> ppc_bits;
-		loff_t ext_chk_end = ext->oe_end >> ppc_bits;
+		pgoff_t ext_chk_start = ext->oe_start >> ppc_bits;
+		pgoff_t ext_chk_end = ext->oe_end >> ppc_bits;
 
 		LASSERT(sanity_check_nolock(ext) == 0);
 		if (chunk > ext_chk_end + 1)
@@ -913,7 +913,7 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 	return 0;
 }
 
-static int extent_wait_cb(struct osc_extent *ext, int state)
+static int extent_wait_cb(struct osc_extent *ext, enum osc_extent_state state)
 {
 	int ret;
 
@@ -928,7 +928,7 @@ static int extent_wait_cb(struct osc_extent *ext, int state)
  * Wait for the extent's state to become @state.
  */
 static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
-			   int state)
+			   enum osc_extent_state state)
 {
 	struct osc_object *obj = ext->oe_obj;
 	struct l_wait_info lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(600), NULL,
@@ -958,7 +958,7 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 	rc = l_wait_event(ext->oe_waitq, extent_wait_cb(ext, state), &lwi);
 	if (rc == -ETIMEDOUT) {
 		OSC_EXTENT_DUMP(D_ERROR, ext,
-				"%s: wait ext to %d timedout, recovery in progress?\n",
+				"%s: wait ext to %u timedout, recovery in progress?\n",
 				osc_export(obj)->exp_obd->obd_name, state);
 
 		lwi = LWI_INTR(NULL, NULL);
@@ -1176,7 +1176,8 @@ static int osc_extent_make_ready(const struct lu_env *env,
  * called to expand the extent for the same IO. To expand the extent, the
  * page index must be in the same or next chunk of ext->oe_end.
  */
-static int osc_extent_expand(struct osc_extent *ext, pgoff_t index, int *grants)
+static int osc_extent_expand(struct osc_extent *ext, pgoff_t index,
+			     unsigned int *grants)
 {
 	struct osc_object *obj = ext->oe_obj;
 	struct client_obd *cli = osc_cli(obj);
@@ -1185,7 +1186,7 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index, int *grants)
 	pgoff_t chunk = index >> ppc_bits;
 	pgoff_t end_chunk;
 	pgoff_t end_index;
-	int chunksize = 1 << cli->cl_chunkbits;
+	unsigned int chunksize = 1 << cli->cl_chunkbits;
 	int rc = 0;
 
 	LASSERT(ext->oe_max_end >= index && ext->oe_start <= index);
@@ -1363,7 +1364,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	if (rc == 0 && srvlock) {
 		struct lu_device *ld = opg->ops_cl.cpl_obj->co_lu.lo_dev;
 		struct osc_stats *stats = &lu2osc_dev(ld)->od_stats;
-		int bytes = oap->oap_count;
+		size_t bytes = oap->oap_count;
 
 		if (crt == CRT_READ)
 			stats->os_lockless_reads += bytes;
@@ -1494,7 +1495,7 @@ static void osc_unreserve_grant(struct client_obd *cli,
 static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 			   unsigned int lost_grant)
 {
-	int grant = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
+	unsigned long grant = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
 
 	spin_lock(&cli->cl_loi_list_lock);
 	atomic_long_sub(nr_pages, &obd_dirty_pages);
@@ -1884,7 +1885,7 @@ static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
  */
 static int try_to_add_extent_for_io(struct client_obd *cli,
 				    struct osc_extent *ext, struct list_head *rpclist,
-				    int *pc, unsigned int *max_pages)
+				    unsigned int *pc, unsigned int *max_pages)
 {
 	struct osc_extent *tmp;
 	struct osc_async_page *oap = list_first_entry(&ext->oe_pages,
@@ -1937,12 +1938,13 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
  * 5. Traverse the extent tree from the 1st extent;
  * 6. Above steps exit if there is no space in this RPC.
  */
-static int get_write_extents(struct osc_object *obj, struct list_head *rpclist)
+static unsigned int get_write_extents(struct osc_object *obj,
+				      struct list_head *rpclist)
 {
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_extent *ext;
 	struct osc_extent *temp;
-	int page_count = 0;
+	unsigned int page_count = 0;
 	unsigned int max_pages = cli->cl_max_pages_per_rpc;
 
 	LASSERT(osc_object_is_locked(obj));
@@ -2080,7 +2082,7 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 	struct osc_extent *ext;
 	struct osc_extent *next;
 	LIST_HEAD(rpclist);
-	int page_count = 0;
+	unsigned int page_count = 0;
 	unsigned int max_pages = cli->cl_max_pages_per_rpc;
 	int rc = 0;
 
@@ -2295,7 +2297,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	struct client_obd *cli = oap->oap_cli;
 	struct osc_object *osc = oap->oap_obj;
 	pgoff_t index;
-	int grants = 0;
+	unsigned int grants = 0, tmp;
 	int brw_flags = OBD_BRW_ASYNC;
 	int cmd = OBD_BRW_WRITE;
 	int need_release = 0;
@@ -2378,7 +2380,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 			grants = 0;
 			need_release = 1;
 		} else if (ext->oe_end < index) {
-			int tmp = grants;
+			tmp = grants;
 			/* try to expand this extent */
 			rc = osc_extent_expand(ext, index, &tmp);
 			if (rc < 0) {
@@ -2403,7 +2405,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	}
 
 	if (!ext) {
-		int tmp = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
+		tmp = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
 
 		/* try to find new extent to cover this page */
 		LASSERT(!oio->oi_active);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 3068113..9c8de15 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -608,7 +608,7 @@ struct osc_extent {
 	/** link list of osc_object's oo_{hp|urgent|locking}_exts. */
 	struct list_head	 oe_link;
 	/** state of this extent */
-	unsigned int       oe_state;
+	enum osc_extent_state	oe_state;
 	/** flags for this extent. */
 	unsigned int       oe_intree:1,
 	/** 0 is write, 1 is read */
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 96beba4..8bbb2a6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -109,11 +109,11 @@ static int osc_io_submit(const struct lu_env *env,
 
 	struct cl_page_list *qin = &queue->c2_qin;
 	struct cl_page_list *qout = &queue->c2_qout;
-	int queued = 0;
+	unsigned int queued = 0;
 	int result = 0;
 	int cmd;
 	int brw_flags;
-	int max_pages;
+	unsigned int max_pages;
 
 	LASSERT(qin->pl_nr > 0);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 59ce7a8..3b59c2d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1110,7 +1110,7 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 	}
 
 	while (nob > 0 && pg_count > 0) {
-		int count = pga[i]->count > nob ? nob : pga[i]->count;
+		unsigned int count = pga[i]->count > nob ? nob : pga[i]->count;
 
 		/* corrupt the data before we compute the checksum, to
 		 * simulate an OST->client data error
@@ -1120,7 +1120,7 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 			unsigned char *ptr = kmap(pga[i]->pg);
 			int off = pga[i]->off & ~PAGE_MASK;
 
-			memcpy(ptr + off, "bad1", min(4, nob));
+			memcpy(ptr + off, "bad1", min_t(typeof(nob), 4, nob));
 			kunmap(pga[i]->pg);
 		}
 		cfs_crypto_hash_update_page(hdesc, pga[i]->pg,
-- 
1.7.1
