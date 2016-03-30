From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:34 -0400
Subject: [lustre-devel] [PATCH v2 13/46] staging/lustre/llite: remove lli_lvb
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-14-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

In struct ll_inode_info remove the struct ost_lvb lli_lvb member and
replace it with obd_time lli_{a,m,c}time. Rename ll_merge_lvb() to
ll_merge_attr(). Remove cl_merge_lvb() and replace calls to it with
calls to ll_merge_attr().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/12849
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c         | 65 ++++++++++++----------
 drivers/staging/lustre/lustre/llite/glimpse.c      |  6 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   | 11 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  6 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  2 +-
 6 files changed, 48 insertions(+), 44 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 127fff6..8fc9da0 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -994,50 +994,57 @@ int ll_inode_getattr(struct inode *inode, struct obdo *obdo,
 	return rc;
 }
 
-int ll_merge_lvb(const struct lu_env *env, struct inode *inode)
+int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct cl_object *obj = lli->lli_clob;
 	struct cl_attr *attr = ccc_env_thread_attr(env);
-	struct ost_lvb lvb;
+	s64 atime;
+	s64 mtime;
+	s64 ctime;
 	int rc = 0;
 
 	ll_inode_size_lock(inode);
+
 	/* merge timestamps the most recently obtained from mds with
 	 * timestamps obtained from osts
 	 */
-	LTIME_S(inode->i_atime) = lli->lli_lvb.lvb_atime;
-	LTIME_S(inode->i_mtime) = lli->lli_lvb.lvb_mtime;
-	LTIME_S(inode->i_ctime) = lli->lli_lvb.lvb_ctime;
+	LTIME_S(inode->i_atime) = lli->lli_atime;
+	LTIME_S(inode->i_mtime) = lli->lli_mtime;
+	LTIME_S(inode->i_ctime) = lli->lli_ctime;
 
-	lvb.lvb_size = i_size_read(inode);
-	lvb.lvb_blocks = inode->i_blocks;
-	lvb.lvb_mtime = LTIME_S(inode->i_mtime);
-	lvb.lvb_atime = LTIME_S(inode->i_atime);
-	lvb.lvb_ctime = LTIME_S(inode->i_ctime);
+	mtime = LTIME_S(inode->i_mtime);
+	atime = LTIME_S(inode->i_atime);
+	ctime = LTIME_S(inode->i_ctime);
 
 	cl_object_attr_lock(obj);
 	rc = cl_object_attr_get(env, obj, attr);
 	cl_object_attr_unlock(obj);
 
-	if (rc == 0) {
-		if (lvb.lvb_atime < attr->cat_atime)
-			lvb.lvb_atime = attr->cat_atime;
-		if (lvb.lvb_ctime < attr->cat_ctime)
-			lvb.lvb_ctime = attr->cat_ctime;
-		if (lvb.lvb_mtime < attr->cat_mtime)
-			lvb.lvb_mtime = attr->cat_mtime;
+	if (rc != 0)
+		goto out_size_unlock;
 
-		CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
-		       PFID(&lli->lli_fid), attr->cat_size);
-		cl_isize_write_nolock(inode, attr->cat_size);
+	if (atime < attr->cat_atime)
+		atime = attr->cat_atime;
 
-		inode->i_blocks = attr->cat_blocks;
+	if (ctime < attr->cat_ctime)
+		ctime = attr->cat_ctime;
 
-		LTIME_S(inode->i_mtime) = lvb.lvb_mtime;
-		LTIME_S(inode->i_atime) = lvb.lvb_atime;
-		LTIME_S(inode->i_ctime) = lvb.lvb_ctime;
-	}
+	if (mtime < attr->cat_mtime)
+		mtime = attr->cat_mtime;
+
+	CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
+	       PFID(&lli->lli_fid), attr->cat_size);
+
+	cl_isize_write_nolock(inode, attr->cat_size);
+
+	inode->i_blocks = attr->cat_blocks;
+
+	LTIME_S(inode->i_mtime) = mtime;
+	LTIME_S(inode->i_atime) = atime;
+	LTIME_S(inode->i_ctime) = ctime;
+
+out_size_unlock:
 	ll_inode_size_unlock(inode);
 
 	return rc;
@@ -1936,7 +1943,7 @@ int ll_hsm_release(struct inode *inode)
 		goto out;
 	}
 
-	ll_merge_lvb(env, inode);
+	ll_merge_attr(env, inode);
 	cl_env_nested_put(&nest, env);
 
 	/* Release the file.
@@ -3001,9 +3008,9 @@ static int ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 
 	/* if object isn't regular file, don't validate size */
 	if (!S_ISREG(inode->i_mode)) {
-		LTIME_S(inode->i_atime) = ll_i2info(inode)->lli_lvb.lvb_atime;
-		LTIME_S(inode->i_mtime) = ll_i2info(inode)->lli_lvb.lvb_mtime;
-		LTIME_S(inode->i_ctime) = ll_i2info(inode)->lli_lvb.lvb_ctime;
+		LTIME_S(inode->i_atime) = ll_i2info(inode)->lli_atime;
+		LTIME_S(inode->i_mtime) = ll_i2info(inode)->lli_mtime;
+		LTIME_S(inode->i_ctime) = ll_i2info(inode)->lli_ctime;
 	} else {
 		/* In case of restore, the MDT has the right size and has
 		 * already send it back without granting the layout lock,
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index f235f35..88bc7c9 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -139,7 +139,7 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 			LASSERT(agl == 0);
 			result = cl_wait(env, lock);
 			if (result == 0) {
-				cl_merge_lvb(env, inode);
+				ll_merge_attr(env, inode);
 				if (cl_isize_read(inode) > 0 &&
 				    inode->i_blocks == 0) {
 					/*
@@ -155,7 +155,7 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 			cl_lock_release(env, lock, "glimpse", current);
 		} else {
 			CDEBUG(D_DLMTRACE, "No objects for inode\n");
-			cl_merge_lvb(env, inode);
+			ll_merge_attr(env, inode);
 		}
 	}
 
@@ -259,7 +259,7 @@ int cl_local_size(struct inode *inode)
 		descr->cld_obj = clob;
 		lock = cl_lock_peek(env, io, descr, "localsize", current);
 		if (lock) {
-			cl_merge_lvb(env, inode);
+			ll_merge_attr(env, inode);
 			cl_unuse(env, lock);
 			cl_lock_release(env, lock, "localsize", current);
 			result = 0;
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index e34d832..4871d0f 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -591,7 +591,7 @@ void ccc_lock_state(const struct lu_env *env,
 		 */
 		if (lock->cll_descr.cld_start == 0 &&
 		    lock->cll_descr.cld_end == CL_PAGE_EOF)
-			cl_merge_lvb(env, inode);
+			ll_merge_attr(env, inode);
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cd69173..c1d747a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -161,7 +161,9 @@ struct ll_inode_info {
 	struct inode			lli_vfs_inode;
 
 	/* the most recent timestamps obtained from mds */
-	struct ost_lvb			lli_lvb;
+	s64				lli_atime;
+	s64				lli_mtime;
+	s64				lli_ctime;
 	spinlock_t			lli_agl_lock;
 
 	/* Try to make the d::member and f::member are aligned. Before using
@@ -752,7 +754,7 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
 		     int *lmm_size, struct ptlrpc_request **request);
 int ll_fsync(struct file *file, loff_t start, loff_t end, int data);
-int ll_merge_lvb(const struct lu_env *env, struct inode *inode);
+int ll_merge_attr(const struct lu_env *env, struct inode *inode);
 int ll_fid2path(struct inode *inode, void __user *arg);
 int ll_data_version(struct inode *inode, __u64 *data_version, int extent_lock);
 int ll_hsm_release(struct inode *inode);
@@ -1319,11 +1321,6 @@ static inline void cl_isize_write(struct inode *inode, loff_t kms)
 
 #define cl_isize_read(inode)	     i_size_read(inode)
 
-static inline int cl_merge_lvb(const struct lu_env *env, struct inode *inode)
-{
-	return ll_merge_lvb(env, inode);
-}
-
 #define cl_inode_atime(inode) LTIME_S((inode)->i_atime)
 #define cl_inode_ctime(inode) LTIME_S((inode)->i_ctime)
 #define cl_inode_mtime(inode) LTIME_S((inode)->i_mtime)
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index a4401f2..0b4e0db 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1551,7 +1551,7 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 	if (body->valid & OBD_MD_FLATIME) {
 		if (body->atime > LTIME_S(inode->i_atime))
 			LTIME_S(inode->i_atime) = body->atime;
-		lli->lli_lvb.lvb_atime = body->atime;
+		lli->lli_atime = body->atime;
 	}
 	if (body->valid & OBD_MD_FLMTIME) {
 		if (body->mtime > LTIME_S(inode->i_mtime)) {
@@ -1560,12 +1560,12 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 			       body->mtime);
 			LTIME_S(inode->i_mtime) = body->mtime;
 		}
-		lli->lli_lvb.lvb_mtime = body->mtime;
+		lli->lli_mtime = body->mtime;
 	}
 	if (body->valid & OBD_MD_FLCTIME) {
 		if (body->ctime > LTIME_S(inode->i_ctime))
 			LTIME_S(inode->i_ctime) = body->ctime;
-		lli->lli_lvb.lvb_ctime = body->ctime;
+		lli->lli_ctime = body->ctime;
 	}
 	if (body->valid & OBD_MD_FLMODE)
 		inode->i_mode = (inode->i_mode & S_IFMT)|(body->mode & ~S_IFMT);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 18127d3..c7db318 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -739,7 +739,7 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 	}
 
 	/* update inode size */
-	ll_merge_lvb(env, inode);
+	ll_merge_attr(env, inode);
 
 	/* Now the pages in queue were failed to commit, discard them
 	 * unless they were dirtied before.
-- 
2.1.0
