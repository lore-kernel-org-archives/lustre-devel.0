From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:32 -0500
Subject: [lustre-devel] [PATCH 464/622] lustre: ldlm: remove unused
 ldlm_server_conn
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-465-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is never set or used, so remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 047a6185a1ed ("LU-6142 ldlm: remove unused ldlm_server_conn")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35883
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_internal.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 4844a9b..336d9b7 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -197,7 +197,6 @@ struct ldlm_state {
 	struct ptlrpc_service *ldlm_cb_service;
 	struct ptlrpc_service *ldlm_cancel_service;
 	struct ptlrpc_client *ldlm_client;
-	struct ptlrpc_connection *ldlm_server_conn;
 	struct ldlm_bl_pool *ldlm_bl_pool;
 };
 
-- 
1.8.3.1
