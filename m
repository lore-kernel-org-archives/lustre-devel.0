From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:26 -0500
Subject: [lustre-devel] [PATCH 398/622] lustre: uapi: add unused enum
 obd_statfs_state
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-399-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The 3rd and 4th bit field of enum obd_statfs_state are for values
that have been obsoleted since Lustre 1.6. Lets make this clear
for end user applications.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12501
Lustre-commit: e4d92a8a08ac ("LU-12501 utils: fix 'lfs df' printing loop")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35456
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 86f3111..9c849ce 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -102,6 +102,8 @@ enum obd_statfs_state {
 	OS_STATE_DEGRADED	= 0x00000001, /**< RAID degraded/rebuilding */
 	OS_STATE_READONLY	= 0x00000002, /**< filesystem is read-only */
 	OS_STATE_NOPRECREATE	= 0x00000004, /**< no object precreation */
+	OS_STATE_UNUSED1	= 0x00000008, /**< obsolete 1.6, was EROFS=30 */
+	OS_STATE_UNUSED2	= 0x00000010, /**< obsolete 1.6, was EROFS=30 */
 	OS_STATE_ENOSPC		= 0x00000020, /**< not enough free space */
 	OS_STATE_ENOINO		= 0x00000040, /**< not enough inodes */
 	OS_STATE_SUM		= 0x00000100, /**< aggregated for all tagrets */
-- 
1.8.3.1
