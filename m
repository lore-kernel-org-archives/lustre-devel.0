From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:43 -0500
Subject: [lustre-devel] [PATCH 175/622] lnet: handle multi-md usage
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-176-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

The MD can be used multiple times. The response tracker needs to have
the same lifespan as the MD. If we re-use the MD and a response
tracker has already been attached to it, then we'll update the
deadline for the response tracker. This means the deadline on the MD
is for its last user.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11734
Lustre-commit: 8c249097e627 ("LU-11734 lnet: handle multi-md usage")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33794
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 -
 net/lnet/lnet/lib-move.c      | 47 +++++++++++++++++--------------
 net/lnet/lnet/lib-msg.c       | 64 +++++++++++++++++++++----------------------
 3 files changed, 57 insertions(+), 55 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 26095a6..bbb678f 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -550,7 +550,6 @@ int lnet_get_peer_list(u32 *countp, u32 *sizep,
 
 void lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 			unsigned int offset, unsigned int mlen);
-void lnet_msg_detach_md(struct lnet_msg *msg, int status);
 void lnet_build_unlink_event(struct lnet_libmd *md, struct lnet_event *ev);
 void lnet_build_msg_event(struct lnet_msg *msg, enum lnet_event_kind ev_type);
 void lnet_msg_commit(struct lnet_msg *msg, int cpt);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index eacda4c..3bcac03 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2437,6 +2437,7 @@ struct lnet_mt_event_info {
 	lnet_nid_t mt_nid;
 };
 
+/* called with res_lock held */
 void
 lnet_detach_rsp_tracker(struct lnet_libmd *md, int cpt)
 {
@@ -2446,11 +2447,9 @@ struct lnet_mt_event_info {
 	 * The rspt queue for the cpt is protected by
 	 * the lnet_net_lock(cpt). cpt is the cpt of the MD cookie.
 	 */
-	lnet_res_lock(cpt);
-	if (!md->md_rspt_ptr) {
-		lnet_res_unlock(cpt);
+	if (!md->md_rspt_ptr)
 		return;
-	}
+
 	rspt = md->md_rspt_ptr;
 	md->md_rspt_ptr = NULL;
 
@@ -2462,7 +2461,6 @@ struct lnet_mt_event_info {
 	 * the rspt block.
 	 */
 	LNetInvalidateMDHandle(&rspt->rspt_mdh);
-	lnet_res_unlock(cpt);
 }
 
 static void
@@ -4152,6 +4150,8 @@ void lnet_monitor_thr_stop(void)
 			struct lnet_libmd *md, struct lnet_handle_md mdh)
 {
 	s64 timeout_ns;
+	bool new_entry = true;
+	struct lnet_rsp_tracker *local_rspt;
 
 	/* MD has a refcount taken by message so it's not going away.
 	 * The MD however can be looked up. We need to secure the access
@@ -4159,27 +4159,34 @@ void lnet_monitor_thr_stop(void)
 	 * The rspt can be accessed without protection up to when it gets
 	 * added to the list.
 	 */
-
-	/* debug code */
-	LASSERT(!md->md_rspt_ptr);
-
-	/* we'll use that same event in case we never get a response  */
-	rspt->rspt_mdh = mdh;
-	rspt->rspt_cpt = cpt;
-	timeout_ns = lnet_transaction_timeout * NSEC_PER_SEC;
-	rspt->rspt_deadline = ktime_add_ns(ktime_get(), timeout_ns);
-
 	lnet_res_lock(cpt);
-	/* store the rspt so we can access it when we get the REPLY */
-	md->md_rspt_ptr = rspt;
-	lnet_res_unlock(cpt);
+	local_rspt = md->md_rspt_ptr;
+	timeout_ns = lnet_transaction_timeout * NSEC_PER_SEC;
+	if (local_rspt) {
+		/* we already have an rspt attached to the md, so we'll
+		 * update the deadline on that one.
+		 */
+		kfree(rspt);
+		new_entry = false;
+	} else {
+		/* new md */
+		rspt->rspt_mdh = mdh;
+		rspt->rspt_cpt = cpt;
+		/* store the rspt so we can access it when we get the REPLY */
+		md->md_rspt_ptr = rspt;
+		local_rspt = rspt;
+	}
+	local_rspt->rspt_deadline = ktime_add_ns(ktime_get(), timeout_ns);
 
 	/* add to the list of tracked responses. It's added to tail of the
 	 * list in order to expire all the older entries first.
 	 */
 	lnet_net_lock(cpt);
-	list_add_tail(&rspt->rspt_on_list, the_lnet.ln_mt_rstq[cpt]);
+	if (!new_entry && !list_empty(&local_rspt->rspt_on_list))
+		list_del_init(&local_rspt->rspt_on_list);
+	list_add_tail(&local_rspt->rspt_on_list, the_lnet.ln_mt_rstq[cpt]);
 	lnet_net_unlock(cpt);
+	lnet_res_unlock(cpt);
 }
 
 /**
@@ -4321,7 +4328,6 @@ void lnet_monitor_thr_stop(void)
 		CNETERR("Error sending PUT to %s: %d\n",
 			libcfs_id2str(target), rc);
 		msg->msg_no_resend = true;
-		lnet_detach_rsp_tracker(msg->msg_md, cpt);
 		lnet_finalize(msg, rc);
 	}
 
@@ -4543,7 +4549,6 @@ struct lnet_msg *
 		CNETERR("Error sending GET to %s: %d\n",
 			libcfs_id2str(target), rc);
 		msg->msg_no_resend = true;
-		lnet_detach_rsp_tracker(msg->msg_md, cpt);
 		lnet_finalize(msg, rc);
 	}
 
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index f626ca3..af0675e 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -369,29 +369,6 @@
 	lnet_md_deconstruct(md, &msg->msg_ev.md);
 }
 
-void
-lnet_msg_detach_md(struct lnet_msg *msg, int status)
-{
-	struct lnet_libmd *md = msg->msg_md;
-	int unlink;
-
-	/* Now it's safe to drop my caller's ref */
-	md->md_refcount--;
-	LASSERT(md->md_refcount >= 0);
-
-	unlink = lnet_md_unlinkable(md);
-	if (md->md_eq) {
-		msg->msg_ev.status = status;
-		msg->msg_ev.unlinked = unlink;
-		lnet_eq_enqueue_event(md->md_eq, &msg->msg_ev);
-	}
-
-	if (unlink)
-		lnet_md_unlink(md);
-
-	msg->msg_md = NULL;
-}
-
 static int
 lnet_complete_msg_locked(struct lnet_msg *msg, int cpt)
 {
@@ -772,12 +749,42 @@
 }
 
 static void
+lnet_msg_detach_md(struct lnet_msg *msg, int cpt, int status)
+{
+	struct lnet_libmd *md = msg->msg_md;
+	int unlink;
+
+	/* Now it's safe to drop my caller's ref */
+	md->md_refcount--;
+	LASSERT(md->md_refcount >= 0);
+
+	unlink = lnet_md_unlinkable(md);
+	if (md->md_eq) {
+		msg->msg_ev.status = status;
+		msg->msg_ev.unlinked = unlink;
+		lnet_eq_enqueue_event(md->md_eq, &msg->msg_ev);
+	}
+
+	if (unlink) {
+		/* if this is an ACK or a REPLY then make sure to remove the
+		 * response tracker.
+		 */
+		if (msg->msg_ev.type == LNET_EVENT_REPLY ||
+		    msg->msg_ev.type == LNET_EVENT_ACK)
+			lnet_detach_rsp_tracker(msg->msg_md, cpt);
+		lnet_md_unlink(md);
+	}
+
+	msg->msg_md = NULL;
+}
+
+static void
 lnet_detach_md(struct lnet_msg *msg, int status)
 {
 	int cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
 
 	lnet_res_lock(cpt);
-	lnet_msg_detach_md(msg, status);
+	lnet_msg_detach_md(msg, cpt, status);
 	lnet_res_unlock(cpt);
 }
 
@@ -877,15 +884,6 @@
 
 	msg->msg_ev.status = status;
 
-	/* if this is an ACK or a REPLY then make sure to remove the
-	 * response tracker.
-	 */
-	if (msg->msg_ev.type == LNET_EVENT_REPLY ||
-	    msg->msg_ev.type == LNET_EVENT_ACK) {
-		cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
-		lnet_detach_rsp_tracker(msg->msg_md, cpt);
-	}
-
 	/* if the message is successfully sent, no need to keep the MD around */
 	if (msg->msg_md && !status)
 		lnet_detach_md(msg, status);
-- 
1.8.3.1
