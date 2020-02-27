From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:18 -0500
Subject: [lustre-devel] [PATCH 090/622] lnet: add health statistics
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-91-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Add a health statistics block for each local and peer NI.
These statistics will be incremented when processing errors reported
by lnet_finalize()

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 67908ab34371 ("LU-9120 lnet: add health statistics")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32775
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h | 18 +++++++++++++++
 net/lnet/lnet/lib-msg.c        | 52 ++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 2b3e76a..e5d4128 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -338,6 +338,22 @@ struct lnet_element_stats {
 	struct lnet_comm_count	el_drop_stats;
 };
 
+struct lnet_health_local_stats {
+	atomic_t hlt_local_interrupt;
+	atomic_t hlt_local_dropped;
+	atomic_t hlt_local_aborted;
+	atomic_t hlt_local_no_route;
+	atomic_t hlt_local_timeout;
+	atomic_t hlt_local_error;
+};
+
+struct lnet_health_remote_stats {
+	atomic_t hlt_remote_dropped;
+	atomic_t hlt_remote_timeout;
+	atomic_t hlt_remote_error;
+	atomic_t hlt_network_timeout;
+};
+
 struct lnet_net {
 	/* chain on the ln_nets */
 	struct list_head	net_list;
@@ -426,6 +442,7 @@ struct lnet_ni {
 
 	/* NI statistics */
 	struct lnet_element_stats ni_stats;
+	struct lnet_health_local_stats ni_hstats;
 
 	/* physical device CPT */
 	int			ni_dev_cpt;
@@ -511,6 +528,7 @@ struct lnet_peer_ni {
 	struct list_head	 lpni_rtr_list;
 	/* statistics kept on each peer NI */
 	struct lnet_element_stats lpni_stats;
+	struct lnet_health_remote_stats lpni_hstats;
 	/* spin lock protecting credits and lpni_txq / lpni_rtrq */
 	spinlock_t		 lpni_lock;
 	/* # tx credits available */
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 32d49e9..dc51a17 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -541,6 +541,54 @@
 	lnet_net_unlock(0);
 }
 
+static void
+lnet_incr_hstats(struct lnet_msg *msg, enum lnet_msg_hstatus hstatus)
+{
+	struct lnet_ni *ni = msg->msg_txni;
+	struct lnet_peer_ni *lpni = msg->msg_txpeer;
+
+	switch (hstatus) {
+	case LNET_MSG_STATUS_LOCAL_INTERRUPT:
+		atomic_inc(&ni->ni_hstats.hlt_local_interrupt);
+		break;
+	case LNET_MSG_STATUS_LOCAL_DROPPED:
+		atomic_inc(&ni->ni_hstats.hlt_local_dropped);
+		break;
+	case LNET_MSG_STATUS_LOCAL_ABORTED:
+		atomic_inc(&ni->ni_hstats.hlt_local_aborted);
+		break;
+	case LNET_MSG_STATUS_LOCAL_NO_ROUTE:
+		atomic_inc(&ni->ni_hstats.hlt_local_no_route);
+		break;
+	case LNET_MSG_STATUS_LOCAL_TIMEOUT:
+		atomic_inc(&ni->ni_hstats.hlt_local_timeout);
+		break;
+	case LNET_MSG_STATUS_LOCAL_ERROR:
+		atomic_inc(&ni->ni_hstats.hlt_local_error);
+		break;
+	case LNET_MSG_STATUS_REMOTE_DROPPED:
+		if (lpni)
+			atomic_inc(&lpni->lpni_hstats.hlt_remote_dropped);
+		break;
+	case LNET_MSG_STATUS_REMOTE_ERROR:
+		if (lpni)
+			atomic_inc(&lpni->lpni_hstats.hlt_remote_error);
+		break;
+	case LNET_MSG_STATUS_REMOTE_TIMEOUT:
+		if (lpni)
+			atomic_inc(&lpni->lpni_hstats.hlt_remote_timeout);
+		break;
+	case LNET_MSG_STATUS_NETWORK_TIMEOUT:
+		if (lpni)
+			atomic_inc(&lpni->lpni_hstats.hlt_network_timeout);
+		break;
+	case LNET_MSG_STATUS_OK:
+		break;
+	default:
+		LBUG();
+	}
+}
+
 /* Do a health check on the message:
  * return -1 if we're not going to handle the error or
  *   if we've reached the maximum number of retries.
@@ -553,8 +601,6 @@
 	enum lnet_msg_hstatus hstatus = msg->msg_health_status;
 	bool lo = false;
 
-	/* TODO: lnet_incr_hstats(hstatus); */
-
 	LASSERT(msg->msg_txni);
 
 	/* if we're sending to the LOLND then the msg_txpeer will not be
@@ -565,6 +611,8 @@
 	else
 		lo = true;
 
+	lnet_incr_hstats(msg, hstatus);
+
 	if (hstatus != LNET_MSG_STATUS_OK &&
 	    ktime_compare(ktime_get(), msg->msg_deadline) >= 0)
 		return -1;
-- 
1.8.3.1
