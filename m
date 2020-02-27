From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:21 -0500
Subject: [lustre-devel] [PATCH 153/622] lnet: socklnd: dynamically set LND
 parameters
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-154-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sharmaso@whamcloud.com>

Currently, the socklnd parameters cannot be set
dynamically. Only the default values are set
which cannot be changed by deleting and
re-adding the net with DLC.

This patch allows setting socklnd parameters
dynamically.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11371
Lustre-commit: 1d94072c63f5 ("LU-11371 socklnd: dynamically set LND parameters")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33191
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 72ecf80..ba5623a 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2723,6 +2723,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 ksocknal_startup(struct lnet_ni *ni)
 {
 	struct ksock_net *net;
+	struct lnet_ioctl_config_lnd_cmn_tunables *net_tunables;
 	struct ksock_interface *ksi = NULL;
 	struct lnet_inetdev *ifaces = NULL;
 	int i = 0;
@@ -2745,17 +2746,28 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	spin_lock_init(&net->ksnn_lock);
 	net->ksnn_incarnation = ktime_get_real_ns();
 	ni->ni_data = net;
-	if (!ni->ni_net->net_tunables_set) {
-		ni->ni_net->net_tunables.lct_peer_timeout =
+	net_tunables = &ni->ni_net->net_tunables;
+
+	if (net_tunables->lct_peer_timeout == -1)
+		net_tunables->lct_peer_timeout =
 			*ksocknal_tunables.ksnd_peertimeout;
-		ni->ni_net->net_tunables.lct_max_tx_credits =
+
+	if (net_tunables->lct_max_tx_credits == -1)
+		net_tunables->lct_max_tx_credits =
 			*ksocknal_tunables.ksnd_credits;
-		ni->ni_net->net_tunables.lct_peer_tx_credits =
+
+	if (net_tunables->lct_peer_tx_credits == -1)
+		net_tunables->lct_peer_tx_credits =
 			*ksocknal_tunables.ksnd_peertxcredits;
-		ni->ni_net->net_tunables.lct_peer_rtr_credits =
+
+	if (net_tunables->lct_peer_tx_credits >
+	    net_tunables->lct_max_tx_credits)
+		net_tunables->lct_peer_tx_credits =
+			net_tunables->lct_max_tx_credits;
+
+	if (net_tunables->lct_peer_rtr_credits == -1)
+		net_tunables->lct_peer_rtr_credits =
 			*ksocknal_tunables.ksnd_peerrtrcredits;
-		ni->ni_net->net_tunables_set = true;
-	}
 
 	rc = lnet_inet_enumerate(&ifaces);
 	if (rc < 0)
-- 
1.8.3.1
