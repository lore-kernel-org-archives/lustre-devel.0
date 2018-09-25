From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:16 +1000
Subject: [lustre-devel] [PATCH 34/34] LU-7734 lnet: cpt locking
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763614.32103.8503784699321046646.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

When source nid is specified it is necessary to also
use the destination nid. Otherwise bulk transfer will end up
on a different interface than the nearest interface to the
memory. This has significant performance impact on NUMA
systems such as the SGI UV.

The CPT which the MD describing the bulk buffers belongs to
is not the same CPT of the actual pages of memory.
Therefore, it is necessary to communicate the CPT of the pages
to LNet, in order for LNet to select the nearest interface.

The MD which describes the pages of memory gets attached to
an ME, to be matched later on. The MD which describes the
message to be sent is different and this patch adds the
handle of the bulk MD into the MD which ends up being
accessible by lnet_select_pathway(). In that function
a new API, lnet_cpt_of_md_page(), is called which returns the
CPT of the buffers used for the bulk transfer.
lnet_select_pathway() proceeds to use this CPT to select
the nearest interface.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: I4117ef912835f16dcdcaafb70703f92d74053b9b
Reviewed-on: https://review.whamcloud.com/24085
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 +
 .../staging/lustre/include/linux/lnet/lib-types.h  |    1 +
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |   12 ++++++++
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   31 ++++++++++++++++++++
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   20 ++++++++-----
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   26 +++++++++++++----
 6 files changed, 78 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 3a53d54b711d..aedc88c69977 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -595,6 +595,7 @@ void lnet_me_unlink(struct lnet_me *me);
 
 void lnet_md_unlink(struct lnet_libmd *md);
 void lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_md *umd);
+int lnet_cpt_of_md(struct lnet_libmd *md);
 
 void lnet_register_lnd(struct lnet_lnd *lnd);
 void lnet_unregister_lnd(struct lnet_lnd *lnd);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index f811f125dfcb..18e2665ad74d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -161,6 +161,7 @@ struct lnet_libmd {
 	void			*md_user_ptr;
 	struct lnet_eq		*md_eq;
 	unsigned int		 md_niov;	/* # frags */
+	struct lnet_handle_md	 md_bulk_handle;
 	union {
 		struct kvec	iov[LNET_MAX_IOV];
 		struct bio_vec	kiov[LNET_MAX_IOV];
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index 62f062c0d1bf..837e5fe25ac1 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -444,6 +444,7 @@ struct lnet_md {
 	 * - LNET_MD_IOVEC: The start and length fields specify an array of
 	 *   struct iovec.
 	 * - LNET_MD_MAX_SIZE: The max_size field is valid.
+	 * - LNET_MD_BULK_HANDLE: The bulk_handle field is valid.
 	 *
 	 * Note:
 	 * - LNET_MD_KIOV or LNET_MD_IOVEC allows for a scatter/gather
@@ -467,6 +468,15 @@ struct lnet_md {
 	 * descriptor are not logged.
 	 */
 	struct lnet_handle_eq eq_handle;
+	/**
+	 * The bulk MD handle which was registered to describe the buffers
+	 * either to be used to transfer data to the peer or receive data
+	 * from the peer. This allows LNet to properly determine the NUMA
+	 * node on which the memory was allocated and use that to select the
+	 * nearest local network interface. This value is only used
+	 * if the LNET_MD_BULK_HANDLE option is set.
+	 */
+	struct lnet_handle_md bulk_handle;
 };
 
 /*
@@ -499,6 +509,8 @@ struct lnet_md {
 #define LNET_MD_MAX_SIZE	BIT(7)
 /** See lnet_md::options. */
 #define LNET_MD_KIOV		BIT(8)
+/** See lnet_md::options. */
+#define LNET_MD_BULK_HANDLE	BIT(9)
 
 /* For compatibility with Cray Portals */
 #define LNET_MD_PHYS		0
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 8a22514aaf71..9e26911cd319 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -84,6 +84,36 @@ lnet_md_unlink(struct lnet_libmd *md)
 	kfree(md);
 }
 
+int
+lnet_cpt_of_md(struct lnet_libmd *md)
+{
+	int cpt = CFS_CPT_ANY;
+
+	if (!md)
+		return CFS_CPT_ANY;
+
+	if ((md->md_options & LNET_MD_BULK_HANDLE) != 0 &&
+	    md->md_bulk_handle.cookie != LNET_WIRE_HANDLE_COOKIE_NONE) {
+		md = lnet_handle2md(&md->md_bulk_handle);
+
+		if (!md)
+			return CFS_CPT_ANY;
+	}
+
+	if ((md->md_options & LNET_MD_KIOV) != 0) {
+		if (md->md_iov.kiov[0].bv_page)
+			cpt = cfs_cpt_of_node(
+				lnet_cpt_table(),
+				page_to_nid(md->md_iov.kiov[0].bv_page));
+	} else if (md->md_iov.iov[0].iov_base) {
+		cpt = cfs_cpt_of_node(
+			lnet_cpt_table(),
+			page_to_nid(virt_to_page(md->md_iov.iov[0].iov_base)));
+	}
+
+	return cpt;
+}
+
 static int
 lnet_md_build(struct lnet_libmd *lmd, struct lnet_md *umd, int unlink)
 {
@@ -101,6 +131,7 @@ lnet_md_build(struct lnet_libmd *lmd, struct lnet_md *umd, int unlink)
 	lmd->md_threshold = umd->threshold;
 	lmd->md_refcount = 0;
 	lmd->md_flags = (unlink == LNET_UNLINK) ? LNET_MD_FLAG_AUTO_UNLINK : 0;
+	lmd->md_bulk_handle = umd->bulk_handle;
 
 	if (umd->options & LNET_MD_IOVEC) {
 		if (umd->options & LNET_MD_KIOV) /* Can't specify both */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 141983f0ef83..d39331fcf932 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1225,6 +1225,11 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 * then we proceed, if there is, then we restart the operation.
 	 */
 	cpt = lnet_net_lock_current();
+
+	md_cpt = lnet_cpt_of_md(msg->msg_md);
+	if (md_cpt == CFS_CPT_ANY)
+		md_cpt = cpt;
+
 again:
 	best_ni = NULL;
 	best_lpni = NULL;
@@ -1242,12 +1247,6 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		return -ESHUTDOWN;
 	}
 
-	if (msg->msg_md)
-		/* get the cpt of the MD, used during NUMA based selection */
-		md_cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
-	else
-		md_cpt = CFS_CPT_ANY;
-
 	peer = lnet_find_or_create_peer_locked(dst_nid, cpt);
 	if (IS_ERR(peer)) {
 		lnet_net_unlock(cpt);
@@ -1285,7 +1284,8 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 
 	if (msg->msg_type == LNET_MSG_REPLY ||
 	    msg->msg_type == LNET_MSG_ACK ||
-	    !peer->lp_multi_rail) {
+	    !peer->lp_multi_rail ||
+	    best_ni) {
 		/*
 		 * for replies we want to respond on the same peer_ni we
 		 * received the message on if possible. If not, then pick
@@ -1294,6 +1294,12 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		 * if the peer is non-multi-rail then you want to send to
 		 * the dst_nid provided as well.
 		 *
+		 * If the best_ni has already been determined, IE the
+		 * src_nid has been specified, then use the
+		 * destination_nid provided as well, since we're
+		 * continuing a series of related messages for the same
+		 * RPC.
+		 *
 		 * It is expected to find the lpni using dst_nid, since we
 		 * created it earlier.
 		 */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index d0bcd8827f8a..415450d3c8c1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -48,7 +48,8 @@
 static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 			enum lnet_ack_req ack, struct ptlrpc_cb_id *cbid,
 			lnet_nid_t self, struct lnet_process_id peer_id,
-			int portal, __u64 xid, unsigned int offset)
+			int portal, __u64 xid, unsigned int offset,
+			struct lnet_handle_md *bulk_cookie)
 {
 	int rc;
 	struct lnet_md md;
@@ -61,13 +62,17 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 	md.options = PTLRPC_MD_OPTIONS;
 	md.user_ptr = cbid;
 	md.eq_handle = ptlrpc_eq_h;
+	md.bulk_handle.cookie = LNET_WIRE_HANDLE_COOKIE_NONE;
+
+	if (bulk_cookie) {
+		md.bulk_handle = *bulk_cookie;
+		md.options |= LNET_MD_BULK_HANDLE;
+	}
 
 	if (unlikely(ack == LNET_ACK_REQ &&
-		     OBD_FAIL_CHECK_ORSET(OBD_FAIL_PTLRPC_ACK,
-					  OBD_FAIL_ONCE))) {
+		     OBD_FAIL_CHECK_ORSET(OBD_FAIL_PTLRPC_ACK, OBD_FAIL_ONCE)))
 		/* don't ask for the ack to simulate failing client */
 		ack = LNET_NOACK_REQ;
-	}
 
 	rc = LNetMDBind(md, LNET_UNLINK, mdh);
 	if (unlikely(rc != 0)) {
@@ -417,7 +422,7 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 			  LNET_ACK_REQ : LNET_NOACK_REQ,
 			  &rs->rs_cb_id, req->rq_self, req->rq_source,
 			  ptlrpc_req2svc(req)->srv_rep_portal,
-			  req->rq_xid, req->rq_reply_off);
+			  req->rq_xid, req->rq_reply_off, NULL);
 out:
 	if (unlikely(rc != 0))
 		ptlrpc_req_drop_rs(req);
@@ -474,12 +479,15 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	int rc;
 	int rc2;
 	unsigned int mpflag = 0;
+	struct lnet_handle_md bulk_cookie;
 	struct ptlrpc_connection *connection;
 	struct lnet_handle_me reply_me_h;
 	struct lnet_md reply_md;
 	struct obd_import *imp = request->rq_import;
 	struct obd_device *obd = imp->imp_obd;
 
+	bulk_cookie.cookie = LNET_WIRE_HANDLE_COOKIE_NONE;
+
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_DROP_RPC))
 		return 0;
 
@@ -577,6 +585,12 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		rc = ptlrpc_register_bulk(request);
 		if (rc != 0)
 			goto out;
+		/*
+		 * All the mds in the request will have the same cpt
+		 * encoded in the cookie. So we can just get the first
+		 * one.
+		 */
+		bulk_cookie = request->rq_bulk->bd_mds[0];
 	}
 
 	if (!noreply) {
@@ -685,7 +699,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			  LNET_NOACK_REQ, &request->rq_req_cbid,
 			  LNET_NID_ANY, connection->c_peer,
 			  request->rq_request_portal,
-			  request->rq_xid, 0);
+			  request->rq_xid, 0, &bulk_cookie);
 	if (likely(rc == 0))
 		goto out;
 
