From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:52 -0500
Subject: [lustre-devel] [PATCH 004/622] lustre: uapi: sync enum
 obd_statfs_state
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With the drift between the OpenSFS and linux client various
enum obd_statfs_state values where dropped that are transmitted
over the wire. Sync the values.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index f5474c5..27501a2 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -101,9 +101,9 @@
 enum obd_statfs_state {
 	OS_STATE_DEGRADED	= 0x00000001, /**< RAID degraded/rebuilding */
 	OS_STATE_READONLY	= 0x00000002, /**< filesystem is read-only */
-	OS_STATE_RDONLY_1	= 0x00000004, /**< obsolete 1.6, was EROFS=30 */
-	OS_STATE_RDONLY_2	= 0x00000008, /**< obsolete 1.6, was EROFS=30 */
-	OS_STATE_RDONLY_3	= 0x00000010, /**< obsolete 1.6, was EROFS=30 */
+	OS_STATE_NOPRECREATE	= 0x00000004, /**< no object precreation */
+	OS_STATE_ENOSPC		= 0x00000020, /**< not enough free space */
+	OS_STATE_ENOINO		= 0x00000040, /**< not enough inodes */
 };
 
 struct obd_statfs {
-- 
1.8.3.1
