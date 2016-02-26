From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:50:13 -0500
Subject: [lustre-devel] [PATCH 25/25] staging/lustre/ptlrpc: Fix
	ENABLE_PINGER ifdef
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-26-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

As it is ENABLE_PINGER is never defined, but in reality
it's the code that is now compiled out that should be used
since all other instances were converted like that too.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/import.c | 28 ---------------------------
 1 file changed, 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 9a9c4d3..041e7ce 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -433,7 +433,6 @@ EXPORT_SYMBOL(ptlrpc_fail_import);
 
 int ptlrpc_reconnect_import(struct obd_import *imp)
 {
-#ifdef ENABLE_PINGER
 	struct l_wait_info lwi;
 	int secs = cfs_time_seconds(obd_timeout);
 	int rc;
@@ -449,33 +448,6 @@ int ptlrpc_reconnect_import(struct obd_import *imp)
 	CDEBUG(D_HA, "%s: recovery finished s:%s\n", obd2cli_tgt(imp->imp_obd),
 	       ptlrpc_import_state_name(imp->imp_state));
 	return rc;
-#else
-	ptlrpc_set_import_discon(imp, 0);
-	/* Force a new connect attempt */
-	ptlrpc_invalidate_import(imp);
-	/* Do a fresh connect next time by zeroing the handle */
-	ptlrpc_disconnect_import(imp, 1);
-	/* Wait for all invalidate calls to finish */
-	if (atomic_read(&imp->imp_inval_count) > 0) {
-		int rc;
-		struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
-
-		rc = l_wait_event(imp->imp_recovery_waitq,
-				  (atomic_read(&imp->imp_inval_count) == 0),
-				  &lwi);
-		if (rc)
-			CERROR("Interrupted, inval=%d\n",
-			       atomic_read(&imp->imp_inval_count));
-	}
-
-	/* Allow reconnect attempts */
-	imp->imp_obd->obd_no_recov = 0;
-	/* Remove 'invalid' flag */
-	ptlrpc_activate_import(imp);
-	/* Attempt a new connect */
-	ptlrpc_recover_import(imp, NULL, 0);
-	return 0;
-#endif
 }
 EXPORT_SYMBOL(ptlrpc_reconnect_import);
 
-- 
2.1.0
