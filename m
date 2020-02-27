From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:31 -0500
Subject: [lustre-devel] [PATCH 223/622] lnet: check for asymmetrical route
 messages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-224-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Asymmetrical routes can be an issue when debugging network,
and allowing them also opens the door to attacks where hostile
clients inject data to the servers.

In order to prevent asymmetrical routes, add a new lnet kernel
module option named 'lnet_drop_asym_route'. When set to non-zero,
lnet_parse() will check if the message received from a remote peer
is coming through a router that would normally be used by this node
to reach the remote peer. If it is not the case, then it means we
are dealing with an asymmetrical route message, and the message will
be dropped.

The check for asymmetrical route can also be switched on/off with
the command 'lnetctl set drop_asym_route 0|1'. And this parameter is
exported/imported in Yaml.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11894
Lustre-commit: 4932febc1213 ("LU-11894 lnet: check for asymmetrical route messages")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/34119
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/lnet/api-ni.c        | 44 ++++++++++++++++++++++++++++++++++++++++
 net/lnet/lnet/lib-move.c      | 47 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 92 insertions(+)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index d09fb4c..a6e64f6 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -507,6 +507,7 @@ struct lnet_ni *
 extern unsigned int lnet_health_sensitivity;
 extern unsigned int lnet_recovery_interval;
 extern unsigned int lnet_peer_discovery_disabled;
+extern unsigned int lnet_drop_asym_route;
 extern int portal_rotor;
 
 int lnet_lib_init(void);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 3ee10da..e5f5c6c 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -126,6 +126,20 @@ static int recovery_interval_set(const char *val,
 MODULE_PARM_DESC(lnet_peer_discovery_disabled,
 		 "Set to 1 to disable peer discovery on this node.");
 
+unsigned int lnet_drop_asym_route;
+static int drop_asym_route_set(const char *val, const struct kernel_param *kp);
+
+static struct kernel_param_ops param_ops_drop_asym_route = {
+	.set = drop_asym_route_set,
+	.get = param_get_int,
+};
+
+#define param_check_drop_asym_route(name, p)	\
+	__param_check(name, p, int)
+module_param(lnet_drop_asym_route, drop_asym_route, 0644);
+MODULE_PARM_DESC(lnet_drop_asym_route,
+		 "Set to 1 to drop asymmetrical route messages.");
+
 unsigned int lnet_transaction_timeout = 50;
 static int transaction_to_set(const char *val, const struct kernel_param *kp);
 static struct kernel_param_ops param_ops_transaction_timeout = {
@@ -292,6 +306,36 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 }
 
 static int
+drop_asym_route_set(const char *val, const struct kernel_param *kp)
+{
+	int rc;
+	unsigned int *drop_asym_route = (unsigned int *)kp->arg;
+	unsigned long value;
+
+	rc = kstrtoul(val, 0, &value);
+	if (rc) {
+		CERROR("Invalid module parameter value for 'lnet_drop_asym_route'\n");
+		return rc;
+	}
+
+	/* The purpose of locking the api_mutex here is to ensure that
+	 * the correct value ends up stored properly.
+	 */
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	if (value == *drop_asym_route) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
+	*drop_asym_route = value;
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return 0;
+}
+
+static int
 transaction_to_set(const char *val, const struct kernel_param *kp)
 {
 	unsigned int *transaction_to = (unsigned int *)kp->arg;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 185c31a..809d2b6 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3959,6 +3959,53 @@ void lnet_monitor_thr_stop(void)
 		goto drop;
 	}
 
+	if (lnet_drop_asym_route && for_me &&
+	    LNET_NIDNET(src_nid) != LNET_NIDNET(from_nid)) {
+		struct lnet_net *net;
+		struct lnet_remotenet *rnet;
+		bool found = true;
+
+		/* we are dealing with a routed message,
+		 * so see if route to reach src_nid goes through from_nid
+		 */
+		lnet_net_lock(cpt);
+		net = lnet_get_net_locked(LNET_NIDNET(ni->ni_nid));
+		if (!net) {
+			lnet_net_unlock(cpt);
+			CERROR("net %s not found\n",
+			       libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
+			return -EPROTO;
+		}
+
+		rnet = lnet_find_rnet_locked(LNET_NIDNET(src_nid));
+		if (rnet) {
+			struct lnet_peer_ni *gw = NULL;
+			struct lnet_route *route;
+
+			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
+				found = false;
+				gw = route->lr_gateway;
+				if (gw->lpni_net != net)
+					continue;
+				if (gw->lpni_nid == from_nid) {
+					found = true;
+					break;
+				}
+			}
+		}
+		lnet_net_unlock(cpt);
+		if (!found) {
+			/* we would not use from_nid to route a message to
+			 * src_nid
+			 * => asymmetric routing detected but forbidden
+			 */
+			CERROR("%s, src %s: Dropping asymmetrical route %s\n",
+			       libcfs_nid2str(from_nid),
+			       libcfs_nid2str(src_nid), lnet_msgtyp2str(type));
+			goto drop;
+		}
+	}
+
 	msg = kzalloc(sizeof(*msg), GFP_NOFS);
 	if (!msg) {
 		CERROR("%s, src %s: Dropping %s (out of memory)\n",
-- 
1.8.3.1
