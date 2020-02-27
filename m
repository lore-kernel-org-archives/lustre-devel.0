From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:56 -0500
Subject: [lustre-devel] [PATCH 248/622] lustre: llite: add file heat support
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-249-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

File heat is a special attribute fo files/objects which reflects
the access frequency of the files/objects.
File heat is mainly desinged for cache management. Caches like
PCC can use file heat to determine which files to be removed from
the cache or which files to fetch into cache.
This patch adds file heat support on llite level.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10602
Lustre-commit: ae723cf8161f ("LU-10602 llite: add file heat support")
Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/34399
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h           |  11 ++++
 fs/lustre/include/obd_support.h         |   6 ++
 fs/lustre/llite/file.c                  | 104 ++++++++++++++++++++++++++++++-
 fs/lustre/llite/llite_internal.h        |  20 +++++-
 fs/lustre/llite/llite_lib.c             |   6 ++
 fs/lustre/llite/lproc_llite.c           | 106 ++++++++++++++++++++++++++++++++
 fs/lustre/obdclass/class_obd.c          |  73 ++++++++++++++++++++++
 include/uapi/linux/lustre/lustre_user.h |  32 ++++++++++
 8 files changed, 356 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 6a4b6a5..6cddc4f 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1710,4 +1710,15 @@ struct root_squash_info {
 struct obd_ioctl_data;
 int obd_ioctl_getdata(struct obd_ioctl_data **data, int *len, void __user *arg);
 
+extern void obd_heat_add(struct obd_heat_instance *instance,
+			 unsigned int time_second, u64 count,
+			 unsigned int weight, unsigned int period_second);
+extern void obd_heat_decay(struct obd_heat_instance *instance,
+			   u64 time_second, unsigned int weight,
+			   unsigned int period_second);
+extern u64 obd_heat_get(struct obd_heat_instance *instance,
+			unsigned int time_second, unsigned int weight,
+			unsigned int period_second);
+extern void obd_heat_clear(struct obd_heat_instance *instance, int count);
+
 #endif /* __LINUX_OBD_CLASS_H */
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index a60fa07..36955e8 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -536,4 +536,10 @@
 	(keylen >= (sizeof(str) - 1) &&			\
 	memcmp(key, str, (sizeof(str) - 1)) == 0)
 
+struct obd_heat_instance {
+	u64 ohi_heat;
+	u64 ohi_time_second;
+	u64 ohi_count;
+};
+
 #endif
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 7ec1099..f5b5eec 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1399,6 +1399,37 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 	ll_io_set_mirror(io, file);
 }
 
+static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
+			u64 count)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	enum obd_heat_type sample_type;
+	enum obd_heat_type iobyte_type;
+	u64 now = ktime_get_real_seconds();
+
+	if (!ll_sbi_has_file_heat(sbi) ||
+	    lli->lli_heat_flags & LU_HEAT_FLAG_OFF)
+		return;
+
+	if (iot == CIT_READ) {
+		sample_type = OBD_HEAT_READSAMPLE;
+		iobyte_type = OBD_HEAT_READBYTE;
+	} else if (iot == CIT_WRITE) {
+		sample_type = OBD_HEAT_WRITESAMPLE;
+		iobyte_type = OBD_HEAT_WRITEBYTE;
+	} else {
+		return;
+	}
+
+	spin_lock(&lli->lli_heat_lock);
+	obd_heat_add(&lli->lli_heat_instances[sample_type], now, 1,
+		     sbi->ll_heat_decay_weight, sbi->ll_heat_period_second);
+	obd_heat_add(&lli->lli_heat_instances[iobyte_type], now, count,
+		     sbi->ll_heat_decay_weight, sbi->ll_heat_period_second);
+	spin_unlock(&lli->lli_heat_lock);
+}
+
 static ssize_t
 ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 		   struct file *file, enum cl_io_type iot,
@@ -1512,6 +1543,8 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 		}
 	}
 	CDEBUG(D_VFSTRACE, "iot: %d, result: %zd\n", iot, result);
+	if (result > 0)
+		ll_heat_add(file_inode(file), iot, result);
 
 	return result > 0 ? result : rc;
 }
@@ -1575,9 +1608,11 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 	if (result == -ENODATA)
 		result = 0;
 
-	if (result > 0)
+	if (result > 0) {
+		ll_heat_add(file_inode(iocb->ki_filp), CIT_READ, result);
 		ll_stats_ops_tally(ll_i2sbi(file_inode(iocb->ki_filp)),
 				   LPROC_LL_READ_BYTES, result);
+	}
 
 	return result;
 }
@@ -1660,6 +1695,7 @@ static ssize_t ll_do_tiny_write(struct kiocb *iocb, struct iov_iter *iter)
 		result = 0;
 
 	if (result > 0) {
+		ll_heat_add(inode, CIT_WRITE, result);
 		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_WRITE_BYTES,
 				   result);
 		set_bit(LLIF_DATA_MODIFIED, &ll_i2info(inode)->lli_flags);
@@ -3128,6 +3164,41 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 	return rc;
 }
 
+static void ll_heat_get(struct inode *inode, struct lu_heat *heat)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	u64 now = ktime_get_real_seconds();
+	int i;
+
+	spin_lock(&lli->lli_heat_lock);
+	heat->lh_flags = lli->lli_heat_flags;
+	for (i = 0; i < heat->lh_count; i++)
+		heat->lh_heat[i] = obd_heat_get(&lli->lli_heat_instances[i],
+						now, sbi->ll_heat_decay_weight,
+						sbi->ll_heat_period_second);
+	spin_unlock(&lli->lli_heat_lock);
+}
+
+static int ll_heat_set(struct inode *inode, u64 flags)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	int rc = 0;
+
+	spin_lock(&lli->lli_heat_lock);
+	if (flags & LU_HEAT_FLAG_CLEAR)
+		obd_heat_clear(lli->lli_heat_instances, OBD_HEAT_COUNT);
+
+	if (flags & LU_HEAT_FLAG_OFF)
+		lli->lli_heat_flags |= LU_HEAT_FLAG_OFF;
+	else
+		lli->lli_heat_flags &= ~LU_HEAT_FLAG_OFF;
+
+	spin_unlock(&lli->lli_heat_lock);
+
+	return rc;
+}
+
 static long
 ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
@@ -3510,6 +3581,37 @@ static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
 		return ll_ioctl_fssetxattr(inode, cmd, arg);
 	case BLKSSZGET:
 		return put_user(PAGE_SIZE, (int __user *)arg);
+	case LL_IOC_HEAT_GET: {
+		struct lu_heat uheat;
+		struct lu_heat *heat;
+		int size;
+
+		if (copy_from_user(&uheat, (void __user *)arg, sizeof(uheat)))
+			return -EFAULT;
+
+		if (uheat.lh_count > OBD_HEAT_COUNT)
+			uheat.lh_count = OBD_HEAT_COUNT;
+
+		size = offsetof(typeof(uheat), lh_heat[uheat.lh_count]);
+		heat = kzalloc(size, GFP_KERNEL);
+		if (!heat)
+			return -ENOMEM;
+
+		heat->lh_count = uheat.lh_count;
+		ll_heat_get(inode, heat);
+		rc = copy_to_user((char __user *)arg, heat, size);
+		kfree(heat);
+		return rc ? -EFAULT : 0;
+	}
+	case LL_IOC_HEAT_SET: {
+		u64 flags;
+
+		if (copy_from_user(&flags, (void __user *)arg, sizeof(flags)))
+			return -EFAULT;
+
+		rc = ll_heat_set(inode, flags);
+		return rc;
+	}
 	default:
 		return obd_iocontrol(cmd, ll_i2dtexp(inode), 0, NULL,
 				     (void __user *)arg);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 3c81c3b..5a0a5ed 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -196,6 +196,11 @@ struct ll_inode_info {
 			/* for writepage() only to communicate to fsync */
 			int				lli_async_rc;
 
+			/* protect the file heat fields */
+			spinlock_t			lli_heat_lock;
+			u32				lli_heat_flags;
+			struct obd_heat_instance	lli_heat_instances[OBD_HEAT_COUNT];
+
 			/*
 			 * Whenever a process try to read/write the file, the
 			 * jobid of the process will be saved here, and it'll
@@ -418,7 +423,7 @@ enum stats_track_type {
 					  * create
 					  */
 #define LL_SBI_TINY_WRITE	0x2000000 /* tiny write support */
-
+#define LL_SBI_FILE_HEAT    0x4000000 /* file heat support */
 #define LL_SBI_FLAGS {	\
 	"nolck",	\
 	"checksum",	\
@@ -446,6 +451,7 @@ enum stats_track_type {
 	"file_secctx",	\
 	"pio",		\
 	"tiny_write",	\
+	"file_heat",	\
 }
 
 /*
@@ -546,8 +552,15 @@ struct ll_sb_info {
 
 	struct kset		ll_kset;	/* sysfs object */
 	struct completion	 ll_kobj_unregister;
+
+	/* File heat */
+	unsigned int		ll_heat_decay_weight;
+	unsigned int		ll_heat_period_second;
 };
 
+#define SBI_DEFAULT_HEAT_DECAY_WEIGHT	((80 * 256 + 50) / 100)
+#define SBI_DEFAULT_HEAT_PERIOD_SECOND	(60)
+
 /*
  * per file-descriptor read-ahead data.
  */
@@ -710,6 +723,11 @@ static inline bool ll_sbi_has_tiny_write(struct ll_sb_info *sbi)
 	return !!(sbi->ll_flags & LL_SBI_TINY_WRITE);
 }
 
+static inline bool ll_sbi_has_file_heat(struct ll_sb_info *sbi)
+{
+	return !!(sbi->ll_flags & LL_SBI_FILE_HEAT);
+}
+
 void ll_ras_enter(struct file *f);
 
 /* llite/lcommon_misc.c */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 10d9180..795a1f1 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -133,6 +133,9 @@ static struct ll_sb_info *ll_init_sbi(void)
 	INIT_LIST_HEAD(&sbi->ll_squash.rsi_nosquash_nids);
 	spin_lock_init(&sbi->ll_squash.rsi_lock);
 
+	/* Per-filesystem file heat */
+	sbi->ll_heat_decay_weight = SBI_DEFAULT_HEAT_DECAY_WEIGHT;
+	sbi->ll_heat_period_second = SBI_DEFAULT_HEAT_PERIOD_SECOND;
 	return sbi;
 }
 
@@ -949,6 +952,9 @@ void ll_lli_init(struct ll_inode_info *lli)
 		INIT_LIST_HEAD(&lli->lli_agl_list);
 		lli->lli_agl_index = 0;
 		lli->lli_async_rc = 0;
+		spin_lock_init(&lli->lli_heat_lock);
+		obd_heat_clear(lli->lli_heat_instances, OBD_HEAT_COUNT);
+		lli->lli_heat_flags = 0;
 	}
 	mutex_init(&lli->lli_layout_mutex);
 	memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 4060271..596aad8 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1096,6 +1096,109 @@ static ssize_t fast_read_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(fast_read);
 
+static ssize_t file_heat_show(struct kobject *kobj,
+			      struct attribute *attr,
+			      char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%u\n",
+			!!(sbi->ll_flags & LL_SBI_FILE_HEAT));
+}
+
+static ssize_t file_heat_store(struct kobject *kobj,
+			       struct attribute *attr,
+			       const char *buffer,
+			       size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	bool val;
+	int rc;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	spin_lock(&sbi->ll_lock);
+	if (val)
+		sbi->ll_flags |= LL_SBI_FILE_HEAT;
+	else
+		sbi->ll_flags &= ~LL_SBI_FILE_HEAT;
+	spin_unlock(&sbi->ll_lock);
+
+	return count;
+}
+LUSTRE_RW_ATTR(file_heat);
+
+static ssize_t heat_decay_percentage_show(struct kobject *kobj,
+					  struct attribute *attr,
+					  char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%u\n",
+		       (sbi->ll_heat_decay_weight * 100 + 128) / 256);
+}
+
+static ssize_t heat_decay_percentage_store(struct kobject *kobj,
+					   struct attribute *attr,
+					   const char *buffer,
+					   size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned long val;
+	int rc;
+
+	rc = kstrtoul(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	if (val < 0 || val > 100)
+		return -ERANGE;
+
+	sbi->ll_heat_decay_weight = (val * 256 + 50) / 100;
+
+	return count;
+}
+LUSTRE_RW_ATTR(heat_decay_percentage);
+
+static ssize_t heat_period_second_show(struct kobject *kobj,
+				       struct attribute *attr,
+				       char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%u\n", sbi->ll_heat_period_second);
+}
+
+static ssize_t heat_period_second_store(struct kobject *kobj,
+					struct attribute *attr,
+					const char *buffer,
+					size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned long val;
+	int rc;
+
+	rc = kstrtoul(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	if (val <= 0)
+		return -ERANGE;
+
+	sbi->ll_heat_period_second = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(heat_period_second);
+
 static int ll_unstable_stats_seq_show(struct seq_file *m, void *v)
 {
 	struct super_block *sb = m->private;
@@ -1264,6 +1367,9 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	&lustre_attr_xattr_cache.attr,
 	&lustre_attr_fast_read.attr,
 	&lustre_attr_tiny_write.attr,
+	&lustre_attr_file_heat.attr,
+	&lustre_attr_heat_decay_percentage.attr,
+	&lustre_attr_heat_period_second.attr,
 	NULL,
 };
 
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 609b4cc..0718fdb 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -706,6 +706,79 @@ static void obdclass_exit(void)
 	obd_zombie_impexp_stop();
 }
 
+void obd_heat_clear(struct obd_heat_instance *instance, int count)
+{
+	memset(instance, 0, sizeof(*instance) * count);
+}
+EXPORT_SYMBOL(obd_heat_clear);
+
+/*
+ * The file heat is calculated for every time interval period I. The access
+ * frequency during each period is counted. The file heat is only recalculated
+ * at the end of a time period.  And a percentage of the former file heat is
+ * lost when recalculated. The recursion formula to calculate the heat of the
+ * file f is as follow:
+ *
+ * Hi+1(f) = (1-P)*Hi(f)+ P*Ci
+ *
+ * Where Hi is the heat value in the period between time points i*I and
+ * (i+1)*I; Ci is the access count in the period; the symbol P refers to the
+ * weight of Ci. The larger the value the value of P is, the more influence Ci
+ * has on the file heat.
+ */
+void obd_heat_decay(struct obd_heat_instance *instance,  u64 time_second,
+		    unsigned int weight, unsigned int period_second)
+{
+	u64 second;
+
+	if (instance->ohi_time_second > time_second) {
+		obd_heat_clear(instance, 1);
+		return;
+	}
+
+	if (instance->ohi_time_second == 0)
+		return;
+
+	for (second = instance->ohi_time_second + period_second;
+	     second < time_second;
+	     second += period_second) {
+		instance->ohi_heat = instance->ohi_heat *
+				(256 - weight) / 256 +
+				instance->ohi_count * weight / 256;
+		instance->ohi_count = 0;
+		instance->ohi_time_second = second;
+	}
+}
+EXPORT_SYMBOL(obd_heat_decay);
+
+u64 obd_heat_get(struct obd_heat_instance *instance, unsigned int time_second,
+		 unsigned int weight, unsigned int period_second)
+{
+	obd_heat_decay(instance, time_second, weight, period_second);
+
+	if (instance->ohi_count == 0)
+		return instance->ohi_heat;
+
+	return instance->ohi_heat * (256 - weight) / 256 +
+	       instance->ohi_count * weight / 256;
+}
+EXPORT_SYMBOL(obd_heat_get);
+
+void obd_heat_add(struct obd_heat_instance *instance,
+		  unsigned int time_second,  u64 count,
+		  unsigned int weight, unsigned int period_second)
+{
+	obd_heat_decay(instance, time_second, weight, period_second);
+	if (instance->ohi_time_second == 0) {
+		instance->ohi_time_second = time_second;
+		instance->ohi_heat = 0;
+		instance->ohi_count = count;
+	} else {
+		instance->ohi_count += count;
+	}
+}
+EXPORT_SYMBOL(obd_heat_add);
+
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre Class Driver");
 MODULE_VERSION(LUSTRE_VERSION_STRING);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index c1e9dca..1d402f1 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -352,6 +352,8 @@ struct ll_ioc_lease_id {
 #define LL_IOC_FID2MDTIDX		_IOWR('f', 248, struct lu_fid)
 #define LL_IOC_GETPARENT		_IOWR('f', 249, struct getparent)
 #define LL_IOC_LADVISE			_IOR('f', 250, struct llapi_lu_ladvise)
+#define LL_IOC_HEAT_GET			_IOWR('f', 251, struct lu_heat)
+#define LL_IOC_HEAT_SET			_IOW('f', 252, long)
 
 #define LL_STATFS_LMV		1
 #define LL_STATFS_LOV		2
@@ -1957,6 +1959,36 @@ enum lockahead_results {
 	LLA_RESULT_SAME,
 };
 
+enum lu_heat_flag_bit {
+	LU_HEAT_FLAG_BIT_INVALID = 0,
+	LU_HEAT_FLAG_BIT_OFF,
+	LU_HEAT_FLAG_BIT_CLEAR,
+};
+
+#define LU_HEAT_FLAG_CLEAR	(1 << LU_HEAT_FLAG_BIT_CLEAR)
+#define LU_HEAT_FLAG_OFF	(1 << LU_HEAT_FLAG_BIT_OFF)
+
+enum obd_heat_type {
+	OBD_HEAT_READSAMPLE	= 0,
+	OBD_HEAT_WRITESAMPLE	= 1,
+	OBD_HEAT_READBYTE	= 2,
+	OBD_HEAT_WRITEBYTE	= 3,
+	OBD_HEAT_COUNT
+};
+
+#define LU_HEAT_NAMES {					\
+	[OBD_HEAT_READSAMPLE]	= "readsample",		\
+	[OBD_HEAT_WRITESAMPLE]	= "writesample",	\
+	[OBD_HEAT_READBYTE]	= "readbyte",		\
+	[OBD_HEAT_WRITEBYTE]	= "writebyte",		\
+}
+
+struct lu_heat {
+	__u32 lh_count;
+	__u32 lh_flags;
+	__u64 lh_heat[0];
+};
+
 /** @} lustreuser */
 
 #endif /* _LUSTRE_USER_H */
-- 
1.8.3.1
