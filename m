From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:31 -0400
Subject: [lustre-devel] [PATCH 09/10] lustre: o2ib: use splice in
 kiblnd_peer_connect_failed()
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In kiblnd_peer_connect_failed() replace a backwards list_add() and
list_del() with list_splice_init().

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10819
Reviewed-on: https://review.whamcloud.com/31643
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 1f31798..23ce59e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2118,8 +2118,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	peer_ni->ibp_reconnected = 0;
 	if (list_empty(&peer_ni->ibp_conns)) {
 		/* Take peer_ni's blocked transmits to complete with error */
-		list_add(&zombies, &peer_ni->ibp_tx_queue);
-		list_del_init(&peer_ni->ibp_tx_queue);
+		list_splice_init(&peer_ni->ibp_tx_queue, &zombies);
 
 		if (kiblnd_peer_active(peer_ni))
 			kiblnd_unlink_peer_locked(peer_ni);
-- 
1.8.3.1
