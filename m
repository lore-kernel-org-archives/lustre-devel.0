Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BCABC433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CBB8E6138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBB8E6138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 45E0F328E46;
	Mon,  5 Apr 2021 00:52:27 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D269F32C4C7
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:27 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 218CCEC1;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1EAD890AA9; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:04 -0400
Message-Id: <1617583870-32029-36-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 35/41] lustre: llite: use is_root_inode()
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

Lustre has multiple tests to see if a given inode is the root of the
filesystem.  Linux has (since 3.19) a helper function is_root_inode().
Use that throughout.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: fca56be02b8fe074 ("LU-6142 lustre: use is_root_inode()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/40293
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c | 2 +-
 fs/lustre/llite/file.c   | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 3d34b3b..0598b3c 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -100,7 +100,7 @@ static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 	}
 
 	/* Encrypting the root directory is not allowed */
-	if (inode->i_ino == inode->i_sb->s_root->d_inode->i_ino)
+	if (is_root_inode(inode))
 		return -EPERM;
 
 	dentry = (struct dentry *)fs_data;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 60b6ac4..c6d53b1 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -421,7 +421,7 @@ int ll_file_release(struct inode *inode, struct file *file)
 		libcfs_debug_dumplog();
 
 out:
-	if (!rc && inode->i_sb->s_root != file_dentry(file))
+	if (!rc && !is_root_inode(inode))
 		ll_stats_ops_tally(sbi, LPROC_LL_RELEASE,
 				   ktime_us_delta(ktime_get(), kstart));
 	return rc;
@@ -4455,7 +4455,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	 * by checking the migrate FID against the FID of the
 	 * filesystem root.
 	 */
-	if (child_inode == parent->i_sb->s_root->d_inode) {
+	if (is_root_inode(child_inode)) {
 		rc = -EINVAL;
 		goto out_iput;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
