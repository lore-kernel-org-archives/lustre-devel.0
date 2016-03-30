From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:39 -0400
Subject: [lustre-devel] [PATCH v2 18/46] staging/lustre/clio: generalize
	cl_sync_io
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-19-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

To make cl_sync_io interfaces not just wait for pages, but to be
a generic synchronization mechanism.

Also remove cl_io_cancel that became not used.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/8656
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4198
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 13 ++--
 drivers/staging/lustre/lustre/obdclass/cl_io.c    | 74 +++++++++++------------
 drivers/staging/lustre/lustre/obdclass/cl_page.c  |  2 +-
 3 files changed, 44 insertions(+), 45 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 69b40f5..91261b1 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -3125,13 +3125,18 @@ struct cl_sync_io {
 	atomic_t		csi_barrier;
 	/** completion to be signaled when transfer is complete. */
 	wait_queue_head_t		csi_waitq;
+	/** callback to invoke when this IO is finished */
+	void			(*csi_end_io)(const struct lu_env *,
+					      struct cl_sync_io *);
 };
 
-void cl_sync_io_init(struct cl_sync_io *anchor, int nrpages);
-int  cl_sync_io_wait(const struct lu_env *env, struct cl_io *io,
-		     struct cl_page_list *queue, struct cl_sync_io *anchor,
+void cl_sync_io_init(struct cl_sync_io *anchor, int nr,
+		     void (*end)(const struct lu_env *, struct cl_sync_io *));
+int  cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 		     long timeout);
-void cl_sync_io_note(struct cl_sync_io *anchor, int ioret);
+void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
+		     int ioret);
+void cl_sync_io_end(const struct lu_env *env, struct cl_sync_io *anchor);
 
 /** @} cl_sync_io */
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 65d6cee..6a8dd9f 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -800,6 +800,9 @@ int cl_io_submit_rw(const struct lu_env *env, struct cl_io *io,
 }
 EXPORT_SYMBOL(cl_io_submit_rw);
 
+static void cl_page_list_assume(const struct lu_env *env,
+				struct cl_io *io, struct cl_page_list *plist);
+
 /**
  * Submit a sync_io and wait for the IO to be finished, or error happens.
  * If \a timeout is zero, it means to wait for the IO unconditionally.
@@ -817,7 +820,7 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 		pg->cp_sync_io = anchor;
 	}
 
-	cl_sync_io_init(anchor, queue->c2_qin.pl_nr);
+	cl_sync_io_init(anchor, queue->c2_qin.pl_nr, &cl_sync_io_end);
 	rc = cl_io_submit_rw(env, io, iot, queue);
 	if (rc == 0) {
 		/*
@@ -828,12 +831,12 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 		 */
 		cl_page_list_for_each(pg, &queue->c2_qin) {
 			pg->cp_sync_io = NULL;
-			cl_sync_io_note(anchor, 1);
+			cl_sync_io_note(env, anchor, 1);
 		}
 
 		/* wait for the IO to be finished. */
-		rc = cl_sync_io_wait(env, io, &queue->c2_qout,
-				     anchor, timeout);
+		rc = cl_sync_io_wait(env, anchor, timeout);
+		cl_page_list_assume(env, io, &queue->c2_qout);
 	} else {
 		LASSERT(list_empty(&queue->c2_qout.pl_pages));
 		cl_page_list_for_each(pg, &queue->c2_qin)
@@ -844,25 +847,6 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 EXPORT_SYMBOL(cl_io_submit_sync);
 
 /**
- * Cancel an IO which has been submitted by cl_io_submit_rw.
- */
-static int cl_io_cancel(const struct lu_env *env, struct cl_io *io,
-			struct cl_page_list *queue)
-{
-	struct cl_page *page;
-	int result = 0;
-
-	CERROR("Canceling ongoing page transmission\n");
-	cl_page_list_for_each(page, queue) {
-		int rc;
-
-		rc = cl_page_cancel(env, page);
-		result = result ?: rc;
-	}
-	return result;
-}
-
-/**
  * Main io loop.
  *
  * Pumps io through iterations calling
@@ -1433,25 +1417,38 @@ void cl_req_attr_set(const struct lu_env *env, struct cl_req *req,
 }
 EXPORT_SYMBOL(cl_req_attr_set);
 
+/* cl_sync_io_callback assumes the caller must call cl_sync_io_wait() to
+ * wait for the IO to finish.
+ */
+void cl_sync_io_end(const struct lu_env *env, struct cl_sync_io *anchor)
+{
+	wake_up_all(&anchor->csi_waitq);
+
+	/* it's safe to nuke or reuse anchor now */
+	atomic_set(&anchor->csi_barrier, 0);
+}
+EXPORT_SYMBOL(cl_sync_io_end);
 
 /**
- * Initialize synchronous io wait anchor, for transfer of \a nrpages pages.
+ * Initialize synchronous io wait anchor
  */
-void cl_sync_io_init(struct cl_sync_io *anchor, int nrpages)
+void cl_sync_io_init(struct cl_sync_io *anchor, int nr,
+		     void (*end)(const struct lu_env *, struct cl_sync_io *))
 {
 	init_waitqueue_head(&anchor->csi_waitq);
-	atomic_set(&anchor->csi_sync_nr, nrpages);
-	atomic_set(&anchor->csi_barrier, nrpages > 0);
+	atomic_set(&anchor->csi_sync_nr, nr);
+	atomic_set(&anchor->csi_barrier, nr > 0);
 	anchor->csi_sync_rc = 0;
+	anchor->csi_end_io = end;
+	LASSERT(end);
 }
 EXPORT_SYMBOL(cl_sync_io_init);
 
 /**
- * Wait until all transfer completes. Transfer completion routine has to call
- * cl_sync_io_note() for every page.
+ * Wait until all IO completes. Transfer completion routine has to call
+ * cl_sync_io_note() for every entity.
  */
-int cl_sync_io_wait(const struct lu_env *env, struct cl_io *io,
-		    struct cl_page_list *queue, struct cl_sync_io *anchor,
+int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 		    long timeout)
 {
 	struct l_wait_info lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(timeout),
@@ -1464,11 +1461,9 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_io *io,
 			  atomic_read(&anchor->csi_sync_nr) == 0,
 			  &lwi);
 	if (rc < 0) {
-		CERROR("SYNC IO failed with error: %d, try to cancel %d remaining pages\n",
+		CERROR("IO failed: %d, still wait for %d remaining entries\n",
 		       rc, atomic_read(&anchor->csi_sync_nr));
 
-		(void)cl_io_cancel(env, io, queue);
-
 		lwi = (struct l_wait_info) { 0 };
 		(void)l_wait_event(anchor->csi_waitq,
 				   atomic_read(&anchor->csi_sync_nr) == 0,
@@ -1477,14 +1472,12 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_io *io,
 		rc = anchor->csi_sync_rc;
 	}
 	LASSERT(atomic_read(&anchor->csi_sync_nr) == 0);
-	cl_page_list_assume(env, io, queue);
 
 	/* wait until cl_sync_io_note() has done wakeup */
 	while (unlikely(atomic_read(&anchor->csi_barrier) != 0)) {
 		cpu_relax();
 	}
 
-	POISON(anchor, 0x5a, sizeof(*anchor));
 	return rc;
 }
 EXPORT_SYMBOL(cl_sync_io_wait);
@@ -1492,7 +1485,8 @@ EXPORT_SYMBOL(cl_sync_io_wait);
 /**
  * Indicate that transfer of a single page completed.
  */
-void cl_sync_io_note(struct cl_sync_io *anchor, int ioret)
+void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
+		     int ioret)
 {
 	if (anchor->csi_sync_rc == 0 && ioret < 0)
 		anchor->csi_sync_rc = ioret;
@@ -1503,9 +1497,9 @@ void cl_sync_io_note(struct cl_sync_io *anchor, int ioret)
 	 */
 	LASSERT(atomic_read(&anchor->csi_sync_nr) > 0);
 	if (atomic_dec_and_test(&anchor->csi_sync_nr)) {
-		wake_up_all(&anchor->csi_waitq);
-		/* it's safe to nuke or reuse anchor now */
-		atomic_set(&anchor->csi_barrier, 0);
+		LASSERT(anchor->csi_end_io);
+		anchor->csi_end_io(env, anchor);
+		/* Can't access anchor any more */
 	}
 }
 EXPORT_SYMBOL(cl_sync_io_note);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 506a9f9..ad7f0ae 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -887,7 +887,7 @@ void cl_page_completion(const struct lu_env *env,
 	cl_page_put(env, pg);
 
 	if (anchor)
-		cl_sync_io_note(anchor, ioret);
+		cl_sync_io_note(env, anchor, ioret);
 }
 EXPORT_SYMBOL(cl_page_completion);
 
-- 
2.1.0
