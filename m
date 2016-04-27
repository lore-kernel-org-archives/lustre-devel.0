From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:21:00 -0400
Subject: [lustre-devel] [PATCH 08/15] staging: lustre: ldlm: update comments
	about ldlm l_flags
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruce Korb <bruce.korb@gmail.com>, James Simmons <jsimmons@infradead.org>

From: Bruce Korb <bruce.korb@gmail.com>

Add and update documentation about some of the ldlm l_flags.

Signed-off-by: Bruce Korb <bruce.korb@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2906
Reviewed-by: Keith Mannthey <Keith.Mannthey@intel.com>
Reviewed-on: http://review.whamcloud.com/7963
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre_dlm_flags.h       |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index 1eb0cc4..e7e0c21 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -198,7 +198,7 @@
 #define ldlm_set_cancel(_l)             LDLM_SET_FLAG((_l), 1ULL << 36)
 #define ldlm_clear_cancel(_l)           LDLM_CLEAR_FLAG((_l), 1ULL << 36)
 
-/** whatever it might mean */
+/** whatever it might mean -- never transmitted? */
 #define LDLM_FL_LOCAL_ONLY              0x0000002000000000ULL /* bit 37 */
 #define ldlm_is_local_only(_l)          LDLM_TEST_FLAG((_l), 1ULL << 37)
 #define ldlm_set_local_only(_l)         LDLM_SET_FLAG((_l), 1ULL << 37)
@@ -281,18 +281,18 @@
  * has canceled this lock and is waiting for rpc_lock which is taken by
  * the first operation. LDLM_FL_BL_AST is set by ldlm_callback_handler() in
  * the lock to prevent the Early Lock Cancel (ELC) code from cancelling it.
- *
- * LDLM_FL_BL_DONE is to be set by ldlm_cancel_callback() when lock cache is
- * dropped to let ldlm_callback_handler() return EINVAL to the server. It
- * is used when ELC RPC is already prepared and is waiting for rpc_lock,
- * too late to send a separate CANCEL RPC.
  */
 #define LDLM_FL_BL_AST                  0x0000400000000000ULL /* bit 46 */
 #define ldlm_is_bl_ast(_l)              LDLM_TEST_FLAG((_l), 1ULL << 46)
 #define ldlm_set_bl_ast(_l)             LDLM_SET_FLAG((_l), 1ULL << 46)
 #define ldlm_clear_bl_ast(_l)           LDLM_CLEAR_FLAG((_l), 1ULL << 46)
 
-/** whatever it might mean */
+/**
+ * Set by ldlm_cancel_callback() when lock cache is dropped to let
+ * ldlm_callback_handler() return EINVAL to the server. It is used when
+ * ELC RPC is already prepared and is waiting for rpc_lock, too late to
+ * send a separate CANCEL RPC.
+ */
 #define LDLM_FL_BL_DONE                 0x0000800000000000ULL /* bit 47 */
 #define ldlm_is_bl_done(_l)             LDLM_TEST_FLAG((_l), 1ULL << 47)
 #define ldlm_set_bl_done(_l)            LDLM_SET_FLAG((_l), 1ULL << 47)
-- 
1.7.1
