From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:02 -0400
Subject: [lustre-devel] [PATCH 06/20] lustre: uapi: change LUSTRE_*_FL
 defines to enum
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Di Wang <di.wang@intel.com>

The preferred style in the case of LUSTRE_*_FL is to use enum.

Fixes: d344c54f4a90c ("lustre: llite: handle ORPHAN/DEAD directories")
WC-bug-id: https://jira.whamcloud.com/browse/LU-7579
Lustre-commit: 098fb363c39 ("LU-7579 osd: move ORPHAN/DEAD flag to OSD")
Signed-off-by: Di Wang <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/18024
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_idl.h | 30 +++++++++++++++++-------------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index bb3f5f1..800154d 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1537,19 +1537,23 @@ enum {
 #define MDS_STATUS_CONN 1
 #define MDS_STATUS_LOV 2
 
-/* these should be identical to their EXT4_*_FL counterparts, they are
- * redefined here only to avoid dragging in fs/ext4/ext4.h
- */
-#define LUSTRE_SYNC_FL		0x00000008 /* Synchronous updates */
-#define LUSTRE_IMMUTABLE_FL	0x00000010 /* Immutable file */
-#define LUSTRE_APPEND_FL	0x00000020 /* writes to file may only append */
-#define LUSTRE_NODUMP_FL	0x00000040 /* do not dump file */
-#define LUSTRE_NOATIME_FL	0x00000080 /* do not update atime */
-#define LUSTRE_INDEX_FL		0x00001000 /* hash-indexed directory */
-#define LUSTRE_DIRSYNC_FL	0x00010000 /* dirsync behaviour (dir only) */
-#define LUSTRE_TOPDIR_FL	0x00020000 /* Top of directory hierarchies*/
-#define LUSTRE_INLINE_DATA_FL	0x10000000 /* Inode has inline data. */
-#define LUSTRE_PROJINHERIT_FL	0x20000000 /* Create with parents projid */
+enum {
+	/* these should be identical to their EXT4_*_FL counterparts, they are
+	 * redefined here only to avoid dragging in fs/ext4/ext4.h
+	 */
+	LUSTRE_SYNC_FL		= 0x00000008, /* Synchronous updates */
+	LUSTRE_IMMUTABLE_FL	= 0x00000010, /* Immutable file */
+	LUSTRE_APPEND_FL	= 0x00000020, /* writes to file may only
+					       * append
+					       */
+	LUSTRE_NODUMP_FL	= 0x00000040, /* do not dump file */
+	LUSTRE_NOATIME_FL	= 0x00000080, /* do not update atime */
+	LUSTRE_INDEX_FL		= 0x00001000, /* hash-indexed directory */
+	LUSTRE_DIRSYNC_FL	= 0x00010000, /* dirsync behaviour (dir only) */
+	LUSTRE_TOPDIR_FL	= 0x00020000, /* Top of directory hierarchies*/
+	LUSTRE_INLINE_DATA_FL	= 0x10000000, /* Inode has inline data. */
+	LUSTRE_PROJINHERIT_FL	= 0x20000000, /* Create with parents projid */
+};
 
 /* 64 possible states */
 enum md_transient_state {
-- 
1.8.3.1
