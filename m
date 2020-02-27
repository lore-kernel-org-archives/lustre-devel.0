From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:23 -0500
Subject: [lustre-devel] [PATCH 035/622] lustre: ptlrpc: add dir migration
 connect flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Add dir migration connect flag to prevent collision with other
features. Though dir migration code exists, it will be reworked,
and the new RPC protocol won't be compatible with current one.

Also handle the previously-added OBD_CONNECT2_FLR flag.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4684
Lustre-commit: 14b98596fa24 ("LU-4684 ptlrpc: add dir migration connect flag")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31914
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 8 ++++++--
 fs/lustre/ptlrpc/wiretest.c            | 4 ++++
 include/uapi/linux/lustre/lustre_idl.h | 2 ++
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 33c76c1..66d2679 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -111,8 +111,12 @@
 	"compact_obdo",
 	"second_flags",
 	/* flags2 names */
-	"file_secctx",
-	"lockaheadv2",
+	"file_secctx",	/* 0x01 */
+	"lockaheadv2",	/* 0x02 */
+	"dir_migrate",	/* 0x04 */
+	"unknown",	/* 0x08 */
+	"unknown",	/* 0x10 */
+	"flr",		/* 0x20 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index bcd0229..46d5e74 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1111,6 +1111,10 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_FILE_SECCTX);
 	LASSERTF(OBD_CONNECT2_LOCKAHEAD == 0x2ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_LOCKAHEAD);
+	LASSERTF(OBD_CONNECT2_DIR_MIGRATE == 0x4ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_DIR_MIGRATE);
+	LASSERTF(OBD_CONNECT2_FLR == 0x20ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_FLR);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 589bb81..e898e67 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -791,6 +791,8 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_LOCKAHEAD		0x2ULL		/* ladvise lockahead
 							 * v2
 							 */
+#define OBD_CONNECT2_DIR_MIGRATE	0x4ULL		/* migrate striped dir
+							 */
 #define OBD_CONNECT2_FLR		0x20ULL		/* FLR support */
 
 /* XXX README XXX:
-- 
1.8.3.1
