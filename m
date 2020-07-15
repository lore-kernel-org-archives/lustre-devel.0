From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:07 -0400
Subject: [lustre-devel] [PATCH 26/37] lnet: socklnd: use
 list_for_each_entry_safe()
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Several loops use list_for_each_safe(), then call list_entry() as
first step.  These can be merged using list_for_each_entry_safe().

In one case, the 'safe' version is clearly not needed, so just use
list_for_each_entry().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 03f375e9f6390 ("LU-12678 socklnd: use list_for_each_entry_safe()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39129
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 55 ++++++++++++++--------------------------
 1 file changed, 19 insertions(+), 36 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 2b8fd3d..2e11737 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -453,15 +453,12 @@ struct ksock_peer_ni *
 	struct ksock_peer_ni *peer_ni = route->ksnr_peer;
 	struct ksock_interface *iface;
 	struct ksock_conn *conn;
-	struct list_head *ctmp;
-	struct list_head *cnxt;
+	struct ksock_conn *cnxt;
 
 	LASSERT(!route->ksnr_deleted);
 
 	/* Close associated conns */
-	list_for_each_safe(ctmp, cnxt, &peer_ni->ksnp_conns) {
-		conn = list_entry(ctmp, struct ksock_conn, ksnc_list);
-
+	list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns, ksnc_list) {
 		if (conn->ksnc_route != route)
 			continue;
 
@@ -548,9 +545,9 @@ struct ksock_peer_ni *
 ksocknal_del_peer_locked(struct ksock_peer_ni *peer_ni, u32 ip)
 {
 	struct ksock_conn *conn;
+	struct ksock_conn *cnxt;
 	struct ksock_route *route;
-	struct list_head *tmp;
-	struct list_head *nxt;
+	struct ksock_route *rnxt;
 	int nshared;
 
 	LASSERT(!peer_ni->ksnp_closing);
@@ -558,9 +555,8 @@ struct ksock_peer_ni *
 	/* Extra ref prevents peer_ni disappearing until I'm done with it */
 	ksocknal_peer_addref(peer_ni);
 
-	list_for_each_safe(tmp, nxt, &peer_ni->ksnp_routes) {
-		route = list_entry(tmp, struct ksock_route, ksnr_list);
-
+	list_for_each_entry_safe(route, rnxt, &peer_ni->ksnp_routes,
+				 ksnr_list) {
 		/* no match */
 		if (!(!ip || route->ksnr_ipaddr == ip))
 			continue;
@@ -571,29 +567,23 @@ struct ksock_peer_ni *
 	}
 
 	nshared = 0;
-	list_for_each_safe(tmp, nxt, &peer_ni->ksnp_routes) {
-		route = list_entry(tmp, struct ksock_route, ksnr_list);
+	list_for_each_entry(route, &peer_ni->ksnp_routes, ksnr_list)
 		nshared += route->ksnr_share_count;
-	}
 
 	if (!nshared) {
-		/*
-		 * remove everything else if there are no explicit entries
+		/* remove everything else if there are no explicit entries
 		 * left
 		 */
-		list_for_each_safe(tmp, nxt, &peer_ni->ksnp_routes) {
-			route = list_entry(tmp, struct ksock_route, ksnr_list);
-
+		list_for_each_entry_safe(route, rnxt, &peer_ni->ksnp_routes,
+					 ksnr_list) {
 			/* we should only be removing auto-entries */
 			LASSERT(!route->ksnr_share_count);
 			ksocknal_del_route_locked(route);
 		}
 
-		list_for_each_safe(tmp, nxt, &peer_ni->ksnp_conns) {
-			conn = list_entry(tmp, struct ksock_conn, ksnc_list);
-
+		list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns,
+					 ksnc_list)
 			ksocknal_close_conn_locked(conn, 0);
-		}
 	}
 
 	ksocknal_peer_decref(peer_ni);
@@ -1752,13 +1742,10 @@ struct ksock_peer_ni *
 				 u32 ipaddr, int why)
 {
 	struct ksock_conn *conn;
-	struct list_head *ctmp;
-	struct list_head *cnxt;
+	struct ksock_conn *cnxt;
 	int count = 0;
 
-	list_for_each_safe(ctmp, cnxt, &peer_ni->ksnp_conns) {
-		conn = list_entry(ctmp, struct ksock_conn, ksnc_list);
-
+	list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns, ksnc_list) {
 		if (!ipaddr || conn->ksnc_ipaddr == ipaddr) {
 			count++;
 			ksocknal_close_conn_locked(conn, why);
@@ -1992,10 +1979,10 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 ksocknal_peer_del_interface_locked(struct ksock_peer_ni *peer_ni,
 				   u32 ipaddr, int index)
 {
-	struct list_head *tmp;
-	struct list_head *nxt;
 	struct ksock_route *route;
+	struct ksock_route *rnxt;
 	struct ksock_conn *conn;
+	struct ksock_conn *cnxt;
 	int i;
 	int j;
 
@@ -2008,9 +1995,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			break;
 		}
 
-	list_for_each_safe(tmp, nxt, &peer_ni->ksnp_routes) {
-		route = list_entry(tmp, struct ksock_route, ksnr_list);
-
+	list_for_each_entry_safe(route, rnxt, &peer_ni->ksnp_routes,
+				 ksnr_list) {
 		if (route->ksnr_myiface != index)
 			continue;
 
@@ -2022,12 +2008,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		}
 	}
 
-	list_for_each_safe(tmp, nxt, &peer_ni->ksnp_conns) {
-		conn = list_entry(tmp, struct ksock_conn, ksnc_list);
-
+	list_for_each_entry_safe(conn, cnxt, &peer_ni->ksnp_conns, ksnc_list)
 		if (conn->ksnc_myipaddr == ipaddr)
 			ksocknal_close_conn_locked(conn, 0);
-	}
 }
 
 static int
-- 
1.8.3.1
