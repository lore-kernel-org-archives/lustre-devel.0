From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:43 -0500
Subject: [lustre-devel] [PATCH 07/40] staging: lustre: return +ve for
	blocked lnet message
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Liang Zhen <liang.zhen@intel.com>

returned value of lnet_post_send_locked and
lnet_post_routed_recv_locked are changed to -ve by:
http://review.whamcloud.com/#/c/9369/

this is wrong because callers rely on +ve to identify blocked
message which is not a failure.

To respect linux kernel coding style and not use positive error
code, this patch adds two macros as non-error returned values of
these functions:
    LNET_CREDIT_OK    has credit for message
    LNET_CREDIT_WAIT  no credit and message is blocked

both these functions will return these two values instead of 0
and EAGAIN

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5151
Reviewed-on: http://review.whamcloud.com/10625
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c |   51 +++++++++++++++++----------
 1 files changed, 32 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 03fcddc..021a81d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -42,6 +42,11 @@
 
 #include "../../include/linux/lnet/lib-lnet.h"
 
+/** lnet message has credit and can be submitted to lnd for send/receive */
+#define LNET_CREDIT_OK		0
+/** lnet message is waiting for credit */
+#define LNET_CREDIT_WAIT	1
+
 static int local_nid_dist_zero = 1;
 module_param(local_nid_dist_zero, int, 0444);
 MODULE_PARM_DESC(local_nid_dist_zero, "Reserved");
@@ -777,10 +782,10 @@ lnet_peer_alive_locked(lnet_peer_t *lp)
  *	  lnet_send() is going to lnet_net_unlock immediately after this, so
  *	  it sets do_send FALSE and I don't do the unlock/send/lock bit.
  *
- * \retval 0 If \a msg sent or OK to send.
- * \retval EAGAIN If \a msg blocked for credit.
- * \retval EHOSTUNREACH If the next hop of the message appears dead.
- * \retval ECANCELED If the MD of the message has been unlinked.
+ * \retval LNET_CREDIT_OK If \a msg sent or OK to send.
+ * \retval LNET_CREDIT_WAIT If \a msg blocked for credit.
+ * \retval -EHOSTUNREACH If the next hop of the message appears dead.
+ * \retval -ECANCELED If the MD of the message has been unlinked.
  */
 static int
 lnet_post_send_locked(lnet_msg_t *msg, int do_send)
@@ -808,7 +813,7 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 			lnet_finalize(ni, msg, -EHOSTUNREACH);
 
 		lnet_net_lock(cpt);
-		return EHOSTUNREACH;
+		return -EHOSTUNREACH;
 	}
 
 	if (msg->msg_md != NULL &&
@@ -821,7 +826,7 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 			lnet_finalize(ni, msg, -ECANCELED);
 
 		lnet_net_lock(cpt);
-		return ECANCELED;
+		return -ECANCELED;
 	}
 
 	if (!msg->msg_peertxcredit) {
@@ -838,7 +843,7 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 		if (lp->lp_txcredits < 0) {
 			msg->msg_tx_delayed = 1;
 			list_add_tail(&msg->msg_list, &lp->lp_txq);
-			return EAGAIN;
+			return LNET_CREDIT_WAIT;
 		}
 	}
 
@@ -855,7 +860,7 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 		if (tq->tq_credits < 0) {
 			msg->msg_tx_delayed = 1;
 			list_add_tail(&msg->msg_list, &tq->tq_delayed);
-			return EAGAIN;
+			return LNET_CREDIT_WAIT;
 		}
 	}
 
@@ -864,7 +869,7 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 		lnet_ni_send(ni, msg);
 		lnet_net_lock(cpt);
 	}
-	return 0;
+	return LNET_CREDIT_OK;
 }
 
 static lnet_rtrbufpool_t *
@@ -891,8 +896,10 @@ static int
 lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 {
 	/* lnet_parse is going to lnet_net_unlock immediately after this, so it
-	 * sets do_recv FALSE and I don't do the unlock/send/lock bit.  I
-	 * return EAGAIN if msg blocked and 0 if received or OK to receive */
+	 * sets do_recv FALSE and I don't do the unlock/send/lock bit.
+	 * I return LNET_CREDIT_WAIT if msg blocked and LNET_CREDIT_OK if
+	 * received or OK to receive
+	 */
 	lnet_peer_t *lp = msg->msg_rxpeer;
 	lnet_rtrbufpool_t *rbp;
 	lnet_rtrbuf_t *rb;
@@ -921,7 +928,7 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 			LASSERT(msg->msg_rx_ready_delay);
 			msg->msg_rx_delayed = 1;
 			list_add_tail(&msg->msg_list, &lp->lp_rtrq);
-			return EAGAIN;
+			return LNET_CREDIT_WAIT;
 		}
 	}
 
@@ -941,7 +948,7 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 			LASSERT(msg->msg_rx_ready_delay);
 			msg->msg_rx_delayed = 1;
 			list_add_tail(&msg->msg_list, &rbp->rbp_msgs);
-			return EAGAIN;
+			return LNET_CREDIT_WAIT;
 		}
 	}
 
@@ -960,7 +967,7 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 			     0, msg->msg_len, msg->msg_len);
 		lnet_net_lock(cpt);
 	}
-	return 0;
+	return LNET_CREDIT_OK;
 }
 
 void
@@ -1340,13 +1347,13 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 	rc = lnet_post_send_locked(msg, 0);
 	lnet_net_unlock(cpt);
 
-	if (rc == EHOSTUNREACH || rc == ECANCELED)
-		return -rc;
+	if (rc < 0)
+		return rc;
 
-	if (rc == 0)
+	if (rc == LNET_CREDIT_OK)
 		lnet_ni_send(src_ni, msg);
 
-	return 0; /* rc == 0 or EAGAIN */
+	return 0; /* rc == LNET_CREDIT_OK or LNET_CREDIT_WAIT */
 }
 
 static void
@@ -1608,6 +1615,11 @@ lnet_parse_ack(lnet_ni_t *ni, lnet_msg_t *msg)
 	return 0;
 }
 
+/**
+ * \retval LNET_CREDIT_OK	If \a msg is forwarded
+ * \retval LNET_CREDIT_WAIT	If \a msg is blocked because w/o buffer
+ * \retval -ve			error code
+ */
 static int
 lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg)
 {
@@ -1897,7 +1909,8 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 
 		if (rc < 0)
 			goto free_drop;
-		if (rc == 0) {
+
+		if (rc == LNET_CREDIT_OK) {
 			lnet_ni_recv(ni, msg->msg_private, msg, 0,
 				     0, payload_length, payload_length);
 		}
-- 
1.7.1
