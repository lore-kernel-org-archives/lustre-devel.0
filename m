From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:49 -0400
Subject: [lustre-devel] [PATCH 05/12] staging: lustre: libcfs: small
	alignment change for cfs_crypto_hash_*()
In-Reply-To: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
References: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459021256-23857-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Change the aligment of some of the functions.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5053
Reviewed-on: http://review.whamcloud.com/9990
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |   11 ++++++-----
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    4 ++--
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index 921aa7c..ade8894 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -75,7 +75,7 @@ static struct cfs_crypto_hash_type hash_types[] = {
  * \retval	NULL for unknown algorithm identifier
  */
 static inline const struct cfs_crypto_hash_type *
-		    cfs_crypto_hash_type(unsigned char hash_alg)
+cfs_crypto_hash_type(unsigned char hash_alg)
 {
 	struct cfs_crypto_hash_type *ht;
 
@@ -95,7 +95,8 @@ static inline const struct cfs_crypto_hash_type *
  * \retval	string name of known hash algorithm
  * \retval	"unknown" if hash algorithm is unknown
  */
-static inline const char *cfs_crypto_hash_name(unsigned char hash_alg)
+static inline const char *
+cfs_crypto_hash_name(unsigned char hash_alg)
 {
 	const struct cfs_crypto_hash_type *ht;
 
@@ -147,9 +148,9 @@ int cfs_crypto_hash_digest(unsigned char hash_alg,
 /* cfs crypto hash descriptor */
 struct cfs_crypto_hash_desc;
 
-struct cfs_crypto_hash_desc*
-	cfs_crypto_hash_init(unsigned char hash_alg,
-			     unsigned char *key, unsigned int key_len);
+struct cfs_crypto_hash_desc *
+cfs_crypto_hash_init(unsigned char hash_alg,
+		     unsigned char *key, unsigned int key_len);
 int cfs_crypto_hash_update_page(struct cfs_crypto_hash_desc *desc,
 				struct page *page, unsigned int offset,
 				unsigned int len);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index b4e203d..0241729 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -193,8 +193,8 @@ EXPORT_SYMBOL(cfs_crypto_hash_digest);
  * \retval		ERR_PTR(errno) in case of error
  */
 struct cfs_crypto_hash_desc *
-	cfs_crypto_hash_init(unsigned char hash_alg,
-			     unsigned char *key, unsigned int key_len)
+cfs_crypto_hash_init(unsigned char hash_alg,
+		     unsigned char *key, unsigned int key_len)
 {
 	struct ahash_request *req;
 	int		     err;
-- 
1.7.1
