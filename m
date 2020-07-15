From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:01 -0400
Subject: [lustre-devel] [PATCH 20/37] lustre: llite: fix to free cl_dio_aio
 properly
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

@cl_dio_aio is allocated by slab, we should use slab
free helper to free its memory.

Fixes: ebdbecbaf50b ("lustre: obdclass: use slab allocation for cl_dio_aio")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13134
Lustre-commit: f71a539c3e41b ("LU-13134 llite: fix to free cl_dio_aio properly")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/39103
Reviewed-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  2 ++
 fs/lustre/llite/rw26.c        |  2 +-
 fs/lustre/obdclass/cl_io.c    | 10 ++++++++--
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 8611285..e656c68 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2538,6 +2538,8 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		     int ioret);
 struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb);
+void cl_aio_free(struct cl_dio_aio *aio);
+
 static inline void cl_sync_io_init(struct cl_sync_io *anchor, int nr)
 {
 	cl_sync_io_init_notify(anchor, nr, NULL, NULL);
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 0971185..d0e3ff6 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -384,7 +384,7 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 			vio->u.write.vui_written += tot_bytes;
 			result = tot_bytes;
 		}
-		kfree(aio);
+		cl_aio_free(aio);
 	} else {
 		result = -EIOCBQUEUED;
 	}
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 2f597d1..dcf940f 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1106,6 +1106,13 @@ struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb)
 }
 EXPORT_SYMBOL(cl_aio_alloc);
 
+void cl_aio_free(struct cl_dio_aio *aio)
+{
+	if (aio)
+		kmem_cache_free(cl_dio_aio_kmem, aio);
+}
+EXPORT_SYMBOL(cl_aio_free);
+
 /**
  * Indicate that transfer of a single page completed.
  */
@@ -1143,8 +1150,7 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		 * If anchor->csi_aio is set, we are responsible for freeing
 		 * memory here rather than when cl_sync_io_wait() completes.
 		 */
-		if (aio)
-			kmem_cache_free(cl_dio_aio_kmem, aio);
+		cl_aio_free(aio);
 	}
 }
 EXPORT_SYMBOL(cl_sync_io_note);
-- 
1.8.3.1
