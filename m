Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4984EC433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0708C6112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 0708C6112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 98DCD21EBE2;
	Tue, 21 Sep 2021 19:20:59 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0095F21F27A
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:10 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 30137477;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2E775FF4BE; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:54 -0400
Message-Id: <1632277201-6920-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/24] lustre: llite: check read only mount
 for setquota
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
Cc: Hongchao Zhang <hongchao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Hongchao Zhang <hongchao@whamcloud.com>

During setting quota, it should fail if the mount is read-only.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14696
Lustre-commit: 29e00cecc6019fbdb ("LU-14696 llite: check read only mount for setquota")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43765
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            | 8 ++++++--
 fs/lustre/llite/llite_internal.h | 2 +-
 fs/lustre/llite/llite_lib.c      | 2 +-
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 57f7c3c..9a4ccfc 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1080,8 +1080,9 @@ static int check_owner(int type, int id)
 	return 0;
 }
 
-int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
+int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl)
 {
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	int cmd = qctl->qc_cmd;
 	int type = qctl->qc_type;
 	int id = qctl->qc_id;
@@ -1097,6 +1098,9 @@ int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 	case LUSTRE_Q_SETDEFAULT_POOL:
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
+
+		if (sb->s_flags & SB_RDONLY)
+			return -EROFS;
 		break;
 	case Q_GETQUOTA:
 	case LUSTRE_Q_GETDEFAULT:
@@ -1873,7 +1877,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			}
 		}
 
-		rc = quotactl_ioctl(sbi, qctl);
+		rc = quotactl_ioctl(inode->i_sb, qctl);
 		if (rc == 0 && copy_to_user((void __user *)arg, qctl,
 					    sizeof(*qctl)))
 			rc = -EFAULT;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 6b5e318..ed6ff07 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1080,7 +1080,7 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
 			     u64 offset);
 void ll_release_page(struct inode *inode, struct page *page, bool remove);
-int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl);
+int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl);
 
 enum get_default_layout_type {
 	GET_DEFAULT_LAYOUT_ROOT = 1,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index cc50503..58e60c8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2263,7 +2263,7 @@ static int ll_statfs_project(struct inode *inode, struct kstatfs *sfs)
 	int ret;
 
 	qctl.qc_id = ll_i2info(inode)->lli_projid;
-	ret = quotactl_ioctl(ll_i2sbi(inode), &qctl);
+	ret = quotactl_ioctl(inode->i_sb, &qctl);
 	if (ret) {
 		/* ignore errors if project ID does not have
 		 * a quota limit or feature unsupported.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
