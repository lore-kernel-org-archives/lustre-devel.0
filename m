From: James Simmons <jsimmons@infradead.org>
Date: Sun, 19 Aug 2018 22:40:11 -0400
Subject: [lustre-devel] [PATCH v2 05/38] lustre: llite: change top kobject
 for llite into a kset
Message-ID: <1534732811-23048-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Currently the top of the sysfs tree for llite is represented by
a kobject and each mount instance a kset. Change the top object
into a kset and each mount instance into a kobject instead. The
reason for this change is in the future lustre_kobj will be
changed into a kset and you can't layer two ksets.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24031
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog)
v1) Initial patch
v2) fstype no longer needs to use kobject
 .../staging/lustre/lustre/llite/llite_internal.h   |   2 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 112 +++++++++++++--------
 2 files changed, 71 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 92dc05d..5577407 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -523,7 +523,7 @@ struct ll_sb_info {
 	struct path		 ll_mnt;
 
 	__kernel_fsid_t		  ll_fsid;
-	struct kobject		 ll_kobj; /* sysfs object */
+	struct kset		ll_kset;	/* sysfs object */
 	struct completion	 ll_kobj_unregister;
 };
 
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 858d276..f43fc99 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -39,22 +39,42 @@
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
+static struct kobject *llite_kobj;
 static struct dentry *llite_root;
-static struct kset *llite_kset;
+
+static void class_sysfs_release(struct kobject *kobj)
+{
+	kfree(kobj);
+}
+
+static struct kobj_type class_ktype = {
+	.sysfs_ops	= &lustre_sysfs_ops,
+	.release	= class_sysfs_release,
+};
 
 int llite_tunables_register(void)
 {
+	const char *name = "llite";
+	struct kobject *kobj;
 	int rc = 0;
 
-	llite_kset = kset_create_and_add("llite", NULL, lustre_kobj);
-	if (!llite_kset)
+	kobj = kzalloc(sizeof(*kobj), GFP_KERNEL);
+	if (!kobj)
+		return -ENOMEM;
+
+	kobject_init(kobj, &class_ktype);
+	rc = kobject_add(kobj, lustre_kobj, "%s", name);
+	if (rc) {
+		kobject_put(kobj);
 		return -ENOMEM;
+	}
+	llite_kobj = kobj;
 
 	llite_root = debugfs_create_dir("llite", debugfs_lustre_root);
 	if (IS_ERR_OR_NULL(llite_root)) {
 		rc = llite_root ? PTR_ERR(llite_root) : -ENOMEM;
 		llite_root = NULL;
-		kset_unregister(llite_kset);
+		kobject_put(kobj);
 	}
 
 	return rc;
@@ -62,7 +82,8 @@ int llite_tunables_register(void)
 
 void llite_tunables_unregister(void)
 {
-	kset_unregister(llite_kset);
+	kobject_put(llite_kobj);
+	llite_kobj = NULL;
 
 	debugfs_remove(llite_root);
 	llite_root = NULL;
@@ -77,7 +98,7 @@ static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	struct obd_statfs osfs;
 	int rc;
 
@@ -95,7 +116,7 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	struct obd_statfs osfs;
 	int rc;
 
@@ -120,7 +141,7 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 			       char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	struct obd_statfs osfs;
 	int rc;
 
@@ -145,7 +166,7 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	struct obd_statfs osfs;
 	int rc;
 
@@ -170,7 +191,7 @@ static ssize_t filestotal_show(struct kobject *kobj, struct attribute *attr,
 			       char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	struct obd_statfs osfs;
 	int rc;
 
@@ -188,7 +209,7 @@ static ssize_t filesfree_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	struct obd_statfs osfs;
 	int rc;
 
@@ -220,7 +241,7 @@ static ssize_t uuid_show(struct kobject *kobj, struct attribute *attr,
 			 char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 
 	return sprintf(buf, "%s\n", sbi->ll_sb_uuid.uuid);
 }
@@ -243,7 +264,7 @@ static ssize_t max_read_ahead_mb_show(struct kobject *kobj,
 				      struct attribute *attr, char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	long pages_number;
 	int mult;
 
@@ -261,7 +282,7 @@ static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
 				       size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	int rc;
 	unsigned long pages_number;
 
@@ -290,7 +311,7 @@ static ssize_t max_read_ahead_per_file_mb_show(struct kobject *kobj,
 					       char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	long pages_number;
 	int mult;
 
@@ -308,7 +329,7 @@ static ssize_t max_read_ahead_per_file_mb_store(struct kobject *kobj,
 						size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	int rc;
 	unsigned long pages_number;
 
@@ -335,7 +356,7 @@ static ssize_t max_read_ahead_whole_mb_show(struct kobject *kobj,
 					    char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	long pages_number;
 	int mult;
 
@@ -353,7 +374,7 @@ static ssize_t max_read_ahead_whole_mb_store(struct kobject *kobj,
 					     size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	int rc;
 	unsigned long pages_number;
 
@@ -518,7 +539,7 @@ static ssize_t checksum_pages_show(struct kobject *kobj, struct attribute *attr,
 				   char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 
 	return sprintf(buf, "%u\n", (sbi->ll_flags & LL_SBI_CHECKSUM) ? 1 : 0);
 }
@@ -529,7 +550,7 @@ static ssize_t checksum_pages_store(struct kobject *kobj,
 				    size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -560,7 +581,7 @@ static ssize_t ll_rd_track_id(struct kobject *kobj, char *buf,
 			      enum stats_track_type type)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 
 	if (sbi->ll_stats_track_type == type)
 		return sprintf(buf, "%d\n", sbi->ll_stats_track_id);
@@ -575,7 +596,7 @@ static ssize_t ll_wr_track_id(struct kobject *kobj, const char *buffer,
 			      enum stats_track_type type)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	int rc;
 	unsigned long pid;
 
@@ -644,7 +665,7 @@ static ssize_t statahead_max_show(struct kobject *kobj,
 				  char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 
 	return sprintf(buf, "%u\n", sbi->ll_sa_max);
 }
@@ -655,7 +676,7 @@ static ssize_t statahead_max_store(struct kobject *kobj,
 				   size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -678,7 +699,7 @@ static ssize_t statahead_agl_show(struct kobject *kobj,
 				  char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 
 	return sprintf(buf, "%u\n", sbi->ll_flags & LL_SBI_AGL_ENABLED ? 1 : 0);
 }
@@ -689,7 +710,7 @@ static ssize_t statahead_agl_store(struct kobject *kobj,
 				   size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -730,7 +751,7 @@ static ssize_t lazystatfs_show(struct kobject *kobj,
 			       char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 
 	return sprintf(buf, "%u\n", sbi->ll_flags & LL_SBI_LAZYSTATFS ? 1 : 0);
 }
@@ -741,7 +762,7 @@ static ssize_t lazystatfs_store(struct kobject *kobj,
 				size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -765,7 +786,7 @@ static ssize_t max_easize_show(struct kobject *kobj,
 			       char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	unsigned int ealen;
 	int rc;
 
@@ -794,7 +815,7 @@ static ssize_t default_easize_show(struct kobject *kobj,
 				   char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	unsigned int ealen;
 	int rc;
 
@@ -827,7 +848,7 @@ static ssize_t default_easize_store(struct kobject *kobj,
 				    size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	unsigned long val;
 	int rc;
 
@@ -873,7 +894,7 @@ static ssize_t xattr_cache_show(struct kobject *kobj,
 				char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 
 	return sprintf(buf, "%u\n", sbi->ll_xattr_cache_enabled);
 }
@@ -884,7 +905,7 @@ static ssize_t xattr_cache_store(struct kobject *kobj,
 				 size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	int rc;
 	unsigned long val;
 
@@ -909,7 +930,7 @@ static ssize_t fast_read_show(struct kobject *kobj,
 			      char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 
 	return sprintf(buf, "%u\n", !!(sbi->ll_flags & LL_SBI_FAST_READ));
 }
@@ -920,7 +941,7 @@ static ssize_t fast_read_store(struct kobject *kobj,
 			       size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	bool val;
 	int rc;
 
@@ -1106,7 +1127,7 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 static void llite_sb_release(struct kobject *kobj)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
-					      ll_kobj);
+					      ll_kset.kobj);
 	complete(&sbi->ll_kobj_unregister);
 }
 
@@ -1281,17 +1302,22 @@ int ll_debugfs_register_super(struct super_block *sb, char *osc, char *mdc)
 
 	ldebugfs_add_vars(sbi->ll_debugfs_entry, lprocfs_llite_obd_vars, sb);
 
-	sbi->ll_kobj.kset = llite_kset;
+	/* Yes we also register sysfs mount kset here as well */
+	sbi->ll_kset.kobj.parent = llite_kobj;
+	sbi->ll_kset.kobj.ktype = &llite_ktype;
 	init_completion(&sbi->ll_kobj_unregister);
-	err = kobject_init_and_add(&sbi->ll_kobj, &llite_ktype, NULL,
-				   "%s", name);
+	err = kobject_set_name(&sbi->ll_kset.kobj, "%s", name);
+	if (err)
+		goto out;
+
+	err = kset_register(&sbi->ll_kset);
 	if (err)
 		goto out;
 
 	/* MDC info */
 	obd = class_name2obd(mdc);
 
-	err = sysfs_create_link(&sbi->ll_kobj, &obd->obd_kobj,
+	err = sysfs_create_link(&sbi->ll_kset.kobj, &obd->obd_kobj,
 				obd->obd_type->typ_name);
 	if (err)
 		goto out;
@@ -1299,7 +1325,7 @@ int ll_debugfs_register_super(struct super_block *sb, char *osc, char *mdc)
 	/* OSC */
 	obd = class_name2obd(osc);
 
-	err = sysfs_create_link(&sbi->ll_kobj, &obd->obd_kobj,
+	err = sysfs_create_link(&sbi->ll_kset.kobj, &obd->obd_kobj,
 				obd->obd_type->typ_name);
 out:
 	if (err) {
@@ -1313,8 +1339,10 @@ int ll_debugfs_register_super(struct super_block *sb, char *osc, char *mdc)
 void ll_debugfs_unregister_super(struct ll_sb_info *sbi)
 {
 	debugfs_remove_recursive(sbi->ll_debugfs_entry);
-	kobject_put(&sbi->ll_kobj);
+
+	kset_unregister(&sbi->ll_kset);
 	wait_for_completion(&sbi->ll_kobj_unregister);
+
 	lprocfs_free_stats(&sbi->ll_ra_stats);
 	lprocfs_free_stats(&sbi->ll_stats);
 }
-- 
1.8.3.1
