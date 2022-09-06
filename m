Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A6AAEECAAA1
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:13 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7ld27CQz1yBj;
	Mon,  5 Sep 2022 18:56:13 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lH1mQVz1y7H
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E0BA2100B033;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DCAE558992; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:32 -0400
Message-Id: <1662429337-18737-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/24] lnet: Remove duplicate checks for peer
 sensitivity
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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

Callers of lnet_inc_lpni_healthv_locked() and
lnet_dec_healthv_locked() currently check whether the parent peer
has a peer specific sensitivity defined. To remove this code
duplication, this logic is rolled into
lnet_inc_lpni_healthv_locked() and lnet_dec_lpni_healthv_locked().
The latter is a new wrapper around lnet_dec_healthv_locked().

lnet_dec_healthv_locked() is changed to return a bool indicating
whether the health value was actually modified so that the peer
net health is only updated when the peer NI health actually changes.

HPE-bug-id: LUS-11018
WC-bug-id: https://jira.whamcloud.com/browse/LU-15930
Lustre-commit: 84b1ca8618129d4e3 ("LU-15930 lnet: Remove duplicate checks for peer sensitivity")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/46626
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 44 +++++++++++++++++++++++++++++++++++++++----
 net/lnet/lnet/lib-msg.c       | 37 ++----------------------------------
 net/lnet/lnet/router.c        |  9 +--------
 3 files changed, 43 insertions(+), 47 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 2900c05..1d9b8c7 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -1108,13 +1108,49 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 	return mod;
 }
 
+static bool
+lnet_dec_healthv_locked(atomic_t *healthv, int sensitivity)
+{
+	int h = atomic_read(healthv);
+
+	if (h == 0)
+		return false;
+
+	if (h < sensitivity)
+		h = 0;
+	else
+		h -= sensitivity;
+
+	return (atomic_xchg(healthv, h) != h);
+}
+
 static inline void
-lnet_inc_lpni_healthv_locked(struct lnet_peer_ni *lpni, int value)
+lnet_dec_lpni_healthv_locked(struct lnet_peer_ni *lpni)
 {
-	/* only adjust the net health if the lpni health value changed */
-	if (lnet_atomic_add_unless_max(&lpni->lpni_healthv, value,
-				       LNET_MAX_HEALTH_VALUE))
+	/* If there is a health sensitivity in the peer then use that
+	 * instead of the globally set one.
+	 * only adjust the net health if the lpni health value changed
+	 */
+	if (lnet_dec_healthv_locked(&lpni->lpni_healthv,
+			lpni->lpni_peer_net->lpn_peer->lp_health_sensitivity ? :
+			lnet_health_sensitivity)) {
 		lnet_update_peer_net_healthv(lpni);
+	}
+}
+
+static inline void
+lnet_inc_lpni_healthv_locked(struct lnet_peer_ni *lpni)
+{
+	/* If there is a health sensitivity in the peer then use that
+	 * instead of the globally set one.
+	 * only adjust the net health if the lpni health value changed
+	 */
+	if (lnet_atomic_add_unless_max(&lpni->lpni_healthv,
+			lpni->lpni_peer_net->lpn_peer->lp_health_sensitivity ? :
+			lnet_health_sensitivity,
+				       LNET_MAX_HEALTH_VALUE)) {
+		lnet_update_peer_net_healthv(lpni);
+	}
 }
 
 static inline void
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 95695b2..3b1f6a3 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -443,19 +443,6 @@
 	return 0;
 }
 
-static void
-lnet_dec_healthv_locked(atomic_t *healthv, int sensitivity)
-{
-	int h = atomic_read(healthv);
-
-	if (h < sensitivity) {
-		atomic_set(healthv, 0);
-	} else {
-		h -= sensitivity;
-		atomic_set(healthv, h);
-	}
-}
-
 /* must hold net_lock/0 */
 void
 lnet_ni_add_to_recoveryq_locked(struct lnet_ni *ni,
@@ -505,20 +492,7 @@
 void
 lnet_handle_remote_failure_locked(struct lnet_peer_ni *lpni)
 {
-	u32 sensitivity = lnet_health_sensitivity;
-	u32 lp_sensitivity;
-
-	/* If there is a health sensitivity in the peer then use that
-	 * instead of the globally set one.
-	 */
-	lp_sensitivity = lpni->lpni_peer_net->lpn_peer->lp_health_sensitivity;
-	if (lp_sensitivity)
-		sensitivity = lp_sensitivity;
-
-	lnet_dec_healthv_locked(&lpni->lpni_healthv, sensitivity);
-
-	/* update the peer_net's health value */
-	lnet_update_peer_net_healthv(lpni);
+	lnet_dec_lpni_healthv_locked(lpni);
 
 	/* add the peer NI to the recovery queue if it's not already there
 	 * and it's health value is actually below the maximum. It's
@@ -914,14 +888,7 @@
 				lnet_set_lpni_healthv_locked(lpni,
 							     LNET_MAX_HEALTH_VALUE);
 			} else {
-				struct lnet_peer *lpn_peer;
-				u32 sensitivity;
-
-				lpn_peer = lpni->lpni_peer_net->lpn_peer;
-				sensitivity = lpn_peer->lp_health_sensitivity ?
-					      lpn_peer->lp_health_sensitivity :
-					      lnet_health_sensitivity;
-				lnet_inc_lpni_healthv_locked(lpni, sensitivity);
+				lnet_inc_lpni_healthv_locked(lpni);
 				/* This peer NI may have previously aged out
 				 * of recovery. Now that we've received a
 				 * message from it, we can continue recovery
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 98707e9..146647c 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1761,14 +1761,7 @@ bool lnet_router_checker_active(void)
 			lnet_set_lpni_healthv_locked(lpni,
 						     LNET_MAX_HEALTH_VALUE);
 		} else {
-			struct lnet_peer *lpn_peer;
-			u32 sensitivity;
-
-			lpn_peer = lpni->lpni_peer_net->lpn_peer;
-			sensitivity = lpn_peer->lp_health_sensitivity;
-			lnet_inc_lpni_healthv_locked(lpni,
-						     (sensitivity) ? sensitivity :
-						     lnet_health_sensitivity);
+			lnet_inc_lpni_healthv_locked(lpni);
 		}
 	} else if (reset) {
 		lpni->lpni_ns_status = LNET_NI_STATUS_DOWN;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
