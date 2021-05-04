Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70E59C433B4
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:26 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 10F61611AD
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10F61611AD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A303A21F54A;
	Mon,  3 May 2021 17:10:24 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 72D6621F3B4
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 21D0EEDD;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 153288AD3E; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:05 -0400
Message-Id: <1620087016-17857-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/14] lnet: Recover local NI w/exponential
 backoff interval
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

Use an exponential backoff algorithm to determine the interval at
which unhealthy local NIs are ping'd

Introduce lnet_ni_add_to_recoveryq_locked() which handles checking
pre-conditions for whether the NI should be added to the recovery
queue, and takes a ref on the NI as appropriate.

HPE-bug-id: LUS-9109
WC-bug-id: https://jira.whamcloud.com/browse/LU-13569
Lustre-commit: 8fdf2bc62ac9c418 ("LU-13569 lnet: Recover local NI w/exponential backoff interval")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39721
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  9 ++++++++
 include/linux/lnet/lib-types.h |  7 ++++++
 net/lnet/lnet/lib-move.c       | 41 ++++++++++++++++++------------------
 net/lnet/lnet/lib-msg.c        | 48 +++++++++++++++++++++++++++---------------
 4 files changed, 67 insertions(+), 38 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index fd24c10..674f9d1 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -518,6 +518,9 @@ extern void lnet_peer_ni_add_to_recoveryq_locked(struct lnet_peer_ni *lpni,
 extern int lnet_peer_del_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
 void lnet_peer_ni_set_selection_priority(struct lnet_peer_ni *lpni,
 					 u32 priority);
+extern void lnet_ni_add_to_recoveryq_locked(struct lnet_ni *ni,
+					    struct list_head *queue,
+					    time64_t now);
 
 void lnet_router_debugfs_init(void);
 void lnet_router_debugfs_fini(void);
@@ -929,6 +932,12 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 		lnet_get_next_recovery_ping(lpni->lpni_ping_count, now);
 }
 
+static inline void
+lnet_ni_set_next_ping(struct lnet_ni *ni, time64_t now)
+{
+	ni->ni_next_ping = lnet_get_next_recovery_ping(ni->ni_ping_count, now);
+}
+
 /*
  * A peer NI is alive if it satisfies the following two conditions:
  *  1. peer NI health >= LNET_MAX_HEALTH_VALUE * router_sensitivity_percentage
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index a6a7588..f199b15 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -460,6 +460,13 @@ struct lnet_ni {
 	/* Recovery state. Protected by lnet_ni_lock() */
 	u32			ni_recovery_state;
 
+	/* When to send the next recovery ping */
+	time64_t                ni_next_ping;
+	/* How many pings sent during current recovery period did not receive
+	 * a reply. NB: reset whenever _any_ message arrives on this NI
+	 */
+	unsigned int		ni_ping_count;
+
 	/* per NI LND tunables */
 	struct lnet_lnd_tunables ni_lnd_tunables;
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 896ab12..46c88d0 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3103,6 +3103,7 @@ struct lnet_mt_event_info {
 	lnet_nid_t nid;
 	int healthv;
 	int rc;
+	time64_t now;
 
 	/* splice the recovery queue on a local queue. We will iterate
 	 * through the local queue and update it as needed. Once we're
@@ -3115,6 +3116,8 @@ struct lnet_mt_event_info {
 			 &local_queue);
 	lnet_net_unlock(0);
 
+	now = ktime_get_seconds();
+
 	list_for_each_entry_safe(ni, tmp, &local_queue, ni_recovery) {
 		/* if an NI is being deleted or it is now healthy, there
 		 * is no need to keep it around in the recovery queue.
@@ -3147,6 +3150,12 @@ struct lnet_mt_event_info {
 		}
 
 		lnet_ni_unlock(ni);
+
+		if (now < ni->ni_next_ping) {
+			lnet_net_unlock(0);
+			continue;
+		}
+
 		lnet_net_unlock(0);
 
 		CDEBUG(D_NET, "attempting to recover local ni: %s\n",
@@ -3212,31 +3221,21 @@ struct lnet_mt_event_info {
 				LNetMDUnlink(mdh);
 				continue;
 			}
-			/* Same note as in lnet_recover_peer_nis(). When
-			 * we're sending the ping, the NI is free to be
-			 * deleted or manipulated. By this point it
-			 * could've been added back on the recovery queue,
-			 * and a refcount taken on it.
-			 * So we can't just add it blindly again or we'll
-			 * corrupt the queue. We must check under lock if
-			 * it's not on any list and if not then add it
-			 * to the processed list, which will eventually be
-			 * spliced back on to the recovery queue.
-			 */
-			ni->ni_ping_mdh = mdh;
-			if (list_empty(&ni->ni_recovery)) {
-				list_add_tail(&ni->ni_recovery,
-					      &processed_list);
-				lnet_ni_addref_locked(ni, 0);
-			}
-			lnet_net_unlock(0);
+			ni->ni_ping_count++;
 
-			lnet_ni_lock(ni);
-			if (rc)
+			ni->ni_ping_mdh = mdh;
+			lnet_ni_add_to_recoveryq_locked(ni, &processed_list,
+							now);
+			if (rc) {
+				lnet_ni_lock(ni);
 				ni->ni_recovery_state &=
 					~LNET_NI_RECOVERY_PENDING;
+				lnet_ni_unlock(ni);
+			}
+			lnet_net_unlock(0);
+		} else {
+			lnet_ni_unlock(ni);
 		}
-		lnet_ni_unlock(ni);
 	}
 
 	/* put back the remaining NIs on the ln_mt_localNIRecovq to be
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 3f6cd1d..580ddf6 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -455,6 +455,32 @@
 	}
 }
 
+/* must hold net_lock/0 */
+void
+lnet_ni_add_to_recoveryq_locked(struct lnet_ni *ni,
+				struct list_head *recovery_queue, time64_t now)
+{
+	if (!list_empty(&ni->ni_recovery))
+		return;
+
+	if (atomic_read(&ni->ni_healthv) == LNET_MAX_HEALTH_VALUE)
+		return;
+
+	/* This NI is going on the recovery queue, so take a ref on it */
+	lnet_ni_addref_locked(ni, 0);
+
+	lnet_ni_set_next_ping(ni, now);
+
+	CDEBUG(D_NET,
+	       "%s added to recovery queue. ping count: %u next ping: %lld health :%d\n",
+	       libcfs_nid2str(ni->ni_nid),
+	       ni->ni_ping_count,
+	       ni->ni_next_ping,
+	       atomic_read(&ni->ni_healthv));
+
+	list_add_tail(&ni->ni_recovery, recovery_queue);
+}
+
 static void
 lnet_handle_local_failure(struct lnet_ni *local_ni)
 {
@@ -469,21 +495,8 @@
 	}
 
 	lnet_dec_healthv_locked(&local_ni->ni_healthv, lnet_health_sensitivity);
-	/* add the NI to the recovery queue if it's not already there
-	 * and it's health value is actually below the maximum. It's
-	 * possible that the sensitivity might be set to 0, and the health
-	 * value will not be reduced. In this case, there is no reason to
-	 * invoke recovery
-	 */
-	if (list_empty(&local_ni->ni_recovery) &&
-	    atomic_read(&local_ni->ni_healthv) < LNET_MAX_HEALTH_VALUE) {
-		CDEBUG(D_NET, "ni %s added to recovery queue. Health = %d\n",
-		       libcfs_nid2str(local_ni->ni_nid),
-		       atomic_read(&local_ni->ni_healthv));
-		list_add_tail(&local_ni->ni_recovery,
-			      &the_lnet.ln_mt_localNIRecovq);
-		lnet_ni_addref_locked(local_ni, 0);
-	}
+	lnet_ni_add_to_recoveryq_locked(local_ni, &the_lnet.ln_mt_localNIRecovq,
+					ktime_get_seconds());
 	lnet_net_unlock(0);
 }
 
@@ -869,6 +882,8 @@
 		 * faster recovery.
 		 */
 		lnet_inc_healthv(&ni->ni_healthv, lnet_health_sensitivity);
+		lnet_net_lock(0);
+		ni->ni_ping_count = 0;
 		/* It's possible msg_txpeer is NULL in the LOLND
 		 * case. Only increment the peer's health if we're
 		 * receiving a message from it. It's the only sure way to
@@ -882,7 +897,6 @@
 			 * I'm a router, then set that lpni's health to
 			 * maximum so we can commence communication
 			 */
-			lnet_net_lock(0);
 			if (lnet_isrouter(lpni) || the_lnet.ln_routing) {
 				lnet_set_lpni_healthv_locked(lpni,
 							     LNET_MAX_HEALTH_VALUE);
@@ -905,8 +919,8 @@
 								     &the_lnet.ln_mt_peerNIRecovq,
 								     ktime_get_seconds());
 			}
-			lnet_net_unlock(0);
 		}
+		lnet_net_unlock(0);
 
 		/* we can finalize this message */
 		return -1;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
