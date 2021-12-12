Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EB883C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:09:18 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4276221F549;
	Sun, 12 Dec 2021 07:08:29 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6C6BD21CBC4
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:07 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B6DA610084C0;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A93CBE07E6; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:07:54 -0500
Message-Id: <1639321683-22909-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/12] lustre: ptlrpc: Do not unlink
 difficult reply until sent
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

If a difficult reply is queued in LNet, or the PUT for it is
otherwise delayed, then it is possible for the commit callback
to unlink the reply MD which will abort the send. This results in
client hitting "slow reply" timeout for the associated RPC and
an unnecessary reconnect (and possibly resend).

This patch replaces the rs_on_net flag with rs_sent and rs_unlinked.
These flags indicate whether the send event for the reply MD has
been generated, and whether the MD has been unlinked, respectively.

If rs_sent is set, but rs_unlinked has not been set, then ptlrpc_hr
is free to unlink the reply MD as a result of the commit callback.
The reply-ack will simply be dropped by the server.

If ptlrpc_hr is processing the reply because of commit callback, and
rs_sent has not been set, then ptlrpc_hr will not unlink the reply
MD. This means that the reply_out_callback must also be modified to
check for this case when the send event occurs. Otherwise, if the ACK
never arrives from the client, then the MD would never be unlinked.
Thus when the send event occurs, and rs_handled is set, the
reply_out_callback will schedule the reply for handling by ptlrpc_hr.

HPE-bug-id: LUS-10505
WC-bug-id: https://jira.whamcloud.com/browse/LU-15068
Lustre-commit: 5c156b48425aae245 ("LU-15068 ptlrpc: Do not unlink difficult reply until sent")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/45138
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h  |  3 ++-
 fs/lustre/ldlm/ldlm_lib.c       | 11 +++++++----
 fs/lustre/ptlrpc/events.c       | 19 ++++++++++++++++---
 fs/lustre/ptlrpc/pack_generic.c |  2 +-
 fs/lustre/ptlrpc/service.c      | 10 +++++++---
 5 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index f72f7c6..78df59b 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -492,7 +492,8 @@ struct ptlrpc_reply_state {
 	unsigned long		rs_scheduled:1; /* being handled? */
 	unsigned long		rs_scheduled_ever:1; /* any schedule attempts? */
 	unsigned long		rs_handled:1;	/* been handled yet? */
-	unsigned long		rs_on_net:1;	/* reply_out_callback pending? */
+	unsigned long		rs_sent:1;	/* Got LNET_EVENT_SEND? */
+	unsigned long		rs_unlinked:1;	/* Reply MD unlinked? */
 	unsigned long		rs_prealloc:1;	/* rs from prealloc list */
 	unsigned long		rs_committed:1;	/* the transaction was committed
 						 * and the rs was dispatched
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 90bad71..9aa87d1 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -813,7 +813,8 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 	LASSERT(!rs->rs_scheduled);
 	LASSERT(!rs->rs_scheduled_ever);
 	LASSERT(!rs->rs_handled);
-	LASSERT(!rs->rs_on_net);
+	LASSERT(!rs->rs_sent);
+	LASSERT(!rs->rs_unlinked);
 	LASSERT(!rs->rs_export);
 	LASSERT(list_empty(&rs->rs_obd_list));
 	LASSERT(list_empty(&rs->rs_exp_list));
@@ -822,7 +823,8 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 
 	/* disable reply scheduling while I'm setting up */
 	rs->rs_scheduled = 1;
-	rs->rs_on_net = 1;
+	rs->rs_sent = 0;
+	rs->rs_unlinked = 0;
 	rs->rs_xid = req->rq_xid;
 	rs->rs_transno = req->rq_transno;
 	rs->rs_export = exp;
@@ -856,13 +858,14 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 		 * would have been +1 ref for the net, which
 		 * reply_out_callback leaves alone)
 		 */
-		rs->rs_on_net = 0;
+		rs->rs_sent = 1;
+		rs->rs_unlinked = 1;
 		ptlrpc_rs_addref(rs);
 	}
 
 	spin_lock(&rs->rs_lock);
 	if (rs->rs_transno <= exp->exp_last_committed ||
-	    (!rs->rs_on_net && !rs->rs_no_ack) ||
+	    (rs->rs_unlinked && !rs->rs_no_ack) ||
 	    list_empty(&rs->rs_exp_list) ||     /* completed already */
 	    list_empty(&rs->rs_obd_list)) {
 		CDEBUG(D_HA, "Schedule reply immediately\n");
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 559d811..dbf9f9d 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -401,6 +401,7 @@ void reply_out_callback(struct lnet_event *ev)
 	struct ptlrpc_cb_id *cbid = ev->md_user_ptr;
 	struct ptlrpc_reply_state *rs = cbid->cbid_arg;
 	struct ptlrpc_service_part *svcpt = rs->rs_svcpt;
+	bool need_schedule = false;
 
 	LASSERT(ev->type == LNET_EVENT_SEND ||
 		ev->type == LNET_EVENT_ACK ||
@@ -415,16 +416,28 @@ void reply_out_callback(struct lnet_event *ev)
 		return;
 	}
 
-	LASSERT(rs->rs_on_net);
+	if (ev->type == LNET_EVENT_SEND) {
+		spin_lock(&rs->rs_lock);
+		rs->rs_sent = 1;
+		/* If transaction was committed before the SEND, and the ACK
+		 * is lost, then we need to schedule so ptlrpc_hr can unlink
+		 * the MD.
+		 */
+		if (rs->rs_handled)
+			need_schedule = true;
+		spin_unlock(&rs->rs_lock);
+	}
+
+	if (ev->unlinked || need_schedule) {
+		LASSERT(rs->rs_sent);
 
-	if (ev->unlinked) {
 		/* Last network callback. The net's ref on 'rs' stays put
 		 * until ptlrpc_handle_rs() is done with it
 		 */
 		spin_lock(&svcpt->scp_rep_lock);
 		spin_lock(&rs->rs_lock);
 
-		rs->rs_on_net = 0;
+		rs->rs_unlinked = ev->unlinked;
 		if (!rs->rs_no_ack ||
 		    rs->rs_transno <=
 		    rs->rs_export->exp_obd->obd_last_committed ||
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 62e060d..23b36de 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -458,7 +458,7 @@ void lustre_free_reply_state(struct ptlrpc_reply_state *rs)
 
 	LASSERT(atomic_read(&rs->rs_refcount) == 0);
 	LASSERT(!rs->rs_difficult || rs->rs_handled);
-	LASSERT(!rs->rs_on_net);
+	LASSERT(!rs->rs_difficult || rs->rs_unlinked);
 	LASSERT(!rs->rs_scheduled);
 	LASSERT(!rs->rs_export);
 	LASSERT(rs->rs_nlocks == 0);
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 2917ca3..dbe2347 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1940,10 +1940,14 @@ static int ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 		       libcfs_nid2str(exp->exp_connection->c_peer.nid));
 	}
 
-	if ((!been_handled && rs->rs_on_net) || nlocks > 0) {
+	if ((rs->rs_sent && !rs->rs_unlinked) || nlocks > 0) {
 		spin_unlock(&rs->rs_lock);
 
-		if (!been_handled && rs->rs_on_net) {
+		/* We can unlink if the LNET_EVENT_SEND has occurred.
+		 * If rs_unlinked is set then MD is already unlinked and no
+		 * need to do so here.
+		 */
+		if ((rs->rs_sent && !rs->rs_unlinked)) {
 			LNetMDUnlink(rs->rs_md_h);
 			/* Ignore return code; we're racing with completion */
 		}
@@ -1957,7 +1961,7 @@ static int ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 
 	rs->rs_scheduled = 0;
 
-	if (!rs->rs_on_net) {
+	if (rs->rs_unlinked) {
 		/* Off the net */
 		spin_unlock(&rs->rs_lock);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
