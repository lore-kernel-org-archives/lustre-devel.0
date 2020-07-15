From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:49 -0400
Subject: [lustre-devel] [PATCH 08/37] lnet: socklnd: fix local interface
 binding
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When a node is configured with multiple interfaces in
Multi-Rail config, socklnd was not utilizing the local interface
requested by LNet. In essence LNet was using all the NIDs in round
robin, however the socklnd module was not binding to the correct
interface. Traffic was thus sent on a subset of the interfaces.

The reason is that the route interface number was not being set.
In most cases lnet_connect() is called to create a socket. The
socket is bound to the interface provided and then
ksocknal_create_conn() is called to create the socklnd connection.
ksocknal_create_conn() calls ksocknal_associate_route_conn_locked()
at which point the route's local interface is assigned. However,
this is already too late as the socket has already been created
and bound to a local interface.

Therefore, it's important to assign the route's interface before
calling lnet_connect() to ensure socket is bound to correct local
interface.

To address this issue, the route's interface index is initialized
to the NI's interface index when it's added to the peer_ni.

Another bug fixed:
The interface index was not being initialized in the startup
routine.

Note: We're strictly assuming that there is one interface for each
NI. This is because tcp bonding will be removed from the socklnd as
it has been deprecated by LNet mutli-rail.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13566
Lustre-commit: a7c9aba5eb96d ("LU-13566 socklnd: fix local interface binding")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38743
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 444b90b..2b8fd3d 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -409,12 +409,14 @@ struct ksock_peer_ni *
 {
 	struct ksock_conn *conn;
 	struct ksock_route *route2;
+	struct ksock_net *net = peer_ni->ksnp_ni->ni_data;
 
 	LASSERT(!peer_ni->ksnp_closing);
 	LASSERT(!route->ksnr_peer);
 	LASSERT(!route->ksnr_scheduled);
 	LASSERT(!route->ksnr_connecting);
 	LASSERT(!route->ksnr_connected);
+	LASSERT(net->ksnn_ninterfaces > 0);
 
 	/* LASSERT(unique) */
 	list_for_each_entry(route2, &peer_ni->ksnp_routes, ksnr_list) {
@@ -428,6 +430,11 @@ struct ksock_peer_ni *
 
 	route->ksnr_peer = peer_ni;
 	ksocknal_peer_addref(peer_ni);
+
+	/* set the route's interface to the current net's interface */
+	route->ksnr_myiface = net->ksnn_interfaces[0].ksni_index;
+	net->ksnn_interfaces[0].ksni_nroutes++;
+
 	/* peer_ni's routelist takes over my ref on 'route' */
 	list_add_tail(&route->ksnr_list, &peer_ni->ksnp_routes);
 
@@ -2667,6 +2674,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		net->ksnn_ninterfaces = 1;
 		ni->ni_dev_cpt = ifaces[0].li_cpt;
 		ksi->ksni_ipaddr = ifaces[0].li_ipaddr;
+		ksi->ksni_index = ksocknal_ip2index(ksi->ksni_ipaddr, ni);
 		ksi->ksni_netmask = ifaces[0].li_netmask;
 		strlcpy(ksi->ksni_name, ifaces[0].li_name,
 			sizeof(ksi->ksni_name));
@@ -2706,6 +2714,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 				ksi = &net->ksnn_interfaces[j];
 				ni->ni_dev_cpt = ifaces[j].li_cpt;
 				ksi->ksni_ipaddr = ifaces[j].li_ipaddr;
+				ksi->ksni_index =
+					ksocknal_ip2index(ksi->ksni_ipaddr, ni);
 				ksi->ksni_netmask = ifaces[j].li_netmask;
 				strlcpy(ksi->ksni_name, ifaces[j].li_name,
 					sizeof(ksi->ksni_name));
-- 
1.8.3.1
