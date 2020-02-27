From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:42 -0500
Subject: [lustre-devel] [PATCH 054/622] lustre: ptlrpc: add LOCK_CONVERT
 connection flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-55-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Add LOCK_CONVERT connection flag to don't use lock
convert feature with old servers.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10175
Lustre-commit: 44a2092f08ca ("LU-10175 ptlrpc: add LOCK_CONVERT connection flag")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32593
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 1 +
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 3 files changed, 4 insertions(+)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index e2575b4..385359f 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -118,6 +118,7 @@
 	"unknown",	/* 0x10 */
 	"flr",		/* 0x20 */
 	"wbc",		/* 0x40 */
+	"lock_convert",	/* 0x80 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 01ddbee..202c5ab 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1117,6 +1117,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_FLR);
 	LASSERTF(OBD_CONNECT2_WBC_INTENTS == 0x40ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_WBC_INTENTS);
+	LASSERTF(OBD_CONNECT2_LOCK_CONVERT == 0x80ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_LOCK_CONVERT);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 11df7b4..798aa57 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -799,6 +799,7 @@ struct ptlrpc_body_v2 {
 						 * under client-held parent
 						 * locks
 						 */
+#define OBD_CONNECT2_LOCK_CONVERT	0x80ULL /* IBITS lock convert support */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1
