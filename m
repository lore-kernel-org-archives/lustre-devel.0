From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:39 -0400
Subject: [lustre-devel] [PATCH 02/45] lustre: fld: convert cache_flush file
 to LPROC_SEQ_FOPS
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

Commit 827650494fbe ("staging/lustre/fld: move all files from procfs to
debugfs") converted files to debugfs, but missed the opportunity to
provide a simpler implementation for cache_flush.  When that patch was
taken to OpenSFS lustre in Commit 6d2b66d22c25 ("LU-8066 fld: move all
files from procfs to debugfs"), that opportunity was taken.

So we now copy that improvement back to Linux.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/lustre/fld/lproc_fld.c        | 31 +++++++++++--------------------
 fs/lustre/include/lustre_lmv.h   |  4 ++--
 fs/lustre/llite/dcache.c         |  3 +--
 fs/lustre/llite/llite_internal.h |  4 ++--
 fs/lustre/llite/lproc_llite.c    |  4 ++--
 fs/lustre/llite/namei.c          |  2 +-
 6 files changed, 19 insertions(+), 29 deletions(-)

diff --git a/fs/lustre/fld/lproc_fld.c b/fs/lustre/fld/lproc_fld.c
index bef359f..e8c8bc7 100644
--- a/fs/lustre/fld/lproc_fld.c
+++ b/fs/lustre/fld/lproc_fld.c
@@ -117,10 +117,11 @@
 }
 
 static ssize_t
-fld_debugfs_cache_flush_write(struct file *file, const char __user *buffer,
-			      size_t count, loff_t *pos)
+lprocfs_wr_cache_flush(struct file *file, const char __user *buffer,
+		      size_t count, loff_t *pos)
 {
-	struct lu_client_fld *fld = file->private_data;
+	struct seq_file *m = file->private_data;
+	struct lu_client_fld *fld = m->private;
 
 	fld_cache_flush(fld->lcf_cache);
 
@@ -129,26 +130,16 @@
 	return count;
 }
 
-static int
-fld_debugfs_cache_flush_release(struct inode *inode, struct file *file)
-{
-	file->private_data = NULL;
-	return 0;
-}
-
-static const struct file_operations fld_debugfs_cache_flush_fops = {
-	.owner		= THIS_MODULE,
-	.open		= simple_open,
-	.write		= fld_debugfs_cache_flush_write,
-	.release	= fld_debugfs_cache_flush_release,
-};
-
 LPROC_SEQ_FOPS_RO(fld_debugfs_targets);
 LPROC_SEQ_FOPS(fld_debugfs_hash);
+LPROC_SEQ_FOPS_WR_ONLY(fld, cache_flush);
 
 struct lprocfs_vars fld_client_debugfs_list[] = {
-	{ "targets",	 &fld_debugfs_targets_fops },
-	{ "hash",	 &fld_debugfs_hash_fops },
-	{ "cache_flush", &fld_debugfs_cache_flush_fops },
+	{ .name =	"targets",
+	  .fops =	&fld_debugfs_targets_fops	},
+	{ .name =	"hash",
+	  .fops =	&fld_debugfs_hash_fops		},
+	{ .name =	"cache_flush",
+	  .fops =	&fld_cache_flush_fops	},
 	{ NULL }
 };
diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index 8780480..645eee3 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -299,8 +299,8 @@ static inline u32 crush_hash(u32 a, u32 b)
 	if (stripe_count > 1) {
 		switch (hash_type & LMV_HASH_TYPE_MASK) {
 		case LMV_HASH_TYPE_ALL_CHARS:
-			stripe_index  = lmv_hash_all_chars(stripe_count, name,
-							   namelen);
+			stripe_index = lmv_hash_all_chars(stripe_count, name,
+							  namelen);
 			break;
 		case LMV_HASH_TYPE_FNV_1A_64:
 			stripe_index = lmv_hash_fnv1a(stripe_count, name,
diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index 395c454a..5fab108 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -58,7 +58,6 @@ static void ll_release(struct dentry *de)
 
 	LASSERT(de);
 	lld = ll_d2d(de);
-
 	call_rcu(&lld->lld_rcu_head, free_dentry_data);
 }
 
@@ -118,7 +117,7 @@ void ll_intent_drop_lock(struct lookup_intent *it)
 			handle.cookie = it->it_remote_lock_handle;
 
 			CDEBUG(D_DLMTRACE,
-			       "releasing remote lock with cookie%#llx from it %p\n",
+			       "releasing remote lock with cookie %#llx from it %p\n",
 			       handle.cookie, it);
 			ldlm_lock_decref(&handle,
 					 it->it_remote_lock_mode);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 724b795..671bceb 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -414,10 +414,10 @@ static inline struct pcc_inode *ll_i2pcci(struct inode *inode)
 /* default to use at least 16M for fast read if possible */
 #define RA_REMAIN_WINDOW_MIN			MiB_TO_PAGES(16UL)
 
-/* default to about 64M of readahead on a given system. */
+/* default readahead on a given system. */
 #define SBI_DEFAULT_READ_AHEAD_MAX		MiB_TO_PAGES(64UL)
 
-/* default to read-ahead full files smaller than 2MB on the second read */
+/* default read-ahead full files smaller than 2MB on the second read */
 #define SBI_DEFAULT_READ_AHEAD_WHOLE_MAX	MiB_TO_PAGES(2UL)
 
 enum ra_stat {
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 0ef418a..a38b25e 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -354,7 +354,7 @@ static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
 	pages_number = round_up(ra_max_mb, 1024 * 1024) >> PAGE_SHIFT;
 	if (pages_number > totalram_pages() / 2) {
 		/* 1/2 of RAM */
-		CERROR("%s: cannot set max_readahead_mb=%llu > %luMB\n",
+		CERROR("%s: cannot set max_read_ahead_mb=%llu > totalram/2=%luMB\n",
 		       sbi->ll_fsname, PAGES_TO_MiB(pages_number),
 		       PAGES_TO_MiB(totalram_pages() / 2));
 		return -ERANGE;
@@ -399,7 +399,7 @@ static ssize_t max_read_ahead_per_file_mb_store(struct kobject *kobj,
 
 	pages_number = round_up(ra_max_file_mb, 1024 * 1024) >> PAGE_SHIFT;
 	if (pages_number > sbi->ll_ra_info.ra_max_pages) {
-		CERROR("%s: cannot set max_readahead_per_file_mb=%llu > max_read_ahead_mb=%lu\n",
+		CERROR("%s: cannot set max_read_ahead_per_file_mb=%llu > max_read_ahead_mb=%lu\n",
 		       sbi->ll_fsname, PAGES_TO_MiB(pages_number),
 		       PAGES_TO_MiB(sbi->ll_ra_info.ra_max_pages));
 		return -ERANGE;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 97fbbee..2ca6bd2 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -978,7 +978,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE,
-	       "VFS Op:name=%pd, dir=" DFID "(%p),file %p,open_flags %x,mode %x\n",
+	       "VFS Op:name=%pd, dir=" DFID "(%p), file %p, open_flags %x, mode %x\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir, file, open_flags, mode);
 
 	/* Only negative dentries enter here */
-- 
1.8.3.1
