Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DA77C433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:12 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B9F316124B
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9F316124B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E1F5421F82F;
	Sun, 25 Apr 2021 13:08:59 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4861421F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:43 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1386010084F6;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0777369A90; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:13 -0400
Message-Id: <1619381316-7719-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/29] lnet: socklnd: replace route construct
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

With TCP bonding removed, it's no longer necessary to
maintain multiple route constructs per peer_ni in socklnd.
Replace the route construct with connection control block,
conn_cb, and make sure there's a single conn_cb per peer_ni.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13641
Lustre-commit: 7766f01e891c378d ("LU-13641 socklnd: replace route construct")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40774
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c    | 367 +++++++++++++++---------------------
 net/lnet/klnds/socklnd/socklnd.h    |  38 ++--
 net/lnet/klnds/socklnd/socklnd_cb.c | 200 ++++++++++----------
 3 files changed, 273 insertions(+), 332 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 55d1ba5..141da88 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -112,40 +112,40 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 	return ret;
 }
 
-static struct ksock_route *
-ksocknal_create_route(struct sockaddr *addr)
+static struct ksock_conn_cb *
+ksocknal_create_conn_cb(struct sockaddr *addr)
 {
-	struct ksock_route *route;
+	struct ksock_conn_cb *conn_cb;
 
-	route = kzalloc(sizeof(*route), GFP_NOFS);
-	if (!route)
+	conn_cb = kzalloc(sizeof(*conn_cb), GFP_NOFS);
+	if (!conn_cb)
 		return NULL;
 
-	refcount_set(&route->ksnr_refcount, 1);
-	route->ksnr_peer = NULL;
-	route->ksnr_retry_interval = 0;		/* OK to connect at any time */
-	rpc_copy_addr((struct sockaddr *)&route->ksnr_addr, addr);
-	rpc_set_port((struct sockaddr *)&route->ksnr_addr, rpc_get_port(addr));
-	route->ksnr_myiface = -1;
-	route->ksnr_scheduled = 0;
-	route->ksnr_connecting = 0;
-	route->ksnr_connected = 0;
-	route->ksnr_deleted = 0;
-	route->ksnr_conn_count = 0;
-	route->ksnr_share_count = 0;
-
-	return route;
+	refcount_set(&conn_cb->ksnr_refcount, 1);
+	conn_cb->ksnr_peer = NULL;
+	conn_cb->ksnr_retry_interval = 0;	/* OK to connect at any time */
+	rpc_copy_addr((struct sockaddr *)&conn_cb->ksnr_addr, addr);
+	rpc_set_port((struct sockaddr *)&conn_cb->ksnr_addr,
+		     rpc_get_port(addr));
+	conn_cb->ksnr_myiface = -1;
+	conn_cb->ksnr_scheduled = 0;
+	conn_cb->ksnr_connecting = 0;
+	conn_cb->ksnr_connected = 0;
+	conn_cb->ksnr_deleted = 0;
+	conn_cb->ksnr_conn_count = 0;
+
+	return conn_cb;
 }
 
 void
-ksocknal_destroy_route(struct ksock_route *route)
+ksocknal_destroy_conn_cb(struct ksock_conn_cb *conn_cb)
 {
-	LASSERT(!refcount_read(&route->ksnr_refcount));
+	LASSERT(refcount_read(&conn_cb->ksnr_refcount) == 0);
 
-	if (route->ksnr_peer)
-		ksocknal_peer_decref(route->ksnr_peer);
+	if (conn_cb->ksnr_peer)
+		ksocknal_peer_decref(conn_cb->ksnr_peer);
 
-	kfree(route);
+	kfree(conn_cb);
 }
 
 static struct ksock_peer_ni *
@@ -178,9 +178,9 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 	peer_ni->ksnp_proto = NULL;
 	peer_ni->ksnp_last_alive = 0;
 	peer_ni->ksnp_zc_next_cookie = SOCKNAL_KEEPALIVE_PING + 1;
+	peer_ni->ksnp_conn_cb = NULL;
 
 	INIT_LIST_HEAD(&peer_ni->ksnp_conns);
-	INIT_LIST_HEAD(&peer_ni->ksnp_routes);
 	INIT_LIST_HEAD(&peer_ni->ksnp_tx_queue);
 	INIT_LIST_HEAD(&peer_ni->ksnp_zc_req_list);
 	spin_lock_init(&peer_ni->ksnp_lock);
@@ -199,17 +199,16 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 	LASSERT(!refcount_read(&peer_ni->ksnp_refcount));
 	LASSERT(!peer_ni->ksnp_accepting);
 	LASSERT(list_empty(&peer_ni->ksnp_conns));
-	LASSERT(list_empty(&peer_ni->ksnp_routes));
+	LASSERT(!peer_ni->ksnp_conn_cb);
 	LASSERT(list_empty(&peer_ni->ksnp_tx_queue));
 	LASSERT(list_empty(&peer_ni->ksnp_zc_req_list));
 
 	kfree(peer_ni);
 
-	/*
-	 * NB a peer_ni's connections and routes keep a reference on their peer
-	 * until they are destroyed, so we can be assured that _all_ state to
-	 * do with this peer_ni has been cleaned up when its refcount drops to
-	 * zero.
+	/* NB a peer_ni's connections and conn_cb keep a reference on their
+	 * peer until they are destroyed, so we can be assured that _all_
+	 * state to do with this peer_ni has been cleaned up when its refcount
+	 * drops to zero.
 	 */
 	if (atomic_dec_and_test(&net->ksnn_npeers))
 		wake_up_var(&net->ksnn_npeers);
@@ -279,7 +278,7 @@ struct ksock_peer_ni *
 	}
 
 	LASSERT(list_empty(&peer_ni->ksnp_conns));
-	LASSERT(list_empty(&peer_ni->ksnp_routes));
+	LASSERT(!peer_ni->ksnp_conn_cb);
 	LASSERT(!peer_ni->ksnp_closing);
 	peer_ni->ksnp_closing = 1;
 	hlist_del(&peer_ni->ksnp_list);
@@ -293,7 +292,7 @@ struct ksock_peer_ni *
 		       int *port, int *conn_count, int *share_count)
 {
 	struct ksock_peer_ni *peer_ni;
-	struct ksock_route *route;
+	struct ksock_conn_cb *conn_cb;
 	int i;
 	int j;
 	int rc = -ENOENT;
@@ -305,7 +304,7 @@ struct ksock_peer_ni *
 			continue;
 
 		if (!peer_ni->ksnp_n_passive_ips &&
-		    list_empty(&peer_ni->ksnp_routes)) {
+		    !peer_ni->ksnp_conn_cb) {
 			if (index-- > 0)
 				continue;
 
@@ -333,18 +332,19 @@ struct ksock_peer_ni *
 			goto out;
 		}
 
-		list_for_each_entry(route, &peer_ni->ksnp_routes,
-				    ksnr_list) {
+		if (peer_ni->ksnp_conn_cb) {
 			if (index-- > 0)
 				continue;
 
+			conn_cb = peer_ni->ksnp_conn_cb;
+
 			*id = peer_ni->ksnp_id;
-			if (route->ksnr_addr.ss_family == AF_INET) {
+			if (conn_cb->ksnr_addr.ss_family == AF_INET) {
 				struct sockaddr_in *sa;
 
-				sa = (void *)&route->ksnr_addr;
+				sa = (void *)&conn_cb->ksnr_addr;
 				rc = choose_ipv4_src(myip,
-						     route->ksnr_myiface,
+						     conn_cb->ksnr_myiface,
 						     ntohl(sa->sin_addr.s_addr),
 						     ni->ni_net_ns);
 				*peer_ip = ntohl(sa->sin_addr.s_addr);
@@ -355,8 +355,8 @@ struct ksock_peer_ni *
 				*port = 0;
 				rc = -ENOTSUPP;
 			}
-			*conn_count = route->ksnr_conn_count;
-			*share_count = route->ksnr_share_count;
+			*conn_count = conn_cb->ksnr_conn_count;
+			*share_count = 1;
 			goto out;
 		}
 	}
@@ -366,133 +366,121 @@ struct ksock_peer_ni *
 }
 
 static void
-ksocknal_associate_route_conn_locked(struct ksock_route *route,
-				     struct ksock_conn *conn)
+ksocknal_associate_cb_conn_locked(struct ksock_conn_cb *conn_cb,
+				  struct ksock_conn *conn)
 {
-	struct ksock_peer_ni *peer_ni = route->ksnr_peer;
+	struct ksock_peer_ni *peer_ni = conn_cb->ksnr_peer;
 	int type = conn->ksnc_type;
 	struct ksock_interface *iface;
 	int conn_iface;
 
 	conn_iface = ksocknal_ip2index((struct sockaddr *)&conn->ksnc_myaddr,
-				       route->ksnr_peer->ksnp_ni);
-	conn->ksnc_route = route;
-	ksocknal_route_addref(route);
-
-	if (route->ksnr_myiface != conn_iface) {
-		if (route->ksnr_myiface < 0) {
-			/* route wasn't bound locally yet (the initial route) */
+				       peer_ni->ksnp_ni);
+	conn->ksnc_conn_cb = conn_cb;
+	ksocknal_conn_cb_addref(conn_cb);
+
+	if (conn_cb->ksnr_myiface != conn_iface) {
+		if (conn_cb->ksnr_myiface < 0) {
+			/* conn_cb wasn't bound locally yet (the initial
+			 * conn_cb)
+			 */
 			CDEBUG(D_NET, "Binding %s %pIS to interface %d\n",
 			       libcfs_id2str(peer_ni->ksnp_id),
-			       &route->ksnr_addr,
+			       &conn_cb->ksnr_addr,
 			       conn_iface);
 		} else {
 			CDEBUG(D_NET,
 			       "Rebinding %s %pIS from interface %d to %d\n",
 			       libcfs_id2str(peer_ni->ksnp_id),
-			       &route->ksnr_addr,
-			       route->ksnr_myiface,
+			       &conn_cb->ksnr_addr,
+			       conn_cb->ksnr_myiface,
 			       conn_iface);
 
-			iface = ksocknal_index2iface(route->ksnr_peer->ksnp_ni,
-						     route->ksnr_myiface);
+			iface = ksocknal_index2iface(peer_ni->ksnp_ni,
+						     conn_cb->ksnr_myiface);
 			if (iface)
 				iface->ksni_nroutes--;
 		}
-		route->ksnr_myiface = conn_iface;
-		iface = ksocknal_index2iface(route->ksnr_peer->ksnp_ni,
-					     route->ksnr_myiface);
+		conn_cb->ksnr_myiface = conn_iface;
+		iface = ksocknal_index2iface(peer_ni->ksnp_ni,
+					     conn_cb->ksnr_myiface);
 		if (iface)
 			iface->ksni_nroutes++;
 	}
 
-	route->ksnr_connected |= (1 << type);
-	route->ksnr_conn_count++;
+	conn_cb->ksnr_connected |= (1 << type);
+	conn_cb->ksnr_conn_count++;
 
-	/*
-	 * Successful connection => further attempts can
+	/* Successful connection => further attempts can
 	 * proceed immediately
 	 */
-	route->ksnr_retry_interval = 0;
+	conn_cb->ksnr_retry_interval = 0;
 }
 
 static void
-ksocknal_add_route_locked(struct ksock_peer_ni *peer_ni, struct ksock_route *route)
+ksocknal_add_conn_cb_locked(struct ksock_peer_ni *peer_ni,
+			    struct ksock_conn_cb *conn_cb)
 {
 	struct ksock_conn *conn;
-	struct ksock_route *route2;
 	struct ksock_net *net = peer_ni->ksnp_ni->ni_data;
 
 	LASSERT(!peer_ni->ksnp_closing);
-	LASSERT(!route->ksnr_peer);
-	LASSERT(!route->ksnr_scheduled);
-	LASSERT(!route->ksnr_connecting);
-	LASSERT(!route->ksnr_connected);
-
-	/* LASSERT(unique) */
-	list_for_each_entry(route2, &peer_ni->ksnp_routes, ksnr_list) {
-		if (rpc_cmp_addr((struct sockaddr *)&route2->ksnr_addr,
-				 (struct sockaddr *)&route->ksnr_addr)) {
-			CERROR("Duplicate route %s %pIS\n",
-			       libcfs_id2str(peer_ni->ksnp_id),
-			       &route->ksnr_addr);
-			LBUG();
-		}
-	}
+	LASSERT(!conn_cb->ksnr_peer);
+	LASSERT(!conn_cb->ksnr_scheduled);
+	LASSERT(!conn_cb->ksnr_connecting);
+	LASSERT(!conn_cb->ksnr_connected);
 
-	route->ksnr_peer = peer_ni;
+	conn_cb->ksnr_peer = peer_ni;
 	ksocknal_peer_addref(peer_ni);
 
-	/* set the route's interface to the current net's interface */
-	route->ksnr_myiface = net->ksnn_interface.ksni_index;
+	/* set the conn_cb's interface to the current net's interface */
+	conn_cb->ksnr_myiface = net->ksnn_interface.ksni_index;
 	net->ksnn_interface.ksni_nroutes++;
 
-	/* peer_ni's routelist takes over my ref on 'route' */
-	list_add_tail(&route->ksnr_list, &peer_ni->ksnp_routes);
+	/* peer_ni's route list takes over my ref on 'route' */
+	peer_ni->ksnp_conn_cb = conn_cb;
 
 	list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
 		if (!rpc_cmp_addr((struct sockaddr *)&conn->ksnc_peeraddr,
-				  (struct sockaddr *)&route->ksnr_addr))
+				  (struct sockaddr *)&conn_cb->ksnr_addr))
 			continue;
 
-		ksocknal_associate_route_conn_locked(route, conn);
-		/* keep going (typed routes) */
+		ksocknal_associate_cb_conn_locked(conn_cb, conn);
+		/* keep going (typed conns) */
 	}
 }
 
 static void
-ksocknal_del_route_locked(struct ksock_route *route)
+ksocknal_del_conn_cb_locked(struct ksock_conn_cb *conn_cb)
 {
-	struct ksock_peer_ni *peer_ni = route->ksnr_peer;
+	struct ksock_peer_ni *peer_ni = conn_cb->ksnr_peer;
 	struct ksock_interface *iface;
 	struct ksock_conn *conn;
 	struct ksock_conn *cnxt;
 
-	LASSERT(!route->ksnr_deleted);
+	LASSERT(!conn_cb->ksnr_deleted);
 
 	/* Close associated conns */
 	list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns, ksnc_list) {
-		if (conn->ksnc_route != route)
+		if (conn->ksnc_conn_cb != conn_cb)
 			continue;
 
 		ksocknal_close_conn_locked(conn, 0);
 	}
 
-	if (route->ksnr_myiface >= 0) {
-		iface = ksocknal_index2iface(route->ksnr_peer->ksnp_ni,
-					     route->ksnr_myiface);
+	if (conn_cb->ksnr_myiface >= 0) {
+		iface = ksocknal_index2iface(peer_ni->ksnp_ni,
+					     conn_cb->ksnr_myiface);
 		if (iface)
 			iface->ksni_nroutes--;
 	}
 
-	route->ksnr_deleted = 1;
-	list_del(&route->ksnr_list);
-	ksocknal_route_decref(route);		/* drop peer_ni's ref */
+	conn_cb->ksnr_deleted = 1;
+	ksocknal_conn_cb_decref(conn_cb);	/* drop peer_ni's ref */
+	peer_ni->ksnp_conn_cb = NULL;
 
-	if (list_empty(&peer_ni->ksnp_routes) &&
-	    list_empty(&peer_ni->ksnp_conns)) {
-		/*
-		 * I've just removed the last route to a peer_ni with no active
+	if (list_empty(&peer_ni->ksnp_conns)) {
+		/* I've just removed the last route to a peer_ni with no active
 		 * connections
 		 */
 		ksocknal_unlink_peer_locked(peer_ni);
@@ -505,8 +493,7 @@ struct ksock_peer_ni *
 {
 	struct ksock_peer_ni *peer_ni;
 	struct ksock_peer_ni *peer2;
-	struct ksock_route *route;
-	struct ksock_route *route2;
+	struct ksock_conn_cb *conn_cb;
 	struct sockaddr_in sa = {.sin_family = AF_INET};
 
 	if (id.nid == LNET_NID_ANY ||
@@ -520,8 +507,8 @@ struct ksock_peer_ni *
 
 	sa.sin_addr.s_addr = htonl(ipaddr);
 	sa.sin_port = htons(port);
-	route = ksocknal_create_route((struct sockaddr *)&sa);
-	if (!route) {
+	conn_cb = ksocknal_create_conn_cb((struct sockaddr *)&sa);
+	if (!conn_cb) {
 		ksocknal_peer_decref(peer_ni);
 		return -ENOMEM;
 	}
@@ -540,20 +527,8 @@ struct ksock_peer_ni *
 		hash_add(ksocknal_data.ksnd_peers, &peer_ni->ksnp_list, id.nid);
 	}
 
-	list_for_each_entry(route2, &peer_ni->ksnp_routes, ksnr_list) {
-		struct sockaddr_in *sa = (void *)&route->ksnr_addr;
+	ksocknal_add_conn_cb_locked(peer_ni, conn_cb);
 
-		if (ipaddr != ntohl(sa->sin_addr.s_addr)) {
-			/* Route already exists, use the old one */
-			ksocknal_route_decref(route);
-			route2->ksnr_share_count++;
-			goto out;
-		}
-	}
-	/* Route doesn't already exist, add the new one */
-	ksocknal_add_route_locked(peer_ni, route);
-	route->ksnr_share_count++;
-out:
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
 	return 0;
@@ -564,50 +539,22 @@ struct ksock_peer_ni *
 {
 	struct ksock_conn *conn;
 	struct ksock_conn *cnxt;
-	struct ksock_route *route;
-	struct ksock_route *rnxt;
-	int nshared;
+	struct ksock_conn_cb *conn_cb;
 
 	LASSERT(!peer_ni->ksnp_closing);
 
 	/* Extra ref prevents peer_ni disappearing until I'm done with it */
 	ksocknal_peer_addref(peer_ni);
+	conn_cb = peer_ni->ksnp_conn_cb;
+	if (conn_cb)
+		ksocknal_del_conn_cb_locked(conn_cb);
 
-	list_for_each_entry_safe(route, rnxt, &peer_ni->ksnp_routes,
-				 ksnr_list) {
-		struct sockaddr_in *sa = (void *)&route->ksnr_addr;
-
-		/* no match */
-		if (!(!ip || ntohl(sa->sin_addr.s_addr) == ip))
-			continue;
-
-		route->ksnr_share_count = 0;
-		/* This deletes associated conns too */
-		ksocknal_del_route_locked(route);
-	}
-
-	nshared = 0;
-	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list)
-		nshared += route->ksnr_share_count;
-
-	if (!nshared) {
-		/* remove everything else if there are no explicit entries
-		 * left
-		 */
-		list_for_each_entry_safe(route, rnxt, &peer_ni->ksnp_routes,
-					 ksnr_list) {
-			/* we should only be removing auto-entries */
-			LASSERT(!route->ksnr_share_count);
-			ksocknal_del_route_locked(route);
-		}
-
-		list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns,
-					 ksnc_list)
-			ksocknal_close_conn_locked(conn, 0);
-	}
+	list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns,
+				 ksnc_list)
+		ksocknal_close_conn_locked(conn, 0);
 
 	ksocknal_peer_decref(peer_ni);
-	/* NB peer_ni unlinks itself when last conn/route is removed */
+	/* NB peer_ni unlinks itself when last conn/conn_cb is removed */
 }
 
 static int
@@ -651,7 +598,7 @@ struct ksock_peer_ni *
 			if (peer_ni->ksnp_closing &&
 			    !list_empty(&peer_ni->ksnp_tx_queue)) {
 				LASSERT(list_empty(&peer_ni->ksnp_conns));
-				LASSERT(list_empty(&peer_ni->ksnp_routes));
+				LASSERT(!peer_ni->ksnp_conn_cb);
 
 				list_splice_init(&peer_ni->ksnp_tx_queue,
 						 &zombies);
@@ -753,19 +700,16 @@ struct ksock_peer_ni *
 }
 
 static int
-ksocknal_connecting(struct ksock_peer_ni *peer_ni, struct sockaddr *sa)
+ksocknal_connecting(struct ksock_conn_cb *conn_cb, struct sockaddr *sa)
 {
-	struct ksock_route *route;
-
-	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
-		if (rpc_cmp_addr((struct sockaddr *)&route->ksnr_addr, sa))
-			return route->ksnr_connecting;
-	}
+	if (conn_cb &&
+	    rpc_cmp_addr((struct sockaddr *)&conn_cb->ksnr_addr, sa))
+		return conn_cb->ksnr_connecting;
 	return 0;
 }
 
 int
-ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
+ksocknal_create_conn(struct lnet_ni *ni, struct ksock_conn_cb *conn_cb,
 		     struct socket *sock, int type)
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
@@ -787,7 +731,7 @@ struct ksock_peer_ni *
 	int active;
 	char *warn = NULL;
 
-	active = !!route;
+	active = !!conn_cb;
 
 	LASSERT(active == (type != SOCKLND_CONN_NONE));
 
@@ -798,7 +742,7 @@ struct ksock_peer_ni *
 	}
 
 	conn->ksnc_peer = NULL;
-	conn->ksnc_route = NULL;
+	conn->ksnc_conn_cb = NULL;
 	conn->ksnc_sock = sock;
 	/*
 	 * 2 ref, 1 for conn, another extra ref prevents socket
@@ -838,7 +782,7 @@ struct ksock_peer_ni *
 	 * eagerly
 	 */
 	if (active) {
-		peer_ni = route->ksnr_peer;
+		peer_ni = conn_cb->ksnr_peer;
 		LASSERT(ni == peer_ni->ksnp_ni);
 
 		/* Active connection sends HELLO eagerly */
@@ -917,8 +861,8 @@ struct ksock_peer_ni *
 		 * favour of higher NID...
 		 */
 		if (peerid.nid < ni->ni_nid &&
-		    ksocknal_connecting(peer_ni, ((struct sockaddr *)
-						 &conn->ksnc_peeraddr))) {
+		    ksocknal_connecting(peer_ni->ksnp_conn_cb,
+					((struct sockaddr *)&conn->ksnc_peeraddr))) {
 			rc = EALREADY;
 			warn = "connection race resolution";
 			goto failed_2;
@@ -926,10 +870,10 @@ struct ksock_peer_ni *
 	}
 
 	if (peer_ni->ksnp_closing ||
-	    (active && route->ksnr_deleted)) {
-		/* peer_ni/route got closed under me */
+	    (active && conn_cb->ksnr_deleted)) {
+		/* peer_ni/conn_cb got closed under me */
 		rc = -ESTALE;
-		warn = "peer_ni/route removed";
+		warn = "peer_ni/conn_cb removed";
 		goto failed_2;
 	}
 
@@ -998,34 +942,29 @@ struct ksock_peer_ni *
 		}
 	}
 
-	/*
-	 * If the connection created by this route didn't bind to the IP
-	 * address the route connected to, the connection/route matching
+	/* If the connection created by this conn_cb didn't bind to the IP
+	 * address the conn_cb connected to, the connection/conn_cb matching
 	 * code below probably isn't going to work.
 	 */
 	if (active &&
-	    !rpc_cmp_addr((struct sockaddr *)&route->ksnr_addr,
+	    !rpc_cmp_addr((struct sockaddr *)&conn_cb->ksnr_addr,
 			  (struct sockaddr *)&conn->ksnc_peeraddr)) {
 		CERROR("Route %s %pIS connected to %pIS\n",
 		       libcfs_id2str(peer_ni->ksnp_id),
-		       &route->ksnr_addr,
+		       &conn_cb->ksnr_addr,
 		       &conn->ksnc_peeraddr);
 	}
 
-	/*
-	 * Search for a route corresponding to the new connection and
+	/* Search for a conn_cb corresponding to the new connection and
 	 * create an association. This allows incoming connections created
-	 * by routes in my peer_ni to match my own route entries so I don't
-	 * continually create duplicate routes.
+	 * by conn_cb in my peer_ni to match my own conn_cb entries so I don't
+	 * continually create duplicate conn_cbs.
 	 */
-	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
-		if (!rpc_cmp_addr((struct sockaddr *)&route->ksnr_addr,
-				  (struct sockaddr *)&conn->ksnc_peeraddr))
-			continue;
+	conn_cb = peer_ni->ksnp_conn_cb;
 
-		ksocknal_associate_route_conn_locked(route, conn);
-		break;
-	}
+	if (conn_cb && rpc_cmp_addr((struct sockaddr *)&conn->ksnc_peeraddr,
+				    (struct sockaddr *)&conn_cb->ksnr_addr))
+		ksocknal_associate_cb_conn_locked(conn_cb, conn);
 
 	conn->ksnc_peer = peer_ni;	/* conn takes my ref on peer_ni */
 	peer_ni->ksnp_last_alive = ktime_get_seconds();
@@ -1135,7 +1074,7 @@ struct ksock_peer_ni *
 failed_2:
 	if (!peer_ni->ksnp_closing &&
 	    list_empty(&peer_ni->ksnp_conns) &&
-	    list_empty(&peer_ni->ksnp_routes)) {
+	    !peer_ni->ksnp_conn_cb) {
 		list_splice_init(&peer_ni->ksnp_tx_queue, &zombies);
 		ksocknal_unlink_peer_locked(peer_ni);
 	}
@@ -1183,6 +1122,7 @@ struct ksock_peer_ni *
 
 failed_0:
 	sock_release(sock);
+
 	return rc;
 }
 
@@ -1195,7 +1135,7 @@ struct ksock_peer_ni *
 	 * Caller holds ksnd_global_lock exclusively in irq context
 	 */
 	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
-	struct ksock_route *route;
+	struct ksock_conn_cb *conn_cb;
 	struct ksock_conn *conn2;
 
 	LASSERT(!peer_ni->ksnp_error);
@@ -1205,22 +1145,23 @@ struct ksock_peer_ni *
 	/* ksnd_deathrow_conns takes over peer_ni's ref */
 	list_del(&conn->ksnc_list);
 
-	route = conn->ksnc_route;
-	if (route) {
-		/* dissociate conn from route... */
-		LASSERT(!route->ksnr_deleted);
-		LASSERT(route->ksnr_connected & (1 << conn->ksnc_type));
+	conn_cb = conn->ksnc_conn_cb;
+	if (conn_cb) {
+		/* dissociate conn from cb... */
+		LASSERT(!conn_cb->ksnr_deleted);
+		LASSERT(conn_cb->ksnr_connected & BIT(conn->ksnc_type));
 
 		list_for_each_entry(conn2, &peer_ni->ksnp_conns, ksnc_list) {
-			if (conn2->ksnc_route == route &&
+			if (conn2->ksnc_conn_cb == conn_cb &&
 			    conn2->ksnc_type == conn->ksnc_type)
 				goto conn2_found;
 		}
-		route->ksnr_connected &= ~(1 << conn->ksnc_type);
+		conn_cb->ksnr_connected &= ~BIT(conn->ksnc_type);
 conn2_found:
-		conn->ksnc_route = NULL;
+		conn->ksnc_conn_cb = NULL;
 
-		ksocknal_route_decref(route);     /* drop conn's ref on route */
+		/* drop conn's ref on route */
+		ksocknal_conn_cb_decref(conn_cb);
 	}
 
 	if (list_empty(&peer_ni->ksnp_conns)) {
@@ -1248,10 +1189,9 @@ struct ksock_peer_ni *
 		peer_ni->ksnp_proto = NULL;  /* renegotiate protocol version */
 		peer_ni->ksnp_error = error; /* stash last conn close reason */
 
-		if (list_empty(&peer_ni->ksnp_routes)) {
-			/*
-			 * I've just closed last conn belonging to a
-			 * peer_ni with no routes to it
+		if (!peer_ni->ksnp_conn_cb) {
+			/* I've just closed last conn belonging to a
+			 * peer_ni with no connections to it
 			 */
 			ksocknal_unlink_peer_locked(peer_ni);
 		}
@@ -1282,7 +1222,7 @@ struct ksock_peer_ni *
 	if (!(peer_ni->ksnp_id.pid & LNET_PID_USERFLAG) &&
 	    list_empty(&peer_ni->ksnp_conns) &&
 	    !peer_ni->ksnp_accepting &&
-	    !ksocknal_find_connecting_route_locked(peer_ni)) {
+	    !ksocknal_find_connecting_conn_cb_locked(peer_ni)) {
 		notify = true;
 		last_alive = peer_ni->ksnp_last_alive;
 	}
@@ -1422,7 +1362,7 @@ struct ksock_peer_ni *
 	LASSERT(!refcount_read(&conn->ksnc_conn_refcount));
 	LASSERT(!refcount_read(&conn->ksnc_sock_refcount));
 	LASSERT(!conn->ksnc_sock);
-	LASSERT(!conn->ksnc_route);
+	LASSERT(!conn->ksnc_conn_cb);
 	LASSERT(!conn->ksnc_tx_scheduled);
 	LASSERT(!conn->ksnc_rx_scheduled);
 	LASSERT(list_empty(&conn->ksnc_tx_queue));
@@ -2012,7 +1952,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	hash_for_each(ksocknal_data.ksnd_peers, i, peer_ni, ksnp_list) {
-		struct ksock_route *route;
+		struct ksock_conn_cb *conn_cb;
 		struct ksock_conn *conn;
 
 		if (peer_ni->ksnp_ni != ni)
@@ -2027,13 +1967,12 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		      !list_empty(&peer_ni->ksnp_tx_queue),
 		      !list_empty(&peer_ni->ksnp_zc_req_list));
 
-		list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
-			CWARN("Route: ref %d, schd %d, conn %d, cnted %d, del %d\n",
-			      refcount_read(&route->ksnr_refcount),
-			      route->ksnr_scheduled,
-			      route->ksnr_connecting,
-			      route->ksnr_connected,
-			      route->ksnr_deleted);
+		conn_cb = peer_ni->ksnp_conn_cb;
+		if (conn_cb) {
+			CWARN("ConnCB: ref %d, schd %d, conn %d, cnted %d, del %d\n",
+			      refcount_read(&conn_cb->ksnr_refcount),
+			      conn_cb->ksnr_scheduled, conn_cb->ksnr_connecting,
+			      conn_cb->ksnr_connected, conn_cb->ksnr_deleted);
 		}
 
 		list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index e6df3ed..9f8fe8a 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -263,7 +263,7 @@ struct ksock_nal_data {
  * received into struct bio_vec fragments.
  */
 struct ksock_conn;				/* forward ref */
-struct ksock_route;				/* forward ref */
+struct ksock_conn_cb;				/* forward ref */
 struct ksock_proto;				/* forward ref */
 
 struct ksock_tx {				/* transmit packet */
@@ -302,8 +302,10 @@ struct ksock_tx {				/* transmit packet */
 
 struct ksock_conn {
 	struct ksock_peer_ni   *ksnc_peer;		/* owning peer_ni */
-	struct ksock_route     *ksnc_route;		/* owning route */
-	struct list_head	ksnc_list;		/* stash on peer_ni's conn list */
+	struct ksock_conn_cb   *ksnc_conn_cb;		/* owning conn control
+							 * block
+							 */
+	struct list_head	ksnc_list;		/* on peer_ni's conn list */
 	struct socket	       *ksnc_sock;		/* actual socket */
 	void		       *ksnc_saved_data_ready;	/* socket's original
 							 * data_ready() callback
@@ -369,8 +371,7 @@ struct ksock_conn {
 							 */
 };
 
-struct ksock_route {
-	struct list_head	ksnr_list;		/* chain on peer_ni route list */
+struct ksock_conn_cb {
 	struct list_head	ksnr_connd_list;	/* chain on ksnr_connd_routes */
 	struct ksock_peer_ni   *ksnr_peer;		/* owning peer_ni */
 	refcount_t		ksnr_refcount;		/* # users */
@@ -388,7 +389,6 @@ struct ksock_route {
 							 * type
 							 */
 	unsigned int		ksnr_deleted:1;		/* been removed from peer_ni? */
-	unsigned int		ksnr_share_count;	/* created explicitly? */
 	int			ksnr_conn_count;	/* # conns established by this
 							 * route
 							 */
@@ -415,7 +415,7 @@ struct ksock_peer_ni {
 							 * protocol
 							 */
 	struct list_head	ksnp_conns;		/* all active connections */
-	struct list_head	ksnp_routes;		/* routes */
+	struct ksock_conn_cb	*ksnp_conn_cb;		/* conn control block */
 	struct list_head	ksnp_tx_queue;		/* waiting packets */
 	spinlock_t		ksnp_lock;		/* serialize, g_lock unsafe */
 	struct list_head	ksnp_zc_req_list;	/* zero copy requests wait for
@@ -495,7 +495,7 @@ struct ksock_proto {
 #endif
 
 static inline int
-ksocknal_route_mask(void)
+ksocknal_conn_cb_mask(void)
 {
 	if (!*ksocknal_tunables.ksnd_typed_conns)
 		return (1 << SOCKLND_CONN_ANY);
@@ -564,18 +564,18 @@ struct ksock_proto {
 }
 
 static inline void
-ksocknal_route_addref(struct ksock_route *route)
+ksocknal_conn_cb_addref(struct ksock_conn_cb *conn_cb)
 {
-	refcount_inc(&route->ksnr_refcount);
+	refcount_inc(&conn_cb->ksnr_refcount);
 }
 
-void ksocknal_destroy_route(struct ksock_route *route);
+void ksocknal_destroy_conn_cb(struct ksock_conn_cb *conn_cb);
 
 static inline void
-ksocknal_route_decref(struct ksock_route *route)
+ksocknal_conn_cb_decref(struct ksock_conn_cb *conn_cb)
 {
-	if (refcount_dec_and_test(&route->ksnr_refcount))
-		ksocknal_destroy_route(route);
+	if (refcount_dec_and_test(&conn_cb->ksnr_refcount))
+		ksocknal_destroy_conn_cb(conn_cb);
 }
 
 static inline void
@@ -615,7 +615,7 @@ struct ksock_peer_ni *ksocknal_find_peer_locked(struct lnet_ni *ni,
 struct ksock_peer_ni *ksocknal_find_peer(struct lnet_ni *ni,
 				         struct lnet_process_id id);
 void ksocknal_peer_failed(struct ksock_peer_ni *peer_ni);
-int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
+int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_conn_cb *conn_cb,
 			 struct socket *sock, int type);
 void ksocknal_close_conn_locked(struct ksock_conn *conn, int why);
 void ksocknal_terminate_conn(struct ksock_conn *conn);
@@ -639,10 +639,10 @@ int ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 int ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name);
 void ksocknal_thread_fini(void);
 void ksocknal_launch_all_connections_locked(struct ksock_peer_ni *peer_ni);
-struct ksock_route *
-ksocknal_find_connectable_route_locked(struct ksock_peer_ni *peer_ni);
-struct ksock_route *
-ksocknal_find_connecting_route_locked(struct ksock_peer_ni *peer_ni);
+struct ksock_conn_cb *
+ksocknal_find_connectable_conn_cb_locked(struct ksock_peer_ni *peer_ni);
+struct ksock_conn_cb *
+ksocknal_find_connecting_conn_cb_locked(struct ksock_peer_ni *peer_ni);
 int ksocknal_new_packet(struct ksock_conn *conn, int skip);
 int ksocknal_scheduler(void *arg);
 int ksocknal_connd(void *arg);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index bfc4e2e..43658b2 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -556,19 +556,20 @@ struct ksock_tx *
 }
 
 static void
-ksocknal_launch_connection_locked(struct ksock_route *route)
+ksocknal_launch_connection_locked(struct ksock_conn_cb *conn_cb)
 {
 	/* called holding write lock on ksnd_global_lock */
-	LASSERT(!route->ksnr_scheduled);
-	LASSERT(!route->ksnr_connecting);
-	LASSERT(ksocknal_route_mask() & ~route->ksnr_connected);
+	LASSERT(!conn_cb->ksnr_scheduled);
+	LASSERT(!conn_cb->ksnr_connecting);
+	LASSERT(ksocknal_conn_cb_mask() & ~conn_cb->ksnr_connected);
 
-	route->ksnr_scheduled = 1;	/* scheduling conn for connd */
-	ksocknal_route_addref(route);	/* extra ref for connd */
+	/* scheduling conn for connd */
+	conn_cb->ksnr_scheduled = 1;
+	ksocknal_conn_cb_addref(conn_cb);
 
 	spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
 
-	list_add_tail(&route->ksnr_connd_list,
+	list_add_tail(&conn_cb->ksnr_connd_list,
 		      &ksocknal_data.ksnd_connd_routes);
 	wake_up(&ksocknal_data.ksnd_connd_waitq);
 
@@ -578,16 +579,16 @@ struct ksock_tx *
 void
 ksocknal_launch_all_connections_locked(struct ksock_peer_ni *peer_ni)
 {
-	struct ksock_route *route;
+	struct ksock_conn_cb *conn_cb;
 
 	/* called holding write lock on ksnd_global_lock */
 	for (;;) {
 		/* launch any/all connections that need it */
-		route = ksocknal_find_connectable_route_locked(peer_ni);
-		if (!route)
+		conn_cb = ksocknal_find_connectable_conn_cb_locked(peer_ni);
+		if (!conn_cb)
 			return;
 
-		ksocknal_launch_connection_locked(route);
+		ksocknal_launch_connection_locked(conn_cb);
 	}
 }
 
@@ -753,53 +754,52 @@ struct ksock_conn *
 	spin_unlock_bh(&sched->kss_lock);
 }
 
-struct ksock_route *
-ksocknal_find_connectable_route_locked(struct ksock_peer_ni *peer_ni)
+struct ksock_conn_cb *
+ksocknal_find_connectable_conn_cb_locked(struct ksock_peer_ni *peer_ni)
 {
 	time64_t now = ktime_get_seconds();
-	struct ksock_route *route;
+	struct ksock_conn_cb *conn_cb;
 
-	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
-		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
+	conn_cb = peer_ni->ksnp_conn_cb;
+	if (!conn_cb)
+		return NULL;
 
-		/* connections being established */
-		if (route->ksnr_scheduled)
-			continue;
+	LASSERT(!conn_cb->ksnr_connecting || conn_cb->ksnr_scheduled);
 
-		/* all route types connected ? */
-		if (!(ksocknal_route_mask() & ~route->ksnr_connected))
-			continue;
+	/* connections being established */
+	if (conn_cb->ksnr_scheduled)
+		return NULL;
 
-		if (!(!route->ksnr_retry_interval || /* first attempt */
-		      now >= route->ksnr_timeout)) {
-			CDEBUG(D_NET,
-			       "Too soon to retry route %pIS (cnted %d, interval %lld, %lld secs later)\n",
-			       &route->ksnr_addr,
-			       route->ksnr_connected,
-			       route->ksnr_retry_interval,
-			       route->ksnr_timeout - now);
-			continue;
-		}
+	/* all conn types connected ? */
+	if (!(ksocknal_conn_cb_mask() & ~conn_cb->ksnr_connected))
+		return NULL;
 
-		return route;
+	if (!(conn_cb->ksnr_retry_interval == 0 || /* first attempt */
+	      now >= conn_cb->ksnr_timeout)) {
+		CDEBUG(D_NET,
+		       "Too soon to retry route %pIS (cnted %d, interval %lld, %lld secs later)\n",
+		       &conn_cb->ksnr_addr,
+		       conn_cb->ksnr_connected,
+		       conn_cb->ksnr_retry_interval,
+		       conn_cb->ksnr_timeout - now);
+		return NULL;
 	}
 
-	return NULL;
+	return conn_cb;
 }
 
-struct ksock_route *
-ksocknal_find_connecting_route_locked(struct ksock_peer_ni *peer_ni)
+struct ksock_conn_cb *
+ksocknal_find_connecting_conn_cb_locked(struct ksock_peer_ni *peer_ni)
 {
-	struct ksock_route *route;
+	struct ksock_conn_cb *conn_cb;
 
-	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list) {
-		LASSERT(!route->ksnr_connecting || route->ksnr_scheduled);
+	conn_cb = peer_ni->ksnp_conn_cb;
+	if (!conn_cb)
+		return NULL;
 
-		if (route->ksnr_scheduled)
-			return route;
-	}
+	LASSERT(!conn_cb->ksnr_connecting || conn_cb->ksnr_scheduled);
 
-	return NULL;
+	return conn_cb->ksnr_scheduled ? conn_cb : NULL;
 }
 
 int
@@ -820,12 +820,11 @@ struct ksock_route *
 		read_lock(g_lock);
 		peer_ni = ksocknal_find_peer_locked(ni, id);
 		if (peer_ni) {
-			if (!ksocknal_find_connectable_route_locked(peer_ni)) {
+			if (!ksocknal_find_connectable_conn_cb_locked(peer_ni)) {
 				conn = ksocknal_find_conn_locked(peer_ni, tx,
 								 tx->tx_nonblk);
 				if (conn) {
-					/*
-					 * I've got no routes that need to be
+					/* I've got nothing that need to be
 					 * connecting and I do have an actual
 					 * connection...
 					 */
@@ -879,7 +878,7 @@ struct ksock_route *
 	}
 
 	if (peer_ni->ksnp_accepting > 0 ||
-	    ksocknal_find_connecting_route_locked(peer_ni)) {
+	    ksocknal_find_connecting_conn_cb_locked(peer_ni)) {
 		/* the message is going to be pinned to the peer_ni */
 		tx->tx_deadline = ktime_get_seconds() +
 				  ksocknal_timeout();
@@ -1771,10 +1770,10 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 }
 
 static bool
-ksocknal_connect(struct ksock_route *route)
+ksocknal_connect(struct ksock_conn_cb *conn_cb)
 {
 	LIST_HEAD(zombies);
-	struct ksock_peer_ni *peer_ni = route->ksnr_peer;
+	struct ksock_peer_ni *peer_ni = conn_cb->ksnr_peer;
 	int type;
 	int wanted;
 	struct socket *sock;
@@ -1786,19 +1785,18 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	LASSERT(route->ksnr_scheduled);
-	LASSERT(!route->ksnr_connecting);
+	LASSERT(conn_cb->ksnr_scheduled);
+	LASSERT(!conn_cb->ksnr_connecting);
 
-	route->ksnr_connecting = 1;
+	conn_cb->ksnr_connecting = 1;
 
 	for (;;) {
-		wanted = ksocknal_route_mask() & ~route->ksnr_connected;
+		wanted = ksocknal_conn_cb_mask() & ~conn_cb->ksnr_connected;
 
-		/*
-		 * stop connecting if peer_ni/route got closed under me, or
-		 * route got connected while queued
+		/* stop connecting if peer_ni/cb got closed under me, or
+		 * conn_cb got connected while queued
 		 */
-		if (peer_ni->ksnp_closing || route->ksnr_deleted ||
+		if (peer_ni->ksnp_closing || conn_cb->ksnr_deleted ||
 		    !wanted) {
 			retry_later = false;
 			break;
@@ -1833,24 +1831,25 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			rc = -ETIMEDOUT;
 			lnet_connect_console_error(rc, peer_ni->ksnp_id.nid,
 						   (struct sockaddr *)
-						   &route->ksnr_addr);
+						   &conn_cb->ksnr_addr);
 			goto failed;
 		}
 
 		sock = lnet_connect(peer_ni->ksnp_id.nid,
-				    route->ksnr_myiface,
-				    (struct sockaddr *)&route->ksnr_addr,
+				    conn_cb->ksnr_myiface,
+				    (struct sockaddr *)&conn_cb->ksnr_addr,
 				    peer_ni->ksnp_ni->ni_net_ns);
 		if (IS_ERR(sock)) {
 			rc = PTR_ERR(sock);
 			goto failed;
 		}
 
-		rc = ksocknal_create_conn(peer_ni->ksnp_ni, route, sock, type);
+		rc = ksocknal_create_conn(peer_ni->ksnp_ni, conn_cb, sock,
+					  type);
 		if (rc < 0) {
 			lnet_connect_console_error(rc, peer_ni->ksnp_id.nid,
 						   (struct sockaddr *)
-						   &route->ksnr_addr);
+						   &conn_cb->ksnr_addr);
 			goto failed;
 		}
 
@@ -1866,8 +1865,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		write_lock_bh(&ksocknal_data.ksnd_global_lock);
 	}
 
-	route->ksnr_scheduled = 0;
-	route->ksnr_connecting = 0;
+	conn_cb->ksnr_scheduled = 0;
+	conn_cb->ksnr_connecting = 0;
 
 	if (retry_later) {
 		/*
@@ -1882,13 +1881,13 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			 * but the race is resolved quickly usually,
 			 * so min_reconnectms should be good heuristic
 			 */
-			route->ksnr_retry_interval =
+			conn_cb->ksnr_retry_interval =
 				*ksocknal_tunables.ksnd_min_reconnectms / 1000;
-			route->ksnr_timeout = ktime_get_seconds() +
-					      route->ksnr_retry_interval;
+			conn_cb->ksnr_timeout = ktime_get_seconds() +
+						conn_cb->ksnr_retry_interval;
 		}
 
-		ksocknal_launch_connection_locked(route);
+		ksocknal_launch_connection_locked(conn_cb);
 	}
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
@@ -1897,24 +1896,25 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 failed:
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	route->ksnr_scheduled = 0;
-	route->ksnr_connecting = 0;
+	conn_cb->ksnr_scheduled = 0;
+	conn_cb->ksnr_connecting = 0;
 
 	/* This is a retry rather than a new connection */
-	route->ksnr_retry_interval *= 2;
-	route->ksnr_retry_interval =
-		max_t(time64_t, route->ksnr_retry_interval,
+	conn_cb->ksnr_retry_interval *= 2;
+	conn_cb->ksnr_retry_interval =
+		max_t(time64_t, conn_cb->ksnr_retry_interval,
 		      *ksocknal_tunables.ksnd_min_reconnectms / 1000);
-	route->ksnr_retry_interval =
-		min_t(time64_t, route->ksnr_retry_interval,
+	conn_cb->ksnr_retry_interval =
+		min_t(time64_t, conn_cb->ksnr_retry_interval,
 		      *ksocknal_tunables.ksnd_max_reconnectms / 1000);
 
-	LASSERT(route->ksnr_retry_interval);
-	route->ksnr_timeout = ktime_get_seconds() + route->ksnr_retry_interval;
+	LASSERT(conn_cb->ksnr_retry_interval);
+	conn_cb->ksnr_timeout = ktime_get_seconds() +
+				conn_cb->ksnr_retry_interval;
 
 	if (!list_empty(&peer_ni->ksnp_tx_queue) &&
 	    !peer_ni->ksnp_accepting &&
-	    !ksocknal_find_connecting_route_locked(peer_ni)) {
+	    !ksocknal_find_connecting_conn_cb_locked(peer_ni)) {
 		struct ksock_conn *conn;
 
 		/*
@@ -2045,26 +2045,28 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	       ksocknal_data.ksnd_connd_connecting + SOCKNAL_CONND_RESV;
 }
 
-/*
- * Go through connd_routes queue looking for a route that we can process
+/* Go through connd_cbs queue looking for a conn_cb that we can process
  * right now, @timeout_p can be updated if we need to come back later
  */
-static struct ksock_route *
-ksocknal_connd_get_route_locked(signed long *timeout_p)
+static struct ksock_conn_cb *
+ksocknal_connd_get_conn_cb_locked(signed long *timeout_p)
 {
 	time64_t now = ktime_get_seconds();
-	struct ksock_route *route;
+	time64_t conn_timeout;
+	struct ksock_conn_cb *conn_cb;
 
-	/* connd_routes can contain both pending and ordinary routes */
-	list_for_each_entry(route, &ksocknal_data.ksnd_connd_routes,
+	/* connd_cb can contain both pending and ordinary conn_cb */
+	list_for_each_entry(conn_cb, &ksocknal_data.ksnd_connd_routes,
 			    ksnr_connd_list) {
-		if (!route->ksnr_retry_interval ||
-		    now >= route->ksnr_timeout)
-			return route;
+		conn_timeout = conn_cb->ksnr_timeout;
+
+		if (!conn_cb->ksnr_retry_interval ||
+		    now >= conn_cb->ksnr_timeout)
+			return conn_cb;
 
 		if (*timeout_p == MAX_SCHEDULE_TIMEOUT ||
-		    *timeout_p > (signed long)(route->ksnr_timeout - now) * HZ)
-			*timeout_p = (signed long)(route->ksnr_timeout - now) * HZ;
+		    *timeout_p > (signed long)(conn_timeout - now) * HZ)
+			*timeout_p = (signed long)(conn_timeout - now) * HZ;
 	}
 
 	return NULL;
@@ -2087,7 +2089,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	ksocknal_data.ksnd_connd_running++;
 
 	while (!ksocknal_data.ksnd_shuttingdown) {
-		struct ksock_route *route = NULL;
+		struct ksock_conn_cb *conn_cb = NULL;
 		time64_t sec = ktime_get_real_seconds();
 		long timeout = MAX_SCHEDULE_TIMEOUT;
 		bool dropped_lock = false;
@@ -2126,27 +2128,27 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		 * create new connd
 		 */
 		if (ksocknal_data.ksnd_connd_connecting + SOCKNAL_CONND_RESV <
-		    ksocknal_data.ksnd_connd_running) {
-			route = ksocknal_connd_get_route_locked(&timeout);
-		}
-		if (route) {
-			list_del(&route->ksnr_connd_list);
+		    ksocknal_data.ksnd_connd_running)
+			conn_cb = ksocknal_connd_get_conn_cb_locked(&timeout);
+
+		if (conn_cb) {
+			list_del(&conn_cb->ksnr_connd_list);
 			ksocknal_data.ksnd_connd_connecting++;
 			spin_unlock_bh(connd_lock);
 			dropped_lock = true;
 
-			if (ksocknal_connect(route)) {
+			if (ksocknal_connect(conn_cb)) {
 				/* consecutive retry */
 				if (cons_retry++ > SOCKNAL_INSANITY_RECONN) {
 					CWARN("massive consecutive re-connecting to %pIS\n",
-					      &route->ksnr_addr);
+					      &conn_cb->ksnr_addr);
 					cons_retry = 0;
 				}
 			} else {
 				cons_retry = 0;
 			}
 
-			ksocknal_route_decref(route);
+			ksocknal_conn_cb_decref(conn_cb);
 
 			spin_lock_bh(connd_lock);
 			ksocknal_data.ksnd_connd_connecting--;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
