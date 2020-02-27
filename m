From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:58 -0500
Subject: [lustre-devel] [PATCH 490/622] lnet: o2iblnd: cache max_qp_wr
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-491-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When creating the device the maximum number of work requests per qp
which can be allocated is already known. Cache that internally,
and when creating the qp make sure the qp's max_send_wr does not
exceed that max. If it does then cap max_send_wr to max_qp_wr.
Recalculate the connection's queue depth based on the max_qp_wr.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12621
Lustre-commit: 7ee319ed7f9d ("LU-12621 o2iblnd: cache max_qp_wr")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36073
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 42 ++++++++++++++++++++++++----------------
 net/lnet/klnds/o2iblnd/o2iblnd.h |  1 +
 2 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 278823f..d4d5d4f 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -656,16 +656,28 @@ static unsigned int kiblnd_send_wrs(struct kib_conn *conn)
 	 * One WR for the LNet message
 	 * And ibc_max_frags for the transfer WRs
 	 */
+	int ret;
+	int multiplier = 1 + conn->ibc_max_frags;
 	enum kib_dev_caps dev_caps = conn->ibc_hdev->ibh_dev->ibd_dev_caps;
-	unsigned int ret = 1 + conn->ibc_max_frags;
 
 	/* FastReg needs two extra WRs for map and invalidate */
 	if (dev_caps & IBLND_DEV_CAPS_FASTREG_ENABLED)
-		ret += 2;
+		multiplier += 2;
 
 	/* account for a maximum of ibc_queue_depth in-flight transfers */
-	ret *= conn->ibc_queue_depth;
-	return ret;
+	ret = multiplier * conn->ibc_queue_depth;
+
+	if (ret > conn->ibc_hdev->ibh_max_qp_wr) {
+		CDEBUG(D_NET,
+		       "peer_credits %u will result in send work request size %d larger than maximum %d device can handle\n",
+		       conn->ibc_queue_depth, ret,
+		       conn->ibc_hdev->ibh_max_qp_wr);
+		conn->ibc_queue_depth =
+			conn->ibc_hdev->ibh_max_qp_wr / multiplier;
+	}
+
+	/* don't go beyond the maximum the device can handle */
+	return min(ret, conn->ibc_hdev->ibh_max_qp_wr);
 }
 
 struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
@@ -814,20 +826,13 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	init_qp_attr->qp_type = IB_QPT_RC;
 	init_qp_attr->send_cq = cq;
 	init_qp_attr->recv_cq = cq;
+	/* kiblnd_send_wrs() can change the connection's queue depth if
+	 * the maximum work requests for the device is maxed out
+	 */
+	init_qp_attr->cap.max_send_wr = kiblnd_send_wrs(conn);
+	init_qp_attr->cap.max_recv_wr = IBLND_RECV_WRS(conn);
 
-	conn->ibc_sched = sched;
-
-	do {
-		init_qp_attr->cap.max_send_wr = kiblnd_send_wrs(conn);
-		init_qp_attr->cap.max_recv_wr = IBLND_RECV_WRS(conn);
-
-		rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
-		if (!rc || conn->ibc_queue_depth < 2)
-			break;
-
-		conn->ibc_queue_depth--;
-	} while (rc);
-
+	rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
 	if (rc) {
 		CERROR("Can't create QP: %d, send_wr: %d, recv_wr: %d, send_sge: %d, recv_sge: %d\n",
 		       rc, init_qp_attr->cap.max_send_wr,
@@ -837,6 +842,8 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 		goto failed_2;
 	}
 
+	conn->ibc_sched = sched;
+
 	if (conn->ibc_queue_depth != peer_ni->ibp_queue_depth)
 		CWARN("peer %s - queue depth reduced from %u to %u  to allow for qp creation\n",
 		      libcfs_nid2str(peer_ni->ibp_nid),
@@ -2330,6 +2337,7 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 	}
 
 	hdev->ibh_mr_size = dev_attr->max_mr_size;
+	hdev->ibh_max_qp_wr = dev_attr->max_qp_wr;
 
 	CERROR("Invalid mr size: %#llx\n", hdev->ibh_mr_size);
 	return -EINVAL;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index bc79874..ac91757 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -178,6 +178,7 @@ struct kib_hca_dev {
 	int			ibh_page_size;	/* page size of current HCA */
 	u64			ibh_page_mask;	/* page mask of current HCA */
 	u64			ibh_mr_size;	/* size of MR */
+	int			ibh_max_qp_wr;	/* maximum work requests size */
 	struct ib_pd		*ibh_pd;	/* PD */
 	struct kib_dev		*ibh_dev;	/* owner */
 	atomic_t		ibh_ref;	/* refcount */
-- 
1.8.3.1
