From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:45 -0400
Subject: [lustre-devel] [PATCH v2 03/29] lustre: llite: replace lli_trunc_sem
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

lli_trunc_sem can lead to a readlock.

vvp_io_read_start can take mmap_sem while holding lli_trunc_sem,
and vvp_io_fault_start will take lli_trunc_sem while holding mmap_sem.

These aren't necessarily the same mmap_sem, but can be if you mmap a
lustre file, then read into that mapped memory from the file.

These are both 'down_read' calls on lli_trunc_sem so they don't
necessarily conflict, but if vvp_io_setattr_start() is called to
truncate the file between these, the later will wait for the former
and a deadlock can eventuate.

Solve this by replacing with a hand-coded semaphore, using atomic
counters and wait_var_event().
In the vvp_io_fault_start() case where mmap_sem is held, don't wait
for a pending writer, only for an active writer.  This means we won't
wait if vvp_io_read_start has started, and so no deadlock happens.

I'd like there to be a better way to fix this, but I haven't found it
yet.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/llite/llite_internal.h |  3 ++-
 fs/lustre/llite/llite_lib.c      |  3 ++-
 fs/lustre/llite/vvp_io.c         | 28 +++++++++++++++++++++-------
 3 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 9da59b1..7566b1b 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -190,7 +190,8 @@ struct ll_inode_info {
 			 *    struct list_head wait_list;
 			 * }
 			 */
-			struct rw_semaphore		lli_trunc_sem;
+			atomic_t			lli_trunc_readers;
+			atomic_t			lli_trunc_waiters;
 			struct range_lock_tree		lli_write_tree;
 
 			struct rw_semaphore		lli_glimpse_sem;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4e98eb4..ab7c84a 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -894,7 +894,8 @@ void ll_lli_init(struct ll_inode_info *lli)
 	} else {
 		mutex_init(&lli->lli_size_mutex);
 		lli->lli_symlink_name = NULL;
-		init_rwsem(&lli->lli_trunc_sem);
+		atomic_set(&lli->lli_trunc_readers, 0);
+		atomic_set(&lli->lli_trunc_waiters, 0);
 		range_lock_tree_init(&lli->lli_write_tree);
 		init_rwsem(&lli->lli_glimpse_sem);
 		lli->lli_glimpse_time = 0;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 225a858..a9db530 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -667,7 +667,10 @@ static int vvp_io_setattr_start(const struct lu_env *env,
 	struct ll_inode_info *lli = ll_i2info(inode);
 
 	if (cl_io_is_trunc(io)) {
-		down_write(&lli->lli_trunc_sem);
+		atomic_inc(&lli->lli_trunc_waiters);
+		wait_var_event(&lli->lli_trunc_readers,
+			       atomic_cmpxchg(&lli->lli_trunc_readers, 0, -1) == 0);
+		atomic_dec(&lli->lli_trunc_waiters);
 		inode_lock(inode);
 		inode_dio_wait(inode);
 	} else {
@@ -693,7 +696,8 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 		 */
 		vvp_do_vmtruncate(inode, io->u.ci_setattr.sa_attr.lvb_size);
 		inode_unlock(inode);
-		up_write(&lli->lli_trunc_sem);
+		atomic_set(&lli->lli_trunc_readers, 0);
+		wake_up_var(&lli->lli_trunc_readers);
 	} else {
 		inode_unlock(inode);
 	}
@@ -732,7 +736,9 @@ static int vvp_io_read_start(const struct lu_env *env,
 
 	CDEBUG(D_VFSTRACE, "read: -> [%lli, %lli)\n", pos, pos + cnt);
 
-	down_read(&lli->lli_trunc_sem);
+	wait_var_event(&lli->lli_trunc_readers,
+		       atomic_read(&lli->lli_trunc_waiters) == 0 &&
+		       atomic_inc_unless_negative(&lli->lli_trunc_readers));
 
 	if (!can_populate_pages(env, io, inode))
 		return 0;
@@ -965,7 +971,9 @@ static int vvp_io_write_start(const struct lu_env *env,
 	size_t cnt = io->u.ci_wr.wr.crw_count;
 	ssize_t result = 0;
 
-	down_read(&lli->lli_trunc_sem);
+	wait_var_event(&lli->lli_trunc_readers,
+		       atomic_read(&lli->lli_trunc_waiters) == 0 &&
+		       atomic_inc_unless_negative(&lli->lli_trunc_readers));
 
 	if (!can_populate_pages(env, io, inode))
 		return 0;
@@ -1059,7 +1067,9 @@ static void vvp_io_rw_end(const struct lu_env *env,
 	struct inode *inode = vvp_object_inode(ios->cis_obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
 
-	up_read(&lli->lli_trunc_sem);
+	if (atomic_dec_return(&lli->lli_trunc_readers) == 0 &&
+	    atomic_read(&lli->lli_trunc_waiters))
+		wake_up_var(&lli->lli_trunc_readers);
 }
 
 static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
@@ -1124,7 +1134,8 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	loff_t size;
 	pgoff_t last_index;
 
-	down_read(&lli->lli_trunc_sem);
+	wait_var_event(&lli->lli_trunc_readers,
+		       atomic_inc_unless_negative(&lli->lli_trunc_readers));
 
 	/* offset of the last byte on the page */
 	offset = cl_offset(obj, fio->ft_index + 1) - 1;
@@ -1281,7 +1292,10 @@ static void vvp_io_fault_end(const struct lu_env *env,
 
 	CLOBINVRNT(env, ios->cis_io->ci_obj,
 		   vvp_object_invariant(ios->cis_io->ci_obj));
-	up_read(&lli->lli_trunc_sem);
+
+	if (atomic_dec_return(&lli->lli_trunc_readers) == 0 &&
+	    atomic_read(&lli->lli_trunc_waiters))
+		wake_up_var(&lli->lli_trunc_readers);
 }
 
 static int vvp_io_fsync_start(const struct lu_env *env,
-- 
1.8.3.1
