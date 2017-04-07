From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 7 Apr 2017 10:08:18 +0000
Subject: [lustre-devel] [PATCH 6/6] staging/lustre: Use generic range
	rwlock
In-Reply-To: <20170406084620.22700-7-dave@stgolabs.net>
References: <20170406084620.22700-1-dave@stgolabs.net>
	<20170406084620.22700-7-dave@stgolabs.net>
Message-ID: <2BBAD983-69DA-47B4-9879-9B503CF86B6B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "jack@suse.cz" <jack@suse.cz>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "ldufour@linux.vnet.ibm.com" <ldufour@linux.vnet.ibm.com>, "mhocko@suse.com" <mhocko@suse.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "jsimmons@infradead.org" <jsimmons@infradead.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, Davidlohr Bueso <dbueso@suse.de>

On Apr 6, 2017, at 02:46, Davidlohr Bueso <dave@stgolabs.net> wrote:
> 
> This replaces the in-house version, which is also derived
> from Jan's interval tree implementation.
> 
> Cc: oleg.drokin at intel.com
> Cc: andreas.dilger at intel.com
> Cc: jsimmons at infradead.org
> Cc: lustre-devel at lists.lustre.org
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

This patch looks fine, but it would probably be better to also post the whole series on
linux-fsdevel for further review.

Cheers, Andreas

> ---
> drivers/staging/lustre/lustre/llite/Makefile       |   2 +-
> drivers/staging/lustre/lustre/llite/file.c         |  21 +-
> .../staging/lustre/lustre/llite/llite_internal.h   |   4 +-
> drivers/staging/lustre/lustre/llite/llite_lib.c    |   3 +-
> drivers/staging/lustre/lustre/llite/range_lock.c   | 239 ---------------------
> drivers/staging/lustre/lustre/llite/range_lock.h   |  82 -------
> 6 files changed, 15 insertions(+), 336 deletions(-)
> delete mode 100644 drivers/staging/lustre/lustre/llite/range_lock.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/range_lock.h
> 
> diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
> index 322d4fa63f5d..922a901bc62c 100644
> --- a/drivers/staging/lustre/lustre/llite/Makefile
> +++ b/drivers/staging/lustre/lustre/llite/Makefile
> @@ -1,6 +1,6 @@
> obj-$(CONFIG_LUSTRE_FS) += lustre.o
> lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
> -	    rw.o rw26.o namei.o symlink.o llite_mmap.o range_lock.o \
> +	    rw.o rw26.o namei.o symlink.o llite_mmap.o \
> 	    xattr.o xattr_cache.o xattr_security.o \
> 	    super25.o statahead.o glimpse.o lcommon_cl.o lcommon_misc.o \
> 	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o \
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index 481c0d01d4c6..1a14a79f87f8 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -42,6 +42,7 @@
> #include <linux/file.h>
> #include <linux/sched.h>
> #include <linux/mount.h>
> +#include <linux/range_rwlock.h>
> #include "../include/lustre/ll_fiemap.h"
> #include "../include/lustre/lustre_ioctl.h"
> #include "../include/lustre_swab.h"
> @@ -1055,7 +1056,7 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
> 	struct ll_inode_info *lli = ll_i2info(file_inode(file));
> 	struct ll_file_data  *fd  = LUSTRE_FPRIVATE(file);
> 	struct vvp_io *vio = vvp_env_io(env);
> -	struct range_lock range;
> +	struct range_rwlock range;
> 	struct cl_io	 *io;
> 	ssize_t result = 0;
> 	int rc = 0;
> @@ -1072,9 +1073,9 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
> 		bool range_locked = false;
> 
> 		if (file->f_flags & O_APPEND)
> -			range_lock_init(&range, 0, LUSTRE_EOF);
> +			range_rwlock_init(&range, 0, LUSTRE_EOF);
> 		else
> -			range_lock_init(&range, *ppos, *ppos + count - 1);
> +			range_rwlock_init(&range, *ppos, *ppos + count - 1);
> 
> 		vio->vui_fd  = LUSTRE_FPRIVATE(file);
> 		vio->vui_iter = args->u.normal.via_iter;
> @@ -1087,10 +1088,9 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
> 		if (((iot == CIT_WRITE) ||
> 		     (iot == CIT_READ && (file->f_flags & O_DIRECT))) &&
> 		    !(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
> -			CDEBUG(D_VFSTRACE, "Range lock [%llu, %llu]\n",
> -			       range.rl_node.in_extent.start,
> -			       range.rl_node.in_extent.end);
> -			rc = range_lock(&lli->lli_write_tree, &range);
> +			CDEBUG(D_VFSTRACE, "Range lock [%lu, %lu]\n",
> +			       range.node.start, range.node.last);
> +			rc = range_write_lock_interruptible(&lli->lli_write_tree, &range);
> 			if (rc < 0)
> 				goto out;
> 
> @@ -1100,10 +1100,9 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
> 		rc = cl_io_loop(env, io);
> 		ll_cl_remove(file, env);
> 		if (range_locked) {
> -			CDEBUG(D_VFSTRACE, "Range unlock [%llu, %llu]\n",
> -			       range.rl_node.in_extent.start,
> -			       range.rl_node.in_extent.end);
> -			range_unlock(&lli->lli_write_tree, &range);
> +			CDEBUG(D_VFSTRACE, "Range unlock [%lu, %lu]\n",
> +			       range.node.start, range.node.last);
> +			range_write_unlock(&lli->lli_write_tree, &range);
> 		}
> 	} else {
> 		/* cl_io_rw_init() handled IO */
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index 55f68acd85d1..aa2ae72e3e70 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -49,8 +49,8 @@
> #include <linux/namei.h>
> #include <linux/xattr.h>
> #include <linux/posix_acl_xattr.h>
> +#include <linux/range_rwlock.h>
> #include "vvp_internal.h"
> -#include "range_lock.h"
> 
> #ifndef FMODE_EXEC
> #define FMODE_EXEC 0
> @@ -193,7 +193,7 @@ struct ll_inode_info {
> 			 * }
> 			 */
> 			struct rw_semaphore		lli_trunc_sem;
> -			struct range_lock_tree		lli_write_tree;
> +			struct range_rwlock_tree	lli_write_tree;
> 
> 			struct rw_semaphore		lli_glimpse_sem;
> 			unsigned long			lli_glimpse_time;
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index b229cbc7bb33..8054e916b3f5 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -40,6 +40,7 @@
> #include <linux/statfs.h>
> #include <linux/types.h>
> #include <linux/mm.h>
> +#include <linux/range_rwlock.h>
> 
> #include "../include/lustre/lustre_ioctl.h"
> #include "../include/lustre_ha.h"
> @@ -853,7 +854,7 @@ void ll_lli_init(struct ll_inode_info *lli)
> 		mutex_init(&lli->lli_size_mutex);
> 		lli->lli_symlink_name = NULL;
> 		init_rwsem(&lli->lli_trunc_sem);
> -		range_lock_tree_init(&lli->lli_write_tree);
> +		range_rwlock_tree_init(&lli->lli_write_tree);
> 		init_rwsem(&lli->lli_glimpse_sem);
> 		lli->lli_glimpse_time = 0;
> 		INIT_LIST_HEAD(&lli->lli_agl_list);
> diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
> deleted file mode 100644
> index 14148a097476..000000000000
> --- a/drivers/staging/lustre/lustre/llite/range_lock.c
> +++ /dev/null
> @@ -1,239 +0,0 @@
> -/*
> - * GPL HEADER START
> - *
> - * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 only,
> - * as published by the Free Software Foundation.
> - *
> - * This program is distributed in the hope that it will be useful, but
> - * WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> - * General Public License version 2 for more details (a copy is included
> - * in the LICENSE file that accompanied this code).
> - *
> - * You should have received a copy of the GNU General Public License
> - * version 2 along with this program; If not, see
> - * http://www.gnu.org/licenses/gpl-2.0.html
> - *
> - * GPL HEADER END
> - */
> -/*
> - * Range lock is used to allow multiple threads writing a single shared
> - * file given each thread is writing to a non-overlapping portion of the
> - * file.
> - *
> - * Refer to the possible upstream kernel version of range lock by
> - * Jan Kara <jack@suse.cz>: https://lkml.org/lkml/2013/1/31/480
> - *
> - * This file could later replaced by the upstream kernel version.
> - */
> -/*
> - * Author: Prakash Surya <surya1@llnl.gov>
> - * Author: Bobi Jam <bobijam.xu@intel.com>
> - */
> -#include "range_lock.h"
> -#include "../include/lustre/lustre_user.h"
> -
> -/**
> - * Initialize a range lock tree
> - *
> - * \param tree [in]	an empty range lock tree
> - *
> - * Pre:  Caller should have allocated the range lock tree.
> - * Post: The range lock tree is ready to function.
> - */
> -void range_lock_tree_init(struct range_lock_tree *tree)
> -{
> -	tree->rlt_root = NULL;
> -	tree->rlt_sequence = 0;
> -	spin_lock_init(&tree->rlt_lock);
> -}
> -
> -/**
> - * Initialize a range lock node
> - *
> - * \param lock  [in]	an empty range lock node
> - * \param start [in]	start of the covering region
> - * \param end   [in]	end of the covering region
> - *
> - * Pre:  Caller should have allocated the range lock node.
> - * Post: The range lock node is meant to cover [start, end] region
> - */
> -int range_lock_init(struct range_lock *lock, __u64 start, __u64 end)
> -{
> -	int rc;
> -
> -	memset(&lock->rl_node, 0, sizeof(lock->rl_node));
> -	if (end != LUSTRE_EOF)
> -		end >>= PAGE_SHIFT;
> -	rc = interval_set(&lock->rl_node, start >> PAGE_SHIFT, end);
> -	if (rc)
> -		return rc;
> -
> -	INIT_LIST_HEAD(&lock->rl_next_lock);
> -	lock->rl_task = NULL;
> -	lock->rl_lock_count = 0;
> -	lock->rl_blocking_ranges = 0;
> -	lock->rl_sequence = 0;
> -	return rc;
> -}
> -
> -static inline struct range_lock *next_lock(struct range_lock *lock)
> -{
> -	return list_entry(lock->rl_next_lock.next, typeof(*lock), rl_next_lock);
> -}
> -
> -/**
> - * Helper function of range_unlock()
> - *
> - * \param node [in]	a range lock found overlapped during interval node
> - *			search
> - * \param arg [in]	the range lock to be tested
> - *
> - * \retval INTERVAL_ITER_CONT	indicate to continue the search for next
> - *				overlapping range node
> - * \retval INTERVAL_ITER_STOP	indicate to stop the search
> - */
> -static enum interval_iter range_unlock_cb(struct interval_node *node, void *arg)
> -{
> -	struct range_lock *lock = arg;
> -	struct range_lock *overlap = node2rangelock(node);
> -	struct range_lock *iter;
> -
> -	list_for_each_entry(iter, &overlap->rl_next_lock, rl_next_lock) {
> -		if (iter->rl_sequence > lock->rl_sequence) {
> -			--iter->rl_blocking_ranges;
> -			LASSERT(iter->rl_blocking_ranges > 0);
> -		}
> -	}
> -	if (overlap->rl_sequence > lock->rl_sequence) {
> -		--overlap->rl_blocking_ranges;
> -		if (overlap->rl_blocking_ranges == 0)
> -			wake_up_process(overlap->rl_task);
> -	}
> -	return INTERVAL_ITER_CONT;
> -}
> -
> -/**
> - * Unlock a range lock, wake up locks blocked by this lock.
> - *
> - * \param tree [in]	range lock tree
> - * \param lock [in]	range lock to be deleted
> - *
> - * If this lock has been granted, relase it; if not, just delete it from
> - * the tree or the same region lock list. Wake up those locks only blocked
> - * by this lock through range_unlock_cb().
> - */
> -void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
> -{
> -	spin_lock(&tree->rlt_lock);
> -	if (!list_empty(&lock->rl_next_lock)) {
> -		struct range_lock *next;
> -
> -		if (interval_is_intree(&lock->rl_node)) { /* first lock */
> -			/* Insert the next same range lock into the tree */
> -			next = next_lock(lock);
> -			next->rl_lock_count = lock->rl_lock_count - 1;
> -			interval_erase(&lock->rl_node, &tree->rlt_root);
> -			interval_insert(&next->rl_node, &tree->rlt_root);
> -		} else {
> -			/* find the first lock in tree */
> -			list_for_each_entry(next, &lock->rl_next_lock,
> -					    rl_next_lock) {
> -				if (!interval_is_intree(&next->rl_node))
> -					continue;
> -
> -				LASSERT(next->rl_lock_count > 0);
> -				next->rl_lock_count--;
> -				break;
> -			}
> -		}
> -		list_del_init(&lock->rl_next_lock);
> -	} else {
> -		LASSERT(interval_is_intree(&lock->rl_node));
> -		interval_erase(&lock->rl_node, &tree->rlt_root);
> -	}
> -
> -	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
> -			range_unlock_cb, lock);
> -	spin_unlock(&tree->rlt_lock);
> -}
> -
> -/**
> - * Helper function of range_lock()
> - *
> - * \param node [in]	a range lock found overlapped during interval node
> - *			search
> - * \param arg [in]	the range lock to be tested
> - *
> - * \retval INTERVAL_ITER_CONT	indicate to continue the search for next
> - *				overlapping range node
> - * \retval INTERVAL_ITER_STOP	indicate to stop the search
> - */
> -static enum interval_iter range_lock_cb(struct interval_node *node, void *arg)
> -{
> -	struct range_lock *lock = (struct range_lock *)arg;
> -	struct range_lock *overlap = node2rangelock(node);
> -
> -	lock->rl_blocking_ranges += overlap->rl_lock_count + 1;
> -	return INTERVAL_ITER_CONT;
> -}
> -
> -/**
> - * Lock a region
> - *
> - * \param tree [in]	range lock tree
> - * \param lock [in]	range lock node containing the region span
> - *
> - * \retval 0	get the range lock
> - * \retval <0	error code while not getting the range lock
> - *
> - * If there exists overlapping range lock, the new lock will wait and
> - * retry, if later it find that it is not the chosen one to wake up,
> - * it wait again.
> - */
> -int range_lock(struct range_lock_tree *tree, struct range_lock *lock)
> -{
> -	struct interval_node *node;
> -	int rc = 0;
> -
> -	spin_lock(&tree->rlt_lock);
> -	/*
> -	 * We need to check for all conflicting intervals
> -	 * already in the tree.
> -	 */
> -	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
> -			range_lock_cb, lock);
> -	/*
> -	 * Insert to the tree if I am unique, otherwise I've been linked to
> -	 * the rl_next_lock of another lock which has the same range as mine
> -	 * in range_lock_cb().
> -	 */
> -	node = interval_insert(&lock->rl_node, &tree->rlt_root);
> -	if (node) {
> -		struct range_lock *tmp = node2rangelock(node);
> -
> -		list_add_tail(&lock->rl_next_lock, &tmp->rl_next_lock);
> -		tmp->rl_lock_count++;
> -	}
> -	lock->rl_sequence = ++tree->rlt_sequence;
> -
> -	while (lock->rl_blocking_ranges > 0) {
> -		lock->rl_task = current;
> -		__set_current_state(TASK_INTERRUPTIBLE);
> -		spin_unlock(&tree->rlt_lock);
> -		schedule();
> -
> -		if (signal_pending(current)) {
> -			range_unlock(tree, lock);
> -			rc = -EINTR;
> -			goto out;
> -		}
> -		spin_lock(&tree->rlt_lock);
> -	}
> -	spin_unlock(&tree->rlt_lock);
> -out:
> -	return rc;
> -}
> diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
> deleted file mode 100644
> index 779091ccec4e..000000000000
> --- a/drivers/staging/lustre/lustre/llite/range_lock.h
> +++ /dev/null
> @@ -1,82 +0,0 @@
> -/*
> - * GPL HEADER START
> - *
> - * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 only,
> - * as published by the Free Software Foundation.
> - *
> - * This program is distributed in the hope that it will be useful, but
> - * WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> - * General Public License version 2 for more details (a copy is included
> - * in the LICENSE file that accompanied this code).
> - *
> - * You should have received a copy of the GNU General Public License
> - * version 2 along with this program; If not, see
> - * http://www.gnu.org/licenses/gpl-2.0.html
> - *
> - * GPL HEADER END
> - */
> -/*
> - * Range lock is used to allow multiple threads writing a single shared
> - * file given each thread is writing to a non-overlapping portion of the
> - * file.
> - *
> - * Refer to the possible upstream kernel version of range lock by
> - * Jan Kara <jack@suse.cz>: https://lkml.org/lkml/2013/1/31/480
> - *
> - * This file could later replaced by the upstream kernel version.
> - */
> -/*
> - * Author: Prakash Surya <surya1@llnl.gov>
> - * Author: Bobi Jam <bobijam.xu@intel.com>
> - */
> -#ifndef _RANGE_LOCK_H
> -#define _RANGE_LOCK_H
> -
> -#include "../../include/linux/libcfs/libcfs.h"
> -#include "../include/interval_tree.h"
> -
> -struct range_lock {
> -	struct interval_node	rl_node;
> -	/**
> -	 * Process to enqueue this lock.
> -	 */
> -	struct task_struct	*rl_task;
> -	/**
> -	 * List of locks with the same range.
> -	 */
> -	struct list_head	rl_next_lock;
> -	/**
> -	 * Number of locks in the list rl_next_lock
> -	 */
> -	unsigned int		rl_lock_count;
> -	/**
> -	 * Number of ranges which are blocking acquisition of the lock
> -	 */
> -	unsigned int		rl_blocking_ranges;
> -	/**
> -	 * Sequence number of range lock. This number is used to get to know
> -	 * the order the locks are queued; this is required for range_cancel().
> -	 */
> -	__u64			rl_sequence;
> -};
> -
> -static inline struct range_lock *node2rangelock(const struct interval_node *n)
> -{
> -	return container_of(n, struct range_lock, rl_node);
> -}
> -
> -struct range_lock_tree {
> -	struct interval_node	*rlt_root;
> -	spinlock_t		 rlt_lock;	/* protect range lock tree */
> -	__u64			 rlt_sequence;
> -};
> -
> -void range_lock_tree_init(struct range_lock_tree *tree);
> -int range_lock_init(struct range_lock *lock, __u64 start, __u64 end);
> -int  range_lock(struct range_lock_tree *tree, struct range_lock *lock);
> -void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
> -#endif
> -- 
> 2.12.0
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
