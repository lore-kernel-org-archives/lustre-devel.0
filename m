From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:51 -0400
Subject: [lustre-devel] [PATCH 07/12] staging: lustre: libcfs: bug fixes for
	cfs_crypto_hash_final()
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Change cfs_crypto_hash_final() to always clean up the hash descrptor
instead of not doing this in error cases.  All of the callers were
just calling cfs_crypto_hash_final() immediately to clean up the
descriptor anyway, and the old behaviour is unlike other init/fini
functions, and prone to memory leaks and other incorrect usage.  The
callers can call cfs_crypto_digest_size() to determine the hash size
in advance if needed, and avoid complexity in cfs_crypto_hash_final().

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   24 +++++++++----------
 drivers/staging/lustre/lustre/osc/osc_request.c    |    5 +---
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   12 +++++-----
 3 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 6fe1fdd..d5bb10f 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -265,8 +265,8 @@ EXPORT_SYMBOL(cfs_crypto_hash_update);
  * \param[in,out] hash_len	pointer to hash buffer size, if \a hdesc = NULL
  *				only free \a hdesc instead of computing the hash
  *
- * \retval	-ENOSPC if \a hash = NULL, or \a hash_len < digest size
  * \retval	0 for success
+ * \retval	-EOVERFLOW if hash_len is too small for the hash digest
  * \retval	negative errno for other errors from lower layers
  */
 int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *hdesc,
@@ -276,22 +276,20 @@ int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *hdesc,
 	struct ahash_request *req = (void *)hdesc;
 	int size = crypto_ahash_digestsize(crypto_ahash_reqtfm(req));
 
-	if (!hash_len) {
-		crypto_free_ahash(crypto_ahash_reqtfm(req));
-		ahash_request_free(req);
-		return 0;
+	if (!hash || !hash_len) {
+		err = 0;
+		goto free_ahash;
 	}
-	if (!hash || *hash_len < size) {
-		*hash_len = size;
-		return -ENOSPC;
+	if (*hash_len < size) {
+		err = -EOVERFLOW;
+		goto free_ahash;
 	}
+
 	ahash_request_set_crypt(req, NULL, hash, 0);
 	err = crypto_ahash_final(req);
-
-	if (err < 0) {
-		/* May be caller can fix error */
-		return err;
-	}
+	if (!err)
+		*hash_len = size;
+free_ahash:
 	crypto_free_ahash(crypto_ahash_reqtfm(req));
 	ahash_request_free(req);
 	return err;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 74805f1..ec0287f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1208,12 +1208,9 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 		i++;
 	}
 
-	bufsize = 4;
+	bufsize = sizeof(cksum);
 	err = cfs_crypto_hash_final(hdesc, (unsigned char *)&cksum, &bufsize);
 
-	if (err)
-		cfs_crypto_hash_final(hdesc, NULL, NULL);
-
 	/* For sending we only compute the wrong checksum instead
 	 * of corrupting the data so it is still correct on a redo
 	 */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 72d5b9b..54a0c1f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -41,7 +41,6 @@
 #define DEBUG_SUBSYSTEM S_SEC
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include <linux/crypto.h>
 
 #include "../include/obd.h"
 #include "../include/obd_cksum.h"
@@ -511,7 +510,6 @@ int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 {
 	struct cfs_crypto_hash_desc *hdesc;
 	int hashsize;
-	char hashbuf[64];
 	unsigned int bufsize;
 	int i, err;
 
@@ -532,18 +530,20 @@ int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 				  desc->bd_iov[i].kiov_offset & ~CFS_PAGE_MASK,
 				  desc->bd_iov[i].kiov_len);
 	}
+
 	if (hashsize > buflen) {
+		unsigned char hashbuf[CFS_CRYPTO_HASH_DIGESTSIZE_MAX];
+
 		bufsize = sizeof(hashbuf);
-		err = cfs_crypto_hash_final(hdesc, (unsigned char *)hashbuf,
-					    &bufsize);
+		LASSERTF(bufsize >= hashsize, "bufsize = %u < hashsize %u\n",
+			 bufsize, hashsize);
+		err = cfs_crypto_hash_final(hdesc, hashbuf, &bufsize);
 		memcpy(buf, hashbuf, buflen);
 	} else {
 		bufsize = buflen;
 		err = cfs_crypto_hash_final(hdesc, buf, &bufsize);
 	}
 
-	if (err)
-		cfs_crypto_hash_final(hdesc, NULL, NULL);
 	return err;
 }
 EXPORT_SYMBOL(sptlrpc_get_bulk_checksum);
-- 
1.7.1
