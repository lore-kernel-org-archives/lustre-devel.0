From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:52 -0500
Subject: [lustre-devel] [PATCH 064/622] lustre: ptlrpc: remove obsolete
 LLOG_ORIGIN_* RPCs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-65-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Remove the obsolete RPC opcodes LLOG_ORIGIN_HANDLE_WRITE_REC,
LLOG_ORIGIN_HANDLE_CLOSE, LLOG_ORIGIN_CONNECT, LLOG_CATINFO
along with their unused OBD_FAIL counterparts.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10855
Lustre-commit: 830ce1b10f3a ("LU-10855 ptlrpc: remove obsolete LLOG_ORIGIN_* RPCs")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32654
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h        | 10 +++++-----
 fs/lustre/ptlrpc/lproc_ptlrpc.c        |  8 ++++----
 fs/lustre/ptlrpc/wiretest.c            |  5 -----
 include/uapi/linux/lustre/lustre_idl.h | 10 +++++-----
 4 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 99b4f1f..28becfa 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -423,15 +423,15 @@
 #define OBD_FAIL_SEC_CTX_HDL_PAUSE			0x1204
 
 #define OBD_FAIL_LLOG					0x1300
-#define OBD_FAIL_LLOG_ORIGIN_CONNECT_NET		0x1301
+/* was	OBD_FAIL_LLOG_ORIGIN_CONNECT_NET		0x1301 until 2.4 */
 #define OBD_FAIL_LLOG_ORIGIN_HANDLE_CREATE_NET		0x1302
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_DESTROY_NET		0x1303
+/* was	OBD_FAIL_LLOG_ORIGIN_HANDLE_DESTROY_NET		0x1303 until 2.11 */
 #define OBD_FAIL_LLOG_ORIGIN_HANDLE_READ_HEADER_NET	0x1304
 #define OBD_FAIL_LLOG_ORIGIN_HANDLE_NEXT_BLOCK_NET	0x1305
 #define OBD_FAIL_LLOG_ORIGIN_HANDLE_PREV_BLOCK_NET	0x1306
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_WRITE_REC_NET	0x1307
-#define OBD_FAIL_LLOG_ORIGIN_HANDLE_CLOSE_NET		0x1308
-#define OBD_FAIL_LLOG_CATINFO_NET			0x1309
+/* was	OBD_FAIL_LLOG_ORIGIN_HANDLE_WRITE_REC_NET	0x1307 until 2.1 */
+/* was	OBD_FAIL_LLOG_ORIGIN_HANDLE_CLOSE_NET		0x1308 until 1.8 */
+/* was	OBD_FAIL_LLOG_CATINFO_NET			0x1309 until 2.3 */
 #define OBD_FAIL_MDS_SYNC_CAPA_SL			0x1310
 #define OBD_FAIL_SEQ_ALLOC				0x1311
 
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index b70a1c7..6af3384 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -117,10 +117,10 @@
 	{ LLOG_ORIGIN_HANDLE_CREATE,		 "llog_origin_handle_open" },
 	{ LLOG_ORIGIN_HANDLE_NEXT_BLOCK,	"llog_origin_handle_next_block" },
 	{ LLOG_ORIGIN_HANDLE_READ_HEADER,	"llog_origin_handle_read_header" },
-	{ LLOG_ORIGIN_HANDLE_WRITE_REC,		"llog_origin_handle_write_rec" },
-	{ LLOG_ORIGIN_HANDLE_CLOSE,		"llog_origin_handle_close" },
-	{ LLOG_ORIGIN_CONNECT,			"llog_origin_connect" },
-	{ LLOG_CATINFO,				"llog_catinfo" },
+	{ 504, /*LLOG_ORIGIN_HANDLE_WRITE_REC*/	"llog_origin_handle_write_rec" },
+	{ 505, /* was LLOG_ORIGIN_HANDLE_CLOSE */"llog_origin_handle_close" },
+	{ 506, /* was LLOG_ORIGIN_CONNECT */	"llog_origin_connect" },
+	{ 507, /* was LLOG_CATINFO */		"llog_catinfo" },
 	{ LLOG_ORIGIN_HANDLE_PREV_BLOCK,	"llog_origin_handle_prev_block" },
 	{ LLOG_ORIGIN_HANDLE_DESTROY,		"llog_origin_handle_destroy" },
 	{ QUOTA_DQACQ,				"quota_acquire" },
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index ef07975..7b6ea86 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -3757,12 +3757,7 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_CREATE != 501);
 	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_NEXT_BLOCK != 502);
 	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_READ_HEADER != 503);
-	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_WRITE_REC != 504);
-	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_CLOSE != 505);
-	BUILD_BUG_ON(LLOG_ORIGIN_CONNECT != 506);
-	BUILD_BUG_ON(LLOG_CATINFO != 507);
 	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_PREV_BLOCK != 508);
-	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_DESTROY != 509);
 	BUILD_BUG_ON(LLOG_FIRST_OPC != 501);
 	BUILD_BUG_ON(LLOG_LAST_OPC != 510);
 	BUILD_BUG_ON(LLOG_CONFIG_ORIG_CTXT != 0);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 1b5794a..5db742f 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2655,12 +2655,12 @@ enum llogd_rpc_ops {
 	LLOG_ORIGIN_HANDLE_CREATE	= 501,
 	LLOG_ORIGIN_HANDLE_NEXT_BLOCK	= 502,
 	LLOG_ORIGIN_HANDLE_READ_HEADER	= 503,
-	LLOG_ORIGIN_HANDLE_WRITE_REC	= 504,	/* Obsolete by 2.1. */
-	LLOG_ORIGIN_HANDLE_CLOSE	= 505,	/* Obsolete by 1.8. */
-	LLOG_ORIGIN_CONNECT		= 506,	/* Obsolete by 2.4. */
-	LLOG_CATINFO			= 507,  /* Obsolete by 2.3. */
+/*	LLOG_ORIGIN_HANDLE_WRITE_REC	= 504,	Obsolete by 2.1. */
+/*	LLOG_ORIGIN_HANDLE_CLOSE	= 505,	Obsolete by 1.8. */
+/*	LLOG_ORIGIN_CONNECT		= 506,	Obsolete by 2.4. */
+/*	LLOG_CATINFO			= 507,  Obsolete by 2.3. */
 	LLOG_ORIGIN_HANDLE_PREV_BLOCK	= 508,
-	LLOG_ORIGIN_HANDLE_DESTROY	= 509,  /* Obsolete. */
+	LLOG_ORIGIN_HANDLE_DESTROY	= 509,  /* Obsolete by 2.11. */
 	LLOG_LAST_OPC,
 	LLOG_FIRST_OPC			= LLOG_ORIGIN_HANDLE_CREATE
 };
-- 
1.8.3.1
