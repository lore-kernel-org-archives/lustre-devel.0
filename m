From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:03 -0400
Subject: [lustre-devel] [PATCH 044/151] lustre: mdt: IO request handling in
 MDT
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-45-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

Add methods to handle IO requests in MDT similar to OFD.
Introduce MDS_INODEBITS_DOM bit for data on MDT, destinguish
IO requests to MDT and OST and take appropriate lock in
target code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 2bcc5ad0ed6a ("LU-3285 mdt: IO request handling in MDT")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28013
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h         |  3 +++
 fs/lustre/llite/llite_lib.c            | 12 +++++++-----
 fs/lustre/mdc/mdc_request.c            | 19 +++++++++++++++++--
 fs/lustre/osc/osc_request.c            |  3 ++-
 include/uapi/linux/lustre/lustre_idl.h |  5 +++--
 5 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index e91fae2..f14ae85 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -512,6 +512,9 @@ int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
 int osc_object_glimpse(const struct lu_env *env, const struct cl_object *obj,
 		       struct ost_lvb *lvb);
 
+/* osc_request.c */
+void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd);
+
 /****************************************************************************
  *
  * Accessors and type conversions.
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 3896dc7..418f464 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -187,7 +187,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	/* indicate MDT features supported by this client */
 	data->ocd_connect_flags = OBD_CONNECT_IBITS	| OBD_CONNECT_NODEVOH  |
-				  OBD_CONNECT_ATTRFID	|
+				  OBD_CONNECT_ATTRFID	| OBD_CONNECT_GRANT    |
 				  OBD_CONNECT_VERSION	| OBD_CONNECT_BRW_SIZE |
 				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID      |
 				  OBD_CONNECT_AT	| OBD_CONNECT_LOV_V3   |
@@ -201,10 +201,10 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_FLOCK_DEAD  |
 				  OBD_CONNECT_DISP_STRIPE | OBD_CONNECT_LFSCK |
 				  OBD_CONNECT_OPEN_BY_FID |
-				  OBD_CONNECT_DIR_STRIPE  |
-				  OBD_CONNECT_BULK_MBITS  |
-				  OBD_CONNECT_SUBTREE	  |
-				  OBD_CONNECT_FLAGS2	  | OBD_CONNECT_MULTIMODRPCS;
+				  OBD_CONNECT_DIR_STRIPE |
+				  OBD_CONNECT_BULK_MBITS | OBD_CONNECT_CKSUM |
+				  OBD_CONNECT_SUBTREE	 |
+				  OBD_CONNECT_FLAGS2	 | OBD_CONNECT_MULTIMODRPCS;
 
 	data->ocd_connect_flags2 = 0;
 
@@ -215,6 +215,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT_LARGE_ACL;
 #endif
 
+	data->ocd_cksum_types = cksum_types_supported_client();
+
 	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_LIGHTWEIGHT))
 		/* flag mdc connection as lightweight, only used for test
 		 * purpose, use with care
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index eefaf44..96e0d0a 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -54,6 +54,7 @@
 #include <uapi/linux/lustre/lustre_param.h>
 #include <lustre_swab.h>
 #include <obd_class.h>
+#include <lustre_osc.h>
 
 #include "mdc_internal.h"
 
@@ -2354,6 +2355,15 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 	LASSERT(imp->imp_obd == obd);
 
 	switch (event) {
+	case IMP_EVENT_DISCON: {
+		struct client_obd *cli = &obd->u.cli;
+
+		spin_lock(&cli->cl_loi_list_lock);
+		cli->cl_avail_grant = 0;
+		cli->cl_lost_grant = 0;
+		spin_unlock(&cli->cl_loi_list_lock);
+		break;
+	}
 	case IMP_EVENT_INACTIVE: {
 		struct client_obd *cli = &obd->u.cli;
 		/*
@@ -2384,10 +2394,15 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 						       mdc_hsm_ct_reregister,
 						       (void *)imp);
 		break;
-	case IMP_EVENT_OCD:
+	case IMP_EVENT_OCD: {
+		struct obd_connect_data *ocd = &imp->imp_connect_data;
+
+		if (OCD_HAS_FLAG(ocd, GRANT))
+			osc_init_grant(&obd->u.cli, ocd);
+
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD);
 		break;
-	case IMP_EVENT_DISCON:
+	}
 	case IMP_EVENT_DEACTIVATE:
 	case IMP_EVENT_ACTIVATE:
 		break;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index b84856d..96d2c01 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -897,7 +897,7 @@ static int osc_del_shrink_grant(struct client_obd *client)
 					 TIMEOUT_GRANT);
 }
 
-static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
+void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 {
 	/*
 	 * ocd_grant is the total grant amount we're expect to hold: if we've
@@ -953,6 +953,7 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	    list_empty(&cli->cl_grant_shrink_list))
 		osc_add_shrink_grant(cli);
 }
+EXPORT_SYMBOL(osc_init_grant);
 
 /* We assume that the reason this OSC got a short read is because it read
  * beyond the end of a stripe file; i.e. lustre is reading a sparse file
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index ec19d31..bcbe557 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -100,7 +100,7 @@
 #define MDC_REPLY_PORTAL	10
 /*#define MDC_BULK_PORTAL	11 */
 #define MDS_REQUEST_PORTAL	12
-/*#define MDS_REPLY_PORTAL	13 */
+#define MDS_IO_PORTAL		13
 #define MDS_BULK_PORTAL		14
 #define LDLM_CB_REQUEST_PORTAL	15
 #define LDLM_CB_REPLY_PORTAL	16
@@ -1429,8 +1429,9 @@ enum mdt_reint_cmd {
  */
 #define MDS_INODELOCK_PERM	0x000010
 #define MDS_INODELOCK_XATTR	0x000020	/* extended attributes */
+#define MDS_INODELOCK_DOM    0x000040 /* Data for data-on-mdt files */
 
-#define MDS_INODELOCK_MAXSHIFT 5
+#define MDS_INODELOCK_MAXSHIFT 6
 /* This FULL lock is useful to take on unlink sort of operations */
 #define MDS_INODELOCK_FULL ((1 << (MDS_INODELOCK_MAXSHIFT + 1)) - 1)
 
-- 
1.8.3.1
