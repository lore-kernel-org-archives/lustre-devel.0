From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:39:01 -0400
Subject: [lustre-devel] [PATCH 122/124] staging: lustre: lnet: Enable
	setting per NI peer_credits
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-123-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Doug Oucharek <doug.s.oucharek@intel.com>

The code to allow peer_credits to be set per NI was originally
"left inactive" because there were concerns about peer_credits
interfering with the ability for IB nodes to connect to each
other when peer_credits are not the same (peer_credits controls
the queue depth for IB). With LU-3322, the values do not have
to match so it is now safe to enable this code so peer_credits
can be set per NI.

This patch enables existing code for setting per NI peer_credits.

Second this patch fixes a long standing bug in that the conf data
was not being used to set variables in the lnet_ni structure until
after lnd_startup() was called which meant LND drivers were
ignoring struct lnet_ni tunable values being set. Now we change
struct lnet_ni data fields based on conf data before calling
lnd_startup().

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8507
Reviewed-on: http://review.whamcloud.com/21948
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   46 ++++++++++++-----------------
 1 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 346db89..4daf828 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1286,6 +1286,25 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 		       sizeof(*ni->ni_lnd_tunables));
 	}
 
+	/*
+	 * If given some LND tunable parameters, parse those now to
+	 * override the values in the NI structure.
+	 */
+	if (conf) {
+		if (conf->cfg_config_u.cfg_net.net_peer_rtr_credits >= 0)
+			ni->ni_peerrtrcredits =
+				conf->cfg_config_u.cfg_net.net_peer_rtr_credits;
+		if (conf->cfg_config_u.cfg_net.net_peer_timeout >= 0)
+			ni->ni_peertimeout =
+				conf->cfg_config_u.cfg_net.net_peer_timeout;
+		if (conf->cfg_config_u.cfg_net.net_peer_tx_credits != -1)
+			ni->ni_peertxcredits =
+				conf->cfg_config_u.cfg_net.net_peer_tx_credits;
+		if (conf->cfg_config_u.cfg_net.net_max_tx_credits >= 0)
+			ni->ni_maxtxcredits =
+				conf->cfg_config_u.cfg_net.net_max_tx_credits;
+	}
+
 	rc = lnd->lnd_startup(ni);
 
 	mutex_unlock(&the_lnet.ln_lnd_mutex);
@@ -1299,33 +1318,6 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 		goto failed0;
 	}
 
-	/*
-	 * If given some LND tunable parameters, parse those now to
-	 * override the values in the NI structure.
-	 */
-	if (conf && conf->cfg_config_u.cfg_net.net_peer_rtr_credits >= 0) {
-		ni->ni_peerrtrcredits =
-			conf->cfg_config_u.cfg_net.net_peer_rtr_credits;
-	}
-	if (conf && conf->cfg_config_u.cfg_net.net_peer_timeout >= 0) {
-		ni->ni_peertimeout =
-			conf->cfg_config_u.cfg_net.net_peer_timeout;
-	}
-	/*
-	 * TODO
-	 * Note: For now, don't allow the user to change
-	 * peertxcredits as this number is used in the
-	 * IB LND to control queue depth.
-	 *
-	 * if (conf && conf->cfg_config_u.cfg_net.net_peer_tx_credits != -1)
-	 *	ni->ni_peertxcredits =
-	 *		conf->cfg_config_u.cfg_net.net_peer_tx_credits;
-	 */
-	if (conf && conf->cfg_config_u.cfg_net.net_max_tx_credits >= 0) {
-		ni->ni_maxtxcredits =
-			conf->cfg_config_u.cfg_net.net_max_tx_credits;
-	}
-
 	LASSERT(ni->ni_peertimeout <= 0 || lnd->lnd_query);
 
 	lnet_net_lock(LNET_LOCK_EX);
-- 
1.7.1
