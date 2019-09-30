From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:56 -0400
Subject: [lustre-devel] [PATCH 037/151] lnet: Handle ping buffer with only
 loopback NID
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf.weber@hpe.com>

During startup lnet_peer_data_resent() can see a ping buffer
for the local node which contains only the loopback NID. This
shows up as pi_nnis == 1, and there is nothing to be done (or
that needs to be done) in that case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9933
Lustre-commit: 002e25b92779 ("LU-9933 lnet: Handle ping buffer with only loopback NID")
Signed-off-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-on: https://review.whamcloud.com/28811
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index d7a2e3b..9fdb6a9 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2589,10 +2589,12 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	 *
 	 * The peer for the loopback interface is a special case: this
 	 * is the peer for the local node, and we want to set its
-	 * primary NID to the correct value here.
+	 * primary NID to the correct value here. Moreover, this peer
+	 * can show up with only the loopback NID in the ping buffer.
 	 */
-	if (pbuf->pb_info.pi_nnis > 1)
-		nid = pbuf->pb_info.pi_ni[1].ns_nid;
+	if (pbuf->pb_info.pi_nnis <= 1)
+		goto out;
+	nid = pbuf->pb_info.pi_ni[1].ns_nid;
 	if (LNET_NETTYP(LNET_NIDNET(lp->lp_primary_nid)) == LOLND) {
 		rc = lnet_peer_set_primary_nid(lp, nid, flags);
 		if (!rc)
-- 
1.8.3.1
