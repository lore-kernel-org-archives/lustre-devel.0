From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:16 -0400
Subject: [lustre-devel] [PATCH 057/151] lustre: mdc: implement own
 mdc_io_fsync_start()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-58-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

DoM lock cancellation may happen in llite and call
cl_sync_file_range() function to flush related data and
it uses DOM component end as limit for data to be flushed.
However related lock and extent are expanded to EOF and
this is asserted in osc_cache_writeback_range().
To avoid this a MDC uses own version of cio_start for FSYNC
and osc_cache_writeback_range() is called on whole DoM object
no matter what start/end are supplied by upper layers.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 1d2e9f42027c ("LU-3285 mdc: implement own mdc_io_fsync_start()")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/29813
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  4 ++--
 fs/lustre/mdc/mdc_dev.c        | 38 +++++++++++++++++++++++++++++++++++++-
 fs/lustre/osc/osc_io.c         |  6 +++---
 3 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 3d83fa5..c3b8849 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -676,8 +676,8 @@ int osc_io_read_start(const struct lu_env *env,
 int osc_io_write_start(const struct lu_env *env,
 		       const struct cl_io_slice *slice);
 void osc_io_end(const struct lu_env *env, const struct cl_io_slice *slice);
-int osc_io_fsync_start(const struct lu_env *env,
-		       const struct cl_io_slice *slice);
+int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
+		  struct cl_fsync_io *fio);
 void osc_io_fsync_end(const struct lu_env *env,
 		      const struct cl_io_slice *slice);
 void osc_read_ahead_release(const struct lu_env *env, void *cbdata);
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index e28c863..de21d7d 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1045,6 +1045,42 @@ static int mdc_io_read_ahead(const struct lu_env *env,
 	return 0;
 }
 
+int mdc_io_fsync_start(const struct lu_env *env,
+		       const struct cl_io_slice *slice)
+{
+	struct cl_io *io = slice->cis_io;
+	struct cl_fsync_io *fio = &io->u.ci_fsync;
+	struct cl_object *obj = slice->cis_obj;
+	struct osc_object *osc = cl2osc(obj);
+	int result = 0;
+
+	/* a MDC lock always covers whole object, do sync for whole
+	 * possible range despite of supplied start/end values.
+	 */
+	result = osc_cache_writeback_range(env, osc, 0, CL_PAGE_EOF, 0,
+					   fio->fi_mode == CL_FSYNC_DISCARD);
+	if (result > 0) {
+		fio->fi_nr_written += result;
+		result = 0;
+	}
+	if (fio->fi_mode == CL_FSYNC_ALL) {
+		int rc;
+
+		rc = osc_cache_wait_range(env, osc, 0, CL_PAGE_EOF);
+		if (result == 0)
+			result = rc;
+		/* Use OSC sync code because it is asynchronous.
+		 * It is to be added into MDC and avoid the using of
+		 * OST_SYNC at both MDC and MDT.
+		 */
+		rc = osc_fsync_ost(env, osc, fio);
+		if (result == 0)
+			result = rc;
+	}
+
+	return result;
+}
+
 static struct cl_io_operations mdc_io_ops = {
 	.op = {
 		[CIT_READ] = {
@@ -1076,7 +1112,7 @@ static int mdc_io_read_ahead(const struct lu_env *env,
 			.cio_end	= osc_io_end,
 		},
 		[CIT_FSYNC] = {
-			.cio_start	= osc_io_fsync_start,
+			.cio_start	= mdc_io_fsync_start,
 			.cio_end	= osc_io_fsync_end,
 		},
 	},
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 0a67089..d2e2f7f 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -750,8 +750,8 @@ int osc_io_write_start(const struct lu_env *env,
 }
 EXPORT_SYMBOL(osc_io_write_start);
 
-static int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
-			 struct cl_fsync_io *fio)
+int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
+		  struct cl_fsync_io *fio)
 {
 	struct osc_io *oio = osc_env_io(env);
 	struct obdo *oa = &oio->oi_oa;
@@ -775,6 +775,7 @@ static int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 	rc = osc_sync_base(obj, oa, osc_async_upcall, cbargs, PTLRPCD_SET);
 	return rc;
 }
+EXPORT_SYMBOL(osc_fsync_ost);
 
 int osc_io_fsync_start(const struct lu_env *env,
 		       const struct cl_io_slice *slice)
@@ -815,7 +816,6 @@ int osc_io_fsync_start(const struct lu_env *env,
 
 	return result;
 }
-EXPORT_SYMBOL(osc_io_fsync_start);
 
 void osc_io_fsync_end(const struct lu_env *env,
 		      const struct cl_io_slice *slice)
-- 
1.8.3.1
