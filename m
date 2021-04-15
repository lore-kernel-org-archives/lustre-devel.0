Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B177DC433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7450E610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7450E610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1799632F77C;
	Wed, 14 Apr 2021 21:04:17 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B359E32F4D3
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:51 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 752EB100F352;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 73CA09188F; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:09 -0400
Message-Id: <1618459361-17909-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/49] lustre: llite: create file_operations
 registration function.
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

Create new ll_register_file_operations() to set sbi->ll_ops to the
correct struct file_operations. We can make all the struct
file_operations static.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: cfa2c25f1b9b0344 ("LU-6142 llite: create file_operations registration function.")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/40608
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/llite/file.c           | 18 +++++++++++++++---
 fs/lustre/llite/llite_internal.h |  4 +---
 fs/lustre/llite/llite_lib.c      |  7 +------
 3 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 0d866ec..767eafa 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5116,7 +5116,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 }
 
 /* -o localflock - only provides locally consistent flock locks */
-const struct file_operations ll_file_operations = {
+static const struct file_operations ll_file_operations = {
 	.read_iter		= ll_file_read_iter,
 	.write_iter		= ll_file_write_iter,
 	.unlocked_ioctl		= ll_file_ioctl,
@@ -5130,7 +5130,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.fallocate		= ll_fallocate,
 };
 
-const struct file_operations ll_file_operations_flock = {
+static const struct file_operations ll_file_operations_flock = {
 	.read_iter		= ll_file_read_iter,
 	.write_iter		= ll_file_write_iter,
 	.unlocked_ioctl		= ll_file_ioctl,
@@ -5147,7 +5147,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 };
 
 /* These are for -o noflock - to return ENOSYS on flock calls */
-const struct file_operations ll_file_operations_noflock = {
+static const struct file_operations ll_file_operations_noflock = {
 	.read_iter		= ll_file_read_iter,
 	.write_iter		= ll_file_write_iter,
 	.unlocked_ioctl		= ll_file_ioctl,
@@ -5172,6 +5172,18 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.get_acl		= ll_get_acl,
 };
 
+const struct file_operations *ll_select_file_operations(struct ll_sb_info *sbi)
+{
+	const struct file_operations *fops = &ll_file_operations_noflock;
+
+	if (sbi->ll_flags & LL_SBI_FLOCK)
+		fops = &ll_file_operations_flock;
+	else if (sbi->ll_flags & LL_SBI_LOCALFLOCK)
+		fops = &ll_file_operations;
+
+	return fops;
+}
+
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 041f6d3..0d97253 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1049,10 +1049,8 @@ void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io,
 extern const struct address_space_operations ll_aops;
 
 /* llite/file.c */
-extern const struct file_operations ll_file_operations;
-extern const struct file_operations ll_file_operations_flock;
-extern const struct file_operations ll_file_operations_noflock;
 extern const struct inode_operations ll_file_inode_operations;
+const struct file_operations *ll_select_file_operations(struct ll_sb_info *sbi);
 int ll_have_md_lock(struct inode *inode, u64 *bits,
 		    enum ldlm_mode l_req_mode);
 enum ldlm_mode ll_take_md_lock(struct inode *inode, u64 bits,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e7c1b73..e15962e 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -293,12 +293,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	 */
 	sb->s_flags |= SB_NOSEC;
 
-	if (sbi->ll_flags & LL_SBI_FLOCK)
-		sbi->ll_fop = &ll_file_operations_flock;
-	else if (sbi->ll_flags & LL_SBI_LOCALFLOCK)
-		sbi->ll_fop = &ll_file_operations;
-	else
-		sbi->ll_fop = &ll_file_operations_noflock;
+	sbi->ll_fop = ll_select_file_operations(sbi);
 
 	/* always ping even if server suppress_pings */
 	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
