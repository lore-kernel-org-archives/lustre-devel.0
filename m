From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:27 -0400
Subject: [lustre-devel] [PATCH 05/10] lustre: o2iblnd: limit cap.max_send_wr
 for MLX5
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

Decrease cap.max_send_wr until it is accepted by rdma_create_qp()

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7124
Reviewed-on: http://review.whamcloud.com/18347
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 8f984a0..99a4650 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -812,7 +812,14 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 
 	conn->ibc_sched = sched;
 
-	rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
+	do {
+		rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
+		if (!rc || init_qp_attr->cap.max_send_wr < 16)
+			break;
+
+		init_qp_attr->cap.max_send_wr -= init_qp_attr->cap.max_send_wr / 4;
+	} while (rc);
+
 	if (rc) {
 		CERROR("Can't create QP: %d, send_wr: %d, recv_wr: %d, send_sge: %d, recv_sge: %d\n",
 		       rc, init_qp_attr->cap.max_send_wr,
@@ -822,6 +829,10 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 		goto failed_2;
 	}
 
+	if (init_qp_attr->cap.max_send_wr != IBLND_SEND_WRS(conn))
+		CDEBUG(D_NET, "original send wr %d, created with %d\n",
+		       IBLND_SEND_WRS(conn), init_qp_attr->cap.max_send_wr);
+
 	kfree(init_qp_attr);
 
 	/* 1 ref for caller and each rxmsg */
-- 
1.8.3.1
