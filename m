From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:12 -0400
Subject: [lustre-devel] [PATCH 35/45] lustre: osc: Do not wait for grants
 for too long
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

obd_timeout is way too long considering we are holding a lock
that might be contended. If OST is slow to respond, we might
get evicted, so limit us to a half of the shortest possible
max wait a server might have before switching to synchronous IO.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13131
Lustre-commit: 1eee11c75ca13 ("LU-13131 osc: Do not wait for grants for too long")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38283
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |  2 ++
 fs/lustre/ldlm/ldlm_request.c  |  1 +
 fs/lustre/osc/osc_cache.c      | 13 ++++++++++++-
 3 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index f67b612..174b314 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1320,6 +1320,8 @@ int ldlm_cli_cancel_list(struct list_head *head, int count,
 			 enum ldlm_cancel_flags flags);
 /** @} ldlm_cli_api */
 
+extern unsigned int ldlm_enqueue_min;
+
 int ldlm_inodebits_drop(struct ldlm_lock *lock, u64 to_drop);
 int ldlm_cli_inodebits_convert(struct ldlm_lock *lock,
 			       enum ldlm_cancel_flags cancel_flags);
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 5f06def..12ee241 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -69,6 +69,7 @@
 unsigned int ldlm_enqueue_min = OBD_TIMEOUT_DEFAULT;
 module_param(ldlm_enqueue_min, uint, 0644);
 MODULE_PARM_DESC(ldlm_enqueue_min, "lock enqueue timeout minimum");
+EXPORT_SYMBOL(ldlm_enqueue_min);
 
 /* in client side, whether the cached locks will be canceled before replay */
 unsigned int ldlm_cancel_unused_locks_before_replay = 1;
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 9e28ff6..c7f1502 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -39,6 +39,7 @@
 #define DEBUG_SUBSYSTEM S_OSC
 
 #include <lustre_osc.h>
+#include <lustre_dlm.h>
 
 #include "osc_internal.h"
 
@@ -1630,10 +1631,20 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 {
 	struct osc_object *osc = oap->oap_obj;
 	struct lov_oinfo *loi = osc->oo_oinfo;
-	unsigned long timeout = (AT_OFF ? obd_timeout : at_max) * HZ;
 	int rc = -EDQUOT;
 	int remain;
 	bool entered = false;
+	/* We cannot wait for a long time here since we are holding ldlm lock
+	 * across the actual IO. If no requests complete fast (e.g. due to
+	 * overloaded OST that takes a long time to process everything, we'd
+	 * get evicted if we wait for a normal obd_timeout or some such.
+	 * So we try to wait half the time it would take the client to be
+	 * evicted by server which is half obd_timeout when AT is off
+	 * or at least ldlm_enqueue_min with AT on.
+	 * See LU-13131
+	 */
+	unsigned long timeout = (AT_OFF ? obd_timeout / 2 :
+					  ldlm_enqueue_min / 2) * HZ;
 
 	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
 
-- 
1.8.3.1
