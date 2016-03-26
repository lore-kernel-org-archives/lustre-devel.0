From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:50 -0400
Subject: [lustre-devel] [PATCH 06/12] staging: lustre: libcfs: start using
	enum cfs_crypto_hash_alg
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Fix the cfs_crypto_hash_* functions to take enum cfs_crypto_hash_alg
as the algorithm type, instead of an unsigned char.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |   23 ++++++++++---------
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   10 ++++----
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index ade8894..02be7d7 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -75,7 +75,7 @@ static struct cfs_crypto_hash_type hash_types[] = {
  * \retval	NULL for unknown algorithm identifier
  */
 static inline const struct cfs_crypto_hash_type *
-cfs_crypto_hash_type(unsigned char hash_alg)
+cfs_crypto_hash_type(enum cfs_crypto_hash_alg hash_alg)
 {
 	struct cfs_crypto_hash_type *ht;
 
@@ -96,7 +96,7 @@ cfs_crypto_hash_type(unsigned char hash_alg)
  * \retval	"unknown" if hash algorithm is unknown
  */
 static inline const char *
-cfs_crypto_hash_name(unsigned char hash_alg)
+cfs_crypto_hash_name(enum cfs_crypto_hash_alg hash_alg)
 {
 	const struct cfs_crypto_hash_type *ht;
 
@@ -114,7 +114,7 @@ cfs_crypto_hash_name(unsigned char hash_alg)
  * \retval	hash algorithm digest size in bytes
  * \retval	0 if hash algorithm type is unknown
  */
-static inline int cfs_crypto_hash_digestsize(unsigned char hash_alg)
+static inline int cfs_crypto_hash_digestsize(enum cfs_crypto_hash_alg hash_alg)
 {
 	const struct cfs_crypto_hash_type *ht;
 
@@ -132,15 +132,16 @@ static inline int cfs_crypto_hash_digestsize(unsigned char hash_alg)
  */
 static inline unsigned char cfs_crypto_hash_alg(const char *algname)
 {
-	unsigned char   i;
+	enum cfs_crypto_hash_alg hash_alg;
 
-	for (i = 0; i < CFS_HASH_ALG_MAX; i++)
-		if (!strcmp(hash_types[i].cht_name, algname))
-			break;
-	return (i == CFS_HASH_ALG_MAX ? CFS_HASH_ALG_UNKNOWN : i);
+	for (hash_alg = 0; hash_alg < CFS_HASH_ALG_MAX; hash_alg++)
+		if (strcmp(hash_types[hash_alg].cht_name, algname) == 0)
+			return hash_alg;
+
+	return CFS_HASH_ALG_UNKNOWN;
 }
 
-int cfs_crypto_hash_digest(unsigned char hash_alg,
+int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
 			   const void *buf, unsigned int buf_len,
 			   unsigned char *key, unsigned int key_len,
 			   unsigned char *hash, unsigned int *hash_len);
@@ -149,7 +150,7 @@ int cfs_crypto_hash_digest(unsigned char hash_alg,
 struct cfs_crypto_hash_desc;
 
 struct cfs_crypto_hash_desc *
-cfs_crypto_hash_init(unsigned char hash_alg,
+cfs_crypto_hash_init(enum cfs_crypto_hash_alg hash_alg,
 		     unsigned char *key, unsigned int key_len);
 int cfs_crypto_hash_update_page(struct cfs_crypto_hash_desc *desc,
 				struct page *page, unsigned int offset,
@@ -160,5 +161,5 @@ int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *desc,
 			  unsigned char *hash, unsigned int *hash_len);
 int cfs_crypto_register(void);
 void cfs_crypto_unregister(void);
-int cfs_crypto_hash_speed(unsigned char hash_alg);
+int cfs_crypto_hash_speed(enum cfs_crypto_hash_alg hash_alg);
 #endif
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 0241729..6fe1fdd 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -57,7 +57,7 @@ static int cfs_crypto_hash_speeds[CFS_HASH_ALG_MAX];
  * \retval			0 on success
  * \retval			negative errno on failure
  */
-static int cfs_crypto_hash_alloc(unsigned char hash_alg,
+static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 				 const struct cfs_crypto_hash_type **type,
 				 struct ahash_request **req,
 				 unsigned char *key,
@@ -141,7 +141,7 @@ static int cfs_crypto_hash_alloc(unsigned char hash_alg,
  * \retval			negative errno for other errors from lower
  *				layers.
  */
-int cfs_crypto_hash_digest(unsigned char hash_alg,
+int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
 			   const void *buf, unsigned int buf_len,
 			   unsigned char *key, unsigned int key_len,
 			   unsigned char *hash, unsigned int *hash_len)
@@ -193,7 +193,7 @@ EXPORT_SYMBOL(cfs_crypto_hash_digest);
  * \retval		ERR_PTR(errno) in case of error
  */
 struct cfs_crypto_hash_desc *
-cfs_crypto_hash_init(unsigned char hash_alg,
+cfs_crypto_hash_init(enum cfs_crypto_hash_alg hash_alg,
 		     unsigned char *key, unsigned int key_len)
 {
 	struct ahash_request *req;
@@ -309,7 +309,7 @@ EXPORT_SYMBOL(cfs_crypto_hash_final);
  * \param[in] buf	data buffer on which to compute the hash
  * \param[in] buf_len	length of \buf on which to compute hash
  */
-static void cfs_crypto_performance_test(unsigned char hash_alg,
+static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg,
 					const unsigned char *buf,
 					unsigned int buf_len)
 {
@@ -355,7 +355,7 @@ static void cfs_crypto_performance_test(unsigned char hash_alg,
  * \retval		-ENOENT if \a hash_alg is unsupported
  * \retval		negative errno if \a hash_alg speed is unavailable
  */
-int cfs_crypto_hash_speed(unsigned char hash_alg)
+int cfs_crypto_hash_speed(enum cfs_crypto_hash_alg hash_alg)
 {
 	if (hash_alg < CFS_HASH_ALG_MAX)
 		return cfs_crypto_hash_speeds[hash_alg];
-- 
1.7.1
