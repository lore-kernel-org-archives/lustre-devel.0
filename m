From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 18:53:28 -0500
Subject: [lustre-devel] [PATCH 5/7] staging: lustre: check wr_id returned by
	ib_poll_cq
In-Reply-To: <1456962810-21806-1-git-send-email-jsimmons@infradead.org>
References: <1456962810-21806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456962810-21806-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

If ib_poll_cq returned +ve without initialising ib_wc::wr_id (bug
in driver), then o2iblnd will run into unpredictable situation
because ib_wc::wr_id may refer to stale tx/rx pointer in stack.

It indicates bug in HCA driver if this happened, ko2iblnd should
output console error then close current connection.

This patch could also be helpful for LU-5271

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-519
Reviewed-on: http://review.whamcloud.com/12747
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    9 ++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   21 ++++++++++++++++++-
 2 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 3db1413..6a4c4ac 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -762,10 +762,11 @@ kiblnd_queue2str(kib_conn_t *conn, struct list_head *q)
 /* CAVEAT EMPTOR: We rely on descriptor alignment to allow us to use the */
 /* lowest bits of the work request id to stash the work item type. */
 
-#define IBLND_WID_TX    0
-#define IBLND_WID_RDMA  1
-#define IBLND_WID_RX    2
-#define IBLND_WID_MASK  3UL
+#define IBLND_WID_INVAL	0
+#define IBLND_WID_TX	1
+#define IBLND_WID_RX	2
+#define IBLND_WID_RDMA	3
+#define IBLND_WID_MASK	3UL
 
 static inline __u64
 kiblnd_ptr2wreqid(void *ptr, int type)
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 7602d71..199c105 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -768,7 +768,6 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 	int ver = conn->ibc_version;
 	int rc;
 	int done;
-	struct ib_send_wr *bad_wrq;
 
 	LASSERT(tx->tx_queued);
 	/* We rely on this for QP sizing */
@@ -852,7 +851,14 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 		/* close_conn will launch failover */
 		rc = -ENETDOWN;
 	} else {
-		rc = ib_post_send(conn->ibc_cmid->qp, &tx->tx_wrq->wr, &bad_wrq);
+		struct ib_send_wr *wrq = &tx->tx_wrq[tx->tx_nwrq - 1].wr;
+
+		LASSERTF(wrq->wr_id == kiblnd_ptr2wreqid(tx, IBLND_WID_TX),
+			 "bad wr_id %llx, opc %d, flags %d, peer: %s\n",
+			 wrq->wr_id, wrq->opcode, wrq->send_flags,
+		libcfs_nid2str(conn->ibc_peer->ibp_nid));
+		wrq = NULL;
+		rc = ib_post_send(conn->ibc_cmid->qp, &tx->tx_wrq->wr, &wrq);
 	}
 
 	conn->ibc_last_send = jiffies;
@@ -3420,6 +3426,8 @@ kiblnd_scheduler(void *arg)
 
 			spin_unlock_irqrestore(&sched->ibs_lock, flags);
 
+			wc.wr_id = IBLND_WID_INVAL;
+
 			rc = ib_poll_cq(conn->ibc_cq, 1, &wc);
 			if (!rc) {
 				rc = ib_req_notify_cq(conn->ibc_cq,
@@ -3437,6 +3445,15 @@ kiblnd_scheduler(void *arg)
 				rc = ib_poll_cq(conn->ibc_cq, 1, &wc);
 			}
 
+			if (unlikely(rc > 0 && wc.wr_id == IBLND_WID_INVAL)) {
+				LCONSOLE_ERROR("ib_poll_cq (rc: %d) returned invalid wr_id, opcode %d, status: %d, vendor_err: %d, conn: %s status: %d\nplease upgrade firmware and OFED or contact vendor.\n",
+					       rc, wc.opcode, wc.status,
+					       wc.vendor_err,
+					       libcfs_nid2str(conn->ibc_peer->ibp_nid),
+					       conn->ibc_state);
+				rc = -EINVAL;
+			}
+
 			if (rc < 0) {
 				CWARN("%s: ib_poll_cq failed: %d, closing connection\n",
 				      libcfs_nid2str(conn->ibc_peer->ibp_nid),
-- 
1.7.1
