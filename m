From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:25 -0500
Subject: [lustre-devel] [PATCH 18/22] staging: lustre: import: don't
	reconnect during connect interpret
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Mikhal Pershin <mike.pershin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Mikhal Pershin <mike.pershin@intel.com>

The import connect flags might be cleared by ptlrpc_connect_import()
wrongly if there is still connect interpret function is running.

Use imp_connected boolean variable to indicate that we are still
interpretting connect reply and don't try to reconnect until it ends.

Signed-off-by: Mikhal Pershin <mike.pershin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7558
Reviewed-on: http://review.whamcloud.com/19312
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_import.h  |    4 +++-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   16 +++++++++++++++-
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 4499c69..f0c931c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -299,7 +299,9 @@ struct obd_import {
 				   */
 				  imp_force_reconnect:1,
 				  /* import has tried to connect with server */
-				  imp_connect_tried:1;
+				  imp_connect_tried:1,
+				 /* connected but not FULL yet */
+				 imp_connected:1;
 	__u32		     imp_connect_op;
 	struct obd_connect_data   imp_connect_data;
 	__u64		     imp_connect_flags_orig;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 66f5b49..e828019 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -622,7 +622,8 @@ int ptlrpc_connect_import(struct obd_import *imp)
 		spin_unlock(&imp->imp_lock);
 		CERROR("already connected\n");
 		return 0;
-	} else if (imp->imp_state == LUSTRE_IMP_CONNECTING) {
+	} else if (imp->imp_state == LUSTRE_IMP_CONNECTING ||
+		   imp->imp_connected) {
 		spin_unlock(&imp->imp_lock);
 		CERROR("already connecting\n");
 		return -EALREADY;
@@ -971,6 +972,13 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		ptlrpc_maybe_ping_import_soon(imp);
 		goto out;
 	}
+
+	/*
+	 * LU-7558: indicate that we are interpretting connect reply,
+	 * pltrpc_connect_import() will not try to reconnect until
+	 * interpret will finish.
+	 */
+	imp->imp_connected = 1;
 	spin_unlock(&imp->imp_lock);
 
 	LASSERT(imp->imp_conn_current);
@@ -1194,12 +1202,18 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		       obd2cli_tgt(imp->imp_obd),
 		       imp->imp_connection->c_remote_uuid.uuid);
 		ptlrpc_connect_import(imp);
+		spin_lock(&imp->imp_lock);
+		imp->imp_connected = 0;
 		imp->imp_connect_tried = 1;
+		spin_unlock(&imp->imp_lock);
 		return 0;
 	}
 
 out:
+	spin_lock(&imp->imp_lock);
+	imp->imp_connected = 0;
 	imp->imp_connect_tried = 1;
+	spin_unlock(&imp->imp_lock);
 
 	if (rc != 0) {
 		IMPORT_SET_STATE(imp, LUSTRE_IMP_DISCON);
-- 
1.7.1
