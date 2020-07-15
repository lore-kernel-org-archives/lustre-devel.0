From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:50 -0400
Subject: [lustre-devel] [PATCH 09/37] lnet: o2iblnd: allocate init_qp_attr
 on stack.
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

'struct ib_qp_init_attr' is not so large that it cannot be allocated
on the stack.  It is about 100 bytes, various other function in Linux
allocate it on the stack, and the stack isn't as constrained as it
once was.

So allocate on stack instead of using kmalloc and handling errors.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 524a5a733ba1c ("LU-12678 o2iblnd: allocate init_qp_attr on stack.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39122
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 45 +++++++++++++++-------------------------
 1 file changed, 17 insertions(+), 28 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 16edfba..d8fca2a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -699,7 +699,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
 	struct kib_net *net = peer_ni->ibp_ni->ni_data;
 	struct kib_dev *dev;
-	struct ib_qp_init_attr *init_qp_attr;
+	struct ib_qp_init_attr init_qp_attr = {};
 	struct kib_sched_info *sched;
 	struct ib_cq_init_attr cq_attr = {};
 	struct kib_conn *conn;
@@ -727,18 +727,11 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	 */
 	cpt = sched->ibs_cpt;
 
-	init_qp_attr = kzalloc_cpt(sizeof(*init_qp_attr), GFP_NOFS, cpt);
-	if (!init_qp_attr) {
-		CERROR("Can't allocate qp_attr for %s\n",
-		       libcfs_nid2str(peer_ni->ibp_nid));
-		goto failed_0;
-	}
-
 	conn = kzalloc_cpt(sizeof(*conn), GFP_NOFS, cpt);
 	if (!conn) {
 		CERROR("Can't allocate connection for %s\n",
 		       libcfs_nid2str(peer_ni->ibp_nid));
-		goto failed_1;
+		goto failed_0;
 	}
 
 	conn->ibc_state = IBLND_CONN_INIT;
@@ -819,27 +812,27 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 		goto failed_2;
 	}
 
-	init_qp_attr->event_handler = kiblnd_qp_event;
-	init_qp_attr->qp_context = conn;
-	init_qp_attr->cap.max_send_sge = *kiblnd_tunables.kib_wrq_sge;
-	init_qp_attr->cap.max_recv_sge = 1;
-	init_qp_attr->sq_sig_type = IB_SIGNAL_REQ_WR;
-	init_qp_attr->qp_type = IB_QPT_RC;
-	init_qp_attr->send_cq = cq;
-	init_qp_attr->recv_cq = cq;
+	init_qp_attr.event_handler = kiblnd_qp_event;
+	init_qp_attr.qp_context = conn;
+	init_qp_attr.cap.max_send_sge = *kiblnd_tunables.kib_wrq_sge;
+	init_qp_attr.cap.max_recv_sge = 1;
+	init_qp_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
+	init_qp_attr.qp_type = IB_QPT_RC;
+	init_qp_attr.send_cq = cq;
+	init_qp_attr.recv_cq = cq;
 	/* kiblnd_send_wrs() can change the connection's queue depth if
 	 * the maximum work requests for the device is maxed out
 	 */
-	init_qp_attr->cap.max_send_wr = kiblnd_send_wrs(conn);
-	init_qp_attr->cap.max_recv_wr = IBLND_RECV_WRS(conn);
+	init_qp_attr.cap.max_send_wr = kiblnd_send_wrs(conn);
+	init_qp_attr.cap.max_recv_wr = IBLND_RECV_WRS(conn);
 
-	rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
+	rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, &init_qp_attr);
 	if (rc) {
 		CERROR("Can't create QP: %d, send_wr: %d, recv_wr: %d, send_sge: %d, recv_sge: %d\n",
-		       rc, init_qp_attr->cap.max_send_wr,
-		       init_qp_attr->cap.max_recv_wr,
-		       init_qp_attr->cap.max_send_sge,
-		       init_qp_attr->cap.max_recv_sge);
+		       rc, init_qp_attr.cap.max_send_wr,
+		       init_qp_attr.cap.max_recv_wr,
+		       init_qp_attr.cap.max_send_sge,
+		       init_qp_attr.cap.max_recv_sge);
 		goto failed_2;
 	}
 
@@ -851,8 +844,6 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 		      peer_ni->ibp_queue_depth,
 		      conn->ibc_queue_depth);
 
-	kfree(init_qp_attr);
-
 	conn->ibc_rxs = kzalloc_cpt(IBLND_RX_MSGS(conn) *
 				    sizeof(*conn->ibc_rxs),
 				    GFP_NOFS, cpt);
@@ -918,8 +909,6 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 failed_2:
 	kiblnd_destroy_conn(conn);
 	kfree(conn);
-failed_1:
-	kfree(init_qp_attr);
 failed_0:
 	return NULL;
 }
-- 
1.8.3.1
