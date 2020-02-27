From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:35 -0500
Subject: [lustre-devel] [PATCH 107/622] lnet: router handling
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-108-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Re-create the md and mdh if the router checker ping times out.
When re-transmitting a message do so even if the peer is marked down
to fulfill the message's retry quota.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11272
Lustre-commit: 05becd69bc0c ("LU-11272 lnet: router handling")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33043
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 12 ++++++++++--
 net/lnet/lnet/router.c   |  8 +++++++-
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index eb0b48d..3cab970 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -678,7 +678,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
  *     may drop the lnet_net_lock
  */
 static int
-lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
+lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp,
+		       struct lnet_msg *msg)
 {
 	time64_t now = ktime_get_seconds();
 
@@ -689,6 +690,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		return 1;
 
 	/*
+	 * If we're resending a message, let's attempt to send it even if
+	 * the peer is down to fulfill our resend quota on the message
+	 */
+	if (msg->msg_retry_count > 0)
+		return 1;
+
+	/*
 	 * Peer appears dead, but we should avoid frequent NI queries (at
 	 * most once per lnet_queryinterval seconds).
 	 */
@@ -746,7 +754,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	/* NB 'lp' is always the next hop */
 	if (!(msg->msg_target.pid & LNET_PID_USERFLAG) &&
-	    !lnet_peer_alive_locked(ni, lp)) {
+	    !lnet_peer_alive_locked(ni, lp, msg)) {
 		the_lnet.ln_counters[cpt]->drop_count++;
 		the_lnet.ln_counters[cpt]->drop_length += msg->msg_len;
 		lnet_net_unlock(cpt);
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 7c3bbd8..66a116c 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1042,7 +1042,13 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 
 	rcd = rtr->lpni_rcd;
-	if (!rcd || rcd->rcd_nnis > rcd->rcd_pingbuffer->pb_nnis)
+
+	/* The response to the router checker ping could've timed out and
+	 * the mdh might've been invalidated, so we need to update it
+	 * again.
+	 */
+	if (!rcd || rcd->rcd_nnis > rcd->rcd_pingbuffer->pb_nnis ||
+	    LNetMDHandleIsInvalid(rcd->rcd_mdh))
 		rcd = lnet_update_rc_data_locked(rtr);
 	if (!rcd)
 		return;
-- 
1.8.3.1
