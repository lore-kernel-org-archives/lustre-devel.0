From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:17 -0500
Subject: [lustre-devel] [PATCH 149/622] lnet: set the health status correctly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-150-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

There are cases where the health status wasn't set properly.
Most notably in the tx_done we need to deal with a specific
set of errno: ENETDOWN, EHOSTUNREACH, ENETUNREACH, ECONNREFUSED,
ECONNRESET. In all those cases we can try and resend to other
available peer NIs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11476
Lustre-commit: 5d77f0d8dc74 ("LU-11476 lnet: set the health status correctly")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33307
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd_cb.c | 8 ++++++--
 net/lnet/lnet/lib-move.c            | 5 ++---
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 10a1934..abb3529 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -374,8 +374,10 @@ struct ksock_tx *
 				tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_TIMEOUT;
 			else if (error == -ENETDOWN ||
 				 error == -EHOSTUNREACH ||
-				 error == -ENETUNREACH)
-				tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_DROPPED;
+				 error == -ENETUNREACH ||
+				 error == -ECONNREFUSED ||
+				 error == -ECONNRESET)
+				tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_DROPPED;
 			/* for all other errors we don't want to
 			 * retransmit
 			 */
@@ -901,6 +903,7 @@ struct ksock_route *
 
 	/* NB Routes may be ignored if connections to them failed recently */
 	CNETERR("No usable routes to %s\n", libcfs_id2str(id));
+	tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_ERROR;
 	return -EHOSTUNREACH;
 }
 
@@ -986,6 +989,7 @@ struct ksock_route *
 	if (!rc)
 		return 0;
 
+	lntmsg->msg_health_status = tx->tx_hstatus;
 	ksocknal_free_tx(tx);
 	return -EIO;
 }
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index b54fbab..bbbcd8d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -770,10 +770,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 		CNETERR("Dropping message for %s: peer not alive\n",
 			libcfs_id2str(msg->msg_target));
-		if (do_send) {
-			msg->msg_health_status = LNET_MSG_STATUS_LOCAL_DROPPED;
+		msg->msg_health_status = LNET_MSG_STATUS_LOCAL_DROPPED;
+		if (do_send)
 			lnet_finalize(msg, -EHOSTUNREACH);
-		}
 
 		lnet_net_lock(cpt);
 		return -EHOSTUNREACH;
-- 
1.8.3.1
