From: James Simmons <jsimmons@infradead.org>
Date: Wed, 14 Jun 2017 11:01:17 -0400
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: lustre: make all struct
	file_operations constant
In-Reply-To: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1497452481-31124-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Checkpatch reported several cases of struct file_operations
not being const. This resolves those warnings.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fld/lproc_fld.c           | 2 +-
 drivers/staging/lustre/lustre/include/lprocfs_status.h  | 8 ++++----
 drivers/staging/lustre/lustre/llite/file.c              | 6 +++---
 drivers/staging/lustre/lustre/llite/llite_internal.h    | 8 ++++----
 drivers/staging/lustre/lustre/llite/lproc_llite.c       | 6 +++---
 drivers/staging/lustre/lustre/lov/lov_pool.c            | 2 +-
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 2 +-
 7 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index 61ac420..b83d7eb 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -136,7 +136,7 @@
 	return 0;
 }
 
-static struct file_operations fld_debugfs_cache_flush_fops = {
+static const struct file_operations fld_debugfs_cache_flush_fops = {
 	.owner		= THIS_MODULE,
 	.open           = simple_open,
 	.write		= fld_debugfs_cache_flush_write,
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 242abb8..1e68c77 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -49,7 +49,7 @@
 
 struct lprocfs_vars {
 	const char		*name;
-	struct file_operations	*fops;
+	const struct file_operations	*fops;
 	void			*data;
 	/**
 	 * sysfs file mode.
@@ -449,7 +449,7 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 struct dentry *ldebugfs_add_simple(struct dentry *root,
 				   char *name,
 				   void *data,
-				   struct file_operations *fops);
+				   const struct file_operations *fops);
 
 int ldebugfs_register_stats(struct dentry *parent,
 			    const char *name,
@@ -536,7 +536,7 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 {									\
 	return single_open(file, name##_seq_show, inode->i_private);	\
 }									\
-static struct file_operations name##_fops = {				\
+static const struct file_operations name##_fops = {			\
 	.owner   = THIS_MODULE,					    \
 	.open    = name##_single_open,				     \
 	.read    = seq_read,					       \
@@ -581,7 +581,7 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 	{								\
 		return single_open(file, NULL, inode->i_private);	\
 	}								\
-	static struct file_operations name##_##type##_fops = {	\
+	static const struct file_operations name##_##type##_fops = {	\
 		.open	= name##_##type##_open,				\
 		.write	= name##_##type##_write,			\
 		.release = lprocfs_single_release,			\
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 711fbb0..ab1c85c 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3114,7 +3114,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 }
 
 /* -o localflock - only provides locally consistent flock locks */
-struct file_operations ll_file_operations = {
+const struct file_operations ll_file_operations = {
 	.read_iter = ll_file_read_iter,
 	.write_iter = ll_file_write_iter,
 	.unlocked_ioctl = ll_file_ioctl,
@@ -3127,7 +3127,7 @@ struct file_operations ll_file_operations = {
 	.flush	  = ll_flush
 };
 
-struct file_operations ll_file_operations_flock = {
+const struct file_operations ll_file_operations_flock = {
 	.read_iter    = ll_file_read_iter,
 	.write_iter   = ll_file_write_iter,
 	.unlocked_ioctl = ll_file_ioctl,
@@ -3143,7 +3143,7 @@ struct file_operations ll_file_operations_flock = {
 };
 
 /* These are for -o noflock - to return ENOSYS on flock calls */
-struct file_operations ll_file_operations_noflock = {
+const struct file_operations ll_file_operations_noflock = {
 	.read_iter    = ll_file_read_iter,
 	.write_iter   = ll_file_write_iter,
 	.unlocked_ioctl = ll_file_ioctl,
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index de09ddf..41a0c8d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -470,7 +470,7 @@ struct ll_sb_info {
 
 	struct ll_ra_info	 ll_ra_info;
 	unsigned int	      ll_namelen;
-	struct file_operations   *ll_fop;
+	const struct file_operations	*ll_fop;
 
 	unsigned int		  ll_md_brw_pages; /* readdir pages per RPC */
 
@@ -736,9 +736,9 @@ int ll_md_blocking_ast(struct ldlm_lock *, struct ldlm_lock_desc *,
 extern const struct address_space_operations ll_aops;
 
 /* llite/file.c */
-extern struct file_operations ll_file_operations;
-extern struct file_operations ll_file_operations_flock;
-extern struct file_operations ll_file_operations_noflock;
+extern const struct file_operations ll_file_operations;
+extern const struct file_operations ll_file_operations_flock;
+extern const struct file_operations ll_file_operations_noflock;
 extern const struct inode_operations ll_file_inode_operations;
 int ll_have_md_lock(struct inode *inode, __u64 *bits,
 		    enum ldlm_mode l_req_mode);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index c742cba..aeae667 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -39,9 +39,9 @@
 #include "vvp_internal.h"
 
 /* debugfs llite mount point registration */
-static struct file_operations ll_rw_extents_stats_fops;
-static struct file_operations ll_rw_extents_stats_pp_fops;
-static struct file_operations ll_rw_offset_stats_fops;
+static const struct file_operations ll_rw_extents_stats_fops;
+static const struct file_operations ll_rw_extents_stats_pp_fops;
+static const struct file_operations ll_rw_offset_stats_fops;
 
 static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 1952bbd..39daa17 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -286,7 +286,7 @@ static int pool_proc_open(struct inode *inode, struct file *file)
 	return rc;
 }
 
-static struct file_operations pool_proc_operations = {
+static const struct file_operations pool_proc_operations = {
 	.open	   = pool_proc_open,
 	.read	   = seq_read,
 	.llseek	 = seq_lseek,
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 6d1caed0..bc19f19 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -301,7 +301,7 @@ int lprocfs_seq_release(struct inode *inode, struct file *file)
 
 struct dentry *ldebugfs_add_simple(struct dentry *root,
 				   char *name, void *data,
-				   struct file_operations *fops)
+				   const struct file_operations *fops)
 {
 	struct dentry *entry;
 	umode_t mode = 0;
-- 
1.8.3.1
