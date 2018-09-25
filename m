From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 24/34] LU-7734 lnet: fix lnet_select_pathway()
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763579.32103.5954776193692454631.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Fixed the selection algorithm to work properly with > 1 local
networks. The behavior now is to iterate through all interfaces
on all networks

Also removed the health variable from struct lnet_peer_net since
it's never used.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: Ib91748e80446585b6a9e1bc0f3af6894599d8aaa
Reviewed-on: http://review.whamcloud.com/20890
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    3 ---
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    4 ++--
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 90a5c6e40dea..0761fd533f8d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -504,9 +504,6 @@ struct lnet_peer_net {
 
 	/* Net ID */
 	__u32			lpn_net_id;
-
-	/* health flag */
-	bool			lpn_healthy;
 };
 
 /* peer hash size */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 8019c59cc64e..2f30ba0d89fb 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1235,6 +1235,8 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 * b. Iterate through each of the peer_nets/nis to decide
 	 * the best peer/local_ni pair to use
 	 */
+	shortest_distance = UINT_MAX;
+	best_credits = INT_MIN;
 	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
 		if (!lnet_is_peer_net_healthy_locked(peer_net))
 			continue;
@@ -1295,8 +1297,6 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		 *	2. NI available credits
 		 *	3. Round Robin
 		 */
-		shortest_distance = UINT_MAX;
-		best_credits = INT_MIN;
 		ni = NULL;
 		while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
 			int ni_credits;
