From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:39 -0500
Subject: [lustre-devel] [PATCH 171/622] lustre: llite: handle -ENODATA in
 ll_layout_fetch()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-172-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In ll_layout_fetch() handle -ENODATA returns from mdc_getxattr(). This
is needed for interop and restores the behavior from before commit
0f42b388432c (LU-11380 mdc: move empty xattr to mdc layer) landed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11662
Lustre-commit: e3f367f3660d ("LU-11662 llite: handle -ENODATA in ll_layout_fetch()")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33665
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 44337a2..25d7986 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4433,8 +4433,13 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 
 	rc = md_getxattr(sbi->ll_md_exp, ll_inode2fid(inode), OBD_MD_FLXATTR,
 			 XATTR_NAME_LOV, lmmsize, &req);
-	if (rc < 0)
+	if (rc < 0) {
+		if (rc == -ENODATA) {
+			rc = 0;
+			goto out; /* empty layout */
+		}
 		return rc;
+	}
 
 	lmmsize = rc;
 	rc = 0;
-- 
1.8.3.1
