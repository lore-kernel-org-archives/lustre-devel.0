From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:38 +1100
Subject: [lustre-devel] [PATCH 13/21] staging: lustre: remove phantom struct
 cfs_crypto_hash_desc
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341798.25814.6579149760977367071.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

There is no "struct cfs_crypto_hash_desc" structure.  There
are only pointers to this structure, which are cast back and
forth to struct ahash_request.
So discard cfs_crypto_hash_desc, and just use ahash_request directly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |   11 +++-----
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   29 +++++++++-----------
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    2 +
 4 files changed, 19 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index e5c156e9d907..3a72117140ed 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -189,18 +189,15 @@ int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
 			   unsigned char *key, unsigned int key_len,
 			   unsigned char *hash, unsigned int *hash_len);
 
-/* cfs crypto hash descriptor */
-struct cfs_crypto_hash_desc;
-
-struct cfs_crypto_hash_desc *
+struct ahash_request *
 cfs_crypto_hash_init(enum cfs_crypto_hash_alg hash_alg,
 		     unsigned char *key, unsigned int key_len);
-int cfs_crypto_hash_update_page(struct cfs_crypto_hash_desc *desc,
+int cfs_crypto_hash_update_page(struct ahash_request *desc,
 				struct page *page, unsigned int offset,
 				unsigned int len);
-int cfs_crypto_hash_update(struct cfs_crypto_hash_desc *desc, const void *buf,
+int cfs_crypto_hash_update(struct ahash_request *desc, const void *buf,
 			   unsigned int buf_len);
-int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *desc,
+int cfs_crypto_hash_final(struct ahash_request *desc,
 			  unsigned char *hash, unsigned int *hash_len);
 int cfs_crypto_register(void);
 void cfs_crypto_unregister(void);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 80072b2a443c..b55006264155 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -42,7 +42,7 @@ static int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
 /**
  * Initialize the state descriptor for the specified hash algorithm.
  *
- * An internal routine to allocate the hash-specific state in \a hdesc for
+ * An internal routine to allocate the hash-specific state in \a req for
  * use with cfs_crypto_hash_digest() to compute the hash of a single message,
  * though possibly in multiple chunks.  The descriptor internal state should
  * be freed with cfs_crypto_hash_final().
@@ -50,7 +50,7 @@ static int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
  * \param[in]	  hash_alg	hash algorithm id (CFS_HASH_ALG_*)
  * \param[out]	  type		pointer to the hash description in hash_types[]
  *				array
- * \param[in,out] hdesc		hash state descriptor to be initialized
+ * \param[in,out] req		hash state descriptor to be initialized
  * \param[in]	  key		initial hash value/state, NULL to use default
  *				value
  * \param[in]	  key_len	length of \a key
@@ -194,7 +194,7 @@ EXPORT_SYMBOL(cfs_crypto_hash_digest);
  * \retval		pointer to descriptor of hash instance
  * \retval		ERR_PTR(errno) in case of error
  */
-struct cfs_crypto_hash_desc *
+struct ahash_request *
 cfs_crypto_hash_init(enum cfs_crypto_hash_alg hash_alg,
 		     unsigned char *key, unsigned int key_len)
 {
@@ -206,14 +206,14 @@ cfs_crypto_hash_init(enum cfs_crypto_hash_alg hash_alg,
 
 	if (err)
 		return ERR_PTR(err);
-	return (struct cfs_crypto_hash_desc *)req;
+	return req;
 }
 EXPORT_SYMBOL(cfs_crypto_hash_init);
 
 /**
  * Update hash digest computed on data within the given \a page
  *
- * \param[in] hdesc	hash state descriptor
+ * \param[in] hreq	hash state descriptor
  * \param[in] page	data page on which to compute the hash
  * \param[in] offset	offset within \a page at which to start hash
  * \param[in] len	length of data on which to compute hash
@@ -221,11 +221,10 @@ EXPORT_SYMBOL(cfs_crypto_hash_init);
  * \retval		0 for success
  * \retval		negative errno on failure
  */
-int cfs_crypto_hash_update_page(struct cfs_crypto_hash_desc *hdesc,
+int cfs_crypto_hash_update_page(struct ahash_request *req,
 				struct page *page, unsigned int offset,
 				unsigned int len)
 {
-	struct ahash_request *req = (void *)hdesc;
 	struct scatterlist sl;
 
 	sg_init_table(&sl, 1);
@@ -239,17 +238,16 @@ EXPORT_SYMBOL(cfs_crypto_hash_update_page);
 /**
  * Update hash digest computed on the specified data
  *
- * \param[in] hdesc	hash state descriptor
+ * \param[in] req	hash state descriptor
  * \param[in] buf	data buffer on which to compute the hash
  * \param[in] buf_len	length of \buf on which to compute hash
  *
  * \retval		0 for success
  * \retval		negative errno on failure
  */
-int cfs_crypto_hash_update(struct cfs_crypto_hash_desc *hdesc,
+int cfs_crypto_hash_update(struct ahash_request *req,
 			   const void *buf, unsigned int buf_len)
 {
-	struct ahash_request *req = (void *)hdesc;
 	struct scatterlist sl;
 
 	sg_init_one(&sl, buf, buf_len);
@@ -262,20 +260,19 @@ EXPORT_SYMBOL(cfs_crypto_hash_update);
 /**
  * Finish hash calculation, copy hash digest to buffer, clean up hash descriptor
  *
- * \param[in]	  hdesc		hash descriptor
+ * \param[in]	  req		hash descriptor
  * \param[out]	  hash		pointer to hash buffer to store hash digest
- * \param[in,out] hash_len	pointer to hash buffer size, if \a hdesc = NULL
- *				only free \a hdesc instead of computing the hash
+ * \param[in,out] hash_len	pointer to hash buffer size, if \a req = NULL
+ *				only free \a req instead of computing the hash
  *
  * \retval	0 for success
  * \retval	-EOVERFLOW if hash_len is too small for the hash digest
  * \retval	negative errno for other errors from lower layers
  */
-int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *hdesc,
+int cfs_crypto_hash_final(struct ahash_request *req,
 			  unsigned char *hash, unsigned int *hash_len)
 {
 	int err;
-	struct ahash_request *req = (void *)hdesc;
 	int size = crypto_ahash_digestsize(crypto_ahash_reqtfm(req));
 
 	if (!hash || !hash_len) {
@@ -331,7 +328,7 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 
 	for (start = jiffies, end = start + msecs_to_jiffies(MSEC_PER_SEC),
 	     bcount = 0; time_before(jiffies, end); bcount++) {
-		struct cfs_crypto_hash_desc *hdesc;
+		struct ahash_request *hdesc;
 		int i;
 
 		hdesc = cfs_crypto_hash_init(hash_alg, NULL, 0);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 074b5ce6284c..1c2bbbf5d864 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -931,7 +931,7 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 {
 	__u32 cksum;
 	int i = 0;
-	struct cfs_crypto_hash_desc *hdesc;
+	struct ahash_request *hdesc;
 	unsigned int bufsize;
 	unsigned char cfs_alg = cksum_obd2cfs(cksum_type);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 2184022ed724..577c5822b823 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -530,7 +530,7 @@ EXPORT_SYMBOL(bulk_sec_desc_unpack);
 int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 			      void *buf, int buflen)
 {
-	struct cfs_crypto_hash_desc *hdesc;
+	struct ahash_request *hdesc;
 	int hashsize;
 	unsigned int bufsize;
 	int i, err;
