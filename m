Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 063C3C433F5
	for <lustre-devel@archiver.kernel.org>; Thu, 28 Apr 2022 17:23:29 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E20DF21E053;
	Thu, 28 Apr 2022 10:23:27 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 113B921CBC4
 for <lustre-devel@lists.lustre.org>; Thu, 28 Apr 2022 10:23:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 7FFBF5F3;
 Thu, 28 Apr 2022 13:23:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7A239D35C8; Thu, 28 Apr 2022 13:23:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>, Sebastien Buisson <sbuisson@ddn.com>
Date: Thu, 28 Apr 2022 13:23:20 -0400
Message-Id: <1651166600-21269-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH] fscrypt: allow alternative bounce buffers
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

Currently fscrypt offers two options. One option is to use the
internal bounce buffer allocated or perform inline encrpytion.
Add the option to use an external bounce buffer. This change can
be used useful for example for a network file systems which can
pass in a page from the page cache and place the encrypted data
into a page for a network packet to be sent. Another potential
use is the use of GPU pages with RDMA being the final destination
for the encrypted data.

Signed-off-By: James Simmons <jsimmons@infradead.org>
---
 fs/crypto/crypto.c      | 34 +++++++++++++++++++---------------
 include/linux/fscrypt.h | 34 ++++++++++++++++++++++++++++------
 2 files changed, 47 insertions(+), 21 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index e78be66..f241c69 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -210,9 +210,10 @@ struct page *fscrypt_encrypt_pagecache_blocks(struct page *page,
 EXPORT_SYMBOL(fscrypt_encrypt_pagecache_blocks);
 
 /**
- * fscrypt_encrypt_block_inplace() - Encrypt a filesystem block in-place
+ * fscrypt_encrypt_page() - Cache an encrypt filesystem block in a page
  * @inode:     The inode to which this block belongs
- * @page:      The page containing the block to encrypt
+ * @src:       The page containing the block to encrypt
+ * @dst:       The page which will contain the encrypted data
  * @len:       Size of block to encrypt.  This must be a multiple of
  *		FSCRYPT_CONTENTS_ALIGNMENT.
  * @offs:      Byte offset within @page at which the block to encrypt begins
@@ -223,17 +224,18 @@ struct page *fscrypt_encrypt_pagecache_blocks(struct page *page,
  * Encrypt a possibly-compressed filesystem block that is located in an
  * arbitrary page, not necessarily in the original pagecache page.  The @inode
  * and @lblk_num must be specified, as they can't be determined from @page.
+ * The decrypted data will be stored in @dst.
  *
  * Return: 0 on success; -errno on failure
  */
-int fscrypt_encrypt_block_inplace(const struct inode *inode, struct page *page,
-				  unsigned int len, unsigned int offs,
-				  u64 lblk_num, gfp_t gfp_flags)
+int fscrypt_encrypt_page(const struct inode *inode, struct page *src,
+			 struct page *dst, unsigned int len, unsigned int offs,
+			 u64 lblk_num, gfp_t gfp_flags)
 {
-	return fscrypt_crypt_block(inode, FS_ENCRYPT, lblk_num, page, page,
+	return fscrypt_crypt_block(inode, FS_ENCRYPT, lblk_num, src, dst,
 				   len, offs, gfp_flags);
 }
-EXPORT_SYMBOL(fscrypt_encrypt_block_inplace);
+EXPORT_SYMBOL(fscrypt_encrypt_page);
 
 /**
  * fscrypt_decrypt_pagecache_blocks() - Decrypt filesystem blocks in a
@@ -280,9 +282,10 @@ int fscrypt_decrypt_pagecache_blocks(struct page *page, unsigned int len,
 EXPORT_SYMBOL(fscrypt_decrypt_pagecache_blocks);
 
 /**
- * fscrypt_decrypt_block_inplace() - Decrypt a filesystem block in-place
+ * fscrypt_decrypt_page() - Cache a decrypt a filesystem block in a page
  * @inode:     The inode to which this block belongs
- * @page:      The page containing the block to decrypt
+ * @src:       The page containing the block to decrypt
+ * @dst:       The page which will contain the plain data
  * @len:       Size of block to decrypt.  This must be a multiple of
  *		FSCRYPT_CONTENTS_ALIGNMENT.
  * @offs:      Byte offset within @page at which the block to decrypt begins
@@ -292,17 +295,18 @@ int fscrypt_decrypt_pagecache_blocks(struct page *page, unsigned int len,
  * Decrypt a possibly-compressed filesystem block that is located in an
  * arbitrary page, not necessarily in the original pagecache page.  The @inode
  * and @lblk_num must be specified, as they can't be determined from @page.
+ * The encrypted data will be stored in @dst.
  *
  * Return: 0 on success; -errno on failure
  */
-int fscrypt_decrypt_block_inplace(const struct inode *inode, struct page *page,
-				  unsigned int len, unsigned int offs,
-				  u64 lblk_num)
+int fscrypt_decrypt_page(const struct inode *inode, struct page *src,
+			 struct page *dst, unsigned int len, unsigned int offs,
+			 u64 lblk_num, gfp_t gfp_flags)
 {
-	return fscrypt_crypt_block(inode, FS_DECRYPT, lblk_num, page, page,
-				   len, offs, GFP_NOFS);
+	return fscrypt_crypt_block(inode, FS_DECRYPT, lblk_num, src, dst,
+				   len, offs, gfp_flags);
 }
-EXPORT_SYMBOL(fscrypt_decrypt_block_inplace);
+EXPORT_SYMBOL(fscrypt_decrypt_page);
 
 /**
  * fscrypt_initialize() - allocate major buffers for fs encryption.
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index efc7f96..c2b67d1 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -255,15 +255,37 @@ struct page *fscrypt_encrypt_pagecache_blocks(struct page *page,
 					      unsigned int len,
 					      unsigned int offs,
 					      gfp_t gfp_flags);
-int fscrypt_encrypt_block_inplace(const struct inode *inode, struct page *page,
-				  unsigned int len, unsigned int offs,
-				  u64 lblk_num, gfp_t gfp_flags);
+int fscrypt_encrypt_page(const struct inode *inode, struct page *src,
+			 struct page *dst, unsigned int len,
+			 unsigned int offs, u64 lblk_num, gfp_t gfp_flags);
+
+static inline int fscrypt_encrypt_block_inplace(const struct inode *inode,
+						struct page *page,
+						unsigned int len,
+						unsigned int offs,
+						u64 lblk_num,
+						gfp_t gfp_flags)
+{
+	return fscrypt_encrypt_page(inode, page, page, len, offs, lblk_num,
+				    gfp_flags);
+}
 
 int fscrypt_decrypt_pagecache_blocks(struct page *page, unsigned int len,
 				     unsigned int offs);
-int fscrypt_decrypt_block_inplace(const struct inode *inode, struct page *page,
-				  unsigned int len, unsigned int offs,
-				  u64 lblk_num);
+
+int fscrypt_decrypt_page(const struct inode *inode, struct page *src,
+			 struct page *dst, unsigned int len,
+			 unsigned int offs, u64 lblk_num, gfp_t gfp_flags);
+
+static inline int fscrypt_decrypt_block_inplace(const struct inode *inode,
+						struct page *page,
+						unsigned int len,
+						unsigned int offs,
+						u64 lblk_num)
+{
+	return fscrypt_decrypt_page(inode, page, page, len, offs, lblk_num,
+				    GFP_NOFS);
+}
 
 static inline bool fscrypt_is_bounce_page(struct page *page)
 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
