Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E4724C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 16 May 2022 17:32:29 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D141721E05A;
	Mon, 16 May 2022 10:32:28 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0253021CBBE
 for <lustre-devel@lists.lustre.org>; Mon, 16 May 2022 10:32:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2F09CEC2;
 Mon, 16 May 2022 13:32:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2609D58970; Mon, 16 May 2022 13:32:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>, Sebastien Buisson <sbuisson@ddn.com>
Date: Mon, 16 May 2022 13:32:22 -0400
Message-Id: <1652722342-27606-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH v3] fscrypt: allow alternative bounce buffers
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
for the encrypted data. Lastly in performance measurements the
allocation of the bounce page incures a heavy cost. Using a page
from a predefined memory pool can lower the case. We can replace
the one off case of inplace encryption with the new general
functions.

Signed-Off-By: James Simmons <jsimmons@infradead.org>
---
 fs/crypto/crypto.c      | 34 +++++++++++++++++++---------------
 fs/ubifs/crypto.c       | 16 +++++++++-------
 include/linux/fscrypt.h | 31 ++++++++++++++++---------------
 3 files changed, 44 insertions(+), 37 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index e78be66bbf01..f241c697b1f9 100644
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
@@ -223,17 +224,18 @@ EXPORT_SYMBOL(fscrypt_encrypt_pagecache_blocks);
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
@@ -292,17 +295,18 @@ EXPORT_SYMBOL(fscrypt_decrypt_pagecache_blocks);
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
diff --git a/fs/ubifs/crypto.c b/fs/ubifs/crypto.c
index c57b46a352d8..c4cb1a8207e0 100644
--- a/fs/ubifs/crypto.c
+++ b/fs/ubifs/crypto.c
@@ -39,10 +39,11 @@ int ubifs_encrypt(const struct inode *inode, struct ubifs_data_node *dn,
 	if (pad_len != in_len)
 		memset(p + in_len, 0, pad_len - in_len);
 
-	err = fscrypt_encrypt_block_inplace(inode, virt_to_page(p), pad_len,
-					    offset_in_page(p), block, GFP_NOFS);
+	/* Encrypt inplace */
+	err = fscrypt_encrypt_page(inode, virt_to_page(p), virt_to_page(p),
+				   pad_len, offset_in_page(p), block, GFP_NOFS);
 	if (err) {
-		ubifs_err(c, "fscrypt_encrypt_block_inplace() failed: %d", err);
+		ubifs_err(c, "fscrypt_encrypt_page() failed: %d", err);
 		return err;
 	}
 	*out_len = pad_len;
@@ -64,11 +65,12 @@ int ubifs_decrypt(const struct inode *inode, struct ubifs_data_node *dn,
 	}
 
 	ubifs_assert(c, dlen <= UBIFS_BLOCK_SIZE);
-	err = fscrypt_decrypt_block_inplace(inode, virt_to_page(&dn->data),
-					    dlen, offset_in_page(&dn->data),
-					    block);
+	/* Decrypt inplace */
+	err = fscrypt_decrypt_page(inode, virt_to_page(&dn->data),
+				   virt_to_page(&dn->data), dlen,
+				   offset_in_page(&dn->data), block, GFP_NOFS);
 	if (err) {
-		ubifs_err(c, "fscrypt_decrypt_block_inplace() failed: %d", err);
+		ubifs_err(c, "fscrypt_decrypt_page() failed: %d", err);
 		return err;
 	}
 	*out_len = clen;
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index e60d57c99cb6..87efd61a764a 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -256,15 +256,16 @@ struct page *fscrypt_encrypt_pagecache_blocks(struct page *page,
 					      unsigned int len,
 					      unsigned int offs,
 					      gfp_t gfp_flags);
-int fscrypt_encrypt_block_inplace(const struct inode *inode, struct page *page,
-				  unsigned int len, unsigned int offs,
-				  u64 lblk_num, gfp_t gfp_flags);
+int fscrypt_encrypt_page(const struct inode *inode, struct page *src,
+			 struct page *dst, unsigned int len,
+			 unsigned int offs, u64 lblk_num, gfp_t gfp_flags);
 
 int fscrypt_decrypt_pagecache_blocks(struct page *page, unsigned int len,
 				     unsigned int offs);
-int fscrypt_decrypt_block_inplace(const struct inode *inode, struct page *page,
-				  unsigned int len, unsigned int offs,
-				  u64 lblk_num);
+
+int fscrypt_decrypt_page(const struct inode *inode, struct page *src,
+			 struct page *dst, unsigned int len,
+			 unsigned int offs, u64 lblk_num, gfp_t gfp_flags);
 
 static inline bool fscrypt_is_bounce_page(struct page *page)
 {
@@ -413,11 +414,11 @@ static inline struct page *fscrypt_encrypt_pagecache_blocks(struct page *page,
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
-static inline int fscrypt_encrypt_block_inplace(const struct inode *inode,
-						struct page *page,
-						unsigned int len,
-						unsigned int offs, u64 lblk_num,
-						gfp_t gfp_flags)
+static inline int fscrypt_encrypt_page(const struct inode *inode,
+				       struct page *src, struct page *dst,
+				       unsigned int len,
+				       unsigned int offs, u64 lblk_num,
+				       gfp_t gfp_flags)
 {
 	return -EOPNOTSUPP;
 }
@@ -429,10 +430,10 @@ static inline int fscrypt_decrypt_pagecache_blocks(struct page *page,
 	return -EOPNOTSUPP;
 }
 
-static inline int fscrypt_decrypt_block_inplace(const struct inode *inode,
-						struct page *page,
-						unsigned int len,
-						unsigned int offs, u64 lblk_num)
+static inline int fscrypt_decrypt_page(const struct inode *inode,
+				       struct page *src, struct page *dst,
+				       unsigned int len,
+				       unsigned int offs, u64 lblk_num)
 {
 	return -EOPNOTSUPP;
 }
-- 
2.34.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
