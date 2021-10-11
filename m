Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30219C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E171660E78
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org E171660E78
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0098D380FEC;
	Mon, 11 Oct 2021 10:41:16 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E125E21FB84
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:54 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id AFB33265;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A72AFD5A47; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:34 -0400
Message-Id: <1633974049-26490-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/20] lustre: sec: do not expose security.c
 to listxattr/getxattr
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

security.c xattr, which contains encryption context, should not be
exposed by the xattr-related system calls such as listxattr() and
getxattr() because of its special semantics.
Update sanity-sec test_57 to test this.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14677
Lustre-commit: efb66de719329ce4d ("LU-14677 sec: do not expose security.c to listxattr/getxattr")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/44101
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c         | 16 ++++++++++++++++
 fs/lustre/llite/llite_internal.h |  5 +++++
 fs/lustre/llite/xattr.c          | 32 +++++++++++++++++++++++++++++++-
 3 files changed, 52 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 5d99037..0fae9a5 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -32,10 +32,26 @@
 static int ll_get_context(struct inode *inode, void *ctx, size_t len)
 {
 	struct dentry *dentry = d_find_any_alias(inode);
+	struct lu_env *env;
+	u16 refcheck;
 	int rc;
 
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	/* Set lcc_getencctx=1 to allow this thread to read
+	 * LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr, as requested by llcrypt.
+	 */
+	ll_cl_add(inode, env, NULL, LCC_RW);
+	ll_env_info(env)->lti_io_ctx.lcc_getencctx = 1;
+
 	rc = __vfs_getxattr(dentry, inode, LL_XATTR_NAME_ENCRYPTION_CONTEXT,
 			    ctx, len);
+
+	ll_cl_remove(inode, env);
+	cl_env_put(env, &refcheck);
+
 	if (dentry)
 		dput(dentry);
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index cfeec14..e0fda00 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1312,6 +1312,11 @@ struct ll_cl_context {
 	struct cl_io   *lcc_io;
 	struct cl_page *lcc_page;
 	enum lcc_type		 lcc_type;
+	/**
+	 * Get encryption context operation in progress,
+	 * allow getxattr of LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr
+	 */
+	unsigned int		 lcc_getencctx:1;
 };
 
 struct ll_thread_info {
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 001c828..59a1400 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -366,6 +366,21 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 	void *xdata;
 	int rc;
 
+	/* Getting LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr is only allowed
+	 * when it comes from ll_get_context(), ie when llcrypt needs to
+	 * know the encryption context.
+	 * Otherwise, any direct reading of this xattr returns -EPERM.
+	 */
+	if (type == XATTR_SECURITY_T &&
+	    !strcmp(name, LL_XATTR_NAME_ENCRYPTION_CONTEXT)) {
+		struct ll_cl_context *lcc = ll_cl_find(inode);
+
+		if (!lcc || !lcc->lcc_getencctx) {
+			rc = -EPERM;
+			goto out_xattr;
+		}
+	}
+
 	if (sbi->ll_xattr_cache_enabled && type != XATTR_ACL_ACCESS_T &&
 	    (type != XATTR_SECURITY_T || strcmp(name, "security.selinux"))) {
 		rc = ll_xattr_cache_get(inode, name, buffer, size, valid);
@@ -632,9 +647,24 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 	rem = rc;
 
 	while (rem > 0) {
+		bool hide_xattr = false;
+
+		/* Listing xattrs should not expose
+		 * LL_XATTR_NAME_ENCRYPTION_CONTEXT xattr, unless it comes
+		 * from llcrypt.
+		 */
+		if (get_xattr_type(xattr_name)->flags == XATTR_SECURITY_T &&
+		    !strcmp(xattr_name, LL_XATTR_NAME_ENCRYPTION_CONTEXT)) {
+			struct ll_cl_context *lcc = ll_cl_find(inode);
+
+			if (!lcc || !lcc->lcc_getencctx)
+				hide_xattr = true;
+		}
+
 		len = strnlen(xattr_name, rem - 1) + 1;
 		rem -= len;
-		if (!xattr_type_filter(sbi, get_xattr_type(xattr_name))) {
+		if (!xattr_type_filter(sbi, hide_xattr ? NULL :
+				       get_xattr_type(xattr_name))) {
 			/* Skip OK xattr type, leave it in buffer. */
 			xattr_name += len;
 			continue;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
