From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:06 -0400
Subject: [lustre-devel] [PATCH 14/31] lustre: llite: buggy special handling
 on MULTIMODRPCS
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

There is some special handling over MULTIMODPRCS flag in
client_connect_import(), it looks unnecessary and buggy,
the MULTIMODPRCS flag would be cleared unexpectedly from
imp_connect_data on reconnect.

This patch removed the special handling code and treat
MULTIMODRPCS normally just like other flags.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-9115
Reviewed-on: https://review.whamcloud.com/25435
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c   | 12 ------------
 drivers/staging/lustre/lustre/llite/llite_lib.c |  2 +-
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 5da8c88..c36d1e4 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -512,7 +512,6 @@ int client_connect_import(const struct lu_env *env,
 	struct obd_import       *imp    = cli->cl_import;
 	struct obd_connect_data *ocd;
 	struct lustre_handle    conn    = { 0 };
-	bool is_mdc = false;
 	int		     rc;
 
 	*exp = NULL;
@@ -539,18 +538,12 @@ int client_connect_import(const struct lu_env *env,
 	ocd = &imp->imp_connect_data;
 	if (data) {
 		*ocd = *data;
-		is_mdc = !strncmp(imp->imp_obd->obd_type->typ_name,
-				  LUSTRE_MDC_NAME, 3);
-		if (is_mdc)
-			data->ocd_connect_flags |= OBD_CONNECT_MULTIMODRPCS;
 		imp->imp_connect_flags_orig = data->ocd_connect_flags;
 		imp->imp_connect_flags2_orig = data->ocd_connect_flags2;
 	}
 
 	rc = ptlrpc_connect_import(imp);
 	if (rc != 0) {
-		if (data && is_mdc)
-			data->ocd_connect_flags &= ~OBD_CONNECT_MULTIMODRPCS;
 		LASSERT(imp->imp_state == LUSTRE_IMP_DISCON);
 		goto out_ldlm;
 	}
@@ -561,11 +554,6 @@ int client_connect_import(const struct lu_env *env,
 			 ocd->ocd_connect_flags, "old %#llx, new %#llx\n",
 			 data->ocd_connect_flags, ocd->ocd_connect_flags);
 		data->ocd_connect_flags = ocd->ocd_connect_flags;
-		/* clear the flag as it was not set and is not known
-		 * by upper layers
-		 */
-		if (is_mdc)
-			data->ocd_connect_flags &= ~OBD_CONNECT_MULTIMODRPCS;
 	}
 
 	ptlrpc_pinger_add_import(imp);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 71eb42d..ccb5bda 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -211,7 +211,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_DIR_STRIPE |
 				  OBD_CONNECT_BULK_MBITS |
 				  OBD_CONNECT_SUBTREE |
-				  OBD_CONNECT_FLAGS2;
+				  OBD_CONNECT_FLAGS2 | OBD_CONNECT_MULTIMODRPCS;
 
 	data->ocd_connect_flags2 = 0;
 
-- 
1.8.3.1
