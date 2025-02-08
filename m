Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5226CC02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:39:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWwr09jfz1y8n;
	Fri, 07 Feb 2025 16:31:24 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw45z69z1xRt
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:44 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0A76217948A;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 08946106BE18; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:16 -0500
Message-ID: <20250208003027.180076-11-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 10/21] lustre: llite: Fix style issues for
 dir.c
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Arshad Hussain <arshad.hussain@aeoncomputing.com>

This patch fixes issues reported by checkpatch
for file lustre/llite/dir.c. We are also in sync
with the OpenSFS version of this file.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 20bc026cfc928511d ("LU-6142 llite: Fix style issues for dir.c")
Signed-off-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50724
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Timothy Day <timday@amazon.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c | 245 +++++++++++++++++++-----------------------
 1 file changed, 110 insertions(+), 135 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 25ea565a2f0b..93f8a27aace3 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -103,26 +103,27 @@
  * returned page, page hash collision has to be handled. Pages in the
  * hash chain, except first one, are termed "overflow pages".
  *
- * Solution to index uniqueness problem is to not cache overflow
- * pages. Instead, when page hash collision is detected, all overflow pages
- * from emerging chain are immediately requested from the server and placed in
- * a special data structure (struct ll_dir_chain). This data structure is used
- * by ll_readdir() to process entries from overflow pages. When readdir
- * invocation finishes, overflow pages are discarded. If page hash collision
- * chain weren't completely processed, next call to readdir will again detect
- * page hash collision, again read overflow pages in, process next portion of
- * entries and again discard the pages. This is not as wasteful as it looks,
- * because, given reasonable hash, page hash collisions are extremely rare.
+ * Proposed (unimplimented) solution to index uniqueness problem is to
+ * not cache overflow pages.  Instead, when page hash collision is
+ * detected, all overflow pages from emerging chain should be
+ * immediately requested from the server and placed in a special data
+ * structure.  This data structure can be used by ll_readdir() to
+ * process entries from overflow pages.  When readdir invocation
+ * finishes, overflow pages are discarded.  If page hash collision chain
+ * weren't completely processed, next call to readdir will again detect
+ * page hash collision, again read overflow pages in, process next
+ * portion of entries and again discard the pages.  This is not as
+ * wasteful as it looks, because, given reasonable hash, page hash
+ * collisions are extremely rare.
  *
  * 1. directory positioning
  *
- * When seekdir(hash) is called, original
- *
- *
- *
- *
- *
+ * When seekdir(hash) is called.
  *
+ * seekdir() sets the location in the directory stream from which the next
+ * readdir() call will start. mdc_page_locate() is used to find page with
+ * starting hash and will issue RPC to fetch that page. If there is a hash
+ * collision the concerned page is removed.
  *
  *
  * Server.
@@ -135,8 +136,9 @@
  * a header lu_dirpage which describes the start/end hash, and whether this
  * page is empty (contains no dir entry) or hash collide with next page.
  * After client receives reply, several pages will be integrated into dir page
- * in PAGE_SIZE (if PAGE_SIZE greater than LU_PAGE_SIZE), and the lu_dirpage
- * for this integrated page will be adjusted. See lmv_adjust_dirpages().
+ * in PAGE_SIZE (if PAGE_SIZE greater than LU_PAGE_SIZE), and the
+ * lu_dirpage for this integrated page will be adjusted. See
+ * mdc_adjust_dirpages().
  *
  */
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
@@ -149,7 +151,7 @@ struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
 	int rc;
 
 	rc = md_read_page(ll_i2mdexp(dir), op_data, &mrinfo, offset, &page);
-	if (rc)
+	if (rc != 0)
 		return ERR_PTR(rc);
 
 	if (partial_readdir_rc && mrinfo.mr_partial_readdir_rc)
@@ -162,11 +164,11 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
 {
 	kunmap(page);
 
-	/*
-	 * Always remove the page for striped dir, because the page is
+	/* Always remove the page for striped dir, because the page is
 	 * built from temporarily in LMV layer
 	 */
-	if (inode && ll_dir_striped(inode)) {
+	if (inode && S_ISDIR(inode->i_mode) &&
+	    lmv_dir_striped(ll_i2info(inode)->lli_lsm_md)) {
 		__free_page(page);
 		return;
 	}
@@ -222,13 +224,11 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 			u64 ino;
 
 			hash = le64_to_cpu(ent->lde_hash);
-			if (hash < pos)
-				/* Skip until we find target hash */
+			if (hash < pos) /* Skip until we find target hash */
 				continue;
 
 			namelen = le16_to_cpu(ent->lde_namelen);
-			if (namelen == 0)
-				/* Skip dummy record. */
+			if (namelen == 0) /* Skip dummy record */
 				continue;
 
 			if (is_api32 && is_hash64)
@@ -237,13 +237,12 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 				lhash = hash;
 			fid_le_to_cpu(&fid, &ent->lde_fid);
 			ino = cl_fid_build_ino(&fid, is_api32);
-			type = IFTODT(lu_dirent_type_get(ent));
-			ctx->pos = lhash;
-			/* For 'll_nfs_get_name_filldir()', it will try
-			 * to access the 'ent' through its 'lde_name',
-			 * so the parameter 'name' for 'ctx->actor()'
-			 * must be part of the 'ent'.
+			type = S_DT(lu_dirent_type_get(ent));
+			/* For ll_nfs_get_name_filldir(), it will try to access
+			 * 'ent' through 'lde_name', so the parameter 'name'
+			 * for 'dir_emit()' must be part of the 'ent'.
 			 */
+			ctx->pos = lhash;
 			if (!IS_ENCRYPTED(inode)) {
 				done = !dir_emit(ctx, ent->lde_name, namelen,
 						 ino, type);
@@ -275,16 +274,11 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 		next = le64_to_cpu(dp->ldp_hash_end);
 		pos = next;
 		if (pos == MDS_DIR_END_OFF) {
-			/*
-			 * End of directory reached.
-			 */
+			/* End of directory reached. */
 			done = 1;
 			ll_release_page(inode, page, false);
 		} else {
-			/*
-			 * Normal case: continue to the next
-			 * page.
-			 */
+			/* Normal case: continue to the next page.*/
 			ll_release_page(inode, page,
 					le32_to_cpu(dp->ldp_flags) &
 					LDF_COLLIDE);
@@ -303,8 +297,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 {
 	struct inode *inode = file_inode(filp);
 	struct ll_file_data *lfd = filp->private_data;
-	struct ll_sb_info *sbi	= ll_i2sbi(inode);
-	u64 pos = lfd ? lfd->lfd_pos : 0;
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	bool hash64 = test_bit(LL_SBI_64BIT_HASH, sbi->ll_flags);
 	bool api32 = ll_need_32bit_api(sbi);
 	struct md_op_data *op_data;
@@ -312,13 +305,14 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	ktime_t kstart = ktime_get();
 	/* result of possible partial readdir */
 	int partial_readdir_rc = 0;
+	u64 pos;
 	int rc;
 
 	LASSERT(lfd);
 	pos = lfd->lfd_pos;
 
 	CDEBUG(D_VFSTRACE,
-	       "VFS Op:inode=" DFID "(%p) pos/size %lu/%llu 32bit_api %d\n",
+	       "VFS Op:inode="DFID"(%p) pos/size %lu/%llu 32bit_api %d\n",
 	       PFID(ll_inode2fid(inode)), inode, (unsigned long)pos,
 	       i_size_read(inode), api32);
 
@@ -329,9 +323,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	}
 
 	if (pos == MDS_DIR_END_OFF) {
-		/*
-		 * end-of-file.
-		 */
+		/* end-of-file. */
 		rc = 0;
 		goto out;
 	}
@@ -352,13 +344,12 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 				pfid = *ll_inode2fid(parent);
 		}
 
-		/*
-		 * If it can not find in cache, do lookup .. on the master
+		/* If it can not find in cache, do lookup .. on the master
 		 * object
 		 */
 		if (fid_is_zero(&pfid)) {
 			rc = ll_dir_get_parent_fid(inode, &pfid);
-			if (rc)
+			if (rc != 0)
 				return rc;
 		}
 	}
@@ -444,7 +435,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 
 	if (lump->lum_magic != LMV_MAGIC_FOREIGN) {
 		CDEBUG(D_VFSTRACE,
-		       "VFS Op:inode=" DFID "(%p) name %s stripe_offset %d stripe_count: %u, hash_type=%x\n",
+		       "VFS Op:inode="DFID"(%p) name %s stripe_offset %d stripe_count: %u, hash_type=%x\n",
 		       PFID(ll_inode2fid(parent)), parent, dirname,
 		       (int)lump->lum_stripe_offset, lump->lum_stripe_count,
 		       lump->lum_hash_type);
@@ -452,7 +443,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 		struct lmv_foreign_md *lfm = (struct lmv_foreign_md *)lump;
 
 		CDEBUG(D_VFSTRACE,
-		       "VFS Op:inode=" DFID "(%p) name %s foreign, length %u, value '%.*s'\n",
+		       "VFS Op:inode="DFID"(%p) name %s foreign, length %u, value '%.*s'\n",
 		       PFID(ll_inode2fid(parent)), parent, dirname,
 		       lfm->lfm_length, lfm->lfm_length, lfm->lfm_value);
 	}
@@ -556,6 +547,8 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 					    op_data->op_file_secctx_size);
 	else
 		err = ll_inode_init_security(&dentry, inode, parent);
+	if (err)
+		goto out_inode;
 
 	if (encrypt)
 		err = ll_set_encflags(inode, op_data->op_file_encctx,
@@ -630,8 +623,7 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 			return -EINVAL;
 		}
 
-		/*
-		 * This is coming from userspace, so should be in
+		/* This is coming from userspace, so should be in
 		 * local endian.  But the MDS would like it in little
 		 * endian, so we swab it before we send it.
 		 */
@@ -721,12 +713,12 @@ int ll_dir_get_default_layout(struct inode *inode, void **plmm, int *plmm_size,
 	struct mdt_body *body;
 	struct lov_mds_md *lmm = NULL;
 	struct ptlrpc_request *req = NULL;
-	int lmmsize = OBD_MAX_DEFAULT_EA_SIZE;
+	int lmm_size = OBD_MAX_DEFAULT_EA_SIZE;
 	struct md_op_data *op_data;
 	struct lu_fid fid;
 	int rc;
 
-	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, lmmsize,
+	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, lmm_size,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
@@ -743,27 +735,27 @@ int ll_dir_get_default_layout(struct inode *inode, void **plmm, int *plmm_size,
 	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 	ll_finish_md_op_data(op_data);
 	if (rc < 0) {
-		CDEBUG(D_INFO, "md_getattr failed on inode " DFID ": rc %d\n",
+		CDEBUG(D_INFO, "md_getattr failed on inode "DFID": rc %d\n",
 		       PFID(&fid), rc);
 		goto out;
 	}
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+	LASSERT(body);
 
-	lmmsize = body->mbo_eadatasize;
+	lmm_size = body->mbo_eadatasize;
 
 	if (!(body->mbo_valid & (OBD_MD_FLEASIZE | OBD_MD_FLDIREA)) ||
-	    lmmsize == 0) {
+	    lmm_size == 0) {
 		rc = -ENODATA;
 		goto out;
 	}
 
 	lmm = req_capsule_server_sized_get(&req->rq_pill,
-					   &RMF_MDT_MD, lmmsize);
+					   &RMF_MDT_MD, lmm_size);
 	LASSERT(lmm);
 
-	/*
-	 * This is coming from the MDS, so is probably in
+	/* This is coming from the MDS, so is probably in
 	 * little endian.  We convert it to host endian before
 	 * passing it to userspace.
 	 */
@@ -796,12 +788,13 @@ int ll_dir_get_default_layout(struct inode *inode, void **plmm, int *plmm_size,
 		break;
 	}
 	default:
-		CERROR("unknown magic: %lX\n", (unsigned long)lmm->lmm_magic);
 		rc = -EPROTO;
+		CERROR("%s: unknown magic: %lX: rc = %d\n", sbi->ll_fsname,
+		       (unsigned long)lmm->lmm_magic, rc);
 	}
 out:
 	*plmm = lmm;
-	*plmm_size = lmmsize;
+	*plmm_size = lmm_size;
 	*request = req;
 	return rc;
 }
@@ -947,7 +940,7 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 		iput(inode);
 		if (rc != 0) {
 			CDEBUG(D_HSM,
-			       "Could not read file data version of " DFID " (rc = %d). Archive request (%#llx) could not be done.\n",
+			       "Could not read file data version of "DFID" (rc = %d). Archive request (%#llx) could not be done.\n",
 			       PFID(&copy->hc_hai.hai_fid), rc,
 			       copy->hc_hai.hai_cookie);
 			hpk.hpk_flags |= HP_FLAG_RETRY;
@@ -966,9 +959,11 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 	/* On error, the request should be considered as completed */
 	if (hpk.hpk_errval > 0)
 		hpk.hpk_flags |= HP_FLAG_COMPLETED;
+
 	rc2 = obd_iocontrol(LL_IOC_HSM_PROGRESS, sbi->ll_md_exp, sizeof(hpk),
 			    &hpk, NULL);
 
+	/* Return first error */
 	return rc ? rc : rc2;
 }
 
@@ -1235,7 +1230,8 @@ int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl)
 	case LUSTRE_Q_GETINFOPOOL:
 		break;
 	default:
-		CERROR("unsupported quotactl op: %#x\n", cmd);
+		CERROR("%s: unsupported quotactl op: %#x: rc = %d\n",
+		       sbi->ll_fsname, cmd, -EOPNOTSUPP);
 		return -ENOTSUPP;
 	}
 
@@ -1374,6 +1370,7 @@ int ll_rmfid(struct file *file, void __user *arg)
 	lfa = kzalloc(size, GFP_NOFS);
 	if (!lfa)
 		return -ENOMEM;
+
 	rcs = kcalloc(nr, sizeof(int), GFP_NOFS);
 	if (!rcs) {
 		rc = -ENOMEM;
@@ -1492,36 +1489,33 @@ int ll_rmfid(struct file *file, void __user *arg)
  */
 static char *ll_getname(const char __user *filename)
 {
-	int ret = 0, len;
 	char *tmp;
 
-	tmp = kzalloc(NAME_MAX + 1, GFP_KERNEL);
-	if (!tmp)
-		return ERR_PTR(-ENOMEM);
+	tmp = strndup_user(filename, NAME_MAX + 1);
+	if (IS_ERR(tmp)) {
+		int ret = PTR_ERR(tmp);
 
-	len = strncpy_from_user(tmp, filename, NAME_MAX + 1);
-	if (len < 0)
-		ret = len;
-	else if (len == 0)
-		ret = -ENOENT;
-	else if (len > NAME_MAX && tmp[NAME_MAX] != 0)
-		ret = -ENAMETOOLONG;
-
-	if (ret) {
-		kfree(tmp);
-		tmp =  ERR_PTR(ret);
+		switch (ret) {
+		case -EFAULT: /* zero length */
+			tmp = ERR_PTR(-ENOENT);
+			break;
+		case -EINVAL:
+			tmp = ERR_PTR(-ENAMETOOLONG);
+		fallthrough;
+		default:
+			break;
+		}
 	}
+
 	return tmp;
 }
 
-#define ll_putname(filename) kfree(filename)
-
 static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct dentry *dentry = file_dentry(file);
 	struct inode *inode = file_inode(file);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
-	struct obd_ioctl_data *data;
+	struct obd_ioctl_data *data = NULL;
 	void __user *uarg = (void __user *)arg;
 	int rc = 0;
 
@@ -1539,12 +1533,11 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		char *filename;
 
 		rc = obd_ioctl_getdata(&data, &len, uarg);
-		if (rc)
+		if (rc != 0)
 			return rc;
 
 		filename = data->ioc_inlbuf1;
 		namelen = strlen(filename);
-
 		if (namelen < 1) {
 			CDEBUG(D_INFO, "IOC_MDC_LOOKUP missing filename\n");
 			rc = -EINVAL;
@@ -1647,7 +1640,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct lov_user_md_v1 __user *lumv1p = uarg;
 		struct lov_user_md_v3 __user *lumv3p = uarg;
 		int lum_size = 0;
-
 		int set_default = 0;
 
 		BUILD_BUG_ON(sizeof(struct lov_user_md_v3) <=
@@ -1703,7 +1695,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		int rc;
 		int i;
 
-		ulmv = (struct lmv_user_md __user *)arg;
 		if (copy_from_user(&lum, ulmv, sizeof(*ulmv)))
 			return -EFAULT;
 
@@ -1721,8 +1712,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		}
 
 		max_stripe_count = lum.lum_stripe_count;
-		/*
-		 * lum_magic will indicate which stripe the ioctl will like
+		/* lum_magic will indicate which stripe the ioctl will like
 		 * to get, LMV_MAGIC_V1 is for normal LMV stripe, LMV_USER_MAGIC
 		 * is for default LMV stripe
 		 */
@@ -1738,7 +1728,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (rc)
 			goto finish_req;
 
-		/* Get default LMV EA in raw mode */
+		/* get default LMV in raw mode */
 		if (lum.lum_magic == LMV_USER_MAGIC) {
 			if (copy_to_user(ulmv, lmm, lmmsize))
 				rc = -EFAULT;
@@ -1758,8 +1748,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 				stripe_count = lmv_foreign_to_md_stripes(size);
 			} else {
-				CERROR("invalid %d foreign size returned\n",
-					    lfm->lfm_length);
+				CERROR("%s: invalid %d foreign size returned: rc = %d\n",
+				       sbi->ll_fsname, lfm->lfm_length,
+				       -EINVAL);
 				return -EINVAL;
 			}
 		} else {
@@ -1833,7 +1824,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case LL_IOC_RMFID:
-		return ll_rmfid(file, (void __user *)arg);
+		return ll_rmfid(file, uarg);
 	case LL_IOC_LOV_SWAP_LAYOUTS:
 		return -EPERM;
 	case LL_IOC_LOV_GETSTRIPE:
@@ -1894,18 +1885,16 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (cmd == IOC_MDC_GETFILESTRIPE ||
 		    cmd == LL_IOC_LOV_GETSTRIPE ||
 		    cmd == LL_IOC_LOV_GETSTRIPE_NEW) {
-			lump = (struct lov_user_md __user *)arg;
+			lump = uarg;
 		} else if (cmd == IOC_MDC_GETFILEINFO_V1 ||
 			   cmd == LL_IOC_MDC_GETINFO_V1) {
-			struct lov_user_mds_data_v1 __user *lmdp;
+			struct lov_user_mds_data_v1 __user *lmdp = uarg;
 
-			lmdp = (struct lov_user_mds_data_v1 __user *)arg;
 			statp = &lmdp->lmd_st;
 			lump = &lmdp->lmd_lmm;
 		} else {
-			struct lov_user_mds_data __user *lmdp;
+			struct lov_user_mds_data __user *lmdp = uarg;
 
-			lmdp = (struct lov_user_mds_data __user *)arg;
 			fidp = &lmdp->lmd_fid;
 			stxp = &lmdp->lmd_stx;
 			flagsp = &lmdp->lmd_flags;
@@ -1985,8 +1974,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			stx.stx_dev_minor = MINOR(inode->i_sb->s_dev);
 			stx.stx_mask |= STATX_BASIC_STATS | STATX_BTIME;
 
-			/*
-			 * For a striped directory, the size and blocks returned
+			/* For a striped directory, the size and blocks returned
 			 * from MDT is not correct.
 			 * The size and blocks are aggregated by client across
 			 * all stripes.
@@ -2031,8 +2019,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 out_req:
 		ptlrpc_req_finished(request);
 		ptlrpc_req_finished(root_request);
-		if (filename)
-			ll_putname(filename);
+		kfree(filename);
 		return rc;
 	}
 	case OBD_IOC_QUOTACTL: {
@@ -2049,7 +2036,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		}
 
 		if (LUSTRE_Q_CMD_IS_POOL(qctl->qc_cmd)) {
-			char __user *from = (char __user *)arg +
+			char __user *from = uarg +
 					    offsetof(typeof(*qctl), qc_poolname);
 
 			if (copy_from_user(qctl->qc_poolname, from,
@@ -2068,10 +2055,10 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case LL_IOC_GETOBDCOUNT: {
-		int count, vallen;
+		u32 count, vallen;
 		struct obd_export *exp;
 
-		if (copy_from_user(&count, (int __user *)arg, sizeof(int)))
+		if (copy_from_user(&count, uarg, sizeof(count)))
 			return -EFAULT;
 
 		/* get ost count when count is zero, get mdt count otherwise */
@@ -2085,31 +2072,24 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			return rc;
 		}
 
-		if (copy_to_user((int __user *)arg, &count, sizeof(int)))
+		if (copy_to_user(uarg, &count, sizeof(count)))
 			return -EFAULT;
 
 		return 0;
 	}
-	case LL_IOC_GET_CONNECT_FLAGS: {
-		return obd_iocontrol(cmd, sbi->ll_md_exp, 0, NULL,
-				     uarg);
-	}
-	case OBD_IOC_FID2PATH:
-		return ll_fid2path(inode, uarg);
-	case LL_IOC_GETPARENT:
-		return ll_getparent(file, uarg);
+	case LL_IOC_GET_CONNECT_FLAGS:
+		return obd_iocontrol(cmd, sbi->ll_md_exp, 0, NULL, uarg);
 	case LL_IOC_FID2MDTIDX: {
 		struct obd_export *exp = ll_i2mdexp(inode);
 		struct lu_fid fid;
 		u32 index;
 
-		if (copy_from_user(&fid, (const struct lu_fid __user *)arg,
-				   sizeof(fid)))
+		if (copy_from_user(&fid, uarg, sizeof(fid)))
 			return -EFAULT;
 
 		/* Call mdc_iocontrol */
 		rc = obd_iocontrol(LL_IOC_FID2MDTIDX, exp, sizeof(fid), &fid,
-				   &index);
+				   (u32 __user *)&index);
 		if (rc)
 			return rc;
 
@@ -2139,8 +2119,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		/* Copy the whole struct */
 		if (copy_from_user(hur, uarg, totalsize)) {
-			kvfree(hur);
-			return -EFAULT;
+			rc = -EFAULT;
+			goto out_hur;
 		}
 
 		if (hur->hur_request.hr_action == HUA_RELEASE) {
@@ -2165,7 +2145,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			rc = obd_iocontrol(cmd, ll_i2mdexp(inode), totalsize,
 					   hur, NULL);
 		}
-
+out_hur:
 		kvfree(hur);
 
 		return rc;
@@ -2195,20 +2175,19 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 
-		rc = copy_and_ct_start(cmd, sbi->ll_md_exp,
-				       (struct lustre_kernelcomm __user *)arg);
+		rc = copy_and_ct_start(cmd, sbi->ll_md_exp, uarg);
 		return rc;
 
 	case LL_IOC_HSM_COPY_START: {
 		struct hsm_copy	*copy;
 		int rc;
 
-		copy = memdup_user((char __user *)arg, sizeof(*copy));
+		copy = memdup_user(uarg, sizeof(*copy));
 		if (IS_ERR(copy))
 			return PTR_ERR(copy);
 
 		rc = ll_ioc_copy_start(inode->i_sb, copy);
-		if (copy_to_user((char __user *)arg, copy, sizeof(*copy)))
+		if (copy_to_user(uarg, copy, sizeof(*copy)))
 			rc = -EFAULT;
 
 		kfree(copy);
@@ -2218,12 +2197,12 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct hsm_copy	*copy;
 		int rc;
 
-		copy = memdup_user((char __user *)arg, sizeof(*copy));
+		copy = memdup_user(uarg, sizeof(*copy));
 		if (IS_ERR(copy))
 			return PTR_ERR(copy);
 
 		rc = ll_ioc_copy_end(inode->i_sb, copy);
-		if (copy_to_user((char __user *)arg, copy, sizeof(*copy)))
+		if (copy_to_user(uarg, copy, sizeof(*copy)))
 			rc = -EFAULT;
 
 		kfree(copy);
@@ -2278,16 +2257,10 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct inode *inode2;
 		unsigned long ino;
 
-		detach = kzalloc(sizeof(*detach), GFP_KERNEL);
-		if (!detach)
-			return -ENOMEM;
+		detach = memdup_user(uarg, sizeof(*detach));
+		if (IS_ERR(detach))
+			return PTR_ERR(detach);
 
-		if (copy_from_user(detach,
-				   (const struct lu_pcc_detach_fid __user *)arg,
-				   sizeof(*detach))) {
-			rc = -EFAULT;
-			goto out_detach;
-		}
 
 		fid = &detach->pccd_fid;
 		ino = cl_fid_build_ino(fid, ll_need_32bit_api(sbi));
@@ -2334,6 +2307,7 @@ static loff_t ll_dir_seek(struct file *file, loff_t offset, int origin)
 	bool api32 = ll_need_32bit_api(sbi);
 	loff_t ret = -EINVAL;
 
+	inode_lock(inode);
 	switch (origin) {
 	case SEEK_SET:
 		break;
@@ -2367,12 +2341,13 @@ static loff_t ll_dir_seek(struct file *file, loff_t offset, int origin)
 			else
 				fd->lfd_pos = offset;
 			file->f_pos = offset;
+			file->f_version = 0;
 		}
 		ret = offset;
 	}
-	goto out;
 
 out:
+	inode_unlock(inode);
 	return ret;
 }
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
