From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:28 -0500
Subject: [lustre-devel] [PATCH 460/622] lustre: ptlrpc: remove struct
 ptlrpc_bulk_page
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-461-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This structure is never used, so remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 2b9bf4c00bce ("LU-6142 ptlrpc: remove struct ptlrpc_bulk_page")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35879
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index f16c6d3..faf15e9 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1146,22 +1146,6 @@ void _debug_req(struct ptlrpc_request *req,
 } while (0)
 /** @} */
 
-/**
- * Structure that defines a single page of a bulk transfer
- */
-struct ptlrpc_bulk_page {
-	/** Linkage to list of pages in a bulk */
-	struct list_head	bp_link;
-	/**
-	 * Number of bytes in a page to transfer starting from @bp_pageoffset
-	 */
-	int			bp_buflen;
-	/** offset within a page */
-	int			bp_pageoffset;
-	/** The page itself */
-	struct page		*bp_page;
-};
-
 enum ptlrpc_bulk_op_type {
 	PTLRPC_BULK_OP_ACTIVE	= 0x00000001,
 	PTLRPC_BULK_OP_PASSIVE	= 0x00000002,
-- 
1.8.3.1
