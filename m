From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:04 +1100
Subject: [lustre-devel] [PATCH 01/37] lustre: obdclass: char
 obd_ioctl_getdata type.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494481.24125.17153359714439231322.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Instead of having obd_ioctl_getdata() return the allocated
data as a "char *", return it as it really is,
 struct obd_ioctl_data *

This avoids the need for extra variables and casts.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |    3 ++-
 drivers/staging/lustre/lustre/llite/dir.c          |   18 ++++++------------
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    8 +++-----
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   15 ++++++---------
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   18 ++++++++----------
 5 files changed, 25 insertions(+), 37 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 30b3e2c69f83..32d4ab6e78a0 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1697,6 +1697,7 @@ struct root_squash_info {
 };
 
 /* linux-module.c */
-int obd_ioctl_getdata(char **buf, int *len, void __user *arg);
+struct obd_ioctl_data;
+int obd_ioctl_getdata(struct obd_ioctl_data **data, int *len, void __user *arg);
 
 #endif /* __LINUX_OBD_CLASS_H */
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index fd1af4a5cdad..17bb6185ba87 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1130,13 +1130,11 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	}
 	case IOC_MDC_LOOKUP: {
 		int namelen, len = 0;
-		char *buf = NULL;
 		char *filename;
 
-		rc = obd_ioctl_getdata(&buf, &len, (void __user *)arg);
+		rc = obd_ioctl_getdata(&data, &len, (void __user *)arg);
 		if (rc)
 			return rc;
-		data = (void *)buf;
 
 		filename = data->ioc_inlbuf1;
 		namelen = strlen(filename);
@@ -1155,12 +1153,11 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto out_free;
 		}
 out_free:
-		kvfree(buf);
+		kvfree(data);
 		return rc;
 	}
 	case LL_IOC_LMV_SETSTRIPE: {
 		struct lmv_user_md  *lum;
-		char *buf = NULL;
 		char *filename;
 		int namelen = 0;
 		int lumlen = 0;
@@ -1168,11 +1165,10 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		int len;
 		int rc;
 
-		rc = obd_ioctl_getdata(&buf, &len, (void __user *)arg);
+		rc = obd_ioctl_getdata(&data, &len, (void __user *)arg);
 		if (rc)
 			return rc;
 
-		data = (void *)buf;
 		if (!data->ioc_inlbuf1 || !data->ioc_inlbuf2 ||
 		    data->ioc_inllen1 == 0 || data->ioc_inllen2 == 0) {
 			rc = -EINVAL;
@@ -1205,7 +1201,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 #endif
 		rc = ll_dir_setdirstripe(dentry, lum, filename, mode);
 lmv_out_free:
-		kvfree(buf);
+		kvfree(data);
 		return rc;
 	}
 	case LL_IOC_LMV_SET_DEFAULT_STRIPE: {
@@ -1651,18 +1647,16 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case LL_IOC_MIGRATE: {
-		char *buf = NULL;
 		const char *filename;
 		int namelen = 0;
 		int len;
 		int rc;
 		int mdtidx;
 
-		rc = obd_ioctl_getdata(&buf, &len, (void __user *)arg);
+		rc = obd_ioctl_getdata(&data, &len, (void __user *)arg);
 		if (rc < 0)
 			return rc;
 
-		data = (struct obd_ioctl_data *)buf;
 		if (!data->ioc_inlbuf1 || !data->ioc_inlbuf2 ||
 		    !data->ioc_inllen1 || !data->ioc_inllen2) {
 			rc = -EINVAL;
@@ -1684,7 +1678,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		rc = ll_migrate(inode, file, mdtidx, filename, namelen - 1);
 migrate_free:
-		kvfree(buf);
+		kvfree(data);
 
 		return rc;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 8e09fdd7a96e..e2417cd5aaed 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2295,7 +2295,6 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 {
 	struct ll_sb_info *sbi = NULL;
 	struct obd_export *exp;
-	char *buf = NULL;
 	struct obd_ioctl_data *data = NULL;
 	u32 type;
 	int len = 0, rc;
@@ -2311,11 +2310,10 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 		goto out_statfs;
 	}
 
-	rc = obd_ioctl_getdata(&buf, &len, arg);
+	rc = obd_ioctl_getdata(&data, &len, arg);
 	if (rc)
 		goto out_statfs;
 
-	data = (void *)buf;
 	if (!data->ioc_inlbuf1 || !data->ioc_inlbuf2 ||
 	    !data->ioc_pbuf1 || !data->ioc_pbuf2) {
 		rc = -EINVAL;
@@ -2340,11 +2338,11 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 		goto out_statfs;
 	}
 
-	rc = obd_iocontrol(IOC_OBD_STATFS, exp, len, buf, NULL);
+	rc = obd_iocontrol(IOC_OBD_STATFS, exp, len, data, NULL);
 	if (rc)
 		goto out_statfs;
 out_statfs:
-	kvfree(buf);
+	kvfree(data);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 04d0a9ed1d05..fd769c39b482 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1039,27 +1039,24 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	case OBD_IOC_LOV_GET_CONFIG: {
 		struct obd_ioctl_data *data;
 		struct lov_desc *desc;
-		char *buf = NULL;
 		u32 *genp;
 
 		len = 0;
-		if (obd_ioctl_getdata(&buf, &len, uarg))
+		if (obd_ioctl_getdata(&data, &len, uarg))
 			return -EINVAL;
 
-		data = (struct obd_ioctl_data *)buf;
-
 		if (sizeof(*desc) > data->ioc_inllen1) {
-			kvfree(buf);
+			kvfree(data);
 			return -EINVAL;
 		}
 
 		if (sizeof(uuidp->uuid) * count > data->ioc_inllen2) {
-			kvfree(buf);
+			kvfree(data);
 			return -EINVAL;
 		}
 
 		if (sizeof(u32) * count > data->ioc_inllen3) {
-			kvfree(buf);
+			kvfree(data);
 			return -EINVAL;
 		}
 
@@ -1076,9 +1073,9 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			*genp = lov->lov_tgts[i]->ltd_gen;
 		}
 
-		if (copy_to_user(uarg, buf, len))
+		if (copy_to_user(uarg, data, len))
 			rc = -EFAULT;
-		kvfree(buf);
+		kvfree(data);
 		break;
 	}
 	case OBD_IOC_QUOTACTL: {
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 2ee6b96f4830..b8fc74044fe3 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -229,7 +229,7 @@ static int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
 }
 
 /* buffer MUST be at least the size of obd_ioctl_hdr */
-int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
+int obd_ioctl_getdata(struct obd_ioctl_data **datap, int *len, void __user *arg)
 {
 	struct obd_ioctl_data *data;
 	struct obd_ioctl_hdr hdr;
@@ -261,16 +261,16 @@ int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
 	 * obdfilter-survey is an example, which relies on ioctl. So we'd
 	 * better avoid vmalloc on ioctl path. LU-66
 	 */
-	*buf = kvzalloc(hdr.ioc_len, GFP_KERNEL);
-	if (!*buf) {
+	data = kvzalloc(hdr.ioc_len, GFP_KERNEL);
+	if (!data) {
 		CERROR("Cannot allocate control buffer of len %d\n",
 		       hdr.ioc_len);
 		return -EINVAL;
 	}
 	*len = hdr.ioc_len;
-	data = (struct obd_ioctl_data *)*buf;
+	*datap = data;
 
-	if (copy_from_user(*buf, arg, hdr.ioc_len)) {
+	if (copy_from_user(data, arg, hdr.ioc_len)) {
 		err = -EFAULT;
 		goto free_buf;
 	}
@@ -307,14 +307,13 @@ int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
 	return 0;
 
 free_buf:
-	kvfree(*buf);
+	kvfree(data);
 	return err;
 }
 EXPORT_SYMBOL(obd_ioctl_getdata);
 
 int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 {
-	char *buf = NULL;
 	struct obd_ioctl_data *data;
 	struct libcfs_debug_ioctl_data *debug_data;
 	struct obd_device *obd = NULL;
@@ -329,11 +328,10 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 	}
 
 	CDEBUG(D_IOCTL, "cmd = %x\n", cmd);
-	if (obd_ioctl_getdata(&buf, &len, (void __user *)arg)) {
+	if (obd_ioctl_getdata(&data, &len, (void __user *)arg)) {
 		CERROR("OBD ioctl: data error\n");
 		return -EINVAL;
 	}
-	data = (struct obd_ioctl_data *)buf;
 
 	switch (cmd) {
 	case OBD_IOC_PROCESS_CFG: {
@@ -542,7 +540,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 	}
 
  out:
-	kvfree(buf);
+	kvfree(data);
 	return err;
 } /* class_handle_ioctl */
 
