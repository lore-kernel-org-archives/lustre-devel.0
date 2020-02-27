From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:11 -0500
Subject: [lustre-devel] [PATCH 443/622] lnet: Fix style issues for
 selftest/rpc.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-444-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <stancheff@cray.com>

This patch fixes issues reported by checkpatch for the file
selftest/rpc.c.
Linux 5.3 enforces the use of 'fallthrough' which is also
suggested by checkpatch

Cray-bug-id: LUS-7690
WC-bug-id: https://jira.whamcloud.com/browse/LU-12635
Lustre-commit: 4bfe21d09c39 ("LU-12635 lnet: Fix style issues for selftest/rpc.c")
Signed-off-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-on: https://review.whamcloud.com/35800
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/selftest/rpc.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index a5941e4..4645f04 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -141,7 +141,8 @@ struct srpc_bulk *
 		struct page *pg;
 		int nob;
 
-		pg = alloc_pages_node(cfs_cpt_spread_node(lnet_cpt_table(), cpt),
+		pg = alloc_pages_node(cfs_cpt_spread_node(lnet_cpt_table(),
+							  cpt),
 				      GFP_KERNEL, 0);
 		if (!pg) {
 			CERROR("Can't allocate page %d of %d\n", i, bulk_npg);
@@ -386,7 +387,8 @@ struct srpc_bulk *
 		return -ENOMEM;
 	}
 
-	CDEBUG(D_NET, "Posted passive RDMA: peer %s, portal %d, matchbits %#llx\n",
+	CDEBUG(D_NET,
+	       "Posted passive RDMA: peer %s, portal %d, matchbits %#llx\n",
 	       libcfs_id2str(peer), portal, matchbits);
 	return 0;
 }
@@ -440,7 +442,8 @@ struct srpc_bulk *
 		rc = LNetMDUnlink(*mdh);
 		LASSERT(!rc);
 	} else {
-		CDEBUG(D_NET, "Posted active RDMA: peer %s, portal %u, matchbits %#llx\n",
+		CDEBUG(D_NET,
+		       "Posted active RDMA: peer %s, portal %u, matchbits %#llx\n",
 		       libcfs_id2str(peer), portal, matchbits);
 	}
 	return 0;
@@ -515,7 +518,8 @@ struct srpc_bulk *
 void
 srpc_add_buffer(struct swi_workitem *wi)
 {
-	struct srpc_service_cd *scd = container_of(wi, struct srpc_service_cd, scd_buf_wi);
+	struct srpc_service_cd *scd = container_of(wi, struct srpc_service_cd,
+						   scd_buf_wi);
 	struct srpc_buffer *buf;
 	int rc = 0;
 
@@ -662,7 +666,8 @@ struct srpc_bulk *
 		spin_lock(&scd->scd_lock);
 
 		if (scd->scd_buf_nposted > 0) {
-			CDEBUG(D_NET, "waiting for %d posted buffers to unlink\n",
+			CDEBUG(D_NET,
+			       "waiting for %d posted buffers to unlink\n",
 			       scd->scd_buf_nposted);
 			spin_unlock(&scd->scd_lock);
 			return 0;
@@ -960,7 +965,8 @@ struct srpc_bulk *
 void
 srpc_handle_rpc(struct swi_workitem *wi)
 {
-	struct srpc_server_rpc *rpc = container_of(wi, struct srpc_server_rpc, srpc_wi);
+	struct srpc_server_rpc *rpc = container_of(wi, struct srpc_server_rpc,
+						   srpc_wi);
 	struct srpc_service_cd *scd = rpc->srpc_scd;
 	struct srpc_service *sv = scd->scd_svc;
 	struct srpc_event *ev = &rpc->srpc_ev;
@@ -1398,7 +1404,9 @@ struct srpc_client_rpc *
 	return rc;
 }
 
-/* when in kernel always called with lnet_net_lock() held, and in thread context */
+/* when in kernel always called with lnet_net_lock() held,
+ * and in thread context
+ */
 static void
 srpc_lnet_ev_handler(struct lnet_event *ev)
 {
@@ -1451,7 +1459,8 @@ struct srpc_client_rpc *
 			       rpcev, crpc, &crpc->crpc_reqstev,
 			       &crpc->crpc_replyev, &crpc->crpc_bulkev);
 			CERROR("Bad event: status %d, type %d, lnet %d\n",
-			       rpcev->ev_status, rpcev->ev_type, rpcev->ev_lnet);
+			       rpcev->ev_status, rpcev->ev_type,
+			       rpcev->ev_lnet);
 			LBUG();
 		}
 
-- 
1.8.3.1
