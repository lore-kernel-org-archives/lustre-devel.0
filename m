From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:00 -0400
Subject: [lustre-devel] [PATCH 19/37] lustre: misc: quiet compiler warning
 on armv7l
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Avoid overflow in lu_prandom_u64_max().

Quiet printk() warning for mismatched type of size_t variables
by using %z modifier for those variables.

Fixes: bc2e21c54ba2 ("lustre: obdclass: generate random u64 max correctly")

WC-bug-id: https://jira.whamcloud.com/browse/LU-13673
Lustre-commit: 57bb302461383 ("LU-13673 misc: quiet compiler warning on armv7l")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38927
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_io.c          | 4 ++--
 fs/lustre/obdclass/lu_tgt_descs.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 7627431..c3fb03a 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -791,7 +791,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 		goto out;
 
 	LU_OBJECT_HEADER(D_INODE, env, &obj->co_lu,
-			 "Read ino %lu, %lu bytes, offset %lld, size %llu\n",
+			 "Read ino %lu, %zu bytes, offset %lld, size %llu\n",
 			 inode->i_ino, cnt, pos, i_size_read(inode));
 
 	/* turn off the kernel's read-ahead */
@@ -1197,7 +1197,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 	}
 	if (vio->vui_iocb->ki_pos != (pos + io->ci_nob - nob)) {
 		CDEBUG(D_VFSTRACE,
-		       "%s: write position mismatch: ki_pos %lld vs. pos %lld, written %ld, commit %ld rc %ld\n",
+		       "%s: write position mismatch: ki_pos %lld vs. pos %lld, written %zd, commit %zd rc %zd\n",
 		       file_dentry(file)->d_name.name,
 		       vio->vui_iocb->ki_pos, pos + io->ci_nob - nob,
 		       written, io->ci_nob - nob, result);
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index db5a93b..469c935 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -62,7 +62,7 @@ u64 lu_prandom_u64_max(u64 ep_ro)
 		 * 32 bits (truncated to the upper limit, if needed)
 		 */
 		if (ep_ro > 0xffffffffULL)
-			rand = prandom_u32_max((u32)(ep_ro >> 32)) << 32;
+			rand = (u64)prandom_u32_max((u32)(ep_ro >> 32)) << 32;
 
 		if (rand == (ep_ro & 0xffffffff00000000ULL))
 			rand |= prandom_u32_max((u32)ep_ro);
-- 
1.8.3.1
