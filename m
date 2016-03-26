From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:56 -0400
Subject: [lustre-devel] [PATCH 12/12] staging: lustre: libcfs: calculate
	crypto performance using pages
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Use alloc_page() and use cfs_crypto_hash_update_page()
to compute the hash instead of cfs_crypto_hash_digest(), since
tgt_checksum_bulk() computes the hash by page anyway.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5279
Reviewed-on: http://review.whamcloud.com/10982
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Alexander Boyko <alexander_boyko@xyratex.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index aec7916..f8383dc 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -330,8 +330,23 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 
 	for (start = jiffies, end = start + sec * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
-		err = cfs_crypto_hash_digest(hash_alg, buf, buf_len, NULL, 0,
-					     hash, &hash_len);
+		struct cfs_crypto_hash_desc *hdesc;
+		int i;
+
+		hdesc = cfs_crypto_hash_init(hash_alg, NULL, 0);
+		if (IS_ERR(hdesc)) {
+			err = PTR_ERR(hdesc);
+			break;
+		}
+
+		for (i = 0; i < buf_len / PAGE_SIZE; i++) {
+			err = cfs_crypto_hash_update_page(hdesc, page, 0,
+							  PAGE_SIZE);
+			if (err)
+				break;
+		}
+
+		err = cfs_crypto_hash_final(hdesc, hash, &hash_len);
 		if (err)
 			break;
 	}
-- 
1.7.1
