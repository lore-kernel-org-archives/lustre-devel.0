From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:41 -0500
Subject: [lustre-devel] [PATCH 413/622] lustre: llite: do not cache write
 open lock for exec file
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-414-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@uber.com>

This is to avoid the problem that the MDT needs an extra lock
revocation to make the file be able to execute.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4398
Lustre-commit: 6dd9d57bc006 ("LU-4398 llite: do not cache write open lock for exec file")
Signed-off-by: Jinshan Xiong <jinshan.xiong@uber.com>
Signed-off-by: Gu Zheng <gzheng@ddn.com>
Reviewed-on: https://review.whamcloud.com/32265
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 6f418e0..35e31ad 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -360,7 +360,9 @@ static int ll_md_close(struct inode *inode, struct file *file)
 	}
 	mutex_unlock(&lli->lli_och_mutex);
 
-	if (!md_lock_match(ll_i2mdexp(inode), flags, ll_inode2fid(inode),
+	/* LU-4398: do not cache write open lock if the file has exec bit */
+	if ((lockmode == LCK_CW && inode->i_mode & 0111) ||
+	    !md_lock_match(ll_i2mdexp(inode), flags, ll_inode2fid(inode),
 			   LDLM_IBITS, &policy, lockmode, &lockh))
 		rc = ll_md_real_close(inode, fd->fd_omode);
 
-- 
1.8.3.1
