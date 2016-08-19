From: James Simmons <jsimmons@infradead.org>
Date: Fri, 19 Aug 2016 14:07:25 -0400
Subject: [lustre-devel] [PATCH 1/7] staging: lustre: lmv: implement lmv
	version of read_page
In-Reply-To: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471630051-26700-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

All the code needed to implement read_page. This
will eventually replace lmv_readpage.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/10761
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4906
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |  329 +++++++++++++++++++++++++++
 1 files changed, 329 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 3e41f49..1f01be4 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2369,6 +2369,334 @@ static int lmv_readpage(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 /**
+ * Get current minimum entry from striped directory
+ *
+ * This function will search the dir entry, whose hash value is the
+ * closest(>=) to @hash_offset, from all of sub-stripes, and it is
+ * only being called for striped directory.
+ *
+ * \param[in] exp		export of LMV
+ * \param[in] op_data		parameters transferred beween client MD stack
+ *				stripe_information will be included in this
+ *				parameter
+ * \param[in] cb_op		ldlm callback being used in enqueue in
+ *				mdc_read_page
+ * \param[in] hash_offset	the hash value, which is used to locate
+ *				minum(closet) dir entry
+ * \param[in|out] stripe_offset	the caller use this to indicate the stripe
+ *				index of last entry, so to avoid hash conflict
+ *				between stripes. It will also be used to
+ *				return the stripe index of current dir entry.
+ * \param[in|out] entp		the minum entry and it also is being used
+ *				to input the last dir entry to resolve the
+ *				hash conflict
+ *
+ * \param[out] ppage		the page which holds the minum entry
+ *
+ * \retval			= 0 get the entry successfully
+ *				negative errno (< 0) does not get the entry
+ */
+static int lmv_get_min_striped_entry(struct obd_export *exp,
+				     struct md_op_data *op_data,
+				     struct md_callback *cb_op,
+				     __u64 hash_offset, int *stripe_offset,
+				     struct lu_dirent **entp,
+				     struct page **ppage)
+{
+	struct lmv_stripe_md *lsm = op_data->op_mea1;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lu_dirent *min_ent = NULL;
+	struct page *min_page = NULL;
+	struct lmv_tgt_desc *tgt;
+	int stripe_count;
+	int min_idx = 0;
+	int rc = 0;
+	int i;
+
+	stripe_count = lsm->lsm_md_stripe_count;
+	for (i = 0; i < stripe_count; i++) {
+		__u64 stripe_hash = hash_offset;
+		struct lu_dirent *ent = NULL;
+		struct page *page = NULL;
+		struct lu_dirpage *dp;
+
+		tgt = lmv_get_target(lmv, lsm->lsm_md_oinfo[i].lmo_mds, NULL);
+		if (IS_ERR(tgt)) {
+			rc = PTR_ERR(tgt);
+			goto out;
+		}
+
+		/*
+		 * op_data will be shared by each stripe, so we need
+		 * reset these value for each stripe
+		 */
+		op_data->op_fid1 = lsm->lsm_md_oinfo[i].lmo_fid;
+		op_data->op_fid2 = lsm->lsm_md_oinfo[i].lmo_fid;
+		op_data->op_data = lsm->lsm_md_oinfo[i].lmo_root;
+next:
+		rc = md_read_page(tgt->ltd_exp, op_data, cb_op, stripe_hash,
+				  &page);
+		if (rc)
+			goto out;
+
+		dp = page_address(page);
+		for (ent = lu_dirent_start(dp); ent;
+		     ent = lu_dirent_next(ent)) {
+			/* Skip dummy entry */
+			if (!le16_to_cpu(ent->lde_namelen))
+				continue;
+
+			if (le64_to_cpu(ent->lde_hash) < hash_offset)
+				continue;
+
+			if (le64_to_cpu(ent->lde_hash) == hash_offset &&
+			    (*entp == ent || i < *stripe_offset))
+				continue;
+
+			/* skip . and .. for other stripes */
+			if (i && (!strncmp(ent->lde_name, ".",
+					   le16_to_cpu(ent->lde_namelen)) ||
+				  !strncmp(ent->lde_name, "..",
+					   le16_to_cpu(ent->lde_namelen))))
+				continue;
+			break;
+		}
+
+		if (!ent) {
+			stripe_hash = le64_to_cpu(dp->ldp_hash_end);
+
+			kunmap(page);
+			put_page(page);
+			page = NULL;
+
+			/*
+			 * reach the end of current stripe, go to next stripe
+			 */
+			if (stripe_hash == MDS_DIR_END_OFF)
+				continue;
+			else
+				goto next;
+		}
+
+		if (min_ent) {
+			if (le64_to_cpu(min_ent->lde_hash) >
+			    le64_to_cpu(ent->lde_hash)) {
+				min_ent = ent;
+				kunmap(min_page);
+				put_page(min_page);
+				min_idx = i;
+				min_page = page;
+			} else {
+				kunmap(page);
+				put_page(page);
+				page = NULL;
+			}
+		} else {
+			min_ent = ent;
+			min_page = page;
+			min_idx = i;
+		}
+	}
+
+out:
+	if (*ppage) {
+		kunmap(*ppage);
+		put_page(*ppage);
+	}
+	*stripe_offset = min_idx;
+	*entp = min_ent;
+	*ppage = min_page;
+	return rc;
+}
+
+/**
+ * Build dir entry page from a striped directory
+ *
+ * This function gets one entry by @offset from a striped directory. It will
+ * read entries from all of stripes, and choose one closest to the required
+ * offset(&offset). A few notes
+ * 1. skip . and .. for non-zero stripes, because there can only have one .
+ * and .. in a directory.
+ * 2. op_data will be shared by all of stripes, instead of allocating new
+ * one, so need to restore before reusing.
+ * 3. release the entry page if that is not being chosen.
+ *
+ * \param[in] exp	obd export refer to LMV
+ * \param[in] op_data	hold those MD parameters of read_entry
+ * \param[in] cb_op	ldlm callback being used in enqueue in mdc_read_entry
+ * \param[out] ldp	the entry being read
+ * \param[out] ppage	the page holding the entry. Note: because the entry
+ *			will be accessed in upper layer, so we need hold the
+ *			page until the usages of entry is finished, see
+ *			ll_dir_entry_next.
+ *
+ * retval		=0 if get entry successfully
+ *			<0 cannot get entry
+ */
+static int lmv_read_striped_page(struct obd_export *exp,
+				 struct md_op_data *op_data,
+				 struct md_callback *cb_op,
+				 __u64 offset, struct page **ppage)
+{
+	struct inode *master_inode = op_data->op_data;
+	struct lu_fid master_fid = op_data->op_fid1;
+	struct obd_device *obd = exp->exp_obd;
+	__u64 hash_offset = offset;
+	struct page *min_ent_page = NULL;
+	struct page *ent_page = NULL;
+	struct lu_dirent *min_ent = NULL;
+	struct lu_dirent *last_ent;
+	struct lu_dirent *ent;
+	struct lu_dirpage *dp;
+	size_t left_bytes;
+	int ent_idx = 0;
+	void *area;
+	int rc;
+
+	rc = lmv_check_connect(obd);
+	if (rc)
+		return rc;
+
+	/*
+	 * Allocate a page and read entries from all of stripes and fill
+	 * the page by hash order
+	 */
+	ent_page = alloc_page(GFP_KERNEL);
+	if (!ent_page)
+		return -ENOMEM;
+
+	/* Initialize the entry page */
+	dp = kmap(ent_page);
+	memset(dp, 0, sizeof(*dp));
+	dp->ldp_hash_start = cpu_to_le64(offset);
+	dp->ldp_flags |= LDF_COLLIDE;
+
+	area = dp + 1;
+	left_bytes = PAGE_SIZE - sizeof(*dp);
+	ent = area;
+	last_ent = ent;
+	do {
+		__u16 ent_size;
+
+		/* Find the minum entry from all sub-stripes */
+		rc = lmv_get_min_striped_entry(exp, op_data, cb_op, hash_offset,
+					       &ent_idx, &min_ent,
+					       &min_ent_page);
+		if (rc)
+			goto out;
+
+		/*
+		 * If it can not get minum entry, it means it already reaches
+		 * the end of this directory
+		 */
+		if (!min_ent) {
+			last_ent->lde_reclen = 0;
+			hash_offset = MDS_DIR_END_OFF;
+			goto out;
+		}
+
+		ent_size = le16_to_cpu(min_ent->lde_reclen);
+
+		/*
+		 * the last entry lde_reclen is 0, but it might not
+		 * the end of this entry of this temporay entry
+		 */
+		if (!ent_size)
+			ent_size = lu_dirent_calc_size(
+					le16_to_cpu(min_ent->lde_namelen),
+					le32_to_cpu(min_ent->lde_attrs));
+		if (ent_size > left_bytes) {
+			last_ent->lde_reclen = cpu_to_le16(0);
+			hash_offset = le64_to_cpu(min_ent->lde_hash);
+			goto out;
+		}
+
+		memcpy(ent, min_ent, ent_size);
+
+		/*
+		 * Replace . with master FID and Replace .. with the parent FID
+		 * of master object
+		 */
+		if (!strncmp(ent->lde_name, ".",
+			     le16_to_cpu(ent->lde_namelen)) &&
+		    le16_to_cpu(ent->lde_namelen) == 1)
+			fid_cpu_to_le(&ent->lde_fid, &master_fid);
+		else if (!strncmp(ent->lde_name, "..",
+				  le16_to_cpu(ent->lde_namelen)) &&
+			 le16_to_cpu(ent->lde_namelen) == 2)
+			fid_cpu_to_le(&ent->lde_fid, &op_data->op_fid3);
+
+		left_bytes -= ent_size;
+		ent->lde_reclen = cpu_to_le16(ent_size);
+		last_ent = ent;
+		ent = (void *)ent + ent_size;
+		hash_offset = le64_to_cpu(min_ent->lde_hash);
+		if (hash_offset == MDS_DIR_END_OFF) {
+			last_ent->lde_reclen = 0;
+			break;
+		}
+	} while (1);
+out:
+	if (min_ent_page) {
+		kunmap(min_ent_page);
+		put_page(min_ent_page);
+	}
+
+	if (unlikely(rc)) {
+		__free_page(ent_page);
+		ent_page = NULL;
+	} else {
+		if (ent == area)
+			dp->ldp_flags |= LDF_EMPTY;
+		dp->ldp_flags = cpu_to_le32(dp->ldp_flags);
+		dp->ldp_hash_end = cpu_to_le64(hash_offset);
+	}
+
+	/*
+	 * We do not want to allocate md_op_data during each
+	 * dir entry reading, so op_data will be shared by every stripe,
+	 * then we need to restore it back to original value before
+	 * return to the upper layer
+	 */
+	op_data->op_fid1 = master_fid;
+	op_data->op_fid2 = master_fid;
+	op_data->op_data = master_inode;
+
+	*ppage = ent_page;
+
+	return rc;
+}
+
+int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
+		  struct md_callback *cb_op, __u64 offset,
+		  struct page **ppage)
+{
+	struct lmv_stripe_md *lsm = op_data->op_mea1;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
+	int rc;
+
+	rc = lmv_check_connect(obd);
+	if (rc)
+		return rc;
+
+	if (unlikely(lsm)) {
+		rc = lmv_read_striped_page(exp, op_data, cb_op, offset, ppage);
+		return rc;
+	}
+
+	tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
+	rc = md_read_page(tgt->ltd_exp, op_data, cb_op, offset, ppage);
+
+	return rc;
+}
+
+/**
  * Unlink a file/directory
  *
  * Unlink a file or directory under the parent dir. The unlink request
@@ -3268,6 +3596,7 @@ static struct md_ops lmv_md_ops = {
 	.setxattr		= lmv_setxattr,
 	.sync			= lmv_sync,
 	.readpage		= lmv_readpage,
+	.read_page		= lmv_read_page,
 	.unlink			= lmv_unlink,
 	.init_ea_size		= lmv_init_ea_size,
 	.cancel_unused		= lmv_cancel_unused,
-- 
1.7.1
