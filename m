Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 86581C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:15:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWHG71nnz1yBY;
	Sun,  9 Apr 2023 05:14:02 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWGd6d3Gz1wYq
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:13:29 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C8096100826D;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B90712B2; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:41 -0400
Message-Id: <1681042400-15491-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/40] lustre: protocol: basic batching
 processing framework
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

Batching processing can obtain boost performace. The larger the
batch size, the higher the latency for the entire batch. Although
the latency for the entire batch of operations is higher than the
latency of any single operation, the throughput of the batch of
operations is much high.

This patch implements the basic batching processing framework for
Lustre. It could be used for the future batching statahead and
WBC.

A batched RPC does not require that the opcodes of sub requests in
a batch are same. Each sub request has its own opcode. It allows
batching not only read-only requests but also multiple
modification updates with different opcodes, and even a mixed
workload which contains both read-only requests and modification
updates.

For the recovery, only the batched RPC contains a client XID,
there is no separate client XID for each sub-request. Although the
server will generate a transno for each update sub request, but
the transno only stores into the batched RPC (in @ptlrpc_body)
when the sub update request is finished. Thus the batched RPC only
stores the transno of the last sub update request. Only the
batched RPC contains the @ptlrpc_body message field. Each sub
request in a batched RPC does not contain @ptlrpc_body field.

A new field named @lrd_batch_idx is added in the client reply data
@lsd_reply_data. It indicates the sub request index in a batched
RPC. When the server finished a sub update request, it will update
@lrd_batch_idx accordingly.
When found that a batched RPC was a resend RPC, and if the index
of the sub request in the batched RPC is smaller or equal than
@lrd_batch_idx in the reply data, it means that the sub request has
already executed and committed, the server will reconstruct the
reply for this sub request; if the index is larger than
@lrd_batch_idx, the server will re-execute the sub request in the
batched RPC.

To simplify the reply/resend of the batched RPCs, the batch
processing stops at the first failure in the current design.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14393
Lustre-commit: 840274b5c5e95e44a ("LU-14393 protocol: basic batching processing framework")
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/41378
Lustre-commit: 178988d67aa2f83aa ("LU-14393 recovery: reply reconstruction for batched RPCs")
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48228
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h         |  43 +++
 fs/lustre/include/lustre_req_layout.h  |  28 +-
 fs/lustre/include/lustre_swab.h        |   3 +
 fs/lustre/include/obd.h                |  78 +++++
 fs/lustre/include/obd_class.h          |  48 +++
 fs/lustre/lmv/lmv_internal.h           |  12 +
 fs/lustre/lmv/lmv_obd.c                | 173 ++++++++++
 fs/lustre/mdc/Makefile                 |   2 +-
 fs/lustre/mdc/mdc_batch.c              |  62 ++++
 fs/lustre/mdc/mdc_internal.h           |   3 +
 fs/lustre/mdc/mdc_request.c            |   4 +
 fs/lustre/ptlrpc/Makefile              |   2 +-
 fs/lustre/ptlrpc/batch.c               | 588 +++++++++++++++++++++++++++++++++
 fs/lustre/ptlrpc/client.c              |  25 ++
 fs/lustre/ptlrpc/layout.c              | 126 ++++++-
 fs/lustre/ptlrpc/lproc_ptlrpc.c        |   1 +
 fs/lustre/ptlrpc/pack_generic.c        |  27 +-
 fs/lustre/ptlrpc/wiretest.c            |  12 +-
 include/uapi/linux/lustre/lustre_idl.h |  82 ++++-
 19 files changed, 1280 insertions(+), 39 deletions(-)
 create mode 100644 fs/lustre/mdc/mdc_batch.c
 create mode 100644 fs/lustre/ptlrpc/batch.c

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 1605fcc..1ffe9f7 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1161,6 +1161,13 @@ struct ptlrpc_bulk_frag_ops {
 			      struct page *page, int pageoffset, int len);
 
 	/**
+	 * Add a @fragment to the bulk descriptor @desc.
+	 * Data to transfer in the fragment is pointed to by @frag
+	 * The size of the fragment is @len
+	 */
+	int (*add_iov_frag)(struct ptlrpc_bulk_desc *desc, void *frag, int len);
+
+	/**
 	 * Uninitialize and free bulk descriptor @desc.
 	 * Works on bulk descriptors both from server and client side.
 	 */
@@ -1170,6 +1177,42 @@ struct ptlrpc_bulk_frag_ops {
 extern const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_pin_ops;
 extern const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_nopin_ops;
 
+static inline bool req_capsule_ptlreq(struct req_capsule *pill)
+{
+	struct ptlrpc_request *req = pill->rc_req;
+
+	return req && pill == &req->rq_pill;
+}
+
+static inline bool req_capsule_subreq(struct req_capsule *pill)
+{
+	struct ptlrpc_request *req = pill->rc_req;
+
+	return !req || pill != &req->rq_pill;
+}
+
+/**
+ * Returns true if request needs to be swabbed into local cpu byteorder
+ */
+static inline bool req_capsule_req_need_swab(struct req_capsule *pill)
+{
+	struct ptlrpc_request *req = pill->rc_req;
+
+	return req && req_capsule_req_swabbed(&req->rq_pill,
+					      MSG_PTLRPC_HEADER_OFF);
+}
+
+/**
+ * Returns true if request reply needs to be swabbed into local cpu byteorder
+ */
+static inline bool req_capsule_rep_need_swab(struct req_capsule *pill)
+{
+	struct ptlrpc_request *req = pill->rc_req;
+
+	return req && req_capsule_rep_swabbed(&req->rq_pill,
+					      MSG_PTLRPC_HEADER_OFF);
+}
+
 /**
  * Definition of bulk descriptor.
  * Bulks are special "Two phase" RPCs where initial request message
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 9f22134b..a7ed89b 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -82,7 +82,9 @@ void req_capsule_init(struct req_capsule *pill, struct ptlrpc_request *req,
 void req_capsule_set(struct req_capsule *pill, const struct req_format *fmt);
 size_t req_capsule_filled_sizes(struct req_capsule *pill,
 				enum req_location loc);
-int  req_capsule_server_pack(struct req_capsule *pill);
+int req_capsule_server_pack(struct req_capsule *pill);
+int req_capsule_client_pack(struct req_capsule *pill);
+void req_capsule_set_replen(struct req_capsule *pill);
 
 void *req_capsule_client_get(struct req_capsule *pill,
 			     const struct req_msg_field *field);
@@ -150,22 +152,6 @@ static inline bool req_capsule_rep_swabbed(struct req_capsule *pill,
 }
 
 /**
- * Returns true if request needs to be swabbed into local cpu byteorder
- */
-static inline bool req_capsule_req_need_swab(struct req_capsule *pill)
-{
-	return req_capsule_req_swabbed(pill, MSG_PTLRPC_HEADER_OFF);
-}
-
-/**
- * Returns true if request reply needs to be swabbed into local cpu byteorder
- */
-static inline bool req_capsule_rep_need_swab(struct req_capsule *pill)
-{
-	return req_capsule_rep_swabbed(pill, MSG_PTLRPC_HEADER_OFF);
-}
-
-/**
  * Mark request buffer at offset \a index that it was already swabbed
  */
 static inline void req_capsule_set_req_swabbed(struct req_capsule *pill,
@@ -295,6 +281,14 @@ static inline void req_capsule_set_rep_swabbed(struct req_capsule *pill,
 
 extern struct req_format RQF_CONNECT;
 
+/* Batch UpdaTe req_format */
+extern struct req_format RQF_MDS_BATCH;
+
+/* Batch UpdaTe format */
+extern struct req_msg_field RMF_BUT_REPLY;
+extern struct req_msg_field RMF_BUT_HEADER;
+extern struct req_msg_field RMF_BUT_BUF;
+
 extern struct req_msg_field RMF_GENERIC_DATA;
 extern struct req_msg_field RMF_PTLRPC_BODY;
 extern struct req_msg_field RMF_MDT_BODY;
diff --git a/fs/lustre/include/lustre_swab.h b/fs/lustre/include/lustre_swab.h
index 000e622..eda3532 100644
--- a/fs/lustre/include/lustre_swab.h
+++ b/fs/lustre/include/lustre_swab.h
@@ -96,6 +96,9 @@ void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 void lustre_swab_hsm_user_state(struct hsm_user_state *hus);
 void lustre_swab_hsm_user_item(struct hsm_user_item *hui);
 void lustre_swab_hsm_request(struct hsm_request *hr);
+void lustre_swab_but_update_header(struct but_update_header *buh);
+void lustre_swab_but_update_buffer(struct but_update_buffer *bub);
+void lustre_swab_batch_update_reply(struct batch_update_reply *bur);
 void lustre_swab_swap_layouts(struct mdc_swap_layouts *msl);
 void lustre_swab_close_data(struct close_data *data);
 void lustre_swab_close_data_resync_done(struct close_data_resync_done *resync);
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index e9752a3..a980bf0 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -835,7 +835,14 @@ struct md_readdir_info {
 struct md_op_item;
 typedef int (*md_op_item_cb_t)(struct md_op_item *item, int rc);
 
+enum md_item_opcode {
+	MD_OP_NONE	= 0,
+	MD_OP_GETATTR	= 1,
+	MD_OP_MAX,
+};
+
 struct md_op_item {
+	enum md_item_opcode		 mop_opc;
 	struct md_op_data		 mop_data;
 	struct lookup_intent		 mop_it;
 	struct lustre_handle		 mop_lockh;
@@ -847,6 +854,69 @@ struct md_op_item {
 	struct work_struct		 mop_work;
 };
 
+enum lu_batch_flags {
+	BATCH_FL_NONE	= 0x0,
+	/* All requests in a batch are read-only. */
+	BATCH_FL_RDONLY	= 0x1,
+	/* Will create PTLRPC request set for the batch. */
+	BATCH_FL_RQSET	= 0x2,
+	/* Whether need sync commit. */
+	BATCH_FL_SYNC	= 0x4,
+};
+
+struct lu_batch {
+	struct ptlrpc_request_set	*lbt_rqset;
+	__s32				 lbt_result;
+	__u32				 lbt_flags;
+	/* Max batched SUB requests count in a batch. */
+	__u32				 lbt_max_count;
+};
+
+struct batch_update_head {
+	struct obd_export	*buh_exp;
+	struct lu_batch		*buh_batch;
+	int			 buh_flags;
+	__u32			 buh_count;
+	__u32			 buh_update_count;
+	__u32			 buh_buf_count;
+	__u32			 buh_reqsize;
+	__u32			 buh_repsize;
+	__u32			 buh_batchid;
+	struct list_head	 buh_buf_list;
+	struct list_head	 buh_cb_list;
+};
+
+struct object_update_callback;
+typedef int (*object_update_interpret_t)(struct ptlrpc_request *req,
+					 struct lustre_msg *repmsg,
+					 struct object_update_callback *ouc,
+					 int rc);
+
+struct object_update_callback {
+	struct list_head		 ouc_item;
+	object_update_interpret_t	 ouc_interpret;
+	struct batch_update_head	*ouc_head;
+	void				*ouc_data;
+};
+
+typedef int (*md_update_pack_t)(struct batch_update_head *head,
+				struct lustre_msg *reqmsg,
+				size_t *max_pack_size,
+				struct md_op_item *item);
+
+struct cli_batch {
+	struct lu_batch			  cbh_super;
+	struct batch_update_head	 *cbh_head;
+};
+
+struct lu_batch *cli_batch_create(struct obd_export *exp,
+				  enum lu_batch_flags flags, __u32 max_count);
+int cli_batch_stop(struct obd_export *exp, struct lu_batch *bh);
+int cli_batch_flush(struct obd_export *exp, struct lu_batch *bh, bool wait);
+int cli_batch_add(struct obd_export *exp, struct lu_batch *bh,
+		  struct md_op_item *item, md_update_pack_t packer,
+		  object_update_interpret_t interpreter);
+
 struct obd_ops {
 	struct module *owner;
 	int (*iocontrol)(unsigned int cmd, struct obd_export *exp, int len,
@@ -1086,6 +1156,14 @@ struct md_ops {
 			const union lmv_mds_md *lmv, size_t lmv_size);
 	int (*rmfid)(struct obd_export *exp, struct fid_array *fa, int *rcs,
 		     struct ptlrpc_request_set *set);
+	struct lu_batch *(*batch_create)(struct obd_export *exp,
+					 enum lu_batch_flags flags,
+					 u32 max_count);
+	int (*batch_stop)(struct obd_export *exp, struct lu_batch *bh);
+	int (*batch_flush)(struct obd_export *exp, struct lu_batch *bh,
+			   bool wait);
+	int (*batch_add)(struct obd_export *exp, struct lu_batch *bh,
+			 struct md_op_item *item);
 };
 
 static inline struct md_open_data *obd_mod_alloc(void)
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 81ef59e..e4ad600 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1673,6 +1673,54 @@ static inline int md_rmfid(struct obd_export *exp, struct fid_array *fa,
 	return MDP(exp->exp_obd, rmfid)(exp, fa, rcs, set);
 }
 
+static inline struct lu_batch *
+md_batch_create(struct obd_export *exp, enum lu_batch_flags flags,
+		__u32 max_count)
+{
+	int rc;
+
+	rc = exp_check_ops(exp);
+	if (rc)
+		return ERR_PTR(rc);
+
+	return MDP(exp->exp_obd, batch_create)(exp, flags, max_count);
+}
+
+static inline int md_batch_stop(struct obd_export *exp, struct lu_batch *bh)
+{
+	int rc;
+
+	rc = exp_check_ops(exp);
+	if (rc)
+		return rc;
+
+	return MDP(exp->exp_obd, batch_stop)(exp, bh);
+}
+
+static inline int md_batch_flush(struct obd_export *exp, struct lu_batch *bh,
+				 bool wait)
+{
+	int rc;
+
+	rc = exp_check_ops(exp);
+	if (rc)
+		return rc;
+
+	return MDP(exp->exp_obd, batch_flush)(exp, bh, wait);
+}
+
+static inline int md_batch_add(struct obd_export *exp, struct lu_batch *bh,
+			       struct md_op_item *item)
+{
+	int rc;
+
+	rc = exp_check_ops(exp);
+	if (rc)
+		return rc;
+
+	return MDP(exp->exp_obd, batch_add)(exp, bh, item);
+}
+
 /* OBD Metadata Support */
 
 int obd_init_caches(void);
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index 9e89f88..64ec4ae 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -42,6 +42,18 @@
 #define LL_IT2STR(it)					\
 	((it) ? ldlm_it2str((it)->it_op) : "0")
 
+struct lmvsub_batch {
+	struct lu_batch		*sbh_sub;
+	struct lmv_tgt_desc	*sbh_tgt;
+	struct list_head	 sbh_sub_item;
+};
+
+struct lmv_batch {
+	struct lu_batch			 lbh_super;
+	struct ptlrpc_request_set	*lbh_rqset;
+	struct list_head		 lbh_sub_batch_list;
+};
+
 int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		    struct lookup_intent *it, struct ptlrpc_request **reqp,
 		    ldlm_blocking_callback cb_blocking,
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 3a02cc1..64d16d8 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3790,6 +3790,175 @@ static int lmv_merge_attr(struct obd_export *exp,
 	return 0;
 }
 
+static struct lu_batch *lmv_batch_create(struct obd_export *exp,
+					 enum lu_batch_flags flags,
+					 __u32 max_count)
+{
+	struct lu_batch *bh;
+	struct lmv_batch *lbh;
+
+	lbh = kzalloc(sizeof(*lbh), GFP_NOFS);
+	if (!lbh)
+		return ERR_PTR(-ENOMEM);
+
+	bh = &lbh->lbh_super;
+	bh->lbt_flags = flags;
+	bh->lbt_max_count = max_count;
+
+	if (flags & BATCH_FL_RQSET) {
+		bh->lbt_rqset = ptlrpc_prep_set();
+		if (!bh->lbt_rqset) {
+			kfree(lbh);
+			return ERR_PTR(-ENOMEM);
+		}
+	}
+
+	INIT_LIST_HEAD(&lbh->lbh_sub_batch_list);
+	return bh;
+}
+
+static int lmv_batch_stop(struct obd_export *exp, struct lu_batch *bh)
+{
+	struct lmv_batch *lbh;
+	struct lmvsub_batch *sub;
+	struct lmvsub_batch *tmp;
+	int rc = 0;
+
+	lbh = container_of(bh, struct lmv_batch, lbh_super);
+	list_for_each_entry_safe(sub, tmp, &lbh->lbh_sub_batch_list,
+				 sbh_sub_item) {
+		list_del(&sub->sbh_sub_item);
+		rc = md_batch_stop(sub->sbh_tgt->ltd_exp, sub->sbh_sub);
+		if (rc < 0) {
+			CERROR("%s: stop batch processing failed: rc = %d\n",
+			       exp->exp_obd->obd_name, rc);
+			if (bh->lbt_result == 0)
+				bh->lbt_result = rc;
+		}
+		kfree(sub);
+	}
+
+	if (bh->lbt_flags & BATCH_FL_RQSET) {
+		rc = ptlrpc_set_wait(NULL, bh->lbt_rqset);
+		ptlrpc_set_destroy(bh->lbt_rqset);
+	}
+
+	kfree(lbh);
+	return rc;
+}
+
+static int lmv_batch_flush(struct obd_export *exp, struct lu_batch *bh,
+			   bool wait)
+{
+	struct lmv_batch *lbh;
+	struct lmvsub_batch *sub;
+	int rc = 0;
+	int rc1;
+
+	lbh = container_of(bh, struct lmv_batch, lbh_super);
+	list_for_each_entry(sub, &lbh->lbh_sub_batch_list, sbh_sub_item) {
+		rc1 = md_batch_flush(sub->sbh_tgt->ltd_exp, sub->sbh_sub, wait);
+		if (rc1 < 0) {
+			CERROR("%s: stop batch processing failed: rc = %d\n",
+			       exp->exp_obd->obd_name, rc);
+			if (bh->lbt_result == 0)
+				bh->lbt_result = rc;
+
+			if (rc == 0)
+				rc = rc1;
+		}
+	}
+
+	if (wait && bh->lbt_flags & BATCH_FL_RQSET) {
+		rc1 = ptlrpc_set_wait(NULL, bh->lbt_rqset);
+		if (rc == 0)
+			rc = rc1;
+	}
+
+	return rc;
+}
+
+static inline struct lmv_tgt_desc *
+lmv_batch_locate_tgt(struct lmv_obd *lmv, struct md_op_item *item)
+{
+	struct lmv_tgt_desc *tgt;
+
+	switch (item->mop_opc) {
+	default:
+		tgt = ERR_PTR(-EOPNOTSUPP);
+	}
+
+	return tgt;
+}
+
+struct lu_batch *lmv_batch_lookup_sub(struct lmv_batch *lbh,
+				      struct lmv_tgt_desc *tgt)
+{
+	struct lmvsub_batch *sub;
+
+	list_for_each_entry(sub, &lbh->lbh_sub_batch_list, sbh_sub_item) {
+		if (sub->sbh_tgt == tgt)
+			return sub->sbh_sub;
+	}
+
+	return NULL;
+}
+
+struct lu_batch *lmv_batch_get_sub(struct lmv_batch *lbh,
+				   struct lmv_tgt_desc *tgt)
+{
+	struct lmvsub_batch *sbh;
+	struct lu_batch *child_bh;
+	struct lu_batch *bh;
+
+	child_bh = lmv_batch_lookup_sub(lbh, tgt);
+	if (child_bh)
+		return child_bh;
+
+	sbh = kzalloc(sizeof(*sbh), GFP_NOFS);
+	if (!sbh)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&sbh->sbh_sub_item);
+	sbh->sbh_tgt = tgt;
+
+	bh = &lbh->lbh_super;
+	child_bh = md_batch_create(tgt->ltd_exp, bh->lbt_flags,
+				   bh->lbt_max_count);
+	if (IS_ERR(child_bh)) {
+		kfree(sbh);
+		return child_bh;
+	}
+
+	child_bh->lbt_rqset = bh->lbt_rqset;
+	sbh->sbh_sub = child_bh;
+	list_add(&sbh->sbh_sub_item, &lbh->lbh_sub_batch_list);
+	return child_bh;
+}
+
+static int lmv_batch_add(struct obd_export *exp, struct lu_batch *bh,
+			 struct md_op_item *item)
+{
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
+	struct lmv_batch *lbh;
+	struct lu_batch *child_bh;
+	int rc;
+
+	tgt = lmv_batch_locate_tgt(lmv, item);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
+	lbh = container_of(bh, struct lmv_batch, lbh_super);
+	child_bh = lmv_batch_get_sub(lbh, tgt);
+	if (IS_ERR(child_bh))
+		return PTR_ERR(child_bh);
+
+	rc = md_batch_add(tgt->ltd_exp, child_bh, item);
+	return rc;
+}
+
 static const struct obd_ops lmv_obd_ops = {
 	.owner			= THIS_MODULE,
 	.setup			= lmv_setup,
@@ -3840,6 +4009,10 @@ static int lmv_merge_attr(struct obd_export *exp,
 	.get_fid_from_lsm	= lmv_get_fid_from_lsm,
 	.unpackmd		= lmv_unpackmd,
 	.rmfid			= lmv_rmfid,
+	.batch_create		= lmv_batch_create,
+	.batch_add		= lmv_batch_add,
+	.batch_stop		= lmv_batch_stop,
+	.batch_flush		= lmv_batch_flush,
 };
 
 static int __init lmv_init(void)
diff --git a/fs/lustre/mdc/Makefile b/fs/lustre/mdc/Makefile
index 1ac97ee..191c400 100644
--- a/fs/lustre/mdc/Makefile
+++ b/fs/lustre/mdc/Makefile
@@ -2,5 +2,5 @@ ccflags-y += -I$(srctree)/$(src)/../include
 
 obj-$(CONFIG_LUSTRE_FS) += mdc.o
 mdc-y := mdc_changelog.o mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
-mdc-y += mdc_dev.o
+mdc-y += mdc_dev.o mdc_batch.o
 mdc-$(CONFIG_LUSTRE_FS_POSIX_ACL) += mdc_acl.o
diff --git a/fs/lustre/mdc/mdc_batch.c b/fs/lustre/mdc/mdc_batch.c
new file mode 100644
index 0000000..496d61e3
--- /dev/null
+++ b/fs/lustre/mdc/mdc_batch.c
@@ -0,0 +1,62 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2020, 2022, DDN Storage Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ */
+/*
+ * lustre/mdc/mdc_batch.c
+ *
+ * Batch Metadata Updating on the client (MDC)
+ *
+ * Author: Qian Yingjin <qian@ddn.com>
+ */
+
+#define DEBUG_SUBSYSTEM S_MDC
+
+#include <linux/module.h>
+#include <lustre_acl.h>
+
+#include "mdc_internal.h"
+
+static md_update_pack_t mdc_update_packers[MD_OP_MAX];
+
+static object_update_interpret_t mdc_update_interpreters[MD_OP_MAX];
+
+int mdc_batch_add(struct obd_export *exp, struct lu_batch *bh,
+		  struct md_op_item *item)
+{
+	enum md_item_opcode opc = item->mop_opc;
+
+	if (opc >= MD_OP_MAX || !mdc_update_packers[opc] ||
+	    !mdc_update_interpreters[opc]) {
+		CERROR("%s: unexpected opcode %d\n",
+		       exp->exp_obd->obd_name, opc);
+		return -EFAULT;
+	}
+
+	return cli_batch_add(exp, bh, item, mdc_update_packers[opc],
+			     mdc_update_interpreters[opc]);
+}
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 2416607..ae12a37 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -132,6 +132,9 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 
 int mdc_intent_getattr_async(struct obd_export *exp, struct md_op_item *item);
 
+int mdc_batch_add(struct obd_export *exp, struct lu_batch *bh,
+		  struct md_op_item *item);
+
 enum ldlm_mode mdc_lock_match(struct obd_export *exp, u64 flags,
 			      const struct lu_fid *fid, enum ldlm_type type,
 			      union ldlm_policy_data *policy,
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index c073da2..643b6ee 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -3023,6 +3023,10 @@ static int mdc_cleanup(struct obd_device *obd)
 	.intent_getattr_async	= mdc_intent_getattr_async,
 	.revalidate_lock	= mdc_revalidate_lock,
 	.rmfid			= mdc_rmfid,
+	.batch_create		= cli_batch_create,
+	.batch_stop		= cli_batch_stop,
+	.batch_flush		= cli_batch_flush,
+	.batch_add		= mdc_batch_add,
 };
 
 dev_t mdc_changelog_dev;
diff --git a/fs/lustre/ptlrpc/Makefile b/fs/lustre/ptlrpc/Makefile
index 3badb05..29287b4 100644
--- a/fs/lustre/ptlrpc/Makefile
+++ b/fs/lustre/ptlrpc/Makefile
@@ -13,7 +13,7 @@ ldlm_objs += $(LDLM)ldlm_pool.o
 ptlrpc_objs := client.o recover.o connection.o niobuf.o pack_generic.o
 ptlrpc_objs += events.o ptlrpc_module.o service.o pinger.o
 ptlrpc_objs += llog_net.o llog_client.o import.o ptlrpcd.o
-ptlrpc_objs += pers.o lproc_ptlrpc.o wiretest.o layout.o
+ptlrpc_objs += pers.o batch.o lproc_ptlrpc.o wiretest.o layout.o
 ptlrpc_objs += sec.o sec_bulk.o sec_gc.o sec_config.o
 ptlrpc_objs += sec_null.o sec_plain.o
 ptlrpc_objs += heap.o nrs.o nrs_fifo.o nrs_delay.o
diff --git a/fs/lustre/ptlrpc/batch.c b/fs/lustre/ptlrpc/batch.c
new file mode 100644
index 0000000..76eb4cf
--- /dev/null
+++ b/fs/lustre/ptlrpc/batch.c
@@ -0,0 +1,588 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2020, 2022, DDN/Whamcloud Storage Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ */
+/*
+ * lustre/ptlrpc/batch.c
+ *
+ * Batch Metadata Updating on the client
+ *
+ * Author: Qian Yingjin <qian@ddn.com>
+ */
+
+#define DEBUG_SUBSYSTEM S_MDC
+
+#include <linux/module.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <obd.h>
+
+#define OUT_UPDATE_REPLY_SIZE          4096
+
+static inline struct lustre_msg *
+batch_update_repmsg_next(struct batch_update_reply *bur,
+			 struct lustre_msg *repmsg)
+{
+	if (repmsg)
+		return (struct lustre_msg *)((char *)repmsg +
+					     lustre_packed_msg_size(repmsg));
+	else
+		return &bur->burp_repmsg[0];
+}
+
+struct batch_update_buffer {
+	struct batch_update_request	*bub_req;
+	size_t				 bub_size;
+	size_t				 bub_end;
+	struct list_head		 bub_item;
+};
+
+struct batch_update_args {
+	struct batch_update_head	*ba_head;
+};
+
+/**
+ * Prepare inline update request
+ *
+ * Prepare BUT update ptlrpc inline request, and the request usuanlly includes
+ * one update buffer, which does not need bulk transfer.
+ */
+static int batch_prep_inline_update_req(struct batch_update_head *head,
+					struct ptlrpc_request *req,
+					int repsize)
+{
+	struct batch_update_buffer *buf;
+	struct but_update_header *buh;
+	int rc;
+
+	buf = list_entry(head->buh_buf_list.next,
+			  struct batch_update_buffer, bub_item);
+	req_capsule_set_size(&req->rq_pill, &RMF_BUT_HEADER, RCL_CLIENT,
+			     buf->bub_end + sizeof(*buh));
+
+	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_BATCH);
+	if (rc != 0)
+		return rc;
+
+	buh = req_capsule_client_get(&req->rq_pill, &RMF_BUT_HEADER);
+	buh->buh_magic = BUT_HEADER_MAGIC;
+	buh->buh_count = 1;
+	buh->buh_inline_length = buf->bub_end;
+	buh->buh_reply_size = repsize;
+	buh->buh_update_count = head->buh_update_count;
+
+	memcpy(buh->buh_inline_data, buf->bub_req, buf->bub_end);
+
+	req_capsule_set_size(&req->rq_pill, &RMF_BUT_REPLY,
+			     RCL_SERVER, repsize);
+
+	ptlrpc_request_set_replen(req);
+	req->rq_request_portal = OUT_PORTAL;
+	req->rq_reply_portal = OSC_REPLY_PORTAL;
+
+	return rc;
+}
+
+static int batch_prep_update_req(struct batch_update_head *head,
+				 struct ptlrpc_request **reqp)
+{
+	struct ptlrpc_request *req;
+	struct ptlrpc_bulk_desc *desc;
+	struct batch_update_buffer *buf;
+	struct but_update_header *buh;
+	struct but_update_buffer *bub;
+	int page_count = 0;
+	int total = 0;
+	int repsize;
+	int rc;
+
+	repsize = head->buh_repsize +
+		  cfs_size_round(offsetof(struct batch_update_reply,
+					  burp_repmsg[0]));
+	if (repsize < OUT_UPDATE_REPLY_SIZE)
+		repsize = OUT_UPDATE_REPLY_SIZE;
+
+	LASSERT(head->buh_buf_count > 0);
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(head->buh_exp),
+				   &RQF_MDS_BATCH);
+	if (!req)
+		return -ENOMEM;
+
+	if (head->buh_buf_count == 1) {
+		buf = list_entry(head->buh_buf_list.next,
+				 struct batch_update_buffer, bub_item);
+
+		/* Check whether it can be packed inline */
+		if (buf->bub_end + sizeof(struct but_update_header) <
+		    OUT_UPDATE_MAX_INLINE_SIZE) {
+			rc = batch_prep_inline_update_req(head, req, repsize);
+			if (rc == 0)
+				*reqp = req;
+			goto out_req;
+		}
+	}
+
+	req_capsule_set_size(&req->rq_pill, &RMF_BUT_HEADER, RCL_CLIENT,
+			     sizeof(struct but_update_header));
+	req_capsule_set_size(&req->rq_pill, &RMF_BUT_BUF, RCL_CLIENT,
+			     head->buh_buf_count * sizeof(*bub));
+
+	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_BATCH);
+	if (rc != 0)
+		goto out_req;
+
+	buh = req_capsule_client_get(&req->rq_pill, &RMF_BUT_HEADER);
+	buh->buh_magic = BUT_HEADER_MAGIC;
+	buh->buh_count = head->buh_buf_count;
+	buh->buh_inline_length = 0;
+	buh->buh_reply_size = repsize;
+	buh->buh_update_count = head->buh_update_count;
+	bub = req_capsule_client_get(&req->rq_pill, &RMF_BUT_BUF);
+	list_for_each_entry(buf, &head->buh_buf_list, bub_item) {
+		bub->bub_size = buf->bub_size;
+		bub++;
+		/* First *and* last might be partial pages, hence +1 */
+		page_count += DIV_ROUND_UP(buf->bub_size, PAGE_SIZE) + 1;
+	}
+
+	req->rq_bulk_write = 1;
+	desc = ptlrpc_prep_bulk_imp(req, page_count,
+				    MD_MAX_BRW_SIZE >> LNET_MTU_BITS,
+				    PTLRPC_BULK_GET_SOURCE,
+				    MDS_BULK_PORTAL,
+				    &ptlrpc_bulk_kiov_nopin_ops);
+	if (!desc) {
+		rc = -ENOMEM;
+		goto out_req;
+	}
+
+	list_for_each_entry(buf, &head->buh_buf_list, bub_item) {
+		desc->bd_frag_ops->add_iov_frag(desc, buf->bub_req,
+						buf->bub_size);
+		total += buf->bub_size;
+	}
+	CDEBUG(D_OTHER, "Total %d in %u\n", total, head->buh_update_count);
+
+	req_capsule_set_size(&req->rq_pill, &RMF_BUT_REPLY,
+			     RCL_SERVER, repsize);
+
+	ptlrpc_request_set_replen(req);
+	req->rq_request_portal = OUT_PORTAL;
+	req->rq_reply_portal = OSC_REPLY_PORTAL;
+	*reqp = req;
+
+out_req:
+	if (rc < 0)
+		ptlrpc_req_finished(req);
+
+	return rc;
+}
+
+static struct batch_update_buffer *
+current_batch_update_buffer(struct batch_update_head *head)
+{
+	if (list_empty(&head->buh_buf_list))
+		return NULL;
+
+	return list_entry(head->buh_buf_list.prev, struct batch_update_buffer,
+			  bub_item);
+}
+
+static int batch_update_buffer_create(struct batch_update_head *head,
+				      size_t size)
+{
+	struct batch_update_buffer *buf;
+	struct batch_update_request *bur;
+
+	buf = kzalloc(sizeof(*buf), GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	LASSERT(size > 0);
+	size = round_up(size, PAGE_SIZE);
+	bur = kvzalloc(size, GFP_KERNEL);
+	if (!bur) {
+		kfree(buf);
+		return -ENOMEM;
+	}
+
+	bur->burq_magic = BUT_REQUEST_MAGIC;
+	bur->burq_count = 0;
+	buf->bub_req = bur;
+	buf->bub_size = size;
+	buf->bub_end = sizeof(*bur);
+	INIT_LIST_HEAD(&buf->bub_item);
+	list_add_tail(&buf->bub_item, &head->buh_buf_list);
+	head->buh_buf_count++;
+
+	return 0;
+}
+
+/**
+ * Destroy an @object_update_callback.
+ */
+static void object_update_callback_fini(struct object_update_callback *ouc)
+{
+	LASSERT(list_empty(&ouc->ouc_item));
+
+	kfree(ouc);
+}
+
+/**
+ * Insert an @object_update_callback into the @batch_update_head.
+ *
+ * Usually each update in @batch_update_head will have one correspondent
+ * callback, and these callbacks will be called in ->rq_interpret_reply.
+ */
+static int
+batch_insert_update_callback(struct batch_update_head *head, void *data,
+			     object_update_interpret_t interpret)
+{
+	struct object_update_callback *ouc;
+
+	ouc = kzalloc(sizeof(*ouc), GFP_KERNEL);
+	if (!ouc)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&ouc->ouc_item);
+	ouc->ouc_interpret = interpret;
+	ouc->ouc_head = head;
+	ouc->ouc_data = data;
+	list_add_tail(&ouc->ouc_item, &head->buh_cb_list);
+
+	return 0;
+}
+
+/**
+ * Allocate and initialize batch update request.
+ *
+ * @batch_update_head is being used to track updates being executed on
+ * this OBD device. The update buffer will be 4K initially, and increased
+ * if needed.
+ */
+static struct batch_update_head *
+batch_update_request_create(struct obd_export *exp, struct lu_batch *bh)
+{
+	struct batch_update_head *head;
+	int rc;
+
+	head = kzalloc(sizeof(*head), GFP_KERNEL);
+	if (!head)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&head->buh_cb_list);
+	INIT_LIST_HEAD(&head->buh_buf_list);
+	head->buh_exp = exp;
+	head->buh_batch = bh;
+
+	rc = batch_update_buffer_create(head, PAGE_SIZE);
+	if (rc != 0) {
+		kfree(head);
+		return ERR_PTR(rc);
+	}
+
+	return head;
+}
+
+static void batch_update_request_destroy(struct batch_update_head *head)
+{
+	struct batch_update_buffer *bub, *tmp;
+
+	if (!head)
+		return;
+
+	list_for_each_entry_safe(bub, tmp, &head->buh_buf_list, bub_item) {
+		list_del(&bub->bub_item);
+		kvfree(bub->bub_req);
+		kfree(bub);
+	}
+
+	kfree(head);
+}
+
+static int batch_update_request_fini(struct batch_update_head *head,
+				     struct ptlrpc_request *req,
+				     struct batch_update_reply *reply, int rc)
+{
+	struct object_update_callback *ouc, *next;
+	struct lustre_msg *repmsg = NULL;
+	int count = 0;
+	int index = 0;
+
+	if (reply)
+		count = reply->burp_count;
+
+	list_for_each_entry_safe(ouc, next, &head->buh_cb_list, ouc_item) {
+		int rc1 = 0;
+
+		list_del_init(&ouc->ouc_item);
+
+		/*
+		 * The peer may only have handled some requests (indicated by
+		 * @count) in the packaged OUT PRC, we can only get results
+		 * for the handled part.
+		 */
+		if (index < count) {
+			repmsg = batch_update_repmsg_next(reply, repmsg);
+			if (!repmsg)
+				rc1 = -EPROTO;
+			else
+				rc1 = repmsg->lm_result;
+		} else {
+			/*
+			 * The peer did not handle these request, let us return
+			 * -ECANCELED to the update interpreter for now.
+			 */
+			repmsg = NULL;
+			rc1 = -ECANCELED;
+		}
+
+		if (ouc->ouc_interpret)
+			ouc->ouc_interpret(req, repmsg, ouc, rc1);
+
+		object_update_callback_fini(ouc);
+		if (rc == 0 && rc1 < 0)
+			rc = rc1;
+	}
+
+	batch_update_request_destroy(head);
+
+	return rc;
+}
+
+static int batch_update_interpret(const struct lu_env *env,
+				  struct ptlrpc_request *req,
+				  void *args, int rc)
+{
+	struct batch_update_args *aa = (struct batch_update_args *)args;
+	struct batch_update_reply *reply = NULL;
+
+	if (!aa->ba_head)
+		return 0;
+
+	ptlrpc_put_mod_rpc_slot(req);
+	/* Unpack the results from the reply message. */
+	if (req->rq_repmsg && req->rq_replied) {
+		reply = req_capsule_server_sized_get(&req->rq_pill,
+						     &RMF_BUT_REPLY,
+						     sizeof(*reply));
+		if ((!reply ||
+		     reply->burp_magic != BUT_REPLY_MAGIC) && rc == 0)
+			rc = -EPROTO;
+	}
+
+	rc = batch_update_request_fini(aa->ba_head, req, reply, rc);
+
+	return rc;
+}
+
+static int batch_send_update_req(const struct lu_env *env,
+				 struct batch_update_head *head)
+{
+	struct lu_batch *bh;
+	struct ptlrpc_request *req = NULL;
+	struct batch_update_args *aa;
+	int rc;
+
+	if (!head)
+		return 0;
+
+	bh = head->buh_batch;
+	rc = batch_prep_update_req(head, &req);
+	if (rc) {
+		rc = batch_update_request_fini(head, NULL, NULL, rc);
+		return rc;
+	}
+
+	aa = ptlrpc_req_async_args(aa, req);
+	aa->ba_head = head;
+	req->rq_interpret_reply = batch_update_interpret;
+
+	/*
+	 * Only acquire modification RPC slot for the batched RPC
+	 * which contains metadata updates.
+	 */
+	if (!(bh->lbt_flags & BATCH_FL_RDONLY))
+		ptlrpc_get_mod_rpc_slot(req);
+
+	if (bh->lbt_flags & BATCH_FL_SYNC) {
+		rc = ptlrpc_queue_wait(req);
+	} else {
+		if ((bh->lbt_flags & (BATCH_FL_RDONLY | BATCH_FL_RQSET)) ==
+		    BATCH_FL_RDONLY) {
+			ptlrpcd_add_req(req);
+		} else if (bh->lbt_flags & BATCH_FL_RQSET) {
+			ptlrpc_set_add_req(bh->lbt_rqset, req);
+			ptlrpc_check_set(env, bh->lbt_rqset);
+		} else {
+			ptlrpcd_add_req(req);
+		}
+		req = NULL;
+	}
+
+	if (req)
+		ptlrpc_req_finished(req);
+
+	return rc;
+}
+
+static int batch_update_request_add(struct batch_update_head **headp,
+				    struct md_op_item *item,
+				    md_update_pack_t packer,
+				    object_update_interpret_t interpreter)
+{
+	struct batch_update_head *head = *headp;
+	struct lu_batch *bh = head->buh_batch;
+	struct batch_update_buffer *buf;
+	struct lustre_msg *reqmsg;
+	size_t max_len;
+	int rc;
+
+	for (; ;) {
+		buf = current_batch_update_buffer(head);
+		LASSERT(buf);
+		max_len = buf->bub_size - buf->bub_end;
+		reqmsg = (struct lustre_msg *)((char *)buf->bub_req +
+						buf->bub_end);
+		rc = packer(head, reqmsg, &max_len, item);
+		if (rc == -E2BIG) {
+			int rc2;
+
+			/* Create new batch object update buffer */
+			rc2 = batch_update_buffer_create(head,
+				max_len + offsetof(struct batch_update_request,
+						   burq_reqmsg[0]) + 1);
+			if (rc2 != 0) {
+				rc = rc2;
+				break;
+			}
+		} else {
+			if (rc == 0) {
+				buf->bub_end += max_len;
+				buf->bub_req->burq_count++;
+				head->buh_update_count++;
+				head->buh_repsize += reqmsg->lm_repsize;
+			}
+			break;
+		}
+	}
+
+	if (rc)
+		goto out;
+
+	rc = batch_insert_update_callback(head, item, interpreter);
+	if (rc)
+		goto out;
+
+	/* Unplug the batch queue if accumulated enough update requests. */
+	if (bh->lbt_max_count && head->buh_update_count >= bh->lbt_max_count) {
+		rc = batch_send_update_req(NULL, head);
+		*headp = NULL;
+	}
+out:
+	if (rc) {
+		batch_update_request_destroy(head);
+		*headp = NULL;
+	}
+
+	return rc;
+}
+
+struct lu_batch *cli_batch_create(struct obd_export *exp,
+				  enum lu_batch_flags flags, u32 max_count)
+{
+	struct cli_batch *cbh;
+	struct lu_batch *bh;
+
+	cbh = kzalloc(sizeof(*cbh), GFP_KERNEL);
+	if (!cbh)
+		return ERR_PTR(-ENOMEM);
+
+	bh = &cbh->cbh_super;
+	bh->lbt_result = 0;
+	bh->lbt_flags = flags;
+	bh->lbt_max_count = max_count;
+
+	cbh->cbh_head = batch_update_request_create(exp, bh);
+	if (IS_ERR(cbh->cbh_head)) {
+		bh = (struct lu_batch *)cbh->cbh_head;
+		kfree(cbh);
+	}
+
+	return bh;
+}
+EXPORT_SYMBOL(cli_batch_create);
+
+int cli_batch_stop(struct obd_export *exp, struct lu_batch *bh)
+{
+	struct cli_batch *cbh;
+	int rc;
+
+	cbh = container_of(bh, struct cli_batch, cbh_super);
+	rc = batch_send_update_req(NULL, cbh->cbh_head);
+
+	kfree(cbh);
+	return rc;
+}
+EXPORT_SYMBOL(cli_batch_stop);
+
+int cli_batch_flush(struct obd_export *exp, struct lu_batch *bh, bool wait)
+{
+	struct cli_batch *cbh;
+	int rc;
+
+	cbh = container_of(bh, struct cli_batch, cbh_super);
+	if (!cbh->cbh_head)
+		return 0;
+
+	rc = batch_send_update_req(NULL, cbh->cbh_head);
+	cbh->cbh_head = NULL;
+
+	return rc;
+}
+EXPORT_SYMBOL(cli_batch_flush);
+
+int cli_batch_add(struct obd_export *exp, struct lu_batch *bh,
+		  struct md_op_item *item, md_update_pack_t packer,
+		  object_update_interpret_t interpreter)
+{
+	struct cli_batch *cbh;
+	int rc;
+
+	cbh = container_of(bh, struct cli_batch, cbh_super);
+	if (!cbh->cbh_head) {
+		cbh->cbh_head = batch_update_request_create(exp, bh);
+		if (IS_ERR(cbh->cbh_head))
+			return PTR_ERR(cbh->cbh_head);
+	}
+
+	rc = batch_update_request_add(&cbh->cbh_head, item,
+				      packer, interpreter);
+
+	return rc;
+}
+EXPORT_SYMBOL(cli_batch_add);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 6c1d98d..c9a8c8f 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -70,6 +70,30 @@ static void ptlrpc_release_bulk_page_pin(struct ptlrpc_bulk_desc *desc)
 		put_page(desc->bd_vec[i].bv_page);
 }
 
+static int ptlrpc_prep_bulk_frag_pages(struct ptlrpc_bulk_desc *desc,
+				       void *frag, int len)
+{
+	unsigned int offset = (unsigned long)frag & ~PAGE_MASK;
+
+	while (len > 0) {
+		int page_len = min_t(unsigned int, PAGE_SIZE - offset,
+				     len);
+		struct page *pg;
+
+		if (is_vmalloc_addr(frag))
+			pg = vmalloc_to_page(frag);
+		else
+			pg = virt_to_page(frag);
+
+		ptlrpc_prep_bulk_page_nopin(desc, pg, offset, page_len);
+		offset = 0;
+		len -= page_len;
+		frag += page_len;
+	}
+
+	return desc->bd_nob;
+}
+
 const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_pin_ops = {
 	.add_kiov_frag		= ptlrpc_prep_bulk_page_pin,
 	.release_frags		= ptlrpc_release_bulk_page_pin,
@@ -79,6 +103,7 @@ static void ptlrpc_release_bulk_page_pin(struct ptlrpc_bulk_desc *desc)
 const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_nopin_ops = {
 	.add_kiov_frag		= ptlrpc_prep_bulk_page_nopin,
 	.release_frags		= NULL,
+	.add_iov_frag		= ptlrpc_prep_bulk_frag_pages,
 };
 EXPORT_SYMBOL(ptlrpc_bulk_kiov_nopin_ops);
 
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 82ec899..0fe74ff 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -561,6 +561,17 @@
 	&RMF_CAPA2
 };
 
+static const struct req_msg_field *mds_batch_client[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_BUT_HEADER,
+	&RMF_BUT_BUF,
+};
+
+static const struct req_msg_field *mds_batch_server[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_BUT_REPLY,
+};
+
 static const struct req_msg_field *llog_origin_handle_create_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_LLOGD_BODY,
@@ -800,6 +811,7 @@
 	&RQF_LLOG_ORIGIN_HANDLE_PREV_BLOCK,
 	&RQF_LLOG_ORIGIN_HANDLE_READ_HEADER,
 	&RQF_CONNECT,
+	&RQF_MDS_BATCH,
 };
 
 struct req_msg_field {
@@ -1222,6 +1234,20 @@ struct req_msg_field RMF_OST_LADVISE =
 		    lustre_swab_ladvise, NULL);
 EXPORT_SYMBOL(RMF_OST_LADVISE);
 
+struct req_msg_field RMF_BUT_REPLY =
+			DEFINE_MSGF("batch_update_reply", 0, -1,
+				    lustre_swab_batch_update_reply, NULL);
+EXPORT_SYMBOL(RMF_BUT_REPLY);
+
+struct req_msg_field RMF_BUT_HEADER = DEFINE_MSGF("but_update_header", 0,
+				-1, lustre_swab_but_update_header, NULL);
+EXPORT_SYMBOL(RMF_BUT_HEADER);
+
+struct req_msg_field RMF_BUT_BUF = DEFINE_MSGF("but_update_buf",
+			RMF_F_STRUCT_ARRAY, sizeof(struct but_update_buffer),
+			lustre_swab_but_update_buffer, NULL);
+EXPORT_SYMBOL(RMF_BUT_BUF);
+
 /*
  * Request formats.
  */
@@ -1422,6 +1448,11 @@ struct req_format RQF_MDS_GET_INFO =
 			mds_getinfo_server);
 EXPORT_SYMBOL(RQF_MDS_GET_INFO);
 
+struct req_format RQF_MDS_BATCH =
+	DEFINE_REQ_FMT0("MDS_BATCH", mds_batch_client,
+			mds_batch_server);
+EXPORT_SYMBOL(RQF_MDS_BATCH);
+
 struct req_format RQF_LDLM_ENQUEUE =
 	DEFINE_REQ_FMT0("LDLM_ENQUEUE",
 			ldlm_enqueue_client, ldlm_enqueue_lvb_server);
@@ -1849,17 +1880,61 @@ int req_capsule_server_pack(struct req_capsule *pill)
 	LASSERT(fmt);
 
 	count = req_capsule_filled_sizes(pill, RCL_SERVER);
-	rc = lustre_pack_reply(pill->rc_req, count,
-			       pill->rc_area[RCL_SERVER], NULL);
-	if (rc != 0) {
-		DEBUG_REQ(D_ERROR, pill->rc_req,
-			  "Cannot pack %d fields in format '%s'",
-			  count, fmt->rf_name);
+	if (req_capsule_ptlreq(pill)) {
+		rc = lustre_pack_reply(pill->rc_req, count,
+				       pill->rc_area[RCL_SERVER], NULL);
+		if (rc != 0) {
+			DEBUG_REQ(D_ERROR, pill->rc_req,
+				  "Cannot pack %d fields in format '%s'",
+				   count, fmt->rf_name);
+		}
+	} else { /* SUB request */
+		u32 msg_len;
+
+		msg_len = lustre_msg_size_v2(count, pill->rc_area[RCL_SERVER]);
+		if (msg_len > pill->rc_reqmsg->lm_repsize) {
+			/* TODO: Check whether there is enough buffer size */
+			CDEBUG(D_INFO,
+			       "Overflow pack %d fields in format '%s' for the SUB request with message len %u:%u\n",
+			       count, fmt->rf_name, msg_len,
+			       pill->rc_reqmsg->lm_repsize);
+		}
+
+		rc = 0;
+		lustre_init_msg_v2(pill->rc_repmsg, count,
+				   pill->rc_area[RCL_SERVER], NULL);
 	}
+
 	return rc;
 }
 EXPORT_SYMBOL(req_capsule_server_pack);
 
+int req_capsule_client_pack(struct req_capsule *pill)
+{
+	const struct req_format *fmt;
+	int count;
+	int rc = 0;
+
+	LASSERT(pill->rc_loc == RCL_CLIENT);
+	fmt = pill->rc_fmt;
+	LASSERT(fmt);
+
+	count = req_capsule_filled_sizes(pill, RCL_CLIENT);
+	if (req_capsule_ptlreq(pill)) {
+		struct ptlrpc_request *req = pill->rc_req;
+
+		rc = lustre_pack_request(req, req->rq_import->imp_msg_magic,
+					 count, pill->rc_area[RCL_CLIENT],
+					 NULL);
+	} else {
+		/* Sub request in a batch PTLRPC request */
+		lustre_init_msg_v2(pill->rc_reqmsg, count,
+				   pill->rc_area[RCL_CLIENT], NULL);
+	}
+	return rc;
+}
+EXPORT_SYMBOL(req_capsule_client_pack);
+
 /**
  * Returns the PTLRPC request or reply (@loc) buffer offset of a @pill
  * corresponding to the given RMF (@field).
@@ -2050,6 +2125,7 @@ static void *__req_capsule_get(struct req_capsule *pill,
 	value = getter(msg, offset, len);
 
 	if (!value) {
+		LASSERT(pill->rc_req);
 		DEBUG_REQ(D_ERROR, pill->rc_req,
 			  "Wrong buffer for field '%s' (%u of %u) in format '%s', %u vs. %u (%s)",
 			  field->rmf_name, offset, lustre_msg_bufcount(msg),
@@ -2218,10 +2294,18 @@ u32 req_capsule_get_size(const struct req_capsule *pill,
  */
 u32 req_capsule_msg_size(struct req_capsule *pill, enum req_location loc)
 {
-	return lustre_msg_size(pill->rc_req->rq_import->imp_msg_magic,
-			       pill->rc_fmt->rf_fields[loc].nr,
-			       pill->rc_area[loc]);
+	if (req_capsule_ptlreq(pill)) {
+		return lustre_msg_size(pill->rc_req->rq_import->imp_msg_magic,
+				       pill->rc_fmt->rf_fields[loc].nr,
+				       pill->rc_area[loc]);
+	} else { /* SUB request in a batch request */
+		int count;
+
+		count = req_capsule_filled_sizes(pill, loc);
+		return lustre_msg_size_v2(count, pill->rc_area[loc]);
+	}
 }
+EXPORT_SYMBOL(req_capsule_msg_size);
 
 /**
  * While req_capsule_msg_size() computes the size of a PTLRPC request or reply
@@ -2373,16 +2457,32 @@ void req_capsule_shrink(struct req_capsule *pill,
 	LASSERTF(newlen <= len, "%s:%s, oldlen=%u, newlen=%u\n",
 		 fmt->rf_name, field->rmf_name, len, newlen);
 
+	len = lustre_shrink_msg(msg, offset, newlen, 1);
 	if (loc == RCL_CLIENT) {
-		pill->rc_req->rq_reqlen = lustre_shrink_msg(msg, offset, newlen,
-							    1);
+		if (req_capsule_ptlreq(pill))
+			pill->rc_req->rq_reqlen = len;
 	} else {
-		pill->rc_req->rq_replen = lustre_shrink_msg(msg, offset, newlen,
-							    1);
 		/* update also field size in reply lenghts arrays for possible
 		 * reply re-pack due to req_capsule_server_grow() call.
 		 */
 		req_capsule_set_size(pill, field, loc, newlen);
+		if (req_capsule_ptlreq(pill))
+			pill->rc_req->rq_replen = len;
 	}
 }
 EXPORT_SYMBOL(req_capsule_shrink);
+
+void req_capsule_set_replen(struct req_capsule *pill)
+{
+	if (req_capsule_ptlreq(pill)) {
+		ptlrpc_request_set_replen(pill->rc_req);
+	} else { /* SUB request in a batch request */
+		int count;
+
+		count = req_capsule_filled_sizes(pill, RCL_SERVER);
+		pill->rc_reqmsg->lm_repsize =
+			lustre_msg_size_v2(count,
+					   pill->rc_area[RCL_SERVER]);
+	}
+}
+EXPORT_SYMBOL(req_capsule_set_replen);
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index f3f8a71..af83902 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -98,6 +98,7 @@
 	{ MDS_HSM_CT_UNREGISTER,		"mds_hsm_ct_unregister" },
 	{ MDS_SWAP_LAYOUTS,			"mds_swap_layouts" },
 	{ MDS_RMFID,				"mds_rmfid" },
+	{ MDS_BATCH,				"mds_batch" },
 	{ LDLM_ENQUEUE,				"ldlm_enqueue" },
 	{ LDLM_CONVERT,				"ldlm_convert" },
 	{ LDLM_CANCEL,				"ldlm_cancel" },
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 3499611..8d58f9b 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -491,7 +491,7 @@ static int lustre_unpack_msg_v2(struct lustre_msg_v2 *m, int len)
 		__swab32s(&m->lm_repsize);
 		__swab32s(&m->lm_cksum);
 		__swab32s(&m->lm_flags);
-		BUILD_BUG_ON(offsetof(typeof(*m), lm_padding_2) == 0);
+		__swab32s(&m->lm_opc);
 		BUILD_BUG_ON(offsetof(typeof(*m), lm_padding_3) == 0);
 	}
 
@@ -2591,6 +2591,31 @@ void lustre_swab_hsm_request(struct hsm_request *hr)
 	__swab32s(&hr->hr_data_len);
 }
 
+/* TODO: swab each sub reply message. */
+void lustre_swab_batch_update_reply(struct batch_update_reply *bur)
+{
+	__swab32s(&bur->burp_magic);
+	__swab16s(&bur->burp_count);
+	__swab16s(&bur->burp_padding);
+}
+
+void lustre_swab_but_update_header(struct but_update_header *buh)
+{
+	__swab32s(&buh->buh_magic);
+	__swab32s(&buh->buh_count);
+	__swab32s(&buh->buh_inline_length);
+	__swab32s(&buh->buh_reply_size);
+	__swab32s(&buh->buh_update_count);
+}
+EXPORT_SYMBOL(lustre_swab_but_update_header);
+
+void lustre_swab_but_update_buffer(struct but_update_buffer *bub)
+{
+	__swab32s(&bub->bub_size);
+	__swab32s(&bub->bub_padding);
+}
+EXPORT_SYMBOL(lustre_swab_but_update_buffer);
+
 void lustre_swab_swap_layouts(struct mdc_swap_layouts *msl)
 {
 	__swab64s(&msl->msl_flags);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 372dc10..2c02430 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -181,7 +181,9 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_SWAP_LAYOUTS);
 	LASSERTF(MDS_RMFID == 62, "found %lld\n",
 		 (long long)MDS_RMFID);
-	LASSERTF(MDS_LAST_OPC == 63, "found %lld\n",
+	LASSERTF(MDS_BATCH == 63, "found %lld\n",
+		 (long long)MDS_BATCH);
+	LASSERTF(MDS_LAST_OPC == 64, "found %lld\n",
 		 (long long)MDS_LAST_OPC);
 	LASSERTF(REINT_SETATTR == 1, "found %lld\n",
 		 (long long)REINT_SETATTR);
@@ -661,10 +663,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lustre_msg_v2, lm_flags));
 	LASSERTF((int)sizeof(((struct lustre_msg_v2 *)0)->lm_flags) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lustre_msg_v2 *)0)->lm_flags));
-	LASSERTF((int)offsetof(struct lustre_msg_v2, lm_padding_2) == 24, "found %lld\n",
-		 (long long)(int)offsetof(struct lustre_msg_v2, lm_padding_2));
-	LASSERTF((int)sizeof(((struct lustre_msg_v2 *)0)->lm_padding_2) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct lustre_msg_v2 *)0)->lm_padding_2));
+	LASSERTF((int)offsetof(struct lustre_msg_v2, lm_opc) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_msg_v2, lm_opc));
+	LASSERTF((int)sizeof(((struct lustre_msg_v2 *)0)->lm_opc) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_msg_v2 *)0)->lm_opc));
 	LASSERTF((int)offsetof(struct lustre_msg_v2, lm_padding_3) == 28, "found %lld\n",
 		 (long long)(int)offsetof(struct lustre_msg_v2, lm_padding_3));
 	LASSERTF((int)sizeof(((struct lustre_msg_v2 *)0)->lm_padding_3) == 4, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 8cf9323..99735fc 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -544,7 +544,7 @@ struct lustre_msg_v2 {
 	__u32 lm_repsize;	/* size of preallocated reply buffer */
 	__u32 lm_cksum;		/* CRC32 of ptlrpc_body early reply messages */
 	__u32 lm_flags;		/* enum lustre_msghdr MSGHDR_* flags */
-	__u32 lm_padding_2;	/* unused */
+	__u32 lm_opc;		/* SUB request opcode in a batch request */
 	__u32 lm_padding_3;	/* unused */
 	__u32 lm_buflens[0];	/* length of additional buffers in bytes,
 				 * padded to a multiple of 8 bytes.
@@ -555,6 +555,9 @@ struct lustre_msg_v2 {
 	 */
 };
 
+/* The returned result of the SUB request in a batch request */
+#define lm_result	lm_opc
+
 /* ptlrpc_body packet pb_types */
 #define PTL_RPC_MSG_REQUEST	4711	/* normal RPC request message */
 #define PTL_RPC_MSG_ERR		4712	/* error reply if request unprocessed */
@@ -1428,6 +1431,7 @@ enum mds_cmd {
 	MDS_HSM_CT_UNREGISTER	= 60,
 	MDS_SWAP_LAYOUTS	= 61,
 	MDS_RMFID		= 62,
+	MDS_BATCH		= 63,
 	MDS_LAST_OPC
 };
 
@@ -2860,6 +2864,82 @@ struct hsm_progress_kernel {
 	__u64			hpk_padding2;
 } __attribute__((packed));
 
+#define OUT_UPDATE_MAX_INLINE_SIZE	4096
+
+#define BUT_REQUEST_MAGIC	0xBADE0001
+/* Hold batched updates sending to the remote target in a single RPC */
+struct batch_update_request {
+	/* Magic number: BUT_REQUEST_MAGIC. */
+	__u32			burq_magic;
+	/* Number of sub requests packed in this batched RPC: burq_reqmsg[]. */
+	__u16			burq_count;
+	/* Unused padding field. */
+	__u16			burq_padding;
+	/*
+	 * Sub request message array. As message feild buffers for each sub
+	 * request are packed after padded lustre_msg.lm_buflens[] arrary, thus
+	 * it can locate the next request message via the function
+	 * @batch_update_reqmsg_next() in lustre/include/obj_update.h
+	 */
+	struct lustre_msg	burq_reqmsg[0];
+};
+
+#define BUT_HEADER_MAGIC	0xBADF0001
+/* Header for Batched UpdaTes request */
+struct but_update_header {
+	/* Magic number: BUT_HEADER_MAGIC */
+	__u32	buh_magic;
+	/*
+	 * When the total request buffer length is less than MAX_INLINE_SIZE,
+	 * @buh_count is set with 1 and the batched RPC request can be packed
+	 * inline.
+	 * Otherwise, @buh_count indicates the IO vector count transferring in
+	 * bulk I/O.
+	 */
+	__u32	buh_count;
+	/* inline buffer length when the batched RPC can be packed inline. */
+	__u32	buh_inline_length;
+	/* The reply buffer size the client prepared. */
+	__u32	buh_reply_size;
+	/* Sub request count in this batched RPC. */
+	__u32	buh_update_count;
+	/* Unused padding field. */
+	__u32	buh_padding;
+	/* Inline buffer used when the RPC request can be packed inline. */
+	__u32	buh_inline_data[0];
+};
+
+struct but_update_buffer {
+	__u32	bub_size;
+	__u32	bub_padding;
+};
+
+#define BUT_REPLY_MAGIC	0x00AD0001
+/* Batched reply received from a remote targer in a batched RPC. */
+struct batch_update_reply {
+	/* Magic number: BUT_REPLY_MAGIC. */
+	__u32			burp_magic;
+	/* Successful returned sub requests. */
+	__u16			burp_count;
+	/* Unused padding field. */
+	__u16			burp_padding;
+	/*
+	 * Sub reply message array.
+	 * It can locate the next reply message buffer via the function
+	 * @batch_update_repmsg_next() in lustre/include/obj_update.h
+	 */
+	struct lustre_msg	burp_repmsg[0];
+};
+
+/**
+ * Batch update opcode.
+ */
+enum batch_update_cmd {
+	BUT_GETATTR	= 1,
+	BUT_LAST_OPC,
+	BUT_FIRST_OPC	= BUT_GETATTR,
+};
+
 /** layout swap request structure
  * fid1 and fid2 are in mdt_body
  */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
