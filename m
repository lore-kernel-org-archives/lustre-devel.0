From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:02 -0400
Subject: [lustre-devel] [PATCH 10/25] lustre: lnet: increment per NI stats
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Increment the per NI stats for messages being routed.
This will give a better view of the traffic distribution
over multiple peer interfaces.

Added extra trace messages to track the messages
sent and received.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9119
Reviewed-on: https://review.whamcloud.com/26907
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c | 16 ++++++++++++++++
 drivers/staging/lustre/lnet/lnet/lib-msg.c  |  8 ++++++--
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 2cf9c89..275e8a9 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1723,6 +1723,16 @@
 
 	rc = lnet_post_send_locked(msg, 0);
 
+	if (!rc)
+		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) : %s\n",
+		       libcfs_nid2str(msg->msg_hdr.src_nid),
+		       libcfs_nid2str(msg->msg_txni->ni_nid),
+		       libcfs_nid2str(src_nid),
+		       libcfs_nid2str(msg->msg_hdr.dest_nid),
+		       libcfs_nid2str(dst_nid),
+		       libcfs_nid2str(msg->msg_txpeer->lpni_nid),
+		       lnet_msgtyp2str(msg->msg_type));
+
 	lnet_net_unlock(cpt);
 
 	return rc;
@@ -2195,6 +2205,12 @@
 	for_me = (ni->ni_nid == dest_nid);
 	cpt = lnet_cpt_of_nid(from_nid, ni);
 
+	CDEBUG(D_NET, "TRACE: %s(%s) <- %s : %s\n",
+	       libcfs_nid2str(dest_nid),
+	       libcfs_nid2str(ni->ni_nid),
+	       libcfs_nid2str(src_nid),
+	       lnet_msgtyp2str(type));
+
 	switch (type) {
 	case LNET_MSG_ACK:
 	case LNET_MSG_GET:
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 00be9ab..1817e54 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -187,7 +187,7 @@
 
 		counters->route_length += msg->msg_len;
 		counters->route_count++;
-		goto out;
+		goto incr_stats;
 
 	case LNET_EVENT_PUT:
 		/* should have been decommitted */
@@ -215,6 +215,8 @@
 	}
 
 	counters->send_count++;
+
+incr_stats:
 	if (msg->msg_txpeer)
 		atomic_inc(&msg->msg_txpeer->lpni_stats.send_count);
 	if (msg->msg_txni)
@@ -241,7 +243,7 @@
 	default:
 		LASSERT(!ev->type);
 		LASSERT(msg->msg_routing);
-		goto out;
+		goto incr_stats;
 
 	case LNET_EVENT_ACK:
 		LASSERT(msg->msg_type == LNET_MSG_ACK);
@@ -274,6 +276,8 @@
 	}
 
 	counters->recv_count++;
+
+incr_stats:
 	if (msg->msg_rxpeer)
 		atomic_inc(&msg->msg_rxpeer->lpni_stats.recv_count);
 	if (msg->msg_rxni)
-- 
1.8.3.1
