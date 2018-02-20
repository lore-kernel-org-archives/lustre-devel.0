From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 01/21] staging: lustre: replace all CFS_CAP_*
 macros with CAP_*
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341755.25814.8807958574153162982.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Lustre defines a few CFS_CAP_* macros which are exactly the
same as the corresponding CAP_* macro, with one exception.

CFS_CAP_SYS_BOOT is 23
CAP_SYS_BOOT is 22.

CFS_CAP_SYS_BOOT is only used through CFS_CAP_FS_MASK and
causes capability 23 (CAP_SYS_NICE) to be dropped in certain
circumstances.
It is probable that the intention was to drop CAP_SYS_BOOT,
and this is what is now done.

CFS_CAP_CHOWN_MASK and CFS_CAP_SYS_RESOURCE_MASK are never
used, so they have been removed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/curproc.h  |   28 ++++++--------------
 drivers/staging/lustre/lustre/include/lustre_sec.h |    3 --
 drivers/staging/lustre/lustre/llite/dir.c          |    8 +++---
 drivers/staging/lustre/lustre/llite/file.c         |    6 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    4 +--
 drivers/staging/lustre/lustre/llite/xattr.c        |    2 +
 .../lustre/lustre/obdclass/linux/linux-module.c    |    2 +
 drivers/staging/lustre/lustre/obdclass/llog.c      |    6 ++--
 .../staging/lustre/lustre/obdecho/echo_client.c    |    8 +++---
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    4 +--
 drivers/staging/lustre/lustre/osc/osc_page.c       |    2 +
 11 files changed, 30 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
index 3cb3f086148e..cdc549e2979f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
@@ -56,25 +56,15 @@
 
 typedef u32 cfs_cap_t;
 
-#define CFS_CAP_CHOWN		   0
-#define CFS_CAP_DAC_OVERRIDE	    1
-#define CFS_CAP_DAC_READ_SEARCH	 2
-#define CFS_CAP_FOWNER		  3
-#define CFS_CAP_FSETID		  4
-#define CFS_CAP_LINUX_IMMUTABLE	 9
-#define CFS_CAP_SYS_ADMIN	      21
-#define CFS_CAP_SYS_BOOT	       23
-#define CFS_CAP_SYS_RESOURCE	   24
-
-#define CFS_CAP_FS_MASK (BIT(CFS_CAP_CHOWN) |		\
-			 BIT(CFS_CAP_DAC_OVERRIDE) |	\
-			 BIT(CFS_CAP_DAC_READ_SEARCH) |	\
-			 BIT(CFS_CAP_FOWNER) |		\
-			 BIT(CFS_CAP_FSETID) |		\
-			 BIT(CFS_CAP_LINUX_IMMUTABLE) | \
-			 BIT(CFS_CAP_SYS_ADMIN) |	\
-			 BIT(CFS_CAP_SYS_BOOT) |	\
-			 BIT(CFS_CAP_SYS_RESOURCE))
+#define CFS_CAP_FS_MASK (BIT(CAP_CHOWN) |		\
+			 BIT(CAP_DAC_OVERRIDE) |	\
+			 BIT(CAP_DAC_READ_SEARCH) |	\
+			 BIT(CAP_FOWNER) |		\
+			 BIT(CAP_FSETID) |		\
+			 BIT(CAP_LINUX_IMMUTABLE) | \
+			 BIT(CAP_SYS_ADMIN) |	\
+			 BIT(CAP_SYS_BOOT) |	\
+			 BIT(CAP_SYS_RESOURCE))
 
 void cfs_cap_raise(cfs_cap_t cap);
 void cfs_cap_lower(cfs_cap_t cap);
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index 64b6fd4fed8f..c5cb07acd0da 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -1058,9 +1058,6 @@ int sptlrpc_current_user_desc_size(void);
 int sptlrpc_pack_user_desc(struct lustre_msg *msg, int offset);
 int sptlrpc_unpack_user_desc(struct lustre_msg *req, int offset, int swabbed);
 
-#define CFS_CAP_CHOWN_MASK (1 << CFS_CAP_CHOWN)
-#define CFS_CAP_SYS_RESOURCE_MASK (1 << CFS_CAP_SYS_RESOURCE)
-
 enum {
 	LUSTRE_SEC_NONE	 = 0,
 	LUSTRE_SEC_REMOTE       = 1,
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 99b0b77c75f5..09e3a4999079 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -885,7 +885,7 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 	switch (cmd) {
 	case Q_SETQUOTA:
 	case Q_SETINFO:
-		if (!capable(CFS_CAP_SYS_ADMIN))
+		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 		break;
 	case Q_GETQUOTA:
@@ -893,7 +893,7 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 		      !uid_eq(current_euid(), make_kuid(&init_user_ns, id))) ||
 		     (type == GRPQUOTA &&
 		      !in_egroup_p(make_kgid(&init_user_ns, id)))) &&
-		      !capable(CFS_CAP_SYS_ADMIN))
+		      !capable(CAP_SYS_ADMIN))
 			return -EPERM;
 		break;
 	case Q_GETINFO:
@@ -1452,7 +1452,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	}
 	case OBD_IOC_CHANGELOG_SEND:
 	case OBD_IOC_CHANGELOG_CLEAR:
-		if (!capable(CFS_CAP_SYS_ADMIN))
+		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 
 		rc = copy_and_ioctl(cmd, sbi->ll_md_exp, (void __user *)arg,
@@ -1556,7 +1556,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case LL_IOC_HSM_CT_START:
-		if (!capable(CFS_CAP_SYS_ADMIN))
+		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 
 		rc = copy_and_ioctl(cmd, sbi->ll_md_exp, (void __user *)arg,
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 938b859b6650..4aad2e331948 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1315,7 +1315,7 @@ static int ll_lov_setea(struct inode *inode, struct file *file,
 					    sizeof(struct lov_user_ost_data);
 	int			 rc;
 
-	if (!capable(CFS_CAP_SYS_ADMIN))
+	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	lump = libcfs_kvzalloc(lum_size, GFP_NOFS);
@@ -1570,7 +1570,7 @@ int ll_fid2path(struct inode *inode, void __user *arg)
 	size_t outsize;
 	int rc;
 
-	if (!capable(CFS_CAP_DAC_READ_SEARCH) &&
+	if (!capable(CAP_DAC_READ_SEARCH) &&
 	    !(ll_i2sbi(inode)->ll_flags & LL_SBI_USER_FID2PATH))
 		return -EPERM;
 
@@ -1840,7 +1840,7 @@ int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss)
 	 * NOT defined in HSM_USER_MASK.
 	 */
 	if (((hss->hss_setmask | hss->hss_clearmask) & ~HSM_USER_MASK) &&
-	    !capable(CFS_CAP_SYS_ADMIN))
+	    !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	/* Detect out-of range archive id */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 9e96a8ee1783..07072ab92bb6 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1450,7 +1450,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	/* POSIX: check before ATTR_*TIME_SET set (from setattr_prepare) */
 	if (attr->ia_valid & TIMES_SET_FLAGS) {
 		if ((!uid_eq(current_fsuid(), inode->i_uid)) &&
-		    !capable(CFS_CAP_FOWNER))
+		    !capable(CAP_FOWNER))
 			return -EPERM;
 	}
 
@@ -2597,7 +2597,7 @@ int ll_getparent(struct file *file, struct getparent __user *arg)
 	u32 linkno;
 	int rc;
 
-	if (!capable(CFS_CAP_DAC_READ_SEARCH) &&
+	if (!capable(CAP_DAC_READ_SEARCH) &&
 	    !(ll_i2sbi(inode)->ll_flags & LL_SBI_USER_FID2PATH))
 		return -EPERM;
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 532384c91447..a723056f7166 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -75,7 +75,7 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 		return -EOPNOTSUPP;
 
 	if (handler->flags == XATTR_TRUSTED_T &&
-	    !capable(CFS_CAP_SYS_ADMIN))
+	    !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	return 0;
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 57951237def2..5b1122c408fb 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -251,7 +251,7 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 	int err = 0;
 
 	/* Allow non-root access for OBD_IOC_PING_TARGET - used by lfs check */
-	if (!capable(CFS_CAP_SYS_ADMIN) && (cmd != OBD_IOC_PING_TARGET))
+	if (!capable(CAP_SYS_ADMIN) && (cmd != OBD_IOC_PING_TARGET))
 		return err = -EACCES;
 	if ((cmd & 0xffffff00) == ((int)'T') << 8) /* ignore all tty ioctls */
 		return err = -ENOTTY;
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index cd051e31233e..aa48b3d2199e 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -483,12 +483,12 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 	(*lgh)->lgh_ctxt = ctxt;
 	(*lgh)->lgh_logops = ctxt->loc_logops;
 
-	raised = cfs_cap_raised(CFS_CAP_SYS_RESOURCE);
+	raised = cfs_cap_raised(CAP_SYS_RESOURCE);
 	if (!raised)
-		cfs_cap_raise(CFS_CAP_SYS_RESOURCE);
+		cfs_cap_raise(CAP_SYS_RESOURCE);
 	rc = ctxt->loc_logops->lop_open(env, *lgh, logid, name, open_param);
 	if (!raised)
-		cfs_cap_lower(CFS_CAP_SYS_RESOURCE);
+		cfs_cap_lower(CAP_SYS_RESOURCE);
 	if (rc) {
 		llog_free_handle(*lgh);
 		*lgh = NULL;
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 9c5ce5074b66..99a76db51ae0 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1502,7 +1502,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 	switch (cmd) {
 	case OBD_IOC_CREATE:		    /* may create echo object */
-		if (!capable(CFS_CAP_SYS_ADMIN)) {
+		if (!capable(CAP_SYS_ADMIN)) {
 			rc = -EPERM;
 			goto out;
 		}
@@ -1511,7 +1511,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		goto out;
 
 	case OBD_IOC_DESTROY:
-		if (!capable(CFS_CAP_SYS_ADMIN)) {
+		if (!capable(CAP_SYS_ADMIN)) {
 			rc = -EPERM;
 			goto out;
 		}
@@ -1534,7 +1534,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		goto out;
 
 	case OBD_IOC_SETATTR:
-		if (!capable(CFS_CAP_SYS_ADMIN)) {
+		if (!capable(CAP_SYS_ADMIN)) {
 			rc = -EPERM;
 			goto out;
 		}
@@ -1547,7 +1547,7 @@ echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		goto out;
 
 	case OBD_IOC_BRW_WRITE:
-		if (!capable(CFS_CAP_SYS_ADMIN)) {
+		if (!capable(CAP_SYS_ADMIN)) {
 			rc = -EPERM;
 			goto out;
 		}
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index dacfab12c501..1c70a504ee89 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2345,7 +2345,7 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 	oap->oap_obj_off = offset;
 	LASSERT(!(offset & ~PAGE_MASK));
 
-	if (capable(CFS_CAP_SYS_RESOURCE))
+	if (capable(CAP_SYS_RESOURCE))
 		oap->oap_brw_flags = OBD_BRW_NOQUOTA;
 
 	INIT_LIST_HEAD(&oap->oap_pending_item);
@@ -2384,7 +2384,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 
 	/* Set the OBD_BRW_SRVLOCK before the page is queued. */
 	brw_flags |= ops->ops_srvlock ? OBD_BRW_SRVLOCK : 0;
-	if (capable(CFS_CAP_SYS_RESOURCE)) {
+	if (capable(CAP_SYS_RESOURCE)) {
 		brw_flags |= OBD_BRW_NOQUOTA;
 		cmd |= OBD_BRW_NOQUOTA;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 6fdd521feb21..01a930dbbf64 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -307,7 +307,7 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	oap->oap_count = opg->ops_to - opg->ops_from;
 	oap->oap_brw_flags = brw_flags | OBD_BRW_SYNC;
 
-	if (capable(CFS_CAP_SYS_RESOURCE)) {
+	if (capable(CAP_SYS_RESOURCE)) {
 		oap->oap_brw_flags |= OBD_BRW_NOQUOTA;
 		oap->oap_cmd |= OBD_BRW_NOQUOTA;
 	}
