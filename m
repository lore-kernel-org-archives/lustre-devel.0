From: Benjamin Coddington <bcodding@redhat.com>
Date: Thu, 22 Oct 2015 11:35:55 -0400
Subject: [lustre-devel] [PATCH 2/3] Move locks API users to
	locks_lock_inode_wait()
In-Reply-To: <cover.1445524157.git.bcodding@redhat.com>
References: <cover.1445524157.git.bcodding@redhat.com>
Message-ID: <b9437d039ca6bd46ee4ea06fbf73313ce4473086.1445524157.git.bcodding@redhat.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Instead of having users check for FL_POSIX or FL_FLOCK to call the correct
locks API function, use the check within locks_lock_inode_wait().  This
allows for some later cleanup.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 drivers/staging/lustre/lustre/llite/file.c |    8 ++------
 fs/9p/vfs_file.c                           |    4 ++--
 fs/ceph/locks.c                            |    4 ++--
 fs/cifs/file.c                             |    2 +-
 fs/dlm/plock.c                             |    4 ++--
 fs/fuse/file.c                             |    2 +-
 fs/gfs2/file.c                             |    8 ++++----
 fs/lockd/clntproc.c                        |   13 +------------
 fs/locks.c                                 |    2 +-
 fs/nfs/file.c                              |   13 +------------
 fs/nfs/nfs4proc.c                          |   13 +------------
 fs/ocfs2/locks.c                           |    8 ++++----
 12 files changed, 22 insertions(+), 59 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index dcd0c6d..4edbf46 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2763,13 +2763,9 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	rc = md_enqueue(sbi->ll_md_exp, &einfo, NULL,
 			op_data, &lockh, &flock, 0, NULL /* req */, flags);
 
-	if ((file_lock->fl_flags & FL_FLOCK) &&
-	    (rc == 0 || file_lock->fl_type == F_UNLCK))
-		rc2  = flock_lock_file_wait(file, file_lock);
-	if ((file_lock->fl_flags & FL_POSIX) &&
-	    (rc == 0 || file_lock->fl_type == F_UNLCK) &&
+	if ((rc == 0 || file_lock->fl_type == F_UNLCK) &&
 	    !(flags & LDLM_FL_TEST_LOCK))
-		rc2  = posix_lock_file_wait(file, file_lock);
+		rc2  = locks_lock_file_wait(file, file_lock);
 
 	if (rc2 && file_lock->fl_type != F_UNLCK) {
 		einfo.ei_mode = LCK_NL;
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index 3abc447..f23fd86 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -161,7 +161,7 @@ static int v9fs_file_do_lock(struct file *filp, int cmd, struct file_lock *fl)
 	if ((fl->fl_flags & FL_POSIX) != FL_POSIX)
 		BUG();
 
-	res = posix_lock_file_wait(filp, fl);
+	res = locks_lock_file_wait(filp, fl);
 	if (res < 0)
 		goto out;
 
@@ -231,7 +231,7 @@ out_unlock:
 	if (res < 0 && fl->fl_type != F_UNLCK) {
 		fl_type = fl->fl_type;
 		fl->fl_type = F_UNLCK;
-		res = posix_lock_file_wait(filp, fl);
+		res = locks_lock_file_wait(filp, fl);
 		fl->fl_type = fl_type;
 	}
 out:
diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
index 6706bde..a2cb0c2 100644
--- a/fs/ceph/locks.c
+++ b/fs/ceph/locks.c
@@ -228,12 +228,12 @@ int ceph_flock(struct file *file, int cmd, struct file_lock *fl)
 	err = ceph_lock_message(CEPH_LOCK_FLOCK, CEPH_MDS_OP_SETFILELOCK,
 				file, lock_cmd, wait, fl);
 	if (!err) {
-		err = flock_lock_file_wait(file, fl);
+		err = locks_lock_file_wait(file, fl);
 		if (err) {
 			ceph_lock_message(CEPH_LOCK_FLOCK,
 					  CEPH_MDS_OP_SETFILELOCK,
 					  file, CEPH_LOCK_UNLOCK, 0, fl);
-			dout("got %d on flock_lock_file_wait, undid lock", err);
+			dout("got %d on locks_lock_file_wait, undid lock", err);
 		}
 	}
 	return err;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index e2a6af1..6afdad7 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1553,7 +1553,7 @@ cifs_setlk(struct file *file, struct file_lock *flock, __u32 type,
 
 out:
 	if (flock->fl_flags & FL_POSIX && !rc)
-		rc = posix_lock_file_wait(file, flock);
+		rc = locks_lock_file_wait(file, flock);
 	return rc;
 }
 
diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
index 5532f09..3585cc0 100644
--- a/fs/dlm/plock.c
+++ b/fs/dlm/plock.c
@@ -172,7 +172,7 @@ int dlm_posix_lock(dlm_lockspace_t *lockspace, u64 number, struct file *file,
 	rv = op->info.rv;
 
 	if (!rv) {
-		if (posix_lock_file_wait(file, fl) < 0)
+		if (locks_lock_file_wait(file, fl) < 0)
 			log_error(ls, "dlm_posix_lock: vfs lock error %llx",
 				  (unsigned long long)number);
 	}
@@ -262,7 +262,7 @@ int dlm_posix_unlock(dlm_lockspace_t *lockspace, u64 number, struct file *file,
 	/* cause the vfs unlock to return ENOENT if lock is not found */
 	fl->fl_flags |= FL_EXISTS;
 
-	rv = posix_lock_file_wait(file, fl);
+	rv = locks_lock_file_wait(file, fl);
 	if (rv == -ENOENT) {
 		rv = 0;
 		goto out_free;
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index f523f2f..e0faf8f 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2189,7 +2189,7 @@ static int fuse_file_flock(struct file *file, int cmd, struct file_lock *fl)
 	int err;
 
 	if (fc->no_flock) {
-		err = flock_lock_file_wait(file, fl);
+		err = locks_lock_file_wait(file, fl);
 	} else {
 		struct fuse_file *ff = file->private_data;
 
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index cf4ab89..9287a2d 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -1000,7 +1000,7 @@ static int gfs2_lock(struct file *file, int cmd, struct file_lock *fl)
 	}
 	if (unlikely(test_bit(SDF_SHUTDOWN, &sdp->sd_flags))) {
 		if (fl->fl_type == F_UNLCK)
-			posix_lock_file_wait(file, fl);
+			locks_lock_file_wait(file, fl);
 		return -EIO;
 	}
 	if (IS_GETLK(cmd))
@@ -1031,7 +1031,7 @@ static int do_flock(struct file *file, int cmd, struct file_lock *fl)
 	if (gl) {
 		if (fl_gh->gh_state == state)
 			goto out;
-		flock_lock_file_wait(file,
+		locks_lock_file_wait(file,
 				     &(struct file_lock){.fl_type = F_UNLCK});
 		gfs2_glock_dq(fl_gh);
 		gfs2_holder_reinit(state, flags, fl_gh);
@@ -1056,7 +1056,7 @@ static int do_flock(struct file *file, int cmd, struct file_lock *fl)
 		if (error == GLR_TRYFAILED)
 			error = -EAGAIN;
 	} else {
-		error = flock_lock_file_wait(file, fl);
+		error = locks_lock_file_wait(file, fl);
 		gfs2_assert_warn(GFS2_SB(&ip->i_inode), !error);
 	}
 
@@ -1071,7 +1071,7 @@ static void do_unflock(struct file *file, struct file_lock *fl)
 	struct gfs2_holder *fl_gh = &fp->f_fl_gh;
 
 	mutex_lock(&fp->f_fl_mutex);
-	flock_lock_file_wait(file, fl);
+	locks_lock_file_wait(file, fl);
 	if (fl_gh->gh_gl) {
 		gfs2_glock_dq(fl_gh);
 		gfs2_holder_uninit(fl_gh);
diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index acd3947..1129520 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -474,18 +474,7 @@ static void nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *ho
 
 static int do_vfs_lock(struct file_lock *fl)
 {
-	int res = 0;
-	switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
-		case FL_POSIX:
-			res = posix_lock_file_wait(fl->fl_file, fl);
-			break;
-		case FL_FLOCK:
-			res = flock_lock_file_wait(fl->fl_file, fl);
-			break;
-		default:
-			BUG();
-	}
-	return res;
+	return locks_lock_file_wait(fl->fl_file, fl);
 }
 
 /*
diff --git a/fs/locks.c b/fs/locks.c
index 68b1784..94d50d3 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1955,7 +1955,7 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
 					  (can_sleep) ? F_SETLKW : F_SETLK,
 					  lock);
 	else
-		error = flock_lock_file_wait(f.file, lock);
+		error = locks_lock_file_wait(f.file, lock);
 
  out_free:
 	locks_free_lock(lock);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c0f9b1e..37f639d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -738,18 +738,7 @@ out_noconflict:
 
 static int do_vfs_lock(struct file *file, struct file_lock *fl)
 {
-	int res = 0;
-	switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
-		case FL_POSIX:
-			res = posix_lock_file_wait(file, fl);
-			break;
-		case FL_FLOCK:
-			res = flock_lock_file_wait(file, fl);
-			break;
-		default:
-			BUG();
-	}
-	return res;
+	return locks_lock_file_wait(file, fl);
 }
 
 static int
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5133bb1..0e5ff69 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5513,18 +5513,7 @@ static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *
 
 static int do_vfs_lock(struct inode *inode, struct file_lock *fl)
 {
-	int res = 0;
-	switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
-		case FL_POSIX:
-			res = posix_lock_inode_wait(inode, fl);
-			break;
-		case FL_FLOCK:
-			res = flock_lock_inode_wait(inode, fl);
-			break;
-		default:
-			BUG();
-	}
-	return res;
+	return locks_lock_inode_wait(inode, fl);
 }
 
 struct nfs4_unlockdata {
diff --git a/fs/ocfs2/locks.c b/fs/ocfs2/locks.c
index 6b6d092..652ece4 100644
--- a/fs/ocfs2/locks.c
+++ b/fs/ocfs2/locks.c
@@ -66,7 +66,7 @@ static int ocfs2_do_flock(struct file *file, struct inode *inode,
 		 * level.
 		 */
 
-		flock_lock_file_wait(file,
+		locks_lock_file_wait(file,
 				     &(struct file_lock){.fl_type = F_UNLCK});
 
 		ocfs2_file_unlock(file);
@@ -81,7 +81,7 @@ static int ocfs2_do_flock(struct file *file, struct inode *inode,
 		goto out;
 	}
 
-	ret = flock_lock_file_wait(file, fl);
+	ret = locks_lock_file_wait(file, fl);
 	if (ret)
 		ocfs2_file_unlock(file);
 
@@ -98,7 +98,7 @@ static int ocfs2_do_funlock(struct file *file, int cmd, struct file_lock *fl)
 
 	mutex_lock(&fp->fp_mutex);
 	ocfs2_file_unlock(file);
-	ret = flock_lock_file_wait(file, fl);
+	ret = locks_lock_file_wait(file, fl);
 	mutex_unlock(&fp->fp_mutex);
 
 	return ret;
@@ -119,7 +119,7 @@ int ocfs2_flock(struct file *file, int cmd, struct file_lock *fl)
 
 	if ((osb->s_mount_opt & OCFS2_MOUNT_LOCALFLOCKS) ||
 	    ocfs2_mount_local(osb))
-		return flock_lock_file_wait(file, fl);
+		return locks_lock_file_wait(file, fl);
 
 	if (fl->fl_type == F_UNLCK)
 		return ocfs2_do_funlock(file, cmd, fl);
-- 
1.7.1
