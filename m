Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E0711C19F2D
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:40:07 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyryH3S24z23L6;
	Wed,  3 Aug 2022 18:40:07 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwm55R4z23K6
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0AB97100B057;
 Wed,  3 Aug 2022 21:38:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0928D8D626; Wed,  3 Aug 2022 21:38:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:16 -0400
Message-Id: <1659577097-19253-32-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 31/32] lustre: llite: pass dmv inherit depth
 instead of dir depth
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

In directory creation, once it's ancestor has default LMV, pass
the inherit depth, otherwise pass the directory depth to ROOT.

This depth will be used in QoS allocation.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15850
Lustre-commit: c23c68a52a0436910 ("LU-15850 llite: pass dmv inherit depth instead of dir depth")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47577
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h   | 23 +++++++++++++++++--
 fs/lustre/llite/dir.c            |  3 ++-
 fs/lustre/llite/llite_internal.h |  4 ++++
 fs/lustre/llite/llite_lib.c      | 48 +++++++++++++++++++++++++++++++++++++---
 fs/lustre/llite/namei.c          |  4 ++--
 5 files changed, 74 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index cd7cf9e..3720a97 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -51,8 +51,6 @@ struct lmv_stripe_md {
 	u32	lsm_md_layout_version;
 	u32	lsm_md_migrate_offset;
 	u32	lsm_md_migrate_hash;
-	u32	lsm_md_default_count;
-	u32	lsm_md_default_index;
 	char	lsm_md_pool_name[LOV_MAXPOOLNAME + 1];
 	struct lmv_oinfo lsm_md_oinfo[0];
 };
@@ -513,4 +511,25 @@ static inline bool lmv_is_layout_changing(const struct lmv_mds_md_v1 *lmv)
 	       lmv_hash_is_migrating(cpu_to_le32(lmv->lmv_hash_type));
 }
 
+static inline u8 lmv_inherit_next(u8 inherit)
+{
+	if (inherit == LMV_INHERIT_END || inherit == LMV_INHERIT_NONE)
+		return LMV_INHERIT_NONE;
+
+	if (inherit == LMV_INHERIT_UNLIMITED || inherit > LMV_INHERIT_MAX)
+		return inherit;
+
+	return inherit - 1;
+}
+
+static inline u8 lmv_inherit_rr_next(u8 inherit_rr)
+{
+	if (inherit_rr == LMV_INHERIT_RR_NONE ||
+	    inherit_rr == LMV_INHERIT_RR_UNLIMITED ||
+	    inherit_rr > LMV_INHERIT_RR_MAX)
+		return inherit_rr;
+
+	return inherit_rr - 1;
+}
+
 #endif
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 3384d81..aea15f5 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -491,7 +491,8 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	op_data->op_dir_depth = ll_i2info(parent)->lli_dir_depth;
+	op_data->op_dir_depth = ll_i2info(parent)->lli_inherit_depth ?:
+				ll_i2info(parent)->lli_dir_depth;
 
 	if (ll_sbi_has_encrypt(sbi) &&
 	    (IS_ENCRYPTED(parent) ||
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index c350440..2139f88 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -183,6 +183,10 @@ struct ll_inode_info {
 			pid_t				lli_opendir_pid;
 			/* directory depth to ROOT */
 			unsigned short			lli_dir_depth;
+			/* directory depth to ancestor whose default LMV is
+			 * inherited.
+			 */
+			unsigned short			lli_inherit_depth;
 			/* stat will try to access statahead entries or start
 			 * statahead if this flag is set, and this flag will be
 			 * set upon dir open, and cleared when dir is closed,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index d947ede..dee2e51 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1561,6 +1561,7 @@ static void ll_update_default_lsm_md(struct inode *inode, struct lustre_md *md)
 				lmv_free_memmd(lli->lli_default_lsm_md);
 				lli->lli_default_lsm_md = NULL;
 			}
+			lli->lli_inherit_depth = 0;
 			up_write(&lli->lli_lsm_sem);
 		}
 		return;
@@ -2648,9 +2649,34 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	return 0;
 }
 
+/* child default LMV is inherited from parent */
+static inline bool ll_default_lmv_inherited(struct lmv_stripe_md *pdmv,
+					    struct lmv_stripe_md *cdmv)
+{
+	if (!pdmv || !cdmv)
+		return false;
+
+	if (pdmv->lsm_md_magic != cdmv->lsm_md_magic ||
+	    pdmv->lsm_md_stripe_count != cdmv->lsm_md_stripe_count ||
+	    pdmv->lsm_md_master_mdt_index != cdmv->lsm_md_master_mdt_index ||
+	    pdmv->lsm_md_hash_type != cdmv->lsm_md_hash_type)
+		return false;
+
+	if (cdmv->lsm_md_max_inherit !=
+	    lmv_inherit_next(pdmv->lsm_md_max_inherit))
+		return false;
+
+	if (cdmv->lsm_md_max_inherit_rr !=
+	    lmv_inherit_rr_next(pdmv->lsm_md_max_inherit_rr))
+		return false;
+
+	return true;
+}
+
 /* update directory depth to ROOT, called after LOOKUP lock is fetched. */
 void ll_update_dir_depth(struct inode *dir, struct inode *inode)
 {
+	struct ll_inode_info *plli;
 	struct ll_inode_info *lli;
 
 	if (!S_ISDIR(inode->i_mode))
@@ -2659,10 +2685,26 @@ void ll_update_dir_depth(struct inode *dir, struct inode *inode)
 	if (inode == dir)
 		return;
 
+	plli = ll_i2info(dir);
 	lli = ll_i2info(inode);
-	lli->lli_dir_depth = ll_i2info(dir)->lli_dir_depth + 1;
-	CDEBUG(D_INODE, DFID" depth %hu\n",
-	       PFID(&lli->lli_fid), lli->lli_dir_depth);
+	lli->lli_dir_depth = plli->lli_dir_depth + 1;
+	if (plli->lli_default_lsm_md && lli->lli_default_lsm_md) {
+		down_read(&plli->lli_lsm_sem);
+		down_read(&lli->lli_lsm_sem);
+		if (ll_default_lmv_inherited(plli->lli_default_lsm_md,
+					     lli->lli_default_lsm_md))
+			lli->lli_inherit_depth =
+				plli->lli_inherit_depth + 1;
+		else
+			lli->lli_inherit_depth = 0;
+		up_read(&lli->lli_lsm_sem);
+		up_read(&plli->lli_lsm_sem);
+	} else {
+		lli->lli_inherit_depth = 0;
+	}
+
+	CDEBUG(D_INODE, DFID" depth %hu default LMV depth %hu\n",
+	       PFID(&lli->lli_fid), lli->lli_dir_depth, lli->lli_inherit_depth);
 }
 
 void ll_truncate_inode_pages_final(struct inode *inode)
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index cc7b243..2215dd8 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1496,7 +1496,7 @@ static void ll_qos_mkdir_prep(struct md_op_data *op_data, struct inode *dir)
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct lmv_stripe_md *lsm;
 
-	op_data->op_dir_depth = lli->lli_dir_depth;
+	op_data->op_dir_depth = lli->lli_inherit_depth ?: lli->lli_dir_depth;
 
 	/* parent directory is striped */
 	if (unlikely(lli->lli_lsm_md))
@@ -1635,7 +1635,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			current_cap(), rdev, &request);
-#if OBD_OCD_VERSION(2, 14, 58, 0) > LUSTRE_VERSION_CODE
+#if OBD_OCD_VERSION(2, 14, 58, 0) < LUSTRE_VERSION_CODE
 	/*
 	 * server < 2.12.58 doesn't pack default LMV in intent_getattr reply,
 	 * fetch default LMV here.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
