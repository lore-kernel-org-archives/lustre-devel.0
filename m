From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:44 -0400
Subject: [lustre-devel] [PATCH 10/29] staging: lustre: ptlrpc: embed highest
	XID in each request
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Gregoire Pichon <gregoire.pichon@bull.net>, Alex Zhuravlev <alexey.zhuravlev@intel.com>, James Simmons <jsimmons@infradead.org>

From: Gregoire Pichon <gregoire.pichon@bull.net>

Atomically assign XIDs and put request and sending list so
we can learn the lowest unreplied XID at any point.

This allows to embed in every resquests the highest XID for
which a reply has been received and does not have an unreplied
lower-numbered XID.

This will be used by the MDT target to release in-memory
reply data corresponding to XIDs of reply received by the client.

Signed-off-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5319
Reviewed-on: http://review.whamcloud.com/14793
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    1 +
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   34 +++++++++++++++++++-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   15 +++++++++
 3 files changed, 49 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 67a7095..a14f1a4 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2069,6 +2069,7 @@ void lustre_msg_set_handle(struct lustre_msg *msg,
 			   struct lustre_handle *handle);
 void lustre_msg_set_type(struct lustre_msg *msg, __u32 type);
 void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc);
+void lustre_msg_set_last_xid(struct lustre_msg *msg, u64 last_xid);
 void lustre_msg_set_tag(struct lustre_msg *msg, __u16 tag);
 void lustre_msg_set_versions(struct lustre_msg *msg, __u64 *versions);
 void lustre_msg_set_transno(struct lustre_msg *msg, __u64 transno);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index e4a31eb..e4fbdd0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -700,7 +700,6 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 
 	ptlrpc_at_set_req_timeout(request);
 
-	request->rq_xid = ptlrpc_next_xid();
 	lustre_msg_set_opc(request->rq_reqmsg, opcode);
 
 	/* Let's setup deadline for req/reply/bulk unlink for opcode. */
@@ -1436,6 +1435,8 @@ static int after_reply(struct ptlrpc_request *req)
 static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 {
 	struct obd_import *imp = req->rq_import;
+	struct list_head *tmp;
+	u64 min_xid = ~0ULL;
 	int rc;
 
 	LASSERT(req->rq_phase == RQ_PHASE_NEW);
@@ -1448,6 +1449,18 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 
 	spin_lock(&imp->imp_lock);
 
+	/*
+	 * the very first time we assign XID. it's important to assign XID
+	 * and put it on the list atomically, so that the lowest assigned
+	 * XID is always known. this is vital for multislot last_rcvd
+	 */
+	if (req->rq_send_state == LUSTRE_IMP_REPLAY) {
+		LASSERT(req->rq_xid);
+	} else {
+		LASSERT(!req->rq_xid);
+		req->rq_xid = ptlrpc_next_xid();
+	}
+
 	if (!req->rq_generation_set)
 		req->rq_import_generation = imp->imp_generation;
 
@@ -1477,8 +1490,27 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 	LASSERT(list_empty(&req->rq_list));
 	list_add_tail(&req->rq_list, &imp->imp_sending_list);
 	atomic_inc(&req->rq_import->imp_inflight);
+
+	/* find the lowest unreplied XID */
+	list_for_each(tmp, &imp->imp_delayed_list) {
+		struct ptlrpc_request *r;
+
+		r = list_entry(tmp, struct ptlrpc_request, rq_list);
+		if (r->rq_xid < min_xid)
+			min_xid = r->rq_xid;
+	}
+	list_for_each(tmp, &imp->imp_sending_list) {
+		struct ptlrpc_request *r;
+
+		r = list_entry(tmp, struct ptlrpc_request, rq_list);
+		if (r->rq_xid < min_xid)
+			min_xid = r->rq_xid;
+	}
 	spin_unlock(&imp->imp_lock);
 
+	if (likely(min_xid != ~0ULL))
+		lustre_msg_set_last_xid(req->rq_reqmsg, min_xid - 1);
+
 	lustre_msg_set_status(req->rq_reqmsg, current_pid());
 
 	rc = sptlrpc_req_refresh_ctx(req, -1);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 1c06b4e..4f63a80 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1255,6 +1255,21 @@ void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc)
 	}
 }
 
+void lustre_msg_set_last_xid(struct lustre_msg *msg, u64 last_xid)
+{
+	switch (msg->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2: {
+		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
+
+		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
+		pb->pb_last_xid = last_xid;
+		return;
+	}
+	default:
+		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
+	}
+}
+
 void lustre_msg_set_tag(struct lustre_msg *msg, __u16 tag)
 {
 	switch (msg->lm_magic) {
-- 
1.7.1
