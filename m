From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:39 -0400
Subject: [lustre-devel] [PATCH 020/151] lustre: readdir: improve striped
 readdir
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Striped directory needs to build its directory page from sub-stripe
directory pages, current code iterate sub stripe directory pages
to search dirent for each hash, this is inefficient, as may cause
statahead fail because statahead thread is slow in readdir, while
'ls' is faster and can't find cached statahead entries, and finally
cause statahead fail.

This patch introduces a struct lmv_dir_ctxt which saves dir page and
current dirent for all stripes, to find the dirent which has the
closest hash value it only needs to compare the dirent of all stripes,
and then pop this dirent from its stripe, until all stripes reache
the end.

This patch contains another fix: previously LDP_COLLIDE is set by
default, change to set dir page end hash 'ldp_hash_end' to hash
of next dirent, and only set LDP_COLLIDE when 'ldp_hash_end' equals
last dirent hash 'lde_hash'. We should avoid dir hash collision.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5106
Lustre-commit: 98fc9a77446a ("LU-5106 readdir: improve striped readdir")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/27663
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 423 ++++++++++++++++++++++++++----------------------
 1 file changed, 231 insertions(+), 192 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 946c757..d71d077 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2001,60 +2001,79 @@ static int lmv_fsync(struct obd_export *exp, const struct lu_fid *fid,
 	return md_fsync(tgt->ltd_exp, fid, request);
 }
 
-/**
- * Get current minimum entry from striped directory
- *
- * This function will search the dir entry, whose hash value is the
- * closest(>=) to @hash_offset, from all of sub-stripes, and it is
- * only being called for striped directory.
- *
- * @exp:		export of LMV
- * @op_data:		parameters transferred beween client MD stack
- *			stripe_information will be included in this
- *			parameter
- * @cb_op:		ldlm callback being used in enqueue in
- *			mdc_read_page
- * @hash_offset:	the hash value, which is used to locate
- *			minum(closet) dir entry
- * @stripe_offset:	the caller use this to indicate the stripe
- *			index of last entry, so to avoid hash conflict
- *			between stripes. It will also be used to
- *			return the stripe index of current dir entry.
- * @entp:		the minum entry and it also is being used
- *			to input the last dir entry to resolve the
- *			hash conflict
- *
- * @ppage:		the page which holds the minum entry
- *
- * Return:		= 0 get the entry successfully
- *			negative errno (< 0) does not get the entry
- */
-static int lmv_get_min_striped_entry(struct obd_export *exp,
-				     struct md_op_data *op_data,
-				     struct md_callback *cb_op,
-				     u64 hash_offset, int *stripe_offset,
-				     struct lu_dirent **entp,
-				     struct page **ppage)
+struct stripe_dirent {
+	struct page		*sd_page;
+	struct lu_dirpage	*sd_dp;
+	struct lu_dirent	*sd_ent;
+	bool			 sd_eof;
+};
+
+struct lmv_dir_ctxt {
+	struct lmv_obd		*ldc_lmv;
+	struct md_op_data	*ldc_op_data;
+	struct md_callback	*ldc_cb_op;
+	u64			 ldc_hash;
+	int			 ldc_count;
+	struct stripe_dirent	 ldc_stripes[0];
+};
+
+static inline void put_stripe_dirent(struct stripe_dirent *stripe)
+{
+	if (stripe->sd_page) {
+		kunmap(stripe->sd_page);
+		put_page(stripe->sd_page);
+		stripe->sd_page = NULL;
+	}
+}
+
+static inline void put_lmv_dir_ctxt(struct lmv_dir_ctxt *ctxt)
 {
-	struct lmv_stripe_md *lsm = op_data->op_mea1;
-	struct obd_device *obd = exp->exp_obd;
-	struct lmv_obd *lmv = &obd->u.lmv;
-	struct lu_dirent *min_ent = NULL;
-	struct page *min_page = NULL;
-	struct lmv_tgt_desc *tgt;
-	int stripe_count;
-	int min_idx = 0;
-	int rc = 0;
 	int i;
 
-	stripe_count = lsm->lsm_md_stripe_count;
-	for (i = 0; i < stripe_count; i++) {
-		u64 stripe_hash = hash_offset;
-		struct lu_dirent *ent = NULL;
-		struct page *page = NULL;
-		struct lu_dirpage *dp;
+	for (i = 0; i < ctxt->ldc_count; i++)
+		put_stripe_dirent(&ctxt->ldc_stripes[i]);
+}
+
+static struct lu_dirent *stripe_dirent_next(struct lmv_dir_ctxt *ctxt,
+					    struct stripe_dirent *stripe,
+					    int stripe_index)
+{
+	struct lu_dirent *ent = stripe->sd_ent;
+	u64 hash = ctxt->ldc_hash;
+	u64 end;
+	int rc = 0;
+
+	LASSERT(stripe == &ctxt->ldc_stripes[stripe_index]);
+
+	if (ent) {
+		ent = lu_dirent_next(ent);
+		if (!ent) {
+check_eof:
+			end = le64_to_cpu(stripe->sd_dp->ldp_hash_end);
+
+			put_stripe_dirent(stripe);
+
+			if (end == MDS_DIR_END_OFF) {
+				stripe->sd_ent = NULL;
+				stripe->sd_eof = true;
+				return NULL;
+			}
+			LASSERT(hash <= end);
+			hash = end;
+		}
+	}
+
+	if (!ent) {
+		struct md_op_data *op_data = ctxt->ldc_op_data;
+		struct lmv_oinfo *oinfo;
+		struct lu_fid fid = op_data->op_fid1;
+		struct inode *inode = op_data->op_data;
+		struct lmv_tgt_desc *tgt;
 
-		tgt = lmv_get_target(lmv, lsm->lsm_md_oinfo[i].lmo_mds, NULL);
+		LASSERT(!stripe->sd_page);
+
+		oinfo = &op_data->op_mea1->lsm_md_oinfo[stripe_index];
+		tgt = lmv_get_target(ctxt->ldc_lmv, oinfo->lmo_mds, NULL);
 		if (IS_ERR(tgt)) {
 			rc = PTR_ERR(tgt);
 			goto out;
@@ -2064,87 +2083,117 @@ static int lmv_get_min_striped_entry(struct obd_export *exp,
 		 * op_data will be shared by each stripe, so we need
 		 * reset these value for each stripe
 		 */
-		op_data->op_fid1 = lsm->lsm_md_oinfo[i].lmo_fid;
-		op_data->op_fid2 = lsm->lsm_md_oinfo[i].lmo_fid;
-		op_data->op_data = lsm->lsm_md_oinfo[i].lmo_root;
-next:
-		rc = md_read_page(tgt->ltd_exp, op_data, cb_op, stripe_hash,
-				  &page);
+		op_data->op_fid1 = oinfo->lmo_fid;
+		op_data->op_fid2 = oinfo->lmo_fid;
+		op_data->op_data = oinfo->lmo_root;
+
+		rc = md_read_page(tgt->ltd_exp, op_data, ctxt->ldc_cb_op, hash,
+				  &stripe->sd_page);
+
+		op_data->op_fid1 = fid;
+		op_data->op_fid2 = fid;
+		op_data->op_data = inode;
+
 		if (rc)
 			goto out;
 
-		dp = page_address(page);
-		for (ent = lu_dirent_start(dp); ent;
-		     ent = lu_dirent_next(ent)) {
-			/* Skip dummy entry */
-			if (!le16_to_cpu(ent->lde_namelen))
-				continue;
+		stripe->sd_dp = page_address(stripe->sd_page);
+		ent = lu_dirent_start(stripe->sd_dp);
+	}
 
-			if (le64_to_cpu(ent->lde_hash) < hash_offset)
-				continue;
+	for (; ent; ent = lu_dirent_next(ent)) {
+		/* Skip dummy entry */
+		if (!le16_to_cpu(ent->lde_namelen))
+			continue;
 
-			if (le64_to_cpu(ent->lde_hash) == hash_offset &&
-			    (*entp == ent || i < *stripe_offset))
-				continue;
+		/* skip . and .. for other stripes */
+		if (stripe_index &&
+		    (strncmp(ent->lde_name, ".",
+			     le16_to_cpu(ent->lde_namelen)) == 0 ||
+		     strncmp(ent->lde_name, "..",
+			     le16_to_cpu(ent->lde_namelen)) == 0))
+			continue;
 
-			/* skip . and .. for other stripes */
-			if (i && (!strncmp(ent->lde_name, ".",
-					   le16_to_cpu(ent->lde_namelen)) ||
-				  !strncmp(ent->lde_name, "..",
-					   le16_to_cpu(ent->lde_namelen))))
-				continue;
-			break;
-		}
+		if (le64_to_cpu(ent->lde_hash) < hash)
+			continue;
 
-		if (!ent) {
-			stripe_hash = le64_to_cpu(dp->ldp_hash_end);
+		break;
+	}
 
-			kunmap(page);
-			put_page(page);
-			page = NULL;
+	if (!ent)
+		goto check_eof;
 
-			/*
-			 * reach the end of current stripe, go to next stripe
-			 */
-			if (stripe_hash == MDS_DIR_END_OFF)
+out:
+	stripe->sd_ent = ent;
+	/* treat error as eof, so dir can be partially accessed */
+	if (rc) {
+		put_stripe_dirent(stripe);
+		stripe->sd_eof = true;
+		LCONSOLE_WARN("dir " DFID " stripe %d readdir failed: %d, directory is partially accessed!\n",
+			      PFID(&ctxt->ldc_op_data->op_fid1), stripe_index,
+			      rc);
+	}
+	return ent;
+}
+
+/**
+ * Get dirent with the closest hash for striped directory
+ *
+ * This function will search the dir entry, whose hash value is the
+ * closest(>=) to hash from all of sub-stripes, and it is only being called
+ * for striped directory.
+ *
+ * @param ctxt	dir read context
+ *
+ * Return:	dirent get the entry successfully NULL does not get
+ *		the entry, normally it means it reaches the end of
+ *		the directory, while read stripe dirent error is
+ *		ignored to allow partial access.
+ */
+static struct lu_dirent *lmv_dirent_next(struct lmv_dir_ctxt *ctxt)
+{
+	struct stripe_dirent *stripe;
+	struct lu_dirent *ent = NULL;
+	int i;
+	int min = -1;
+
+	/* TODO: optimize with k-way merge sort */
+	for (i = 0; i < ctxt->ldc_count; i++) {
+		stripe = &ctxt->ldc_stripes[i];
+		if (stripe->sd_eof)
+			continue;
+
+		if (!stripe->sd_ent) {
+			/* locate starting entry */
+			stripe_dirent_next(ctxt, stripe, i);
+			if (!stripe->sd_ent) {
+				LASSERT(stripe->sd_eof);
 				continue;
-			else
-				goto next;
+			}
 		}
 
-		if (min_ent) {
-			if (le64_to_cpu(min_ent->lde_hash) >
-			    le64_to_cpu(ent->lde_hash)) {
-				min_ent = ent;
-				kunmap(min_page);
-				put_page(min_page);
-				min_idx = i;
-				min_page = page;
-			} else {
-				kunmap(page);
-				put_page(page);
-				page = NULL;
-			}
-		} else {
-			min_ent = ent;
-			min_page = page;
-			min_idx = i;
+		if (min == -1 ||
+		    le64_to_cpu(ctxt->ldc_stripes[min].sd_ent->lde_hash) >
+		    le64_to_cpu(stripe->sd_ent->lde_hash)) {
+			min = i;
+			if (le64_to_cpu(stripe->sd_ent->lde_hash) ==
+			    ctxt->ldc_hash)
+				break;
 		}
 	}
 
-out:
-	if (*ppage) {
-		kunmap(*ppage);
-		put_page(*ppage);
+	if (min != -1) {
+		stripe = &ctxt->ldc_stripes[min];
+		ent = stripe->sd_ent;
+		/* pop found dirent */
+		stripe_dirent_next(ctxt, stripe, min);
 	}
-	*stripe_offset = min_idx;
-	*entp = min_ent;
-	*ppage = min_page;
-	return rc;
+
+	return ent;
 }
 
 /**
- * Build dir entry page from a striped directory
+ * Build dir entry page for striped directory
  *
  * This function gets one entry by @offset from a striped directory. It will
  * read entries from all of stripes, and choose one closest to the required
@@ -2153,12 +2202,11 @@ static int lmv_get_min_striped_entry(struct obd_export *exp,
  * and .. in a directory.
  * 2. op_data will be shared by all of stripes, instead of allocating new
  * one, so need to restore before reusing.
- * 3. release the entry page if that is not being chosen.
  *
  * @exp:	obd export refer to LMV
  * @op_data:	hold those MD parameters of read_entry
  * @cb_op:	ldlm callback being used in enqueue in mdc_read_entry
- * @ldp:	the entry being read
+ * @offset:	the entry being read
  * @ppage:	the page holding the entry. Note: because the entry
  *		will be accessed in upper layer, so we need hold the
  *		page until the usages of entry is finished, see
@@ -2167,81 +2215,80 @@ static int lmv_get_min_striped_entry(struct obd_export *exp,
  * Returns:	=0 if get entry successfully
  *		<0 cannot get entry
  */
-static int lmv_read_striped_page(struct obd_export *exp,
+static int lmv_striped_read_page(struct obd_export *exp,
 				 struct md_op_data *op_data,
 				 struct md_callback *cb_op,
 				 u64 offset, struct page **ppage)
 {
-	struct inode *master_inode = op_data->op_data;
-	struct lu_fid master_fid = op_data->op_fid1;
-	u64 hash_offset = offset;
-	u32 ldp_flags;
-	struct page *min_ent_page = NULL;
-	struct page *ent_page = NULL;
-	struct lu_dirent *min_ent = NULL;
-	struct lu_dirent *last_ent;
-	struct lu_dirent *ent;
+	struct page *page = NULL;
 	struct lu_dirpage *dp;
+	void *start;
+	struct lu_dirent *ent;
+	struct lu_dirent *last_ent;
+	int stripe_count;
+	struct lmv_dir_ctxt *ctxt;
+	struct lu_dirent *next = NULL;
+	u16 ent_size;
 	size_t left_bytes;
-	int ent_idx = 0;
-	void *area;
-	int rc;
+	int rc = 0;
 
 	/*
 	 * Allocate a page and read entries from all of stripes and fill
 	 * the page by hash order
 	 */
-	ent_page = alloc_page(GFP_KERNEL);
-	if (!ent_page)
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
 		return -ENOMEM;
 
 	/* Initialize the entry page */
-	dp = kmap(ent_page);
+	dp = kmap(page);
 	memset(dp, 0, sizeof(*dp));
 	dp->ldp_hash_start = cpu_to_le64(offset);
-	ldp_flags = LDF_COLLIDE;
 
-	area = dp + 1;
+	start = dp + 1;
 	left_bytes = PAGE_SIZE - sizeof(*dp);
-	ent = area;
+	ent = start;
 	last_ent = ent;
-	do {
-		u16 ent_size;
-
-		/* Find the minum entry from all sub-stripes */
-		rc = lmv_get_min_striped_entry(exp, op_data, cb_op, hash_offset,
-					       &ent_idx, &min_ent,
-					       &min_ent_page);
-		if (rc)
-			goto out;
 
-		/*
-		 * If it can not get minum entry, it means it already reaches
-		 * the end of this directory
-		 */
-		if (!min_ent) {
-			last_ent->lde_reclen = 0;
-			hash_offset = MDS_DIR_END_OFF;
-			goto out;
+	/* initialize dir read context */
+	stripe_count = op_data->op_mea1->lsm_md_stripe_count;
+	ctxt = kzalloc(offsetof(typeof(*ctxt), ldc_stripes[stripe_count]),
+		       GFP_NOFS);
+	if (!ctxt) {
+		rc = -ENOMEM;
+		goto free_page;
+	}
+	ctxt->ldc_lmv = &exp->exp_obd->u.lmv;
+	ctxt->ldc_op_data = op_data;
+	ctxt->ldc_cb_op = cb_op;
+	ctxt->ldc_hash = offset;
+	ctxt->ldc_count = stripe_count;
+
+	while (1) {
+		next = lmv_dirent_next(ctxt);
+
+		/* end of directory */
+		if (!next) {
+			ctxt->ldc_hash = MDS_DIR_END_OFF;
+			break;
 		}
+		ctxt->ldc_hash = le64_to_cpu(next->lde_hash);
 
-		ent_size = le16_to_cpu(min_ent->lde_reclen);
+		ent_size = le16_to_cpu(next->lde_reclen);
 
 		/*
-		 * the last entry lde_reclen is 0, but it might not
-		 * the end of this entry of this temporay entry
+		 * the last entry lde_reclen is 0, but it might not be the last
+		 * one of this temporay dir page
 		 */
 		if (!ent_size)
 			ent_size = lu_dirent_calc_size(
-					le16_to_cpu(min_ent->lde_namelen),
-					le32_to_cpu(min_ent->lde_attrs));
-		if (ent_size > left_bytes) {
-			last_ent->lde_reclen = cpu_to_le16(0);
-			hash_offset = le64_to_cpu(min_ent->lde_hash);
-			goto out;
-		}
+					le16_to_cpu(next->lde_namelen),
+					le32_to_cpu(next->lde_attrs));
+		/* page full */
+		if (ent_size > left_bytes)
+			break;
 
-		memcpy(ent, min_ent, ent_size);
+		memcpy(ent, next, ent_size);
 
 		/*
 		 * Replace . with master FID and Replace .. with the parent FID
@@ -2250,49 +2297,41 @@ static int lmv_read_striped_page(struct obd_export *exp,
 		if (!strncmp(ent->lde_name, ".",
 			     le16_to_cpu(ent->lde_namelen)) &&
 		    le16_to_cpu(ent->lde_namelen) == 1)
-			fid_cpu_to_le(&ent->lde_fid, &master_fid);
+			fid_cpu_to_le(&ent->lde_fid, &op_data->op_fid1);
 		else if (!strncmp(ent->lde_name, "..",
 				  le16_to_cpu(ent->lde_namelen)) &&
 			 le16_to_cpu(ent->lde_namelen) == 2)
 			fid_cpu_to_le(&ent->lde_fid, &op_data->op_fid3);
 
+		CDEBUG(D_INODE, "entry %.*s hash %#llx\n",
+		       le16_to_cpu(ent->lde_namelen), ent->lde_name,
+		       le64_to_cpu(ent->lde_hash));
+
 		left_bytes -= ent_size;
 		ent->lde_reclen = cpu_to_le16(ent_size);
 		last_ent = ent;
 		ent = (void *)ent + ent_size;
-		hash_offset = le64_to_cpu(min_ent->lde_hash);
-		if (hash_offset == MDS_DIR_END_OFF) {
-			last_ent->lde_reclen = 0;
-			break;
-		}
-	} while (1);
-out:
-	if (min_ent_page) {
-		kunmap(min_ent_page);
-		put_page(min_ent_page);
 	}
 
-	if (unlikely(rc)) {
-		__free_page(ent_page);
-		ent_page = NULL;
-	} else {
-		if (ent == area)
-			ldp_flags |= LDF_EMPTY;
-		dp->ldp_flags |= cpu_to_le32(ldp_flags);
-		dp->ldp_hash_end = cpu_to_le64(hash_offset);
-	}
+	last_ent->lde_reclen = 0;
 
-	/*
-	 * We do not want to allocate md_op_data during each
-	 * dir entry reading, so op_data will be shared by every stripe,
-	 * then we need to restore it back to original value before
-	 * return to the upper layer
-	 */
-	op_data->op_fid1 = master_fid;
-	op_data->op_fid2 = master_fid;
-	op_data->op_data = master_inode;
+	if (ent == start)
+		dp->ldp_flags |= LDF_EMPTY;
+	else if (ctxt->ldc_hash == le64_to_cpu(last_ent->lde_hash))
+		dp->ldp_flags |= LDF_COLLIDE;
+	dp->ldp_flags = cpu_to_le32(dp->ldp_flags);
+	dp->ldp_hash_end = cpu_to_le64(ctxt->ldc_hash);
+
+	put_lmv_dir_ctxt(ctxt);
+	kfree(ctxt);
+
+	*ppage = page;
+
+	return 0;
 
-	*ppage = ent_page;
+free_page:
+	kunmap(page);
+	__free_page(page);
 
 	return rc;
 }
@@ -2307,7 +2346,7 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_tgt_desc *tgt;
 
 	if (unlikely(lsm)) {
-		return lmv_read_striped_page(exp, op_data, cb_op,
+		return lmv_striped_read_page(exp, op_data, cb_op,
 					     offset, ppage);
 	}
 
-- 
1.8.3.1
