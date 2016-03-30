From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:55 -0400
Subject: [lustre-devel] [PATCH v2 34/46] staging/lustre/llite: Rename struct
	ccc_grouplock to ll_grouplock
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-35-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, John Hammond <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: John Hammond <john.hammond@intel.com>

And move the definition from vvp_internal.h to llite_internal.h.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/13714
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c         | 16 ++++++-------
 drivers/staging/lustre/lustre/llite/lcommon_misc.c | 26 +++++++++++-----------
 .../staging/lustre/lustre/llite/llite_internal.h   | 14 +++++++++++-
 drivers/staging/lustre/lustre/llite/vvp_internal.h | 11 ---------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  2 +-
 5 files changed, 35 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 63aa080..210d1e2 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -278,7 +278,7 @@ static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
 
 	/* clear group lock, if present */
 	if (unlikely(fd->fd_flags & LL_FILE_GROUP_LOCKED))
-		ll_put_grouplock(inode, file, fd->fd_grouplock.cg_gid);
+		ll_put_grouplock(inode, file, fd->fd_grouplock.lg_gid);
 
 	if (fd->fd_lease_och) {
 		bool lease_broken;
@@ -1570,7 +1570,7 @@ ll_get_grouplock(struct inode *inode, struct file *file, unsigned long arg)
 {
 	struct ll_inode_info   *lli = ll_i2info(inode);
 	struct ll_file_data    *fd = LUSTRE_FPRIVATE(file);
-	struct ccc_grouplock    grouplock;
+	struct ll_grouplock    grouplock;
 	int		     rc;
 
 	if (arg == 0) {
@@ -1584,11 +1584,11 @@ ll_get_grouplock(struct inode *inode, struct file *file, unsigned long arg)
 	spin_lock(&lli->lli_lock);
 	if (fd->fd_flags & LL_FILE_GROUP_LOCKED) {
 		CWARN("group lock already existed with gid %lu\n",
-		      fd->fd_grouplock.cg_gid);
+		      fd->fd_grouplock.lg_gid);
 		spin_unlock(&lli->lli_lock);
 		return -EINVAL;
 	}
-	LASSERT(!fd->fd_grouplock.cg_lock);
+	LASSERT(!fd->fd_grouplock.lg_lock);
 	spin_unlock(&lli->lli_lock);
 
 	rc = cl_get_grouplock(ll_i2info(inode)->lli_clob,
@@ -1617,7 +1617,7 @@ static int ll_put_grouplock(struct inode *inode, struct file *file,
 {
 	struct ll_inode_info   *lli = ll_i2info(inode);
 	struct ll_file_data    *fd = LUSTRE_FPRIVATE(file);
-	struct ccc_grouplock    grouplock;
+	struct ll_grouplock    grouplock;
 
 	spin_lock(&lli->lli_lock);
 	if (!(fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
@@ -1625,11 +1625,11 @@ static int ll_put_grouplock(struct inode *inode, struct file *file,
 		CWARN("no group lock held\n");
 		return -EINVAL;
 	}
-	LASSERT(fd->fd_grouplock.cg_lock);
+	LASSERT(fd->fd_grouplock.lg_lock);
 
-	if (fd->fd_grouplock.cg_gid != arg) {
+	if (fd->fd_grouplock.lg_gid != arg) {
 		CWARN("group lock %lu doesn't match current id %lu\n",
-		      arg, fd->fd_grouplock.cg_gid);
+		      arg, fd->fd_grouplock.lg_gid);
 		spin_unlock(&lli->lli_lock);
 		return -EINVAL;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index 68e3db1..5e3e43f 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -42,8 +42,8 @@
 #include "../include/obd.h"
 #include "../include/cl_object.h"
 
-#include "vvp_internal.h"
 #include "../include/lustre_lite.h"
+#include "llite_internal.h"
 
 /* Initialize the default and maximum LOV EA and cookie sizes.  This allows
  * us to make MDS RPCs with large enough reply buffers to hold the
@@ -126,7 +126,7 @@ int cl_ocd_update(struct obd_device *host,
 #define GROUPLOCK_SCOPE "grouplock"
 
 int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
-		     struct ccc_grouplock *cg)
+		     struct ll_grouplock *cg)
 {
 	struct lu_env	  *env;
 	struct cl_io	   *io;
@@ -172,25 +172,25 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 		return rc;
 	}
 
-	cg->cg_env  = cl_env_get(&refcheck);
-	cg->cg_io   = io;
-	cg->cg_lock = lock;
-	cg->cg_gid  = gid;
-	LASSERT(cg->cg_env == env);
+	cg->lg_env  = cl_env_get(&refcheck);
+	cg->lg_io   = io;
+	cg->lg_lock = lock;
+	cg->lg_gid  = gid;
+	LASSERT(cg->lg_env == env);
 
 	cl_env_unplant(env, &refcheck);
 	return 0;
 }
 
-void cl_put_grouplock(struct ccc_grouplock *cg)
+void cl_put_grouplock(struct ll_grouplock *cg)
 {
-	struct lu_env  *env  = cg->cg_env;
-	struct cl_io   *io   = cg->cg_io;
-	struct cl_lock *lock = cg->cg_lock;
+	struct lu_env  *env  = cg->lg_env;
+	struct cl_io   *io   = cg->lg_io;
+	struct cl_lock *lock = cg->lg_lock;
 	int	     refcheck;
 
-	LASSERT(cg->cg_env);
-	LASSERT(cg->cg_gid);
+	LASSERT(cg->lg_env);
+	LASSERT(cg->lg_gid);
 
 	cl_env_implant(env, &refcheck);
 	cl_env_put(env, &refcheck);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 86e93c0..8b943df 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -99,6 +99,13 @@ struct ll_remote_perm {
 					     */
 };
 
+struct ll_grouplock {
+	struct lu_env	*lg_env;
+	struct cl_io	*lg_io;
+	struct cl_lock	*lg_lock;
+	unsigned long	 lg_gid;
+};
+
 enum lli_flags {
 	/* MDS has an authority for the Size-on-MDS attributes. */
 	LLIF_MDS_SIZE_LOCK      = (1 << 0),
@@ -612,7 +619,7 @@ extern struct kmem_cache *ll_file_data_slab;
 struct lustre_handle;
 struct ll_file_data {
 	struct ll_readahead_state fd_ras;
-	struct ccc_grouplock fd_grouplock;
+	struct ll_grouplock fd_grouplock;
 	__u64 lfd_pos;
 	__u32 fd_flags;
 	fmode_t fd_omode;
@@ -655,6 +662,11 @@ static inline int ll_need_32bit_api(struct ll_sb_info *sbi)
 
 void ll_ras_enter(struct file *f);
 
+/* llite/lcommon_misc.c */
+int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
+		     struct ll_grouplock *cg);
+void cl_put_grouplock(struct ll_grouplock *cg);
+
 /* llite/lproc_llite.c */
 int ldebugfs_register_mountpoint(struct dentry *parent,
 				 struct super_block *sb, char *osc, char *mdc);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 99e7ef3..4740ff5 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -388,17 +388,6 @@ int cl_ocd_update(struct obd_device *host,
 		  struct obd_device *watched,
 		  enum obd_notify_event ev, void *owner, void *data);
 
-struct ccc_grouplock {
-	struct lu_env	*cg_env;
-	struct cl_io	*cg_io;
-	struct cl_lock	*cg_lock;
-	unsigned long	 cg_gid;
-};
-
-int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
-		     struct ccc_grouplock *cg);
-void cl_put_grouplock(struct ccc_grouplock *cg);
-
 /**
  * New interfaces to get and put lov_stripe_md from lov layer. This violates
  * layering because lov_stripe_md is supposed to be a private data in lov.
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 48b0693..18bc71b 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -235,7 +235,7 @@ static int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 
 	if (vio->vui_fd && (vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
 		descr->cld_mode = CLM_GROUP;
-		descr->cld_gid  = vio->vui_fd->fd_grouplock.cg_gid;
+		descr->cld_gid  = vio->vui_fd->fd_grouplock.lg_gid;
 	} else {
 		descr->cld_mode  = mode;
 	}
-- 
2.1.0
