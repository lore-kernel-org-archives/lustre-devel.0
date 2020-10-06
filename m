From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:53 -0400
Subject: [lustre-devel] [PATCH 14/42] lnet: call event handlers without
 res_lock
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Currently event handlers are called with the lnet_res_lock()
(a spinlock) held.  This is a problem if the handler wants
to take a mutex, allocate memory, or sleep for some other
reason.

The lock is needed because handlers for a given md need to
be serialized.  At the very least, the final event which
reports that the md is "unlinked" needs to be called last,
after any other events have been handled.

Instead of using a spinlock to ensure this ordering, we can
use a flag bit in the md.

- Before considering whether to send an event we wait for the flag bit
  to be cleared.  This ensures serialization.
- Also wait for the flag to be cleared before final freeing of the md.
- If this is not an unlink event and we need to call the handler, we
  set the flag bit before dropping lnet_res_lock().  This
  ensures the not further events will happen, and that the md
  won't be freed - so we can still clear the flag.
- use wait_var_event to wait for the flag it to be cleared,
  and wake_up_var() to signal a wakeup.  After wait_var_event()
  returns, we need to take the spinlock and check again.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10428
Lustre-commit: d05427a7856e8 ("LU-10428 lnet: call event handlers without res_lock")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37068
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  | 23 +++++++++++++++++++++++
 include/linux/lnet/lib-types.h |  9 +++++++++
 net/lnet/lnet/lib-md.c         | 26 ++++++++++++++++++++------
 net/lnet/lnet/lib-msg.c        | 36 +++++++++++++++++++++++++++---------
 4 files changed, 79 insertions(+), 15 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index d2a39f6..6a9ea10 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -188,6 +188,29 @@ static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 	cfs_percpt_unlock(the_lnet.ln_res_lock, cpt);
 }
 
+static inline void lnet_md_wait_handling(struct lnet_libmd *md, int cpt)
+{
+	wait_queue_head_t *wq = __var_waitqueue(md);
+	struct wait_bit_queue_entry entry;
+	wait_queue_entry_t *wqe = &entry.wq_entry;
+
+	init_wait_var_entry(&entry, md, 0);
+	prepare_to_wait_event(wq, wqe, TASK_IDLE);
+	if (md->md_flags & LNET_MD_FLAG_HANDLING) {
+		/* Race with unlocked call to ->md_handler.
+		 * It is safe to drop the res_lock here as the
+		 * caller has only just claimed it.
+		 */
+		lnet_res_unlock(cpt);
+		schedule();
+		/* Cannot check md now, it might be freed.  Caller
+		 * must reclaim reference and check.
+		 */
+		lnet_res_lock(cpt);
+	}
+	finish_wait(wq, wqe);
+}
+
 static inline void
 lnet_md_free(struct lnet_libmd *md)
 {
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 1c016fd..aaf2a46 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -213,6 +213,15 @@ struct lnet_libmd {
 #define LNET_MD_FLAG_ZOMBIE		BIT(0)
 #define LNET_MD_FLAG_AUTO_UNLINK	BIT(1)
 #define LNET_MD_FLAG_ABORTED		BIT(2)
+/* LNET_MD_FLAG_HANDLING is set when a non-unlink event handler
+ * is being called for an event relating to the md.
+ * It ensures only one such handler runs at a time.
+ * The final "unlink" event is only called once the
+ * md_refcount has reached zero, and this flag has been cleared,
+ * ensuring that it doesn't race with any other event handler
+ * call.
+ */
+#define LNET_MD_FLAG_HANDLING		BIT(3)
 
 struct lnet_test_peer {
 	/* info about peers we are trying to fail */
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index 48249f3..e2c3e90 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -75,6 +75,7 @@
 
 	LASSERT(!list_empty(&md->md_list));
 	list_del_init(&md->md_list);
+	LASSERT(!(md->md_flags & LNET_MD_FLAG_HANDLING));
 	lnet_md_free(md);
 }
 
@@ -448,7 +449,8 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 LNetMDUnlink(struct lnet_handle_md mdh)
 {
 	struct lnet_event ev;
-	struct lnet_libmd *md;
+	struct lnet_libmd *md = NULL;
+	lnet_handler_t handler = NULL;
 	int cpt;
 
 	LASSERT(the_lnet.ln_refcount > 0);
@@ -456,10 +458,18 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	cpt = lnet_cpt_of_cookie(mdh.cookie);
 	lnet_res_lock(cpt);
 
-	md = lnet_handle2md(&mdh);
-	if (!md) {
-		lnet_res_unlock(cpt);
-		return -ENOENT;
+	while (!md) {
+		md = lnet_handle2md(&mdh);
+		if (!md) {
+			lnet_res_unlock(cpt);
+			return -ENOENT;
+		}
+		if (md->md_refcount == 0 &&
+		    md->md_flags & LNET_MD_FLAG_HANDLING) {
+			/* Race with unlocked call to ->md_handler. */
+			lnet_md_wait_handling(md, cpt);
+			md = NULL;
+		}
 	}
 
 	md->md_flags |= LNET_MD_FLAG_ABORTED;
@@ -470,7 +480,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	 */
 	if (md->md_handler && !md->md_refcount) {
 		lnet_build_unlink_event(md, &ev);
-		md->md_handler(&ev);
+		handler = md->md_handler;
 	}
 
 	if (md->md_rspt_ptr)
@@ -479,6 +489,10 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	lnet_md_unlink(md);
 
 	lnet_res_unlock(cpt);
+
+	if (handler)
+		handler(&ev);
+
 	return 0;
 }
 EXPORT_SYMBOL(LNetMDUnlink);
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index f759b2d..e84cf02 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -938,11 +938,20 @@
 }
 
 static void
-lnet_msg_detach_md(struct lnet_msg *msg, int cpt, int status)
+lnet_msg_detach_md(struct lnet_msg *msg, int status)
 {
 	struct lnet_libmd *md = msg->msg_md;
+	lnet_handler_t handler = NULL;
+	int cpt = lnet_cpt_of_cookie(md->md_lh.lh_cookie);
 	int unlink;
 
+	lnet_res_lock(cpt);
+	while (md->md_flags & LNET_MD_FLAG_HANDLING)
+		/* An event handler is running - wait for it to
+		 * complete to avoid races.
+		 */
+		lnet_md_wait_handling(md, cpt);
+
 	/* Now it's safe to drop my caller's ref */
 	md->md_refcount--;
 	LASSERT(md->md_refcount >= 0);
@@ -956,17 +965,30 @@
 			msg->msg_ev.status = status;
 		}
 		msg->msg_ev.unlinked = unlink;
-		md->md_handler(&msg->msg_ev);
+		handler = md->md_handler;
+		if (!unlink)
+			md->md_flags |= LNET_MD_FLAG_HANDLING;
 	}
 
 	if (unlink || (md->md_refcount == 0 &&
 		       md->md_threshold == LNET_MD_THRESH_INF))
 		lnet_detach_rsp_tracker(md, cpt);
 
+	msg->msg_md = NULL;
 	if (unlink)
 		lnet_md_unlink(md);
 
-	msg->msg_md = NULL;
+	lnet_res_unlock(cpt);
+
+	if (handler) {
+		handler(&msg->msg_ev);
+		if (!unlink) {
+			lnet_res_lock(cpt);
+			md->md_flags &= ~LNET_MD_FLAG_HANDLING;
+			wake_up_var(md);
+			lnet_res_unlock(cpt);
+		}
+	}
 }
 
 static bool
@@ -1101,12 +1123,8 @@
 	/* We're not going to resend this message so detach its MD and invoke
 	 * the appropriate callbacks
 	 */
-	if (msg->msg_md) {
-		cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
-		lnet_res_lock(cpt);
-		lnet_msg_detach_md(msg, cpt, status);
-		lnet_res_unlock(cpt);
-	}
+	if (msg->msg_md)
+		lnet_msg_detach_md(msg, status);
 
 again:
 	if (!msg->msg_tx_committed && !msg->msg_rx_committed) {
-- 
1.8.3.1
