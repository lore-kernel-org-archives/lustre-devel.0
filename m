From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:27 -0500
Subject: [lustre-devel] [PATCH 039/622] lustre: ptlrpc: fix return type of
 boolean functions
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Some functions are returning type int with values 0 or 1 when
they could be returning bool.  Fix up the return type of:

   lustre_req_swabbed()
   lustre_rep_swabbed()
   ptlrpc_req_need_swab()
   ptlrpc_rep_need_swab()
   ptlrpc_buf_need_swab()

WC-bug-id: https://jira.whamcloud.com/browse/LU-1644
Lustre-commit: e2cac9fb9baf ("LU-1644 ptlrpc: fix return type of boolean functions")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32088
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h  | 20 ++++++++++----------
 fs/lustre/ptlrpc/pack_generic.c |  9 ++++-----
 fs/lustre/ptlrpc/sec_plain.c    |  7 +++----
 3 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 961b8cb..0231011 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -953,35 +953,35 @@ static inline bool ptlrpc_nrs_req_can_move(struct ptlrpc_request *req)
 /** @} nrs */
 
 /**
- * Returns 1 if request buffer at offset @index was already swabbed
+ * Returns true if request buffer at offset @index was already swabbed
  */
-static inline int lustre_req_swabbed(struct ptlrpc_request *req, size_t index)
+static inline bool lustre_req_swabbed(struct ptlrpc_request *req, size_t index)
 {
 	LASSERT(index < sizeof(req->rq_req_swab_mask) * 8);
 	return req->rq_req_swab_mask & (1 << index);
 }
 
 /**
- * Returns 1 if request reply buffer at offset @index was already swabbed
+ * Returns true if request reply buffer@offset @index was already swabbed
  */
-static inline int lustre_rep_swabbed(struct ptlrpc_request *req, size_t index)
+static inline bool lustre_rep_swabbed(struct ptlrpc_request *req, size_t index)
 {
 	LASSERT(index < sizeof(req->rq_rep_swab_mask) * 8);
 	return req->rq_rep_swab_mask & (1 << index);
 }
 
 /**
- * Returns 1 if request needs to be swabbed into local cpu byteorder
+ * Returns true if request needs to be swabbed into local cpu byteorder
  */
-static inline int ptlrpc_req_need_swab(struct ptlrpc_request *req)
+static inline bool ptlrpc_req_need_swab(struct ptlrpc_request *req)
 {
 	return lustre_req_swabbed(req, MSG_PTLRPC_HEADER_OFF);
 }
 
 /**
- * Returns 1 if request reply needs to be swabbed into local cpu byteorder
+ * Returns true if request reply needs to be swabbed into local cpu byteorder
  */
-static inline int ptlrpc_rep_need_swab(struct ptlrpc_request *req)
+static inline bool ptlrpc_rep_need_swab(struct ptlrpc_request *req)
 {
 	return lustre_rep_swabbed(req, MSG_PTLRPC_HEADER_OFF);
 }
@@ -1999,8 +1999,8 @@ struct ptlrpc_service *ptlrpc_register_service(struct ptlrpc_service_conf *conf,
  *
  * @{
  */
-int ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
-			 u32 index);
+bool ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
+			  u32 index);
 void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
 			    u32 index);
 int ptlrpc_unpack_rep_msg(struct ptlrpc_request *req, int len);
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index bc5e513..9cea826 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -78,15 +78,14 @@ void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
 		lustre_set_rep_swabbed(req, index);
 }
 
-int ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
-			 u32 index)
+bool ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
+			  u32 index)
 {
 	if (inout)
 		return (ptlrpc_req_need_swab(req) &&
 			!lustre_req_swabbed(req, index));
-	else
-		return (ptlrpc_rep_need_swab(req) &&
-			!lustre_rep_swabbed(req, index));
+
+	return (ptlrpc_rep_need_swab(req) && !lustre_rep_swabbed(req, index));
 }
 
 /* early reply size */
diff --git a/fs/lustre/ptlrpc/sec_plain.c b/fs/lustre/ptlrpc/sec_plain.c
index 2358c3f..93a9a17 100644
--- a/fs/lustre/ptlrpc/sec_plain.c
+++ b/fs/lustre/ptlrpc/sec_plain.c
@@ -217,7 +217,7 @@ int plain_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 	struct lustre_msg *msg = req->rq_repdata;
 	struct plain_header *phdr;
 	u32 cksum;
-	int swabbed;
+	bool swabbed;
 
 	if (msg->lm_bufcount != PLAIN_PACK_SEGMENTS) {
 		CERROR("unexpected reply buf count %u\n", msg->lm_bufcount);
@@ -715,12 +715,11 @@ int plain_enlarge_reqbuf(struct ptlrpc_sec *sec,
 	.sc_policy	= &plain_policy,
 };
 
-static
-int plain_accept(struct ptlrpc_request *req)
+static int plain_accept(struct ptlrpc_request *req)
 {
 	struct lustre_msg *msg = req->rq_reqbuf;
 	struct plain_header *phdr;
-	int swabbed;
+	bool swabbed;
 
 	LASSERT(SPTLRPC_FLVR_POLICY(req->rq_flvr.sf_rpc) ==
 		SPTLRPC_POLICY_PLAIN);
-- 
1.8.3.1
