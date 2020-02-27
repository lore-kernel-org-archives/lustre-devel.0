From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:02 -0500
Subject: [lustre-devel] [PATCH 194/622] lustre: ptlrpc: connect vs import
 invalidate race
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-195-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

Connect can't be sent while import invalidate is
in progress, thus it leaves the import in not
initialized state.

Don't allow reconnect in evicted state.

Cray-bug-id: LUS-6322
WC-bug-id: https://jira.whamcloud.com/browse/LU-7558
Lustre-commit: b1827ff1da82 ("LU-7558 ptlrpc: connect vs import invalidate race")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/33718
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/ptlrpc/import.c       | 6 ++++++
 fs/lustre/ptlrpc/recover.c      | 2 ++
 3 files changed, 9 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index c2db38f..5ff270a 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -353,6 +353,7 @@
 #define OBD_FAIL_PTLRPC_LONG_REQ_UNLINK			0x51b
 #define OBD_FAIL_PTLRPC_LONG_BOTH_UNLINK		0x51c
 #define OBD_FAIL_PTLRPC_BULK_ATTACH      0x521
+#define OBD_FAIL_PTLRPC_CONNECT_RACE			0x531
 
 #define OBD_FAIL_OBD_PING_NET				0x600
 /*	OBD_FAIL_OBD_LOG_CANCEL_NET	0x601 obsolete since 1.5 */
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 867aff6..df6c459 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -38,6 +38,7 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/kthread.h>
+#include <linux/delay.h>
 #include <linux/fs_struct.h>
 #include <obd_support.h>
 #include <lustre_ha.h>
@@ -273,6 +274,10 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 	if (!imp->imp_invalid || imp->imp_obd->obd_no_recov)
 		ptlrpc_deactivate_import(imp);
 
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_PTLRPC_CONNECT_RACE)) {
+		OBD_RACE(OBD_FAIL_PTLRPC_CONNECT_RACE);
+		msleep(10 * MSEC_PER_SEC);
+	}
 	CFS_FAIL_TIMEOUT(OBD_FAIL_MGS_CONNECT_NET, 3 * cfs_fail_val / 2);
 	LASSERT(imp->imp_invalid);
 
@@ -615,6 +620,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 		CERROR("already connected\n");
 		return 0;
 	} else if (imp->imp_state == LUSTRE_IMP_CONNECTING ||
+		   imp->imp_state == LUSTRE_IMP_EVICTED ||
 		   imp->imp_connected) {
 		spin_unlock(&imp->imp_lock);
 		CERROR("already connecting\n");
diff --git a/fs/lustre/ptlrpc/recover.c b/fs/lustre/ptlrpc/recover.c
index 7c09c4e..ceab288 100644
--- a/fs/lustre/ptlrpc/recover.c
+++ b/fs/lustre/ptlrpc/recover.c
@@ -339,6 +339,8 @@ int ptlrpc_recover_import(struct obd_import *imp, char *new_uuid, int async)
 	if (rc)
 		goto out;
 
+	OBD_RACE(OBD_FAIL_PTLRPC_CONNECT_RACE);
+
 	rc = ptlrpc_connect_import(imp);
 	if (rc)
 		goto out;
-- 
1.8.3.1
