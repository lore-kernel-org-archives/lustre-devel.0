Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 58D12C433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4DFE43B60F6;
	Thu, 13 Jan 2022 17:38:13 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CAC943B47A4
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:09 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C8EAD100F32E;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C7340E07E4; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:50 -0500
Message-Id: <1642124283-10148-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/24] lustre: lmv: improve MDT QOS space
 balance
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

When MDTs are not balanced, QOS code tries to keep subdirectory
creation local to the same MDT when it is deep in the directory
tree, to avoid creating too many remote directories, but the
existing weight to stay on the parent MDT until 50% of other MDTs
is too radical, and causes mkdirs to be "stuck" on the same MDT.

* remove "lq_threshold_rr" from above calculation because the check
  in ltd_qos_is_usable() handles this, so use only "dir_depth".
* the factor is changed to "16 / (dir_depth + 10)", then it's less
  likely to stick to the parent MDT for top levels, while more
  likely to stay on the parent MDT for low levels:
  depth=0 -> 160%, depth=4 -> 114%, depth=6 -> 100%,
  depth=8 -> 88%, depth=12 -> 72%
* rename lli_depth to lli_dir_depth to make usage more clear.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15216
Lustre-commit: 38c4c538f53fb5f0c ("LU-15216 lmv: improve MDT QOS space balance")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45544
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            | 2 +-
 fs/lustre/llite/llite_internal.h | 2 +-
 fs/lustre/llite/llite_lib.c      | 6 +++---
 fs/lustre/llite/namei.c          | 6 +++---
 fs/lustre/lmv/lmv_obd.c          | 7 ++++---
 5 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index f3f1ce7..43cd3cc 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -480,7 +480,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	op_data->op_dir_depth = ll_i2info(parent)->lli_depth;
+	op_data->op_dir_depth = ll_i2info(parent)->lli_dir_depth;
 
 	if (ll_sbi_has_encrypt(sbi) &&
 	    (IS_ENCRYPTED(parent) ||
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index a2abec6..0398b5f 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -184,7 +184,7 @@ struct ll_inode_info {
 			 */
 			pid_t				lli_opendir_pid;
 			/* directory depth to ROOT */
-			unsigned short			lli_depth;
+			unsigned short			lli_dir_depth;
 			/* stat will try to access statahead entries or start
 			 * statahead if this flag is set, and this flag will be
 			 * set upon dir open, and cleared when dir is closed,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index f8ecdcba..e3e871d 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2609,9 +2609,9 @@ void ll_update_dir_depth(struct inode *dir, struct inode *inode)
 		return;
 
 	lli = ll_i2info(inode);
-	lli->lli_depth = ll_i2info(dir)->lli_depth + 1;
-	CDEBUG(D_INODE, DFID" depth %hu\n", PFID(&lli->lli_fid),
-	       lli->lli_depth);
+	lli->lli_dir_depth = ll_i2info(dir)->lli_dir_depth + 1;
+	CDEBUG(D_INODE, DFID" depth %hu\n",
+	       PFID(&lli->lli_fid), lli->lli_dir_depth);
 }
 
 void ll_truncate_inode_pages_final(struct inode *inode)
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index d46a30f..0683614 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1493,7 +1493,7 @@ static void ll_qos_mkdir_prep(struct md_op_data *op_data, struct inode *dir)
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct lmv_stripe_md *lsm;
 
-	op_data->op_dir_depth = lli->lli_depth;
+	op_data->op_dir_depth = lli->lli_dir_depth;
 
 	/* parent directory is striped */
 	if (unlikely(lli->lli_lsm_md))
@@ -1522,11 +1522,11 @@ static void ll_qos_mkdir_prep(struct md_op_data *op_data, struct inode *dir)
 
 	if (lsm->lsm_md_max_inherit != LMV_INHERIT_NONE &&
 	    (lsm->lsm_md_max_inherit == LMV_INHERIT_UNLIMITED ||
-	     lsm->lsm_md_max_inherit >= lli->lli_depth)) {
+	     lsm->lsm_md_max_inherit >= lli->lli_dir_depth)) {
 		op_data->op_flags |= MF_QOS_MKDIR;
 		if (lsm->lsm_md_max_inherit_rr != LMV_INHERIT_RR_NONE &&
 		    (lsm->lsm_md_max_inherit_rr == LMV_INHERIT_RR_UNLIMITED ||
-		     lsm->lsm_md_max_inherit_rr >= lli->lli_depth))
+		     lsm->lsm_md_max_inherit_rr >= lli->lli_dir_depth))
 			op_data->op_flags |= MF_RR_MKDIR;
 		CDEBUG(D_INODE, DFID" requests qos mkdir %#x\n",
 		       PFID(&lli->lli_fid), op_data->op_flags);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 55816a1..3e050b7 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1471,10 +1471,11 @@ static struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 mdt,
 
 	/* if current MDT has above-average space, within range of the QOS
 	 * threshold, stay on the same MDT to avoid creating needless remote
-	 * MDT directories. It's more likely for low level directories.
+	 * MDT directories. It's more likely for low level directories
+	 * "16 / (dir_depth + 10)" is the factor to make it more unlikely for
+	 * top level directories, while more likely for low levels.
 	 */
-	rand = total_avail * (256 - lmv->lmv_qos.lq_threshold_rr) /
-	       (total_usable * 256 * (1 + dir_depth / 4));
+	rand = total_avail * 16 / (total_usable * (dir_depth + 10));
 	if (cur && cur->ltd_qos.ltq_avail >= rand) {
 		tgt = cur;
 		goto unlock;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
