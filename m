From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:47 -0400
Subject: [lustre-devel] [PATCH 03/12] staging: lustre: libcfs: rename some
	variables for crypto handling
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

For the crypto algorthim type use the same name hash_alg everywhere.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |    4 +-
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   30 ++++++++++----------
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index 5182416..0782bfb 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -134,7 +134,7 @@ static inline unsigned char cfs_crypto_hash_alg(const char *algname)
 	return (i == CFS_HASH_ALG_MAX ? 0xFF : i);
 }
 
-int cfs_crypto_hash_digest(unsigned char alg,
+int cfs_crypto_hash_digest(unsigned char hash_alg,
 			   const void *buf, unsigned int buf_len,
 			   unsigned char *key, unsigned int key_len,
 			   unsigned char *hash, unsigned int *hash_len);
@@ -143,7 +143,7 @@ int cfs_crypto_hash_digest(unsigned char alg,
 struct cfs_crypto_hash_desc;
 
 struct cfs_crypto_hash_desc*
-	cfs_crypto_hash_init(unsigned char alg,
+	cfs_crypto_hash_init(unsigned char hash_alg,
 			     unsigned char *key, unsigned int key_len);
 int cfs_crypto_hash_update_page(struct cfs_crypto_hash_desc *desc,
 				struct page *page, unsigned int offset,
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 8960c3a..1a9eb77 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -57,7 +57,7 @@ static int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
  * \retval			0 on success
  * \retval			negative errno on failure
  */
-static int cfs_crypto_hash_alloc(unsigned char alg_id,
+static int cfs_crypto_hash_alloc(unsigned char hash_alg,
 				 const struct cfs_crypto_hash_type **type,
 				 struct ahash_request **req,
 				 unsigned char *key,
@@ -66,11 +66,11 @@ static int cfs_crypto_hash_alloc(unsigned char alg_id,
 	struct crypto_ahash *tfm;
 	int     err = 0;
 
-	*type = cfs_crypto_hash_type(alg_id);
+	*type = cfs_crypto_hash_type(hash_alg);
 
 	if (!*type) {
 		CWARN("Unsupported hash algorithm id = %d, max id is %d\n",
-		      alg_id, CFS_HASH_ALG_MAX);
+		      hash_alg, CFS_HASH_ALG_MAX);
 		return -EINVAL;
 	}
 	tfm = crypto_alloc_ahash((*type)->cht_name, 0, CRYPTO_ALG_ASYNC);
@@ -105,7 +105,7 @@ static int cfs_crypto_hash_alloc(unsigned char alg_id,
 
 	CDEBUG(D_INFO, "Using crypto hash: %s (%s) speed %d MB/s\n",
 	       crypto_ahash_alg_name(tfm), crypto_ahash_driver_name(tfm),
-	       cfs_crypto_hash_speeds[alg_id]);
+	       cfs_crypto_hash_speeds[hash_alg]);
 
 	err = crypto_ahash_init(*req);
 	if (err) {
@@ -133,7 +133,7 @@ static int cfs_crypto_hash_alloc(unsigned char alg_id,
  * \param[in,out] hash_len	size of \a hash buffer
  *
  * \retval -EINVAL		\a buf, \a buf_len, \a hash_len,
- *				\a alg_id invalid
+ *				\a hash_alg invalid
  * \retval -ENOENT		\a hash_alg is unsupported
  * \retval -ENOSPC		\a hash is NULL, or \a hash_len less than
  *				digest size
@@ -141,7 +141,7 @@ static int cfs_crypto_hash_alloc(unsigned char alg_id,
  * \retval			negative errno for other errors from lower
  *				layers.
  */
-int cfs_crypto_hash_digest(unsigned char alg_id,
+int cfs_crypto_hash_digest(unsigned char hash_alg,
 			   const void *buf, unsigned int buf_len,
 			   unsigned char *key, unsigned int key_len,
 			   unsigned char *hash, unsigned int *hash_len)
@@ -154,7 +154,7 @@ int cfs_crypto_hash_digest(unsigned char alg_id,
 	if (!buf || buf_len == 0 || !hash_len)
 		return -EINVAL;
 
-	err = cfs_crypto_hash_alloc(alg_id, &type, &req, key, key_len);
+	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
 	if (err != 0)
 		return err;
 
@@ -193,14 +193,14 @@ EXPORT_SYMBOL(cfs_crypto_hash_digest);
  * \retval		ERR_PTR(errno) in case of error
  */
 struct cfs_crypto_hash_desc *
-	cfs_crypto_hash_init(unsigned char alg_id,
+	cfs_crypto_hash_init(unsigned char hash_alg,
 			     unsigned char *key, unsigned int key_len)
 {
 	struct ahash_request *req;
 	int		     err;
 	const struct cfs_crypto_hash_type       *type;
 
-	err = cfs_crypto_hash_alloc(alg_id, &type, &req, key, key_len);
+	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
 
 	if (err)
 		return ERR_PTR(err);
@@ -309,7 +309,7 @@ EXPORT_SYMBOL(cfs_crypto_hash_final);
  * \param[in] buf	data buffer on which to compute the hash
  * \param[in] buf_len	length of \buf on which to compute hash
  */
-static void cfs_crypto_performance_test(unsigned char alg_id,
+static void cfs_crypto_performance_test(unsigned char hash_alg,
 					const unsigned char *buf,
 					unsigned int buf_len)
 {
@@ -321,7 +321,7 @@ static void cfs_crypto_performance_test(unsigned char alg_id,
 
 	for (start = jiffies, end = start + sec * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
-		err = cfs_crypto_hash_digest(alg_id, buf, buf_len, NULL, 0,
+		err = cfs_crypto_hash_digest(hash_alg, buf, buf_len, NULL, 0,
 					     hash, &hash_len);
 		if (err)
 			break;
@@ -329,18 +329,18 @@ static void cfs_crypto_performance_test(unsigned char alg_id,
 	end = jiffies;
 
 	if (err) {
-		cfs_crypto_hash_speeds[alg_id] =  -1;
+		cfs_crypto_hash_speeds[hash_alg] =  -1;
 		CDEBUG(D_INFO, "Crypto hash algorithm %s, err = %d\n",
-		       cfs_crypto_hash_name(alg_id), err);
+		       cfs_crypto_hash_name(hash_alg), err);
 	} else {
 		unsigned long   tmp;
 
 		tmp = ((bcount * buf_len / jiffies_to_msecs(end - start)) *
 		       1000) / (1024 * 1024);
-		cfs_crypto_hash_speeds[alg_id] = (int)tmp;
+		cfs_crypto_hash_speeds[hash_alg] = (int)tmp;
 	}
 	CDEBUG(D_INFO, "Crypto hash algorithm %s speed = %d MB/s\n",
-	       cfs_crypto_hash_name(alg_id), cfs_crypto_hash_speeds[alg_id]);
+	       cfs_crypto_hash_name(hash_alg), cfs_crypto_hash_speeds[hash_alg]);
 }
 
 /**
-- 
1.7.1
