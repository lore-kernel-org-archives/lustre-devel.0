From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:50 -0500
Subject: [lustre-devel] [PATCH 062/622] lustre: ptlrpc: remove obsolete OBD
 RPC opcodes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-63-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Remove the obsolete OBD_LOG_CANCEL (since Lustre 1.5) and
OBD_QC_CALLBACK (since Lustre 2.4) RPC opcodes.

Assign  OBD_IDX_READ an explicit opcode (as should be done with all
enums in lustre_idl.h) so that the value does not change if some
prior field is removed.

Also remove the OBD_FAIL checks that were used to test them.
The setting in conf_sanity.sh test_58 was unused for many years.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10855
Lustre-commit: 7d89a5b8aefc ("LU-10855 ptlrpc: remove obsolete OBD RPC opcodes")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32651
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h        |  6 +++---
 fs/lustre/ptlrpc/lproc_ptlrpc.c        |  4 ++--
 fs/lustre/ptlrpc/wiretest.c            |  4 ----
 include/uapi/linux/lustre/lustre_idl.h | 12 ++++++------
 4 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 67500b5..99b4f1f 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -352,12 +352,12 @@
 #define OBD_FAIL_PTLRPC_BULK_ATTACH      0x521
 
 #define OBD_FAIL_OBD_PING_NET				0x600
-#define OBD_FAIL_OBD_LOG_CANCEL_NET			0x601
+/*	OBD_FAIL_OBD_LOG_CANCEL_NET	0x601 obsolete since 1.5 */
 #define OBD_FAIL_OBD_LOGD_NET				0x602
-/*	OBD_FAIL_OBD_QC_CALLBACK_NET     0x603 obsolete since 2.4 */
+/*	OBD_FAIL_OBD_QC_CALLBACK_NET	0x603 obsolete since 2.4 */
 #define OBD_FAIL_OBD_DQACQ				0x604
 #define OBD_FAIL_OBD_LLOG_SETUP				0x605
-#define OBD_FAIL_OBD_LOG_CANCEL_REP			0x606
+/*	OBD_FAIL_OBD_LOG_CANCEL_REP	0x606 obsolete since 1.5 */
 #define OBD_FAIL_OBD_IDX_READ_NET			0x607
 #define OBD_FAIL_OBD_IDX_READ_BREAK			0x608
 #define OBD_FAIL_OBD_NO_LRU				0x609
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 0efbcfc..b70a1c7 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -111,8 +111,8 @@
 	{ MGS_SET_INFO,				"mgs_set_info" },
 	{ MGS_CONFIG_READ,			"mgs_config_read" },
 	{ OBD_PING,				"obd_ping" },
-	{ OBD_LOG_CANCEL,			"llog_cancel" },
-	{ OBD_QC_CALLBACK,			"obd_quota_callback" },
+	{ 401, /* was OBD_LOG_CANCEL */		"llog_cancel" },
+	{ 402, /* was OBD_QC_CALLBACK */	"obd_quota_callback" },
 	{ OBD_IDX_READ,				"dt_index_read" },
 	{ LLOG_ORIGIN_HANDLE_CREATE,		 "llog_origin_handle_open" },
 	{ LLOG_ORIGIN_HANDLE_NEXT_BLOCK,	"llog_origin_handle_next_block" },
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 202c5ab..015c5bd 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -326,10 +326,6 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LUSTRE_RES_ID_HSH_OFF != 3);
 	LASSERTF(OBD_PING == 400, "found %lld\n",
 		 (long long)OBD_PING);
-	LASSERTF(OBD_LOG_CANCEL == 401, "found %lld\n",
-		 (long long)OBD_LOG_CANCEL);
-	LASSERTF(OBD_QC_CALLBACK == 402, "found %lld\n",
-		 (long long)OBD_QC_CALLBACK);
 	LASSERTF(OBD_IDX_READ == 403, "found %lld\n",
 		 (long long)OBD_IDX_READ);
 	LASSERTF(OBD_LAST_OPC == 404, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 798aa57..adaa994 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2342,13 +2342,13 @@ struct cfg_marker {
  */
 
 enum obd_cmd {
-	OBD_PING = 400,
-	OBD_LOG_CANCEL,	/* Obsolete since 1.5. */
-	OBD_QC_CALLBACK, /* not used since 2.4 */
-	OBD_IDX_READ,
-	OBD_LAST_OPC
+	OBD_PING	= 400,
+/*	OBD_LOG_CANCEL	= 401, Obsolete since 1.5 */
+/*	OBD_QC_CALLBACK	= 402, not used since 2.4 */
+	OBD_IDX_READ	= 403,
+	OBD_LAST_OPC,
+	OBD_FIRST_OPC = OBD_PING
 };
-#define OBD_FIRST_OPC OBD_PING
 
 /**
  * llog contexts indices.
-- 
1.8.3.1
