From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:11 -0400
Subject: [lustre-devel] [PATCH 15/23] lnet: Preferred NI logic breaks MR
 routing
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Edge (final-hop) routers typically use the non-multi-rail destination
(NMR_DST) send case. i.e. they treat the destination as
non-multi-rail. The reason for this is that we do not want routers to
modify the destination peer interface selected by the message
originator. As a result of using the NMR_DST send case, edge routers
set a preferred NI, and then continue to use that NI, because it's
preferred, even if the NI goes down and the router has other healthy
interfaces available to it. Routers do not need to use the preferred
NI selection logic when they are forwarding a message, so modify the
NMR_DST algorithm to allow routers to select any suitable local NI.

HPE-bug-id: LUS-9045
WC-bug-id: https://jira.whamcloud.com/browse/LU-13712
Lustre-commit: ef6c35877b96c ("LU-13712 lnet: Preferred NI logic breaks MR routing")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39168
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index aa6fe37..7c14518 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2107,7 +2107,7 @@ struct lnet_ni *
 static int
 lnet_handle_any_local_nmr_dst(struct lnet_send_data *sd)
 {
-	int rc;
+	int rc = 0;
 
 	/* sd->sd_best_lpni is already set to the final destination */
 
@@ -2122,7 +2122,23 @@ struct lnet_ni *
 		return -EFAULT;
 	}
 
-	rc = lnet_select_preferred_best_ni(sd);
+	if (sd->sd_msg->msg_routing) {
+		/* If I'm forwarding this message then I can choose any NI
+		 * on the destination peer net
+		 */
+		sd->sd_best_ni = lnet_find_best_ni_on_spec_net(NULL,
+							       sd->sd_peer,
+							       sd->sd_best_lpni->lpni_peer_net,
+							       sd->sd_md_cpt,
+							       true);
+		if (!sd->sd_best_ni) {
+			CERROR("Unable to forward message to %s. No local NI available\n",
+			       libcfs_nid2str(sd->sd_dst_nid));
+			rc = -EHOSTUNREACH;
+		}
+	} else {
+		rc = lnet_select_preferred_best_ni(sd);
+	}
 	if (!rc)
 		rc = lnet_handle_send(sd);
 
-- 
1.8.3.1
