Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91EE0C433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3D4AF23A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D4AF23A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1BFA221FD2A;
	Thu, 21 Jan 2021 09:18:05 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7C68F21FB9F
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:10 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4D8FB1008058;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4B57A1B49B; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:39 -0500
Message-Id: <1611249422-556-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/39] lnet: discard the callback
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
Cc: Yang Sheng <ys@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Yang Sheng <ys@whamcloud.com>

Lustre need a completion callback for event that request
has been sent. And then need other callback when reply
arrived. Sometime the request completion callback maybe
lost by some reason even reply has been received.
system will wait forever even timeout. We needn't to wait
request completion in such case. So provide a way to
discard the callback.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13368
Lustre-commit: babf0232273467 ("LU-13368 lnet: discard the callback")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38845
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h      | 15 +++++++++-
 fs/lustre/ptlrpc/client.c           | 15 ++++++----
 fs/lustre/ptlrpc/niobuf.c           |  7 +++--
 include/linux/lnet/api.h            |  3 +-
 include/linux/lnet/lib-lnet.h       |  1 +
 include/linux/lnet/lib-types.h      |  1 +
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  1 +
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  4 +++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 58 +++++++++++++++++++++++++++++++++++--
 net/lnet/lnet/lib-md.c              | 25 ++++++++++++++--
 10 files changed, 117 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 61be05c..f16c935 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2225,8 +2225,10 @@ static inline int ptlrpc_status_ntoh(int n)
 	return req->rq_receiving_reply;
 }
 
+#define ptlrpc_cli_wait_unlink(req) __ptlrpc_cli_wait_unlink(req, NULL)
+
 static inline int
-ptlrpc_client_recv_or_unlink(struct ptlrpc_request *req)
+__ptlrpc_cli_wait_unlink(struct ptlrpc_request *req, bool *discard)
 {
 	int rc;
 
@@ -2239,6 +2241,17 @@ static inline int ptlrpc_status_ntoh(int n)
 		spin_unlock(&req->rq_lock);
 		return 1;
 	}
+
+	if (discard) {
+		*discard = false;
+		if (req->rq_reply_unlinked && req->rq_req_unlinked == 0) {
+			*discard = true;
+			spin_unlock(&req->rq_lock);
+			return 1; /* Should call again after LNetMDUnlink */
+		}
+	}
+
+
 	rc = !req->rq_req_unlinked || !req->rq_reply_unlinked ||
 	     req->rq_receiving_reply;
 	spin_unlock(&req->rq_lock);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 4b8aa25..cec4da99 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1783,7 +1783,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			 * not corrupt any data.
 			 */
 			if (req->rq_phase == RQ_PHASE_UNREG_RPC &&
-			    ptlrpc_client_recv_or_unlink(req))
+			    ptlrpc_cli_wait_unlink(req))
 				continue;
 			if (req->rq_phase == RQ_PHASE_UNREG_BULK &&
 			    ptlrpc_client_bulk_active(req))
@@ -1821,7 +1821,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 			ptlrpc_expire_one_request(req, 1);
 
 			/* Check if we still need to wait for unlink. */
-			if (ptlrpc_client_recv_or_unlink(req) ||
+			if (ptlrpc_cli_wait_unlink(req) ||
 			    ptlrpc_client_bulk_active(req))
 				continue;
 			/* If there is no need to resend, fail it now. */
@@ -2599,6 +2599,8 @@ u64 ptlrpc_req_xid(struct ptlrpc_request *request)
  */
 static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 {
+	bool discard = false;
+
 	/* Might sleep. */
 	LASSERT(!in_interrupt());
 
@@ -2609,13 +2611,16 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 					     PTLRPC_REQ_LONG_UNLINK;
 
 	/* Nothing left to do. */
-	if (!ptlrpc_client_recv_or_unlink(request))
+	if (!__ptlrpc_cli_wait_unlink(request, &discard))
 		return 1;
 
 	LNetMDUnlink(request->rq_reply_md_h);
 
+	if (discard) /* Discard the request-out callback */
+		__LNetMDUnlink(request->rq_req_md_h, discard);
+
 	/* Let's check it once again. */
-	if (!ptlrpc_client_recv_or_unlink(request))
+	if (!ptlrpc_cli_wait_unlink(request))
 		return 1;
 
 	/* Move to "Unregistering" phase as reply was not unlinked yet. */
@@ -2636,7 +2641,7 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 		 */
 		while (seconds > PTLRPC_REQ_LONG_UNLINK &&
 		       (wait_event_idle_timeout(*wq,
-						!ptlrpc_client_recv_or_unlink(request),
+						!ptlrpc_cli_wait_unlink(request),
 						HZ)) == 0)
 			seconds -= 1;
 		if (seconds > 0) {
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index a1e6581..5ae7dd1 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -103,12 +103,15 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 	return 0;
 }
 
-static void mdunlink_iterate_helper(struct lnet_handle_md *bd_mds, int count)
+#define mdunlink_iterate_helper(mds, count) \
+		__mdunlink_iterate_helper(mds, count, false)
+static void __mdunlink_iterate_helper(struct lnet_handle_md *bd_mds,
+				      int count, bool discard)
 {
 	int i;
 
 	for (i = 0; i < count; i++)
-		LNetMDUnlink(bd_mds[i]);
+		__LNetMDUnlink(bd_mds[i], discard);
 }
 
 /**
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index 064c92e..891c4a6 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -125,7 +125,8 @@ int LNetMDBind(const struct lnet_md *md_in,
 	       enum lnet_unlink unlink_in,
 	       struct lnet_handle_md *md_handle_out);
 
-int LNetMDUnlink(struct lnet_handle_md md_in);
+int __LNetMDUnlink(struct lnet_handle_md md_in, bool discard);
+#define LNetMDUnlink(handle) __LNetMDUnlink(handle, false)
 
 void lnet_assert_handler_unused(lnet_handler_t handler);
 /** @} lnet_md */
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 6253c16..d349f06 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -625,6 +625,7 @@ void lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *msg,
 void lnet_detach_rsp_tracker(struct lnet_libmd *md, int cpt);
 void lnet_clean_zombie_rstqs(void);
 
+bool lnet_md_discarded(struct lnet_libmd *md);
 void lnet_finalize(struct lnet_msg *msg, int rc);
 bool lnet_send_error_simulation(struct lnet_msg *msg,
 				enum lnet_msg_hstatus *hstatus);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index aaf2a46..7c9d7e2 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -222,6 +222,7 @@ struct lnet_libmd {
  * call.
  */
 #define LNET_MD_FLAG_HANDLING		BIT(3)
+#define LNET_MD_FLAG_DISCARD		BIT(4)
 
 struct lnet_test_peer {
 	/* info about peers we are trying to fail */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index c6a077b..9c65524 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2732,6 +2732,7 @@ static int kiblnd_base_startup(struct net *ns)
 
 	spin_lock_init(&kiblnd_data.kib_connd_lock);
 	INIT_LIST_HEAD(&kiblnd_data.kib_connd_conns);
+	INIT_LIST_HEAD(&kiblnd_data.kib_connd_waits);
 	INIT_LIST_HEAD(&kiblnd_data.kib_connd_zombies);
 	INIT_LIST_HEAD(&kiblnd_data.kib_reconn_list);
 	INIT_LIST_HEAD(&kiblnd_data.kib_reconn_wait);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 2b8d5ff..1fc68e1 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -360,6 +360,8 @@ struct kib_data {
 	struct list_head	kib_reconn_list;
 	/* peers wait for reconnection */
 	struct list_head	kib_reconn_wait;
+	/* connections wait for completion */
+	struct list_head	kib_connd_waits;
 	/*
 	 * The second that peers are pulled out from @kib_reconn_wait
 	 * for reconnection.
@@ -567,6 +569,8 @@ struct kib_conn {
 	u16			ibc_queue_depth;
 	/* connections max frags */
 	u16			ibc_max_frags;
+	/* count of timeout txs waiting on cq */
+	u16			ibc_waits;
 	unsigned int		ibc_nrx:16;	/* receive buffers owned */
 	unsigned int		ibc_scheduled:1;/* scheduled for attention */
 	unsigned int		ibc_ready:1;	/* CQ callback fired */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 20d555f..5cd367e5 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2052,6 +2052,10 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		if (!tx->tx_sending) {
 			tx->tx_queued = 0;
 			list_move(&tx->tx_list, &zombies);
+		} else {
+			/* keep tx until cq destroy */
+			list_move(&tx->tx_list, &conn->ibc_zombie_txs);
+			conn->ibc_waits++;
 		}
 	}
 
@@ -2065,6 +2069,31 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	kiblnd_txlist_done(&zombies, -ECONNABORTED, LNET_MSG_STATUS_OK);
 }
 
+static int
+kiblnd_tx_may_discard(struct kib_conn *conn)
+{
+	int rc = 0;
+	struct kib_tx *nxt;
+	struct kib_tx *tx;
+
+	spin_lock(&conn->ibc_lock);
+
+	list_for_each_entry_safe(tx, nxt, &conn->ibc_zombie_txs, tx_list) {
+		if (tx->tx_sending > 0 && tx->tx_lntmsg[0] &&
+		    lnet_md_discarded(tx->tx_lntmsg[0]->msg_md)) {
+			tx->tx_sending--;
+			if (tx->tx_sending == 0) {
+				kiblnd_conn_decref(tx->tx_conn);
+				tx->tx_conn = NULL;
+				rc = 1;
+			}
+		}
+	}
+
+	spin_unlock(&conn->ibc_lock);
+	return rc;
+}
+
 static void
 kiblnd_finalise_conn(struct kib_conn *conn)
 {
@@ -3221,8 +3250,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		}
 
 		if (ktime_compare(ktime_get(), tx->tx_deadline) >= 0) {
-			CERROR("Timed out tx: %s, %lld seconds\n",
+			CERROR("Timed out tx: %s(WSQ:%d%d%d), %lld seconds\n",
 			       kiblnd_queue2str(conn, txs),
+			       tx->tx_waiting, tx->tx_sending, tx->tx_queued,
 			       kiblnd_timeout() +
 			       ktime_ms_delta(ktime_get(),
 					      tx->tx_deadline) / MSEC_PER_SEC);
@@ -3426,15 +3456,23 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		conn = list_first_entry_or_null(&kiblnd_data.kib_connd_conns,
 						struct kib_conn, ibc_list);
 		if (conn) {
+			int wait;
+
 			list_del(&conn->ibc_list);
 
 			spin_unlock_irqrestore(lock, flags);
 			dropped_lock = 1;
 
 			kiblnd_disconnect_conn(conn);
-			kiblnd_conn_decref(conn);
+			wait = conn->ibc_waits;
+			if (wait == 0) /* keep ref for connd_wait, see below */
+				kiblnd_conn_decref(conn);
 
 			spin_lock_irqsave(lock, flags);
+
+			if (wait)
+				list_add_tail(&conn->ibc_list,
+					      &kiblnd_data.kib_connd_waits);
 		}
 
 		while (reconn < KIB_RECONN_BREAK) {
@@ -3462,6 +3500,22 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			spin_lock_irqsave(lock, flags);
 		}
 
+		conn = list_first_entry_or_null(&kiblnd_data.kib_connd_conns,
+						struct kib_conn, ibc_list);
+		if (conn) {
+			list_del(&conn->ibc_list);
+			spin_unlock_irqrestore(lock, flags);
+
+			dropped_lock = kiblnd_tx_may_discard(conn);
+			if (dropped_lock)
+				kiblnd_conn_decref(conn);
+
+			spin_lock_irqsave(lock, flags);
+			if (dropped_lock == 0)
+				list_add_tail(&conn->ibc_list,
+					      &kiblnd_data.kib_connd_waits);
+		}
+
 		/* careful with the jiffy wrap... */
 		timeout = (int)(deadline - jiffies);
 		if (timeout <= 0) {
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index 203c794..b3f758c 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -465,7 +465,7 @@ void lnet_assert_handler_unused(lnet_handler_t handler)
  *		-ENOENT If @mdh does not point to a valid MD object.
  */
 int
-LNetMDUnlink(struct lnet_handle_md mdh)
+__LNetMDUnlink(struct lnet_handle_md mdh, bool discard)
 {
 	struct lnet_event ev;
 	struct lnet_libmd *md = NULL;
@@ -502,6 +502,9 @@ void lnet_assert_handler_unused(lnet_handler_t handler)
 		handler = md->md_handler;
 	}
 
+	if (discard)
+		md->md_flags |= LNET_MD_FLAG_DISCARD;
+
 	if (md->md_rspt_ptr)
 		lnet_detach_rsp_tracker(md, cpt);
 
@@ -514,4 +517,22 @@ void lnet_assert_handler_unused(lnet_handler_t handler)
 
 	return 0;
 }
-EXPORT_SYMBOL(LNetMDUnlink);
+EXPORT_SYMBOL(__LNetMDUnlink);
+
+bool
+lnet_md_discarded(struct lnet_libmd *md)
+{
+	bool rc;
+	int cpt;
+
+	if (!md)
+		return false;
+
+	cpt = lnet_cpt_of_cookie(md->md_lh.lh_cookie);
+	lnet_res_lock(cpt);
+	rc = md->md_flags & LNET_MD_FLAG_DISCARD;
+	lnet_res_unlock(cpt);
+
+	return rc;
+}
+EXPORT_SYMBOL(lnet_md_discarded);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
