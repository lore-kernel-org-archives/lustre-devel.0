From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:31 -0500
Subject: [lustre-devel] [PATCH 523/622] lustre: ptlrpc: grammar fix.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-524-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Zarochentsev <c17826@cray.com>

ptlrpc_invalidate_import() error message grammar fix.

Cray-bug-id: LUS-4015
WC-bug-id: https://jira.whamcloud.com/browse/LU-12370
Lustre-commit: 316eddce9382 ("LU-12370 ptlrpc: grammar fix.")
Signed-off-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-on: https://review.whamcloud.com/36508
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Stephan Thiell <sthiell@stanford.edu>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Colin Faber <cfaber@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 76a40be..813d3c8 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -381,7 +381,7 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 						  "still on delayed list");
 				}
 
-				CERROR("%s: Unregistering RPCs found (%d). Network is sluggish? Waiting them to error out.\n",
+				CERROR("%s: Unregistering RPCs found (%d). Network is sluggish? Waiting for them to error out.\n",
 				       cli_tgt,
 				       atomic_read(&imp->imp_unregistering));
 			}
-- 
1.8.3.1
