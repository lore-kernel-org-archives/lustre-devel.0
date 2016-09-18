From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:53 -0400
Subject: [lustre-devel] [PATCH 054/124] staging: lustre: llite: Add ioctl to
	get parent fids from link EA.
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-55-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, Thomas Leibovici <thomas.leibovici@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

Added LL_IOC_GETPARENT to retrieve the <parent_fid>/name(s) of a given
entry, based on its link EA. This saves multiple calls to
path2fid/fid2path.

Merged with second later patch that does various cleanups.
Avoid unneeded allocation. Get read-only attributes from the user
getparent structure and write the modified attributes only, instead
of populating a whole structure in kernel and copying it back.

Signed-off-by: Thomas Leibovici <thomas.leibovici@cea.fr>
Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3613
Reviewed-on: http://review.whamcloud.com/7069
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5837
Reviewed-on: http://review.whamcloud.com/12527
Reviewed-by: Ned Bass <bass6@llnl.gov>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    8 ++
 .../lustre/lustre/include/lustre/lustre_user.h     |    1 +
 drivers/staging/lustre/lustre/llite/dir.c          |    2 +
 drivers/staging/lustre/lustre/llite/file.c         |    2 +
 .../staging/lustre/lustre/llite/llite_internal.h   |   13 ++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  125 ++++++++++++++++++++
 drivers/staging/lustre/lustre/llite/xattr.c        |   10 +--
 7 files changed, 152 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 2dc550a..0cc47bc 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3468,6 +3468,14 @@ struct getinfo_fid2path {
 
 void lustre_swab_fid2path(struct getinfo_fid2path *gf);
 
+/** path2parent request/reply structures */
+struct getparent {
+	struct lu_fid	gp_fid;		/**< parent FID */
+	__u32		gp_linkno;	/**< hardlink number */
+	__u32		gp_name_size;	/**< size of the name field */
+	char		gp_name[0];	/**< zero-terminated link name */
+} __packed;
+
 enum {
 	LAYOUT_INTENT_ACCESS    = 0,
 	LAYOUT_INTENT_READ      = 1,
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index cc0a786..08ac6e4 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -245,6 +245,7 @@ struct ost_id {
 #define LL_IOC_LMV_SET_DEFAULT_STRIPE	_IOWR('f', 246, struct lmv_user_md)
 #define LL_IOC_MIGRATE			_IOR('f', 247, int)
 #define LL_IOC_FID2MDTIDX		_IOWR('f', 248, struct lu_fid)
+#define LL_IOC_GETPARENT		_IOWR('f', 249, struct getparent)
 
 /* Lease types for use as arg and return of LL_IOC_{GET,SET}_LEASE ioctl. */
 enum ll_lease_type {
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 234095e..705de1c 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1562,6 +1562,8 @@ out_quotactl:
 		return rc;
 	case OBD_IOC_FID2PATH:
 		return ll_fid2path(inode, (void __user *)arg);
+	case LL_IOC_GETPARENT:
+		return ll_getparent(file, (void __user *)arg);
 	case LL_IOC_FID2MDTIDX: {
 		struct obd_export *exp = ll_i2mdexp(inode);
 		struct lu_fid fid;
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 127d0e0..45acc5d 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2362,6 +2362,8 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		return 0;
 	}
+	case LL_IOC_GETPARENT:
+		return ll_getparent(file, (struct getparent __user *)arg);
 	case OBD_IOC_FID2PATH:
 		return ll_fid2path(inode, (void __user *)arg);
 	case LL_IOC_DATA_VERSION: {
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index fc707c2..1cc427c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -36,6 +36,7 @@
 #include "../include/lustre_ver.h"
 #include "../include/lustre_disk.h"	/* for s2sbi */
 #include "../include/lustre_eacl.h"
+#include "../include/lustre_linkea.h"
 
 /* for struct cl_lock_descr and struct cl_io */
 #include "../include/cl_object.h"
@@ -1038,7 +1039,17 @@ static inline __u64 ll_file_maxbytes(struct inode *inode)
 /* llite/xattr.c */
 extern const struct xattr_handler *ll_xattr_handlers[];
 
+#define XATTR_USER_T		1
+#define XATTR_TRUSTED_T		2
+#define XATTR_SECURITY_T	3
+#define XATTR_ACL_ACCESS_T	4
+#define XATTR_ACL_DEFAULT_T	5
+#define XATTR_LUSTRE_T		6
+#define XATTR_OTHER_T		7
+
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size);
+int ll_xattr_list(struct inode *inode, const char *name, int type,
+		  void *buffer, size_t size, __u64 valid);
 
 /**
  * Common IO arguments for various VFS I/O interfaces.
@@ -1399,6 +1410,8 @@ void ll_xattr_fini(void);
 int ll_page_sync_io(const struct lu_env *env, struct cl_io *io,
 		    struct cl_page *page, enum cl_req_type crt);
 
+int ll_getparent(struct file *file, struct getparent __user *arg);
+
 /* lcommon_cl.c */
 int cl_setattr_ost(struct inode *inode, const struct iattr *attr);
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 5792354..5cbce1b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2545,3 +2545,128 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 	}
 	up_write(&squash->rsi_sem);
 }
+
+/**
+ * Parse linkea content to extract information about a given hardlink
+ *
+ * \param[in]	ldata		- Initialized linkea data
+ * \param[in]	linkno		- Link identifier
+ * \param[out]	parent_fid	- The entry's parent FID
+ * \param[in]	size		- Entry name destination buffer
+ *
+ * \retval 0 on success
+ * \retval Appropriate negative error code on failure
+ */
+static int ll_linkea_decode(struct linkea_data *ldata, unsigned int linkno,
+			    struct lu_fid *parent_fid, struct lu_name *ln)
+{
+	unsigned int idx;
+	int rc;
+
+	rc = linkea_init(ldata);
+	if (rc < 0)
+		return rc;
+
+	if (linkno >= ldata->ld_leh->leh_reccount)
+		/* beyond last link */
+		return -ENODATA;
+
+	linkea_first_entry(ldata);
+	for (idx = 0; ldata->ld_lee; idx++) {
+		linkea_entry_unpack(ldata->ld_lee, &ldata->ld_reclen, ln,
+				    parent_fid);
+		if (idx == linkno)
+			break;
+
+		linkea_next_entry(ldata);
+	}
+
+	if (idx < linkno)
+		return -ENODATA;
+
+	return 0;
+}
+
+/**
+ * Get parent FID and name of an identified link. Operation is performed for
+ * a given link number, letting the caller iterate over linkno to list one or
+ * all links of an entry.
+ *
+ * \param[in]	  file	- File descriptor against which to perform the operation
+ * \param[in,out] arg	- User-filled structure containing the linkno to operate
+ *			  on and the available size. It is eventually filled with
+ *			  the requested information or left untouched on error
+ *
+ * \retval - 0 on success
+ * \retval - Appropriate negative error code on failure
+ */
+int ll_getparent(struct file *file, struct getparent __user *arg)
+{
+	struct inode *inode = file_inode(file);
+	struct linkea_data *ldata;
+	struct lu_fid parent_fid;
+	struct lu_buf buf = {
+		.lb_buf = NULL,
+		.lb_len = 0
+	};
+	struct lu_name ln;
+	u32 name_size;
+	u32 linkno;
+	int rc;
+
+	if (!capable(CFS_CAP_DAC_READ_SEARCH) &&
+	    !(ll_i2sbi(inode)->ll_flags & LL_SBI_USER_FID2PATH))
+		return -EPERM;
+
+	if (get_user(name_size, &arg->gp_name_size))
+		return -EFAULT;
+
+	if (get_user(linkno, &arg->gp_linkno))
+		return -EFAULT;
+
+	if (name_size > PATH_MAX)
+		return -EINVAL;
+
+	ldata = kzalloc(sizeof(*ldata), GFP_NOFS);
+	if (!ldata)
+		return -ENOMEM;
+
+	rc = linkea_data_new(ldata, &buf);
+	if (rc < 0)
+		goto ldata_free;
+
+	rc = ll_xattr_list(inode, XATTR_NAME_LINK, XATTR_TRUSTED_T, buf.lb_buf,
+			   buf.lb_len, OBD_MD_FLXATTR);
+	if (rc < 0)
+		goto lb_free;
+
+	rc = ll_linkea_decode(ldata, linkno, &parent_fid, &ln);
+	if (rc < 0)
+		goto lb_free;
+
+	if (ln.ln_namelen >= name_size) {
+		rc = -EOVERFLOW;
+		goto lb_free;
+	}
+
+	if (copy_to_user(&arg->gp_fid, &parent_fid, sizeof(arg->gp_fid))) {
+		rc = -EFAULT;
+		goto lb_free;
+	}
+
+	if (copy_to_user(&arg->gp_name, ln.ln_name, ln.ln_namelen)) {
+		rc = -EFAULT;
+		goto lb_free;
+	}
+
+	if (put_user('\0', arg->gp_name + ln.ln_namelen)) {
+		rc = -EFAULT;
+		goto lb_free;
+	}
+
+lb_free:
+	lu_buf_free(&buf);
+ldata_free:
+	kfree(ldata);
+	return rc;
+}
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 17ad04f..0e6a559 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -44,14 +44,6 @@
 
 #include "llite_internal.h"
 
-#define XATTR_USER_T	    (1)
-#define XATTR_TRUSTED_T	 (2)
-#define XATTR_SECURITY_T	(3)
-#define XATTR_ACL_ACCESS_T      (4)
-#define XATTR_ACL_DEFAULT_T     (5)
-#define XATTR_LUSTRE_T	  (6)
-#define XATTR_OTHER_T	   (7)
-
 static
 int get_xattr_type(const char *name)
 {
@@ -219,7 +211,7 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 				   flags);
 }
 
-static int
+int
 ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 	      size_t size, __u64 valid)
 {
-- 
1.7.1
