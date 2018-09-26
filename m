From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:06 -0400
Subject: [lustre-devel] [PATCH 14/25] lustre: lnet: safe access to msg
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When tx credits are returned if there are pending messages they
need to be sent. Messages could have different tx_cpts, so the
correct one needs to be locked. After lnet_post_send_locked(),
if we locked a different CPT then we need to relock the correct one
However, as part of lnet_post_send_locked(), lnet_finalze() can
be called which can free the message. Therefore, the cpt of the
message being passed must be cached in order to prevent access to
freed memory.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9817
Reviewed-on: https://review.whamcloud.com/28308
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 4d74421..e8c0216 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -847,6 +847,8 @@
 
 		txpeer->lpni_txcredits++;
 		if (txpeer->lpni_txcredits <= 0) {
+			int msg2_cpt;
+
 			msg2 = list_entry(txpeer->lpni_txq.next,
 					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
@@ -855,13 +857,26 @@
 			LASSERT(msg2->msg_txpeer == txpeer);
 			LASSERT(msg2->msg_tx_delayed);
 
-			if (msg2->msg_tx_cpt != msg->msg_tx_cpt) {
+			msg2_cpt = msg2->msg_tx_cpt;
+
+			/*
+			 * The msg_cpt can be different from the msg2_cpt
+			 * so we need to make sure we lock the correct cpt
+			 * for msg2.
+			 * Once we call lnet_post_send_locked() it is no
+			 * longer safe to access msg2, since it could've
+			 * been freed by lnet_finalize(), but we still
+			 * need to relock the correct cpt, so we cache the
+			 * msg2_cpt for the purpose of the check that
+			 * follows the call to lnet_pose_send_locked().
+			 */
+			if (msg2_cpt != msg->msg_tx_cpt) {
 				lnet_net_unlock(msg->msg_tx_cpt);
-				lnet_net_lock(msg2->msg_tx_cpt);
+				lnet_net_lock(msg2_cpt);
 			}
 			(void)lnet_post_send_locked(msg2, 1);
-			if (msg2->msg_tx_cpt != msg->msg_tx_cpt) {
-				lnet_net_unlock(msg2->msg_tx_cpt);
+			if (msg2_cpt != msg->msg_tx_cpt) {
+				lnet_net_unlock(msg2_cpt);
 				lnet_net_lock(msg->msg_tx_cpt);
 			}
 		} else {
-- 
1.8.3.1
