From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:03 -0400
Subject: [lustre-devel] [PATCH 11/25] lustre: lnet: Fix lost lock
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

Unlock lnet_net_lock in case of error in function lnet_select_pathway().

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9607
Reviewed-on: https://review.whamcloud.com/27455
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 275e8a9..f2bc97d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1260,6 +1260,7 @@
 	}
 
 	if (!peer->lp_multi_rail && lnet_get_num_peer_nis(peer) > 1) {
+		lnet_net_unlock(cpt);
 		CERROR("peer %s is declared to be non MR capable, yet configured with more than one NID\n",
 		       libcfs_nid2str(dst_nid));
 		return -EINVAL;
-- 
1.8.3.1
