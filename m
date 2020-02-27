From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:59 -0500
Subject: [lustre-devel] [PATCH 611/622] lnet: socklnd: convert peers hash
 table to hashtable.h
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-612-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Using a hashtable.h hashtable, rather than bespoke code, has several
advantages:

- the table is comprised of hlist_head, rather than list_head, so
  it consumes less memory (though we need to make it a little bigger
  as it must be a power-of-2)
- there are existing macros for easily walking the whole table
- it uses a "real" hash function rather than "mod a prime number".

In some ways, rhashtable might be even better, but it can change the
ordering of objects in the table at arbitrary moments, and that could
hurt the user-space API.  It also does not support the partitioned
walking that ksocknal_check_peer_timeouts() depends on.

Note that new peers are inserted at the top of a hash chain, rather
than appended at the end.  I don't think that should be a problem.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: dbbcf61d2bdc ("LU-12678 socklnd: convert peers hash table to hashtable.h")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36837
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c    | 299 ++++++++++++++++--------------------
 net/lnet/klnds/socklnd/socklnd.h    |  18 +--
 net/lnet/klnds/socklnd/socklnd_cb.c |   8 +-
 3 files changed, 140 insertions(+), 185 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 016e005..7abb75a 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -167,10 +167,10 @@
 struct ksock_peer_ni *
 ksocknal_find_peer_locked(struct lnet_ni *ni, struct lnet_process_id id)
 {
-	struct list_head *peer_list = ksocknal_nid2peerlist(id.nid);
 	struct ksock_peer_ni *peer_ni;
 
-	list_for_each_entry(peer_ni, peer_list, ksnp_list) {
+	hash_for_each_possible(ksocknal_data.ksnd_peers, peer_ni,
+			       ksnp_list, id.nid) {
 		LASSERT(!peer_ni->ksnp_closing);
 
 		if (peer_ni->ksnp_ni != ni)
@@ -229,7 +229,7 @@ struct ksock_peer_ni *
 	LASSERT(list_empty(&peer_ni->ksnp_routes));
 	LASSERT(!peer_ni->ksnp_closing);
 	peer_ni->ksnp_closing = 1;
-	list_del(&peer_ni->ksnp_list);
+	hlist_del(&peer_ni->ksnp_list);
 	/* lose peerlist's ref */
 	ksocknal_peer_decref(peer_ni);
 }
@@ -247,55 +247,52 @@ struct ksock_peer_ni *
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
-	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
-		list_for_each_entry(peer_ni, &ksocknal_data.ksnd_peers[i],
-				    ksnp_list) {
-			if (peer_ni->ksnp_ni != ni)
-				continue;
+	hash_for_each(ksocknal_data.ksnd_peers, i, peer_ni, ksnp_list) {
+		if (peer_ni->ksnp_ni != ni)
+			continue;
 
-			if (!peer_ni->ksnp_n_passive_ips &&
-			    list_empty(&peer_ni->ksnp_routes)) {
-				if (index-- > 0)
-					continue;
+		if (!peer_ni->ksnp_n_passive_ips &&
+		    list_empty(&peer_ni->ksnp_routes)) {
+			if (index-- > 0)
+				continue;
 
-				*id = peer_ni->ksnp_id;
-				*myip = 0;
-				*peer_ip = 0;
-				*port = 0;
-				*conn_count = 0;
-				*share_count = 0;
-				rc = 0;
-				goto out;
-			}
+			*id = peer_ni->ksnp_id;
+			*myip = 0;
+			*peer_ip = 0;
+			*port = 0;
+			*conn_count = 0;
+			*share_count = 0;
+			rc = 0;
+			goto out;
+		}
 
-			for (j = 0; j < peer_ni->ksnp_n_passive_ips; j++) {
-				if (index-- > 0)
-					continue;
+		for (j = 0; j < peer_ni->ksnp_n_passive_ips; j++) {
+			if (index-- > 0)
+				continue;
 
-				*id = peer_ni->ksnp_id;
-				*myip = peer_ni->ksnp_passive_ips[j];
-				*peer_ip = 0;
-				*port = 0;
-				*conn_count = 0;
-				*share_count = 0;
-				rc = 0;
-				goto out;
-			}
+			*id = peer_ni->ksnp_id;
+			*myip = peer_ni->ksnp_passive_ips[j];
+			*peer_ip = 0;
+			*port = 0;
+			*conn_count = 0;
+			*share_count = 0;
+			rc = 0;
+			goto out;
+		}
 
-			list_for_each_entry(route, &peer_ni->ksnp_routes,
-					    ksnr_list) {
-				if (index-- > 0)
-					continue;
+		list_for_each_entry(route, &peer_ni->ksnp_routes,
+				    ksnr_list) {
+			if (index-- > 0)
+				continue;
 
-				*id = peer_ni->ksnp_id;
-				*myip = route->ksnr_myipaddr;
-				*peer_ip = route->ksnr_ipaddr;
-				*port = route->ksnr_port;
-				*conn_count = route->ksnr_conn_count;
-				*share_count = route->ksnr_share_count;
-				rc = 0;
-				goto out;
-			}
+			*id = peer_ni->ksnp_id;
+			*myip = route->ksnr_myipaddr;
+			*peer_ip = route->ksnr_ipaddr;
+			*port = route->ksnr_port;
+			*conn_count = route->ksnr_conn_count;
+			*share_count = route->ksnr_share_count;
+			rc = 0;
+			goto out;
 		}
 	}
 out:
@@ -463,8 +460,7 @@ struct ksock_peer_ni *
 		peer_ni = peer2;
 	} else {
 		/* peer_ni table takes my ref on peer_ni */
-		list_add_tail(&peer_ni->ksnp_list,
-			      ksocknal_nid2peerlist(id.nid));
+		hash_add(ksocknal_data.ksnd_peers, &peer_ni->ksnp_list, id.nid);
 	}
 
 	list_for_each_entry(route2, &peer_ni->ksnp_routes, ksnr_list) {
@@ -544,7 +540,7 @@ struct ksock_peer_ni *
 ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ip)
 {
 	LIST_HEAD(zombies);
-	struct ksock_peer_ni *pnxt;
+	struct hlist_node *pnxt;
 	struct ksock_peer_ni *peer_ni;
 	int lo;
 	int hi;
@@ -554,17 +550,17 @@ struct ksock_peer_ni *
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	if (id.nid != LNET_NID_ANY) {
-		lo = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
-		hi = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
+		lo = hash_min(id.nid, HASH_BITS(ksocknal_data.ksnd_peers));
+		hi = lo;
 	} else {
 		lo = 0;
-		hi = ksocknal_data.ksnd_peer_hash_size - 1;
+		hi = HASH_SIZE(ksocknal_data.ksnd_peers) - 1;
 	}
 
 	for (i = lo; i <= hi; i++) {
-		list_for_each_entry_safe(peer_ni, pnxt,
-					 &ksocknal_data.ksnd_peers[i],
-					 ksnp_list) {
+		hlist_for_each_entry_safe(peer_ni, pnxt,
+					  &ksocknal_data.ksnd_peers[i],
+					  ksnp_list) {
 			if (peer_ni->ksnp_ni != ni)
 				continue;
 
@@ -609,23 +605,20 @@ struct ksock_peer_ni *
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
-	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
-		list_for_each_entry(peer_ni, &ksocknal_data.ksnd_peers[i],
-				    ksnp_list) {
-			LASSERT(!peer_ni->ksnp_closing);
+	hash_for_each(ksocknal_data.ksnd_peers, i, peer_ni, ksnp_list) {
+		LASSERT(!peer_ni->ksnp_closing);
+
+		if (peer_ni->ksnp_ni != ni)
+			continue;
 
-			if (peer_ni->ksnp_ni != ni)
+		list_for_each_entry(conn, &peer_ni->ksnp_conns,
+				    ksnc_list) {
+			if (index-- > 0)
 				continue;
 
-			list_for_each_entry(conn, &peer_ni->ksnp_conns,
-					    ksnc_list) {
-				if (index-- > 0)
-					continue;
-
-				ksocknal_conn_addref(conn);
-				read_unlock(&ksocknal_data.ksnd_global_lock);
-				return conn;
-			}
+			ksocknal_conn_addref(conn);
+			read_unlock(&ksocknal_data.ksnd_global_lock);
+			return conn;
 		}
 	}
 
@@ -1119,8 +1112,8 @@ struct ksock_peer_ni *
 			 * NB this puts an "empty" peer_ni in the peer
 			 * table (which takes my ref)
 			 */
-			list_add_tail(&peer_ni->ksnp_list,
-				      ksocknal_nid2peerlist(peerid.nid));
+			hash_add(ksocknal_data.ksnd_peers,
+				 &peer_ni->ksnp_list, peerid.nid);
 		} else {
 			ksocknal_peer_decref(peer_ni);
 			peer_ni = peer2;
@@ -1732,7 +1725,7 @@ struct ksock_peer_ni *
 ksocknal_close_matching_conns(struct lnet_process_id id, u32 ipaddr)
 {
 	struct ksock_peer_ni *peer_ni;
-	struct ksock_peer_ni *pnxt;
+	struct hlist_node *pnxt;
 	int lo;
 	int hi;
 	int i;
@@ -1741,17 +1734,17 @@ struct ksock_peer_ni *
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	if (id.nid != LNET_NID_ANY) {
-		lo = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
-		hi = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
+		lo = hash_min(id.nid, HASH_BITS(ksocknal_data.ksnd_peers));
+		hi = lo;
 	} else {
 		lo = 0;
-		hi = ksocknal_data.ksnd_peer_hash_size - 1;
+		hi = HASH_SIZE(ksocknal_data.ksnd_peers) - 1;
 	}
 
 	for (i = lo; i <= hi; i++) {
-		list_for_each_entry_safe(peer_ni, pnxt,
-					 &ksocknal_data.ksnd_peers[i],
-					 ksnp_list) {
+		hlist_for_each_entry_safe(peer_ni, pnxt,
+					  &ksocknal_data.ksnd_peers[i],
+					  ksnp_list) {
 			if (!((id.nid == LNET_NID_ANY ||
 			       id.nid == peer_ni->ksnp_id.nid) &&
 			      (id.pid == LNET_PID_ANY ||
@@ -1769,10 +1762,7 @@ struct ksock_peer_ni *
 	if (id.nid == LNET_NID_ANY || id.pid == LNET_PID_ANY || !ipaddr)
 		return 0;
 
-	if (!count)
-		return -ENOENT;
-	else
-		return 0;
+	return count ? 0 : -ENOENT;
 }
 
 void
@@ -1892,21 +1882,20 @@ struct ksock_peer_ni *
 
 static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 {
-	struct list_head *start;
-	struct list_head *end;
-	struct list_head *tmp;
+	int lo;
+	int hi;
+	int bkt;
 	int rc = -ENOENT;
-	unsigned int hsize = ksocknal_data.ksnd_peer_hash_size;
 
-	if (id.nid == LNET_NID_ANY) {
-		start = &ksocknal_data.ksnd_peers[0];
-		end = &ksocknal_data.ksnd_peers[hsize - 1];
+	if (id.nid != LNET_NID_ANY) {
+		lo = hash_min(id.nid, HASH_BITS(ksocknal_data.ksnd_peers));
+		hi = lo;
 	} else {
-		start = ksocknal_nid2peerlist(id.nid);
-		end = ksocknal_nid2peerlist(id.nid);
+		lo = 0;
+		hi = HASH_SIZE(ksocknal_data.ksnd_peers) - 1;
 	}
 
-	for (tmp = start; tmp <= end; tmp++) {
+	for (bkt = lo; bkt <= hi; bkt++) {
 		int peer_off; /* searching offset in peer_ni hash table */
 
 		for (peer_off = 0; ; peer_off++) {
@@ -1914,7 +1903,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			int i = 0;
 
 			read_lock(&ksocknal_data.ksnd_global_lock);
-			list_for_each_entry(peer_ni, tmp, ksnp_list) {
+			hlist_for_each_entry(peer_ni,
+					     &ksocknal_data.ksnd_peers[bkt],
+					     ksnp_list) {
 				if (!((id.nid == LNET_NID_ANY ||
 				       id.nid == peer_ni->ksnp_id.nid) &&
 				      (id.pid == LNET_PID_ANY ||
@@ -1969,24 +1960,15 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		iface->ksni_nroutes = 0;
 		iface->ksni_npeers = 0;
 
-		for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
-			list_for_each_entry(peer_ni,
-					    &ksocknal_data.ksnd_peers[i],
-					    ksnp_list) {
-
-				for (j = 0;
-				     j < peer_ni->ksnp_n_passive_ips;
-				     j++)
-					if (peer_ni->ksnp_passive_ips[j] ==
-					    ipaddress)
-						iface->ksni_npeers++;
-
-				list_for_each_entry(route,
-						    &peer_ni->ksnp_routes,
-						    ksnr_list) {
-					if (route->ksnr_myipaddr == ipaddress)
-						iface->ksni_nroutes++;
-				}
+		hash_for_each(ksocknal_data.ksnd_peers, i, peer_ni, ksnp_list) {
+			for (j = 0; j < peer_ni->ksnp_n_passive_ips; j++)
+				if (peer_ni->ksnp_passive_ips[j] == ipaddress)
+					iface->ksni_npeers++;
+
+			list_for_each_entry(route, &peer_ni->ksnp_routes,
+					    ksnr_list) {
+				if (route->ksnr_myipaddr == ipaddress)
+					iface->ksni_nroutes++;
 			}
 		}
 
@@ -2048,7 +2030,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct ksock_net *net = ni->ni_data;
 	int rc = -ENOENT;
-	struct ksock_peer_ni *nxt;
+	struct hlist_node *nxt;
 	struct ksock_peer_ni *peer_ni;
 	u32 this_ip;
 	int i;
@@ -2070,16 +2052,12 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 		net->ksnn_ninterfaces--;
 
-		for (j = 0; j < ksocknal_data.ksnd_peer_hash_size; j++) {
-			list_for_each_entry_safe(peer_ni, nxt,
-						 &ksocknal_data.ksnd_peers[j],
-						 ksnp_list) {
-				if (peer_ni->ksnp_ni != ni)
-					continue;
+		hash_for_each_safe(ksocknal_data.ksnd_peers, j,
+				   nxt, peer_ni, ksnp_list) {
+			if (peer_ni->ksnp_ni != ni)
+				continue;
 
-				ksocknal_peer_del_interface_locked(peer_ni,
-								   this_ip);
-			}
+			ksocknal_peer_del_interface_locked(peer_ni, this_ip);
 		}
 	}
 
@@ -2224,8 +2202,6 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	if (ksocknal_data.ksnd_schedulers)
 		cfs_percpt_free(ksocknal_data.ksnd_schedulers);
 
-	kvfree(ksocknal_data.ksnd_peers);
-
 	spin_lock(&ksocknal_data.ksnd_tx_lock);
 
 	if (!list_empty(&ksocknal_data.ksnd_idle_noop_txs)) {
@@ -2250,6 +2226,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 ksocknal_base_shutdown(void)
 {
 	struct ksock_sched *sched;
+	struct ksock_peer_ni *peer_ni;
 	int i;
 
 	LASSERT(!ksocknal_data.ksnd_nnets);
@@ -2260,9 +2237,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		/* fall through */
 	case SOCKNAL_INIT_ALL:
 	case SOCKNAL_INIT_DATA:
-		LASSERT(ksocknal_data.ksnd_peers);
-		for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++)
-			LASSERT(list_empty(&ksocknal_data.ksnd_peers[i]));
+		hash_for_each(ksocknal_data.ksnd_peers, i, peer_ni, ksnp_list)
+			LASSERT(0);
 
 		LASSERT(list_empty(&ksocknal_data.ksnd_nets));
 		LASSERT(list_empty(&ksocknal_data.ksnd_enomem_conns));
@@ -2326,15 +2302,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 	memset(&ksocknal_data, 0, sizeof(ksocknal_data)); /* zero pointers */
 
-	ksocknal_data.ksnd_peer_hash_size = SOCKNAL_PEER_HASH_SIZE;
-	ksocknal_data.ksnd_peers = kvmalloc_array(ksocknal_data.ksnd_peer_hash_size,
-						  sizeof(struct list_head),
-						  GFP_KERNEL);
-	if (!ksocknal_data.ksnd_peers)
-		return -ENOMEM;
-
-	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++)
-		INIT_LIST_HEAD(&ksocknal_data.ksnd_peers[i]);
+	hash_init(ksocknal_data.ksnd_peers);
 
 	rwlock_init(&ksocknal_data.ksnd_global_lock);
 	INIT_LIST_HEAD(&ksocknal_data.ksnd_nets);
@@ -2452,43 +2420,38 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
-	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
-		list_for_each_entry(peer_ni, &ksocknal_data.ksnd_peers[i],
-				    ksnp_list) {
-			struct ksock_route *route;
-			struct ksock_conn *conn;
-
-			if (peer_ni->ksnp_ni != ni)
-				continue;
+	hash_for_each(ksocknal_data.ksnd_peers, i, peer_ni, ksnp_list) {
+		struct ksock_route *route;
+		struct ksock_conn *conn;
 
-			CWARN("Active peer_ni on shutdown: %s, ref %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
-			      libcfs_id2str(peer_ni->ksnp_id),
-			      atomic_read(&peer_ni->ksnp_refcount),
-			      peer_ni->ksnp_closing,
-			      peer_ni->ksnp_accepting, peer_ni->ksnp_error,
-			      peer_ni->ksnp_zc_next_cookie,
-			      !list_empty(&peer_ni->ksnp_tx_queue),
-			      !list_empty(&peer_ni->ksnp_zc_req_list));
+		if (peer_ni->ksnp_ni != ni)
+			continue;
 
-			list_for_each_entry(route, &peer_ni->ksnp_routes,
-					    ksnr_list) {
-				CWARN("Route: ref %d, schd %d, conn %d, cnted %d, del %d\n",
-				      atomic_read(&route->ksnr_refcount),
-				      route->ksnr_scheduled,
-				      route->ksnr_connecting,
-				      route->ksnr_connected,
-				      route->ksnr_deleted);
-			}
+		CWARN("Active peer_ni on shutdown: %s, ref %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
+		      libcfs_id2str(peer_ni->ksnp_id),
+		      atomic_read(&peer_ni->ksnp_refcount),
+		      peer_ni->ksnp_closing,
+		      peer_ni->ksnp_accepting, peer_ni->ksnp_error,
+		      peer_ni->ksnp_zc_next_cookie,
+		      !list_empty(&peer_ni->ksnp_tx_queue),
+		      !list_empty(&peer_ni->ksnp_zc_req_list));
+
+		list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
+			CWARN("Route: ref %d, schd %d, conn %d, cnted %d, del %d\n",
+			      atomic_read(&route->ksnr_refcount),
+			      route->ksnr_scheduled,
+			      route->ksnr_connecting,
+			      route->ksnr_connected,
+			      route->ksnr_deleted);
+		}
 
-			list_for_each_entry(conn, &peer_ni->ksnp_conns,
-					    ksnc_list) {
-				CWARN("Conn: ref %d, sref %d, t %d, c %d\n",
-				      atomic_read(&conn->ksnc_conn_refcount),
-				      atomic_read(&conn->ksnc_sock_refcount),
-				      conn->ksnc_type, conn->ksnc_closing);
-			}
-			goto done;
+		list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
+			CWARN("Conn: ref %d, sref %d, t %d, c %d\n",
+			      atomic_read(&conn->ksnc_conn_refcount),
+			      atomic_read(&conn->ksnc_sock_refcount),
+			      conn->ksnc_type, conn->ksnc_closing);
 		}
+		goto done;
 	}
 done:
 	read_unlock(&ksocknal_data.ksnd_global_lock);
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 2d4e8d59..9ebb959 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -43,7 +43,7 @@
 #include <linux/sysctl.h>
 #include <linux/uio.h>
 #include <linux/unistd.h>
-#include <asm/irq.h>
+#include <linux/hashtable.h>
 #include <net/sock.h>
 #include <net/tcp.h>
 
@@ -54,7 +54,7 @@
 #define SOCKNAL_NSCHEDS		3
 #define SOCKNAL_NSCHEDS_HIGH	(SOCKNAL_NSCHEDS << 1)
 
-#define SOCKNAL_PEER_HASH_SIZE	101   /* # peer_ni lists */
+#define SOCKNAL_PEER_HASH_BITS	7     /* # log2 of # of peer_ni lists */
 #define SOCKNAL_RESCHED		100   /* # scheduler loops before reschedule */
 #define SOCKNAL_INSANITY_RECONN	5000  /* connd is trying on reconn infinitely */
 #define SOCKNAL_ENOMEM_RETRY	1     /* seconds between retries */
@@ -190,10 +190,10 @@ struct ksock_nal_data {
 	rwlock_t		ksnd_global_lock;	/* stabilize
 							 * peer_ni/conn ops
 							 */
-	struct list_head	*ksnd_peers;		/* hash table of all my
+	DECLARE_HASHTABLE(ksnd_peers, SOCKNAL_PEER_HASH_BITS);
+							/* hash table of all my
 							 * known peers
 							 */
-	int			ksnd_peer_hash_size;	/* size of ksnd_peers */
 
 	int			ksnd_nthreads;		/* # live threads */
 	int			ksnd_shuttingdown;	/* tell threads to exit
@@ -411,7 +411,7 @@ struct ksock_route {
 #define SOCKNAL_KEEPALIVE_PING	1	/* cookie for keepalive ping */
 
 struct ksock_peer_ni {
-	struct list_head	ksnp_list;		/* stash on global peer_ni list */
+	struct hlist_node	ksnp_list;		/* on global peer_nis hash table */
 	time64_t		ksnp_last_alive;	/* when (in seconds) I was last
 							 * alive
 							 */
@@ -519,14 +519,6 @@ struct ksock_proto {
 		(1 << SOCKLND_CONN_BULK_OUT));
 }
 
-static inline struct list_head *
-ksocknal_nid2peerlist(lnet_nid_t nid)
-{
-	unsigned int hash = ((unsigned int)nid) % ksocknal_data.ksnd_peer_hash_size;
-
-	return &ksocknal_data.ksnd_peers[hash];
-}
-
 static inline void
 ksocknal_conn_addref(struct ksock_conn *conn)
 {
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 996b231..fb933e3 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -2386,7 +2386,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 static void
 ksocknal_check_peer_timeouts(int idx)
 {
-	struct list_head *peers = &ksocknal_data.ksnd_peers[idx];
+	struct hlist_head *peers = &ksocknal_data.ksnd_peers[idx];
 	struct ksock_peer_ni *peer_ni;
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
@@ -2399,7 +2399,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	 */
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
-	list_for_each_entry(peer_ni, peers, ksnp_list) {
+	hlist_for_each_entry(peer_ni, peers, ksnp_list) {
 		struct ksock_tx *tx_stale;
 		time64_t deadline = 0;
 		int resid = 0;
@@ -2564,7 +2564,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		while ((timeout = deadline - ktime_get_seconds()) <= 0) {
 			const int n = 4;
 			const int p = 1;
-			int chunk = ksocknal_data.ksnd_peer_hash_size;
+			int chunk = HASH_SIZE(ksocknal_data.ksnd_peers);
 			unsigned int lnd_timeout;
 
 			/*
@@ -2585,7 +2585,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			for (i = 0; i < chunk; i++) {
 				ksocknal_check_peer_timeouts(peer_index);
 				peer_index = (peer_index + 1) %
-					     ksocknal_data.ksnd_peer_hash_size;
+					     HASH_SIZE(ksocknal_data.ksnd_peers);
 			}
 
 			deadline += p;
-- 
1.8.3.1
