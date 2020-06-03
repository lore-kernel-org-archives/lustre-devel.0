From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:47 -0400
Subject: [lustre-devel] [PATCH 08/22] lustre: llite: integrate statx() API
 with Lustre
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

System call statx() interface can specify a bitmask to fetch
specific attributes from a file (e.g. st_uid, st_gid, st_mode, and
st_btime = file creation time), rather than fetching all of the
normal stat() attributes (such as st_size and st_blocks). It also
has a AT_STATX_DONT_SYNC mode which allows the kernel to return
cached attributes without flushing all of the client data and
fetching an accurate result from the server.
The conditions for adding statx() API for Lustre are mature:
1. statx() is added to Linux 4.11+;
2. glibc supports statx() (glibc 2.28+ -> RHEL 8, Ubuntun 18.10+)
3. The support for stat(1) and ls(1) to use statx(3) to fetch
   only the required attributes has landed to the upstream GNU
   coreutils package.

This patch integrates statx() API with Lustre so that we can take
advantage of the efficiencies available:
 - Only fetch MDS attributes if STATX_SIZE, STATX_BLOCKS and
   STATX_MTIME are not requested, and avoid OSS glimpse RPCs
   completely;
 - Hook this into statahead to avoid async glimpse locks (AGL) if
   OST information not needed;
 - Enhance the MDS RPC interface to return the file creation time
   stored in both ldiskfs and ZFS already, and enable STATX_BTIME;
 - Better support with AT_STATX_DONT_SYNC mode. Return the "lazy"
   attributes or cached attributes (even stale) on a client if
   available without any RPCs to servers (MDS and OSS).
 - statx (lustre/test/statx): port coreutils ls/stat by using
   statx(3) system call if OS supported it.
 - Test scripts. Using statx() to verify btime attribute and the
   advantage described above.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10934
Lustre-commit: 3f7853b31ef6f5 ("LU-10934 llite: integrate statx() API with Lustre")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/36674
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dcache.c         |  4 +-
 fs/lustre/llite/file.c           | 80 ++++++++++++++++++++++++++++++++++++----
 fs/lustre/llite/llite_internal.h | 12 +++++-
 fs/lustre/llite/llite_lib.c      |  9 +++++
 fs/lustre/llite/namei.c          |  2 +-
 fs/lustre/llite/pcc.c            |  5 ++-
 fs/lustre/llite/pcc.h            |  3 +-
 fs/lustre/llite/statahead.c      | 59 +++++++++++++++++++++++++----
 8 files changed, 152 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index edcc1a7..e8b6fe8 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -270,7 +270,9 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 	if (lookup_flags & LOOKUP_RCU)
 		return -ECHILD;
 
-	ll_statahead(dir, &dentry, !d_inode(dentry));
+	if (dentry_may_statahead(dir, dentry))
+		ll_revalidate_statahead(dir, &dentry, !d_inode(dentry));
+
 	return 1;
 }
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 52f0865..8264b86 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4555,23 +4555,66 @@ static int ll_merge_md_attr(struct inode *inode)
 int ll_getattr(const struct path *path, struct kstat *stat,
 	       u32 request_mask, unsigned int flags)
 {
-	struct inode *inode = d_inode(path->dentry);
+	struct dentry *de = path->dentry;
+	struct inode *inode = d_inode(de);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ll_inode_info *lli = ll_i2info(inode);
+	struct inode *dir = de->d_parent->d_inode;
+	bool need_glimpse = true;
 	ktime_t kstart = ktime_get();
 	int rc;
 
-	rc = ll_inode_revalidate(path->dentry, IT_GETATTR);
+	/* The OST object(s) determine the file size, blocks and mtime. */
+	if (!(request_mask & STATX_SIZE || request_mask & STATX_BLOCKS ||
+	      request_mask & STATX_MTIME))
+		need_glimpse = false;
+
+	if (dentry_may_statahead(dir, de))
+		ll_start_statahead(dir, de, need_glimpse &&
+				   !(flags & AT_STATX_DONT_SYNC));
+
+	if (flags & AT_STATX_DONT_SYNC) {
+		rc = 0;
+		goto fill_attr;
+	}
+
+	rc = ll_inode_revalidate(de, IT_GETATTR);
 	if (rc < 0)
 		return rc;
 
 	if (S_ISREG(inode->i_mode)) {
 		bool cached;
 
-		rc = pcc_inode_getattr(inode, &cached);
+		if (!need_glimpse)
+			goto fill_attr;
+
+		rc = pcc_inode_getattr(inode, request_mask, flags, &cached);
 		if (cached && rc < 0)
 			return rc;
 
+		if (cached)
+			goto fill_attr;
+
+		/*
+		 * If the returned attr is masked with OBD_MD_FLSIZE &
+		 * OBD_MD_FLBLOCKS & OBD_MD_FLMTIME, it means that the file size
+		 * or blocks obtained from MDT is strictly correct, and the file
+		 * is usually not being modified by clients, and the [a|m|c]time
+		 * got from MDT is also strictly correct.
+		 * Under this circumstance, it does not need to send glimpse
+		 * RPCs to OSTs for file attributes such as the size and blocks.
+		 */
+		if (lli->lli_attr_valid & OBD_MD_FLSIZE &&
+		    lli->lli_attr_valid & OBD_MD_FLBLOCKS &&
+		    lli->lli_attr_valid & OBD_MD_FLMTIME) {
+			inode->i_mtime.tv_sec = lli->lli_mtime;
+			if (lli->lli_attr_valid & OBD_MD_FLATIME)
+				inode->i_atime.tv_sec = lli->lli_atime;
+			if (lli->lli_attr_valid & OBD_MD_FLCTIME)
+				inode->i_ctime.tv_sec = lli->lli_ctime;
+			goto fill_attr;
+		}
+
 		/* In case of restore, the MDT has the right size and has
 		 * already send it back without granting the layout lock,
 		 * inode is up-to-date so glimpse is useless.
@@ -4579,8 +4622,7 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 		 * restore the MDT holds the layout lock so the glimpse will
 		 * block up to the end of restore (getattr will block)
 		 */
-		if (!cached && !test_bit(LLIF_FILE_RESTORING,
-					 &lli->lli_flags)) {
+		if (!test_bit(LLIF_FILE_RESTORING, &lli->lli_flags)) {
 			rc = ll_glimpse_size(inode);
 			if (rc < 0)
 				return rc;
@@ -4593,11 +4635,15 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 				return rc;
 		}
 
-		inode->i_atime.tv_sec = lli->lli_atime;
-		inode->i_mtime.tv_sec = lli->lli_mtime;
-		inode->i_ctime.tv_sec = lli->lli_ctime;
+		if (lli->lli_attr_valid & OBD_MD_FLATIME)
+			inode->i_atime.tv_sec = lli->lli_atime;
+		if (lli->lli_attr_valid & OBD_MD_FLMTIME)
+			inode->i_mtime.tv_sec = lli->lli_mtime;
+		if (lli->lli_attr_valid & OBD_MD_FLCTIME)
+			inode->i_ctime.tv_sec = lli->lli_ctime;
 	}
 
+fill_attr:
 	OBD_FAIL_TIMEOUT(OBD_FAIL_GETATTR_DELAY, 30);
 
 	stat->dev = inode->i_sb->s_dev;
@@ -4631,6 +4677,24 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 	stat->size = i_size_read(inode);
 	stat->blocks = inode->i_blocks;
 
+	if (flags & AT_STATX_DONT_SYNC) {
+		if (stat->size == 0 &&
+		    lli->lli_attr_valid & OBD_MD_FLLAZYSIZE)
+			stat->size = lli->lli_lazysize;
+		if (stat->blocks == 0 &&
+		    lli->lli_attr_valid & OBD_MD_FLLAZYBLOCKS)
+			stat->blocks = lli->lli_lazyblocks;
+	}
+
+	if (lli->lli_attr_valid & OBD_MD_FLBTIME) {
+		stat->result_mask |= STATX_BTIME;
+		stat->btime.tv_sec = lli->lli_btime;
+	}
+
+	stat->attributes_mask = STATX_ATTR_IMMUTABLE | STATX_ATTR_APPEND;
+	stat->attributes |= ll_inode_to_ext_flags(inode->i_flags);
+	stat->result_mask &= request_mask;
+
 	ll_stats_ops_tally(sbi, LPROC_LL_GETATTR,
 			   ktime_us_delta(ktime_get(), kstart));
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 2544a40..be3a0b0 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -143,6 +143,7 @@ struct ll_inode_info {
 	s64				lli_atime;
 	s64				lli_mtime;
 	s64				lli_ctime;
+	s64				lli_btime;
 	spinlock_t			lli_agl_lock;
 
 	/* Try to make the d::member and f::member are aligned. Before using
@@ -233,6 +234,10 @@ struct ll_inode_info {
 			struct mutex			lli_group_mutex;
 			u64				lli_group_users;
 			unsigned long			lli_group_gid;
+
+			u64				lli_attr_valid;
+			u64				lli_lazysize;
+			u64				lli_lazyblocks;
 		};
 	};
 
@@ -1349,7 +1354,9 @@ struct ll_statahead_info {
 	atomic_t		sai_cache_count; /* entry count in cache */
 };
 
-int ll_statahead(struct inode *dir, struct dentry **dentry, bool unplug);
+int ll_revalidate_statahead(struct inode *dir, struct dentry **dentry,
+			    bool unplug);
+int ll_start_statahead(struct inode *dir, struct dentry *dentry, bool agl);
 void ll_authorize_statahead(struct inode *dir, void *key);
 void ll_deauthorize_statahead(struct inode *dir, void *key);
 
@@ -1433,7 +1440,8 @@ static inline int ll_glimpse_size(struct inode *inode)
 	 * 'lld_sa_generation == lli->lli_sa_generation'.
 	 */
 	ldd = ll_d2d(dentry);
-	if (ldd->lld_sa_generation == lli->lli_sa_generation)
+	if (lli->lli_sa_generation &&
+	    ldd->lld_sa_generation == lli->lli_sa_generation)
 		return false;
 
 	return true;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index da7604f..70e839b 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2049,6 +2049,9 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 		lli->lli_ctime = body->mbo_ctime;
 	}
 
+	if (body->mbo_valid & OBD_MD_FLBTIME)
+		lli->lli_btime = body->mbo_btime;
+
 	/* Clear i_flags to remove S_NOSEC before permissions are updated */
 	if (body->mbo_valid & OBD_MD_FLFLAGS)
 		ll_update_inode_flags(inode, body->mbo_flags);
@@ -2085,6 +2088,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 
 	LASSERT(fid_seq(&lli->lli_fid) != 0);
 
+	lli->lli_attr_valid = body->mbo_valid;
 	if (body->mbo_valid & OBD_MD_FLSIZE) {
 		i_size_write(inode, body->mbo_size);
 
@@ -2094,6 +2098,11 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 
 		if (body->mbo_valid & OBD_MD_FLBLOCKS)
 			inode->i_blocks = body->mbo_blocks;
+	} else {
+		if (body->mbo_valid & OBD_MD_FLLAZYSIZE)
+			lli->lli_lazysize = body->mbo_size;
+		if (body->mbo_valid & OBD_MD_FLLAZYBLOCKS)
+			lli->lli_lazyblocks = body->mbo_blocks;
 	}
 
 	if (body->mbo_valid & OBD_MD_TSTATE) {
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 16c3bc5..aa2dd13 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -751,7 +751,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		it = &lookup_it;
 
 	if (it->it_op == IT_GETATTR && dentry_may_statahead(parent, dentry)) {
-		rc = ll_statahead(parent, &dentry, 0);
+		rc = ll_revalidate_statahead(parent, &dentry, 0);
 		if (rc == 1) {
 			if (dentry == save)
 				retval = NULL;
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 2adde68..5a4bb33 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1673,7 +1673,8 @@ int pcc_inode_setattr(struct inode *inode, struct iattr *attr,
 	return rc;
 }
 
-int pcc_inode_getattr(struct inode *inode, bool *cached)
+int pcc_inode_getattr(struct inode *inode, u32 request_mask,
+		      unsigned int flags, bool *cached)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	const struct cred *old_cred;
@@ -1694,7 +1695,7 @@ int pcc_inode_getattr(struct inode *inode, bool *cached)
 
 	old_cred = override_creds(pcc_super_cred(inode->i_sb));
 	rc = vfs_getattr(&ll_i2pcci(inode)->pcci_path, &stat,
-			 STATX_BASIC_STATS, AT_STATX_SYNC_AS_STAT);
+			 request_mask, flags);
 	revert_creds(old_cred);
 	if (rc)
 		goto out;
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index 60f9bea..b13f9da8 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -238,7 +238,8 @@ ssize_t pcc_file_read_iter(struct kiocb *iocb, struct iov_iter *iter,
 			   bool *cached);
 ssize_t pcc_file_write_iter(struct kiocb *iocb, struct iov_iter *iter,
 			    bool *cached);
-int pcc_inode_getattr(struct inode *inode, bool *cached);
+int pcc_inode_getattr(struct inode *inode, u32 request_mask,
+		      unsigned int flags, bool *cached);
 int pcc_inode_setattr(struct inode *inode, struct iattr *attr, bool *cached);
 ssize_t pcc_file_splice_read(struct file *in_file, loff_t *ppos,
 			     struct pipe_inode_info *pipe, size_t count,
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 04e013f..fb25520 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -965,10 +965,12 @@ static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 			      plli->lli_opendir_pid);
 	if (IS_ERR(task)) {
 		CERROR("can't start ll_agl thread, rc: %ld\n", PTR_ERR(task));
+		sai->sai_agl_valid = 0;
 		return;
 	}
 
 	sai->sai_agl_task = task;
+	LASSERT(sai->sai_agl_valid == 1);
 	atomic_inc(&ll_i2sbi(d_inode(parent))->ll_agl_total);
 	spin_lock(&plli->lli_agl_lock);
 	sai->sai_agl_valid = 1;
@@ -1521,6 +1523,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
  * @dir:	parent directory
  * @dentry:	dentry that triggers statahead, normally the first
  *		dirent under @dir
+ * @agl		indicate whether AGL is needed
  *
  * Returns:	-EAGAIN on success, because when this function is
  *		called, it's already in lookup call, so client should
@@ -1529,7 +1532,8 @@ static int revalidate_statahead_dentry(struct inode *dir,
  *
  *		negative number upon error
  */
-static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
+static int start_statahead_thread(struct inode *dir, struct dentry *dentry,
+				  bool agl)
 {
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = NULL;
@@ -1562,6 +1566,8 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	}
 
 	sai->sai_ls_all = (first == LS_FIRST_DOT_DE);
+	sai->sai_agl_valid = agl;
+
 	/*
 	 * if current lli_opendir_key was deauthorized, or dir re-opened by
 	 * another process, don't start statahead, otherwise the newly spawned
@@ -1592,7 +1598,7 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 		goto out;
 	}
 
-	if (ll_i2sbi(parent->d_inode)->ll_flags & LL_SBI_AGL_ENABLED)
+	if (ll_i2sbi(parent->d_inode)->ll_flags & LL_SBI_AGL_ENABLED && agl)
 		ll_start_agl(parent, sai);
 
 	atomic_inc(&ll_i2sbi(parent->d_inode)->ll_sa_total);
@@ -1615,6 +1621,7 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	if (lli->lli_opendir_pid == current->pid)
 		lli->lli_sa_enabled = 0;
 	spin_unlock(&lli->lli_sa_lock);
+
 	if (sai)
 		ll_sai_free(sai);
 	if (first != LS_NOT_FIRST_DE)
@@ -1623,11 +1630,50 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	return rc;
 }
 
+/*
+ * Check whether statahead for @dir was started.
+ */
+static inline bool ll_statahead_started(struct inode *dir, bool agl)
+{
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct ll_statahead_info *sai;
+
+	spin_lock(&lli->lli_sa_lock);
+	sai = lli->lli_sai;
+	if (sai && sai->sai_agl_valid != agl)
+		CDEBUG(D_READA,
+		       "%s: Statahead AGL hint changed from %d to %d\n",
+		       ll_i2sbi(dir)->ll_fsname, sai->sai_agl_valid, agl);
+	spin_unlock(&lli->lli_sa_lock);
+
+	return !!sai;
+}
+
 /**
  * statahead entry function, this is called when client getattr on a file, it
  * will start statahead thread if this is the first dir entry, else revalidate
  * dentry from statahead cache.
  *
+ * @dir		parent directory
+ * @dentryp	dentry to getattr
+ * @agl		whether start the agl thread
+ *
+ * Return:	1 on success
+ *		0 revalidation from statahead cache failed, caller needs
+ *		to getattr from server directly
+ *		negative number on error, caller often ignores this and
+ *		then getattr from server
+ */
+int ll_start_statahead(struct inode *dir, struct dentry *dentry, bool agl)
+{
+	if (!ll_statahead_started(dir, agl))
+		return start_statahead_thread(dir, dentry, agl);
+	return 0;
+}
+
+/**
+ * revalidate dentry from statahead cache.
+ *
  * @dir:	parent directory
  * @dentryp:	dentry to getattr
  * @unplug:	unplug statahead window only (normally for negative
@@ -1638,19 +1684,18 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
  *		negative number on error, caller often ignores this and
  *		then getattr from server
  */
-int ll_statahead(struct inode *dir, struct dentry **dentryp, bool unplug)
+int ll_revalidate_statahead(struct inode *dir, struct dentry **dentryp,
+			    bool unplug)
 {
 	struct ll_statahead_info *sai;
+	int rc = 0;
 
 	sai = ll_sai_get(dir);
 	if (sai) {
-		int rc;
-
 		rc = revalidate_statahead_dentry(dir, sai, dentryp, unplug);
 		CDEBUG(D_READA, "revalidate statahead %pd: %d.\n",
 		       *dentryp, rc);
 		ll_sai_put(sai);
-		return rc;
 	}
-	return start_statahead_thread(dir, *dentryp);
+	return rc;
 }
-- 
1.8.3.1
