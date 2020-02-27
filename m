From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:06 -0500
Subject: [lustre-devel] [PATCH 378/622] lustre: ptlrpc: Add increasing XIDs
 CONNECT2 flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-379-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

This patch reserves the OBD_CONNECT2 flag
for increasing XIDs.

Cray-bug-id: LUS-6272
WC-bug-id: https://jira.whamcloud.com/browse/LU-11444
Lustre-commit: b4375f5fc66c ("LU-11444 ptlrpc: Add increasing XIDs CONNECT2 flag")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/35113
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 2 +-
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index c244adb..ca169ec 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -120,7 +120,7 @@
 	"wbc",		/* 0x40 */
 	"lock_convert",	/* 0x80 */
 	"archive_id_array",	/* 0x100 */
-	"unknown",		/* 0x200 */
+	"increasing_xid",	/* 0x200 */
 	"selinux_policy",	/* 0x400 */
 	"lsom",			/* 0x800 */
 	"pcc",			/* 0x1000 */
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 64ccc6e..e801f2c 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1148,6 +1148,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_LOCK_CONVERT);
 	LASSERTF(OBD_CONNECT2_ARCHIVE_ID_ARRAY == 0x100ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ARCHIVE_ID_ARRAY);
+	LASSERTF(OBD_CONNECT2_INC_XID == 0x200ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_INC_XID);
 	LASSERTF(OBD_CONNECT2_SELINUX_POLICY == 0x400ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_SELINUX_POLICY);
 	LASSERTF(OBD_CONNECT2_LSOM == 0x800ULL, "found 0x%.16llxULL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2e54dd1..c86b188 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -806,6 +806,7 @@ struct ptlrpc_body_v2 {
 						 */
 #define OBD_CONNECT2_LOCK_CONVERT	0x80ULL /* IBITS lock convert support */
 #define OBD_CONNECT2_ARCHIVE_ID_ARRAY  0x100ULL	/* store HSM archive_id in array */
+#define OBD_CONNECT2_INC_XID	       0x200ULL /* Increasing xid */
 #define OBD_CONNECT2_SELINUX_POLICY    0x400ULL	/* has client SELinux policy */
 #define OBD_CONNECT2_LSOM	       0x800ULL	/* LSOM support */
 #define OBD_CONNECT2_PCC	       0x1000ULL /* Persistent Client Cache */
-- 
1.8.3.1
