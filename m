From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:07 -0400
Subject: [lustre-devel] [PATCH 108/151] lustre: lustre: move LA_* flags to
 lustre_user.h
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-109-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

The LA_* flags are written to disk as part of the ChangeLog records
in mdd_attr_set_changelog(), which means they are now part of the
on-disk and network protocol, and cannot be changed (at least not the
first 12 bits that are written).
They need to be moved to lustre_user.h.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10485
Lustre-commit: 2b14e545001b ("LU-10485 lustre: move LA_* flags to lustre_user.h")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/30825
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h           | 19 -------------------
 include/uapi/linux/lustre/lustre_user.h | 29 +++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index a938e64..e1979be 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -425,25 +425,6 @@ struct lu_attr {
 	u64	  la_valid;
 };
 
-/** Bit-mask of valid attributes */
-enum la_valid {
-	LA_ATIME	= 1 << 0,
-	LA_MTIME	= 1 << 1,
-	LA_CTIME	= 1 << 2,
-	LA_SIZE		= 1 << 3,
-	LA_MODE		= 1 << 4,
-	LA_UID		= 1 << 5,
-	LA_GID		= 1 << 6,
-	LA_BLOCKS	= 1 << 7,
-	LA_TYPE		= 1 << 8,
-	LA_FLAGS	= 1 << 9,
-	LA_NLINK	= 1 << 10,
-	LA_RDEV		= 1 << 11,
-	LA_BLKSIZE	= 1 << 12,
-	LA_KILL_SUID	= 1 << 13,
-	LA_KILL_SGID	= 1 << 14,
-};
-
 /**
  * Layer in the layered object.
  */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 21dc1e9..d53e795 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -837,6 +837,35 @@ struct lustre_swap_layouts {
 	__u64	sl_dv2;
 };
 
+/** Bit-mask of valid attributes */
+/* The LA_* flags are written to disk as part of the ChangeLog records
+ * so they are part of the on-disk and network protocol, and cannot be changed.
+ * Only the first 12 bits are currently saved.
+ */
+enum la_valid {
+	LA_ATIME	= 1 << 0,
+	LA_MTIME	= 1 << 1,
+	LA_CTIME	= 1 << 2,
+	LA_SIZE		= 1 << 3,
+	LA_MODE		= 1 << 4,
+	LA_UID		= 1 << 5,
+	LA_GID		= 1 << 6,
+	LA_BLOCKS	= 1 << 7,
+	LA_TYPE		= 1 << 8,
+	LA_FLAGS	= 1 << 9,
+	LA_NLINK	= 1 << 10,
+	LA_RDEV		= 1 << 11,
+	LA_BLKSIZE	= 1 << 12,
+	LA_KILL_SUID	= 1 << 13,
+	LA_KILL_SGID	= 1 << 14,
+	LA_PROJID	= 1 << 15,
+	LA_LAYOUT_VERSION = 1 << 16,
+	/**
+	 * Attributes must be transmitted to OST objects
+	 */
+	LA_REMOTE_ATTR_SET = (LA_UID | LA_GID | LA_PROJID | LA_LAYOUT_VERSION)
+};
+
 /********* Changelogs **********/
 /** Changelog record types */
 enum changelog_rec_type {
-- 
1.8.3.1
