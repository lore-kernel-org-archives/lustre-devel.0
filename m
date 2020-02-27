From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:31 -0500
Subject: [lustre-devel] [PATCH 283/622] lustre: uapi: fix file heat support
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-284-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Change the LL_IOC_HEAT_SET ioctl number assignment to reduce the
number of different values used, since we are running out.  Use
a __u64 as the IOC struct argument instead of a "long" since that
is what is actually passed, and it avoids being CPU-dependent.

Move the LU_HEAT_FLAG_* values into an enum to avoid a generic
"flags" argument in the code.  This makes it clear what is passed.

Clean up code style for lfs_heat_get() and lfs_heat_set().

Fixes: 868c66dca13f ("lustre: llite: add file heat support")
WC-bug-id: https://jira.whamcloud.com/browse/LU-10602
Lustre-commit: ac1f97a88101 ("LU-10602 utils: fix file heat support")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34757
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                  | 2 +-
 include/uapi/linux/lustre/lustre_user.h | 8 +++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 76d3b4c..e9d0ff9 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3193,7 +3193,7 @@ static void ll_heat_get(struct inode *inode, struct lu_heat *heat)
 	spin_unlock(&lli->lli_heat_lock);
 }
 
-static int ll_heat_set(struct inode *inode, u64 flags)
+static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int rc = 0;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 03ec680..d52879e 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -354,7 +354,7 @@ struct ll_ioc_lease_id {
 #define LL_IOC_GETPARENT		_IOWR('f', 249, struct getparent)
 #define LL_IOC_LADVISE			_IOR('f', 250, struct llapi_lu_ladvise)
 #define LL_IOC_HEAT_GET			_IOWR('f', 251, struct lu_heat)
-#define LL_IOC_HEAT_SET			_IOW('f', 252, long)
+#define LL_IOC_HEAT_SET			_IOW('f', 251, __u64)
 
 #define LL_STATFS_LMV		1
 #define LL_STATFS_LOV		2
@@ -2010,8 +2010,10 @@ enum lu_heat_flag_bit {
 	LU_HEAT_FLAG_BIT_CLEAR,
 };
 
-#define LU_HEAT_FLAG_CLEAR	(1 << LU_HEAT_FLAG_BIT_CLEAR)
-#define LU_HEAT_FLAG_OFF	(1 << LU_HEAT_FLAG_BIT_OFF)
+enum lu_heat_flag {
+	LU_HEAT_FLAG_OFF	= 1ULL << LU_HEAT_FLAG_BIT_OFF,
+	LU_HEAT_FLAG_CLEAR	= 1ULL << LU_HEAT_FLAG_BIT_CLEAR,
+};
 
 enum obd_heat_type {
 	OBD_HEAT_READSAMPLE	= 0,
-- 
1.8.3.1
