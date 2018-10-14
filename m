From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 15:00:46 -0400
Subject: [lustre-devel] [PATCH 7/7] lustre: ioctl: Add BLKSSZGET ioctl
 support
In-Reply-To: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
References: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543646-29717-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Emoly Liu <emoly@whamcloud.com>

Add BLKSSZGET ioctl and return PAGE_SIZE for the minimun
alignment from ll_file_ioctl() for this call.

Signed-off-by: Emoly Liu <emoly@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9347
Reviewed-on: https://review.whamcloud.com/28578
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index f69eefc..d3ddfd2 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2618,6 +2618,8 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		return ll_ioctl_fsgetxattr(inode, cmd, arg);
 	case FS_IOC_FSSETXATTR:
 		return ll_ioctl_fssetxattr(inode, cmd, arg);
+	case BLKSSZGET:
+		return put_user(PAGE_SIZE, (int __user *)arg);
 	default: {
 		int err;
 
-- 
1.8.3.1
