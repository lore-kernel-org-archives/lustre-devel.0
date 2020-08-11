From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:06 -0400
Subject: [lustre-devel] [PATCH 10/23] lustre: uapi: add
 OBD_CONNECT2_GETATTR_PFID
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Add OBD_CONNECT2_GETATTR_PFID connect flag to pack parent FID in
getattr request, which will be used to check whether target is
remote object, if so, don't take LOOKUP lock, otherwise client
may see stale directory entries.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13437
Lustre-commit: f384a8733c41e4 ("LU-13437 uapi: add OBD_CONNECT2_GETATTR_PFID")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39289
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 2 ++
 fs/lustre/ptlrpc/wiretest.c            | 4 +++-
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 3d16516..a3c5657 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -127,6 +127,8 @@
 	"crush",		/* 0x2000 */
 	"async_discard",	/* 0x4000 */
 	"client_encryption",	/* 0x8000 */
+	"fidmap",		/* 0x10000 */
+	"getattr_pfid",		/* 0x20000 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index d1dff09..556aaff 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1241,8 +1241,10 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_ASYNC_DISCARD);
 	LASSERTF(OBD_CONNECT2_ENCRYPT == 0x8000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ENCRYPT);
-	LASSERTF(OBD_CONNECT2_FIDMAP== 0x10000ULL, "found 0x%.16llxULL\n",
+	LASSERTF(OBD_CONNECT2_FIDMAP == 0x10000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_FIDMAP);
+	LASSERTF(OBD_CONNECT2_GETATTR_PFID == 0x20000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_GETATTR_PFID);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index fdeb2a3..2cdc230 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -837,6 +837,7 @@ struct ptlrpc_body_v2 {
 						  */
 #define OBD_CONNECT2_ENCRYPT	       0x8000ULL /* client-to-disk encrypt */
 #define OBD_CONNECT2_FIDMAP	      0x10000ULL /* FID map */
+#define OBD_CONNECT2_GETATTR_PFID     0x20000ULL /* pack parent FID in getattr */
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
  * flag value is not in use on some other branch.  Please clear any such
-- 
1.8.3.1
