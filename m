From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:49 -0400
Subject: [lustre-devel] [PATCH 10/22] lnet: always pass struct lnet_md by
 reference.
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Both LNetMDAttach and LNetMDBind expected a struct lnet_md to be
passed by value.  This requires copying the data structure onto the
stack, which is a waste of stack space and brings no value.

So change them to expect a reference, and declare it 'const' to be
sure it doesn't get changed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13004
Lustre-commit: fb3ed0fe68e32 ("LU-13004 lnet: always pass struct lnet_md by reference.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37853
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c |  8 ++++----
 include/linux/lnet/api.h  |  4 ++--
 net/lnet/lnet/api-ni.c    |  6 +++---
 net/lnet/lnet/lib-md.c    | 24 ++++++++++++------------
 net/lnet/lnet/lib-move.c  |  2 +-
 net/lnet/lnet/peer.c      |  2 +-
 net/lnet/selftest/rpc.c   |  4 ++--
 7 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index c59fc7f..d62629a 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -74,7 +74,7 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 		/* don't ask for the ack to simulate failing client */
 		ack = LNET_NOACK_REQ;
 
-	rc = LNetMDBind(md, LNET_UNLINK, mdh);
+	rc = LNetMDBind(&md, LNET_UNLINK, mdh);
 	if (unlikely(rc != 0)) {
 		CERROR("LNetMDBind failed: %d\n", rc);
 		LASSERT(rc == -ENOMEM);
@@ -197,7 +197,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 		percpu_ref_get(&ptlrpc_pending);
 
 		/* About to let the network at it... */
-		rc = LNetMDAttach(me, md, LNET_UNLINK,
+		rc = LNetMDAttach(me, &md, LNET_UNLINK,
 				  &desc->bd_mds[posted_md]);
 		if (rc != 0) {
 			CERROR("%s: LNetMDAttach failed x%llu/%d: rc = %d\n",
@@ -656,7 +656,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		/* We must see the unlink callback to set rq_reply_unlinked,
 		 * so we can't auto-unlink
 		 */
-		rc = LNetMDAttach(reply_me, reply_md, LNET_RETAIN,
+		rc = LNetMDAttach(reply_me, &reply_md, LNET_RETAIN,
 				  &request->rq_reply_md_h);
 		if (rc != 0) {
 			CERROR("LNetMDAttach failed: %d\n", rc);
@@ -786,7 +786,7 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	md.user_ptr = &rqbd->rqbd_cbid;
 	md.handler = ptlrpc_handler;
 
-	rc = LNetMDAttach(me, md, LNET_UNLINK, &rqbd->rqbd_md_h);
+	rc = LNetMDAttach(me, &md, LNET_UNLINK, &rqbd->rqbd_md_h);
 	if (rc == 0) {
 		percpu_ref_get(&ptlrpc_pending);
 		return 0;
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index bdfc8d3..24115eb 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -119,11 +119,11 @@ struct lnet_me *
  * @{
  */
 int LNetMDAttach(struct lnet_me *current_in,
-		 struct lnet_md md_in,
+		 const struct lnet_md *md_in,
 		 enum lnet_unlink unlink_in,
 		 struct lnet_handle_md *md_handle_out);
 
-int LNetMDBind(struct lnet_md md_in,
+int LNetMDBind(const struct lnet_md *md_in,
 	       enum lnet_unlink unlink_in,
 	       struct lnet_handle_md *md_handle_out);
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 629a597..6f19e63 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1646,7 +1646,7 @@ struct lnet_ping_buffer *
 	md.handler = the_lnet.ln_ping_target_handler;
 	md.user_ptr = *ppbuf;
 
-	rc = LNetMDAttach(me, md, LNET_RETAIN, ping_mdh);
+	rc = LNetMDAttach(me, &md, LNET_RETAIN, ping_mdh);
 	if (rc) {
 		CERROR("Can't attach ping target MD: %d\n", rc);
 		goto fail_unlink_ping_me;
@@ -1856,7 +1856,7 @@ int lnet_push_target_post(struct lnet_ping_buffer *pbuf,
 	md.user_ptr = pbuf;
 	md.handler = the_lnet.ln_push_target_handler;
 
-	rc = LNetMDAttach(me, md, LNET_UNLINK, mdhp);
+	rc = LNetMDAttach(me, &md, LNET_UNLINK, mdhp);
 	if (rc) {
 		CERROR("Can't attach push MD: %d\n", rc);
 		LNetMEUnlink(me);
@@ -4066,7 +4066,7 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 
 	init_completion(&pd.completion);
 
-	rc = LNetMDBind(md, LNET_UNLINK, &pd.mdh);
+	rc = LNetMDBind(&md, LNET_UNLINK, &pd.mdh);
 	if (rc) {
 		CERROR("Can't bind MD: %d\n", rc);
 		goto fail_ping_buffer_decref;
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index cfa285a..e80dc6f 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -124,7 +124,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 }
 
 static struct lnet_libmd *
-lnet_md_build(struct lnet_md *umd, int unlink)
+lnet_md_build(const struct lnet_md *umd, int unlink)
 {
 	int i;
 	unsigned int niov;
@@ -269,7 +269,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 }
 
 static int
-lnet_md_validate(struct lnet_md *umd)
+lnet_md_validate(const struct lnet_md *umd)
 {
 	if (!umd->start && umd->length) {
 		CERROR("MD start pointer can not be NULL with length %u\n",
@@ -314,7 +314,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
  *		a MD.
  */
 int
-LNetMDAttach(struct lnet_me *me, struct lnet_md umd,
+LNetMDAttach(struct lnet_me *me, const struct lnet_md *umd,
 	     enum lnet_unlink unlink, struct lnet_handle_md *handle)
 {
 	LIST_HEAD(matches);
@@ -325,15 +325,15 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 	LASSERT(the_lnet.ln_refcount > 0);
 
-	if (lnet_md_validate(&umd))
+	if (lnet_md_validate(umd))
 		return -EINVAL;
 
-	if (!(umd.options & (LNET_MD_OP_GET | LNET_MD_OP_PUT))) {
+	if (!(umd->options & (LNET_MD_OP_GET | LNET_MD_OP_PUT))) {
 		CERROR("Invalid option: no MD_OP set\n");
 		return -EINVAL;
 	}
 
-	md = lnet_md_build(&umd, unlink);
+	md = lnet_md_build(umd, unlink);
 	if (IS_ERR(md))
 		return PTR_ERR(md);
 
@@ -344,7 +344,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	if (me->me_md)
 		rc = -EBUSY;
 	else
-		rc = lnet_md_link(md, umd.handler, cpt);
+		rc = lnet_md_link(md, umd->handler, cpt);
 
 	if (rc)
 		goto out_unlock;
@@ -388,7 +388,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
  *			calling LNetInvalidateHandle() on it.
  */
 int
-LNetMDBind(struct lnet_md umd, enum lnet_unlink unlink,
+LNetMDBind(const struct lnet_md *umd, enum lnet_unlink unlink,
 	   struct lnet_handle_md *handle)
 {
 	struct lnet_libmd *md;
@@ -397,15 +397,15 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 	LASSERT(the_lnet.ln_refcount > 0);
 
-	if (lnet_md_validate(&umd))
+	if (lnet_md_validate(umd))
 		return -EINVAL;
 
-	if ((umd.options & (LNET_MD_OP_GET | LNET_MD_OP_PUT))) {
+	if ((umd->options & (LNET_MD_OP_GET | LNET_MD_OP_PUT))) {
 		CERROR("Invalid option: GET|PUT illegal on active MDs\n");
 		return -EINVAL;
 	}
 
-	md = lnet_md_build(&umd, unlink);
+	md = lnet_md_build(umd, unlink);
 	if (IS_ERR(md))
 		return PTR_ERR(md);
 
@@ -418,7 +418,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 
 	cpt = lnet_res_lock_current();
 
-	rc = lnet_md_link(md, umd.handler, cpt);
+	rc = lnet_md_link(md, umd->handler, cpt);
 	if (rc)
 		goto out_unlock;
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 51b8191..2f3ef8c 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3305,7 +3305,7 @@ struct lnet_mt_event_info {
 	md.user_ptr = user_data;
 	md.handler = handler;
 
-	rc = LNetMDBind(md, LNET_UNLINK, mdh);
+	rc = LNetMDBind(&md, LNET_UNLINK, mdh);
 	if (rc) {
 		lnet_ping_buffer_decref(pbuf);
 		CERROR("Can't bind MD: %d\n", rc);
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index ae70033..b2065bd 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3073,7 +3073,7 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	md.handler = the_lnet.ln_dc_handler;
 	md.user_ptr = lp;
 
-	rc = LNetMDBind(md, LNET_UNLINK, &lp->lp_push_mdh);
+	rc = LNetMDBind(&md, LNET_UNLINK, &lp->lp_push_mdh);
 	if (rc) {
 		lnet_ping_buffer_decref(pbuf);
 		CERROR("Can't bind push source MD: %d\n", rc);
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index e8667b1..799ad99 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -378,7 +378,7 @@ struct srpc_bulk *
 	md.options = options;
 	md.handler = srpc_data.rpc_lnet_handler;
 
-	rc = LNetMDAttach(me, md, LNET_UNLINK, mdh);
+	rc = LNetMDAttach(me, &md, LNET_UNLINK, mdh);
 	if (rc) {
 		CERROR("LNetMDAttach failed: %d\n", rc);
 		LASSERT(rc == -ENOMEM);
@@ -409,7 +409,7 @@ struct srpc_bulk *
 	md.threshold = options & LNET_MD_OP_GET ? 2 : 1;
 	md.options = options & ~(LNET_MD_OP_PUT | LNET_MD_OP_GET);
 
-	rc = LNetMDBind(md, LNET_UNLINK, mdh);
+	rc = LNetMDBind(&md, LNET_UNLINK, mdh);
 	if (rc) {
 		CERROR("LNetMDBind failed: %d\n", rc);
 		LASSERT(rc == -ENOMEM);
-- 
1.8.3.1
