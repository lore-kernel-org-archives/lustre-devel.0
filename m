From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:28 -0500
Subject: [lustre-devel] [PATCH 520/622] lustre: llite: report latency for
 filesystem ops
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-521-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Add the elapsed time of VFS operations to the llite stats
counter, instead of just tracking the number of operations,
to allow tracking of operation round-trip latency.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12631
Lustre-commit: ea58c4cfb0fc ("LU-12631 llite: report latency for filesystem ops")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36078
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h |  4 +-
 fs/lustre/llite/dir.c              |  4 +-
 fs/lustre/llite/file.c             | 69 ++++++++++++++++++++++++---------
 fs/lustre/llite/llite_internal.h   |  7 ++--
 fs/lustre/llite/llite_lib.c        | 15 ++++++--
 fs/lustre/llite/llite_mmap.c       | 36 ++++++++++++------
 fs/lustre/llite/lproc_llite.c      | 78 ++++++++++++++++++++------------------
 fs/lustre/llite/namei.c            | 39 ++++++++++++++-----
 fs/lustre/llite/pcc.c              |  4 +-
 fs/lustre/llite/pcc.h              |  4 +-
 fs/lustre/llite/super25.c          |  1 -
 fs/lustre/llite/xattr.c            | 49 ++++++++++++++----------
 12 files changed, 199 insertions(+), 111 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index fdc1b19..ac62560 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -138,10 +138,10 @@ enum {
 	LPROCFS_CNTR_STDDEV		= 0x0004,
 
 	/* counter data type */
-	LPROCFS_TYPE_REGS		= 0x0100,
+	LPROCFS_TYPE_REQS		= 0x0100,
 	LPROCFS_TYPE_BYTES		= 0x0200,
 	LPROCFS_TYPE_PAGES		= 0x0400,
-	LPROCFS_TYPE_CYCLE		= 0x0800,
+	LPROCFS_TYPE_USEC		= 0x0800,
 };
 
 #define LC_MIN_INIT ((~(u64)0) >> 1)
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 4dccd24..c38862e 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -298,6 +298,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	bool api32 = ll_need_32bit_api(sbi);
 	struct md_op_data *op_data;
 	struct lu_fid pfid = { 0 };
+	ktime_t kstart = ktime_get();
 	int rc;
 
 	CDEBUG(D_VFSTRACE,
@@ -374,7 +375,8 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	ll_finish_md_op_data(op_data);
 out:
 	if (!rc)
-		ll_stats_ops_tally(sbi, LPROC_LL_READDIR, 1);
+		ll_stats_ops_tally(sbi, LPROC_LL_READDIR,
+				   ktime_us_delta(ktime_get(), kstart));
 
 	return rc;
 }
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 31d7dce..92eead1 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -383,13 +383,12 @@ int ll_file_release(struct inode *inode, struct file *file)
 	struct ll_file_data *fd;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ll_inode_info *lli = ll_i2info(inode);
+	ktime_t kstart = ktime_get();
 	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
-	if (!is_root_inode(inode))
-		ll_stats_ops_tally(sbi, LPROC_LL_RELEASE, 1);
 	fd = LUSTRE_FPRIVATE(file);
 	LASSERT(fd);
 
@@ -402,7 +401,8 @@ int ll_file_release(struct inode *inode, struct file *file)
 	if (is_root_inode(inode)) {
 		LUSTRE_FPRIVATE(file) = NULL;
 		ll_file_data_put(fd);
-		return 0;
+		rc = 0;
+		goto out;
 	}
 
 	pcc_file_release(inode, file);
@@ -418,6 +418,10 @@ int ll_file_release(struct inode *inode, struct file *file)
 	if (CFS_FAIL_TIMEOUT_MS(OBD_FAIL_PTLRPC_DUMP_LOG, cfs_fail_val))
 		libcfs_debug_dumplog();
 
+out:
+	if (!rc && inode->i_sb->s_root != file_dentry(file))
+		ll_stats_ops_tally(sbi, LPROC_LL_RELEASE,
+				   ktime_us_delta(ktime_get(), kstart));
 	return rc;
 }
 
@@ -699,6 +703,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	struct obd_client_handle **och_p = NULL;
 	u64 *och_usecount = NULL;
 	struct ll_file_data *fd;
+	ktime_t kstart = ktime_get();
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), flags %o\n",
@@ -896,7 +901,8 @@ int ll_file_open(struct inode *inode, struct file *file)
 		if (fd)
 			ll_file_data_put(fd);
 	} else {
-		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_OPEN, 1);
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_OPEN,
+				   ktime_us_delta(ktime_get(), kstart));
 	}
 
 out_nofiledata:
@@ -1676,6 +1682,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	ssize_t result;
 	u16 refcheck;
 	ssize_t rc2;
+	ktime_t kstart = ktime_get();
 	bool cached;
 
 	if (!iov_iter_count(to))
@@ -1694,7 +1701,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	 */
 	result = pcc_file_read_iter(iocb, to, &cached);
 	if (cached)
-		return result;
+		goto out;
 
 	ll_ras_enter(file);
 
@@ -1719,10 +1726,13 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 
 	cl_env_put(env, &refcheck);
 out:
-	if (result > 0)
+	if (result > 0) {
 		ll_rw_stats_tally(ll_i2sbi(file_inode(file)), current->pid,
 				  LUSTRE_FPRIVATE(file), iocb->ki_pos, result,
 				  READ);
+		ll_stats_ops_tally(ll_i2sbi(file_inode(file)), LPROC_LL_READ,
+				   ktime_us_delta(ktime_get(), kstart));
+	}
 
 	return result;
 }
@@ -1795,6 +1805,7 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	struct file *file = iocb->ki_filp;
 	u16 refcheck;
 	bool cached;
+	ktime_t kstart = ktime_get();
 	int result;
 
 	if (!iov_iter_count(from)) {
@@ -1813,8 +1824,10 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	 * from PCC cache automatically.
 	 */
 	result = pcc_file_write_iter(iocb, from, &cached);
-	if (cached && result != -ENOSPC && result != -EDQUOT)
-		return result;
+	if (cached && result != -ENOSPC && result != -EDQUOT) {
+		rc_normal = result;
+		goto out;
+	}
 
 	/* NB: we can't do direct IO for tiny writes because they use the page
 	 * cache, we can't do sync writes because tiny writes can't flush
@@ -1855,10 +1868,14 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 
 	cl_env_put(env, &refcheck);
 out:
-	if (rc_normal > 0)
+	if (rc_normal > 0) {
 		ll_rw_stats_tally(ll_i2sbi(file_inode(file)), current->pid,
 				  LUSTRE_FPRIVATE(file), iocb->ki_pos,
 				  rc_normal, WRITE);
+		ll_stats_ops_tally(ll_i2sbi(file_inode(file)), LPROC_LL_WRITE,
+				   ktime_us_delta(ktime_get(), kstart));
+	}
+
 	return rc_normal;
 }
 
@@ -3850,12 +3867,12 @@ static loff_t ll_file_seek(struct file *file, loff_t offset, int origin)
 {
 	struct inode *inode = file_inode(file);
 	loff_t retval, eof = 0;
+	ktime_t kstart = ktime_get();
 
 	retval = offset + ((origin == SEEK_END) ? i_size_read(inode) :
 			   (origin == SEEK_CUR) ? file->f_pos : 0);
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), to=%llu=%#llx(%d)\n",
 	       PFID(ll_inode2fid(inode)), inode, retval, retval, origin);
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LLSEEK, 1);
 
 	if (origin == SEEK_END || origin == SEEK_HOLE || origin == SEEK_DATA) {
 		retval = ll_glimpse_size(inode);
@@ -3864,8 +3881,12 @@ static loff_t ll_file_seek(struct file *file, loff_t offset, int origin)
 		eof = i_size_read(inode);
 	}
 
-	return generic_file_llseek_size(file, offset, origin,
-					ll_file_maxbytes(inode), eof);
+	retval = generic_file_llseek_size(file, offset, origin,
+					  ll_file_maxbytes(inode), eof);
+	if (retval >= 0)
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LLSEEK,
+				   ktime_us_delta(ktime_get(), kstart));
+	return retval;
 }
 
 static int ll_flush(struct file *file, fl_owner_t id)
@@ -3948,14 +3969,13 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct inode *inode = file_inode(file);
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ptlrpc_request *req;
+	ktime_t kstart = ktime_get();
 	int rc, err;
 
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op:inode=" DFID "(%p), start %lld, end %lld, datasync %d\n",
 	       PFID(ll_inode2fid(inode)), inode, start, end, datasync);
 
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FSYNC, 1);
-
 
 	rc = file_write_and_wait_range(file, start, end);
 	inode_lock(inode);
@@ -4002,6 +4022,10 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	}
 
 	inode_unlock(inode);
+
+	if (!rc)
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FSYNC,
+				   ktime_us_delta(ktime_get(), kstart));
 	return rc;
 }
 
@@ -4019,6 +4043,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct lustre_handle lockh = {0};
 	union ldlm_policy_data flock = { { 0 } };
 	int fl_type = file_lock->fl_type;
+	ktime_t kstart = ktime_get();
 	u64 flags = 0;
 	int rc;
 	int rc2 = 0;
@@ -4026,7 +4051,6 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID " file_lock=%p\n",
 	       PFID(ll_inode2fid(inode)), file_lock);
 
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FLOCK, 1);
 
 	if (file_lock->fl_flags & FL_FLOCK)
 		LASSERT((cmd == F_SETLKW) || (cmd == F_SETLK));
@@ -4122,6 +4146,9 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 	ll_finish_md_op_data(op_data);
 
+	if (!rc)
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FLOCK,
+				   ktime_us_delta(ktime_get(), kstart));
 	return rc;
 }
 
@@ -4515,10 +4542,9 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 	struct inode *inode = d_inode(path->dentry);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ll_inode_info *lli = ll_i2info(inode);
+	ktime_t kstart = ktime_get();
 	int rc;
 
-	ll_stats_ops_tally(sbi, LPROC_LL_GETATTR, 1);
-
 	rc = ll_inode_revalidate(path->dentry, IT_GETATTR);
 	if (rc < 0)
 		return rc;
@@ -4582,6 +4608,9 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 	stat->size = i_size_read(inode);
 	stat->blocks = inode->i_blocks;
 
+	ll_stats_ops_tally(sbi, LPROC_LL_GETATTR,
+			   ktime_us_delta(ktime_get(), kstart));
+
 	return 0;
 }
 
@@ -4634,6 +4663,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 	const struct cred *old_cred = NULL;
 	struct cred *cred = NULL;
 	bool squash_id = false;
+	ktime_t kstart = ktime_get();
 	int rc = 0;
 
 	if (mask & MAY_NOT_BLOCK)
@@ -4682,7 +4712,6 @@ int ll_inode_permission(struct inode *inode, int mask)
 		old_cred = override_creds(cred);
 	}
 
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_INODE_PERM, 1);
 	rc = generic_permission(inode, mask);
 
 	/* restore current process's credentials and FS capability */
@@ -4691,6 +4720,10 @@ int ll_inode_permission(struct inode *inode, int mask)
 		put_cred(cred);
 	}
 
+	if (!rc)
+		ll_stats_ops_tally(sbi, LPROC_LL_INODE_PERM,
+				   ktime_us_delta(ktime_get(), kstart));
+
 	return rc;
 }
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index d84f50c..205ea50 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -775,7 +775,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 /* llite/lproc_llite.c */
 int ll_debugfs_register_super(struct super_block *sb, const char *name);
 void ll_debugfs_unregister_super(struct super_block *sb);
-void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count);
+void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, long count);
 void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		       struct ll_file_data *file, loff_t pos,
 		       size_t count, int rw);
@@ -783,10 +783,12 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 enum {
 	LPROC_LL_READ_BYTES,
 	LPROC_LL_WRITE_BYTES,
+	LPROC_LL_READ,
+	LPROC_LL_WRITE,
 	LPROC_LL_IOCTL,
 	LPROC_LL_OPEN,
 	LPROC_LL_RELEASE,
-	LPROC_LL_MAP,
+	LPROC_LL_MMAP,
 	LPROC_LL_FAULT,
 	LPROC_LL_MKWRITE,
 	LPROC_LL_LLSEEK,
@@ -805,7 +807,6 @@ enum {
 	LPROC_LL_MKNOD,
 	LPROC_LL_RENAME,
 	LPROC_LL_STATFS,
-	LPROC_LL_ALLOC_INODE,
 	LPROC_LL_SETXATTR,
 	LPROC_LL_GETXATTR,
 	LPROC_LL_GETXATTR_HITS,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 49490ee..84472fb 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1644,6 +1644,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 	struct inode *inode = d_inode(dentry);
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct md_op_data *op_data = NULL;
+	ktime_t kstart = ktime_get();
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "%s: setattr inode " DFID "(%p) from %llu to %llu, valid %x, hsm_import %d\n",
@@ -1820,8 +1821,10 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		inode_has_no_xattr(inode);
 	}
 
-	ll_stats_ops_tally(ll_i2sbi(inode), (attr->ia_valid & ATTR_SIZE) ?
-			LPROC_LL_TRUNC : LPROC_LL_SETATTR, 1);
+	if (!rc)
+		ll_stats_ops_tally(ll_i2sbi(inode), attr->ia_valid & ATTR_SIZE ?
+					LPROC_LL_TRUNC : LPROC_LL_SETATTR,
+				   ktime_us_delta(ktime_get(), kstart));
 
 	return rc;
 }
@@ -1918,10 +1921,10 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 	struct super_block *sb = de->d_sb;
 	struct obd_statfs osfs;
 	u64 fsid = huge_encode_dev(sb->s_dev);
+	ktime_t kstart = ktime_get();
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op: at %llu jiffies\n", get_jiffies_64());
-	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_STATFS, 1);
+	CDEBUG(D_VFSTRACE, "VFS Op:sb=%s (%p)\n", sb->s_id, sb);
 
 	/* Some amount of caching on the client is allowed */
 	rc = ll_statfs_internal(ll_s2sbi(sb), &osfs, OBD_STATFS_SUM);
@@ -1950,6 +1953,10 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 	sfs->f_bavail = osfs.os_bavail;
 	sfs->f_fsid.val[0] = (u32)fsid;
 	sfs->f_fsid.val[1] = (u32)(fsid >> 32);
+
+	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_STATFS,
+			   ktime_us_delta(ktime_get(), kstart));
+
 	return 0;
 }
 
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 5c13164..b955756e 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -363,13 +363,11 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	bool cached;
 	vm_fault_t result;
 	sigset_t old, new;
-
-	ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
-			   LPROC_LL_FAULT, 1);
+	ktime_t kstart = ktime_get();
 
 	result = pcc_fault(vma, vmf, &cached);
 	if (cached)
-		return result;
+		goto out;
 
 	/* Only SIGKILL and SIGTERM are allowed for fault/nopage/mkwrite
 	 * so that it can be killed by admin but not cause segfault by
@@ -407,11 +405,17 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	}
 	sigprocmask(SIG_SETMASK, &old, NULL);
 
-	if (vmf->page && result == VM_FAULT_LOCKED)
+out:
+	if (vmf->page && result == VM_FAULT_LOCKED) {
 		ll_rw_stats_tally(ll_i2sbi(file_inode(vma->vm_file)),
 				  current->pid, LUSTRE_FPRIVATE(vma->vm_file),
 				  cl_offset(NULL, vmf->page->index), PAGE_SIZE,
 				  READ);
+		ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
+				   LPROC_LL_FAULT,
+				   ktime_us_delta(ktime_get(), kstart));
+	}
+
 	return result;
 }
 
@@ -424,13 +428,11 @@ static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 	bool cached;
 	int err;
 	vm_fault_t ret;
+	ktime_t kstart = ktime_get();
 
-	ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
-			   LPROC_LL_MKWRITE, 1);
-
-	err = pcc_page_mkwrite(vma, vmf, &cached);
+	ret = pcc_page_mkwrite(vma, vmf, &cached);
 	if (cached)
-		return err;
+		goto out;
 
 	file_update_time(vma->vm_file);
 	do {
@@ -465,11 +467,17 @@ static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 		break;
 	}
 
-	if (ret == VM_FAULT_LOCKED)
+out:
+	if (ret == VM_FAULT_LOCKED) {
 		ll_rw_stats_tally(ll_i2sbi(file_inode(vma->vm_file)),
 				  current->pid, LUSTRE_FPRIVATE(vma->vm_file),
 				  cl_offset(NULL, vmf->page->index), PAGE_SIZE,
 				  WRITE);
+		ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
+				   LPROC_LL_MKWRITE,
+				   ktime_us_delta(ktime_get(), kstart));
+	}
+
 	return ret;
 }
 
@@ -527,6 +535,7 @@ int ll_teardown_mmaps(struct address_space *mapping, u64 first, u64 last)
 int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file_inode(file);
+	ktime_t kstart = ktime_get();
 	bool cached;
 	int rc;
 
@@ -537,7 +546,6 @@ int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
 	if (cached && rc != 0)
 		return rc;
 
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_MAP, 1);
 	rc = generic_file_mmap(file, vma);
 	if (rc == 0) {
 		vma->vm_ops = &ll_file_vm_ops;
@@ -547,5 +555,9 @@ int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
 			rc = ll_glimpse_size(inode);
 	}
 
+	if (!rc)
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_MMAP,
+				   ktime_us_delta(ktime_get(), kstart));
+
 	return rc;
 }
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 439c096..82c5e5c 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1541,54 +1541,58 @@ static void sbi_kobj_release(struct kobject *kobj)
 	.release	= sbi_kobj_release,
 };
 
+#define LPROCFS_TYPE_LATENCY \
+	(LPROCFS_TYPE_USEC | LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV)
 static const struct llite_file_opcode {
 	u32		opcode;
 	u32		type;
 	const char	*opname;
 } llite_opcode_table[LPROC_LL_FILE_OPCODES] = {
 	/* file operation */
-	{ LPROC_LL_READ_BYTES,     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
-				   "read_bytes" },
-	{ LPROC_LL_WRITE_BYTES,    LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
-				   "write_bytes" },
-	{ LPROC_LL_IOCTL,	   LPROCFS_TYPE_REGS, "ioctl" },
-	{ LPROC_LL_OPEN,	   LPROCFS_TYPE_REGS, "open" },
-	{ LPROC_LL_RELEASE,	   LPROCFS_TYPE_REGS, "close" },
-	{ LPROC_LL_MAP,		   LPROCFS_TYPE_REGS, "mmap" },
-	{ LPROC_LL_FAULT,	   LPROCFS_TYPE_REGS, "page_fault" },
-	{ LPROC_LL_MKWRITE,	   LPROCFS_TYPE_REGS, "page_mkwrite" },
-	{ LPROC_LL_LLSEEK,	   LPROCFS_TYPE_REGS, "seek" },
-	{ LPROC_LL_FSYNC,	   LPROCFS_TYPE_REGS, "fsync" },
-	{ LPROC_LL_READDIR,	   LPROCFS_TYPE_REGS, "readdir" },
+	{ LPROC_LL_READ_BYTES,	LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
+		"read_bytes" },
+	{ LPROC_LL_WRITE_BYTES,	LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
+		"write_bytes" },
+	{ LPROC_LL_READ,	LPROCFS_TYPE_LATENCY,	"read" },
+	{ LPROC_LL_WRITE,	LPROCFS_TYPE_LATENCY,	"write" },
+	{ LPROC_LL_IOCTL,	LPROCFS_TYPE_REQS,	"ioctl" },
+	{ LPROC_LL_OPEN,	LPROCFS_TYPE_LATENCY,	"open" },
+	{ LPROC_LL_RELEASE,	LPROCFS_TYPE_LATENCY,	"close" },
+	{ LPROC_LL_MMAP,	LPROCFS_TYPE_LATENCY,	"mmap" },
+	{ LPROC_LL_FAULT,	LPROCFS_TYPE_LATENCY,	"page_fault" },
+	{ LPROC_LL_MKWRITE,	LPROCFS_TYPE_LATENCY,	"page_mkwrite" },
+	{ LPROC_LL_LLSEEK,	LPROCFS_TYPE_LATENCY,	"seek" },
+	{ LPROC_LL_FSYNC,	LPROCFS_TYPE_LATENCY,	"fsync" },
+	{ LPROC_LL_READDIR,	LPROCFS_TYPE_LATENCY,	"readdir" },
 	/* inode operation */
-	{ LPROC_LL_SETATTR,	   LPROCFS_TYPE_REGS, "setattr" },
-	{ LPROC_LL_TRUNC,	   LPROCFS_TYPE_REGS, "truncate" },
-	{ LPROC_LL_FLOCK,	   LPROCFS_TYPE_REGS, "flock" },
-	{ LPROC_LL_GETATTR,	   LPROCFS_TYPE_REGS, "getattr" },
+	{ LPROC_LL_SETATTR,	LPROCFS_TYPE_LATENCY,	"setattr" },
+	{ LPROC_LL_TRUNC,	LPROCFS_TYPE_LATENCY,	"truncate" },
+	{ LPROC_LL_FLOCK,	LPROCFS_TYPE_LATENCY,	"flock" },
+	{ LPROC_LL_GETATTR,	LPROCFS_TYPE_LATENCY,	"getattr" },
 	/* dir inode operation */
-	{ LPROC_LL_CREATE,	   LPROCFS_TYPE_REGS, "create" },
-	{ LPROC_LL_LINK,	   LPROCFS_TYPE_REGS, "link" },
-	{ LPROC_LL_UNLINK,	   LPROCFS_TYPE_REGS, "unlink" },
-	{ LPROC_LL_SYMLINK,	   LPROCFS_TYPE_REGS, "symlink" },
-	{ LPROC_LL_MKDIR,	   LPROCFS_TYPE_REGS, "mkdir" },
-	{ LPROC_LL_RMDIR,	   LPROCFS_TYPE_REGS, "rmdir" },
-	{ LPROC_LL_MKNOD,	   LPROCFS_TYPE_REGS, "mknod" },
-	{ LPROC_LL_RENAME,	   LPROCFS_TYPE_REGS, "rename" },
+	{ LPROC_LL_CREATE,	LPROCFS_TYPE_LATENCY,	"create" },
+	{ LPROC_LL_LINK,	LPROCFS_TYPE_LATENCY,	"link" },
+	{ LPROC_LL_UNLINK,	LPROCFS_TYPE_LATENCY,	"unlink" },
+	{ LPROC_LL_SYMLINK,	LPROCFS_TYPE_LATENCY,	"symlink" },
+	{ LPROC_LL_MKDIR,	LPROCFS_TYPE_LATENCY,	"mkdir" },
+	{ LPROC_LL_RMDIR,	LPROCFS_TYPE_LATENCY,	"rmdir" },
+	{ LPROC_LL_MKNOD,	LPROCFS_TYPE_LATENCY,	"mknod" },
+	{ LPROC_LL_RENAME,	LPROCFS_TYPE_LATENCY,	"rename" },
 	/* special inode operation */
-	{ LPROC_LL_STATFS,	   LPROCFS_TYPE_REGS, "statfs" },
-	{ LPROC_LL_ALLOC_INODE,    LPROCFS_TYPE_REGS, "alloc_inode" },
-	{ LPROC_LL_SETXATTR,       LPROCFS_TYPE_REGS, "setxattr" },
-	{ LPROC_LL_GETXATTR,       LPROCFS_TYPE_REGS, "getxattr" },
-	{ LPROC_LL_GETXATTR_HITS,  LPROCFS_TYPE_REGS, "getxattr_hits" },
-	{ LPROC_LL_LISTXATTR,      LPROCFS_TYPE_REGS, "listxattr" },
-	{ LPROC_LL_REMOVEXATTR,    LPROCFS_TYPE_REGS, "removexattr" },
-	{ LPROC_LL_INODE_PERM,     LPROCFS_TYPE_REGS, "inode_permission" },
+	{ LPROC_LL_STATFS,	LPROCFS_TYPE_LATENCY,	"statfs" },
+	{ LPROC_LL_SETXATTR,	LPROCFS_TYPE_LATENCY,	"setxattr" },
+	{ LPROC_LL_GETXATTR,	LPROCFS_TYPE_LATENCY,	"getxattr" },
+	{ LPROC_LL_GETXATTR_HITS, LPROCFS_TYPE_REQS,	"getxattr_hits" },
+	{ LPROC_LL_LISTXATTR,	LPROCFS_TYPE_LATENCY,	"listxattr" },
+	{ LPROC_LL_REMOVEXATTR,	LPROCFS_TYPE_LATENCY,	"removexattr" },
+	{ LPROC_LL_INODE_PERM,	LPROCFS_TYPE_LATENCY,	"inode_permission" },
 };
 
-void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, int count)
+void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, long count)
 {
 	if (!sbi->ll_stats)
 		return;
+
 	if (sbi->ll_stats_track_type == STATS_TRACK_ALL)
 		lprocfs_counter_add(sbi->ll_stats, op, count);
 	else if (sbi->ll_stats_track_type == STATS_TRACK_PID &&
@@ -1661,12 +1665,14 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 		u32 type = llite_opcode_table[id].type;
 		void *ptr = NULL;
 
-		if (type & LPROCFS_TYPE_REGS)
-			ptr = "regs";
+		if (type & LPROCFS_TYPE_REQS)
+			ptr = "reqs";
 		else if (type & LPROCFS_TYPE_BYTES)
 			ptr = "bytes";
 		else if (type & LPROCFS_TYPE_PAGES)
 			ptr = "pages";
+		else if (type & LPROCFS_TYPE_USEC)
+			ptr = "usec";
 		lprocfs_counter_init(sbi->ll_stats,
 				     llite_opcode_table[id].opcode,
 				     (type & LPROCFS_CNTR_AVGMINMAX),
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index f4ca16e..5b9f3a7 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1322,6 +1322,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 static int ll_mknod(struct inode *dir, struct dentry *dchild,
 		    umode_t mode, dev_t rdev)
 {
+	ktime_t kstart = ktime_get();
 	int err;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p) mode %o dev %x\n",
@@ -1353,7 +1354,8 @@ static int ll_mknod(struct inode *dir, struct dentry *dchild,
 	}
 
 	if (!err)
-		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_MKNOD, 1);
+		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_MKNOD,
+				   ktime_us_delta(ktime_get(), kstart));
 
 	return err;
 }
@@ -1364,6 +1366,7 @@ static int ll_mknod(struct inode *dir, struct dentry *dchild,
 static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 			umode_t mode, bool want_excl)
 {
+	ktime_t kstart = ktime_get();
 	int rc;
 
 	CDEBUG(D_VFSTRACE,
@@ -1372,11 +1375,13 @@ static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 
 	rc = ll_mknod(dir, dentry, mode, 0);
 
-	ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_CREATE, 1);
-
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, unhashed %d\n",
 	       dentry, d_unhashed(dentry));
 
+	if (!rc)
+		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_CREATE,
+				   ktime_us_delta(ktime_get(), kstart));
+
 	return rc;
 }
 
@@ -1385,6 +1390,7 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
 	struct mdt_body *body;
+	ktime_t kstart = ktime_get();
 	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p)\n",
@@ -1414,7 +1420,8 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 		set_nlink(dchild->d_inode, body->mbo_nlink);
 
 	ll_update_times(request, dir);
-	ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_UNLINK, 1);
+	ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_UNLINK,
+				   ktime_us_delta(ktime_get(), kstart));
 
  out:
 	ptlrpc_req_finished(request);
@@ -1423,6 +1430,7 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 
 static int ll_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
+	ktime_t kstart = ktime_get();
 	int err;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir" DFID "(%p)\n",
@@ -1434,13 +1442,15 @@ static int ll_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 
 	err = ll_new_node(dir, dentry, NULL, mode, 0, LUSTRE_OPC_MKDIR);
 	if (!err)
-		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_MKDIR, 1);
+		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_MKDIR,
+				   ktime_us_delta(ktime_get(), kstart));
 
 	return err;
 }
 
 static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 {
+	ktime_t kstart = ktime_get();
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
 	int rc;
@@ -1463,7 +1473,8 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	ll_finish_md_op_data(op_data);
 	if (rc == 0) {
 		ll_update_times(request, dir);
-		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_RMDIR, 1);
+		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_RMDIR,
+				   ktime_us_delta(ktime_get(), kstart));
 	}
 
 	ptlrpc_req_finished(request);
@@ -1473,6 +1484,7 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 static int ll_symlink(struct inode *dir, struct dentry *dentry,
 		      const char *oldname)
 {
+	ktime_t kstart = ktime_get();
 	int err;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p),target=%.*s\n",
@@ -1482,7 +1494,8 @@ static int ll_symlink(struct inode *dir, struct dentry *dentry,
 			  0, LUSTRE_OPC_SYMLINK);
 
 	if (!err)
-		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_SYMLINK, 1);
+		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_SYMLINK,
+				   ktime_us_delta(ktime_get(), kstart));
 
 	return err;
 }
@@ -1494,6 +1507,7 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 	struct ll_sb_info *sbi = ll_i2sbi(dir);
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
+	ktime_t kstart = ktime_get();
 	int err;
 
 	CDEBUG(D_VFSTRACE,
@@ -1513,7 +1527,8 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 		goto out;
 
 	ll_update_times(request, dir);
-	ll_stats_ops_tally(sbi, LPROC_LL_LINK, 1);
+	ll_stats_ops_tally(sbi, LPROC_LL_LINK,
+			   ktime_us_delta(ktime_get(), kstart));
 out:
 	ptlrpc_req_finished(request);
 	return err;
@@ -1526,6 +1541,7 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	struct ptlrpc_request *request = NULL;
 	struct ll_sb_info *sbi = ll_i2sbi(src);
 	struct md_op_data *op_data;
+	ktime_t kstart = ktime_get();
 	int err;
 
 	if (flags)
@@ -1555,12 +1571,15 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	if (!err) {
 		ll_update_times(request, src);
 		ll_update_times(request, tgt);
-		ll_stats_ops_tally(sbi, LPROC_LL_RENAME, 1);
 	}
 
 	ptlrpc_req_finished(request);
-	if (!err)
+	if (!err) {
 		d_move(src_dchild, tgt_dchild);
+		ll_stats_ops_tally(sbi, LPROC_LL_RENAME,
+				   ktime_us_delta(ktime_get(), kstart));
+	}
+
 	return err;
 }
 
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index b926f87..a40f242 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1754,8 +1754,8 @@ void pcc_vm_close(struct vm_area_struct *vma)
 	pcc_inode_unlock(inode);
 }
 
-int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
-		     bool *cached)
+vm_fault_t pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
+			    bool *cached)
 {
 	struct page *page = vmf->page;
 	struct mm_struct *mm = vma->vm_mm;
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index a221ef6..ec2e421 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -239,8 +239,8 @@ int pcc_fsync(struct file *file, loff_t start, loff_t end,
 void pcc_vm_open(struct vm_area_struct *vma);
 void pcc_vm_close(struct vm_area_struct *vma);
 int pcc_fault(struct vm_area_struct *mva, struct vm_fault *vmf, bool *cached);
-int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
-		     bool *cached);
+vm_fault_t pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
+			    bool *cached);
 int pcc_inode_create(struct super_block *sb, struct pcc_dataset *dataset,
 		     struct lu_fid *fid, struct dentry **pcc_dentry);
 int pcc_inode_create_fini(struct inode *inode, struct pcc_create_attach *pca);
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index 38d60b0..006be6b 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -50,7 +50,6 @@ static struct inode *ll_alloc_inode(struct super_block *sb)
 {
 	struct ll_inode_info *lli;
 
-	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_ALLOC_INODE, 1);
 	lli = kmem_cache_zalloc(ll_inode_cachep, GFP_NOFS);
 	if (!lli)
 		return NULL;
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 4e1ce34..7134f10 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -91,6 +91,7 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	struct ptlrpc_request *req = NULL;
 	const char *pv = value;
 	char *fullname;
+	ktime_t kstart = ktime_get();
 	u64 valid;
 	int rc;
 
@@ -98,13 +99,10 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	 * unconditionally replaced by "". When removexattr() is
 	 * called we get a NULL value and XATTR_REPLACE for flags.
 	 */
-	if (!value && flags == XATTR_REPLACE) {
-		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_REMOVEXATTR, 1);
+	if (!value && flags == XATTR_REPLACE)
 		valid = OBD_MD_FLXATTRRM;
-	} else {
-		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_SETXATTR, 1);
+	else
 		valid = OBD_MD_FLXATTR;
-	}
 
 	rc = xattr_type_filter(sbi, handler);
 	if (rc)
@@ -153,6 +151,11 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	}
 
 	ptlrpc_req_finished(req);
+
+	ll_stats_ops_tally(ll_i2sbi(inode), valid == OBD_MD_FLXATTRRM ?
+				LPROC_LL_REMOVEXATTR : LPROC_LL_SETXATTR,
+			   ktime_us_delta(ktime_get(), kstart));
+
 	return 0;
 }
 
@@ -294,6 +297,11 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 			const char *name, const void *value, size_t size,
 			int flags)
 {
+	ktime_t kstart = ktime_get();
+	int op_type = flags == XATTR_REPLACE ? LPROC_LL_REMOVEXATTR :
+					       LPROC_LL_SETXATTR;
+	int rc;
+
 	LASSERT(inode);
 	LASSERT(name);
 
@@ -302,18 +310,14 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 
 	/* lustre/trusted.lov.xxx would be passed through xattr API */
 	if (!strcmp(name, "lov")) {
-		int op_type = flags == XATTR_REPLACE ? LPROC_LL_REMOVEXATTR :
-						       LPROC_LL_SETXATTR;
-
-		ll_stats_ops_tally(ll_i2sbi(inode), op_type, 1);
-
-		return ll_setstripe_ea(dentry, (struct lov_user_md *)value,
+		rc = ll_setstripe_ea(dentry, (struct lov_user_md *)value,
 				       size);
+		ll_stats_ops_tally(ll_i2sbi(inode), op_type,
+				   ktime_us_delta(ktime_get(), kstart));
+		return rc;
 	} else if (!strcmp(name, "lma") || !strcmp(name, "link")) {
-		int op_type = flags == XATTR_REPLACE ? LPROC_LL_REMOVEXATTR :
-						       LPROC_LL_SETXATTR;
-
-		ll_stats_ops_tally(ll_i2sbi(inode), op_type, 1);
+		ll_stats_ops_tally(ll_i2sbi(inode), op_type,
+				   ktime_us_delta(ktime_get(), kstart));
 		return 0;
 	}
 
@@ -402,14 +406,13 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 			       const char *name, void *buffer, size_t size)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	ktime_t kstart = ktime_get();
 	char *fullname;
 	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR, 1);
-
 	rc = xattr_type_filter(sbi, handler);
 	if (rc)
 		return rc;
@@ -444,6 +447,9 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	rc = ll_xattr_list(inode, fullname, handler->flags, buffer, size,
 			   OBD_MD_FLXATTR);
 	kfree(fullname);
+	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR,
+			   ktime_us_delta(ktime_get(), kstart));
+
 	return rc;
 }
 
@@ -569,6 +575,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 {
 	struct inode *inode = d_inode(dentry);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	ktime_t kstart = ktime_get();
 	char *xattr_name;
 	ssize_t rc, rc2;
 	size_t len, rem;
@@ -578,8 +585,6 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LISTXATTR, 1);
-
 	rc = ll_xattr_list(inode, NULL, XATTR_OTHER_T, buffer, size,
 			   OBD_MD_FLXATTRLS);
 	if (rc < 0)
@@ -591,7 +596,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 	 * exists.
 	 */
 	if (!size)
-		return rc + sizeof(XATTR_LUSTRE_LOV);
+		goto out;
 
 	xattr_name = buffer;
 	rem = rc;
@@ -625,6 +630,10 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 
 	memcpy(buffer + rc, XATTR_LUSTRE_LOV, sizeof(XATTR_LUSTRE_LOV));
 
+out:
+	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LISTXATTR,
+			   ktime_us_delta(ktime_get(), kstart));
+
 	return rc + sizeof(XATTR_LUSTRE_LOV);
 }
 
-- 
1.8.3.1
