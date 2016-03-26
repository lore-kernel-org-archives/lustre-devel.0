From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:48 -0400
Subject: [lustre-devel] [PATCH 04/12] staging: lustre: libcfs: add new
	definitions for cfs_crypto api
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Add CFS_HASH_ALG_UNKOWN for unknown hash names instead of
using "0xFF" directly. Define the max digestsize the cfs
crypto api can handle.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |    9 +++++++--
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    4 ++--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index 0782bfb..921aa7c 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -46,7 +46,8 @@ enum cfs_crypto_hash_alg {
 	CFS_HASH_ALG_SHA384,
 	CFS_HASH_ALG_SHA512,
 	CFS_HASH_ALG_CRC32C,
-	CFS_HASH_ALG_MAX
+	CFS_HASH_ALG_MAX,
+	CFS_HASH_ALG_UNKNOWN	= 0xff
 };
 
 static struct cfs_crypto_hash_type hash_types[] = {
@@ -59,8 +60,12 @@ static struct cfs_crypto_hash_type hash_types[] = {
 	[CFS_HASH_ALG_SHA256]  = { "sha256",   0,     32 },
 	[CFS_HASH_ALG_SHA384]  = { "sha384",   0,     48 },
 	[CFS_HASH_ALG_SHA512]  = { "sha512",   0,     64 },
+	[CFS_HASH_ALG_MAX]	= { NULL,	0,	64 },
 };
 
+/* Maximum size of hash_types[].cht_size */
+#define CFS_CRYPTO_HASH_DIGESTSIZE_MAX	64
+
 /**
  * Return hash algorithm information for the specified algorithm identifier
  *
@@ -131,7 +136,7 @@ static inline unsigned char cfs_crypto_hash_alg(const char *algname)
 	for (i = 0; i < CFS_HASH_ALG_MAX; i++)
 		if (!strcmp(hash_types[i].cht_name, algname))
 			break;
-	return (i == CFS_HASH_ALG_MAX ? 0xFF : i);
+	return (i == CFS_HASH_ALG_MAX ? CFS_HASH_ALG_UNKNOWN : i);
 }
 
 int cfs_crypto_hash_digest(unsigned char hash_alg,
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 1a9eb77..b4e203d 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -316,8 +316,8 @@ static void cfs_crypto_performance_test(unsigned char hash_alg,
 	unsigned long		   start, end;
 	int			     bcount, err = 0;
 	int			     sec = 1; /* do test only 1 sec */
-	unsigned char		   hash[64];
-	unsigned int		    hash_len = 64;
+	unsigned char hash[CFS_CRYPTO_HASH_DIGESTSIZE_MAX];
+	unsigned int hash_len = sizeof(hash);
 
 	for (start = jiffies, end = start + sec * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
-- 
1.7.1
