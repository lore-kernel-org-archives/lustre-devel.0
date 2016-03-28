From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:27 -0400
Subject: [lustre-devel] [PATCH 7/9] staging: lustre: libcfs: replace direct
	HZ access with kernel APIs
In-Reply-To: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
References: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459124789-20758-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jian Yu <jian.yu@intel.com>

From: Jian Yu <jian.yu@intel.com>

On some customers' systems, the kernel was compiled with HZ defined
to 100, instead of 1000. This improves performance for HPC applications.
However, to use these systems with Lustre, customers have to re-build
Lustre for the kernel because Lustre directly uses the defined constant
HZ.

Since kernel 2.6.21, some non-HZ dependent timing APIs become non-
inline functions, which can be used in Lustre codes to replace the
direct HZ access.

These kernel APIs include:
  jiffies_to_msecs()
  jiffies_to_usecs()
  jiffies_to_timespec()
  msecs_to_jiffies()
  usecs_to_jiffies()
  timespec_to_jiffies()

 And here are some samples of the replacement:
  HZ            -> msecs_to_jiffies(MSEC_PER_SEC)
  n * HZ        -> msecs_to_jiffies(n * MSEC_PER_SEC)
  HZ / n        -> msecs_to_jiffies(MSEC_PER_SEC / n)
  n / HZ        -> jiffies_to_msecs(n) / MSEC_PER_SEC
  n / HZ * 1000 -> jiffies_to_msecs(n)

This patch replaces the direct HZ access in the libcfs module.

Signed-off-by: Jian Yu <jian.yu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5443
Reviewed-on: http://review.whamcloud.com/11993
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/linux/linux-time.h |    4 ++--
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
index ed8764b..7656b09 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
@@ -70,12 +70,12 @@ static inline unsigned long cfs_time_current(void)
 
 static inline long cfs_time_seconds(int seconds)
 {
-	return ((long)seconds) * HZ;
+	return ((long)seconds) * msecs_to_jiffies(MSEC_PER_SEC);
 }
 
 static inline long cfs_duration_sec(long d)
 {
-	return d / HZ;
+	return d / msecs_to_jiffies(MSEC_PER_SEC);
 }
 
 #define cfs_time_current_64 get_jiffies_64
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index f8383dc..0715101 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -313,7 +313,6 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 	void *buf;
 	unsigned long		   start, end;
 	int			     bcount, err = 0;
-	int			     sec = 1; /* do test only 1 sec */
 	struct page *page;
 	unsigned char hash[CFS_CRYPTO_HASH_DIGESTSIZE_MAX];
 	unsigned int hash_len = sizeof(hash);
@@ -328,8 +327,8 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 	memset(buf, 0xAD, PAGE_SIZE);
 	kunmap(page);
 
-	for (start = jiffies, end = start + sec * HZ, bcount = 0;
-	     time_before(jiffies, end); bcount++) {
+	for (start = jiffies, end = start + msecs_to_jiffies(MSEC_PER_SEC),
+	     bcount = 0; time_before(jiffies, end); bcount++) {
 		struct cfs_crypto_hash_desc *hdesc;
 		int i;
 
-- 
1.7.1
