From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:22 -0500
Subject: [lustre-devel] [PATCH 214/622] lnet: o2iblnd: ibc_rxs is created
 and freed with different size
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-215-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

kiblnd_create_conn()) alloc '(conn->ibc_rxs)': 26832 at ffffc90012e69000
kiblnd_destroy_conn()) kfreed 'conn->ibc_rxs': 4576 at ffffc90012e69000

The size changed by kiblnd_create_conn() :
"peer 172.18.2.3 at o2ib - queue depth reduced from 128 to 21"

Based on size LIBCFS_FREE() decides whether to use kfree or vfree
and accounts memory usage.

Allocate ibc_rxs after rdma_create_qp()

Cray-bug-id: LUS-6339
WC-bug-id: https://jira.whamcloud.com/browse/LU-11702
Lustre-commit: 277a6faa5b16 ("LU-11702 o2iblnd: ibc_rxs is created and freed with different size")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/33721
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 017fe5f..0e207ef 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -735,6 +735,8 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	conn->ibc_cmid = cmid;
 	conn->ibc_max_frags = peer_ni->ibp_max_frags;
 	conn->ibc_queue_depth = peer_ni->ibp_queue_depth;
+	conn->ibc_rxs = NULL;
+	conn->ibc_rx_pages = NULL;
 
 	INIT_LIST_HEAD(&conn->ibc_early_rxs);
 	INIT_LIST_HEAD(&conn->ibc_tx_noops);
@@ -778,20 +780,6 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 
 	write_unlock_irqrestore(glock, flags);
 
-	conn->ibc_rxs = kzalloc_cpt(IBLND_RX_MSGS(conn) * sizeof(struct kib_rx),
-				    GFP_NOFS, cpt);
-	if (!conn->ibc_rxs) {
-		CERROR("Cannot allocate RX buffers\n");
-		goto failed_2;
-	}
-
-	rc = kiblnd_alloc_pages(&conn->ibc_rx_pages, cpt,
-				IBLND_RX_MSG_PAGES(conn));
-	if (rc)
-		goto failed_2;
-
-	kiblnd_map_rx_descs(conn);
-
 	cq_attr.cqe = IBLND_CQ_ENTRIES(conn);
 	cq_attr.comp_vector = kiblnd_get_completion_vector(conn, cpt);
 	cq = ib_create_cq(cmid->device,
@@ -856,6 +844,20 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 
 	kfree(init_qp_attr);
 
+	conn->ibc_rxs = kzalloc_cpt(IBLND_RX_MSGS(conn) * sizeof(struct kib_rx),
+				    GFP_NOFS, cpt);
+	if (!conn->ibc_rxs) {
+		CERROR("Cannot allocate RX buffers\n");
+		goto failed_2;
+	}
+
+	rc = kiblnd_alloc_pages(&conn->ibc_rx_pages, cpt,
+				IBLND_RX_MSG_PAGES(conn));
+	if (rc)
+		goto failed_2;
+
+	kiblnd_map_rx_descs(conn);
+
 	/* 1 ref for caller and each rxmsg */
 	atomic_set(&conn->ibc_refcount, 1 + IBLND_RX_MSGS(conn));
 	conn->ibc_nrx = IBLND_RX_MSGS(conn);
-- 
1.8.3.1
