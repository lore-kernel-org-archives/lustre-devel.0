From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:02 -0500
Subject: [lustre-devel] [PATCH 554/622] lnet: change ksocknal_create_peer()
 to return pointer
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-555-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

ksocknal_create_peer() currently returns an error status, and if that
is 0, a pointer is stored in a by-reference argument.  The preferred
pattern in the kernel is to return the pointer, or the error code
encoded with ERR_PTR().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 049683bc0fc0 ("LU-12678 lnet: change ksocknal_create_peer() to return pointer")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36833
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 79068f3..3e69d9c 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -98,9 +98,8 @@
 	kfree(route);
 }
 
-static int
-ksocknal_create_peer(struct ksock_peer_ni **peerp, struct lnet_ni *ni,
-		     struct lnet_process_id id)
+static struct ksock_peer_ni *
+ksocknal_create_peer(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	int cpt = lnet_cpt_of_nid(id.nid, ni);
 	struct ksock_net *net = ni->ni_data;
@@ -112,7 +111,7 @@
 
 	peer_ni = kzalloc_cpt(sizeof(*peer_ni), GFP_NOFS, cpt);
 	if (!peer_ni)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	peer_ni->ksnp_ni = ni;
 	peer_ni->ksnp_id = id;
@@ -136,15 +135,14 @@
 
 		kfree(peer_ni);
 		CERROR("Can't create peer_ni: network shutdown\n");
-		return -ESHUTDOWN;
+		return ERR_PTR(-ESHUTDOWN);
 	}
 
 	net->ksnn_npeers++;
 
 	spin_unlock_bh(&net->ksnn_lock);
 
-	*peerp = peer_ni;
-	return 0;
+	return peer_ni;
 }
 
 void
@@ -447,16 +445,15 @@ struct ksock_peer_ni *
 	struct ksock_peer_ni *peer2;
 	struct ksock_route *route;
 	struct ksock_route *route2;
-	int rc;
 
 	if (id.nid == LNET_NID_ANY ||
 	    id.pid == LNET_PID_ANY)
 		return -EINVAL;
 
 	/* Have a brand new peer_ni ready... */
-	rc = ksocknal_create_peer(&peer_ni, ni, id);
-	if (rc)
-		return rc;
+	peer_ni = ksocknal_create_peer(ni, id);
+	if (IS_ERR(peer_ni))
+		return PTR_ERR(peer_ni);
 
 	route = ksocknal_create_route(ipaddr, port);
 	if (!route) {
@@ -1114,9 +1111,11 @@ struct ksock_peer_ni *
 		ksocknal_peer_addref(peer_ni);
 		write_lock_bh(global_lock);
 	} else {
-		rc = ksocknal_create_peer(&peer_ni, ni, peerid);
-		if (rc)
+		peer_ni = ksocknal_create_peer(ni, peerid);
+		if (IS_ERR(peer_ni)) {
+			rc = PTR_ERR(peer_ni);
 			goto failed_1;
+		}
 
 		write_lock_bh(global_lock);
 
-- 
1.8.3.1
