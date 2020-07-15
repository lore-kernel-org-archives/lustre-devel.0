From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:18 -0400
Subject: [lustre-devel] [PATCH 37/37] lnet: check rtr_nid is a gateway
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

The rtr_nid is specified for all REPLY/ACK. However it is possible
for the route through the gateway specified by rtr_nid to be removed.
In this case we don't want to use it. We should lookup alternative
paths.

This patch checks if the peer looked up is indeed a gateway. If it's
not a gateway then we attempt to find another path. There is no need
to fail right away. It's not a hard requirement to fail if the default
rtr_nid is not valid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13713
Lustre-commit: 07397a2e7473c ("LU-13713 lnet: check rtr_nid is a gateway")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39175
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 234fbb5..c0dd30c 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1777,6 +1777,7 @@ struct lnet_ni *
 	struct lnet_route *last_route = NULL;
 	struct lnet_peer_ni *lpni = NULL;
 	struct lnet_peer_ni *gwni = NULL;
+	bool route_found = false;
 	lnet_nid_t src_nid = (sd->sd_src_nid != LNET_NID_ANY) ? sd->sd_src_nid :
 			      sd->sd_best_ni ? sd->sd_best_ni->ni_nid :
 			      LNET_NID_ANY;
@@ -1790,15 +1791,20 @@ struct lnet_ni *
 	 */
 	if (sd->sd_rtr_nid != LNET_NID_ANY) {
 		gwni = lnet_find_peer_ni_locked(sd->sd_rtr_nid);
-		if (!gwni) {
-			CERROR("No peer NI for gateway %s\n",
+		if (gwni) {
+			gw = gwni->lpni_peer_net->lpn_peer;
+			lnet_peer_ni_decref_locked(gwni);
+			if (gw->lp_rtr_refcount) {
+				local_lnet = LNET_NIDNET(sd->sd_rtr_nid);
+				route_found = true;
+			}
+		} else {
+			CWARN("No peer NI for gateway %s. Attempting to find an alternative route.\n",
 			       libcfs_nid2str(sd->sd_rtr_nid));
-			return -EHOSTUNREACH;
 		}
-		gw = gwni->lpni_peer_net->lpn_peer;
-		lnet_peer_ni_decref_locked(gwni);
-		local_lnet = LNET_NIDNET(sd->sd_rtr_nid);
-	} else {
+	}
+
+	if (!route_found) {
 		/* we've already looked up the initial lpni using dst_nid */
 		lpni = sd->sd_best_lpni;
 		/* the peer tree must be in existence */
-- 
1.8.3.1
