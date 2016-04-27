From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:20:58 -0400
Subject: [lustre-devel] [PATCH 06/15] staging: lustre: ldlm: clean up l_flags
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruce Korb <bruce.korb@gmail.com>, James Simmons <jsimmons@infradead.org>

From: Bruce Korb <bruce.korb@gmail.com>

Remove the now obsolete LDLM_AST_FLAGS and LDLM_INHERIT_FLAGS defines.
Remove the obsolete LDLM_FL_HIDE_LOCK_MASK define.
Rename "local_only" mask to "off_wire" since it is confusingly similar
to a flag that (I think) means, "do not copy this lock over the wire."

Signed-off-by: Bruce Korb <bruce.korb@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2906
Reviewed-by: Keith Mannthey <Keith.Mannthey@intel.com>
Reviewed-on: http://review.whamcloud.com/7963
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre_dlm_flags.h       |   16 ++--------------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    2 +-
 3 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index aff0904..62d3b31 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -37,17 +37,11 @@
 /** l_flags bits marked as "gone" bits */
 #define LDLM_FL_GONE_MASK               0x0006004000000000ULL
 
-/** l_flags bits marked as "hide_lock" bits */
-#define LDLM_FL_HIDE_LOCK_MASK          0x0000206400000000ULL
-
 /** l_flags bits marked as "inherit" bits */
 #define LDLM_FL_INHERIT_MASK            0x0000000000800000ULL
 
-/** l_flags bits marked as "local_only" bits */
-#define LDLM_FL_LOCAL_ONLY_MASK         0x00FFFFFF00000000ULL
-
-/** l_flags bits marked as "on_wire" bits */
-#define LDLM_FL_ON_WIRE_MASK            0x00000000C08F932FULL
+/** l_flags bits marked as "off_wire" bits */
+#define LDLM_FL_OFF_WIRE_MASK           0x00FFFFFF00000000ULL
 
 /** extent, mode, or resource changed */
 #define LDLM_FL_LOCK_CHANGED            0x0000000000000001ULL /* bit 0 */
@@ -390,12 +384,6 @@
 /** clear a ldlm_lock flag bit */
 #define LDLM_CLEAR_FLAG(_l, _b)       ((_l)->l_flags &= ~(_b))
 
-/** Mask of flags inherited from parent lock when doing intents. */
-#define LDLM_INHERIT_FLAGS            LDLM_FL_INHERIT_MASK
-
-/** Mask of Flags sent in AST lock_flags to map into the receiving lock. */
-#define LDLM_AST_FLAGS                LDLM_FL_AST_MASK
-
 /** @} subgroup */
 /** @} group */
 #ifdef WIRESHARK_COMPILE
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 024185b..ab739f0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -632,7 +632,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 	/* Copy hints/flags (e.g. LDLM_FL_DISCARD_DATA) from AST. */
 	lock_res_and_lock(lock);
 	lock->l_flags |= ldlm_flags_from_wire(dlm_req->lock_flags &
-					      LDLM_AST_FLAGS);
+					      LDLM_FL_AST_MASK);
 	if (lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK) {
 		/* If somebody cancels lock and cache is already dropped,
 		 * or lock is failed before cp_ast received on client,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 0e4ab2c..107314e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -421,7 +421,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 
 	*flags = ldlm_flags_from_wire(reply->lock_flags);
 	lock->l_flags |= ldlm_flags_from_wire(reply->lock_flags &
-					      LDLM_INHERIT_FLAGS);
+					      LDLM_FL_INHERIT_MASK);
 	/* move NO_TIMEOUT flag to the lock to force ldlm_lock_match()
 	 * to wait with no timeout as well
 	 */
-- 
1.7.1
