From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:14 -0400
Subject: [lustre-devel] [PATCH 22/31] lustre: libcfs: reduce libcfs checksum
 speed test time
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Loading the libcfs module is getting increasingly slow due to
multiple checksum types being speed tested at startup (8 different
checksums * 1s per checksum).

Reduce the number of checksum algorithms checked at module load
time to the ones that are actually need the speed (i.e. the bulk
data checksums), and reduce the amount of time taken to compute the
checksum. The other checksum types typically do not need the speed,
but rather are selected by the configuration.

Precompute the checksum speeds and supported types for the OST so
they are not recomputed for each new client that connects.

This reduces the module load time from 8.0s to 0.76s in my testing.

Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
WC-id: https://jira.whamcloud.com/browse/LU-9201
Reviewed-on: https://review.whamcloud.com/25923
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |  4 ++-
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c  | 30 +++++++++++++++++-----
 2 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index 176fae7..ca8620b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -46,13 +46,15 @@ enum cfs_crypto_hash_alg {
 	CFS_HASH_ALG_NULL       = 0,
 	CFS_HASH_ALG_ADLER32,
 	CFS_HASH_ALG_CRC32,
+	CFS_HASH_ALG_CRC32C,
+	/* hashes before here will be speed-tested at module load */
 	CFS_HASH_ALG_MD5,
 	CFS_HASH_ALG_SHA1,
 	CFS_HASH_ALG_SHA256,
 	CFS_HASH_ALG_SHA384,
 	CFS_HASH_ALG_SHA512,
-	CFS_HASH_ALG_CRC32C,
 	CFS_HASH_ALG_MAX,
+	CFS_HASH_ALG_SPEED_MAX = CFS_HASH_ALG_MD5,
 	CFS_HASH_ALG_UNKNOWN	= 0xff
 };
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
index cfff54d..b206e3c 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
@@ -300,7 +300,10 @@ int cfs_crypto_hash_final(struct ahash_request *req,
 /**
  * Compute the speed of specified hash function
  *
- * Run a speed test on the given hash algorithm on buffer of the given size.
+ * Run a speed test on the given hash algorithm on buffer using a 1MB buffer
+ * size.  This is a reasonable buffer size for Lustre RPCs, even if the actual
+ * RPC size is larger or smaller.
+ *
  * The speed is stored internally in the cfs_crypto_hash_speeds[] array, and
  * is available through the cfs_crypto_hash_speed() function.
  *
@@ -329,8 +332,8 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 	memset(buf, 0xAD, PAGE_SIZE);
 	kunmap(page);
 
-	for (start = jiffies, end = start + msecs_to_jiffies(MSEC_PER_SEC),
-	     bcount = 0; time_before(jiffies, end); bcount++) {
+	for (start = jiffies, end = start + msecs_to_jiffies(MSEC_PER_SEC / 4),
+	     bcount = 0; time_before(jiffies, end) && err == 0; bcount++) {
 		struct ahash_request *hdesc;
 		int i;
 
@@ -373,8 +376,12 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 /**
  * hash speed in Mbytes per second for valid hash algorithm
  *
- * Return the performance of the specified \a hash_alg that was previously
- * computed using cfs_crypto_performance_test().
+ * Return the performance of the specified \a hash_alg that was
+ * computed using cfs_crypto_performance_test().  If the performance
+ * has not yet been computed, do that when it is first requested.
+ * That avoids computing the speed when it is not actually needed.
+ * To avoid competing threads computing the checksum speed at the
+ * same time, only compute a single checksum speed at one time.
  *
  * \param[in] hash_alg	hash algorithm id (CFS_HASH_ALG_*)
  *
@@ -384,8 +391,17 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
  */
 int cfs_crypto_hash_speed(enum cfs_crypto_hash_alg hash_alg)
 {
-	if (hash_alg < CFS_HASH_ALG_MAX)
+	if (hash_alg < CFS_HASH_ALG_MAX) {
+		if (unlikely(cfs_crypto_hash_speeds[hash_alg] == 0)) {
+			static DEFINE_MUTEX(crypto_hash_speed_mutex);
+
+			mutex_lock(&crypto_hash_speed_mutex);
+			if (cfs_crypto_hash_speeds[hash_alg] == 0)
+				cfs_crypto_performance_test(hash_alg);
+			mutex_unlock(&crypto_hash_speed_mutex);
+		}
 		return cfs_crypto_hash_speeds[hash_alg];
+	}
 	return -ENOENT;
 }
 EXPORT_SYMBOL(cfs_crypto_hash_speed);
@@ -412,7 +428,7 @@ static int cfs_crypto_test_hashes(void)
 {
 	enum cfs_crypto_hash_alg hash_alg;
 
-	for (hash_alg = 0; hash_alg < CFS_HASH_ALG_MAX; hash_alg++)
+	for (hash_alg = 0; hash_alg < CFS_HASH_ALG_SPEED_MAX; hash_alg++)
 		cfs_crypto_performance_test(hash_alg);
 
 	return 0;
-- 
1.8.3.1
