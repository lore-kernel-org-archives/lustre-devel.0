From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 22:12:19 -0400
Subject: [lustre-devel] [PATCH 07/10] lustre: ptlrpc: remove inline on
 non-inlined functions.
In-Reply-To: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
References: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563761542-3708-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

These three functions are never inlined.  The only time they
are used, their address is taken, and this forces them to
be compiled as stand-alone functions.  So having the "inline"
declaration is misleading.

Move the functions to the place where their address is used, and
remove the 'inline' tag.

Signed-off-by: NeilBrown <neilb@suse.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4423
Reviewed-on: https://review.whamcloud.com/35296
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 21 ---------------------
 fs/lustre/ptlrpc/client.c      | 22 ++++++++++++++++++++++
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 83f8aff..f7bd8ad 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1872,30 +1872,9 @@ int ptlrpc_prep_bulk_frag(struct ptlrpc_bulk_desc *desc,
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
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index ff1fa68..5f3dc3f 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
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
-- 
1.8.3.1
