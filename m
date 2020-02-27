From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:44 -0500
Subject: [lustre-devel] [PATCH 356/622] lnet: check peer timeout on a router
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-357-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

On a router assume that a peer is alive and attempt to send it
messages as long as the peer_timeout hasn't expired.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12200
Lustre-commit: 41f3c27adf16 ("LU-12200 lnet: check peer timeout on a router")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34772
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  2 ++
 net/lnet/lnet/lib-move.c       | 26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index da5b860..b240361 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -566,6 +566,8 @@ struct lnet_peer_ni {
 	u32			 lpni_gw_seq;
 	/* returned RC ping features. Protected with lpni_lock */
 	unsigned int		 lpni_ping_feats;
+	/* time last message was received from the peer */
+	time64_t		lpni_last_alive;
 	/* preferred local nids: if only one, use lpni_pref.nid */
 	union lpni_pref {
 		lnet_nid_t	 nid;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index f0804e1..629856c 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -608,6 +608,23 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return rc;
 }
 
+static bool
+lnet_is_peer_deadline_passed(struct lnet_peer_ni *lpni, time64_t now)
+{
+	time64_t deadline;
+
+	deadline = lpni->lpni_last_alive +
+		   lpni->lpni_net->net_tunables.lct_peer_timeout;
+
+	/* assume peer_ni is alive as long as we're within the configured
+	 * peer timeout
+	 */
+	if (deadline > now)
+		return false;
+
+	return true;
+}
+
 /*
  * NB: returns 1 when alive, 0 when dead, negative when error;
  *     may drop the lnet_net_lock
@@ -616,6 +633,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer_ni *lpni,
 		       struct lnet_msg *msg)
 {
+	time64_t now = ktime_get_seconds();
+
 	if (!lnet_peer_aliveness_enabled(lpni))
 		return -ENODEV;
 
@@ -635,6 +654,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	    msg->msg_type == LNET_MSG_REPLY)
 		return 1;
 
+	if (!lnet_is_peer_deadline_passed(lpni, now))
+		return true;
+
 	return lnet_is_peer_ni_alive(lpni);
 }
 
@@ -4142,6 +4164,10 @@ void lnet_monitor_thr_stop(void)
 			return 0;
 		goto drop;
 	}
+
+	if (the_lnet.ln_routing)
+		lpni->lpni_last_alive = ktime_get_seconds();
+
 	msg->msg_rxpeer = lpni;
 	msg->msg_rxni = ni;
 	lnet_ni_addref_locked(ni, cpt);
-- 
1.8.3.1
