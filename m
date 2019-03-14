From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:49 +1100
Subject: [lustre-devel] [PATCH 08/32] lustre: ptlrpc: simplify bd_vec access.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230930.26912.11226938812548150863.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Now that there are no kvecs in ptlrpc_bulk_desc, only bdvecs, we can
simplify the access, discarding the containing struct and the macros,
and just accessing the fields directly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |   17 +++++------------
 drivers/staging/lustre/lustre/osc/osc_page.c       |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   12 ++++++------
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |    6 +++---
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   16 ++++++++--------
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |   10 +++++-----
 6 files changed, 28 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index e2cf456fc1cd..d14840b4aeb0 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1224,21 +1224,14 @@ struct ptlrpc_bulk_desc {
 	/** array of associated MDs */
 	struct lnet_handle_md		bd_mds[PTLRPC_BULK_OPS_COUNT];
 
-	struct {
-		/*
-		 * encrypt iov, size is either 0 or bd_iov_count.
-		 */
-		struct bio_vec *bd_enc_vec;
-		struct bio_vec *bd_vec;	/* Array of bio_vecs */
-	} bd_kiov;
+	/*
+	 * encrypt iov, size is either 0 or bd_iov_count.
+	 */
+	struct bio_vec *bd_enc_vec;
+	struct bio_vec *bd_vec;	/* Array of bio_vecs */
 
 };
 
-#define GET_KIOV(desc)			((desc)->bd_kiov.bd_vec)
-#define BD_GET_KIOV(desc, i)		((desc)->bd_kiov.bd_vec[i])
-#define GET_ENC_KIOV(desc)		((desc)->bd_kiov.bd_enc_vec)
-#define BD_GET_ENC_KIOV(desc, i)	((desc)->bd_kiov.bd_enc_vec[i])
-
 enum {
 	SVC_STOPPED     = 1 << 0,
 	SVC_STOPPING    = 1 << 1,
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index e7ee97337bd4..1ee0a7682a5b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -861,7 +861,7 @@ static inline void unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
 	int i;
 
 	for (i = 0; i < page_count; i++) {
-		pg_data_t *pgdat = page_pgdat(BD_GET_KIOV(desc, i).bv_page);
+		pg_data_t *pgdat = page_pgdat(desc->bd_vec[i].bv_page);
 
 		if (likely(pgdat == last)) {
 			++count;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 16ccf2e47d84..a148b1e54712 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -67,7 +67,7 @@ static void ptlrpc_release_bulk_page_pin(struct ptlrpc_bulk_desc *desc)
 	int i;
 
 	for (i = 0; i < desc->bd_iov_count ; i++)
-		put_page(BD_GET_KIOV(desc, i).bv_page);
+		put_page(desc->bd_vec[i].bv_page);
 }
 
 const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_pin_ops = {
@@ -149,9 +149,9 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 	if (!desc)
 		return NULL;
 
-	GET_KIOV(desc) = kcalloc(nfrags, sizeof(*GET_KIOV(desc)),
-				 GFP_NOFS);
-	if (!GET_KIOV(desc))
+	desc->bd_vec = kcalloc(nfrags, sizeof(desc->bd_vec[0]),
+			       GFP_NOFS);
+	if (!desc->bd_vec)
 		goto free_desc;
 
 	spin_lock_init(&desc->bd_lock);
@@ -225,7 +225,7 @@ void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 	LASSERT(len > 0);
 	LASSERT(pageoffset + len <= PAGE_SIZE);
 
-	kiov = &BD_GET_KIOV(desc, desc->bd_iov_count);
+	kiov = &desc->bd_vec[desc->bd_iov_count];
 
 	desc->bd_nob += len;
 
@@ -257,7 +257,7 @@ void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc)
 	if (desc->bd_frag_ops->release_frags)
 		desc->bd_frag_ops->release_frags(desc);
 
-	kfree(GET_KIOV(desc));
+	kfree(desc->bd_vec);
 	kfree(desc);
 }
 EXPORT_SYMBOL(ptlrpc_free_bulk);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index fbc36be51a91..948ece11970f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -57,8 +57,8 @@ void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 	md->length = min_t(unsigned int, LNET_MAX_IOV, md->length);
 
 	md->options |= LNET_MD_KIOV;
-	if (GET_ENC_KIOV(desc))
-		md->start = &BD_GET_ENC_KIOV(desc, offset);
+	if (desc->bd_enc_vec)
+		md->start = &desc->bd_enc_vec[offset];
 	else
-		md->start = &BD_GET_KIOV(desc, offset);
+		md->start = &desc->bd_vec[offset];
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index c3dbcebc16fc..dc2dab8a8d60 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -336,7 +336,7 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 	int p_idx, g_idx;
 	int i;
 
-	if (!GET_ENC_KIOV(desc))
+	if (!desc->bd_enc_vec)
 		return;
 
 	LASSERT(desc->bd_iov_count > 0);
@@ -351,12 +351,12 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 	LASSERT(page_pools.epp_pools[p_idx]);
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
-		LASSERT(BD_GET_ENC_KIOV(desc, i).bv_page);
+		LASSERT(desc->bd_enc_vec[i].bv_page);
 		LASSERT(g_idx != 0 || page_pools.epp_pools[p_idx]);
 		LASSERT(!page_pools.epp_pools[p_idx][g_idx]);
 
 		page_pools.epp_pools[p_idx][g_idx] =
-			BD_GET_ENC_KIOV(desc, i).bv_page;
+			desc->bd_enc_vec[i].bv_page;
 
 		if (++g_idx == PAGES_PER_POOL) {
 			p_idx++;
@@ -370,8 +370,8 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 
 	spin_unlock(&page_pools.epp_lock);
 
-	kfree(GET_ENC_KIOV(desc));
-	GET_ENC_KIOV(desc) = NULL;
+	kfree(desc->bd_enc_vec);
+	desc->bd_enc_vec = NULL;
 }
 
 static inline void enc_pools_alloc(void)
@@ -552,10 +552,10 @@ int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, u8 alg,
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
 		cfs_crypto_hash_update_page(hdesc,
-					    BD_GET_KIOV(desc, i).bv_page,
-					    BD_GET_KIOV(desc, i).bv_offset &
+					    desc->bd_vec[i].bv_page,
+					    desc->bd_vec[i].bv_offset &
 					    ~PAGE_MASK,
-					    BD_GET_KIOV(desc, i).bv_len);
+					    desc->bd_vec[i].bv_len);
 	}
 
 	if (hashsize > buflen) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 0c431eb60ea5..988cbba491cf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -156,13 +156,13 @@ static void corrupt_bulk_data(struct ptlrpc_bulk_desc *desc)
 	unsigned int off, i;
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
-		if (!BD_GET_KIOV(desc, i).bv_len)
+		if (!desc->bd_vec[i].bv_len)
 			continue;
 
-		ptr = kmap(BD_GET_KIOV(desc, i).bv_page);
-		off = BD_GET_KIOV(desc, i).bv_offset & ~PAGE_MASK;
+		ptr = kmap(desc->bd_vec[i].bv_page);
+		off = desc->bd_vec[i].bv_offset & ~PAGE_MASK;
 		ptr[off] ^= 0x1;
-		kunmap(BD_GET_KIOV(desc, i).bv_page);
+		kunmap(desc->bd_vec[i].bv_page);
 		return;
 	}
 }
@@ -354,7 +354,7 @@ int plain_cli_unwrap_bulk(struct ptlrpc_cli_ctx *ctx,
 
 	/* fix the actual data size */
 	for (i = 0, nob = 0; i < desc->bd_iov_count; i++) {
-		struct bio_vec bv_desc = BD_GET_KIOV(desc, i);
+		struct bio_vec bv_desc = desc->bd_vec[i];
 
 		if (bv_desc.bv_len + nob > desc->bd_nob_transferred)
 			bv_desc.bv_len = desc->bd_nob_transferred - nob;
