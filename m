Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B7379C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:37 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CF16521FCCD;
	Sun, 20 Mar 2022 06:32:28 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0ACB921CABE
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3A5CCEEF;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 391B5D87DE; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:38 -0400
Message-Id: <1647783064-20688-25-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/50] lnet: Convert ping to support 16-bytes
 address
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

Now that ksocknal can send hello messages with 16-byte address, we can
change lnet_send_ping() to ping hosts with large-address nids.

Note that this doesn't change the addresses in the ping message sent,
only the sending and receiving of the message.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 3e37ac8bb7e068a30 ("LU-10391 lnet: Convert ping to support 16-bytes address")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43612
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  5 +++--
 net/lnet/lnet/lib-move.c      | 42 ++++++++++++++++++++----------------------
 net/lnet/lnet/peer.c          |  3 +--
 3 files changed, 24 insertions(+), 26 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 0155111..297e5ef 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -643,8 +643,9 @@ void lnet_prep_send(struct lnet_msg *msg, int type,
 		    unsigned int len);
 int lnet_send(struct lnet_nid *nid, struct lnet_msg *msg,
 	      struct lnet_nid *rtr_nid);
-int lnet_send_ping(lnet_nid_t dest_nid, struct lnet_handle_md *mdh, int nnis,
-		   void *user_ptr, lnet_handler_t handler, bool recovery);
+int lnet_send_ping(struct lnet_nid *dest_nid, struct lnet_handle_md *mdh,
+		   int nnis, void *user_ptr, lnet_handler_t handler,
+		   bool recovery);
 void lnet_return_tx_credits_locked(struct lnet_msg *msg);
 void lnet_return_rx_credits_locked(struct lnet_msg *msg);
 void lnet_schedule_blocked_locked(struct lnet_rtrbufpool *rbp);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index aa230d7..496c895 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2891,8 +2891,8 @@ enum lnet_mt_event_type {
 };
 
 struct lnet_mt_event_info {
-	enum lnet_mt_event_type mt_type;
-	lnet_nid_t mt_nid;
+	enum lnet_mt_event_type	mt_type;
+	struct lnet_nid		mt_nid;
 };
 
 /* called with res_lock held */
@@ -3176,7 +3176,7 @@ struct lnet_mt_event_info {
 	struct lnet_handle_md mdh;
 	struct lnet_ni *tmp;
 	struct lnet_ni *ni;
-	lnet_nid_t nid;
+	struct lnet_nid nid;
 	int healthv;
 	int rc;
 	time64_t now;
@@ -3258,8 +3258,7 @@ struct lnet_mt_event_info {
 			 * We'll unlink the mdh in this case below.
 			 */
 			LNetInvalidateMDHandle(&ni->ni_ping_mdh);
-			/* FIXME need to handle large-addr nid */
-			nid = lnet_nid_to_nid4(&ni->ni_nid);
+			nid = ni->ni_nid;
 
 			/* remove the NI from the local queue and drop the
 			 * reference count to it while we're recovering
@@ -3284,12 +3283,12 @@ struct lnet_mt_event_info {
 
 			ev_info->mt_type = MT_TYPE_LOCAL_NI;
 			ev_info->mt_nid = nid;
-			rc = lnet_send_ping(nid, &mdh, LNET_INTERFACES_MIN,
+			rc = lnet_send_ping(&nid, &mdh, LNET_INTERFACES_MIN,
 					    ev_info, the_lnet.ln_mt_handler,
 					    true);
 			/* lookup the nid again */
 			lnet_net_lock(0);
-			ni = lnet_nid2ni_locked(nid, 0);
+			ni = lnet_nid_to_ni_locked(&nid, 0);
 			if (!ni) {
 				/* the NI has been deleted when we dropped
 				 * the ref count
@@ -3430,7 +3429,7 @@ struct lnet_mt_event_info {
 	struct lnet_handle_md mdh;
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer_ni *tmp;
-	lnet_nid_t nid;
+	struct lnet_nid nid;
 	time64_t now;
 	int healthv;
 	int rc;
@@ -3504,9 +3503,8 @@ struct lnet_mt_event_info {
 
 			/* look at the comments in lnet_recover_local_nis() */
 			mdh = lpni->lpni_recovery_ping_mdh;
+			nid = lpni->lpni_nid;
 			LNetInvalidateMDHandle(&lpni->lpni_recovery_ping_mdh);
-			/* FIXME handle large-addr nid */
-			nid = lnet_nid_to_nid4(&lpni->lpni_nid);
 			lnet_net_lock(0);
 			list_del_init(&lpni->lpni_recovery);
 			lnet_peer_ni_decref_locked(lpni);
@@ -3514,14 +3512,14 @@ struct lnet_mt_event_info {
 
 			ev_info->mt_type = MT_TYPE_PEER_NI;
 			ev_info->mt_nid = nid;
-			rc = lnet_send_ping(nid, &mdh, LNET_INTERFACES_MIN,
+			rc = lnet_send_ping(&nid, &mdh, LNET_INTERFACES_MIN,
 					    ev_info, the_lnet.ln_mt_handler,
 					    true);
 			lnet_net_lock(0);
 			/* lnet_find_peer_ni_locked() grabs a refcount for
 			 * us. No need to take it explicitly.
 			 */
-			lpni = lnet_find_peer_ni_locked(nid);
+			lpni = lnet_peer_ni_find_locked(&nid);
 			if (!lpni) {
 				lnet_net_unlock(0);
 				LNetMDUnlink(mdh);
@@ -3622,7 +3620,7 @@ struct lnet_mt_event_info {
  * Returns < 0 if LNetGet fails
  */
 int
-lnet_send_ping(lnet_nid_t dest_nid,
+lnet_send_ping(struct lnet_nid *dest_nid,
 	       struct lnet_handle_md *mdh, int nnis,
 	       void *user_data, lnet_handler_t handler, bool recovery)
 {
@@ -3631,7 +3629,7 @@ struct lnet_mt_event_info {
 	struct lnet_ping_buffer *pbuf;
 	int rc;
 
-	if (dest_nid == LNET_NID_ANY) {
+	if (LNET_NID_IS_ANY(dest_nid)) {
 		rc = -EHOSTUNREACH;
 		goto fail_error;
 	}
@@ -3659,7 +3657,7 @@ struct lnet_mt_event_info {
 		goto fail_error;
 	}
 	id.pid = LNET_PID_LUSTRE;
-	id.nid = dest_nid;
+	id.nid = lnet_nid_to_nid4(dest_nid);
 
 	rc = LNetGet(LNET_NID_ANY, *mdh, id,
 		     LNET_RESERVED_PORTAL,
@@ -3680,13 +3678,13 @@ struct lnet_mt_event_info {
 lnet_handle_recovery_reply(struct lnet_mt_event_info *ev_info,
 			   int status, bool send, bool unlink_event)
 {
-	lnet_nid_t nid = ev_info->mt_nid;
+	struct lnet_nid *nid = &ev_info->mt_nid;
 
 	if (ev_info->mt_type == MT_TYPE_LOCAL_NI) {
 		struct lnet_ni *ni;
 
 		lnet_net_lock(0);
-		ni = lnet_nid2ni_locked(nid, 0);
+		ni = lnet_nid_to_ni_locked(nid, 0);
 		if (!ni) {
 			lnet_net_unlock(0);
 			return;
@@ -3701,7 +3699,7 @@ struct lnet_mt_event_info {
 
 		if (status != 0) {
 			CERROR("local NI (%s) recovery failed with %d\n",
-			       libcfs_nid2str(nid), status);
+			       libcfs_nidstr(nid), status);
 			return;
 		}
 		/* need to increment healthv for the ni here, because in
@@ -3718,7 +3716,7 @@ struct lnet_mt_event_info {
 		int cpt;
 
 		cpt = lnet_net_lock_current();
-		lpni = lnet_find_peer_ni_locked(nid);
+		lpni = lnet_peer_ni_find_locked(nid);
 		if (!lpni) {
 			lnet_net_unlock(cpt);
 			return;
@@ -3733,7 +3731,7 @@ struct lnet_mt_event_info {
 
 		if (status != 0)
 			CERROR("peer NI (%s) recovery failed with %d\n",
-			       libcfs_nid2str(nid), status);
+			       libcfs_nidstr(nid), status);
 	}
 }
 
@@ -3754,7 +3752,7 @@ struct lnet_mt_event_info {
 	switch (event->type) {
 	case LNET_EVENT_UNLINK:
 		CDEBUG(D_NET, "%s recovery ping unlinked\n",
-		       libcfs_nid2str(ev_info->mt_nid));
+		       libcfs_nidstr(&ev_info->mt_nid));
 		/* fall-through */
 	case LNET_EVENT_REPLY:
 		lnet_handle_recovery_reply(ev_info, event->status, false,
@@ -3762,7 +3760,7 @@ struct lnet_mt_event_info {
 		break;
 	case LNET_EVENT_SEND:
 		CDEBUG(D_NET, "%s recovery message sent %s:%d\n",
-		       libcfs_nid2str(ev_info->mt_nid),
+		       libcfs_nidstr(&ev_info->mt_nid),
 		       (event->status) ? "unsuccessfully" :
 		       "successfully", event->status);
 		lnet_handle_recovery_reply(ev_info, event->status, true, false);
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index d0b7bc8..494b7ef 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3471,8 +3471,7 @@ static int lnet_peer_send_ping(struct lnet_peer *lp)
 
 	nnis = max_t(int, lp->lp_data_nnis, LNET_INTERFACES_MIN);
 
-	rc = lnet_send_ping(lnet_nid_to_nid4(&lp->lp_primary_nid),
-			    &lp->lp_ping_mdh, nnis, lp,
+	rc = lnet_send_ping(&lp->lp_primary_nid, &lp->lp_ping_mdh, nnis, lp,
 			    the_lnet.ln_dc_handler, false);
 	/* if LNetMDBind in lnet_send_ping fails we need to decrement the
 	 * refcount on the peer, otherwise LNetMDUnlink will be called
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
