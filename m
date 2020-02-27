From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:18 -0500
Subject: [lustre-devel] [PATCH 510/622] lustre: ptlrpc: return proper error
 code
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-511-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

from ptlrpc_disconnect_prep_req() using ERR_PTR()
as the callers expect.

Fixes: 4b102da53ad ("lustre: ptlrpc: idle connections can disconnect")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12799
Lustre-commit: 9e2620d75cce ("LU-12799 ptlrpc: return proper error code")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36282
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index c4a732d..76a40be 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1571,7 +1571,7 @@ static struct ptlrpc_request *ptlrpc_disconnect_prep_req(struct obd_import *imp)
 	req = ptlrpc_request_alloc_pack(imp, &RQF_MDS_DISCONNECT,
 					LUSTRE_OBD_VERSION, rq_opc);
 	if (!req)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 
 	/* We are disconnecting, do not retry a failed DISCONNECT rpc if
 	 * it fails.  We can get through the above with a down server
-- 
1.8.3.1
