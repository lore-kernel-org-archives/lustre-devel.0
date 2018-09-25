From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 22/34] LU-7734 lnet: fix
 lnet_peer_table_cleanup_locked()
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763572.32103.17043305407995526499.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

In lnet_peer_table_cleanup_locked() we delete the entire peer if the
lnet_peer_ni for the primary NID of the peer is deleted. If the next
lnet_peer_ni in the list belongs to the peer being deleted, then the
next pointer kept by list_for_each_entry_safe() ends up pointing at
freed memory.

Add a list_for_each_entry_from() loop to advance next to a peer_ni
that does not belong to the peer being deleted and will therefore
remain present in the list.

Signed-off-by: Olaf Weber <olaf@sgi.com>
Change-Id: I92bf219dc93a79f7d90035ccfbb38cd251138c04
Reviewed-on: http://review.whamcloud.com/20824
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/peer.c |   26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 3555e9bd1db1..11edf3632405 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -331,26 +331,32 @@ lnet_peer_table_cleanup_locked(struct lnet_net *net,
 			       struct lnet_peer_table *ptable)
 {
 	int i;
+	struct lnet_peer_ni *next;
 	struct lnet_peer_ni *lpni;
-	struct lnet_peer_ni *tmp;
 	struct lnet_peer *peer;
 
 	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
-		list_for_each_entry_safe(lpni, tmp, &ptable->pt_hash[i],
+		list_for_each_entry_safe(lpni, next, &ptable->pt_hash[i],
 					 lpni_hashlist) {
 			if (net && net != lpni->lpni_net)
 				continue;
 
-			/*
-			 * check if by removing this peer ni we should be
-			 * removing the entire peer.
-			 */
 			peer = lpni->lpni_peer_net->lpn_peer;
-
-			if (peer->lp_primary_nid == lpni->lpni_nid)
-				lnet_peer_del_locked(peer);
-			else
+			if (peer->lp_primary_nid != lpni->lpni_nid) {
 				lnet_peer_ni_del_locked(lpni);
+				continue;
+			}
+			/*
+			 * Removing the primary NID implies removing
+			 * the entire peer. Advance next beyond any
+			 * peer_ni that belongs to the same peer.
+			 */
+			list_for_each_entry_from(next, &ptable->pt_hash[i],
+						 lpni_hashlist) {
+				if (next->lpni_peer_net->lpn_peer != peer)
+					break;
+			}
+			lnet_peer_del_locked(peer);
 		}
 	}
 }
