Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 938D3C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:30 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4D624610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D624610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5B42732F875;
	Wed, 14 Apr 2021 21:03:14 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E117D32F545
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8198A100F356;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 802229188F; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:13 -0400
Message-Id: <1618459361-17909-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/49] lustre: sec: fix migrate for encrypted
 dir
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

From: Sebastien Buisson <sbuisson@ddn.com>

When setting an encryption policy on a directory that we want to
be encrypted, we need to make sure it is empty.
But, in some cases, setting the LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr
should be allowed on non-empty directories, for instance when a
directory is migrated across MDTs into new shard directories.
Also, it is required for the encrpytion key to be available on the
client when migrating a directory so that the filenames can be
properly rehashed for the new MDT directory shard.
And, in any case, we need to prevent explicit setting of
LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr outside of encryption policy
definition.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14401
Lustre-commit: 67c4cffac6dbd30c ("LU-14401 sec: fix migrate for encrypted dir")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/41413
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c         |  1 +
 fs/lustre/llite/file.c           | 12 ++++++++++++
 fs/lustre/llite/llite_internal.h |  8 +++++---
 fs/lustre/llite/xattr.c          | 11 +++++++++++
 4 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 0598b3c..8bbb766 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -104,6 +104,7 @@ static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 		return -EPERM;
 
 	dentry = (struct dentry *)fs_data;
+	set_bit(LLIF_SET_ENC_CTX, &ll_i2info(inode)->lli_flags);
 	rc = __vfs_setxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
 			    ctx, len, XATTR_CREATE);
 	if (rc)
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 767eafa..225008e 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4455,6 +4455,18 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 		goto out_iput;
 	}
 
+	if (IS_ENCRYPTED(child_inode)) {
+		rc = llcrypt_get_encryption_info(child_inode);
+		if (rc)
+			goto out_iput;
+		if (!llcrypt_has_encryption_key(child_inode)) {
+			CDEBUG(D_SEC, "no enc key for "DFID"\n",
+			       PFID(ll_inode2fid(child_inode)));
+			rc = -ENOKEY;
+			goto out_iput;
+		}
+	}
+
 	op_data = ll_prep_md_op_data(NULL, parent, NULL, name, namelen,
 				     child_inode->i_mode, LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data)) {
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 0d97253..dc9ea03 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -97,12 +97,14 @@ enum ll_file_flags {
 	LLIF_FILE_RESTORING	= 1,
 	/* Xattr cache is attached to the file */
 	LLIF_XATTR_CACHE	= 2,
+	/* Project inherit */
+	LLIF_PROJECT_INHERIT	= 3,
 	/* update atime from MDS no matter if it's older than
 	 * local inode atime.
 	 */
-	LLIF_UPDATE_ATIME,
-	/* Project inherit */
-	LLIF_PROJECT_INHERIT	= 3,
+	LLIF_UPDATE_ATIME	= 4,
+	/* setting encryption context in progress */
+	LLIF_SET_ENC_CTX	= 6,
 };
 
 /* See comment on trunc_sem_down_read_nowait */
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 119fb26..7004893 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -133,6 +133,17 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 			return -EPERM;
 	}
 
+	/* Setting LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr is only allowed
+	 * when defining an encryption policy on a directory, ie when it
+	 * comes from ll_set_context().
+	 * When new files/dirs are created in an encrypted dir, the xattr
+	 * is set directly in the create request.
+	 */
+	if (handler->flags == XATTR_SECURITY_T &&
+	    !strcmp(name, "c") &&
+	    !test_and_clear_bit(LLIF_SET_ENC_CTX, &ll_i2info(inode)->lli_flags))
+		return -EPERM;
+
 	fullname = kasprintf(GFP_KERNEL, "%s%s", xattr_prefix(handler), name);
 	if (!fullname)
 		return -ENOMEM;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
