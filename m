From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:16 -0500
Subject: [lustre-devel] [PATCH 088/622] lnet: handle fatal device error
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-89-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

The o2iblnd can receive device status on the QP event handler.
There are three in specific that are being handled in this patch:
IB_EVENT_DEVICE_FATAL
IB_EVENT_PORT_ERR
IB_EVENT_PORT_ACTIVE
For DEVICE_FATAL and PORT_ERR the NI associated with the QP is set
in fatal error mode. This NI will no longer be selected when sending
messages. When PORT_ACTIVE is received the NI associated with the QP
has the fatal error cleared and future messages can use that NI.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 6b1571209a99 ("LU-9120 lnet: handle fatal device error")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32772
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h      |  7 +++++++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 13 +++++++++++++
 net/lnet/lnet/lib-move.c            |  6 +++++-
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index d815a87..2b3e76a 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -443,6 +443,13 @@ struct lnet_ni {
 	atomic_t		ni_healthv;
 
 	/*
+	 * Set to 1 by the LND when it receives an event telling it the device
+	 * has gone into a fatal state. Set to 0 when the LND receives an
+	 * even telling it the device is back online.
+	 */
+	atomic_t		ni_fatal_error_on;
+
+	/*
 	 * equivalent interfaces to use
 	 * This is an array because socklnd bonding can still be configured
 	 */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index c6e8e73..293a859 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3567,6 +3567,19 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		rdma_notify(conn->ibc_cmid, IB_EVENT_COMM_EST);
 		return;
 
+	case IB_EVENT_PORT_ERR:
+	case IB_EVENT_DEVICE_FATAL:
+		CERROR("Fatal device error for NI %s\n",
+		       libcfs_nid2str(conn->ibc_peer->ibp_ni->ni_nid));
+		atomic_set(&conn->ibc_peer->ibp_ni->ni_fatal_error_on, 1);
+		return;
+
+	case IB_EVENT_PORT_ACTIVE:
+		CERROR("Port reactivated for NI %s\n",
+		       libcfs_nid2str(conn->ibc_peer->ibp_ni->ni_nid));
+		atomic_set(&conn->ibc_peer->ibp_ni->ni_fatal_error_on, 0);
+		return;
+
 	default:
 		CERROR("%s: Async QP event type %d\n",
 		       libcfs_nid2str(conn->ibc_peer->ibp_nid), event->event);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 55cbf57..8d5f1e5 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1303,9 +1303,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		unsigned int distance;
 		int ni_credits;
 		int ni_healthv;
+		int ni_fatal;
 
 		ni_credits = atomic_read(&ni->ni_tx_credits);
 		ni_healthv = atomic_read(&ni->ni_healthv);
+		ni_fatal = atomic_read(&ni->ni_fatal_error_on);
 
 		/*
 		 * calculate the distance from the CPT on which
@@ -1334,7 +1336,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * Select on health, shorter distance, available
 		 * credits, then round-robin.
 		 */
-		if (ni_healthv < best_healthv) {
+		if (ni_fatal) {
+			continue;
+		} else if (ni_healthv < best_healthv) {
 			continue;
 		} else if (ni_healthv > best_healthv) {
 			best_healthv = ni_healthv;
-- 
1.8.3.1
