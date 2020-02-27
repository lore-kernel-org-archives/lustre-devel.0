From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:35 -0500
Subject: [lustre-devel] [PATCH 407/622] lustre: clio: support custom
 csi_end_io handler
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-408-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <stancheff@cray.com>

Provide an initialize that supports a custom end_io handler.

Cray-bug-id: LUS-7330
WC-bug-id: https://jira.whamcloud.com/browse/LU-12431
Lustre-commit: 6ee742fd5c56 ("LU-12431 clio: remove default csi_end_io handler")
Signed-off-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-on: https://review.whamcloud.com/35400
Reviewed-by: Neil Brown <neilb@suse.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 24 ++++++++++++++++++------
 fs/lustre/obdclass/cl_io.c    | 19 ++++++++++++++++---
 2 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 7ac0dd2..71ca283 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2457,6 +2457,22 @@ void cl_req_attr_set(const struct lu_env *env, struct cl_object *obj,
  * @{
  */
 
+struct cl_sync_io;
+
+typedef void (cl_sync_io_end_t)(const struct lu_env *, struct cl_sync_io *);
+
+void cl_sync_io_init_notify(struct cl_sync_io *anchor, int nr,
+			    cl_sync_io_end_t *end);
+
+int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
+		    long timeout);
+void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
+		     int ioret);
+static inline void cl_sync_io_init(struct cl_sync_io *anchor, int nr)
+{
+	cl_sync_io_init_notify(anchor, nr, NULL);
+}
+
 /**
  * Anchor for synchronous transfer. This is allocated on a stack by thread
  * doing synchronous transfer, and a pointer to this structure is set up in
@@ -2470,14 +2486,10 @@ struct cl_sync_io {
 	int			csi_sync_rc;
 	/** completion to be signaled when transfer is complete. */
 	wait_queue_head_t	csi_waitq;
+	/** callback to invoke when this IO is finished */
+	cl_sync_io_end_t	*csi_end_io;
 };
 
-void cl_sync_io_init(struct cl_sync_io *anchor, int nr);
-int  cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
-		     long timeout);
-void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
-		     int ioret);
-
 /** @} cl_sync_io */
 
 /** \defgroup cl_env cl_env
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 4278bc0..14849ed 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1024,16 +1024,26 @@ void cl_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 EXPORT_SYMBOL(cl_req_attr_set);
 
 /**
- * Initialize synchronous io wait anchor
+ * Initialize synchronous io wait @anchor for @nr pages with optional
+ * @end handler.
+ *
+ * @anchor	owned by caller, initialzied here.
+ * @nr		number of pages initally pending in sync.
+ * @end		optional callback sync_io completion, can be used to
+ *		trigger erasure coding, integrity, dedupe, or similar
+ *		operation. @end is called with a spinlock on
+ *		anchor->csi_waitq.lock
  */
-void cl_sync_io_init(struct cl_sync_io *anchor, int nr)
+void cl_sync_io_init_notify(struct cl_sync_io *anchor, int nr,
+			    cl_sync_io_end_t *end)
 {
 	memset(anchor, 0, sizeof(*anchor));
 	init_waitqueue_head(&anchor->csi_waitq);
 	atomic_set(&anchor->csi_sync_nr, nr);
 	anchor->csi_sync_rc = 0;
+	anchor->csi_end_io = end;
 }
-EXPORT_SYMBOL(cl_sync_io_init);
+EXPORT_SYMBOL(cl_sync_io_init_notify);
 
 /**
  * Wait until all IO completes. Transfer completion routine has to call
@@ -1088,6 +1098,7 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 	LASSERT(atomic_read(&anchor->csi_sync_nr) > 0);
 	if (atomic_dec_and_lock(&anchor->csi_sync_nr,
 				&anchor->csi_waitq.lock)) {
+		cl_sync_io_end_t *end_io = anchor->csi_end_io;
 
 		/*
 		 * Holding the lock across both the decrement and
@@ -1095,6 +1106,8 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		 * before the wakeup completes.
 		 */
 		wake_up_all_locked(&anchor->csi_waitq);
+		if (end_io)
+			end_io(env, anchor);
 		spin_unlock(&anchor->csi_waitq.lock);
 
 		/* Can't access anchor any more */
-- 
1.8.3.1
