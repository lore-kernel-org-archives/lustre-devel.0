From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:49 +1100
Subject: [lustre-devel] [PATCH 06/32] lustre: ptlrpc: discard BULK_BUF types
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230912.26912.9137198915483706306.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Now that all BULK bufs are KIOV, we can discard all the
tests for this, and discard the flags themselves.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |   14 --------------
 drivers/staging/lustre/lustre/osc/osc_page.c       |    2 --
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   12 +++---------
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |   18 +++++-------------
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    2 --
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |    2 --
 6 files changed, 8 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index a01ab99a2b5c..1bf2c61c1fd4 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1110,8 +1110,6 @@ enum ptlrpc_bulk_op_type {
 	PTLRPC_BULK_OP_PASSIVE	= 0x00000002,
 	PTLRPC_BULK_OP_PUT	= 0x00000004,
 	PTLRPC_BULK_OP_GET	= 0x00000008,
-	PTLRPC_BULK_BUF_KVEC	= 0x00000010,
-	PTLRPC_BULK_BUF_KIOV	= 0x00000020,
 	PTLRPC_BULK_GET_SOURCE	= PTLRPC_BULK_OP_PASSIVE | PTLRPC_BULK_OP_GET,
 	PTLRPC_BULK_PUT_SINK	= PTLRPC_BULK_OP_PASSIVE | PTLRPC_BULK_OP_PUT,
 	PTLRPC_BULK_GET_SINK	= PTLRPC_BULK_OP_ACTIVE | PTLRPC_BULK_OP_GET,
@@ -1143,18 +1141,6 @@ static inline bool ptlrpc_is_bulk_put_source(enum ptlrpc_bulk_op_type type)
 	return (type & PTLRPC_BULK_PUT_SOURCE) == PTLRPC_BULK_PUT_SOURCE;
 }
 
-static inline bool ptlrpc_is_bulk_desc_kvec(enum ptlrpc_bulk_op_type type)
-{
-	return ((type & PTLRPC_BULK_BUF_KVEC) | (type & PTLRPC_BULK_BUF_KIOV))
-		== PTLRPC_BULK_BUF_KVEC;
-}
-
-static inline bool ptlrpc_is_bulk_desc_kiov(enum ptlrpc_bulk_op_type type)
-{
-	return ((type & PTLRPC_BULK_BUF_KVEC) | (type & PTLRPC_BULK_BUF_KIOV))
-		== PTLRPC_BULK_BUF_KIOV;
-}
-
 static inline bool ptlrpc_is_bulk_op_active(enum ptlrpc_bulk_op_type type)
 {
 	return ((type & PTLRPC_BULK_OP_ACTIVE) |
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index ce911b82512d..e7ee97337bd4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -860,8 +860,6 @@ static inline void unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
 	int count = 0;
 	int i;
 
-	LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
-
 	for (i = 0; i < page_count; i++) {
 		pg_data_t *pgdat = page_pgdat(BD_GET_KIOV(desc, i).bv_page);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 53f49c6408cc..16ccf2e47d84 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -159,7 +159,7 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 	desc->bd_max_iov = nfrags;
 	desc->bd_iov_count = 0;
 	desc->bd_portal = portal;
-	desc->bd_type = type | PTLRPC_BULK_BUF_KIOV;
+	desc->bd_type = type;
 	desc->bd_md_count = 0;
 	desc->bd_frag_ops = ops;
 	LASSERT(max_brw > 0);
@@ -224,7 +224,6 @@ void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 	LASSERT(pageoffset >= 0);
 	LASSERT(len > 0);
 	LASSERT(pageoffset + len <= PAGE_SIZE);
-	LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
 
 	kiov = &BD_GET_KIOV(desc, desc->bd_iov_count);
 
@@ -248,8 +247,7 @@ void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc)
 	LASSERT((desc->bd_export != NULL) ^ (desc->bd_import != NULL));
 	LASSERT(desc->bd_frag_ops);
 
-	if (ptlrpc_is_bulk_desc_kiov(desc->bd_type))
-		sptlrpc_enc_pool_put_pages(desc);
+	sptlrpc_enc_pool_put_pages(desc);
 
 	if (desc->bd_export)
 		class_export_put(desc->bd_export);
@@ -259,11 +257,7 @@ void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc)
 	if (desc->bd_frag_ops->release_frags)
 		desc->bd_frag_ops->release_frags(desc);
 
-	if (ptlrpc_is_bulk_desc_kiov(desc->bd_type))
-		kfree(GET_KIOV(desc));
-	else
-		kfree(GET_KVEC(desc));
-
+	kfree(GET_KIOV(desc));
 	kfree(desc);
 }
 EXPORT_SYMBOL(ptlrpc_free_bulk);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index 2466868afb9c..fbc36be51a91 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -56,17 +56,9 @@ void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 	md->length = max(0, desc->bd_iov_count - mdidx * LNET_MAX_IOV);
 	md->length = min_t(unsigned int, LNET_MAX_IOV, md->length);
 
-	if (ptlrpc_is_bulk_desc_kiov(desc->bd_type)) {
-		md->options |= LNET_MD_KIOV;
-		if (GET_ENC_KIOV(desc))
-			md->start = &BD_GET_ENC_KIOV(desc, offset);
-		else
-			md->start = &BD_GET_KIOV(desc, offset);
-	} else {
-		md->options |= LNET_MD_IOVEC;
-		if (GET_ENC_KVEC(desc))
-			md->start = &BD_GET_ENC_KVEC(desc, offset);
-		else
-			md->start = &BD_GET_KVEC(desc, offset);
-	}
+	md->options |= LNET_MD_KIOV;
+	if (GET_ENC_KIOV(desc))
+		md->start = &BD_GET_ENC_KIOV(desc, offset);
+	else
+		md->start = &BD_GET_KIOV(desc, offset);
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 74cfdd8e486b..c3dbcebc16fc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -336,8 +336,6 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 	int p_idx, g_idx;
 	int i;
 
-	LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
-
 	if (!GET_ENC_KIOV(desc))
 		return;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 021bf7fcf559..0c431eb60ea5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -155,8 +155,6 @@ static void corrupt_bulk_data(struct ptlrpc_bulk_desc *desc)
 	char *ptr;
 	unsigned int off, i;
 
-	LASSERT(ptlrpc_is_bulk_desc_kiov(desc->bd_type));
-
 	for (i = 0; i < desc->bd_iov_count; i++) {
 		if (!BD_GET_KIOV(desc, i).bv_len)
 			continue;
