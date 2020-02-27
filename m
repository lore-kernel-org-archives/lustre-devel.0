From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:55 -0500
Subject: [lustre-devel] [PATCH 427/622] lustre: osc: reserve lru pages for
 read in batch
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-428-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

The benefit of doing this is to reduce contention
against atomic counter cl_lru_left by changing it from
per-page access to per-IO access.

We have done this optimization for write, do it for read
too.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12520
Lustre-commit: 0692dadfba87 ("LU-12520 osc: reserve lru pages for read in batch")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35440
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  6 +++---
 fs/lustre/mdc/mdc_dev.c        |  8 ++++----
 fs/lustre/osc/osc_io.c         | 20 ++++++++++----------
 3 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 1c5af80..37e56ef 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -685,9 +685,9 @@ int osc_io_commit_async(const struct lu_env *env,
 int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios);
 void osc_io_iter_fini(const struct lu_env *env,
 		      const struct cl_io_slice *ios);
-int osc_io_write_iter_init(const struct lu_env *env,
-			   const struct cl_io_slice *ios);
-void osc_io_write_iter_fini(const struct lu_env *env,
+int osc_io_rw_iter_init(const struct lu_env *env,
+			const struct cl_io_slice *ios);
+void osc_io_rw_iter_fini(const struct lu_env *env,
 			    const struct cl_io_slice *ios);
 int osc_io_fault_start(const struct lu_env *env, const struct cl_io_slice *ios);
 void osc_io_setattr_end(const struct lu_env *env,
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index df8bb33..b49509c 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1257,13 +1257,13 @@ static void mdc_io_data_version_end(const struct lu_env *env,
 static struct cl_io_operations mdc_io_ops = {
 	.op = {
 		[CIT_READ] = {
-			.cio_iter_init	= osc_io_iter_init,
-			.cio_iter_fini	= osc_io_iter_fini,
+			.cio_iter_init	= osc_io_rw_iter_init,
+			.cio_iter_fini	= osc_io_rw_iter_fini,
 			.cio_start	= osc_io_read_start,
 		},
 		[CIT_WRITE] = {
-			.cio_iter_init	= osc_io_write_iter_init,
-			.cio_iter_fini	= osc_io_write_iter_fini,
+			.cio_iter_init	= osc_io_rw_iter_init,
+			.cio_iter_fini	= osc_io_rw_iter_fini,
 			.cio_start	= osc_io_write_start,
 			.cio_end	= osc_io_end,
 		},
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index dfdf064..4f46b95 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -375,8 +375,8 @@ int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios)
 }
 EXPORT_SYMBOL(osc_io_iter_init);
 
-int osc_io_write_iter_init(const struct lu_env *env,
-			   const struct cl_io_slice *ios)
+int osc_io_rw_iter_init(const struct lu_env *env,
+			const struct cl_io_slice *ios)
 {
 	struct cl_io *io = ios->cis_io;
 	struct osc_io *oio = osc_env_io(env);
@@ -394,7 +394,7 @@ int osc_io_write_iter_init(const struct lu_env *env,
 
 	return osc_io_iter_init(env, ios);
 }
-EXPORT_SYMBOL(osc_io_write_iter_init);
+EXPORT_SYMBOL(osc_io_rw_iter_init);
 
 void osc_io_iter_fini(const struct lu_env *env,
 		      const struct cl_io_slice *ios)
@@ -412,8 +412,8 @@ void osc_io_iter_fini(const struct lu_env *env,
 }
 EXPORT_SYMBOL(osc_io_iter_fini);
 
-void osc_io_write_iter_fini(const struct lu_env *env,
-			    const struct cl_io_slice *ios)
+void osc_io_rw_iter_fini(const struct lu_env *env,
+			 const struct cl_io_slice *ios)
 {
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_object *osc = cl2osc(ios->cis_obj);
@@ -426,7 +426,7 @@ void osc_io_write_iter_fini(const struct lu_env *env,
 
 	osc_io_iter_fini(env, ios);
 }
-EXPORT_SYMBOL(osc_io_write_iter_fini);
+EXPORT_SYMBOL(osc_io_rw_iter_fini);
 
 int osc_io_fault_start(const struct lu_env *env, const struct cl_io_slice *ios)
 {
@@ -970,14 +970,14 @@ void osc_io_end(const struct lu_env *env, const struct cl_io_slice *slice)
 static const struct cl_io_operations osc_io_ops = {
 	.op = {
 		[CIT_READ] = {
-			.cio_iter_init	= osc_io_iter_init,
-			.cio_iter_fini	= osc_io_iter_fini,
+			.cio_iter_init	= osc_io_rw_iter_init,
+			.cio_iter_fini	= osc_io_rw_iter_fini,
 			.cio_start	= osc_io_read_start,
 			.cio_fini	= osc_io_fini
 		},
 		[CIT_WRITE] = {
-			.cio_iter_init	= osc_io_write_iter_init,
-			.cio_iter_fini	= osc_io_write_iter_fini,
+			.cio_iter_init	= osc_io_rw_iter_init,
+			.cio_iter_fini	= osc_io_rw_iter_fini,
 			.cio_start	= osc_io_write_start,
 			.cio_end	= osc_io_end,
 			.cio_fini	= osc_io_fini
-- 
1.8.3.1
