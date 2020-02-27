From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:30 -0500
Subject: [lustre-devel] [PATCH 402/622] lustre: llite: cleanup stats of
 LPROC_LL_*
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-403-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

Some LPROC_LL_ stats are not used for a long time. This patch
removes them. LPROC_LL_STAFS is changed to LPROC_LL_STATFS in
this patch too.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12545
Lustre-commit: 976c1f334fcb ("LU-12545 llite: cleanup stats of LPROC_LL_*")
Signed-off-by: Li Xi <lixi@ddn.com>
Reviewed-on: https://review.whamcloud.com/35514
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 6 +-----
 fs/lustre/llite/llite_lib.c      | 2 +-
 fs/lustre/llite/lproc_llite.c    | 8 +-------
 3 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 9d60ae5..a0d631d 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -789,12 +789,8 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 void ll_io_init(struct cl_io *io, const struct file *file, int write);
 
 enum {
-	LPROC_LL_DIRTY_HITS,
-	LPROC_LL_DIRTY_MISSES,
 	LPROC_LL_READ_BYTES,
 	LPROC_LL_WRITE_BYTES,
-	LPROC_LL_BRW_READ,
-	LPROC_LL_BRW_WRITE,
 	LPROC_LL_IOCTL,
 	LPROC_LL_OPEN,
 	LPROC_LL_RELEASE,
@@ -816,7 +812,7 @@ enum {
 	LPROC_LL_RMDIR,
 	LPROC_LL_MKNOD,
 	LPROC_LL_RENAME,
-	LPROC_LL_STAFS,
+	LPROC_LL_STATFS,
 	LPROC_LL_ALLOC_INODE,
 	LPROC_LL_SETXATTR,
 	LPROC_LL_GETXATTR,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index cc417d6..e0395e5 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1918,7 +1918,7 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op: at %llu jiffies\n", get_jiffies_64());
-	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_STAFS, 1);
+	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_STATFS, 1);
 
 	/* Some amount of caching on the client is allowed */
 	rc = ll_statfs_internal(ll_s2sbi(sb), &osfs, OBD_STATFS_SUM);
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 4cffd36..6eb3d33 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1543,16 +1543,10 @@ static void sbi_kobj_release(struct kobject *kobj)
 	const char	*opname;
 } llite_opcode_table[LPROC_LL_FILE_OPCODES] = {
 	/* file operation */
-	{ LPROC_LL_DIRTY_HITS,     LPROCFS_TYPE_REGS, "dirty_pages_hits" },
-	{ LPROC_LL_DIRTY_MISSES,   LPROCFS_TYPE_REGS, "dirty_pages_misses" },
 	{ LPROC_LL_READ_BYTES,     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
 				   "read_bytes" },
 	{ LPROC_LL_WRITE_BYTES,    LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
 				   "write_bytes" },
-	{ LPROC_LL_BRW_READ,       LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_PAGES,
-				   "brw_read" },
-	{ LPROC_LL_BRW_WRITE,      LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_PAGES,
-				   "brw_write" },
 	{ LPROC_LL_IOCTL,	   LPROCFS_TYPE_REGS, "ioctl" },
 	{ LPROC_LL_OPEN,	   LPROCFS_TYPE_REGS, "open" },
 	{ LPROC_LL_RELEASE,	   LPROCFS_TYPE_REGS, "close" },
@@ -1577,7 +1571,7 @@ static void sbi_kobj_release(struct kobject *kobj)
 	{ LPROC_LL_MKNOD,	   LPROCFS_TYPE_REGS, "mknod" },
 	{ LPROC_LL_RENAME,	   LPROCFS_TYPE_REGS, "rename" },
 	/* special inode operation */
-	{ LPROC_LL_STAFS,	   LPROCFS_TYPE_REGS, "statfs" },
+	{ LPROC_LL_STATFS,	   LPROCFS_TYPE_REGS, "statfs" },
 	{ LPROC_LL_ALLOC_INODE,    LPROCFS_TYPE_REGS, "alloc_inode" },
 	{ LPROC_LL_SETXATTR,       LPROCFS_TYPE_REGS, "setxattr" },
 	{ LPROC_LL_GETXATTR,       LPROCFS_TYPE_REGS, "getxattr" },
-- 
1.8.3.1
