From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:07 -0400
Subject: [lustre-devel] [PATCH 15/25] lustre: o2iblnd: reconnect peer for
 REJ_INVALID_SERVICE_ID
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sergey Cheremencev <c17829@cray.com>

Don't kill the peer in case of INVALID_SERVICE_ID. This produces
huge number of peers for the same nid and may cause an OOM.

The OOM was frequently seen with mlnx-ofa-kernel-2.3 where used
RCU mechanism in mlx4_cq_free. In older mlnx4 versions to mitigate
the issue RCU was changed with spin locks.

Signed-off-by: Sergey Cheremencev <c17829@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9094
Seagate-bug-id: MRP-4056
Reviewed-on: https://review.whamcloud.com/25378
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 1 +
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index a3d89ec..de04355 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -460,6 +460,7 @@ struct kib_rej {
 #define IBLND_REJECT_RDMA_FRAGS	    6
 /* peer_ni's msg queue size doesn't match mine */
 #define IBLND_REJECT_MSG_QUEUE_SIZE 7
+#define IBLND_REJECT_INVALID_SRV_ID 8
 
 /***********************************************************************/
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index a6b261a..dc71554 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2611,6 +2611,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	case IBLND_REJECT_CONN_UNCOMPAT:
 		reason = "version negotiation";
 		break;
+
+	case IBLND_REJECT_INVALID_SRV_ID:
+		reason = "invalid service id";
+		break;
 	}
 
 	conn->ibc_reconnect = 1;
@@ -2648,6 +2652,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		break;
 
 	case IB_CM_REJ_INVALID_SERVICE_ID:
+		kiblnd_check_reconnect(conn, IBLND_MSG_VERSION, 0,
+				       IBLND_REJECT_INVALID_SRV_ID, NULL);
 		CNETERR("%s rejected: no listener at %d\n",
 			libcfs_nid2str(peer_ni->ibp_nid),
 			*kiblnd_tunables.kib_service);
-- 
1.8.3.1
