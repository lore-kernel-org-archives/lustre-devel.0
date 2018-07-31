From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:25:57 -0400
Subject: [lustre-devel] [PATCH 05/31] lustre: llite: return small device
 numbers for compat stat()
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

The compat_sys_*stat*() syscalls will fail unless the devices majors
and minors are both less than 256. So in ll_getattr_it(), if we are in
32 bit compat mode then coerce the device numbers in to the expected
format.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-id: https://jira.whamcloud.com/browse/LU-8855
Reviewed-on: https://review.whamcloud.com/23877
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 3f0f379..684877c 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3248,14 +3248,20 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 	OBD_FAIL_TIMEOUT(OBD_FAIL_GETATTR_DELAY, 30);
 
 	stat->dev = inode->i_sb->s_dev;
-	if (ll_need_32bit_api(sbi))
+	if (ll_need_32bit_api(sbi)) {
 		stat->ino = cl_fid_build_ino(&lli->lli_fid, 1);
-	else
+		stat->dev = MKDEV(MAJOR(inode->i_sb->s_dev) & 0xff,
+				  MINOR(inode->i_sb->s_dev) & 0xff);
+		stat->rdev = MKDEV(MAJOR(inode->i_rdev) & 0xff,
+				   MINOR(inode->i_rdev) & 0xff);
+	} else {
+		stat->dev = inode->i_sb->s_dev;
+		stat->rdev = inode->i_rdev;
 		stat->ino = inode->i_ino;
+	}
 	stat->mode = inode->i_mode;
 	stat->uid = inode->i_uid;
 	stat->gid = inode->i_gid;
-	stat->rdev = inode->i_rdev;
 	stat->atime = inode->i_atime;
 	stat->mtime = inode->i_mtime;
 	stat->ctime = inode->i_ctime;
-- 
1.8.3.1
