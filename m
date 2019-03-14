From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:49 +1100
Subject: [lustre-devel] [PATCH 07/32] lustre: ptlrpc: remove *GET*KIOV
 macros and fields.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230922.26912.4252335480706472434.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The bd_vec and bd_enc_vec fields are no longer used,
so discard the fields and macros that access them.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |   34 +++++++-------------
 1 file changed, 12 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 1bf2c61c1fd4..e2cf456fc1cd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1224,30 +1224,20 @@ struct ptlrpc_bulk_desc {
 	/** array of associated MDs */
 	struct lnet_handle_md		bd_mds[PTLRPC_BULK_OPS_COUNT];
 
-	union {
-		struct {
-			/*
-			 * encrypt iov, size is either 0 or bd_iov_count.
-			 */
-			struct bio_vec *bd_enc_vec;
-			struct bio_vec *bd_vec;	/* Array of bio_vecs */
-		} bd_kiov;
-
-		struct {
-			struct kvec *bd_enc_kvec;
-			struct kvec *bd_kvec;	/* Array of kvecs */
-		} bd_kvec;
-	} bd_u;
+	struct {
+		/*
+		 * encrypt iov, size is either 0 or bd_iov_count.
+		 */
+		struct bio_vec *bd_enc_vec;
+		struct bio_vec *bd_vec;	/* Array of bio_vecs */
+	} bd_kiov;
+
 };
 
-#define GET_KIOV(desc)			((desc)->bd_u.bd_kiov.bd_vec)
-#define BD_GET_KIOV(desc, i)		((desc)->bd_u.bd_kiov.bd_vec[i])
-#define GET_ENC_KIOV(desc)		((desc)->bd_u.bd_kiov.bd_enc_vec)
-#define BD_GET_ENC_KIOV(desc, i)	((desc)->bd_u.bd_kiov.bd_enc_vec[i])
-#define GET_KVEC(desc)			((desc)->bd_u.bd_kvec.bd_kvec)
-#define BD_GET_KVEC(desc, i)		((desc)->bd_u.bd_kvec.bd_kvec[i])
-#define GET_ENC_KVEC(desc)		((desc)->bd_u.bd_kvec.bd_enc_kvec)
-#define BD_GET_ENC_KVEC(desc, i)	((desc)->bd_u.bd_kvec.bd_enc_kvec[i])
+#define GET_KIOV(desc)			((desc)->bd_kiov.bd_vec)
+#define BD_GET_KIOV(desc, i)		((desc)->bd_kiov.bd_vec[i])
+#define GET_ENC_KIOV(desc)		((desc)->bd_kiov.bd_enc_vec)
+#define BD_GET_ENC_KIOV(desc, i)	((desc)->bd_kiov.bd_enc_vec[i])
 
 enum {
 	SVC_STOPPED     = 1 << 0,
