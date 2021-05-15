Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7941C433B4
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8421A611C9
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8421A611C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 355FE21FA9B;
	Sat, 15 May 2021 06:06:38 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4025C21CB06
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8E9EC1006CBC;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8989993BCE; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:06:07 -0400
Message-Id: <1621083970-32463-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/13] lustre: lmv: add default LMV inherit
 depth
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

A new field "u8 lum_max_inherit" is added into struct lmv_user_md,
which represents the inherit depth of default LMV. It will be
decreased by 1 for subdirectories.

The valid value of lum_max_inherit is [0, 255]:
* 0 means unlimited inherit.
* 1 means inherit end.
* 250 is the max inherit depth.
* [251, 254] are reserved.
* 255 means it's not set.

A new field "u8 lum_max_inherit_rr" is added, if default stripe
offset is -1, lum_max_inherit_rr is non-zero, and system is balanced,
new directories are created in roundrobin mannner, otherwise they
are created on the MDT where their parents are located to avoid
creating remote directories. And similarly this value will be
decreased by 1 for each level of subdirectories.

The valid value of lum_max_inherit_rr is different:
* 0 means not set.
* 1 means inherit end.
* 250 is the max inherit depth.
* [251, 254] are reserved.
* 255 means unlimited inherit.

However for the user interface of "lfs", the valid value is [-1, 250]:
* -1 means unlimited inherit.
* 0 means not set.
* others are the same.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13440
Lustre-commit: 01d34a6b3b2e34f7 ("LU-13440 lmv: add default LMV inherit depth")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43131
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h           | 24 ++++++++++++-
 fs/lustre/include/lustre_lmv.h          |  8 +++--
 fs/lustre/llite/namei.c                 |  4 +++
 fs/lustre/lmv/lmv_obd.c                 | 62 +++++++++++++++++++++++++++------
 fs/lustre/obdclass/lu_tgt_descs.c       | 16 ---------
 fs/lustre/ptlrpc/pack_generic.c         |  5 ++-
 include/uapi/linux/lustre/lustre_user.h | 37 +++++++++++++++++++-
 7 files changed, 124 insertions(+), 32 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index a270631..3a71d6b 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1537,11 +1537,33 @@ struct lu_tgt_descs {
 void lu_tgt_descs_fini(struct lu_tgt_descs *ltd);
 int ltd_add_tgt(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt);
 void ltd_del_tgt(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt);
-bool ltd_qos_is_usable(struct lu_tgt_descs *ltd);
 int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd);
 int ltd_qos_update(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt,
 		   u64 *total_wt);
 
+/**
+ * Whether MDT inode and space usages are balanced.
+ */
+static inline bool ltd_qos_is_balanced(struct lu_tgt_descs *ltd)
+{
+	return !test_bit(LQ_DIRTY, &ltd->ltd_qos.lq_flags) &&
+	       test_bit(LQ_SAME_SPACE, &ltd->ltd_qos.lq_flags);
+}
+
+/**
+ * Whether QoS data is up-to-date and QoS can be applied.
+ */
+static inline bool ltd_qos_is_usable(struct lu_tgt_descs *ltd)
+{
+	if (ltd_qos_is_balanced(ltd))
+		return false;
+
+	if (ltd->ltd_lov_desc.ld_active_tgt_count < 2)
+		return false;
+
+	return true;
+}
+
 static inline struct lu_tgt_desc *ltd_first_tgt(struct lu_tgt_descs *ltd)
 {
 	int index;
diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index aee8342..a74f0a5 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -46,6 +46,8 @@ struct lmv_stripe_md {
 	u32	lsm_md_stripe_count;
 	u32	lsm_md_master_mdt_index;
 	u32	lsm_md_hash_type;
+	u8	lsm_md_max_inherit;
+	u8	lsm_md_max_inherit_rr;
 	u32	lsm_md_layout_version;
 	u32	lsm_md_migrate_offset;
 	u32	lsm_md_migrate_hash;
@@ -119,11 +121,11 @@ static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
 	 * terminated string so only print LOV_MAXPOOLNAME bytes.
 	 */
 	CDEBUG(mask,
-	       "magic %#x stripe count %d master mdt %d hash type %#x version %d migrate offset %d migrate hash %#x pool %.*s\n",
+	       "magic %#x stripe count %d master mdt %d hash type %#x max inherit %hhu version %d migrate offset %d migrate hash %#x pool %.*s\n",
 	       lsm->lsm_md_magic, lsm->lsm_md_stripe_count,
 	       lsm->lsm_md_master_mdt_index, lsm->lsm_md_hash_type,
-	       lsm->lsm_md_layout_version, lsm->lsm_md_migrate_offset,
-	       lsm->lsm_md_migrate_hash,
+	       lsm->lsm_md_max_inherit, lsm->lsm_md_layout_version,
+	       lsm->lsm_md_migrate_offset, lsm->lsm_md_migrate_hash,
 	       LOV_MAXPOOLNAME, lsm->lsm_md_pool_name);
 
 	if (!lmv_dir_striped(lsm))
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 658da49..6ed2943 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1451,6 +1451,10 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 			md.default_lmv->lsm_md_master_mdt_index =
 				lum->lum_stripe_offset;
 			md.default_lmv->lsm_md_hash_type = lum->lum_hash_type;
+			md.default_lmv->lsm_md_max_inherit =
+				lum->lum_max_inherit;
+			md.default_lmv->lsm_md_max_inherit_rr =
+				lum->lum_max_inherit_rr;
 
 			err = ll_update_inode(dir, &md);
 			md_free_lustre_md(sbi->ll_md_exp, &md);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 4fa441e..552ef07 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1695,6 +1695,22 @@ int lmv_old_layout_lookup(struct lmv_obd *lmv, struct md_op_data *op_data)
 	return rc;
 }
 
+static inline bool lmv_op_user_qos_mkdir(const struct md_op_data *op_data)
+{
+	const struct lmv_user_md *lum = op_data->op_data;
+
+	return (op_data->op_cli_flags & CLI_SET_MEA) && lum &&
+	       le32_to_cpu(lum->lum_magic) == LMV_USER_MAGIC &&
+	       le32_to_cpu(lum->lum_stripe_offset) == LMV_OFFSET_DEFAULT;
+}
+
+static inline bool lmv_op_default_qos_mkdir(const struct md_op_data *op_data)
+{
+	const struct lmv_stripe_md *lsm = op_data->op_default_mea1;
+
+	return lsm && lsm->lsm_md_master_mdt_index == LMV_OFFSET_DEFAULT;
+}
+
 /* mkdir by QoS in two cases:
  * 1. 'lfs mkdir -i -1'
  * 2. parent default LMV master_mdt_index is -1
@@ -1704,27 +1720,38 @@ int lmv_old_layout_lookup(struct lmv_obd *lmv, struct md_op_data *op_data)
  */
 static inline bool lmv_op_qos_mkdir(const struct md_op_data *op_data)
 {
-	const struct lmv_stripe_md *lsm = op_data->op_default_mea1;
-	const struct lmv_user_md *lum = op_data->op_data;
-
 	if (op_data->op_code != LUSTRE_OPC_MKDIR)
 		return false;
 
 	if (lmv_dir_striped(op_data->op_mea1))
 		return false;
 
-	if (op_data->op_cli_flags & CLI_SET_MEA && lum &&
-	    (le32_to_cpu(lum->lum_magic) == LMV_USER_MAGIC ||
-	     le32_to_cpu(lum->lum_magic) == LMV_USER_MAGIC_SPECIFIC) &&
-	    le32_to_cpu(lum->lum_stripe_offset) == LMV_OFFSET_DEFAULT)
+	if (lmv_op_user_qos_mkdir(op_data))
 		return true;
 
-	if (lsm && lsm->lsm_md_master_mdt_index == LMV_OFFSET_DEFAULT)
+	if (lmv_op_default_qos_mkdir(op_data))
 		return true;
 
 	return false;
 }
 
+/* if default LMV is set, and its index is LMV_OFFSET_DEFAULT, and
+ * 1. max_inherit_rr is set and is not LMV_INHERIT_RR_NONE
+ * 2. or parent is ROOT
+ * mkdir roundrobin.
+ * NB, this also needs to check server is balanced, which is checked by caller.
+ */
+static inline bool lmv_op_default_rr_mkdir(const struct md_op_data *op_data)
+{
+	const struct lmv_stripe_md *lsm = op_data->op_default_mea1;
+
+	if (!lmv_op_default_qos_mkdir(op_data))
+		return false;
+
+	return lsm->lsm_md_max_inherit_rr != LMV_INHERIT_RR_NONE ||
+	       fid_is_root(&op_data->op_fid1);
+}
+
 /* 'lfs mkdir -i <specific_MDT>' */
 static inline bool lmv_op_user_specific_mkdir(const struct md_op_data *op_data)
 {
@@ -1746,6 +1773,7 @@ static inline bool lmv_op_user_specific_mkdir(const struct md_op_data *op_data)
 	       op_data->op_default_mea1->lsm_md_master_mdt_index !=
 			LMV_OFFSET_DEFAULT;
 }
+
 int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		const void *data, size_t datalen, umode_t mode, uid_t uid,
 		gid_t gid, kernel_cap_t cap_effective, u64 rdev,
@@ -1793,11 +1821,23 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		if (!tgt)
 			return -ENODEV;
 	} else if (lmv_op_qos_mkdir(op_data)) {
+		struct lmv_tgt_desc *tmp = tgt;
+
 		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds);
-		if (tgt == ERR_PTR(-EAGAIN))
-			tgt = lmv_locate_tgt_rr(lmv, &op_data->op_mds);
+		if (tgt == ERR_PTR(-EAGAIN)) {
+			if (ltd_qos_is_balanced(&lmv->lmv_mdt_descs) &&
+			    !lmv_op_default_rr_mkdir(op_data) &&
+			    !lmv_op_user_qos_mkdir(op_data))
+				/* if it's not necessary, don't create remote
+				 * directory.
+				 */
+				tgt = tmp;
+			else
+				tgt = lmv_locate_tgt_rr(lmv, &op_data->op_mds);
+		}
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
+
 		/*
 		 * only update statfs after QoS mkdir, this means the cached
 		 * statfs may be stale, and current mkdir may not follow QoS
@@ -3110,6 +3150,8 @@ static inline int lmv_unpack_user_md(struct obd_export *exp,
 	lsm->lsm_md_stripe_count = le32_to_cpu(lmu->lum_stripe_count);
 	lsm->lsm_md_master_mdt_index = le32_to_cpu(lmu->lum_stripe_offset);
 	lsm->lsm_md_hash_type = le32_to_cpu(lmu->lum_hash_type);
+	lsm->lsm_md_max_inherit = lmu->lum_max_inherit;
+	lsm->lsm_md_max_inherit_rr = lmu->lum_max_inherit_rr;
 	lsm->lsm_md_pool_name[LOV_MAXPOOLNAME] = 0;
 
 	return 0;
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index 9f33d22..83f4675 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -403,22 +403,6 @@ void ltd_del_tgt(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
 EXPORT_SYMBOL(ltd_del_tgt);
 
 /**
- * Whether QoS data is up-to-date and QoS can be applied.
- */
-bool ltd_qos_is_usable(struct lu_tgt_descs *ltd)
-{
-	if (!test_bit(LQ_DIRTY, &ltd->ltd_qos.lq_flags) &&
-	    test_bit(LQ_SAME_SPACE, &ltd->ltd_qos.lq_flags))
-		return false;
-
-	if (ltd->ltd_lov_desc.ld_active_tgt_count < 2)
-		return false;
-
-	return true;
-}
-EXPORT_SYMBOL(ltd_qos_is_usable);
-
-/**
  * Calculate penalties per-tgt and per-server
  *
  * Re-calculate penalties when the configuration changes, active targets
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 5dbab3d..047573a 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2067,7 +2067,10 @@ void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 	__swab32s(&lum->lum_stripe_offset);
 	__swab32s(&lum->lum_hash_type);
 	__swab32s(&lum->lum_type);
-	BUILD_BUG_ON(!offsetof(typeof(*lum), lum_padding1));
+	/* lum_max_inherit and lum_max_inherit_rr do not need to be swabbed */
+	BUILD_BUG_ON(offsetof(typeof(*lum), lum_padding1) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*lum), lum_padding2) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*lum), lum_padding3) == 0);
 	switch (lum->lum_magic) {
 	case LMV_USER_MAGIC_SPECIFIC:
 		count = lum->lum_stripe_count;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 542d2d3..bcb9f86 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -789,7 +789,11 @@ struct lmv_user_md_v1 {
 	__u32	lum_stripe_offset;	/* MDT idx for default dirstripe */
 	__u32	lum_hash_type;		/* Dir stripe policy */
 	__u32	lum_type;		/* LMV type: default */
-	__u32	lum_padding1;
+	__u8	lum_max_inherit;	/* inherit depth of default LMV */
+	__u8	lum_max_inherit_rr;	/* inherit depth of default LMV to
+					 * round-robin mkdir
+					 */
+	__u16	lum_padding1;
 	__u32	lum_padding2;
 	__u32	lum_padding3;
 	char	lum_pool_name[LOV_MAXPOOLNAME + 1];
@@ -815,6 +819,37 @@ enum lmv_type {
 	LMV_TYPE_DEFAULT = 0x0000,
 };
 
+/* lum_max_inherit will be decreased by 1 after each inheritance if it's not
+ * LMV_INHERIT_UNLIMITED or > LMV_INHERIT_MAX.
+ */
+enum {
+	/* for historical reason, 0 means unlimited inheritance */
+	LMV_INHERIT_UNLIMITED	= 0,
+	/* unlimited lum_max_inherit by default */
+	LMV_INHERIT_DEFAULT	= 0,
+	/* not inherit any more */
+	LMV_INHERIT_END		= 1,
+	/* max inherit depth */
+	LMV_INHERIT_MAX		= 250,
+	/* [251, 254] are reserved */
+	/* not set, or when inherit depth goes beyond end,  */
+	LMV_INHERIT_NONE	= 255,
+};
+
+enum {
+	/* not set, or when inherit_rr depth goes beyond end,  */
+	LMV_INHERIT_RR_NONE		= 0,
+	/* disable lum_max_inherit_rr by default */
+	LMV_INHERIT_RR_DEFAULT		= 0,
+	/* not inherit any more */
+	LMV_INHERIT_RR_END		= 1,
+	/* max inherit depth */
+	LMV_INHERIT_RR_MAX		= 250,
+	/* [251, 254] are reserved */
+	/* unlimited inheritance */
+	LMV_INHERIT_RR_UNLIMITED	= 255,
+};
+
 static inline int lmv_user_md_size(int stripes, int lmm_magic)
 {
 	int size = sizeof(struct lmv_user_md);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
