From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:01 -0400
Subject: [lustre-devel] [PATCH 102/151] lustre: libcfs: remove
 cfs_time_XXX_64 wrappers
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-103-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In an attempt to support 64 bit time handling before the linux
kernel developed time64_t and ktime lustre attempted to use
64 bit jiffies with a libcfs abstraction. Lets remove these
wrappers and replace them with modern 64 bit time support. The
lustre code that used these wrappers needs time resolution at
the seconds level so replace the code with time64_t handling.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Lustre-commit: 2728de4db8c0 ("LU-9019 libcfs: remove cfs_time_XXX_64 wrappers")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/30867
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h   | 10 ++++----
 fs/lustre/include/obd.h             |  6 ++---
 fs/lustre/include/obd_class.h       | 14 +++++------
 fs/lustre/llite/llite_internal.h    |  2 +-
 fs/lustre/llite/llite_lib.c         |  6 ++---
 fs/lustre/llite/lproc_llite.c       | 12 +++++-----
 fs/lustre/lmv/lmv_obd.c             |  4 ++--
 fs/lustre/lov/lov_obd.c             |  4 ++--
 fs/lustre/lov/lov_request.c         |  4 ++--
 fs/lustre/mdc/mdc_request.c         |  4 ++--
 fs/lustre/obdclass/genops.c         |  2 +-
 fs/lustre/obdclass/lprocfs_status.c | 48 +++++++++++++++++++++++--------------
 fs/lustre/osc/osc_request.c         |  4 ++--
 fs/lustre/ptlrpc/import.c           | 10 ++++----
 14 files changed, 70 insertions(+), 60 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 6a2d402..2d8f6be 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -134,10 +134,10 @@ struct obd_import_conn {
 	struct ptlrpc_connection	*oic_conn;
 	/** uuid of remote side */
 	struct obd_uuid			oic_uuid;
-	/**
-	 * Time (64 bit jiffies) of last connection attempt on this connection
+	/*
+	 * Time (64 bit seconds) of last connection attempt on this connection
 	 */
-	u64				oic_last_attempt;
+	time64_t			oic_last_attempt;
 };
 
 /* state history */
@@ -251,8 +251,8 @@ struct obd_import {
 	struct lustre_handle		imp_remote_handle;
 	/** When to perform next ping. time in jiffies. */
 	time64_t			imp_next_ping;
-	/** When we last successfully connected. time in 64bit jiffies */
-	u64				imp_last_success_conn;
+	/** When we last successfully connected. time in 64bit seconds */
+	time64_t			imp_last_success_conn;
 
 	/** List of all possible connection for import. */
 	struct list_head		imp_conn_list;
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 309a168..1cb37a0 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -587,7 +587,7 @@ struct obd_device {
 	spinlock_t		 obd_dev_lock; /* protect OBD bitfield above */
 	spinlock_t		 obd_osfs_lock;
 	struct obd_statfs	 obd_osfs;       /* locked by obd_osfs_lock */
-	u64			 obd_osfs_age;
+	time64_t		 obd_osfs_age;
 	u64			 obd_last_committed;
 	struct mutex		 obd_dev_mutex;
 	struct lvfs_run_ctxt	 obd_lvfs_ctxt;
@@ -850,9 +850,9 @@ struct obd_ops {
 	 * about this.
 	 */
 	int (*statfs)(const struct lu_env *, struct obd_export *exp,
-		      struct obd_statfs *osfs, u64 max_age, u32 flags);
+		      struct obd_statfs *osfs, time64_t max_age, u32 flags);
 	int (*statfs_async)(struct obd_export *exp, struct obd_info *oinfo,
-			    u64 max_age, struct ptlrpc_request_set *set);
+			    time64_t max_age, struct ptlrpc_request_set *set);
 	int (*create)(const struct lu_env *env, struct obd_export *exp,
 		      struct obdo *oa);
 	int (*destroy)(const struct lu_env *env, struct obd_export *exp,
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index f977b2e..dd07ec5 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -874,7 +874,7 @@ static inline int obd_destroy_export(struct obd_export *exp)
  */
 static inline int obd_statfs_async(struct obd_export *exp,
 				   struct obd_info *oinfo,
-				   u64 max_age,
+				   time64_t max_age,
 				   struct ptlrpc_request_set *rqset)
 {
 	int rc = 0;
@@ -889,9 +889,9 @@ static inline int obd_statfs_async(struct obd_export *exp,
 		return -EOPNOTSUPP;
 	}
 
-	CDEBUG(D_SUPER, "%s: osfs %p age %llu, max_age %llu\n",
+	CDEBUG(D_SUPER, "%s: osfs %p age %lld, max_age %lld\n",
 	       obd->obd_name, &obd->obd_osfs, obd->obd_osfs_age, max_age);
-	if (time_before64(obd->obd_osfs_age, max_age)) {
+	if (obd->obd_osfs_age < max_age) {
 		rc = OBP(obd, statfs_async)(exp, oinfo, max_age, rqset);
 	} else {
 		CDEBUG(D_SUPER,
@@ -915,7 +915,7 @@ static inline int obd_statfs_async(struct obd_export *exp,
  * target.  Use a value of "jiffies + HZ" to guarantee freshness.
  */
 static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
-			     struct obd_statfs *osfs, u64 max_age,
+			     struct obd_statfs *osfs, time64_t max_age,
 			     u32 flags)
 {
 	struct obd_device *obd = exp->exp_obd;
@@ -929,14 +929,14 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 		return -EOPNOTSUPP;
 	}
 
-	CDEBUG(D_SUPER, "osfs %llu, max_age %llu\n",
+	CDEBUG(D_SUPER, "osfs %lld, max_age %lld\n",
 	       obd->obd_osfs_age, max_age);
-	if (time_before64(obd->obd_osfs_age, max_age)) {
+	if (obd->obd_osfs_age < max_age) {
 		rc = OBP(obd, statfs)(env, exp, osfs, max_age, flags);
 		if (rc == 0) {
 			spin_lock(&obd->obd_osfs_lock);
 			memcpy(&obd->obd_osfs, osfs, sizeof(obd->obd_osfs));
-			obd->obd_osfs_age = get_jiffies_64();
+			obd->obd_osfs_age = ktime_get_seconds();
 			spin_unlock(&obd->obd_osfs_lock);
 		}
 	} else {
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 229d417..fc4c4db 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -878,7 +878,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 int ll_setattr(struct dentry *de, struct iattr *attr);
 int ll_statfs(struct dentry *de, struct kstatfs *sfs);
 int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
-		       u64 max_age, u32 flags);
+		       time64_t max_age, __u32 flags);
 int ll_update_inode(struct inode *inode, struct lustre_md *md);
 void ll_update_inode_flags(struct inode *inode, int ext_flags);
 int ll_read_inode2(struct inode *inode, void *opaque);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index d4ff2bf..4f4234d 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -288,7 +288,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	 * available
 	 */
 	err = obd_statfs(NULL, sbi->ll_md_exp, osfs,
-			 get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+			 ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 			 OBD_STATFS_FOR_MDT0);
 	if (err)
 		goto out_md_fid;
@@ -1716,7 +1716,7 @@ int ll_setattr(struct dentry *de, struct iattr *attr)
 }
 
 int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
-		       u64 max_age, u32 flags)
+		       time64_t max_age, u32 flags)
 {
 	struct obd_statfs obd_osfs;
 	int rc;
@@ -1775,7 +1775,7 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 
 	/* Some amount of caching on the client is allowed */
 	rc = ll_statfs_internal(ll_s2sbi(sb), &osfs,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				0);
 	if (rc)
 		return rc;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 81c8fe6..9173d94 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -141,7 +141,7 @@ static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
 	int rc;
 
 	rc = ll_statfs_internal(sbi, &osfs,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
@@ -193,7 +193,7 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 	int rc;
 
 	rc = ll_statfs_internal(sbi, &osfs,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
@@ -219,7 +219,7 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 	int rc;
 
 	rc = ll_statfs_internal(sbi, &osfs,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
@@ -245,7 +245,7 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 	int rc;
 
 	rc = ll_statfs_internal(sbi, &osfs,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
@@ -269,7 +269,7 @@ static ssize_t filestotal_show(struct kobject *kobj, struct attribute *attr,
 	int rc;
 
 	rc = ll_statfs_internal(sbi, &osfs,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
@@ -287,7 +287,7 @@ static ssize_t filesfree_show(struct kobject *kobj, struct attribute *attr,
 	int rc;
 
 	rc = ll_statfs_internal(sbi, &osfs,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				OBD_STATFS_NODELAY);
 	if (rc)
 		return rc;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 9a1064b..d0f626f 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -893,7 +893,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			return -EFAULT;
 
 		rc = obd_statfs(NULL, tgt->ltd_exp, &stat_buf,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				0);
 		if (rc)
 			return rc;
@@ -1326,7 +1326,7 @@ static int lmv_process_config(struct obd_device *obd, u32 len, void *buf)
 }
 
 static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
-		      struct obd_statfs *osfs, u64 max_age, u32 flags)
+		      struct obd_statfs *osfs, time64_t max_age, u32 flags)
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct lmv_obd *lmv = &obd->u.lmv;
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index acfee93..1708fa9 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -915,7 +915,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 }
 
 static int lov_statfs(const struct lu_env *env, struct obd_export *exp,
-		      struct obd_statfs *osfs, u64 max_age, u32 flags)
+		      struct obd_statfs *osfs, time64_t max_age, u32 flags)
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct lov_obd *lov = &obd->u.lov;
@@ -1001,7 +1001,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 		/* got statfs data */
 		rc = obd_statfs(NULL, lov->lov_tgts[index]->ltd_exp, &stat_buf,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				flags);
 		if (rc)
 			return rc;
diff --git a/fs/lustre/lov/lov_request.c b/fs/lustre/lov/lov_request.c
index 057d6ca..864e410 100644
--- a/fs/lustre/lov/lov_request.c
+++ b/fs/lustre/lov/lov_request.c
@@ -158,7 +158,7 @@ static int lov_fini_statfs(struct obd_device *obd, struct obd_statfs *osfs,
 
 		spin_lock(&obd->obd_osfs_lock);
 		memcpy(&obd->obd_osfs, osfs, sizeof(*osfs));
-		obd->obd_osfs_age = get_jiffies_64();
+		obd->obd_osfs_age = ktime_get_seconds();
 		spin_unlock(&obd->obd_osfs_lock);
 		return 0;
 	}
@@ -275,7 +275,7 @@ static int cb_statfs_update(void *cookie, int rc)
 	spin_lock(&tgtobd->obd_osfs_lock);
 	memcpy(&tgtobd->obd_osfs, lov_sfs, sizeof(*lov_sfs));
 	if ((oinfo->oi_flags & OBD_STATFS_FROM_CACHE) == 0)
-		tgtobd->obd_osfs_age = get_jiffies_64();
+		tgtobd->obd_osfs_age = ktime_get_seconds();
 	spin_unlock(&tgtobd->obd_osfs_lock);
 
 out_update:
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 95698c3..dd9ab5a 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1439,7 +1439,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 
 static int mdc_statfs(const struct lu_env *env,
 		      struct obd_export *exp, struct obd_statfs *osfs,
-		      u64 max_age, u32 flags)
+		      time64_t max_age, u32 flags)
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct ptlrpc_request *req;
@@ -2002,7 +2002,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		}
 
 		rc = mdc_statfs(NULL, obd->obd_self_export, &stat_buf,
-				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
+				ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
 				0);
 		if (rc != 0)
 			goto out;
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 6491032..f809d00c 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -307,7 +307,7 @@ struct obd_device *class_newdev(const char *type_name, const char *name,
 	/* newdev->obd_osfs_age must be set to a value in the distant
 	 * past to guarantee a fresh statfs is fetched on mount.
 	 */
-	newdev->obd_osfs_age = get_jiffies_64() - 1000 * HZ;
+	newdev->obd_osfs_age = ktime_get_seconds() - 1000;
 
 	/* XXX belongs in setup not attach  */
 	init_rwsem(&newdev->obd_observer_link_sem);
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index dbbaa92..135926e 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -351,9 +351,11 @@ static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct obd_statfs osfs;
-	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
-			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
-			    OBD_STATFS_NODELAY);
+	int rc;
+
+	rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
+			ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
+			OBD_STATFS_NODELAY);
 	if (!rc)
 		return sprintf(buf, "%u\n", osfs.os_bsize);
 
@@ -367,9 +369,11 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct obd_statfs osfs;
-	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
-			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
-			    OBD_STATFS_NODELAY);
+	int rc;
+
+	rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
+			ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
+			OBD_STATFS_NODELAY);
 	if (!rc) {
 		u32 blk_size = osfs.os_bsize >> 10;
 		u64 result = osfs.os_blocks;
@@ -388,9 +392,11 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct obd_statfs osfs;
-	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
-			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
-			    OBD_STATFS_NODELAY);
+	int rc;
+
+	rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
+			ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
+			OBD_STATFS_NODELAY);
 	if (!rc) {
 		u32 blk_size = osfs.os_bsize >> 10;
 		u64 result = osfs.os_bfree;
@@ -410,9 +416,11 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct obd_statfs osfs;
-	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
-			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
-			    OBD_STATFS_NODELAY);
+	int rc;
+
+	rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
+			ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
+			OBD_STATFS_NODELAY);
 	if (!rc) {
 		u32 blk_size = osfs.os_bsize >> 10;
 		u64 result = osfs.os_bavail;
@@ -432,9 +440,11 @@ static ssize_t filestotal_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct obd_statfs osfs;
-	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
-			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
-			    OBD_STATFS_NODELAY);
+	int rc;
+
+	rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
+			ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
+			OBD_STATFS_NODELAY);
 	if (!rc)
 		return sprintf(buf, "%llu\n", osfs.os_files);
 
@@ -448,9 +458,11 @@ static ssize_t filesfree_show(struct kobject *kobj, struct attribute *attr,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct obd_statfs osfs;
-	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
-			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
-			    OBD_STATFS_NODELAY);
+	int rc;
+
+	rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
+			ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
+			OBD_STATFS_NODELAY);
 	if (!rc)
 		return sprintf(buf, "%llu\n", osfs.os_ffree);
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 0f7ac2d..5797535 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2471,7 +2471,7 @@ static int osc_statfs_interpret(const struct lu_env *env,
 }
 
 static int osc_statfs_async(struct obd_export *exp,
-			    struct obd_info *oinfo, u64 max_age,
+			    struct obd_info *oinfo, time64_t max_age,
 			    struct ptlrpc_request_set *rqset)
 {
 	struct obd_device *obd = class_exp2obd(exp);
@@ -2515,7 +2515,7 @@ static int osc_statfs_async(struct obd_export *exp,
 }
 
 static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
-		      struct obd_statfs *osfs, u64 max_age, u32 flags)
+		      struct obd_statfs *osfs, time64_t max_age, u32 flags)
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct obd_statfs *msfs;
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 3c56798..152a84c 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -462,7 +462,7 @@ static int import_select_connection(struct obd_import *imp)
 	}
 
 	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
-		CDEBUG(D_HA, "%s: connect to NID %s last attempt %llu\n",
+		CDEBUG(D_HA, "%s: connect to NID %s last attempt %lld\n",
 		       imp->imp_obd->obd_name,
 		       libcfs_nid2str(conn->oic_conn->c_peer.nid),
 		       conn->oic_last_attempt);
@@ -471,8 +471,7 @@ static int import_select_connection(struct obd_import *imp)
 		 * the last successful attempt, go with this one
 		 */
 		if ((conn->oic_last_attempt == 0) ||
-		    time_before_eq64(conn->oic_last_attempt,
-				     imp->imp_last_success_conn)) {
+		    conn->oic_last_attempt <= imp->imp_last_success_conn) {
 			imp_conn = conn;
 			tried_all = 0;
 			break;
@@ -484,8 +483,7 @@ static int import_select_connection(struct obd_import *imp)
 		 */
 		if (!imp_conn)
 			imp_conn = conn;
-		else if (time_before64(conn->oic_last_attempt,
-					    imp_conn->oic_last_attempt))
+		else if (imp_conn->oic_last_attempt > conn->oic_last_attempt)
 			imp_conn = conn;
 	}
 
@@ -517,7 +515,7 @@ static int import_select_connection(struct obd_import *imp)
 		       imp->imp_obd->obd_name, at_get(at));
 	}
 
-	imp_conn->oic_last_attempt = get_jiffies_64();
+	imp_conn->oic_last_attempt = ktime_get_seconds();
 
 	/* switch connection, don't mind if it's same as the current one */
 	ptlrpc_connection_put(imp->imp_connection);
-- 
1.8.3.1
