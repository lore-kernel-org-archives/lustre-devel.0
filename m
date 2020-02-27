From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:29 -0500
Subject: [lustre-devel] [PATCH 581/622] lustre: llite: replace lli_trunc_sem
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-582-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

lli_trunc_sem can lead to a deadlock.

vvp_io_read_start takes lli_trunc_sem, and can take
mmap sem in the direct i/o case, via
generic_file_read_iter->ll_direct_IO->get_user_pages_unlocked

vvp_io_fault_start is called with mmap_sem held (taken in
the kernel page fault code), and takes lli_trunc_sem.

These aren't necessarily the same mmap_sem, but can be if
you mmap a lustre file, then read into that mapped memory
from the file.

These are both 'down_read' calls on lli_trunc_sem so they
don't directly conflict, but if vvp_io_setattr_start() is
called to truncate the file between these, it does
'down_write' on lli_trunc_sem.  As semaphores are queued,
this down_write blocks subsequent reads.

This means if the page fault has taken the mmap_sem,
but not yet the lli_trunc_sem in vvp_io_fault_start,
it will wait behind the lli_trunc_sem down_write from
vvp_io_setattr_start.

At the same time, vvp_io_read_start is holding the
lli_trunc_sem and waiting for the mmap_sem, which will not
be released because vvp_io_fault_start cannot get the
lli_trunc_sem because the setattr 'down_write' operation is
queued in front of it.

Solve this by replacing with a hand-coded semaphore, using
atomic counters and wait_var_event().  This allows a
special down_read_nowait which ignores waiting down_write
operations.  This combined with waking up all waiters at
once guarantees that down_read_nowait can always 'join'
another down_read, guaranteeing our ability to take the
semaphore twice for read and avoiding the deadlock.

I'd like there to be a better way to fix this, but I
haven't found it yet.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12460
Lustre-commit: e5914a61ac77 ("LU-12460 llite: replace lli_trunc_sem")
Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35271
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 93 +++++++++++++++++++++++++++++++++++++++-
 fs/lustre/llite/llite_lib.c      |  2 +-
 fs/lustre/llite/vvp_io.c         | 14 +++---
 3 files changed, 100 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index def4df0..b7b418f 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -105,6 +105,16 @@ enum ll_file_flags {
 	LLIF_PROJECT_INHERIT	= 3,
 };
 
+/* See comment on trunc_sem_down_read_nowait */
+struct ll_trunc_sem {
+	/* when positive, this is a count of readers, when -1, it indicates
+	 * the semaphore is held for write, and 0 is unlocked
+	 */
+	atomic_t	ll_trunc_readers;
+	/* this tracks a count of waiting writers */
+	atomic_t	ll_trunc_waiters;
+};
+
 struct ll_inode_info {
 	u32				lli_inode_magic;
 
@@ -178,7 +188,7 @@ struct ll_inode_info {
 		struct {
 			struct mutex			lli_size_mutex;
 			char			       *lli_symlink_name;
-			struct rw_semaphore		lli_trunc_sem;
+			struct ll_trunc_sem		lli_trunc_sem;
 			struct range_lock_tree		lli_write_tree;
 
 			struct rw_semaphore		lli_glimpse_sem;
@@ -253,6 +263,87 @@ struct ll_inode_info {
 	struct list_head		lli_xattrs;/* ll_xattr_entry->xe_list */
 };
 
+static inline void ll_trunc_sem_init(struct ll_trunc_sem *sem)
+{
+	atomic_set(&sem->ll_trunc_readers, 0);
+	atomic_set(&sem->ll_trunc_waiters, 0);
+}
+
+/* This version of down read ignores waiting writers, meaning if the semaphore
+ * is already held for read, this down_read will 'join' that reader and also
+ * take the semaphore.
+ *
+ * This lets us avoid an unusual deadlock.
+ *
+ * We must take lli_trunc_sem in read mode on entry in to various i/o paths
+ * in Lustre, in order to exclude truncates.  Some of these paths then need to
+ * take the mmap_sem, while still holding the trunc_sem.  The problem is that
+ * page faults hold the mmap_sem when calling in to Lustre, and then must also
+ * take the trunc_sem to exclude truncate.
+ *
+ * This means the locking order for trunc_sem and mmap_sem is sometimes AB,
+ * sometimes BA.  This is almost OK because in both cases, we take the trunc
+ * sem for read, so it doesn't block.
+ *
+ * However, if a write mode user (truncate, a setattr op) arrives in the
+ * middle of this, the second reader on the truncate_sem will wait behind that
+ * writer.
+ *
+ * So we have, on our truncate sem, in order (where 'reader' and 'writer' refer
+ * to the mode in which they take the semaphore):
+ * reader (holding mmap_sem, needs truncate_sem)
+ * writer
+ * reader (holding truncate sem, waiting for mmap_sem)
+ *
+ * And so the readers deadlock.
+ *
+ * The solution is this modified semaphore, where this down_read ignores
+ * waiting write operations, and all waiters are woken up at once, so readers
+ * using down_read_nowait cannot get stuck behind waiting writers, regardless
+ * of the order they arrived in.
+ *
+ * down_read_nowait is only used in the page fault case, where we already hold
+ * the mmap_sem.  This is because otherwise repeated read and write operations
+ * (which take the truncate sem) could prevent a truncate from ever starting.
+ * This could still happen with page faults, but without an even more complex
+ * mechanism, this is unavoidable.
+ *
+ * LU-12460
+ */
+static inline void trunc_sem_down_read_nowait(struct ll_trunc_sem *sem)
+{
+	wait_var_event(&sem->ll_trunc_readers,
+		       atomic_inc_unless_negative(&sem->ll_trunc_readers));
+}
+
+static inline void trunc_sem_down_read(struct ll_trunc_sem *sem)
+{
+	wait_var_event(&sem->ll_trunc_readers,
+		       atomic_read(&sem->ll_trunc_waiters) == 0 &&
+		       atomic_inc_unless_negative(&sem->ll_trunc_readers));
+}
+
+static inline void trunc_sem_up_read(struct ll_trunc_sem *sem)
+{
+	if (atomic_dec_return(&sem->ll_trunc_readers) == 0 &&
+	    atomic_read(&sem->ll_trunc_waiters))
+		wake_up_var(&sem->ll_trunc_readers);
+}
+
+static inline void trunc_sem_down_write(struct ll_trunc_sem *sem)
+{
+	atomic_inc(&sem->ll_trunc_waiters);
+	wait_var_event(&sem->ll_trunc_readers,
+		       atomic_cmpxchg(&sem->ll_trunc_readers, 0, -1) == 0);
+	atomic_dec(&sem->ll_trunc_waiters);
+}
+
+static inline void trunc_sem_up_write(struct ll_trunc_sem *sem)
+{
+	atomic_set(&sem->ll_trunc_readers, 0);
+	wake_up_var(&sem->ll_trunc_readers);
+}
+
 static inline u32 ll_layout_version_get(struct ll_inode_info *lli)
 {
 	u32 gen;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 7e128f0..f083a90 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -971,7 +971,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 	} else {
 		mutex_init(&lli->lli_size_mutex);
 		lli->lli_symlink_name = NULL;
-		init_rwsem(&lli->lli_trunc_sem);
+		ll_trunc_sem_init(&lli->lli_trunc_sem);
 		range_lock_tree_init(&lli->lli_write_tree);
 		init_rwsem(&lli->lli_glimpse_sem);
 		lli->lli_glimpse_time = ktime_set(0, 0);
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index b3f628c..259b14a 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -682,7 +682,7 @@ static int vvp_io_setattr_start(const struct lu_env *env,
 	struct ll_inode_info *lli = ll_i2info(inode);
 
 	if (cl_io_is_trunc(io)) {
-		down_write(&lli->lli_trunc_sem);
+		trunc_sem_down_write(&lli->lli_trunc_sem);
 		inode_lock(inode);
 		inode_dio_wait(inode);
 	} else {
@@ -708,7 +708,7 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 		 */
 		vvp_do_vmtruncate(inode, io->u.ci_setattr.sa_attr.lvb_size);
 		inode_unlock(inode);
-		up_write(&lli->lli_trunc_sem);
+		trunc_sem_up_write(&lli->lli_trunc_sem);
 	} else {
 		inode_unlock(inode);
 	}
@@ -747,7 +747,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 
 	CDEBUG(D_VFSTRACE, "read: -> [%lli, %lli)\n", pos, pos + cnt);
 
-	down_read(&lli->lli_trunc_sem);
+	trunc_sem_down_read(&lli->lli_trunc_sem);
 
 	if (io->ci_async_readahead) {
 		file_accessed(file);
@@ -1076,7 +1076,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 	size_t written = 0;
 	ssize_t result = 0;
 
-	down_read(&lli->lli_trunc_sem);
+	trunc_sem_down_read(&lli->lli_trunc_sem);
 
 	if (!can_populate_pages(env, io, inode))
 		return 0;
@@ -1178,7 +1178,7 @@ static void vvp_io_rw_end(const struct lu_env *env,
 	struct inode *inode = vvp_object_inode(ios->cis_obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
 
-	up_read(&lli->lli_trunc_sem);
+	trunc_sem_up_read(&lli->lli_trunc_sem);
 }
 
 static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
@@ -1243,7 +1243,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	loff_t size;
 	pgoff_t last_index;
 
-	down_read(&lli->lli_trunc_sem);
+	trunc_sem_down_read_nowait(&lli->lli_trunc_sem);
 
 	/* offset of the last byte on the page */
 	offset = cl_offset(obj, fio->ft_index + 1) - 1;
@@ -1400,7 +1400,7 @@ static void vvp_io_fault_end(const struct lu_env *env,
 
 	CLOBINVRNT(env, ios->cis_io->ci_obj,
 		   vvp_object_invariant(ios->cis_io->ci_obj));
-	up_read(&lli->lli_trunc_sem);
+	trunc_sem_up_read(&lli->lli_trunc_sem);
 }
 
 static int vvp_io_fsync_start(const struct lu_env *env,
-- 
1.8.3.1
