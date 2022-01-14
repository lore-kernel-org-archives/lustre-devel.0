Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 10359C433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A443121FFAB;
	Thu, 13 Jan 2022 17:38:41 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1FE723AD835
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:10 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CFFAF100F331;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CBF9DA8102; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:51 -0500
Message-Id: <1642124283-10148-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/24] lustre: llite: access striped
 directory with missing stripe
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

This patch allows accessing striped directory with missing stripes:
* lmv_revalidate_slave() skip error if one stripe returns -ESHUTDOWN.
* add ll_dir_flush(), which will return error found in reading
  stripe dir pages, thus 'ls' can list dirents on other stripes, and
  return an error in the end.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9206
Lustre-commit: c0fa6f7a10d1162f8 ("LU-9206 llite: access striped directory with missing stripe")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45631
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h          |  9 ++++++---
 fs/lustre/include/obd_class.h    |  7 +++----
 fs/lustre/llite/dir.c            | 43 ++++++++++++++++++++++++++++++----------
 fs/lustre/llite/llite_internal.h |  8 ++++++--
 fs/lustre/llite/llite_nfs.c      |  2 +-
 fs/lustre/llite/statahead.c      |  6 +++---
 fs/lustre/lmv/lmv_intent.c       |  4 ++--
 fs/lustre/lmv/lmv_obd.c          | 22 ++++++++++----------
 fs/lustre/mdc/mdc_request.c      |  7 +++----
 9 files changed, 69 insertions(+), 39 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index f6b9d16..ecee321 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -826,10 +826,12 @@ struct md_op_data {
 	u32			op_archive_id;
 };
 
-struct md_callback {
-	int (*md_blocking_ast)(struct ldlm_lock *lock,
+struct md_readdir_info {
+	int (*mr_blocking_ast)(struct ldlm_lock *lock,
 			       struct ldlm_lock_desc *desc,
 			       void *data, int flag);
+	/* if striped directory is partially read, the result is stored here */
+	int mr_partial_readdir_rc;
 };
 
 struct md_enqueue_info;
@@ -1028,8 +1030,9 @@ struct md_ops {
 	int (*fsync)(struct obd_export *, const struct lu_fid *,
 		     struct ptlrpc_request **);
 	int (*read_page)(struct obd_export *, struct md_op_data *,
-			 struct md_callback *cb_op, u64 hash_offset,
+			 struct md_readdir_info *mrinfo, u64 hash_offset,
 			 struct page **ppage);
+
 	int (*unlink)(struct obd_export *, struct md_op_data *,
 		      struct ptlrpc_request **);
 
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index f2a3d2b..b69331d 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1399,9 +1399,8 @@ static inline int md_file_resync(struct obd_export *exp,
 
 static inline int md_read_page(struct obd_export *exp,
 			       struct md_op_data *op_data,
-			       struct md_callback *cb_op,
-			       u64 hash_offset,
-			       struct page **ppage)
+			       struct md_readdir_info *mrinfo,
+			       u64 hash_offset, struct page **ppage)
 {
 	int rc;
 
@@ -1412,7 +1411,7 @@ static inline int md_read_page(struct obd_export *exp,
 	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
 			     LPROC_MD_READ_PAGE);
 
-	return MDP(exp->exp_obd, read_page)(exp, op_data, cb_op, hash_offset,
+	return MDP(exp->exp_obd, read_page)(exp, op_data, mrinfo, hash_offset,
 					    ppage);
 }
 
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 43cd3cc..b4870d9 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -140,17 +140,21 @@
  *
  */
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
-			     u64 offset)
+			     u64 offset, int *partial_readdir_rc)
 {
-	struct md_callback cb_op;
+	struct md_readdir_info mrinfo = {
+		.mr_blocking_ast = ll_md_blocking_ast
+	};
 	struct page *page;
 	int rc;
 
-	cb_op.md_blocking_ast = ll_md_blocking_ast;
-	rc = md_read_page(ll_i2mdexp(dir), op_data, &cb_op, offset, &page);
+	rc = md_read_page(ll_i2mdexp(dir), op_data, &mrinfo, offset, &page);
 	if (rc)
 		return ERR_PTR(rc);
 
+	if (partial_readdir_rc && mrinfo.mr_partial_readdir_rc)
+		*partial_readdir_rc = mrinfo.mr_partial_readdir_rc;
+
 	return page;
 }
 
@@ -177,7 +181,7 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
 }
 
 int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
-		struct dir_context *ctx)
+		struct dir_context *ctx, int *partial_readdir_rc)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	u64 pos = *ppos;
@@ -194,7 +198,7 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 			return rc;
 	}
 
-	page = ll_get_dir_page(inode, op_data, pos);
+	page = ll_get_dir_page(inode, op_data, pos, partial_readdir_rc);
 
 	while (rc == 0 && !done) {
 		struct lu_dirpage *dp;
@@ -285,7 +289,8 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 					le32_to_cpu(dp->ldp_flags) &
 					LDF_COLLIDE);
 			next = pos;
-			page = ll_get_dir_page(inode, op_data, pos);
+			page = ll_get_dir_page(inode, op_data, pos,
+					       partial_readdir_rc);
 		}
 	}
 
@@ -305,8 +310,13 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	struct md_op_data *op_data;
 	struct lu_fid pfid = { 0 };
 	ktime_t kstart = ktime_get();
+	/* result of possible partial readdir */
+	int partial_readdir_rc = 0;
 	int rc;
 
+	LASSERT(lfd);
+	pos = lfd->lfd_pos;
+
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op:inode=" DFID "(%p) pos/size %lu/%llu 32bit_api %d\n",
 	       PFID(ll_inode2fid(inode)), inode, (unsigned long)pos,
@@ -369,10 +379,11 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	op_data->op_fid3 = pfid;
 
 	ctx->pos = pos;
-	rc = ll_dir_read(inode, &pos, op_data, ctx);
+	rc = ll_dir_read(inode, &pos, op_data, ctx, &partial_readdir_rc);
 	pos = ctx->pos;
-	if (lfd)
-		lfd->lfd_pos = pos;
+	lfd->lfd_pos = pos;
+	if (!lfd->fd_partial_readdir_rc)
+		lfd->fd_partial_readdir_rc = partial_readdir_rc;
 
 	if (pos == MDS_DIR_END_OFF) {
 		if (api32)
@@ -2294,6 +2305,17 @@ static int ll_dir_release(struct inode *inode, struct file *file)
 	return ll_file_release(inode, file);
 }
 
+/* notify error if partially read striped directory */
+static int ll_dir_flush(struct file *file, fl_owner_t id)
+{
+	struct ll_file_data *lfd = file->private_data;
+	int rc = lfd->fd_partial_readdir_rc;
+
+	lfd->fd_partial_readdir_rc = 0;
+
+	return rc;
+}
+
 const struct file_operations ll_dir_operations = {
 	.llseek			= ll_dir_seek,
 	.open			= ll_dir_open,
@@ -2302,4 +2324,5 @@ static int ll_dir_release(struct inode *inode, struct file *file)
 	.iterate_shared		= ll_readdir,
 	.unlocked_ioctl		= ll_dir_ioctl,
 	.fsync			= ll_fsync,
+	.flush			= ll_dir_flush,
 };
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 0398b5f..54f0218 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -920,6 +920,10 @@ struct ll_file_data {
 	 */
 	u32 fd_layout_version;
 	struct pcc_file fd_pcc_file;
+	/* striped directory may read partially if some stripe inaccessible,
+	 * -errno is saved here, and will return to user in close().
+	 */
+	int fd_partial_readdir_rc;
 };
 
 void llite_tunables_unregister(void);
@@ -1043,11 +1047,11 @@ enum {
 extern const struct file_operations ll_dir_operations;
 extern const struct inode_operations ll_dir_inode_operations;
 int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
-		struct dir_context *ctx);
+		struct dir_context *ctx, int *partial_readdir_rc);
 int ll_get_mdt_idx(struct inode *inode);
 int ll_get_mdt_idx_by_fid(struct ll_sb_info *sbi, const struct lu_fid *fid);
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
-			     u64 offset);
+			     u64 offset, int *partial_readdir_rc);
 void ll_release_page(struct inode *inode, struct page *page, bool remove);
 int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl);
 
diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index 07fcad6..3c4c9ef 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -233,7 +233,7 @@ static int ll_get_name(struct dentry *dentry, char *name,
 	}
 
 	inode_lock(dir);
-	rc = ll_dir_read(dir, &pos, op_data, &lgd.ctx);
+	rc = ll_dir_read(dir, &pos, op_data, &lgd.ctx, NULL);
 	inode_unlock(dir);
 	ll_finish_md_op_data(op_data);
 	if (!rc && !lgd.lgd_found)
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index afb668e..c781e49 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1041,7 +1041,7 @@ static int ll_statahead_thread(void *arg)
 		}
 
 		sai->sai_in_readpage = 1;
-		page = ll_get_dir_page(dir, op_data, pos);
+		page = ll_get_dir_page(dir, op_data, pos, NULL);
 		ll_unlock_md_op_lsm(op_data);
 		sai->sai_in_readpage = 0;
 		if (IS_ERR(page)) {
@@ -1325,7 +1325,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 	/**
 	 * FIXME choose the start offset of the readdir
 	 */
-	page = ll_get_dir_page(dir, op_data, pos);
+	page = ll_get_dir_page(dir, op_data, pos, NULL);
 
 	while (1) {
 		struct lu_dirpage *dp;
@@ -1429,7 +1429,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			ll_release_page(dir, page,
 					le32_to_cpu(dp->ldp_flags) &
 					LDF_COLLIDE);
-			page = ll_get_dir_page(dir, op_data, pos);
+			page = ll_get_dir_page(dir, op_data, pos, NULL);
 		}
 	}
 out:
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 906ca16..2322b6a 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -222,8 +222,8 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 
 		rc = md_intent_lock(tgt->ltd_exp, op_data, &it, &req,
 				    cb_blocking, extra_lock_flags);
-		if (rc == -ENOENT) {
-			/* skip stripe is not exists */
+		if (rc == -ENOENT || rc == -ESHUTDOWN) {
+			/* skip stripe that doesn't exist or is inaccessible */
 			rc = 0;
 			continue;
 		}
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 3e050b7..5fd00d3 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2574,7 +2574,7 @@ struct stripe_dirent {
 struct lmv_dir_ctxt {
 	struct lmv_obd		*ldc_lmv;
 	struct md_op_data	*ldc_op_data;
-	struct md_callback	*ldc_cb_op;
+	struct md_readdir_info  *ldc_mrinfo;
 	u64			 ldc_hash;
 	int			 ldc_count;
 	struct stripe_dirent	 ldc_stripes[0];
@@ -2675,7 +2675,7 @@ static struct lu_dirent *stripe_dirent_load(struct lmv_dir_ctxt *ctxt,
 		op_data->op_fid2 = oinfo->lmo_fid;
 		op_data->op_data = oinfo->lmo_root;
 
-		rc = md_read_page(tgt->ltd_exp, op_data, ctxt->ldc_cb_op, hash,
+		rc = md_read_page(tgt->ltd_exp, op_data, ctxt->ldc_mrinfo, hash,
 				  &stripe->sd_page);
 
 		op_data->op_fid1 = fid;
@@ -2696,6 +2696,7 @@ static struct lu_dirent *stripe_dirent_load(struct lmv_dir_ctxt *ctxt,
 		LASSERT(!ent);
 		/* treat error as eof, so dir can be partially accessed */
 		stripe->sd_eof = true;
+		ctxt->ldc_mrinfo->mr_partial_readdir_rc = rc;
 		LCONSOLE_WARN("dir " DFID " stripe %d readdir failed: %d, directory is partially accessed!\n",
 			      PFID(&ctxt->ldc_op_data->op_fid1), stripe_index,
 			      rc);
@@ -2793,7 +2794,8 @@ static struct lu_dirent *lmv_dirent_next(struct lmv_dir_ctxt *ctxt)
  *
  * @exp:	obd export refer to LMV
  * @op_data:	hold those MD parameters of read_entry
- * @cb_op:	ldlm callback being used in enqueue in mdc_read_entry
+ * @mrinfo:	ldlm callback being used in enqueue in mdc_read_entry,
+ *		and partial readdir results will be stored in it.
  * @offset:	the entry being read
  * @ppage:	the page holding the entry. Note: because the entry
  *		will be accessed in upper layer, so we need hold the
@@ -2805,8 +2807,8 @@ static struct lu_dirent *lmv_dirent_next(struct lmv_dir_ctxt *ctxt)
  */
 static int lmv_striped_read_page(struct obd_export *exp,
 				 struct md_op_data *op_data,
-				 struct md_callback *cb_op,
-				 u64 offset, struct page **ppage)
+				 struct md_readdir_info *mrinfo, u64 offset,
+				 struct page **ppage)
 {
 	struct page *page = NULL;
 	struct lu_dirpage *dp;
@@ -2848,7 +2850,7 @@ static int lmv_striped_read_page(struct obd_export *exp,
 	}
 	ctxt->ldc_lmv = &exp->exp_obd->u.lmv;
 	ctxt->ldc_op_data = op_data;
-	ctxt->ldc_cb_op = cb_op;
+	ctxt->ldc_mrinfo = mrinfo;
 	ctxt->ldc_hash = offset;
 	ctxt->ldc_count = stripe_count;
 
@@ -2925,7 +2927,7 @@ static int lmv_striped_read_page(struct obd_export *exp,
 }
 
 static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
-			 struct md_callback *cb_op, u64 offset,
+			 struct md_readdir_info *mrinfo, u64 offset,
 			 struct page **ppage)
 {
 	struct obd_device *obd = exp->exp_obd;
@@ -2936,15 +2938,15 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 		return -ENODATA;
 
 	if (unlikely(lmv_dir_striped(op_data->op_mea1))) {
-		return lmv_striped_read_page(exp, op_data, cb_op,
-					     offset, ppage);
+		return lmv_striped_read_page(exp, op_data, mrinfo, offset,
+					     ppage);
 	}
 
 	tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	return md_read_page(tgt->ltd_exp, op_data, cb_op, offset, ppage);
+	return md_read_page(tgt->ltd_exp, op_data, mrinfo, offset, ppage);
 }
 
 /**
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 9788bd3..3284c01 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1294,7 +1294,6 @@ struct readpage_param {
 	u64			rp_off;
 	int			rp_hash64;
 	struct obd_export	*rp_exp;
-	struct md_callback	*rp_cb;
 };
 
 /**
@@ -1410,7 +1409,7 @@ static int mdc_read_page_remote(void *data, struct page *page0)
  * @exp:		MDC export
  * @op_data:		client MD stack parameters, transferring parameters
  *			between different layers on client MD stack.
- * @cb_op:		callback required for ldlm lock enqueue during
+ * @mrinfo:		callback required for ldlm lock enqueue during
  *			read page
  * @hash_offset:	the hash offset of the page to be read
  * @ppage		the page to be read
@@ -1419,7 +1418,7 @@ static int mdc_read_page_remote(void *data, struct page *page0)
  *			errno(<0) get the page failed
  */
 static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
-			 struct md_callback *cb_op, u64 hash_offset,
+			 struct md_readdir_info *mrinfo, u64 hash_offset,
 			 struct page **ppage)
 {
 	struct lookup_intent it = { .it_op = IT_READDIR };
@@ -1440,7 +1439,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	mapping = dir->i_mapping;
 
 	rc = mdc_intent_lock(exp, op_data, &it, &enq_req,
-			     cb_op->md_blocking_ast, 0);
+			     mrinfo->mr_blocking_ast, 0);
 	if (enq_req)
 		ptlrpc_req_finished(enq_req);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
