From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:55 -0400
Subject: [lustre-devel] [PATCH 11/12] staging: lustre: libcfs: improve
	reporting error for crypto performance
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Set cfs_crypto_hash_speeds[X] result to the actual error instead
of -1. Make the error message more clear and informative.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 3d74fd1..aec7916 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -339,8 +339,8 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 	__free_page(page);
 out_err:
 	if (err) {
-		cfs_crypto_hash_speeds[hash_alg] =  -1;
-		CDEBUG(D_INFO, "Crypto hash algorithm %s, err = %d\n",
+		cfs_crypto_hash_speeds[hash_alg] = err;
+		CDEBUG(D_INFO, "Crypto hash algorithm %s test error: rc = %d\n",
 		       cfs_crypto_hash_name(hash_alg), err);
 	} else {
 		unsigned long   tmp;
-- 
1.7.1
