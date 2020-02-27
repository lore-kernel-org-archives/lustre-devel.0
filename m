From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:55 -0500
Subject: [lustre-devel] [PATCH 607/622] lustre: uapi: remove unused
 LUSTRE_DIRECTIO_FL
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-608-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The LUSTRE_DIRECTIO_FL was added based on the upstream FS_DIRECTIO_FL
flag in the hopes that it might be useful, but it has since been
removed from the upstream in kernel commit v4.4-rc4-22-g68ce7bfcd995
and replaced by FS_VERITY_FL using the same value in kernel commit
v5.3-rc2-4-gfe9918d3b228, which we are much more likely to use.

Since LUSTRE_DIRECTIO_FL was unused, there is no risk to remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13164
Lustre-commit: ff168481a1b2 ("LU-13164 uapi: remove unused LUSTRE_DIRECTIO_FL")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37295
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c            | 2 --
 include/uapi/linux/lustre/lustre_idl.h | 1 -
 2 files changed, 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 6c66815..96f327f 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2176,8 +2176,6 @@ void lustre_assert_wire_constants(void)
 		 LUSTRE_DIRSYNC_FL);
 	LASSERTF(LUSTRE_TOPDIR_FL == 0x00020000, "found 0x%.8x\n",
 		 LUSTRE_TOPDIR_FL);
-	LASSERTF(LUSTRE_DIRECTIO_FL == 0x00100000, "found 0x%.8x\n",
-		 LUSTRE_DIRECTIO_FL);
 	LASSERTF(LUSTRE_INLINE_DATA_FL == 0x10000000, "found 0x%.8x\n",
 		 LUSTRE_INLINE_DATA_FL);
 	LASSERTF(MDS_INODELOCK_LOOKUP == 0x00000001UL, "found 0x%.8x\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 19ac0cb..df2e34b 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1543,7 +1543,6 @@ enum {
 #define LUSTRE_INDEX_FL		0x00001000 /* hash-indexed directory */
 #define LUSTRE_DIRSYNC_FL	0x00010000 /* dirsync behaviour (dir only) */
 #define LUSTRE_TOPDIR_FL	0x00020000 /* Top of directory hierarchies*/
-#define LUSTRE_DIRECTIO_FL	0x00100000 /* Use direct i/o */
 #define LUSTRE_INLINE_DATA_FL	0x10000000 /* Inode has inline data. */
 #define LUSTRE_PROJINHERIT_FL	0x20000000 /* Create with parents projid */
 
-- 
1.8.3.1
