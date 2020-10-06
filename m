From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:54 -0400
Subject: [lustre-devel] [PATCH 15/42] lnet: Conditionally attach rspt in
 LNetPut & LNetGet
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Create a function to interpret the message type and md options to
determine whether response tracking should be enabled for a particular
PUT or GET.

Use that function in LNetPut and LNetGet to determine whether we
attach the response tracker.

HPE-bug-id: LUS-8827
WC-bug-id: https://jira.whamcloud.com/browse/LU-13502
Lustre-commit: 0722e7601f0ba5 ("LU-13502 lnet: Conditionally attach rspt in LNetPut & LNetGet")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38452
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Petros Koutoupis <petros.koutoupis@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 38 +++++++++++++++++++++++++++++++++++---
 1 file changed, 35 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index cf14f32..aa3f3ab 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -68,6 +68,30 @@ struct lnet_send_data {
 	return msg->msg_type == LNET_MSG_ACK || msg->msg_type == LNET_MSG_REPLY;
 }
 
+static inline bool
+lnet_response_tracking_enabled(u32 msg_type, unsigned int md_options)
+{
+	if (md_options & LNET_MD_NO_TRACK_RESPONSE)
+		/* Explicitly disabled in MD options */
+		return false;
+
+	if (md_options & LNET_MD_TRACK_RESPONSE)
+		/* Explicity enabled in MD options */
+		return true;
+
+	if (lnet_response_tracking == 3)
+		/* Enabled for all message types */
+		return true;
+
+	if (msg_type == LNET_MSG_PUT)
+		return lnet_response_tracking == 2;
+
+	if (msg_type == LNET_MSG_GET)
+		return lnet_response_tracking == 1;
+
+	return false;
+}
+
 static inline struct lnet_comm_count *
 get_stats_counts(struct lnet_element_stats *stats,
 		 enum lnet_stats_type stats_type)
@@ -4458,7 +4482,9 @@ void lnet_monitor_thr_stop(void)
 			       md->md_me->me_portal);
 		lnet_res_unlock(cpt);
 
-		lnet_rspt_free(rspt, cpt);
+		if (rspt)
+			lnet_rspt_free(rspt, cpt);
+
 		kfree(msg);
 		return -ENOENT;
 	}
@@ -4491,8 +4517,11 @@ void lnet_monitor_thr_stop(void)
 
 	lnet_build_msg_event(msg, LNET_EVENT_SEND);
 
-	if (ack == LNET_ACK_REQ)
+	if (rspt && lnet_response_tracking_enabled(LNET_MSG_PUT,
+						   md->md_options))
 		lnet_attach_rsp_tracker(rspt, cpt, md, mdh);
+	else if (rspt)
+		lnet_rspt_free(rspt, cpt);
 
 	if (CFS_FAIL_CHECK_ORSET(CFS_FAIL_PTLRPC_OST_BULK_CB2,
 				 CFS_FAIL_ONCE))
@@ -4718,7 +4747,10 @@ struct lnet_msg *
 
 	lnet_build_msg_event(msg, LNET_EVENT_SEND);
 
-	lnet_attach_rsp_tracker(rspt, cpt, md, mdh);
+	if (lnet_response_tracking_enabled(LNET_MSG_GET, md->md_options))
+		lnet_attach_rsp_tracker(rspt, cpt, md, mdh);
+	else
+		lnet_rspt_free(rspt, cpt);
 
 	rc = lnet_send(self, msg, LNET_NID_ANY);
 	if (rc < 0) {
-- 
1.8.3.1
