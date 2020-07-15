From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:46 -0400
Subject: [lustre-devel] [PATCH 05/37] lustre: ptlrpc: handle conn_hash
 rhashtable resize
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The errors returned by rhashtable_lookup_get_insert_fast() of the
values -ENOMEM or -EBUSY is due to the hashtable being resized.
This is not fatal so retry a lookup.

Fixes: ac2370ac2b ("staging: lustre: ptlrpc: convert conn_hash to rhashtable")
WC-bug-id: https://jira.whamcloud.com/browse/LU-8130
Lustre-commit: 37b29a8f709aa ("LU-8130 ptlrpc: convert conn_hash to rhashtable")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/33616
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/ptlrpc/connection.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/connection.c b/fs/lustre/ptlrpc/connection.c
index 5466755..a548d99 100644
--- a/fs/lustre/ptlrpc/connection.c
+++ b/fs/lustre/ptlrpc/connection.c
@@ -32,6 +32,8 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
+
+#include <linux/delay.h>
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_net.h>
@@ -103,13 +105,21 @@ struct ptlrpc_connection *
 	 * connection.  The object which exists in the hash will be
 	 * returned, otherwise NULL is returned on success.
 	 */
+try_again:
 	conn2 = rhashtable_lookup_get_insert_fast(&conn_hash, &conn->c_hash,
 						  conn_hash_params);
 	if (conn2) {
 		/* insertion failed */
 		kfree(conn);
-		if (IS_ERR(conn2))
+		if (IS_ERR(conn2)) {
+			/* hash table could be resizing. */
+			if (PTR_ERR(conn2) == -ENOMEM ||
+			    PTR_ERR(conn2) == -EBUSY) {
+				msleep(20);
+				goto try_again;
+			}
 			return NULL;
+		}
 		conn = conn2;
 		ptlrpc_connection_addref(conn);
 	}
-- 
1.8.3.1
