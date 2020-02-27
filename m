From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:56 -0500
Subject: [lustre-devel] [PATCH 608/622] lustre: lustre: Reserve
 OST_FALLOCATE(fallocate) opcode
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-609-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Swapnil Pimpale <spimpale@ddn.com>

A new RPC, OST_FALLOCATE has been added for
space preallocation. This patch reserves
OST_FALLOCATE opcode for fallocate syscall.
Reserving opcode upfront would ensure consistency
and would avoid protocol interoperability issues
in the future.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3606
Lustre-commit: 46a11df089c9 ("LU-3606 lustre: Reserve OST_FALLOCATE(fallocate) opcode")
Signed-off-by: Swapnil Pimpale <spimpale@ddn.com>
Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Abrarahmed Momin <abrar.momin@gmail.com>
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/37277
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/lproc_ptlrpc.c        | 3 ++-
 fs/lustre/ptlrpc/wiretest.c            | 4 +++-
 include/uapi/linux/lustre/lustre_idl.h | 2 ++
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index f34aec3..fc7aa3e 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -67,6 +67,7 @@
 	{ OST_QUOTACTL,				"ost_quotactl" },
 	{ OST_QUOTA_ADJUST_QUNIT,		"ost_quota_adjust_qunit" },
 	{ OST_LADVISE,				"ost_ladvise" },
+	{ OST_FALLOCATE,			"ost_fallocate"},
 	{ MDS_GETATTR,				"mds_getattr" },
 	{ MDS_GETATTR_NAME,			"mds_getattr_lock" },
 	{ MDS_CLOSE,				"mds_close" },
@@ -115,7 +116,7 @@
 	{ 401, /* was OBD_LOG_CANCEL */		"llog_cancel" },
 	{ 402, /* was OBD_QC_CALLBACK */	"obd_quota_callback" },
 	{ OBD_IDX_READ,				"dt_index_read" },
-	{ LLOG_ORIGIN_HANDLE_CREATE,		 "llog_origin_handle_open" },
+	{ LLOG_ORIGIN_HANDLE_CREATE,		"llog_origin_handle_open" },
 	{ LLOG_ORIGIN_HANDLE_NEXT_BLOCK,	"llog_origin_handle_next_block" },
 	{ LLOG_ORIGIN_HANDLE_READ_HEADER,	"llog_origin_handle_read_header" },
 	{ 504, /*LLOG_ORIGIN_HANDLE_WRITE_REC*/	"llog_origin_handle_write_rec" },
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 96f327f..d94d2d9 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -106,7 +106,9 @@ void lustre_assert_wire_constants(void)
 		 (long long)OST_QUOTA_ADJUST_QUNIT);
 	LASSERTF(OST_LADVISE == 21, "found %lld\n",
 		 (long long)OST_LADVISE);
-	LASSERTF(OST_LAST_OPC == 22, "found %lld\n",
+	LASSERTF(OST_FALLOCATE == 22, "found %lld\n",
+		 (long long)OST_FALLOCATE);
+	LASSERTF(OST_LAST_OPC == 23, "found %lld\n",
 		 (long long)OST_LAST_OPC);
 	LASSERTF(OBD_OBJECT_EOF == 0xffffffffffffffffULL, "found 0x%.16llxULL\n",
 		 OBD_OBJECT_EOF);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index df2e34b..12ab369 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -956,6 +956,7 @@ enum ost_cmd {
 	OST_QUOTACTL	= 19,
 	OST_QUOTA_ADJUST_QUNIT = 20, /* not used since 2.4 */
 	OST_LADVISE	= 21,
+	OST_FALLOCATE	= 22,
 	OST_LAST_OPC /* must be < 33 to avoid MDS_GETATTR */
 };
 #define OST_FIRST_OPC  OST_REPLY
@@ -2789,6 +2790,7 @@ struct obdo {
 #define o_dropped o_misc
 #define o_cksum   o_nlink
 #define o_grant_used o_data_version
+#define o_falloc_mode o_nlink
 
 /* request structure for OST's */
 struct ost_body {
-- 
1.8.3.1
