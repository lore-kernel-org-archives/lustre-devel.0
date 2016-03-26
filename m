From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:54 -0400
Subject: [lustre-devel] [PATCH 10/12] staging: lustre: libcfs: print crypto
	performance result only on success
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Only print info about the crypto performance when no error
is encounter.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 4857a11..3d74fd1 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -348,9 +348,10 @@ out_err:
 		tmp = ((bcount * buf_len / jiffies_to_msecs(end - start)) *
 		       1000) / (1024 * 1024);
 		cfs_crypto_hash_speeds[hash_alg] = (int)tmp;
+		CDEBUG(D_CONFIG, "Crypto hash algorithm %s speed = %d MB/s\n",
+		       cfs_crypto_hash_name(hash_alg),
+		       cfs_crypto_hash_speeds[hash_alg]);
 	}
-	CDEBUG(D_INFO, "Crypto hash algorithm %s speed = %d MB/s\n",
-	       cfs_crypto_hash_name(hash_alg), cfs_crypto_hash_speeds[hash_alg]);
 }
 
 /**
-- 
1.7.1
