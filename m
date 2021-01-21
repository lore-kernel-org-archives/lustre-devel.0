Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0F42C433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7251823A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7251823A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D5BF921FF2C;
	Thu, 21 Jan 2021 09:18:01 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2D1B621FB7C
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:10 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 49B991008057;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4859C1158C; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:38 -0500
Message-Id: <1611249422-556-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/39] lustre: quota: df should return
 projid-specific values
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
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

With local ext4 and XFS filesystems, it is possible to use
"df /path/to/directory" (statfs()) to return the current
project quota usage for that directory as "used", and
min(projid quota limit, free space) as "total".

statfs() is a natural interface for users/applications, since
it represents the used/maximum space for that subdirectory.
Otherwise, the user will get EDQUOT back when the project
quota runs out for that directory and applications will not
be able to figure out how much data they could write into
that directory.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9555
Lustre-commit: e5c8f6670fbeea ("LU-9555 quota: df should return projid-specific values")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/36685
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   |  2 +-
 fs/lustre/llite/llite_internal.h        |  1 +
 fs/lustre/llite/llite_lib.c             | 49 +++++++++++++++++++++++++++++++++
 include/uapi/linux/lustre/lustre_user.h |  6 ++--
 4 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 6bc95d9..db620ce 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1079,7 +1079,7 @@ static int check_owner(int type, int id)
 	return 0;
 }
 
-static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
+int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 {
 	int cmd = qctl->qc_cmd;
 	int type = qctl->qc_type;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 9d988aac..bad974f 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -996,6 +996,7 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
 			     u64 offset);
 void ll_release_page(struct inode *inode, struct page *page, bool remove);
+int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl);
 
 enum get_default_layout_type {
 	GET_DEFAULT_LAYOUT_ROOT = 1,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e4036af..34bd661 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2137,6 +2137,53 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 	return rc;
 }
 
+static int ll_statfs_project(struct inode *inode, struct kstatfs *sfs)
+{
+	struct if_quotactl qctl = {
+		.qc_cmd = LUSTRE_Q_GETQUOTA,
+		.qc_type = PRJQUOTA,
+		.qc_valid = QC_GENERAL,
+	};
+	u64 limit, curblock;
+	int ret;
+
+	qctl.qc_id = ll_i2info(inode)->lli_projid;
+	ret = quotactl_ioctl(ll_i2sbi(inode), &qctl);
+	if (ret) {
+		/* ignore errors if project ID does not have
+		 * a quota limit or feature unsupported.
+		 */
+		if (ret == -ESRCH || ret == -EOPNOTSUPP)
+			ret = 0;
+		return ret;
+	}
+
+	limit = ((qctl.qc_dqblk.dqb_bsoftlimit ?
+		 qctl.qc_dqblk.dqb_bsoftlimit :
+		 qctl.qc_dqblk.dqb_bhardlimit) * 1024) / sfs->f_bsize;
+	if (limit && sfs->f_blocks > limit) {
+		curblock = (qctl.qc_dqblk.dqb_curspace +
+			    sfs->f_bsize - 1) / sfs->f_bsize;
+		sfs->f_blocks = limit;
+		sfs->f_bavail =
+			(sfs->f_blocks > curblock) ?
+			(sfs->f_blocks - curblock) : 0;
+		sfs->f_bfree = sfs->f_bavail;
+	}
+
+	limit = qctl.qc_dqblk.dqb_isoftlimit ?
+		qctl.qc_dqblk.dqb_isoftlimit :
+		qctl.qc_dqblk.dqb_ihardlimit;
+	if (limit && sfs->f_files > limit) {
+		sfs->f_files = limit;
+		sfs->f_ffree = (sfs->f_files >
+			qctl.qc_dqblk.dqb_curinodes) ?
+			(sfs->f_files - qctl.qc_dqblk.dqb_curinodes) : 0;
+	}
+
+	return 0;
+}
+
 int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 {
 	struct super_block *sb = de->d_sb;
@@ -2174,6 +2221,8 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 	sfs->f_bavail = osfs.os_bavail;
 	sfs->f_fsid.val[0] = (u32)fsid;
 	sfs->f_fsid.val[1] = (u32)(fsid >> 32);
+	if (ll_i2info(de->d_inode)->lli_projid)
+		return ll_statfs_project(de->d_inode, sfs);
 
 	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_STATFS,
 			   ktime_us_delta(ktime_get(), kstart));
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 143b7d5..62c6952 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1043,9 +1043,9 @@ struct obd_dqinfo {
 
 /* XXX: same as if_dqblk struct in kernel, plus one padding */
 struct obd_dqblk {
-	__u64 dqb_bhardlimit;
-	__u64 dqb_bsoftlimit;
-	__u64 dqb_curspace;
+	__u64 dqb_bhardlimit;	/* kbytes unit */
+	__u64 dqb_bsoftlimit;	/* kbytes unit */
+	__u64 dqb_curspace;	/* bytes unit */
 	__u64 dqb_ihardlimit;
 	__u64 dqb_isoftlimit;
 	__u64 dqb_curinodes;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
