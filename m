From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:34 -0500
Subject: [lustre-devel] [PATCH 046/622] lustre: ptlrpc: Add WBC connect flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-47-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

It denotes ability of the node to understand additional
types of intent requests, exclusive metadata locks issued
to clients and server operations performed under such
locks while still held by clients.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10938
Lustre-commit: f024aabf8bbf ("LU-10938 ptlrpc: Add WBC connect flag")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32241
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mikhal Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 1 +
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 5 +++++
 3 files changed, 8 insertions(+)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 66d2679..e2575b4 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -117,6 +117,7 @@
 	"unknown",	/* 0x08 */
 	"unknown",	/* 0x10 */
 	"flr",		/* 0x20 */
+	"wbc",		/* 0x40 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index b14d301c..c566dea 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1115,6 +1115,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_DIR_MIGRATE);
 	LASSERTF(OBD_CONNECT2_FLR == 0x20ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_FLR);
+	LASSERTF(OBD_CONNECT2_WBC_INTENTS == 0x40ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_WBC_INTENTS);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2403b89..f437614 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -794,6 +794,11 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_DIR_MIGRATE	0x4ULL		/* migrate striped dir
 							 */
 #define OBD_CONNECT2_FLR		0x20ULL		/* FLR support */
+#define OBD_CONNECT2_WBC_INTENTS	0x40ULL /* create/unlink/... intents
+						 * for wbc, also operations
+						 * under client-held parent
+						 * locks
+						 */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1
