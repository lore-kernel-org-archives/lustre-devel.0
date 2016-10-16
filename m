From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 16 Oct 2016 13:16:50 -0400
Subject: [lustre-devel] [PATCH] staging/lustre/llite: Move unstable_stats
	from sysfs to debugfs
Message-ID: <1476638210-208994-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

It's multiple values per file, so it has no business being in sysfs,
besides it was assuming seqfile anyway.

Introduced by
commit d806f30e639b ("staging: lustre: osc: revise unstable pages accounting")

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 34 +++++++++++------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 6eae605..23fda9d 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -871,12 +871,10 @@ static ssize_t xattr_cache_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(xattr_cache);
 
-static ssize_t unstable_stats_show(struct kobject *kobj,
-				   struct attribute *attr,
-				   char *buf)
+static int ll_unstable_stats_seq_show(struct seq_file *m, void *v)
 {
-	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+	struct super_block     *sb    = m->private;
+	struct ll_sb_info      *sbi   = ll_s2sbi(sb);
 	struct cl_client_cache *cache = sbi->ll_cache;
 	long pages;
 	int mb;
@@ -884,19 +882,21 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
 	pages = atomic_long_read(&cache->ccc_unstable_nr);
 	mb = (pages * PAGE_SIZE) >> 20;
 
-	return sprintf(buf, "unstable_check:     %8d\n"
-			    "unstable_pages: %12ld\n"
-			    "unstable_mb:        %8d\n",
-			    cache->ccc_unstable_check, pages, mb);
+	seq_printf(m,
+		   "unstable_check:     %8d\n"
+		   "unstable_pages: %12ld\n"
+		   "unstable_mb:        %8d\n",
+		   cache->ccc_unstable_check, pages, mb);
+
+	return 0;
 }
 
-static ssize_t unstable_stats_store(struct kobject *kobj,
-				    struct attribute *attr,
-				    const char *buffer,
-				    size_t count)
+static ssize_t ll_unstable_stats_seq_write(struct file *file,
+					   const char __user *buffer,
+					   size_t count, loff_t *off)
 {
-	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+	struct super_block *sb = ((struct seq_file *)file->private_data)->private;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	char kernbuf[128];
 	int val, rc;
 
@@ -922,7 +922,7 @@ static ssize_t unstable_stats_store(struct kobject *kobj,
 
 	return count;
 }
-LUSTRE_RW_ATTR(unstable_stats);
+LPROC_SEQ_FOPS(ll_unstable_stats);
 
 static ssize_t root_squash_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
@@ -995,6 +995,7 @@ static struct lprocfs_vars lprocfs_llite_obd_vars[] = {
 	/* { "filegroups",   lprocfs_rd_filegroups,  0, 0 }, */
 	{ "max_cached_mb",    &ll_max_cached_mb_fops, NULL },
 	{ "statahead_stats",  &ll_statahead_stats_fops, NULL, 0 },
+	{ "unstable_stats",   &ll_unstable_stats_fops, NULL },
 	{ "sbi_flags",	      &ll_sbi_flags_fops, NULL, 0 },
 	{ .name =		"nosquash_nids",
 	  .fops =		&ll_nosquash_nids_fops		},
@@ -1026,7 +1027,6 @@ static struct attribute *llite_attrs[] = {
 	&lustre_attr_max_easize.attr,
 	&lustre_attr_default_easize.attr,
 	&lustre_attr_xattr_cache.attr,
-	&lustre_attr_unstable_stats.attr,
 	&lustre_attr_root_squash.attr,
 	NULL,
 };
-- 
2.7.4
