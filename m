From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:07 -0500
Subject: [lustre-devel] [PATCH 379/622] lustre: ptlrpc: don't reset
 lru_resize on idle reconnect
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-380-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

ptlrpc_disconnect_idle_interpret() clears imp_remote_handle,
so reconnect has pcaa_initial_connect set to 1.

Update only changed ns_connect_flags bits.

Fixes: 4b102da53ad ("lustre: ptlrpc: idle connections can disconnect")
Cray-bug-id: LUS-7471
WC-bug-id: https://jira.whamcloud.com/browse/LU-11518
Lustre-commit: acacc9d9b1d0 ("LU-11518 ptlrpc: don't reset lru_resize on idle reconnect")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/35285
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 6f13ec1..f8e15f2 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -858,13 +858,17 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 	 * disable lru_resize, etc.
 	 */
 	if (old_connect_flags != exp_connect_flags(exp) || init_connect) {
+		struct ldlm_namespace *ns = imp->imp_obd->obd_namespace;
+		u64 changed_flags;
+
+		changed_flags =
+			ns->ns_connect_flags ^ ns->ns_orig_connect_flags;
 		CDEBUG(D_HA,
 		       "%s: Resetting ns_connect_flags to server flags: %#llx\n",
 		       imp->imp_obd->obd_name, ocd->ocd_connect_flags);
-		imp->imp_obd->obd_namespace->ns_connect_flags =
-			ocd->ocd_connect_flags;
-		imp->imp_obd->obd_namespace->ns_orig_connect_flags =
-			ocd->ocd_connect_flags;
+		ns->ns_connect_flags = (ns->ns_connect_flags & changed_flags) |
+				      (ocd->ocd_connect_flags & ~changed_flags);
+		ns->ns_orig_connect_flags = ocd->ocd_connect_flags;
 	}
 
 	if (ocd->ocd_connect_flags & OBD_CONNECT_AT)
-- 
1.8.3.1
