From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:29 -0400
Subject: [lustre-devel] [PATCH 030/124] staging: lustre: llite: Replace
	write mutex with range lock
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Prakash Surya <surya1@llnl.gov>, Patrick Farrell <paf@cray.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Prakash Surya <surya1@llnl.gov>

Testing has shown the ll_inode_inode's lli_write_mutex to be a
limiting factor with single shared file write performance, when using
many writing threads on a single machine. Even if each thread is
writing to a unique portion of the file, the lli_write_mutex will
prevent no more than a single thread to ever write to the file
simultaneously.

This change attempts to remove this bottle neck, by replacing this
mutex with a range lock. This should allow multiple threads to write
to a single file simultaneously iff the threads are writing to unique
regions of the file.

Performance testing shows this change to garner a significant
performance boost to write bandwidth. Using FIO on a single machine
with 32 GB of RAM, write performance tests were run with and without
this change applied; the results are below:

    +---------+-----------+---------+--------+--------+--------+
    |     fio v2.0.13     |        Write Bandwidth (KB/s)      |
    +---------+-----------+---------+--------+--------+--------+
    | # Tasks | GB / Task | Test 1  | Test 2 | Test 3 | Test 4 |
    +---------+-----------+---------+--------+--------+--------+
    |    1    |    64     |  452446 | 454623 | 457653 | 463737 |
    |    2    |    32     |  850318 | 565373 | 602498 | 733027 |
    |    4    |    16     | 1058900 | 463546 | 529107 | 976284 |
    |    8    |     8     | 1026300 | 468190 | 576451 | 963404 |
    |   16    |     4     | 1065500 | 503160 | 462902 | 830065 |
    |   32    |     2     | 1068600 | 462228 | 466963 | 749733 |
    |   64    |     1     |  991830 | 556618 | 557863 | 710912 |
    +---------+-----------+---------+--------+--------+--------+

 * Test 1: Lustre client running 04ec54f. File per process write
           workload. This test was used as a baseline for what we
           _could_ achieve in the single shared file tests if the
           bottle necks were removed.

 * Test 2: Lustre client running 04ec54f. Single shared file
           workload, each task writing to a unique region.

 * Test 3: Lustre client running 04ec54f + I0023132b. Single shared
           file workload, each task writing to a unique region.

 * Test 4: Lustre client running 04ec54f + this patch.
           Single shared file workload, each task writing to a unique
           region.

Direct IO does not use the page cache like normal IO, so
concurrent direct IO reads of the same pages are not safe.

As a result, direct IO reads must take the range lock
in ll_file_io_generic, otherwise they will attempt to work
on the same pages and hit assertions like:
(osc_request.c:1219:osc_brw_prep_request())
ASSERTION( i == 0 || pg->off > pg_prev->off ) failed:
i 3 p_c 10 pg ffffea00017a5208 [pri 0 ind 2771] off 16384
prev_pg ffffea00017a51d0 [pri 0 ind 2256] off 16384

Signed-off-by: Prakash Surya <surya1@llnl.gov>
Signed-off-by: Patrick Farrell <paf@cray.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1669
Reviewed-on: http://review.whamcloud.com/6320
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6227
Reviewed-on: http://review.whamcloud.com/14385
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Alexander Boyko <alexander.boyko@seagate.com>
Reviewed-by: Hiroya Nozaki <nozaki.hiroya@jp.fujitsu.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/Makefile       |    2 +-
 drivers/staging/lustre/lustre/llite/file.c         |   37 +++-
 .../staging/lustre/lustre/llite/llite_internal.h   |    5 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +-
 drivers/staging/lustre/lustre/llite/range_lock.c   |  233 ++++++++++++++++++++
 drivers/staging/lustre/lustre/llite/range_lock.h   |   82 +++++++
 6 files changed, 348 insertions(+), 13 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/llite/range_lock.c
 create mode 100644 drivers/staging/lustre/lustre/llite/range_lock.h

diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 2cbb1b8..1ac0940 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -1,6 +1,6 @@
 obj-$(CONFIG_LUSTRE_FS) += lustre.o
 lustre-y := dcache.o dir.o file.o llite_close.o llite_lib.o llite_nfs.o \
-	    rw.o namei.o symlink.o llite_mmap.o \
+	    rw.o namei.o symlink.o llite_mmap.o range_lock.o \
 	    xattr.o xattr_cache.o rw26.o super25.o statahead.o \
 	    glimpse.o lcommon_cl.o lcommon_misc.o \
 	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o vvp_req.o \
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 273b563..d9ee255 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1126,6 +1126,7 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 {
 	struct ll_inode_info *lli = ll_i2info(file_inode(file));
 	struct ll_file_data  *fd  = LUSTRE_FPRIVATE(file);
+	struct range_lock range;
 	struct cl_io	 *io;
 	ssize_t	       result;
 
@@ -1138,7 +1139,12 @@ restart:
 
 	if (cl_io_rw_init(env, io, iot, *ppos, count) == 0) {
 		struct vvp_io *vio = vvp_env_io(env);
-		int write_mutex_locked = 0;
+		bool range_locked = false;
+
+		if (file->f_flags & O_APPEND)
+			range_lock_init(&range, 0, LUSTRE_EOF);
+		else
+			range_lock_init(&range, *ppos, *ppos + count - 1);
 
 		vio->vui_fd  = LUSTRE_FPRIVATE(file);
 		vio->vui_io_subtype = args->via_io_subtype;
@@ -1147,14 +1153,23 @@ restart:
 		case IO_NORMAL:
 			vio->vui_iter = args->u.normal.via_iter;
 			vio->vui_iocb = args->u.normal.via_iocb;
-			if ((iot == CIT_WRITE) &&
+			/*
+			 * Direct IO reads must also take range lock,
+			 * or multiple reads will try to work on the same pages
+			 * See LU-6227 for details.
+			 */
+			if (((iot == CIT_WRITE) ||
+			     (iot == CIT_READ && (file->f_flags & O_DIRECT))) &&
 			    !(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
-				if (mutex_lock_interruptible(&lli->
-							       lli_write_mutex)) {
-					result = -ERESTARTSYS;
+				CDEBUG(D_VFSTRACE, "Range lock [%llu, %llu]\n",
+				       range.rl_node.in_extent.start,
+				       range.rl_node.in_extent.end);
+				result = range_lock(&lli->lli_write_tree,
+						    &range);
+				if (result < 0)
 					goto out;
-				}
-				write_mutex_locked = 1;
+
+				range_locked = true;
 			}
 			down_read(&lli->lli_trunc_sem);
 			break;
@@ -1171,8 +1186,12 @@ restart:
 		ll_cl_remove(file, env);
 		if (args->via_io_subtype == IO_NORMAL)
 			up_read(&lli->lli_trunc_sem);
-		if (write_mutex_locked)
-			mutex_unlock(&lli->lli_write_mutex);
+		if (range_locked) {
+			CDEBUG(D_VFSTRACE, "Range unlock [%llu, %llu]\n",
+			       range.rl_node.in_extent.start,
+			       range.rl_node.in_extent.end);
+			range_unlock(&lli->lli_write_tree, &range);
+		}
 	} else {
 		/* cl_io_rw_init() handled IO */
 		result = io->ci_result;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index f903f2a..7f0a6c9 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -46,6 +46,7 @@
 #include <linux/xattr.h>
 #include <linux/posix_acl_xattr.h>
 #include "vvp_internal.h"
+#include "range_lock.h"
 
 #ifndef FMODE_EXEC
 #define FMODE_EXEC 0
@@ -210,7 +211,7 @@ struct ll_inode_info {
 			 * }
 			 */
 			struct rw_semaphore		f_trunc_sem;
-			struct mutex			f_write_mutex;
+			struct range_lock_tree		f_write_tree;
 
 			struct rw_semaphore		f_glimpse_sem;
 			unsigned long			f_glimpse_time;
@@ -235,7 +236,7 @@ struct ll_inode_info {
 #define lli_symlink_name	u.f.f_symlink_name
 #define lli_maxbytes	    u.f.f_maxbytes
 #define lli_trunc_sem	   u.f.f_trunc_sem
-#define lli_write_mutex	 u.f.f_write_mutex
+#define lli_write_tree		u.f.f_write_tree
 #define lli_glimpse_sem		u.f.f_glimpse_sem
 #define lli_glimpse_time	u.f.f_glimpse_time
 #define lli_agl_list		u.f.f_agl_list
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 93fd69b..9112fa8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -807,7 +807,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		mutex_init(&lli->lli_size_mutex);
 		lli->lli_symlink_name = NULL;
 		init_rwsem(&lli->lli_trunc_sem);
-		mutex_init(&lli->lli_write_mutex);
+		range_lock_tree_init(&lli->lli_write_tree);
 		init_rwsem(&lli->lli_glimpse_sem);
 		lli->lli_glimpse_time = 0;
 		INIT_LIST_HEAD(&lli->lli_agl_list);
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
new file mode 100644
index 0000000..94c818f
--- /dev/null
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -0,0 +1,233 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Range lock is used to allow multiple threads writing a single shared
+ * file given each thread is writing to a non-overlapping portion of the
+ * file.
+ *
+ * Refer to the possible upstream kernel version of range lock by
+ * Jan Kara <jack@suse.cz>: https://lkml.org/lkml/2013/1/31/480
+ *
+ * This file could later replaced by the upstream kernel version.
+ */
+/*
+ * Author: Prakash Surya <surya1@llnl.gov>
+ * Author: Bobi Jam <bobijam.xu@intel.com>
+ */
+#include "range_lock.h"
+#include "../include/lustre/lustre_user.h"
+
+/**
+ * Initialize a range lock tree
+ *
+ * \param tree [in]	an empty range lock tree
+ *
+ * Pre:  Caller should have allocated the range lock tree.
+ * Post: The range lock tree is ready to function.
+ */
+void range_lock_tree_init(struct range_lock_tree *tree)
+{
+	tree->rlt_root = NULL;
+	tree->rlt_sequence = 0;
+	spin_lock_init(&tree->rlt_lock);
+}
+
+/**
+ * Initialize a range lock node
+ *
+ * \param lock  [in]	an empty range lock node
+ * \param start [in]	start of the covering region
+ * \param end   [in]	end of the covering region
+ *
+ * Pre:  Caller should have allocated the range lock node.
+ * Post: The range lock node is meant to cover [start, end] region
+ */
+void range_lock_init(struct range_lock *lock, __u64 start, __u64 end)
+{
+	memset(&lock->rl_node, 0, sizeof(lock->rl_node));
+	if (end != LUSTRE_EOF)
+		end >>= PAGE_SHIFT;
+	interval_set(&lock->rl_node, start >> PAGE_SHIFT, end);
+	INIT_LIST_HEAD(&lock->rl_next_lock);
+	lock->rl_task = NULL;
+	lock->rl_lock_count = 0;
+	lock->rl_blocking_ranges = 0;
+	lock->rl_sequence = 0;
+}
+
+static inline struct range_lock *next_lock(struct range_lock *lock)
+{
+	return list_entry(lock->rl_next_lock.next, typeof(*lock), rl_next_lock);
+}
+
+/**
+ * Helper function of range_unlock()
+ *
+ * \param node [in]	a range lock found overlapped during interval node
+ *			search
+ * \param arg [in]	the range lock to be tested
+ *
+ * \retval INTERVAL_ITER_CONT	indicate to continue the search for next
+ *				overlapping range node
+ * \retval INTERVAL_ITER_STOP	indicate to stop the search
+ */
+static enum interval_iter range_unlock_cb(struct interval_node *node, void *arg)
+{
+	struct range_lock *lock = arg;
+	struct range_lock *overlap = node2rangelock(node);
+	struct range_lock *iter;
+
+	list_for_each_entry(iter, &overlap->rl_next_lock, rl_next_lock) {
+		if (iter->rl_sequence > lock->rl_sequence) {
+			--iter->rl_blocking_ranges;
+			LASSERT(iter->rl_blocking_ranges > 0);
+		}
+	}
+	if (overlap->rl_sequence > lock->rl_sequence) {
+		--overlap->rl_blocking_ranges;
+		if (overlap->rl_blocking_ranges == 0)
+			wake_up_process(overlap->rl_task);
+	}
+	return INTERVAL_ITER_CONT;
+}
+
+/**
+ * Unlock a range lock, wake up locks blocked by this lock.
+ *
+ * \param tree [in]	range lock tree
+ * \param lock [in]	range lock to be deleted
+ *
+ * If this lock has been granted, relase it; if not, just delete it from
+ * the tree or the same region lock list. Wake up those locks only blocked
+ * by this lock through range_unlock_cb().
+ */
+void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	spin_lock(&tree->rlt_lock);
+	if (!list_empty(&lock->rl_next_lock)) {
+		struct range_lock *next;
+
+		if (interval_is_intree(&lock->rl_node)) { /* first lock */
+			/* Insert the next same range lock into the tree */
+			next = next_lock(lock);
+			next->rl_lock_count = lock->rl_lock_count - 1;
+			interval_erase(&lock->rl_node, &tree->rlt_root);
+			interval_insert(&next->rl_node, &tree->rlt_root);
+		} else {
+			/* find the first lock in tree */
+			list_for_each_entry(next, &lock->rl_next_lock,
+					    rl_next_lock) {
+				if (!interval_is_intree(&next->rl_node))
+					continue;
+
+				LASSERT(next->rl_lock_count > 0);
+				next->rl_lock_count--;
+				break;
+			}
+		}
+		list_del_init(&lock->rl_next_lock);
+	} else {
+		LASSERT(interval_is_intree(&lock->rl_node));
+		interval_erase(&lock->rl_node, &tree->rlt_root);
+	}
+
+	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
+			range_unlock_cb, lock);
+	spin_unlock(&tree->rlt_lock);
+}
+
+/**
+ * Helper function of range_lock()
+ *
+ * \param node [in]	a range lock found overlapped during interval node
+ *			search
+ * \param arg [in]	the range lock to be tested
+ *
+ * \retval INTERVAL_ITER_CONT	indicate to continue the search for next
+ *				overlapping range node
+ * \retval INTERVAL_ITER_STOP	indicate to stop the search
+ */
+static enum interval_iter range_lock_cb(struct interval_node *node, void *arg)
+{
+	struct range_lock *lock = (struct range_lock *)arg;
+	struct range_lock *overlap = node2rangelock(node);
+
+	lock->rl_blocking_ranges += overlap->rl_lock_count + 1;
+	return INTERVAL_ITER_CONT;
+}
+
+/**
+ * Lock a region
+ *
+ * \param tree [in]	range lock tree
+ * \param lock [in]	range lock node containing the region span
+ *
+ * \retval 0	get the range lock
+ * \retval <0	error code while not getting the range lock
+ *
+ * If there exists overlapping range lock, the new lock will wait and
+ * retry, if later it find that it is not the chosen one to wake up,
+ * it wait again.
+ */
+int range_lock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	struct interval_node *node;
+	int rc = 0;
+
+	spin_lock(&tree->rlt_lock);
+	/*
+	 * We need to check for all conflicting intervals
+	 * already in the tree.
+	 */
+	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
+			range_lock_cb, lock);
+	/*
+	 * Insert to the tree if I am unique, otherwise I've been linked to
+	 * the rl_next_lock of another lock which has the same range as mine
+	 * in range_lock_cb().
+	 */
+	node = interval_insert(&lock->rl_node, &tree->rlt_root);
+	if (node) {
+		struct range_lock *tmp = node2rangelock(node);
+
+		list_add_tail(&lock->rl_next_lock, &tmp->rl_next_lock);
+		tmp->rl_lock_count++;
+	}
+	lock->rl_sequence = ++tree->rlt_sequence;
+
+	while (lock->rl_blocking_ranges > 0) {
+		lock->rl_task = current;
+		__set_current_state(TASK_INTERRUPTIBLE);
+		spin_unlock(&tree->rlt_lock);
+		schedule();
+
+		if (signal_pending(current)) {
+			range_unlock(tree, lock);
+			rc = -EINTR;
+			goto out;
+		}
+		spin_lock(&tree->rlt_lock);
+	}
+	spin_unlock(&tree->rlt_lock);
+out:
+	return rc;
+}
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
new file mode 100644
index 0000000..c6d04a6
--- /dev/null
+++ b/drivers/staging/lustre/lustre/llite/range_lock.h
@@ -0,0 +1,82 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Range lock is used to allow multiple threads writing a single shared
+ * file given each thread is writing to a non-overlapping portion of the
+ * file.
+ *
+ * Refer to the possible upstream kernel version of range lock by
+ * Jan Kara <jack@suse.cz>: https://lkml.org/lkml/2013/1/31/480
+ *
+ * This file could later replaced by the upstream kernel version.
+ */
+/*
+ * Author: Prakash Surya <surya1@llnl.gov>
+ * Author: Bobi Jam <bobijam.xu@intel.com>
+ */
+#ifndef _RANGE_LOCK_H
+#define _RANGE_LOCK_H
+
+#include "../../include/linux/libcfs/libcfs.h"
+#include "../include/interval_tree.h"
+
+struct range_lock {
+	struct interval_node	rl_node;
+	/**
+	 * Process to enqueue this lock.
+	 */
+	struct task_struct	*rl_task;
+	/**
+	 * List of locks with the same range.
+	 */
+	struct list_head	rl_next_lock;
+	/**
+	 * Number of locks in the list rl_next_lock
+	 */
+	unsigned int		rl_lock_count;
+	/**
+	 * Number of ranges which are blocking acquisition of the lock
+	 */
+	unsigned int		rl_blocking_ranges;
+	/**
+	 * Sequence number of range lock. This number is used to get to know
+	 * the order the locks are queued; this is required for range_cancel().
+	 */
+	__u64			rl_sequence;
+};
+
+static inline struct range_lock *node2rangelock(const struct interval_node *n)
+{
+	return container_of(n, struct range_lock, rl_node);
+}
+
+struct range_lock_tree {
+	struct interval_node	*rlt_root;
+	spinlock_t		 rlt_lock;	/* protect range lock tree */
+	__u64			 rlt_sequence;
+};
+
+void range_lock_tree_init(struct range_lock_tree *tree);
+void range_lock_init(struct range_lock *lock, __u64 start, __u64 end);
+int  range_lock(struct range_lock_tree *tree, struct range_lock *lock);
+void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
+#endif
-- 
1.7.1
