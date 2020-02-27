From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:13 -0500
Subject: [lustre-devel] [PATCH 325/622] lnet: Protect lp_dc_pendq
 manipulation with lp_lock
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-326-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Protect the peer discovery queue from concurrent manipulation by
acquiring the lp_lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12264
Lustre-commit: dd16a31bf4ae ("LU-12264 lnet: Protect lp_dc_pendq manipulation with lp_lock")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/34798
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 2 ++
 net/lnet/lnet/peer.c     | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 8bce3a9..de5951a 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2336,7 +2336,9 @@ struct lnet_ni *
 		/* queue message and return */
 		msg->msg_rtr_nid_param = rtr_nid;
 		msg->msg_sending = 0;
+		spin_lock(&peer->lp_lock);
 		list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
+		spin_unlock(&peer->lp_lock);
 		lnet_peer_ni_decref_locked(lpni);
 		primary_nid = peer->lp_primary_nid;
 		lnet_net_unlock(cpt);
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 8af9db2..0d2d356 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -254,7 +254,9 @@
 	 * Releasing the lock can cause an inconsistent state
 	 */
 	spin_lock(&the_lnet.ln_msg_resend_lock);
+	spin_lock(&lp->lp_lock);
 	list_splice(&lp->lp_dc_pendq, &the_lnet.ln_msg_resend);
+	spin_unlock(&lp->lp_lock);
 	spin_unlock(&the_lnet.ln_msg_resend_lock);
 	wake_up(&the_lnet.ln_dc_waitq);
 
@@ -1778,7 +1780,9 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 	       libcfs_nid2str(lp->lp_primary_nid));
 
 	list_del_init(&lp->lp_dc_list);
+	spin_lock(&lp->lp_lock);
 	list_splice_init(&lp->lp_dc_pendq, &pending_msgs);
+	spin_unlock(&lp->lp_lock);
 	wake_up_all(&lp->lp_dc_waitq);
 
 	lnet_net_unlock(LNET_LOCK_EX);
-- 
1.8.3.1
