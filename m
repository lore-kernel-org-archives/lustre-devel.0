From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:33 -0500
Subject: [lustre-devel] [PATCH 285/622] lustre: obd: round values to nearest
 MiB for *_mb syfs files
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-286-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Several sysfs files report their settings with the functions
lprocfs_read_frac_helper() which has the intent of showing
fractional values i.e 1.5 MiB. This approach has caused problems
with shells which don't handle fractional representation and the
values reported don't faithfully represent the original value the
configurator passed into the sysfs file. To resolve this lets
instead always round up the value the configurator passed into
the sysfs file to the nearest MiB value. This way it is always
guaranteed the values reported are always exactly some MiB value.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11157
Lustre-commit: ba2817fe3ead ("LU-11157 obd: round values to nearest MiB for *_mb syfs files")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/34317
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h |  5 ++-
 fs/lustre/llite/llite_internal.h   |  6 +--
 fs/lustre/llite/lproc_llite.c      | 78 +++++++++++++++-----------------------
 fs/lustre/mdc/lproc_mdc.c          |  8 ++--
 fs/lustre/osc/lproc_osc.c          | 21 +++++-----
 5 files changed, 50 insertions(+), 68 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 8d74822..9f62d4e 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -63,6 +63,9 @@ static inline unsigned int pct(unsigned long a, unsigned long b)
 	return b ? a * 100 / b : 0;
 }
 
+#define PAGES_TO_MiB(pages)	((pages) >> (20 - PAGE_SHIFT))
+#define MiB_TO_PAGES(mb)	((mb) << (20 - PAGE_SHIFT))
+
 struct lprocfs_static_vars {
 	struct lprocfs_vars		*obd_vars;
 	const struct attribute_group	*sysfs_vars;
@@ -363,8 +366,6 @@ enum {
 
 int lprocfs_write_frac_helper(const char __user *buffer,
 			      unsigned long count, int *val, int mult);
-int lprocfs_read_frac_helper(char *buffer, unsigned long count,
-			     long val, int mult);
 
 int lprocfs_stats_alloc_one(struct lprocfs_stats *stats,
 			    unsigned int cpuid);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 9d7345a..eb7e0dc 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -297,18 +297,16 @@ int ll_listsecurity(struct inode *inode, char *secctx_name,
 void ll_inode_size_lock(struct inode *inode);
 void ll_inode_size_unlock(struct inode *inode);
 
-/* FIXME: replace the name of this with LL_I to conform to kernel stuff */
-/* static inline struct ll_inode_info *LL_I(struct inode *inode) */
 static inline struct ll_inode_info *ll_i2info(struct inode *inode)
 {
 	return container_of(inode, struct ll_inode_info, lli_vfs_inode);
 }
 
 /* default to about 64M of readahead on a given system. */
-#define SBI_DEFAULT_READAHEAD_MAX	(64UL << (20 - PAGE_SHIFT))
+#define SBI_DEFAULT_READAHEAD_MAX		MiB_TO_PAGES(64UL)
 
 /* default to read-ahead full files smaller than 2MB on the second read */
-#define SBI_DEFAULT_READAHEAD_WHOLE_MAX (2UL << (20 - PAGE_SHIFT))
+#define SBI_DEFAULT_READAHEAD_WHOLE_MAX		MiB_TO_PAGES(2UL)
 
 enum ra_stat {
 	RA_STAT_HIT = 0,
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index cc9f80e..165d37f 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -326,15 +326,13 @@ static ssize_t max_read_ahead_mb_show(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
-	long pages_number;
-	int mult;
+	unsigned long ra_max_mb;
 
 	spin_lock(&sbi->ll_lock);
-	pages_number = sbi->ll_ra_info.ra_max_pages;
+	ra_max_mb = PAGES_TO_MiB(sbi->ll_ra_info.ra_max_pages);
 	spin_unlock(&sbi->ll_lock);
 
-	mult = 1 << (20 - PAGE_SHIFT);
-	return lprocfs_read_frac_helper(buf, PAGE_SIZE, pages_number, mult);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n", ra_max_mb);
 }
 
 static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
@@ -344,21 +342,19 @@ static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
+	u64 ra_max_mb, pages_number;
 	int rc;
-	unsigned long pages_number;
-	int pages_shift;
 
-	pages_shift = 20 - PAGE_SHIFT;
-	rc = kstrtoul(buffer, 10, &pages_number);
+	rc = kstrtoull(buffer, 10, &ra_max_mb);
 	if (rc)
 		return rc;
 
-	pages_number <<= pages_shift; /* MB -> pages */
-
+	pages_number = round_up(ra_max_mb, 1024 * 1024) >> PAGE_SHIFT;
 	if (pages_number > totalram_pages() / 2) {
-		CERROR("%s: can't set max_readahead_mb=%lu > %luMB\n",
-		       sbi->ll_fsname, pages_number >> pages_shift,
-		       totalram_pages() >> (pages_shift + 1)); /*1/2 of RAM*/
+		/* 1/2 of RAM */
+		CERROR("%s: can't set max_readahead_mb=%llu > %luMB\n",
+		       sbi->ll_fsname, PAGES_TO_MiB(pages_number),
+		       PAGES_TO_MiB(totalram_pages()));
 		return -ERANGE;
 	}
 
@@ -376,15 +372,13 @@ static ssize_t max_read_ahead_per_file_mb_show(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
-	long pages_number;
-	int mult;
+	unsigned long ra_max_file_mb;
 
 	spin_lock(&sbi->ll_lock);
-	pages_number = sbi->ll_ra_info.ra_max_pages_per_file;
+	ra_max_file_mb = PAGES_TO_MiB(sbi->ll_ra_info.ra_max_pages_per_file);
 	spin_unlock(&sbi->ll_lock);
 
-	mult = 1 << (20 - PAGE_SHIFT);
-	return lprocfs_read_frac_helper(buf, PAGE_SIZE, pages_number, mult);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n", ra_max_file_mb);
 }
 
 static ssize_t max_read_ahead_per_file_mb_store(struct kobject *kobj,
@@ -394,22 +388,18 @@ static ssize_t max_read_ahead_per_file_mb_store(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
+	u64 ra_max_file_mb, pages_number;
 	int rc;
-	unsigned long pages_number;
-	int pages_shift;
 
-	pages_shift = 20 - PAGE_SHIFT;
-	rc = kstrtoul(buffer, 10, &pages_number);
+	rc = kstrtoull(buffer, 10, &ra_max_file_mb);
 	if (rc)
 		return rc;
 
-	pages_number <<= pages_shift; /* MB -> pages */
-
+	pages_number = round_up(ra_max_file_mb, 1024 * 1024) >> PAGE_SHIFT;
 	if (pages_number > sbi->ll_ra_info.ra_max_pages) {
-		CERROR("%s: can't set max_readahead_per_file_mb=%lu > max_read_ahead_mb=%lu\n",
-		       sbi->ll_fsname,
-		       pages_number >> pages_shift,
-		       sbi->ll_ra_info.ra_max_pages >> pages_shift);
+		CERROR("%s: can't set max_readahead_per_file_mb=%llu > max_read_ahead_mb=%lu\n",
+		       sbi->ll_fsname, PAGES_TO_MiB(pages_number),
+		       PAGES_TO_MiB(sbi->ll_ra_info.ra_max_pages));
 		return -ERANGE;
 	}
 
@@ -427,15 +417,13 @@ static ssize_t max_read_ahead_whole_mb_show(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
-	long pages_number;
-	int mult;
+	unsigned long ra_max_whole_mb;
 
 	spin_lock(&sbi->ll_lock);
-	pages_number = sbi->ll_ra_info.ra_max_read_ahead_whole_pages;
+	ra_max_whole_mb = PAGES_TO_MiB(sbi->ll_ra_info.ra_max_read_ahead_whole_pages);
 	spin_unlock(&sbi->ll_lock);
 
-	mult = 1 << (20 - PAGE_SHIFT);
-	return lprocfs_read_frac_helper(buf, PAGE_SIZE, pages_number, mult);
+	return scnprintf(buf, PAGE_SIZE, "%lu\n", ra_max_whole_mb);
 }
 
 static ssize_t max_read_ahead_whole_mb_store(struct kobject *kobj,
@@ -445,24 +433,21 @@ static ssize_t max_read_ahead_whole_mb_store(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
+	u64 ra_max_whole_mb, pages_number;
 	int rc;
-	unsigned long pages_number;
-	int pages_shift;
 
-	pages_shift = 20 - PAGE_SHIFT;
-	rc = kstrtoul(buffer, 10, &pages_number);
+	rc = kstrtoull(buffer, 10, &ra_max_whole_mb);
 	if (rc)
 		return rc;
-	pages_number <<= pages_shift; /* MB -> pages */
 
+	pages_number = round_up(ra_max_whole_mb, 1024 * 1024) >> PAGE_SHIFT;
 	/* Cap this at the current max readahead window size, the readahead
 	 * algorithm does this anyway so it's pointless to set it larger.
 	 */
 	if (pages_number > sbi->ll_ra_info.ra_max_pages_per_file) {
-		CERROR("%s: can't set max_read_ahead_whole_mb=%lu > max_read_ahead_per_file_mb=%lu\n",
-		       sbi->ll_fsname,
-		       pages_number >> pages_shift,
-		       sbi->ll_ra_info.ra_max_pages_per_file >> pages_shift);
+		CERROR("%s: can't set max_read_ahead_whole_mb=%llu > max_read_ahead_per_file_mb=%lu\n",
+		       sbi->ll_fsname, PAGES_TO_MiB(pages_number),
+		       PAGES_TO_MiB(sbi->ll_ra_info.ra_max_pages_per_file));
 		return -ERANGE;
 	}
 
@@ -479,12 +464,11 @@ static int ll_max_cached_mb_seq_show(struct seq_file *m, void *v)
 	struct super_block *sb = m->private;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct cl_client_cache *cache = sbi->ll_cache;
-	int shift = 20 - PAGE_SHIFT;
 	long max_cached_mb;
 	long unused_mb;
 
-	max_cached_mb = cache->ccc_lru_max >> shift;
-	unused_mb = atomic_long_read(&cache->ccc_lru_left) >> shift;
+	max_cached_mb = PAGES_TO_MiB(cache->ccc_lru_max);
+	unused_mb = PAGES_TO_MiB(atomic_long_read(&cache->ccc_lru_left));
 	seq_printf(m,
 		   "users: %d\n"
 		   "max_cached_mb: %ld\n"
@@ -538,7 +522,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 	if (pages_number < 0 || pages_number > totalram_pages()) {
 		CERROR("%s: can't set max cache more than %lu MB\n",
 		       sbi->ll_fsname,
-		       totalram_pages() >> (20 - PAGE_SHIFT));
+		       PAGES_TO_MiB(totalram_pages()));
 		return -ERANGE;
 	}
 	/* Allow enough cache so clients can make well-formed RPCs */
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 81167bbd..454b69d 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -47,7 +47,7 @@ static int mdc_max_dirty_mb_seq_show(struct seq_file *m, void *v)
 	unsigned long val;
 
 	spin_lock(&cli->cl_loi_list_lock);
-	val = cli->cl_dirty_max_pages >> (20 - PAGE_SHIFT);
+	val = PAGES_TO_MiB(cli->cl_dirty_max_pages);
 	spin_unlock(&cli->cl_loi_list_lock);
 
 	seq_printf(m, "%lu\n", val);
@@ -69,10 +69,10 @@ static ssize_t mdc_max_dirty_mb_seq_write(struct file *file,
 	if (rc)
 		return rc;
 
-	pages_number >>= PAGE_SHIFT;
-
+	/* MB -> pages */
+	pages_number = round_up(pages_number, 1024 * 1024) >> PAGE_SHIFT;
 	if (pages_number <= 0 ||
-	    pages_number >= OSC_MAX_DIRTY_MB_MAX << (20 - PAGE_SHIFT) ||
+	    pages_number >= MiB_TO_PAGES(OSC_MAX_DIRTY_MB_MAX) ||
 	    pages_number > totalram_pages() / 4) /* 1/4 of RAM */
 		return -ERANGE;
 
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 5faf518..775bf74 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -134,12 +134,13 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
-	long val;
-	int mult;
+	unsigned long val;
 
-	val = cli->cl_dirty_max_pages;
-	mult = 1 << (20 - PAGE_SHIFT);
-	return lprocfs_read_frac_helper(buf, PAGE_SIZE, val, mult);
+	spin_lock(&cli->cl_loi_list_lock);
+	val = PAGES_TO_MiB(cli->cl_dirty_max_pages);
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	return scnprintf(buf, PAGE_SIZE, "%lu\n", val);
 }
 
 static ssize_t max_dirty_mb_store(struct kobject *kobj,
@@ -150,17 +151,15 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
-	unsigned long pages_number;
+	unsigned long pages_number, max_dirty_mb;
 	int rc;
 
-	rc = kstrtoul(buffer, 10, &pages_number);
+	rc = kstrtoul(buffer, 10, &max_dirty_mb);
 	if (rc)
 		return rc;
 
-	pages_number *= 1 << (20 - PAGE_SHIFT); /* MB -> pages */
-
-	if (pages_number <= 0 ||
-	    pages_number >= OSC_MAX_DIRTY_MB_MAX << (20 - PAGE_SHIFT) ||
+	pages_number = MiB_TO_PAGES(max_dirty_mb);
+	if (pages_number >= MiB_TO_PAGES(OSC_MAX_DIRTY_MB_MAX) ||
 	    pages_number > totalram_pages() / 4) /* 1/4 of RAM */
 		return -ERANGE;
 
-- 
1.8.3.1
