From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Wed, 11 Nov 2015 15:43:28 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: Remove cl_2queue_add wrapper
Message-ID: <1447236808-45674-1-git-send-email-shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the wrapper function cl_2queue_add() and replace all its calls in
different files with the function it wrapped. Also, comments are added
wherever necessary to make the working of function clear. Prototype of
the function is also removed from the header file as it is no longer
needed.

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h   |  1 -
 drivers/staging/lustre/lustre/llite/rw26.c          |  5 ++++-
 drivers/staging/lustre/lustre/llite/vvp_io.c        |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c      | 14 ++++----------
 drivers/staging/lustre/lustre/obdecho/echo_client.c |  6 ++++--
 5 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 73564f8..e81c591 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -3127,7 +3127,6 @@ void cl_page_list_disown (const struct lu_env *env,
 			  struct cl_io *io, struct cl_page_list *plist);
 
 void cl_2queue_init     (struct cl_2queue *queue);
-void cl_2queue_add      (struct cl_2queue *queue, struct cl_page *page);
 void cl_2queue_disown   (const struct lu_env *env,
 			 struct cl_io *io, struct cl_2queue *queue);
 void cl_2queue_discard  (const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 3da4c01..39fa13b 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -298,7 +298,10 @@ ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
 		}
 
 		if (likely(do_io)) {
-			cl_2queue_add(queue, clp);
+			/*
+			 * Add a page to the incoming page list of 2-queue.
+			 */
+			cl_page_list_add(&queue->c2_qin, clp);
 
 			/*
 			 * Set page clip to tell transfer formation engine
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 37773c1..b7bdc35 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -849,7 +849,7 @@ static int vvp_io_read_page(const struct lu_env *env,
 	 * Add page into the queue even when it is marked uptodate above.
 	 * this will unlock it automatically as part of cl_page_list_disown().
 	 */
-	cl_2queue_add(queue, page);
+	cl_page_list_add(&queue->c2_qin, page);
 	if (sbi->ll_ra_info.ra_max_pages_per_file &&
 	    sbi->ll_ra_info.ra_max_pages)
 		ll_readahead(env, io, ras,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 37c449b..e56dce5 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -1212,15 +1212,6 @@ void cl_2queue_init(struct cl_2queue *queue)
 EXPORT_SYMBOL(cl_2queue_init);
 
 /**
- * Add a page to the incoming page list of 2-queue.
- */
-void cl_2queue_add(struct cl_2queue *queue, struct cl_page *page)
-{
-	cl_page_list_add(&queue->c2_qin, page);
-}
-EXPORT_SYMBOL(cl_2queue_add);
-
-/**
  * Disown pages in both lists of a 2-queue.
  */
 void cl_2queue_disown(const struct lu_env *env,
@@ -1258,7 +1249,10 @@ EXPORT_SYMBOL(cl_2queue_fini);
 void cl_2queue_init_page(struct cl_2queue *queue, struct cl_page *page)
 {
 	cl_2queue_init(queue);
-	cl_2queue_add(queue, page);
+	/*
+	 * Add a page to the incoming page list of 2-queue.
+	 */
+	cl_page_list_add(&queue->c2_qin, page);
 }
 EXPORT_SYMBOL(cl_2queue_init_page);
 
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 35a2f59..d82a087 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1228,8 +1228,10 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 			cl_page_put(env, clp);
 			break;
 		}
-
-		cl_2queue_add(queue, clp);
+		/*
+		 * Add a page to the incoming page list of 2-queue.
+		 */
+		cl_page_list_add(&queue->c2_qin, clp);
 
 		/* drop the reference count for cl_page_find, so that the page
 		 * will be freed in cl_2queue_fini. */
-- 
2.1.0
