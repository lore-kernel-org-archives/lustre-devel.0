From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:27 -0400
Subject: [lustre-devel] [PATCH 008/151] lustre: seq: make
 seq_proc_write_common() safer
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Don't allow seq_proc_write_common() to specify arbitrary ranges,
since this can permanently corrupt the sequence controller and/or
sequnece server.  That would allow duplicate FID allocation, or
possibly prevent any new files to be created or servers to be added
to the filesystem.

Instead, limit the sequence range that can be written via /proc to
a subset of the sequence range currently allocated to that node.
Add the "clear" keyword to allow dropping the entire local sequence
and force a new one to be fetched from the sequence server.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3642
Lustre-commit: 05f69f5ee20e ("LU-3642 seq: make seq_proc_write_common() safer")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: http://review.whamcloud.com/7123
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <green@whamclould.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fid/lproc_fid.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/fid/lproc_fid.c b/fs/lustre/fid/lproc_fid.c
index 94869d4..e2e47df 100644
--- a/fs/lustre/fid/lproc_fid.c
+++ b/fs/lustre/fid/lproc_fid.c
@@ -52,14 +52,18 @@
 /* Format: [0x64BIT_INT - 0x64BIT_INT] + 32 bytes just in case */
 #define MAX_FID_RANGE_STRLEN (32 + 2 * 2 * sizeof(u64))
 /*
- * Note: this function is only used for testing, it is no safe for production
- * use.
+ * Reduce the SEQ range allocated to a node to a strict subset of the range
+ * currently-allocated SEQ range.  If the specified range is "clear", then
+ * drop all allocated sequences and request a new one from the master.
+ *
+ * Note: this function should only be used for testing, it is not necessarily
+ * safe for production use.
  */
 static int
 ldebugfs_fid_write_common(const char __user *buffer, size_t count,
 			  struct lu_seq_range *range)
 {
-	struct lu_seq_range tmp;
+	struct lu_seq_range tmp = { 0, };
 	int rc;
 	char kernbuf[MAX_FID_RANGE_STRLEN];
 
@@ -82,8 +86,6 @@
 	rc = sscanf(kernbuf, "[%llx - %llx]\n",
 		    (unsigned long long *)&tmp.lsr_start,
 		    (unsigned long long *)&tmp.lsr_end);
-	if (rc != 2)
-		return -EINVAL;
 	if (!lu_seq_range_is_sane(&tmp) || lu_seq_range_is_zero(&tmp) ||
 	    tmp.lsr_start < range->lsr_start || tmp.lsr_end > range->lsr_end)
 		return -EINVAL;
-- 
1.8.3.1
