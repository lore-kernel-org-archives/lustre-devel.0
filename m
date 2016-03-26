From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:53 -0400
Subject: [lustre-devel] [PATCH 09/12] staging: lustre: libcfs: allocate
	memory in cfs_crypto_performance_test()
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Move memory allocation from cfs_crypto_test_hashes() into the
function cfs_crypto_performance_test().

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   40 +++++++++----------
 1 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 90d6e08..4857a11 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -307,16 +307,27 @@ EXPORT_SYMBOL(cfs_crypto_hash_final);
  * \param[in] buf	data buffer on which to compute the hash
  * \param[in] buf_len	length of \buf on which to compute hash
  */
-static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg,
-					const unsigned char *buf,
-					unsigned int buf_len)
+static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 {
+	int buf_len = max(PAGE_SIZE, 1048576UL);
+	void *buf;
 	unsigned long		   start, end;
 	int			     bcount, err = 0;
 	int			     sec = 1; /* do test only 1 sec */
+	struct page *page;
 	unsigned char hash[CFS_CRYPTO_HASH_DIGESTSIZE_MAX];
 	unsigned int hash_len = sizeof(hash);
 
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
 	for (start = jiffies, end = start + sec * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		err = cfs_crypto_hash_digest(hash_alg, buf, buf_len, NULL, 0,
@@ -325,7 +336,8 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg,
 			break;
 	}
 	end = jiffies;
-
+	__free_page(page);
+out_err:
 	if (err) {
 		cfs_crypto_hash_speeds[hash_alg] =  -1;
 		CDEBUG(D_INFO, "Crypto hash algorithm %s, err = %d\n",
@@ -381,25 +393,11 @@ EXPORT_SYMBOL(cfs_crypto_hash_speed);
  */
 static int cfs_crypto_test_hashes(void)
 {
-	unsigned char	   i;
-	unsigned char	   *data;
-	unsigned int	    j;
-	/* Data block size for testing hash. Maximum
-	 * kmalloc size for 2.6.18 kernel is 128K
-	 */
-	unsigned int	    data_len = 1 * 128 * 1024;
-
-	data = kmalloc(data_len, 0);
-	if (!data)
-		return -ENOMEM;
-
-	for (j = 0; j < data_len; j++)
-		data[j] = j & 0xff;
+	enum cfs_crypto_hash_alg hash_alg;
 
-	for (i = 0; i < CFS_HASH_ALG_MAX; i++)
-		cfs_crypto_performance_test(i, data, data_len);
+	for (hash_alg = 0; hash_alg < CFS_HASH_ALG_MAX; hash_alg++)
+		cfs_crypto_performance_test(hash_alg);
 
-	kfree(data);
 	return 0;
 }
 
-- 
1.7.1
