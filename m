Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1BDEC432BE
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:28 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6388660FC2
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 6388660FC2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B1B48352E27;
	Mon,  2 Aug 2021 12:51:20 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 928F3352C1D
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:51:01 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 91712100F35C;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 90631C2F50; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:45 -0400
Message-Id: <1627933851-7603-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/25] lustre: llite: enable filesystem-wide
 default LMV
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

This change includes three parts:
1. save dir depth to ROOT after lookup on client side.
2. once space balanced default LMV is set on ROOT, and
   max-inherit/max-inherit-rr is unlimited or not less than directory
   depth, new directory will be created in QOS or roundrobin mode.
3. set ROOT default LMV max-inherit unlimited, and max-inherit-rr to
   3, and increase the ratio to create subdirectory on local MDT with
   the directory depth to ROOT, so that new directories will be
   created by space usage, and the deeper it's located it's more
   likely to create on local MDTs; and the top 3 layer will be created
   in roundrobin mode if system is balanced.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14792
Lustre-commit: b9c4dc3c33fe87ec ("LU-14792 llite: enable filesystem-wide default LMV")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44090
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                 |  5 +++
 fs/lustre/llite/dir.c                   |  2 +
 fs/lustre/llite/file.c                  |  5 ++-
 fs/lustre/llite/llite_internal.h        |  5 ++-
 fs/lustre/llite/llite_lib.c             | 17 ++++++++
 fs/lustre/llite/namei.c                 | 74 ++++++++++++++++++++++++++++++---
 fs/lustre/llite/statahead.c             |  5 ++-
 fs/lustre/lmv/lmv_obd.c                 | 32 ++++++++------
 fs/lustre/lmv/lproc_lmv.c               | 26 +++++++++++-
 include/uapi/linux/lustre/lustre_user.h |  2 +
 10 files changed, 149 insertions(+), 24 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index f619342..7c5e699 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -706,6 +706,8 @@ enum md_op_flags {
 	MF_MDC_CANCEL_FID4	= BIT(3),
 	MF_GET_MDT_IDX		= BIT(4),
 	MF_GETATTR_BY_FID	= BIT(5),
+	MF_QOS_MKDIR		= BIT(6),
+	MF_RR_MKDIR		= BIT(7),
 };
 
 enum md_cli_flags {
@@ -795,6 +797,9 @@ struct md_op_data {
 
 	u32			op_projid;
 
+	/* mkdir */
+	unsigned short		op_dir_depth;
+
 	u16			op_mirror_id;
 
 	/*
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 9666534..57f7c3c 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -442,6 +442,8 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
+	op_data->op_dir_depth = ll_i2info(parent)->lli_depth;
+
 	if (ll_sbi_has_encrypt(sbi) &&
 	    (IS_ENCRYPTED(parent) ||
 	     unlikely(fscrypt_dummy_context_enabled(parent)))) {
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index a4e432e..aa5c662 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -676,8 +676,11 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 		 * of kernel will deal with that later.
 		 */
 		ll_set_lock_data(sbi->ll_md_exp, inode, itp, &bits);
-		if (bits & MDS_INODELOCK_LOOKUP)
+		if (bits & MDS_INODELOCK_LOOKUP) {
 			d_lustre_revalidate(de);
+			ll_update_dir_depth(parent->d_inode, d_inode(de));
+		}
+
 		/* if DoM bit returned along with LAYOUT bit then there
 		 * can be read-on-open data returned.
 		 */
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 2247806..95e4f45 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -178,13 +178,15 @@ struct ll_inode_info {
 			 * -- I am the owner of dir statahead.
 			 */
 			pid_t				lli_opendir_pid;
+			/* directory depth to ROOT */
+			unsigned short			lli_depth;
 			/* stat will try to access statahead entries or start
 			 * statahead if this flag is set, and this flag will be
 			 * set upon dir open, and cleared when dir is closed,
 			 * statahead hit ratio is too low, or start statahead
 			 * thread failed.
 			 */
-			unsigned int			lli_sa_enabled:1;
+			unsigned short			lli_sa_enabled:1;
 			/* generation for statahead */
 			unsigned int			lli_sa_generation;
 			/* rw lock protects lli_lsm_md */
@@ -1215,6 +1217,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 		       u32 flags);
 int ll_update_inode(struct inode *inode, struct lustre_md *md);
 void ll_update_inode_flags(struct inode *inode, unsigned int ext_flags);
+void ll_update_dir_depth(struct inode *dir, struct inode *inode);
 int ll_read_inode2(struct inode *inode, void *opaque);
 void ll_truncate_inode_pages_final(struct inode *inode);
 void ll_delete_inode(struct inode *inode);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 63d0f02..f540caf 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2483,6 +2483,23 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	return 0;
 }
 
+/* update directory depth to ROOT, called after LOOKUP lock is fetched. */
+void ll_update_dir_depth(struct inode *dir, struct inode *inode)
+{
+	struct ll_inode_info *lli;
+
+	if (!S_ISDIR(inode->i_mode))
+		return;
+
+	if (inode == dir)
+		return;
+
+	lli = ll_i2info(inode);
+	lli->lli_depth = ll_i2info(dir)->lli_depth + 1;
+	CDEBUG(D_INODE, DFID" depth %hu\n", PFID(&lli->lli_fid),
+	       lli->lli_depth);
+}
+
 void ll_truncate_inode_pages_final(struct inode *inode)
 {
 	struct address_space *mapping = &inode->i_data;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 5cc01f0..54b4e0a 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -741,8 +741,10 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 
 	if (!it_disposition(it, DISP_LOOKUP_NEG)) {
 		/* We have the "lookup" lock, so unhide dentry */
-		if (bits & MDS_INODELOCK_LOOKUP)
+		if (bits & MDS_INODELOCK_LOOKUP) {
 			d_lustre_revalidate(*de);
+			ll_update_dir_depth(parent, d_inode(*de));
+		}
 
 		if (encrypt) {
 			rc = fscrypt_get_encryption_info(inode);
@@ -1415,10 +1417,6 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			return rc;
 	}
 
-	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, inode, it, &bits);
-	if (bits & MDS_INODELOCK_LOOKUP)
-		d_lustre_revalidate(dentry);
-
 	d_instantiate(dentry, inode);
 
 	if (encrypt) {
@@ -1427,8 +1425,17 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			return rc;
 	}
 
-	if (!(ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX))
+	if (!(ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX)) {
 		rc = ll_inode_init_security(dentry, inode, dir);
+		if (rc)
+			return rc;
+	}
+
+	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, inode, it, &bits);
+	if (bits & MDS_INODELOCK_LOOKUP) {
+		d_lustre_revalidate(dentry);
+		ll_update_dir_depth(dir, inode);
+	}
 
 	return rc;
 }
@@ -1451,6 +1458,58 @@ void ll_update_times(struct ptlrpc_request *request, struct inode *inode)
 		inode->i_ctime.tv_sec = body->mbo_ctime;
 }
 
+/* once default LMV (space balanced) is set on ROOT, it should take effect if
+ * default LMV is not set on parent directory.
+ */
+static void ll_qos_mkdir_prep(struct md_op_data *op_data, struct inode *dir)
+{
+	struct inode *root = dir->i_sb->s_root->d_inode;
+	struct ll_inode_info *rlli = ll_i2info(root);
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct lmv_stripe_md *lsm;
+
+	op_data->op_dir_depth = lli->lli_depth;
+
+	/* parent directory is striped */
+	if (unlikely(lli->lli_lsm_md))
+		return;
+
+	/* default LMV set on parent directory */
+	if (unlikely(lli->lli_default_lsm_md))
+		return;
+
+	/* parent is ROOT */
+	if (unlikely(dir == root))
+		return;
+
+	/* default LMV not set on ROOT */
+	if (!rlli->lli_default_lsm_md)
+		return;
+
+	down_read(&rlli->lli_lsm_sem);
+	lsm = rlli->lli_default_lsm_md;
+	if (!lsm)
+		goto unlock;
+
+	/* not space balanced */
+	if (lsm->lsm_md_master_mdt_index != LMV_OFFSET_DEFAULT)
+		goto unlock;
+
+	if (lsm->lsm_md_max_inherit != LMV_INHERIT_NONE &&
+	    (lsm->lsm_md_max_inherit == LMV_INHERIT_UNLIMITED ||
+	     lsm->lsm_md_max_inherit >= lli->lli_depth)) {
+		op_data->op_flags |= MF_QOS_MKDIR;
+		if (lsm->lsm_md_max_inherit_rr != LMV_INHERIT_RR_NONE &&
+		    (lsm->lsm_md_max_inherit_rr == LMV_INHERIT_RR_UNLIMITED ||
+		     lsm->lsm_md_max_inherit_rr >= lli->lli_depth))
+			op_data->op_flags |= MF_RR_MKDIR;
+		CDEBUG(D_INODE, DFID" requests qos mkdir %#x\n",
+		       PFID(&lli->lli_fid), op_data->op_flags);
+	}
+unlock:
+	up_read(&rlli->lli_lsm_sem);
+}
+
 static int ll_new_node(struct inode *dir, struct dentry *dentry,
 		       const char *tgt, umode_t mode, int rdev,
 		       u32 opc)
@@ -1475,6 +1534,9 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 		goto err_exit;
 	}
 
+	if (S_ISDIR(mode))
+		ll_qos_mkdir_prep(op_data, dir);
+
 	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
 		err = ll_dentry_init_security(dentry, mode, &dentry->d_name,
 					      &op_data->op_file_secctx_name,
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 8930f61..e00fe58 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1488,8 +1488,11 @@ static int revalidate_statahead_dentry(struct inode *dir,
 			}
 
 			if ((bits & MDS_INODELOCK_LOOKUP) &&
-			    d_lustre_invalid(*dentryp))
+			    d_lustre_invalid(*dentryp)) {
 				d_lustre_revalidate(*dentryp);
+				ll_update_dir_depth(dir, (*dentryp)->d_inode);
+			}
+
 			ll_intent_release(&it);
 		}
 	}
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 71bf7811..fb64b6c 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1427,7 +1427,8 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	return md_close(tgt->ltd_exp, op_data, mod, request);
 }
 
-static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
+static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt,
+					      unsigned short dir_depth)
 {
 	struct lu_tgt_desc *tgt, *cur = NULL;
 	u64 total_avail = 0;
@@ -1470,10 +1471,10 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 
 	/* if current MDT has above-average space, within range of the QOS
 	 * threshold, stay on the same MDT to avoid creating needless remote
-	 * MDT directories.
+	 * MDT directories. It's more likely for low level directories.
 	 */
 	rand = total_avail * (256 - lmv->lmv_qos.lq_threshold_rr) /
-	       (total_usable * 256);
+	       (total_usable * 256 * (1 + dir_depth / 4));
 	if (cur && cur->ltd_qos.ltq_avail >= rand) {
 		tgt = cur;
 		rc = 0;
@@ -1727,12 +1728,14 @@ static inline bool lmv_op_default_qos_mkdir(const struct md_op_data *op_data)
 {
 	const struct lmv_stripe_md *lsm = op_data->op_default_mea1;
 
-	return lsm && lsm->lsm_md_master_mdt_index == LMV_OFFSET_DEFAULT;
+	return (op_data->op_flags & MF_QOS_MKDIR) ||
+	       (lsm && lsm->lsm_md_master_mdt_index == LMV_OFFSET_DEFAULT);
 }
 
-/* mkdir by QoS in two cases:
- * 1. 'lfs mkdir -i -1'
- * 2. parent default LMV master_mdt_index is -1
+/* mkdir by QoS in three cases:
+ * 1. ROOT default LMV is space balanced.
+ * 2. 'lfs mkdir -i -1'
+ * 3. parent default LMV master_mdt_index is -1
  *
  * NB, mkdir by QoS only if parent is not striped, this is to avoid remote
  * directories under striped directory.
@@ -1754,11 +1757,12 @@ static inline bool lmv_op_qos_mkdir(const struct md_op_data *op_data)
 	return false;
 }
 
-/* if default LMV is set, and its index is LMV_OFFSET_DEFAULT, and
- * 1. max_inherit_rr is set and is not LMV_INHERIT_RR_NONE
+/* if parent default LMV is space balanced, and
+ * 1. max_inherit_rr is set
  * 2. or parent is ROOT
- * mkdir roundrobin.
- * NB, this also needs to check server is balanced, which is checked by caller.
+ * mkdir roundrobin. Or if parent doesn't have default LMV, while ROOT default
+ * LMV requests roundrobin mkdir, do the same.
+ * NB, this needs to check server is balanced, which is done by caller.
  */
 static inline bool lmv_op_default_rr_mkdir(const struct md_op_data *op_data)
 {
@@ -1767,7 +1771,8 @@ static inline bool lmv_op_default_rr_mkdir(const struct md_op_data *op_data)
 	if (!lmv_op_default_qos_mkdir(op_data))
 		return false;
 
-	return lsm->lsm_md_max_inherit_rr != LMV_INHERIT_RR_NONE ||
+	return (op_data->op_flags & MF_RR_MKDIR) ||
+	       (lsm && lsm->lsm_md_max_inherit_rr != LMV_INHERIT_RR_NONE) ||
 	       fid_is_root(&op_data->op_fid1);
 }
 
@@ -1842,7 +1847,8 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	} else if (lmv_op_qos_mkdir(op_data)) {
 		struct lmv_tgt_desc *tmp = tgt;
 
-		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds);
+		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds,
+					 op_data->op_dir_depth);
 		if (tgt == ERR_PTR(-EAGAIN)) {
 			if (ltd_qos_is_balanced(&lmv->lmv_mdt_descs) &&
 			    !lmv_op_default_rr_mkdir(op_data) &&
diff --git a/fs/lustre/lmv/lproc_lmv.c b/fs/lustre/lmv/lproc_lmv.c
index 767b40e..b9efae9 100644
--- a/fs/lustre/lmv/lproc_lmv.c
+++ b/fs/lustre/lmv/lproc_lmv.c
@@ -121,10 +121,21 @@ static ssize_t qos_prio_free_store(struct kobject *kobj,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct lmv_obd *lmv = &obd->u.lmv;
+	char buf[6], *tmp;
 	unsigned int val;
 	int rc;
 
-	rc = kstrtouint(buffer, 0, &val);
+	/* "100%\n\0" should be largest string */
+	if (count >= sizeof(buf))
+		return -ERANGE;
+
+	strncpy(buf, buffer, sizeof(buf));
+	buf[sizeof(buf) - 1] = '\0';
+	tmp = strchr(buf, '%');
+	if (tmp)
+		*tmp = '\0';
+
+	rc = kstrtouint(buf, 0, &val);
 	if (rc)
 		return rc;
 
@@ -158,10 +169,21 @@ static ssize_t qos_threshold_rr_store(struct kobject *kobj,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct lmv_obd *lmv = &obd->u.lmv;
+	char buf[6], *tmp;
 	unsigned int val;
 	int rc;
 
-	rc = kstrtouint(buffer, 0, &val);
+	/* "100%\n\0" should be largest string */
+	if (count >= sizeof(buf))
+		return -ERANGE;
+
+	strncpy(buf, buffer, sizeof(buf));
+	buf[sizeof(buf) - 1] = '\0';
+	tmp = strchr(buf, '%');
+	if (tmp)
+		*tmp = '\0';
+
+	rc = kstrtouint(buf, 0, &val);
 	if (rc)
 		return rc;
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index da15ca8..b317bbf 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -847,6 +847,8 @@ enum {
 	LMV_INHERIT_RR_DEFAULT		= 0,
 	/* not inherit any more */
 	LMV_INHERIT_RR_END		= 1,
+	/* default inherit_rr of ROOT */
+	LMV_INHERIT_RR_ROOT		= 3,
 	/* max inherit depth */
 	LMV_INHERIT_RR_MAX		= 250,
 	/* [251, 254] are reserved */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
