From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:02 -0400
Subject: [lustre-devel] [PATCH 06/23] lustre: obd: rename lprocfs_ /
 LPROC_SEQ_ to debugfs name
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For a long time lustre has not used procfs so rename several
functions starting with lprocfs_* to ldebugfs_*. Do this as
well the for LPROC_SEQ_* macros to LDEBUGFS_SEQ_*.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: 0100ab268c312 ("LU-8066 obd: final pieces for sysfs/debugfs support.")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/28108
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/fid/fid_internal.h        |   2 +-
 fs/lustre/fid/lproc_fid.c           |  10 +--
 fs/lustre/fld/fld_internal.h        |   2 +-
 fs/lustre/fld/lproc_fld.c           |  12 +--
 fs/lustre/include/lprocfs_status.h  | 158 ++++++++++++------------------------
 fs/lustre/include/obd.h             |   2 +-
 fs/lustre/include/obd_class.h       |   4 -
 fs/lustre/ldlm/ldlm_internal.h      |   2 +-
 fs/lustre/ldlm/ldlm_pool.c          |   4 +-
 fs/lustre/ldlm/ldlm_resource.c      |  10 +--
 fs/lustre/llite/lproc_llite.c       |  30 +++----
 fs/lustre/mdc/lproc_mdc.c           |  28 +++----
 fs/lustre/mgc/lproc_mgc.c           |  12 +--
 fs/lustre/obdclass/lprocfs_status.c |  48 ++++++-----
 fs/lustre/obdclass/obd_config.c     |  92 ---------------------
 fs/lustre/obdclass/obd_sysfs.c      |   2 +-
 fs/lustre/osc/lproc_osc.c           |  24 +++---
 fs/lustre/ptlrpc/lproc_ptlrpc.c     |  30 +++----
 fs/lustre/ptlrpc/sec_lproc.c        |  15 ++--
 19 files changed, 171 insertions(+), 316 deletions(-)

diff --git a/fs/lustre/fid/fid_internal.h b/fs/lustre/fid/fid_internal.h
index 7bb1283..cbf0987 100644
--- a/fs/lustre/fid/fid_internal.h
+++ b/fs/lustre/fid/fid_internal.h
@@ -41,6 +41,6 @@
 
 /* Functions used internally in module. */
 
-extern struct lprocfs_vars seq_client_debugfs_list[];
+extern struct ldebugfs_vars seq_client_debugfs_list[];
 
 #endif /* __FID_INTERNAL_H */
diff --git a/fs/lustre/fid/lproc_fid.c b/fs/lustre/fid/lproc_fid.c
index 15468b4..be9846b 100644
--- a/fs/lustre/fid/lproc_fid.c
+++ b/fs/lustre/fid/lproc_fid.c
@@ -209,12 +209,12 @@ static ssize_t ldebugfs_fid_width_seq_write(struct file *file,
 	return 0;
 }
 
-LPROC_SEQ_FOPS(ldebugfs_fid_space);
-LPROC_SEQ_FOPS(ldebugfs_fid_width);
-LPROC_SEQ_FOPS_RO(ldebugfs_fid_server);
-LPROC_SEQ_FOPS_RO(ldebugfs_fid_fid);
+LDEBUGFS_SEQ_FOPS(ldebugfs_fid_space);
+LDEBUGFS_SEQ_FOPS(ldebugfs_fid_width);
+LDEBUGFS_SEQ_FOPS_RO(ldebugfs_fid_server);
+LDEBUGFS_SEQ_FOPS_RO(ldebugfs_fid_fid);
 
-struct lprocfs_vars seq_client_debugfs_list[] = {
+struct ldebugfs_vars seq_client_debugfs_list[] = {
 	{ .name =	"space",
 	  .fops =	&ldebugfs_fid_space_fops },
 	{ .name	=	"width",
diff --git a/fs/lustre/fld/fld_internal.h b/fs/lustre/fld/fld_internal.h
index d44e378..d32360c 100644
--- a/fs/lustre/fld/fld_internal.h
+++ b/fs/lustre/fld/fld_internal.h
@@ -133,7 +133,7 @@ int fld_client_rpc(struct obd_export *exp,
 		   struct lu_seq_range *range, u32 fld_op,
 		   struct ptlrpc_request **reqp);
 
-extern struct lprocfs_vars fld_client_debugfs_list[];
+extern struct ldebugfs_vars fld_client_debugfs_list[];
 
 struct fld_cache *fld_cache_init(const char *name,
 				 int cache_size, int cache_threshold);
diff --git a/fs/lustre/fld/lproc_fld.c b/fs/lustre/fld/lproc_fld.c
index e8c8bc7..9e1be53 100644
--- a/fs/lustre/fld/lproc_fld.c
+++ b/fs/lustre/fld/lproc_fld.c
@@ -117,8 +117,8 @@
 }
 
 static ssize_t
-lprocfs_wr_cache_flush(struct file *file, const char __user *buffer,
-		      size_t count, loff_t *pos)
+ldebugfs_cache_flush_seq_write(struct file *file, const char __user *buffer,
+			       size_t count, loff_t *pos)
 {
 	struct seq_file *m = file->private_data;
 	struct lu_client_fld *fld = m->private;
@@ -130,11 +130,11 @@
 	return count;
 }
 
-LPROC_SEQ_FOPS_RO(fld_debugfs_targets);
-LPROC_SEQ_FOPS(fld_debugfs_hash);
-LPROC_SEQ_FOPS_WR_ONLY(fld, cache_flush);
+LDEBUGFS_SEQ_FOPS_RO(fld_debugfs_targets);
+LDEBUGFS_SEQ_FOPS(fld_debugfs_hash);
+LDEBUGFS_SEQ_FOPS_WR_ONLY(fld, cache_flush);
 
-struct lprocfs_vars fld_client_debugfs_list[] = {
+struct ldebugfs_vars fld_client_debugfs_list[] = {
 	{ .name =	"targets",
 	  .fops =	&fld_debugfs_targets_fops	},
 	{ .name =	"hash",
diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 759e66b..33d78de 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -49,13 +49,12 @@
 #include <uapi/linux/lustre/lustre_cfg.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 
-struct lprocfs_vars {
+/** debugfs file mode. */
+struct ldebugfs_vars {
 	const char			*name;
 	const struct file_operations	*fops;
 	void				*data;
-	/**
-	 * sysfs file mode.
-	 */
+	/** debugfs file mode. */
 	umode_t				proc_mode;
 };
 
@@ -67,11 +66,6 @@ static inline unsigned int pct(unsigned long a, unsigned long b)
 #define PAGES_TO_MiB(pages)	((pages) >> (20 - PAGE_SHIFT))
 #define MiB_TO_PAGES(mb)	((mb) << (20 - PAGE_SHIFT))
 
-struct lprocfs_static_vars {
-	struct lprocfs_vars		*obd_vars;
-	const struct attribute_group	*sysfs_vars;
-};
-
 /* if we find more consumers this could be generalized */
 #define OBD_HIST_MAX 32
 struct obd_histogram {
@@ -446,7 +440,7 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 extern const struct file_operations lprocfs_stats_seq_fops;
 
 /* lprocfs_status.c */
-void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *var,
+void ldebugfs_add_vars(struct dentry *parent, struct ldebugfs_vars *var,
 		       void *data);
 
 int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only);
@@ -454,29 +448,30 @@ void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *var,
 
 /* Generic callbacks */
 
-int lprocfs_rd_uint(struct seq_file *m, void *data);
+int ldebugfs_uint(struct seq_file *m, void *data);
 int lprocfs_wr_uint(struct file *file, const char __user *buffer,
 		    unsigned long count, void *data);
-int lprocfs_rd_server_uuid(struct seq_file *m, void *data);
-int lprocfs_rd_conn_uuid(struct seq_file *m, void *data);
+int ldebugfs_server_uuid_seq_show(struct seq_file *m, void *data);
+int ldebugfs_conn_uuid_seq_show(struct seq_file *m, void *data);
 ssize_t conn_uuid_show(struct kobject *kobj, struct attribute *attr, char *buf);
-int lprocfs_rd_import(struct seq_file *m, void *data);
-int lprocfs_rd_state(struct seq_file *m, void *data);
-int lprocfs_rd_connect_flags(struct seq_file *m, void *data);
+int ldebugfs_import_seq_show(struct seq_file *m, void *data);
+int ldebugfs_state_seq_show(struct seq_file *m, void *data);
+int ldebugfs_connect_flags_seq_show(struct seq_file *m, void *data);
 
 struct adaptive_timeout;
 int lprocfs_at_hist_helper(struct seq_file *m, struct adaptive_timeout *at);
-int lprocfs_rd_timeouts(struct seq_file *m, void *data);
+int ldebugfs_timeouts_seq_show(struct seq_file *m, void *data);
 ssize_t ping_store(struct kobject *kobj, struct attribute *attr,
 		   const char *buffer, size_t count);
 ssize_t ping_show(struct kobject *kobj, struct attribute *attr,
 		  char *buffer);
 
-int lprocfs_wr_import(struct file *file, const char __user *buffer,
-		      size_t count, loff_t *off);
-int lprocfs_rd_pinger_recov(struct seq_file *m, void *n);
-int lprocfs_wr_pinger_recov(struct file *file, const char __user *buffer,
-			    size_t count, loff_t *off);
+ssize_t ldebugfs_import_seq_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *off);
+int ldebugfs_pinger_recov_seq_show(struct seq_file *m, void *n);
+ssize_t ldebugfs_pinger_recov_seq_write(struct file *file,
+					const char __user *buffer,
+					size_t count, loff_t *off);
 
 int string_to_size(u64 *size, const char *buffer, size_t count);
 int sysfs_memparse(const char *buffer, size_t count, u64 *val,
@@ -501,12 +496,12 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 	     __imp ? 1 : (up_read(&(__obd)->u.cli.cl_sem), 0);		\
 	     __imp = NULL)
 
-/* write the name##_seq_show function, call LPROC_SEQ_FOPS_RO for read-only
- * proc entries; otherwise, you will define name##_seq_write function also for
- * a read-write proc entry, and then call LPROC_SEQ_SEQ instead. Finally,
- * call ldebugfs_obd_seq_create(obd, filename, 0444, &name#_fops, data);
+/* write the name##_seq_show function, call LDEBUGFS_SEQ_FOPS_RO for read-only
+ * debugfs entries; otherwise, you will define name##_seq_write function also
+ * for a read-write debugfs entry, and then call LDEBUGFS_SEQ_SEQ instead.
+ * Finally, call debugfs_create_file(filename, 0444, obd, data, &name#_fops);
  */
-#define __LPROC_SEQ_FOPS(name, custom_seq_write)			\
+#define __LDEBUGFS_SEQ_FOPS(name, custom_seq_write)			\
 static int name##_single_open(struct inode *inode, struct file *file)	\
 {									\
 	return single_open(file, name##_seq_show, inode->i_private);	\
@@ -520,44 +515,46 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 	.release = single_release,					\
 }
 
-#define LPROC_SEQ_FOPS_RO(name)	 __LPROC_SEQ_FOPS(name, NULL)
-#define LPROC_SEQ_FOPS(name)	    __LPROC_SEQ_FOPS(name, name##_seq_write)
+#define LDEBUGFS_SEQ_FOPS_RO(name)	__LDEBUGFS_SEQ_FOPS(name, NULL)
+#define LDEBUGFS_SEQ_FOPS(name)		__LDEBUGFS_SEQ_FOPS(name, \
+							    name##_seq_write)
 
-#define LPROC_SEQ_FOPS_RO_TYPE(name, type)				\
+#define LDEBUGFS_SEQ_FOPS_RO_TYPE(name, type)				\
 	static int name##_##type##_seq_show(struct seq_file *m, void *v)\
 	{								\
 		if (!m->private)					\
 			return -ENODEV;					\
-		return lprocfs_rd_##type(m, m->private);		\
+		return ldebugfs_##type##_seq_show(m, m->private);	\
 	}								\
-	LPROC_SEQ_FOPS_RO(name##_##type)
+	LDEBUGFS_SEQ_FOPS_RO(name##_##type)
 
-#define LPROC_SEQ_FOPS_RW_TYPE(name, type)				\
+#define LDEBUGFS_SEQ_FOPS_RW_TYPE(name, type)				\
 	static int name##_##type##_seq_show(struct seq_file *m, void *v)\
 	{								\
 		if (!m->private)					\
 			return -ENODEV;					\
-		return lprocfs_rd_##type(m, m->private);		\
+		return ldebugfs_##type##_seq_show(m, m->private);	\
 	}								\
 	static ssize_t name##_##type##_seq_write(struct file *file,	\
 			const char __user *buffer, size_t count,	\
-						loff_t *off)		\
+			loff_t *off)					\
 	{								\
 		struct seq_file *seq = file->private_data;		\
 									\
 		if (!seq->private)					\
 			return -ENODEV;					\
-		return lprocfs_wr_##type(file, buffer,			\
-					 count, seq->private);		\
+		return ldebugfs_##type##_seq_write(file, buffer, count,	\
+						   seq->private);	\
 	}								\
-	LPROC_SEQ_FOPS(name##_##type)
+	LDEBUGFS_SEQ_FOPS(name##_##type)
 
-#define LPROC_SEQ_FOPS_WR_ONLY(name, type)				\
+#define LDEBUGFS_SEQ_FOPS_WR_ONLY(name, type)				\
 	static ssize_t name##_##type##_write(struct file *file,		\
-			const char __user *buffer, size_t count,	\
-						loff_t *off)		\
+					     const char __user *buffer,	\
+					     size_t count, loff_t *off)	\
 	{								\
-		return lprocfs_wr_##type(file, buffer, count, off);	\
+		return ldebugfs_##type##_seq_write(file, buffer, count, \
+						   off);		\
 	}								\
 	static int name##_##type##_open(struct inode *inode,		\
 					struct file *file)		\
@@ -565,8 +562,8 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 		return single_open(file, NULL, inode->i_private);	\
 	}								\
 	static const struct file_operations name##_##type##_fops = {	\
-		.open	= name##_##type##_open,				\
-		.write	= name##_##type##_write,			\
+		.open	 = name##_##type##_open,			\
+		.write	 = name##_##type##_write,			\
 		.release = single_release,				\
 	}
 
@@ -602,68 +599,13 @@ ssize_t short_io_bytes_store(struct kobject *kobj, struct attribute *attr,
 			     const char *buffer, size_t count);
 
 struct root_squash_info;
-int lprocfs_wr_root_squash(const char __user *buffer, unsigned long count,
-			   struct root_squash_info *squash, char *name);
-int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
-			     struct root_squash_info *squash, char *name);
-
-/* all quota proc functions */
-int lprocfs_quota_rd_bunit(char *page, char **start,
-			   loff_t off, int count,
-			   int *eof, void *data);
-int lprocfs_quota_wr_bunit(struct file *file, const char *buffer,
-			   unsigned long count, void *data);
-int lprocfs_quota_rd_btune(char *page, char **start,
-			   loff_t off, int count,
-			   int *eof, void *data);
-int lprocfs_quota_wr_btune(struct file *file, const char *buffer,
-			   unsigned long count, void *data);
-int lprocfs_quota_rd_iunit(char *page, char **start,
-			   loff_t off, int count,
-			   int *eof, void *data);
-int lprocfs_quota_wr_iunit(struct file *file, const char *buffer,
-			   unsigned long count, void *data);
-int lprocfs_quota_rd_itune(char *page, char **start,
-			   loff_t off, int count,
-			   int *eof, void *data);
-int lprocfs_quota_wr_itune(struct file *file, const char *buffer,
-			   unsigned long count, void *data);
-int lprocfs_quota_rd_type(char *page, char **start, loff_t off, int count,
-			  int *eof, void *data);
-int lprocfs_quota_wr_type(struct file *file, const char *buffer,
-			  unsigned long count, void *data);
-int lprocfs_quota_rd_switch_seconds(char *page, char **start, loff_t off,
-				    int count, int *eof, void *data);
-int lprocfs_quota_wr_switch_seconds(struct file *file,
-				    const char *buffer,
-				    unsigned long count, void *data);
-int lprocfs_quota_rd_sync_blk(char *page, char **start, loff_t off,
-			      int count, int *eof, void *data);
-int lprocfs_quota_wr_sync_blk(struct file *file, const char *buffer,
-			      unsigned long count, void *data);
-int lprocfs_quota_rd_switch_qs(char *page, char **start, loff_t off,
-			       int count, int *eof, void *data);
-int lprocfs_quota_wr_switch_qs(struct file *file,
-			       const char *buffer, unsigned long count,
-			       void *data);
-int lprocfs_quota_rd_boundary_factor(char *page, char **start, loff_t off,
-				     int count, int *eof, void *data);
-int lprocfs_quota_wr_boundary_factor(struct file *file,
-				     const char *buffer, unsigned long count,
-				     void *data);
-int lprocfs_quota_rd_least_bunit(char *page, char **start, loff_t off,
-				 int count, int *eof, void *data);
-int lprocfs_quota_wr_least_bunit(struct file *file,
-				 const char *buffer, unsigned long count,
-				 void *data);
-int lprocfs_quota_rd_least_iunit(char *page, char **start, loff_t off,
-				 int count, int *eof, void *data);
-int lprocfs_quota_wr_least_iunit(struct file *file,
-				 const char *buffer, unsigned long count,
-				 void *data);
-int lprocfs_quota_rd_qs_factor(char *page, char **start, loff_t off,
-			       int count, int *eof, void *data);
-int lprocfs_quota_wr_qs_factor(struct file *file,
-			       const char *buffer, unsigned long count,
-			       void *data);
+ssize_t ldebugfs_root_squash_seq_write(const char __user *buffer,
+				       unsigned long count,
+				       struct root_squash_info *squash,
+				       char *name);
+ssize_t ldebugfs_nosquash_nids_seq_write(const char __user *buffer,
+					 unsigned long count,
+					 struct root_squash_info *squash,
+					 char *name);
+
 #endif /* LPROCFS_SNMP_H */
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index ad2b2f4..849483f 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -608,7 +608,7 @@ struct obd_device {
 	struct dentry		*obd_svc_debugfs_entry;
 	struct lprocfs_stats	*obd_svc_stats;
 	const struct attribute **obd_attrs;
-	struct lprocfs_vars	*obd_vars;
+	struct ldebugfs_vars	*obd_vars;
 	atomic_t		 obd_evict_inprogress;
 	wait_queue_head_t	 obd_evict_inprogress_waitq;
 	struct list_head	 obd_evict_list; /* protected with pet_lock */
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 187553d..a22581d 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -134,8 +134,6 @@ typedef int (*llog_cb_t)(const struct lu_env *, struct llog_handle *,
 ssize_t class_set_global(const char *param);
 ssize_t class_modify_config(struct lustre_cfg *lcfg, const char *prefix,
 			    struct kobject *kobj);
-int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
-			     struct lustre_cfg *lcfg, void *data);
 
 /* For interoperability */
 struct cfg_interop_param {
@@ -162,8 +160,6 @@ int class_config_llog_handler(const struct lu_env *env,
 			      struct llog_rec_hdr *rec, void *data);
 
 /* obdecho */
-void lprocfs_echo_init_vars(struct lprocfs_static_vars *lvars);
-
 #define CFG_F_START	0x01   /* Set when we start updating from a log */
 #define CFG_F_MARKER	0x02   /* We are within a maker */
 #define CFG_F_SKIP	0x04   /* We should ignore this cfg command */
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 996c0fb..0dce219 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -298,7 +298,7 @@ enum ldlm_policy_res {
 	struct __##var##__dummy_write {; } /* semicolon catcher */
 
 static inline void
-ldlm_add_var(struct lprocfs_vars *vars, struct dentry *debugfs_entry,
+ldlm_add_var(struct ldebugfs_vars *vars, struct dentry *debugfs_entry,
 	     const char *name, void *data, const struct file_operations *ops)
 {
 	vars->name = name;
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 9185dc93..40585f7 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -459,7 +459,7 @@ static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 	return 0;
 }
 
-LPROC_SEQ_FOPS_RO(lprocfs_pool_state);
+LDEBUGFS_SEQ_FOPS_RO(lprocfs_pool_state);
 
 static ssize_t grant_speed_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
@@ -549,7 +549,7 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 	struct ldlm_namespace *ns = container_of(pl, struct ldlm_namespace,
 						 ns_pool);
 	struct dentry *debugfs_ns_parent;
-	struct lprocfs_vars pool_vars[2];
+	struct ldebugfs_vars pool_vars[2];
 	int rc = 0;
 
 	debugfs_ns_parent = ns->ns_debugfs_entry;
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index a461ca7..d0a59a8 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -71,15 +71,15 @@
 static unsigned int ldlm_dump_granted_max = 256;
 
 static ssize_t
-lprocfs_wr_dump_ns(struct file *file, const char __user *buffer,
-		   size_t count, loff_t *off)
+ldebugfs_dump_ns_seq_write(struct file *file, const char __user *buffer,
+			   size_t count, loff_t *off)
 {
 	ldlm_dump_all_namespaces(LDLM_NAMESPACE_SERVER, D_DLMTRACE);
 	ldlm_dump_all_namespaces(LDLM_NAMESPACE_CLIENT, D_DLMTRACE);
 	return count;
 }
 
-LPROC_SEQ_FOPS_WR_ONLY(ldlm, dump_ns);
+LDEBUGFS_SEQ_FOPS_WR_ONLY(ldlm, dump_ns);
 
 static int ldlm_rw_uint_seq_show(struct seq_file *m, void *v)
 {
@@ -99,9 +99,9 @@ static int ldlm_rw_uint_seq_show(struct seq_file *m, void *v)
 				    (unsigned int *)seq->private);
 }
 
-LPROC_SEQ_FOPS(ldlm_rw_uint);
+LDEBUGFS_SEQ_FOPS(ldlm_rw_uint);
 
-static struct lprocfs_vars ldlm_debugfs_list[] = {
+static struct ldebugfs_vars ldlm_debugfs_list[] = {
 	{ "dump_namespaces", &ldlm_dump_ns_fops, NULL, 0222 },
 	{ "dump_granted_max", &ldlm_rw_uint_fops, &ldlm_dump_granted_max },
 	{ NULL }
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index f5a1940..a742200 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -319,7 +319,7 @@ static int ll_site_stats_seq_show(struct seq_file *m, void *v)
 	return cl_site_stats_print(lu2cl_site(ll_s2sbi(sb)->ll_site), m);
 }
 
-LPROC_SEQ_FOPS_RO(ll_site_stats);
+LDEBUGFS_SEQ_FOPS_RO(ll_site_stats);
 
 static ssize_t max_read_ahead_mb_show(struct kobject *kobj,
 				      struct attribute *attr, char *buf)
@@ -601,7 +601,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 	return rc;
 }
 
-LPROC_SEQ_FOPS(ll_max_cached_mb);
+LDEBUGFS_SEQ_FOPS(ll_max_cached_mb);
 
 static ssize_t checksums_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
@@ -851,7 +851,7 @@ static int ll_statahead_stats_seq_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-LPROC_SEQ_FOPS_RO(ll_statahead_stats);
+LDEBUGFS_SEQ_FOPS_RO(ll_statahead_stats);
 
 static ssize_t lazystatfs_show(struct kobject *kobj,
 			       struct attribute *attr,
@@ -1028,7 +1028,7 @@ static int ll_sbi_flags_seq_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-LPROC_SEQ_FOPS_RO(ll_sbi_flags);
+LDEBUGFS_SEQ_FOPS_RO(ll_sbi_flags);
 
 static ssize_t xattr_cache_show(struct kobject *kobj,
 				struct attribute *attr,
@@ -1376,7 +1376,7 @@ static ssize_t ll_unstable_stats_seq_write(struct file *file,
 
 	return count;
 }
-LPROC_SEQ_FOPS(ll_unstable_stats);
+LDEBUGFS_SEQ_FOPS(ll_unstable_stats);
 
 static int ll_root_squash_seq_show(struct seq_file *m, void *v)
 {
@@ -1397,9 +1397,10 @@ static ssize_t ll_root_squash_seq_write(struct file *file,
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct root_squash_info *squash = &sbi->ll_squash;
 
-	return lprocfs_wr_root_squash(buffer, count, squash, sbi->ll_fsname);
+	return ldebugfs_root_squash_seq_write(buffer, count, squash,
+					      sbi->ll_fsname);
 }
-LPROC_SEQ_FOPS(ll_root_squash);
+LDEBUGFS_SEQ_FOPS(ll_root_squash);
 
 static int ll_nosquash_nids_seq_show(struct seq_file *m, void *v)
 {
@@ -1432,7 +1433,8 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	struct root_squash_info *squash = &sbi->ll_squash;
 	int rc;
 
-	rc = lprocfs_wr_nosquash_nids(buffer, count, squash, sbi->ll_fsname);
+	rc = ldebugfs_nosquash_nids_seq_write(buffer, count, squash,
+					      sbi->ll_fsname);
 	if (rc < 0)
 		return rc;
 
@@ -1441,7 +1443,7 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	return rc;
 }
 
-LPROC_SEQ_FOPS(ll_nosquash_nids);
+LDEBUGFS_SEQ_FOPS(ll_nosquash_nids);
 
 static int ll_pcc_seq_show(struct seq_file *m, void *v)
 {
@@ -1480,9 +1482,9 @@ static ssize_t ll_pcc_seq_write(struct file *file, const char __user *buffer,
 	kfree(kernbuf);
 	return rc ? rc : count;
 }
-LPROC_SEQ_FOPS(ll_pcc);
+LDEBUGFS_SEQ_FOPS(ll_pcc);
 
-struct lprocfs_vars lprocfs_llite_obd_vars[] = {
+struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	{ .name	=	"site",
 	  .fops	=	&ll_site_stats_fops			},
 	{ .name	=	"max_cached_mb",
@@ -1858,7 +1860,7 @@ static ssize_t ll_rw_extents_stats_pp_seq_write(struct file *file,
 	return len;
 }
 
-LPROC_SEQ_FOPS(ll_rw_extents_stats_pp);
+LDEBUGFS_SEQ_FOPS(ll_rw_extents_stats_pp);
 
 static int ll_rw_extents_stats_seq_show(struct seq_file *seq, void *v)
 {
@@ -1918,7 +1920,7 @@ static ssize_t ll_rw_extents_stats_seq_write(struct file *file,
 	return len;
 }
 
-LPROC_SEQ_FOPS(ll_rw_extents_stats);
+LDEBUGFS_SEQ_FOPS(ll_rw_extents_stats);
 
 void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		       struct ll_file_data *file, loff_t pos,
@@ -2109,4 +2111,4 @@ static ssize_t ll_rw_offset_stats_seq_write(struct file *file,
 	return len;
 }
 
-LPROC_SEQ_FOPS(ll_rw_offset_stats);
+LDEBUGFS_SEQ_FOPS(ll_rw_offset_stats);
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 0c252ed..d7506ea 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -90,7 +90,7 @@ static ssize_t mdc_max_dirty_mb_seq_write(struct file *file,
 
 	return count;
 }
-LPROC_SEQ_FOPS(mdc_max_dirty_mb);
+LDEBUGFS_SEQ_FOPS(mdc_max_dirty_mb);
 
 static int mdc_cached_mb_seq_show(struct seq_file *m, void *v)
 {
@@ -150,7 +150,7 @@ static int mdc_cached_mb_seq_show(struct seq_file *m, void *v)
 
 	return count;
 }
-LPROC_SEQ_FOPS(mdc_cached_mb);
+LDEBUGFS_SEQ_FOPS(mdc_cached_mb);
 
 static int mdc_contention_seconds_seq_show(struct seq_file *m, void *v)
 {
@@ -189,7 +189,7 @@ static ssize_t mdc_contention_seconds_seq_write(struct file *file,
 
 	return count;
 }
-LPROC_SEQ_FOPS(mdc_contention_seconds);
+LDEBUGFS_SEQ_FOPS(mdc_contention_seconds);
 
 static int mdc_unstable_stats_seq_show(struct seq_file *m, void *v)
 {
@@ -205,7 +205,7 @@ static int mdc_unstable_stats_seq_show(struct seq_file *m, void *v)
 		   "unstable_mb:              %10d\n", pages, mb);
 	return 0;
 }
-LPROC_SEQ_FOPS_RO(mdc_unstable_stats);
+LDEBUGFS_SEQ_FOPS_RO(mdc_unstable_stats);
 
 static ssize_t active_show(struct kobject *kobj, struct attribute *attr,
 			   char *buf)
@@ -427,7 +427,7 @@ static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 
 	return 0;
 }
-LPROC_SEQ_FOPS(mdc_rpc_stats);
+LDEBUGFS_SEQ_FOPS(mdc_rpc_stats);
 
 static int mdc_stats_seq_show(struct seq_file *seq, void *v)
 {
@@ -459,7 +459,7 @@ static ssize_t mdc_stats_seq_write(struct file *file,
 	memset(stats, 0, sizeof(*stats));
 	return len;
 }
-LPROC_SEQ_FOPS(mdc_stats);
+LDEBUGFS_SEQ_FOPS(mdc_stats);
 
 static int mdc_dom_min_repsize_seq_show(struct seq_file *m, void *v)
 {
@@ -489,17 +489,17 @@ static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
 	obd->u.cli.cl_dom_min_inline_repsize = val;
 	return count;
 }
-LPROC_SEQ_FOPS(mdc_dom_min_repsize);
+LDEBUGFS_SEQ_FOPS(mdc_dom_min_repsize);
 
-LPROC_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
-LPROC_SEQ_FOPS_RO_TYPE(mdc, server_uuid);
-LPROC_SEQ_FOPS_RO_TYPE(mdc, timeouts);
-LPROC_SEQ_FOPS_RO_TYPE(mdc, state);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(mdc, server_uuid);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(mdc, timeouts);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(mdc, state);
 
-LPROC_SEQ_FOPS_RW_TYPE(mdc, import);
-LPROC_SEQ_FOPS_RW_TYPE(mdc, pinger_recov);
+LDEBUGFS_SEQ_FOPS_RW_TYPE(mdc, import);
+LDEBUGFS_SEQ_FOPS_RW_TYPE(mdc, pinger_recov);
 
-static struct lprocfs_vars lprocfs_mdc_obd_vars[] = {
+static struct ldebugfs_vars lprocfs_mdc_obd_vars[] = {
 	{ .name	=	"connect_flags",
 	  .fops	=	&mdc_connect_flags_fops		},
 	{ .name	=	"mds_server_uuid",
diff --git a/fs/lustre/mgc/lproc_mgc.c b/fs/lustre/mgc/lproc_mgc.c
index 0c716df..c22ec23 100644
--- a/fs/lustre/mgc/lproc_mgc.c
+++ b/fs/lustre/mgc/lproc_mgc.c
@@ -37,22 +37,22 @@
 #include <lprocfs_status.h>
 #include "mgc_internal.h"
 
-LPROC_SEQ_FOPS_RO_TYPE(mgc, connect_flags);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(mgc, connect_flags);
 
-LPROC_SEQ_FOPS_RO_TYPE(mgc, server_uuid);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(mgc, server_uuid);
 
-LPROC_SEQ_FOPS_RO_TYPE(mgc, import);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(mgc, import);
 
-LPROC_SEQ_FOPS_RO_TYPE(mgc, state);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(mgc, state);
 
 static int mgc_ir_state_seq_show(struct seq_file *m, void *v)
 {
 	return lprocfs_mgc_rd_ir_state(m, m->private);
 }
 
-LPROC_SEQ_FOPS_RO(mgc_ir_state);
+LDEBUGFS_SEQ_FOPS_RO(mgc_ir_state);
 
-struct lprocfs_vars lprocfs_mgc_obd_vars[] = {
+struct ldebugfs_vars lprocfs_mgc_obd_vars[] = {
 	{ .name =	"connect_flags",
 	  .fops =	&mgc_connect_flags_fops	},
 	{ .name =	"mgs_server_uuid",
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index aba04d5..3d16516 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -412,7 +412,7 @@ int sysfs_memparse(const char *buffer, size_t count, u64 *val,
 
 static const struct file_operations lprocfs_generic_fops = { };
 
-void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *list,
+void ldebugfs_add_vars(struct dentry *parent, struct ldebugfs_vars *list,
 		       void *data)
 {
 	if (IS_ERR_OR_NULL(parent) || IS_ERR_OR_NULL(list))
@@ -593,7 +593,7 @@ ssize_t conn_uuid_show(struct kobject *kobj, struct attribute *attr, char *buf)
 }
 EXPORT_SYMBOL(conn_uuid_show);
 
-int lprocfs_rd_server_uuid(struct seq_file *m, void *data)
+int ldebugfs_server_uuid_seq_show(struct seq_file *m, void *data)
 {
 	struct obd_device *obd = data;
 	struct obd_import *imp;
@@ -610,7 +610,7 @@ int lprocfs_rd_server_uuid(struct seq_file *m, void *data)
 
 	return 0;
 }
-EXPORT_SYMBOL(lprocfs_rd_server_uuid);
+EXPORT_SYMBOL(ldebugfs_server_uuid_seq_show);
 
 /**
  * Lock statistics structure for access, possibly only on this CPU.
@@ -804,7 +804,7 @@ static void obd_connect_seq_flags2str(struct seq_file *m, u64 flags,
 	}
 }
 
-static void lprocfs_rd_import_locked(struct seq_file *m,
+static void ldebugfs_import_locked(struct seq_file *m,
 				     struct obd_device *obd,
 				     struct obd_import *imp)
 {
@@ -942,7 +942,7 @@ static void lprocfs_rd_import_locked(struct seq_file *m,
 	}
 }
 
-int lprocfs_rd_import(struct seq_file *m, void *data)
+int ldebugfs_import_seq_show(struct seq_file *m, void *data)
 {
 	struct obd_device *obd = (struct obd_device *)data;
 	struct obd_import *imp;
@@ -950,12 +950,12 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 
 	LASSERT(obd);
 	with_imp_locked(obd, imp, rc)
-		lprocfs_rd_import_locked(m, obd, imp);
+		ldebugfs_import_locked(m, obd, imp);
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_rd_import);
+EXPORT_SYMBOL(ldebugfs_import_seq_show);
 
-int lprocfs_rd_state(struct seq_file *m, void *data)
+int ldebugfs_state_seq_show(struct seq_file *m, void *data)
 {
 	struct obd_device *obd = data;
 	struct obd_import *imp;
@@ -980,7 +980,7 @@ int lprocfs_rd_state(struct seq_file *m, void *data)
 
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_rd_state);
+EXPORT_SYMBOL(ldebugfs_state_seq_show);
 
 int lprocfs_at_hist_helper(struct seq_file *m, struct adaptive_timeout *at)
 {
@@ -993,8 +993,8 @@ int lprocfs_at_hist_helper(struct seq_file *m, struct adaptive_timeout *at)
 }
 EXPORT_SYMBOL(lprocfs_at_hist_helper);
 
-/* See also ptlrpc_lprocfs_rd_timeouts */
-static void lprocfs_rd_timeouts_locked(struct seq_file *m,
+/* See also ptlrpc_ldebugfs_timeouts */
+static void ldebugfs_timeouts_locked(struct seq_file *m,
 				       struct obd_device *obd,
 				       struct obd_import *imp)
 {
@@ -1037,19 +1037,19 @@ static void lprocfs_rd_timeouts_locked(struct seq_file *m,
 	}
 }
 
-int lprocfs_rd_timeouts(struct seq_file *m, void *data)
+int ldebugfs_timeouts_seq_show(struct seq_file *m, void *data)
 {
 	struct obd_device *obd = (struct obd_device *)data;
 	struct obd_import *imp;
 	int rc;
 
 	with_imp_locked(obd, imp, rc)
-		lprocfs_rd_timeouts_locked(m, obd, imp);
+		ldebugfs_timeouts_locked(m, obd, imp);
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_rd_timeouts);
+EXPORT_SYMBOL(ldebugfs_timeouts_seq_show);
 
-int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
+int ldebugfs_connect_flags_seq_show(struct seq_file *m, void *data)
 {
 	struct obd_device *obd = data;
 	struct obd_import *imp;
@@ -1067,7 +1067,7 @@ int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_rd_connect_flags);
+EXPORT_SYMBOL(ldebugfs_connect_flags_seq_show);
 
 static const struct attribute *obd_def_uuid_attrs[] = {
 	&lustre_attr_uuid.attr,
@@ -1640,8 +1640,10 @@ void lprocfs_oh_clear(struct obd_histogram *oh)
 }
 EXPORT_SYMBOL(lprocfs_oh_clear);
 
-int lprocfs_wr_root_squash(const char __user *buffer, unsigned long count,
-			   struct root_squash_info *squash, char *name)
+ssize_t ldebugfs_root_squash_seq_write(const char __user *buffer,
+				       unsigned long count,
+				       struct root_squash_info *squash,
+				       char *name)
 {
 	char kernbuf[64], *tmp, *errmsg;
 	unsigned long uid, gid;
@@ -1702,10 +1704,12 @@ int lprocfs_wr_root_squash(const char __user *buffer, unsigned long count,
 	      name, errmsg, rc);
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_wr_root_squash);
+EXPORT_SYMBOL(ldebugfs_root_squash_seq_write);
 
-int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
-			     struct root_squash_info *squash, char *name)
+ssize_t ldebugfs_nosquash_nids_seq_write(const char __user *buffer,
+					 unsigned long count,
+					 struct root_squash_info *squash,
+					 char *name)
 {
 	char *kernbuf = NULL, *errmsg;
 	LIST_HEAD(tmp);
@@ -1777,7 +1781,7 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
 	}
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_wr_nosquash_nids);
+EXPORT_SYMBOL(ldebugfs_nosquash_nids_seq_write);
 
 ssize_t lustre_attr_show(struct kobject *kobj,
 			 struct attribute *attr, char *buf)
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 5495609..09dee7b 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -1158,98 +1158,6 @@ ssize_t class_modify_config(struct lustre_cfg *lcfg, const char *prefix,
 }
 EXPORT_SYMBOL(class_modify_config);
 
-int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
-			     struct lustre_cfg *lcfg, void *data)
-{
-	struct lprocfs_vars *var;
-	struct file fakefile;
-	struct seq_file fake_seqfile;
-	char *key, *sval;
-	int i, keylen, vallen;
-	int matched = 0, j = 0;
-	int rc = 0;
-	int skip = 0;
-
-	if (lcfg->lcfg_command != LCFG_PARAM) {
-		CERROR("Unknown command: %d\n", lcfg->lcfg_command);
-		return -EINVAL;
-	}
-
-	/* fake a seq file so that var->fops->write can work... */
-	fakefile.private_data = &fake_seqfile;
-	fake_seqfile.private = data;
-	/* e.g. tunefs.lustre --param mdt.group_upcall=foo /r/tmp/lustre-mdt
-	 * or   lctl conf_param lustre-MDT0000.mdt.group_upcall=bar
-	 * or   lctl conf_param lustre-OST0000.osc.max_dirty_mb=36
-	 */
-	for (i = 1; i < lcfg->lcfg_bufcount; i++) {
-		key = lustre_cfg_buf(lcfg, i);
-		/* Strip off prefix */
-		if (class_match_param(key, prefix, &key)) {
-			/*
-			 * If the prefix doesn't match, return error so we
-			 * can pass it down the stack
-			 */
-			return -ENOSYS;
-		}
-		sval = strchr(key, '=');
-		if (!sval || (*(sval + 1) == 0)) {
-			CERROR("Can't parse param %s (missing '=')\n", key);
-			/* rc = -EINVAL;	continue parsing other params */
-			continue;
-		}
-		keylen = sval - key;
-		sval++;
-		vallen = strlen(sval);
-		matched = 0;
-		j = 0;
-		/* Search proc entries */
-		while (lvars[j].name) {
-			var = &lvars[j];
-			if (!class_match_param(key, var->name, NULL) &&
-			    keylen == strlen(var->name)) {
-				matched++;
-				rc = -EROFS;
-				if (var->fops && var->fops->write) {
-					mm_segment_t oldfs;
-
-					oldfs = get_fs();
-					set_fs(KERNEL_DS);
-					rc = var->fops->write(&fakefile,
-						(const char __user *)sval,
-								vallen, NULL);
-					set_fs(oldfs);
-				}
-				break;
-			}
-			j++;
-		}
-		if (!matched) {
-			CERROR("%.*s: %s unknown param %s\n",
-			       (int)strlen(prefix) - 1, prefix,
-			       (char *)lustre_cfg_string(lcfg, 0), key);
-			/* rc = -EINVAL;	continue parsing other params */
-			skip++;
-		} else if (rc < 0) {
-			CERROR("%s: error writing parameter '%s': rc = %d\n",
-			       prefix, var->name, rc);
-			rc = 0;
-		} else {
-			CDEBUG(D_CONFIG, "%s.%.*s: set parameter %.*s\n",
-			       lustre_cfg_string(lcfg, 0),
-			       (int)strlen(prefix) - 1, prefix,
-			       (int)(sval - key - 1), key);
-		}
-	}
-
-	if (rc > 0)
-		rc = 0;
-	if (!rc && skip)
-		rc = skip;
-	return rc;
-}
-EXPORT_SYMBOL(class_process_proc_param);
-
 /** Parse a configuration llog, doing various manipulations on them
  * for various reasons, (modifications for compatibility, skip obsolete
  * records, change uuids, etc), then class_process_config() resulting
diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index f1fc78d..cb2f0a9 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -443,7 +443,7 @@ static int obd_device_list_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-LPROC_SEQ_FOPS_RO(health_check);
+LDEBUGFS_SEQ_FOPS_RO(health_check);
 
 struct kset *lustre_kset;
 EXPORT_SYMBOL_GPL(lustre_kset);
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 9b43710..14cbe54 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -242,7 +242,7 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 	return count;
 }
 
-LPROC_SEQ_FOPS(osc_cached_mb);
+LDEBUGFS_SEQ_FOPS(osc_cached_mb);
 
 static ssize_t cur_dirty_bytes_show(struct kobject *kobj,
 				    struct attribute *attr,
@@ -447,7 +447,7 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 	}
 	return rc;
 }
-LPROC_SEQ_FOPS(osc_checksum_type);
+LDEBUGFS_SEQ_FOPS(osc_checksum_type);
 
 static ssize_t resend_count_show(struct kobject *kobj,
 				 struct attribute *attr,
@@ -605,7 +605,7 @@ static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-LPROC_SEQ_FOPS_RO(osc_unstable_stats);
+LDEBUGFS_SEQ_FOPS_RO(osc_unstable_stats);
 
 static ssize_t idle_timeout_show(struct kobject *kobj, struct attribute *attr,
 				 char *buf)
@@ -729,15 +729,15 @@ static ssize_t grant_shrink_store(struct kobject *kobj, struct attribute *attr,
 }
 LUSTRE_RW_ATTR(grant_shrink);
 
-LPROC_SEQ_FOPS_RO_TYPE(osc, connect_flags);
-LPROC_SEQ_FOPS_RO_TYPE(osc, server_uuid);
-LPROC_SEQ_FOPS_RO_TYPE(osc, timeouts);
-LPROC_SEQ_FOPS_RO_TYPE(osc, state);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(osc, connect_flags);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(osc, server_uuid);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(osc, timeouts);
+LDEBUGFS_SEQ_FOPS_RO_TYPE(osc, state);
 
-LPROC_SEQ_FOPS_RW_TYPE(osc, import);
-LPROC_SEQ_FOPS_RW_TYPE(osc, pinger_recov);
+LDEBUGFS_SEQ_FOPS_RW_TYPE(osc, import);
+LDEBUGFS_SEQ_FOPS_RW_TYPE(osc, pinger_recov);
 
-static struct lprocfs_vars lprocfs_osc_obd_vars[] = {
+static struct ldebugfs_vars lprocfs_osc_obd_vars[] = {
 	{ .name	=	"connect_flags",
 	  .fops	=	&osc_connect_flags_fops		},
 	{ .name	=	"ost_server_uuid",
@@ -876,7 +876,7 @@ static ssize_t osc_rpc_stats_seq_write(struct file *file,
 	return len;
 }
 
-LPROC_SEQ_FOPS(osc_rpc_stats);
+LDEBUGFS_SEQ_FOPS(osc_rpc_stats);
 
 static int osc_stats_seq_show(struct seq_file *seq, void *v)
 {
@@ -909,7 +909,7 @@ static ssize_t osc_stats_seq_write(struct file *file,
 	return len;
 }
 
-LPROC_SEQ_FOPS(osc_stats);
+LDEBUGFS_SEQ_FOPS(osc_stats);
 
 void lproc_osc_attach_seqstat(struct obd_device *obd)
 {
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 86ec1f5..4d2ae14 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -263,7 +263,7 @@ static const char *ll_eopcode2str(u32 opcode)
 	return 0;
 }
 
-LPROC_SEQ_FOPS_RO(ptlrpc_lprocfs_req_history_len);
+LDEBUGFS_SEQ_FOPS_RO(ptlrpc_lprocfs_req_history_len);
 
 static int
 ptlrpc_lprocfs_req_history_max_seq_show(struct seq_file *m, void *n)
@@ -325,7 +325,7 @@ static const char *ll_eopcode2str(u32 opcode)
 	return count;
 }
 
-LPROC_SEQ_FOPS(ptlrpc_lprocfs_req_history_max);
+LDEBUGFS_SEQ_FOPS(ptlrpc_lprocfs_req_history_max);
 
 static int
 ptlrpc_lprocfs_req_buffers_max_seq_show(struct seq_file *m, void *n)
@@ -362,7 +362,7 @@ static const char *ll_eopcode2str(u32 opcode)
 	return count;
 }
 
-LPROC_SEQ_FOPS(ptlrpc_lprocfs_req_buffers_max);
+LDEBUGFS_SEQ_FOPS(ptlrpc_lprocfs_req_buffers_max);
 
 static ssize_t threads_min_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
@@ -753,7 +753,7 @@ static ssize_t ptlrpc_lprocfs_nrs_seq_write(struct file *file,
 	return rc < 0 ? rc : count;
 }
 
-LPROC_SEQ_FOPS(ptlrpc_lprocfs_nrs);
+LDEBUGFS_SEQ_FOPS(ptlrpc_lprocfs_nrs);
 
 /** @} nrs */
 
@@ -1050,7 +1050,7 @@ static int ptlrpc_lprocfs_timeouts_seq_show(struct seq_file *m, void *n)
 	return 0;
 }
 
-LPROC_SEQ_FOPS_RO(ptlrpc_lprocfs_timeouts);
+LDEBUGFS_SEQ_FOPS_RO(ptlrpc_lprocfs_timeouts);
 
 static ssize_t high_priority_ratio_show(struct kobject *kobj,
 					struct attribute *attr,
@@ -1133,7 +1133,7 @@ int ptlrpc_sysfs_register_service(struct kset *parent,
 void ptlrpc_ldebugfs_register_service(struct dentry *entry,
 				      struct ptlrpc_service *svc)
 {
-	struct lprocfs_vars lproc_vars[] = {
+	struct ldebugfs_vars lproc_vars[] = {
 		{ .name		= "req_buffer_history_len",
 		  .fops		= &ptlrpc_lprocfs_req_history_len_fops,
 		  .data		= svc },
@@ -1284,8 +1284,9 @@ ssize_t ping_store(struct kobject *kobj, struct attribute *attr,
  * The connection UUID is a node's primary NID. For example,
  * "echo connection=192.168.0.1@tcp0::instance > .../import".
  */
-int lprocfs_wr_import(struct file *file, const char __user *buffer,
-		      size_t count, loff_t *off)
+ssize_t
+ldebugfs_import_seq_write(struct file *file, const char __user *buffer,
+			  size_t count, loff_t *off)
 {
 	struct seq_file *m = file->private_data;
 	struct obd_device *obd = m->private;
@@ -1352,9 +1353,9 @@ int lprocfs_wr_import(struct file *file, const char __user *buffer,
 	kfree(kbuf);
 	return rc ?: count;
 }
-EXPORT_SYMBOL(lprocfs_wr_import);
+EXPORT_SYMBOL(ldebugfs_import_seq_write);
 
-int lprocfs_rd_pinger_recov(struct seq_file *m, void *n)
+int ldebugfs_pinger_recov_seq_show(struct seq_file *m, void *n)
 {
 	struct obd_device *obd = m->private;
 	struct obd_import *imp = obd->u.cli.cl_import;
@@ -1365,10 +1366,11 @@ int lprocfs_rd_pinger_recov(struct seq_file *m, void *n)
 
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_rd_pinger_recov);
+EXPORT_SYMBOL(ldebugfs_pinger_recov_seq_show);
 
-int lprocfs_wr_pinger_recov(struct file *file, const char __user *buffer,
-			    size_t count, loff_t *off)
+ssize_t
+ldebugfs_pinger_recov_seq_write(struct file *file, const char __user *buffer,
+				size_t count, loff_t *off)
 {
 	struct seq_file *m = file->private_data;
 	struct obd_device *obd = m->private;
@@ -1388,4 +1390,4 @@ int lprocfs_wr_pinger_recov(struct file *file, const char __user *buffer,
 
 	return rc ?: count;
 }
-EXPORT_SYMBOL(lprocfs_wr_pinger_recov);
+EXPORT_SYMBOL(ldebugfs_pinger_recov_seq_write);
diff --git a/fs/lustre/ptlrpc/sec_lproc.c b/fs/lustre/ptlrpc/sec_lproc.c
index b34ced4..94f77350 100644
--- a/fs/lustre/ptlrpc/sec_lproc.c
+++ b/fs/lustre/ptlrpc/sec_lproc.c
@@ -104,7 +104,7 @@ static int sptlrpc_info_lprocfs_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-LPROC_SEQ_FOPS_RO(sptlrpc_info_lprocfs);
+LDEBUGFS_SEQ_FOPS_RO(sptlrpc_info_lprocfs);
 
 static int sptlrpc_ctxs_lprocfs_seq_show(struct seq_file *seq, void *v)
 {
@@ -129,7 +129,7 @@ static int sptlrpc_ctxs_lprocfs_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-LPROC_SEQ_FOPS_RO(sptlrpc_ctxs_lprocfs);
+LDEBUGFS_SEQ_FOPS_RO(sptlrpc_ctxs_lprocfs);
 
 #if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(2, 16, 53, 0)
 static ssize_t sepol_seq_write_old(struct obd_device *obd,
@@ -212,8 +212,8 @@ static ssize_t sepol_seq_write_old(struct obd_device *obd,
 #endif
 
 static ssize_t
-lprocfs_wr_sptlrpc_sepol(struct file *file, const char __user *buffer,
-			 size_t count, void *data)
+ldebugfs_sptlrpc_sepol_seq_write(struct file *file, const char __user *buffer,
+				 size_t count, void *data)
 {
 	struct seq_file	*seq = file->private_data;
 	struct obd_device *obd = seq->private;
@@ -309,7 +309,7 @@ static ssize_t sepol_seq_write_old(struct obd_device *obd,
 
 	return rc ? rc : count;
 }
-LPROC_SEQ_FOPS_WR_ONLY(srpc, sptlrpc_sepol);
+LDEBUGFS_SEQ_FOPS_WR_ONLY(srpc, sptlrpc_sepol);
 
 int sptlrpc_lprocfs_cliobd_attach(struct obd_device *obd)
 {
@@ -332,8 +332,9 @@ int sptlrpc_lprocfs_cliobd_attach(struct obd_device *obd)
 }
 EXPORT_SYMBOL(sptlrpc_lprocfs_cliobd_attach);
 
-LPROC_SEQ_FOPS_RO(sptlrpc_proc_enc_pool);
-static struct lprocfs_vars sptlrpc_lprocfs_vars[] = {
+LDEBUGFS_SEQ_FOPS_RO(sptlrpc_proc_enc_pool);
+
+static struct ldebugfs_vars sptlrpc_lprocfs_vars[] = {
 	{ "encrypt_page_pools", &sptlrpc_proc_enc_pool_fops },
 	{ NULL }
 };
-- 
1.8.3.1
