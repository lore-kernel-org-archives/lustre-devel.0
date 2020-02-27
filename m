From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:28 -0500
Subject: [lustre-devel] [PATCH 220/622] lnet: use right address for routing
 message
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-221-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

msg_initiator is real sender address, so use this address as
hash source to better distribution against CPT on server side.

Cray-bug-id: LUS-6841
WC-bug-id: https://jira.whamcloud.com/browse/LU-11413
Lustre-commit: ad263e5d6e93 ("LU-11413 lnet: use right address for routing message")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/34032
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 468de06..185c31a 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3463,7 +3463,7 @@ void lnet_monitor_thr_stop(void)
 	info.mi_rlength	= hdr->payload_length;
 	info.mi_roffset	= hdr->msg.put.offset;
 	info.mi_mbits = hdr->msg.put.match_bits;
-	info.mi_cpt = lnet_cpt_of_nid(msg->msg_rxpeer->lpni_nid, ni);
+	info.mi_cpt = lnet_cpt_of_nid(msg->msg_initiator, ni);
 
 	msg->msg_rx_ready_delay = !ni->ni_net->net_lnd->lnd_eager_recv;
 	ready_delay = msg->msg_rx_ready_delay;
@@ -3527,7 +3527,7 @@ void lnet_monitor_thr_stop(void)
 	info.mi_rlength = hdr->msg.get.sink_length;
 	info.mi_roffset = hdr->msg.get.src_offset;
 	info.mi_mbits = hdr->msg.get.match_bits;
-	info.mi_cpt = lnet_cpt_of_nid(msg->msg_rxpeer->lpni_nid, ni);
+	info.mi_cpt = lnet_cpt_of_nid(msg->msg_initiator, ni);
 
 	rc = lnet_ptl_match_md(&info, msg);
 	if (rc == LNET_MATCHMD_DROP) {
-- 
1.8.3.1
