From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 11:34:57 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: added debugging ability for
	LFSCK
In-Reply-To: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
References: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447000500-29427-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

Add the ability to debug LFSCK to libcfs. This is
broken out of patch http://review.whamcloud.com/6321.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2914
Reviewed-on: http://review.whamcloud.com/6321
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     |    2 +-
 drivers/staging/lustre/lustre/libcfs/debug.c       |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index a1787bb..98430e7 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -106,7 +106,7 @@ struct ptldebug_header {
 #define S_LOV		0x00020000
 #define S_LQUOTA	0x00040000
 #define S_OSD		0x00080000
-/* unused */
+#define S_LFSCK		0x00100000
 /* unused */
 /* unused */
 #define S_LMV		0x00800000 /* b_new_cmd */
diff --git a/drivers/staging/lustre/lustre/libcfs/debug.c b/drivers/staging/lustre/lustre/libcfs/debug.c
index e56785a..3c914bf 100644
--- a/drivers/staging/lustre/lustre/libcfs/debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/debug.c
@@ -271,6 +271,8 @@ libcfs_debug_subsys2str(int subsys)
 		return "lquota";
 	case S_OSD:
 		return "osd";
+	case S_LFSCK:
+		return "lfsck";
 	case S_LMV:
 		return "lmv";
 	case S_SEC:
-- 
1.7.1
