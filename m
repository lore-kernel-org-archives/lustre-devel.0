From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:39 -0500
Subject: [lustre-devel] [PATCH 111/622] lnet: lnd: Clean up logging
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-112-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

No need to output error in ksocknal_tx_done() as this error is
tracked in lnet.
No need to keep a cookie in the connection. It's always set to
the message. This will allow us to set the msg's health status
properly before calling lnet_finalize()

WC-bug-id: https://jira.whamcloud.com/browse/LU-11309
Lustre-commit: cdf462b19345 ("LU-11309 lnd: Clean up logging")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33096
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c    |  5 ++++-
 net/lnet/klnds/socklnd/socklnd.h    |  3 +--
 net/lnet/klnds/socklnd/socklnd_cb.c | 10 +++++-----
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 891d3bd..72ecf80 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1680,7 +1680,10 @@ struct ksock_peer *
 		       &conn->ksnc_ipaddr, conn->ksnc_port,
 		       iov_iter_count(&conn->ksnc_rx_to), conn->ksnc_rx_nob_left,
 		       ktime_get_seconds() - last_rcv);
-		lnet_finalize(conn->ksnc_cookie, -EIO);
+		if (conn->ksnc_lnet_msg)
+			conn->ksnc_lnet_msg->msg_health_status =
+				LNET_MSG_STATUS_REMOTE_ERROR;
+		lnet_finalize(conn->ksnc_lnet_msg, -EIO);
 		break;
 	case SOCKNAL_RX_LNET_HEADER:
 		if (conn->ksnc_rx_started)
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 48884cf..c8d8acf 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -355,8 +355,7 @@ struct ksock_conn {
 	u32			ksnc_rx_csum;		/* partial checksum for incoming
 							 * data
 							 */
-	void		       *ksnc_cookie;		/* rx lnet_finalize passthru arg
-							 */
+	struct lnet_msg	       *ksnc_lnet_msg;		/* rx lnet_finalize arg */
 	struct ksock_msg	ksnc_msg;		/* incoming message buffer:
 							 * V2.x message takes the
 							 * whole struct
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 057c7f3..10a1934 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -344,9 +344,6 @@ struct ksock_tx *
 
 	ksocknal_free_tx(tx);
 	if (lnetmsg) { /* KSOCK_MSG_NOOP go without lnetmsg */
-		if (rc)
-			CERROR("tx failure rc = %d, hstatus = %d\n", rc,
-			       hstatus);
 		lnetmsg->msg_health_status = hstatus;
 		lnet_finalize(lnetmsg, rc);
 	}
@@ -1266,7 +1263,10 @@ struct ksock_route *
 					le64_to_cpu(lhdr->src_nid) != id->nid);
 		}
 
-		lnet_finalize(conn->ksnc_cookie, rc);
+		if (rc && conn->ksnc_lnet_msg)
+			conn->ksnc_lnet_msg->msg_health_status =
+				LNET_MSG_STATUS_REMOTE_ERROR;
+		lnet_finalize(conn->ksnc_lnet_msg, rc);
 
 		if (rc) {
 			ksocknal_new_packet(conn, 0);
@@ -1300,7 +1300,7 @@ struct ksock_route *
 	LASSERT(iov_iter_count(to) <= rlen);
 	LASSERT(to->nr_segs <= LNET_MAX_IOV);
 
-	conn->ksnc_cookie = msg;
+	conn->ksnc_lnet_msg = msg;
 	conn->ksnc_rx_nob_left = rlen;
 
 	conn->ksnc_rx_to = *to;
-- 
1.8.3.1
