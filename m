From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:28 -0400
Subject: [lustre-devel] [PATCH 06/10] lustre: lnd: calculate qp max_send_wrs
 properly
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

The maximum in-flight transfers can not exceed the
negotiated queue depth. Instead of calculating the
max_send_wrs to be the negotiated number of frags *
concurrent sends, it should be the negotiated number
of frags * queue depth.

If that value is too large for successful qp creation then
we reduce the queue depth in a loop until we successfully
create the qp or the queue depth dips below 2.

Due to the queue depth negotiation protocol it is guaranteed
that the queue depth on both the active and the passive
will match.

This change resolves the discrepancy created by the previous
code which reduces max_send_wr by a quarter.

That could lead to:
mlx5_ib_post_send:4184:(pid 26272): Failed to prepare WQE
When the o2iblnd transfers a message which requires more
WRs than the max that has been allocated.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10213
Reviewed-on: https://review.whamcloud.com/30310
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 30 +++++++++++++++++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  4 +--
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 99a4650..43266d8 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -650,6 +650,19 @@ static struct kib_sched_info *kiblnd_get_scheduler(int cpt)
 	return NULL;
 }
 
+static unsigned int kiblnd_send_wrs(struct kib_conn *conn)
+{
+	/*
+	 * One WR for the LNet message
+	 * And ibc_max_frags for the transfer WRs
+	 */
+	unsigned int ret = 1 + conn->ibc_max_frags;
+
+	/* account for a maximum of ibc_queue_depth in-flight transfers */
+	ret *= conn->ibc_queue_depth;
+	return ret;
+}
+
 struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 				    struct rdma_cm_id *cmid,
 				    int state, int version)
@@ -801,8 +814,6 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 
 	init_qp_attr->event_handler = kiblnd_qp_event;
 	init_qp_attr->qp_context = conn;
-	init_qp_attr->cap.max_send_wr = IBLND_SEND_WRS(conn);
-	init_qp_attr->cap.max_recv_wr = IBLND_RECV_WRS(conn);
 	init_qp_attr->cap.max_send_sge = *kiblnd_tunables.kib_wrq_sge;
 	init_qp_attr->cap.max_recv_sge = 1;
 	init_qp_attr->sq_sig_type = IB_SIGNAL_REQ_WR;
@@ -813,11 +824,14 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	conn->ibc_sched = sched;
 
 	do {
+		init_qp_attr->cap.max_send_wr = kiblnd_send_wrs(conn);
+		init_qp_attr->cap.max_recv_wr = IBLND_RECV_WRS(conn);
+
 		rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
-		if (!rc || init_qp_attr->cap.max_send_wr < 16)
+		if (!rc || conn->ibc_queue_depth < 2)
 			break;
 
-		init_qp_attr->cap.max_send_wr -= init_qp_attr->cap.max_send_wr / 4;
+		conn->ibc_queue_depth--;
 	} while (rc);
 
 	if (rc) {
@@ -829,9 +843,11 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 		goto failed_2;
 	}
 
-	if (init_qp_attr->cap.max_send_wr != IBLND_SEND_WRS(conn))
-		CDEBUG(D_NET, "original send wr %d, created with %d\n",
-		       IBLND_SEND_WRS(conn), init_qp_attr->cap.max_send_wr);
+	if (conn->ibc_queue_depth != peer_ni->ibp_queue_depth)
+		CWARN("peer %s - queue depth reduced from %u to %u  to allow for qp creation\n",
+		      libcfs_nid2str(peer_ni->ibp_nid),
+		      peer_ni->ibp_queue_depth,
+		      conn->ibc_queue_depth);
 
 	kfree(init_qp_attr);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index cd64cfb..c6c8106 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -139,9 +139,7 @@ struct kib_tunables {
 
 /* WRs and CQEs (per connection) */
 #define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
-#define IBLND_SEND_WRS(c)	\
-	((c->ibc_max_frags + 1) * kiblnd_concurrent_sends(c->ibc_version, \
-							  c->ibc_peer->ibp_ni))
+
 #define IBLND_CQ_ENTRIES(c)	\
 	(IBLND_RECV_WRS(c) + 2 * kiblnd_concurrent_sends(c->ibc_version, \
 							 c->ibc_peer->ibp_ni))
-- 
1.8.3.1
