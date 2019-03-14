From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:48 +1100
Subject: [lustre-devel] [PATCH 02/32] lustre: ptlrpc: remove
 ptlrpc_prep_bulk_frag
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230861.26912.5974069235566954129.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This function is never used, best to discard it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    2 --
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   23 --------------------
 2 files changed, 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 1cf0f127203a..bb251769bf72 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1867,8 +1867,6 @@ struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 					      unsigned int portal,
 					      const struct ptlrpc_bulk_frag_ops *ops);
 
-int ptlrpc_prep_bulk_frag(struct ptlrpc_bulk_desc *desc,
-			  void *frag, int len);
 void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 			     struct page *page, int pageoffset, int len,
 			     int pin);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index e24c9c5eb90d..7170a2ce1bb6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -230,29 +230,6 @@ void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 }
 EXPORT_SYMBOL(__ptlrpc_prep_bulk_page);
 
-int ptlrpc_prep_bulk_frag(struct ptlrpc_bulk_desc *desc,
-			  void *frag, int len)
-{
-	struct kvec *iovec;
-
-	LASSERT(desc->bd_iov_count < desc->bd_max_iov);
-	LASSERT(frag);
-	LASSERT(len > 0);
-	LASSERT(ptlrpc_is_bulk_desc_kvec(desc->bd_type));
-
-	iovec = &BD_GET_KVEC(desc, desc->bd_iov_count);
-
-	desc->bd_nob += len;
-
-	iovec->iov_base = frag;
-	iovec->iov_len = len;
-
-	desc->bd_iov_count++;
-
-	return desc->bd_nob;
-}
-EXPORT_SYMBOL(ptlrpc_prep_bulk_frag);
-
 void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc)
 {
 	LASSERT(desc->bd_iov_count != LI_POISON); /* not freed already */
