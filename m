From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:58 -0400
Subject: [lustre-devel] [PATCH 18/18] lnet: handle undefined parameters
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

If peer_tx_credits or peer_credits are 0, they should be
defaulted to the system defaults 8 and 256 respectively

WC-bug-id: https://jira.whamcloud.com/browse/LU-13662
Lustre-commit: d934eb3c4f638 ("LU-13662 lnet: handle undefined parameters")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38894
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h              |  4 +++-
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c |  4 ++--
 net/lnet/klnds/socklnd/socklnd_modparams.c |  4 ++--
 net/lnet/lnet/api-ni.c                     | 26 +++++++++++++++++++++++---
 4 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index def0923..75c0da7 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -81,8 +81,10 @@
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
 
-/* default timeout */
+/* default timeout and credits */
 #define DEFAULT_PEER_TIMEOUT    180
+#define DEFAULT_PEER_CREDITS	8
+#define DEFAULT_CREDITS	256
 
 int choose_ipv4_src(u32 *ret, int interface, u32 dst_ipaddr, struct net *ns);
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 7407ced..f341376 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -67,11 +67,11 @@
 MODULE_PARM_DESC(ntx, "# of message descriptors allocated for each pool");
 
 /* NB: this value is shared by all CPTs */
-static int credits = 256;
+static int credits = DEFAULT_CREDITS;
 module_param(credits, int, 0444);
 MODULE_PARM_DESC(credits, "# concurrent sends");
 
-static int peer_credits = 8;
+static int peer_credits = DEFAULT_PEER_CREDITS;
 module_param(peer_credits, int, 0444);
 MODULE_PARM_DESC(peer_credits, "# concurrent sends to 1 peer");
 
diff --git a/net/lnet/klnds/socklnd/socklnd_modparams.c b/net/lnet/klnds/socklnd/socklnd_modparams.c
index b511e54..017627f 100644
--- a/net/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/net/lnet/klnds/socklnd/socklnd_modparams.c
@@ -28,11 +28,11 @@
 module_param(sock_timeout, int, 0644);
 MODULE_PARM_DESC(sock_timeout, "dead socket timeout (seconds)");
 
-static int credits = 256;
+static int credits = DEFAULT_CREDITS;
 module_param(credits, int, 0444);
 MODULE_PARM_DESC(credits, "# concurrent sends");
 
-static int peer_credits = 8;
+static int peer_credits = DEFAULT_PEER_CREDITS;
 module_param(peer_credits, int, 0444);
 MODULE_PARM_DESC(peer_credits, "# concurrent sends to 1 peer");
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index d6694cb..3e69435 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3093,6 +3093,19 @@ static int lnet_add_net_common(struct lnet_net *net,
 	return rc;
 }
 
+static void
+lnet_set_tune_defaults(struct lnet_ioctl_config_lnd_tunables *tun)
+{
+	if (tun) {
+		if (!tun->lt_cmn.lct_peer_timeout)
+			tun->lt_cmn.lct_peer_timeout = DEFAULT_PEER_TIMEOUT;
+		if (!tun->lt_cmn.lct_peer_tx_credits)
+			tun->lt_cmn.lct_peer_tx_credits = DEFAULT_PEER_CREDITS;
+		if (!tun->lt_cmn.lct_max_tx_credits)
+			tun->lt_cmn.lct_max_tx_credits = DEFAULT_CREDITS;
+	}
+}
+
 static int lnet_handle_legacy_ip2nets(char *ip2nets,
 				      struct lnet_ioctl_config_lnd_tunables *tun)
 {
@@ -3109,6 +3122,8 @@ static int lnet_handle_legacy_ip2nets(char *ip2nets,
 	if (rc < 0)
 		return rc;
 
+	lnet_set_tune_defaults(tun);
+
 	mutex_lock(&the_lnet.ln_api_mutex);
 	while ((net = list_first_entry_or_null(&net_head,
 					       struct lnet_net,
@@ -3172,6 +3187,8 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 	if (!ni)
 		return -ENOMEM;
 
+	lnet_set_tune_defaults(tun);
+
 	mutex_lock(&the_lnet.ln_api_mutex);
 
 	rc = lnet_add_net_common(net, tun);
@@ -3304,13 +3321,16 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 	memset(&tun, 0, sizeof(tun));
 
 	tun.lt_cmn.lct_peer_timeout =
-		conf->cfg_config_u.cfg_net.net_peer_timeout;
+	 (!conf->cfg_config_u.cfg_net.net_peer_timeout) ? DEFAULT_PEER_TIMEOUT :
+	  conf->cfg_config_u.cfg_net.net_peer_timeout;
 	tun.lt_cmn.lct_peer_tx_credits =
-		conf->cfg_config_u.cfg_net.net_peer_tx_credits;
+	 (!conf->cfg_config_u.cfg_net.net_peer_tx_credits) ? DEFAULT_PEER_CREDITS :
+	  conf->cfg_config_u.cfg_net.net_peer_tx_credits;
 	tun.lt_cmn.lct_peer_rtr_credits =
 		conf->cfg_config_u.cfg_net.net_peer_rtr_credits;
 	tun.lt_cmn.lct_max_tx_credits =
-		conf->cfg_config_u.cfg_net.net_max_tx_credits;
+	 (!conf->cfg_config_u.cfg_net.net_max_tx_credits) ? DEFAULT_CREDITS :
+	  conf->cfg_config_u.cfg_net.net_max_tx_credits;
 
 	rc = lnet_add_net_common(net, &tun);
 
-- 
1.8.3.1
