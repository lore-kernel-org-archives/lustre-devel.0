From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:01 -0500
Subject: [lustre-devel] [PATCH 073/622] lustre: hsm: add
 OBD_CONNECT2_ARCHIVE_ID_ARRAY to pass archive_id lists in array
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-74-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Teddy Zheng <teddy@ddn.com>

Clients registed to MDS with OBD_CONNECT2_ARCHIVE_ID_ARRAY will
use array to pass ARCHIVED IDs. While clients without it still
use bitmap. This flag allows old clients connect to new MDSs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10114
Lustre-commit: 1c7e7d1243f7 ("LU-10114 hsm: add OBD_CONNECT2_ARCHIVE_ID_ARRAY to pass archive_id lists in array")
Signed-off-by: Teddy Zheng <teddy@ddn.com>
Signed-off-by: Li Xi <lixi@ddn.com>
Reviewed-on: https://review.whamcloud.com/32806
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 1 +
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 3 files changed, 4 insertions(+)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 385359f..fbd46df 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -119,6 +119,7 @@
 	"flr",		/* 0x20 */
 	"wbc",		/* 0x40 */
 	"lock_convert",	/* 0x80 */
+	"archive_id_array",	/* 0x100 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index e22f8f8..1afbb41 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1141,6 +1141,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_WBC_INTENTS);
 	LASSERTF(OBD_CONNECT2_LOCK_CONVERT == 0x80ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_LOCK_CONVERT);
+	LASSERTF(OBD_CONNECT2_ARCHIVE_ID_ARRAY == 0x100ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_ARCHIVE_ID_ARRAY);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 75326c0..dc9872cf3 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -800,6 +800,7 @@ struct ptlrpc_body_v2 {
 						 * locks
 						 */
 #define OBD_CONNECT2_LOCK_CONVERT	0x80ULL /* IBITS lock convert support */
+#define OBD_CONNECT2_ARCHIVE_ID_ARRAY  0x100ULL	/* store HSM archive_id in array */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1
