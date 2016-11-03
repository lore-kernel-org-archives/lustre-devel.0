From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:24:52 -0400
Subject: [lustre-devel] [PATCH 02/14] staging/lustre/ldlm: fix export
	reference problem
In-Reply-To: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1478136304-867780-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Hongchao Zhang <hongchao.zhang@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Hongchao Zhang <hongchao.zhang@intel.com>

1, in client_import_del_conn, the export returned from
   class_conn2export is not released after using it.

2, in ptlrpc_connect_interpret, the export is not released
   if the connect_flags isn't compatible.

Signed-off-by: Hongchao Zhang <hongchao.zhang@intel.com>
Reviewed-on: http://review.whamcloud.com/22031
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8500
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c |  3 +++
 drivers/staging/lustre/lustre/ptlrpc/import.c | 19 ++++++++++---------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 4f9480e..06d3cc6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -170,6 +170,9 @@ int client_import_del_conn(struct obd_import *imp, struct obd_uuid *uuid)
 				ptlrpc_connection_put(dlmexp->exp_connection);
 				dlmexp->exp_connection = NULL;
 			}
+
+			if (dlmexp)
+				class_export_put(dlmexp);
 		}
 
 		list_del(&imp_conn->oic_item);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 46ba5a4..05fd92d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -972,6 +972,16 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 
 	spin_unlock(&imp->imp_lock);
 
+	if (!exp) {
+		/* This could happen if export is cleaned during the
+		 * connect attempt
+		 */
+		CERROR("%s: missing export after connect\n",
+		       imp->imp_obd->obd_name);
+		rc = -ENODEV;
+		goto out;
+	}
+
 	/* check that server granted subset of flags we asked for. */
 	if ((ocd->ocd_connect_flags & imp->imp_connect_flags_orig) !=
 	    ocd->ocd_connect_flags) {
@@ -982,15 +992,6 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		goto out;
 	}
 
-	if (!exp) {
-		/* This could happen if export is cleaned during the
-		 * connect attempt
-		 */
-		CERROR("%s: missing export after connect\n",
-		       imp->imp_obd->obd_name);
-		rc = -ENODEV;
-		goto out;
-	}
 	old_connect_flags = exp_connect_flags(exp);
 	exp->exp_connect_data = *ocd;
 	imp->imp_obd->obd_self_export->exp_connect_data = *ocd;
-- 
2.7.4
