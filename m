From: Benjamin Coddington <bcodding@redhat.com>
Date: Thu, 22 Oct 2015 11:35:56 -0400
Subject: [lustre-devel] [PATCH 3/3] locks: cleanup posix_lock_inode_wait and
	flock_lock_inode_wait
In-Reply-To: <cover.1445524157.git.bcodding@redhat.com>
References: <cover.1445524157.git.bcodding@redhat.com>
Message-ID: <ded792d8fdcba562a1c74fd14fefcb387debc4b1.1445524157.git.bcodding@redhat.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All callers use locks_lock_inode_wait() instead.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c         |    5 +----
 include/linux/fs.h |   24 ------------------------
 2 files changed, 1 insertions(+), 28 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 94d50d3..b6f3c92 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1167,8 +1167,7 @@ EXPORT_SYMBOL(posix_lock_file);
  * @inode: inode of file to which lock request should be applied
  * @fl: The lock to be applied
  *
- * Variant of posix_lock_file_wait that does not take a filp, and so can be
- * used after the filp has already been torn down.
+ * Apply a POSIX style lock request to an inode.
  */
 int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 {
@@ -1187,7 +1186,6 @@ int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 	}
 	return error;
 }
-EXPORT_SYMBOL(posix_lock_inode_wait);
 
 /**
  * locks_mandatory_locked - Check for an active lock
@@ -1873,7 +1871,6 @@ int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 	}
 	return error;
 }
-EXPORT_SYMBOL(flock_lock_inode_wait);
 
 /**
  * locks_lock_inode_wait - Apply a lock to an inode
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2e283b7..05b07c9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1053,12 +1053,10 @@ extern void locks_remove_file(struct file *);
 extern void locks_release_private(struct file_lock *);
 extern void posix_test_lock(struct file *, struct file_lock *);
 extern int posix_lock_file(struct file *, struct file_lock *, struct file_lock *);
-extern int posix_lock_inode_wait(struct inode *, struct file_lock *);
 extern int posix_unblock_lock(struct file_lock *);
 extern int vfs_test_lock(struct file *, struct file_lock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
-extern int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl);
 extern int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl);
 extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
@@ -1145,12 +1143,6 @@ static inline int posix_lock_file(struct file *filp, struct file_lock *fl,
 	return -ENOLCK;
 }
 
-static inline int posix_lock_inode_wait(struct inode *inode,
-					struct file_lock *fl)
-{
-	return -ENOLCK;
-}
-
 static inline int posix_unblock_lock(struct file_lock *waiter)
 {
 	return -ENOENT;
@@ -1172,12 +1164,6 @@ static inline int vfs_cancel_lock(struct file *filp, struct file_lock *fl)
 	return 0;
 }
 
-static inline int flock_lock_inode_wait(struct inode *inode,
-					struct file_lock *request)
-{
-	return -ENOLCK;
-}
-
 static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
 {
 	return -ENOLCK;
@@ -1221,16 +1207,6 @@ static inline struct inode *file_inode(const struct file *f)
 	return f->f_inode;
 }
 
-static inline int posix_lock_file_wait(struct file *filp, struct file_lock *fl)
-{
-	return posix_lock_inode_wait(file_inode(filp), fl);
-}
-
-static inline int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
-{
-	return flock_lock_inode_wait(file_inode(filp), fl);
-}
-
 static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
 {
 	return locks_lock_inode_wait(file_inode(filp), fl);
-- 
1.7.1
