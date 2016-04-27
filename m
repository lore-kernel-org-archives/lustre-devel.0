From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:20:59 -0400
Subject: [lustre-devel] [PATCH 07/15] staging: lustre: ldlm: remove code
	wireshark handling
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruce Korb <bruce.korb@gmail.com>, James Simmons <jsimmons@infradead.org>

From: Bruce Korb <bruce.korb@gmail.com>

Wireshark output moved to userland file "lustre_dlm_flags_wshark.c"
and only bits that can actually appear "on the wire" are emitted.
The user land "packet-lustre.c" code that references these bits
now gets emitted into that file. e.g. the "local_only" bit is
never put on the wire, so references to it in wireshark are gone.

Signed-off-by: Bruce Korb <bruce.korb@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2906
Reviewed-by: Keith Mannthey <Keith.Mannthey@intel.com>
Reviewed-on: http://review.whamcloud.com/7963
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre_dlm_flags.h       |   87 +-------------------
 1 files changed, 1 insertions(+), 86 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index 62d3b31..1eb0cc4 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -386,90 +386,5 @@
 
 /** @} subgroup */
 /** @} group */
-#ifdef WIRESHARK_COMPILE
-static int hf_lustre_ldlm_fl_lock_changed        = -1;
-static int hf_lustre_ldlm_fl_block_granted       = -1;
-static int hf_lustre_ldlm_fl_block_conv          = -1;
-static int hf_lustre_ldlm_fl_block_wait          = -1;
-static int hf_lustre_ldlm_fl_ast_sent            = -1;
-static int hf_lustre_ldlm_fl_replay              = -1;
-static int hf_lustre_ldlm_fl_intent_only         = -1;
-static int hf_lustre_ldlm_fl_has_intent          = -1;
-static int hf_lustre_ldlm_fl_flock_deadlock      = -1;
-static int hf_lustre_ldlm_fl_discard_data        = -1;
-static int hf_lustre_ldlm_fl_no_timeout          = -1;
-static int hf_lustre_ldlm_fl_block_nowait        = -1;
-static int hf_lustre_ldlm_fl_test_lock           = -1;
-static int hf_lustre_ldlm_fl_cancel_on_block     = -1;
-static int hf_lustre_ldlm_fl_deny_on_contention  = -1;
-static int hf_lustre_ldlm_fl_ast_discard_data    = -1;
-static int hf_lustre_ldlm_fl_fail_loc            = -1;
-static int hf_lustre_ldlm_fl_skipped             = -1;
-static int hf_lustre_ldlm_fl_cbpending           = -1;
-static int hf_lustre_ldlm_fl_wait_noreproc       = -1;
-static int hf_lustre_ldlm_fl_cancel              = -1;
-static int hf_lustre_ldlm_fl_local_only          = -1;
-static int hf_lustre_ldlm_fl_failed              = -1;
-static int hf_lustre_ldlm_fl_canceling           = -1;
-static int hf_lustre_ldlm_fl_local               = -1;
-static int hf_lustre_ldlm_fl_lvb_ready           = -1;
-static int hf_lustre_ldlm_fl_kms_ignore          = -1;
-static int hf_lustre_ldlm_fl_cp_reqd             = -1;
-static int hf_lustre_ldlm_fl_cleaned             = -1;
-static int hf_lustre_ldlm_fl_atomic_cb           = -1;
-static int hf_lustre_ldlm_fl_bl_ast              = -1;
-static int hf_lustre_ldlm_fl_bl_done             = -1;
-static int hf_lustre_ldlm_fl_no_lru              = -1;
-static int hf_lustre_ldlm_fl_fail_notified       = -1;
-static int hf_lustre_ldlm_fl_destroyed           = -1;
-static int hf_lustre_ldlm_fl_server_lock         = -1;
-static int hf_lustre_ldlm_fl_res_locked          = -1;
-static int hf_lustre_ldlm_fl_waited              = -1;
-static int hf_lustre_ldlm_fl_ns_srv              = -1;
-static int hf_lustre_ldlm_fl_excl                = -1;
-
-const value_string lustre_ldlm_flags_vals[] = {
-	{LDLM_FL_LOCK_CHANGED,        "LDLM_FL_LOCK_CHANGED"},
-	{LDLM_FL_BLOCK_GRANTED,       "LDLM_FL_BLOCK_GRANTED"},
-	{LDLM_FL_BLOCK_CONV,          "LDLM_FL_BLOCK_CONV"},
-	{LDLM_FL_BLOCK_WAIT,          "LDLM_FL_BLOCK_WAIT"},
-	{LDLM_FL_AST_SENT,            "LDLM_FL_AST_SENT"},
-	{LDLM_FL_REPLAY,              "LDLM_FL_REPLAY"},
-	{LDLM_FL_INTENT_ONLY,         "LDLM_FL_INTENT_ONLY"},
-	{LDLM_FL_HAS_INTENT,          "LDLM_FL_HAS_INTENT"},
-	{LDLM_FL_FLOCK_DEADLOCK,      "LDLM_FL_FLOCK_DEADLOCK"},
-	{LDLM_FL_DISCARD_DATA,        "LDLM_FL_DISCARD_DATA"},
-	{LDLM_FL_NO_TIMEOUT,          "LDLM_FL_NO_TIMEOUT"},
-	{LDLM_FL_BLOCK_NOWAIT,        "LDLM_FL_BLOCK_NOWAIT"},
-	{LDLM_FL_TEST_LOCK,           "LDLM_FL_TEST_LOCK"},
-	{LDLM_FL_CANCEL_ON_BLOCK,     "LDLM_FL_CANCEL_ON_BLOCK"},
-	{LDLM_FL_DENY_ON_CONTENTION,  "LDLM_FL_DENY_ON_CONTENTION"},
-	{LDLM_FL_AST_DISCARD_DATA,    "LDLM_FL_AST_DISCARD_DATA"},
-	{LDLM_FL_FAIL_LOC,            "LDLM_FL_FAIL_LOC"},
-	{LDLM_FL_SKIPPED,             "LDLM_FL_SKIPPED"},
-	{LDLM_FL_CBPENDING,           "LDLM_FL_CBPENDING"},
-	{LDLM_FL_WAIT_NOREPROC,       "LDLM_FL_WAIT_NOREPROC"},
-	{LDLM_FL_CANCEL,              "LDLM_FL_CANCEL"},
-	{LDLM_FL_LOCAL_ONLY,          "LDLM_FL_LOCAL_ONLY"},
-	{LDLM_FL_FAILED,              "LDLM_FL_FAILED"},
-	{LDLM_FL_CANCELING,           "LDLM_FL_CANCELING"},
-	{LDLM_FL_LOCAL,               "LDLM_FL_LOCAL"},
-	{LDLM_FL_LVB_READY,           "LDLM_FL_LVB_READY"},
-	{LDLM_FL_KMS_IGNORE,          "LDLM_FL_KMS_IGNORE"},
-	{LDLM_FL_CP_REQD,             "LDLM_FL_CP_REQD"},
-	{LDLM_FL_CLEANED,             "LDLM_FL_CLEANED"},
-	{LDLM_FL_ATOMIC_CB,           "LDLM_FL_ATOMIC_CB"},
-	{LDLM_FL_BL_AST,              "LDLM_FL_BL_AST"},
-	{LDLM_FL_BL_DONE,             "LDLM_FL_BL_DONE"},
-	{LDLM_FL_NO_LRU,              "LDLM_FL_NO_LRU"},
-	{LDLM_FL_FAIL_NOTIFIED,       "LDLM_FL_FAIL_NOTIFIED"},
-	{LDLM_FL_DESTROYED,           "LDLM_FL_DESTROYED"},
-	{LDLM_FL_SERVER_LOCK,         "LDLM_FL_SERVER_LOCK"},
-	{LDLM_FL_RES_LOCKED,          "LDLM_FL_RES_LOCKED"},
-	{LDLM_FL_WAITED,              "LDLM_FL_WAITED"},
-	{LDLM_FL_NS_SRV,              "LDLM_FL_NS_SRV"},
-	{LDLM_FL_EXCL,                "LDLM_FL_EXCL"},
-	{ 0, NULL }
-};
-#endif /*  WIRESHARK_COMPILE */
+
 #endif /* LDLM_ALL_FLAGS_MASK */
-- 
1.7.1
