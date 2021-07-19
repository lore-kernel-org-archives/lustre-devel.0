Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F377C07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:33:15 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 27BAC6112D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:33:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27BAC6112D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8637834F9FB;
	Mon, 19 Jul 2021 05:32:46 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E4B0834F996
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id BABFA9E8;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B7F72BD1CB; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:32:13 -0400
Message-Id: <1626697933-6971-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/18] lustre: sec: migrate/extend/split on
 encrypted file
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

lfs migrate/extend/split makes use of volatile files to swap layouts.
When operation is carried out on an encrypted file, the volatile file
must be assigned the same encryption context as the original file, so
that data moved/copied to different OSTs is identical to the original
file's.
Also update sanity-sec test_52 to exercise these commands.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14677
Lustre-commit: 09c558d16f0a80f4 ("LU-14677 sec: migrate/extend/split on encrypted file")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/43878
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_crypto.h |   2 +
 fs/lustre/llite/llite_lib.c       |   6 +--
 fs/lustre/llite/namei.c           | 101 ++++++++++++++++++++++++++++++++++++--
 3 files changed, 102 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/include/lustre_crypto.h b/fs/lustre/include/lustre_crypto.h
index b19bb420..6cc946d 100644
--- a/fs/lustre/include/lustre_crypto.h
+++ b/fs/lustre/include/lustre_crypto.h
@@ -58,6 +58,8 @@ static inline bool ll_sbi_has_encrypt(struct ll_sb_info *sbi)
 
 static inline void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set) { }
 #endif
+/* sizeof(struct fscrypt_context_v2) = 40 */
+#define LLCRYPT_ENC_CTX_SIZE 40
 
 /* Encoding/decoding routines inspired from yEnc principles.
  * We just take care of a few critical characters:
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 88a1d17..5610523 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2063,8 +2063,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 			 * it is necessary due to possible time
 			 * de-synchronization between MDT inode and OST objects
 			 */
-			if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode) &&
-			    attr->ia_valid & ATTR_SIZE) {
+			if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode)) {
 				xvalid |= OP_XVALID_FLAGS;
 				flags = LUSTRE_ENCRYPT_FL;
 				/* Call to ll_io_zero_page is not necessary if
@@ -2073,7 +2072,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 				 * In case of Direct IO, all we need is to set
 				 * new size.
 				 */
-				if (attr->ia_size & ~PAGE_MASK &&
+				if (attr->ia_valid & ATTR_SIZE &&
+				    attr->ia_size & ~PAGE_MASK &&
 				    !(attr->ia_valid & ATTR_FILE &&
 				      attr->ia_file->f_flags & O_DIRECT)) {
 					pgoff_t offset;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index f32aa14..5cc01f0 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -33,6 +33,7 @@
 #include <linux/fs.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
+#include <linux/file.h>
 #include <linux/quotaops.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
@@ -878,10 +879,102 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 			*secctxlen = 0;
 	}
 	if (it->it_op & IT_CREAT && encrypt) {
-		rc = fscrypt_inherit_context(parent, NULL, op_data, false);
-		if (rc) {
-			retval = ERR_PTR(rc);
-			goto out;
+		/* Volatile file name may look like:
+		 * <parent>/LUSTRE_VOLATILE_HDR:<mdt_index>:<random>:fd=<fd>
+		 * where fd is opened descriptor of reference file.
+		 */
+		if (unlikely(filename_is_volatile(dentry->d_name.name,
+						  dentry->d_name.len, NULL))) {
+			int ctx_size = LLCRYPT_ENC_CTX_SIZE;
+			struct lustre_sb_info *lsi;
+			struct file *ref_file;
+			struct inode *ref_inode;
+			char *p, *q, *fd_str;
+			void *ctx;
+			int fd;
+
+			p = strnstr(dentry->d_name.name, ":fd=",
+				    dentry->d_name.len);
+			if (!p || strlen(p + 4) == 0) {
+				retval = ERR_PTR(-EINVAL);
+				goto out;
+			}
+
+			q = strchrnul(p + 4, ':');
+			fd_str = kstrndup(p + 4, q - p - 4, GFP_NOFS);
+			if (!fd_str) {
+				retval = ERR_PTR(-ENOMEM);
+				goto out;
+			}
+			rc = kstrtouint(fd_str, 10, &fd);
+			kfree(fd_str);
+			if (rc) {
+				rc = -EINVAL;
+				goto inherit;
+			}
+
+			ref_file = fget(fd);
+			if (!ref_file) {
+				rc = -EINVAL;
+				goto inherit;
+			}
+
+			ref_inode = file_inode(ref_file);
+			if (!ref_inode) {
+				fput(ref_file);
+				rc = -EINVAL;
+				goto inherit;
+			}
+
+			lsi = s2lsi(ref_inode->i_sb);
+
+getctx:
+			ctx = kzalloc(ctx_size, GFP_NOFS);
+			if (!ctx) {
+				retval = ERR_PTR(-ENOMEM);
+				goto out;
+			}
+
+#ifdef CONFIG_FS_ENCRYPTION
+			rc = ref_inode->i_sb->s_cop->get_context(ref_inode,
+								 ctx, ctx_size);
+#else
+			rc = -ENODATA;
+#endif
+			if (rc == -ERANGE) {
+				kfree(ctx);
+				ctx_size *= 2;
+				goto getctx;
+			}
+			fput(ref_file);
+			if (rc < 0) {
+				kfree(ctx);
+				goto inherit;
+			}
+
+			op_data->op_file_encctx_size = rc;
+			if (rc == ctx_size) {
+				op_data->op_file_encctx = ctx;
+			} else {
+				op_data->op_file_encctx = kzalloc(op_data->op_file_encctx_size,
+								  GFP_NOFS);
+				if (!op_data->op_file_encctx) {
+					kfree(ctx);
+					retval = ERR_PTR(-ENOMEM);
+					goto out;
+				}
+				memcpy(op_data->op_file_encctx, ctx,
+				       op_data->op_file_encctx_size);
+				kfree(ctx);
+			}
+		} else {
+inherit:
+			rc = fscrypt_inherit_context(parent, NULL, op_data,
+						     false);
+			if (rc) {
+				retval = ERR_PTR(rc);
+				goto out;
+			}
 		}
 		if (encctx)
 			*encctx = op_data->op_file_encctx;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
