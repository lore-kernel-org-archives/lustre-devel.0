From: Benjamin Coddington <bcodding@redhat.com>
Date: Tue, 27 Jun 2017 11:18:07 -0400
Subject: [lustre-devel] [PATCH 1/3] fs/locks: Use allocation rather than the
	stack in fcntl_getlk()
In-Reply-To: <cover.1498572504.git.bcodding@redhat.com>
References: <cover.1498572504.git.bcodding@redhat.com>
Message-ID: <eb812a7fde61f4ed8a23911f89ceeef44b8df943.1498572504.git.bcodding@redhat.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andreas Dilger <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, James Simmons <jsimmons-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ron Minnich <rminnich-4OHPYypu0djtX7QSmKvirg@public.gmane.org>, Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>, "Yan, Zheng" <zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Sage Weil <sage-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Christine Caulfield <ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Teigland <teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Vitaly Fertman <vitaly_fertman-qCPWdT176rRBDgjK7y7TUQ@public.gmane.org>, "John L. Hammond" <john.hammond-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andriy Skulysh <andriy.skulysh-ShLqkCeKS0lBDgjK7y7TUQ@public.gmane.org>, Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Emoly Liu <emoly.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

Struct file_lock is fairly large, so let's save some space on the stack by
using an allocation for struct file_lock in fcntl_getlk(), just as we do
for fcntl_setlk().

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c | 46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index afefeb4ad6de..d7daa6c8932f 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2086,14 +2086,17 @@ static void posix_lock_to_flock64(struct flock64 *flock, struct file_lock *fl)
  */
 int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock *flock)
 {
-	struct file_lock file_lock;
+	struct file_lock *fl;
 	int error;
 
+	fl = locks_alloc_lock();
+	if (fl == NULL)
+		return -ENOMEM;
 	error = -EINVAL;
 	if (flock->l_type != F_RDLCK && flock->l_type != F_WRLCK)
 		goto out;
 
-	error = flock_to_posix_lock(filp, &file_lock, flock);
+	error = flock_to_posix_lock(filp, fl, flock);
 	if (error)
 		goto out;
 
@@ -2103,23 +2106,22 @@ int fcntl_getlk(struct file *filp, unsigned int cmd, struct flock *flock)
 			goto out;
 
 		cmd = F_GETLK;
-		file_lock.fl_flags |= FL_OFDLCK;
-		file_lock.fl_owner = filp;
+		fl->fl_flags |= FL_OFDLCK;
+		fl->fl_owner = filp;
 	}
 
-	error = vfs_test_lock(filp, &file_lock);
+	error = vfs_test_lock(filp, fl);
 	if (error)
 		goto out;
  
-	flock->l_type = file_lock.fl_type;
-	if (file_lock.fl_type != F_UNLCK) {
-		error = posix_lock_to_flock(flock, &file_lock);
+	flock->l_type = fl->fl_type;
+	if (fl->fl_type != F_UNLCK) {
+		error = posix_lock_to_flock(flock, fl);
 		if (error)
-			goto rel_priv;
+			goto out;
 	}
-rel_priv:
-	locks_release_private(&file_lock);
 out:
+	locks_free_lock(fl);
 	return error;
 }
 
@@ -2298,14 +2300,18 @@ int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
  */
 int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 *flock)
 {
-	struct file_lock file_lock;
+	struct file_lock *fl;
 	int error;
 
+	fl = locks_alloc_lock();
+	if (fl == NULL)
+		return -ENOMEM;
+
 	error = -EINVAL;
 	if (flock->l_type != F_RDLCK && flock->l_type != F_WRLCK)
 		goto out;
 
-	error = flock64_to_posix_lock(filp, &file_lock, flock);
+	error = flock64_to_posix_lock(filp, fl, flock);
 	if (error)
 		goto out;
 
@@ -2315,20 +2321,20 @@ int fcntl_getlk64(struct file *filp, unsigned int cmd, struct flock64 *flock)
 			goto out;
 
 		cmd = F_GETLK64;
-		file_lock.fl_flags |= FL_OFDLCK;
-		file_lock.fl_owner = filp;
+		fl->fl_flags |= FL_OFDLCK;
+		fl->fl_owner = filp;
 	}
 
-	error = vfs_test_lock(filp, &file_lock);
+	error = vfs_test_lock(filp, fl);
 	if (error)
 		goto out;
 
-	flock->l_type = file_lock.fl_type;
-	if (file_lock.fl_type != F_UNLCK)
-		posix_lock_to_flock64(flock, &file_lock);
+	flock->l_type = fl->fl_type;
+	if (fl->fl_type != F_UNLCK)
+		posix_lock_to_flock64(flock, fl);
 
-	locks_release_private(&file_lock);
 out:
+	locks_free_lock(fl);
 	return error;
 }
 
-- 
2.9.3
