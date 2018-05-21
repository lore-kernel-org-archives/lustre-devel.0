From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 03/30] staging: lustre: move files out of
 lustre/lnet/libcfs/linux/
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731246.24196.8137393531590982778.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

There is no longer any value in having this separate
subdirectory, so promote the files in it.
Also tidy the Makefile a little to use the common "*-obj-y"
macro name.  This will allow individual files to be conditionally
compiled.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/Makefile        |   17 -
 .../lustre/lnet/libcfs/linux-crypto-adler.c        |  139 ++++++
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c  |  445 ++++++++++++++++++++
 drivers/staging/lustre/lnet/libcfs/linux-crypto.h  |   30 +
 drivers/staging/lustre/lnet/libcfs/linux-debug.c   |  144 ++++++
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   |  257 ++++++++++++
 .../lustre/lnet/libcfs/linux/linux-crypto-adler.c  |  139 ------
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |  445 --------------------
 .../lustre/lnet/libcfs/linux/linux-crypto.h        |   30 -
 .../staging/lustre/lnet/libcfs/linux/linux-debug.c |  144 ------
 .../lustre/lnet/libcfs/linux/linux-tracefile.c     |  257 ------------
 11 files changed, 1023 insertions(+), 1024 deletions(-)
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-crypto.c
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-crypto.h
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-debug.c
 create mode 100644 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-crypto-adler.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c

diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index e73515789a11..6335f909d22b 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -4,14 +4,13 @@ subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LNET) += libcfs.o
 
-libcfs-linux-objs := linux-tracefile.o linux-debug.o
-libcfs-linux-objs += linux-crypto.o
-libcfs-linux-objs += linux-crypto-adler.o
+libcfs-obj-y += linux-tracefile.o linux-debug.o
+libcfs-obj-y += linux-crypto.o
+libcfs-obj-y += linux-crypto-adler.o
 
-libcfs-linux-objs := $(addprefix linux/,$(libcfs-linux-objs))
+libcfs-obj-y += debug.o fail.o module.o tracefile.o
+libcfs-obj-y += libcfs_string.o hash.o
+libcfs-obj-y += libcfs_cpu.o
+libcfs-obj-y += libcfs_mem.o libcfs_lock.o
 
-libcfs-all-objs := debug.o fail.o module.o tracefile.o \
-		   libcfs_string.o hash.o \
-		   libcfs_cpu.o libcfs_mem.o libcfs_lock.o
-
-libcfs-objs := $(libcfs-linux-objs) $(libcfs-all-objs)
+libcfs-objs := $(libcfs-obj-y)
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c
new file mode 100644
index 000000000000..db81ed527452
--- /dev/null
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c
@@ -0,0 +1,139 @@
+// SPDX-License-Identifier: GPL-2.0
+/* GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see http://www.gnu.org/licenses
+ *
+ * Please  visit http://www.xyratex.com/contact if you need additional
+ * information or have any questions.
+ *
+ * GPL HEADER END
+ */
+
+/*
+ * Copyright 2012 Xyratex Technology Limited
+ */
+
+/*
+ * This is crypto api shash wrappers to zlib_adler32.
+ */
+
+#include <linux/module.h>
+#include <linux/zutil.h>
+#include <crypto/internal/hash.h>
+#include "linux-crypto.h"
+
+#define CHKSUM_BLOCK_SIZE	1
+#define CHKSUM_DIGEST_SIZE	4
+
+static int adler32_cra_init(struct crypto_tfm *tfm)
+{
+	u32 *key = crypto_tfm_ctx(tfm);
+
+	*key = 1;
+
+	return 0;
+}
+
+static int adler32_setkey(struct crypto_shash *hash, const u8 *key,
+			  unsigned int keylen)
+{
+	u32 *mctx = crypto_shash_ctx(hash);
+
+	if (keylen != sizeof(u32)) {
+		crypto_shash_set_flags(hash, CRYPTO_TFM_RES_BAD_KEY_LEN);
+		return -EINVAL;
+	}
+	*mctx = *(u32 *)key;
+	return 0;
+}
+
+static int adler32_init(struct shash_desc *desc)
+{
+	u32 *mctx = crypto_shash_ctx(desc->tfm);
+	u32 *cksump = shash_desc_ctx(desc);
+
+	*cksump = *mctx;
+
+	return 0;
+}
+
+static int adler32_update(struct shash_desc *desc, const u8 *data,
+			  unsigned int len)
+{
+	u32 *cksump = shash_desc_ctx(desc);
+
+	*cksump = zlib_adler32(*cksump, data, len);
+	return 0;
+}
+
+static int __adler32_finup(u32 *cksump, const u8 *data, unsigned int len,
+			   u8 *out)
+{
+	*(u32 *)out = zlib_adler32(*cksump, data, len);
+	return 0;
+}
+
+static int adler32_finup(struct shash_desc *desc, const u8 *data,
+			 unsigned int len, u8 *out)
+{
+	return __adler32_finup(shash_desc_ctx(desc), data, len, out);
+}
+
+static int adler32_final(struct shash_desc *desc, u8 *out)
+{
+	u32 *cksump = shash_desc_ctx(desc);
+
+	*(u32 *)out = *cksump;
+	return 0;
+}
+
+static int adler32_digest(struct shash_desc *desc, const u8 *data,
+			  unsigned int len, u8 *out)
+{
+	return __adler32_finup(crypto_shash_ctx(desc->tfm), data, len,
+				    out);
+}
+
+static struct shash_alg alg = {
+	.setkey		= adler32_setkey,
+	.init		= adler32_init,
+	.update		= adler32_update,
+	.final		= adler32_final,
+	.finup		= adler32_finup,
+	.digest		= adler32_digest,
+	.descsize	= sizeof(u32),
+	.digestsize	= CHKSUM_DIGEST_SIZE,
+	.base		= {
+		.cra_name		= "adler32",
+		.cra_driver_name	= "adler32-zlib",
+		.cra_priority		= 100,
+		.cra_flags		= CRYPTO_ALG_OPTIONAL_KEY,
+		.cra_blocksize		= CHKSUM_BLOCK_SIZE,
+		.cra_ctxsize		= sizeof(u32),
+		.cra_module		= THIS_MODULE,
+		.cra_init		= adler32_cra_init,
+	}
+};
+
+int cfs_crypto_adler32_register(void)
+{
+	return crypto_register_shash(&alg);
+}
+
+void cfs_crypto_adler32_unregister(void)
+{
+	crypto_unregister_shash(&alg);
+}
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
new file mode 100644
index 000000000000..18113335503b
--- /dev/null
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
@@ -0,0 +1,445 @@
+// SPDX-License-Identifier: GPL-2.0
+/* GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see http://www.gnu.org/licenses
+ *
+ * Please  visit http://www.xyratex.com/contact if you need additional
+ * information or have any questions.
+ *
+ * GPL HEADER END
+ */
+
+/*
+ * Copyright 2012 Xyratex Technology Limited
+ *
+ * Copyright (c) 2012, Intel Corporation.
+ */
+
+#include <crypto/hash.h>
+#include <linux/scatterlist.h>
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_crypto.h>
+#include "linux-crypto.h"
+
+/**
+ *  Array of hash algorithm speed in MByte per second
+ */
+static int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
+
+/**
+ * Initialize the state descriptor for the specified hash algorithm.
+ *
+ * An internal routine to allocate the hash-specific state in \a req for
+ * use with cfs_crypto_hash_digest() to compute the hash of a single message,
+ * though possibly in multiple chunks.  The descriptor internal state should
+ * be freed with cfs_crypto_hash_final().
+ *
+ * \param[in]	  hash_alg	hash algorithm id (CFS_HASH_ALG_*)
+ * \param[out]	  type		pointer to the hash description in hash_types[]
+ *				array
+ * \param[in,out] req		hash state descriptor to be initialized
+ * \param[in]	  key		initial hash value/state, NULL to use default
+ *				value
+ * \param[in]	  key_len	length of \a key
+ *
+ * \retval			0 on success
+ * \retval			negative errno on failure
+ */
+static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
+				 const struct cfs_crypto_hash_type **type,
+				 struct ahash_request **req,
+				 unsigned char *key,
+				 unsigned int key_len)
+{
+	struct crypto_ahash *tfm;
+	int err = 0;
+
+	*type = cfs_crypto_hash_type(hash_alg);
+
+	if (!*type) {
+		CWARN("Unsupported hash algorithm id = %d, max id is %d\n",
+		      hash_alg, CFS_HASH_ALG_MAX);
+		return -EINVAL;
+	}
+	tfm = crypto_alloc_ahash((*type)->cht_name, 0, CRYPTO_ALG_ASYNC);
+
+	if (IS_ERR(tfm)) {
+		CDEBUG(D_INFO, "Failed to alloc crypto hash %s\n",
+		       (*type)->cht_name);
+		return PTR_ERR(tfm);
+	}
+
+	*req = ahash_request_alloc(tfm, GFP_KERNEL);
+	if (!*req) {
+		CDEBUG(D_INFO, "Failed to alloc ahash_request for %s\n",
+		       (*type)->cht_name);
+		crypto_free_ahash(tfm);
+		return -ENOMEM;
+	}
+
+	ahash_request_set_callback(*req, 0, NULL, NULL);
+
+	if (key)
+		err = crypto_ahash_setkey(tfm, key, key_len);
+	else if ((*type)->cht_key)
+		err = crypto_ahash_setkey(tfm,
+					  (unsigned char *)&((*type)->cht_key),
+					  (*type)->cht_size);
+
+	if (err) {
+		ahash_request_free(*req);
+		crypto_free_ahash(tfm);
+		return err;
+	}
+
+	CDEBUG(D_INFO, "Using crypto hash: %s (%s) speed %d MB/s\n",
+	       crypto_ahash_alg_name(tfm), crypto_ahash_driver_name(tfm),
+	       cfs_crypto_hash_speeds[hash_alg]);
+
+	err = crypto_ahash_init(*req);
+	if (err) {
+		ahash_request_free(*req);
+		crypto_free_ahash(tfm);
+	}
+	return err;
+}
+
+/**
+ * Calculate hash digest for the passed buffer.
+ *
+ * This should be used when computing the hash on a single contiguous buffer.
+ * It combines the hash initialization, computation, and cleanup.
+ *
+ * \param[in]	  hash_alg	id of hash algorithm (CFS_HASH_ALG_*)
+ * \param[in]	  buf		data buffer on which to compute hash
+ * \param[in]	  buf_len	length of \a buf in bytes
+ * \param[in]	  key		initial value/state for algorithm,
+ *				if \a key = NULL use default initial value
+ * \param[in]	  key_len	length of \a key in bytes
+ * \param[out]	  hash		pointer to computed hash value,
+ *				if \a hash = NULL then \a hash_len is to digest
+ *				size in bytes, retval -ENOSPC
+ * \param[in,out] hash_len	size of \a hash buffer
+ *
+ * \retval -EINVAL		\a buf, \a buf_len, \a hash_len,
+ *				\a hash_alg invalid
+ * \retval -ENOENT		\a hash_alg is unsupported
+ * \retval -ENOSPC		\a hash is NULL, or \a hash_len less than
+ *				digest size
+ * \retval			0 for success
+ * \retval			negative errno for other errors from lower
+ *				layers.
+ */
+int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
+			   const void *buf, unsigned int buf_len,
+			   unsigned char *key, unsigned int key_len,
+			   unsigned char *hash, unsigned int *hash_len)
+{
+	struct scatterlist sl;
+	struct ahash_request *req;
+	int err;
+	const struct cfs_crypto_hash_type *type;
+
+	if (!buf || !buf_len || !hash_len)
+		return -EINVAL;
+
+	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
+	if (err)
+		return err;
+
+	if (!hash || *hash_len < type->cht_size) {
+		*hash_len = type->cht_size;
+		crypto_free_ahash(crypto_ahash_reqtfm(req));
+		ahash_request_free(req);
+		return -ENOSPC;
+	}
+	sg_init_one(&sl, buf, buf_len);
+
+	ahash_request_set_crypt(req, &sl, hash, sl.length);
+	err = crypto_ahash_digest(req);
+	crypto_free_ahash(crypto_ahash_reqtfm(req));
+	ahash_request_free(req);
+
+	return err;
+}
+EXPORT_SYMBOL(cfs_crypto_hash_digest);
+
+/**
+ * Allocate and initialize descriptor for hash algorithm.
+ *
+ * This should be used to initialize a hash descriptor for multiple calls
+ * to a single hash function when computing the hash across multiple
+ * separate buffers or pages using cfs_crypto_hash_update{,_page}().
+ *
+ * The hash descriptor should be freed with cfs_crypto_hash_final().
+ *
+ * \param[in] hash_alg	algorithm id (CFS_HASH_ALG_*)
+ * \param[in] key	initial value/state for algorithm, if \a key = NULL
+ *			use default initial value
+ * \param[in] key_len	length of \a key in bytes
+ *
+ * \retval		pointer to descriptor of hash instance
+ * \retval		ERR_PTR(errno) in case of error
+ */
+struct ahash_request *
+cfs_crypto_hash_init(enum cfs_crypto_hash_alg hash_alg,
+		     unsigned char *key, unsigned int key_len)
+{
+	struct ahash_request *req;
+	int err;
+	const struct cfs_crypto_hash_type *type;
+
+	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
+
+	if (err)
+		return ERR_PTR(err);
+	return req;
+}
+EXPORT_SYMBOL(cfs_crypto_hash_init);
+
+/**
+ * Update hash digest computed on data within the given \a page
+ *
+ * \param[in] hreq	hash state descriptor
+ * \param[in] page	data page on which to compute the hash
+ * \param[in] offset	offset within \a page at which to start hash
+ * \param[in] len	length of data on which to compute hash
+ *
+ * \retval		0 for success
+ * \retval		negative errno on failure
+ */
+int cfs_crypto_hash_update_page(struct ahash_request *req,
+				struct page *page, unsigned int offset,
+				unsigned int len)
+{
+	struct scatterlist sl;
+
+	sg_init_table(&sl, 1);
+	sg_set_page(&sl, page, len, offset & ~PAGE_MASK);
+
+	ahash_request_set_crypt(req, &sl, NULL, sl.length);
+	return crypto_ahash_update(req);
+}
+EXPORT_SYMBOL(cfs_crypto_hash_update_page);
+
+/**
+ * Update hash digest computed on the specified data
+ *
+ * \param[in] req	hash state descriptor
+ * \param[in] buf	data buffer on which to compute the hash
+ * \param[in] buf_len	length of \buf on which to compute hash
+ *
+ * \retval		0 for success
+ * \retval		negative errno on failure
+ */
+int cfs_crypto_hash_update(struct ahash_request *req,
+			   const void *buf, unsigned int buf_len)
+{
+	struct scatterlist sl;
+
+	sg_init_one(&sl, buf, buf_len);
+
+	ahash_request_set_crypt(req, &sl, NULL, sl.length);
+	return crypto_ahash_update(req);
+}
+EXPORT_SYMBOL(cfs_crypto_hash_update);
+
+/**
+ * Finish hash calculation, copy hash digest to buffer, clean up hash descriptor
+ *
+ * \param[in]	  req		hash descriptor
+ * \param[out]	  hash		pointer to hash buffer to store hash digest
+ * \param[in,out] hash_len	pointer to hash buffer size, if \a req = NULL
+ *				only free \a req instead of computing the hash
+ *
+ * \retval	0 for success
+ * \retval	-EOVERFLOW if hash_len is too small for the hash digest
+ * \retval	negative errno for other errors from lower layers
+ */
+int cfs_crypto_hash_final(struct ahash_request *req,
+			  unsigned char *hash, unsigned int *hash_len)
+{
+	int err;
+	int size = crypto_ahash_digestsize(crypto_ahash_reqtfm(req));
+
+	if (!hash || !hash_len) {
+		err = 0;
+		goto free_ahash;
+	}
+	if (*hash_len < size) {
+		err = -EOVERFLOW;
+		goto free_ahash;
+	}
+
+	ahash_request_set_crypt(req, NULL, hash, 0);
+	err = crypto_ahash_final(req);
+	if (!err)
+		*hash_len = size;
+free_ahash:
+	crypto_free_ahash(crypto_ahash_reqtfm(req));
+	ahash_request_free(req);
+	return err;
+}
+EXPORT_SYMBOL(cfs_crypto_hash_final);
+
+/**
+ * Compute the speed of specified hash function
+ *
+ * Run a speed test on the given hash algorithm on buffer of the given size.
+ * The speed is stored internally in the cfs_crypto_hash_speeds[] array, and
+ * is available through the cfs_crypto_hash_speed() function.
+ *
+ * \param[in] hash_alg	hash algorithm id (CFS_HASH_ALG_*)
+ * \param[in] buf	data buffer on which to compute the hash
+ * \param[in] buf_len	length of \buf on which to compute hash
+ */
+static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
+{
+	int buf_len = max(PAGE_SIZE, 1048576UL);
+	void *buf;
+	unsigned long start, end;
+	int bcount, err = 0;
+	struct page *page;
+	unsigned char hash[CFS_CRYPTO_HASH_DIGESTSIZE_MAX];
+	unsigned int hash_len = sizeof(hash);
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page) {
+		err = -ENOMEM;
+		goto out_err;
+	}
+
+	buf = kmap(page);
+	memset(buf, 0xAD, PAGE_SIZE);
+	kunmap(page);
+
+	for (start = jiffies, end = start + msecs_to_jiffies(MSEC_PER_SEC),
+	     bcount = 0; time_before(jiffies, end); bcount++) {
+		struct ahash_request *hdesc;
+		int i;
+
+		hdesc = cfs_crypto_hash_init(hash_alg, NULL, 0);
+		if (IS_ERR(hdesc)) {
+			err = PTR_ERR(hdesc);
+			break;
+		}
+
+		for (i = 0; i < buf_len / PAGE_SIZE; i++) {
+			err = cfs_crypto_hash_update_page(hdesc, page, 0,
+							  PAGE_SIZE);
+			if (err)
+				break;
+		}
+
+		err = cfs_crypto_hash_final(hdesc, hash, &hash_len);
+		if (err)
+			break;
+	}
+	end = jiffies;
+	__free_page(page);
+out_err:
+	if (err) {
+		cfs_crypto_hash_speeds[hash_alg] = err;
+		CDEBUG(D_INFO, "Crypto hash algorithm %s test error: rc = %d\n",
+		       cfs_crypto_hash_name(hash_alg), err);
+	} else {
+		unsigned long tmp;
+
+		tmp = ((bcount * buf_len / jiffies_to_msecs(end - start)) *
+		       1000) / (1024 * 1024);
+		cfs_crypto_hash_speeds[hash_alg] = (int)tmp;
+		CDEBUG(D_CONFIG, "Crypto hash algorithm %s speed = %d MB/s\n",
+		       cfs_crypto_hash_name(hash_alg),
+		       cfs_crypto_hash_speeds[hash_alg]);
+	}
+}
+
+/**
+ * hash speed in Mbytes per second for valid hash algorithm
+ *
+ * Return the performance of the specified \a hash_alg that was previously
+ * computed using cfs_crypto_performance_test().
+ *
+ * \param[in] hash_alg	hash algorithm id (CFS_HASH_ALG_*)
+ *
+ * \retval		positive speed of the hash function in MB/s
+ * \retval		-ENOENT if \a hash_alg is unsupported
+ * \retval		negative errno if \a hash_alg speed is unavailable
+ */
+int cfs_crypto_hash_speed(enum cfs_crypto_hash_alg hash_alg)
+{
+	if (hash_alg < CFS_HASH_ALG_MAX)
+		return cfs_crypto_hash_speeds[hash_alg];
+	return -ENOENT;
+}
+EXPORT_SYMBOL(cfs_crypto_hash_speed);
+
+/**
+ * Run the performance test for all hash algorithms.
+ *
+ * Run the cfs_crypto_performance_test() benchmark for all of the available
+ * hash functions using a 1MB buffer size.  This is a reasonable buffer size
+ * for Lustre RPCs, even if the actual RPC size is larger or smaller.
+ *
+ * Since the setup cost and computation speed of various hash algorithms is
+ * a function of the buffer size (and possibly internal contention of offload
+ * engines), this speed only represents an estimate of the actual speed under
+ * actual usage, but is reasonable for comparing available algorithms.
+ *
+ * The actual speeds are available via cfs_crypto_hash_speed() for later
+ * comparison.
+ *
+ * \retval	0 on success
+ * \retval	-ENOMEM if no memory is available for test buffer
+ */
+static int cfs_crypto_test_hashes(void)
+{
+	enum cfs_crypto_hash_alg hash_alg;
+
+	for (hash_alg = 0; hash_alg < CFS_HASH_ALG_MAX; hash_alg++)
+		cfs_crypto_performance_test(hash_alg);
+
+	return 0;
+}
+
+static int adler32;
+
+/**
+ * Register available hash functions
+ *
+ * \retval	0
+ */
+int cfs_crypto_register(void)
+{
+	request_module("crc32c");
+
+	if (cfs_crypto_adler32_register() == 0)
+		adler32 = 1;
+
+	/* check all algorithms and do performance test */
+	cfs_crypto_test_hashes();
+	return 0;
+}
+
+/**
+ * Unregister previously registered hash functions
+ */
+void cfs_crypto_unregister(void)
+{
+	if (adler32)
+		cfs_crypto_adler32_unregister();
+	adler32 = 0;
+}
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.h b/drivers/staging/lustre/lnet/libcfs/linux-crypto.h
new file mode 100644
index 000000000000..5616e9ea1450
--- /dev/null
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto.h
@@ -0,0 +1,30 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see http://www.gnu.org/licenses
+ *
+ * Please  visit http://www.xyratex.com/contact if you need additional
+ * information or have any questions.
+ *
+ * GPL HEADER END
+ */
+
+/**
+ * Functions for start/stop shash adler32 algorithm.
+ */
+int cfs_crypto_adler32_register(void);
+void cfs_crypto_adler32_unregister(void);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux-debug.c
new file mode 100644
index 000000000000..2ca385cbea92
--- /dev/null
+++ b/drivers/staging/lustre/lnet/libcfs/linux-debug.c
@@ -0,0 +1,144 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2012, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * libcfs/libcfs/linux/linux-debug.c
+ *
+ * Author: Phil Schwan <phil@clusterfs.com>
+ */
+
+#include <linux/module.h>
+#include <linux/kmod.h>
+#include <linux/notifier.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <linux/stat.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/interrupt.h>
+#include <linux/completion.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+
+# define DEBUG_SUBSYSTEM S_LNET
+
+#include <linux/libcfs/libcfs.h>
+
+#include "tracefile.h"
+
+#include <linux/kallsyms.h>
+
+char lnet_debug_log_upcall[1024] = "/usr/lib/lustre/lnet_debug_log_upcall";
+
+/**
+ * Upcall function once a Lustre log has been dumped.
+ *
+ * \param file  path of the dumped log
+ */
+void libcfs_run_debug_log_upcall(char *file)
+{
+	char *argv[3];
+	int rc;
+	static const char * const envp[] = {
+		"HOME=/",
+		"PATH=/sbin:/bin:/usr/sbin:/usr/bin",
+		NULL
+	};
+
+	argv[0] = lnet_debug_log_upcall;
+
+	LASSERTF(file, "called on a null filename\n");
+	argv[1] = file; /* only need to pass the path of the file */
+
+	argv[2] = NULL;
+
+	rc = call_usermodehelper(argv[0], argv, (char **)envp, 1);
+	if (rc < 0 && rc != -ENOENT) {
+		CERROR("Error %d invoking LNET debug log upcall %s %s; check /sys/kernel/debug/lnet/debug_log_upcall\n",
+		       rc, argv[0], argv[1]);
+	} else {
+		CDEBUG(D_HA, "Invoked LNET debug log upcall %s %s\n",
+		       argv[0], argv[1]);
+	}
+}
+
+/* coverity[+kill] */
+void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
+{
+	libcfs_catastrophe = 1;
+	libcfs_debug_msg(msgdata, "LBUG\n");
+
+	if (in_interrupt()) {
+		panic("LBUG in interrupt.\n");
+		/* not reached */
+	}
+
+	dump_stack();
+	if (!libcfs_panic_on_lbug)
+		libcfs_debug_dumplog();
+	if (libcfs_panic_on_lbug)
+		panic("LBUG");
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	while (1)
+		schedule();
+}
+EXPORT_SYMBOL(lbug_with_loc);
+
+static int panic_notifier(struct notifier_block *self, unsigned long unused1,
+			  void *unused2)
+{
+	if (libcfs_panic_in_progress)
+		return 0;
+
+	libcfs_panic_in_progress = 1;
+	mb();
+
+	return 0;
+}
+
+static struct notifier_block libcfs_panic_notifier = {
+	.notifier_call	= panic_notifier,
+	.next		= NULL,
+	.priority	= 10000,
+};
+
+void libcfs_register_panic_notifier(void)
+{
+	atomic_notifier_chain_register(&panic_notifier_list,
+				       &libcfs_panic_notifier);
+}
+
+void libcfs_unregister_panic_notifier(void)
+{
+	atomic_notifier_chain_unregister(&panic_notifier_list,
+					 &libcfs_panic_notifier);
+}
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
new file mode 100644
index 000000000000..3366ae6411ee
--- /dev/null
+++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
@@ -0,0 +1,257 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2012, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+
+#define DEBUG_SUBSYSTEM S_LNET
+#define LUSTRE_TRACEFILE_PRIVATE
+
+#include <linux/libcfs/libcfs.h>
+#include "tracefile.h"
+
+/* percents to share the total debug memory for each type */
+static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
+	80,  /* 80% pages for CFS_TCD_TYPE_PROC */
+	10,  /* 10% pages for CFS_TCD_TYPE_SOFTIRQ */
+	10   /* 10% pages for CFS_TCD_TYPE_IRQ */
+};
+
+char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
+
+static DECLARE_RWSEM(cfs_tracefile_sem);
+
+int cfs_tracefile_init_arch(void)
+{
+	int i;
+	int j;
+	struct cfs_trace_cpu_data *tcd;
+
+	/* initialize trace_data */
+	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
+	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
+		cfs_trace_data[i] =
+			kmalloc_array(num_possible_cpus(),
+				      sizeof(union cfs_trace_data_union),
+				      GFP_KERNEL);
+		if (!cfs_trace_data[i])
+			goto out;
+	}
+
+	/* arch related info initialized */
+	cfs_tcd_for_each(tcd, i, j) {
+		spin_lock_init(&tcd->tcd_lock);
+		tcd->tcd_pages_factor = pages_factor[i];
+		tcd->tcd_type = i;
+		tcd->tcd_cpu = j;
+	}
+
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			cfs_trace_console_buffers[i][j] =
+				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
+					GFP_KERNEL);
+
+			if (!cfs_trace_console_buffers[i][j])
+				goto out;
+		}
+
+	return 0;
+
+out:
+	cfs_tracefile_fini_arch();
+	pr_err("lnet: Not enough memory\n");
+	return -ENOMEM;
+}
+
+void cfs_tracefile_fini_arch(void)
+{
+	int i;
+	int j;
+
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			kfree(cfs_trace_console_buffers[i][j]);
+			cfs_trace_console_buffers[i][j] = NULL;
+		}
+
+	for (i = 0; cfs_trace_data[i]; i++) {
+		kfree(cfs_trace_data[i]);
+		cfs_trace_data[i] = NULL;
+	}
+}
+
+void cfs_tracefile_read_lock(void)
+{
+	down_read(&cfs_tracefile_sem);
+}
+
+void cfs_tracefile_read_unlock(void)
+{
+	up_read(&cfs_tracefile_sem);
+}
+
+void cfs_tracefile_write_lock(void)
+{
+	down_write(&cfs_tracefile_sem);
+}
+
+void cfs_tracefile_write_unlock(void)
+{
+	up_write(&cfs_tracefile_sem);
+}
+
+enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
+{
+	if (in_irq())
+		return CFS_TCD_TYPE_IRQ;
+	if (in_softirq())
+		return CFS_TCD_TYPE_SOFTIRQ;
+	return CFS_TCD_TYPE_PROC;
+}
+
+/*
+ * The walking argument indicates the locking comes from all tcd types
+ * iterator and we must lock it and dissable local irqs to avoid deadlocks
+ * with other interrupt locks that might be happening. See LU-1311
+ * for details.
+ */
+int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
+	__acquires(&tcd->tc_lock)
+{
+	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
+	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
+		spin_lock_irqsave(&tcd->tcd_lock, tcd->tcd_lock_flags);
+	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
+		spin_lock_bh(&tcd->tcd_lock);
+	else if (unlikely(walking))
+		spin_lock_irq(&tcd->tcd_lock);
+	else
+		spin_lock(&tcd->tcd_lock);
+	return 1;
+}
+
+void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
+	__releases(&tcd->tcd_lock)
+{
+	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
+	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
+		spin_unlock_irqrestore(&tcd->tcd_lock, tcd->tcd_lock_flags);
+	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
+		spin_unlock_bh(&tcd->tcd_lock);
+	else if (unlikely(walking))
+		spin_unlock_irq(&tcd->tcd_lock);
+	else
+		spin_unlock(&tcd->tcd_lock);
+}
+
+void
+cfs_set_ptldebug_header(struct ptldebug_header *header,
+			struct libcfs_debug_msg_data *msgdata,
+			unsigned long stack)
+{
+	struct timespec64 ts;
+
+	ktime_get_real_ts64(&ts);
+
+	header->ph_subsys = msgdata->msg_subsys;
+	header->ph_mask = msgdata->msg_mask;
+	header->ph_cpu_id = smp_processor_id();
+	header->ph_type = cfs_trace_buf_idx_get();
+	/* y2038 safe since all user space treats this as unsigned, but
+	 * will overflow in 2106
+	 */
+	header->ph_sec = (u32)ts.tv_sec;
+	header->ph_usec = ts.tv_nsec / NSEC_PER_USEC;
+	header->ph_stack = stack;
+	header->ph_pid = current->pid;
+	header->ph_line_num = msgdata->msg_line;
+	header->ph_extern_pid = 0;
+}
+
+static char *
+dbghdr_to_err_string(struct ptldebug_header *hdr)
+{
+	switch (hdr->ph_subsys) {
+	case S_LND:
+	case S_LNET:
+		return "LNetError";
+	default:
+		return "LustreError";
+	}
+}
+
+static char *
+dbghdr_to_info_string(struct ptldebug_header *hdr)
+{
+	switch (hdr->ph_subsys) {
+	case S_LND:
+	case S_LNET:
+		return "LNet";
+	default:
+		return "Lustre";
+	}
+}
+
+void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
+			  const char *buf, int len, const char *file,
+			  const char *fn)
+{
+	char *prefix = "Lustre", *ptype = NULL;
+
+	if (mask & D_EMERG) {
+		prefix = dbghdr_to_err_string(hdr);
+		ptype = KERN_EMERG;
+	} else if (mask & D_ERROR) {
+		prefix = dbghdr_to_err_string(hdr);
+		ptype = KERN_ERR;
+	} else if (mask & D_WARNING) {
+		prefix = dbghdr_to_info_string(hdr);
+		ptype = KERN_WARNING;
+	} else if (mask & (D_CONSOLE | libcfs_printk)) {
+		prefix = dbghdr_to_info_string(hdr);
+		ptype = KERN_INFO;
+	}
+
+	if (mask & D_CONSOLE) {
+		pr_info("%s%s: %.*s", ptype, prefix, len, buf);
+	} else {
+		pr_info("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
+			hdr->ph_pid, hdr->ph_extern_pid, file,
+			hdr->ph_line_num, fn, len, buf);
+	}
+}
+
+int cfs_trace_max_debug_mb(void)
+{
+	int  total_mb = (totalram_pages >> (20 - PAGE_SHIFT));
+
+	return max(512, (total_mb * 80) / 100);
+}
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto-adler.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto-adler.c
deleted file mode 100644
index db81ed527452..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto-adler.c
+++ /dev/null
@@ -1,139 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/* GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see http://www.gnu.org/licenses
- *
- * Please  visit http://www.xyratex.com/contact if you need additional
- * information or have any questions.
- *
- * GPL HEADER END
- */
-
-/*
- * Copyright 2012 Xyratex Technology Limited
- */
-
-/*
- * This is crypto api shash wrappers to zlib_adler32.
- */
-
-#include <linux/module.h>
-#include <linux/zutil.h>
-#include <crypto/internal/hash.h>
-#include "linux-crypto.h"
-
-#define CHKSUM_BLOCK_SIZE	1
-#define CHKSUM_DIGEST_SIZE	4
-
-static int adler32_cra_init(struct crypto_tfm *tfm)
-{
-	u32 *key = crypto_tfm_ctx(tfm);
-
-	*key = 1;
-
-	return 0;
-}
-
-static int adler32_setkey(struct crypto_shash *hash, const u8 *key,
-			  unsigned int keylen)
-{
-	u32 *mctx = crypto_shash_ctx(hash);
-
-	if (keylen != sizeof(u32)) {
-		crypto_shash_set_flags(hash, CRYPTO_TFM_RES_BAD_KEY_LEN);
-		return -EINVAL;
-	}
-	*mctx = *(u32 *)key;
-	return 0;
-}
-
-static int adler32_init(struct shash_desc *desc)
-{
-	u32 *mctx = crypto_shash_ctx(desc->tfm);
-	u32 *cksump = shash_desc_ctx(desc);
-
-	*cksump = *mctx;
-
-	return 0;
-}
-
-static int adler32_update(struct shash_desc *desc, const u8 *data,
-			  unsigned int len)
-{
-	u32 *cksump = shash_desc_ctx(desc);
-
-	*cksump = zlib_adler32(*cksump, data, len);
-	return 0;
-}
-
-static int __adler32_finup(u32 *cksump, const u8 *data, unsigned int len,
-			   u8 *out)
-{
-	*(u32 *)out = zlib_adler32(*cksump, data, len);
-	return 0;
-}
-
-static int adler32_finup(struct shash_desc *desc, const u8 *data,
-			 unsigned int len, u8 *out)
-{
-	return __adler32_finup(shash_desc_ctx(desc), data, len, out);
-}
-
-static int adler32_final(struct shash_desc *desc, u8 *out)
-{
-	u32 *cksump = shash_desc_ctx(desc);
-
-	*(u32 *)out = *cksump;
-	return 0;
-}
-
-static int adler32_digest(struct shash_desc *desc, const u8 *data,
-			  unsigned int len, u8 *out)
-{
-	return __adler32_finup(crypto_shash_ctx(desc->tfm), data, len,
-				    out);
-}
-
-static struct shash_alg alg = {
-	.setkey		= adler32_setkey,
-	.init		= adler32_init,
-	.update		= adler32_update,
-	.final		= adler32_final,
-	.finup		= adler32_finup,
-	.digest		= adler32_digest,
-	.descsize	= sizeof(u32),
-	.digestsize	= CHKSUM_DIGEST_SIZE,
-	.base		= {
-		.cra_name		= "adler32",
-		.cra_driver_name	= "adler32-zlib",
-		.cra_priority		= 100,
-		.cra_flags		= CRYPTO_ALG_OPTIONAL_KEY,
-		.cra_blocksize		= CHKSUM_BLOCK_SIZE,
-		.cra_ctxsize		= sizeof(u32),
-		.cra_module		= THIS_MODULE,
-		.cra_init		= adler32_cra_init,
-	}
-};
-
-int cfs_crypto_adler32_register(void)
-{
-	return crypto_register_shash(&alg);
-}
-
-void cfs_crypto_adler32_unregister(void)
-{
-	crypto_unregister_shash(&alg);
-}
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
deleted file mode 100644
index 18113335503b..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ /dev/null
@@ -1,445 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/* GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see http://www.gnu.org/licenses
- *
- * Please  visit http://www.xyratex.com/contact if you need additional
- * information or have any questions.
- *
- * GPL HEADER END
- */
-
-/*
- * Copyright 2012 Xyratex Technology Limited
- *
- * Copyright (c) 2012, Intel Corporation.
- */
-
-#include <crypto/hash.h>
-#include <linux/scatterlist.h>
-#include <linux/libcfs/libcfs.h>
-#include <linux/libcfs/libcfs_crypto.h>
-#include "linux-crypto.h"
-
-/**
- *  Array of hash algorithm speed in MByte per second
- */
-static int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
-
-/**
- * Initialize the state descriptor for the specified hash algorithm.
- *
- * An internal routine to allocate the hash-specific state in \a req for
- * use with cfs_crypto_hash_digest() to compute the hash of a single message,
- * though possibly in multiple chunks.  The descriptor internal state should
- * be freed with cfs_crypto_hash_final().
- *
- * \param[in]	  hash_alg	hash algorithm id (CFS_HASH_ALG_*)
- * \param[out]	  type		pointer to the hash description in hash_types[]
- *				array
- * \param[in,out] req		hash state descriptor to be initialized
- * \param[in]	  key		initial hash value/state, NULL to use default
- *				value
- * \param[in]	  key_len	length of \a key
- *
- * \retval			0 on success
- * \retval			negative errno on failure
- */
-static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
-				 const struct cfs_crypto_hash_type **type,
-				 struct ahash_request **req,
-				 unsigned char *key,
-				 unsigned int key_len)
-{
-	struct crypto_ahash *tfm;
-	int err = 0;
-
-	*type = cfs_crypto_hash_type(hash_alg);
-
-	if (!*type) {
-		CWARN("Unsupported hash algorithm id = %d, max id is %d\n",
-		      hash_alg, CFS_HASH_ALG_MAX);
-		return -EINVAL;
-	}
-	tfm = crypto_alloc_ahash((*type)->cht_name, 0, CRYPTO_ALG_ASYNC);
-
-	if (IS_ERR(tfm)) {
-		CDEBUG(D_INFO, "Failed to alloc crypto hash %s\n",
-		       (*type)->cht_name);
-		return PTR_ERR(tfm);
-	}
-
-	*req = ahash_request_alloc(tfm, GFP_KERNEL);
-	if (!*req) {
-		CDEBUG(D_INFO, "Failed to alloc ahash_request for %s\n",
-		       (*type)->cht_name);
-		crypto_free_ahash(tfm);
-		return -ENOMEM;
-	}
-
-	ahash_request_set_callback(*req, 0, NULL, NULL);
-
-	if (key)
-		err = crypto_ahash_setkey(tfm, key, key_len);
-	else if ((*type)->cht_key)
-		err = crypto_ahash_setkey(tfm,
-					  (unsigned char *)&((*type)->cht_key),
-					  (*type)->cht_size);
-
-	if (err) {
-		ahash_request_free(*req);
-		crypto_free_ahash(tfm);
-		return err;
-	}
-
-	CDEBUG(D_INFO, "Using crypto hash: %s (%s) speed %d MB/s\n",
-	       crypto_ahash_alg_name(tfm), crypto_ahash_driver_name(tfm),
-	       cfs_crypto_hash_speeds[hash_alg]);
-
-	err = crypto_ahash_init(*req);
-	if (err) {
-		ahash_request_free(*req);
-		crypto_free_ahash(tfm);
-	}
-	return err;
-}
-
-/**
- * Calculate hash digest for the passed buffer.
- *
- * This should be used when computing the hash on a single contiguous buffer.
- * It combines the hash initialization, computation, and cleanup.
- *
- * \param[in]	  hash_alg	id of hash algorithm (CFS_HASH_ALG_*)
- * \param[in]	  buf		data buffer on which to compute hash
- * \param[in]	  buf_len	length of \a buf in bytes
- * \param[in]	  key		initial value/state for algorithm,
- *				if \a key = NULL use default initial value
- * \param[in]	  key_len	length of \a key in bytes
- * \param[out]	  hash		pointer to computed hash value,
- *				if \a hash = NULL then \a hash_len is to digest
- *				size in bytes, retval -ENOSPC
- * \param[in,out] hash_len	size of \a hash buffer
- *
- * \retval -EINVAL		\a buf, \a buf_len, \a hash_len,
- *				\a hash_alg invalid
- * \retval -ENOENT		\a hash_alg is unsupported
- * \retval -ENOSPC		\a hash is NULL, or \a hash_len less than
- *				digest size
- * \retval			0 for success
- * \retval			negative errno for other errors from lower
- *				layers.
- */
-int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
-			   const void *buf, unsigned int buf_len,
-			   unsigned char *key, unsigned int key_len,
-			   unsigned char *hash, unsigned int *hash_len)
-{
-	struct scatterlist sl;
-	struct ahash_request *req;
-	int err;
-	const struct cfs_crypto_hash_type *type;
-
-	if (!buf || !buf_len || !hash_len)
-		return -EINVAL;
-
-	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
-	if (err)
-		return err;
-
-	if (!hash || *hash_len < type->cht_size) {
-		*hash_len = type->cht_size;
-		crypto_free_ahash(crypto_ahash_reqtfm(req));
-		ahash_request_free(req);
-		return -ENOSPC;
-	}
-	sg_init_one(&sl, buf, buf_len);
-
-	ahash_request_set_crypt(req, &sl, hash, sl.length);
-	err = crypto_ahash_digest(req);
-	crypto_free_ahash(crypto_ahash_reqtfm(req));
-	ahash_request_free(req);
-
-	return err;
-}
-EXPORT_SYMBOL(cfs_crypto_hash_digest);
-
-/**
- * Allocate and initialize descriptor for hash algorithm.
- *
- * This should be used to initialize a hash descriptor for multiple calls
- * to a single hash function when computing the hash across multiple
- * separate buffers or pages using cfs_crypto_hash_update{,_page}().
- *
- * The hash descriptor should be freed with cfs_crypto_hash_final().
- *
- * \param[in] hash_alg	algorithm id (CFS_HASH_ALG_*)
- * \param[in] key	initial value/state for algorithm, if \a key = NULL
- *			use default initial value
- * \param[in] key_len	length of \a key in bytes
- *
- * \retval		pointer to descriptor of hash instance
- * \retval		ERR_PTR(errno) in case of error
- */
-struct ahash_request *
-cfs_crypto_hash_init(enum cfs_crypto_hash_alg hash_alg,
-		     unsigned char *key, unsigned int key_len)
-{
-	struct ahash_request *req;
-	int err;
-	const struct cfs_crypto_hash_type *type;
-
-	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
-
-	if (err)
-		return ERR_PTR(err);
-	return req;
-}
-EXPORT_SYMBOL(cfs_crypto_hash_init);
-
-/**
- * Update hash digest computed on data within the given \a page
- *
- * \param[in] hreq	hash state descriptor
- * \param[in] page	data page on which to compute the hash
- * \param[in] offset	offset within \a page at which to start hash
- * \param[in] len	length of data on which to compute hash
- *
- * \retval		0 for success
- * \retval		negative errno on failure
- */
-int cfs_crypto_hash_update_page(struct ahash_request *req,
-				struct page *page, unsigned int offset,
-				unsigned int len)
-{
-	struct scatterlist sl;
-
-	sg_init_table(&sl, 1);
-	sg_set_page(&sl, page, len, offset & ~PAGE_MASK);
-
-	ahash_request_set_crypt(req, &sl, NULL, sl.length);
-	return crypto_ahash_update(req);
-}
-EXPORT_SYMBOL(cfs_crypto_hash_update_page);
-
-/**
- * Update hash digest computed on the specified data
- *
- * \param[in] req	hash state descriptor
- * \param[in] buf	data buffer on which to compute the hash
- * \param[in] buf_len	length of \buf on which to compute hash
- *
- * \retval		0 for success
- * \retval		negative errno on failure
- */
-int cfs_crypto_hash_update(struct ahash_request *req,
-			   const void *buf, unsigned int buf_len)
-{
-	struct scatterlist sl;
-
-	sg_init_one(&sl, buf, buf_len);
-
-	ahash_request_set_crypt(req, &sl, NULL, sl.length);
-	return crypto_ahash_update(req);
-}
-EXPORT_SYMBOL(cfs_crypto_hash_update);
-
-/**
- * Finish hash calculation, copy hash digest to buffer, clean up hash descriptor
- *
- * \param[in]	  req		hash descriptor
- * \param[out]	  hash		pointer to hash buffer to store hash digest
- * \param[in,out] hash_len	pointer to hash buffer size, if \a req = NULL
- *				only free \a req instead of computing the hash
- *
- * \retval	0 for success
- * \retval	-EOVERFLOW if hash_len is too small for the hash digest
- * \retval	negative errno for other errors from lower layers
- */
-int cfs_crypto_hash_final(struct ahash_request *req,
-			  unsigned char *hash, unsigned int *hash_len)
-{
-	int err;
-	int size = crypto_ahash_digestsize(crypto_ahash_reqtfm(req));
-
-	if (!hash || !hash_len) {
-		err = 0;
-		goto free_ahash;
-	}
-	if (*hash_len < size) {
-		err = -EOVERFLOW;
-		goto free_ahash;
-	}
-
-	ahash_request_set_crypt(req, NULL, hash, 0);
-	err = crypto_ahash_final(req);
-	if (!err)
-		*hash_len = size;
-free_ahash:
-	crypto_free_ahash(crypto_ahash_reqtfm(req));
-	ahash_request_free(req);
-	return err;
-}
-EXPORT_SYMBOL(cfs_crypto_hash_final);
-
-/**
- * Compute the speed of specified hash function
- *
- * Run a speed test on the given hash algorithm on buffer of the given size.
- * The speed is stored internally in the cfs_crypto_hash_speeds[] array, and
- * is available through the cfs_crypto_hash_speed() function.
- *
- * \param[in] hash_alg	hash algorithm id (CFS_HASH_ALG_*)
- * \param[in] buf	data buffer on which to compute the hash
- * \param[in] buf_len	length of \buf on which to compute hash
- */
-static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
-{
-	int buf_len = max(PAGE_SIZE, 1048576UL);
-	void *buf;
-	unsigned long start, end;
-	int bcount, err = 0;
-	struct page *page;
-	unsigned char hash[CFS_CRYPTO_HASH_DIGESTSIZE_MAX];
-	unsigned int hash_len = sizeof(hash);
-
-	page = alloc_page(GFP_KERNEL);
-	if (!page) {
-		err = -ENOMEM;
-		goto out_err;
-	}
-
-	buf = kmap(page);
-	memset(buf, 0xAD, PAGE_SIZE);
-	kunmap(page);
-
-	for (start = jiffies, end = start + msecs_to_jiffies(MSEC_PER_SEC),
-	     bcount = 0; time_before(jiffies, end); bcount++) {
-		struct ahash_request *hdesc;
-		int i;
-
-		hdesc = cfs_crypto_hash_init(hash_alg, NULL, 0);
-		if (IS_ERR(hdesc)) {
-			err = PTR_ERR(hdesc);
-			break;
-		}
-
-		for (i = 0; i < buf_len / PAGE_SIZE; i++) {
-			err = cfs_crypto_hash_update_page(hdesc, page, 0,
-							  PAGE_SIZE);
-			if (err)
-				break;
-		}
-
-		err = cfs_crypto_hash_final(hdesc, hash, &hash_len);
-		if (err)
-			break;
-	}
-	end = jiffies;
-	__free_page(page);
-out_err:
-	if (err) {
-		cfs_crypto_hash_speeds[hash_alg] = err;
-		CDEBUG(D_INFO, "Crypto hash algorithm %s test error: rc = %d\n",
-		       cfs_crypto_hash_name(hash_alg), err);
-	} else {
-		unsigned long tmp;
-
-		tmp = ((bcount * buf_len / jiffies_to_msecs(end - start)) *
-		       1000) / (1024 * 1024);
-		cfs_crypto_hash_speeds[hash_alg] = (int)tmp;
-		CDEBUG(D_CONFIG, "Crypto hash algorithm %s speed = %d MB/s\n",
-		       cfs_crypto_hash_name(hash_alg),
-		       cfs_crypto_hash_speeds[hash_alg]);
-	}
-}
-
-/**
- * hash speed in Mbytes per second for valid hash algorithm
- *
- * Return the performance of the specified \a hash_alg that was previously
- * computed using cfs_crypto_performance_test().
- *
- * \param[in] hash_alg	hash algorithm id (CFS_HASH_ALG_*)
- *
- * \retval		positive speed of the hash function in MB/s
- * \retval		-ENOENT if \a hash_alg is unsupported
- * \retval		negative errno if \a hash_alg speed is unavailable
- */
-int cfs_crypto_hash_speed(enum cfs_crypto_hash_alg hash_alg)
-{
-	if (hash_alg < CFS_HASH_ALG_MAX)
-		return cfs_crypto_hash_speeds[hash_alg];
-	return -ENOENT;
-}
-EXPORT_SYMBOL(cfs_crypto_hash_speed);
-
-/**
- * Run the performance test for all hash algorithms.
- *
- * Run the cfs_crypto_performance_test() benchmark for all of the available
- * hash functions using a 1MB buffer size.  This is a reasonable buffer size
- * for Lustre RPCs, even if the actual RPC size is larger or smaller.
- *
- * Since the setup cost and computation speed of various hash algorithms is
- * a function of the buffer size (and possibly internal contention of offload
- * engines), this speed only represents an estimate of the actual speed under
- * actual usage, but is reasonable for comparing available algorithms.
- *
- * The actual speeds are available via cfs_crypto_hash_speed() for later
- * comparison.
- *
- * \retval	0 on success
- * \retval	-ENOMEM if no memory is available for test buffer
- */
-static int cfs_crypto_test_hashes(void)
-{
-	enum cfs_crypto_hash_alg hash_alg;
-
-	for (hash_alg = 0; hash_alg < CFS_HASH_ALG_MAX; hash_alg++)
-		cfs_crypto_performance_test(hash_alg);
-
-	return 0;
-}
-
-static int adler32;
-
-/**
- * Register available hash functions
- *
- * \retval	0
- */
-int cfs_crypto_register(void)
-{
-	request_module("crc32c");
-
-	if (cfs_crypto_adler32_register() == 0)
-		adler32 = 1;
-
-	/* check all algorithms and do performance test */
-	cfs_crypto_test_hashes();
-	return 0;
-}
-
-/**
- * Unregister previously registered hash functions
- */
-void cfs_crypto_unregister(void)
-{
-	if (adler32)
-		cfs_crypto_adler32_unregister();
-	adler32 = 0;
-}
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h
deleted file mode 100644
index 5616e9ea1450..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.h
+++ /dev/null
@@ -1,30 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see http://www.gnu.org/licenses
- *
- * Please  visit http://www.xyratex.com/contact if you need additional
- * information or have any questions.
- *
- * GPL HEADER END
- */
-
-/**
- * Functions for start/stop shash adler32 algorithm.
- */
-int cfs_crypto_adler32_register(void);
-void cfs_crypto_adler32_unregister(void);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
deleted file mode 100644
index 1d728f18e529..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
+++ /dev/null
@@ -1,144 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * libcfs/libcfs/linux/linux-debug.c
- *
- * Author: Phil Schwan <phil@clusterfs.com>
- */
-
-#include <linux/module.h>
-#include <linux/kmod.h>
-#include <linux/notifier.h>
-#include <linux/kernel.h>
-#include <linux/mm.h>
-#include <linux/string.h>
-#include <linux/stat.h>
-#include <linux/errno.h>
-#include <linux/unistd.h>
-#include <linux/interrupt.h>
-#include <linux/completion.h>
-#include <linux/fs.h>
-#include <linux/uaccess.h>
-
-# define DEBUG_SUBSYSTEM S_LNET
-
-#include <linux/libcfs/libcfs.h>
-
-#include "../tracefile.h"
-
-#include <linux/kallsyms.h>
-
-char lnet_debug_log_upcall[1024] = "/usr/lib/lustre/lnet_debug_log_upcall";
-
-/**
- * Upcall function once a Lustre log has been dumped.
- *
- * \param file  path of the dumped log
- */
-void libcfs_run_debug_log_upcall(char *file)
-{
-	char *argv[3];
-	int rc;
-	static const char * const envp[] = {
-		"HOME=/",
-		"PATH=/sbin:/bin:/usr/sbin:/usr/bin",
-		NULL
-	};
-
-	argv[0] = lnet_debug_log_upcall;
-
-	LASSERTF(file, "called on a null filename\n");
-	argv[1] = file; /* only need to pass the path of the file */
-
-	argv[2] = NULL;
-
-	rc = call_usermodehelper(argv[0], argv, (char **)envp, 1);
-	if (rc < 0 && rc != -ENOENT) {
-		CERROR("Error %d invoking LNET debug log upcall %s %s; check /sys/kernel/debug/lnet/debug_log_upcall\n",
-		       rc, argv[0], argv[1]);
-	} else {
-		CDEBUG(D_HA, "Invoked LNET debug log upcall %s %s\n",
-		       argv[0], argv[1]);
-	}
-}
-
-/* coverity[+kill] */
-void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
-{
-	libcfs_catastrophe = 1;
-	libcfs_debug_msg(msgdata, "LBUG\n");
-
-	if (in_interrupt()) {
-		panic("LBUG in interrupt.\n");
-		/* not reached */
-	}
-
-	dump_stack();
-	if (!libcfs_panic_on_lbug)
-		libcfs_debug_dumplog();
-	if (libcfs_panic_on_lbug)
-		panic("LBUG");
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	while (1)
-		schedule();
-}
-EXPORT_SYMBOL(lbug_with_loc);
-
-static int panic_notifier(struct notifier_block *self, unsigned long unused1,
-			  void *unused2)
-{
-	if (libcfs_panic_in_progress)
-		return 0;
-
-	libcfs_panic_in_progress = 1;
-	mb();
-
-	return 0;
-}
-
-static struct notifier_block libcfs_panic_notifier = {
-	.notifier_call	= panic_notifier,
-	.next		= NULL,
-	.priority	= 10000,
-};
-
-void libcfs_register_panic_notifier(void)
-{
-	atomic_notifier_chain_register(&panic_notifier_list,
-				       &libcfs_panic_notifier);
-}
-
-void libcfs_unregister_panic_notifier(void)
-{
-	atomic_notifier_chain_unregister(&panic_notifier_list,
-					 &libcfs_panic_notifier);
-}
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
deleted file mode 100644
index 7928d7182634..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
+++ /dev/null
@@ -1,257 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#define DEBUG_SUBSYSTEM S_LNET
-#define LUSTRE_TRACEFILE_PRIVATE
-
-#include <linux/libcfs/libcfs.h>
-#include "../tracefile.h"
-
-/* percents to share the total debug memory for each type */
-static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
-	80,  /* 80% pages for CFS_TCD_TYPE_PROC */
-	10,  /* 10% pages for CFS_TCD_TYPE_SOFTIRQ */
-	10   /* 10% pages for CFS_TCD_TYPE_IRQ */
-};
-
-char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
-
-static DECLARE_RWSEM(cfs_tracefile_sem);
-
-int cfs_tracefile_init_arch(void)
-{
-	int i;
-	int j;
-	struct cfs_trace_cpu_data *tcd;
-
-	/* initialize trace_data */
-	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
-	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
-		cfs_trace_data[i] =
-			kmalloc_array(num_possible_cpus(),
-				      sizeof(union cfs_trace_data_union),
-				      GFP_KERNEL);
-		if (!cfs_trace_data[i])
-			goto out;
-	}
-
-	/* arch related info initialized */
-	cfs_tcd_for_each(tcd, i, j) {
-		spin_lock_init(&tcd->tcd_lock);
-		tcd->tcd_pages_factor = pages_factor[i];
-		tcd->tcd_type = i;
-		tcd->tcd_cpu = j;
-	}
-
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
-			cfs_trace_console_buffers[i][j] =
-				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
-					GFP_KERNEL);
-
-			if (!cfs_trace_console_buffers[i][j])
-				goto out;
-		}
-
-	return 0;
-
-out:
-	cfs_tracefile_fini_arch();
-	pr_err("lnet: Not enough memory\n");
-	return -ENOMEM;
-}
-
-void cfs_tracefile_fini_arch(void)
-{
-	int i;
-	int j;
-
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
-			kfree(cfs_trace_console_buffers[i][j]);
-			cfs_trace_console_buffers[i][j] = NULL;
-		}
-
-	for (i = 0; cfs_trace_data[i]; i++) {
-		kfree(cfs_trace_data[i]);
-		cfs_trace_data[i] = NULL;
-	}
-}
-
-void cfs_tracefile_read_lock(void)
-{
-	down_read(&cfs_tracefile_sem);
-}
-
-void cfs_tracefile_read_unlock(void)
-{
-	up_read(&cfs_tracefile_sem);
-}
-
-void cfs_tracefile_write_lock(void)
-{
-	down_write(&cfs_tracefile_sem);
-}
-
-void cfs_tracefile_write_unlock(void)
-{
-	up_write(&cfs_tracefile_sem);
-}
-
-enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
-{
-	if (in_irq())
-		return CFS_TCD_TYPE_IRQ;
-	if (in_softirq())
-		return CFS_TCD_TYPE_SOFTIRQ;
-	return CFS_TCD_TYPE_PROC;
-}
-
-/*
- * The walking argument indicates the locking comes from all tcd types
- * iterator and we must lock it and dissable local irqs to avoid deadlocks
- * with other interrupt locks that might be happening. See LU-1311
- * for details.
- */
-int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
-	__acquires(&tcd->tc_lock)
-{
-	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
-	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
-		spin_lock_irqsave(&tcd->tcd_lock, tcd->tcd_lock_flags);
-	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
-		spin_lock_bh(&tcd->tcd_lock);
-	else if (unlikely(walking))
-		spin_lock_irq(&tcd->tcd_lock);
-	else
-		spin_lock(&tcd->tcd_lock);
-	return 1;
-}
-
-void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
-	__releases(&tcd->tcd_lock)
-{
-	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
-	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
-		spin_unlock_irqrestore(&tcd->tcd_lock, tcd->tcd_lock_flags);
-	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
-		spin_unlock_bh(&tcd->tcd_lock);
-	else if (unlikely(walking))
-		spin_unlock_irq(&tcd->tcd_lock);
-	else
-		spin_unlock(&tcd->tcd_lock);
-}
-
-void
-cfs_set_ptldebug_header(struct ptldebug_header *header,
-			struct libcfs_debug_msg_data *msgdata,
-			unsigned long stack)
-{
-	struct timespec64 ts;
-
-	ktime_get_real_ts64(&ts);
-
-	header->ph_subsys = msgdata->msg_subsys;
-	header->ph_mask = msgdata->msg_mask;
-	header->ph_cpu_id = smp_processor_id();
-	header->ph_type = cfs_trace_buf_idx_get();
-	/* y2038 safe since all user space treats this as unsigned, but
-	 * will overflow in 2106
-	 */
-	header->ph_sec = (u32)ts.tv_sec;
-	header->ph_usec = ts.tv_nsec / NSEC_PER_USEC;
-	header->ph_stack = stack;
-	header->ph_pid = current->pid;
-	header->ph_line_num = msgdata->msg_line;
-	header->ph_extern_pid = 0;
-}
-
-static char *
-dbghdr_to_err_string(struct ptldebug_header *hdr)
-{
-	switch (hdr->ph_subsys) {
-	case S_LND:
-	case S_LNET:
-		return "LNetError";
-	default:
-		return "LustreError";
-	}
-}
-
-static char *
-dbghdr_to_info_string(struct ptldebug_header *hdr)
-{
-	switch (hdr->ph_subsys) {
-	case S_LND:
-	case S_LNET:
-		return "LNet";
-	default:
-		return "Lustre";
-	}
-}
-
-void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
-			  const char *buf, int len, const char *file,
-			  const char *fn)
-{
-	char *prefix = "Lustre", *ptype = NULL;
-
-	if (mask & D_EMERG) {
-		prefix = dbghdr_to_err_string(hdr);
-		ptype = KERN_EMERG;
-	} else if (mask & D_ERROR) {
-		prefix = dbghdr_to_err_string(hdr);
-		ptype = KERN_ERR;
-	} else if (mask & D_WARNING) {
-		prefix = dbghdr_to_info_string(hdr);
-		ptype = KERN_WARNING;
-	} else if (mask & (D_CONSOLE | libcfs_printk)) {
-		prefix = dbghdr_to_info_string(hdr);
-		ptype = KERN_INFO;
-	}
-
-	if (mask & D_CONSOLE) {
-		pr_info("%s%s: %.*s", ptype, prefix, len, buf);
-	} else {
-		pr_info("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
-			hdr->ph_pid, hdr->ph_extern_pid, file,
-			hdr->ph_line_num, fn, len, buf);
-	}
-}
-
-int cfs_trace_max_debug_mb(void)
-{
-	int  total_mb = (totalram_pages >> (20 - PAGE_SHIFT));
-
-	return max(512, (total_mb * 80) / 100);
-}
