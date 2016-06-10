From: James Simmons <jsimmons@infradead.org>
Date: Fri, 10 Jun 2016 16:14:23 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: socklnd: remove typedefs
Message-ID: <1465589663-22408-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove all remaining typedefs in socklnd driver.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  302 ++++++++++----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  209 +++++++-------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  200 +++++++-------
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   34 ++--
 .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  |    2 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   68 +++---
 6 files changed, 406 insertions(+), 409 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 406c0e7..0fdc37c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -44,14 +44,14 @@
 #include "socklnd.h"
 
 static lnd_t the_ksocklnd;
-ksock_nal_data_t ksocknal_data;
+struct ksock_nal_data ksocknal_data;
 
-static ksock_interface_t *
+static struct ksock_interface *
 ksocknal_ip2iface(lnet_ni_t *ni, __u32 ip)
 {
-	ksock_net_t *net = ni->ni_data;
+	struct ksock_net *net = ni->ni_data;
 	int i;
-	ksock_interface_t *iface;
+	struct ksock_interface *iface;
 
 	for (i = 0; i < net->ksnn_ninterfaces; i++) {
 		LASSERT(i < LNET_MAX_INTERFACES);
@@ -64,10 +64,10 @@ ksocknal_ip2iface(lnet_ni_t *ni, __u32 ip)
 	return NULL;
 }
 
-static ksock_route_t *
+static struct ksock_route *
 ksocknal_create_route(__u32 ipaddr, int port)
 {
-	ksock_route_t *route;
+	struct ksock_route *route;
 
 	LIBCFS_ALLOC(route, sizeof(*route));
 	if (!route)
@@ -89,7 +89,7 @@ ksocknal_create_route(__u32 ipaddr, int port)
 }
 
 void
-ksocknal_destroy_route(ksock_route_t *route)
+ksocknal_destroy_route(struct ksock_route *route)
 {
 	LASSERT(!atomic_read(&route->ksnr_refcount));
 
@@ -100,11 +100,11 @@ ksocknal_destroy_route(ksock_route_t *route)
 }
 
 static int
-ksocknal_create_peer(ksock_peer_t **peerp, lnet_ni_t *ni, lnet_process_id_t id)
+ksocknal_create_peer(struct ksock_peer **peerp, lnet_ni_t *ni, lnet_process_id_t id)
 {
 	int cpt = lnet_cpt_of_nid(id.nid);
-	ksock_net_t *net = ni->ni_data;
-	ksock_peer_t *peer;
+	struct ksock_net *net = ni->ni_data;
+	struct ksock_peer *peer;
 
 	LASSERT(id.nid != LNET_NID_ANY);
 	LASSERT(id.pid != LNET_PID_ANY);
@@ -148,9 +148,9 @@ ksocknal_create_peer(ksock_peer_t **peerp, lnet_ni_t *ni, lnet_process_id_t id)
 }
 
 void
-ksocknal_destroy_peer(ksock_peer_t *peer)
+ksocknal_destroy_peer(struct ksock_peer *peer)
 {
-	ksock_net_t *net = peer->ksnp_ni->ni_data;
+	struct ksock_net *net = peer->ksnp_ni->ni_data;
 
 	CDEBUG(D_NET, "peer %s %p deleted\n",
 	       libcfs_id2str(peer->ksnp_id), peer);
@@ -175,15 +175,15 @@ ksocknal_destroy_peer(ksock_peer_t *peer)
 	spin_unlock_bh(&net->ksnn_lock);
 }
 
-ksock_peer_t *
+struct ksock_peer *
 ksocknal_find_peer_locked(lnet_ni_t *ni, lnet_process_id_t id)
 {
 	struct list_head *peer_list = ksocknal_nid2peerlist(id.nid);
 	struct list_head *tmp;
-	ksock_peer_t *peer;
+	struct ksock_peer *peer;
 
 	list_for_each(tmp, peer_list) {
-		peer = list_entry(tmp, ksock_peer_t, ksnp_list);
+		peer = list_entry(tmp, struct ksock_peer, ksnp_list);
 
 		LASSERT(!peer->ksnp_closing);
 
@@ -202,10 +202,10 @@ ksocknal_find_peer_locked(lnet_ni_t *ni, lnet_process_id_t id)
 	return NULL;
 }
 
-ksock_peer_t *
+struct ksock_peer *
 ksocknal_find_peer(lnet_ni_t *ni, lnet_process_id_t id)
 {
-	ksock_peer_t *peer;
+	struct ksock_peer *peer;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 	peer = ksocknal_find_peer_locked(ni, id);
@@ -217,11 +217,11 @@ ksocknal_find_peer(lnet_ni_t *ni, lnet_process_id_t id)
 }
 
 static void
-ksocknal_unlink_peer_locked(ksock_peer_t *peer)
+ksocknal_unlink_peer_locked(struct ksock_peer *peer)
 {
 	int i;
 	__u32 ip;
-	ksock_interface_t *iface;
+	struct ksock_interface *iface;
 
 	for (i = 0; i < peer->ksnp_n_passive_ips; i++) {
 		LASSERT(i < LNET_MAX_INTERFACES);
@@ -253,9 +253,9 @@ ksocknal_get_peer_info(lnet_ni_t *ni, int index,
 		       lnet_process_id_t *id, __u32 *myip, __u32 *peer_ip,
 		       int *port, int *conn_count, int *share_count)
 {
-	ksock_peer_t *peer;
+	struct ksock_peer *peer;
 	struct list_head *ptmp;
-	ksock_route_t *route;
+	struct ksock_route *route;
 	struct list_head *rtmp;
 	int i;
 	int j;
@@ -265,7 +265,7 @@ ksocknal_get_peer_info(lnet_ni_t *ni, int index,
 
 	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
 		list_for_each(ptmp, &ksocknal_data.ksnd_peers[i]) {
-			peer = list_entry(ptmp, ksock_peer_t, ksnp_list);
+			peer = list_entry(ptmp, struct ksock_peer, ksnp_list);
 
 			if (peer->ksnp_ni != ni)
 				continue;
@@ -303,7 +303,7 @@ ksocknal_get_peer_info(lnet_ni_t *ni, int index,
 				if (index-- > 0)
 					continue;
 
-				route = list_entry(rtmp, ksock_route_t,
+				route = list_entry(rtmp, struct ksock_route,
 						   ksnr_list);
 
 				*id = peer->ksnp_id;
@@ -323,11 +323,11 @@ ksocknal_get_peer_info(lnet_ni_t *ni, int index,
 }
 
 static void
-ksocknal_associate_route_conn_locked(ksock_route_t *route, ksock_conn_t *conn)
+ksocknal_associate_route_conn_locked(struct ksock_route *route, struct ksock_conn *conn)
 {
-	ksock_peer_t *peer = route->ksnr_peer;
+	struct ksock_peer *peer = route->ksnr_peer;
 	int type = conn->ksnc_type;
-	ksock_interface_t *iface;
+	struct ksock_interface *iface;
 
 	conn->ksnc_route = route;
 	ksocknal_route_addref(route);
@@ -369,11 +369,11 @@ ksocknal_associate_route_conn_locked(ksock_route_t *route, ksock_conn_t *conn)
 }
 
 static void
-ksocknal_add_route_locked(ksock_peer_t *peer, ksock_route_t *route)
+ksocknal_add_route_locked(struct ksock_peer *peer, struct ksock_route *route)
 {
 	struct list_head *tmp;
-	ksock_conn_t *conn;
-	ksock_route_t *route2;
+	struct ksock_conn *conn;
+	struct ksock_route *route2;
 
 	LASSERT(!peer->ksnp_closing);
 	LASSERT(!route->ksnr_peer);
@@ -383,7 +383,7 @@ ksocknal_add_route_locked(ksock_peer_t *peer, ksock_route_t *route)
 
 	/* LASSERT(unique) */
 	list_for_each(tmp, &peer->ksnp_routes) {
-		route2 = list_entry(tmp, ksock_route_t, ksnr_list);
+		route2 = list_entry(tmp, struct ksock_route, ksnr_list);
 
 		if (route2->ksnr_ipaddr == route->ksnr_ipaddr) {
 			CERROR("Duplicate route %s %pI4h\n",
@@ -399,7 +399,7 @@ ksocknal_add_route_locked(ksock_peer_t *peer, ksock_route_t *route)
 	list_add_tail(&route->ksnr_list, &peer->ksnp_routes);
 
 	list_for_each(tmp, &peer->ksnp_conns) {
-		conn = list_entry(tmp, ksock_conn_t, ksnc_list);
+		conn = list_entry(tmp, struct ksock_conn, ksnc_list);
 
 		if (conn->ksnc_ipaddr != route->ksnr_ipaddr)
 			continue;
@@ -410,11 +410,11 @@ ksocknal_add_route_locked(ksock_peer_t *peer, ksock_route_t *route)
 }
 
 static void
-ksocknal_del_route_locked(ksock_route_t *route)
+ksocknal_del_route_locked(struct ksock_route *route)
 {
-	ksock_peer_t *peer = route->ksnr_peer;
-	ksock_interface_t *iface;
-	ksock_conn_t *conn;
+	struct ksock_peer *peer = route->ksnr_peer;
+	struct ksock_interface *iface;
+	struct ksock_conn *conn;
 	struct list_head *ctmp;
 	struct list_head *cnxt;
 
@@ -422,7 +422,7 @@ ksocknal_del_route_locked(ksock_route_t *route)
 
 	/* Close associated conns */
 	list_for_each_safe(ctmp, cnxt, &peer->ksnp_conns) {
-		conn = list_entry(ctmp, ksock_conn_t, ksnc_list);
+		conn = list_entry(ctmp, struct ksock_conn, ksnc_list);
 
 		if (conn->ksnc_route != route)
 			continue;
@@ -455,10 +455,10 @@ int
 ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 {
 	struct list_head *tmp;
-	ksock_peer_t *peer;
-	ksock_peer_t *peer2;
-	ksock_route_t *route;
-	ksock_route_t *route2;
+	struct ksock_peer *peer;
+	struct ksock_peer *peer2;
+	struct ksock_route *route;
+	struct ksock_route *route2;
 	int rc;
 
 	if (id.nid == LNET_NID_ANY ||
@@ -479,7 +479,7 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	/* always called with a ref on ni, so shutdown can't have started */
-	LASSERT(!((ksock_net_t *) ni->ni_data)->ksnn_shutdown);
+	LASSERT(!((struct ksock_net *) ni->ni_data)->ksnn_shutdown);
 
 	peer2 = ksocknal_find_peer_locked(ni, id);
 	if (peer2) {
@@ -493,7 +493,7 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 
 	route2 = NULL;
 	list_for_each(tmp, &peer->ksnp_routes) {
-		route2 = list_entry(tmp, ksock_route_t, ksnr_list);
+		route2 = list_entry(tmp, struct ksock_route, ksnr_list);
 
 		if (route2->ksnr_ipaddr == ipaddr)
 			break;
@@ -514,10 +514,10 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 }
 
 static void
-ksocknal_del_peer_locked(ksock_peer_t *peer, __u32 ip)
+ksocknal_del_peer_locked(struct ksock_peer *peer, __u32 ip)
 {
-	ksock_conn_t *conn;
-	ksock_route_t *route;
+	struct ksock_conn *conn;
+	struct ksock_route *route;
 	struct list_head *tmp;
 	struct list_head *nxt;
 	int nshared;
@@ -528,7 +528,7 @@ ksocknal_del_peer_locked(ksock_peer_t *peer, __u32 ip)
 	ksocknal_peer_addref(peer);
 
 	list_for_each_safe(tmp, nxt, &peer->ksnp_routes) {
-		route = list_entry(tmp, ksock_route_t, ksnr_list);
+		route = list_entry(tmp, struct ksock_route, ksnr_list);
 
 		/* no match */
 		if (!(!ip || route->ksnr_ipaddr == ip))
@@ -541,7 +541,7 @@ ksocknal_del_peer_locked(ksock_peer_t *peer, __u32 ip)
 
 	nshared = 0;
 	list_for_each_safe(tmp, nxt, &peer->ksnp_routes) {
-		route = list_entry(tmp, ksock_route_t, ksnr_list);
+		route = list_entry(tmp, struct ksock_route, ksnr_list);
 		nshared += route->ksnr_share_count;
 	}
 
@@ -551,7 +551,7 @@ ksocknal_del_peer_locked(ksock_peer_t *peer, __u32 ip)
 		 * left
 		 */
 		list_for_each_safe(tmp, nxt, &peer->ksnp_routes) {
-			route = list_entry(tmp, ksock_route_t, ksnr_list);
+			route = list_entry(tmp, struct ksock_route, ksnr_list);
 
 			/* we should only be removing auto-entries */
 			LASSERT(!route->ksnr_share_count);
@@ -559,7 +559,7 @@ ksocknal_del_peer_locked(ksock_peer_t *peer, __u32 ip)
 		}
 
 		list_for_each_safe(tmp, nxt, &peer->ksnp_conns) {
-			conn = list_entry(tmp, ksock_conn_t, ksnc_list);
+			conn = list_entry(tmp, struct ksock_conn, ksnc_list);
 
 			ksocknal_close_conn_locked(conn, 0);
 		}
@@ -575,7 +575,7 @@ ksocknal_del_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip)
 	LIST_HEAD(zombies);
 	struct list_head *ptmp;
 	struct list_head *pnxt;
-	ksock_peer_t *peer;
+	struct ksock_peer *peer;
 	int lo;
 	int hi;
 	int i;
@@ -593,7 +593,7 @@ ksocknal_del_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip)
 
 	for (i = lo; i <= hi; i++) {
 		list_for_each_safe(ptmp, pnxt, &ksocknal_data.ksnd_peers[i]) {
-			peer = list_entry(ptmp, ksock_peer_t, ksnp_list);
+			peer = list_entry(ptmp, struct ksock_peer, ksnp_list);
 
 			if (peer->ksnp_ni != ni)
 				continue;
@@ -628,12 +628,12 @@ ksocknal_del_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip)
 	return rc;
 }
 
-static ksock_conn_t *
+static struct ksock_conn *
 ksocknal_get_conn_by_idx(lnet_ni_t *ni, int index)
 {
-	ksock_peer_t *peer;
+	struct ksock_peer *peer;
 	struct list_head *ptmp;
-	ksock_conn_t *conn;
+	struct ksock_conn *conn;
 	struct list_head *ctmp;
 	int i;
 
@@ -641,7 +641,7 @@ ksocknal_get_conn_by_idx(lnet_ni_t *ni, int index)
 
 	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
 		list_for_each(ptmp, &ksocknal_data.ksnd_peers[i]) {
-			peer = list_entry(ptmp, ksock_peer_t, ksnp_list);
+			peer = list_entry(ptmp, struct ksock_peer, ksnp_list);
 
 			LASSERT(!peer->ksnp_closing);
 
@@ -652,7 +652,7 @@ ksocknal_get_conn_by_idx(lnet_ni_t *ni, int index)
 				if (index-- > 0)
 					continue;
 
-				conn = list_entry(ctmp, ksock_conn_t,
+				conn = list_entry(ctmp, struct ksock_conn,
 						  ksnc_list);
 				ksocknal_conn_addref(conn);
 				read_unlock(&ksocknal_data.ksnd_global_lock);
@@ -665,11 +665,11 @@ ksocknal_get_conn_by_idx(lnet_ni_t *ni, int index)
 	return NULL;
 }
 
-static ksock_sched_t *
+static struct ksock_sched *
 ksocknal_choose_scheduler_locked(unsigned int cpt)
 {
 	struct ksock_sched_info	*info = ksocknal_data.ksnd_sched_info[cpt];
-	ksock_sched_t *sched;
+	struct ksock_sched *sched;
 	int i;
 
 	LASSERT(info->ksi_nthreads > 0);
@@ -691,7 +691,7 @@ ksocknal_choose_scheduler_locked(unsigned int cpt)
 static int
 ksocknal_local_ipvec(lnet_ni_t *ni, __u32 *ipaddrs)
 {
-	ksock_net_t *net = ni->ni_data;
+	struct ksock_net *net = ni->ni_data;
 	int i;
 	int nip;
 
@@ -719,7 +719,7 @@ ksocknal_local_ipvec(lnet_ni_t *ni, __u32 *ipaddrs)
 }
 
 static int
-ksocknal_match_peerip(ksock_interface_t *iface, __u32 *ips, int nips)
+ksocknal_match_peerip(struct ksock_interface *iface, __u32 *ips, int nips)
 {
 	int best_netmatch = 0;
 	int best_xor      = 0;
@@ -751,12 +751,12 @@ ksocknal_match_peerip(ksock_interface_t *iface, __u32 *ips, int nips)
 }
 
 static int
-ksocknal_select_ips(ksock_peer_t *peer, __u32 *peerips, int n_peerips)
+ksocknal_select_ips(struct ksock_peer *peer, __u32 *peerips, int n_peerips)
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
-	ksock_net_t *net = peer->ksnp_ni->ni_data;
-	ksock_interface_t *iface;
-	ksock_interface_t *best_iface;
+	struct ksock_net *net = peer->ksnp_ni->ni_data;
+	struct ksock_interface *iface;
+	struct ksock_interface *best_iface;
 	int n_ips;
 	int i;
 	int j;
@@ -862,17 +862,17 @@ ksocknal_select_ips(ksock_peer_t *peer, __u32 *peerips, int n_peerips)
 }
 
 static void
-ksocknal_create_routes(ksock_peer_t *peer, int port,
+ksocknal_create_routes(struct ksock_peer *peer, int port,
 		       __u32 *peer_ipaddrs, int npeer_ipaddrs)
 {
-	ksock_route_t *newroute = NULL;
+	struct ksock_route *newroute = NULL;
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
 	lnet_ni_t *ni = peer->ksnp_ni;
-	ksock_net_t *net = ni->ni_data;
+	struct ksock_net *net = ni->ni_data;
 	struct list_head *rtmp;
-	ksock_route_t *route;
-	ksock_interface_t *iface;
-	ksock_interface_t *best_iface;
+	struct ksock_route *route;
+	struct ksock_interface *iface;
+	struct ksock_interface *best_iface;
 	int best_netmatch;
 	int this_netmatch;
 	int best_nroutes;
@@ -919,7 +919,7 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 		/* Already got a route? */
 		route = NULL;
 		list_for_each(rtmp, &peer->ksnp_routes) {
-			route = list_entry(rtmp, ksock_route_t, ksnr_list);
+			route = list_entry(rtmp, struct ksock_route, ksnr_list);
 
 			if (route->ksnr_ipaddr == newroute->ksnr_ipaddr)
 				break;
@@ -941,7 +941,7 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 
 			/* Using this interface already? */
 			list_for_each(rtmp, &peer->ksnp_routes) {
-				route = list_entry(rtmp, ksock_route_t,
+				route = list_entry(rtmp, struct ksock_route,
 						   ksnr_list);
 
 				if (route->ksnr_myipaddr == iface->ksni_ipaddr)
@@ -985,7 +985,7 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 int
 ksocknal_accept(lnet_ni_t *ni, struct socket *sock)
 {
-	ksock_connreq_t *cr;
+	struct ksock_connreq *cr;
 	int rc;
 	__u32 peer_ip;
 	int peer_port;
@@ -1014,9 +1014,9 @@ ksocknal_accept(lnet_ni_t *ni, struct socket *sock)
 }
 
 static int
-ksocknal_connecting(ksock_peer_t *peer, __u32 ipaddr)
+ksocknal_connecting(struct ksock_peer *peer, __u32 ipaddr)
 {
-	ksock_route_t *route;
+	struct ksock_route *route;
 
 	list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
 		if (route->ksnr_ipaddr == ipaddr)
@@ -1026,7 +1026,7 @@ ksocknal_connecting(ksock_peer_t *peer, __u32 ipaddr)
 }
 
 int
-ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
+ksocknal_create_conn(lnet_ni_t *ni, struct ksock_route *route,
 		     struct socket *sock, int type)
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
@@ -1034,15 +1034,15 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	lnet_process_id_t peerid;
 	struct list_head *tmp;
 	__u64 incarnation;
-	ksock_conn_t *conn;
-	ksock_conn_t *conn2;
-	ksock_peer_t *peer = NULL;
-	ksock_peer_t *peer2;
-	ksock_sched_t *sched;
+	struct ksock_conn *conn;
+	struct ksock_conn *conn2;
+	struct ksock_peer *peer = NULL;
+	struct ksock_peer *peer2;
+	struct ksock_sched *sched;
 	ksock_hello_msg_t *hello;
 	int cpt;
-	ksock_tx_t *tx;
-	ksock_tx_t *txtmp;
+	struct ksock_tx *tx;
+	struct ksock_tx *txtmp;
 	int rc;
 	int active;
 	char *warn = NULL;
@@ -1150,7 +1150,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		write_lock_bh(global_lock);
 
 		/* called with a ref on ni, so shutdown can't have started */
-		LASSERT(!((ksock_net_t *) ni->ni_data)->ksnn_shutdown);
+		LASSERT(!((struct ksock_net *) ni->ni_data)->ksnn_shutdown);
 
 		peer2 = ksocknal_find_peer_locked(ni, peerid);
 		if (!peer2) {
@@ -1233,7 +1233,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	 */
 	if (conn->ksnc_ipaddr != conn->ksnc_myipaddr) {
 		list_for_each(tmp, &peer->ksnp_conns) {
-			conn2 = list_entry(tmp, ksock_conn_t, ksnc_list);
+			conn2 = list_entry(tmp, struct ksock_conn, ksnc_list);
 
 			if (conn2->ksnc_ipaddr != conn->ksnc_ipaddr ||
 			    conn2->ksnc_myipaddr != conn->ksnc_myipaddr ||
@@ -1273,7 +1273,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	 * continually create duplicate routes.
 	 */
 	list_for_each(tmp, &peer->ksnp_routes) {
-		route = list_entry(tmp, ksock_route_t, ksnr_list);
+		route = list_entry(tmp, struct ksock_route, ksnr_list);
 
 		if (route->ksnr_ipaddr != conn->ksnc_ipaddr)
 			continue;
@@ -1432,16 +1432,16 @@ failed_0:
 }
 
 void
-ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
+ksocknal_close_conn_locked(struct ksock_conn *conn, int error)
 {
 	/*
 	 * This just does the immmediate housekeeping, and queues the
 	 * connection for the reaper to terminate.
 	 * Caller holds ksnd_global_lock exclusively in irq context
 	 */
-	ksock_peer_t *peer = conn->ksnc_peer;
-	ksock_route_t *route;
-	ksock_conn_t *conn2;
+	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_route *route;
+	struct ksock_conn *conn2;
 	struct list_head *tmp;
 
 	LASSERT(!peer->ksnp_error);
@@ -1459,7 +1459,7 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 
 		conn2 = NULL;
 		list_for_each(tmp, &peer->ksnp_conns) {
-			conn2 = list_entry(tmp, ksock_conn_t, ksnc_list);
+			conn2 = list_entry(tmp, struct ksock_conn, ksnc_list);
 
 			if (conn2->ksnc_route == route &&
 			    conn2->ksnc_type == conn->ksnc_type)
@@ -1484,7 +1484,7 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 		/* No more connections to this peer */
 
 		if (!list_empty(&peer->ksnp_tx_queue)) {
-			ksock_tx_t *tx;
+			struct ksock_tx *tx;
 
 			LASSERT(conn->ksnc_proto == &ksocknal_protocol_v3x);
 
@@ -1524,7 +1524,7 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 }
 
 void
-ksocknal_peer_failed(ksock_peer_t *peer)
+ksocknal_peer_failed(struct ksock_peer *peer)
 {
 	int notify = 0;
 	unsigned long last_alive = 0;
@@ -1552,12 +1552,12 @@ ksocknal_peer_failed(ksock_peer_t *peer)
 }
 
 void
-ksocknal_finalize_zcreq(ksock_conn_t *conn)
+ksocknal_finalize_zcreq(struct ksock_conn *conn)
 {
-	ksock_peer_t *peer = conn->ksnc_peer;
-	ksock_tx_t *tx;
-	ksock_tx_t *temp;
-	ksock_tx_t *tmp;
+	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_tx *tx;
+	struct ksock_tx *temp;
+	struct ksock_tx *tmp;
 	LIST_HEAD(zlist);
 
 	/*
@@ -1589,7 +1589,7 @@ ksocknal_finalize_zcreq(ksock_conn_t *conn)
 }
 
 void
-ksocknal_terminate_conn(ksock_conn_t *conn)
+ksocknal_terminate_conn(struct ksock_conn *conn)
 {
 	/*
 	 * This gets called by the reaper (guaranteed thread context) to
@@ -1597,8 +1597,8 @@ ksocknal_terminate_conn(ksock_conn_t *conn)
 	 * ksnc_refcount will eventually hit zero, and then the reaper will
 	 * destroy it.
 	 */
-	ksock_peer_t *peer = conn->ksnc_peer;
-	ksock_sched_t *sched = conn->ksnc_scheduler;
+	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_sched *sched = conn->ksnc_scheduler;
 	int failed = 0;
 
 	LASSERT(conn->ksnc_closing);
@@ -1656,7 +1656,7 @@ ksocknal_terminate_conn(ksock_conn_t *conn)
 }
 
 void
-ksocknal_queue_zombie_conn(ksock_conn_t *conn)
+ksocknal_queue_zombie_conn(struct ksock_conn *conn)
 {
 	/* Queue the conn for the reaper to destroy */
 
@@ -1670,7 +1670,7 @@ ksocknal_queue_zombie_conn(ksock_conn_t *conn)
 }
 
 void
-ksocknal_destroy_conn(ksock_conn_t *conn)
+ksocknal_destroy_conn(struct ksock_conn *conn)
 {
 	unsigned long last_rcv;
 
@@ -1730,15 +1730,15 @@ ksocknal_destroy_conn(ksock_conn_t *conn)
 }
 
 int
-ksocknal_close_peer_conns_locked(ksock_peer_t *peer, __u32 ipaddr, int why)
+ksocknal_close_peer_conns_locked(struct ksock_peer *peer, __u32 ipaddr, int why)
 {
-	ksock_conn_t *conn;
+	struct ksock_conn *conn;
 	struct list_head *ctmp;
 	struct list_head *cnxt;
 	int count = 0;
 
 	list_for_each_safe(ctmp, cnxt, &peer->ksnp_conns) {
-		conn = list_entry(ctmp, ksock_conn_t, ksnc_list);
+		conn = list_entry(ctmp, struct ksock_conn, ksnc_list);
 
 		if (!ipaddr || conn->ksnc_ipaddr == ipaddr) {
 			count++;
@@ -1750,9 +1750,9 @@ ksocknal_close_peer_conns_locked(ksock_peer_t *peer, __u32 ipaddr, int why)
 }
 
 int
-ksocknal_close_conn_and_siblings(ksock_conn_t *conn, int why)
+ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why)
 {
-	ksock_peer_t *peer = conn->ksnc_peer;
+	struct ksock_peer *peer = conn->ksnc_peer;
 	__u32 ipaddr = conn->ksnc_ipaddr;
 	int count;
 
@@ -1768,7 +1768,7 @@ ksocknal_close_conn_and_siblings(ksock_conn_t *conn, int why)
 int
 ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr)
 {
-	ksock_peer_t *peer;
+	struct ksock_peer *peer;
 	struct list_head *ptmp;
 	struct list_head *pnxt;
 	int lo;
@@ -1789,7 +1789,7 @@ ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr)
 	for (i = lo; i <= hi; i++) {
 		list_for_each_safe(ptmp, pnxt,
 				   &ksocknal_data.ksnd_peers[i]) {
-			peer = list_entry(ptmp, ksock_peer_t, ksnp_list);
+			peer = list_entry(ptmp, struct ksock_peer, ksnp_list);
 
 			if (!((id.nid == LNET_NID_ANY || id.nid == peer->ksnp_id.nid) &&
 			      (id.pid == LNET_PID_ANY || id.pid == peer->ksnp_id.pid)))
@@ -1844,7 +1844,7 @@ ksocknal_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	int connect = 1;
 	unsigned long last_alive = 0;
 	unsigned long now = cfs_time_current();
-	ksock_peer_t *peer = NULL;
+	struct ksock_peer *peer = NULL;
 	rwlock_t *glock = &ksocknal_data.ksnd_global_lock;
 	lnet_process_id_t id = {
 		.nid = nid,
@@ -1856,11 +1856,11 @@ ksocknal_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	peer = ksocknal_find_peer_locked(ni, id);
 	if (peer) {
 		struct list_head *tmp;
-		ksock_conn_t *conn;
+		struct ksock_conn *conn;
 		int bufnob;
 
 		list_for_each(tmp, &peer->ksnp_conns) {
-			conn = list_entry(tmp, ksock_conn_t, ksnc_list);
+			conn = list_entry(tmp, struct ksock_conn, ksnc_list);
 			bufnob = conn->ksnc_sock->sk->sk_wmem_queued;
 
 			if (bufnob < conn->ksnc_tx_bufnob) {
@@ -1902,12 +1902,12 @@ ksocknal_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 }
 
 static void
-ksocknal_push_peer(ksock_peer_t *peer)
+ksocknal_push_peer(struct ksock_peer *peer)
 {
 	int index;
 	int i;
 	struct list_head *tmp;
-	ksock_conn_t *conn;
+	struct ksock_conn *conn;
 
 	for (index = 0; ; index++) {
 		read_lock(&ksocknal_data.ksnd_global_lock);
@@ -1917,7 +1917,7 @@ ksocknal_push_peer(ksock_peer_t *peer)
 
 		list_for_each(tmp, &peer->ksnp_conns) {
 			if (i++ == index) {
-				conn = list_entry(tmp, ksock_conn_t,
+				conn = list_entry(tmp, struct ksock_conn,
 						  ksnc_list);
 				ksocknal_conn_addref(conn);
 				break;
@@ -1954,7 +1954,7 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 		int peer_off; /* searching offset in peer hash table */
 
 		for (peer_off = 0; ; peer_off++) {
-			ksock_peer_t *peer;
+			struct ksock_peer *peer;
 			int i = 0;
 
 			read_lock(&ksocknal_data.ksnd_global_lock);
@@ -1986,15 +1986,15 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 static int
 ksocknal_add_interface(lnet_ni_t *ni, __u32 ipaddress, __u32 netmask)
 {
-	ksock_net_t *net = ni->ni_data;
-	ksock_interface_t *iface;
+	struct ksock_net *net = ni->ni_data;
+	struct ksock_interface *iface;
 	int rc;
 	int i;
 	int j;
 	struct list_head *ptmp;
-	ksock_peer_t *peer;
+	struct ksock_peer *peer;
 	struct list_head *rtmp;
-	ksock_route_t *route;
+	struct ksock_route *route;
 
 	if (!ipaddress || !netmask)
 		return -EINVAL;
@@ -2017,7 +2017,7 @@ ksocknal_add_interface(lnet_ni_t *ni, __u32 ipaddress, __u32 netmask)
 
 		for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
 			list_for_each(ptmp, &ksocknal_data.ksnd_peers[i]) {
-				peer = list_entry(ptmp, ksock_peer_t,
+				peer = list_entry(ptmp, struct ksock_peer,
 						  ksnp_list);
 
 				for (j = 0; j < peer->ksnp_n_passive_ips; j++)
@@ -2025,7 +2025,7 @@ ksocknal_add_interface(lnet_ni_t *ni, __u32 ipaddress, __u32 netmask)
 						iface->ksni_npeers++;
 
 				list_for_each(rtmp, &peer->ksnp_routes) {
-					route = list_entry(rtmp, ksock_route_t,
+					route = list_entry(rtmp, struct ksock_route,
 							   ksnr_list);
 
 					if (route->ksnr_myipaddr == ipaddress)
@@ -2044,12 +2044,12 @@ ksocknal_add_interface(lnet_ni_t *ni, __u32 ipaddress, __u32 netmask)
 }
 
 static void
-ksocknal_peer_del_interface_locked(ksock_peer_t *peer, __u32 ipaddr)
+ksocknal_peer_del_interface_locked(struct ksock_peer *peer, __u32 ipaddr)
 {
 	struct list_head *tmp;
 	struct list_head *nxt;
-	ksock_route_t *route;
-	ksock_conn_t *conn;
+	struct ksock_route *route;
+	struct ksock_conn *conn;
 	int i;
 	int j;
 
@@ -2063,7 +2063,7 @@ ksocknal_peer_del_interface_locked(ksock_peer_t *peer, __u32 ipaddr)
 		}
 
 	list_for_each_safe(tmp, nxt, &peer->ksnp_routes) {
-		route = list_entry(tmp, ksock_route_t, ksnr_list);
+		route = list_entry(tmp, struct ksock_route, ksnr_list);
 
 		if (route->ksnr_myipaddr != ipaddr)
 			continue;
@@ -2077,7 +2077,7 @@ ksocknal_peer_del_interface_locked(ksock_peer_t *peer, __u32 ipaddr)
 	}
 
 	list_for_each_safe(tmp, nxt, &peer->ksnp_conns) {
-		conn = list_entry(tmp, ksock_conn_t, ksnc_list);
+		conn = list_entry(tmp, struct ksock_conn, ksnc_list);
 
 		if (conn->ksnc_myipaddr == ipaddr)
 			ksocknal_close_conn_locked(conn, 0);
@@ -2087,11 +2087,11 @@ ksocknal_peer_del_interface_locked(ksock_peer_t *peer, __u32 ipaddr)
 static int
 ksocknal_del_interface(lnet_ni_t *ni, __u32 ipaddress)
 {
-	ksock_net_t *net = ni->ni_data;
+	struct ksock_net *net = ni->ni_data;
 	int rc = -ENOENT;
 	struct list_head *tmp;
 	struct list_head *nxt;
-	ksock_peer_t *peer;
+	struct ksock_peer *peer;
 	__u32 this_ip;
 	int i;
 	int j;
@@ -2115,7 +2115,7 @@ ksocknal_del_interface(lnet_ni_t *ni, __u32 ipaddress)
 		for (j = 0; j < ksocknal_data.ksnd_peer_hash_size; j++) {
 			list_for_each_safe(tmp, nxt,
 					   &ksocknal_data.ksnd_peers[j]) {
-				peer = list_entry(tmp, ksock_peer_t, ksnp_list);
+				peer = list_entry(tmp, struct ksock_peer, ksnp_list);
 
 				if (peer->ksnp_ni != ni)
 					continue;
@@ -2139,8 +2139,8 @@ ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 
 	switch (cmd) {
 	case IOC_LIBCFS_GET_INTERFACE: {
-		ksock_net_t       *net = ni->ni_data;
-		ksock_interface_t *iface;
+		struct ksock_net       *net = ni->ni_data;
+		struct ksock_interface *iface;
 
 		read_lock(&ksocknal_data.ksnd_global_lock);
 
@@ -2209,7 +2209,7 @@ ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 		int txmem;
 		int rxmem;
 		int nagle;
-		ksock_conn_t *conn = ksocknal_get_conn_by_idx(ni, data->ioc_count);
+		struct ksock_conn *conn = ksocknal_get_conn_by_idx(ni, data->ioc_count);
 
 		if (!conn)
 			return -ENOENT;
@@ -2284,8 +2284,8 @@ ksocknal_free_buffers(void)
 
 	if (!list_empty(&ksocknal_data.ksnd_idle_noop_txs)) {
 		struct list_head zlist;
-		ksock_tx_t *tx;
-		ksock_tx_t *temp;
+		struct ksock_tx *tx;
+		struct ksock_tx *temp;
 
 		list_add(&zlist, &ksocknal_data.ksnd_idle_noop_txs);
 		list_del_init(&ksocknal_data.ksnd_idle_noop_txs);
@@ -2304,7 +2304,7 @@ static void
 ksocknal_base_shutdown(void)
 {
 	struct ksock_sched_info *info;
-	ksock_sched_t *sched;
+	struct ksock_sched *sched;
 	int i;
 	int j;
 
@@ -2446,7 +2446,7 @@ ksocknal_base_startup(void)
 		goto failed;
 
 	cfs_percpt_for_each(info, i, ksocknal_data.ksnd_sched_info) {
-		ksock_sched_t *sched;
+		struct ksock_sched *sched;
 		int nthrs;
 
 		nthrs = cfs_cpt_weight(lnet_cpt_table(), i);
@@ -2534,7 +2534,7 @@ ksocknal_base_startup(void)
 static void
 ksocknal_debug_peerhash(lnet_ni_t *ni)
 {
-	ksock_peer_t *peer = NULL;
+	struct ksock_peer *peer = NULL;
 	struct list_head *tmp;
 	int i;
 
@@ -2542,7 +2542,7 @@ ksocknal_debug_peerhash(lnet_ni_t *ni)
 
 	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
 		list_for_each(tmp, &ksocknal_data.ksnd_peers[i]) {
-			peer = list_entry(tmp, ksock_peer_t, ksnp_list);
+			peer = list_entry(tmp, struct ksock_peer, ksnp_list);
 
 			if (peer->ksnp_ni == ni)
 				break;
@@ -2552,8 +2552,8 @@ ksocknal_debug_peerhash(lnet_ni_t *ni)
 	}
 
 	if (peer) {
-		ksock_route_t *route;
-		ksock_conn_t  *conn;
+		struct ksock_route *route;
+		struct ksock_conn  *conn;
 
 		CWARN("Active peer on shutdown: %s, ref %d, scnt %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
 		      libcfs_id2str(peer->ksnp_id),
@@ -2565,7 +2565,7 @@ ksocknal_debug_peerhash(lnet_ni_t *ni)
 		      !list_empty(&peer->ksnp_zc_req_list));
 
 		list_for_each(tmp, &peer->ksnp_routes) {
-			route = list_entry(tmp, ksock_route_t, ksnr_list);
+			route = list_entry(tmp, struct ksock_route, ksnr_list);
 			CWARN("Route: ref %d, schd %d, conn %d, cnted %d, del %d\n",
 			      atomic_read(&route->ksnr_refcount),
 			      route->ksnr_scheduled, route->ksnr_connecting,
@@ -2573,7 +2573,7 @@ ksocknal_debug_peerhash(lnet_ni_t *ni)
 		}
 
 		list_for_each(tmp, &peer->ksnp_conns) {
-			conn = list_entry(tmp, ksock_conn_t, ksnc_list);
+			conn = list_entry(tmp, struct ksock_conn, ksnc_list);
 			CWARN("Conn: ref %d, sref %d, t %d, c %d\n",
 			      atomic_read(&conn->ksnc_conn_refcount),
 			      atomic_read(&conn->ksnc_sock_refcount),
@@ -2587,7 +2587,7 @@ ksocknal_debug_peerhash(lnet_ni_t *ni)
 void
 ksocknal_shutdown(lnet_ni_t *ni)
 {
-	ksock_net_t *net = ni->ni_data;
+	struct ksock_net *net = ni->ni_data;
 	int i;
 	lnet_process_id_t anyid = {0};
 
@@ -2637,7 +2637,7 @@ ksocknal_shutdown(lnet_ni_t *ni)
 }
 
 static int
-ksocknal_enumerate_interfaces(ksock_net_t *net)
+ksocknal_enumerate_interfaces(struct ksock_net *net)
 {
 	char **names;
 	int i;
@@ -2694,7 +2694,7 @@ ksocknal_enumerate_interfaces(ksock_net_t *net)
 }
 
 static int
-ksocknal_search_new_ipif(ksock_net_t *net)
+ksocknal_search_new_ipif(struct ksock_net *net)
 {
 	int new_ipif = 0;
 	int i;
@@ -2703,7 +2703,7 @@ ksocknal_search_new_ipif(ksock_net_t *net)
 		char *ifnam = &net->ksnn_interfaces[i].ksni_name[0];
 		char *colon = strchr(ifnam, ':');
 		int found  = 0;
-		ksock_net_t *tmp;
+		struct ksock_net *tmp;
 		int j;
 
 		if (colon) /* ignore alias device */
@@ -2760,7 +2760,7 @@ ksocknal_start_schedulers(struct ksock_sched_info *info)
 	for (i = 0; i < nthrs; i++) {
 		long id;
 		char name[20];
-		ksock_sched_t *sched;
+		struct ksock_sched *sched;
 
 		id = KSOCK_THREAD_ID(info->ksi_cpt, info->ksi_nthreads + i);
 		sched = &info->ksi_scheds[KSOCK_THREAD_SID(id)];
@@ -2782,7 +2782,7 @@ ksocknal_start_schedulers(struct ksock_sched_info *info)
 }
 
 static int
-ksocknal_net_start_threads(ksock_net_t *net, __u32 *cpts, int ncpts)
+ksocknal_net_start_threads(struct ksock_net *net, __u32 *cpts, int ncpts)
 {
 	int newif = ksocknal_search_new_ipif(net);
 	int rc;
@@ -2810,7 +2810,7 @@ ksocknal_net_start_threads(ksock_net_t *net, __u32 *cpts, int ncpts)
 int
 ksocknal_startup(lnet_ni_t *ni)
 {
-	ksock_net_t *net;
+	struct ksock_net *net;
 	int rc;
 	int i;
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index a60d72f..a56632b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -77,8 +77,7 @@
 
 struct ksock_sched_info;
 
-typedef struct				  /* per scheduler state */
-{
+struct ksock_sched {				/* per scheduler state */
 	spinlock_t              kss_lock;       /* serialise */
 	struct list_head        kss_rx_conns;   /* conn waiting to be read */
 	struct list_head        kss_tx_conns;   /* conn waiting to be written */
@@ -89,13 +88,13 @@ typedef struct				  /* per scheduler state */
 	struct ksock_sched_info *kss_info;	/* owner of it */
 	struct page             *kss_rx_scratch_pgs[LNET_MAX_IOV];
 	struct kvec             kss_scratch_iov[LNET_MAX_IOV];
-} ksock_sched_t;
+};
 
 struct ksock_sched_info {
 	int                     ksi_nthreads_max; /* max allowed threads */
 	int                     ksi_nthreads;     /* number of threads */
 	int                     ksi_cpt;          /* CPT id */
-	ksock_sched_t           *ksi_scheds;      /* array of schedulers */
+	struct ksock_sched	*ksi_scheds;	  /* array of schedulers */
 };
 
 #define KSOCK_CPT_SHIFT           16
@@ -103,16 +102,15 @@ struct ksock_sched_info {
 #define KSOCK_THREAD_CPT(id)      ((id) >> KSOCK_CPT_SHIFT)
 #define KSOCK_THREAD_SID(id)      ((id) & ((1UL << KSOCK_CPT_SHIFT) - 1))
 
-typedef struct                                  /* in-use interface */
-{
+struct ksock_interface {			/* in-use interface */
 	__u32		ksni_ipaddr;		/* interface's IP address */
 	__u32		ksni_netmask;		/* interface's network mask */
 	int		ksni_nroutes;		/* # routes using (active) */
 	int		ksni_npeers;		/* # peers using (passive) */
 	char		ksni_name[IFNAMSIZ];	/* interface name */
-} ksock_interface_t;
+};
 
-typedef struct {
+struct ksock_tunables {
 	int          *ksnd_timeout;            /* "stuck" socket timeout
 						* (seconds) */
 	int          *ksnd_nscheds;            /* # scheduler threads in each
@@ -155,24 +153,24 @@ typedef struct {
 						* Chelsio TOE) */
 	int          *ksnd_zc_recv_min_nfrags; /* minimum # of fragments to
 						* enable ZC receive */
-} ksock_tunables_t;
+};
 
-typedef struct {
+struct ksock_net {
 	__u64		  ksnn_incarnation;	/* my epoch */
 	spinlock_t	  ksnn_lock;		/* serialise */
 	struct list_head	  ksnn_list;		/* chain on global list */
 	int		  ksnn_npeers;		/* # peers */
 	int		  ksnn_shutdown;	/* shutting down? */
 	int		  ksnn_ninterfaces;	/* IP interfaces */
-	ksock_interface_t ksnn_interfaces[LNET_MAX_INTERFACES];
-} ksock_net_t;
+	struct ksock_interface ksnn_interfaces[LNET_MAX_INTERFACES];
+};
 
 /** connd timeout */
 #define SOCKNAL_CONND_TIMEOUT  120
 /** reserved thread for accepting & creating new connd */
 #define SOCKNAL_CONND_RESV     1
 
-typedef struct {
+struct ksock_nal_data {
 	int                     ksnd_init;              /* initialisation state
 							 */
 	int                     ksnd_nnets;             /* # networks set up */
@@ -229,7 +227,7 @@ typedef struct {
 	spinlock_t              ksnd_tx_lock;           /* serialise, g_lock
 							 * unsafe */
 
-} ksock_nal_data_t;
+};
 
 #define SOCKNAL_INIT_NOTHING 0
 #define SOCKNAL_INIT_DATA    1
@@ -250,8 +248,7 @@ struct ksock_peer;  /* forward ref */
 struct ksock_route; /* forward ref */
 struct ksock_proto; /* forward ref */
 
-typedef struct                             /* transmit packet */
-{
+struct ksock_tx {			   /* transmit packet */
 	struct list_head  tx_list;         /* queue on conn for transmission etc
 					    */
 	struct list_head  tx_zc_list;      /* queue on peer for ZC request */
@@ -281,20 +278,20 @@ typedef struct                             /* transmit packet */
 			struct kvec iov[1];  /* virt hdr + payload */
 		} virt;
 	} tx_frags;
-} ksock_tx_t;
+};
 
-#define KSOCK_NOOP_TX_SIZE (offsetof(ksock_tx_t, tx_frags.paged.kiov[0]))
+#define KSOCK_NOOP_TX_SIZE (offsetof(struct ksock_tx, tx_frags.paged.kiov[0]))
 
-/* network zero copy callback descriptor embedded in ksock_tx_t */
+/* network zero copy callback descriptor embedded in struct ksock_tx */
 
 /*
  * space for the rx frag descriptors; we either read a single contiguous
  * header, or up to LNET_MAX_IOV frags of payload of either type.
  */
-typedef union {
+union ksock_rxiovspace {
 	struct kvec      iov[LNET_MAX_IOV];
 	lnet_kiov_t      kiov[LNET_MAX_IOV];
-} ksock_rxiovspace_t;
+};
 
 #define SOCKNAL_RX_KSM_HEADER   1 /* reading ksock message header */
 #define SOCKNAL_RX_LNET_HEADER  2 /* reading lnet message header */
@@ -303,7 +300,7 @@ typedef union {
 #define SOCKNAL_RX_LNET_PAYLOAD 5 /* reading lnet payload (to deliver here) */
 #define SOCKNAL_RX_SLOP         6 /* skipping body */
 
-typedef struct ksock_conn {
+struct ksock_conn {
 	struct ksock_peer  *ksnc_peer;        /* owning peer */
 	struct ksock_route *ksnc_route;       /* owning route */
 	struct list_head   ksnc_list;         /* stash on peer's conn list */
@@ -314,8 +311,8 @@ typedef struct ksock_conn {
 						     * write_space() callback */
 	atomic_t           ksnc_conn_refcount;/* conn refcount */
 	atomic_t           ksnc_sock_refcount;/* sock refcount */
-	ksock_sched_t      *ksnc_scheduler;   /* who schedules this connection
-					       */
+	struct ksock_sched *ksnc_scheduler;	/* who schedules this connection
+					         */
 	__u32              ksnc_myipaddr;     /* my IP */
 	__u32              ksnc_ipaddr;       /* peer's IP */
 	int                ksnc_port;         /* peer's port */
@@ -341,7 +338,7 @@ typedef struct ksock_conn {
 	struct kvec        *ksnc_rx_iov;      /* the iovec frags */
 	int                ksnc_rx_nkiov;     /* # page frags */
 	lnet_kiov_t        *ksnc_rx_kiov;     /* the page frags */
-	ksock_rxiovspace_t ksnc_rx_iov_space; /* space for frag descriptors */
+	union ksock_rxiovspace ksnc_rx_iov_space; /* space for frag descriptors */
 	__u32              ksnc_rx_csum;      /* partial checksum for incoming
 					       * data */
 	void               *ksnc_cookie;      /* rx lnet_finalize passthru arg
@@ -357,7 +354,7 @@ typedef struct ksock_conn {
 	struct list_head   ksnc_tx_list;      /* where I enq waiting for output
 					       * space */
 	struct list_head   ksnc_tx_queue;     /* packets waiting to be sent */
-	ksock_tx_t         *ksnc_tx_carrier;  /* next TX that can carry a LNet
+	struct ksock_tx         *ksnc_tx_carrier;  /* next TX that can carry a LNet
 					       * message or ZC-ACK */
 	unsigned long      ksnc_tx_deadline;  /* when (in jiffies) tx times out
 					       */
@@ -367,9 +364,9 @@ typedef struct ksock_conn {
 	int		   ksnc_tx_scheduled; /* being progressed */
 	unsigned long      ksnc_tx_last_post; /* time stamp of the last posted
 					       * TX */
-} ksock_conn_t;
+};
 
-typedef struct ksock_route {
+struct ksock_route {
 	struct list_head  ksnr_list;           /* chain on peer route list */
 	struct list_head  ksnr_connd_list;     /* chain on ksnr_connd_routes */
 	struct ksock_peer *ksnr_peer;          /* owning peer */
@@ -389,11 +386,11 @@ typedef struct ksock_route {
 	unsigned int      ksnr_share_count;    /* created explicitly? */
 	int               ksnr_conn_count;     /* # conns established by this
 						* route */
-} ksock_route_t;
+};
 
 #define SOCKNAL_KEEPALIVE_PING 1 /* cookie for keepalive ping */
 
-typedef struct ksock_peer {
+struct ksock_peer {
 	struct list_head   ksnp_list;           /* stash on global peer list */
 	unsigned long      ksnp_last_alive;     /* when (in jiffies) I was last
 						 * alive */
@@ -420,49 +417,49 @@ typedef struct ksock_peer {
 
 	/* preferred local interfaces */
 	__u32              ksnp_passive_ips[LNET_MAX_INTERFACES];
-} ksock_peer_t;
+};
 
-typedef struct ksock_connreq {
+struct ksock_connreq {
 	struct list_head ksncr_list;  /* stash on ksnd_connd_connreqs */
 	lnet_ni_t        *ksncr_ni;   /* chosen NI */
 	struct socket    *ksncr_sock; /* accepted socket */
-} ksock_connreq_t;
+};
 
-extern ksock_nal_data_t ksocknal_data;
-extern ksock_tunables_t ksocknal_tunables;
+extern struct ksock_nal_data ksocknal_data;
+extern struct ksock_tunables ksocknal_tunables;
 
 #define SOCKNAL_MATCH_NO  0 /* TX can't match type of connection */
 #define SOCKNAL_MATCH_YES 1 /* TX matches type of connection */
 #define SOCKNAL_MATCH_MAY 2 /* TX can be sent on the connection, but not
 			     * preferred */
 
-typedef struct ksock_proto {
+struct ksock_proto {
 	/* version number of protocol */
 	int        pro_version;
 
 	/* handshake function */
-	int        (*pro_send_hello)(ksock_conn_t *, ksock_hello_msg_t *);
+	int        (*pro_send_hello)(struct ksock_conn *, ksock_hello_msg_t *);
 
 	/* handshake function */
-	int        (*pro_recv_hello)(ksock_conn_t *, ksock_hello_msg_t *, int);
+	int        (*pro_recv_hello)(struct ksock_conn *, ksock_hello_msg_t *, int);
 
 	/* message pack */
-	void       (*pro_pack)(ksock_tx_t *);
+	void       (*pro_pack)(struct ksock_tx *);
 
 	/* message unpack */
 	void       (*pro_unpack)(ksock_msg_t *);
 
 	/* queue tx on the connection */
-	ksock_tx_t *(*pro_queue_tx_msg)(ksock_conn_t *, ksock_tx_t *);
+	struct ksock_tx *(*pro_queue_tx_msg)(struct ksock_conn *, struct ksock_tx *);
 
 	/* queue ZC ack on the connection */
-	int        (*pro_queue_tx_zcack)(ksock_conn_t *, ksock_tx_t *, __u64);
+	int        (*pro_queue_tx_zcack)(struct ksock_conn *, struct ksock_tx *, __u64);
 
 	/* handle ZC request */
-	int        (*pro_handle_zcreq)(ksock_conn_t *, __u64, int);
+	int        (*pro_handle_zcreq)(struct ksock_conn *, __u64, int);
 
 	/* handle ZC ACK */
-	int        (*pro_handle_zcack)(ksock_conn_t *, __u64, __u64);
+	int        (*pro_handle_zcack)(struct ksock_conn *, __u64, __u64);
 
 	/*
 	 * msg type matches the connection type:
@@ -471,12 +468,12 @@ typedef struct ksock_proto {
 	 *   return MATCH_YES : matching type
 	 *   return MATCH_MAY : can be backup
 	 */
-	int        (*pro_match_tx)(ksock_conn_t *, ksock_tx_t *, int);
-} ksock_proto_t;
+	int        (*pro_match_tx)(struct ksock_conn *, struct ksock_tx *, int);
+};
 
-extern ksock_proto_t ksocknal_protocol_v1x;
-extern ksock_proto_t ksocknal_protocol_v2x;
-extern ksock_proto_t ksocknal_protocol_v3x;
+extern struct ksock_proto ksocknal_protocol_v1x;
+extern struct ksock_proto ksocknal_protocol_v2x;
+extern struct ksock_proto ksocknal_protocol_v3x;
 
 #define KSOCK_PROTO_V1_MAJOR LNET_PROTO_TCP_VERSION_MAJOR
 #define KSOCK_PROTO_V1_MINOR LNET_PROTO_TCP_VERSION_MINOR
@@ -517,17 +514,17 @@ ksocknal_nid2peerlist(lnet_nid_t nid)
 }
 
 static inline void
-ksocknal_conn_addref(ksock_conn_t *conn)
+ksocknal_conn_addref(struct ksock_conn *conn)
 {
 	LASSERT(atomic_read(&conn->ksnc_conn_refcount) > 0);
 	atomic_inc(&conn->ksnc_conn_refcount);
 }
 
-void ksocknal_queue_zombie_conn(ksock_conn_t *conn);
-void ksocknal_finalize_zcreq(ksock_conn_t *conn);
+void ksocknal_queue_zombie_conn(struct ksock_conn *conn);
+void ksocknal_finalize_zcreq(struct ksock_conn *conn);
 
 static inline void
-ksocknal_conn_decref(ksock_conn_t *conn)
+ksocknal_conn_decref(struct ksock_conn *conn)
 {
 	LASSERT(atomic_read(&conn->ksnc_conn_refcount) > 0);
 	if (atomic_dec_and_test(&conn->ksnc_conn_refcount))
@@ -535,7 +532,7 @@ ksocknal_conn_decref(ksock_conn_t *conn)
 }
 
 static inline int
-ksocknal_connsock_addref(ksock_conn_t *conn)
+ksocknal_connsock_addref(struct ksock_conn *conn)
 {
 	int rc = -ESHUTDOWN;
 
@@ -551,7 +548,7 @@ ksocknal_connsock_addref(ksock_conn_t *conn)
 }
 
 static inline void
-ksocknal_connsock_decref(ksock_conn_t *conn)
+ksocknal_connsock_decref(struct ksock_conn *conn)
 {
 	LASSERT(atomic_read(&conn->ksnc_sock_refcount) > 0);
 	if (atomic_dec_and_test(&conn->ksnc_sock_refcount)) {
@@ -563,17 +560,17 @@ ksocknal_connsock_decref(ksock_conn_t *conn)
 }
 
 static inline void
-ksocknal_tx_addref(ksock_tx_t *tx)
+ksocknal_tx_addref(struct ksock_tx *tx)
 {
 	LASSERT(atomic_read(&tx->tx_refcount) > 0);
 	atomic_inc(&tx->tx_refcount);
 }
 
-void ksocknal_tx_prep(ksock_conn_t *, ksock_tx_t *tx);
-void ksocknal_tx_done(lnet_ni_t *ni, ksock_tx_t *tx);
+void ksocknal_tx_prep(struct ksock_conn *, struct ksock_tx *tx);
+void ksocknal_tx_done(lnet_ni_t *ni, struct ksock_tx *tx);
 
 static inline void
-ksocknal_tx_decref(ksock_tx_t *tx)
+ksocknal_tx_decref(struct ksock_tx *tx)
 {
 	LASSERT(atomic_read(&tx->tx_refcount) > 0);
 	if (atomic_dec_and_test(&tx->tx_refcount))
@@ -581,16 +578,16 @@ ksocknal_tx_decref(ksock_tx_t *tx)
 }
 
 static inline void
-ksocknal_route_addref(ksock_route_t *route)
+ksocknal_route_addref(struct ksock_route *route)
 {
 	LASSERT(atomic_read(&route->ksnr_refcount) > 0);
 	atomic_inc(&route->ksnr_refcount);
 }
 
-void ksocknal_destroy_route(ksock_route_t *route);
+void ksocknal_destroy_route(struct ksock_route *route);
 
 static inline void
-ksocknal_route_decref(ksock_route_t *route)
+ksocknal_route_decref(struct ksock_route *route)
 {
 	LASSERT(atomic_read(&route->ksnr_refcount) > 0);
 	if (atomic_dec_and_test(&route->ksnr_refcount))
@@ -598,16 +595,16 @@ ksocknal_route_decref(ksock_route_t *route)
 }
 
 static inline void
-ksocknal_peer_addref(ksock_peer_t *peer)
+ksocknal_peer_addref(struct ksock_peer *peer)
 {
 	LASSERT(atomic_read(&peer->ksnp_refcount) > 0);
 	atomic_inc(&peer->ksnp_refcount);
 }
 
-void ksocknal_destroy_peer(ksock_peer_t *peer);
+void ksocknal_destroy_peer(struct ksock_peer *peer);
 
 static inline void
-ksocknal_peer_decref(ksock_peer_t *peer)
+ksocknal_peer_decref(struct ksock_peer *peer)
 {
 	LASSERT(atomic_read(&peer->ksnp_refcount) > 0);
 	if (atomic_dec_and_test(&peer->ksnp_refcount))
@@ -625,71 +622,71 @@ int ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
 int ksocknal_accept(lnet_ni_t *ni, struct socket *sock);
 
 int ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip, int port);
-ksock_peer_t *ksocknal_find_peer_locked(lnet_ni_t *ni, lnet_process_id_t id);
-ksock_peer_t *ksocknal_find_peer(lnet_ni_t *ni, lnet_process_id_t id);
-void ksocknal_peer_failed(ksock_peer_t *peer);
-int ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
+struct ksock_peer *ksocknal_find_peer_locked(lnet_ni_t *ni, lnet_process_id_t id);
+struct ksock_peer *ksocknal_find_peer(lnet_ni_t *ni, lnet_process_id_t id);
+void ksocknal_peer_failed(struct ksock_peer *peer);
+int ksocknal_create_conn(lnet_ni_t *ni, struct ksock_route *route,
 			 struct socket *sock, int type);
-void ksocknal_close_conn_locked(ksock_conn_t *conn, int why);
-void ksocknal_terminate_conn(ksock_conn_t *conn);
-void ksocknal_destroy_conn(ksock_conn_t *conn);
-int  ksocknal_close_peer_conns_locked(ksock_peer_t *peer,
+void ksocknal_close_conn_locked(struct ksock_conn *conn, int why);
+void ksocknal_terminate_conn(struct ksock_conn *conn);
+void ksocknal_destroy_conn(struct ksock_conn *conn);
+int  ksocknal_close_peer_conns_locked(struct ksock_peer *peer,
 				      __u32 ipaddr, int why);
-int ksocknal_close_conn_and_siblings(ksock_conn_t *conn, int why);
+int ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why);
 int ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr);
-ksock_conn_t *ksocknal_find_conn_locked(ksock_peer_t *peer,
-					ksock_tx_t *tx, int nonblk);
+struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer *peer,
+					struct ksock_tx *tx, int nonblk);
 
-int  ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx,
+int  ksocknal_launch_packet(lnet_ni_t *ni, struct ksock_tx *tx,
 			    lnet_process_id_t id);
-ksock_tx_t *ksocknal_alloc_tx(int type, int size);
-void ksocknal_free_tx(ksock_tx_t *tx);
-ksock_tx_t *ksocknal_alloc_tx_noop(__u64 cookie, int nonblk);
-void ksocknal_next_tx_carrier(ksock_conn_t *conn);
-void ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn);
+struct ksock_tx *ksocknal_alloc_tx(int type, int size);
+void ksocknal_free_tx(struct ksock_tx *tx);
+struct ksock_tx *ksocknal_alloc_tx_noop(__u64 cookie, int nonblk);
+void ksocknal_next_tx_carrier(struct ksock_conn *conn);
+void ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn);
 void ksocknal_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int error);
 void ksocknal_notify(lnet_ni_t *ni, lnet_nid_t gw_nid, int alive);
 void ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, unsigned long *when);
 int ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name);
 void ksocknal_thread_fini(void);
-void ksocknal_launch_all_connections_locked(ksock_peer_t *peer);
-ksock_route_t *ksocknal_find_connectable_route_locked(ksock_peer_t *peer);
-ksock_route_t *ksocknal_find_connecting_route_locked(ksock_peer_t *peer);
-int ksocknal_new_packet(ksock_conn_t *conn, int skip);
+void ksocknal_launch_all_connections_locked(struct ksock_peer *peer);
+struct ksock_route *ksocknal_find_connectable_route_locked(struct ksock_peer *peer);
+struct ksock_route *ksocknal_find_connecting_route_locked(struct ksock_peer *peer);
+int ksocknal_new_packet(struct ksock_conn *conn, int skip);
 int ksocknal_scheduler(void *arg);
 int ksocknal_connd(void *arg);
 int ksocknal_reaper(void *arg);
-int ksocknal_send_hello(lnet_ni_t *ni, ksock_conn_t *conn,
+int ksocknal_send_hello(lnet_ni_t *ni, struct ksock_conn *conn,
 			lnet_nid_t peer_nid, ksock_hello_msg_t *hello);
-int ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
+int ksocknal_recv_hello(lnet_ni_t *ni, struct ksock_conn *conn,
 			ksock_hello_msg_t *hello, lnet_process_id_t *id,
 			__u64 *incarnation);
-void ksocknal_read_callback(ksock_conn_t *conn);
-void ksocknal_write_callback(ksock_conn_t *conn);
-
-int ksocknal_lib_zc_capable(ksock_conn_t *conn);
-void ksocknal_lib_save_callback(struct socket *sock, ksock_conn_t *conn);
-void ksocknal_lib_set_callback(struct socket *sock,  ksock_conn_t *conn);
-void ksocknal_lib_reset_callback(struct socket *sock, ksock_conn_t *conn);
-void ksocknal_lib_push_conn(ksock_conn_t *conn);
-int ksocknal_lib_get_conn_addrs(ksock_conn_t *conn);
+void ksocknal_read_callback(struct ksock_conn *conn);
+void ksocknal_write_callback(struct ksock_conn *conn);
+
+int ksocknal_lib_zc_capable(struct ksock_conn *conn);
+void ksocknal_lib_save_callback(struct socket *sock, struct ksock_conn *conn);
+void ksocknal_lib_set_callback(struct socket *sock,  struct ksock_conn *conn);
+void ksocknal_lib_reset_callback(struct socket *sock, struct ksock_conn *conn);
+void ksocknal_lib_push_conn(struct ksock_conn *conn);
+int ksocknal_lib_get_conn_addrs(struct ksock_conn *conn);
 int ksocknal_lib_setup_sock(struct socket *so);
-int ksocknal_lib_send_iov(ksock_conn_t *conn, ksock_tx_t *tx);
-int ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx);
-void ksocknal_lib_eager_ack(ksock_conn_t *conn);
-int ksocknal_lib_recv_iov(ksock_conn_t *conn);
-int ksocknal_lib_recv_kiov(ksock_conn_t *conn);
-int ksocknal_lib_get_conn_tunables(ksock_conn_t *conn, int *txmem,
+int ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx);
+int ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx);
+void ksocknal_lib_eager_ack(struct ksock_conn *conn);
+int ksocknal_lib_recv_iov(struct ksock_conn *conn);
+int ksocknal_lib_recv_kiov(struct ksock_conn *conn);
+int ksocknal_lib_get_conn_tunables(struct ksock_conn *conn, int *txmem,
 				   int *rxmem, int *nagle);
 
-void ksocknal_read_callback(ksock_conn_t *conn);
-void ksocknal_write_callback(ksock_conn_t *conn);
+void ksocknal_read_callback(struct ksock_conn *conn);
+void ksocknal_write_callback(struct ksock_conn *conn);
 
 int ksocknal_tunables_init(void);
 
-void ksocknal_lib_csum_tx(ksock_tx_t *tx);
+void ksocknal_lib_csum_tx(struct ksock_tx *tx);
 
-int ksocknal_lib_memory_pressure(ksock_conn_t *conn);
+int ksocknal_lib_memory_pressure(struct ksock_conn *conn);
 int ksocknal_lib_bind_thread_to_cpu(int id);
 
 #endif /* _SOCKLND_SOCKLND_H_ */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 976fd78..e63d29b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -23,10 +23,10 @@
 
 #include "socklnd.h"
 
-ksock_tx_t *
+struct ksock_tx *
 ksocknal_alloc_tx(int type, int size)
 {
-	ksock_tx_t *tx = NULL;
+	struct ksock_tx *tx = NULL;
 
 	if (type == KSOCK_MSG_NOOP) {
 		LASSERT(size == KSOCK_NOOP_TX_SIZE);
@@ -36,7 +36,7 @@ ksocknal_alloc_tx(int type, int size)
 
 		if (!list_empty(&ksocknal_data.ksnd_idle_noop_txs)) {
 			tx = list_entry(ksocknal_data.ksnd_idle_noop_txs. \
-					    next, ksock_tx_t, tx_list);
+					    next, struct ksock_tx, tx_list);
 			LASSERT(tx->tx_desc_size == size);
 			list_del(&tx->tx_list);
 		}
@@ -61,10 +61,10 @@ ksocknal_alloc_tx(int type, int size)
 	return tx;
 }
 
-ksock_tx_t *
+struct ksock_tx *
 ksocknal_alloc_tx_noop(__u64 cookie, int nonblk)
 {
-	ksock_tx_t *tx;
+	struct ksock_tx *tx;
 
 	tx = ksocknal_alloc_tx(KSOCK_MSG_NOOP, KSOCK_NOOP_TX_SIZE);
 	if (!tx) {
@@ -87,7 +87,7 @@ ksocknal_alloc_tx_noop(__u64 cookie, int nonblk)
 }
 
 void
-ksocknal_free_tx(ksock_tx_t *tx)
+ksocknal_free_tx(struct ksock_tx *tx)
 {
 	atomic_dec(&ksocknal_data.ksnd_nactive_txs);
 
@@ -104,7 +104,7 @@ ksocknal_free_tx(ksock_tx_t *tx)
 }
 
 static int
-ksocknal_send_iov(ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	struct kvec *iov = tx->tx_iov;
 	int nob;
@@ -141,7 +141,7 @@ ksocknal_send_iov(ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 static int
-ksocknal_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	lnet_kiov_t *kiov = tx->tx_kiov;
 	int nob;
@@ -179,7 +179,7 @@ ksocknal_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 static int
-ksocknal_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	int rc;
 	int bufnob;
@@ -247,7 +247,7 @@ ksocknal_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 static int
-ksocknal_recv_iov(ksock_conn_t *conn)
+ksocknal_recv_iov(struct ksock_conn *conn)
 {
 	struct kvec *iov = conn->ksnc_rx_iov;
 	int nob;
@@ -294,7 +294,7 @@ ksocknal_recv_iov(ksock_conn_t *conn)
 }
 
 static int
-ksocknal_recv_kiov(ksock_conn_t *conn)
+ksocknal_recv_kiov(struct ksock_conn *conn)
 {
 	lnet_kiov_t *kiov = conn->ksnc_rx_kiov;
 	int nob;
@@ -341,7 +341,7 @@ ksocknal_recv_kiov(ksock_conn_t *conn)
 }
 
 static int
-ksocknal_receive(ksock_conn_t *conn)
+ksocknal_receive(struct ksock_conn *conn)
 {
 	/*
 	 * Return 1 on success, 0 on EOF, < 0 on error.
@@ -391,7 +391,7 @@ ksocknal_receive(ksock_conn_t *conn)
 }
 
 void
-ksocknal_tx_done(lnet_ni_t *ni, ksock_tx_t *tx)
+ksocknal_tx_done(lnet_ni_t *ni, struct ksock_tx *tx)
 {
 	lnet_msg_t *lnetmsg = tx->tx_lnetmsg;
 	int rc = (!tx->tx_resid && !tx->tx_zc_aborted) ? 0 : -EIO;
@@ -412,10 +412,10 @@ ksocknal_tx_done(lnet_ni_t *ni, ksock_tx_t *tx)
 void
 ksocknal_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int error)
 {
-	ksock_tx_t *tx;
+	struct ksock_tx *tx;
 
 	while (!list_empty(txlist)) {
-		tx = list_entry(txlist->next, ksock_tx_t, tx_list);
+		tx = list_entry(txlist->next, struct ksock_tx, tx_list);
 
 		if (error && tx->tx_lnetmsg) {
 			CNETERR("Deleting packet type %d len %d %s->%s\n",
@@ -435,10 +435,10 @@ ksocknal_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int error)
 }
 
 static void
-ksocknal_check_zc_req(ksock_tx_t *tx)
+ksocknal_check_zc_req(struct ksock_tx *tx)
 {
-	ksock_conn_t *conn = tx->tx_conn;
-	ksock_peer_t *peer = conn->ksnc_peer;
+	struct ksock_conn *conn = tx->tx_conn;
+	struct ksock_peer *peer = conn->ksnc_peer;
 
 	/*
 	 * Set tx_msg.ksm_zc_cookies[0] to a unique non-zero cookie and add tx
@@ -482,9 +482,9 @@ ksocknal_check_zc_req(ksock_tx_t *tx)
 }
 
 static void
-ksocknal_uncheck_zc_req(ksock_tx_t *tx)
+ksocknal_uncheck_zc_req(struct ksock_tx *tx)
 {
-	ksock_peer_t *peer = tx->tx_conn->ksnc_peer;
+	struct ksock_peer *peer = tx->tx_conn->ksnc_peer;
 
 	LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 	LASSERT(tx->tx_zc_capable);
@@ -508,7 +508,7 @@ ksocknal_uncheck_zc_req(ksock_tx_t *tx)
 }
 
 static int
-ksocknal_process_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_process_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	int rc;
 
@@ -583,7 +583,7 @@ ksocknal_process_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 static void
-ksocknal_launch_connection_locked(ksock_route_t *route)
+ksocknal_launch_connection_locked(struct ksock_route *route)
 {
 	/* called holding write lock on ksnd_global_lock */
 
@@ -604,9 +604,9 @@ ksocknal_launch_connection_locked(ksock_route_t *route)
 }
 
 void
-ksocknal_launch_all_connections_locked(ksock_peer_t *peer)
+ksocknal_launch_all_connections_locked(struct ksock_peer *peer)
 {
-	ksock_route_t *route;
+	struct ksock_route *route;
 
 	/* called holding write lock on ksnd_global_lock */
 	for (;;) {
@@ -619,18 +619,18 @@ ksocknal_launch_all_connections_locked(ksock_peer_t *peer)
 	}
 }
 
-ksock_conn_t *
-ksocknal_find_conn_locked(ksock_peer_t *peer, ksock_tx_t *tx, int nonblk)
+struct ksock_conn *
+ksocknal_find_conn_locked(struct ksock_peer *peer, struct ksock_tx *tx, int nonblk)
 {
 	struct list_head *tmp;
-	ksock_conn_t *conn;
-	ksock_conn_t *typed = NULL;
-	ksock_conn_t *fallback = NULL;
+	struct ksock_conn *conn;
+	struct ksock_conn *typed = NULL;
+	struct ksock_conn *fallback = NULL;
 	int tnob = 0;
 	int fnob = 0;
 
 	list_for_each(tmp, &peer->ksnp_conns) {
-		ksock_conn_t *c  = list_entry(tmp, ksock_conn_t, ksnc_list);
+		struct ksock_conn *c  = list_entry(tmp, struct ksock_conn, ksnc_list);
 		int nob = atomic_read(&c->ksnc_tx_nob) +
 			c->ksnc_sock->sk->sk_wmem_queued;
 		int rc;
@@ -677,7 +677,7 @@ ksocknal_find_conn_locked(ksock_peer_t *peer, ksock_tx_t *tx, int nonblk)
 }
 
 void
-ksocknal_tx_prep(ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_tx_prep(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	conn->ksnc_proto->pro_pack(tx);
 
@@ -687,11 +687,11 @@ ksocknal_tx_prep(ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 void
-ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn)
+ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn)
 {
-	ksock_sched_t *sched = conn->ksnc_scheduler;
+	struct ksock_sched *sched = conn->ksnc_scheduler;
 	ksock_msg_t *msg = &tx->tx_msg;
-	ksock_tx_t *ztx = NULL;
+	struct ksock_tx *ztx = NULL;
 	int bufnob = 0;
 
 	/*
@@ -784,15 +784,15 @@ ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn)
 	spin_unlock_bh(&sched->kss_lock);
 }
 
-ksock_route_t *
-ksocknal_find_connectable_route_locked(ksock_peer_t *peer)
+struct ksock_route *
+ksocknal_find_connectable_route_locked(struct ksock_peer *peer)
 {
 	unsigned long now = cfs_time_current();
 	struct list_head *tmp;
-	ksock_route_t *route;
+	struct ksock_route *route;
 
 	list_for_each(tmp, &peer->ksnp_routes) {
-		route = list_entry(tmp, ksock_route_t, ksnr_list);
+		route = list_entry(tmp, struct ksock_route, ksnr_list);
 
 		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
 
@@ -820,14 +820,14 @@ ksocknal_find_connectable_route_locked(ksock_peer_t *peer)
 	return NULL;
 }
 
-ksock_route_t *
-ksocknal_find_connecting_route_locked(ksock_peer_t *peer)
+struct ksock_route *
+ksocknal_find_connecting_route_locked(struct ksock_peer *peer)
 {
 	struct list_head *tmp;
-	ksock_route_t *route;
+	struct ksock_route *route;
 
 	list_for_each(tmp, &peer->ksnp_routes) {
-		route = list_entry(tmp, ksock_route_t, ksnr_list);
+		route = list_entry(tmp, struct ksock_route, ksnr_list);
 
 		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
 
@@ -839,10 +839,10 @@ ksocknal_find_connecting_route_locked(ksock_peer_t *peer)
 }
 
 int
-ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
+ksocknal_launch_packet(lnet_ni_t *ni, struct ksock_tx *tx, lnet_process_id_t id)
 {
-	ksock_peer_t *peer;
-	ksock_conn_t *conn;
+	struct ksock_peer *peer;
+	struct ksock_conn *conn;
 	rwlock_t *g_lock;
 	int retry;
 	int rc;
@@ -942,7 +942,7 @@ ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	lnet_kiov_t *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
-	ksock_tx_t *tx;
+	struct ksock_tx *tx;
 	int desc_size;
 	int rc;
 
@@ -960,10 +960,10 @@ ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	LASSERT(!in_interrupt());
 
 	if (payload_iov)
-		desc_size = offsetof(ksock_tx_t,
+		desc_size = offsetof(struct ksock_tx,
 				     tx_frags.virt.iov[1 + payload_niov]);
 	else
-		desc_size = offsetof(ksock_tx_t,
+		desc_size = offsetof(struct ksock_tx,
 				     tx_frags.paged.kiov[payload_niov]);
 
 	if (lntmsg->msg_vmflush)
@@ -1037,7 +1037,7 @@ ksocknal_thread_fini(void)
 }
 
 int
-ksocknal_new_packet(ksock_conn_t *conn, int nob_to_skip)
+ksocknal_new_packet(struct ksock_conn *conn, int nob_to_skip)
 {
 	static char ksocknal_slop_buffer[4096];
 
@@ -1120,7 +1120,7 @@ ksocknal_new_packet(ksock_conn_t *conn, int nob_to_skip)
 }
 
 static int
-ksocknal_process_receive(ksock_conn_t *conn)
+ksocknal_process_receive(struct ksock_conn *conn)
 {
 	lnet_hdr_t *lhdr;
 	lnet_process_id_t *id;
@@ -1328,8 +1328,8 @@ ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	      unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
 	      unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
-	ksock_conn_t *conn = private;
-	ksock_sched_t *sched = conn->ksnc_scheduler;
+	struct ksock_conn *conn = private;
+	struct ksock_sched *sched = conn->ksnc_scheduler;
 
 	LASSERT(mlen <= rlen);
 	LASSERT(niov <= LNET_MAX_IOV);
@@ -1382,7 +1382,7 @@ ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 }
 
 static inline int
-ksocknal_sched_cansleep(ksock_sched_t *sched)
+ksocknal_sched_cansleep(struct ksock_sched *sched)
 {
 	int rc;
 
@@ -1399,9 +1399,9 @@ ksocknal_sched_cansleep(ksock_sched_t *sched)
 int ksocknal_scheduler(void *arg)
 {
 	struct ksock_sched_info *info;
-	ksock_sched_t *sched;
-	ksock_conn_t *conn;
-	ksock_tx_t *tx;
+	struct ksock_sched *sched;
+	struct ksock_conn *conn;
+	struct ksock_tx *tx;
 	int rc;
 	int nloops = 0;
 	long id = (long)arg;
@@ -1426,7 +1426,7 @@ int ksocknal_scheduler(void *arg)
 
 		if (!list_empty(&sched->kss_rx_conns)) {
 			conn = list_entry(sched->kss_rx_conns.next,
-					  ksock_conn_t, ksnc_rx_list);
+					  struct ksock_conn, ksnc_rx_list);
 			list_del(&conn->ksnc_rx_list);
 
 			LASSERT(conn->ksnc_rx_scheduled);
@@ -1481,7 +1481,7 @@ int ksocknal_scheduler(void *arg)
 			}
 
 			conn = list_entry(sched->kss_tx_conns.next,
-					  ksock_conn_t, ksnc_tx_list);
+					  struct ksock_conn, ksnc_tx_list);
 			list_del(&conn->ksnc_tx_list);
 
 			LASSERT(conn->ksnc_tx_scheduled);
@@ -1489,7 +1489,7 @@ int ksocknal_scheduler(void *arg)
 			LASSERT(!list_empty(&conn->ksnc_tx_queue));
 
 			tx = list_entry(conn->ksnc_tx_queue.next,
-					ksock_tx_t, tx_list);
+					struct ksock_tx, tx_list);
 
 			if (conn->ksnc_tx_carrier == tx)
 				ksocknal_next_tx_carrier(conn);
@@ -1575,9 +1575,9 @@ int ksocknal_scheduler(void *arg)
  * Add connection to kss_rx_conns of scheduler
  * and wakeup the scheduler.
  */
-void ksocknal_read_callback(ksock_conn_t *conn)
+void ksocknal_read_callback(struct ksock_conn *conn)
 {
-	ksock_sched_t *sched;
+	struct ksock_sched *sched;
 
 	sched = conn->ksnc_scheduler;
 
@@ -1600,9 +1600,9 @@ void ksocknal_read_callback(ksock_conn_t *conn)
  * Add connection to kss_tx_conns of scheduler
  * and wakeup the scheduler.
  */
-void ksocknal_write_callback(ksock_conn_t *conn)
+void ksocknal_write_callback(struct ksock_conn *conn)
 {
-	ksock_sched_t *sched;
+	struct ksock_sched *sched;
 
 	sched = conn->ksnc_scheduler;
 
@@ -1623,7 +1623,7 @@ void ksocknal_write_callback(ksock_conn_t *conn)
 	spin_unlock_bh(&sched->kss_lock);
 }
 
-static ksock_proto_t *
+static struct ksock_proto *
 ksocknal_parse_proto_version(ksock_hello_msg_t *hello)
 {
 	__u32 version = 0;
@@ -1666,11 +1666,11 @@ ksocknal_parse_proto_version(ksock_hello_msg_t *hello)
 }
 
 int
-ksocknal_send_hello(lnet_ni_t *ni, ksock_conn_t *conn,
+ksocknal_send_hello(lnet_ni_t *ni, struct ksock_conn *conn,
 		    lnet_nid_t peer_nid, ksock_hello_msg_t *hello)
 {
 	/* CAVEAT EMPTOR: this byte flips 'ipaddrs' */
-	ksock_net_t *net = (ksock_net_t *)ni->ni_data;
+	struct ksock_net *net = (struct ksock_net *)ni->ni_data;
 
 	LASSERT(hello->kshm_nips <= LNET_MAX_INTERFACES);
 
@@ -1704,7 +1704,7 @@ ksocknal_invert_type(int type)
 }
 
 int
-ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
+ksocknal_recv_hello(lnet_ni_t *ni, struct ksock_conn *conn,
 		    ksock_hello_msg_t *hello, lnet_process_id_t *peerid,
 		    __u64 *incarnation)
 {
@@ -1718,7 +1718,7 @@ ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
 	int timeout;
 	int proto_match;
 	int rc;
-	ksock_proto_t *proto;
+	struct ksock_proto *proto;
 	lnet_process_id_t recv_id;
 
 	/* socket type set on active connections - not set on passive */
@@ -1847,10 +1847,10 @@ ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
 }
 
 static int
-ksocknal_connect(ksock_route_t *route)
+ksocknal_connect(struct ksock_route *route)
 {
 	LIST_HEAD(zombies);
-	ksock_peer_t *peer = route->ksnr_peer;
+	struct ksock_peer *peer = route->ksnr_peer;
 	int type;
 	int wanted;
 	struct socket *sock;
@@ -1989,7 +1989,7 @@ ksocknal_connect(ksock_route_t *route)
 	if (!list_empty(&peer->ksnp_tx_queue) &&
 	    !peer->ksnp_accepting &&
 	    !ksocknal_find_connecting_route_locked(peer)) {
-		ksock_conn_t *conn;
+		struct ksock_conn *conn;
 
 		/*
 		 * ksnp_tx_queue is queued on a conn on successful
@@ -1997,7 +1997,7 @@ ksocknal_connect(ksock_route_t *route)
 		 */
 		if (!list_empty(&peer->ksnp_conns)) {
 			conn = list_entry(peer->ksnp_conns.next,
-					  ksock_conn_t, ksnc_list);
+					  struct ksock_conn, ksnc_list);
 			LASSERT(conn->ksnc_proto == &ksocknal_protocol_v3x);
 		}
 
@@ -2131,10 +2131,10 @@ ksocknal_connd_check_stop(time64_t sec, long *timeout)
  * Go through connd_routes queue looking for a route that we can process
  * right now, @timeout_p can be updated if we need to come back later
  */
-static ksock_route_t *
+static struct ksock_route *
 ksocknal_connd_get_route_locked(signed long *timeout_p)
 {
-	ksock_route_t *route;
+	struct ksock_route *route;
 	unsigned long now;
 
 	now = cfs_time_current();
@@ -2158,7 +2158,7 @@ int
 ksocknal_connd(void *arg)
 {
 	spinlock_t *connd_lock = &ksocknal_data.ksnd_connd_lock;
-	ksock_connreq_t *cr;
+	struct ksock_connreq *cr;
 	wait_queue_t wait;
 	int nloops = 0;
 	int cons_retry = 0;
@@ -2174,7 +2174,7 @@ ksocknal_connd(void *arg)
 	ksocknal_data.ksnd_connd_running++;
 
 	while (!ksocknal_data.ksnd_shuttingdown) {
-		ksock_route_t *route = NULL;
+		struct ksock_route *route = NULL;
 		time64_t sec = ktime_get_real_seconds();
 		long timeout = MAX_SCHEDULE_TIMEOUT;
 		int dropped_lock = 0;
@@ -2192,8 +2192,8 @@ ksocknal_connd(void *arg)
 
 		if (!list_empty(&ksocknal_data.ksnd_connd_connreqs)) {
 			/* Connection accepted by the listener */
-			cr = list_entry(ksocknal_data.ksnd_connd_connreqs. \
-					    next, ksock_connreq_t, ksncr_list);
+			cr = list_entry(ksocknal_data.ksnd_connd_connreqs.next,
+					struct ksock_connreq, ksncr_list);
 
 			list_del(&cr->ksncr_list);
 			spin_unlock_bh(connd_lock);
@@ -2267,17 +2267,17 @@ ksocknal_connd(void *arg)
 	return 0;
 }
 
-static ksock_conn_t *
-ksocknal_find_timed_out_conn(ksock_peer_t *peer)
+static struct ksock_conn *
+ksocknal_find_timed_out_conn(struct ksock_peer *peer)
 {
 	/* We're called with a shared lock on ksnd_global_lock */
-	ksock_conn_t *conn;
+	struct ksock_conn *conn;
 	struct list_head *ctmp;
 
 	list_for_each(ctmp, &peer->ksnp_conns) {
 		int error;
 
-		conn = list_entry(ctmp, ksock_conn_t, ksnc_list);
+		conn = list_entry(ctmp, struct ksock_conn, ksnc_list);
 
 		/* Don't need the {get,put}connsock dance to deref ksnc_sock */
 		LASSERT(!conn->ksnc_closing);
@@ -2351,10 +2351,10 @@ ksocknal_find_timed_out_conn(ksock_peer_t *peer)
 }
 
 static inline void
-ksocknal_flush_stale_txs(ksock_peer_t *peer)
+ksocknal_flush_stale_txs(struct ksock_peer *peer)
 {
-	ksock_tx_t *tx;
-	ksock_tx_t *tmp;
+	struct ksock_tx *tx;
+	struct ksock_tx *tmp;
 	LIST_HEAD(stale_txs);
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
@@ -2374,12 +2374,12 @@ ksocknal_flush_stale_txs(ksock_peer_t *peer)
 }
 
 static int
-ksocknal_send_keepalive_locked(ksock_peer_t *peer)
+ksocknal_send_keepalive_locked(struct ksock_peer *peer)
 	__must_hold(&ksocknal_data.ksnd_global_lock)
 {
-	ksock_sched_t *sched;
-	ksock_conn_t *conn;
-	ksock_tx_t *tx;
+	struct ksock_sched *sched;
+	struct ksock_conn *conn;
+	struct ksock_tx *tx;
 
 	if (list_empty(&peer->ksnp_conns)) /* last_alive will be updated by create_conn */
 		return 0;
@@ -2440,9 +2440,9 @@ static void
 ksocknal_check_peer_timeouts(int idx)
 {
 	struct list_head *peers = &ksocknal_data.ksnd_peers[idx];
-	ksock_peer_t *peer;
-	ksock_conn_t *conn;
-	ksock_tx_t *tx;
+	struct ksock_peer *peer;
+	struct ksock_conn *conn;
+	struct ksock_tx *tx;
 
  again:
 	/*
@@ -2483,8 +2483,8 @@ ksocknal_check_peer_timeouts(int idx)
 		 * holding only shared lock
 		 */
 		if (!list_empty(&peer->ksnp_tx_queue)) {
-			ksock_tx_t *tx = list_entry(peer->ksnp_tx_queue.next,
-						    ksock_tx_t, tx_list);
+			struct ksock_tx *tx = list_entry(peer->ksnp_tx_queue.next,
+						    struct ksock_tx, tx_list);
 
 			if (cfs_time_aftereq(cfs_time_current(),
 					     tx->tx_deadline)) {
@@ -2518,7 +2518,7 @@ ksocknal_check_peer_timeouts(int idx)
 		}
 
 		tx = list_entry(peer->ksnp_zc_req_list.next,
-				ksock_tx_t, tx_zc_list);
+				struct ksock_tx, tx_zc_list);
 		deadline = tx->tx_deadline;
 		resid = tx->tx_resid;
 		conn = tx->tx_conn;
@@ -2544,8 +2544,8 @@ int
 ksocknal_reaper(void *arg)
 {
 	wait_queue_t wait;
-	ksock_conn_t *conn;
-	ksock_sched_t *sched;
+	struct ksock_conn *conn;
+	struct ksock_sched *sched;
 	struct list_head enomem_conns;
 	int nenomem_conns;
 	long timeout;
@@ -2563,7 +2563,7 @@ ksocknal_reaper(void *arg)
 	while (!ksocknal_data.ksnd_shuttingdown) {
 		if (!list_empty(&ksocknal_data.ksnd_deathrow_conns)) {
 			conn = list_entry(ksocknal_data.ksnd_deathrow_conns.next,
-					  ksock_conn_t, ksnc_list);
+					  struct ksock_conn, ksnc_list);
 			list_del(&conn->ksnc_list);
 
 			spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
@@ -2577,7 +2577,7 @@ ksocknal_reaper(void *arg)
 
 		if (!list_empty(&ksocknal_data.ksnd_zombie_conns)) {
 			conn = list_entry(ksocknal_data.ksnd_zombie_conns.next,
-					  ksock_conn_t, ksnc_list);
+					  struct ksock_conn, ksnc_list);
 			list_del(&conn->ksnc_list);
 
 			spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
@@ -2599,7 +2599,7 @@ ksocknal_reaper(void *arg)
 		/* reschedule all the connections that stalled with ENOMEM... */
 		nenomem_conns = 0;
 		while (!list_empty(&enomem_conns)) {
-			conn = list_entry(enomem_conns.next, ksock_conn_t,
+			conn = list_entry(enomem_conns.next, struct ksock_conn,
 					  ksnc_tx_list);
 			list_del(&conn->ksnc_tx_list);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 964b4e3..44d417b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -37,7 +37,7 @@
 #include "socklnd.h"
 
 int
-ksocknal_lib_get_conn_addrs(ksock_conn_t *conn)
+ksocknal_lib_get_conn_addrs(struct ksock_conn *conn)
 {
 	int rc = lnet_sock_getaddr(conn->ksnc_sock, 1, &conn->ksnc_ipaddr,
 				   &conn->ksnc_port);
@@ -60,7 +60,7 @@ ksocknal_lib_get_conn_addrs(ksock_conn_t *conn)
 }
 
 int
-ksocknal_lib_zc_capable(ksock_conn_t *conn)
+ksocknal_lib_zc_capable(struct ksock_conn *conn)
 {
 	int caps = conn->ksnc_sock->sk->sk_route_caps;
 
@@ -75,7 +75,7 @@ ksocknal_lib_zc_capable(ksock_conn_t *conn)
 }
 
 int
-ksocknal_lib_send_iov(ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	struct socket *sock = conn->ksnc_sock;
 	int nob;
@@ -118,7 +118,7 @@ ksocknal_lib_send_iov(ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 int
-ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
+ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	struct socket *sock = conn->ksnc_sock;
 	lnet_kiov_t *kiov = tx->tx_kiov;
@@ -187,7 +187,7 @@ ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 }
 
 void
-ksocknal_lib_eager_ack(ksock_conn_t *conn)
+ksocknal_lib_eager_ack(struct ksock_conn *conn)
 {
 	int opt = 1;
 	struct socket *sock = conn->ksnc_sock;
@@ -203,7 +203,7 @@ ksocknal_lib_eager_ack(ksock_conn_t *conn)
 }
 
 int
-ksocknal_lib_recv_iov(ksock_conn_t *conn)
+ksocknal_lib_recv_iov(struct ksock_conn *conn)
 {
 #if SOCKNAL_SINGLE_FRAG_RX
 	struct kvec scratch;
@@ -309,7 +309,7 @@ ksocknal_lib_kiov_vmap(lnet_kiov_t *kiov, int niov,
 }
 
 int
-ksocknal_lib_recv_kiov(ksock_conn_t *conn)
+ksocknal_lib_recv_kiov(struct ksock_conn *conn)
 {
 #if SOCKNAL_SINGLE_FRAG_RX || !SOCKNAL_RISK_KMAP_DEADLOCK
 	struct kvec scratch;
@@ -393,7 +393,7 @@ ksocknal_lib_recv_kiov(ksock_conn_t *conn)
 }
 
 void
-ksocknal_lib_csum_tx(ksock_tx_t *tx)
+ksocknal_lib_csum_tx(struct ksock_tx *tx)
 {
 	int i;
 	__u32 csum;
@@ -432,7 +432,7 @@ ksocknal_lib_csum_tx(ksock_tx_t *tx)
 }
 
 int
-ksocknal_lib_get_conn_tunables(ksock_conn_t *conn, int *txmem, int *rxmem, int *nagle)
+ksocknal_lib_get_conn_tunables(struct ksock_conn *conn, int *txmem, int *rxmem, int *nagle)
 {
 	struct socket *sock = conn->ksnc_sock;
 	int len;
@@ -562,7 +562,7 @@ ksocknal_lib_setup_sock(struct socket *sock)
 }
 
 void
-ksocknal_lib_push_conn(ksock_conn_t *conn)
+ksocknal_lib_push_conn(struct ksock_conn *conn)
 {
 	struct sock *sk;
 	struct tcp_sock *tp;
@@ -599,7 +599,7 @@ ksocknal_lib_push_conn(ksock_conn_t *conn)
 static void
 ksocknal_data_ready(struct sock *sk)
 {
-	ksock_conn_t *conn;
+	struct ksock_conn *conn;
 
 	/* interleave correctly with closing sockets... */
 	LASSERT(!in_irq());
@@ -619,7 +619,7 @@ ksocknal_data_ready(struct sock *sk)
 static void
 ksocknal_write_space(struct sock *sk)
 {
-	ksock_conn_t *conn;
+	struct ksock_conn *conn;
 	int wspace;
 	int min_wpace;
 
@@ -663,14 +663,14 @@ ksocknal_write_space(struct sock *sk)
 }
 
 void
-ksocknal_lib_save_callback(struct socket *sock, ksock_conn_t *conn)
+ksocknal_lib_save_callback(struct socket *sock, struct ksock_conn *conn)
 {
 	conn->ksnc_saved_data_ready = sock->sk->sk_data_ready;
 	conn->ksnc_saved_write_space = sock->sk->sk_write_space;
 }
 
 void
-ksocknal_lib_set_callback(struct socket *sock,  ksock_conn_t *conn)
+ksocknal_lib_set_callback(struct socket *sock,  struct ksock_conn *conn)
 {
 	sock->sk->sk_user_data = conn;
 	sock->sk->sk_data_ready = ksocknal_data_ready;
@@ -678,7 +678,7 @@ ksocknal_lib_set_callback(struct socket *sock,  ksock_conn_t *conn)
 }
 
 void
-ksocknal_lib_reset_callback(struct socket *sock, ksock_conn_t *conn)
+ksocknal_lib_reset_callback(struct socket *sock, struct ksock_conn *conn)
 {
 	/*
 	 * Remove conn's network callbacks.
@@ -697,10 +697,10 @@ ksocknal_lib_reset_callback(struct socket *sock, ksock_conn_t *conn)
 }
 
 int
-ksocknal_lib_memory_pressure(ksock_conn_t *conn)
+ksocknal_lib_memory_pressure(struct ksock_conn *conn)
 {
 	int rc = 0;
-	ksock_sched_t *sched;
+	struct ksock_sched *sched;
 
 	sched = conn->ksnc_scheduler;
 	spin_lock_bh(&sched->kss_lock);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
index 6329cbe..fc7eec8 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
@@ -139,7 +139,7 @@ module_param(protocol, int, 0644);
 MODULE_PARM_DESC(protocol, "protocol version");
 #endif
 
-ksock_tunables_t ksocknal_tunables;
+struct ksock_tunables ksocknal_tunables;
 
 int ksocknal_tunables_init(void)
 {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 32cc31e..e1bf910 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -38,8 +38,8 @@
  *   pro_match_tx()       : Called holding glock
  */
 
-static ksock_tx_t *
-ksocknal_queue_tx_msg_v1(ksock_conn_t *conn, ksock_tx_t *tx_msg)
+static struct ksock_tx *
+ksocknal_queue_tx_msg_v1(struct ksock_conn *conn, struct ksock_tx *tx_msg)
 {
 	/* V1.x, just enqueue it */
 	list_add_tail(&tx_msg->tx_list, &conn->ksnc_tx_queue);
@@ -47,9 +47,9 @@ ksocknal_queue_tx_msg_v1(ksock_conn_t *conn, ksock_tx_t *tx_msg)
 }
 
 void
-ksocknal_next_tx_carrier(ksock_conn_t *conn)
+ksocknal_next_tx_carrier(struct ksock_conn *conn)
 {
-	ksock_tx_t *tx = conn->ksnc_tx_carrier;
+	struct ksock_tx *tx = conn->ksnc_tx_carrier;
 
 	/* Called holding BH lock: conn->ksnc_scheduler->kss_lock */
 	LASSERT(!list_empty(&conn->ksnc_tx_queue));
@@ -66,10 +66,10 @@ ksocknal_next_tx_carrier(ksock_conn_t *conn)
 }
 
 static int
-ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
-			   ksock_tx_t *tx_ack, __u64 cookie)
+ksocknal_queue_tx_zcack_v2(struct ksock_conn *conn,
+			   struct ksock_tx *tx_ack, __u64 cookie)
 {
-	ksock_tx_t *tx = conn->ksnc_tx_carrier;
+	struct ksock_tx *tx = conn->ksnc_tx_carrier;
 
 	LASSERT(!tx_ack ||
 		tx_ack->tx_msg.ksm_type == KSOCK_MSG_NOOP);
@@ -112,10 +112,10 @@ ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
 	return 1;
 }
 
-static ksock_tx_t *
-ksocknal_queue_tx_msg_v2(ksock_conn_t *conn, ksock_tx_t *tx_msg)
+static struct ksock_tx *
+ksocknal_queue_tx_msg_v2(struct ksock_conn *conn, struct ksock_tx *tx_msg)
 {
-	ksock_tx_t *tx  = conn->ksnc_tx_carrier;
+	struct ksock_tx *tx  = conn->ksnc_tx_carrier;
 
 	/*
 	 * Enqueue tx_msg:
@@ -149,10 +149,10 @@ ksocknal_queue_tx_msg_v2(ksock_conn_t *conn, ksock_tx_t *tx_msg)
 }
 
 static int
-ksocknal_queue_tx_zcack_v3(ksock_conn_t *conn,
-			   ksock_tx_t *tx_ack, __u64 cookie)
+ksocknal_queue_tx_zcack_v3(struct ksock_conn *conn,
+			   struct ksock_tx *tx_ack, __u64 cookie)
 {
-	ksock_tx_t *tx;
+	struct ksock_tx *tx;
 
 	if (conn->ksnc_type != SOCKLND_CONN_ACK)
 		return ksocknal_queue_tx_zcack_v2(conn, tx_ack, cookie);
@@ -267,7 +267,7 @@ ksocknal_queue_tx_zcack_v3(ksock_conn_t *conn,
 }
 
 static int
-ksocknal_match_tx(ksock_conn_t *conn, ksock_tx_t *tx, int nonblk)
+ksocknal_match_tx(struct ksock_conn *conn, struct ksock_tx *tx, int nonblk)
 {
 	int nob;
 
@@ -311,7 +311,7 @@ ksocknal_match_tx(ksock_conn_t *conn, ksock_tx_t *tx, int nonblk)
 }
 
 static int
-ksocknal_match_tx_v3(ksock_conn_t *conn, ksock_tx_t *tx, int nonblk)
+ksocknal_match_tx_v3(struct ksock_conn *conn, struct ksock_tx *tx, int nonblk)
 {
 	int nob;
 
@@ -355,18 +355,18 @@ ksocknal_match_tx_v3(ksock_conn_t *conn, ksock_tx_t *tx, int nonblk)
 
 /* (Sink) handle incoming ZC request from sender */
 static int
-ksocknal_handle_zcreq(ksock_conn_t *c, __u64 cookie, int remote)
+ksocknal_handle_zcreq(struct ksock_conn *c, __u64 cookie, int remote)
 {
-	ksock_peer_t *peer = c->ksnc_peer;
-	ksock_conn_t *conn;
-	ksock_tx_t *tx;
+	struct ksock_peer *peer = c->ksnc_peer;
+	struct ksock_conn *conn;
+	struct ksock_tx *tx;
 	int rc;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	conn = ksocknal_find_conn_locked(peer, NULL, !!remote);
 	if (conn) {
-		ksock_sched_t *sched = conn->ksnc_scheduler;
+		struct ksock_sched *sched = conn->ksnc_scheduler;
 
 		LASSERT(conn->ksnc_proto->pro_queue_tx_zcack);
 
@@ -399,12 +399,12 @@ ksocknal_handle_zcreq(ksock_conn_t *c, __u64 cookie, int remote)
 
 /* (Sender) handle ZC_ACK from sink */
 static int
-ksocknal_handle_zcack(ksock_conn_t *conn, __u64 cookie1, __u64 cookie2)
+ksocknal_handle_zcack(struct ksock_conn *conn, __u64 cookie1, __u64 cookie2)
 {
-	ksock_peer_t *peer = conn->ksnc_peer;
-	ksock_tx_t *tx;
-	ksock_tx_t *temp;
-	ksock_tx_t *tmp;
+	struct ksock_peer *peer = conn->ksnc_peer;
+	struct ksock_tx *tx;
+	struct ksock_tx *temp;
+	struct ksock_tx *tmp;
 	LIST_HEAD(zlist);
 	int count;
 
@@ -446,7 +446,7 @@ ksocknal_handle_zcack(ksock_conn_t *conn, __u64 cookie1, __u64 cookie2)
 }
 
 static int
-ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
+ksocknal_send_hello_v1(struct ksock_conn *conn, ksock_hello_msg_t *hello)
 {
 	struct socket *sock = conn->ksnc_sock;
 	lnet_hdr_t *hdr;
@@ -521,7 +521,7 @@ out:
 }
 
 static int
-ksocknal_send_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello)
+ksocknal_send_hello_v2(struct ksock_conn *conn, ksock_hello_msg_t *hello)
 {
 	struct socket *sock = conn->ksnc_sock;
 	int rc;
@@ -563,7 +563,7 @@ ksocknal_send_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 }
 
 static int
-ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
+ksocknal_recv_hello_v1(struct ksock_conn *conn, ksock_hello_msg_t *hello,
 		       int timeout)
 {
 	struct socket *sock = conn->ksnc_sock;
@@ -639,7 +639,7 @@ out:
 }
 
 static int
-ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout)
+ksocknal_recv_hello_v2(struct ksock_conn *conn, ksock_hello_msg_t *hello, int timeout)
 {
 	struct socket *sock = conn->ksnc_sock;
 	int rc;
@@ -705,7 +705,7 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 }
 
 static void
-ksocknal_pack_msg_v1(ksock_tx_t *tx)
+ksocknal_pack_msg_v1(struct ksock_tx *tx)
 {
 	/* V1.x has no KSOCK_MSG_NOOP */
 	LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
@@ -719,7 +719,7 @@ ksocknal_pack_msg_v1(ksock_tx_t *tx)
 }
 
 static void
-ksocknal_pack_msg_v2(ksock_tx_t *tx)
+ksocknal_pack_msg_v2(struct ksock_tx *tx)
 {
 	tx->tx_iov[0].iov_base = &tx->tx_msg;
 
@@ -755,7 +755,7 @@ ksocknal_unpack_msg_v2(ksock_msg_t *msg)
 	return;  /* Do nothing */
 }
 
-ksock_proto_t  ksocknal_protocol_v1x = {
+struct ksock_proto ksocknal_protocol_v1x = {
 	.pro_version        = KSOCK_PROTO_V1,
 	.pro_send_hello     = ksocknal_send_hello_v1,
 	.pro_recv_hello     = ksocknal_recv_hello_v1,
@@ -768,7 +768,7 @@ ksock_proto_t  ksocknal_protocol_v1x = {
 	.pro_match_tx       = ksocknal_match_tx
 };
 
-ksock_proto_t  ksocknal_protocol_v2x = {
+struct ksock_proto ksocknal_protocol_v2x = {
 	.pro_version        = KSOCK_PROTO_V2,
 	.pro_send_hello     = ksocknal_send_hello_v2,
 	.pro_recv_hello     = ksocknal_recv_hello_v2,
@@ -781,7 +781,7 @@ ksock_proto_t  ksocknal_protocol_v2x = {
 	.pro_match_tx       = ksocknal_match_tx
 };
 
-ksock_proto_t  ksocknal_protocol_v3x = {
+struct ksock_proto ksocknal_protocol_v3x = {
 	.pro_version        = KSOCK_PROTO_V3,
 	.pro_send_hello     = ksocknal_send_hello_v2,
 	.pro_recv_hello     = ksocknal_recv_hello_v2,
-- 
1.7.1
