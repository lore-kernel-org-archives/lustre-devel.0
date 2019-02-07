From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:32 +1100
Subject: [lustre-devel] [PATCH 01/21] lustre: obdclass: discard csi_end_io
In-Reply-To: <154949776249.10620.1215070753973826063.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
Message-ID: <154949781233.10620.15965903498344624062.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The csi_end_io field in "struct cl_sync_io" is always
set to cl_sync_io_end(), which is a tiny function.
This indirection doesn't help clarity, so remove it.

Inline the function in the one place where ->csi_end_io()
is called, and discard the field.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h |    7 +-----
 drivers/staging/lustre/lustre/obdclass/cl_io.c    |   26 ++++++---------------
 drivers/staging/lustre/lustre/obdclass/cl_lock.c  |    2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c      |    2 +-
 4 files changed, 10 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index b8ae41de7192..71ba73cdbb5e 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2395,18 +2395,13 @@ struct cl_sync_io {
 	atomic_t		csi_barrier;
 	/** completion to be signaled when transfer is complete. */
 	wait_queue_head_t	csi_waitq;
-	/** callback to invoke when this IO is finished */
-	void			(*csi_end_io)(const struct lu_env *,
-					      struct cl_sync_io *);
 };
 
-void cl_sync_io_init(struct cl_sync_io *anchor, int nr,
-		     void (*end)(const struct lu_env *, struct cl_sync_io *));
+void cl_sync_io_init(struct cl_sync_io *anchor, int nr);
 int  cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 		     long timeout);
 void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		     int ioret);
-void cl_sync_io_end(const struct lu_env *env, struct cl_sync_io *anchor);
 
 /** @} cl_sync_io */
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 09fd45d5394a..e9ad055f84b8 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -668,7 +668,7 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 		pg->cp_sync_io = anchor;
 	}
 
-	cl_sync_io_init(anchor, queue->c2_qin.pl_nr, &cl_sync_io_end);
+	cl_sync_io_init(anchor, queue->c2_qin.pl_nr);
 	rc = cl_io_submit_rw(env, io, iot, queue);
 	if (rc == 0) {
 		/*
@@ -1039,31 +1039,16 @@ void cl_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 }
 EXPORT_SYMBOL(cl_req_attr_set);
 
-/* cl_sync_io_callback assumes the caller must call cl_sync_io_wait() to
- * wait for the IO to finish.
- */
-void cl_sync_io_end(const struct lu_env *env, struct cl_sync_io *anchor)
-{
-	wake_up_all(&anchor->csi_waitq);
-
-	/* it's safe to nuke or reuse anchor now */
-	atomic_set(&anchor->csi_barrier, 0);
-}
-EXPORT_SYMBOL(cl_sync_io_end);
-
 /**
  * Initialize synchronous io wait anchor
  */
-void cl_sync_io_init(struct cl_sync_io *anchor, int nr,
-		     void (*end)(const struct lu_env *, struct cl_sync_io *))
+void cl_sync_io_init(struct cl_sync_io *anchor, int nr)
 {
 	memset(anchor, 0, sizeof(*anchor));
 	init_waitqueue_head(&anchor->csi_waitq);
 	atomic_set(&anchor->csi_sync_nr, nr);
 	atomic_set(&anchor->csi_barrier, nr > 0);
 	anchor->csi_sync_rc = 0;
-	anchor->csi_end_io = end;
-	LASSERT(end);
 }
 EXPORT_SYMBOL(cl_sync_io_init);
 
@@ -1120,8 +1105,11 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 	 */
 	LASSERT(atomic_read(&anchor->csi_sync_nr) > 0);
 	if (atomic_dec_and_test(&anchor->csi_sync_nr)) {
-		LASSERT(anchor->csi_end_io);
-		anchor->csi_end_io(env, anchor);
+
+		wake_up_all(&anchor->csi_waitq);
+		/* it's safe to nuke or reuse anchor now */
+		atomic_set(&anchor->csi_barrier, 0);
+
 		/* Can't access anchor any more */
 	}
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index d7bcb8c203dd..8133d992cc73 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -189,7 +189,7 @@ int cl_lock_request(const struct lu_env *env, struct cl_io *io,
 
 	if ((enq_flags & CEF_ASYNC) && !(enq_flags & CEF_AGL)) {
 		anchor = &cl_env_info(env)->clt_anchor;
-		cl_sync_io_init(anchor, 1, cl_sync_io_end);
+		cl_sync_io_init(anchor, 1);
 	}
 
 	rc = cl_lock_enqueue(env, io, lock, anchor);
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 5a1717c7d132..da8c3978fab8 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -877,7 +877,7 @@ static int osc_lock_enqueue_wait(const struct lu_env *env,
 			continue;
 
 		/* wait for conflicting lock to be canceled */
-		cl_sync_io_init(waiter, 1, cl_sync_io_end);
+		cl_sync_io_init(waiter, 1);
 		oscl->ols_owner = waiter;
 
 		spin_lock(&tmp_oscl->ols_lock);
