From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:13 -0400
Subject: [lustre-devel] [PATCH 054/151] lustre: ldlm: remove liblustre
 remnants
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-55-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Remove the last remnants of liblustre in the code.
There are still some liblustre remnants in the code (e.g. blocked
lock handling for LDLM_FL_CANCEL_ON_BLOCK), but that has more
complex semantics and should be removed in a separate patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9452
Lustre-commit: 82e794e268be ("LU-9452 ldlm: remove MSG_CONNECT_LIBCLIENT support")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/26972
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm_flags.h |  4 ++--
 fs/lustre/llite/glimpse.c            |  3 +--
 fs/lustre/llite/lcommon_cl.c         |  3 +--
 fs/lustre/llite/lcommon_misc.c       |  3 +--
 fs/lustre/obdclass/cl_object.c       | 12 +++++-------
 fs/lustre/ptlrpc/import.c            | 12 ++++++------
 fs/lustre/ptlrpc/niobuf.c            |  2 +-
 7 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm_flags.h b/fs/lustre/include/lustre_dlm_flags.h
index 2413309..f1f454f 100644
--- a/fs/lustre/include/lustre_dlm_flags.h
+++ b/fs/lustre/include/lustre_dlm_flags.h
@@ -137,8 +137,8 @@
 /**
  * Immediately cancel such locks when they block some other locks. Send
  * cancel notification to original lock holder, but expect no reply. This
- * is for clients (like liblustre) that cannot be expected to reliably
- * response to blocking AST.
+ * is for clients that cannot be expected to reliably response to blocking
+ * AST.
  */
 #define LDLM_FL_CANCEL_ON_BLOCK		0x0000000000800000ULL /* bit 23 */
 #define ldlm_is_cancel_on_block(_l)	LDLM_TEST_FLAG((_l), 1ULL << 23)
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index 56a5094..ed5164a 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -30,8 +30,7 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * glimpse code shared between vvp and liblustre (and other Lustre clients in
- * the future).
+ * glimpse code used by vvp (and other Lustre clients in the future).
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
  *   Author: Oleg Drokin <oleg.drokin@sun.com>
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index cc8d1b2..e859351 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -30,8 +30,7 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * cl code shared between vvp and liblustre (and other Lustre clients in the
- * future).
+ * cl code used by vvp (and other Lustre clients in the future).
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
  */
diff --git a/fs/lustre/llite/lcommon_misc.c b/fs/lustre/llite/lcommon_misc.c
index 75156d8..cafcb4d 100644
--- a/fs/lustre/llite/lcommon_misc.c
+++ b/fs/lustre/llite/lcommon_misc.c
@@ -30,8 +30,7 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * cl code shared between vvp and liblustre (and other Lustre clients in the
- * future).
+ * cl code used by vvp (and other Lustre clients in the future).
  *
  */
 #define DEBUG_SUBSYSTEM S_LLITE
diff --git a/fs/lustre/obdclass/cl_object.c b/fs/lustre/obdclass/cl_object.c
index b4ea585..4a40121 100644
--- a/fs/lustre/obdclass/cl_object.c
+++ b/fs/lustre/obdclass/cl_object.c
@@ -515,18 +515,16 @@ int cl_site_stats_print(const struct cl_site *site, struct seq_file *m)
 
 /**
  * The most efficient way is to store cl_env pointer in task specific
- * structures. On Linux, it wont' be easy to use task_struct->journal_info
- * because Lustre code may call into other fs which has certain assumptions
- * about journal_info. Currently following fields in task_struct are identified
- * can be used for this purpose:
- *  - tux_info: only on RedHat kernel.
- *  - ...
+ * structures. On Linux, it isn't easy to use task_struct->journal_info
+ * because Lustre code may call into other fs during memory reclaim, which
+ * has certain assumptions about journal_info. There are not currently any
+ * fields in task_struct that can be used for this purpose.
  * \note As long as we use task_struct to store cl_env, we assume that once
  * called into Lustre, we'll never call into the other part of the kernel
  * which will use those fields in task_struct without explicitly exiting
  * Lustre.
  *
- * If there's no space in task_struct is available, hash will be used.
+ * Since there's no space in task_struct is available, hash will be used.
  * bz20044, bz22683.
  */
 
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 3cb9b84..e1fc2ef 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -781,7 +781,7 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 		 * of macro arguments
 		 */
 		const char *older = "older than client. Consider upgrading server";
-		const char *newer = "newer than client. Consider recompiling application";
+		const char *newer = "newer than client. Consider upgrading client";
 
 		LCONSOLE_WARN("Server %s version (%d.%d.%d.%d) is much %s (%s)\n",
 			      obd2cli_tgt(imp->imp_obd),
@@ -1237,14 +1237,14 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 
 			ocd = req_capsule_server_get(&request->rq_pill,
 						     &RMF_CONNECT_DATA);
+			/* Servers are not supposed to refuse connections from
+			 * clients based on version, only connection feature
+			 * flags.  We should never see this from llite, but it
+			 * may be useful for debugging in the future.
+			 */
 			if (ocd &&
 			    (ocd->ocd_connect_flags & OBD_CONNECT_VERSION) &&
 			    (ocd->ocd_version != LUSTRE_VERSION_CODE)) {
-				/*
-				 * Actually servers are only supposed to refuse
-				 * connection from liblustre clients, so we
-				 * should never see this from VFS context
-				 */
 				LCONSOLE_ERROR_MSG(0x16a,
 						   "Server %s version (%d.%d.%d.%d) refused connection from this client with an incompatible version (%s).  Client must be recompiled\n",
 						   obd2cli_tgt(imp->imp_obd),
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index f2b7902..7bf78ee 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -256,7 +256,7 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 
 	/* the unlink ensures the callback happens ASAP and is the last
 	 * one.  If it fails, it must be because completion just happened,
-	 * but we must still wait_event() in this case to give liblustre
+	 * but we must still wait_event() in this case to give lustre
 	 * a chance to run client_bulk_callback()
 	 */
 	mdunlink_iterate_helper(desc->bd_mds, desc->bd_md_max_brw);
-- 
1.8.3.1
