From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:10 -0400
Subject: [lustre-devel] [PATCH 31/42] lustre: clio: don't call
 aio_complete() in lustre upon errors
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

For older kernels VFS will call aio_complete() if ret is
not -EIOCBQUEUED, this could happen when we don't pass user
buffer as page alignment or some other errors happen in Lustre.

So in Lustre, we need be careful to handle this case to avoid double
aio_complete() called. Newer kernels don't have this issue but
apply this change to keep in sync with OpenSFS tree.

Fixes: fde7ac1 ("lustre: clio: AIO support for direct IO")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13900
Lustre-commit: 2fb8444b5a6369 ("LU-13900 clio: don't call aio_complete() in lustre upon errors")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/39636
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 1 +
 fs/lustre/llite/file.c        | 7 +++++++
 fs/lustre/obdclass/cl_io.c    | 3 ++-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index e849f23..56200d2 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2572,6 +2572,7 @@ struct cl_dio_aio {
 	struct cl_page_list	cda_pages;
 	struct kiocb		*cda_iocb;
 	ssize_t			cda_bytes;
+	unsigned int		cda_no_aio_complete:1;
 };
 
 /** @} cl_sync_io */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index babd24d..1d2ab11 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1669,6 +1669,13 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	}
 
 	if (io->ci_aio) {
+		/*
+		 * VFS will call aio_complete() if no -EIOCBQUEUED
+		 * is returned for AIO, so we can not call aio_complete()
+		 * in our end_io().
+		 */
+		if (rc != -EIOCBQUEUED)
+			io->ci_aio->cda_no_aio_complete = 1;
 		/**
 		 * Drop one extra reference so that end_io() could be
 		 * called for this IO context, we could call it after
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 1564d9f..aa3cb17 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1087,7 +1087,7 @@ static void cl_aio_end(const struct lu_env *env, struct cl_sync_io *anchor)
 		cl_page_put(env, page);
 	}
 
-	if (!is_sync_kiocb(aio->cda_iocb) &&
+	if (!is_sync_kiocb(aio->cda_iocb) && !aio->cda_no_aio_complete &&
 	    aio->cda_iocb->ki_complete)
 		aio->cda_iocb->ki_complete(aio->cda_iocb,
 					   ret ?: aio->cda_bytes, 0);
@@ -1108,6 +1108,7 @@ struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb)
 				       cl_aio_end);
 		cl_page_list_init(&aio->cda_pages);
 		aio->cda_iocb = iocb;
+		aio->cda_no_aio_complete = 0;
 	}
 	return aio;
 }
-- 
1.8.3.1
