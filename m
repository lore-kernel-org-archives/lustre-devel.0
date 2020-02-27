From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:07 -0500
Subject: [lustre-devel] [PATCH 499/622] lustre: ptlrpc: resend may corrupt
 the data
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-500-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

Late resend if arrives much later than another modification RPC
which has been already handled on this slot, may be still applied
and therefore overrides the last one

Send RPCs from client in increasing order for each tag
and check it on server to check late resend.

A slot can be reused by a client after kill while
the server continue to rely on it.

Add flag for such obsolete requests, here we trust the
client and perform xid check for all in progress requests.

Cray-bug-id: LUS-6272, LUS-7277, LUS-7339
WC-bug-id: https://jira.whamcloud.com/browse/LU-11444
Lustre-commit: 23773b32bfe1 ("LU-11444 ptlrpc: resend may corrupt the data")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/35114
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_mdc.h |  1 +
 fs/lustre/include/lustre_net.h |  1 +
 fs/lustre/llite/llite_lib.c    |  4 +++-
 fs/lustre/obdclass/genops.c    |  6 ++++++
 fs/lustre/ptlrpc/client.c      | 10 ++++++++++
 fs/lustre/ptlrpc/service.c     | 11 ++++++++---
 6 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/lustre_mdc.h b/fs/lustre/include/lustre_mdc.h
index aecb6ee..f57783d 100644
--- a/fs/lustre/include/lustre_mdc.h
+++ b/fs/lustre/include/lustre_mdc.h
@@ -70,6 +70,7 @@ static inline void mdc_get_mod_rpc_slot(struct ptlrpc_request *req,
 	opc = lustre_msg_get_opc(req->rq_reqmsg);
 	tag = obd_get_mod_rpc_slot(cli, opc, it);
 	lustre_msg_set_tag(req->rq_reqmsg, tag);
+	ptlrpc_reassign_next_xid(req);
 }
 
 static inline void mdc_put_mod_rpc_slot(struct ptlrpc_request *req,
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 8dad08e..40c1ae8 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1916,6 +1916,7 @@ void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 u64 ptlrpc_next_xid(void);
 u64 ptlrpc_sample_next_xid(void);
 u64 ptlrpc_req_xid(struct ptlrpc_request *request);
+void ptlrpc_reassign_next_xid(struct ptlrpc_request *req);
 
 /* Set of routines to run a function in ptlrpcd context */
 void *ptlrpcd_alloc_work(struct obd_import *imp,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 5d74f30..4580be3 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -240,6 +240,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_FLR |
 				   OBD_CONNECT2_LOCK_CONVERT |
 				   OBD_CONNECT2_ARCHIVE_ID_ARRAY |
+				   OBD_CONNECT2_INC_XID |
 				   OBD_CONNECT2_LSOM |
 				   OBD_CONNECT2_ASYNC_DISCARD |
 				   OBD_CONNECT2_PCC;
@@ -459,7 +460,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (data->ocd_version < OBD_OCD_VERSION(2, 12, 50, 0))
 		data->ocd_connect_flags |= OBD_CONNECT_LOCKAHEAD_OLD;
 
-	data->ocd_connect_flags2 = OBD_CONNECT2_LOCKAHEAD;
+	data->ocd_connect_flags2 = OBD_CONNECT2_LOCKAHEAD |
+				   OBD_CONNECT2_INC_XID;
 
 	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_GRANT_PARAM))
 		data->ocd_connect_flags |= OBD_CONNECT_GRANT_PARAM;
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 49db077..5d4e421 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1550,6 +1550,12 @@ u16 obd_get_mod_rpc_slot(struct client_obd *cli, u32 opc,
 			LASSERT(!test_and_set_bit(i, cli->cl_mod_tag_bitmap));
 			spin_unlock(&cli->cl_mod_rpcs_lock);
 			/* tag 0 is reserved for non-modify RPCs */
+
+			CDEBUG(D_RPCTRACE,
+			       "%s: modify RPC slot %u is allocated opc %u, max %hu\n",
+			       cli->cl_import->imp_obd->obd_name,
+			       i + 1, opc, max);
+
 			return i + 1;
 		}
 		spin_unlock(&cli->cl_mod_rpcs_lock);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index c359ac0..8d874f2 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -717,6 +717,16 @@ static inline void ptlrpc_assign_next_xid(struct ptlrpc_request *req)
 
 static atomic64_t ptlrpc_last_xid;
 
+void ptlrpc_reassign_next_xid(struct ptlrpc_request *req)
+{
+	spin_lock(&req->rq_import->imp_lock);
+	list_del_init(&req->rq_unreplied_list);
+	ptlrpc_assign_next_xid_nolock(req);
+	spin_unlock(&req->rq_import->imp_lock);
+	DEBUG_REQ(D_RPCTRACE, req, "reassign xid");
+}
+EXPORT_SYMBOL(ptlrpc_reassign_next_xid);
+
 int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 			     u32 version, int opcode, char **bufs,
 			     struct ptlrpc_cli_ctx *ctx)
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index c66c690..b2a33a3 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -864,6 +864,13 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 	}
 }
 
+static void ptlrpc_del_exp_list(struct ptlrpc_request *req)
+{
+	spin_lock(&req->rq_export->exp_rpc_lock);
+	list_del_init(&req->rq_exp_list);
+	spin_unlock(&req->rq_export->exp_rpc_lock);
+}
+
 /**
  * to finish a request: stop sending more early replies, and release
  * the request.
@@ -1367,9 +1374,7 @@ static void ptlrpc_server_hpreq_fini(struct ptlrpc_request *req)
 		if (req->rq_ops->hpreq_fini)
 			req->rq_ops->hpreq_fini(req);
 
-		spin_lock(&req->rq_export->exp_rpc_lock);
-		list_del_init(&req->rq_exp_list);
-		spin_unlock(&req->rq_export->exp_rpc_lock);
+		ptlrpc_del_exp_list(req);
 	}
 }
 
-- 
1.8.3.1
