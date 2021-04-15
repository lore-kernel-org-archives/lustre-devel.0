Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D90CC433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:56 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D75F5610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D75F5610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 720D021FE54;
	Wed, 14 Apr 2021 21:03:55 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1EE4532F601
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:59 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C6850100F373;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C54209188F; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:35 -0400
Message-Id: <1618459361-17909-44-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 43/49] lnet: Age peer NI out of recovery
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

No longer send recovery pings to a peer NI that has been in recovery
for the recovery time limit. A peer NI will become eligible for
recovery again once we receive a message from it.

The existing lpni_last_alive field is utilized for this new purpose.

A check for NULL lpni is removed from
lnet_handle_remote_failure_locked() because all callers of that
function already ensure the lpni is non-NULL.

lnet_peer_ni_add_to_recoveryq_locked() now takes the recovery queue
as an argument rather than using the_lnet.ln_mt_peerNIRecovq. This
allows the function to be used by lnet_recover_peer_nis().
lnet_peer_ni_add_to_recoveryq_locked() is also modified to take a ref
on the peer NI if it is added to the recovery queue. Previously, it
was the responsibility of callers to take this ref.

HPE-bug-id: LUS-9109
WC-bug-id: https://jira.whamcloud.com/browse/LU-13569
Lustre-commit: cc27201a76574b5 ("LU-13569 lnet: Age peer NI out of recovery")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39718
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  4 +++-
 net/lnet/lnet/lib-move.c      | 40 ++++++++++++++++---------------------
 net/lnet/lnet/lib-msg.c       | 25 ++++++++++++++---------
 net/lnet/lnet/peer.c          | 46 ++++++++++++++++++++++++++++++++-----------
 4 files changed, 70 insertions(+), 45 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 1954614..e30d0c4 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -513,7 +513,9 @@ struct lnet_ni *lnet_get_next_ni_locked(struct lnet_net *mynet,
 int lnet_get_peer_list(u32 *countp, u32 *sizep,
 		       struct lnet_process_id __user *ids);
 extern void lnet_peer_ni_set_healthv(lnet_nid_t nid, int value, bool all);
-extern void lnet_peer_ni_add_to_recoveryq_locked(struct lnet_peer_ni *lpni);
+extern void lnet_peer_ni_add_to_recoveryq_locked(struct lnet_peer_ni *lpni,
+						 struct list_head *queue,
+						 time64_t now);
 extern int lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
 extern void lnet_peer_clr_pref_nids(struct lnet_peer_ni *lpni);
 extern int lnet_peer_del_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 1868506..bdcba54 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3356,6 +3356,7 @@ struct lnet_mt_event_info {
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer_ni *tmp;
 	lnet_nid_t nid;
+	time64_t now;
 	int healthv;
 	int rc;
 
@@ -3367,6 +3368,8 @@ struct lnet_mt_event_info {
 			 &local_queue);
 	lnet_net_unlock(0);
 
+	now = ktime_get_seconds();
+
 	list_for_each_entry_safe(lpni, tmp, &local_queue,
 				 lpni_recovery) {
 		/* The same protection strategy is used here as is in the
@@ -3444,30 +3447,22 @@ struct lnet_mt_event_info {
 			}
 
 			lpni->lpni_recovery_ping_mdh = mdh;
-			/* While we're unlocked the lpni could've been
-			 * readded on the recovery queue. In this case we
-			 * don't need to add it to the local queue, since
-			 * it's already on there and the thread that added
-			 * it would've incremented the refcount on the
-			 * peer, which means we need to decref the refcount
-			 * that was implicitly grabbed by find_peer_ni_locked.
-			 * Otherwise, if the lpni is still not on
-			 * the recovery queue, then we'll add it to the
-			 * processed list.
-			 */
-			if (list_empty(&lpni->lpni_recovery))
-				list_add_tail(&lpni->lpni_recovery,
-					      &processed_list);
-			else
-				lnet_peer_ni_decref_locked(lpni);
-			lnet_net_unlock(0);
-
-			spin_lock(&lpni->lpni_lock);
-			if (rc)
+			lnet_peer_ni_add_to_recoveryq_locked(lpni,
+							     &processed_list,
+							     now);
+			if (rc) {
+				spin_lock(&lpni->lpni_lock);
 				lpni->lpni_state &=
 					~LNET_PEER_NI_RECOVERY_PENDING;
+				spin_unlock(&lpni->lpni_lock);
+			}
+
+			/* Drop the ref taken by lnet_find_peer_ni_locked() */
+			lnet_peer_ni_decref_locked(lpni);
+			lnet_net_unlock(0);
+		} else {
+			spin_unlock(&lpni->lpni_lock);
 		}
-		spin_unlock(&lpni->lpni_lock);
 	}
 
 	list_splice_init(&processed_list, &local_queue);
@@ -4384,8 +4379,7 @@ void lnet_monitor_thr_stop(void)
 		}
 	}
 
-	if (the_lnet.ln_routing)
-		lpni->lpni_last_alive = ktime_get_seconds();
+	lpni->lpni_last_alive = ktime_get_seconds();
 
 	msg->msg_rxpeer = lpni;
 	msg->msg_rxni = ni;
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index d888090..2e8fea7 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -488,19 +488,13 @@
 	lnet_net_unlock(0);
 }
 
+/* must hold net_lock/0 */
 void
 lnet_handle_remote_failure_locked(struct lnet_peer_ni *lpni)
 {
 	u32 sensitivity = lnet_health_sensitivity;
 	u32 lp_sensitivity;
 
-	/* NO-OP if:
-	 * 1. lpni could be NULL if we're in the LOLND case
-	 * 2. this is a recovery message
-	 */
-	if (!lpni)
-		return;
-
 	/* If there is a health sensitivity in the peer then use that
 	 * instead of the globally set one.
 	 */
@@ -519,7 +513,9 @@
 	 * value will not be reduced. In this case, there is no reason to
 	 * invoke recovery
 	 */
-	lnet_peer_ni_add_to_recoveryq_locked(lpni);
+	lnet_peer_ni_add_to_recoveryq_locked(lpni,
+					     &the_lnet.ln_mt_peerNIRecovq,
+					     ktime_get_seconds());
 }
 
 static void
@@ -892,8 +888,19 @@
 				u32 sensitivity;
 
 				lpn_peer = lpni->lpni_peer_net->lpn_peer;
-				sensitivity = lpn_peer->lp_health_sensitivity;
+				sensitivity = lpn_peer->lp_health_sensitivity ?
+					      lpn_peer->lp_health_sensitivity :
+					      lnet_health_sensitivity;
 				lnet_inc_lpni_healthv_locked(lpni, sensitivity);
+				/* This peer NI may have previously aged out
+				 * of recovery. Now that we've received a
+				 * message from it, we can continue recovery
+				 * if its health value is still below the
+				 * maximum.
+				 */
+				lnet_peer_ni_add_to_recoveryq_locked(lpni,
+								     &the_lnet.ln_mt_peerNIRecovq,
+								     ktime_get_seconds());
 			}
 			lnet_net_unlock(0);
 		}
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index ba41d86..fe80b81 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3978,22 +3978,38 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	return rc;
 }
 
+/* must hold net_lock/0 */
 void
-lnet_peer_ni_add_to_recoveryq_locked(struct lnet_peer_ni *lpni)
+lnet_peer_ni_add_to_recoveryq_locked(struct lnet_peer_ni *lpni,
+				     struct list_head *recovery_queue,
+				     time64_t now)
 {
 	/* the mt could've shutdown and cleaned up the queues */
 	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING)
 		return;
 
-	if (list_empty(&lpni->lpni_recovery) &&
-	    atomic_read(&lpni->lpni_healthv) < LNET_MAX_HEALTH_VALUE) {
-		CDEBUG(D_NET, "lpni %s added to recovery queue. Health = %d\n",
+	if (!list_empty(&lpni->lpni_recovery))
+		return;
+
+	if (atomic_read(&lpni->lpni_healthv) == LNET_MAX_HEALTH_VALUE)
+		return;
+
+	if (now > lpni->lpni_last_alive + lnet_recovery_limit) {
+		CDEBUG(D_NET, "lpni %s aged out last alive %lld\n",
 		       libcfs_nid2str(lpni->lpni_nid),
-		       atomic_read(&lpni->lpni_healthv));
-		list_add_tail(&lpni->lpni_recovery,
-			      &the_lnet.ln_mt_peerNIRecovq);
-		lnet_peer_ni_addref_locked(lpni);
+		       lpni->lpni_last_alive);
+		return;
 	}
+
+	/* This peer NI is going on the recovery queue, so take a ref on it */
+	lnet_peer_ni_addref_locked(lpni);
+
+	CDEBUG(D_NET, "%s added to recovery queue. last alive: %lld health: %d\n",
+	       libcfs_nid2str(lpni->lpni_nid),
+	       lpni->lpni_last_alive,
+	       atomic_read(&lpni->lpni_healthv));
+
+	list_add_tail(&lpni->lpni_recovery, recovery_queue);
 }
 
 /* Call with the ln_api_mutex held */
@@ -4006,10 +4022,13 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	struct lnet_peer_ni *lpni;
 	int lncpt;
 	int cpt;
+	time64_t now;
 
 	if (the_lnet.ln_state != LNET_STATE_RUNNING)
 		return;
 
+	now = ktime_get_seconds();
+
 	if (!all) {
 		lnet_net_lock(LNET_LOCK_EX);
 		lpni = lnet_find_peer_ni_locked(nid);
@@ -4018,7 +4037,8 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 			return;
 		}
 		atomic_set(&lpni->lpni_healthv, value);
-		lnet_peer_ni_add_to_recoveryq_locked(lpni);
+		lnet_peer_ni_add_to_recoveryq_locked(lpni,
+						     &the_lnet.ln_mt_peerNIRecovq, now);
 		lnet_peer_ni_decref_locked(lpni);
 		lnet_net_unlock(LNET_LOCK_EX);
 		return;
@@ -4026,8 +4046,8 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 
 	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
 
-	/* Walk all the peers and reset the healhv for each one to the
-	 * maximum value.
+	/* Walk all the peers and reset the healh value for each one to the
+	 * specified value.
 	 */
 	lnet_net_lock(LNET_LOCK_EX);
 	for (cpt = 0; cpt < lncpt; cpt++) {
@@ -4038,7 +4058,9 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 				list_for_each_entry(lpni, &lpn->lpn_peer_nis,
 						    lpni_peer_nis) {
 					atomic_set(&lpni->lpni_healthv, value);
-					lnet_peer_ni_add_to_recoveryq_locked(lpni);
+					lnet_peer_ni_add_to_recoveryq_locked(lpni,
+									     &the_lnet.ln_mt_peerNIRecovq,
+									     now);
 				}
 			}
 		}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
