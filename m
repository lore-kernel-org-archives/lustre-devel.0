From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:10 -0400
Subject: [lustre-devel] [PATCH 14/20] lustre: ptlrpc: fill md correctly.
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

MD fill should limit to the overall transfer size in additional
to the number a fragment.
Let's do this.

Cray-bug-id: LUS-8139
WC-bug-id: https://jira.whamcloud.com/browse/LU-10157
Lustre-commit: e1ac9e74844dc ("LU-10157 ptlrpc: fill md correctly.")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/37387
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  5 +++++
 fs/lustre/ptlrpc/client.c      | 22 ++++++++++++++++++----
 fs/lustre/ptlrpc/niobuf.c      | 10 +++++-----
 fs/lustre/ptlrpc/pers.c        | 20 +++++++++++++++-----
 4 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 18de7d9..2d58f13e 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1260,6 +1260,7 @@ struct ptlrpc_bulk_desc {
 	int				bd_max_iov;	/* allocated size of bd_iov */
 	int				bd_nob;		/* # bytes covered */
 	int				bd_nob_transferred; /* # bytes GOT/PUT */
+	unsigned int			bd_nob_last;	/* # bytes in last MD */
 
 	u64				bd_last_mbits;
 
@@ -1267,6 +1268,10 @@ struct ptlrpc_bulk_desc {
 	lnet_nid_t			bd_sender;	/* stash event::sender */
 	int				bd_md_count;	/* # valid entries in bd_mds */
 	int				bd_md_max_brw;	/* max entries in bd_mds */
+
+	/** array of offsets for each MD */
+	unsigned int			bd_mds_off[PTLRPC_BULK_OPS_COUNT];
+
 	/** array of associated MDs */
 	struct lnet_handle_md		bd_mds[PTLRPC_BULK_OPS_COUNT];
 
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index e69c988..c9d9fe9 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -147,6 +147,12 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 
 	LASSERT(ops->add_kiov_frag);
 
+	if (max_brw > PTLRPC_BULK_OPS_COUNT)
+		return NULL;
+
+	if (nfrags > LNET_MAX_IOV * max_brw)
+		return NULL;
+
 	desc = kzalloc(sizeof(*desc), GFP_NOFS);
 	if (!desc)
 		return NULL;
@@ -162,6 +168,7 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 	desc->bd_portal = portal;
 	desc->bd_type = type;
 	desc->bd_md_count = 0;
+	desc->bd_nob_last = LNET_MTU;
 	desc->bd_frag_ops = ops;
 	LASSERT(max_brw > 0);
 	desc->bd_md_max_brw = min(max_brw, PTLRPC_BULK_OPS_COUNT);
@@ -228,6 +235,15 @@ void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 
 	kiov = &desc->bd_vec[desc->bd_iov_count];
 
+	if (((desc->bd_iov_count % LNET_MAX_IOV) == 0) ||
+	    ((desc->bd_nob_last + len) > LNET_MTU)) {
+		desc->bd_mds_off[desc->bd_md_count] = desc->bd_iov_count;
+		desc->bd_md_count++;
+		desc->bd_nob_last = 0;
+		LASSERT(desc->bd_md_count <= PTLRPC_BULK_OPS_COUNT);
+	}
+
+	desc->bd_nob_last += len;
 	desc->bd_nob += len;
 
 	if (pin)
@@ -3177,9 +3193,7 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 		    || req->rq_mbits == 0) {
 			req->rq_mbits = req->rq_xid;
 		} else {
-			int total_md = (bd->bd_iov_count + LNET_MAX_IOV - 1) /
-					LNET_MAX_IOV;
-			req->rq_mbits -= total_md - 1;
+			req->rq_mbits -= bd->bd_md_count - 1;
 		}
 	} else {
 		/*
@@ -3194,7 +3208,7 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 	 * that server can infer the number of bulks that were prepared,
 	 * see LU-1431
 	 */
-	req->rq_mbits += DIV_ROUND_UP(bd->bd_iov_count, LNET_MAX_IOV) - 1;
+	req->rq_mbits += bd->bd_md_count - 1;
 
 	/* Set rq_xid as rq_mbits to indicate the final bulk for the old
 	 * server which does not support OBD_CONNECT_BULK_MBITS. LU-6808
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 3f8b2c6..6fb79a2 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -131,7 +131,6 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 
 	/* NB no locking required until desc is on the network */
 	LASSERT(desc->bd_nob > 0);
-	LASSERT(desc->bd_md_count == 0);
 	LASSERT(desc->bd_md_max_brw <= PTLRPC_BULK_OPS_COUNT);
 	LASSERT(desc->bd_iov_count <= PTLRPC_MAX_BRW_PAGES);
 	LASSERT(desc->bd_req);
@@ -154,9 +153,9 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	LASSERT(desc->bd_cbid.cbid_fn == client_bulk_callback);
 	LASSERT(desc->bd_cbid.cbid_arg == desc);
 
-	total_md = DIV_ROUND_UP(desc->bd_iov_count, LNET_MAX_IOV);
+	total_md = desc->bd_md_count;
 	/* rq_mbits is matchbits of the final bulk */
-	mbits = req->rq_mbits - total_md + 1;
+	mbits = req->rq_mbits - desc->bd_md_count + 1;
 
 	LASSERTF(mbits == (req->rq_mbits & PTLRPC_BULK_OPS_MASK),
 		 "first mbits = x%llu, last mbits = x%llu\n",
@@ -174,13 +173,14 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	md.handler = ptlrpc_handler;
 	md.threshold = 1;		/* PUT or GET */
 
-	for (posted_md = 0; posted_md < total_md; posted_md++, mbits++) {
+	for (posted_md = 0; posted_md < desc->bd_md_count;
+	     posted_md++, mbits++) {
 		md.options = PTLRPC_MD_OPTIONS |
 			     (ptlrpc_is_bulk_op_get(desc->bd_type) ?
 			      LNET_MD_OP_GET : LNET_MD_OP_PUT);
 		ptlrpc_fill_bulk_md(&md, desc, posted_md);
 
-		if (posted_md > 0 && posted_md + 1 == total_md &&
+		if (posted_md > 0 && posted_md + 1 == desc->bd_md_count &&
 		    OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_ATTACH)) {
 			rc = -ENOMEM;
 		} else {
diff --git a/fs/lustre/ptlrpc/pers.c b/fs/lustre/ptlrpc/pers.c
index d02b155..ecbc9d3 100644
--- a/fs/lustre/ptlrpc/pers.c
+++ b/fs/lustre/ptlrpc/pers.c
@@ -44,7 +44,7 @@
 void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 			 int mdidx)
 {
-	int offset = mdidx * LNET_MAX_IOV;
+	unsigned int start = desc->bd_mds_off[mdidx];
 
 	BUILD_BUG_ON(PTLRPC_MAX_BRW_PAGES >= LI_POISON);
 
@@ -52,12 +52,22 @@ void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 	LASSERT(desc->bd_iov_count <= PTLRPC_MAX_BRW_PAGES);
 	LASSERT(!(md->options & (LNET_MD_KIOV | LNET_MD_PHYS)));
 
-	md->length = max(0, desc->bd_iov_count - mdidx * LNET_MAX_IOV);
-	md->length = min_t(unsigned int, LNET_MAX_IOV, md->length);
+	/* just send a lnet header */
+	if (mdidx >= desc->bd_md_count) {
+		md->options |= LNET_MD_KIOV;
+		md->length = 0;
+		md->start = NULL;
+		return;
+	}
+
+	if (mdidx == (desc->bd_md_count - 1))
+		md->length = desc->bd_iov_count - start;
+	else
+		md->length = desc->bd_mds_off[mdidx + 1] - start;
 
 	md->options |= LNET_MD_KIOV;
 	if (desc->bd_enc_vec)
-		md->start = &desc->bd_enc_vec[offset];
+		md->start = &desc->bd_enc_vec[start];
 	else
-		md->start = &desc->bd_vec[offset];
+		md->start = &desc->bd_vec[start];
 }
-- 
1.8.3.1
