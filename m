From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:46 -0400
Subject: [lustre-devel] [PATCH 02/12] staging: lustre: libcfs: add
	documentation for cfs_crypto_hash_*()
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Add comment blocks for cfs_crypto_hash_*() in linux-crypto.c and
libcfs_crypto.h. Delete obsolete comment about shash handling in
cfs_crypto_hash_alloc().

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |  101 ++++---------
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |  153 ++++++++++++++++++--
 2 files changed, 174 insertions(+), 80 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index e866369..5182416 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -61,7 +61,14 @@ static struct cfs_crypto_hash_type hash_types[] = {
 	[CFS_HASH_ALG_SHA512]  = { "sha512",   0,     64 },
 };
 
-/**    Return pointer to type of hash for valid hash algorithm identifier */
+/**
+ * Return hash algorithm information for the specified algorithm identifier
+ *
+ * Hash information includes algorithm name, initial seed, hash size.
+ *
+ * \retval	cfs_crypto_hash_type for valid ID (CFS_HASH_ALG_*)
+ * \retval	NULL for unknown algorithm identifier
+ */
 static inline const struct cfs_crypto_hash_type *
 		    cfs_crypto_hash_type(unsigned char hash_alg)
 {
@@ -75,7 +82,14 @@ static inline const struct cfs_crypto_hash_type *
 	return NULL;
 }
 
-/**     Return hash name for valid hash algorithm identifier or "unknown" */
+/**
+ * Return hash name for hash algorithm identifier
+ *
+ * \param[in]	hash_alg hash alrgorithm id (CFS_HASH_ALG_*)
+ *
+ * \retval	string name of known hash algorithm
+ * \retval	"unknown" if hash algorithm is unknown
+ */
 static inline const char *cfs_crypto_hash_name(unsigned char hash_alg)
 {
 	const struct cfs_crypto_hash_type *ht;
@@ -86,7 +100,14 @@ static inline const char *cfs_crypto_hash_name(unsigned char hash_alg)
 	return "unknown";
 }
 
-/**     Return digest size for valid algorithm identifier or 0 */
+/**
+ * Return digest size for hash algorithm type
+ *
+ * \param[in]	hash_alg hash alrgorithm id (CFS_HASH_ALG_*)
+ *
+ * \retval	hash algorithm digest size in bytes
+ * \retval	0 if hash algorithm type is unknown
+ */
 static inline int cfs_crypto_hash_digestsize(unsigned char hash_alg)
 {
 	const struct cfs_crypto_hash_type *ht;
@@ -97,7 +118,12 @@ static inline int cfs_crypto_hash_digestsize(unsigned char hash_alg)
 	return 0;
 }
 
-/**     Return hash identifier for valid hash algorithm name or 0xFF */
+/**
+ * Find hash algorithm ID for the specified algorithm name
+ *
+ * \retval	hash algorithm ID for valid ID (CFS_HASH_ALG_*)
+ * \retval	CFS_HASH_ALG_UNKNOWN for unknown algorithm name
+ */
 static inline unsigned char cfs_crypto_hash_alg(const char *algname)
 {
 	unsigned char   i;
@@ -108,24 +134,6 @@ static inline unsigned char cfs_crypto_hash_alg(const char *algname)
 	return (i == CFS_HASH_ALG_MAX ? 0xFF : i);
 }
 
-/**     Calculate hash digest for buffer.
- *      @param alg	    id of hash algorithm
- *      @param buf	    buffer of data
- *      @param buf_len	buffer len
- *      @param key	    initial value for algorithm, if it is NULL,
- *			    default initial value should be used.
- *      @param key_len	len of initial value
- *      @param hash	   [out] pointer to hash, if it is NULL, hash_len is
- *			    set to valid digest size in bytes, retval -ENOSPC.
- *      @param hash_len       [in,out] size of hash buffer
- *      @returns	      status of operation
- *      @retval -EINVAL       if buf, buf_len, hash_len or alg_id is invalid
- *      @retval -ENODEV       if this algorithm is unsupported
- *      @retval -ENOSPC       if pointer to hash is NULL, or hash_len less than
- *			    digest size
- *      @retval 0	     for success
- *      @retval < 0	   other errors from lower layers.
- */
 int cfs_crypto_hash_digest(unsigned char alg,
 			   const void *buf, unsigned int buf_len,
 			   unsigned char *key, unsigned int key_len,
@@ -134,66 +142,17 @@ int cfs_crypto_hash_digest(unsigned char alg,
 /* cfs crypto hash descriptor */
 struct cfs_crypto_hash_desc;
 
-/**     Allocate and initialize descriptor for hash algorithm.
- *      @param alg	    algorithm id
- *      @param key	    initial value for algorithm, if it is NULL,
- *			    default initial value should be used.
- *      @param key_len	len of initial value
- *      @returns	      pointer to descriptor of hash instance
- *      @retval ERR_PTR(error) when errors occurred.
- */
 struct cfs_crypto_hash_desc*
 	cfs_crypto_hash_init(unsigned char alg,
 			     unsigned char *key, unsigned int key_len);
-
-/**    Update digest by part of data.
- *     @param desc	      hash descriptor
- *     @param page	      data page
- *     @param offset	    data offset
- *     @param len	       data len
- *     @returns		 status of operation
- *     @retval 0		for success.
- */
 int cfs_crypto_hash_update_page(struct cfs_crypto_hash_desc *desc,
 				struct page *page, unsigned int offset,
 				unsigned int len);
-
-/**    Update digest by part of data.
- *     @param desc	      hash descriptor
- *     @param buf	       pointer to data buffer
- *     @param buf_len	   size of data@buffer
- *     @returns		 status of operation
- *     @retval 0		for success.
- */
 int cfs_crypto_hash_update(struct cfs_crypto_hash_desc *desc, const void *buf,
 			   unsigned int buf_len);
-
-/**    Finalize hash calculation, copy hash digest to buffer, destroy hash
- *     descriptor.
- *     @param desc	      hash descriptor
- *     @param hash	      buffer pointer to store hash digest
- *     @param hash_len	  pointer to hash buffer size, if NULL
- *			      destroy hash descriptor
- *     @returns		 status of operation
- *     @retval -ENOSPC	  if hash is NULL, or *hash_len less than
- *			      digest size
- *     @retval 0		for success
- *     @retval < 0	      other errors from lower layers.
- */
 int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *desc,
 			  unsigned char *hash, unsigned int *hash_len);
-/**
- *      Register crypto hash algorithms
- */
 int cfs_crypto_register(void);
-
-/**
- *      Unregister
- */
 void cfs_crypto_unregister(void);
-
-/**     Return hash speed in Mbytes per second for valid hash algorithm
- *      identifier. If test was unsuccessful -1 would be returned.
- */
 int cfs_crypto_hash_speed(unsigned char hash_alg);
 #endif
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index d4cb260..8960c3a 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -32,11 +32,31 @@
 #include "../../../include/linux/libcfs/libcfs.h"
 #include "../../../include/linux/libcfs/libcfs_crypto.h"
 #include "linux-crypto.h"
+
 /**
- *  Array of  hash algorithm speed in MByte per second
+ *  Array of hash algorithm speed in MByte per second
  */
 static int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
 
+/**
+ * Initialize the state descriptor for the specified hash algorithm.
+ *
+ * An internal routine to allocate the hash-specific state in \a hdesc for
+ * use with cfs_crypto_hash_digest() to compute the hash of a single message,
+ * though possibly in multiple chunks.  The descriptor internal state should
+ * be freed with cfs_crypto_hash_final().
+ *
+ * \param[in]	  hash_alg	hash algorithm id (CFS_HASH_ALG_*)
+ * \param[out]	  type		pointer to the hash description in hash_types[]
+ *				array
+ * \param[in,out] hdesc		hash state descriptor to be initialized
+ * \param[in]	  key		initial hash value/state, NULL to use default
+ *				value
+ * \param[in]	  key_len	length of \a key
+ *
+ * \retval			0 on success
+ * \retval			negative errno on failure
+ */
 static int cfs_crypto_hash_alloc(unsigned char alg_id,
 				 const struct cfs_crypto_hash_type **type,
 				 struct ahash_request **req,
@@ -71,12 +91,6 @@ static int cfs_crypto_hash_alloc(unsigned char alg_id,
 
 	ahash_request_set_callback(*req, 0, NULL, NULL);
 
-	/** Shash have different logic for initialization then digest
-	 * shash: crypto_hash_setkey, crypto_hash_init
-	 * digest: crypto_digest_init, crypto_digest_setkey
-	 * Skip this function for digest, because we use shash logic at
-	 * cfs_crypto_hash_alloc.
-	 */
 	if (key)
 		err = crypto_ahash_setkey(tfm, key, key_len);
 	else if ((*type)->cht_key != 0)
@@ -101,6 +115,32 @@ static int cfs_crypto_hash_alloc(unsigned char alg_id,
 	return err;
 }
 
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
+ *				\a alg_id invalid
+ * \retval -ENOENT		\a hash_alg is unsupported
+ * \retval -ENOSPC		\a hash is NULL, or \a hash_len less than
+ *				digest size
+ * \retval			0 for success
+ * \retval			negative errno for other errors from lower
+ *				layers.
+ */
 int cfs_crypto_hash_digest(unsigned char alg_id,
 			   const void *buf, unsigned int buf_len,
 			   unsigned char *key, unsigned int key_len,
@@ -135,6 +175,23 @@ int cfs_crypto_hash_digest(unsigned char alg_id,
 }
 EXPORT_SYMBOL(cfs_crypto_hash_digest);
 
+/**
+ * Allocate and initialize desriptor for hash algorithm.
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
 struct cfs_crypto_hash_desc *
 	cfs_crypto_hash_init(unsigned char alg_id,
 			     unsigned char *key, unsigned int key_len)
@@ -151,6 +208,17 @@ struct cfs_crypto_hash_desc *
 }
 EXPORT_SYMBOL(cfs_crypto_hash_init);
 
+/**
+ * Update hash digest computed on data within the given \a page
+ *
+ * \param[in] hdesc	hash state descriptor
+ * \param[in] page	data page on which to compute the hash
+ * \param[in] offset	offset within \a page at which to start hash
+ * \param[in] len	length of data on which to compute hash
+ *
+ * \retval		0 for success
+ * \retval		negative errno on failure
+ */
 int cfs_crypto_hash_update_page(struct cfs_crypto_hash_desc *hdesc,
 				struct page *page, unsigned int offset,
 				unsigned int len)
@@ -166,6 +234,16 @@ int cfs_crypto_hash_update_page(struct cfs_crypto_hash_desc *hdesc,
 }
 EXPORT_SYMBOL(cfs_crypto_hash_update_page);
 
+/**
+ * Update hash digest computed on the specified data
+ *
+ * \param[in] hdesc	hash state descriptor
+ * \param[in] buf	data buffer on which to compute the hash
+ * \param[in] buf_len	length of \buf on which to compute hash
+ *
+ * \retval		0 for success
+ * \retval		negative errno on failure
+ */
 int cfs_crypto_hash_update(struct cfs_crypto_hash_desc *hdesc,
 			   const void *buf, unsigned int buf_len)
 {
@@ -179,7 +257,18 @@ int cfs_crypto_hash_update(struct cfs_crypto_hash_desc *hdesc,
 }
 EXPORT_SYMBOL(cfs_crypto_hash_update);
 
-/*      If hash_len pointer is NULL - destroy descriptor. */
+/**
+ * Finish hash calculation, copy hash digest to buffer, clean up hash descriptor
+ *
+ * \param[in]	  hdesc		hash descriptor
+ * \param[out]	  hash		pointer to hash buffer to store hash digest
+ * \param[in,out] hash_len	pointer to hash buffer size, if \a hdesc = NULL
+ *				only free \a hdesc instead of computing the hash
+ *
+ * \retval	-ENOSPC if \a hash = NULL, or \a hash_len < digest size
+ * \retval	0 for success
+ * \retval	negative errno for other errors from lower layers
+ */
 int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *hdesc,
 			  unsigned char *hash, unsigned int *hash_len)
 {
@@ -209,6 +298,17 @@ int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *hdesc,
 }
 EXPORT_SYMBOL(cfs_crypto_hash_final);
 
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
 static void cfs_crypto_performance_test(unsigned char alg_id,
 					const unsigned char *buf,
 					unsigned int buf_len)
@@ -243,6 +343,18 @@ static void cfs_crypto_performance_test(unsigned char alg_id,
 	       cfs_crypto_hash_name(alg_id), cfs_crypto_hash_speeds[alg_id]);
 }
 
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
 int cfs_crypto_hash_speed(unsigned char hash_alg)
 {
 	if (hash_alg < CFS_HASH_ALG_MAX)
@@ -252,7 +364,22 @@ int cfs_crypto_hash_speed(unsigned char hash_alg)
 EXPORT_SYMBOL(cfs_crypto_hash_speed);
 
 /**
- * Do performance test for all hash algorithms.
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
  */
 static int cfs_crypto_test_hashes(void)
 {
@@ -280,6 +407,11 @@ static int cfs_crypto_test_hashes(void)
 
 static int adler32;
 
+/**
+ * Register available hash functions
+ *
+ * \retval	0
+ */
 int cfs_crypto_register(void)
 {
 	request_module("crc32c");
@@ -291,6 +423,9 @@ int cfs_crypto_register(void)
 	return 0;
 }
 
+/**
+ * Unregister previously registered hash functions
+ */
 void cfs_crypto_unregister(void)
 {
 	if (adler32 == 0)
-- 
1.7.1
