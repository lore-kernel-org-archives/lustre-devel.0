From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:37 -0500
Subject: [lustre-devel] [PATCH 109/622] lnet: update logging
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-110-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Add the retry count when logging message sending/resending.
Make timed out responses visible on net error.
Log cases when a message is not resent

WC-bug-id: https://jira.whamcloud.com/browse/LU-11273
Lustre-commit: b9523f474346 ("LU-11273 lnet: update logging")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33044
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 13 +++++++------
 net/lnet/lnet/lib-msg.c  | 21 ++++++++++++++++++---
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 3cab970..84a30e0 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1517,14 +1517,14 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	rc = lnet_post_send_locked(msg, 0);
 	if (!rc)
-		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) : %s\n",
+		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) : %s try# %d\n",
 		       libcfs_nid2str(msg->msg_hdr.src_nid),
 		       libcfs_nid2str(msg->msg_txni->ni_nid),
 		       libcfs_nid2str(sd->sd_src_nid),
 		       libcfs_nid2str(msg->msg_hdr.dest_nid),
 		       libcfs_nid2str(sd->sd_dst_nid),
 		       libcfs_nid2str(msg->msg_txpeer->lpni_nid),
-		       lnet_msgtyp2str(msg->msg_type));
+		       lnet_msgtyp2str(msg->msg_type), msg->msg_retry_count);
 
 	return rc;
 }
@@ -2515,8 +2515,7 @@ struct lnet_mt_event_info {
 
 				list_del_init(&rspt->rspt_on_list);
 
-				CDEBUG(D_NET,
-				       "Response timed out: md = %p\n", md);
+				CNETERR("Response timed out: md = %p\n", md);
 				LNetMDUnlink(rspt->rspt_mdh);
 				lnet_rspt_free(rspt, i);
 			} else {
@@ -2579,11 +2578,13 @@ struct lnet_mt_event_info {
 			lnet_peer_ni_decref_locked(lpni);
 
 			lnet_net_unlock(cpt);
-			CDEBUG(D_NET, "resending %s->%s: %s recovery %d\n",
+			CDEBUG(D_NET,
+			       "resending %s->%s: %s recovery %d try# %d\n",
 			       libcfs_nid2str(src_nid),
 			       libcfs_id2str(msg->msg_target),
 			       lnet_msgtyp2str(msg->msg_type),
-			       msg->msg_recovery);
+			       msg->msg_recovery,
+			       msg->msg_retry_count);
 			rc = lnet_send(src_nid, msg, LNET_NID_ANY);
 			if (rc) {
 				CERROR("Error sending %s to %s: %d\n",
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 5072238..9b52549 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -690,18 +690,33 @@
 
 resend:
 	/* don't resend recovery messages */
-	if (msg->msg_recovery)
+	if (msg->msg_recovery) {
+		CDEBUG(D_NET, "msg %s->%s is a recovery ping. retry# %d\n",
+		       libcfs_nid2str(msg->msg_from),
+		       libcfs_nid2str(msg->msg_target.nid),
+		       msg->msg_retry_count);
 		return -1;
+	}
 
 	/* if we explicitly indicated we don't want to resend then just
 	 * return
 	 */
-	if (msg->msg_no_resend)
+	if (msg->msg_no_resend) {
+		CDEBUG(D_NET, "msg %s->%s requested no resend. retry# %d\n",
+		       libcfs_nid2str(msg->msg_from),
+		       libcfs_nid2str(msg->msg_target.nid),
+		       msg->msg_retry_count);
 		return -1;
+	}
 
 	/* check if the message has exceeded the number of retries */
-	if (msg->msg_retry_count >= lnet_retry_count)
+	if (msg->msg_retry_count >= lnet_retry_count) {
+		CNETERR("msg %s->%s exceeded retry count %d\n",
+			libcfs_nid2str(msg->msg_from),
+			libcfs_nid2str(msg->msg_target.nid),
+			msg->msg_retry_count);
 		return -1;
+	}
 	msg->msg_retry_count++;
 
 	lnet_net_lock(msg->msg_tx_cpt);
-- 
1.8.3.1
