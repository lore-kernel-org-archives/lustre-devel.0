Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 71931C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:44:15 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWXc5WYyz22cv;
	Sun,  9 Apr 2023 05:25:36 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWXP4qxGz22ck
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:25:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7B4901008496;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7A1082B3; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:20 -0400
Message-Id: <1681042400-15491-41-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 40/40] lustre: llite: dir layout inheritance
 fixes
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
Cc: Vitaly Fertman <c17818@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <c17818@cray.com>

fixes for some minor problems:
- it may happen that the depth is not set on a dir, do not consider
  depth == 0 as a real depth while checking if the root default is
  applicable;
- setdirstripe util implicitely sets max_inherit to 3 for non-striped
  dir when -i option is given but -c is not; at the same time 3 is the
  default for striped dirs only;
- getdirstripe shows inherited default layouts with max_inherit==0,
  whereas it has no sense anymore; the same for an explicitily set
  default layout on a dir/root with max_inherit==0;
- getdirstripe hides max_inherit_rr when stripe_offset != -1 as it has
  no sense and reset to 0, however it leads to user confusion;

HPE-bug-id: LUS-11090
WC-bug-id: https://jira.whamcloud.com/browse/LU-16527
Lustre-commit: 6a5a4b49fabcb4c97 ("LU-16527 llite: dir layout inheritance fixes")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://es-gerrit.dev.cray.com/161035
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49882
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c   | 34 +++++++++++++---------------------
 fs/lustre/llite/namei.c | 10 ++++++++--
 2 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 0422701..871dd93 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1695,40 +1695,34 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		/* Get default LMV EA */
 		if (lum.lum_magic == LMV_USER_MAGIC) {
+			struct lmv_user_md *lum;
+			struct ll_inode_info *lli;
+
 			if (lmmsize > sizeof(*ulmv)) {
 				rc = -EINVAL;
 				goto finish_req;
 			}
 
-			if (root_request) {
-				struct lmv_user_md *lum;
-				struct ll_inode_info *lli;
+			lum = (struct lmv_user_md *)lmm;
+			if (lum->lum_max_inherit == LMV_INHERIT_NONE) {
+				rc = -ENODATA;
+				goto finish_req;
+			}
 
-				lum = (struct lmv_user_md *)lmm;
+			if (root_request) {
 				lli = ll_i2info(inode);
 				if (lum->lum_max_inherit !=
 				    LMV_INHERIT_UNLIMITED) {
-					if (lum->lum_max_inherit ==
-						LMV_INHERIT_NONE ||
-					    lum->lum_max_inherit <
+					if (lum->lum_max_inherit <
 						LMV_INHERIT_END ||
 					    lum->lum_max_inherit >
 						LMV_INHERIT_MAX ||
-					    lum->lum_max_inherit <
+					    lum->lum_max_inherit <=
 						lli->lli_dir_depth) {
 						rc = -ENODATA;
 						goto finish_req;
 					}
 
-					if (lum->lum_max_inherit ==
-					    lli->lli_dir_depth) {
-						lum->lum_max_inherit =
-							LMV_INHERIT_NONE;
-						lum->lum_max_inherit_rr =
-							LMV_INHERIT_RR_NONE;
-						goto out_copy;
-					}
-
 					lum->lum_max_inherit -=
 						lli->lli_dir_depth;
 				}
@@ -1748,10 +1742,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 						goto out_copy;
 					}
 
-					if (lum->lum_max_inherit_rr >
-					    lli->lli_dir_depth)
-						lum->lum_max_inherit_rr -=
-							lli->lli_dir_depth;
+					lum->lum_max_inherit_rr -=
+						lli->lli_dir_depth;
 				}
 			}
 out_copy:
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 0c4c8e6..a19e5f7 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1464,8 +1464,10 @@ static void ll_qos_mkdir_prep(struct md_op_data *op_data, struct inode *dir)
 	struct ll_inode_info *rlli = ll_i2info(root);
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct lmv_stripe_md *lsm;
+	unsigned short depth;
 
 	op_data->op_dir_depth = lli->lli_inherit_depth ?: lli->lli_dir_depth;
+	depth = lli->lli_dir_depth;
 
 	/* parent directory is striped */
 	if (unlikely(lli->lli_lsm_md))
@@ -1492,13 +1494,17 @@ static void ll_qos_mkdir_prep(struct md_op_data *op_data, struct inode *dir)
 	if (lsm->lsm_md_master_mdt_index != LMV_OFFSET_DEFAULT)
 		goto unlock;
 
+	/**
+	 * Check if the fs default is to be applied.
+	 * depth == 0 means 'not inited' for not root dir.
+	 */
 	if (lsm->lsm_md_max_inherit != LMV_INHERIT_NONE &&
 	    (lsm->lsm_md_max_inherit == LMV_INHERIT_UNLIMITED ||
-	     lsm->lsm_md_max_inherit >= lli->lli_dir_depth)) {
+	     (depth && lsm->lsm_md_max_inherit > depth))) {
 		op_data->op_flags |= MF_QOS_MKDIR;
 		if (lsm->lsm_md_max_inherit_rr != LMV_INHERIT_RR_NONE &&
 		    (lsm->lsm_md_max_inherit_rr == LMV_INHERIT_RR_UNLIMITED ||
-		     lsm->lsm_md_max_inherit_rr >= lli->lli_dir_depth))
+		     (depth && lsm->lsm_md_max_inherit_rr > depth)))
 			op_data->op_flags |= MF_RR_MKDIR;
 		CDEBUG(D_INODE, DFID" requests qos mkdir %#x\n",
 		       PFID(&lli->lli_fid), op_data->op_flags);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
