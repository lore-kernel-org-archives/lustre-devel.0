From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:10 -0400
Subject: [lustre-devel] [PATCH 051/151] lustre: mdc: use generic grant code
 at MDT
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-52-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

Now that we have files on the MDT server we need to
expand the mdc layer to handle grant space. Export
osc_reconnect() and osc_disconnect() for the mdc
layer. Indicate that we support grants on MDT with
the client by adding OBD_CONNECT_GRANT_PARAM.

WC--bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 0697cf73c74d ("LU-3285 mdt: use generic grant code at MDT")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28021
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  5 ++++-
 fs/lustre/llite/llite_lib.c    |  3 ++-
 fs/lustre/mdc/mdc_request.c    |  3 ++-
 fs/lustre/osc/osc_request.c    | 12 ++++++------
 4 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 2a16197..3d83fa5 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -647,7 +647,10 @@ int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		       struct ptlrpc_request_set *set);
 int osc_ldlm_resource_invalidate(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 				 struct hlist_node *hnode, void *arg);
-
+int osc_reconnect(const struct lu_env *env, struct obd_export *exp,
+		  struct obd_device *obd, struct obd_uuid *cluuid,
+		  struct obd_connect_data *data, void *localdata);
+int osc_disconnect(struct obd_export *exp);
 int osc_punch_send(struct obd_export *exp, struct obdo *oa,
 		   obd_enqueue_update_f upcall, void *cookie);
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index a02ac03..beacaeb 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -205,7 +205,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_DIR_STRIPE |
 				  OBD_CONNECT_BULK_MBITS | OBD_CONNECT_CKSUM |
 				  OBD_CONNECT_SUBTREE	 |
-				  OBD_CONNECT_FLAGS2	 | OBD_CONNECT_MULTIMODRPCS;
+				  OBD_CONNECT_MULTIMODRPCS |
+				  OBD_CONNECT_GRANT_PARAM | OBD_CONNECT_FLAGS2;
 
 	data->ocd_connect_flags2 = 0;
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 85eb0ec..655f1c2 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2596,7 +2596,8 @@ int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 	.add_conn		= client_import_add_conn,
 	.del_conn		= client_import_del_conn,
 	.connect		= client_connect_import,
-	.disconnect		= client_disconnect_export,
+	.reconnect		= osc_reconnect,
+	.disconnect		= osc_disconnect,
 	.iocontrol		= mdc_iocontrol,
 	.set_info_async		= mdc_set_info_async,
 	.statfs			= mdc_statfs,
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 7e3f954..33555ed 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2633,11 +2633,9 @@ int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 }
 EXPORT_SYMBOL(osc_set_info_async);
 
-static int osc_reconnect(const struct lu_env *env,
-			 struct obd_export *exp, struct obd_device *obd,
-			 struct obd_uuid *cluuid,
-			 struct obd_connect_data *data,
-			 void *localdata)
+int osc_reconnect(const struct lu_env *env, struct obd_export *exp,
+		  struct obd_device *obd, struct obd_uuid *cluuid,
+		  struct obd_connect_data *data, void *localdata)
 {
 	struct client_obd *cli = &obd->u.cli;
 
@@ -2663,8 +2661,9 @@ static int osc_reconnect(const struct lu_env *env,
 
 	return 0;
 }
+EXPORT_SYMBOL(osc_reconnect);
 
-static int osc_disconnect(struct obd_export *exp)
+int osc_disconnect(struct obd_export *exp)
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	int rc;
@@ -2691,6 +2690,7 @@ static int osc_disconnect(struct obd_export *exp)
 		osc_del_shrink_grant(&obd->u.cli);
 	return rc;
 }
+EXPORT_SYMBOL(osc_disconnect);
 
 int osc_ldlm_resource_invalidate(struct cfs_hash *hs,
 				 struct cfs_hash_bd *bd,
-- 
1.8.3.1
