Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6E7C7C0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:51:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLnX6kYTz22V4;
	Thu, 30 Jan 2025 06:22:08 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLdJ3wrvz214y
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:15:00 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 32EAB18236F;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 2FE38106BE18; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:10 -0500
Message-ID: <20250130141115.950749-21-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 20/25] lustre: ptlrpc: retry mechanism for
 overflowed batched RPCs
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

Before send the batched RPC, the client has no idea about the
actual reply buffer size. The reply buffer size prepared by a
client may be smalller than the reply buffer buffer size in need.
We already have the patch to grow the reply buffer properly in
most cases.

However, when the reply buffer size is growing larger than
BUT_MAXREPSIZE (1000 * 1024), the server will return -EOVERFLOW
error code. At this time, the server only executed the partial
sub requests in the batched RPC. The overflowed sub requests are
not handled.

In this patch, it adds a retry mechanism for overflowed batched
RPC. When found that the reply buffer overflowed, the client will
rebuild the batched RPC for the unhandled sub requests, and use
work queue mechanism to resend the new batched RPC to the server
to re-execute then again.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15550
Lustre-commit: 668f48f87bec39998 ("LU-15550 ptlrpc: retry mechanism for overflowed batched RPCs")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/46540
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/batch.c | 146 +++++++++++++++++++++++++++++++++++++--
 1 file changed, 140 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/ptlrpc/batch.c b/fs/lustre/ptlrpc/batch.c
index 83342c7b3605..77e3261862e0 100644
--- a/fs/lustre/ptlrpc/batch.c
+++ b/fs/lustre/ptlrpc/batch.c
@@ -43,6 +43,17 @@
 
 #define OUT_UPDATE_REPLY_SIZE          4096
 
+static inline struct lustre_msg *
+batch_update_reqmsg_next(struct batch_update_request *bur,
+			 struct lustre_msg *reqmsg)
+{
+	if (reqmsg)
+		return (struct lustre_msg *)((char *)reqmsg +
+					     lustre_packed_msg_size(reqmsg));
+	else
+		return &bur->burq_reqmsg[0];
+}
+
 static inline struct lustre_msg *
 batch_update_repmsg_next(struct batch_update_reply *bur,
 			 struct lustre_msg *repmsg)
@@ -65,6 +76,12 @@ struct batch_update_args {
 	struct batch_update_head	*ba_head;
 };
 
+struct batch_work_resend {
+	struct work_struct		 bwr_work;
+	struct batch_update_head	*bwr_head;
+	int				 bwr_index;
+};
+
 /**
  * Prepare inline update request
  *
@@ -325,6 +342,8 @@ static void batch_update_request_destroy(struct batch_update_head *head)
 	kfree(head);
 }
 
+static void cli_batch_resend_work(struct work_struct *data);
+
 static int batch_update_request_fini(struct batch_update_head *head,
 				     struct ptlrpc_request *req,
 				     struct batch_update_reply *reply, int rc)
@@ -340,8 +359,6 @@ static int batch_update_request_fini(struct batch_update_head *head,
 	list_for_each_entry_safe(ouc, next, &head->buh_cb_list, ouc_item) {
 		int rc1 = 0;
 
-		list_del_init(&ouc->ouc_item);
-
 		/*
 		 * The peer may only have handled some requests (indicated by
 		 * @count) in the packaged OUT PRC, we can only get results
@@ -364,8 +381,24 @@ static int batch_update_request_fini(struct batch_update_head *head,
 			 * TODO: resend the unfinished sub request when the
 			 * return code is -EOVERFLOW.
 			 */
+			if (rc == -EOVERFLOW) {
+				struct batch_work_resend *work;
+
+				work = kmalloc(sizeof(*work), GFP_ATOMIC);
+				if (!work) {
+					rc1 = -ENOMEM;
+				} else {
+					INIT_WORK(&work->bwr_work,
+						  cli_batch_resend_work);
+					work->bwr_head = head;
+					work->bwr_index = index;
+					schedule_work(&work->bwr_work);
+					return 0;
+				}
+			}
 		}
 
+		list_del_init(&ouc->ouc_item);
 		if (ouc->ouc_interpret)
 			ouc->ouc_interpret(req, repmsg, ouc, rc1);
 
@@ -413,6 +446,7 @@ static int batch_send_update_req(const struct lu_env *env,
 	struct ptlrpc_request *req = NULL;
 	struct batch_update_args *aa;
 	struct lu_batch *bh;
+	u32 flags = 0;
 	int rc;
 
 	if (!head)
@@ -420,6 +454,9 @@ static int batch_send_update_req(const struct lu_env *env,
 
 	obd = class_exp2obd(head->buh_exp);
 	bh = head->buh_batch;
+	if (bh)
+		flags = bh->lbt_flags;
+
 	rc = batch_prep_update_req(head, &req);
 	if (rc) {
 		rc = batch_update_request_fini(head, NULL, NULL, rc);
@@ -434,16 +471,16 @@ static int batch_send_update_req(const struct lu_env *env,
 	 * Only acquire modification RPC slot for the batched RPC
 	 * which contains metadata updates.
 	 */
-	if (!(bh->lbt_flags & BATCH_FL_RDONLY))
+	if (!(flags & BATCH_FL_RDONLY))
 		ptlrpc_get_mod_rpc_slot(req);
 
-	if (bh->lbt_flags & BATCH_FL_SYNC) {
+	if (flags & BATCH_FL_SYNC) {
 		rc = ptlrpc_queue_wait(req);
 	} else {
-		if ((bh->lbt_flags & (BATCH_FL_RDONLY | BATCH_FL_RQSET)) ==
+		if ((flags & (BATCH_FL_RDONLY | BATCH_FL_RQSET)) ==
 		    BATCH_FL_RDONLY) {
 			ptlrpcd_add_req(req);
-		} else if (bh->lbt_flags & BATCH_FL_RQSET) {
+		} else if (flags & BATCH_FL_RQSET) {
 			ptlrpc_set_add_req(bh->lbt_rqset, req);
 			ptlrpc_check_set(env, bh->lbt_rqset);
 		} else {
@@ -522,6 +559,103 @@ static int batch_update_request_add(struct batch_update_head **headp,
 	return rc;
 }
 
+static void cli_batch_resend_work(struct work_struct *data)
+{
+	struct batch_work_resend *work = container_of(data,
+					struct batch_work_resend, bwr_work);
+	struct batch_update_head *obuh = work->bwr_head;
+	struct object_update_callback *ouc;
+	struct batch_update_head *head;
+	struct batch_update_buffer *buf;
+	struct batch_update_buffer *tmp;
+	int index = work->bwr_index;
+	int rc = 0;
+	int i = 0;
+
+	head = batch_update_request_create(obuh->buh_exp, NULL);
+	if (!head) {
+		rc = -ENOMEM;
+		goto err_up;
+	}
+
+	list_for_each_entry_safe(buf, tmp, &obuh->buh_buf_list, bub_item) {
+		struct batch_update_request *bur = buf->bub_req;
+		struct batch_update_buffer *newbuf;
+		struct lustre_msg *reqmsg = NULL;
+		size_t max_len;
+		int j;
+
+		if (i + bur->burq_count < index) {
+			i += bur->burq_count;
+			continue;
+		}
+
+		/* reused the allocated buffer */
+		if (i >= index) {
+			list_move_tail(&buf->bub_item, &head->buh_buf_list);
+			head->buh_update_count += buf->bub_req->burq_count;
+			head->buh_buf_count++;
+			continue;
+		}
+
+		for (j = 0; j < bur->burq_count; j++) {
+			struct lustre_msg *newmsg;
+			u32 msgsz;
+
+			reqmsg = batch_update_reqmsg_next(bur, reqmsg);
+			if (i + j < index)
+				continue;
+repeat:
+			newbuf = current_batch_update_buffer(head);
+			LASSERT(newbuf);
+			max_len = newbuf->bub_size - newbuf->bub_end;
+			newmsg = (struct lustre_msg *)((char *)newbuf->bub_req +
+						       newbuf->bub_end);
+			msgsz = lustre_packed_msg_size(reqmsg);
+			if (msgsz >= max_len) {
+				int rc2;
+
+				/* Create new batch update buffer */
+				rc2 = batch_update_buffer_create(head, msgsz +
+					offsetof(struct batch_update_request,
+						 burq_reqmsg[0]) + 1);
+				if (rc2 != 0) {
+					rc = rc2;
+					goto err_up;
+				}
+				goto repeat;
+			}
+
+			memcpy(newmsg, reqmsg, msgsz);
+			newbuf->bub_end += msgsz;
+			newbuf->bub_req->burq_count++;
+			head->buh_update_count++;
+		}
+
+		i = index;
+	}
+
+	list_splice_init(&obuh->buh_cb_list, &head->buh_cb_list);
+	list_for_each_entry(ouc, &head->buh_cb_list, ouc_item)
+		ouc->ouc_head = head;
+
+	head->buh_repsize = BUT_MAXREPSIZE - SPTLRPC_MAX_PAYLOAD;
+	rc = batch_send_update_req(NULL, head);
+	if (rc)
+		goto err_up;
+
+	batch_update_request_destroy(obuh);
+	kfree(work);
+	return;
+
+err_up:
+	batch_update_request_fini(obuh, NULL, NULL, rc);
+	if (head)
+		batch_update_request_fini(head, NULL, NULL, rc);
+
+	kfree(work);
+}
+
 struct lu_batch *cli_batch_create(struct obd_export *exp,
 				  enum lu_batch_flags flags, u32 max_count)
 {
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
