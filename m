From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:09 -0400
Subject: [lustre-devel] [PATCH 13/20] lustre: ptlrpc: separate number MD and
 refrences for bulk
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

Introduce a bulk desc refs, it's different from MD's count ptlrpc
expects to have events from all MD's even it's filled or not. So,
number an MD's to post is related to the requested transfer size,
not a number MD's with data.

Cray-bug-id: LUS-8139
WC-bug-id: https://jira.whamcloud.com/browse/LU-10157
Lustre-commit: 8a7f2d4b11801 ("LU-10157 ptlrpc: separate number MD and refrences for bulk")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/37386
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  4 +++-
 fs/lustre/ptlrpc/client.c      |  2 +-
 fs/lustre/ptlrpc/events.c      |  6 +++---
 fs/lustre/ptlrpc/niobuf.c      | 12 ++++++------
 4 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index a94d826..18de7d9 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1237,6 +1237,8 @@ struct ptlrpc_bulk_frag_ops {
  *  Another user is readpage for MDT.
  */
 struct ptlrpc_bulk_desc {
+	/* number MD's assigned including zero-sends */
+	unsigned int			bd_refs;
 	/** completed with failure */
 	unsigned long			bd_failure:1;
 	/** client side */
@@ -1796,7 +1798,7 @@ static inline int ptlrpc_client_bulk_active(struct ptlrpc_request *req)
 		return 1;
 
 	spin_lock(&desc->bd_lock);
-	rc = desc->bd_md_count;
+	rc = desc->bd_refs;
 	spin_unlock(&desc->bd_lock);
 	return rc;
 }
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 22022ff..e69c988 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -244,7 +244,7 @@ void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc)
 {
 	LASSERT(desc->bd_iov_count != LI_POISON);	/* not freed already */
-	LASSERT(desc->bd_md_count == 0);		/* network hands off */
+	LASSERT(desc->bd_refs == 0);			/* network hands off */
 	LASSERT((desc->bd_export != NULL) ^ (desc->bd_import != NULL));
 	LASSERT(desc->bd_frag_ops);
 
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 5e3787c..eef40b3 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -204,8 +204,8 @@ void client_bulk_callback(struct lnet_event *ev)
 
 	spin_lock(&desc->bd_lock);
 	req = desc->bd_req;
-	LASSERT(desc->bd_md_count > 0);
-	desc->bd_md_count--;
+	LASSERT(desc->bd_refs > 0);
+	desc->bd_refs--;
 
 	if (ev->type != LNET_EVENT_UNLINK && ev->status == 0) {
 		desc->bd_nob_transferred += ev->mlength;
@@ -223,7 +223,7 @@ void client_bulk_callback(struct lnet_event *ev)
 	/* NB don't unlock till after wakeup; desc can disappear under us
 	 * otherwise
 	 */
-	if (desc->bd_md_count == 0)
+	if (desc->bd_refs == 0)
 		ptlrpc_client_wake_req(desc->bd_req);
 
 	spin_unlock(&desc->bd_lock);
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 331a0c8..3f8b2c6 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -169,7 +169,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 
 	desc->bd_registered = 1;
 	desc->bd_last_mbits = mbits;
-	desc->bd_md_count = total_md;
+	desc->bd_refs = total_md;
 	md.user_ptr = &desc->bd_cbid;
 	md.handler = ptlrpc_handler;
 	md.threshold = 1;		/* PUT or GET */
@@ -211,9 +211,9 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	if (rc != 0) {
 		LASSERT(rc == -ENOMEM);
 		spin_lock(&desc->bd_lock);
-		desc->bd_md_count -= total_md - posted_md;
+		desc->bd_refs -= total_md - posted_md;
 		spin_unlock(&desc->bd_lock);
-		LASSERT(desc->bd_md_count >= 0);
+		LASSERT(desc->bd_refs >= 0);
 		mdunlink_iterate_helper(desc->bd_mds, desc->bd_md_max_brw);
 		req->rq_status = -ENOMEM;
 		desc->bd_registered = 0;
@@ -222,15 +222,15 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 
 	spin_lock(&desc->bd_lock);
 	/* Holler if peer manages to touch buffers before he knows the mbits */
-	if (desc->bd_md_count != total_md)
+	if (desc->bd_refs != total_md)
 		CWARN("%s: Peer %s touched %d buffers while I registered\n",
 		      desc->bd_import->imp_obd->obd_name, libcfs_id2str(peer),
-		      total_md - desc->bd_md_count);
+		      total_md - desc->bd_refs);
 	spin_unlock(&desc->bd_lock);
 
 	CDEBUG(D_NET,
 	       "Setup %u bulk %s buffers: %u pages %u bytes, mbits x%#llx-%#llx, portal %u\n",
-	       desc->bd_md_count,
+	       desc->bd_refs,
 	       ptlrpc_is_bulk_op_get(desc->bd_type) ? "get-source" : "put-sink",
 	       desc->bd_iov_count, desc->bd_nob,
 	       desc->bd_last_mbits, req->rq_mbits, desc->bd_portal);
-- 
1.8.3.1
