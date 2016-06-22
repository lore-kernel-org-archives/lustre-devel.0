From: James Simmons <jsimmons@infradead.org>
Date: Wed, 22 Jun 2016 11:19:54 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: Remove old commented
	out code
Message-ID: <1466608794-27947-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

These #if 0 blocks have been in place for years. Assume
they are not used and remove them

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8058
Reviewed-on: http://review.whamcloud.com/20414
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    5 -----
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    7 -------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   18 +-----------------
 3 files changed, 1 insertions(+), 29 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 07ec540..cbc9a9c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1468,11 +1468,6 @@ ksocknal_close_conn_locked(struct ksock_conn *conn, int error)
 
 		conn->ksnc_route = NULL;
 
-#if 0	   /* irrelevant with only eager routes */
-		/* make route least favourite */
-		list_del(&route->ksnr_list);
-		list_add_tail(&route->ksnr_list, &peer->ksnp_routes);
-#endif
 		ksocknal_route_decref(route);     /* drop conn's ref on route */
 	}
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 303576d..d53da55 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -2008,13 +2008,6 @@ ksocknal_connect(struct ksock_route *route)
 		list_splice_init(&peer->ksnp_tx_queue, &zombies);
 	}
 
-#if 0	   /* irrelevant with only eager routes */
-	if (!route->ksnr_deleted) {
-		/* make this route least-favourite for re-selection */
-		list_del(&route->ksnr_list);
-		list_add_tail(&route->ksnr_list, &peer->ksnp_routes);
-	}
-#endif
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
 	ksocknal_peer_failed(peer);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 910e106..0897e58 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -449,23 +449,7 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 
 	if (!msg)
 		return;
-#if 0
-	CDEBUG(D_WARNING, "%s msg->%s Flags:%s%s%s%s%s%s%s%s%s%s%s txp %s rxp %s\n",
-	       lnet_msgtyp2str(msg->msg_type), libcfs_id2str(msg->msg_target),
-	       msg->msg_target_is_router ? "t" : "",
-	       msg->msg_routing ? "X" : "",
-	       msg->msg_ack ? "A" : "",
-	       msg->msg_sending ? "S" : "",
-	       msg->msg_receiving ? "R" : "",
-	       msg->msg_delayed ? "d" : "",
-	       msg->msg_txcredit ? "C" : "",
-	       msg->msg_peertxcredit ? "c" : "",
-	       msg->msg_rtrcredit ? "F" : "",
-	       msg->msg_peerrtrcredit ? "f" : "",
-	       msg->msg_onactivelist ? "!" : "",
-	       !msg->msg_txpeer ? "<none>" : libcfs_nid2str(msg->msg_txpeer->lp_nid),
-	       !msg->msg_rxpeer ? "<none>" : libcfs_nid2str(msg->msg_rxpeer->lp_nid));
-#endif
+
 	msg->msg_ev.status = status;
 
 	if (msg->msg_md) {
-- 
1.7.1
