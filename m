From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:11 -0500
Subject: [lustre-devel] [PATCH 383/622] lustre: llite: collect debug info
 for ll_fsync
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-384-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Improve ll_fsync() debug message to capture all the arguments of
the current fsync.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12462
Lustre-commit: 4cb6ce1863d0 ("LU-12462 llite: Remove old fsync versions")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35339
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 76a5074..a20896c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3907,8 +3907,10 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct ptlrpc_request *req;
 	int rc, err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
-	       PFID(ll_inode2fid(inode)), inode);
+	CDEBUG(D_VFSTRACE,
+	       "VFS Op:inode=" DFID "(%p), start %lld, end %lld, datasync %d\n",
+	       PFID(ll_inode2fid(inode)), inode, start, end, datasync);
+
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FSYNC, 1);
 
 
-- 
1.8.3.1
