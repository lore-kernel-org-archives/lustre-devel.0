From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:39 -0400
Subject: [lustre-devel] [PATCH 080/151] lustre: ldlm: assume
 OBD_CONNECT_IBITS
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-81-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Clients and MDSs have supported and required OBD_CONNECT_IBITS since
before 1.6 so remove obsolete code to handle clients that do not
support this flag.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8402
Lustre-commit: c7a833830de6 ("LU-8402 ldlm: assume OBD_CONNECT_IBITS")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30009
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c          | 17 +++++++++--------
 fs/lustre/ptlrpc/import.c              | 10 ----------
 include/uapi/linux/lustre/lustre_idl.h |  4 ++--
 3 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 65c3558..eb99279 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -445,14 +445,15 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			}
 			LDLM_DEBUG(lock, "client-side enqueue, new resource");
 		}
-		if (with_policy)
-			if (!(type == LDLM_IBITS &&
-			      !(exp_connect_flags(exp) & OBD_CONNECT_IBITS)))
-				/* We assume lock type cannot change on server*/
-				ldlm_convert_policy_to_local(exp,
-							     lock->l_resource->lr_type,
-							     &reply->lock_desc.l_policy_data,
-							     &lock->l_policy_data);
+
+		if (with_policy) {
+			/* We assume lock type cannot change on server*/
+			ldlm_convert_policy_to_local(exp,
+						     lock->l_resource->lr_type,
+						     &reply->lock_desc.l_policy_data,
+						     &lock->l_policy_data);
+		}
+
 		if (type != LDLM_PLAIN)
 			LDLM_DEBUG(lock,
 				   "client-side enqueue, new policy data");
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 32aceb9..6e2af7f 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -754,16 +754,6 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 	struct client_obd *cli = &imp->imp_obd->u.cli;
 	static bool warned;
 
-	if ((imp->imp_connect_flags_orig & OBD_CONNECT_IBITS) &&
-	    !(ocd->ocd_connect_flags & OBD_CONNECT_IBITS)) {
-		LCONSOLE_WARN("%s: MDS %s does not support ibits lock, either very old or invalid: requested %#llx, replied %#llx\n",
-			      imp->imp_obd->obd_name,
-			      imp->imp_connection->c_remote_uuid.uuid,
-			      imp->imp_connect_flags_orig,
-			      ocd->ocd_connect_flags);
-		return -EPROTO;
-	}
-
 	spin_lock(&imp->imp_lock);
 	list_del(&imp->imp_conn_current->oic_item);
 	list_add(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index c23d1cb..078ad6c 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -702,7 +702,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT_LARGE_ACL		0x200ULL /* more than 32 ACL entries */
 #define OBD_CONNECT_TRUNCLOCK		0x400ULL /*locks on server for punch */
 #define OBD_CONNECT_TRANSNO		0x800ULL /*replay sends init transno */
-#define OBD_CONNECT_IBITS	       0x1000ULL /*support for inodebits locks*/
+#define OBD_CONNECT_IBITS	       0x1000ULL /* not checked in 2.11+ */
 #define OBD_CONNECT_JOIN	       0x2000ULL /*files can be concatenated.
 						  *We do not support JOIN FILE
 						  *anymore, reserve this flags
@@ -809,7 +809,7 @@ struct ptlrpc_body_v2 {
 	(!!((ocd)->ocd_connect_flags & OBD_CONNECT_##flg))
 
 /* Features required for this version of the client to work with server */
-#define CLIENT_CONNECT_MDT_REQD (OBD_CONNECT_IBITS | OBD_CONNECT_FID | \
+#define CLIENT_CONNECT_MDT_REQD (OBD_CONNECT_FID |	\
 				 OBD_CONNECT_FULL20)
 
 /* This structure is used for both request and reply.
-- 
1.8.3.1
