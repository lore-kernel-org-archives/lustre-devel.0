From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:27 -0500
Subject: [lustre-devel] [PATCH 159/622] lnet: separate ni state from recovery
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-160-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

To make the code more readable we make the ni_state an
enumerated type, and create a separate bit filed to track
the recovery state. Both of these are protected by the
lnet_ni_lock()

WC-bug-id: https://jira.whamcloud.com/browse/LU-11514
Lustre-commit: 2be10428ac22 ("LU-11514 lnet: separate ni state from recovery")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33361
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h | 24 ++++++++++++++++--------
 net/lnet/lnet/api-ni.c         |  8 +++-----
 net/lnet/lnet/config.c         |  2 +-
 net/lnet/lnet/lib-move.c       | 23 +++++++++++++----------
 4 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index ce0caa9..b1a6f6a 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -315,12 +315,17 @@ struct lnet_tx_queue {
 	struct list_head	tq_delayed;	/* delayed TXs */
 };
 
-#define LNET_NI_STATE_INIT		(1 << 0)
-#define LNET_NI_STATE_ACTIVE		(1 << 1)
-#define LNET_NI_STATE_FAILED		(1 << 2)
-#define LNET_NI_STATE_RECOVERY_PENDING	(1 << 3)
-#define LNET_NI_STATE_RECOVERY_FAILED	BIT(4)
-#define LNET_NI_STATE_DELETING		BIT(5)
+enum lnet_ni_state {
+	/* initial state when NI is created */
+	LNET_NI_STATE_INIT = 0,
+	/* set when NI is brought up */
+	LNET_NI_STATE_ACTIVE,
+	/* set when NI is being shutdown */
+	LNET_NI_STATE_DELETING,
+};
+
+#define LNET_NI_RECOVERY_PENDING	BIT(0)
+#define LNET_NI_RECOVERY_FAILED		BIT(1)
 
 enum lnet_stats_type {
 	LNET_STATS_TYPE_SEND	= 0,
@@ -435,8 +440,11 @@ struct lnet_ni {
 	/* my health status */
 	struct lnet_ni_status	*ni_status;
 
-	/* NI FSM */
-	u32			ni_state;
+	/* NI FSM. Protected by lnet_ni_lock() */
+	enum lnet_ni_state	ni_state;
+
+	/* Recovery state. Protected by lnet_ni_lock() */
+	u32			ni_recovery_state;
 
 	/* per NI LND tunables */
 	struct lnet_lnd_tunables ni_lnd_tunables;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index c4f698d..25592db 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1823,7 +1823,7 @@ static void lnet_push_target_fini(void)
 		list_del_init(&ni->ni_netlist);
 		/* the ni should be in deleting state. If it's not it's
 		 * a bug */
-		LASSERT(ni->ni_state & LNET_NI_STATE_DELETING);
+		LASSERT(ni->ni_state == LNET_NI_STATE_DELETING);
 		cfs_percpt_for_each(ref, j, ni->ni_refs) {
 			if (!*ref)
 				continue;
@@ -1871,8 +1871,7 @@ static void lnet_push_target_fini(void)
 
 	lnet_net_lock(LNET_LOCK_EX);
 	lnet_ni_lock(ni);
-	ni->ni_state |= LNET_NI_STATE_DELETING;
-	ni->ni_state &= ~LNET_NI_STATE_ACTIVE;
+	ni->ni_state = LNET_NI_STATE_DELETING;
 	lnet_ni_unlock(ni);
 	lnet_ni_unlink_locked(ni);
 	lnet_incr_dlc_seq();
@@ -2005,8 +2004,7 @@ static void lnet_push_target_fini(void)
 	}
 
 	lnet_ni_lock(ni);
-	ni->ni_state |= LNET_NI_STATE_ACTIVE;
-	ni->ni_state &= ~LNET_NI_STATE_INIT;
+	ni->ni_state = LNET_NI_STATE_ACTIVE;
 	lnet_ni_unlock(ni);
 
 	/* We keep a reference on the loopback net through the loopback NI */
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index ea62d36..5e0831a 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -467,7 +467,7 @@ struct lnet_net *
 		ni->ni_net_ns = NULL;
 
 	ni->ni_last_alive = ktime_get_real_seconds();
-	ni->ni_state |= LNET_NI_STATE_INIT;
+	ni->ni_state = LNET_NI_STATE_INIT;
 	list_add_tail(&ni->ni_netlist, &net->net_ni_added);
 
 	/*
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 434aa09..eacda4c 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2651,7 +2651,8 @@ struct lnet_mt_event_info {
 
 	LNetInvalidateMDHandle(&recovery_mdh);
 
-	if (ni->ni_state & LNET_NI_STATE_RECOVERY_PENDING || force) {
+	if (ni->ni_recovery_state & LNET_NI_RECOVERY_PENDING ||
+	    force) {
 		recovery_mdh = ni->ni_ping_mdh;
 		LNetInvalidateMDHandle(&ni->ni_ping_mdh);
 	}
@@ -2702,7 +2703,7 @@ struct lnet_mt_event_info {
 
 		lnet_net_lock(0);
 		lnet_ni_lock(ni);
-		if (!(ni->ni_state & LNET_NI_STATE_ACTIVE) ||
+		if (ni->ni_state != LNET_NI_STATE_ACTIVE ||
 		    healthv == LNET_MAX_HEALTH_VALUE) {
 			list_del_init(&ni->ni_recovery);
 			lnet_unlink_ni_recovery_mdh_locked(ni, 0, false);
@@ -2716,9 +2717,9 @@ struct lnet_mt_event_info {
 		 * But we want to keep the local_ni on the recovery queue
 		 * so we can continue the attempts to recover it.
 		 */
-		if (ni->ni_state & LNET_NI_STATE_RECOVERY_FAILED) {
+		if (ni->ni_recovery_state & LNET_NI_RECOVERY_FAILED) {
 			lnet_unlink_ni_recovery_mdh_locked(ni, 0, true);
-			ni->ni_state &= ~LNET_NI_STATE_RECOVERY_FAILED;
+			ni->ni_recovery_state &= ~LNET_NI_RECOVERY_FAILED;
 		}
 
 		lnet_ni_unlock(ni);
@@ -2728,8 +2729,8 @@ struct lnet_mt_event_info {
 		       libcfs_nid2str(ni->ni_nid));
 
 		lnet_ni_lock(ni);
-		if (!(ni->ni_state & LNET_NI_STATE_RECOVERY_PENDING)) {
-			ni->ni_state |= LNET_NI_STATE_RECOVERY_PENDING;
+		if (!(ni->ni_recovery_state & LNET_NI_RECOVERY_PENDING)) {
+			ni->ni_recovery_state |= LNET_NI_RECOVERY_PENDING;
 			lnet_ni_unlock(ni);
 
 			ev_info = kzalloc(sizeof(*ev_info), GFP_NOFS);
@@ -2737,7 +2738,8 @@ struct lnet_mt_event_info {
 				CERROR("out of memory. Can't recover %s\n",
 				       libcfs_nid2str(ni->ni_nid));
 				lnet_ni_lock(ni);
-				ni->ni_state &= ~LNET_NI_STATE_RECOVERY_PENDING;
+				ni->ni_recovery_state &=
+				  ~LNET_NI_RECOVERY_PENDING;
 				lnet_ni_unlock(ni);
 				continue;
 			}
@@ -2806,7 +2808,8 @@ struct lnet_mt_event_info {
 
 			lnet_ni_lock(ni);
 			if (rc)
-				ni->ni_state &= ~LNET_NI_STATE_RECOVERY_PENDING;
+				ni->ni_recovery_state &=
+					~LNET_NI_RECOVERY_PENDING;
 		}
 		lnet_ni_unlock(ni);
 	}
@@ -3210,9 +3213,9 @@ struct lnet_mt_event_info {
 			return;
 		}
 		lnet_ni_lock(ni);
-		ni->ni_state &= ~LNET_NI_STATE_RECOVERY_PENDING;
+		ni->ni_recovery_state &= ~LNET_NI_RECOVERY_PENDING;
 		if (status)
-			ni->ni_state |= LNET_NI_STATE_RECOVERY_FAILED;
+			ni->ni_recovery_state |= LNET_NI_RECOVERY_FAILED;
 		lnet_ni_unlock(ni);
 		lnet_net_unlock(0);
 
-- 
1.8.3.1
