From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:13 -0500
Subject: [lustre-devel] [PATCH 145/622] lnet: unlink md if fail to send
 recovery
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-146-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

MD for recovery ping should be unlinked if we fail to send the GET.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11474
Lustre-commit: e0132e16df15 ("LU-11474 lnet: unlink md if fail to send recovery")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33306
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  7 ++++--
 net/lnet/lnet/lib-move.c       | 48 +++++++++++++++++++++++++++++++++---------
 2 files changed, 43 insertions(+), 12 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index f82ebb6..b2159b0 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -317,7 +317,8 @@ struct lnet_tx_queue {
 #define LNET_NI_STATE_ACTIVE		(1 << 1)
 #define LNET_NI_STATE_FAILED		(1 << 2)
 #define LNET_NI_STATE_RECOVERY_PENDING	(1 << 3)
-#define LNET_NI_STATE_DELETING		(1 << 4)
+#define LNET_NI_STATE_RECOVERY_FAILED	BIT(4)
+#define LNET_NI_STATE_DELETING		BIT(5)
 
 enum lnet_stats_type {
 	LNET_STATS_TYPE_SEND	= 0,
@@ -606,8 +607,10 @@ struct lnet_peer_ni {
 #define LNET_PEER_NI_NON_MR_PREF	BIT(0)
 /* peer is being recovered. */
 #define LNET_PEER_NI_RECOVERY_PENDING	BIT(1)
+/* recovery ping failed */
+#define LNET_PEER_NI_RECOVERY_FAILED	BIT(2)
 /* peer is being deleted */
-#define LNET_PEER_NI_DELETING		BIT(2)
+#define LNET_PEER_NI_DELETING		BIT(3)
 
 struct lnet_peer {
 	/* chain on pt_peer_list */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 38ee970..b54fbab 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2615,13 +2615,13 @@ struct lnet_mt_event_info {
 
 /* called with cpt and ni_lock held */
 static void
-lnet_unlink_ni_recovery_mdh_locked(struct lnet_ni *ni, int cpt)
+lnet_unlink_ni_recovery_mdh_locked(struct lnet_ni *ni, int cpt, bool force)
 {
 	struct lnet_handle_md recovery_mdh;
 
 	LNetInvalidateMDHandle(&recovery_mdh);
 
-	if (ni->ni_state & LNET_NI_STATE_RECOVERY_PENDING) {
+	if (ni->ni_state & LNET_NI_STATE_RECOVERY_PENDING || force) {
 		recovery_mdh = ni->ni_ping_mdh;
 		LNetInvalidateMDHandle(&ni->ni_ping_mdh);
 	}
@@ -2675,12 +2675,22 @@ struct lnet_mt_event_info {
 		if (!(ni->ni_state & LNET_NI_STATE_ACTIVE) ||
 		    healthv == LNET_MAX_HEALTH_VALUE) {
 			list_del_init(&ni->ni_recovery);
-			lnet_unlink_ni_recovery_mdh_locked(ni, 0);
+			lnet_unlink_ni_recovery_mdh_locked(ni, 0, false);
 			lnet_ni_unlock(ni);
 			lnet_ni_decref_locked(ni, 0);
 			lnet_net_unlock(0);
 			continue;
 		}
+
+		/* if the local NI failed recovery we must unlink the md.
+		 * But we want to keep the local_ni on the recovery queue
+		 * so we can continue the attempts to recover it.
+		 */
+		if (ni->ni_state & LNET_NI_STATE_RECOVERY_FAILED) {
+			lnet_unlink_ni_recovery_mdh_locked(ni, 0, true);
+			ni->ni_state &= ~LNET_NI_STATE_RECOVERY_FAILED;
+		}
+
 		lnet_ni_unlock(ni);
 		lnet_net_unlock(0);
 
@@ -2829,7 +2839,7 @@ struct lnet_mt_event_info {
 				struct lnet_ni, ni_recovery);
 		list_del_init(&ni->ni_recovery);
 		lnet_ni_lock(ni);
-		lnet_unlink_ni_recovery_mdh_locked(ni, 0);
+		lnet_unlink_ni_recovery_mdh_locked(ni, 0, true);
 		lnet_ni_unlock(ni);
 		lnet_ni_decref_locked(ni, 0);
 	}
@@ -2838,13 +2848,14 @@ struct lnet_mt_event_info {
 }
 
 static void
-lnet_unlink_lpni_recovery_mdh_locked(struct lnet_peer_ni *lpni, int cpt)
+lnet_unlink_lpni_recovery_mdh_locked(struct lnet_peer_ni *lpni, int cpt,
+				     bool force)
 {
 	struct lnet_handle_md recovery_mdh;
 
 	LNetInvalidateMDHandle(&recovery_mdh);
 
-	if (lpni->lpni_state & LNET_PEER_NI_RECOVERY_PENDING) {
+	if (lpni->lpni_state & LNET_PEER_NI_RECOVERY_PENDING || force) {
 		recovery_mdh = lpni->lpni_recovery_ping_mdh;
 		LNetInvalidateMDHandle(&lpni->lpni_recovery_ping_mdh);
 	}
@@ -2867,7 +2878,7 @@ struct lnet_mt_event_info {
 				 lpni_recovery) {
 		list_del_init(&lpni->lpni_recovery);
 		spin_lock(&lpni->lpni_lock);
-		lnet_unlink_lpni_recovery_mdh_locked(lpni, LNET_LOCK_EX);
+		lnet_unlink_lpni_recovery_mdh_locked(lpni, LNET_LOCK_EX, true);
 		spin_unlock(&lpni->lpni_lock);
 		lnet_peer_ni_decref_locked(lpni);
 	}
@@ -2933,12 +2944,22 @@ struct lnet_mt_event_info {
 		if (lpni->lpni_state & LNET_PEER_NI_DELETING ||
 		    healthv == LNET_MAX_HEALTH_VALUE) {
 			list_del_init(&lpni->lpni_recovery);
-			lnet_unlink_lpni_recovery_mdh_locked(lpni, 0);
+			lnet_unlink_lpni_recovery_mdh_locked(lpni, 0, false);
 			spin_unlock(&lpni->lpni_lock);
 			lnet_peer_ni_decref_locked(lpni);
 			lnet_net_unlock(0);
 			continue;
 		}
+
+		/* If the peer NI has failed recovery we must unlink the
+		 * md. But we want to keep the peer ni on the recovery
+		 * queue so we can try to continue recovering it
+		 */
+		if (lpni->lpni_state & LNET_PEER_NI_RECOVERY_FAILED) {
+			lnet_unlink_lpni_recovery_mdh_locked(lpni, 0, true);
+			lpni->lpni_state &= ~LNET_PEER_NI_RECOVERY_FAILED;
+		}
+
 		spin_unlock(&lpni->lpni_lock);
 		lnet_net_unlock(0);
 
@@ -3152,11 +3173,14 @@ struct lnet_mt_event_info {
 		}
 		lnet_ni_lock(ni);
 		ni->ni_state &= ~LNET_NI_STATE_RECOVERY_PENDING;
+		if (status)
+			ni->ni_state |= LNET_NI_STATE_RECOVERY_FAILED;
 		lnet_ni_unlock(ni);
 		lnet_net_unlock(0);
 
 		if (status != 0) {
-			CERROR("local NI recovery failed with %d\n", status);
+			CERROR("local NI (%s) recovery failed with %d\n",
+			       libcfs_nid2str(nid), status);
 			return;
 		}
 		/* need to increment healthv for the ni here, because in
@@ -3178,12 +3202,15 @@ struct lnet_mt_event_info {
 		}
 		spin_lock(&lpni->lpni_lock);
 		lpni->lpni_state &= ~LNET_PEER_NI_RECOVERY_PENDING;
+		if (status)
+			lpni->lpni_state |= LNET_PEER_NI_RECOVERY_FAILED;
 		spin_unlock(&lpni->lpni_lock);
 		lnet_peer_ni_decref_locked(lpni);
 		lnet_net_unlock(cpt);
 
 		if (status != 0)
-			CERROR("peer NI recovery failed with %d\n", status);
+			CERROR("peer NI (%s) recovery failed with %d\n",
+			       libcfs_nid2str(nid), status);
 	}
 }
 
@@ -3214,6 +3241,7 @@ struct lnet_mt_event_info {
 		       libcfs_nid2str(ev_info->mt_nid),
 		       (event->status) ? "unsuccessfully" :
 		       "successfully", event->status);
+		lnet_handle_recovery_reply(ev_info, event->status);
 		break;
 	default:
 		CERROR("Unexpected event: %d\n", event->type);
-- 
1.8.3.1
