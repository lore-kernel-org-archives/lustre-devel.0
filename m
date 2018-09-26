From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:01 -0400
Subject: [lustre-devel] [PATCH 09/25] lustre: lnet: prevent assert on
 ln_state
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

lnet_peer_primary_nid() is called from lnet_parse. It checks
ln_state outside the net lock, causing a race condition
during shutdown where the code expects the state to be
running, but it's stopping or shutdown.

Fixed the issue by renaming lnet_peer_primary_nid() to
lnet_peer_primary_nid_locked(). This function is now called
when lnet_net_lock is held in lnet_parse().

In lnet_create_reply_msg() we already have access to the
msg_txpeer, so we lookup the primary_nid directly

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9549
Reviewed-on: https://review.whamcloud.com/27262
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c          | 7 +++----
 drivers/staging/lustre/lnet/lnet/peer.c              | 5 +----
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index f510b9e..6bfdc9b 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -653,7 +653,7 @@ struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 struct lnet_peer_ni *lnet_nid2peerni_ex(lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 void lnet_peer_net_added(struct lnet_net *net);
-lnet_nid_t lnet_peer_primary_nid(lnet_nid_t nid);
+lnet_nid_t lnet_peer_primary_nid_locked(lnet_nid_t nid);
 void lnet_peer_tables_cleanup(struct lnet_net *net);
 void lnet_peer_uninit(void);
 int lnet_peer_tables_create(void);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index d533b8e..2cf9c89 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -2338,8 +2338,6 @@
 		msg->msg_hdr.dest_pid	= dest_pid;
 		msg->msg_hdr.payload_length = payload_length;
 	}
-	/* Multi-Rail: Primary NID of source. */
-	msg->msg_initiator = lnet_peer_primary_nid(src_nid);
 
 	lnet_net_lock(cpt);
 	lpni = lnet_nid2peerni_locked(from_nid, cpt);
@@ -2357,6 +2355,8 @@
 	msg->msg_rxpeer = lpni;
 	msg->msg_rxni = ni;
 	lnet_ni_addref_locked(ni, cpt);
+	/* Multi-Rail: Primary NID of source. */
+	msg->msg_initiator = lnet_peer_primary_nid_locked(src_nid);
 
 	if (lnet_isrouter(msg->msg_rxpeer)) {
 		lnet_peer_set_alive(msg->msg_rxpeer);
@@ -2658,8 +2658,7 @@ struct lnet_msg *
 	       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id), getmd);
 
 	/* setup information for lnet_build_msg_event */
-	msg->msg_initiator = lnet_peer_primary_nid(peer_id.nid);
-	/* Cheaper: msg->msg_initiator = getmsg->msg_txpeer->lp_nid; */
+	msg->msg_initiator = getmsg->msg_txpeer->lpni_peer_net->lpn_peer->lp_primary_nid;
 	msg->msg_from = peer_id.nid;
 	msg->msg_type = LNET_MSG_GET; /* flag this msg as an "optimized" GET */
 	msg->msg_hdr.src_nid = peer_id.nid;
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 2fbf93a..ebb8435 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -593,19 +593,16 @@ struct lnet_peer_ni *
 }
 
 lnet_nid_t
-lnet_peer_primary_nid(lnet_nid_t nid)
+lnet_peer_primary_nid_locked(lnet_nid_t nid)
 {
 	struct lnet_peer_ni *lpni;
 	lnet_nid_t primary_nid = nid;
-	int cpt;
 
-	cpt = lnet_net_lock_current();
 	lpni = lnet_find_peer_ni_locked(nid);
 	if (lpni) {
 		primary_nid = lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
 		lnet_peer_ni_decref_locked(lpni);
 	}
-	lnet_net_unlock(cpt);
 
 	return primary_nid;
 }
-- 
1.8.3.1
