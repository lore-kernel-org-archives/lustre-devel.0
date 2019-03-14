From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:49 +1100
Subject: [lustre-devel] [PATCH 04/32] lustre: ptlrpc: remove inline on
 non-inlined functions.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230889.26912.4651696996284556901.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These three functions are never inlined.  The only time they
are used, their address is taken, and this forces them to
be compiled as stand-alone functions.  So having the "inline"
declaration is misleading.

Move the functions to the place where their address is used, and
remove the 'inline' tag.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |   21 -------------------
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   22 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 430ad8bb2226..591c4edaa10e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1870,30 +1870,9 @@ struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 			     struct page *page, int pageoffset, int len,
 			     int pin);
-static inline void ptlrpc_prep_bulk_page_pin(struct ptlrpc_bulk_desc *desc,
-					     struct page *page, int pageoffset,
-					     int len)
-{
-	__ptlrpc_prep_bulk_page(desc, page, pageoffset, len, 1);
-}
-
-static inline void ptlrpc_prep_bulk_page_nopin(struct ptlrpc_bulk_desc *desc,
-					       struct page *page, int pageoffset,
-					       int len)
-{
-	__ptlrpc_prep_bulk_page(desc, page, pageoffset, len, 0);
-}
 
 void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *bulk);
 
-static inline void ptlrpc_release_bulk_page_pin(struct ptlrpc_bulk_desc *desc)
-{
-	int i;
-
-	for (i = 0; i < desc->bd_iov_count ; i++)
-		put_page(BD_GET_KIOV(desc, i).bv_page);
-}
-
 void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 				      struct obd_import *imp);
 u64 ptlrpc_next_xid(void);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index c17fde56d004..a602fa4e5340 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -48,6 +48,28 @@
 
 #include "ptlrpc_internal.h"
 
+static void ptlrpc_prep_bulk_page_pin(struct ptlrpc_bulk_desc *desc,
+				      struct page *page, int pageoffset,
+				      int len)
+{
+	__ptlrpc_prep_bulk_page(desc, page, pageoffset, len, 1);
+}
+
+static void ptlrpc_prep_bulk_page_nopin(struct ptlrpc_bulk_desc *desc,
+					struct page *page, int pageoffset,
+					int len)
+{
+	__ptlrpc_prep_bulk_page(desc, page, pageoffset, len, 0);
+}
+
+static void ptlrpc_release_bulk_page_pin(struct ptlrpc_bulk_desc *desc)
+{
+	int i;
+
+	for (i = 0; i < desc->bd_iov_count ; i++)
+		put_page(BD_GET_KIOV(desc, i).bv_page);
+}
+
 const struct ptlrpc_bulk_frag_ops ptlrpc_bulk_kiov_pin_ops = {
 	.add_kiov_frag		= ptlrpc_prep_bulk_page_pin,
 	.release_frags		= ptlrpc_release_bulk_page_pin,
