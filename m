Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2FBEBECAAD3
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lz6PWsz1yBh;
	Mon,  5 Sep 2022 18:56:31 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lK3DtFz1y6G
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EAF10100B036;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E97CA58999; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:35 -0400
Message-Id: <1662429337-18737-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/24] lustre: sec: fix detection of SELinux
 enforcement
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

For newer kernels, for which selinux_is_enabled() does not exist
anymore, the only way to find out if SELinux is enforced when
initializing the security context is to fetch the length of the
security attribute name. If it is 0, we conclude SELinux is disabled.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16012
Lustre-commit: 155cbc22ba4f758cf ("LU-16012 sec: fix detection of SELinux enforcement")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/48049
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            |  3 ++-
 fs/lustre/llite/llite_internal.h |  3 ++-
 fs/lustre/llite/namei.c          |  6 ++++--
 fs/lustre/llite/xattr_security.c | 12 +++++++++++-
 4 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index bffd34c..9e7812d 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -513,7 +513,8 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 		 * to determine the security context for the file. So our fake
 		 * dentry should be real enough for this purpose.
 		 */
-		err = ll_dentry_init_security(&dentry, mode, &dentry.d_name,
+		err = ll_dentry_init_security(parent,
+					      &dentry, mode, &dentry.d_name,
 					      &op_data->op_file_secctx_name,
 					      &op_data->op_file_secctx,
 					      &op_data->op_file_secctx_size);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 227b944..6d85b96 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -447,7 +447,8 @@ static inline void obd_connect_set_secctx(struct obd_connect_data *data)
 #endif
 }
 
-int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
+int ll_dentry_init_security(struct inode *parent, struct dentry *dentry,
+			    int mode, struct qstr *name,
 			    const char **secctx_name, void **secctx,
 			    u32 *secctx_size);
 int ll_inode_init_security(struct dentry *dentry, struct inode *inode,
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index a08b1c1..d382554 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -891,7 +891,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 
 	if (it->it_op & IT_CREAT &&
 	    test_bit(LL_SBI_FILE_SECCTX, ll_i2sbi(parent)->ll_flags)) {
-		rc = ll_dentry_init_security(dentry, it->it_create_mode,
+		rc = ll_dentry_init_security(parent,
+					     dentry, it->it_create_mode,
 					     &dentry->d_name,
 					     &op_data->op_file_secctx_name,
 					     &op_data->op_file_secctx,
@@ -1570,7 +1571,8 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 		ll_qos_mkdir_prep(op_data, dir);
 
 	if (test_bit(LL_SBI_FILE_SECCTX, sbi->ll_flags)) {
-		err = ll_dentry_init_security(dchild, mode, &dchild->d_name,
+		err = ll_dentry_init_security(dir,
+					      dchild, mode, &dchild->d_name,
 					      &op_data->op_file_secctx_name,
 					      &op_data->op_file_secctx,
 					      &op_data->op_file_secctx_size);
diff --git a/fs/lustre/llite/xattr_security.c b/fs/lustre/llite/xattr_security.c
index f14021d..39229d3 100644
--- a/fs/lustre/llite/xattr_security.c
+++ b/fs/lustre/llite/xattr_security.c
@@ -38,7 +38,8 @@
 /*
  * Check for LL_SBI_FILE_SECCTX before calling.
  */
-int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
+int ll_dentry_init_security(struct inode *parent, struct dentry *dentry,
+			    int mode, struct qstr *name,
 			    const char **secctx_name, void **secctx,
 			    u32 *secctx_size)
 {
@@ -58,6 +59,15 @@ int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
 	 * from SELinux.
 	 */
 
+	/* fetch length of security xattr name */
+	rc = security_inode_listsecurity(parent, NULL, 0);
+	/* xattr name length == 0 means SELinux is disabled */
+	if (rc == 0)
+		return 0;
+	/* we support SELinux only */
+	if (rc != strlen(XATTR_NAME_SELINUX) + 1)
+		return -EOPNOTSUPP;
+
 	rc = security_dentry_init_security(dentry, mode, name, secctx,
 					   secctx_size);
 	/* Usually, security_dentry_init_security() returns -EOPNOTSUPP when
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
