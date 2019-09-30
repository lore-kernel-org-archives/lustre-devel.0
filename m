From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:47 -0400
Subject: [lustre-devel] [PATCH 088/151] lnet: libcfs: call proper crypto
 algo when keys are passed in
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-89-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In most cases keys are not passed to cfs_crypto_hash_alloc()
but if they are then crypto_ahash_setkey() will fail. Keys
are only handled by the hmac version of the algorithm requested.
If a key is passed into cfs_crypto_hash_alloc() then we should
request the hmac version of the algorithm when calling
crypto_alloc_ahash().

WC-bug-id: https://jira.whamcloud.com/browse/LU-8602
Lustre-commit: 53e967746f37 ("LU-8602 libcfs: call proper crypto algo when keys are passed in")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/25199
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/linux-crypto.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/lnet/libcfs/linux-crypto.c b/net/lnet/libcfs/linux-crypto.c
index 1c96dc6..53285c2 100644
--- a/net/lnet/libcfs/linux-crypto.c
+++ b/net/lnet/libcfs/linux-crypto.c
@@ -70,14 +70,27 @@ static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 	int err = 0;
 
 	*type = cfs_crypto_hash_type(hash_alg);
-
 	if (!*type) {
 		CWARN("Unsupported hash algorithm id = %d, max id is %d\n",
 		      hash_alg, CFS_HASH_ALG_MAX);
 		return -EINVAL;
 	}
-	tfm = crypto_alloc_ahash((*type)->cht_name, 0, CRYPTO_ALG_ASYNC);
 
+	/* Keys are only supported for the hmac version */
+	if (key && key_len > 0) {
+		char *algo_name;
+
+		algo_name = kasprintf(GFP_KERNEL, "hmac(%s)",
+				      (*type)->cht_name);
+		if (!algo_name)
+			return -ENOMEM;
+
+		tfm = crypto_alloc_ahash(algo_name, 0, CRYPTO_ALG_ASYNC);
+		kfree(algo_name);
+	} else {
+		tfm = crypto_alloc_ahash((*type)->cht_name, 0,
+					 CRYPTO_ALG_ASYNC);
+	}
 	if (IS_ERR(tfm)) {
 		CDEBUG(D_INFO, "Failed to alloc crypto hash %s\n",
 		       (*type)->cht_name);
@@ -88,8 +101,8 @@ static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 	if (!*req) {
 		CDEBUG(D_INFO, "Failed to alloc ahash_request for %s\n",
 		       (*type)->cht_name);
-		crypto_free_ahash(tfm);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto out_free_tfm;
 	}
 
 	ahash_request_set_callback(*req, 0, NULL, NULL);
@@ -100,12 +113,8 @@ static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 		err = crypto_ahash_setkey(tfm,
 					  (unsigned char *)&((*type)->cht_key),
 					  (*type)->cht_size);
-
-	if (err) {
-		ahash_request_free(*req);
-		crypto_free_ahash(tfm);
-		return err;
-	}
+	if (err)
+		goto out_free_req;
 
 	CDEBUG(D_INFO, "Using crypto hash: %s (%s) speed %d MB/s\n",
 	       crypto_ahash_alg_name(tfm), crypto_ahash_driver_name(tfm),
@@ -113,7 +122,9 @@ static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 
 	err = crypto_ahash_init(*req);
 	if (err) {
+out_free_req:
 		ahash_request_free(*req);
+out_free_tfm:
 		crypto_free_ahash(tfm);
 	}
 	return err;
-- 
1.8.3.1
