From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:55 -0400
Subject: [lustre-devel] [PATCH 16/42] lustre: llite: reuse same cl_dio_aio
 for one IO
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

IO might be restarted if layout changed, this might
cause ki_complete() called several times for one IO.

Fixes: fde7ac1 ("lustre: clio: AIO support for direct IO")
Fixes: 52f2fc5 ("lustre: llite: fix short io for AIO")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13835
Lustre-commit: db6f203965d91 ("LU-13835 llite: reuse same cl_dio_aio for one IO")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/39542
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 57 ++++++++++++++++++++++++++++----------------------
 fs/lustre/llite/rw26.c |  5 +++++
 2 files changed, 37 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index d872cf3..251cca5 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1563,13 +1563,26 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	unsigned int retried = 0;
 	unsigned int ignore_lockless = 0;
 	bool is_aio = false;
+	struct cl_dio_aio *ci_aio = NULL;
 
 	CDEBUG(D_VFSTRACE, "file: %pD, type: %d ppos: %llu, count: %zu\n",
 	       file, iot, *ppos, count);
 
+	io = vvp_env_thread_io(env);
+	if (file->f_flags & O_DIRECT) {
+		if (!is_sync_kiocb(args->u.normal.via_iocb))
+			is_aio = true;
+		ci_aio = cl_aio_alloc(args->u.normal.via_iocb);
+		if (!ci_aio) {
+			rc = -ENOMEM;
+			goto out;
+		}
+	}
+
 restart:
 	io = vvp_env_thread_io(env);
 	ll_io_init(io, file, iot == CIT_WRITE, args);
+	io->ci_aio = ci_aio;
 	io->ci_ignore_lockless = ignore_lockless;
 	io->ci_ndelay_tried = retried;
 
@@ -1585,15 +1598,6 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		vio->vui_fd  = file->private_data;
 		vio->vui_iter = args->u.normal.via_iter;
 		vio->vui_iocb = args->u.normal.via_iocb;
-		if (file->f_flags & O_DIRECT) {
-			if (!is_sync_kiocb(vio->vui_iocb))
-				is_aio = true;
-			io->ci_aio = cl_aio_alloc(vio->vui_iocb);
-			if (!io->ci_aio) {
-				rc = -ENOMEM;
-				goto out;
-			}
-		}
 		/*
 		 * Direct IO reads must also take range lock,
 		 * or multiple reads will try to work on the same pages
@@ -1632,29 +1636,18 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	 * EIOCBQUEUED to the caller, So we could only return
 	 * number of bytes in non-AIO case.
 	 */
-	if (io->ci_nob > 0 && !is_aio) {
-		result += io->ci_nob;
+	if (io->ci_nob > 0) {
+		if (!is_aio) {
+			result += io->ci_nob;
+			*ppos = io->u.ci_wr.wr.crw_pos; /* for splice */
+		}
 		count -= io->ci_nob;
-		*ppos = io->u.ci_wr.wr.crw_pos;
 
 		/* prepare IO restart */
 		if (count > 0)
 			args->u.normal.via_iter = vio->vui_iter;
 	}
 out:
-	if (io->ci_aio) {
-		/**
-		 * Drop one extra reference so that end_io() could be
-		 * called for this IO context, we could call it after
-		 * we make sure all AIO requests have been proceed.
-		 */
-		cl_sync_io_note(env, &io->ci_aio->cda_sync,
-				rc == -EIOCBQUEUED ? 0 : rc);
-		if (!is_aio) {
-			cl_aio_free(io->ci_aio);
-			io->ci_aio = NULL;
-		}
-	}
 	cl_io_fini(env, io);
 
 	CDEBUG(D_VFSTRACE,
@@ -1675,6 +1668,20 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		goto restart;
 	}
 
+	if (io->ci_aio) {
+		/**
+		 * Drop one extra reference so that end_io() could be
+		 * called for this IO context, we could call it after
+		 * we make sure all AIO requests have been proceed.
+		 */
+		cl_sync_io_note(env, &io->ci_aio->cda_sync,
+				rc == -EIOCBQUEUED ? 0 : rc);
+		if (!is_aio) {
+			cl_aio_free(io->ci_aio);
+			io->ci_aio = NULL;
+		}
+	}
+
 	if (iot == CIT_READ) {
 		if (result >= 0)
 			ll_stats_ops_tally(ll_i2sbi(file_inode(file)),
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 7010fe8..a4ae211 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -243,6 +243,11 @@ struct ll_dio_pages {
 		int iot = rw == READ ? CRT_READ : CRT_WRITE;
 
 		atomic_add(io_pages, &anchor->csi_sync_nr);
+		/*
+		 * Avoid out-of-order execution of adding inflight
+		 * modifications count and io submit.
+		 */
+		smp_mb();
 		rc = cl_io_submit_rw(env, io, iot, queue);
 		if (rc == 0) {
 			cl_page_list_splice(&queue->c2_qout,
-- 
1.8.3.1
