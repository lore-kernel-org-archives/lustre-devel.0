From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:40 -0500
Subject: [lustre-devel] [PATCH v2 57/84] staging/lustre: Remove stray space
	before newline in messages
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-58-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

There were some messages in Lustre that ended with a space followed by
a newline which is pointless, so remove the extra spaces.
Found with checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/lloop.c      | 2 +-
 drivers/staging/lustre/lustre/llite/rw.c         | 8 ++++----
 drivers/staging/lustre/lustre/lov/lov_pack.c     | 2 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c | 2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c  | 4 ++--
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index 20fecaf..3f53292 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -307,7 +307,7 @@ static unsigned int loop_get_bio(struct lloop_device *lo, struct bio **req)
 	rw = first->bi_rw;
 	bio = &lo->lo_bio;
 	while (*bio && (*bio)->bi_rw == rw) {
-		CDEBUG(D_INFO, "bio sector %llu size %u count %u vcnt%u \n",
+		CDEBUG(D_INFO, "bio sector %llu size %u count %u vcnt%u\n",
 		       (unsigned long long)(*bio)->bi_iter.bi_sector,
 		       (*bio)->bi_iter.bi_size,
 		       page_count, (*bio)->bi_vcnt);
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 0e5bd4f..671039a 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -367,7 +367,7 @@ void ll_ra_stats_inc(struct address_space *mapping, enum ra_stat which)
 #define RAS_CDEBUG(ras) \
 	CDEBUG(D_READA,						      \
 	       "lrp %lu cr %lu cp %lu ws %lu wl %lu nra %lu r %lu ri %lu"    \
-	       "csr %lu sf %lu sp %lu sl %lu \n",			    \
+	       "csr %lu sf %lu sp %lu sl %lu\n",			    \
 	       ras->ras_last_readpage, ras->ras_consecutive_requests,	\
 	       ras->ras_consecutive_pages, ras->ras_window_start,	    \
 	       ras->ras_window_len, ras->ras_next_readahead,		 \
@@ -575,7 +575,7 @@ stride_pg_count(pgoff_t st_off, unsigned long st_len, unsigned long st_pgs,
 	if (end_left > st_pgs)
 		end_left = st_pgs;
 
-	CDEBUG(D_READA, "start %llu, end %llu start_left %lu end_left %lu \n",
+	CDEBUG(D_READA, "start %llu, end %llu start_left %lu end_left %lu\n",
 	       start, end, start_left, end_left);
 
 	if (start == end)
@@ -655,7 +655,7 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 			offset = offset % (ria->ria_length);
 			if (offset > ria->ria_pages) {
 				page_idx += ria->ria_length - offset;
-				CDEBUG(D_READA, "i %lu skip %lu \n", page_idx,
+				CDEBUG(D_READA, "i %lu skip %lu\n", page_idx,
 				       ria->ria_length - offset);
 				continue;
 			}
@@ -785,7 +785,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	 * if the region we failed to issue read-ahead on is still ahead
 	 * of the app and behind the next index to start read-ahead from
 	 */
-	CDEBUG(D_READA, "ra_end %lu end %lu stride end %lu \n",
+	CDEBUG(D_READA, "ra_end %lu end %lu stride end %lu\n",
 	       ra_end, end, ria->ria_end);
 
 	if (ra_end != end + 1) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 8871bce..9235d7d 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -185,7 +185,7 @@ int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 			return -ENOMEM;
 	}
 
-	CDEBUG(D_INFO, "lov_packmd: LOV_MAGIC 0x%08X, lmm_size = %d \n",
+	CDEBUG(D_INFO, "lov_packmd: LOV_MAGIC 0x%08X, lmm_size = %d\n",
 	       lmm_magic, lmm_size);
 
 	lmmv1 = *lmmp;
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 6f44dde..7b7f344 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -1453,7 +1453,7 @@ int cl_wait(const struct lu_env *env, struct cl_lock *lock)
 
 	LINVRNT(cl_lock_invariant(env, lock));
 	LASSERTF(lock->cll_state == CLS_ENQUEUED || lock->cll_state == CLS_HELD,
-		 "Wrong state %d \n", lock->cll_state);
+		 "Wrong state %d\n", lock->cll_state);
 	LASSERT(lock->cll_holds > 0);
 
 	do {
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 53668e2..10f262f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -843,7 +843,7 @@ void osc_update_next_shrink(struct client_obd *cli)
 {
 	cli->cl_next_shrink_grant =
 		cfs_time_shift(cli->cl_grant_shrink_interval);
-	CDEBUG(D_CACHE, "next time %ld to shrink grant \n",
+	CDEBUG(D_CACHE, "next time %ld to shrink grant\n",
 	       cli->cl_next_shrink_grant);
 }
 
@@ -1014,7 +1014,7 @@ static int osc_add_shrink_grant(struct client_obd *client)
 			client->cl_import->imp_obd->obd_name, rc);
 		return rc;
 	}
-	CDEBUG(D_CACHE, "add grant client %s \n",
+	CDEBUG(D_CACHE, "add grant client %s\n",
 	       client->cl_import->imp_obd->obd_name);
 	osc_update_next_shrink(client);
 	return 0;
-- 
2.1.0
