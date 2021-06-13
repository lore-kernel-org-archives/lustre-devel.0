Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8EF2C48BDF
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:31 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6C30E611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C30E611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 990AB21F538;
	Sun, 13 Jun 2021 16:12:10 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D8D9521F273
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E6034100B05F;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E4D199C308; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:33 -0400
Message-Id: <1623625897-17706-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/27] lustre: ptlrpc: move more members in
 PTLRPC request into pill
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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

Some data members in the data structure @ptlrpc_request can be
moved into the data structure @rep_capsule:
/** Request message - what client sent */
struct lustre_msg *rq_reqmsg;
/** Reply message - server response */
struct lustre_msg *rq_repmsg;
/** Fields that help to see if request and reply were swabbed */
u32 rq_req_swab_mask;
u32 rq_rep_swab_mask;

After these data structures are reconstructed, @rep_capsule can
be more common used and it makes pack and unpack sub requests
in a batch PtlRPC request for the coming batch metadata processing
more easily.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14138
Lustre-commit: f75d2a1fc9b17b38 ("LU-14138 ptlrpc: move more members in PTLRPC request into pill")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/40669
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h        |  72 +----------------
 fs/lustre/include/lustre_req_layout.h |  78 +++++++++++++++++-
 fs/lustre/include/obd.h               |   2 +-
 fs/lustre/include/obd_class.h         |   4 +-
 fs/lustre/llite/dcache.c              |   6 +-
 fs/lustre/llite/dir.c                 |   2 +-
 fs/lustre/llite/file.c                |   4 +-
 fs/lustre/llite/llite_internal.h      |   4 +-
 fs/lustre/llite/llite_lib.c           |  16 ++--
 fs/lustre/llite/llite_nfs.c           |   2 +-
 fs/lustre/llite/namei.c               |   8 +-
 fs/lustre/llite/statahead.c           |   2 +-
 fs/lustre/lmv/lmv_obd.c               |   5 +-
 fs/lustre/mdc/mdc_acl.c               |   3 +-
 fs/lustre/mdc/mdc_dev.c               |   6 +-
 fs/lustre/mdc/mdc_internal.h          |  36 ++++-----
 fs/lustre/mdc/mdc_lib.c               | 146 +++++++++++++++++-----------------
 fs/lustre/mdc/mdc_locks.c             |  10 +--
 fs/lustre/mdc/mdc_reint.c             |  13 +--
 fs/lustre/mdc/mdc_request.c           |  43 +++++-----
 fs/lustre/mgc/mgc_request.c           |   2 +-
 fs/lustre/ptlrpc/layout.c             |  32 ++++++--
 fs/lustre/ptlrpc/pack_generic.c       |  52 +++++-------
 fs/lustre/ptlrpc/sec.c                |   6 +-
 fs/lustre/ptlrpc/sec_plain.c          |   4 +-
 25 files changed, 282 insertions(+), 276 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index c894d0f..f72f7c6 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -770,6 +770,10 @@ struct ptlrpc_srv_req {
 #define rq_user_desc		rq_srv.sr_user_desc
 #define rq_ops			rq_srv.sr_ops
 #define rq_rqbd			rq_srv.sr_rqbd
+#define rq_reqmsg		rq_pill.rc_reqmsg
+#define rq_repmsg		rq_pill.rc_repmsg
+#define rq_req_swab_mask	rq_pill.rc_req_swab_mask
+#define rq_rep_swab_mask	rq_pill.rc_rep_swab_mask
 
 /**
  * Represents remote procedure call.
@@ -857,10 +861,6 @@ struct ptlrpc_request {
 	int				rq_replen;
 	/** Pool if request is from preallocated list */
 	struct ptlrpc_request_pool     *rq_pool;
-	/** Request message - what client sent */
-	struct lustre_msg	       *rq_reqmsg;
-	/** Reply message - server response */
-	struct lustre_msg	       *rq_repmsg;
 	/** Transaction number */
 	u64				rq_transno;
 	/** xid */
@@ -932,10 +932,6 @@ struct ptlrpc_request {
 
 	/** @} */
 
-	/** Fields that help to see if request and reply were swabbed or not */
-	u32			rq_req_swab_mask;
-	u32			rq_rep_swab_mask;
-
 	/** how many early replies (for stats) */
 	int			rq_early_count;
 
@@ -1011,62 +1007,6 @@ static inline bool ptlrpc_nrs_req_can_move(struct ptlrpc_request *req)
 /** @} nrs */
 
 /**
- * Returns true if request buffer at offset @index was already swabbed
- */
-static inline bool lustre_req_swabbed(struct ptlrpc_request *req, size_t index)
-{
-	LASSERT(index < sizeof(req->rq_req_swab_mask) * 8);
-	return req->rq_req_swab_mask & BIT(index);
-}
-
-/**
- * Returns true if request reply buffer at offset @index was already swabbed
- */
-static inline bool lustre_rep_swabbed(struct ptlrpc_request *req, size_t index)
-{
-	LASSERT(index < sizeof(req->rq_rep_swab_mask) * 8);
-	return req->rq_rep_swab_mask & BIT(index);
-}
-
-/**
- * Returns true if request needs to be swabbed into local cpu byteorder
- */
-static inline bool ptlrpc_req_need_swab(struct ptlrpc_request *req)
-{
-	return lustre_req_swabbed(req, MSG_PTLRPC_HEADER_OFF);
-}
-
-/**
- * Returns true if request reply needs to be swabbed into local cpu byteorder
- */
-static inline bool ptlrpc_rep_need_swab(struct ptlrpc_request *req)
-{
-	return lustre_rep_swabbed(req, MSG_PTLRPC_HEADER_OFF);
-}
-
-/**
- * Mark request buffer at offset @index that it was already swabbed
- */
-static inline void lustre_set_req_swabbed(struct ptlrpc_request *req,
-					  size_t index)
-{
-	LASSERT(index < sizeof(req->rq_req_swab_mask) * 8);
-	LASSERT((req->rq_req_swab_mask & BIT(index)) == 0);
-	req->rq_req_swab_mask |= BIT(index);
-}
-
-/**
- * Mark request reply buffer at offset @index that it was already swabbed
- */
-static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
-					  size_t index)
-{
-	LASSERT(index < sizeof(req->rq_rep_swab_mask) * 8);
-	LASSERT((req->rq_rep_swab_mask & BIT(index)) == 0);
-	req->rq_rep_swab_mask |= BIT(index);
-}
-
-/**
  * Convert numerical request phase value @phase into text string description
  */
 static inline const char *
@@ -2047,10 +1987,6 @@ struct ptlrpc_service *ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 				 MDS_REG_MAXREQSIZE : OUT_MAXREQSIZE)
 #define PTLRPC_MAX_BUFLEN	(OST_IO_MAXREQSIZE > MD_MAX_BUFLEN ? \
 				 OST_IO_MAXREQSIZE : MD_MAX_BUFLEN)
-bool ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
-			  u32 index);
-void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
-			    u32 index);
 int ptlrpc_unpack_rep_msg(struct ptlrpc_request *req, int len);
 int ptlrpc_unpack_req_msg(struct ptlrpc_request *req, int len);
 
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index f6ebda3..9f22134b 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -62,10 +62,17 @@ enum req_location {
 #define REQ_MAX_FIELD_NR 12
 
 struct req_capsule {
-	struct ptlrpc_request		*rc_req;
-	const struct req_format		*rc_fmt;
-	enum req_location		 rc_loc;
-	u32				 rc_area[RCL_NR][REQ_MAX_FIELD_NR];
+	struct ptlrpc_request	*rc_req;
+	/** Request message - what client sent */
+	struct lustre_msg	*rc_reqmsg;
+	/** Reply message - server response */
+	struct lustre_msg	*rc_repmsg;
+	/** Fields that help to see if request and reply were swabved or not */
+	u32			 rc_req_swab_mask;
+	u32			 rc_rep_swab_mask;
+	const struct req_format	*rc_fmt;
+	enum req_location	 rc_loc;
+	u32			 rc_area[RCL_NR][REQ_MAX_FIELD_NR];
 };
 
 void req_capsule_init(struct req_capsule *pill, struct ptlrpc_request *req,
@@ -117,6 +124,69 @@ int req_capsule_field_present(const struct req_capsule *pill,
 void req_capsule_shrink(struct req_capsule *pill,
 			const struct req_msg_field *field,
 			u32 newlen, enum req_location loc);
+bool req_capsule_need_swab(struct req_capsule *pill, enum req_location loc,
+			   u32 index);
+void req_capsule_set_swabbed(struct req_capsule *pill, enum req_location loc,
+			     u32 index);
+
+/**
+ * Returns true if request buffer at offset \a index was already swabbed
+ */
+static inline bool req_capsule_req_swabbed(struct req_capsule *pill,
+					   size_t index)
+{
+	LASSERT(index < sizeof(pill->rc_req_swab_mask) * 8);
+	return pill->rc_req_swab_mask & BIT(index);
+}
+
+/**
+ * Returns true if request reply buffer at offset \a index was already swabbed
+ */
+static inline bool req_capsule_rep_swabbed(struct req_capsule *pill,
+					   size_t index)
+{
+	LASSERT(index < sizeof(pill->rc_rep_swab_mask) * 8);
+	return pill->rc_rep_swab_mask & BIT(index);
+}
+
+/**
+ * Returns true if request needs to be swabbed into local cpu byteorder
+ */
+static inline bool req_capsule_req_need_swab(struct req_capsule *pill)
+{
+	return req_capsule_req_swabbed(pill, MSG_PTLRPC_HEADER_OFF);
+}
+
+/**
+ * Returns true if request reply needs to be swabbed into local cpu byteorder
+ */
+static inline bool req_capsule_rep_need_swab(struct req_capsule *pill)
+{
+	return req_capsule_rep_swabbed(pill, MSG_PTLRPC_HEADER_OFF);
+}
+
+/**
+ * Mark request buffer at offset \a index that it was already swabbed
+ */
+static inline void req_capsule_set_req_swabbed(struct req_capsule *pill,
+					       size_t index)
+{
+	LASSERT(index < sizeof(pill->rc_req_swab_mask) * 8);
+	LASSERT((pill->rc_req_swab_mask & BIT(index)) == 0);
+	pill->rc_req_swab_mask |= BIT(index);
+}
+
+/**
+ * Mark request reply buffer at offset \a index that it was already swabbed
+ */
+static inline void req_capsule_set_rep_swabbed(struct req_capsule *pill,
+					       size_t index)
+{
+	LASSERT(index < sizeof(pill->rc_rep_swab_mask) * 8);
+	LASSERT((pill->rc_rep_swab_mask & BIT(index)) == 0);
+	pill->rc_rep_swab_mask |= BIT(index);
+}
+
 int  req_layout_init(void);
 void req_layout_fini(void);
 
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 678953a..86d7839 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -1028,7 +1028,7 @@ struct md_ops {
 
 	int (*init_ea_size)(struct obd_export *, u32, u32);
 
-	int (*get_lustre_md)(struct obd_export *, struct ptlrpc_request *,
+	int (*get_lustre_md)(struct obd_export *exp, struct req_capsule *pill,
 			     struct obd_export *, struct obd_export *,
 			     struct lustre_md *);
 
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 4cc5a7df..2fe4ea2 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1432,7 +1432,7 @@ static inline int md_unlink(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static inline int md_get_lustre_md(struct obd_export *exp,
-				   struct ptlrpc_request *req,
+				   struct req_capsule *pill,
 				   struct obd_export *dt_exp,
 				   struct obd_export *md_exp,
 				   struct lustre_md *md)
@@ -1443,7 +1443,7 @@ static inline int md_get_lustre_md(struct obd_export *exp,
 	if (rc)
 		return rc;
 
-	return MDP(exp->exp_obd, get_lustre_md)(exp, req, dt_exp, md_exp, md);
+	return MDP(exp->exp_obd, get_lustre_md)(exp, pill, dt_exp, md_exp, md);
 }
 
 static inline int md_free_lustre_md(struct obd_export *exp,
diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index 24af33e..4162f46 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -202,17 +202,13 @@ int ll_revalidate_it_finish(struct ptlrpc_request *request,
 			    struct lookup_intent *it,
 			    struct inode *inode)
 {
-	int rc = 0;
-
 	if (!request)
 		return 0;
 
 	if (it_disposition(it, DISP_LOOKUP_NEG))
 		return -ENOENT;
 
-	rc = ll_prep_inode(&inode, request, NULL, it);
-
-	return rc;
+	return ll_prep_inode(&inode, &request->rq_pill, NULL, it);
 }
 
 void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode)
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index bd15fee..3432034 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -486,7 +486,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	if (err)
 		goto out_request;
 
-	err = ll_prep_inode(&inode, request, parent->i_sb, NULL);
+	err = ll_prep_inode(&inode, &request->rq_pill, parent->i_sb, NULL);
 	if (err)
 		goto out_inode;
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 7c14cf2..2dcf25f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -665,7 +665,7 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 		goto out;
 	}
 
-	rc = ll_prep_inode(&inode, req, NULL, itp);
+	rc = ll_prep_inode(&inode, &req->rq_pill, NULL, itp);
 
 	if (!rc && itp->it_lock_mode) {
 		u64 bits = 0;
@@ -4531,7 +4531,7 @@ int ll_get_fid_by_name(struct inode *parent, const char *name,
 		*fid = body->mbo_fid1;
 
 	if (inode)
-		rc = ll_prep_inode(inode, req, parent->i_sb, NULL);
+		rc = ll_prep_inode(inode, &req->rq_pill, parent->i_sb, NULL);
 out_req:
 	ptlrpc_req_finished(req);
 	return rc;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index a1e5e468..3674af9 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1213,7 +1213,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 int ll_remount_fs(struct super_block *sb, int *flags, char *data);
 int ll_show_options(struct seq_file *seq, struct dentry *dentry);
 void ll_dirty_page_discard_warn(struct page *page, int ioret);
-int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
+int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 		  struct super_block *sb, struct lookup_intent *it);
 int ll_obd_statfs(struct inode *inode, void __user *arg);
 int ll_get_max_mdsize(struct ll_sb_info *sbi, int *max_mdsize);
@@ -1229,9 +1229,9 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 void ll_finish_md_op_data(struct md_op_data *op_data);
 int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg);
 void ll_compute_rootsquash_state(struct ll_sb_info *sbi);
-void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req);
 ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
 			struct lov_user_md **kbuf);
+void ll_open_cleanup(struct super_block *sb, struct req_capsule *pill);
 
 void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req);
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index fe49030..646bff8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -650,8 +650,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		goto out_lock_cn_cb;
 	}
 
-	err = md_get_lustre_md(sbi->ll_md_exp, request, sbi->ll_dt_exp,
-			       sbi->ll_md_exp, &lmd);
+	err = md_get_lustre_md(sbi->ll_md_exp, &request->rq_pill,
+			       sbi->ll_dt_exp, sbi->ll_md_exp, &lmd);
 	if (err) {
 		CERROR("failed to understand root inode md: rc = %d\n", err);
 		ptlrpc_req_finished(request);
@@ -1723,7 +1723,7 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
 		return rc;
 	}
 
-	rc = md_get_lustre_md(sbi->ll_md_exp, request, sbi->ll_dt_exp,
+	rc = md_get_lustre_md(sbi->ll_md_exp, &request->rq_pill, sbi->ll_dt_exp,
 			      sbi->ll_md_exp, &md);
 	if (rc) {
 		ptlrpc_req_finished(request);
@@ -2762,14 +2762,14 @@ int ll_remount_fs(struct super_block *sb, int *flags, char *data)
  * @sb:		super block for this file-system
  * @open_req:	pointer to the original open request
  */
-void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req)
+void ll_open_cleanup(struct super_block *sb, struct req_capsule *pill)
 {
 	struct mdt_body	*body;
 	struct md_op_data *op_data;
 	struct ptlrpc_request *close_req = NULL;
 	struct obd_export *exp = ll_s2sbi(sb)->ll_md_exp;
 
-	body = req_capsule_server_get(&open_req->rq_pill, &RMF_MDT_BODY);
+	body = req_capsule_server_get(pill, &RMF_MDT_BODY);
 	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
 	if (!op_data)
 		return;
@@ -2782,7 +2782,7 @@ void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req)
 	ll_finish_md_op_data(op_data);
 }
 
-int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
+int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 		  struct super_block *sb, struct lookup_intent *it)
 {
 	struct ll_sb_info *sbi = NULL;
@@ -2792,7 +2792,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 
 	LASSERT(*inode || sb);
 	sbi = sb ? ll_s2sbi(sb) : ll_i2sbi(*inode);
-	rc = md_get_lustre_md(sbi->ll_md_exp, req, sbi->ll_dt_exp,
+	rc = md_get_lustre_md(sbi->ll_md_exp, pill, sbi->ll_dt_exp,
 			      sbi->ll_md_exp, &md);
 	if (rc)
 		goto out;
@@ -2878,7 +2878,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 
 	if (rc != 0 && it && it->it_op & IT_OPEN) {
 		ll_intent_drop_lock(it);
-		ll_open_cleanup(sb ? sb : (*inode)->i_sb, req);
+		ll_open_cleanup(sb ? sb : (*inode)->i_sb, pill);
 	}
 
 	return rc;
diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index bf15023..6be2309 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -101,7 +101,7 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 		       PFID(fid), rc);
 		return ERR_PTR(rc);
 	}
-	rc = ll_prep_inode(&inode, req, sb, NULL);
+	rc = ll_prep_inode(&inode, &req->rq_pill, sb, NULL);
 	ptlrpc_req_finished(req);
 	if (rc)
 		return ERR_PTR(rc);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 43cbfbd..9eab6fe 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -649,7 +649,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		struct mdt_body *body = req_capsule_server_get(pill,
 							       &RMF_MDT_BODY);
 
-		rc = ll_prep_inode(&inode, request, (*de)->d_sb, it);
+		rc = ll_prep_inode(&inode, &request->rq_pill, (*de)->d_sb, it);
 		if (rc)
 			return rc;
 
@@ -789,7 +789,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 out:
 	if (rc != 0 && it->it_op & IT_OPEN) {
 		ll_intent_drop_lock(it);
-		ll_open_cleanup((*de)->d_sb, request);
+		ll_open_cleanup((*de)->d_sb, &request->rq_pill);
 	}
 
 	return rc;
@@ -1249,7 +1249,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 	LASSERT(it_disposition(it, DISP_ENQ_CREATE_REF));
 	request = it->it_request;
 	it_clear_disposition(it, DISP_ENQ_CREATE_REF);
-	rc = ll_prep_inode(&inode, request, dir->i_sb, it);
+	rc = ll_prep_inode(&inode, &request->rq_pill, dir->i_sb, it);
 	if (rc) {
 		inode = ERR_PTR(rc);
 		goto out;
@@ -1485,7 +1485,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 
 	ll_update_times(request, dir);
 
-	err = ll_prep_inode(&inode, request, dir->i_sb, NULL);
+	err = ll_prep_inode(&inode, &request->rq_pill, dir->i_sb, NULL);
 	if (err)
 		goto err_exit;
 
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 995a9e1..282cb5a 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -663,7 +663,7 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 		goto out;
 	}
 
-	rc = ll_prep_inode(&child, req, dir->i_sb, it);
+	rc = ll_prep_inode(&child, &req->rq_pill, dir->i_sb, it);
 	if (rc)
 		goto out;
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index fb89047..56d22d1 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3368,7 +3368,7 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, u64 flags,
 }
 
 static int lmv_get_lustre_md(struct obd_export *exp,
-			     struct ptlrpc_request *req,
+			     struct req_capsule *pill,
 			     struct obd_export *dt_exp,
 			     struct obd_export *md_exp,
 			     struct lustre_md *md)
@@ -3378,7 +3378,8 @@ static int lmv_get_lustre_md(struct obd_export *exp,
 
 	if (!tgt || !tgt->ltd_exp)
 		return -EINVAL;
-	return md_get_lustre_md(tgt->ltd_exp, req, dt_exp, md_exp, md);
+
+	return md_get_lustre_md(tgt->ltd_exp, pill, dt_exp, md_exp, md);
 }
 
 static int lmv_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
diff --git a/fs/lustre/mdc/mdc_acl.c b/fs/lustre/mdc/mdc_acl.c
index 6814045..8126390 100644
--- a/fs/lustre/mdc/mdc_acl.c
+++ b/fs/lustre/mdc/mdc_acl.c
@@ -24,9 +24,8 @@
 
 #include "mdc_internal.h"
 
-int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
+int mdc_unpack_acl(struct req_capsule *pill, struct lustre_md *md)
 {
-	struct req_capsule *pill = &req->rq_pill;
 	struct mdt_body	*body = md->body;
 	struct posix_acl *acl;
 	void *buf;
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 0db05b5..1c28f80 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -563,12 +563,12 @@ static int mdc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 }
 
 /* This is needed only for old servers (before 2.14) support */
-int mdc_fill_lvb(struct ptlrpc_request *req, struct ost_lvb *lvb)
+int mdc_fill_lvb(struct req_capsule *pill, struct ost_lvb *lvb)
 {
 	struct mdt_body *body;
 
 	/* get LVB data from mdt_body otherwise */
-	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+	body = req_capsule_server_get(pill, &RMF_MDT_BODY);
 	if (!body)
 		return -EPROTO;
 
@@ -590,7 +590,7 @@ int mdc_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 
 	/* needed only for glimpse from an old server (< 2.14) */
 	if (glimpse && !exp_connect_dom_lvb(exp))
-		rc = mdc_fill_lvb(req, &ols->ols_lvb);
+		rc = mdc_fill_lvb(&req->rq_pill, &ols->ols_lvb);
 
 	if (glimpse && errcode == ELDLM_LOCK_ABORTED) {
 		struct ldlm_reply *rep;
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 06b0637..fab40bd 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -37,37 +37,37 @@
 
 int mdc_tunables_init(struct obd_device *obd);
 
-void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
+void mdc_pack_body(struct req_capsule *pill, const struct lu_fid *fid,
 		   u64 valid, size_t ea_size, u32 suppgid, u32 flags);
-void mdc_swap_layouts_pack(struct ptlrpc_request *req,
+void mdc_swap_layouts_pack(struct req_capsule *pill,
 			   struct md_op_data *op_data);
-void mdc_readdir_pack(struct ptlrpc_request *req, u64 pgoff, size_t size,
+void mdc_readdir_pack(struct req_capsule *pill, u64 pgoff, size_t size,
 		      const struct lu_fid *fid);
-void mdc_getattr_pack(struct ptlrpc_request *req, u64 valid, u32 flags,
+void mdc_getattr_pack(struct req_capsule *pill, u64 valid, u32 flags,
 		      struct md_op_data *data, size_t ea_size);
-void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_setattr_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		      void *ea, size_t ealen);
-void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_create_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		     const void *data, size_t datalen, umode_t mode, uid_t uid,
 		     gid_t gid, kernel_cap_t capability, u64 rdev);
-void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_open_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		   umode_t mode, u64 rdev, u64 flags, const void *data,
 		   size_t datalen);
-void mdc_file_secctx_pack(struct ptlrpc_request *req,
+void mdc_file_secctx_pack(struct req_capsule *pill,
 			  const char *secctx_name,
 			  const void *secctx, size_t secctx_size);
-void mdc_file_encctx_pack(struct ptlrpc_request *req,
+void mdc_file_encctx_pack(struct req_capsule *pill,
 			  const void *encctx, size_t encctx_size);
-void mdc_file_sepol_pack(struct ptlrpc_request *req);
+void mdc_file_sepol_pack(struct req_capsule *pill);
 
-void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
-void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
-void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_unlink_pack(struct req_capsule *pill, struct md_op_data *op_data);
+void mdc_link_pack(struct req_capsule *pill, struct md_op_data *op_data);
+void mdc_rename_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		     const char *old, size_t oldlen,
 		     const char *new, size_t newlen);
-void mdc_migrate_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_migrate_pack(struct req_capsule *pill, struct md_op_data *op_data,
 			const char *name, size_t namelen);
-void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
+void mdc_close_pack(struct req_capsule *pill, struct md_op_data *op_data);
 
 /* mdc/mdc_locks.c */
 int mdc_set_lock_data(struct obd_export *exp,
@@ -158,10 +158,10 @@ static inline int mdc_prep_elc_req(struct obd_export *exp,
 }
 
 #ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md);
+int mdc_unpack_acl(struct req_capsule *pill, struct lustre_md *md);
 #else
 static inline
-int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
+int mdc_unpack_acl(struct req_capsule *pill, struct lustre_md *md)
 {
 	return 0;
 }
@@ -190,7 +190,7 @@ static inline unsigned long hash_x_index(u64 hash, int hash64)
 int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 			  struct ldlm_lock_desc *new, void *data, int flag);
 int mdc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data);
-int mdc_fill_lvb(struct ptlrpc_request *req, struct ost_lvb *lvb);
+int mdc_fill_lvb(struct req_capsule *pill, struct ost_lvb *lvb);
 
 /* the minimum inline repsize should be PAGE_SIZE at least */
 #define MDC_DOM_DEF_INLINE_REPSIZE max(8192UL, PAGE_SIZE)
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 37fcb38..ccaa0f2 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -51,11 +51,10 @@ static void __mdc_pack_body(struct mdt_body *b, u32 suppgid)
 	b->mbo_capability = current_cap().cap[0];
 }
 
-void mdc_swap_layouts_pack(struct ptlrpc_request *req,
+void mdc_swap_layouts_pack(struct req_capsule *pill,
 			   struct md_op_data *op_data)
 {
-	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
-						    &RMF_MDT_BODY);
+	struct mdt_body *b = req_capsule_client_get(pill, &RMF_MDT_BODY);
 
 	__mdc_pack_body(b, op_data->op_suppgids[0]);
 	b->mbo_fid1 = op_data->op_fid1;
@@ -63,11 +62,11 @@ void mdc_swap_layouts_pack(struct ptlrpc_request *req,
 	b->mbo_valid |= OBD_MD_FLID;
 }
 
-void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
+void mdc_pack_body(struct req_capsule *pill, const struct lu_fid *fid,
 		   u64 valid, size_t ea_size, u32 suppgid, u32 flags)
 {
-	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
-						    &RMF_MDT_BODY);
+	struct mdt_body *b = req_capsule_client_get(pill, &RMF_MDT_BODY);
+
 	b->mbo_valid = valid;
 	b->mbo_eadatasize = ea_size;
 	b->mbo_flags = flags;
@@ -81,7 +80,7 @@ void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
 /**
  * Pack a name (path component) into a request
  *
- * @req:	request
+ * @pill:	request pill
  * @field:	request field (usually RMF_NAME)
  * @name:	path component
  * @name_len:	length of path component
@@ -91,7 +90,7 @@ void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
  * @name must be '\0' terminated of length @name_len and represent
  * a single path component (not contain '/').
  */
-static void mdc_pack_name(struct ptlrpc_request *req,
+static void mdc_pack_name(struct req_capsule *pill,
 			  const struct req_msg_field *field,
 			  const char *name, size_t name_len)
 {
@@ -99,8 +98,8 @@ static void mdc_pack_name(struct ptlrpc_request *req,
 	size_t cpy_len;
 	char *buf;
 
-	buf = req_capsule_client_get(&req->rq_pill, field);
-	buf_size = req_capsule_get_size(&req->rq_pill, field, RCL_CLIENT);
+	buf = req_capsule_client_get(pill, field);
+	buf_size = req_capsule_get_size(pill, field, RCL_CLIENT);
 
 	LASSERT(name && name_len && buf && buf_size == name_len + 1);
 
@@ -108,12 +107,11 @@ static void mdc_pack_name(struct ptlrpc_request *req,
 
 	LASSERT(lu_name_is_valid_2(buf, cpy_len));
 	if (cpy_len != name_len)
-		CDEBUG(D_DENTRY, "%s: %s len %zd != %zd, concurrent rename?\n",
-		       req->rq_export->exp_obd->obd_name, buf, name_len,
-		       cpy_len);
+		CDEBUG(D_DENTRY, "%s len %zd != %zd, concurrent rename?\n",
+		       buf, name_len, cpy_len);
 }
 
-void mdc_file_secctx_pack(struct ptlrpc_request *req, const char *secctx_name,
+void mdc_file_secctx_pack(struct req_capsule *pill, const char *secctx_name,
 			  const void *secctx, size_t secctx_size)
 {
 	size_t buf_size;
@@ -122,22 +120,22 @@ void mdc_file_secctx_pack(struct ptlrpc_request *req, const char *secctx_name,
 	if (!secctx_name)
 		return;
 
-	buf = req_capsule_client_get(&req->rq_pill, &RMF_FILE_SECCTX_NAME);
-	buf_size = req_capsule_get_size(&req->rq_pill, &RMF_FILE_SECCTX_NAME,
+	buf = req_capsule_client_get(pill, &RMF_FILE_SECCTX_NAME);
+	buf_size = req_capsule_get_size(pill, &RMF_FILE_SECCTX_NAME,
 					RCL_CLIENT);
 
 	LASSERT(buf_size == strlen(secctx_name) + 1);
 	memcpy(buf, secctx_name, buf_size);
 
-	buf = req_capsule_client_get(&req->rq_pill, &RMF_FILE_SECCTX);
-	buf_size = req_capsule_get_size(&req->rq_pill, &RMF_FILE_SECCTX,
+	buf = req_capsule_client_get(pill, &RMF_FILE_SECCTX);
+	buf_size = req_capsule_get_size(pill, &RMF_FILE_SECCTX,
 					RCL_CLIENT);
 
 	LASSERT(buf_size == secctx_size);
 	memcpy(buf, secctx, buf_size);
 }
 
-void mdc_file_encctx_pack(struct ptlrpc_request *req,
+void mdc_file_encctx_pack(struct req_capsule *pill,
 			  const void *encctx, size_t encctx_size)
 {
 	void *buf;
@@ -146,35 +144,36 @@ void mdc_file_encctx_pack(struct ptlrpc_request *req,
 	if (!encctx)
 		return;
 
-	buf = req_capsule_client_get(&req->rq_pill, &RMF_FILE_ENCCTX);
-	buf_size = req_capsule_get_size(&req->rq_pill, &RMF_FILE_ENCCTX,
+	buf = req_capsule_client_get(pill, &RMF_FILE_ENCCTX);
+	buf_size = req_capsule_get_size(pill, &RMF_FILE_ENCCTX,
 					RCL_CLIENT);
 
 	LASSERT(buf_size == encctx_size);
 	memcpy(buf, encctx, buf_size);
 }
 
-void mdc_file_sepol_pack(struct ptlrpc_request *req)
+void mdc_file_sepol_pack(struct req_capsule *pill)
 {
 	void *buf;
 	size_t buf_size;
+	struct ptlrpc_request *req = pill->rc_req;
 
 	if (strlen(req->rq_sepol) == 0)
 		return;
 
-	buf = req_capsule_client_get(&req->rq_pill, &RMF_SELINUX_POL);
-	buf_size = req_capsule_get_size(&req->rq_pill, &RMF_SELINUX_POL,
+	buf = req_capsule_client_get(pill, &RMF_SELINUX_POL);
+	buf_size = req_capsule_get_size(pill, &RMF_SELINUX_POL,
 					RCL_CLIENT);
 
 	LASSERT(buf_size == strlen(req->rq_sepol) + 1);
 	snprintf(buf, strlen(req->rq_sepol) + 1, "%s", req->rq_sepol);
 }
 
-void mdc_readdir_pack(struct ptlrpc_request *req, u64 pgoff, size_t size,
+void mdc_readdir_pack(struct req_capsule *pill, u64 pgoff, size_t size,
 		      const struct lu_fid *fid)
 {
-	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
-						    &RMF_MDT_BODY);
+	struct mdt_body *b = req_capsule_client_get(pill, &RMF_MDT_BODY);
+
 	b->mbo_fid1 = *fid;
 	b->mbo_valid |= OBD_MD_FLID;
 	b->mbo_size = pgoff;			/* !! */
@@ -184,7 +183,7 @@ void mdc_readdir_pack(struct ptlrpc_request *req, u64 pgoff, size_t size,
 }
 
 /* packing of MDS records */
-void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_create_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		     const void *data, size_t datalen, umode_t mode,
 		     uid_t uid, gid_t gid, kernel_cap_t cap_effective,
 		     u64 rdev)
@@ -195,7 +194,7 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
 		     sizeof(struct mdt_rec_create));
-	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
+	rec = req_capsule_client_get(pill, &RMF_REC_REINT);
 
 	rec->cr_opcode = REINT_CREATE;
 	rec->cr_fsuid = uid;
@@ -220,21 +219,21 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->cr_bias = op_data->op_bias;
 	rec->cr_umask = current_umask();
 
-	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
+	mdc_pack_name(pill, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 	if (data) {
-		tmp = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
+		tmp = req_capsule_client_get(pill, &RMF_EADATA);
 		memcpy(tmp, data, datalen);
 	}
 
-	mdc_file_secctx_pack(req, op_data->op_file_secctx_name,
+	mdc_file_secctx_pack(pill, op_data->op_file_secctx_name,
 			     op_data->op_file_secctx,
 			     op_data->op_file_secctx_size);
 
-	mdc_file_encctx_pack(req, op_data->op_file_encctx,
+	mdc_file_encctx_pack(pill, op_data->op_file_encctx,
 			     op_data->op_file_encctx_size);
 
 	/* pack SELinux policy info if any */
-	mdc_file_sepol_pack(req);
+	mdc_file_sepol_pack(pill);
 }
 
 static inline u64 mds_pack_open_flags(u64 flags)
@@ -269,7 +268,7 @@ static inline u64 mds_pack_open_flags(u64 flags)
 }
 
 /* packing of MDS records */
-void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_open_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		   umode_t mode, u64 rdev, u64 flags, const void *lmm,
 		   size_t lmmlen)
 {
@@ -279,7 +278,7 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
 		     sizeof(struct mdt_rec_create));
-	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
+	rec = req_capsule_client_get(pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
 	rec->cr_opcode = REINT_OPEN;
@@ -300,26 +299,26 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->cr_open_handle_old = op_data->op_open_handle;
 
 	if (op_data->op_name) {
-		mdc_pack_name(req, &RMF_NAME, op_data->op_name,
+		mdc_pack_name(pill, &RMF_NAME, op_data->op_name,
 			      op_data->op_namelen);
 
 		if (op_data->op_bias & MDS_CREATE_VOLATILE)
 			cr_flags |= MDS_OPEN_VOLATILE;
 
-		mdc_file_secctx_pack(req, op_data->op_file_secctx_name,
+		mdc_file_secctx_pack(pill, op_data->op_file_secctx_name,
 				     op_data->op_file_secctx,
 				     op_data->op_file_secctx_size);
 
-		mdc_file_encctx_pack(req, op_data->op_file_encctx,
+		mdc_file_encctx_pack(pill, op_data->op_file_encctx,
 				     op_data->op_file_encctx_size);
 
 		/* pack SELinux policy info if any */
-		mdc_file_sepol_pack(req);
+		mdc_file_sepol_pack(pill);
 	}
 
 	if (lmm) {
 		cr_flags |= MDS_OPEN_HAS_EA;
-		tmp = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
+		tmp = req_capsule_client_get(pill, &RMF_EADATA);
 		memcpy(tmp, lmm, lmmlen);
 		if (cr_flags & MDS_OPEN_PCC) {
 			LASSERT(op_data);
@@ -420,7 +419,7 @@ static void mdc_ioepoch_pack(struct mdt_ioepoch *epoch,
 	epoch->mio_padding = 0;
 }
 
-void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_setattr_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		      void *ea, size_t ealen)
 {
 	struct mdt_rec_setattr *rec;
@@ -428,13 +427,13 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
 					sizeof(struct mdt_rec_setattr));
-	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
+	rec = req_capsule_client_get(pill, &RMF_REC_REINT);
 	mdc_setattr_pack_rec(rec, op_data);
 
 	if (ealen == 0)
 		return;
 
-	lum = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
+	lum = req_capsule_client_get(pill, &RMF_EADATA);
 	if (!ea) { /* Remove LOV EA */
 		lum->lmm_magic = cpu_to_le32(LOV_USER_MAGIC_V1);
 		lum->lmm_stripe_size = 0;
@@ -446,13 +445,13 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	}
 }
 
-void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
+void mdc_unlink_pack(struct req_capsule *pill, struct md_op_data *op_data)
 {
 	struct mdt_rec_unlink *rec;
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
 		     sizeof(struct mdt_rec_unlink));
-	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
+	rec = req_capsule_client_get(pill, &RMF_REC_REINT);
 
 	rec->ul_opcode = op_data->op_cli_flags & CLI_RM_ENTRY ?
 			 REINT_RMENTRY : REINT_UNLINK;
@@ -467,19 +466,19 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	rec->ul_time = op_data->op_mod_time;
 	rec->ul_bias = op_data->op_bias;
 
-	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
+	mdc_pack_name(pill, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 
 	/* pack SELinux policy info if any */
-	mdc_file_sepol_pack(req);
+	mdc_file_sepol_pack(pill);
 }
 
-void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
+void mdc_link_pack(struct req_capsule *pill, struct md_op_data *op_data)
 {
 	struct mdt_rec_link *rec;
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
 		     sizeof(struct mdt_rec_link));
-	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
+	rec = req_capsule_client_get(pill, &RMF_REC_REINT);
 
 	rec->lk_opcode = REINT_LINK;
 	rec->lk_fsuid = op_data->op_fsuid; /* current->fsuid; */
@@ -492,13 +491,13 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	rec->lk_time = op_data->op_mod_time;
 	rec->lk_bias = op_data->op_bias;
 
-	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
+	mdc_pack_name(pill, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 
 	/* pack SELinux policy info if any */
-	mdc_file_sepol_pack(req);
+	mdc_file_sepol_pack(pill);
 }
 
-static void mdc_close_intent_pack(struct ptlrpc_request *req,
+static void mdc_close_intent_pack(struct req_capsule *pill,
 				  struct md_op_data *op_data)
 {
 	enum mds_op_bias bias = op_data->op_bias;
@@ -508,7 +507,7 @@ static void mdc_close_intent_pack(struct ptlrpc_request *req,
 	if (!(bias & (MDS_CLOSE_INTENT | MDS_CLOSE_MIGRATE)))
 		return;
 
-	data = req_capsule_client_get(&req->rq_pill, &RMF_CLOSE_DATA);
+	data = req_capsule_client_get(pill, &RMF_CLOSE_DATA);
 	LASSERT(data);
 
 	lock = ldlm_handle2lock(&op_data->op_lease_handle);
@@ -534,7 +533,7 @@ static void mdc_close_intent_pack(struct ptlrpc_request *req,
 		} else {
 			size_t count = sync->resync_count;
 
-			memcpy(req_capsule_client_get(&req->rq_pill, &RMF_U32),
+			memcpy(req_capsule_client_get(pill, &RMF_U32),
 				op_data->op_data, count * sizeof(u32));
 		}
 	} else if (bias & MDS_PCC_ATTACH) {
@@ -542,7 +541,7 @@ static void mdc_close_intent_pack(struct ptlrpc_request *req,
 	}
 }
 
-void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_rename_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		     const char *old, size_t oldlen,
 		     const char *new, size_t newlen)
 {
@@ -550,7 +549,7 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
 		     sizeof(struct mdt_rec_rename));
-	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
+	rec = req_capsule_client_get(pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
 	rec->rn_opcode = REINT_RENAME;
@@ -565,16 +564,16 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->rn_mode = op_data->op_mode;
 	rec->rn_bias = op_data->op_bias;
 
-	mdc_pack_name(req, &RMF_NAME, old, oldlen);
+	mdc_pack_name(pill, &RMF_NAME, old, oldlen);
 
 	if (new)
-		mdc_pack_name(req, &RMF_SYMTGT, new, newlen);
+		mdc_pack_name(pill, &RMF_SYMTGT, new, newlen);
 
 	/* pack SELinux policy info if any */
-	mdc_file_sepol_pack(req);
+	mdc_file_sepol_pack(pill);
 }
 
-void mdc_migrate_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+void mdc_migrate_pack(struct req_capsule *pill, struct md_op_data *op_data,
 		      const char *name, size_t namelen)
 {
 	struct mdt_rec_rename *rec;
@@ -582,7 +581,7 @@ void mdc_migrate_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
 		     sizeof(struct mdt_rec_rename));
-	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
+	rec = req_capsule_client_get(pill, &RMF_REC_REINT);
 
 	rec->rn_opcode	 = REINT_MIGRATE;
 	rec->rn_fsuid	 = op_data->op_fsuid;
@@ -596,25 +595,24 @@ void mdc_migrate_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->rn_mode	 = op_data->op_mode;
 	rec->rn_bias	 = op_data->op_bias;
 
-	mdc_pack_name(req, &RMF_NAME, name, namelen);
+	mdc_pack_name(pill, &RMF_NAME, name, namelen);
 
 	if (op_data->op_bias & MDS_CLOSE_MIGRATE) {
 		struct mdt_ioepoch *epoch;
 
-		mdc_close_intent_pack(req, op_data);
-		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
+		mdc_close_intent_pack(pill, op_data);
+		epoch = req_capsule_client_get(pill, &RMF_MDT_EPOCH);
 		mdc_ioepoch_pack(epoch, op_data);
 	}
 
-	ea = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
+	ea = req_capsule_client_get(pill, &RMF_EADATA);
 	memcpy(ea, op_data->op_data, op_data->op_data_size);
 }
 
-void mdc_getattr_pack(struct ptlrpc_request *req, u64 valid, u32 flags,
+void mdc_getattr_pack(struct req_capsule *pill, u64 valid, u32 flags,
 		      struct md_op_data *op_data, size_t ea_size)
 {
-	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
-						    &RMF_MDT_BODY);
+	struct mdt_body *b = req_capsule_client_get(pill, &RMF_MDT_BODY);
 
 	b->mbo_valid = valid;
 	if (op_data->op_bias & MDS_CROSS_REF)
@@ -628,17 +626,17 @@ void mdc_getattr_pack(struct ptlrpc_request *req, u64 valid, u32 flags,
 	b->mbo_valid |= OBD_MD_FLID;
 
 	if (op_data->op_name)
-		mdc_pack_name(req, &RMF_NAME, op_data->op_name,
+		mdc_pack_name(pill, &RMF_NAME, op_data->op_name,
 			      op_data->op_namelen);
 }
 
-void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
+void mdc_close_pack(struct req_capsule *pill, struct md_op_data *op_data)
 {
 	struct mdt_ioepoch *epoch;
 	struct mdt_rec_setattr *rec;
 
-	epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
-	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
+	epoch = req_capsule_client_get(pill, &RMF_MDT_EPOCH);
+	rec = req_capsule_client_get(pill, &RMF_REC_REINT);
 
 	mdc_setattr_pack_rec(rec, op_data);
 	/*
@@ -654,5 +652,5 @@ void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 		rec->sa_valid &= ~MDS_ATTR_ATIME;
 
 	mdc_ioepoch_pack(epoch, op_data);
-	mdc_close_intent_pack(req, op_data);
+	mdc_close_intent_pack(pill, op_data);
 }
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 5373ec9..4135c3a 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -348,8 +348,8 @@ static int mdc_save_lovea(struct ptlrpc_request *req, void *data, u32 size)
 	lit->opc = (u64)it->it_op;
 
 	/* pack the intended request */
-	mdc_open_pack(req, op_data, it->it_create_mode, 0, it->it_flags, lmm,
-		      lmmsize);
+	mdc_open_pack(&req->rq_pill, op_data, it->it_create_mode, 0,
+		      it->it_flags, lmm, lmmsize);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     mdt_md_capsule_size);
@@ -487,11 +487,11 @@ static int mdc_save_lovea(struct ptlrpc_request *req, void *data, u32 size)
 					 exp->exp_connect_data.ocd_max_easize);
 
 	/* pack the intended request */
-	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
+	mdc_pack_body(&req->rq_pill, &op_data->op_fid1, op_data->op_valid,
 		      ea_vals_buf_size, -1, 0);
 
 	/* get SELinux policy info if any */
-	mdc_file_sepol_pack(req);
+	mdc_file_sepol_pack(&req->rq_pill);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_SERVER,
 			     GA_DEFAULT_EA_NAME_LEN * GA_DEFAULT_EA_NUM);
@@ -559,7 +559,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req, void *data, u32 size)
 		easize = obd->u.cli.cl_max_mds_easize;
 
 	/* pack the intended request */
-	mdc_getattr_pack(req, valid, it->it_flags, op_data, easize);
+	mdc_getattr_pack(&req->rq_pill, valid, it->it_flags, op_data, easize);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, easize);
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 786b23d..3f4e28a 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -139,7 +139,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		CDEBUG(D_INODE, "setting mtime %lld, ctime %lld\n",
 		       op_data->op_attr.ia_mtime.tv_sec,
 		       op_data->op_attr.ia_ctime.tv_sec);
-	mdc_setattr_pack(req, op_data, ea, ealen);
+	mdc_setattr_pack(&req->rq_pill, op_data, ea, ealen);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, 0);
 
@@ -227,7 +227,7 @@ int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 	 * mdc_create_pack() fills msg->bufs[1] with name and msg->bufs[2] with
 	 * tgt, for symlinks or lov MD data.
 	 */
-	mdc_create_pack(req, op_data, data, datalen, mode, uid,
+	mdc_create_pack(&req->rq_pill, op_data, data, datalen, mode, uid,
 			gid, cap_effective, rdev);
 
 	ptlrpc_request_set_replen(req);
@@ -325,7 +325,7 @@ int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 	}
 
-	mdc_unlink_pack(req, op_data);
+	mdc_unlink_pack(&req->rq_pill, op_data);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obd->u.cli.cl_default_mds_easize);
@@ -381,7 +381,7 @@ int mdc_link(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 	}
 
-	mdc_link_pack(req, op_data);
+	mdc_link_pack(&req->rq_pill, op_data);
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_reint(req, LUSTRE_IMP_FULL);
@@ -457,9 +457,10 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 		ldlm_cli_cancel_list(&cancels, count, req, 0);
 
 	if (op_data->op_cli_flags & CLI_MIGRATE)
-		mdc_migrate_pack(req, op_data, old, oldlen);
+		mdc_migrate_pack(&req->rq_pill, op_data, old, oldlen);
 	else
-		mdc_rename_pack(req, op_data, old, oldlen, new, newlen);
+		mdc_rename_pack(&req->rq_pill, op_data, old, oldlen,
+				new, newlen);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obd->u.cli.cl_default_mds_easize);
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 7df2c59..1fb9c46 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -116,7 +116,7 @@ static int mdc_get_root(struct obd_export *exp, const char *fileset,
 		ptlrpc_request_free(req);
 		return rc;
 	}
-	mdc_pack_body(req, NULL, 0, 0, -1, 0);
+	mdc_pack_body(&req->rq_pill, NULL, 0, 0, -1, 0);
 	if (fileset) {
 		char *name = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
 
@@ -225,7 +225,7 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 again:
-	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
+	mdc_pack_body(&req->rq_pill, &op_data->op_fid1, op_data->op_valid,
 		      op_data->op_mode, -1, 0);
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
@@ -281,7 +281,7 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 	}
 
 again:
-	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
+	mdc_pack_body(&req->rq_pill, &op_data->op_fid1, op_data->op_valid,
 		      op_data->op_mode, op_data->op_suppgids[0], 0);
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     op_data->op_mode);
@@ -391,7 +391,8 @@ static int mdc_xattr_common(struct obd_export *exp,
 		rec->sx_flags = flags;
 
 	} else {
-		mdc_pack_body(req, fid, valid, output_size, suppgid, flags);
+		mdc_pack_body(&req->rq_pill, fid, valid, output_size,
+			      suppgid, flags);
 	}
 
 	if (xattr_name) {
@@ -403,7 +404,7 @@ static int mdc_xattr_common(struct obd_export *exp,
 		memcpy(tmp, input, input_size);
 	}
 
-	mdc_file_sepol_pack(req);
+	mdc_file_sepol_pack(&req->rq_pill);
 
 	if (req_capsule_has_field(&req->rq_pill, &RMF_EADATA, RCL_SERVER))
 		req_capsule_set_size(&req->rq_pill, &RMF_EADATA,
@@ -510,13 +511,11 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 }
 
 
-static int mdc_get_lustre_md(struct obd_export *exp,
-			     struct ptlrpc_request *req,
+static int mdc_get_lustre_md(struct obd_export *exp, struct req_capsule *pill,
 			     struct obd_export *dt_exp,
 			     struct obd_export *md_exp,
 			     struct lustre_md *md)
 {
-	struct req_capsule *pill = &req->rq_pill;
 	int rc;
 
 	LASSERT(md);
@@ -624,7 +623,7 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 	 * in reply buffer.
 	 */
 	if (md->body->mbo_valid & OBD_MD_FLACL)
-		rc = mdc_unpack_acl(req, md);
+		rc = mdc_unpack_acl(pill, md);
 
 out:
 	if (rc)
@@ -940,7 +939,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		op_data->op_xvalid &= ~(OP_XVALID_LAZYSIZE |
 					OP_XVALID_LAZYBLOCKS);
 
-	mdc_close_pack(req, op_data);
+	mdc_close_pack(&req->rq_pill, op_data);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obd->u.cli.cl_default_mds_easize);
@@ -1034,7 +1033,7 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 	for (i = 0; i < npages; i++)
 		desc->bd_frag_ops->add_kiov_frag(desc, pages[i], 0, PAGE_SIZE);
 
-	mdc_readdir_pack(req, offset, PAGE_SIZE * npages, fid);
+	mdc_readdir_pack(&req->rq_pill, offset, PAGE_SIZE * npages, fid);
 
 	ptlrpc_request_set_replen(req);
 	rc = ptlrpc_queue_wait(req);
@@ -1727,7 +1726,7 @@ static int mdc_ioc_hsm_progress(struct obd_export *exp,
 		goto out;
 	}
 
-	mdc_pack_body(req, NULL, 0, 0, -1, 0);
+	mdc_pack_body(&req->rq_pill, NULL, 0, 0, -1, 0);
 
 	/* Copy hsm_progress struct */
 	req_hpk = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_PROGRESS);
@@ -1786,7 +1785,7 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, u32 archive_count,
 		return -ENOMEM;
 	}
 
-	mdc_pack_body(req, NULL, 0, 0, -1, 0);
+	mdc_pack_body(&req->rq_pill, NULL, 0, 0, -1, 0);
 
 	archive_array = req_capsule_client_get(&req->rq_pill,
 					       &RMF_MDS_HSM_ARCHIVE);
@@ -1828,7 +1827,7 @@ static int mdc_ioc_hsm_current_action(struct obd_export *exp,
 		return rc;
 	}
 
-	mdc_pack_body(req, &op_data->op_fid1, 0, 0,
+	mdc_pack_body(&req->rq_pill, &op_data->op_fid1, 0, 0,
 		      op_data->op_suppgids[0], 0);
 
 	ptlrpc_request_set_replen(req);
@@ -1864,7 +1863,7 @@ static int mdc_ioc_hsm_ct_unregister(struct obd_import *imp)
 		goto out;
 	}
 
-	mdc_pack_body(req, NULL, 0, 0, -1, 0);
+	mdc_pack_body(&req->rq_pill, NULL, 0, 0, -1, 0);
 
 	ptlrpc_request_set_replen(req);
 
@@ -1893,7 +1892,7 @@ static int mdc_ioc_hsm_state_get(struct obd_export *exp,
 		return rc;
 	}
 
-	mdc_pack_body(req, &op_data->op_fid1, 0, 0,
+	mdc_pack_body(&req->rq_pill, &op_data->op_fid1, 0, 0,
 		      op_data->op_suppgids[0], 0);
 
 	ptlrpc_request_set_replen(req);
@@ -1934,7 +1933,7 @@ static int mdc_ioc_hsm_state_set(struct obd_export *exp,
 		return rc;
 	}
 
-	mdc_pack_body(req, &op_data->op_fid1, 0, 0,
+	mdc_pack_body(&req->rq_pill, &op_data->op_fid1, 0, 0,
 		      op_data->op_suppgids[0], 0);
 
 	/* Copy states */
@@ -1983,7 +1982,7 @@ static int mdc_ioc_hsm_request(struct obd_export *exp,
 		return rc;
 	}
 
-	mdc_pack_body(req, NULL, 0, 0, -1, 0);
+	mdc_pack_body(&req->rq_pill, NULL, 0, 0, -1, 0);
 
 	/* Copy hsm_request struct */
 	req_hr = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_REQUEST);
@@ -2115,7 +2114,7 @@ static int mdc_ioc_swap_layouts(struct obd_export *exp,
 		return rc;
 	}
 
-	mdc_swap_layouts_pack(req, op_data);
+	mdc_swap_layouts_pack(&req->rq_pill, op_data);
 
 	payload = req_capsule_client_get(&req->rq_pill, &RMF_SWAP_LAYOUTS);
 	LASSERT(payload);
@@ -2308,7 +2307,7 @@ static int mdc_get_info_rpc(struct obd_export *exp,
 	if (rc == 0 || rc == -EREMOTE) {
 		tmp = req_capsule_server_get(&req->rq_pill, &RMF_GETINFO_VAL);
 		memcpy(val, tmp, vallen);
-		if (ptlrpc_rep_need_swab(req)) {
+		if (req_capsule_rep_need_swab(&req->rq_pill)) {
 			if (KEY_IS(KEY_FID2PATH))
 				lustre_swab_fid2path(val);
 		}
@@ -2560,7 +2559,7 @@ static int mdc_fsync(struct obd_export *exp, const struct lu_fid *fid,
 		return rc;
 	}
 
-	mdc_pack_body(req, fid, 0, 0, -1, 0);
+	mdc_pack_body(&req->rq_pill, fid, 0, 0, -1, 0);
 
 	ptlrpc_request_set_replen(req);
 
@@ -2627,7 +2626,7 @@ static int mdc_rmfid(struct obd_export *exp, struct fid_array *fa,
 	tmp = req_capsule_client_get(&req->rq_pill, &RMF_FID_ARRAY);
 	memcpy(tmp, fa->fa_fids, flen);
 
-	mdc_pack_body(req, NULL, 0, 0, -1, 0);
+	mdc_pack_body(&req->rq_pill, NULL, 0, 0, -1, 0);
 	b = req_capsule_client_get(&req->rq_pill, &RMF_MDT_BODY);
 	b->mbo_ctime = ktime_get_real_seconds();
 
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 5ea965c..1dfc74b 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -1442,7 +1442,7 @@ static int mgc_process_recover_log(struct obd_device *obd,
 		goto out;
 	}
 
-	mne_swab = ptlrpc_rep_need_swab(req);
+	mne_swab = req_capsule_rep_need_swab(&req->rq_pill);
 
 	for (i = 0; i < nrpages && ealen > 0; i++) {
 		int rc2;
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 8bbe68b..836b2a2 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -1756,7 +1756,7 @@ void req_capsule_init(struct req_capsule *pill,
 	if (req && pill == &req->rq_pill && req->rq_pill_init)
 		return;
 
-	memset(pill, 0, sizeof(*pill));
+	pill->rc_fmt = NULL;
 	pill->rc_req = req;
 	pill->rc_loc = location;
 	req_capsule_init_area(pill);
@@ -1780,10 +1780,7 @@ static int __req_format_is_sane(const struct req_format *fmt)
 static struct lustre_msg *__req_msg(const struct req_capsule *pill,
 				    enum req_location loc)
 {
-	struct ptlrpc_request *req;
-
-	req = pill->rc_req;
-	return loc == RCL_CLIENT ? req->rq_reqmsg : req->rq_repmsg;
+	return loc == RCL_CLIENT ? pill->rc_reqmsg : pill->rc_repmsg;
 }
 
 /**
@@ -1881,6 +1878,26 @@ u32 __req_capsule_offset(const struct req_capsule *pill,
 	return offset;
 }
 
+void req_capsule_set_swabbed(struct req_capsule *pill, enum req_location loc,
+			    u32 index)
+{
+	if (loc == RCL_CLIENT)
+		req_capsule_set_req_swabbed(pill, index);
+	else
+		req_capsule_set_rep_swabbed(pill, index);
+}
+
+bool req_capsule_need_swab(struct req_capsule *pill, enum req_location loc,
+			   u32 index)
+{
+	if (loc == RCL_CLIENT)
+		return (req_capsule_req_need_swab(pill) &&
+			!req_capsule_req_swabbed(pill, index));
+
+	return (req_capsule_rep_need_swab(pill) &&
+	       !req_capsule_rep_swabbed(pill, index));
+}
+
 /**
  * Helper for __req_capsule_get(); swabs value / array of values and/or dumps
  * them if desired.
@@ -1898,12 +1915,11 @@ u32 __req_capsule_offset(const struct req_capsule *pill,
 	int size;
 	int rc = 0;
 	bool do_swab;
-	bool inout = loc == RCL_CLIENT;
 	bool array = field->rmf_flags & RMF_F_STRUCT_ARRAY;
 
 	swabber = swabber ?: field->rmf_swabber;
 
-	if (ptlrpc_buf_need_swab(pill->rc_req, inout, offset) &&
+	if (req_capsule_need_swab(pill, loc, offset) &&
 	    (swabber || field->rmf_swab_len) && value)
 		do_swab = true;
 	else
@@ -1968,7 +1984,7 @@ u32 __req_capsule_offset(const struct req_capsule *pill,
 		}
 	}
 	if (do_swab)
-		ptlrpc_buf_set_swabbed(pill->rc_req, inout, offset);
+		req_capsule_set_swabbed(pill, loc, offset);
 
 	return 0;
 }
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 133202d..6710e6b 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -72,25 +72,6 @@ u32 lustre_msg_hdr_size(u32 magic, u32 count)
 	}
 }
 
-void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
-			    u32 index)
-{
-	if (inout)
-		lustre_set_req_swabbed(req, index);
-	else
-		lustre_set_rep_swabbed(req, index);
-}
-
-bool ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
-			  u32 index)
-{
-	if (inout)
-		return (ptlrpc_req_need_swab(req) &&
-			!lustre_req_swabbed(req, index));
-
-	return (ptlrpc_rep_need_swab(req) && !lustre_rep_swabbed(req, index));
-}
-
 /* early reply size */
 u32 lustre_msg_early_size(void)
 {
@@ -576,7 +557,8 @@ int ptlrpc_unpack_req_msg(struct ptlrpc_request *req, int len)
 
 	rc = __lustre_unpack_msg(req->rq_reqmsg, len);
 	if (rc == 1) {
-		lustre_set_req_swabbed(req, MSG_PTLRPC_HEADER_OFF);
+		req_capsule_set_req_swabbed(&req->rq_pill,
+					    MSG_PTLRPC_HEADER_OFF);
 		rc = 0;
 	}
 	return rc;
@@ -588,26 +570,30 @@ int ptlrpc_unpack_rep_msg(struct ptlrpc_request *req, int len)
 
 	rc = __lustre_unpack_msg(req->rq_repmsg, len);
 	if (rc == 1) {
-		lustre_set_rep_swabbed(req, MSG_PTLRPC_HEADER_OFF);
+		req_capsule_set_rep_swabbed(&req->rq_pill,
+					    MSG_PTLRPC_HEADER_OFF);
 		rc = 0;
 	}
 	return rc;
 }
 
-static inline int lustre_unpack_ptlrpc_body_v2(struct ptlrpc_request *req,
-					       const int inout, int offset)
+static inline int
+lustre_unpack_ptlrpc_body_v2(struct ptlrpc_request *req,
+			     enum req_location loc, int offset)
 {
 	struct ptlrpc_body *pb;
-	struct lustre_msg_v2 *m = inout ? req->rq_reqmsg : req->rq_repmsg;
+	struct lustre_msg_v2 *m;
+
+	m = loc == RCL_CLIENT ? req->rq_reqmsg : req->rq_repmsg;
 
 	pb = lustre_msg_buf_v2(m, offset, sizeof(struct ptlrpc_body_v2));
 	if (!pb) {
 		CERROR("error unpacking ptlrpc body\n");
 		return -EFAULT;
 	}
-	if (ptlrpc_buf_need_swab(req, inout, offset)) {
+	if (req_capsule_need_swab(&req->rq_pill, loc, offset)) {
 		lustre_swab_ptlrpc_body(pb);
-		ptlrpc_buf_set_swabbed(req, inout, offset);
+		req_capsule_set_swabbed(&req->rq_pill, loc, offset);
 	}
 
 	if ((pb->pb_version & ~LUSTRE_VERSION_MASK) != PTLRPC_MSG_VERSION) {
@@ -615,7 +601,7 @@ static inline int lustre_unpack_ptlrpc_body_v2(struct ptlrpc_request *req,
 		return -EINVAL;
 	}
 
-	if (!inout)
+	if (loc == RCL_SERVER)
 		pb->pb_status = ptlrpc_status_ntoh(pb->pb_status);
 
 	return 0;
@@ -625,7 +611,7 @@ int lustre_unpack_req_ptlrpc_body(struct ptlrpc_request *req, int offset)
 {
 	switch (req->rq_reqmsg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
-		return lustre_unpack_ptlrpc_body_v2(req, 1, offset);
+		return lustre_unpack_ptlrpc_body_v2(req, RCL_CLIENT, offset);
 	default:
 		CERROR("bad lustre msg magic: %08x\n",
 		       req->rq_reqmsg->lm_magic);
@@ -637,7 +623,7 @@ int lustre_unpack_rep_ptlrpc_body(struct ptlrpc_request *req, int offset)
 {
 	switch (req->rq_repmsg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
-		return lustre_unpack_ptlrpc_body_v2(req, 0, offset);
+		return lustre_unpack_ptlrpc_body_v2(req, RCL_SERVER, offset);
 	default:
 		CERROR("bad lustre msg magic: %08x\n",
 		       req->rq_repmsg->lm_magic);
@@ -2454,7 +2440,8 @@ static inline int req_ptlrpc_body_swabbed(struct ptlrpc_request *req)
 
 	switch (req->rq_reqmsg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
-		return lustre_req_swabbed(req, MSG_PTLRPC_BODY_OFF);
+		return req_capsule_req_swabbed(&req->rq_pill,
+					       MSG_PTLRPC_BODY_OFF);
 	default:
 		CERROR("bad lustre msg magic: %#08X\n",
 		       req->rq_reqmsg->lm_magic);
@@ -2469,7 +2456,8 @@ static inline int rep_ptlrpc_body_swabbed(struct ptlrpc_request *req)
 
 	switch (req->rq_repmsg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
-		return lustre_rep_swabbed(req, MSG_PTLRPC_BODY_OFF);
+		return req_capsule_rep_swabbed(&req->rq_pill,
+					       MSG_PTLRPC_BODY_OFF);
 	default:
 		/* uninitialized yet */
 		return 0;
@@ -2491,7 +2479,7 @@ void _debug_req(struct ptlrpc_request *req,
 	if (req->rq_repmsg)
 		rep_ok = true;
 
-	if (ptlrpc_req_need_swab(req)) {
+	if (req_capsule_req_need_swab(&req->rq_pill)) {
 		req_ok = req_ok && req_ptlrpc_body_swabbed(req);
 		rep_ok = rep_ok && rep_ptlrpc_body_swabbed(req);
 	}
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index c65cf89..7e6b681 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -961,7 +961,8 @@ static int do_cli_unwrap_reply(struct ptlrpc_request *req)
 	rc = __lustre_unpack_msg(req->rq_repdata, req->rq_repdata_len);
 	switch (rc) {
 	case 1:
-		lustre_set_rep_swabbed(req, MSG_PTLRPC_HEADER_OFF);
+		req_capsule_set_rep_swabbed(&req->rq_pill,
+					    MSG_PTLRPC_HEADER_OFF);
 	case 0:
 		break;
 	default:
@@ -2090,7 +2091,8 @@ int sptlrpc_svc_unwrap_request(struct ptlrpc_request *req)
 	rc = __lustre_unpack_msg(msg, req->rq_reqdata_len);
 	switch (rc) {
 	case 1:
-		lustre_set_req_swabbed(req, MSG_PTLRPC_HEADER_OFF);
+		req_capsule_set_req_swabbed(&req->rq_pill,
+					    MSG_PTLRPC_HEADER_OFF);
 	case 0:
 		break;
 	default:
diff --git a/fs/lustre/ptlrpc/sec_plain.c b/fs/lustre/ptlrpc/sec_plain.c
index 7920ab0..0d1c591 100644
--- a/fs/lustre/ptlrpc/sec_plain.c
+++ b/fs/lustre/ptlrpc/sec_plain.c
@@ -221,7 +221,7 @@ int plain_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 		return -EPROTO;
 	}
 
-	swabbed = ptlrpc_rep_need_swab(req);
+	swabbed = req_capsule_rep_need_swab(&req->rq_pill);
 
 	phdr = lustre_msg_buf(msg, PLAIN_PACK_HDR_OFF, sizeof(*phdr));
 	if (!phdr) {
@@ -736,7 +736,7 @@ static int plain_accept(struct ptlrpc_request *req)
 		return SECSVC_DROP;
 	}
 
-	swabbed = ptlrpc_req_need_swab(req);
+	swabbed = req_capsule_req_need_swab(&req->rq_pill);
 
 	phdr = lustre_msg_buf(msg, PLAIN_PACK_HDR_OFF, sizeof(*phdr));
 	if (!phdr) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
