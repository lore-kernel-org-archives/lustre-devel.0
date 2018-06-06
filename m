From: NeilBrown <neilb@suse.com>
Date: Wed, 06 Jun 2018 16:05:19 +1000
Subject: [lustre-devel] [PATCH 10/11] staging: lustre: move ldlm into ptlrpc
In-Reply-To: <152826510267.16761.14361003167157833896.stgit@noble>
References: <152826510267.16761.14361003167157833896.stgit@noble>
Message-ID: <152826511923.16761.9237280635711887801.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The ldlm code is built into the ptlrpc module, yet it lived in a
separate directory.  This requires filename editing in the Makefile
and make it difficult to e.g. build the .s file for code in ldlm.

All the ldlm files have distinctive names so confusion from having
ptlrpc and ldlm in the same directory is unlikely.  So move them all
into ptlrpc.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |   73 -
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  206 --
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  486 -----
 .../staging/lustre/lustre/ldlm/ldlm_inodebits.c    |   69 -
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  329 ---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  842 --------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 2103 --------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 1154 -----------
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c    |   68 -
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 1013 ----------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 2033 -------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 1318 -------------
 drivers/staging/lustre/lustre/ptlrpc/Makefile      |   14 
 drivers/staging/lustre/lustre/ptlrpc/l_lock.c      |   73 +
 drivers/staging/lustre/lustre/ptlrpc/ldlm_extent.c |  206 ++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_flock.c  |  486 +++++
 .../staging/lustre/lustre/ptlrpc/ldlm_inodebits.c  |   69 +
 .../staging/lustre/lustre/ptlrpc/ldlm_internal.h   |  329 +++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_lib.c    |  842 ++++++++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_lock.c   | 2103 ++++++++++++++++++++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_lockd.c  | 1154 +++++++++++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_plain.c  |   68 +
 drivers/staging/lustre/lustre/ptlrpc/ldlm_pool.c   | 1013 ++++++++++
 .../staging/lustre/lustre/ptlrpc/ldlm_request.c    | 2033 +++++++++++++++++++
 .../staging/lustre/lustre/ptlrpc/ldlm_resource.c   | 1318 +++++++++++++
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    2 
 26 files changed, 9702 insertions(+), 9702 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/l_lock.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_request.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/l_lock.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_extent.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_flock.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_inodebits.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_internal.h
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_lib.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_lock.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_lockd.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_plain.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_pool.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_request.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_resource.c

diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
deleted file mode 100644
index 296259aa51e6..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
+++ /dev/null
@@ -1,73 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-
-#include <lustre_dlm.h>
-#include <lustre_lib.h>
-
-/**
- * Lock a lock and its resource.
- *
- * LDLM locking uses resource to serialize access to locks
- * but there is a case when we change resource of lock upon
- * enqueue reply. We rely on lock->l_resource = new_res
- * being an atomic operation.
- */
-struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
-				__acquires(&lock->l_lock)
-				__acquires(&lock->l_resource->lr_lock)
-{
-	spin_lock(&lock->l_lock);
-
-	lock_res(lock->l_resource);
-
-	ldlm_set_res_locked(lock);
-	return lock->l_resource;
-}
-EXPORT_SYMBOL(lock_res_and_lock);
-
-/**
- * Unlock a lock and its resource previously locked with lock_res_and_lock
- */
-void unlock_res_and_lock(struct ldlm_lock *lock)
-		__releases(&lock->l_resource->lr_lock)
-		__releases(&lock->l_lock)
-{
-	/* on server-side resource of lock doesn't change */
-	ldlm_clear_res_locked(lock);
-
-	unlock_res(lock->l_resource);
-	spin_unlock(&lock->l_lock);
-}
-EXPORT_SYMBOL(unlock_res_and_lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
deleted file mode 100644
index 225c023b0bba..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ /dev/null
@@ -1,206 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2010, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/ldlm/ldlm_extent.c
- *
- * Author: Peter Braam <braam@clusterfs.com>
- * Author: Phil Schwan <phil@clusterfs.com>
- */
-
-/**
- * This file contains implementation of EXTENT lock type
- *
- * EXTENT lock type is for locking a contiguous range of values, represented
- * by 64-bit starting and ending offsets (inclusive). There are several extent
- * lock modes, some of which may be mutually incompatible. Extent locks are
- * considered incompatible if their modes are incompatible and their extents
- * intersect.  See the lock mode compatibility matrix in lustre_dlm.h.
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-#include <lustre_dlm.h>
-#include <obd_support.h>
-#include <obd.h>
-#include <obd_class.h>
-#include <lustre_lib.h>
-#include "ldlm_internal.h"
-#include <linux/interval_tree_generic.h>
-
-#define START(node) ((node)->l_policy_data.l_extent.start)
-#define LAST(node) ((node)->l_policy_data.l_extent.end)
-INTERVAL_TREE_DEFINE(struct ldlm_lock, l_rb, __u64, __subtree_last,
-		     START, LAST, static, extent);
-
-/* When a lock is cancelled by a client, the KMS may undergo change if this
- * is the "highest lock".  This function returns the new KMS value.
- * Caller must hold lr_lock already.
- *
- * NB: A lock on [x,y] protects a KMS of up to y + 1 bytes!
- */
-__u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
-{
-	struct ldlm_resource *res = lock->l_resource;
-	struct ldlm_lock *lck;
-	__u64 kms = 0;
-
-	/* don't let another thread in ldlm_extent_shift_kms race in
-	 * just after we finish and take our lock into account in its
-	 * calculation of the kms
-	 */
-	ldlm_set_kms_ignore(lock);
-
-	list_for_each_entry(lck, &res->lr_granted, l_res_link) {
-
-		if (ldlm_is_kms_ignore(lck))
-			continue;
-
-		if (lck->l_policy_data.l_extent.end >= old_kms)
-			return old_kms;
-
-		/* This extent _has_ to be smaller than old_kms (checked above)
-		 * so kms can only ever be smaller or the same as old_kms.
-		 */
-		if (lck->l_policy_data.l_extent.end + 1 > kms)
-			kms = lck->l_policy_data.l_extent.end + 1;
-	}
-	LASSERTF(kms <= old_kms, "kms %llu old_kms %llu\n", kms, old_kms);
-
-	return kms;
-}
-EXPORT_SYMBOL(ldlm_extent_shift_kms);
-
-static inline int lock_mode_to_index(enum ldlm_mode mode)
-{
-	int index;
-
-	LASSERT(mode != 0);
-	LASSERT(is_power_of_2(mode));
-	for (index = -1; mode; index++)
-		mode >>= 1;
-	LASSERT(index < LCK_MODE_NUM);
-	return index;
-}
-
-/** Add newly granted lock into interval tree for the resource. */
-void ldlm_extent_add_lock(struct ldlm_resource *res,
-			  struct ldlm_lock *lock)
-{
-	struct ldlm_interval_tree *tree;
-	int idx;
-
-	LASSERT(lock->l_granted_mode == lock->l_req_mode);
-
-	LASSERT(RB_EMPTY_NODE(&lock->l_rb));
-
-	idx = lock_mode_to_index(lock->l_granted_mode);
-	LASSERT(lock->l_granted_mode == 1 << idx);
-	LASSERT(lock->l_granted_mode == res->lr_itree[idx].lit_mode);
-
-	tree = &res->lr_itree[idx];
-	extent_insert(lock, &tree->lit_root);
-	tree->lit_size++;
-
-	/* even though we use interval tree to manage the extent lock, we also
-	 * add the locks into grant list, for debug purpose, ..
-	 */
-	ldlm_resource_add_lock(res, &res->lr_granted, lock);
-
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_GRANT_CHECK)) {
-		struct ldlm_lock *lck;
-
-		list_for_each_entry_reverse(lck, &res->lr_granted,
-					    l_res_link) {
-			if (lck == lock)
-				continue;
-			if (lockmode_compat(lck->l_granted_mode,
-					    lock->l_granted_mode))
-				continue;
-			if (ldlm_extent_overlap(&lck->l_req_extent,
-						&lock->l_req_extent)) {
-				CDEBUG(D_ERROR,
-				       "granting conflicting lock %p %p\n",
-				       lck, lock);
-				ldlm_resource_dump(D_ERROR, res);
-				LBUG();
-			}
-		}
-	}
-}
-
-/** Remove cancelled lock from resource interval tree. */
-void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
-{
-	struct ldlm_resource *res = lock->l_resource;
-	struct ldlm_interval_tree *tree;
-	int idx;
-
-	if (RB_EMPTY_NODE(&lock->l_rb)) /* duplicate unlink */
-		return;
-
-	idx = lock_mode_to_index(lock->l_granted_mode);
-	LASSERT(lock->l_granted_mode == 1 << idx);
-	tree = &res->lr_itree[idx];
-
-	tree->lit_size--;
-	extent_remove(lock, &tree->lit_root);
-}
-
-void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				      union ldlm_policy_data *lpolicy)
-{
-	lpolicy->l_extent.start = wpolicy->l_extent.start;
-	lpolicy->l_extent.end = wpolicy->l_extent.end;
-	lpolicy->l_extent.gid = wpolicy->l_extent.gid;
-}
-
-void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				      union ldlm_wire_policy_data *wpolicy)
-{
-	memset(wpolicy, 0, sizeof(*wpolicy));
-	wpolicy->l_extent.start = lpolicy->l_extent.start;
-	wpolicy->l_extent.end = lpolicy->l_extent.end;
-	wpolicy->l_extent.gid = lpolicy->l_extent.gid;
-}
-
-void ldlm_extent_search(struct rb_root_cached *root,
-			__u64 start, __u64 end,
-			bool (*matches)(struct ldlm_lock *lock, void *data),
-			void *data)
-{
-	struct ldlm_lock *lock;
-
-	for (lock = extent_iter_first(root, start, end);
-	     lock;
-	     lock = extent_iter_next(lock, start, end))
-		if (matches(lock, data))
-			break;
-}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
deleted file mode 100644
index 94f3b1e49896..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ /dev/null
@@ -1,486 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2003 Hewlett-Packard Development Company LP.
- * Developed under the sponsorship of the US Government under
- * Subcontract No. B514193
- *
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2010, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-/**
- * This file implements POSIX lock type for Lustre.
- * Its policy properties are start and end of extent and PID.
- *
- * These locks are only done through MDS due to POSIX semantics requiring
- * e.g. that locks could be only partially released and as such split into
- * two parts, and also that two adjacent locks from the same process may be
- * merged into a single wider lock.
- *
- * Lock modes are mapped like this:
- * PR and PW for READ and WRITE locks
- * NL to request a releasing of a portion of the lock
- *
- * These flock locks never timeout.
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-
-#include <lustre_dlm.h>
-#include <obd_support.h>
-#include <obd_class.h>
-#include <lustre_lib.h>
-#include <linux/list.h>
-#include "ldlm_internal.h"
-
-static inline int
-ldlm_same_flock_owner(struct ldlm_lock *lock, struct ldlm_lock *new)
-{
-	return((new->l_policy_data.l_flock.owner ==
-		lock->l_policy_data.l_flock.owner) &&
-	       (new->l_export == lock->l_export));
-}
-
-static inline int
-ldlm_flocks_overlap(struct ldlm_lock *lock, struct ldlm_lock *new)
-{
-	return((new->l_policy_data.l_flock.start <=
-		lock->l_policy_data.l_flock.end) &&
-	       (new->l_policy_data.l_flock.end >=
-		lock->l_policy_data.l_flock.start));
-}
-
-static inline void
-ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode)
-{
-	LDLM_DEBUG(lock, "%s(mode: %d)",
-		   __func__, mode);
-
-	list_del_init(&lock->l_res_link);
-
-	/* client side - set a flag to prevent sending a CANCEL */
-	lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_CBPENDING;
-
-	/* when reaching here, it is under lock_res_and_lock(). Thus,
-	 * need call the nolock version of ldlm_lock_decref_internal
-	 */
-	ldlm_lock_decref_internal_nolock(lock, mode);
-
-	ldlm_lock_destroy_nolock(lock);
-}
-
-/**
- * Process a granting attempt for flock lock.
- * Must be called under ns lock held.
- *
- * This function looks for any conflicts for \a lock in the granted or
- * waiting queues. The lock is granted if no conflicts are found in
- * either queue.
- *
- * It is also responsible for splitting a lock if a portion of the lock
- * is released.
- *
- */
-static int ldlm_process_flock_lock(struct ldlm_lock *req)
-{
-	struct ldlm_resource *res = req->l_resource;
-	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
-	struct ldlm_lock *tmp;
-	struct ldlm_lock *lock;
-	struct ldlm_lock *new = req;
-	struct ldlm_lock *new2 = NULL;
-	enum ldlm_mode mode = req->l_req_mode;
-	int added = (mode == LCK_NL);
-	int splitted = 0;
-	const struct ldlm_callback_suite null_cbs = { };
-
-	CDEBUG(D_DLMTRACE,
-	       "owner %llu pid %u mode %u start %llu end %llu\n",
-	       new->l_policy_data.l_flock.owner,
-	       new->l_policy_data.l_flock.pid, mode,
-	       req->l_policy_data.l_flock.start,
-	       req->l_policy_data.l_flock.end);
-
-	/* No blocking ASTs are sent to the clients for
-	 * Posix file & record locks
-	 */
-	req->l_blocking_ast = NULL;
-
-reprocess:
-	/* This loop determines where this processes locks start
-	 * in the resource lr_granted list.
-	 */
-	list_for_each_entry(lock, &res->lr_granted, l_res_link)
-		if (ldlm_same_flock_owner(lock, req))
-			break;
-
-	/* Scan the locks owned by this process to find the insertion point
-	 * (as locks are ordered), and to handle overlaps.
-	 * We may have to merge or split existing locks.
-	 */
-	list_for_each_entry_safe_from(lock, tmp, &res->lr_granted, l_res_link) {
-
-		if (!ldlm_same_flock_owner(lock, new))
-			break;
-
-		if (lock->l_granted_mode == mode) {
-			/* If the modes are the same then we need to process
-			 * locks that overlap OR adjoin the new lock. The extra
-			 * logic condition is necessary to deal with arithmetic
-			 * overflow and underflow.
-			 */
-			if ((new->l_policy_data.l_flock.start >
-			     (lock->l_policy_data.l_flock.end + 1)) &&
-			    (lock->l_policy_data.l_flock.end != OBD_OBJECT_EOF))
-				continue;
-
-			if ((new->l_policy_data.l_flock.end <
-			     (lock->l_policy_data.l_flock.start - 1)) &&
-			    (lock->l_policy_data.l_flock.start != 0))
-				break;
-
-			if (new->l_policy_data.l_flock.start <
-			    lock->l_policy_data.l_flock.start) {
-				lock->l_policy_data.l_flock.start =
-					new->l_policy_data.l_flock.start;
-			} else {
-				new->l_policy_data.l_flock.start =
-					lock->l_policy_data.l_flock.start;
-			}
-
-			if (new->l_policy_data.l_flock.end >
-			    lock->l_policy_data.l_flock.end) {
-				lock->l_policy_data.l_flock.end =
-					new->l_policy_data.l_flock.end;
-			} else {
-				new->l_policy_data.l_flock.end =
-					lock->l_policy_data.l_flock.end;
-			}
-
-			if (added) {
-				ldlm_flock_destroy(lock, mode);
-			} else {
-				new = lock;
-				added = 1;
-			}
-			continue;
-		}
-
-		if (new->l_policy_data.l_flock.start >
-		    lock->l_policy_data.l_flock.end)
-			continue;
-
-		if (new->l_policy_data.l_flock.end <
-		    lock->l_policy_data.l_flock.start)
-			break;
-
-		if (new->l_policy_data.l_flock.start <=
-		    lock->l_policy_data.l_flock.start) {
-			if (new->l_policy_data.l_flock.end <
-			    lock->l_policy_data.l_flock.end) {
-				lock->l_policy_data.l_flock.start =
-					new->l_policy_data.l_flock.end + 1;
-				break;
-			}
-			ldlm_flock_destroy(lock, lock->l_req_mode);
-			continue;
-		}
-		if (new->l_policy_data.l_flock.end >=
-		    lock->l_policy_data.l_flock.end) {
-			lock->l_policy_data.l_flock.end =
-				new->l_policy_data.l_flock.start - 1;
-			continue;
-		}
-
-		/* split the existing lock into two locks */
-
-		/* if this is an F_UNLCK operation then we could avoid
-		 * allocating a new lock and use the req lock passed in
-		 * with the request but this would complicate the reply
-		 * processing since updates to req get reflected in the
-		 * reply. The client side replays the lock request so
-		 * it must see the original lock data in the reply.
-		 */
-
-		/* XXX - if ldlm_lock_new() can sleep we should
-		 * release the lr_lock, allocate the new lock,
-		 * and restart processing this lock.
-		 */
-		if (!new2) {
-			unlock_res_and_lock(req);
-			new2 = ldlm_lock_create(ns, &res->lr_name, LDLM_FLOCK,
-						lock->l_granted_mode, &null_cbs,
-						NULL, 0, LVB_T_NONE);
-			lock_res_and_lock(req);
-			if (IS_ERR(new2)) {
-				ldlm_flock_destroy(req, lock->l_granted_mode);
-				return LDLM_ITER_STOP;
-			}
-			goto reprocess;
-		}
-
-		splitted = 1;
-
-		new2->l_granted_mode = lock->l_granted_mode;
-		new2->l_policy_data.l_flock.pid =
-			new->l_policy_data.l_flock.pid;
-		new2->l_policy_data.l_flock.owner =
-			new->l_policy_data.l_flock.owner;
-		new2->l_policy_data.l_flock.start =
-			lock->l_policy_data.l_flock.start;
-		new2->l_policy_data.l_flock.end =
-			new->l_policy_data.l_flock.start - 1;
-		lock->l_policy_data.l_flock.start =
-			new->l_policy_data.l_flock.end + 1;
-		new2->l_conn_export = lock->l_conn_export;
-		if (lock->l_export)
-			new2->l_export = class_export_lock_get(lock->l_export,
-							       new2);
-		ldlm_lock_addref_internal_nolock(new2,
-						 lock->l_granted_mode);
-
-		/* insert new2 at lock */
-		ldlm_resource_add_lock(res, &lock->l_res_link, new2);
-		LDLM_LOCK_RELEASE(new2);
-		break;
-	}
-
-	/* if new2 is created but never used, destroy it*/
-	if (splitted == 0 && new2)
-		ldlm_lock_destroy_nolock(new2);
-
-	/* At this point we're granting the lock request. */
-	req->l_granted_mode = req->l_req_mode;
-
-	if (!added) {
-		list_del_init(&req->l_res_link);
-		/* insert new lock before "lock", which might be the
-		 * next lock for this owner, or might be the first
-		 * lock for the next owner, or might not be a lock at
-		 * all, but instead points at the head of the list
-		 */
-		ldlm_resource_add_lock(res, &lock->l_res_link, req);
-	}
-
-	/* In case we're reprocessing the requested lock we can't destroy
-	 * it until after calling ldlm_add_ast_work_item() above so that laawi()
-	 * can bump the reference count on \a req. Otherwise \a req
-	 * could be freed before the completion AST can be sent.
-	 */
-	if (added)
-		ldlm_flock_destroy(req, mode);
-
-	ldlm_resource_dump(D_INFO, res);
-	return LDLM_ITER_CONTINUE;
-}
-
-/**
- * Flock completion callback function.
- *
- * \param lock [in,out]: A lock to be handled
- * \param flags    [in]: flags
- * \param *data    [in]: ldlm_work_cp_ast_lock() will use ldlm_cb_set_arg
- *
- * \retval 0    : success
- * \retval <0   : failure
- */
-int
-ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
-{
-	struct file_lock		*getlk = lock->l_ast_data;
-	int				rc = 0;
-
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT2, 4);
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT3)) {
-		lock_res_and_lock(lock);
-		lock->l_flags |= LDLM_FL_FAIL_LOC;
-		unlock_res_and_lock(lock);
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT3, 4);
-	}
-	CDEBUG(D_DLMTRACE, "flags: 0x%llx data: %p getlk: %p\n",
-	       flags, data, getlk);
-
-	LASSERT(flags != LDLM_FL_WAIT_NOREPROC);
-
-	if (flags & LDLM_FL_FAILED)
-		goto granted;
-
-	if (!(flags & LDLM_FL_BLOCKED_MASK)) {
-		if (!data)
-			/* mds granted the lock in the reply */
-			goto granted;
-		/* CP AST RPC: lock get granted, wake it up */
-		wake_up(&lock->l_waitq);
-		return 0;
-	}
-
-	LDLM_DEBUG(lock,
-		   "client-side enqueue returned a blocked lock, sleeping");
-
-	/* Go to sleep until the lock is granted. */
-	rc = l_wait_event_abortable(lock->l_waitq, is_granted_or_cancelled(lock));
-
-	if (rc) {
-		lock_res_and_lock(lock);
-
-		/* client side - set flag to prevent lock from being put on LRU list */
-		ldlm_set_cbpending(lock);
-		unlock_res_and_lock(lock);
-
-		LDLM_DEBUG(lock, "client-side enqueue waking up: failed (%d)",
-			   rc);
-		return rc;
-	}
-
-granted:
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT, 10);
-
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT4)) {
-		lock_res_and_lock(lock);
-		/* DEADLOCK is always set with CBPENDING */
-		lock->l_flags |= LDLM_FL_FLOCK_DEADLOCK | LDLM_FL_CBPENDING;
-		unlock_res_and_lock(lock);
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT4, 4);
-	}
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT5)) {
-		lock_res_and_lock(lock);
-		/* DEADLOCK is always set with CBPENDING */
-		lock->l_flags |= LDLM_FL_FAIL_LOC |
-				 LDLM_FL_FLOCK_DEADLOCK | LDLM_FL_CBPENDING;
-		unlock_res_and_lock(lock);
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT5, 4);
-	}
-
-	lock_res_and_lock(lock);
-
-	/*
-	 * Protect against race where lock could have been just destroyed
-	 * due to overlap in ldlm_process_flock_lock().
-	 */
-	if (ldlm_is_destroyed(lock)) {
-		unlock_res_and_lock(lock);
-		LDLM_DEBUG(lock, "client-side enqueue waking up: destroyed");
-		/*
-		 * An error is still to be returned, to propagate it up to
-		 * ldlm_cli_enqueue_fini() caller.
-		 */
-		return -EIO;
-	}
-
-	/* ldlm_lock_enqueue() has already placed lock on the granted list. */
-	ldlm_resource_unlink_lock(lock);
-
-	/*
-	 * Import invalidation. We need to actually release the lock
-	 * references being held, so that it can go away. No point in
-	 * holding the lock even if app still believes it has it, since
-	 * server already dropped it anyway. Only for granted locks too.
-	 */
-	/* Do the same for DEADLOCK'ed locks. */
-	if (ldlm_is_failed(lock) || ldlm_is_flock_deadlock(lock)) {
-		int mode;
-
-		if (flags & LDLM_FL_TEST_LOCK)
-			LASSERT(ldlm_is_test_lock(lock));
-
-		if (ldlm_is_test_lock(lock) || ldlm_is_flock_deadlock(lock))
-			mode = getlk->fl_type;
-		else
-			mode = lock->l_granted_mode;
-
-		if (ldlm_is_flock_deadlock(lock)) {
-			LDLM_DEBUG(lock,
-				   "client-side enqueue deadlock received");
-			rc = -EDEADLK;
-		}
-		ldlm_flock_destroy(lock, mode);
-		unlock_res_and_lock(lock);
-
-		/* Need to wake up the waiter if we were evicted */
-		wake_up(&lock->l_waitq);
-
-		/*
-		 * An error is still to be returned, to propagate it up to
-		 * ldlm_cli_enqueue_fini() caller.
-		 */
-		return rc ? : -EIO;
-	}
-
-	LDLM_DEBUG(lock, "client-side enqueue granted");
-
-	if (flags & LDLM_FL_TEST_LOCK) {
-		/* fcntl(F_GETLK) request */
-		/* The old mode was saved in getlk->fl_type so that if the mode
-		 * in the lock changes we can decref the appropriate refcount.
-		 */
-		LASSERT(ldlm_is_test_lock(lock));
-		ldlm_flock_destroy(lock, getlk->fl_type);
-		switch (lock->l_granted_mode) {
-		case LCK_PR:
-			getlk->fl_type = F_RDLCK;
-			break;
-		case LCK_PW:
-			getlk->fl_type = F_WRLCK;
-			break;
-		default:
-			getlk->fl_type = F_UNLCK;
-		}
-		getlk->fl_pid = -(pid_t)lock->l_policy_data.l_flock.pid;
-		getlk->fl_start = (loff_t)lock->l_policy_data.l_flock.start;
-		getlk->fl_end = (loff_t)lock->l_policy_data.l_flock.end;
-	} else {
-		/* We need to reprocess the lock to do merges or splits
-		 * with existing locks owned by this process.
-		 */
-		ldlm_process_flock_lock(lock);
-	}
-	unlock_res_and_lock(lock);
-	return rc;
-}
-EXPORT_SYMBOL(ldlm_flock_completion_ast);
-
-void ldlm_flock_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				     union ldlm_policy_data *lpolicy)
-{
-	lpolicy->l_flock.start = wpolicy->l_flock.lfw_start;
-	lpolicy->l_flock.end = wpolicy->l_flock.lfw_end;
-	lpolicy->l_flock.pid = wpolicy->l_flock.lfw_pid;
-	lpolicy->l_flock.owner = wpolicy->l_flock.lfw_owner;
-}
-
-void ldlm_flock_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     union ldlm_wire_policy_data *wpolicy)
-{
-	memset(wpolicy, 0, sizeof(*wpolicy));
-	wpolicy->l_flock.lfw_start = lpolicy->l_flock.start;
-	wpolicy->l_flock.lfw_end = lpolicy->l_flock.end;
-	wpolicy->l_flock.lfw_pid = lpolicy->l_flock.pid;
-	wpolicy->l_flock.lfw_owner = lpolicy->l_flock.owner;
-}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
deleted file mode 100644
index 2926208cdfa1..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
+++ /dev/null
@@ -1,69 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/ldlm/ldlm_inodebits.c
- *
- * Author: Peter Braam <braam@clusterfs.com>
- * Author: Phil Schwan <phil@clusterfs.com>
- */
-
-/**
- * This file contains implementation of IBITS lock type
- *
- * IBITS lock type contains a bit mask determining various properties of an
- * object. The meanings of specific bits are specific to the caller and are
- * opaque to LDLM code.
- *
- * Locks with intersecting bitmasks and conflicting lock modes (e.g.  LCK_PW)
- * are considered conflicting.  See the lock mode compatibility matrix
- * in lustre_dlm.h.
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-
-#include <lustre_dlm.h>
-#include <obd_support.h>
-#include <lustre_lib.h>
-#include "ldlm_internal.h"
-
-void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				     union ldlm_policy_data *lpolicy)
-{
-	lpolicy->l_inodebits.bits = wpolicy->l_inodebits.bits;
-}
-
-void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     union ldlm_wire_policy_data *wpolicy)
-{
-	memset(wpolicy, 0, sizeof(*wpolicy));
-	wpolicy->l_inodebits.bits = lpolicy->l_inodebits.bits;
-}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
deleted file mode 100644
index 60a15b963c8a..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ /dev/null
@@ -1,329 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#define MAX_STRING_SIZE 128
-
-extern int ldlm_srv_namespace_nr;
-extern int ldlm_cli_namespace_nr;
-extern struct mutex ldlm_srv_namespace_lock;
-extern struct list_head ldlm_srv_namespace_list;
-extern struct mutex ldlm_cli_namespace_lock;
-extern struct list_head ldlm_cli_active_namespace_list;
-
-static inline int ldlm_namespace_nr_read(enum ldlm_side client)
-{
-	return client == LDLM_NAMESPACE_SERVER ?
-		ldlm_srv_namespace_nr : ldlm_cli_namespace_nr;
-}
-
-static inline void ldlm_namespace_nr_inc(enum ldlm_side client)
-{
-	if (client == LDLM_NAMESPACE_SERVER)
-		ldlm_srv_namespace_nr++;
-	else
-		ldlm_cli_namespace_nr++;
-}
-
-static inline void ldlm_namespace_nr_dec(enum ldlm_side client)
-{
-	if (client == LDLM_NAMESPACE_SERVER)
-		ldlm_srv_namespace_nr--;
-	else
-		ldlm_cli_namespace_nr--;
-}
-
-static inline struct list_head *ldlm_namespace_list(enum ldlm_side client)
-{
-	return client == LDLM_NAMESPACE_SERVER ?
-		&ldlm_srv_namespace_list : &ldlm_cli_active_namespace_list;
-}
-
-static inline struct mutex *ldlm_namespace_lock(enum ldlm_side client)
-{
-	return client == LDLM_NAMESPACE_SERVER ?
-		&ldlm_srv_namespace_lock : &ldlm_cli_namespace_lock;
-}
-
-/* ns_bref is the number of resources in this namespace */
-static inline int ldlm_ns_empty(struct ldlm_namespace *ns)
-{
-	return atomic_read(&ns->ns_bref) == 0;
-}
-
-void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *ns,
-					  enum ldlm_side client);
-void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
-					    enum ldlm_side client);
-struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side client);
-
-/* ldlm_request.c */
-/* Cancel lru flag, it indicates we cancel aged locks. */
-enum {
-	LDLM_LRU_FLAG_AGED	= BIT(0), /* Cancel old non-LRU resize locks */
-	LDLM_LRU_FLAG_PASSED	= BIT(1), /* Cancel passed number of locks. */
-	LDLM_LRU_FLAG_SHRINK	= BIT(2), /* Cancel locks from shrinker. */
-	LDLM_LRU_FLAG_LRUR	= BIT(3), /* Cancel locks from lru resize. */
-	LDLM_LRU_FLAG_NO_WAIT	= BIT(4), /* Cancel locks w/o blocking (neither
-					   * sending nor waiting for any rpcs)
-					   */
-	LDLM_LRU_FLAG_LRUR_NO_WAIT = BIT(5), /* LRUR + NO_WAIT */
-};
-
-int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
-		    enum ldlm_cancel_flags sync, int flags);
-int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
-			  struct list_head *cancels, int count, int max,
-			  enum ldlm_cancel_flags cancel_flags, int flags);
-extern unsigned int ldlm_enqueue_min;
-extern unsigned int ldlm_cancel_unused_locks_before_replay;
-
-/* ldlm_lock.c */
-
-struct ldlm_cb_set_arg {
-	struct ptlrpc_request_set	*set;
-	int				 type; /* LDLM_{CP,BL,GL}_CALLBACK */
-	atomic_t			 restart;
-	struct list_head			*list;
-	union ldlm_gl_desc		*gl_desc; /* glimpse AST descriptor */
-};
-
-enum ldlm_desc_ast_t {
-	LDLM_WORK_BL_AST,
-	LDLM_WORK_CP_AST,
-	LDLM_WORK_REVOKE_AST,
-	LDLM_WORK_GL_AST
-};
-
-void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list);
-int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
-		  enum req_location loc, void *data, int size);
-struct ldlm_lock *
-ldlm_lock_create(struct ldlm_namespace *ns, const struct ldlm_res_id *id,
-		 enum ldlm_type type, enum ldlm_mode mode,
-		 const struct ldlm_callback_suite *cbs,
-		 void *data, __u32 lvb_len, enum lvb_type lvb_type);
-enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
-				  struct ldlm_lock **lock, void *cookie,
-				  __u64 *flags);
-void ldlm_lock_addref_internal(struct ldlm_lock *lock, enum ldlm_mode mode);
-void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
-				      enum ldlm_mode mode);
-void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode);
-void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
-				      enum ldlm_mode mode);
-int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
-		      enum ldlm_desc_ast_t ast_type);
-int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use);
-#define ldlm_lock_remove_from_lru(lock) ldlm_lock_remove_from_lru_check(lock, 0)
-int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock);
-void ldlm_lock_destroy_nolock(struct ldlm_lock *lock);
-
-/* ldlm_lockd.c */
-int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
-			   struct ldlm_lock *lock);
-int ldlm_bl_to_thread_list(struct ldlm_namespace *ns,
-			   struct ldlm_lock_desc *ld,
-			   struct list_head *cancels, int count,
-			   enum ldlm_cancel_flags cancel_flags);
-int ldlm_bl_thread_wakeup(void);
-
-void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
-			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock);
-
-extern struct kmem_cache *ldlm_resource_slab;
-extern struct kset *ldlm_ns_kset;
-
-/* ldlm_lockd.c & ldlm_lock.c */
-extern struct kmem_cache *ldlm_lock_slab;
-
-/* ldlm_extent.c */
-void ldlm_extent_add_lock(struct ldlm_resource *res, struct ldlm_lock *lock);
-void ldlm_extent_unlink_lock(struct ldlm_lock *lock);
-void ldlm_extent_search(struct rb_root_cached *root,
-			__u64 start, __u64 end,
-			bool (*matches)(struct ldlm_lock *lock, void *data),
-			void *data);
-
-/* l_lock.c */
-void l_check_ns_lock(struct ldlm_namespace *ns);
-void l_check_no_ns_lock(struct ldlm_namespace *ns);
-
-extern struct dentry *ldlm_svc_debugfs_dir;
-
-struct ldlm_state {
-	struct ptlrpc_service *ldlm_cb_service;
-	struct ptlrpc_service *ldlm_cancel_service;
-	struct ptlrpc_client *ldlm_client;
-	struct ptlrpc_connection *ldlm_server_conn;
-	struct ldlm_bl_pool *ldlm_bl_pool;
-};
-
-/* ldlm_pool.c */
-__u64 ldlm_pool_get_slv(struct ldlm_pool *pl);
-void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv);
-__u32 ldlm_pool_get_lvf(struct ldlm_pool *pl);
-
-int ldlm_init(void);
-void ldlm_exit(void);
-
-enum ldlm_policy_res {
-	LDLM_POLICY_CANCEL_LOCK,
-	LDLM_POLICY_KEEP_LOCK,
-	LDLM_POLICY_SKIP_LOCK
-};
-
-#define LDLM_POOL_SYSFS_PRINT_int(v) sprintf(buf, "%d\n", v)
-#define LDLM_POOL_SYSFS_SET_int(a, b) { a = b; }
-#define LDLM_POOL_SYSFS_PRINT_u64(v) sprintf(buf, "%lld\n", v)
-#define LDLM_POOL_SYSFS_SET_u64(a, b) { a = b; }
-#define LDLM_POOL_SYSFS_PRINT_atomic(v) sprintf(buf, "%d\n", atomic_read(&v))
-#define LDLM_POOL_SYSFS_SET_atomic(a, b) atomic_set(&a, b)
-
-#define LDLM_POOL_SYSFS_READER_SHOW(var, type)				    \
-	static ssize_t var##_show(struct kobject *kobj,			    \
-				  struct attribute *attr,		    \
-				  char *buf)				    \
-	{								    \
-		struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, \
-						    pl_kobj);		    \
-		type tmp;						    \
-									    \
-		spin_lock(&pl->pl_lock);				    \
-		tmp = pl->pl_##var;					    \
-		spin_unlock(&pl->pl_lock);				    \
-									    \
-		return LDLM_POOL_SYSFS_PRINT_##type(tmp);		    \
-	}								    \
-	struct __##var##__dummy_read {; } /* semicolon catcher */
-
-#define LDLM_POOL_SYSFS_WRITER_STORE(var, type)				    \
-	static ssize_t var##_store(struct kobject *kobj,		    \
-				     struct attribute *attr,		    \
-				     const char *buffer,		    \
-				     size_t count)			    \
-	{								    \
-		struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, \
-						    pl_kobj);		    \
-		unsigned long tmp;					    \
-		int rc;							    \
-									    \
-		rc = kstrtoul(buffer, 10, &tmp);			    \
-		if (rc < 0) {						    \
-			return rc;					    \
-		}							    \
-									    \
-		spin_lock(&pl->pl_lock);				    \
-		LDLM_POOL_SYSFS_SET_##type(pl->pl_##var, tmp);		    \
-		spin_unlock(&pl->pl_lock);				    \
-									    \
-		return count;						    \
-	}								    \
-	struct __##var##__dummy_write {; } /* semicolon catcher */
-
-#define LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(var, type)			    \
-	static ssize_t var##_show(struct kobject *kobj,		    \
-				    struct attribute *attr,		    \
-				    char *buf)				    \
-	{								    \
-		struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, \
-						    pl_kobj);		    \
-									    \
-		return LDLM_POOL_SYSFS_PRINT_##type(pl->pl_##var);	    \
-	}								    \
-	struct __##var##__dummy_read {; } /* semicolon catcher */
-
-#define LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(var, type)			    \
-	static ssize_t var##_store(struct kobject *kobj,		    \
-				     struct attribute *attr,		    \
-				     const char *buffer,		    \
-				     size_t count)			    \
-	{								    \
-		struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, \
-						    pl_kobj);		    \
-		unsigned long tmp;					    \
-		int rc;							    \
-									    \
-		rc = kstrtoul(buffer, 10, &tmp);			    \
-		if (rc < 0) {						    \
-			return rc;					    \
-		}							    \
-									    \
-		LDLM_POOL_SYSFS_SET_##type(pl->pl_##var, tmp);		    \
-									    \
-		return count;						    \
-	}								    \
-	struct __##var##__dummy_write {; } /* semicolon catcher */
-
-static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
-{
-	int ret = 0;
-
-	lock_res_and_lock(lock);
-	if ((lock->l_req_mode == lock->l_granted_mode) &&
-	    !ldlm_is_cp_reqd(lock))
-		ret = 1;
-	else if (ldlm_is_failed(lock) || ldlm_is_cancel(lock))
-		ret = 1;
-	unlock_res_and_lock(lock);
-
-	return ret;
-}
-
-typedef void (*ldlm_policy_wire_to_local_t)(const union ldlm_wire_policy_data *,
-					    union ldlm_policy_data *);
-
-typedef void (*ldlm_policy_local_to_wire_t)(const union ldlm_policy_data *,
-					    union ldlm_wire_policy_data *);
-
-void ldlm_plain_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				     union ldlm_policy_data *lpolicy);
-void ldlm_plain_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     union ldlm_wire_policy_data *wpolicy);
-void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				     union ldlm_policy_data *lpolicy);
-void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     union ldlm_wire_policy_data *wpolicy);
-void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				      union ldlm_policy_data *lpolicy);
-void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				      union ldlm_wire_policy_data *wpolicy);
-void ldlm_flock_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				     union ldlm_policy_data *lpolicy);
-void ldlm_flock_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     union ldlm_wire_policy_data *wpolicy);
-
-static inline bool ldlm_res_eq(const struct ldlm_res_id *res0,
-			       const struct ldlm_res_id *res1)
-{
-	return memcmp(res0, res1, sizeof(*res0)) == 0;
-}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
deleted file mode 100644
index 0aa4f234a4f4..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ /dev/null
@@ -1,842 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2010, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-/**
- * This file deals with various client/target related logic including recovery.
- *
- * TODO: This code more logically belongs in the ptlrpc module than in ldlm and
- * should be moved.
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-
-#include <obd.h>
-#include <obd_class.h>
-#include <lustre_dlm.h>
-#include <lustre_net.h>
-#include <lustre_sec.h>
-#include "ldlm_internal.h"
-
-/* @priority: If non-zero, move the selected connection to the list head.
- * @create: If zero, only search in existing connections.
- */
-static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
-			   int priority, int create)
-{
-	struct ptlrpc_connection *ptlrpc_conn;
-	struct obd_import_conn *imp_conn = NULL, *item;
-	int rc = 0;
-
-	if (!create && !priority) {
-		CDEBUG(D_HA, "Nothing to do\n");
-		return -EINVAL;
-	}
-
-	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid);
-	if (!ptlrpc_conn) {
-		CDEBUG(D_HA, "can't find connection %s\n", uuid->uuid);
-		return -ENOENT;
-	}
-
-	if (create) {
-		imp_conn = kzalloc(sizeof(*imp_conn), GFP_NOFS);
-		if (!imp_conn) {
-			rc = -ENOMEM;
-			goto out_put;
-		}
-	}
-
-	spin_lock(&imp->imp_lock);
-	list_for_each_entry(item, &imp->imp_conn_list, oic_item) {
-		if (obd_uuid_equals(uuid, &item->oic_uuid)) {
-			if (priority) {
-				list_del(&item->oic_item);
-				list_add(&item->oic_item,
-					 &imp->imp_conn_list);
-				item->oic_last_attempt = 0;
-			}
-			CDEBUG(D_HA, "imp %p@%s: found existing conn %s%s\n",
-			       imp, imp->imp_obd->obd_name, uuid->uuid,
-			       (priority ? ", moved to head" : ""));
-			spin_unlock(&imp->imp_lock);
-			rc = 0;
-			goto out_free;
-		}
-	}
-	/* No existing import connection found for \a uuid. */
-	if (create) {
-		imp_conn->oic_conn = ptlrpc_conn;
-		imp_conn->oic_uuid = *uuid;
-		imp_conn->oic_last_attempt = 0;
-		if (priority)
-			list_add(&imp_conn->oic_item, &imp->imp_conn_list);
-		else
-			list_add_tail(&imp_conn->oic_item,
-				      &imp->imp_conn_list);
-		CDEBUG(D_HA, "imp %p@%s: add connection %s at %s\n",
-		       imp, imp->imp_obd->obd_name, uuid->uuid,
-		       (priority ? "head" : "tail"));
-	} else {
-		spin_unlock(&imp->imp_lock);
-		rc = -ENOENT;
-		goto out_free;
-	}
-
-	spin_unlock(&imp->imp_lock);
-	return 0;
-out_free:
-	kfree(imp_conn);
-out_put:
-	ptlrpc_connection_put(ptlrpc_conn);
-	return rc;
-}
-
-int import_set_conn_priority(struct obd_import *imp, struct obd_uuid *uuid)
-{
-	return import_set_conn(imp, uuid, 1, 0);
-}
-
-int client_import_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
-			   int priority)
-{
-	return import_set_conn(imp, uuid, priority, 1);
-}
-EXPORT_SYMBOL(client_import_add_conn);
-
-int client_import_del_conn(struct obd_import *imp, struct obd_uuid *uuid)
-{
-	struct obd_import_conn *imp_conn;
-	struct obd_export *dlmexp;
-	int rc = -ENOENT;
-
-	spin_lock(&imp->imp_lock);
-	if (list_empty(&imp->imp_conn_list)) {
-		LASSERT(!imp->imp_connection);
-		goto out;
-	}
-
-	list_for_each_entry(imp_conn, &imp->imp_conn_list, oic_item) {
-		if (!obd_uuid_equals(uuid, &imp_conn->oic_uuid))
-			continue;
-		LASSERT(imp_conn->oic_conn);
-
-		if (imp_conn == imp->imp_conn_current) {
-			LASSERT(imp_conn->oic_conn == imp->imp_connection);
-
-			if (imp->imp_state != LUSTRE_IMP_CLOSED &&
-			    imp->imp_state != LUSTRE_IMP_DISCON) {
-				CERROR("can't remove current connection\n");
-				rc = -EBUSY;
-				goto out;
-			}
-
-			ptlrpc_connection_put(imp->imp_connection);
-			imp->imp_connection = NULL;
-
-			dlmexp = class_conn2export(&imp->imp_dlm_handle);
-			if (dlmexp && dlmexp->exp_connection) {
-				LASSERT(dlmexp->exp_connection ==
-					imp_conn->oic_conn);
-				ptlrpc_connection_put(dlmexp->exp_connection);
-				dlmexp->exp_connection = NULL;
-			}
-
-			if (dlmexp)
-				class_export_put(dlmexp);
-		}
-
-		list_del(&imp_conn->oic_item);
-		ptlrpc_connection_put(imp_conn->oic_conn);
-		kfree(imp_conn);
-		CDEBUG(D_HA, "imp %p@%s: remove connection %s\n",
-		       imp, imp->imp_obd->obd_name, uuid->uuid);
-		rc = 0;
-		break;
-	}
-out:
-	spin_unlock(&imp->imp_lock);
-	if (rc == -ENOENT)
-		CERROR("connection %s not found\n", uuid->uuid);
-	return rc;
-}
-EXPORT_SYMBOL(client_import_del_conn);
-
-/**
- * Find conn UUID by peer NID. \a peer is a server NID. This function is used
- * to find a conn uuid of \a imp which can reach \a peer.
- */
-int client_import_find_conn(struct obd_import *imp, lnet_nid_t peer,
-			    struct obd_uuid *uuid)
-{
-	struct obd_import_conn *conn;
-	int rc = -ENOENT;
-
-	spin_lock(&imp->imp_lock);
-	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
-		/* Check if conn UUID does have this peer NID. */
-		if (class_check_uuid(&conn->oic_uuid, peer)) {
-			*uuid = conn->oic_uuid;
-			rc = 0;
-			break;
-		}
-	}
-	spin_unlock(&imp->imp_lock);
-	return rc;
-}
-EXPORT_SYMBOL(client_import_find_conn);
-
-void client_destroy_import(struct obd_import *imp)
-{
-	/* Drop security policy instance after all RPCs have finished/aborted
-	 * to let all busy contexts be released.
-	 */
-	class_import_get(imp);
-	class_destroy_import(imp);
-	sptlrpc_import_sec_put(imp);
-	class_import_put(imp);
-}
-EXPORT_SYMBOL(client_destroy_import);
-
-/* Configure an RPC client OBD device.
- *
- * lcfg parameters:
- * 1 - client UUID
- * 2 - server UUID
- * 3 - inactive-on-startup
- */
-int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
-{
-	struct client_obd *cli = &obddev->u.cli;
-	struct obd_import *imp;
-	struct obd_uuid server_uuid;
-	int rq_portal, rp_portal, connect_op;
-	char *name = obddev->obd_type->typ_name;
-	enum ldlm_ns_type ns_type = LDLM_NS_TYPE_UNKNOWN;
-	int rc;
-
-	/* In a more perfect world, we would hang a ptlrpc_client off of
-	 * obd_type and just use the values from there.
-	 */
-	if (!strcmp(name, LUSTRE_OSC_NAME)) {
-		rq_portal = OST_REQUEST_PORTAL;
-		rp_portal = OSC_REPLY_PORTAL;
-		connect_op = OST_CONNECT;
-		cli->cl_sp_me = LUSTRE_SP_CLI;
-		cli->cl_sp_to = LUSTRE_SP_OST;
-		ns_type = LDLM_NS_TYPE_OSC;
-	} else if (!strcmp(name, LUSTRE_MDC_NAME) ||
-		   !strcmp(name, LUSTRE_LWP_NAME)) {
-		rq_portal = MDS_REQUEST_PORTAL;
-		rp_portal = MDC_REPLY_PORTAL;
-		connect_op = MDS_CONNECT;
-		cli->cl_sp_me = LUSTRE_SP_CLI;
-		cli->cl_sp_to = LUSTRE_SP_MDT;
-		ns_type = LDLM_NS_TYPE_MDC;
-	} else if (!strcmp(name, LUSTRE_MGC_NAME)) {
-		rq_portal = MGS_REQUEST_PORTAL;
-		rp_portal = MGC_REPLY_PORTAL;
-		connect_op = MGS_CONNECT;
-		cli->cl_sp_me = LUSTRE_SP_MGC;
-		cli->cl_sp_to = LUSTRE_SP_MGS;
-		cli->cl_flvr_mgc.sf_rpc = SPTLRPC_FLVR_INVALID;
-		ns_type = LDLM_NS_TYPE_MGC;
-	} else {
-		CERROR("unknown client OBD type \"%s\", can't setup\n",
-		       name);
-		return -EINVAL;
-	}
-
-	if (LUSTRE_CFG_BUFLEN(lcfg, 1) < 1) {
-		CERROR("requires a TARGET UUID\n");
-		return -EINVAL;
-	}
-
-	if (LUSTRE_CFG_BUFLEN(lcfg, 1) > 37) {
-		CERROR("client UUID must be less than 38 characters\n");
-		return -EINVAL;
-	}
-
-	if (LUSTRE_CFG_BUFLEN(lcfg, 2) < 1) {
-		CERROR("setup requires a SERVER UUID\n");
-		return -EINVAL;
-	}
-
-	if (LUSTRE_CFG_BUFLEN(lcfg, 2) > 37) {
-		CERROR("target UUID must be less than 38 characters\n");
-		return -EINVAL;
-	}
-
-	init_rwsem(&cli->cl_sem);
-	cli->cl_conn_count = 0;
-	memcpy(server_uuid.uuid, lustre_cfg_buf(lcfg, 2),
-	       min_t(unsigned int, LUSTRE_CFG_BUFLEN(lcfg, 2),
-		     sizeof(server_uuid)));
-
-	cli->cl_dirty_pages = 0;
-	cli->cl_avail_grant = 0;
-	/* FIXME: Should limit this for the sum of all cl_dirty_max_pages. */
-	/*
-	 * cl_dirty_max_pages may be changed at connect time in
-	 * ptlrpc_connect_interpret().
-	 */
-	client_adjust_max_dirty(cli);
-	INIT_LIST_HEAD(&cli->cl_cache_waiters);
-	INIT_LIST_HEAD(&cli->cl_loi_ready_list);
-	INIT_LIST_HEAD(&cli->cl_loi_hp_ready_list);
-	INIT_LIST_HEAD(&cli->cl_loi_write_list);
-	INIT_LIST_HEAD(&cli->cl_loi_read_list);
-	spin_lock_init(&cli->cl_loi_list_lock);
-	atomic_set(&cli->cl_pending_w_pages, 0);
-	atomic_set(&cli->cl_pending_r_pages, 0);
-	cli->cl_r_in_flight = 0;
-	cli->cl_w_in_flight = 0;
-
-	spin_lock_init(&cli->cl_read_rpc_hist.oh_lock);
-	spin_lock_init(&cli->cl_write_rpc_hist.oh_lock);
-	spin_lock_init(&cli->cl_read_page_hist.oh_lock);
-	spin_lock_init(&cli->cl_write_page_hist.oh_lock);
-	spin_lock_init(&cli->cl_read_offset_hist.oh_lock);
-	spin_lock_init(&cli->cl_write_offset_hist.oh_lock);
-
-	/* lru for osc. */
-	INIT_LIST_HEAD(&cli->cl_lru_osc);
-	atomic_set(&cli->cl_lru_shrinkers, 0);
-	atomic_long_set(&cli->cl_lru_busy, 0);
-	atomic_long_set(&cli->cl_lru_in_list, 0);
-	INIT_LIST_HEAD(&cli->cl_lru_list);
-	spin_lock_init(&cli->cl_lru_list_lock);
-	atomic_long_set(&cli->cl_unstable_count, 0);
-	INIT_LIST_HEAD(&cli->cl_shrink_list);
-
-	init_waitqueue_head(&cli->cl_destroy_waitq);
-	atomic_set(&cli->cl_destroy_in_flight, 0);
-	/* Turn on checksumming by default. */
-	cli->cl_checksum = 1;
-	/*
-	 * The supported checksum types will be worked out at connect time
-	 * Set cl_chksum* to CRC32 for now to avoid returning screwed info
-	 * through procfs.
-	 */
-	cli->cl_cksum_type = OBD_CKSUM_CRC32;
-	cli->cl_supp_cksum_types = OBD_CKSUM_CRC32;
-	atomic_set(&cli->cl_resends, OSC_DEFAULT_RESENDS);
-
-	/*
-	 * Set it to possible maximum size. It may be reduced by ocd_brw_size
-	 * from OFD after connecting.
-	 */
-	cli->cl_max_pages_per_rpc = PTLRPC_MAX_BRW_PAGES;
-
-	/*
-	 * set cl_chunkbits default value to PAGE_CACHE_SHIFT,
-	 * it will be updated at OSC connection time.
-	 */
-	cli->cl_chunkbits = PAGE_SHIFT;
-
-	if (!strcmp(name, LUSTRE_MDC_NAME))
-		cli->cl_max_rpcs_in_flight = OBD_MAX_RIF_DEFAULT;
-	else if (totalram_pages >> (20 - PAGE_SHIFT) <= 128 /* MB */)
-		cli->cl_max_rpcs_in_flight = 2;
-	else if (totalram_pages >> (20 - PAGE_SHIFT) <= 256 /* MB */)
-		cli->cl_max_rpcs_in_flight = 3;
-	else if (totalram_pages >> (20 - PAGE_SHIFT) <= 512 /* MB */)
-		cli->cl_max_rpcs_in_flight = 4;
-	else
-		cli->cl_max_rpcs_in_flight = OBD_MAX_RIF_DEFAULT;
-
-	spin_lock_init(&cli->cl_mod_rpcs_lock);
-	spin_lock_init(&cli->cl_mod_rpcs_hist.oh_lock);
-	cli->cl_max_mod_rpcs_in_flight = 0;
-	cli->cl_mod_rpcs_in_flight = 0;
-	cli->cl_close_rpcs_in_flight = 0;
-	init_waitqueue_head(&cli->cl_mod_rpcs_waitq);
-	cli->cl_mod_tag_bitmap = NULL;
-
-	if (connect_op == MDS_CONNECT) {
-		cli->cl_max_mod_rpcs_in_flight = cli->cl_max_rpcs_in_flight - 1;
-		cli->cl_mod_tag_bitmap = kcalloc(BITS_TO_LONGS(OBD_MAX_RIF_MAX),
-						 sizeof(long), GFP_NOFS);
-		if (!cli->cl_mod_tag_bitmap) {
-			rc = -ENOMEM;
-			goto err;
-		}
-	}
-
-	rc = ldlm_get_ref();
-	if (rc) {
-		CERROR("ldlm_get_ref failed: %d\n", rc);
-		goto err;
-	}
-
-	ptlrpc_init_client(rq_portal, rp_portal, name,
-			   &obddev->obd_ldlm_client);
-
-	imp = class_new_import(obddev);
-	if (!imp) {
-		rc = -ENOENT;
-		goto err_ldlm;
-	}
-	imp->imp_client = &obddev->obd_ldlm_client;
-	imp->imp_connect_op = connect_op;
-	memcpy(cli->cl_target_uuid.uuid, lustre_cfg_buf(lcfg, 1),
-	       LUSTRE_CFG_BUFLEN(lcfg, 1));
-	class_import_put(imp);
-
-	rc = client_import_add_conn(imp, &server_uuid, 1);
-	if (rc) {
-		CERROR("can't add initial connection\n");
-		goto err_import;
-	}
-
-	cli->cl_import = imp;
-	/* cli->cl_max_mds_easize updated by mdc_init_ea_size() */
-	cli->cl_max_mds_easize = sizeof(struct lov_mds_md_v3);
-
-	if (LUSTRE_CFG_BUFLEN(lcfg, 3) > 0) {
-		if (!strcmp(lustre_cfg_string(lcfg, 3), "inactive")) {
-			CDEBUG(D_HA, "marking %s %s->%s as inactive\n",
-			       name, obddev->obd_name,
-			       cli->cl_target_uuid.uuid);
-			spin_lock(&imp->imp_lock);
-			imp->imp_deactive = 1;
-			spin_unlock(&imp->imp_lock);
-		}
-	}
-
-	obddev->obd_namespace = ldlm_namespace_new(obddev, obddev->obd_name,
-						   LDLM_NAMESPACE_CLIENT,
-						   LDLM_NAMESPACE_GREEDY,
-						   ns_type);
-	if (!obddev->obd_namespace) {
-		CERROR("Unable to create client namespace - %s\n",
-		       obddev->obd_name);
-		rc = -ENOMEM;
-		goto err_import;
-	}
-
-	return rc;
-
-err_import:
-	class_destroy_import(imp);
-err_ldlm:
-	ldlm_put_ref();
-err:
-	kfree(cli->cl_mod_tag_bitmap);
-	cli->cl_mod_tag_bitmap = NULL;
-	return rc;
-}
-EXPORT_SYMBOL(client_obd_setup);
-
-int client_obd_cleanup(struct obd_device *obddev)
-{
-	struct client_obd *cli = &obddev->u.cli;
-
-	ldlm_namespace_free_post(obddev->obd_namespace);
-	obddev->obd_namespace = NULL;
-
-	obd_cleanup_client_import(obddev);
-	LASSERT(!obddev->u.cli.cl_import);
-
-	ldlm_put_ref();
-
-	kfree(cli->cl_mod_tag_bitmap);
-	cli->cl_mod_tag_bitmap = NULL;
-
-	return 0;
-}
-EXPORT_SYMBOL(client_obd_cleanup);
-
-/* ->o_connect() method for client side (OSC and MDC and MGC) */
-int client_connect_import(const struct lu_env *env,
-			  struct obd_export **exp,
-			  struct obd_device *obd, struct obd_uuid *cluuid,
-			  struct obd_connect_data *data, void *localdata)
-{
-	struct client_obd       *cli    = &obd->u.cli;
-	struct obd_import       *imp    = cli->cl_import;
-	struct obd_connect_data *ocd;
-	struct lustre_handle    conn    = { 0 };
-	bool is_mdc = false;
-	int		     rc;
-
-	*exp = NULL;
-	down_write(&cli->cl_sem);
-	if (cli->cl_conn_count > 0) {
-		rc = -EALREADY;
-		goto out_sem;
-	}
-
-	rc = class_connect(&conn, obd, cluuid);
-	if (rc)
-		goto out_sem;
-
-	cli->cl_conn_count++;
-	*exp = class_conn2export(&conn);
-
-	LASSERT(obd->obd_namespace);
-
-	imp->imp_dlm_handle = conn;
-	rc = ptlrpc_init_import(imp);
-	if (rc != 0)
-		goto out_ldlm;
-
-	ocd = &imp->imp_connect_data;
-	if (data) {
-		*ocd = *data;
-		is_mdc = !strncmp(imp->imp_obd->obd_type->typ_name,
-				  LUSTRE_MDC_NAME, 3);
-		if (is_mdc)
-			data->ocd_connect_flags |= OBD_CONNECT_MULTIMODRPCS;
-		imp->imp_connect_flags_orig = data->ocd_connect_flags;
-	}
-
-	rc = ptlrpc_connect_import(imp);
-	if (rc != 0) {
-		if (data && is_mdc)
-			data->ocd_connect_flags &= ~OBD_CONNECT_MULTIMODRPCS;
-		LASSERT(imp->imp_state == LUSTRE_IMP_DISCON);
-		goto out_ldlm;
-	}
-	LASSERT(*exp && (*exp)->exp_connection);
-
-	if (data) {
-		LASSERTF((ocd->ocd_connect_flags & data->ocd_connect_flags) ==
-			 ocd->ocd_connect_flags, "old %#llx, new %#llx\n",
-			 data->ocd_connect_flags, ocd->ocd_connect_flags);
-		data->ocd_connect_flags = ocd->ocd_connect_flags;
-		/* clear the flag as it was not set and is not known
-		 * by upper layers
-		 */
-		if (is_mdc)
-			data->ocd_connect_flags &= ~OBD_CONNECT_MULTIMODRPCS;
-	}
-
-	ptlrpc_pinger_add_import(imp);
-
-	if (rc) {
-out_ldlm:
-		cli->cl_conn_count--;
-		class_disconnect(*exp);
-		*exp = NULL;
-	}
-out_sem:
-	up_write(&cli->cl_sem);
-
-	return rc;
-}
-EXPORT_SYMBOL(client_connect_import);
-
-int client_disconnect_export(struct obd_export *exp)
-{
-	struct obd_device *obd = class_exp2obd(exp);
-	struct client_obd *cli;
-	struct obd_import *imp;
-	int rc = 0, err;
-
-	if (!obd) {
-		CERROR("invalid export for disconnect: exp %p cookie %#llx\n",
-		       exp, exp ? exp->exp_handle.h_cookie : -1);
-		return -EINVAL;
-	}
-
-	cli = &obd->u.cli;
-	imp = cli->cl_import;
-
-	down_write(&cli->cl_sem);
-	CDEBUG(D_INFO, "disconnect %s - %zu\n", obd->obd_name,
-	       cli->cl_conn_count);
-
-	if (!cli->cl_conn_count) {
-		CERROR("disconnecting disconnected device (%s)\n",
-		       obd->obd_name);
-		rc = -EINVAL;
-		goto out_disconnect;
-	}
-
-	cli->cl_conn_count--;
-	if (cli->cl_conn_count) {
-		rc = 0;
-		goto out_disconnect;
-	}
-
-	/* Mark import deactivated now, so we don't try to reconnect if any
-	 * of the cleanup RPCs fails (e.g. LDLM cancel, etc).  We don't
-	 * fully deactivate the import, or that would drop all requests.
-	 */
-	spin_lock(&imp->imp_lock);
-	imp->imp_deactive = 1;
-	spin_unlock(&imp->imp_lock);
-
-	/* Some non-replayable imports (MDS's OSCs) are pinged, so just
-	 * delete it regardless.  (It's safe to delete an import that was
-	 * never added.)
-	 */
-	(void)ptlrpc_pinger_del_import(imp);
-
-	if (obd->obd_namespace) {
-		/* obd_force == local only */
-		ldlm_cli_cancel_unused(obd->obd_namespace, NULL,
-				       obd->obd_force ? LCF_LOCAL : 0, NULL);
-		ldlm_namespace_free_prior(obd->obd_namespace, imp,
-					  obd->obd_force);
-	}
-
-	/* There's no need to hold sem while disconnecting an import,
-	 * and it may actually cause deadlock in GSS.
-	 */
-	up_write(&cli->cl_sem);
-	rc = ptlrpc_disconnect_import(imp, 0);
-	down_write(&cli->cl_sem);
-
-	ptlrpc_invalidate_import(imp);
-
-out_disconnect:
-	/* Use server style - class_disconnect should be always called for
-	 * o_disconnect.
-	 */
-	err = class_disconnect(exp);
-	if (!rc && err)
-		rc = err;
-
-	up_write(&cli->cl_sem);
-
-	return rc;
-}
-EXPORT_SYMBOL(client_disconnect_export);
-
-/**
- * Packs current SLV and Limit into \a req.
- */
-int target_pack_pool_reply(struct ptlrpc_request *req)
-{
-	struct obd_device *obd;
-
-	/* Check that we still have all structures alive as this may
-	 * be some late RPC at shutdown time.
-	 */
-	if (unlikely(!req->rq_export || !req->rq_export->exp_obd ||
-		     !exp_connect_lru_resize(req->rq_export))) {
-		lustre_msg_set_slv(req->rq_repmsg, 0);
-		lustre_msg_set_limit(req->rq_repmsg, 0);
-		return 0;
-	}
-
-	/* OBD is alive here as export is alive, which we checked above. */
-	obd = req->rq_export->exp_obd;
-
-	read_lock(&obd->obd_pool_lock);
-	lustre_msg_set_slv(req->rq_repmsg, obd->obd_pool_slv);
-	lustre_msg_set_limit(req->rq_repmsg, obd->obd_pool_limit);
-	read_unlock(&obd->obd_pool_lock);
-
-	return 0;
-}
-EXPORT_SYMBOL(target_pack_pool_reply);
-
-static int
-target_send_reply_msg(struct ptlrpc_request *req, int rc, int fail_id)
-{
-	if (OBD_FAIL_CHECK_ORSET(fail_id & ~OBD_FAIL_ONCE, OBD_FAIL_ONCE)) {
-		DEBUG_REQ(D_ERROR, req, "dropping reply");
-		return -ECOMM;
-	}
-
-	if (unlikely(rc)) {
-		DEBUG_REQ(D_NET, req, "processing error (%d)", rc);
-		req->rq_status = rc;
-		return ptlrpc_send_error(req, 1);
-	}
-
-	DEBUG_REQ(D_NET, req, "sending reply");
-	return ptlrpc_send_reply(req, PTLRPC_REPLY_MAYBE_DIFFICULT);
-}
-
-void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
-{
-	struct ptlrpc_service_part *svcpt;
-	int			netrc;
-	struct ptlrpc_reply_state *rs;
-	struct obd_export	 *exp;
-
-	if (req->rq_no_reply)
-		return;
-
-	svcpt = req->rq_rqbd->rqbd_svcpt;
-	rs = req->rq_reply_state;
-	if (!rs || !rs->rs_difficult) {
-		/* no notifiers */
-		target_send_reply_msg(req, rc, fail_id);
-		return;
-	}
-
-	/* must be an export if locks saved */
-	LASSERT(req->rq_export);
-	/* req/reply consistent */
-	LASSERT(rs->rs_svcpt == svcpt);
-
-	/* "fresh" reply */
-	LASSERT(!rs->rs_scheduled);
-	LASSERT(!rs->rs_scheduled_ever);
-	LASSERT(!rs->rs_handled);
-	LASSERT(!rs->rs_on_net);
-	LASSERT(!rs->rs_export);
-	LASSERT(list_empty(&rs->rs_obd_list));
-	LASSERT(list_empty(&rs->rs_exp_list));
-
-	exp = class_export_get(req->rq_export);
-
-	/* disable reply scheduling while I'm setting up */
-	rs->rs_scheduled = 1;
-	rs->rs_on_net    = 1;
-	rs->rs_xid       = req->rq_xid;
-	rs->rs_transno   = req->rq_transno;
-	rs->rs_export    = exp;
-	rs->rs_opc       = lustre_msg_get_opc(req->rq_reqmsg);
-
-	spin_lock(&exp->exp_uncommitted_replies_lock);
-	CDEBUG(D_NET, "rs transno = %llu, last committed = %llu\n",
-	       rs->rs_transno, exp->exp_last_committed);
-	if (rs->rs_transno > exp->exp_last_committed) {
-		/* not committed already */
-		list_add_tail(&rs->rs_obd_list,
-			      &exp->exp_uncommitted_replies);
-	}
-	spin_unlock(&exp->exp_uncommitted_replies_lock);
-
-	spin_lock(&exp->exp_lock);
-	list_add_tail(&rs->rs_exp_list, &exp->exp_outstanding_replies);
-	spin_unlock(&exp->exp_lock);
-
-	netrc = target_send_reply_msg(req, rc, fail_id);
-
-	spin_lock(&svcpt->scp_rep_lock);
-
-	atomic_inc(&svcpt->scp_nreps_difficult);
-
-	if (netrc != 0) {
-		/* error sending: reply is off the net.  Also we need +1
-		 * reply ref until ptlrpc_handle_rs() is done
-		 * with the reply state (if the send was successful, there
-		 * would have been +1 ref for the net, which
-		 * reply_out_callback leaves alone)
-		 */
-		rs->rs_on_net = 0;
-		ptlrpc_rs_addref(rs);
-	}
-
-	spin_lock(&rs->rs_lock);
-	if (rs->rs_transno <= exp->exp_last_committed ||
-	    (!rs->rs_on_net && !rs->rs_no_ack) ||
-	    list_empty(&rs->rs_exp_list) ||     /* completed already */
-	    list_empty(&rs->rs_obd_list)) {
-		CDEBUG(D_HA, "Schedule reply immediately\n");
-		ptlrpc_dispatch_difficult_reply(rs);
-	} else {
-		list_add(&rs->rs_list, &svcpt->scp_rep_active);
-		rs->rs_scheduled = 0;	/* allow notifier to schedule */
-	}
-	spin_unlock(&rs->rs_lock);
-	spin_unlock(&svcpt->scp_rep_lock);
-}
-EXPORT_SYMBOL(target_send_reply);
-
-enum ldlm_mode lck_compat_array[] = {
-	[LCK_EX]	= LCK_COMPAT_EX,
-	[LCK_PW]	= LCK_COMPAT_PW,
-	[LCK_PR]	= LCK_COMPAT_PR,
-	[LCK_CW]	= LCK_COMPAT_CW,
-	[LCK_CR]	= LCK_COMPAT_CR,
-	[LCK_NL]	= LCK_COMPAT_NL,
-	[LCK_GROUP]	= LCK_COMPAT_GROUP,
-	[LCK_COS]	= LCK_COMPAT_COS,
-};
-
-/**
- * Rather arbitrary mapping from LDLM error codes to errno values. This should
- * not escape to the user level.
- */
-int ldlm_error2errno(enum ldlm_error error)
-{
-	int result;
-
-	switch (error) {
-	case ELDLM_OK:
-	case ELDLM_LOCK_MATCHED:
-		result = 0;
-		break;
-	case ELDLM_LOCK_CHANGED:
-		result = -ESTALE;
-		break;
-	case ELDLM_LOCK_ABORTED:
-		result = -ENAVAIL;
-		break;
-	case ELDLM_LOCK_REPLACED:
-		result = -ESRCH;
-		break;
-	case ELDLM_NO_LOCK_DATA:
-		result = -ENOENT;
-		break;
-	case ELDLM_NAMESPACE_EXISTS:
-		result = -EEXIST;
-		break;
-	case ELDLM_BAD_NAMESPACE:
-		result = -EBADF;
-		break;
-	default:
-		if (((int)error) < 0)  /* cast to signed type */
-			result = error; /* as enum ldlm_error can be unsigned */
-		else {
-			CERROR("Invalid DLM result code: %d\n", error);
-			result = -EPROTO;
-		}
-	}
-	return result;
-}
-EXPORT_SYMBOL(ldlm_error2errno);
-
-#if LUSTRE_TRACKS_LOCK_EXP_REFS
-void ldlm_dump_export_locks(struct obd_export *exp)
-{
-	spin_lock(&exp->exp_locks_list_guard);
-	if (!list_empty(&exp->exp_locks_list)) {
-		struct ldlm_lock *lock;
-
-		CERROR("dumping locks for export %p,ignore if the unmount doesn't hang\n",
-		       exp);
-		list_for_each_entry(lock, &exp->exp_locks_list,
-				    l_exp_refs_link)
-			LDLM_ERROR(lock, "lock:");
-	}
-	spin_unlock(&exp->exp_locks_list_guard);
-}
-#endif
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
deleted file mode 100644
index 2fb2e088dc87..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ /dev/null
@@ -1,2103 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2010, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/ldlm/ldlm_lock.c
- *
- * Author: Peter Braam <braam@clusterfs.com>
- * Author: Phil Schwan <phil@clusterfs.com>
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-
-#include <lustre_intent.h>
-#include <lustre_swab.h>
-#include <obd_class.h>
-#include "ldlm_internal.h"
-
-/* lock types */
-char *ldlm_lockname[] = {
-	[0]		= "--",
-	[LCK_EX]	= "EX",
-	[LCK_PW]	= "PW",
-	[LCK_PR]	= "PR",
-	[LCK_CW]	= "CW",
-	[LCK_CR]	= "CR",
-	[LCK_NL]	= "NL",
-	[LCK_GROUP]	= "GROUP",
-	[LCK_COS]	= "COS",
-};
-EXPORT_SYMBOL(ldlm_lockname);
-
-static char *ldlm_typename[] = {
-	[LDLM_PLAIN]	= "PLN",
-	[LDLM_EXTENT]	= "EXT",
-	[LDLM_FLOCK]	= "FLK",
-	[LDLM_IBITS]	= "IBT",
-};
-
-static ldlm_policy_wire_to_local_t ldlm_policy_wire_to_local[] = {
-	[LDLM_PLAIN - LDLM_MIN_TYPE]	= ldlm_plain_policy_wire_to_local,
-	[LDLM_EXTENT - LDLM_MIN_TYPE]	= ldlm_extent_policy_wire_to_local,
-	[LDLM_FLOCK - LDLM_MIN_TYPE]	= ldlm_flock_policy_wire_to_local,
-	[LDLM_IBITS - LDLM_MIN_TYPE]	= ldlm_ibits_policy_wire_to_local,
-};
-
-static ldlm_policy_local_to_wire_t ldlm_policy_local_to_wire[] = {
-	[LDLM_PLAIN - LDLM_MIN_TYPE]	= ldlm_plain_policy_local_to_wire,
-	[LDLM_EXTENT - LDLM_MIN_TYPE]	= ldlm_extent_policy_local_to_wire,
-	[LDLM_FLOCK - LDLM_MIN_TYPE]	= ldlm_flock_policy_local_to_wire,
-	[LDLM_IBITS - LDLM_MIN_TYPE]	= ldlm_ibits_policy_local_to_wire,
-};
-
-/**
- * Converts lock policy from local format to on the wire lock_desc format
- */
-static void ldlm_convert_policy_to_wire(enum ldlm_type type,
-					const union ldlm_policy_data *lpolicy,
-					union ldlm_wire_policy_data *wpolicy)
-{
-	ldlm_policy_local_to_wire_t convert;
-
-	convert = ldlm_policy_local_to_wire[type - LDLM_MIN_TYPE];
-
-	convert(lpolicy, wpolicy);
-}
-
-/**
- * Converts lock policy from on the wire lock_desc format to local format
- */
-void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
-				  const union ldlm_wire_policy_data *wpolicy,
-				  union ldlm_policy_data *lpolicy)
-{
-	ldlm_policy_wire_to_local_t convert;
-
-	convert = ldlm_policy_wire_to_local[type - LDLM_MIN_TYPE];
-
-	convert(wpolicy, lpolicy);
-}
-
-const char *ldlm_it2str(enum ldlm_intent_flags it)
-{
-	switch (it) {
-	case IT_OPEN:
-		return "open";
-	case IT_CREAT:
-		return "creat";
-	case (IT_OPEN | IT_CREAT):
-		return "open|creat";
-	case IT_READDIR:
-		return "readdir";
-	case IT_GETATTR:
-		return "getattr";
-	case IT_LOOKUP:
-		return "lookup";
-	case IT_UNLINK:
-		return "unlink";
-	case IT_GETXATTR:
-		return "getxattr";
-	case IT_LAYOUT:
-		return "layout";
-	default:
-		CERROR("Unknown intent 0x%08x\n", it);
-		return "UNKNOWN";
-	}
-}
-EXPORT_SYMBOL(ldlm_it2str);
-
-/*
- * REFCOUNTED LOCK OBJECTS
- */
-
-/**
- * Get a reference on a lock.
- *
- * Lock refcounts, during creation:
- *   - one special one for allocation, dec'd only once in destroy
- *   - one for being a lock that's in-use
- *   - one for the addref associated with a new lock
- */
-struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock)
-{
-	atomic_inc(&lock->l_refc);
-	return lock;
-}
-EXPORT_SYMBOL(ldlm_lock_get);
-
-/**
- * Release lock reference.
- *
- * Also frees the lock if it was last reference.
- */
-void ldlm_lock_put(struct ldlm_lock *lock)
-{
-	LASSERT(lock->l_resource != LP_POISON);
-	LASSERT(atomic_read(&lock->l_refc) > 0);
-	if (atomic_dec_and_test(&lock->l_refc)) {
-		struct ldlm_resource *res;
-
-		LDLM_DEBUG(lock,
-			   "final lock_put on destroyed lock, freeing it.");
-
-		res = lock->l_resource;
-		LASSERT(ldlm_is_destroyed(lock));
-		LASSERT(list_empty(&lock->l_res_link));
-		LASSERT(list_empty(&lock->l_pending_chain));
-
-		lprocfs_counter_decr(ldlm_res_to_ns(res)->ns_stats,
-				     LDLM_NSS_LOCKS);
-		lu_ref_del(&res->lr_reference, "lock", lock);
-		ldlm_resource_putref(res);
-		lock->l_resource = NULL;
-		if (lock->l_export) {
-			class_export_lock_put(lock->l_export, lock);
-			lock->l_export = NULL;
-		}
-
-		kfree(lock->l_lvb_data);
-
-		lu_ref_fini(&lock->l_reference);
-		OBD_FREE_RCU(lock, sizeof(*lock), &lock->l_handle);
-	}
-}
-EXPORT_SYMBOL(ldlm_lock_put);
-
-/**
- * Removes LDLM lock \a lock from LRU. Assumes LRU is already locked.
- */
-int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock)
-{
-	int rc = 0;
-
-	if (!list_empty(&lock->l_lru)) {
-		struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
-
-		LASSERT(lock->l_resource->lr_type != LDLM_FLOCK);
-		list_del_init(&lock->l_lru);
-		LASSERT(ns->ns_nr_unused > 0);
-		ns->ns_nr_unused--;
-		rc = 1;
-	}
-	return rc;
-}
-
-/**
- * Removes LDLM lock \a lock from LRU. Obtains the LRU lock first.
- *
- * If \a last_use is non-zero, it will remove the lock from LRU only if
- * it matches lock's l_last_used.
- *
- * \retval 0 if \a last_use is set, the lock is not in LRU list or \a last_use
- *           doesn't match lock's l_last_used;
- *           otherwise, the lock hasn't been in the LRU list.
- * \retval 1 the lock was in LRU list and removed.
- */
-int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use)
-{
-	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
-	int rc = 0;
-
-	spin_lock(&ns->ns_lock);
-	if (last_use == 0 || last_use == lock->l_last_used)
-		rc = ldlm_lock_remove_from_lru_nolock(lock);
-	spin_unlock(&ns->ns_lock);
-
-	return rc;
-}
-
-/**
- * Adds LDLM lock \a lock to namespace LRU. Assumes LRU is already locked.
- */
-static void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
-{
-	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
-
-	lock->l_last_used = jiffies;
-	LASSERT(list_empty(&lock->l_lru));
-	LASSERT(lock->l_resource->lr_type != LDLM_FLOCK);
-	list_add_tail(&lock->l_lru, &ns->ns_unused_list);
-	ldlm_clear_skipped(lock);
-	LASSERT(ns->ns_nr_unused >= 0);
-	ns->ns_nr_unused++;
-}
-
-/**
- * Adds LDLM lock \a lock to namespace LRU. Obtains necessary LRU locks
- * first.
- */
-static void ldlm_lock_add_to_lru(struct ldlm_lock *lock)
-{
-	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
-
-	spin_lock(&ns->ns_lock);
-	ldlm_lock_add_to_lru_nolock(lock);
-	spin_unlock(&ns->ns_lock);
-}
-
-/**
- * Moves LDLM lock \a lock that is already in namespace LRU to the tail of
- * the LRU. Performs necessary LRU locking
- */
-static void ldlm_lock_touch_in_lru(struct ldlm_lock *lock)
-{
-	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
-
-	spin_lock(&ns->ns_lock);
-	if (!list_empty(&lock->l_lru)) {
-		ldlm_lock_remove_from_lru_nolock(lock);
-		ldlm_lock_add_to_lru_nolock(lock);
-	}
-	spin_unlock(&ns->ns_lock);
-}
-
-/**
- * Helper to destroy a locked lock.
- *
- * Used by ldlm_lock_destroy and ldlm_lock_destroy_nolock
- * Must be called with l_lock and lr_lock held.
- *
- * Does not actually free the lock data, but rather marks the lock as
- * destroyed by setting l_destroyed field in the lock to 1.  Destroys a
- * handle->lock association too, so that the lock can no longer be found
- * and removes the lock from LRU list.  Actual lock freeing occurs when
- * last lock reference goes away.
- *
- * Original comment (of some historical value):
- * This used to have a 'strict' flag, which recovery would use to mark an
- * in-use lock as needing-to-die.  Lest I am ever tempted to put it back, I
- * shall explain why it's gone: with the new hash table scheme, once you call
- * ldlm_lock_destroy, you can never drop your final references on this lock.
- * Because it's not in the hash table anymore.  -phil
- */
-static int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
-{
-	if (lock->l_readers || lock->l_writers) {
-		LDLM_ERROR(lock, "lock still has references");
-		LBUG();
-	}
-
-	if (!list_empty(&lock->l_res_link)) {
-		LDLM_ERROR(lock, "lock still on resource");
-		LBUG();
-	}
-
-	if (ldlm_is_destroyed(lock)) {
-		LASSERT(list_empty(&lock->l_lru));
-		return 0;
-	}
-	ldlm_set_destroyed(lock);
-
-	ldlm_lock_remove_from_lru(lock);
-	class_handle_unhash(&lock->l_handle);
-
-	return 1;
-}
-
-/**
- * Destroys a LDLM lock \a lock. Performs necessary locking first.
- */
-static void ldlm_lock_destroy(struct ldlm_lock *lock)
-{
-	int first;
-
-	lock_res_and_lock(lock);
-	first = ldlm_lock_destroy_internal(lock);
-	unlock_res_and_lock(lock);
-
-	/* drop reference from hashtable only for first destroy */
-	if (first) {
-		lu_ref_del(&lock->l_reference, "hash", lock);
-		LDLM_LOCK_RELEASE(lock);
-	}
-}
-
-/**
- * Destroys a LDLM lock \a lock that is already locked.
- */
-void ldlm_lock_destroy_nolock(struct ldlm_lock *lock)
-{
-	int first;
-
-	first = ldlm_lock_destroy_internal(lock);
-	/* drop reference from hashtable only for first destroy */
-	if (first) {
-		lu_ref_del(&lock->l_reference, "hash", lock);
-		LDLM_LOCK_RELEASE(lock);
-	}
-}
-
-/* this is called by portals_handle2object with the handle lock taken */
-static void lock_handle_addref(void *lock)
-{
-	LDLM_LOCK_GET((struct ldlm_lock *)lock);
-}
-
-static void lock_handle_free(void *lock, int size)
-{
-	LASSERT(size == sizeof(struct ldlm_lock));
-	kmem_cache_free(ldlm_lock_slab, lock);
-}
-
-static struct portals_handle_ops lock_handle_ops = {
-	.hop_addref = lock_handle_addref,
-	.hop_free   = lock_handle_free,
-};
-
-/**
- *
- * Allocate and initialize new lock structure.
- *
- * usage: pass in a resource on which you have done ldlm_resource_get
- *	new lock will take over the refcount.
- * returns: lock with refcount 2 - one for current caller and one for remote
- */
-static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
-{
-	struct ldlm_lock *lock;
-
-	LASSERT(resource);
-
-	lock = kmem_cache_zalloc(ldlm_lock_slab, GFP_NOFS);
-	if (!lock)
-		return NULL;
-
-	spin_lock_init(&lock->l_lock);
-	lock->l_resource = resource;
-	lu_ref_add(&resource->lr_reference, "lock", lock);
-
-	atomic_set(&lock->l_refc, 2);
-	INIT_LIST_HEAD(&lock->l_res_link);
-	INIT_LIST_HEAD(&lock->l_lru);
-	INIT_LIST_HEAD(&lock->l_pending_chain);
-	INIT_LIST_HEAD(&lock->l_bl_ast);
-	INIT_LIST_HEAD(&lock->l_cp_ast);
-	INIT_LIST_HEAD(&lock->l_rk_ast);
-	init_waitqueue_head(&lock->l_waitq);
-	lock->l_blocking_lock = NULL;
-	INIT_LIST_HEAD(&lock->l_sl_mode);
-	INIT_LIST_HEAD(&lock->l_sl_policy);
-	RB_CLEAR_NODE(&lock->l_rb);
-
-	lprocfs_counter_incr(ldlm_res_to_ns(resource)->ns_stats,
-			     LDLM_NSS_LOCKS);
-	INIT_LIST_HEAD(&lock->l_handle.h_link);
-	class_handle_hash(&lock->l_handle, &lock_handle_ops);
-
-	lu_ref_init(&lock->l_reference);
-	lu_ref_add(&lock->l_reference, "hash", lock);
-	lock->l_callback_timeout = 0;
-
-#if LUSTRE_TRACKS_LOCK_EXP_REFS
-	INIT_LIST_HEAD(&lock->l_exp_refs_link);
-	lock->l_exp_refs_nr = 0;
-	lock->l_exp_refs_target = NULL;
-#endif
-
-	return lock;
-}
-
-/**
- * Moves LDLM lock \a lock to another resource.
- * This is used on client when server returns some other lock than requested
- * (typically as a result of intent operation)
- */
-int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
-			      const struct ldlm_res_id *new_resid)
-{
-	struct ldlm_resource *oldres = lock->l_resource;
-	struct ldlm_resource *newres;
-	int type;
-
-	lock_res_and_lock(lock);
-	if (memcmp(new_resid, &lock->l_resource->lr_name,
-		   sizeof(lock->l_resource->lr_name)) == 0) {
-		/* Nothing to do */
-		unlock_res_and_lock(lock);
-		return 0;
-	}
-
-	LASSERT(new_resid->name[0] != 0);
-
-	/* This function assumes that the lock isn't on any lists */
-	LASSERT(list_empty(&lock->l_res_link));
-
-	type = oldres->lr_type;
-	unlock_res_and_lock(lock);
-
-	newres = ldlm_resource_get(ns, NULL, new_resid, type, 1);
-	if (IS_ERR(newres))
-		return PTR_ERR(newres);
-
-	lu_ref_add(&newres->lr_reference, "lock", lock);
-	/*
-	 * To flip the lock from the old to the new resource, lock, oldres and
-	 * newres have to be locked. Resource spin-locks are nested within
-	 * lock->l_lock, and are taken in the memory address order to avoid
-	 * dead-locks.
-	 */
-	spin_lock(&lock->l_lock);
-	oldres = lock->l_resource;
-	if (oldres < newres) {
-		lock_res(oldres);
-		lock_res_nested(newres, LRT_NEW);
-	} else {
-		lock_res(newres);
-		lock_res_nested(oldres, LRT_NEW);
-	}
-	LASSERT(memcmp(new_resid, &oldres->lr_name,
-		       sizeof(oldres->lr_name)) != 0);
-	lock->l_resource = newres;
-	unlock_res(oldres);
-	unlock_res_and_lock(lock);
-
-	/* ...and the flowers are still standing! */
-	lu_ref_del(&oldres->lr_reference, "lock", lock);
-	ldlm_resource_putref(oldres);
-
-	return 0;
-}
-
-/** \defgroup ldlm_handles LDLM HANDLES
- * Ways to get hold of locks without any addresses.
- * @{
- */
-
-/**
- * Fills in handle for LDLM lock \a lock into supplied \a lockh
- * Does not take any references.
- */
-void ldlm_lock2handle(const struct ldlm_lock *lock, struct lustre_handle *lockh)
-{
-	lockh->cookie = lock->l_handle.h_cookie;
-}
-EXPORT_SYMBOL(ldlm_lock2handle);
-
-/**
- * Obtain a lock reference by handle.
- *
- * if \a flags: atomically get the lock and set the flags.
- *	      Return NULL if flag already set
- */
-struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
-				     __u64 flags)
-{
-	struct ldlm_lock *lock;
-
-	LASSERT(handle);
-
-	lock = class_handle2object(handle->cookie, NULL);
-	if (!lock)
-		return NULL;
-
-	if (lock->l_export && lock->l_export->exp_failed) {
-		CDEBUG(D_INFO, "lock export failed: lock %p, exp %p\n",
-		       lock, lock->l_export);
-		LDLM_LOCK_PUT(lock);
-		return NULL;
-	}
-
-	/* It's unlikely but possible that someone marked the lock as
-	 * destroyed after we did handle2object on it
-	 */
-	if (flags == 0 && !ldlm_is_destroyed(lock)) {
-		lu_ref_add(&lock->l_reference, "handle", current);
-		return lock;
-	}
-
-	lock_res_and_lock(lock);
-
-	LASSERT(lock->l_resource);
-
-	lu_ref_add_atomic(&lock->l_reference, "handle", current);
-	if (unlikely(ldlm_is_destroyed(lock))) {
-		unlock_res_and_lock(lock);
-		CDEBUG(D_INFO, "lock already destroyed: lock %p\n", lock);
-		LDLM_LOCK_PUT(lock);
-		return NULL;
-	}
-
-	if (flags) {
-		if (lock->l_flags & flags) {
-			unlock_res_and_lock(lock);
-			LDLM_LOCK_PUT(lock);
-			return NULL;
-		}
-
-		lock->l_flags |= flags;
-	}
-
-	unlock_res_and_lock(lock);
-	return lock;
-}
-EXPORT_SYMBOL(__ldlm_handle2lock);
-/** @} ldlm_handles */
-
-/**
- * Fill in "on the wire" representation for given LDLM lock into supplied
- * lock descriptor \a desc structure.
- */
-void ldlm_lock2desc(struct ldlm_lock *lock, struct ldlm_lock_desc *desc)
-{
-	ldlm_res2desc(lock->l_resource, &desc->l_resource);
-	desc->l_req_mode = lock->l_req_mode;
-	desc->l_granted_mode = lock->l_granted_mode;
-	ldlm_convert_policy_to_wire(lock->l_resource->lr_type,
-				    &lock->l_policy_data,
-				    &desc->l_policy_data);
-}
-
-/**
- * Add a lock to list of conflicting locks to send AST to.
- *
- * Only add if we have not sent a blocking AST to the lock yet.
- */
-static void ldlm_add_bl_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
-				  struct list_head *work_list)
-{
-	if (!ldlm_is_ast_sent(lock)) {
-		LDLM_DEBUG(lock, "lock incompatible; sending blocking AST.");
-		ldlm_set_ast_sent(lock);
-		/* If the enqueuing client said so, tell the AST recipient to
-		 * discard dirty data, rather than writing back.
-		 */
-		if (ldlm_is_ast_discard_data(new))
-			ldlm_set_discard_data(lock);
-		LASSERT(list_empty(&lock->l_bl_ast));
-		list_add(&lock->l_bl_ast, work_list);
-		LDLM_LOCK_GET(lock);
-		LASSERT(!lock->l_blocking_lock);
-		lock->l_blocking_lock = LDLM_LOCK_GET(new);
-	}
-}
-
-/**
- * Add a lock to list of just granted locks to send completion AST to.
- */
-static void ldlm_add_cp_work_item(struct ldlm_lock *lock,
-				  struct list_head *work_list)
-{
-	if (!ldlm_is_cp_reqd(lock)) {
-		ldlm_set_cp_reqd(lock);
-		LDLM_DEBUG(lock, "lock granted; sending completion AST.");
-		LASSERT(list_empty(&lock->l_cp_ast));
-		list_add(&lock->l_cp_ast, work_list);
-		LDLM_LOCK_GET(lock);
-	}
-}
-
-/**
- * Aggregator function to add AST work items into a list. Determines
- * what sort of an AST work needs to be done and calls the proper
- * adding function.
- * Must be called with lr_lock held.
- */
-static void ldlm_add_ast_work_item(struct ldlm_lock *lock,
-				   struct ldlm_lock *new,
-				   struct list_head *work_list)
-{
-	check_res_locked(lock->l_resource);
-	if (new)
-		ldlm_add_bl_work_item(lock, new, work_list);
-	else
-		ldlm_add_cp_work_item(lock, work_list);
-}
-
-/**
- * Add specified reader/writer reference to LDLM lock with handle \a lockh.
- * r/w reference type is determined by \a mode
- * Calls ldlm_lock_addref_internal.
- */
-void ldlm_lock_addref(const struct lustre_handle *lockh, enum ldlm_mode mode)
-{
-	struct ldlm_lock *lock;
-
-	lock = ldlm_handle2lock(lockh);
-	LASSERTF(lock, "Non-existing lock: %llx\n", lockh->cookie);
-	ldlm_lock_addref_internal(lock, mode);
-	LDLM_LOCK_PUT(lock);
-}
-EXPORT_SYMBOL(ldlm_lock_addref);
-
-/**
- * Helper function.
- * Add specified reader/writer reference to LDLM lock \a lock.
- * r/w reference type is determined by \a mode
- * Removes lock from LRU if it is there.
- * Assumes the LDLM lock is already locked.
- */
-void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
-				      enum ldlm_mode mode)
-{
-	ldlm_lock_remove_from_lru(lock);
-	if (mode & (LCK_NL | LCK_CR | LCK_PR)) {
-		lock->l_readers++;
-		lu_ref_add_atomic(&lock->l_reference, "reader", lock);
-	}
-	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS)) {
-		lock->l_writers++;
-		lu_ref_add_atomic(&lock->l_reference, "writer", lock);
-	}
-	LDLM_LOCK_GET(lock);
-	lu_ref_add_atomic(&lock->l_reference, "user", lock);
-	LDLM_DEBUG(lock, "ldlm_lock_addref(%s)", ldlm_lockname[mode]);
-}
-
-/**
- * Attempts to add reader/writer reference to a lock with handle \a lockh, and
- * fails if lock is already LDLM_FL_CBPENDING or destroyed.
- *
- * \retval 0 success, lock was addref-ed
- *
- * \retval -EAGAIN lock is being canceled.
- */
-int ldlm_lock_addref_try(const struct lustre_handle *lockh, enum ldlm_mode mode)
-{
-	struct ldlm_lock *lock;
-	int	       result;
-
-	result = -EAGAIN;
-	lock = ldlm_handle2lock(lockh);
-	if (lock) {
-		lock_res_and_lock(lock);
-		if (lock->l_readers != 0 || lock->l_writers != 0 ||
-		    !ldlm_is_cbpending(lock)) {
-			ldlm_lock_addref_internal_nolock(lock, mode);
-			result = 0;
-		}
-		unlock_res_and_lock(lock);
-		LDLM_LOCK_PUT(lock);
-	}
-	return result;
-}
-EXPORT_SYMBOL(ldlm_lock_addref_try);
-
-/**
- * Add specified reader/writer reference to LDLM lock \a lock.
- * Locks LDLM lock and calls ldlm_lock_addref_internal_nolock to do the work.
- * Only called for local locks.
- */
-void ldlm_lock_addref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
-{
-	lock_res_and_lock(lock);
-	ldlm_lock_addref_internal_nolock(lock, mode);
-	unlock_res_and_lock(lock);
-}
-
-/**
- * Removes reader/writer reference for LDLM lock \a lock.
- * Assumes LDLM lock is already locked.
- * only called in ldlm_flock_destroy and for local locks.
- * Does NOT add lock to LRU if no r/w references left to accommodate flock locks
- * that cannot be placed in LRU.
- */
-void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
-				      enum ldlm_mode mode)
-{
-	LDLM_DEBUG(lock, "ldlm_lock_decref(%s)", ldlm_lockname[mode]);
-	if (mode & (LCK_NL | LCK_CR | LCK_PR)) {
-		LASSERT(lock->l_readers > 0);
-		lu_ref_del(&lock->l_reference, "reader", lock);
-		lock->l_readers--;
-	}
-	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS)) {
-		LASSERT(lock->l_writers > 0);
-		lu_ref_del(&lock->l_reference, "writer", lock);
-		lock->l_writers--;
-	}
-
-	lu_ref_del(&lock->l_reference, "user", lock);
-	LDLM_LOCK_RELEASE(lock);    /* matches the LDLM_LOCK_GET() in addref */
-}
-
-/**
- * Removes reader/writer reference for LDLM lock \a lock.
- * Locks LDLM lock first.
- * If the lock is determined to be client lock on a client and r/w refcount
- * drops to zero and the lock is not blocked, the lock is added to LRU lock
- * on the namespace.
- * For blocked LDLM locks if r/w count drops to zero, blocking_ast is called.
- */
-void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
-{
-	struct ldlm_namespace *ns;
-
-	lock_res_and_lock(lock);
-
-	ns = ldlm_lock_to_ns(lock);
-
-	ldlm_lock_decref_internal_nolock(lock, mode);
-
-	if ((ldlm_is_local(lock) || lock->l_req_mode == LCK_GROUP) &&
-	    !lock->l_readers && !lock->l_writers) {
-		/* If this is a local lock on a server namespace and this was
-		 * the last reference, cancel the lock.
-		 *
-		 * Group locks are special:
-		 * They must not go in LRU, but they are not called back
-		 * like non-group locks, instead they are manually released.
-		 * They have an l_writers reference which they keep until
-		 * they are manually released, so we remove them when they have
-		 * no more reader or writer references. - LU-6368
-		 */
-		ldlm_set_cbpending(lock);
-	}
-
-	if (!lock->l_readers && !lock->l_writers && ldlm_is_cbpending(lock)) {
-		/* If we received a blocked AST and this was the last reference,
-		 * run the callback.
-		 */
-		LDLM_DEBUG(lock, "final decref done on cbpending lock");
-
-		LDLM_LOCK_GET(lock); /* dropped by bl thread */
-		ldlm_lock_remove_from_lru(lock);
-		unlock_res_and_lock(lock);
-
-		if (ldlm_is_fail_loc(lock))
-			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
-
-		if (ldlm_is_atomic_cb(lock) ||
-		    ldlm_bl_to_thread_lock(ns, NULL, lock) != 0)
-			ldlm_handle_bl_callback(ns, NULL, lock);
-	} else if (!lock->l_readers && !lock->l_writers &&
-		   !ldlm_is_no_lru(lock) && !ldlm_is_bl_ast(lock)) {
-		LDLM_DEBUG(lock, "add lock into lru list");
-
-		/* If this is a client-side namespace and this was the last
-		 * reference, put it on the LRU.
-		 */
-		ldlm_lock_add_to_lru(lock);
-		unlock_res_and_lock(lock);
-
-		if (ldlm_is_fail_loc(lock))
-			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
-
-		/* Call ldlm_cancel_lru() only if EARLY_CANCEL and LRU RESIZE
-		 * are not supported by the server, otherwise, it is done on
-		 * enqueue.
-		 */
-		if (!exp_connect_cancelset(lock->l_conn_export) &&
-		    !ns_connect_lru_resize(ns))
-			ldlm_cancel_lru(ns, 0, LCF_ASYNC, 0);
-	} else {
-		LDLM_DEBUG(lock, "do not add lock into lru list");
-		unlock_res_and_lock(lock);
-	}
-}
-
-/**
- * Decrease reader/writer refcount for LDLM lock with handle \a lockh
- */
-void ldlm_lock_decref(const struct lustre_handle *lockh, enum ldlm_mode mode)
-{
-	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
-
-	LASSERTF(lock, "Non-existing lock: %#llx\n", lockh->cookie);
-	ldlm_lock_decref_internal(lock, mode);
-	LDLM_LOCK_PUT(lock);
-}
-EXPORT_SYMBOL(ldlm_lock_decref);
-
-/**
- * Decrease reader/writer refcount for LDLM lock with handle
- * \a lockh and mark it for subsequent cancellation once r/w refcount
- * drops to zero instead of putting into LRU.
- */
-void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh,
-				 enum ldlm_mode mode)
-{
-	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
-
-	LASSERT(lock);
-
-	LDLM_DEBUG(lock, "ldlm_lock_decref(%s)", ldlm_lockname[mode]);
-	lock_res_and_lock(lock);
-	ldlm_set_cbpending(lock);
-	unlock_res_and_lock(lock);
-	ldlm_lock_decref_internal(lock, mode);
-	LDLM_LOCK_PUT(lock);
-}
-EXPORT_SYMBOL(ldlm_lock_decref_and_cancel);
-
-struct sl_insert_point {
-	struct list_head *res_link;
-	struct list_head *mode_link;
-	struct list_head *policy_link;
-};
-
-/**
- * Finds a position to insert the new lock into granted lock list.
- *
- * Used for locks eligible for skiplist optimization.
- *
- * Parameters:
- *      queue [input]:  the granted list where search acts on;
- *      req [input]:    the lock whose position to be located;
- *      prev [output]:  positions within 3 lists to insert @req to
- * Return Value:
- *      filled @prev
- * NOTE: called by
- *  - ldlm_grant_lock_with_skiplist
- */
-static void search_granted_lock(struct list_head *queue,
-				struct ldlm_lock *req,
-				struct sl_insert_point *prev)
-{
-	struct ldlm_lock *lock, *mode_end, *policy_end;
-
-	list_for_each_entry(lock, queue, l_res_link) {
-
-		mode_end = list_prev_entry(lock, l_sl_mode);
-
-		if (lock->l_req_mode != req->l_req_mode) {
-			/* jump to last lock of mode group */
-			lock = mode_end;
-			continue;
-		}
-
-		/* suitable mode group is found */
-		if (lock->l_resource->lr_type == LDLM_PLAIN) {
-			/* insert point is last lock of the mode group */
-			prev->res_link = &mode_end->l_res_link;
-			prev->mode_link = &mode_end->l_sl_mode;
-			prev->policy_link = &req->l_sl_policy;
-			return;
-		}
-
-		if (lock->l_resource->lr_type == LDLM_IBITS) {
-			for (;;) {
-				policy_end =
-					list_prev_entry(lock, l_sl_policy);
-
-				if (lock->l_policy_data.l_inodebits.bits ==
-				    req->l_policy_data.l_inodebits.bits) {
-					/* insert point is last lock of
-					 * the policy group
-					 */
-					prev->res_link =
-						&policy_end->l_res_link;
-					prev->mode_link =
-						&policy_end->l_sl_mode;
-					prev->policy_link =
-						&policy_end->l_sl_policy;
-					return;
-				}
-
-				if (policy_end == mode_end)
-					/* done with mode group */
-					break;
-
-				/* go to next policy group within mode group */
-				lock = list_next_entry(policy_end, l_res_link);
-			}  /* loop over policy groups within the mode group */
-
-			/* insert point is last lock of the mode group,
-			 * new policy group is started
-			 */
-			prev->res_link = &mode_end->l_res_link;
-			prev->mode_link = &mode_end->l_sl_mode;
-			prev->policy_link = &req->l_sl_policy;
-			return;
-		}
-
-		LDLM_ERROR(lock, "is not LDLM_PLAIN or LDLM_IBITS lock");
-		LBUG();
-	}
-
-	/* insert point is last lock on the queue,
-	 * new mode group and new policy group are started
-	 */
-	prev->res_link = queue->prev;
-	prev->mode_link = &req->l_sl_mode;
-	prev->policy_link = &req->l_sl_policy;
-}
-
-/**
- * Add a lock into resource granted list after a position described by
- * \a prev.
- */
-static void ldlm_granted_list_add_lock(struct ldlm_lock *lock,
-				       struct sl_insert_point *prev)
-{
-	struct ldlm_resource *res = lock->l_resource;
-
-	check_res_locked(res);
-
-	ldlm_resource_dump(D_INFO, res);
-	LDLM_DEBUG(lock, "About to add lock:");
-
-	if (ldlm_is_destroyed(lock)) {
-		CDEBUG(D_OTHER, "Lock destroyed, not adding to resource\n");
-		return;
-	}
-
-	LASSERT(list_empty(&lock->l_res_link));
-	LASSERT(list_empty(&lock->l_sl_mode));
-	LASSERT(list_empty(&lock->l_sl_policy));
-
-	/*
-	 * lock->link == prev->link means lock is first starting the group.
-	 * Don't re-add to itself to suppress kernel warnings.
-	 */
-	if (&lock->l_res_link != prev->res_link)
-		list_add(&lock->l_res_link, prev->res_link);
-	if (&lock->l_sl_mode != prev->mode_link)
-		list_add(&lock->l_sl_mode, prev->mode_link);
-	if (&lock->l_sl_policy != prev->policy_link)
-		list_add(&lock->l_sl_policy, prev->policy_link);
-}
-
-/**
- * Add a lock to granted list on a resource maintaining skiplist
- * correctness.
- */
-static void ldlm_grant_lock_with_skiplist(struct ldlm_lock *lock)
-{
-	struct sl_insert_point prev;
-
-	LASSERT(lock->l_req_mode == lock->l_granted_mode);
-
-	search_granted_lock(&lock->l_resource->lr_granted, lock, &prev);
-	ldlm_granted_list_add_lock(lock, &prev);
-}
-
-/**
- * Perform lock granting bookkeeping.
- *
- * Includes putting the lock into granted list and updating lock mode.
- * NOTE: called by
- *  - ldlm_lock_enqueue
- *  - ldlm_reprocess_queue
- *  - ldlm_lock_convert
- *
- * must be called with lr_lock held
- */
-void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
-{
-	struct ldlm_resource *res = lock->l_resource;
-
-	check_res_locked(res);
-
-	lock->l_granted_mode = lock->l_req_mode;
-
-	if (work_list && lock->l_completion_ast)
-		ldlm_add_ast_work_item(lock, NULL, work_list);
-
-	if (res->lr_type == LDLM_PLAIN || res->lr_type == LDLM_IBITS) {
-		ldlm_grant_lock_with_skiplist(lock);
-	} else if (res->lr_type == LDLM_EXTENT) {
-		ldlm_extent_add_lock(res, lock);
-	} else if (res->lr_type == LDLM_FLOCK) {
-		/*
-		 * We should not add locks to granted list in
-		 * the following cases:
-		 * - this is an UNLOCK but not a real lock;
-		 * - this is a TEST lock;
-		 * - this is a F_CANCELLK lock (async flock has req_mode == 0)
-		 * - this is a deadlock (flock cannot be granted)
-		 */
-		if (!lock->l_req_mode || lock->l_req_mode == LCK_NL ||
-		    ldlm_is_test_lock(lock) || ldlm_is_flock_deadlock(lock))
-			return;
-		ldlm_resource_add_lock(res, &res->lr_granted, lock);
-	} else {
-		LBUG();
-	}
-
-	ldlm_pool_add(&ldlm_res_to_ns(res)->ns_pool, lock);
-}
-
-/**
- * Describe the overlap between two locks.  itree_overlap_cb data.
- */
-struct lock_match_data {
-	struct ldlm_lock	*lmd_old;
-	struct ldlm_lock	*lmd_lock;
-	enum ldlm_mode		*lmd_mode;
-	union ldlm_policy_data	*lmd_policy;
-	__u64			 lmd_flags;
-	int			 lmd_unref;
-};
-
-/**
- * Check if the given @lock meets the criteria for a match.
- * A reference on the lock is taken if matched.
- *
- * \param lock	test-against this lock
- * \param data	parameters
- */
-static bool lock_matches(struct ldlm_lock *lock, void *vdata)
-{
-	struct lock_match_data *data = vdata;
-	union ldlm_policy_data *lpol = &lock->l_policy_data;
-	enum ldlm_mode match;
-
-	if (lock == data->lmd_old)
-		return true;
-
-	/*
-	 * Check if this lock can be matched.
-	 * Used by LU-2919(exclusive open) for open lease lock
-	 */
-	if (ldlm_is_excl(lock))
-		return false;
-
-	/*
-	 * llite sometimes wants to match locks that will be
-	 * canceled when their users drop, but we allow it to match
-	 * if it passes in CBPENDING and the lock still has users.
-	 * this is generally only going to be used by children
-	 * whose parents already hold a lock so forward progress
-	 * can still happen.
-	 */
-	if (ldlm_is_cbpending(lock) &&
-	    !(data->lmd_flags & LDLM_FL_CBPENDING))
-		return false;
-
-	if (!data->lmd_unref && ldlm_is_cbpending(lock) &&
-	    !lock->l_readers && !lock->l_writers)
-		return false;
-
-	if (!(lock->l_req_mode & *data->lmd_mode))
-		return false;
-	match = lock->l_req_mode;
-
-	switch (lock->l_resource->lr_type) {
-	case LDLM_EXTENT:
-		if (lpol->l_extent.start > data->lmd_policy->l_extent.start ||
-		    lpol->l_extent.end < data->lmd_policy->l_extent.end)
-			return false;
-
-		if (unlikely(match == LCK_GROUP) &&
-		    data->lmd_policy->l_extent.gid != LDLM_GID_ANY &&
-		    lpol->l_extent.gid != data->lmd_policy->l_extent.gid)
-			return false;
-		break;
-	case LDLM_IBITS:
-		/*
-		 * We match if we have existing lock with same or wider set
-		 * of bits.
-		 */
-		if ((lpol->l_inodebits.bits &
-		     data->lmd_policy->l_inodebits.bits) !=
-		    data->lmd_policy->l_inodebits.bits)
-			return false;
-		break;
-	default:
-		break;
-	}
-	/*
-	 * We match if we have existing lock with same or wider set
-	 * of bits.
-	 */
-	if (!data->lmd_unref && LDLM_HAVE_MASK(lock, GONE))
-		return false;
-
-	if (!equi(data->lmd_flags & LDLM_FL_LOCAL_ONLY, ldlm_is_local(lock)))
-		return false;
-
-	if (data->lmd_flags & LDLM_FL_TEST_LOCK) {
-		LDLM_LOCK_GET(lock);
-		ldlm_lock_touch_in_lru(lock);
-	} else {
-		ldlm_lock_addref_internal_nolock(lock, match);
-	}
-
-	*data->lmd_mode = match;
-	data->lmd_lock = lock;
-
-	return true;
-}
-
-/**
- * Search for a lock with given parameters in interval trees.
- *
- * \param res	search for a lock in this resource
- * \param data	parameters
- *
- * \retval	a referenced lock or NULL.
- */
-static struct ldlm_lock *search_itree(struct ldlm_resource *res,
-				      struct lock_match_data *data)
-{
-	int idx;
-
-	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
-		struct ldlm_interval_tree *tree = &res->lr_itree[idx];
-
-		if (RB_EMPTY_ROOT(&tree->lit_root.rb_root))
-			continue;
-
-		if (!(tree->lit_mode & *data->lmd_mode))
-			continue;
-
-		ldlm_extent_search(&tree->lit_root,
-				   data->lmd_policy->l_extent.start,
-				   data->lmd_policy->l_extent.end,
-				   lock_matches, data);
-	}
-	return data->lmd_lock;
-}
-
-/**
- * Search for a lock with given properties in a queue.
- *
- * \param queue	search for a lock in this queue
- * \param data	parameters
- *
- * \retval	a referenced lock or NULL.
- */
-static struct ldlm_lock *search_queue(struct list_head *queue,
-				      struct lock_match_data *data)
-{
-	struct ldlm_lock *lock;
-
-	list_for_each_entry(lock, queue, l_res_link)
-		if (lock_matches(lock, data))
-			return data->lmd_lock;
-	return NULL;
-}
-
-void ldlm_lock_fail_match_locked(struct ldlm_lock *lock)
-{
-	if ((lock->l_flags & LDLM_FL_FAIL_NOTIFIED) == 0) {
-		lock->l_flags |= LDLM_FL_FAIL_NOTIFIED;
-		wake_up_all(&lock->l_waitq);
-	}
-}
-
-/**
- * Mark lock as "matchable" by OST.
- *
- * Used to prevent certain races in LOV/OSC where the lock is granted, but LVB
- * is not yet valid.
- * Assumes LDLM lock is already locked.
- */
-void ldlm_lock_allow_match_locked(struct ldlm_lock *lock)
-{
-	ldlm_set_lvb_ready(lock);
-	wake_up_all(&lock->l_waitq);
-}
-EXPORT_SYMBOL(ldlm_lock_allow_match_locked);
-
-/**
- * Mark lock as "matchable" by OST.
- * Locks the lock and then \see ldlm_lock_allow_match_locked
- */
-void ldlm_lock_allow_match(struct ldlm_lock *lock)
-{
-	lock_res_and_lock(lock);
-	ldlm_lock_allow_match_locked(lock);
-	unlock_res_and_lock(lock);
-}
-EXPORT_SYMBOL(ldlm_lock_allow_match);
-
-/**
- * Attempt to find a lock with specified properties.
- *
- * Typically returns a reference to matched lock unless LDLM_FL_TEST_LOCK is
- * set in \a flags
- *
- * Can be called in two ways:
- *
- * If 'ns' is NULL, then lockh describes an existing lock that we want to look
- * for a duplicate of.
- *
- * Otherwise, all of the fields must be filled in, to match against.
- *
- * If 'flags' contains LDLM_FL_LOCAL_ONLY, then only match local locks on the
- *     server (ie, connh is NULL)
- * If 'flags' contains LDLM_FL_BLOCK_GRANTED, then only locks on the granted
- *     list will be considered
- * If 'flags' contains LDLM_FL_CBPENDING, then locks that have been marked
- *     to be canceled can still be matched as long as they still have reader
- *     or writer referneces
- * If 'flags' contains LDLM_FL_TEST_LOCK, then don't actually reference a lock,
- *     just tell us if we would have matched.
- *
- * \retval 1 if it finds an already-existing lock that is compatible; in this
- * case, lockh is filled in with a addref()ed lock
- *
- * We also check security context, and if that fails we simply return 0 (to
- * keep caller code unchanged), the context failure will be discovered by
- * caller sometime later.
- */
-enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
-			       const struct ldlm_res_id *res_id,
-			       enum ldlm_type type,
-			       union ldlm_policy_data *policy,
-			       enum ldlm_mode mode,
-			       struct lustre_handle *lockh, int unref)
-{
-	struct lock_match_data data = {
-		.lmd_old	= NULL,
-		.lmd_lock	= NULL,
-		.lmd_mode	= &mode,
-		.lmd_policy	= policy,
-		.lmd_flags	= flags,
-		.lmd_unref	= unref,
-	};
-	struct ldlm_resource *res;
-	struct ldlm_lock *lock;
-	int rc = 0;
-
-	if (!ns) {
-		data.lmd_old = ldlm_handle2lock(lockh);
-		LASSERT(data.lmd_old);
-
-		ns = ldlm_lock_to_ns(data.lmd_old);
-		res_id = &data.lmd_old->l_resource->lr_name;
-		type = data.lmd_old->l_resource->lr_type;
-		*data.lmd_mode = data.lmd_old->l_req_mode;
-	}
-
-	res = ldlm_resource_get(ns, NULL, res_id, type, 0);
-	if (IS_ERR(res)) {
-		LASSERT(!data.lmd_old);
-		return 0;
-	}
-
-	LDLM_RESOURCE_ADDREF(res);
-	lock_res(res);
-
-	if (res->lr_type == LDLM_EXTENT)
-		lock = search_itree(res, &data);
-	else
-		lock = search_queue(&res->lr_granted, &data);
-	if (lock) {
-		rc = 1;
-		goto out;
-	}
-	if (flags & LDLM_FL_BLOCK_GRANTED) {
-		rc = 0;
-		goto out;
-	}
-	lock = search_queue(&res->lr_waiting, &data);
-	if (lock) {
-		rc = 1;
-		goto out;
-	}
-out:
-	unlock_res(res);
-	LDLM_RESOURCE_DELREF(res);
-	ldlm_resource_putref(res);
-
-	if (lock) {
-		ldlm_lock2handle(lock, lockh);
-		if ((flags & LDLM_FL_LVB_READY) && !ldlm_is_lvb_ready(lock)) {
-			__u64 wait_flags = LDLM_FL_LVB_READY |
-				LDLM_FL_DESTROYED | LDLM_FL_FAIL_NOTIFIED;
-
-			if (lock->l_completion_ast) {
-				int err = lock->l_completion_ast(lock,
-							  LDLM_FL_WAIT_NOREPROC,
-								 NULL);
-				if (err) {
-					if (flags & LDLM_FL_TEST_LOCK)
-						LDLM_LOCK_RELEASE(lock);
-					else
-						ldlm_lock_decref_internal(lock,
-									  mode);
-					rc = 0;
-					goto out2;
-				}
-			}
-
-			/* XXX FIXME see comment on CAN_MATCH in lustre_dlm.h */
-			wait_event_idle_timeout(lock->l_waitq,
-						lock->l_flags & wait_flags,
-						obd_timeout * HZ);
-			if (!ldlm_is_lvb_ready(lock)) {
-				if (flags & LDLM_FL_TEST_LOCK)
-					LDLM_LOCK_RELEASE(lock);
-				else
-					ldlm_lock_decref_internal(lock, mode);
-				rc = 0;
-			}
-		}
-	}
- out2:
-	if (rc) {
-		LDLM_DEBUG(lock, "matched (%llu %llu)",
-			   (type == LDLM_PLAIN || type == LDLM_IBITS) ?
-				res_id->name[2] : policy->l_extent.start,
-			   (type == LDLM_PLAIN || type == LDLM_IBITS) ?
-				res_id->name[3] : policy->l_extent.end);
-
-		/* check user's security context */
-		if (lock->l_conn_export &&
-		    sptlrpc_import_check_ctx(
-				class_exp2cliimp(lock->l_conn_export))) {
-			if (!(flags & LDLM_FL_TEST_LOCK))
-				ldlm_lock_decref_internal(lock, mode);
-			rc = 0;
-		}
-
-		if (flags & LDLM_FL_TEST_LOCK)
-			LDLM_LOCK_RELEASE(lock);
-
-	} else if (!(flags & LDLM_FL_TEST_LOCK)) {/*less verbose for test-only*/
-		LDLM_DEBUG_NOLOCK("not matched ns %p type %u mode %u res %llu/%llu (%llu %llu)",
-				  ns, type, mode, res_id->name[0],
-				  res_id->name[1],
-				  (type == LDLM_PLAIN || type == LDLM_IBITS) ?
-					res_id->name[2] : policy->l_extent.start,
-				  (type == LDLM_PLAIN || type == LDLM_IBITS) ?
-					res_id->name[3] : policy->l_extent.end);
-	}
-	if (data.lmd_old)
-		LDLM_LOCK_PUT(data.lmd_old);
-
-	return rc ? mode : 0;
-}
-EXPORT_SYMBOL(ldlm_lock_match);
-
-enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
-					   __u64 *bits)
-{
-	struct ldlm_lock *lock;
-	enum ldlm_mode mode = 0;
-
-	lock = ldlm_handle2lock(lockh);
-	if (lock) {
-		lock_res_and_lock(lock);
-		if (LDLM_HAVE_MASK(lock, GONE))
-			goto out;
-
-		if (ldlm_is_cbpending(lock) &&
-		    lock->l_readers == 0 && lock->l_writers == 0)
-			goto out;
-
-		if (bits)
-			*bits = lock->l_policy_data.l_inodebits.bits;
-		mode = lock->l_granted_mode;
-		ldlm_lock_addref_internal_nolock(lock, mode);
-	}
-
-out:
-	if (lock) {
-		unlock_res_and_lock(lock);
-		LDLM_LOCK_PUT(lock);
-	}
-	return mode;
-}
-EXPORT_SYMBOL(ldlm_revalidate_lock_handle);
-
-/** The caller must guarantee that the buffer is large enough. */
-int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
-		  enum req_location loc, void *data, int size)
-{
-	void *lvb;
-
-	LASSERT(data);
-	LASSERT(size >= 0);
-
-	switch (lock->l_lvb_type) {
-	case LVB_T_OST:
-		if (size == sizeof(struct ost_lvb)) {
-			if (loc == RCL_CLIENT)
-				lvb = req_capsule_client_swab_get(pill,
-								  &RMF_DLM_LVB,
-							lustre_swab_ost_lvb);
-			else
-				lvb = req_capsule_server_swab_get(pill,
-								  &RMF_DLM_LVB,
-							lustre_swab_ost_lvb);
-			if (unlikely(!lvb)) {
-				LDLM_ERROR(lock, "no LVB");
-				return -EPROTO;
-			}
-
-			memcpy(data, lvb, size);
-		} else if (size == sizeof(struct ost_lvb_v1)) {
-			struct ost_lvb *olvb = data;
-
-			if (loc == RCL_CLIENT)
-				lvb = req_capsule_client_swab_get(pill,
-								  &RMF_DLM_LVB,
-							lustre_swab_ost_lvb_v1);
-			else
-				lvb = req_capsule_server_sized_swab_get(pill,
-						&RMF_DLM_LVB, size,
-						lustre_swab_ost_lvb_v1);
-			if (unlikely(!lvb)) {
-				LDLM_ERROR(lock, "no LVB");
-				return -EPROTO;
-			}
-
-			memcpy(data, lvb, size);
-			olvb->lvb_mtime_ns = 0;
-			olvb->lvb_atime_ns = 0;
-			olvb->lvb_ctime_ns = 0;
-		} else {
-			LDLM_ERROR(lock, "Replied unexpected ost LVB size %d",
-				   size);
-			return -EINVAL;
-		}
-		break;
-	case LVB_T_LQUOTA:
-		if (size == sizeof(struct lquota_lvb)) {
-			if (loc == RCL_CLIENT)
-				lvb = req_capsule_client_swab_get(pill,
-								  &RMF_DLM_LVB,
-							lustre_swab_lquota_lvb);
-			else
-				lvb = req_capsule_server_swab_get(pill,
-								  &RMF_DLM_LVB,
-							lustre_swab_lquota_lvb);
-			if (unlikely(!lvb)) {
-				LDLM_ERROR(lock, "no LVB");
-				return -EPROTO;
-			}
-
-			memcpy(data, lvb, size);
-		} else {
-			LDLM_ERROR(lock,
-				   "Replied unexpected lquota LVB size %d",
-				   size);
-			return -EINVAL;
-		}
-		break;
-	case LVB_T_LAYOUT:
-		if (size == 0)
-			break;
-
-		if (loc == RCL_CLIENT)
-			lvb = req_capsule_client_get(pill, &RMF_DLM_LVB);
-		else
-			lvb = req_capsule_server_get(pill, &RMF_DLM_LVB);
-		if (unlikely(!lvb)) {
-			LDLM_ERROR(lock, "no LVB");
-			return -EPROTO;
-		}
-
-		memcpy(data, lvb, size);
-		break;
-	default:
-		LDLM_ERROR(lock, "Unknown LVB type: %d", lock->l_lvb_type);
-		dump_stack();
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-/**
- * Create and fill in new LDLM lock with specified properties.
- * Returns a referenced lock
- */
-struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
-				   const struct ldlm_res_id *res_id,
-				   enum ldlm_type type,
-				   enum ldlm_mode mode,
-				   const struct ldlm_callback_suite *cbs,
-				   void *data, __u32 lvb_len,
-				   enum lvb_type lvb_type)
-{
-	struct ldlm_lock *lock;
-	struct ldlm_resource *res;
-	int rc;
-
-	res = ldlm_resource_get(ns, NULL, res_id, type, 1);
-	if (IS_ERR(res))
-		return ERR_CAST(res);
-
-	lock = ldlm_lock_new(res);
-	if (!lock) {
-		ldlm_resource_putref(res);
-		return ERR_PTR(-ENOMEM);
-	}
-
-	lock->l_req_mode = mode;
-	lock->l_ast_data = data;
-	lock->l_pid = current->pid;
-	if (cbs) {
-		lock->l_blocking_ast = cbs->lcs_blocking;
-		lock->l_completion_ast = cbs->lcs_completion;
-		lock->l_glimpse_ast = cbs->lcs_glimpse;
-	}
-
-	if (lvb_len) {
-		lock->l_lvb_len = lvb_len;
-		lock->l_lvb_data = kzalloc(lvb_len, GFP_NOFS);
-		if (!lock->l_lvb_data) {
-			rc = -ENOMEM;
-			goto out;
-		}
-	}
-
-	lock->l_lvb_type = lvb_type;
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_NEW_LOCK)) {
-		rc = -ENOENT;
-		goto out;
-	}
-
-	return lock;
-
-out:
-	ldlm_lock_destroy(lock);
-	LDLM_LOCK_RELEASE(lock);
-	return ERR_PTR(rc);
-}
-
-
-
-/**
- * Enqueue (request) a lock.
- * On the client this is called from ldlm_cli_enqueue_fini
- * after we already got an initial reply from the server with some status.
- *
- * Does not block. As a result of enqueue the lock would be put
- * into granted or waiting list.
- */
-enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
-				  struct ldlm_lock **lockp,
-				  void *cookie, __u64 *flags)
-{
-	struct ldlm_lock *lock = *lockp;
-	struct ldlm_resource *res = lock->l_resource;
-
-	lock_res_and_lock(lock);
-	if (lock->l_req_mode == lock->l_granted_mode) {
-		/* The server returned a blocked lock, but it was granted
-		 * before we got a chance to actually enqueue it.  We don't
-		 * need to do anything else.
-		 */
-		*flags &= ~LDLM_FL_BLOCKED_MASK;
-		goto out;
-	}
-
-	ldlm_resource_unlink_lock(lock);
-
-	/* Some flags from the enqueue want to make it into the AST, via the
-	 * lock's l_flags.
-	 */
-	if (*flags & LDLM_FL_AST_DISCARD_DATA)
-		ldlm_set_ast_discard_data(lock);
-	if (*flags & LDLM_FL_TEST_LOCK)
-		ldlm_set_test_lock(lock);
-
-	/*
-	 * This distinction between local lock trees is very important; a client
-	 * namespace only has information about locks taken by that client, and
-	 * thus doesn't have enough information to decide for itself if it can
-	 * be granted (below).  In this case, we do exactly what the server
-	 * tells us to do, as dictated by the 'flags'.
-	 */
-	if (*flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED))
-		ldlm_resource_add_lock(res, &res->lr_waiting, lock);
-	else
-		ldlm_grant_lock(lock, NULL);
-
-out:
-	unlock_res_and_lock(lock);
-	return ELDLM_OK;
-}
-
-/**
- * Process a call to blocking AST callback for a lock in ast_work list
- */
-static int
-ldlm_work_bl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
-{
-	struct ldlm_cb_set_arg *arg = opaq;
-	struct ldlm_lock_desc   d;
-	int		     rc;
-	struct ldlm_lock       *lock;
-
-	if (list_empty(arg->list))
-		return -ENOENT;
-
-	lock = list_first_entry(arg->list, struct ldlm_lock, l_bl_ast);
-
-	/* nobody should touch l_bl_ast */
-	lock_res_and_lock(lock);
-	list_del_init(&lock->l_bl_ast);
-
-	LASSERT(ldlm_is_ast_sent(lock));
-	LASSERT(lock->l_bl_ast_run == 0);
-	LASSERT(lock->l_blocking_lock);
-	lock->l_bl_ast_run++;
-	unlock_res_and_lock(lock);
-
-	ldlm_lock2desc(lock->l_blocking_lock, &d);
-
-	rc = lock->l_blocking_ast(lock, &d, (void *)arg, LDLM_CB_BLOCKING);
-	LDLM_LOCK_RELEASE(lock->l_blocking_lock);
-	lock->l_blocking_lock = NULL;
-	LDLM_LOCK_RELEASE(lock);
-
-	return rc;
-}
-
-/**
- * Process a call to completion AST callback for a lock in ast_work list
- */
-static int
-ldlm_work_cp_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
-{
-	struct ldlm_cb_set_arg  *arg = opaq;
-	int		      rc = 0;
-	struct ldlm_lock	*lock;
-	ldlm_completion_callback completion_callback;
-
-	if (list_empty(arg->list))
-		return -ENOENT;
-
-	lock = list_first_entry(arg->list, struct ldlm_lock, l_cp_ast);
-
-	/* It's possible to receive a completion AST before we've set
-	 * the l_completion_ast pointer: either because the AST arrived
-	 * before the reply, or simply because there's a small race
-	 * window between receiving the reply and finishing the local
-	 * enqueue. (bug 842)
-	 *
-	 * This can't happen with the blocking_ast, however, because we
-	 * will never call the local blocking_ast until we drop our
-	 * reader/writer reference, which we won't do until we get the
-	 * reply and finish enqueueing.
-	 */
-
-	/* nobody should touch l_cp_ast */
-	lock_res_and_lock(lock);
-	list_del_init(&lock->l_cp_ast);
-	LASSERT(ldlm_is_cp_reqd(lock));
-	/* save l_completion_ast since it can be changed by
-	 * mds_intent_policy(), see bug 14225
-	 */
-	completion_callback = lock->l_completion_ast;
-	ldlm_clear_cp_reqd(lock);
-	unlock_res_and_lock(lock);
-
-	if (completion_callback)
-		rc = completion_callback(lock, 0, (void *)arg);
-	LDLM_LOCK_RELEASE(lock);
-
-	return rc;
-}
-
-/**
- * Process a call to revocation AST callback for a lock in ast_work list
- */
-static int
-ldlm_work_revoke_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
-{
-	struct ldlm_cb_set_arg *arg = opaq;
-	struct ldlm_lock_desc   desc;
-	int		     rc;
-	struct ldlm_lock       *lock;
-
-	if (list_empty(arg->list))
-		return -ENOENT;
-
-	lock = list_first_entry(arg->list, struct ldlm_lock, l_rk_ast);
-	list_del_init(&lock->l_rk_ast);
-
-	/* the desc just pretend to exclusive */
-	ldlm_lock2desc(lock, &desc);
-	desc.l_req_mode = LCK_EX;
-	desc.l_granted_mode = 0;
-
-	rc = lock->l_blocking_ast(lock, &desc, (void *)arg, LDLM_CB_BLOCKING);
-	LDLM_LOCK_RELEASE(lock);
-
-	return rc;
-}
-
-/**
- * Process a call to glimpse AST callback for a lock in ast_work list
- */
-static int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
-{
-	struct ldlm_cb_set_arg		*arg = opaq;
-	struct ldlm_glimpse_work	*gl_work;
-	struct ldlm_lock		*lock;
-	int				 rc = 0;
-
-	if (list_empty(arg->list))
-		return -ENOENT;
-
-	gl_work = list_first_entry(arg->list, struct ldlm_glimpse_work,
-			     gl_list);
-	list_del_init(&gl_work->gl_list);
-
-	lock = gl_work->gl_lock;
-
-	/* transfer the glimpse descriptor to ldlm_cb_set_arg */
-	arg->gl_desc = gl_work->gl_desc;
-
-	/* invoke the actual glimpse callback */
-	if (lock->l_glimpse_ast(lock, (void *)arg) == 0)
-		rc = 1;
-
-	LDLM_LOCK_RELEASE(lock);
-
-	if ((gl_work->gl_flags & LDLM_GL_WORK_NOFREE) == 0)
-		kfree(gl_work);
-
-	return rc;
-}
-
-/**
- * Process list of locks in need of ASTs being sent.
- *
- * Used on server to send multiple ASTs together instead of sending one by
- * one.
- */
-int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
-		      enum ldlm_desc_ast_t ast_type)
-{
-	struct ldlm_cb_set_arg *arg;
-	set_producer_func       work_ast_lock;
-	int		     rc;
-
-	if (list_empty(rpc_list))
-		return 0;
-
-	arg = kzalloc(sizeof(*arg), GFP_NOFS);
-	if (!arg)
-		return -ENOMEM;
-
-	atomic_set(&arg->restart, 0);
-	arg->list = rpc_list;
-
-	switch (ast_type) {
-	case LDLM_WORK_BL_AST:
-		arg->type = LDLM_BL_CALLBACK;
-		work_ast_lock = ldlm_work_bl_ast_lock;
-		break;
-	case LDLM_WORK_CP_AST:
-		arg->type = LDLM_CP_CALLBACK;
-		work_ast_lock = ldlm_work_cp_ast_lock;
-		break;
-	case LDLM_WORK_REVOKE_AST:
-		arg->type = LDLM_BL_CALLBACK;
-		work_ast_lock = ldlm_work_revoke_ast_lock;
-		break;
-	case LDLM_WORK_GL_AST:
-		arg->type = LDLM_GL_CALLBACK;
-		work_ast_lock = ldlm_work_gl_ast_lock;
-		break;
-	default:
-		LBUG();
-	}
-
-	/* We create a ptlrpc request set with flow control extension.
-	 * This request set will use the work_ast_lock function to produce new
-	 * requests and will send a new request each time one completes in order
-	 * to keep the number of requests in flight to ns_max_parallel_ast
-	 */
-	arg->set = ptlrpc_prep_fcset(ns->ns_max_parallel_ast ? : UINT_MAX,
-				     work_ast_lock, arg);
-	if (!arg->set) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	ptlrpc_set_wait(arg->set);
-	ptlrpc_set_destroy(arg->set);
-
-	rc = atomic_read(&arg->restart) ? -ERESTART : 0;
-	goto out;
-out:
-	kfree(arg);
-	return rc;
-}
-
-static bool is_bl_done(struct ldlm_lock *lock)
-{
-	bool bl_done = true;
-
-	if (!ldlm_is_bl_done(lock)) {
-		lock_res_and_lock(lock);
-		bl_done = ldlm_is_bl_done(lock);
-		unlock_res_and_lock(lock);
-	}
-
-	return bl_done;
-}
-
-/**
- * Helper function to call blocking AST for LDLM lock \a lock in a
- * "cancelling" mode.
- */
-void ldlm_cancel_callback(struct ldlm_lock *lock)
-{
-	check_res_locked(lock->l_resource);
-	if (!ldlm_is_cancel(lock)) {
-		ldlm_set_cancel(lock);
-		if (lock->l_blocking_ast) {
-			unlock_res_and_lock(lock);
-			lock->l_blocking_ast(lock, NULL, lock->l_ast_data,
-					     LDLM_CB_CANCELING);
-			lock_res_and_lock(lock);
-		} else {
-			LDLM_DEBUG(lock, "no blocking ast");
-		}
-		/* only canceller can set bl_done bit */
-		ldlm_set_bl_done(lock);
-		wake_up_all(&lock->l_waitq);
-	} else if (!ldlm_is_bl_done(lock)) {
-		/*
-		 * The lock is guaranteed to have been canceled once
-		 * returning from this function.
-		 */
-		unlock_res_and_lock(lock);
-		wait_event_idle(lock->l_waitq, is_bl_done(lock));
-		lock_res_and_lock(lock);
-	}
-}
-
-/**
- * Remove skiplist-enabled LDLM lock \a req from granted list
- */
-void ldlm_unlink_lock_skiplist(struct ldlm_lock *req)
-{
-	if (req->l_resource->lr_type != LDLM_PLAIN &&
-	    req->l_resource->lr_type != LDLM_IBITS)
-		return;
-
-	list_del_init(&req->l_sl_policy);
-	list_del_init(&req->l_sl_mode);
-}
-
-/**
- * Attempts to cancel LDLM lock \a lock that has no reader/writer references.
- */
-void ldlm_lock_cancel(struct ldlm_lock *lock)
-{
-	struct ldlm_resource *res;
-	struct ldlm_namespace *ns;
-
-	lock_res_and_lock(lock);
-
-	res = lock->l_resource;
-	ns  = ldlm_res_to_ns(res);
-
-	/* Please do not, no matter how tempting, remove this LBUG without
-	 * talking to me first. -phik
-	 */
-	if (lock->l_readers || lock->l_writers) {
-		LDLM_ERROR(lock, "lock still has references");
-		LBUG();
-	}
-
-	/* Releases cancel callback. */
-	ldlm_cancel_callback(lock);
-
-	ldlm_resource_unlink_lock(lock);
-	ldlm_lock_destroy_nolock(lock);
-
-	if (lock->l_granted_mode == lock->l_req_mode)
-		ldlm_pool_del(&ns->ns_pool, lock);
-
-	/* Make sure we will not be called again for same lock what is possible
-	 * if not to zero out lock->l_granted_mode
-	 */
-	lock->l_granted_mode = LCK_MINMODE;
-	unlock_res_and_lock(lock);
-}
-EXPORT_SYMBOL(ldlm_lock_cancel);
-
-/**
- * Set opaque data into the lock that only makes sense to upper layer.
- */
-int ldlm_lock_set_data(const struct lustre_handle *lockh, void *data)
-{
-	struct ldlm_lock *lock = ldlm_handle2lock(lockh);
-	int rc = -EINVAL;
-
-	if (lock) {
-		if (!lock->l_ast_data)
-			lock->l_ast_data = data;
-		if (lock->l_ast_data == data)
-			rc = 0;
-		LDLM_LOCK_PUT(lock);
-	}
-	return rc;
-}
-EXPORT_SYMBOL(ldlm_lock_set_data);
-
-struct export_cl_data {
-	struct obd_export	*ecl_exp;
-	int			ecl_loop;
-};
-
-/**
- * Print lock with lock handle \a lockh description into debug log.
- *
- * Used when printing all locks on a resource for debug purposes.
- */
-void ldlm_lock_dump_handle(int level, const struct lustre_handle *lockh)
-{
-	struct ldlm_lock *lock;
-
-	if (!((libcfs_debug | D_ERROR) & level))
-		return;
-
-	lock = ldlm_handle2lock(lockh);
-	if (!lock)
-		return;
-
-	LDLM_DEBUG_LIMIT(level, lock, "###");
-
-	LDLM_LOCK_PUT(lock);
-}
-EXPORT_SYMBOL(ldlm_lock_dump_handle);
-
-/**
- * Print lock information with custom message into debug log.
- * Helper function.
- */
-void _ldlm_lock_debug(struct ldlm_lock *lock,
-		      struct libcfs_debug_msg_data *msgdata,
-		      const char *fmt, ...)
-{
-	va_list args;
-	struct obd_export *exp = lock->l_export;
-	struct ldlm_resource *resource = lock->l_resource;
-	char *nid = "local";
-
-	va_start(args, fmt);
-
-	if (exp && exp->exp_connection) {
-		nid = libcfs_nid2str(exp->exp_connection->c_peer.nid);
-	} else if (exp && exp->exp_obd) {
-		struct obd_import *imp = exp->exp_obd->u.cli.cl_import;
-
-		nid = libcfs_nid2str(imp->imp_connection->c_peer.nid);
-	}
-
-	if (!resource) {
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: \?\? lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: \?\? rrc=\?\? type: \?\?\? flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
-				   lock,
-				   lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout,
-				   lock->l_lvb_type);
-		va_end(args);
-		return;
-	}
-
-	switch (resource->lr_type) {
-	case LDLM_EXTENT:
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s [%llu->%llu] (req %llu->%llu) flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
-				   ldlm_lock_to_ns_name(lock), lock,
-				   lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   PLDLMRES(resource),
-				   atomic_read(&resource->lr_refcount),
-				   ldlm_typename[resource->lr_type],
-				   lock->l_policy_data.l_extent.start,
-				   lock->l_policy_data.l_extent.end,
-				   lock->l_req_extent.start,
-				   lock->l_req_extent.end,
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout,
-				   lock->l_lvb_type);
-		break;
-
-	case LDLM_FLOCK:
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s pid: %d [%llu->%llu] flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu\n",
-				   ldlm_lock_to_ns_name(lock), lock,
-				   lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   PLDLMRES(resource),
-				   atomic_read(&resource->lr_refcount),
-				   ldlm_typename[resource->lr_type],
-				   lock->l_policy_data.l_flock.pid,
-				   lock->l_policy_data.l_flock.start,
-				   lock->l_policy_data.l_flock.end,
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout);
-		break;
-
-	case LDLM_IBITS:
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
-				   ldlm_lock_to_ns_name(lock),
-				   lock, lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   PLDLMRES(resource),
-				   lock->l_policy_data.l_inodebits.bits,
-				   atomic_read(&resource->lr_refcount),
-				   ldlm_typename[resource->lr_type],
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout,
-				   lock->l_lvb_type);
-		break;
-
-	default:
-		libcfs_debug_vmsg2(msgdata, fmt, args,
-				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
-				   ldlm_lock_to_ns_name(lock),
-				   lock, lock->l_handle.h_cookie,
-				   atomic_read(&lock->l_refc),
-				   lock->l_readers, lock->l_writers,
-				   ldlm_lockname[lock->l_granted_mode],
-				   ldlm_lockname[lock->l_req_mode],
-				   PLDLMRES(resource),
-				   atomic_read(&resource->lr_refcount),
-				   ldlm_typename[resource->lr_type],
-				   lock->l_flags, nid,
-				   lock->l_remote_handle.cookie,
-				   exp ? atomic_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout,
-				   lock->l_lvb_type);
-		break;
-	}
-	va_end(args);
-}
-EXPORT_SYMBOL(_ldlm_lock_debug);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
deleted file mode 100644
index f410ef6c02ef..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ /dev/null
@@ -1,1154 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2010, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/ldlm/ldlm_lockd.c
- *
- * Author: Peter Braam <braam@clusterfs.com>
- * Author: Phil Schwan <phil@clusterfs.com>
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-
-#include <linux/kthread.h>
-#include <linux/sched/mm.h>
-#include <lustre_dlm.h>
-#include <obd_class.h>
-#include <linux/list.h>
-#include "ldlm_internal.h"
-
-static int ldlm_num_threads;
-module_param(ldlm_num_threads, int, 0444);
-MODULE_PARM_DESC(ldlm_num_threads, "number of DLM service threads to start");
-
-static char *ldlm_cpts;
-module_param(ldlm_cpts, charp, 0444);
-MODULE_PARM_DESC(ldlm_cpts, "CPU partitions ldlm threads should run on");
-
-static struct mutex	ldlm_ref_mutex;
-static int ldlm_refcount;
-
-static struct kobject *ldlm_kobj;
-struct kset *ldlm_ns_kset;
-static struct kset *ldlm_svc_kset;
-
-struct ldlm_cb_async_args {
-	struct ldlm_cb_set_arg *ca_set_arg;
-	struct ldlm_lock       *ca_lock;
-};
-
-/* LDLM state */
-
-static struct ldlm_state *ldlm_state;
-
-#define ELT_STOPPED   0
-#define ELT_READY     1
-#define ELT_TERMINATE 2
-
-struct ldlm_bl_pool {
-	spinlock_t		blp_lock;
-
-	/*
-	 * blp_prio_list is used for callbacks that should be handled
-	 * as a priority. It is used for LDLM_FL_DISCARD_DATA requests.
-	 * see bug 13843
-	 */
-	struct list_head	      blp_prio_list;
-
-	/*
-	 * blp_list is used for all other callbacks which are likely
-	 * to take longer to process.
-	 */
-	struct list_head	      blp_list;
-
-	wait_queue_head_t	     blp_waitq;
-	struct completion	blp_comp;
-	atomic_t	    blp_num_threads;
-	atomic_t	    blp_busy_threads;
-	int		     blp_min_threads;
-	int		     blp_max_threads;
-};
-
-struct ldlm_bl_work_item {
-	struct list_head	      blwi_entry;
-	struct ldlm_namespace  *blwi_ns;
-	struct ldlm_lock_desc   blwi_ld;
-	struct ldlm_lock       *blwi_lock;
-	struct list_head	      blwi_head;
-	int		     blwi_count;
-	struct completion	blwi_comp;
-	enum ldlm_cancel_flags  blwi_flags;
-	int		     blwi_mem_pressure;
-};
-
-/**
- * Callback handler for receiving incoming blocking ASTs.
- *
- * This can only happen on client side.
- */
-void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
-			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock)
-{
-	int do_ast;
-
-	LDLM_DEBUG(lock, "client blocking AST callback handler");
-
-	lock_res_and_lock(lock);
-	ldlm_set_cbpending(lock);
-
-	if (ldlm_is_cancel_on_block(lock))
-		ldlm_set_cancel(lock);
-
-	do_ast = !lock->l_readers && !lock->l_writers;
-	unlock_res_and_lock(lock);
-
-	if (do_ast) {
-		CDEBUG(D_DLMTRACE,
-		       "Lock %p already unused, calling callback (%p)\n", lock,
-		       lock->l_blocking_ast);
-		if (lock->l_blocking_ast)
-			lock->l_blocking_ast(lock, ld, lock->l_ast_data,
-					     LDLM_CB_BLOCKING);
-	} else {
-		CDEBUG(D_DLMTRACE,
-		       "Lock %p is referenced, will be cancelled later\n",
-		       lock);
-	}
-
-	LDLM_DEBUG(lock, "client blocking callback handler END");
-	LDLM_LOCK_RELEASE(lock);
-}
-
-/**
- * Callback handler for receiving incoming completion ASTs.
- *
- * This only can happen on client side.
- */
-static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
-				    struct ldlm_namespace *ns,
-				    struct ldlm_request *dlm_req,
-				    struct ldlm_lock *lock)
-{
-	int lvb_len;
-	LIST_HEAD(ast_list);
-	int rc = 0;
-
-	LDLM_DEBUG(lock, "client completion callback handler START");
-
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE)) {
-		int to = HZ;
-
-		while (to > 0) {
-			set_current_state(TASK_INTERRUPTIBLE);
-			schedule_timeout(to);
-			if (lock->l_granted_mode == lock->l_req_mode ||
-			    ldlm_is_destroyed(lock))
-				break;
-		}
-	}
-
-	lvb_len = req_capsule_get_size(&req->rq_pill, &RMF_DLM_LVB, RCL_CLIENT);
-	if (lvb_len < 0) {
-		LDLM_ERROR(lock, "Fail to get lvb_len, rc = %d", lvb_len);
-		rc = lvb_len;
-		goto out;
-	} else if (lvb_len > 0) {
-		if (lock->l_lvb_len > 0) {
-			/* for extent lock, lvb contains ost_lvb{}. */
-			LASSERT(lock->l_lvb_data);
-
-			if (unlikely(lock->l_lvb_len < lvb_len)) {
-				LDLM_ERROR(lock,
-					   "Replied LVB is larger than expectation, expected = %d, replied = %d",
-					   lock->l_lvb_len, lvb_len);
-				rc = -EINVAL;
-				goto out;
-			}
-		} else if (ldlm_has_layout(lock)) { /* for layout lock, lvb has
-						     * variable length
-						     */
-			void *lvb_data;
-
-			lvb_data = kzalloc(lvb_len, GFP_NOFS);
-			if (!lvb_data) {
-				LDLM_ERROR(lock, "No memory: %d.\n", lvb_len);
-				rc = -ENOMEM;
-				goto out;
-			}
-
-			lock_res_and_lock(lock);
-			LASSERT(!lock->l_lvb_data);
-			lock->l_lvb_type = LVB_T_LAYOUT;
-			lock->l_lvb_data = lvb_data;
-			lock->l_lvb_len = lvb_len;
-			unlock_res_and_lock(lock);
-		}
-	}
-
-	lock_res_and_lock(lock);
-	if (ldlm_is_destroyed(lock) ||
-	    lock->l_granted_mode == lock->l_req_mode) {
-		/* bug 11300: the lock has already been granted */
-		unlock_res_and_lock(lock);
-		LDLM_DEBUG(lock, "Double grant race happened");
-		rc = 0;
-		goto out;
-	}
-
-	/* If we receive the completion AST before the actual enqueue returned,
-	 * then we might need to switch lock modes, resources, or extents.
-	 */
-	if (dlm_req->lock_desc.l_granted_mode != lock->l_req_mode) {
-		lock->l_req_mode = dlm_req->lock_desc.l_granted_mode;
-		LDLM_DEBUG(lock, "completion AST, new lock mode");
-	}
-
-	if (lock->l_resource->lr_type != LDLM_PLAIN) {
-		ldlm_convert_policy_to_local(req->rq_export,
-					  dlm_req->lock_desc.l_resource.lr_type,
-					  &dlm_req->lock_desc.l_policy_data,
-					  &lock->l_policy_data);
-		LDLM_DEBUG(lock, "completion AST, new policy data");
-	}
-
-	ldlm_resource_unlink_lock(lock);
-	if (memcmp(&dlm_req->lock_desc.l_resource.lr_name,
-		   &lock->l_resource->lr_name,
-		   sizeof(lock->l_resource->lr_name)) != 0) {
-		unlock_res_and_lock(lock);
-		rc = ldlm_lock_change_resource(ns, lock,
-				&dlm_req->lock_desc.l_resource.lr_name);
-		if (rc < 0) {
-			LDLM_ERROR(lock, "Failed to allocate resource");
-			goto out;
-		}
-		LDLM_DEBUG(lock, "completion AST, new resource");
-		CERROR("change resource!\n");
-		lock_res_and_lock(lock);
-	}
-
-	if (dlm_req->lock_flags & LDLM_FL_AST_SENT) {
-		/* BL_AST locks are not needed in LRU.
-		 * Let ldlm_cancel_lru() be fast.
-		 */
-		ldlm_lock_remove_from_lru(lock);
-		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_BL_AST;
-		LDLM_DEBUG(lock, "completion AST includes blocking AST");
-	}
-
-	if (lock->l_lvb_len > 0) {
-		rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_CLIENT,
-				   lock->l_lvb_data, lvb_len);
-		if (rc < 0) {
-			unlock_res_and_lock(lock);
-			goto out;
-		}
-	}
-
-	ldlm_grant_lock(lock, &ast_list);
-	unlock_res_and_lock(lock);
-
-	LDLM_DEBUG(lock, "callback handler finished, about to run_ast_work");
-
-	/* Let Enqueue to call osc_lock_upcall() and initialize l_ast_data */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 2);
-
-	ldlm_run_ast_work(ns, &ast_list, LDLM_WORK_CP_AST);
-
-	LDLM_DEBUG_NOLOCK("client completion callback handler END (lock %p)",
-			  lock);
-	goto out;
-
-out:
-	if (rc < 0) {
-		lock_res_and_lock(lock);
-		ldlm_set_failed(lock);
-		unlock_res_and_lock(lock);
-		wake_up(&lock->l_waitq);
-	}
-	LDLM_LOCK_RELEASE(lock);
-}
-
-/**
- * Callback handler for receiving incoming glimpse ASTs.
- *
- * This only can happen on client side.  After handling the glimpse AST
- * we also consider dropping the lock here if it is unused locally for a
- * long time.
- */
-static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
-				    struct ldlm_namespace *ns,
-				    struct ldlm_request *dlm_req,
-				    struct ldlm_lock *lock)
-{
-	int rc = -ENOSYS;
-
-	LDLM_DEBUG(lock, "client glimpse AST callback handler");
-
-	if (lock->l_glimpse_ast)
-		rc = lock->l_glimpse_ast(lock, req);
-
-	if (req->rq_repmsg) {
-		ptlrpc_reply(req);
-	} else {
-		req->rq_status = rc;
-		ptlrpc_error(req);
-	}
-
-	lock_res_and_lock(lock);
-	if (lock->l_granted_mode == LCK_PW &&
-	    !lock->l_readers && !lock->l_writers &&
-	    time_after(jiffies,
-		       lock->l_last_used + 10 * HZ)) {
-		unlock_res_and_lock(lock);
-		if (ldlm_bl_to_thread_lock(ns, NULL, lock))
-			ldlm_handle_bl_callback(ns, NULL, lock);
-
-		return;
-	}
-	unlock_res_and_lock(lock);
-	LDLM_LOCK_RELEASE(lock);
-}
-
-static int ldlm_callback_reply(struct ptlrpc_request *req, int rc)
-{
-	if (req->rq_no_reply)
-		return 0;
-
-	req->rq_status = rc;
-	if (!req->rq_packed_final) {
-		rc = lustre_pack_reply(req, 1, NULL, NULL);
-		if (rc)
-			return rc;
-	}
-	return ptlrpc_reply(req);
-}
-
-static int __ldlm_bl_to_thread(struct ldlm_bl_work_item *blwi,
-			       enum ldlm_cancel_flags cancel_flags)
-{
-	struct ldlm_bl_pool *blp = ldlm_state->ldlm_bl_pool;
-
-	spin_lock(&blp->blp_lock);
-	if (blwi->blwi_lock && ldlm_is_discard_data(blwi->blwi_lock)) {
-		/* add LDLM_FL_DISCARD_DATA requests to the priority list */
-		list_add_tail(&blwi->blwi_entry, &blp->blp_prio_list);
-	} else {
-		/* other blocking callbacks are added to the regular list */
-		list_add_tail(&blwi->blwi_entry, &blp->blp_list);
-	}
-	spin_unlock(&blp->blp_lock);
-
-	wake_up(&blp->blp_waitq);
-
-	/* can not check blwi->blwi_flags as blwi could be already freed in
-	 * LCF_ASYNC mode
-	 */
-	if (!(cancel_flags & LCF_ASYNC))
-		wait_for_completion(&blwi->blwi_comp);
-
-	return 0;
-}
-
-static inline void init_blwi(struct ldlm_bl_work_item *blwi,
-			     struct ldlm_namespace *ns,
-			     struct ldlm_lock_desc *ld,
-			     struct list_head *cancels, int count,
-			     struct ldlm_lock *lock,
-			     enum ldlm_cancel_flags cancel_flags)
-{
-	init_completion(&blwi->blwi_comp);
-	INIT_LIST_HEAD(&blwi->blwi_head);
-
-	if (current->flags & PF_MEMALLOC)
-		blwi->blwi_mem_pressure = 1;
-
-	blwi->blwi_ns = ns;
-	blwi->blwi_flags = cancel_flags;
-	if (ld)
-		blwi->blwi_ld = *ld;
-	if (count) {
-		list_add(&blwi->blwi_head, cancels);
-		list_del_init(cancels);
-		blwi->blwi_count = count;
-	} else {
-		blwi->blwi_lock = lock;
-	}
-}
-
-/**
- * Queues a list of locks \a cancels containing \a count locks
- * for later processing by a blocking thread.  If \a count is zero,
- * then the lock referenced as \a lock is queued instead.
- *
- * The blocking thread would then call ->l_blocking_ast callback in the lock.
- * If list addition fails an error is returned and caller is supposed to
- * call ->l_blocking_ast itself.
- */
-static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
-			     struct ldlm_lock_desc *ld,
-			     struct ldlm_lock *lock,
-			     struct list_head *cancels, int count,
-			     enum ldlm_cancel_flags cancel_flags)
-{
-	if (cancels && count == 0)
-		return 0;
-
-	if (cancel_flags & LCF_ASYNC) {
-		struct ldlm_bl_work_item *blwi;
-
-		blwi = kzalloc(sizeof(*blwi), GFP_NOFS);
-		if (!blwi)
-			return -ENOMEM;
-		init_blwi(blwi, ns, ld, cancels, count, lock, cancel_flags);
-
-		return __ldlm_bl_to_thread(blwi, cancel_flags);
-	} else {
-		/* if it is synchronous call do minimum mem alloc, as it could
-		 * be triggered from kernel shrinker
-		 */
-		struct ldlm_bl_work_item blwi;
-
-		memset(&blwi, 0, sizeof(blwi));
-		init_blwi(&blwi, ns, ld, cancels, count, lock, cancel_flags);
-		return __ldlm_bl_to_thread(&blwi, cancel_flags);
-	}
-}
-
-int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
-			   struct ldlm_lock *lock)
-{
-	return ldlm_bl_to_thread(ns, ld, lock, NULL, 0, LCF_ASYNC);
-}
-
-int ldlm_bl_to_thread_list(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
-			   struct list_head *cancels, int count,
-			   enum ldlm_cancel_flags cancel_flags)
-{
-	return ldlm_bl_to_thread(ns, ld, NULL, cancels, count, cancel_flags);
-}
-
-int ldlm_bl_thread_wakeup(void)
-{
-	wake_up(&ldlm_state->ldlm_bl_pool->blp_waitq);
-	return 0;
-}
-
-/* Setinfo coming from Server (eg MDT) to Client (eg MDC)! */
-static int ldlm_handle_setinfo(struct ptlrpc_request *req)
-{
-	struct obd_device *obd = req->rq_export->exp_obd;
-	char *key;
-	void *val;
-	int keylen, vallen;
-	int rc = -ENOSYS;
-
-	DEBUG_REQ(D_HSM, req, "%s: handle setinfo\n", obd->obd_name);
-
-	req_capsule_set(&req->rq_pill, &RQF_OBD_SET_INFO);
-
-	key = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_KEY);
-	if (!key) {
-		DEBUG_REQ(D_IOCTL, req, "no set_info key");
-		return -EFAULT;
-	}
-	keylen = req_capsule_get_size(&req->rq_pill, &RMF_SETINFO_KEY,
-				      RCL_CLIENT);
-	val = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_VAL);
-	if (!val) {
-		DEBUG_REQ(D_IOCTL, req, "no set_info val");
-		return -EFAULT;
-	}
-	vallen = req_capsule_get_size(&req->rq_pill, &RMF_SETINFO_VAL,
-				      RCL_CLIENT);
-
-	/* We are responsible for swabbing contents of val */
-
-	if (KEY_IS(KEY_HSM_COPYTOOL_SEND))
-		/* Pass it on to mdc (the "export" in this case) */
-		rc = obd_set_info_async(req->rq_svc_thread->t_env,
-					req->rq_export,
-					sizeof(KEY_HSM_COPYTOOL_SEND),
-					KEY_HSM_COPYTOOL_SEND,
-					vallen, val, NULL);
-	else
-		DEBUG_REQ(D_WARNING, req, "ignoring unknown key %s", key);
-
-	return rc;
-}
-
-static inline void ldlm_callback_errmsg(struct ptlrpc_request *req,
-					const char *msg, int rc,
-					const struct lustre_handle *handle)
-{
-	DEBUG_REQ((req->rq_no_reply || rc) ? D_WARNING : D_DLMTRACE, req,
-		  "%s: [nid %s] [rc %d] [lock %#llx]",
-		  msg, libcfs_id2str(req->rq_peer), rc,
-		  handle ? handle->cookie : 0);
-	if (req->rq_no_reply)
-		CWARN("No reply was sent, maybe cause bug 21636.\n");
-	else if (rc)
-		CWARN("Send reply failed, maybe cause bug 21636.\n");
-}
-
-/* TODO: handle requests in a similar way as MDT: see mdt_handle_common() */
-static int ldlm_callback_handler(struct ptlrpc_request *req)
-{
-	struct ldlm_namespace *ns;
-	struct ldlm_request *dlm_req;
-	struct ldlm_lock *lock;
-	int rc;
-
-	/* Requests arrive in sender's byte order.  The ptlrpc service
-	 * handler has already checked and, if necessary, byte-swapped the
-	 * incoming request message body, but I am responsible for the
-	 * message buffers.
-	 */
-
-	/* do nothing for sec context finalize */
-	if (lustre_msg_get_opc(req->rq_reqmsg) == SEC_CTX_FINI)
-		return 0;
-
-	req_capsule_init(&req->rq_pill, req, RCL_SERVER);
-
-	if (!req->rq_export) {
-		rc = ldlm_callback_reply(req, -ENOTCONN);
-		ldlm_callback_errmsg(req, "Operate on unconnected server",
-				     rc, NULL);
-		return 0;
-	}
-
-	LASSERT(req->rq_export->exp_obd);
-
-	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
-	case LDLM_BL_CALLBACK:
-		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_BL_CALLBACK_NET)) {
-			if (cfs_fail_err)
-				ldlm_callback_reply(req, -(int)cfs_fail_err);
-			return 0;
-		}
-		break;
-	case LDLM_CP_CALLBACK:
-		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CP_CALLBACK_NET))
-			return 0;
-		break;
-	case LDLM_GL_CALLBACK:
-		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_GL_CALLBACK_NET))
-			return 0;
-		break;
-	case LDLM_SET_INFO:
-		rc = ldlm_handle_setinfo(req);
-		ldlm_callback_reply(req, rc);
-		return 0;
-	default:
-		CERROR("unknown opcode %u\n",
-		       lustre_msg_get_opc(req->rq_reqmsg));
-		ldlm_callback_reply(req, -EPROTO);
-		return 0;
-	}
-
-	ns = req->rq_export->exp_obd->obd_namespace;
-	LASSERT(ns);
-
-	req_capsule_set(&req->rq_pill, &RQF_LDLM_CALLBACK);
-
-	dlm_req = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
-	if (!dlm_req) {
-		rc = ldlm_callback_reply(req, -EPROTO);
-		ldlm_callback_errmsg(req, "Operate without parameter", rc,
-				     NULL);
-		return 0;
-	}
-
-	/* Force a known safe race, send a cancel to the server for a lock
-	 * which the server has already started a blocking callback on.
-	 */
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE) &&
-	    lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK) {
-		rc = ldlm_cli_cancel(&dlm_req->lock_handle[0], 0);
-		if (rc < 0)
-			CERROR("ldlm_cli_cancel: %d\n", rc);
-	}
-
-	lock = ldlm_handle2lock_long(&dlm_req->lock_handle[0], 0);
-	if (!lock) {
-		CDEBUG(D_DLMTRACE,
-		       "callback on lock %#llx - lock disappeared\n",
-		       dlm_req->lock_handle[0].cookie);
-		rc = ldlm_callback_reply(req, -EINVAL);
-		ldlm_callback_errmsg(req, "Operate with invalid parameter", rc,
-				     &dlm_req->lock_handle[0]);
-		return 0;
-	}
-
-	if (ldlm_is_fail_loc(lock) &&
-	    lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK)
-		OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
-
-	/* Copy hints/flags (e.g. LDLM_FL_DISCARD_DATA) from AST. */
-	lock_res_and_lock(lock);
-	lock->l_flags |= ldlm_flags_from_wire(dlm_req->lock_flags &
-					      LDLM_FL_AST_MASK);
-	if (lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK) {
-		/* If somebody cancels lock and cache is already dropped,
-		 * or lock is failed before cp_ast received on client,
-		 * we can tell the server we have no lock. Otherwise, we
-		 * should send cancel after dropping the cache.
-		 */
-		if ((ldlm_is_canceling(lock) && ldlm_is_bl_done(lock)) ||
-		    ldlm_is_failed(lock)) {
-			LDLM_DEBUG(lock,
-				   "callback on lock %#llx - lock disappeared",
-				   dlm_req->lock_handle[0].cookie);
-			unlock_res_and_lock(lock);
-			LDLM_LOCK_RELEASE(lock);
-			rc = ldlm_callback_reply(req, -EINVAL);
-			ldlm_callback_errmsg(req, "Operate on stale lock", rc,
-					     &dlm_req->lock_handle[0]);
-			return 0;
-		}
-		/* BL_AST locks are not needed in LRU.
-		 * Let ldlm_cancel_lru() be fast.
-		 */
-		ldlm_lock_remove_from_lru(lock);
-		ldlm_set_bl_ast(lock);
-	}
-	unlock_res_and_lock(lock);
-
-	/* We want the ost thread to get this reply so that it can respond
-	 * to ost requests (write cache writeback) that might be triggered
-	 * in the callback.
-	 *
-	 * But we'd also like to be able to indicate in the reply that we're
-	 * cancelling right now, because it's unused, or have an intent result
-	 * in the reply, so we might have to push the responsibility for sending
-	 * the reply down into the AST handlers, alas.
-	 */
-
-	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
-	case LDLM_BL_CALLBACK:
-		CDEBUG(D_INODE, "blocking ast\n");
-		req_capsule_extend(&req->rq_pill, &RQF_LDLM_BL_CALLBACK);
-		if (!ldlm_is_cancel_on_block(lock)) {
-			rc = ldlm_callback_reply(req, 0);
-			if (req->rq_no_reply || rc)
-				ldlm_callback_errmsg(req, "Normal process", rc,
-						     &dlm_req->lock_handle[0]);
-		}
-		if (ldlm_bl_to_thread_lock(ns, &dlm_req->lock_desc, lock))
-			ldlm_handle_bl_callback(ns, &dlm_req->lock_desc, lock);
-		break;
-	case LDLM_CP_CALLBACK:
-		CDEBUG(D_INODE, "completion ast\n");
-		req_capsule_extend(&req->rq_pill, &RQF_LDLM_CP_CALLBACK);
-		ldlm_callback_reply(req, 0);
-		ldlm_handle_cp_callback(req, ns, dlm_req, lock);
-		break;
-	case LDLM_GL_CALLBACK:
-		CDEBUG(D_INODE, "glimpse ast\n");
-		req_capsule_extend(&req->rq_pill, &RQF_LDLM_GL_CALLBACK);
-		ldlm_handle_gl_callback(req, ns, dlm_req, lock);
-		break;
-	default:
-		LBUG();			 /* checked above */
-	}
-
-	return 0;
-}
-
-static int ldlm_bl_get_work(struct ldlm_bl_pool *blp,
-			    struct ldlm_bl_work_item **p_blwi,
-			    struct obd_export **p_exp)
-{
-	int num_th = atomic_read(&blp->blp_num_threads);
-	struct ldlm_bl_work_item *blwi = NULL;
-	static unsigned int num_bl;
-
-	spin_lock(&blp->blp_lock);
-	/* process a request from the blp_list at least every blp_num_threads */
-	if (!list_empty(&blp->blp_list) &&
-	    (list_empty(&blp->blp_prio_list) || num_bl == 0))
-		blwi = list_first_entry(&blp->blp_list,
-					struct ldlm_bl_work_item, blwi_entry);
-	else
-		if (!list_empty(&blp->blp_prio_list))
-			blwi = list_first_entry(&blp->blp_prio_list,
-						struct ldlm_bl_work_item,
-						blwi_entry);
-
-	if (blwi) {
-		if (++num_bl >= num_th)
-			num_bl = 0;
-		list_del(&blwi->blwi_entry);
-	}
-	spin_unlock(&blp->blp_lock);
-	*p_blwi = blwi;
-
-	return (*p_blwi || *p_exp) ? 1 : 0;
-}
-
-/* This only contains temporary data until the thread starts */
-struct ldlm_bl_thread_data {
-	struct ldlm_bl_pool	*bltd_blp;
-	struct completion	bltd_comp;
-	int			bltd_num;
-};
-
-static int ldlm_bl_thread_main(void *arg);
-
-static int ldlm_bl_thread_start(struct ldlm_bl_pool *blp, bool check_busy)
-{
-	struct ldlm_bl_thread_data bltd = { .bltd_blp = blp };
-	struct task_struct *task;
-
-	init_completion(&bltd.bltd_comp);
-
-	bltd.bltd_num = atomic_inc_return(&blp->blp_num_threads);
-	if (bltd.bltd_num >= blp->blp_max_threads) {
-		atomic_dec(&blp->blp_num_threads);
-		return 0;
-	}
-
-	LASSERTF(bltd.bltd_num > 0, "thread num:%d\n", bltd.bltd_num);
-	if (check_busy &&
-	    atomic_read(&blp->blp_busy_threads) < (bltd.bltd_num - 1)) {
-		atomic_dec(&blp->blp_num_threads);
-		return 0;
-	}
-
-	task = kthread_run(ldlm_bl_thread_main, &bltd, "ldlm_bl_%02d",
-			   bltd.bltd_num);
-	if (IS_ERR(task)) {
-		CERROR("cannot start LDLM thread ldlm_bl_%02d: rc %ld\n",
-		       bltd.bltd_num, PTR_ERR(task));
-		atomic_dec(&blp->blp_num_threads);
-		return PTR_ERR(task);
-	}
-	wait_for_completion(&bltd.bltd_comp);
-
-	return 0;
-}
-
-/* Not fatal if racy and have a few too many threads */
-static int ldlm_bl_thread_need_create(struct ldlm_bl_pool *blp,
-				      struct ldlm_bl_work_item *blwi)
-{
-	if (atomic_read(&blp->blp_num_threads) >= blp->blp_max_threads)
-		return 0;
-
-	if (atomic_read(&blp->blp_busy_threads) <
-	    atomic_read(&blp->blp_num_threads))
-		return 0;
-
-	if (blwi && (!blwi->blwi_ns || blwi->blwi_mem_pressure))
-		return 0;
-
-	return 1;
-}
-
-static int ldlm_bl_thread_blwi(struct ldlm_bl_pool *blp,
-			       struct ldlm_bl_work_item *blwi)
-{
-	unsigned int flags = 0;
-
-	if (!blwi->blwi_ns)
-		/* added by ldlm_cleanup() */
-		return LDLM_ITER_STOP;
-
-	if (blwi->blwi_mem_pressure)
-		flags = memalloc_noreclaim_save();
-
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL2, 4);
-
-	if (blwi->blwi_count) {
-		int count;
-
-		/*
-		 * The special case when we cancel locks in lru
-		 * asynchronously, we pass the list of locks here.
-		 * Thus locks are marked LDLM_FL_CANCELING, but NOT
-		 * canceled locally yet.
-		 */
-		count = ldlm_cli_cancel_list_local(&blwi->blwi_head,
-						   blwi->blwi_count,
-						   LCF_BL_AST);
-		ldlm_cli_cancel_list(&blwi->blwi_head, count, NULL,
-				     blwi->blwi_flags);
-	} else {
-		ldlm_handle_bl_callback(blwi->blwi_ns, &blwi->blwi_ld,
-					blwi->blwi_lock);
-	}
-	if (blwi->blwi_mem_pressure)
-		memalloc_noreclaim_restore(flags);
-
-	if (blwi->blwi_flags & LCF_ASYNC)
-		kfree(blwi);
-	else
-		complete(&blwi->blwi_comp);
-
-	return 0;
-}
-
-/**
- * Main blocking requests processing thread.
- *
- * Callers put locks into its queue by calling ldlm_bl_to_thread.
- * This thread in the end ends up doing actual call to ->l_blocking_ast
- * for queued locks.
- */
-static int ldlm_bl_thread_main(void *arg)
-{
-	struct ldlm_bl_pool *blp;
-	struct ldlm_bl_thread_data *bltd = arg;
-
-	blp = bltd->bltd_blp;
-
-	complete(&bltd->bltd_comp);
-	/* cannot use bltd after this, it is only on caller's stack */
-
-	while (1) {
-		struct ldlm_bl_work_item *blwi = NULL;
-		struct obd_export *exp = NULL;
-		int rc;
-
-		rc = ldlm_bl_get_work(blp, &blwi, &exp);
-		if (!rc)
-			wait_event_idle_exclusive(blp->blp_waitq,
-						  ldlm_bl_get_work(blp, &blwi,
-								   &exp));
-		atomic_inc(&blp->blp_busy_threads);
-
-		if (ldlm_bl_thread_need_create(blp, blwi))
-			/* discard the return value, we tried */
-			ldlm_bl_thread_start(blp, true);
-
-		if (blwi)
-			rc = ldlm_bl_thread_blwi(blp, blwi);
-
-		atomic_dec(&blp->blp_busy_threads);
-
-		if (rc == LDLM_ITER_STOP)
-			break;
-	}
-
-	atomic_dec(&blp->blp_num_threads);
-	complete(&blp->blp_comp);
-	return 0;
-}
-
-static int ldlm_setup(void);
-static int ldlm_cleanup(void);
-
-int ldlm_get_ref(void)
-{
-	int rc = 0;
-
-	rc = ptlrpc_inc_ref();
-	if (rc)
-		return rc;
-
-	mutex_lock(&ldlm_ref_mutex);
-	if (++ldlm_refcount == 1) {
-		rc = ldlm_setup();
-		if (rc)
-			ldlm_refcount--;
-	}
-	mutex_unlock(&ldlm_ref_mutex);
-
-	if (rc)
-		ptlrpc_dec_ref();
-
-	return rc;
-}
-
-void ldlm_put_ref(void)
-{
-	int rc = 0;
-	mutex_lock(&ldlm_ref_mutex);
-	if (ldlm_refcount == 1) {
-		rc = ldlm_cleanup();
-
-		if (rc)
-			CERROR("ldlm_cleanup failed: %d\n", rc);
-		else
-			ldlm_refcount--;
-	} else {
-		ldlm_refcount--;
-	}
-	mutex_unlock(&ldlm_ref_mutex);
-	if (!rc)
-		ptlrpc_dec_ref();
-}
-
-static ssize_t cancel_unused_locks_before_replay_show(struct kobject *kobj,
-						      struct attribute *attr,
-						      char *buf)
-{
-	return sprintf(buf, "%d\n", ldlm_cancel_unused_locks_before_replay);
-}
-
-static ssize_t cancel_unused_locks_before_replay_store(struct kobject *kobj,
-						       struct attribute *attr,
-						       const char *buffer,
-						       size_t count)
-{
-	int rc;
-	unsigned long val;
-
-	rc = kstrtoul(buffer, 10, &val);
-	if (rc)
-		return rc;
-
-	ldlm_cancel_unused_locks_before_replay = val;
-
-	return count;
-}
-LUSTRE_RW_ATTR(cancel_unused_locks_before_replay);
-
-/* These are for root of /sys/fs/lustre/ldlm */
-static struct attribute *ldlm_attrs[] = {
-	&lustre_attr_cancel_unused_locks_before_replay.attr,
-	NULL,
-};
-
-static const struct attribute_group ldlm_attr_group = {
-	.attrs = ldlm_attrs,
-};
-
-static int ldlm_setup(void)
-{
-	static struct ptlrpc_service_conf	conf;
-	struct ldlm_bl_pool			*blp = NULL;
-	int rc = 0;
-	int i;
-
-	if (ldlm_state)
-		return -EALREADY;
-
-	ldlm_state = kzalloc(sizeof(*ldlm_state), GFP_NOFS);
-	if (!ldlm_state)
-		return -ENOMEM;
-
-	ldlm_kobj = kobject_create_and_add("ldlm", lustre_kobj);
-	if (!ldlm_kobj) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	rc = sysfs_create_group(ldlm_kobj, &ldlm_attr_group);
-	if (rc)
-		goto out;
-
-	ldlm_ns_kset = kset_create_and_add("namespaces", NULL, ldlm_kobj);
-	if (!ldlm_ns_kset) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	ldlm_svc_kset = kset_create_and_add("services", NULL, ldlm_kobj);
-	if (!ldlm_svc_kset) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	ldlm_debugfs_setup();
-
-	memset(&conf, 0, sizeof(conf));
-	conf = (typeof(conf)) {
-		.psc_name		= "ldlm_cbd",
-		.psc_watchdog_factor	= 2,
-		.psc_buf		= {
-			.bc_nbufs		= LDLM_CLIENT_NBUFS,
-			.bc_buf_size		= LDLM_BUFSIZE,
-			.bc_req_max_size	= LDLM_MAXREQSIZE,
-			.bc_rep_max_size	= LDLM_MAXREPSIZE,
-			.bc_req_portal		= LDLM_CB_REQUEST_PORTAL,
-			.bc_rep_portal		= LDLM_CB_REPLY_PORTAL,
-		},
-		.psc_thr		= {
-			.tc_thr_name		= "ldlm_cb",
-			.tc_thr_factor		= LDLM_THR_FACTOR,
-			.tc_nthrs_init		= LDLM_NTHRS_INIT,
-			.tc_nthrs_base		= LDLM_NTHRS_BASE,
-			.tc_nthrs_max		= LDLM_NTHRS_MAX,
-			.tc_nthrs_user		= ldlm_num_threads,
-			.tc_cpu_affinity	= 1,
-			.tc_ctx_tags		= LCT_MD_THREAD | LCT_DT_THREAD,
-		},
-		.psc_cpt		= {
-			.cc_pattern		= ldlm_cpts,
-		},
-		.psc_ops		= {
-			.so_req_handler		= ldlm_callback_handler,
-		},
-	};
-	ldlm_state->ldlm_cb_service =
-			ptlrpc_register_service(&conf, ldlm_svc_kset,
-						ldlm_svc_debugfs_dir);
-	if (IS_ERR(ldlm_state->ldlm_cb_service)) {
-		CERROR("failed to start service\n");
-		rc = PTR_ERR(ldlm_state->ldlm_cb_service);
-		ldlm_state->ldlm_cb_service = NULL;
-		goto out;
-	}
-
-	blp = kzalloc(sizeof(*blp), GFP_NOFS);
-	if (!blp) {
-		rc = -ENOMEM;
-		goto out;
-	}
-	ldlm_state->ldlm_bl_pool = blp;
-
-	spin_lock_init(&blp->blp_lock);
-	INIT_LIST_HEAD(&blp->blp_list);
-	INIT_LIST_HEAD(&blp->blp_prio_list);
-	init_waitqueue_head(&blp->blp_waitq);
-	atomic_set(&blp->blp_num_threads, 0);
-	atomic_set(&blp->blp_busy_threads, 0);
-
-	if (ldlm_num_threads == 0) {
-		blp->blp_min_threads = LDLM_NTHRS_INIT;
-		blp->blp_max_threads = LDLM_NTHRS_MAX;
-	} else {
-		blp->blp_min_threads = min_t(int, LDLM_NTHRS_MAX,
-					     max_t(int, LDLM_NTHRS_INIT,
-						   ldlm_num_threads));
-
-		blp->blp_max_threads = blp->blp_min_threads;
-	}
-
-	for (i = 0; i < blp->blp_min_threads; i++) {
-		rc = ldlm_bl_thread_start(blp, false);
-		if (rc < 0)
-			goto out;
-	}
-
-	rc = ldlm_pools_init();
-	if (rc) {
-		CERROR("Failed to initialize LDLM pools: %d\n", rc);
-		goto out;
-	}
-	return 0;
-
- out:
-	ldlm_cleanup();
-	return rc;
-}
-
-static int ldlm_cleanup(void)
-{
-	if (!list_empty(ldlm_namespace_list(LDLM_NAMESPACE_SERVER)) ||
-	    !list_empty(ldlm_namespace_list(LDLM_NAMESPACE_CLIENT))) {
-		CERROR("ldlm still has namespaces; clean these up first.\n");
-		ldlm_dump_all_namespaces(LDLM_NAMESPACE_SERVER, D_DLMTRACE);
-		ldlm_dump_all_namespaces(LDLM_NAMESPACE_CLIENT, D_DLMTRACE);
-		return -EBUSY;
-	}
-
-	ldlm_pools_fini();
-
-	if (ldlm_state->ldlm_bl_pool) {
-		struct ldlm_bl_pool *blp = ldlm_state->ldlm_bl_pool;
-
-		while (atomic_read(&blp->blp_num_threads) > 0) {
-			struct ldlm_bl_work_item blwi = { .blwi_ns = NULL };
-
-			init_completion(&blp->blp_comp);
-
-			spin_lock(&blp->blp_lock);
-			list_add_tail(&blwi.blwi_entry, &blp->blp_list);
-			wake_up(&blp->blp_waitq);
-			spin_unlock(&blp->blp_lock);
-
-			wait_for_completion(&blp->blp_comp);
-		}
-
-		kfree(blp);
-	}
-
-	if (ldlm_state->ldlm_cb_service)
-		ptlrpc_unregister_service(ldlm_state->ldlm_cb_service);
-
-	if (ldlm_ns_kset)
-		kset_unregister(ldlm_ns_kset);
-	if (ldlm_svc_kset)
-		kset_unregister(ldlm_svc_kset);
-	if (ldlm_kobj) {
-		sysfs_remove_group(ldlm_kobj, &ldlm_attr_group);
-		kobject_put(ldlm_kobj);
-	}
-
-	ldlm_debugfs_cleanup();
-
-	kfree(ldlm_state);
-	ldlm_state = NULL;
-
-	return 0;
-}
-
-int ldlm_init(void)
-{
-	mutex_init(&ldlm_ref_mutex);
-	mutex_init(ldlm_namespace_lock(LDLM_NAMESPACE_SERVER));
-	mutex_init(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
-	ldlm_resource_slab = kmem_cache_create("ldlm_resources",
-					       sizeof(struct ldlm_resource), 0,
-					       SLAB_HWCACHE_ALIGN, NULL);
-	if (!ldlm_resource_slab)
-		return -ENOMEM;
-
-	ldlm_lock_slab = kmem_cache_create("ldlm_locks",
-					   sizeof(struct ldlm_lock), 0,
-					   SLAB_HWCACHE_ALIGN |
-					   SLAB_TYPESAFE_BY_RCU, NULL);
-	if (!ldlm_lock_slab) {
-		kmem_cache_destroy(ldlm_resource_slab);
-		return -ENOMEM;
-	}
-
-#if LUSTRE_TRACKS_LOCK_EXP_REFS
-	class_export_dump_hook = ldlm_dump_export_locks;
-#endif
-	return 0;
-}
-
-void ldlm_exit(void)
-{
-	if (ldlm_refcount)
-		CERROR("ldlm_refcount is %d in %s!\n", ldlm_refcount, __func__);
-	kmem_cache_destroy(ldlm_resource_slab);
-	/* ldlm_lock_put() use RCU to call ldlm_lock_free, so need call
-	 * synchronize_rcu() to wait a grace period elapsed, so that
-	 * ldlm_lock_free() get a chance to be called.
-	 */
-	synchronize_rcu();
-	kmem_cache_destroy(ldlm_lock_slab);
-}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
deleted file mode 100644
index 33b5a3f96fcb..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
+++ /dev/null
@@ -1,68 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/ldlm/ldlm_plain.c
- *
- * Author: Peter Braam <braam@clusterfs.com>
- * Author: Phil Schwan <phil@clusterfs.com>
- */
-
-/**
- * This file contains implementation of PLAIN lock type.
- *
- * PLAIN locks are the simplest form of LDLM locking, and are used when
- * there only needs to be a single lock on a resource. This avoids some
- * of the complexity of EXTENT and IBITS lock types, but doesn't allow
- * different "parts" of a resource to be locked concurrently.  Example
- * use cases for PLAIN locks include locking of MGS configuration logs
- * and (as of Lustre 2.4) quota records.
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-
-#include <lustre_dlm.h>
-#include <obd_support.h>
-#include <lustre_lib.h>
-
-#include "ldlm_internal.h"
-
-void ldlm_plain_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				     union ldlm_policy_data *lpolicy)
-{
-	/* No policy for plain locks */
-}
-
-void ldlm_plain_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     union ldlm_wire_policy_data *wpolicy)
-{
-	/* No policy for plain locks */
-}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
deleted file mode 100644
index 36d14ee4e5b1..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ /dev/null
@@ -1,1013 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2010, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/ldlm/ldlm_pool.c
- *
- * Author: Yury Umanets <umka@clusterfs.com>
- */
-
-/*
- * Idea of this code is rather simple. Each second, for each server namespace
- * we have SLV - server lock volume which is calculated on current number of
- * granted locks, grant speed for past period, etc - that is, locking load.
- * This SLV number may be thought as a flow definition for simplicity. It is
- * sent to clients with each occasion to let them know what is current load
- * situation on the server. By default, at the beginning, SLV on server is
- * set max value which is calculated as the following: allow to one client
- * have all locks of limit ->pl_limit for 10h.
- *
- * Next, on clients, number of cached locks is not limited artificially in any
- * way as it was before. Instead, client calculates CLV, that is, client lock
- * volume for each lock and compares it with last SLV from the server. CLV is
- * calculated as the number of locks in LRU * lock live time in seconds. If
- * CLV > SLV - lock is canceled.
- *
- * Client has LVF, that is, lock volume factor which regulates how much
- * sensitive client should be about last SLV from server. The higher LVF is the
- * more locks will be canceled on client. Default value for it is 1. Setting LVF
- * to 2 means that client will cancel locks 2 times faster.
- *
- * Locks on a client will be canceled more intensively in these cases:
- * (1) if SLV is smaller, that is, load is higher on the server;
- * (2) client has a lot of locks (the more locks are held by client, the bigger
- *     chances that some of them should be canceled);
- * (3) client has old locks (taken some time ago);
- *
- * Thus, according to flow paradigm that we use for better understanding SLV,
- * CLV is the volume of particle in flow described by SLV. According to this,
- * if flow is getting thinner, more and more particles become outside of it and
- * as particles are locks, they should be canceled.
- *
- * General idea of this belongs to Vitaly Fertman (vitaly at clusterfs.com).
- * Andreas Dilger (adilger at clusterfs.com) proposed few nice ideas like using
- * LVF and many cleanups. Flow definition to allow more easy understanding of
- * the logic belongs to Nikita Danilov (nikita at clusterfs.com) as well as many
- * cleanups and fixes. And design and implementation are done by Yury Umanets
- * (umka at clusterfs.com).
- *
- * Glossary for terms used:
- *
- * pl_limit - Number of allowed locks in pool. Applies to server and client
- * side (tunable);
- *
- * pl_granted - Number of granted locks (calculated);
- * pl_grant_rate - Number of granted locks for last T (calculated);
- * pl_cancel_rate - Number of canceled locks for last T (calculated);
- * pl_grant_speed - Grant speed (GR - CR) for last T (calculated);
- * pl_grant_plan - Planned number of granted locks for next T (calculated);
- * pl_server_lock_volume - Current server lock volume (calculated);
- *
- * As it may be seen from list above, we have few possible tunables which may
- * affect behavior much. They all may be modified via sysfs. However, they also
- * give a possibility for constructing few pre-defined behavior policies. If
- * none of predefines is suitable for a working pattern being used, new one may
- * be "constructed" via sysfs tunables.
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-
-#include <lustre_dlm.h>
-#include <cl_object.h>
-#include <obd_class.h>
-#include <obd_support.h>
-#include "ldlm_internal.h"
-
-/*
- * 50 ldlm locks for 1MB of RAM.
- */
-#define LDLM_POOL_HOST_L ((NUM_CACHEPAGES >> (20 - PAGE_SHIFT)) * 50)
-
-/*
- * Maximal possible grant step plan in %.
- */
-#define LDLM_POOL_MAX_GSP (30)
-
-/*
- * Minimal possible grant step plan in %.
- */
-#define LDLM_POOL_MIN_GSP (1)
-
-/*
- * This controls the speed of reaching LDLM_POOL_MAX_GSP
- * with increasing thread period.
- */
-#define LDLM_POOL_GSP_STEP_SHIFT (2)
-
-/*
- * LDLM_POOL_GSP% of all locks is default GP.
- */
-#define LDLM_POOL_GP(L)   (((L) * LDLM_POOL_MAX_GSP) / 100)
-
-/*
- * Max age for locks on clients.
- */
-#define LDLM_POOL_MAX_AGE (36000)
-
-/*
- * The granularity of SLV calculation.
- */
-#define LDLM_POOL_SLV_SHIFT (10)
-
-static inline __u64 dru(__u64 val, __u32 shift, int round_up)
-{
-	return (val + (round_up ? (1 << shift) - 1 : 0)) >> shift;
-}
-
-static inline __u64 ldlm_pool_slv_max(__u32 L)
-{
-	/*
-	 * Allow to have all locks for 1 client for 10 hrs.
-	 * Formula is the following: limit * 10h / 1 client.
-	 */
-	__u64 lim = (__u64)L *  LDLM_POOL_MAX_AGE / 1;
-	return lim;
-}
-
-static inline __u64 ldlm_pool_slv_min(__u32 L)
-{
-	return 1;
-}
-
-enum {
-	LDLM_POOL_FIRST_STAT = 0,
-	LDLM_POOL_GRANTED_STAT = LDLM_POOL_FIRST_STAT,
-	LDLM_POOL_GRANT_STAT,
-	LDLM_POOL_CANCEL_STAT,
-	LDLM_POOL_GRANT_RATE_STAT,
-	LDLM_POOL_CANCEL_RATE_STAT,
-	LDLM_POOL_GRANT_PLAN_STAT,
-	LDLM_POOL_SLV_STAT,
-	LDLM_POOL_SHRINK_REQTD_STAT,
-	LDLM_POOL_SHRINK_FREED_STAT,
-	LDLM_POOL_RECALC_STAT,
-	LDLM_POOL_TIMING_STAT,
-	LDLM_POOL_LAST_STAT
-};
-
-/**
- * Calculates suggested grant_step in % of available locks for passed
- * \a period. This is later used in grant_plan calculations.
- */
-static inline int ldlm_pool_t2gsp(unsigned int t)
-{
-	/*
-	 * This yields 1% grant step for anything below LDLM_POOL_GSP_STEP
-	 * and up to 30% for anything higher than LDLM_POOL_GSP_STEP.
-	 *
-	 * How this will affect execution is the following:
-	 *
-	 * - for thread period 1s we will have grant_step 1% which good from
-	 * pov of taking some load off from server and push it out to clients.
-	 * This is like that because 1% for grant_step means that server will
-	 * not allow clients to get lots of locks in short period of time and
-	 * keep all old locks in their caches. Clients will always have to
-	 * get some locks back if they want to take some new;
-	 *
-	 * - for thread period 10s (which is default) we will have 23% which
-	 * means that clients will have enough of room to take some new locks
-	 * without getting some back. All locks from this 23% which were not
-	 * taken by clients in current period will contribute in SLV growing.
-	 * SLV growing means more locks cached on clients until limit or grant
-	 * plan is reached.
-	 */
-	return LDLM_POOL_MAX_GSP -
-		((LDLM_POOL_MAX_GSP - LDLM_POOL_MIN_GSP) >>
-		 (t >> LDLM_POOL_GSP_STEP_SHIFT));
-}
-
-/**
- * Recalculates next stats on passed \a pl.
- *
- * \pre ->pl_lock is locked.
- */
-static void ldlm_pool_recalc_stats(struct ldlm_pool *pl)
-{
-	int grant_plan = pl->pl_grant_plan;
-	__u64 slv = pl->pl_server_lock_volume;
-	int granted = atomic_read(&pl->pl_granted);
-	int grant_rate = atomic_read(&pl->pl_grant_rate);
-	int cancel_rate = atomic_read(&pl->pl_cancel_rate);
-
-	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_SLV_STAT,
-			    slv);
-	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_GRANTED_STAT,
-			    granted);
-	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_GRANT_RATE_STAT,
-			    grant_rate);
-	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_GRANT_PLAN_STAT,
-			    grant_plan);
-	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_CANCEL_RATE_STAT,
-			    cancel_rate);
-}
-
-/**
- * Sets SLV and Limit from container_of(pl, struct ldlm_namespace,
- * ns_pool)->ns_obd tp passed \a pl.
- */
-static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
-{
-	struct obd_device *obd;
-
-	/*
-	 * Get new SLV and Limit from obd which is updated with coming
-	 * RPCs.
-	 */
-	obd = container_of(pl, struct ldlm_namespace,
-			   ns_pool)->ns_obd;
-	read_lock(&obd->obd_pool_lock);
-	pl->pl_server_lock_volume = obd->obd_pool_slv;
-	atomic_set(&pl->pl_limit, obd->obd_pool_limit);
-	read_unlock(&obd->obd_pool_lock);
-}
-
-/**
- * Recalculates client size pool \a pl according to current SLV and Limit.
- */
-static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
-{
-	time64_t recalc_interval_sec;
-	int ret;
-
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
-	if (recalc_interval_sec < pl->pl_recalc_period)
-		return 0;
-
-	spin_lock(&pl->pl_lock);
-	/*
-	 * Check if we need to recalc lists now.
-	 */
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
-	if (recalc_interval_sec < pl->pl_recalc_period) {
-		spin_unlock(&pl->pl_lock);
-		return 0;
-	}
-
-	/*
-	 * Make sure that pool knows last SLV and Limit from obd.
-	 */
-	ldlm_cli_pool_pop_slv(pl);
-
-	spin_unlock(&pl->pl_lock);
-
-	/*
-	 * Do not cancel locks in case lru resize is disabled for this ns.
-	 */
-	if (!ns_connect_lru_resize(container_of(pl, struct ldlm_namespace,
-						ns_pool))) {
-		ret = 0;
-		goto out;
-	}
-
-	/*
-	 * In the time of canceling locks on client we do not need to maintain
-	 * sharp timing, we only want to cancel locks asap according to new SLV.
-	 * It may be called when SLV has changed much, this is why we do not
-	 * take into account pl->pl_recalc_time here.
-	 */
-	ret = ldlm_cancel_lru(container_of(pl, struct ldlm_namespace, ns_pool),
-			      0, LCF_ASYNC, LDLM_LRU_FLAG_LRUR);
-
-out:
-	spin_lock(&pl->pl_lock);
-	/*
-	 * Time of LRU resizing might be longer than period,
-	 * so update after LRU resizing rather than before it.
-	 */
-	pl->pl_recalc_time = ktime_get_real_seconds();
-	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_TIMING_STAT,
-			    recalc_interval_sec);
-	spin_unlock(&pl->pl_lock);
-	return ret;
-}
-
-/**
- * This function is main entry point for memory pressure handling on client
- * side.  Main goal of this function is to cancel some number of locks on
- * passed \a pl according to \a nr and \a gfp_mask.
- */
-static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
-				int nr, gfp_t gfp_mask)
-{
-	struct ldlm_namespace *ns;
-	int unused;
-
-	ns = container_of(pl, struct ldlm_namespace, ns_pool);
-
-	/*
-	 * Do not cancel locks in case lru resize is disabled for this ns.
-	 */
-	if (!ns_connect_lru_resize(ns))
-		return 0;
-
-	/*
-	 * Make sure that pool knows last SLV and Limit from obd.
-	 */
-	ldlm_cli_pool_pop_slv(pl);
-
-	spin_lock(&ns->ns_lock);
-	unused = ns->ns_nr_unused;
-	spin_unlock(&ns->ns_lock);
-
-	if (nr == 0)
-		return (unused / 100) * sysctl_vfs_cache_pressure;
-	else
-		return ldlm_cancel_lru(ns, nr, LCF_ASYNC, LDLM_LRU_FLAG_SHRINK);
-}
-
-static const struct ldlm_pool_ops ldlm_cli_pool_ops = {
-	.po_recalc = ldlm_cli_pool_recalc,
-	.po_shrink = ldlm_cli_pool_shrink
-};
-
-/**
- * Pool recalc wrapper. Will call either client or server pool recalc callback
- * depending what pool \a pl is used.
- */
-static int ldlm_pool_recalc(struct ldlm_pool *pl)
-{
-	u32 recalc_interval_sec;
-	int count;
-
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
-	if (recalc_interval_sec > 0) {
-		spin_lock(&pl->pl_lock);
-		recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
-
-		if (recalc_interval_sec > 0) {
-			/*
-			 * Update pool statistics every 1s.
-			 */
-			ldlm_pool_recalc_stats(pl);
-
-			/*
-			 * Zero out all rates and speed for the last period.
-			 */
-			atomic_set(&pl->pl_grant_rate, 0);
-			atomic_set(&pl->pl_cancel_rate, 0);
-		}
-		spin_unlock(&pl->pl_lock);
-	}
-
-	if (pl->pl_ops->po_recalc) {
-		count = pl->pl_ops->po_recalc(pl);
-		lprocfs_counter_add(pl->pl_stats, LDLM_POOL_RECALC_STAT,
-				    count);
-	}
-
-	recalc_interval_sec = pl->pl_recalc_time - ktime_get_real_seconds() +
-			      pl->pl_recalc_period;
-	if (recalc_interval_sec <= 0) {
-		/* DEBUG: should be re-removed after LU-4536 is fixed */
-		CDEBUG(D_DLMTRACE,
-		       "%s: Negative interval(%ld), too short period(%ld)\n",
-		       pl->pl_name, (long)recalc_interval_sec,
-		       (long)pl->pl_recalc_period);
-
-		/* Prevent too frequent recalculation. */
-		recalc_interval_sec = 1;
-	}
-
-	return recalc_interval_sec;
-}
-
-/*
- * Pool shrink wrapper. Will call either client or server pool recalc callback
- * depending what pool pl is used. When nr == 0, just return the number of
- * freeable locks. Otherwise, return the number of canceled locks.
- */
-static int ldlm_pool_shrink(struct ldlm_pool *pl, int nr, gfp_t gfp_mask)
-{
-	int cancel = 0;
-
-	if (pl->pl_ops->po_shrink) {
-		cancel = pl->pl_ops->po_shrink(pl, nr, gfp_mask);
-		if (nr > 0) {
-			lprocfs_counter_add(pl->pl_stats,
-					    LDLM_POOL_SHRINK_REQTD_STAT,
-					    nr);
-			lprocfs_counter_add(pl->pl_stats,
-					    LDLM_POOL_SHRINK_FREED_STAT,
-					    cancel);
-			CDEBUG(D_DLMTRACE,
-			       "%s: request to shrink %d locks, shrunk %d\n",
-			       pl->pl_name, nr, cancel);
-		}
-	}
-	return cancel;
-}
-
-static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
-{
-	int granted, grant_rate, cancel_rate;
-	int grant_speed, lvf;
-	struct ldlm_pool *pl = m->private;
-	__u64 slv, clv;
-	__u32 limit;
-
-	spin_lock(&pl->pl_lock);
-	slv = pl->pl_server_lock_volume;
-	clv = pl->pl_client_lock_volume;
-	limit = atomic_read(&pl->pl_limit);
-	granted = atomic_read(&pl->pl_granted);
-	grant_rate = atomic_read(&pl->pl_grant_rate);
-	cancel_rate = atomic_read(&pl->pl_cancel_rate);
-	grant_speed = grant_rate - cancel_rate;
-	lvf = atomic_read(&pl->pl_lock_volume_factor);
-	spin_unlock(&pl->pl_lock);
-
-	seq_printf(m, "LDLM pool state (%s):\n"
-		      "  SLV: %llu\n"
-		      "  CLV: %llu\n"
-		      "  LVF: %d\n",
-		      pl->pl_name, slv, clv, lvf);
-
-	seq_printf(m, "  GR:  %d\n  CR:  %d\n  GS:  %d\n"
-		      "  G:   %d\n  L:   %d\n",
-		      grant_rate, cancel_rate, grant_speed,
-		      granted, limit);
-
-	return 0;
-}
-
-LPROC_SEQ_FOPS_RO(lprocfs_pool_state);
-
-static ssize_t grant_speed_show(struct kobject *kobj, struct attribute *attr,
-				char *buf)
-{
-	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool,
-					    pl_kobj);
-
-	int	       grant_speed;
-
-	spin_lock(&pl->pl_lock);
-	/* serialize with ldlm_pool_recalc */
-	grant_speed = atomic_read(&pl->pl_grant_rate) -
-			atomic_read(&pl->pl_cancel_rate);
-	spin_unlock(&pl->pl_lock);
-	return sprintf(buf, "%d\n", grant_speed);
-}
-LUSTRE_RO_ATTR(grant_speed);
-
-LDLM_POOL_SYSFS_READER_SHOW(grant_plan, int);
-LUSTRE_RO_ATTR(grant_plan);
-
-LDLM_POOL_SYSFS_READER_SHOW(recalc_period, int);
-LDLM_POOL_SYSFS_WRITER_STORE(recalc_period, int);
-LUSTRE_RW_ATTR(recalc_period);
-
-LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(server_lock_volume, u64);
-LUSTRE_RO_ATTR(server_lock_volume);
-
-LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(limit, atomic);
-LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(limit, atomic);
-LUSTRE_RW_ATTR(limit);
-
-LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(granted, atomic);
-LUSTRE_RO_ATTR(granted);
-
-LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(cancel_rate, atomic);
-LUSTRE_RO_ATTR(cancel_rate);
-
-LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(grant_rate, atomic);
-LUSTRE_RO_ATTR(grant_rate);
-
-LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(lock_volume_factor, atomic);
-LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(lock_volume_factor, atomic);
-LUSTRE_RW_ATTR(lock_volume_factor);
-
-#define LDLM_POOL_ADD_VAR(name, var, ops)			\
-	do {							\
-		snprintf(var_name, MAX_STRING_SIZE, #name);	\
-		pool_vars[0].data = var;			\
-		pool_vars[0].fops = ops;			\
-		ldebugfs_add_vars(pl->pl_debugfs_entry, pool_vars, NULL);\
-	} while (0)
-
-/* These are for pools in /sys/fs/lustre/ldlm/namespaces/.../pool */
-static struct attribute *ldlm_pl_attrs[] = {
-	&lustre_attr_grant_speed.attr,
-	&lustre_attr_grant_plan.attr,
-	&lustre_attr_recalc_period.attr,
-	&lustre_attr_server_lock_volume.attr,
-	&lustre_attr_limit.attr,
-	&lustre_attr_granted.attr,
-	&lustre_attr_cancel_rate.attr,
-	&lustre_attr_grant_rate.attr,
-	&lustre_attr_lock_volume_factor.attr,
-	NULL,
-};
-
-static void ldlm_pl_release(struct kobject *kobj)
-{
-	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool,
-					    pl_kobj);
-	complete(&pl->pl_kobj_unregister);
-}
-
-static struct kobj_type ldlm_pl_ktype = {
-	.default_attrs	= ldlm_pl_attrs,
-	.sysfs_ops	= &lustre_sysfs_ops,
-	.release	= ldlm_pl_release,
-};
-
-static int ldlm_pool_sysfs_init(struct ldlm_pool *pl)
-{
-	struct ldlm_namespace *ns = container_of(pl, struct ldlm_namespace,
-						 ns_pool);
-	int err;
-
-	init_completion(&pl->pl_kobj_unregister);
-	err = kobject_init_and_add(&pl->pl_kobj, &ldlm_pl_ktype, &ns->ns_kobj,
-				   "pool");
-
-	return err;
-}
-
-static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
-{
-	struct ldlm_namespace *ns = container_of(pl, struct ldlm_namespace,
-						 ns_pool);
-	struct dentry *debugfs_ns_parent;
-	struct lprocfs_vars pool_vars[2];
-	char *var_name = NULL;
-	int rc = 0;
-
-	var_name = kzalloc(MAX_STRING_SIZE + 1, GFP_NOFS);
-	if (!var_name)
-		return -ENOMEM;
-
-	debugfs_ns_parent = ns->ns_debugfs_entry;
-	if (IS_ERR_OR_NULL(debugfs_ns_parent)) {
-		CERROR("%s: debugfs entry is not initialized\n",
-		       ldlm_ns_name(ns));
-		rc = -EINVAL;
-		goto out_free_name;
-	}
-	pl->pl_debugfs_entry = debugfs_create_dir("pool", debugfs_ns_parent);
-
-	var_name[MAX_STRING_SIZE] = '\0';
-	memset(pool_vars, 0, sizeof(pool_vars));
-	pool_vars[0].name = var_name;
-
-	LDLM_POOL_ADD_VAR(state, pl, &lprocfs_pool_state_fops);
-
-	pl->pl_stats = lprocfs_alloc_stats(LDLM_POOL_LAST_STAT -
-					   LDLM_POOL_FIRST_STAT, 0);
-	if (!pl->pl_stats) {
-		rc = -ENOMEM;
-		goto out_free_name;
-	}
-
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANTED_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "granted", "locks");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "grant", "locks");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_CANCEL_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "cancel", "locks");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_RATE_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "grant_rate", "locks/s");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_CANCEL_RATE_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "cancel_rate", "locks/s");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_PLAN_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "grant_plan", "locks/s");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SLV_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "slv", "slv");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SHRINK_REQTD_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "shrink_request", "locks");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SHRINK_FREED_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "shrink_freed", "locks");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_RECALC_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "recalc_freed", "locks");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_TIMING_STAT,
-			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
-			     "recalc_timing", "sec");
-	debugfs_create_file("stats", 0644, pl->pl_debugfs_entry, pl->pl_stats,
-			    &lprocfs_stats_seq_fops);
-
-out_free_name:
-	kfree(var_name);
-	return rc;
-}
-
-static void ldlm_pool_sysfs_fini(struct ldlm_pool *pl)
-{
-	kobject_put(&pl->pl_kobj);
-	wait_for_completion(&pl->pl_kobj_unregister);
-}
-
-static void ldlm_pool_debugfs_fini(struct ldlm_pool *pl)
-{
-	if (pl->pl_stats) {
-		lprocfs_free_stats(&pl->pl_stats);
-		pl->pl_stats = NULL;
-	}
-	debugfs_remove_recursive(pl->pl_debugfs_entry);
-}
-
-int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
-		   int idx, enum ldlm_side client)
-{
-	int rc;
-
-	spin_lock_init(&pl->pl_lock);
-	atomic_set(&pl->pl_granted, 0);
-	pl->pl_recalc_time = ktime_get_real_seconds();
-	atomic_set(&pl->pl_lock_volume_factor, 1);
-
-	atomic_set(&pl->pl_grant_rate, 0);
-	atomic_set(&pl->pl_cancel_rate, 0);
-	pl->pl_grant_plan = LDLM_POOL_GP(LDLM_POOL_HOST_L);
-
-	snprintf(pl->pl_name, sizeof(pl->pl_name), "ldlm-pool-%s-%d",
-		 ldlm_ns_name(ns), idx);
-
-	atomic_set(&pl->pl_limit, 1);
-	pl->pl_server_lock_volume = 0;
-	pl->pl_ops = &ldlm_cli_pool_ops;
-	pl->pl_recalc_period = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
-	pl->pl_client_lock_volume = 0;
-	rc = ldlm_pool_debugfs_init(pl);
-	if (rc)
-		return rc;
-
-	rc = ldlm_pool_sysfs_init(pl);
-	if (rc)
-		return rc;
-
-	CDEBUG(D_DLMTRACE, "Lock pool %s is initialized\n", pl->pl_name);
-
-	return rc;
-}
-
-void ldlm_pool_fini(struct ldlm_pool *pl)
-{
-	ldlm_pool_sysfs_fini(pl);
-	ldlm_pool_debugfs_fini(pl);
-
-	/*
-	 * Pool should not be used after this point. We can't free it here as
-	 * it lives in struct ldlm_namespace, but still interested in catching
-	 * any abnormal using cases.
-	 */
-	POISON(pl, 0x5a, sizeof(*pl));
-}
-
-/**
- * Add new taken ldlm lock \a lock into pool \a pl accounting.
- */
-void ldlm_pool_add(struct ldlm_pool *pl, struct ldlm_lock *lock)
-{
-	/*
-	 * FLOCK locks are special in a sense that they are almost never
-	 * cancelled, instead special kind of lock is used to drop them.
-	 * also there is no LRU for flock locks, so no point in tracking
-	 * them anyway.
-	 */
-	if (lock->l_resource->lr_type == LDLM_FLOCK)
-		return;
-
-	atomic_inc(&pl->pl_granted);
-	atomic_inc(&pl->pl_grant_rate);
-	lprocfs_counter_incr(pl->pl_stats, LDLM_POOL_GRANT_STAT);
-	/*
-	 * Do not do pool recalc for client side as all locks which
-	 * potentially may be canceled has already been packed into
-	 * enqueue/cancel rpc. Also we do not want to run out of stack
-	 * with too long call paths.
-	 */
-}
-
-/**
- * Remove ldlm lock \a lock from pool \a pl accounting.
- */
-void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock)
-{
-	/*
-	 * Filter out FLOCK locks. Read above comment in ldlm_pool_add().
-	 */
-	if (lock->l_resource->lr_type == LDLM_FLOCK)
-		return;
-
-	LASSERT(atomic_read(&pl->pl_granted) > 0);
-	atomic_dec(&pl->pl_granted);
-	atomic_inc(&pl->pl_cancel_rate);
-
-	lprocfs_counter_incr(pl->pl_stats, LDLM_POOL_CANCEL_STAT);
-}
-
-/**
- * Returns current \a pl SLV.
- *
- * \pre ->pl_lock is not locked.
- */
-__u64 ldlm_pool_get_slv(struct ldlm_pool *pl)
-{
-	__u64 slv;
-
-	spin_lock(&pl->pl_lock);
-	slv = pl->pl_server_lock_volume;
-	spin_unlock(&pl->pl_lock);
-	return slv;
-}
-
-/**
- * Sets passed \a clv to \a pl.
- *
- * \pre ->pl_lock is not locked.
- */
-void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv)
-{
-	spin_lock(&pl->pl_lock);
-	pl->pl_client_lock_volume = clv;
-	spin_unlock(&pl->pl_lock);
-}
-
-/**
- * Returns current LVF from \a pl.
- */
-__u32 ldlm_pool_get_lvf(struct ldlm_pool *pl)
-{
-	return atomic_read(&pl->pl_lock_volume_factor);
-}
-
-static int ldlm_pool_granted(struct ldlm_pool *pl)
-{
-	return atomic_read(&pl->pl_granted);
-}
-
-/*
- * count locks from all namespaces (if possible). Returns number of
- * cached locks.
- */
-static unsigned long ldlm_pools_count(enum ldlm_side client, gfp_t gfp_mask)
-{
-	unsigned long total = 0;
-	int nr_ns;
-	struct ldlm_namespace *ns;
-	struct ldlm_namespace *ns_old = NULL; /* loop detection */
-
-	if (client == LDLM_NAMESPACE_CLIENT && !(gfp_mask & __GFP_FS))
-		return 0;
-
-	CDEBUG(D_DLMTRACE, "Request to count %s locks from all pools\n",
-	       client == LDLM_NAMESPACE_CLIENT ? "client" : "server");
-
-	/*
-	 * Find out how many resources we may release.
-	 */
-	for (nr_ns = ldlm_namespace_nr_read(client);
-	     nr_ns > 0; nr_ns--) {
-		mutex_lock(ldlm_namespace_lock(client));
-		if (list_empty(ldlm_namespace_list(client))) {
-			mutex_unlock(ldlm_namespace_lock(client));
-			return 0;
-		}
-		ns = ldlm_namespace_first_locked(client);
-
-		if (ns == ns_old) {
-			mutex_unlock(ldlm_namespace_lock(client));
-			break;
-		}
-
-		if (ldlm_ns_empty(ns)) {
-			ldlm_namespace_move_to_inactive_locked(ns, client);
-			mutex_unlock(ldlm_namespace_lock(client));
-			continue;
-		}
-
-		if (!ns_old)
-			ns_old = ns;
-
-		ldlm_namespace_get(ns);
-		ldlm_namespace_move_to_active_locked(ns, client);
-		mutex_unlock(ldlm_namespace_lock(client));
-		total += ldlm_pool_shrink(&ns->ns_pool, 0, gfp_mask);
-		ldlm_namespace_put(ns);
-	}
-
-	return total;
-}
-
-static unsigned long ldlm_pools_scan(enum ldlm_side client, int nr,
-				     gfp_t gfp_mask)
-{
-	unsigned long freed = 0;
-	int tmp, nr_ns;
-	struct ldlm_namespace *ns;
-
-	if (client == LDLM_NAMESPACE_CLIENT && !(gfp_mask & __GFP_FS))
-		return -1;
-
-	/*
-	 * Shrink at least ldlm_namespace_nr_read(client) namespaces.
-	 */
-	for (tmp = nr_ns = ldlm_namespace_nr_read(client);
-	     tmp > 0; tmp--) {
-		int cancel, nr_locks;
-
-		/*
-		 * Do not call shrink under ldlm_namespace_lock(client)
-		 */
-		mutex_lock(ldlm_namespace_lock(client));
-		if (list_empty(ldlm_namespace_list(client))) {
-			mutex_unlock(ldlm_namespace_lock(client));
-			break;
-		}
-		ns = ldlm_namespace_first_locked(client);
-		ldlm_namespace_get(ns);
-		ldlm_namespace_move_to_active_locked(ns, client);
-		mutex_unlock(ldlm_namespace_lock(client));
-
-		nr_locks = ldlm_pool_granted(&ns->ns_pool);
-		/*
-		 * We use to shrink propotionally but with new shrinker API,
-		 * we lost the total number of freeable locks.
-		 */
-		cancel = 1 + min_t(int, nr_locks, nr / nr_ns);
-		freed += ldlm_pool_shrink(&ns->ns_pool, cancel, gfp_mask);
-		ldlm_namespace_put(ns);
-	}
-	/*
-	 * we only decrease the SLV in server pools shrinker, return
-	 * SHRINK_STOP to kernel to avoid needless loop. LU-1128
-	 */
-	return freed;
-}
-
-static unsigned long ldlm_pools_cli_count(struct shrinker *s,
-					  struct shrink_control *sc)
-{
-	return ldlm_pools_count(LDLM_NAMESPACE_CLIENT, sc->gfp_mask);
-}
-
-static unsigned long ldlm_pools_cli_scan(struct shrinker *s,
-					 struct shrink_control *sc)
-{
-	return ldlm_pools_scan(LDLM_NAMESPACE_CLIENT, sc->nr_to_scan,
-			       sc->gfp_mask);
-}
-
-static void ldlm_pools_recalc(struct work_struct *ws);
-static DECLARE_DELAYED_WORK(ldlm_recalc_pools, ldlm_pools_recalc);
-
-static void ldlm_pools_recalc(struct work_struct *ws)
-{
-	enum ldlm_side client = LDLM_NAMESPACE_CLIENT;
-	struct ldlm_namespace *ns;
-	struct ldlm_namespace *ns_old = NULL;
-	/* seconds of sleep if no active namespaces */
-	int time = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
-	int nr;
-
-	/*
-	 * Recalc at least ldlm_namespace_nr_read(client) namespaces.
-	 */
-	for (nr = ldlm_namespace_nr_read(client); nr > 0; nr--) {
-		int     skip;
-		/*
-		 * Lock the list, get first @ns in the list, getref, move it
-		 * to the tail, unlock and call pool recalc. This way we avoid
-		 * calling recalc under @ns lock what is really good as we get
-		 * rid of potential deadlock on client nodes when canceling
-		 * locks synchronously.
-		 */
-		mutex_lock(ldlm_namespace_lock(client));
-		if (list_empty(ldlm_namespace_list(client))) {
-			mutex_unlock(ldlm_namespace_lock(client));
-			break;
-		}
-		ns = ldlm_namespace_first_locked(client);
-
-		if (ns_old == ns) { /* Full pass complete */
-			mutex_unlock(ldlm_namespace_lock(client));
-			break;
-		}
-
-		/* We got an empty namespace, need to move it back to inactive
-		 * list.
-		 * The race with parallel resource creation is fine:
-		 * - If they do namespace_get before our check, we fail the
-		 *   check and they move this item to the end of the list anyway
-		 * - If we do the check and then they do namespace_get, then
-		 *   we move the namespace to inactive and they will move
-		 *   it back to active (synchronised by the lock, so no clash
-		 *   there).
-		 */
-		if (ldlm_ns_empty(ns)) {
-			ldlm_namespace_move_to_inactive_locked(ns, client);
-			mutex_unlock(ldlm_namespace_lock(client));
-			continue;
-		}
-
-		if (!ns_old)
-			ns_old = ns;
-
-		spin_lock(&ns->ns_lock);
-		/*
-		 * skip ns which is being freed, and we don't want to increase
-		 * its refcount again, not even temporarily. bz21519 & LU-499.
-		 */
-		if (ns->ns_stopping) {
-			skip = 1;
-		} else {
-			skip = 0;
-			ldlm_namespace_get(ns);
-		}
-		spin_unlock(&ns->ns_lock);
-
-		ldlm_namespace_move_to_active_locked(ns, client);
-		mutex_unlock(ldlm_namespace_lock(client));
-
-		/*
-		 * After setup is done - recalc the pool.
-		 */
-		if (!skip) {
-			int ttime = ldlm_pool_recalc(&ns->ns_pool);
-
-			if (ttime < time)
-				time = ttime;
-
-			ldlm_namespace_put(ns);
-		}
-	}
-
-	/* Wake up the blocking threads from time to time. */
-	ldlm_bl_thread_wakeup();
-
-	schedule_delayed_work(&ldlm_recalc_pools, time * HZ);
-}
-
-static int ldlm_pools_thread_start(void)
-{
-	schedule_delayed_work(&ldlm_recalc_pools, 0);
-
-	return 0;
-}
-
-static void ldlm_pools_thread_stop(void)
-{
-	cancel_delayed_work_sync(&ldlm_recalc_pools);
-}
-
-static struct shrinker ldlm_pools_cli_shrinker = {
-	.count_objects	= ldlm_pools_cli_count,
-	.scan_objects	= ldlm_pools_cli_scan,
-	.seeks		= DEFAULT_SEEKS,
-};
-
-int ldlm_pools_init(void)
-{
-	int rc;
-
-	rc = ldlm_pools_thread_start();
-	if (!rc)
-		rc = register_shrinker(&ldlm_pools_cli_shrinker);
-
-	return rc;
-}
-
-void ldlm_pools_fini(void)
-{
-	unregister_shrinker(&ldlm_pools_cli_shrinker);
-
-	ldlm_pools_thread_stop();
-}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
deleted file mode 100644
index cdc52eed6d85..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ /dev/null
@@ -1,2033 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2010, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-/**
- * This file contains Asynchronous System Trap (AST) handlers and related
- * LDLM request-processing routines.
- *
- * An AST is a callback issued on a lock when its state is changed. There are
- * several different types of ASTs (callbacks) registered for each lock:
- *
- * - completion AST: when a lock is enqueued by some process, but cannot be
- *   granted immediately due to other conflicting locks on the same resource,
- *   the completion AST is sent to notify the caller when the lock is
- *   eventually granted
- *
- * - blocking AST: when a lock is granted to some process, if another process
- *   enqueues a conflicting (blocking) lock on a resource, a blocking AST is
- *   sent to notify the holder(s) of the lock(s) of the conflicting lock
- *   request. The lock holder(s) must release their lock(s) on that resource in
- *   a timely manner or be evicted by the server.
- *
- * - glimpse AST: this is used when a process wants information about a lock
- *   (i.e. the lock value block (LVB)) but does not necessarily require holding
- *   the lock. If the resource is locked, the lock holder(s) are sent glimpse
- *   ASTs and the LVB is returned to the caller, and lock holder(s) may CANCEL
- *   their lock(s) if they are idle. If the resource is not locked, the server
- *   may grant the lock.
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-
-#include <lustre_errno.h>
-#include <lustre_dlm.h>
-#include <obd_class.h>
-#include <obd.h>
-#include <linux/libcfs/libcfs_hash.h>
-
-#include "ldlm_internal.h"
-
-unsigned int ldlm_enqueue_min = OBD_TIMEOUT_DEFAULT;
-module_param(ldlm_enqueue_min, uint, 0644);
-MODULE_PARM_DESC(ldlm_enqueue_min, "lock enqueue timeout minimum");
-
-/* in client side, whether the cached locks will be canceled before replay */
-unsigned int ldlm_cancel_unused_locks_before_replay = 1;
-
-struct ldlm_async_args {
-	struct lustre_handle lock_handle;
-};
-
-/**
- * ldlm_request_bufsize
- *
- * @count:	number of ldlm handles
- * @type:	ldlm opcode
- *
- * If opcode=LDLM_ENQUEUE, 1 slot is already occupied,
- * LDLM_LOCKREQ_HANDLE -1 slots are available.
- * Otherwise, LDLM_LOCKREQ_HANDLE slots are available.
- *
- * Return:	size of the request buffer
- */
-static int ldlm_request_bufsize(int count, int type)
-{
-	int avail = LDLM_LOCKREQ_HANDLES;
-
-	if (type == LDLM_ENQUEUE)
-		avail -= LDLM_ENQUEUE_CANCEL_OFF;
-
-	if (count > avail)
-		avail = (count - avail) * sizeof(struct lustre_handle);
-	else
-		avail = 0;
-
-	return sizeof(struct ldlm_request) + avail;
-}
-
-static void ldlm_expired_completion_wait(struct ldlm_lock *lock, __u32 conn_cnt)
-{
-	struct obd_import *imp;
-	struct obd_device *obd;
-
-	if (!lock->l_conn_export) {
-		static unsigned long next_dump, last_dump;
-
-		LDLM_ERROR(lock,
-			   "lock timed out (enqueued at %lld, %llds ago); not entering recovery in server code, just going back to sleep",
-			   (s64)lock->l_last_activity,
-			   (s64)(ktime_get_real_seconds() -
-				 lock->l_last_activity));
-		if (time_after(jiffies, next_dump)) {
-			last_dump = next_dump;
-			next_dump = jiffies + 300 * HZ;
-			ldlm_namespace_dump(D_DLMTRACE,
-					    ldlm_lock_to_ns(lock));
-			if (last_dump == 0)
-				libcfs_debug_dumplog();
-		}
-		return;
-	}
-
-	obd = lock->l_conn_export->exp_obd;
-	imp = obd->u.cli.cl_import;
-	ptlrpc_fail_import(imp, conn_cnt);
-	LDLM_ERROR(lock,
-		   "lock timed out (enqueued at %lld, %llds ago), entering recovery for %s@%s",
-		   (s64)lock->l_last_activity,
-		   (s64)(ktime_get_real_seconds() - lock->l_last_activity),
-		   obd2cli_tgt(obd), imp->imp_connection->c_remote_uuid.uuid);
-}
-
-/**
- * Calculate the Completion timeout (covering enqueue, BL AST, data flush,
- * lock cancel, and their replies). Used for lock completion timeout on the
- * client side.
- *
- * \param[in] lock	lock which is waiting the completion callback
- *
- * \retval		timeout in seconds to wait for the server reply
- */
-/* We use the same basis for both server side and client side functions
- * from a single node.
- */
-static unsigned int ldlm_cp_timeout(struct ldlm_lock *lock)
-{
-	unsigned int timeout;
-
-	if (AT_OFF)
-		return obd_timeout;
-
-	/*
-	 * Wait a long time for enqueue - server may have to callback a
-	 * lock from another client.  Server will evict the other client if it
-	 * doesn't respond reasonably, and then give us the lock.
-	 */
-	timeout = at_get(ldlm_lock_to_ns_at(lock));
-	return max(3 * timeout, ldlm_enqueue_min);
-}
-
-/**
- * Helper function for ldlm_completion_ast(), updating timings when lock is
- * actually granted.
- */
-static int ldlm_completion_tail(struct ldlm_lock *lock, void *data)
-{
-	long delay;
-	int result = 0;
-
-	if (ldlm_is_destroyed(lock) || ldlm_is_failed(lock)) {
-		LDLM_DEBUG(lock, "client-side enqueue: destroyed");
-		result = -EIO;
-	} else if (!data) {
-		LDLM_DEBUG(lock, "client-side enqueue: granted");
-	} else {
-		/* Take into AT only CP RPC, not immediately granted locks */
-		delay = ktime_get_real_seconds() - lock->l_last_activity;
-		LDLM_DEBUG(lock, "client-side enqueue: granted after %lds",
-			   delay);
-
-		/* Update our time estimate */
-		at_measured(ldlm_lock_to_ns_at(lock), delay);
-	}
-	return result;
-}
-
-/**
- * Generic LDLM "completion" AST. This is called in several cases:
- *
- *     - when a reply to an ENQUEUE RPC is received from the server
- *       (ldlm_cli_enqueue_fini()). Lock might be granted or not granted at
- *       this point (determined by flags);
- *
- *     - when LDLM_CP_CALLBACK RPC comes to client to notify it that lock has
- *       been granted;
- *
- *     - when ldlm_lock_match(LDLM_FL_LVB_READY) is about to wait until lock
- *       gets correct lvb;
- *
- *     - to force all locks when resource is destroyed (cleanup_resource());
- *
- *     - during lock conversion (not used currently).
- *
- * If lock is not granted in the first case, this function waits until second
- * or penultimate cases happen in some other thread.
- *
- */
-int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
-{
-	/* XXX ALLOCATE - 160 bytes */
-	struct obd_device *obd;
-	struct obd_import *imp = NULL;
-	__u32 timeout;
-	__u32 conn_cnt = 0;
-	int rc = 0;
-
-	if (flags == LDLM_FL_WAIT_NOREPROC) {
-		LDLM_DEBUG(lock, "client-side enqueue waiting on pending lock");
-		goto noreproc;
-	}
-
-	if (!(flags & LDLM_FL_BLOCKED_MASK)) {
-		wake_up(&lock->l_waitq);
-		return 0;
-	}
-
-	LDLM_DEBUG(lock,
-		   "client-side enqueue returned a blocked lock, sleeping");
-
-noreproc:
-
-	obd = class_exp2obd(lock->l_conn_export);
-
-	/* if this is a local lock, then there is no import */
-	if (obd)
-		imp = obd->u.cli.cl_import;
-
-	timeout = ldlm_cp_timeout(lock);
-
-	lock->l_last_activity = ktime_get_real_seconds();
-
-	if (imp) {
-		spin_lock(&imp->imp_lock);
-		conn_cnt = imp->imp_conn_cnt;
-		spin_unlock(&imp->imp_lock);
-	}
-	if (OBD_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
-				 OBD_FAIL_LDLM_CP_BL_RACE | OBD_FAIL_ONCE)) {
-		ldlm_set_fail_loc(lock);
-		rc = -EINTR;
-	} else {
-		/* Go to sleep until the lock is granted or canceled. */
-		if (!ldlm_is_no_timeout(lock)) {
-			/* Wait uninterruptible for a while first */
-			rc = wait_event_idle_timeout(lock->l_waitq,
-						     is_granted_or_cancelled(lock),
-						     timeout * HZ);
-			if (rc == 0)
-				ldlm_expired_completion_wait(lock, conn_cnt);
-		}
-		/* Now wait abortable */
-		if (rc == 0)
-			rc = l_wait_event_abortable(lock->l_waitq,
-						    is_granted_or_cancelled(lock));
-		else
-			rc = 0;
-	}
-
-	if (rc) {
-		LDLM_DEBUG(lock, "client-side enqueue waking up: failed (%d)",
-			   rc);
-		return rc;
-	}
-
-	return ldlm_completion_tail(lock, data);
-}
-EXPORT_SYMBOL(ldlm_completion_ast);
-
-static void failed_lock_cleanup(struct ldlm_namespace *ns,
-				struct ldlm_lock *lock, int mode)
-{
-	int need_cancel = 0;
-
-	/* Set a flag to prevent us from sending a CANCEL (bug 407) */
-	lock_res_and_lock(lock);
-	/* Check that lock is not granted or failed, we might race. */
-	if ((lock->l_req_mode != lock->l_granted_mode) &&
-	    !ldlm_is_failed(lock)) {
-		/* Make sure that this lock will not be found by raced
-		 * bl_ast and -EINVAL reply is sent to server anyways.
-		 * bug 17645
-		 */
-		lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_FAILED |
-				 LDLM_FL_ATOMIC_CB | LDLM_FL_CBPENDING;
-		need_cancel = 1;
-	}
-	unlock_res_and_lock(lock);
-
-	if (need_cancel)
-		LDLM_DEBUG(lock,
-			   "setting FL_LOCAL_ONLY | LDLM_FL_FAILED | LDLM_FL_ATOMIC_CB | LDLM_FL_CBPENDING");
-	else
-		LDLM_DEBUG(lock, "lock was granted or failed in race");
-
-	/* XXX - HACK because we shouldn't call ldlm_lock_destroy()
-	 *       from llite/file.c/ll_file_flock().
-	 */
-	/* This code makes for the fact that we do not have blocking handler on
-	 * a client for flock locks. As such this is the place where we must
-	 * completely kill failed locks. (interrupted and those that
-	 * were waiting to be granted when server evicted us.
-	 */
-	if (lock->l_resource->lr_type == LDLM_FLOCK) {
-		lock_res_and_lock(lock);
-		if (!ldlm_is_destroyed(lock)) {
-			ldlm_resource_unlink_lock(lock);
-			ldlm_lock_decref_internal_nolock(lock, mode);
-			ldlm_lock_destroy_nolock(lock);
-		}
-		unlock_res_and_lock(lock);
-	} else {
-		ldlm_lock_decref_internal(lock, mode);
-	}
-}
-
-/**
- * Finishing portion of client lock enqueue code.
- *
- * Called after receiving reply from server.
- */
-int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
-			  enum ldlm_type type, __u8 with_policy,
-			  enum ldlm_mode mode,
-			  __u64 *flags, void *lvb, __u32 lvb_len,
-			  const struct lustre_handle *lockh, int rc)
-{
-	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
-	int is_replay = *flags & LDLM_FL_REPLAY;
-	struct ldlm_lock *lock;
-	struct ldlm_reply *reply;
-	int cleanup_phase = 1;
-
-	lock = ldlm_handle2lock(lockh);
-	/* ldlm_cli_enqueue is holding a reference on this lock. */
-	if (!lock) {
-		LASSERT(type == LDLM_FLOCK);
-		return -ENOLCK;
-	}
-
-	LASSERTF(ergo(lvb_len != 0, lvb_len == lock->l_lvb_len),
-		 "lvb_len = %d, l_lvb_len = %d\n", lvb_len, lock->l_lvb_len);
-
-	if (rc != ELDLM_OK) {
-		LASSERT(!is_replay);
-		LDLM_DEBUG(lock, "client-side enqueue END (%s)",
-			   rc == ELDLM_LOCK_ABORTED ? "ABORTED" : "FAILED");
-
-		if (rc != ELDLM_LOCK_ABORTED)
-			goto cleanup;
-	}
-
-	/* Before we return, swab the reply */
-	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
-	if (!reply) {
-		rc = -EPROTO;
-		goto cleanup;
-	}
-
-	if (lvb_len > 0) {
-		int size = 0;
-
-		size = req_capsule_get_size(&req->rq_pill, &RMF_DLM_LVB,
-					    RCL_SERVER);
-		if (size < 0) {
-			LDLM_ERROR(lock, "Fail to get lvb_len, rc = %d", size);
-			rc = size;
-			goto cleanup;
-		} else if (unlikely(size > lvb_len)) {
-			LDLM_ERROR(lock,
-				   "Replied LVB is larger than expectation, expected = %d, replied = %d",
-				   lvb_len, size);
-			rc = -EINVAL;
-			goto cleanup;
-		}
-		lvb_len = size;
-	}
-
-	if (rc == ELDLM_LOCK_ABORTED) {
-		if (lvb_len > 0 && lvb)
-			rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_SERVER,
-					   lvb, lvb_len);
-		if (rc == 0)
-			rc = ELDLM_LOCK_ABORTED;
-		goto cleanup;
-	}
-
-	/* lock enqueued on the server */
-	cleanup_phase = 0;
-
-	lock_res_and_lock(lock);
-	lock->l_remote_handle = reply->lock_handle;
-
-	*flags = ldlm_flags_from_wire(reply->lock_flags);
-	lock->l_flags |= ldlm_flags_from_wire(reply->lock_flags &
-					      LDLM_FL_INHERIT_MASK);
-	unlock_res_and_lock(lock);
-
-	CDEBUG(D_INFO, "local: %p, remote cookie: %#llx, flags: 0x%llx\n",
-	       lock, reply->lock_handle.cookie, *flags);
-
-	/* If enqueue returned a blocked lock but the completion handler has
-	 * already run, then it fixed up the resource and we don't need to do it
-	 * again.
-	 */
-	if ((*flags) & LDLM_FL_LOCK_CHANGED) {
-		int newmode = reply->lock_desc.l_req_mode;
-
-		LASSERT(!is_replay);
-		if (newmode && newmode != lock->l_req_mode) {
-			LDLM_DEBUG(lock, "server returned different mode %s",
-				   ldlm_lockname[newmode]);
-			lock->l_req_mode = newmode;
-		}
-
-		if (!ldlm_res_eq(&reply->lock_desc.l_resource.lr_name,
-				 &lock->l_resource->lr_name)) {
-			CDEBUG(D_INFO,
-			       "remote intent success, locking " DLDLMRES " instead of " DLDLMRES "\n",
-			       PLDLMRES(&reply->lock_desc.l_resource),
-			       PLDLMRES(lock->l_resource));
-
-			rc = ldlm_lock_change_resource(ns, lock,
-					&reply->lock_desc.l_resource.lr_name);
-			if (rc || !lock->l_resource) {
-				rc = -ENOMEM;
-				goto cleanup;
-			}
-			LDLM_DEBUG(lock, "client-side enqueue, new resource");
-		}
-		if (with_policy)
-			if (!(type == LDLM_IBITS &&
-			      !(exp_connect_flags(exp) & OBD_CONNECT_IBITS)))
-				/* We assume lock type cannot change on server*/
-				ldlm_convert_policy_to_local(exp,
-						lock->l_resource->lr_type,
-						&reply->lock_desc.l_policy_data,
-						&lock->l_policy_data);
-		if (type != LDLM_PLAIN)
-			LDLM_DEBUG(lock,
-				   "client-side enqueue, new policy data");
-	}
-
-	if ((*flags) & LDLM_FL_AST_SENT) {
-		lock_res_and_lock(lock);
-		lock->l_flags |= LDLM_FL_CBPENDING |  LDLM_FL_BL_AST;
-		unlock_res_and_lock(lock);
-		LDLM_DEBUG(lock, "enqueue reply includes blocking AST");
-	}
-
-	/* If the lock has already been granted by a completion AST, don't
-	 * clobber the LVB with an older one.
-	 */
-	if (lvb_len > 0) {
-		/* We must lock or a racing completion might update lvb without
-		 * letting us know and we'll clobber the correct value.
-		 * Cannot unlock after the check either, as that still leaves
-		 * a tiny window for completion to get in
-		 */
-		lock_res_and_lock(lock);
-		if (lock->l_req_mode != lock->l_granted_mode)
-			rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_SERVER,
-					   lock->l_lvb_data, lvb_len);
-		unlock_res_and_lock(lock);
-		if (rc < 0) {
-			cleanup_phase = 1;
-			goto cleanup;
-		}
-	}
-
-	if (!is_replay) {
-		rc = ldlm_lock_enqueue(ns, &lock, NULL, flags);
-		if (lock->l_completion_ast) {
-			int err = lock->l_completion_ast(lock, *flags, NULL);
-
-			if (!rc)
-				rc = err;
-			if (rc)
-				cleanup_phase = 1;
-		}
-	}
-
-	if (lvb_len > 0 && lvb) {
-		/* Copy the LVB here, and not earlier, because the completion
-		 * AST (if any) can override what we got in the reply
-		 */
-		memcpy(lvb, lock->l_lvb_data, lvb_len);
-	}
-
-	LDLM_DEBUG(lock, "client-side enqueue END");
-cleanup:
-	if (cleanup_phase == 1 && rc)
-		failed_lock_cleanup(ns, lock, mode);
-	/* Put lock 2 times, the second reference is held by ldlm_cli_enqueue */
-	LDLM_LOCK_PUT(lock);
-	LDLM_LOCK_RELEASE(lock);
-	return rc;
-}
-EXPORT_SYMBOL(ldlm_cli_enqueue_fini);
-
-/**
- * Estimate number of lock handles that would fit into request of given
- * size.  PAGE_SIZE-512 is to allow TCP/IP and LNET headers to fit into
- * a single page on the send/receive side. XXX: 512 should be changed to
- * more adequate value.
- */
-static inline int ldlm_req_handles_avail(int req_size, int off)
-{
-	int avail;
-
-	avail = min_t(int, LDLM_MAXREQSIZE, PAGE_SIZE - 512) - req_size;
-	if (likely(avail >= 0))
-		avail /= (int)sizeof(struct lustre_handle);
-	else
-		avail = 0;
-	avail += LDLM_LOCKREQ_HANDLES - off;
-
-	return avail;
-}
-
-static inline int ldlm_capsule_handles_avail(struct req_capsule *pill,
-					     enum req_location loc,
-					     int off)
-{
-	u32 size = req_capsule_msg_size(pill, loc);
-
-	return ldlm_req_handles_avail(size, off);
-}
-
-static inline int ldlm_format_handles_avail(struct obd_import *imp,
-					    const struct req_format *fmt,
-					    enum req_location loc, int off)
-{
-	u32 size = req_capsule_fmt_size(imp->imp_msg_magic, fmt, loc);
-
-	return ldlm_req_handles_avail(size, off);
-}
-
-/**
- * Cancel LRU locks and pack them into the enqueue request. Pack there the given
- * \a count locks in \a cancels.
- *
- * This is to be called by functions preparing their own requests that
- * might contain lists of locks to cancel in addition to actual operation
- * that needs to be performed.
- */
-int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
-		      int version, int opc, int canceloff,
-		      struct list_head *cancels, int count)
-{
-	struct ldlm_namespace   *ns = exp->exp_obd->obd_namespace;
-	struct req_capsule      *pill = &req->rq_pill;
-	struct ldlm_request     *dlm = NULL;
-	int flags, avail, to_free, pack = 0;
-	LIST_HEAD(head);
-	int rc;
-
-	if (!cancels)
-		cancels = &head;
-	if (ns_connect_cancelset(ns)) {
-		/* Estimate the amount of available space in the request. */
-		req_capsule_filled_sizes(pill, RCL_CLIENT);
-		avail = ldlm_capsule_handles_avail(pill, RCL_CLIENT, canceloff);
-
-		flags = ns_connect_lru_resize(ns) ?
-			LDLM_LRU_FLAG_LRUR_NO_WAIT : LDLM_LRU_FLAG_AGED;
-		to_free = !ns_connect_lru_resize(ns) &&
-			  opc == LDLM_ENQUEUE ? 1 : 0;
-
-		/* Cancel LRU locks here _only_ if the server supports
-		 * EARLY_CANCEL. Otherwise we have to send extra CANCEL
-		 * RPC, which will make us slower.
-		 */
-		if (avail > count)
-			count += ldlm_cancel_lru_local(ns, cancels, to_free,
-						       avail - count, 0, flags);
-		if (avail > count)
-			pack = count;
-		else
-			pack = avail;
-		req_capsule_set_size(pill, &RMF_DLM_REQ, RCL_CLIENT,
-				     ldlm_request_bufsize(pack, opc));
-	}
-
-	rc = ptlrpc_request_pack(req, version, opc);
-	if (rc) {
-		ldlm_lock_list_put(cancels, l_bl_ast, count);
-		return rc;
-	}
-
-	if (ns_connect_cancelset(ns)) {
-		if (canceloff) {
-			dlm = req_capsule_client_get(pill, &RMF_DLM_REQ);
-			LASSERT(dlm);
-			/* Skip first lock handler in ldlm_request_pack(),
-			 * this method will increment @lock_count according
-			 * to the lock handle amount actually written to
-			 * the buffer.
-			 */
-			dlm->lock_count = canceloff;
-		}
-		/* Pack into the request @pack lock handles. */
-		ldlm_cli_cancel_list(cancels, pack, req, 0);
-		/* Prepare and send separate cancel RPC for others. */
-		ldlm_cli_cancel_list(cancels, count - pack, NULL, 0);
-	} else {
-		ldlm_lock_list_put(cancels, l_bl_ast, count);
-	}
-	return 0;
-}
-EXPORT_SYMBOL(ldlm_prep_elc_req);
-
-int ldlm_prep_enqueue_req(struct obd_export *exp, struct ptlrpc_request *req,
-			  struct list_head *cancels, int count)
-{
-	return ldlm_prep_elc_req(exp, req, LUSTRE_DLM_VERSION, LDLM_ENQUEUE,
-				 LDLM_ENQUEUE_CANCEL_OFF, cancels, count);
-}
-EXPORT_SYMBOL(ldlm_prep_enqueue_req);
-
-static struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp,
-						int lvb_len)
-{
-	struct ptlrpc_request *req;
-	int rc;
-
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_LDLM_ENQUEUE);
-	if (!req)
-		return ERR_PTR(-ENOMEM);
-
-	rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
-	if (rc) {
-		ptlrpc_request_free(req);
-		return ERR_PTR(rc);
-	}
-
-	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER, lvb_len);
-	ptlrpc_request_set_replen(req);
-	return req;
-}
-
-/**
- * Client-side lock enqueue.
- *
- * If a request has some specific initialisation it is passed in \a reqp,
- * otherwise it is created in ldlm_cli_enqueue.
- *
- * Supports sync and async requests, pass \a async flag accordingly. If a
- * request was created in ldlm_cli_enqueue and it is the async request,
- * pass it to the caller in \a reqp.
- */
-int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
-		     struct ldlm_enqueue_info *einfo,
-		     const struct ldlm_res_id *res_id,
-		     union ldlm_policy_data const *policy, __u64 *flags,
-		     void *lvb, __u32 lvb_len, enum lvb_type lvb_type,
-		     struct lustre_handle *lockh, int async)
-{
-	struct ldlm_namespace *ns;
-	struct ldlm_lock      *lock;
-	struct ldlm_request   *body;
-	int		    is_replay = *flags & LDLM_FL_REPLAY;
-	int		    req_passed_in = 1;
-	int		    rc, err;
-	struct ptlrpc_request *req;
-
-	ns = exp->exp_obd->obd_namespace;
-
-	/* If we're replaying this lock, just check some invariants.
-	 * If we're creating a new lock, get everything all setup nicely.
-	 */
-	if (is_replay) {
-		lock = ldlm_handle2lock_long(lockh, 0);
-		LASSERT(lock);
-		LDLM_DEBUG(lock, "client-side enqueue START");
-		LASSERT(exp == lock->l_conn_export);
-	} else {
-		const struct ldlm_callback_suite cbs = {
-			.lcs_completion = einfo->ei_cb_cp,
-			.lcs_blocking	= einfo->ei_cb_bl,
-			.lcs_glimpse	= einfo->ei_cb_gl
-		};
-		lock = ldlm_lock_create(ns, res_id, einfo->ei_type,
-					einfo->ei_mode, &cbs, einfo->ei_cbdata,
-					lvb_len, lvb_type);
-		if (IS_ERR(lock))
-			return PTR_ERR(lock);
-		/* for the local lock, add the reference */
-		ldlm_lock_addref_internal(lock, einfo->ei_mode);
-		ldlm_lock2handle(lock, lockh);
-		if (policy)
-			lock->l_policy_data = *policy;
-
-		if (einfo->ei_type == LDLM_EXTENT) {
-			/* extent lock without policy is a bug */
-			if (!policy)
-				LBUG();
-
-			lock->l_req_extent = policy->l_extent;
-		}
-		LDLM_DEBUG(lock, "client-side enqueue START, flags %llx",
-			   *flags);
-	}
-
-	lock->l_conn_export = exp;
-	lock->l_export = NULL;
-	lock->l_blocking_ast = einfo->ei_cb_bl;
-	lock->l_flags |= (*flags & (LDLM_FL_NO_LRU | LDLM_FL_EXCL));
-	lock->l_last_activity = ktime_get_real_seconds();
-
-	/* lock not sent to server yet */
-	if (!reqp || !*reqp) {
-		req = ldlm_enqueue_pack(exp, lvb_len);
-		if (IS_ERR(req)) {
-			failed_lock_cleanup(ns, lock, einfo->ei_mode);
-			LDLM_LOCK_RELEASE(lock);
-			return PTR_ERR(req);
-		}
-
-		req_passed_in = 0;
-		if (reqp)
-			*reqp = req;
-	} else {
-		int len;
-
-		req = *reqp;
-		len = req_capsule_get_size(&req->rq_pill, &RMF_DLM_REQ,
-					   RCL_CLIENT);
-		LASSERTF(len >= sizeof(*body), "buflen[%d] = %d, not %d\n",
-			 DLM_LOCKREQ_OFF, len, (int)sizeof(*body));
-	}
-
-	/* Dump lock data into the request buffer */
-	body = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
-	ldlm_lock2desc(lock, &body->lock_desc);
-	body->lock_flags = ldlm_flags_to_wire(*flags);
-	body->lock_handle[0] = *lockh;
-
-	if (async) {
-		LASSERT(reqp);
-		return 0;
-	}
-
-	LDLM_DEBUG(lock, "sending request");
-
-	rc = ptlrpc_queue_wait(req);
-
-	err = ldlm_cli_enqueue_fini(exp, req, einfo->ei_type, policy ? 1 : 0,
-				    einfo->ei_mode, flags, lvb, lvb_len,
-				    lockh, rc);
-
-	/* If ldlm_cli_enqueue_fini did not find the lock, we need to free
-	 * one reference that we took
-	 */
-	if (err == -ENOLCK)
-		LDLM_LOCK_RELEASE(lock);
-	else
-		rc = err;
-
-	if (!req_passed_in && req) {
-		ptlrpc_req_finished(req);
-		if (reqp)
-			*reqp = NULL;
-	}
-
-	return rc;
-}
-EXPORT_SYMBOL(ldlm_cli_enqueue);
-
-/**
- * Cancel locks locally.
- * Returns:
- * \retval LDLM_FL_LOCAL_ONLY if there is no need for a CANCEL RPC to the server
- * \retval LDLM_FL_CANCELING otherwise;
- * \retval LDLM_FL_BL_AST if there is a need for a separate CANCEL RPC.
- */
-static __u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
-{
-	__u64 rc = LDLM_FL_LOCAL_ONLY;
-
-	if (lock->l_conn_export) {
-		bool local_only;
-
-		LDLM_DEBUG(lock, "client-side cancel");
-		/* Set this flag to prevent others from getting new references*/
-		lock_res_and_lock(lock);
-		ldlm_set_cbpending(lock);
-		local_only = !!(lock->l_flags &
-				(LDLM_FL_LOCAL_ONLY | LDLM_FL_CANCEL_ON_BLOCK));
-		ldlm_cancel_callback(lock);
-		rc = ldlm_is_bl_ast(lock) ? LDLM_FL_BL_AST : LDLM_FL_CANCELING;
-		unlock_res_and_lock(lock);
-
-		if (local_only) {
-			CDEBUG(D_DLMTRACE,
-			       "not sending request (at caller's instruction)\n");
-			rc = LDLM_FL_LOCAL_ONLY;
-		}
-		ldlm_lock_cancel(lock);
-	} else {
-		LDLM_ERROR(lock, "Trying to cancel local lock");
-		LBUG();
-	}
-
-	return rc;
-}
-
-/**
- * Pack \a count locks in \a head into ldlm_request buffer of request \a req.
- */
-static void ldlm_cancel_pack(struct ptlrpc_request *req,
-			     struct list_head *head, int count)
-{
-	struct ldlm_request *dlm;
-	struct ldlm_lock *lock;
-	int max, packed = 0;
-
-	dlm = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
-	LASSERT(dlm);
-
-	/* Check the room in the request buffer. */
-	max = req_capsule_get_size(&req->rq_pill, &RMF_DLM_REQ, RCL_CLIENT) -
-		sizeof(struct ldlm_request);
-	max /= sizeof(struct lustre_handle);
-	max += LDLM_LOCKREQ_HANDLES;
-	LASSERT(max >= dlm->lock_count + count);
-
-	/* XXX: it would be better to pack lock handles grouped by resource.
-	 * so that the server cancel would call filter_lvbo_update() less
-	 * frequently.
-	 */
-	list_for_each_entry(lock, head, l_bl_ast) {
-		if (!count--)
-			break;
-		LASSERT(lock->l_conn_export);
-		/* Pack the lock handle to the given request buffer. */
-		LDLM_DEBUG(lock, "packing");
-		dlm->lock_handle[dlm->lock_count++] = lock->l_remote_handle;
-		packed++;
-	}
-	CDEBUG(D_DLMTRACE, "%d locks packed\n", packed);
-}
-
-/**
- * Prepare and send a batched cancel RPC. It will include \a count lock
- * handles of locks given in \a cancels list.
- */
-static int ldlm_cli_cancel_req(struct obd_export *exp,
-			       struct list_head *cancels,
-			       int count, enum ldlm_cancel_flags flags)
-{
-	struct ptlrpc_request *req = NULL;
-	struct obd_import *imp;
-	int free, sent = 0;
-	int rc = 0;
-
-	LASSERT(exp);
-	LASSERT(count > 0);
-
-	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL, cfs_fail_val);
-
-	if (CFS_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_RACE))
-		return count;
-
-	free = ldlm_format_handles_avail(class_exp2cliimp(exp),
-					 &RQF_LDLM_CANCEL, RCL_CLIENT, 0);
-	if (count > free)
-		count = free;
-
-	while (1) {
-		imp = class_exp2cliimp(exp);
-		if (!imp || imp->imp_invalid) {
-			CDEBUG(D_DLMTRACE,
-			       "skipping cancel on invalid import %p\n", imp);
-			return count;
-		}
-
-		req = ptlrpc_request_alloc(imp, &RQF_LDLM_CANCEL);
-		if (!req) {
-			rc = -ENOMEM;
-			goto out;
-		}
-
-		req_capsule_filled_sizes(&req->rq_pill, RCL_CLIENT);
-		req_capsule_set_size(&req->rq_pill, &RMF_DLM_REQ, RCL_CLIENT,
-				     ldlm_request_bufsize(count, LDLM_CANCEL));
-
-		rc = ptlrpc_request_pack(req, LUSTRE_DLM_VERSION, LDLM_CANCEL);
-		if (rc) {
-			ptlrpc_request_free(req);
-			goto out;
-		}
-
-		req->rq_request_portal = LDLM_CANCEL_REQUEST_PORTAL;
-		req->rq_reply_portal = LDLM_CANCEL_REPLY_PORTAL;
-		ptlrpc_at_set_req_timeout(req);
-
-		ldlm_cancel_pack(req, cancels, count);
-
-		ptlrpc_request_set_replen(req);
-		if (flags & LCF_ASYNC) {
-			ptlrpcd_add_req(req);
-			sent = count;
-			goto out;
-		}
-
-		rc = ptlrpc_queue_wait(req);
-		if (rc == LUSTRE_ESTALE) {
-			CDEBUG(D_DLMTRACE,
-			       "client/server (nid %s) out of sync -- not fatal\n",
-			       libcfs_nid2str(req->rq_import->
-					      imp_connection->c_peer.nid));
-			rc = 0;
-		} else if (rc == -ETIMEDOUT && /* check there was no reconnect*/
-			   req->rq_import_generation == imp->imp_generation) {
-			ptlrpc_req_finished(req);
-			continue;
-		} else if (rc != ELDLM_OK) {
-			/* -ESHUTDOWN is common on umount */
-			CDEBUG_LIMIT(rc == -ESHUTDOWN ? D_DLMTRACE : D_ERROR,
-				     "Got rc %d from cancel RPC: canceling anyway\n",
-				     rc);
-			break;
-		}
-		sent = count;
-		break;
-	}
-
-	ptlrpc_req_finished(req);
-out:
-	return sent ? sent : rc;
-}
-
-static inline struct ldlm_pool *ldlm_imp2pl(struct obd_import *imp)
-{
-	return &imp->imp_obd->obd_namespace->ns_pool;
-}
-
-/**
- * Update client's OBD pool related fields with new SLV and Limit from \a req.
- */
-int ldlm_cli_update_pool(struct ptlrpc_request *req)
-{
-	struct obd_device *obd;
-	__u64 new_slv;
-	__u32 new_limit;
-
-	if (unlikely(!req->rq_import || !req->rq_import->imp_obd ||
-		     !imp_connect_lru_resize(req->rq_import))) {
-		/*
-		 * Do nothing for corner cases.
-		 */
-		return 0;
-	}
-
-	/* In some cases RPC may contain SLV and limit zeroed out. This
-	 * is the case when server does not support LRU resize feature.
-	 * This is also possible in some recovery cases when server-side
-	 * reqs have no reference to the OBD export and thus access to
-	 * server-side namespace is not possible.
-	 */
-	if (lustre_msg_get_slv(req->rq_repmsg) == 0 ||
-	    lustre_msg_get_limit(req->rq_repmsg) == 0) {
-		DEBUG_REQ(D_HA, req,
-			  "Zero SLV or Limit found (SLV: %llu, Limit: %u)",
-			  lustre_msg_get_slv(req->rq_repmsg),
-			  lustre_msg_get_limit(req->rq_repmsg));
-		return 0;
-	}
-
-	new_limit = lustre_msg_get_limit(req->rq_repmsg);
-	new_slv = lustre_msg_get_slv(req->rq_repmsg);
-	obd = req->rq_import->imp_obd;
-
-	/* Set new SLV and limit in OBD fields to make them accessible
-	 * to the pool thread. We do not access obd_namespace and pool
-	 * directly here as there is no reliable way to make sure that
-	 * they are still alive at cleanup time. Evil races are possible
-	 * which may cause Oops at that time.
-	 */
-	write_lock(&obd->obd_pool_lock);
-	obd->obd_pool_slv = new_slv;
-	obd->obd_pool_limit = new_limit;
-	write_unlock(&obd->obd_pool_lock);
-
-	return 0;
-}
-
-/**
- * Client side lock cancel.
- *
- * Lock must not have any readers or writers by this time.
- */
-int ldlm_cli_cancel(const struct lustre_handle *lockh,
-		    enum ldlm_cancel_flags cancel_flags)
-{
-	struct obd_export *exp;
-	int avail, flags, count = 1;
-	__u64 rc = 0;
-	struct ldlm_namespace *ns;
-	struct ldlm_lock *lock;
-	LIST_HEAD(cancels);
-
-	lock = ldlm_handle2lock_long(lockh, 0);
-	if (!lock) {
-		LDLM_DEBUG_NOLOCK("lock is already being destroyed");
-		return 0;
-	}
-
-	lock_res_and_lock(lock);
-	/* Lock is being canceled and the caller doesn't want to wait */
-	if (ldlm_is_canceling(lock) && (cancel_flags & LCF_ASYNC)) {
-		unlock_res_and_lock(lock);
-		LDLM_LOCK_RELEASE(lock);
-		return 0;
-	}
-
-	ldlm_set_canceling(lock);
-	unlock_res_and_lock(lock);
-
-	rc = ldlm_cli_cancel_local(lock);
-	if (rc == LDLM_FL_LOCAL_ONLY || cancel_flags & LCF_LOCAL) {
-		LDLM_LOCK_RELEASE(lock);
-		return 0;
-	}
-	/* Even if the lock is marked as LDLM_FL_BL_AST, this is a LDLM_CANCEL
-	 * RPC which goes to canceld portal, so we can cancel other LRU locks
-	 * here and send them all as one LDLM_CANCEL RPC.
-	 */
-	LASSERT(list_empty(&lock->l_bl_ast));
-	list_add(&lock->l_bl_ast, &cancels);
-
-	exp = lock->l_conn_export;
-	if (exp_connect_cancelset(exp)) {
-		avail = ldlm_format_handles_avail(class_exp2cliimp(exp),
-						  &RQF_LDLM_CANCEL,
-						  RCL_CLIENT, 0);
-		LASSERT(avail > 0);
-
-		ns = ldlm_lock_to_ns(lock);
-		flags = ns_connect_lru_resize(ns) ?
-			LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED;
-		count += ldlm_cancel_lru_local(ns, &cancels, 0, avail - 1,
-					       LCF_BL_AST, flags);
-	}
-	ldlm_cli_cancel_list(&cancels, count, NULL, cancel_flags);
-	return 0;
-}
-EXPORT_SYMBOL(ldlm_cli_cancel);
-
-/**
- * Locally cancel up to \a count locks in list \a cancels.
- * Return the number of cancelled locks.
- */
-int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
-			       enum ldlm_cancel_flags flags)
-{
-	LIST_HEAD(head);
-	struct ldlm_lock *lock, *next;
-	int left = 0, bl_ast = 0;
-	__u64 rc;
-
-	left = count;
-	list_for_each_entry_safe(lock, next, cancels, l_bl_ast) {
-		if (left-- == 0)
-			break;
-
-		if (flags & LCF_LOCAL) {
-			rc = LDLM_FL_LOCAL_ONLY;
-			ldlm_lock_cancel(lock);
-		} else {
-			rc = ldlm_cli_cancel_local(lock);
-		}
-		/* Until we have compound requests and can send LDLM_CANCEL
-		 * requests batched with generic RPCs, we need to send cancels
-		 * with the LDLM_FL_BL_AST flag in a separate RPC from
-		 * the one being generated now.
-		 */
-		if (!(flags & LCF_BL_AST) && (rc == LDLM_FL_BL_AST)) {
-			LDLM_DEBUG(lock, "Cancel lock separately");
-			list_del_init(&lock->l_bl_ast);
-			list_add(&lock->l_bl_ast, &head);
-			bl_ast++;
-			continue;
-		}
-		if (rc == LDLM_FL_LOCAL_ONLY) {
-			/* CANCEL RPC should not be sent to server. */
-			list_del_init(&lock->l_bl_ast);
-			LDLM_LOCK_RELEASE(lock);
-			count--;
-		}
-	}
-	if (bl_ast > 0) {
-		count -= bl_ast;
-		ldlm_cli_cancel_list(&head, bl_ast, NULL, 0);
-	}
-
-	return count;
-}
-
-/**
- * Cancel as many locks as possible w/o sending any RPCs (e.g. to write back
- * dirty data, to close a file, ...) or waiting for any RPCs in-flight (e.g.
- * readahead requests, ...)
- */
-static enum ldlm_policy_res
-ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
-			   int unused, int added, int count)
-{
-	enum ldlm_policy_res result = LDLM_POLICY_CANCEL_LOCK;
-
-	/* don't check added & count since we want to process all locks
-	 * from unused list.
-	 * It's fine to not take lock to access lock->l_resource since
-	 * the lock has already been granted so it won't change.
-	 */
-	switch (lock->l_resource->lr_type) {
-	case LDLM_EXTENT:
-	case LDLM_IBITS:
-		if (ns->ns_cancel && ns->ns_cancel(lock) != 0)
-			break;
-		/* fall through */
-	default:
-		result = LDLM_POLICY_SKIP_LOCK;
-		lock_res_and_lock(lock);
-		ldlm_set_skipped(lock);
-		unlock_res_and_lock(lock);
-		break;
-	}
-
-	return result;
-}
-
-/**
- * Callback function for LRU-resize policy. Decides whether to keep
- * \a lock in LRU for current \a LRU size \a unused, added in current
- * scan \a added and number of locks to be preferably canceled \a count.
- *
- * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
- *
- * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
- */
-static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
-						    struct ldlm_lock *lock,
-						    int unused, int added,
-						    int count)
-{
-	unsigned long cur = jiffies;
-	struct ldlm_pool *pl = &ns->ns_pool;
-	__u64 slv, lvf, lv;
-	unsigned long la;
-
-	/* Stop LRU processing when we reach past @count or have checked all
-	 * locks in LRU.
-	 */
-	if (count && added >= count)
-		return LDLM_POLICY_KEEP_LOCK;
-
-	/*
-	 * Despite of the LV, It doesn't make sense to keep the lock which
-	 * is unused for ns_max_age time.
-	 */
-	if (time_after(jiffies, lock->l_last_used + ns->ns_max_age))
-		return LDLM_POLICY_CANCEL_LOCK;
-
-	slv = ldlm_pool_get_slv(pl);
-	lvf = ldlm_pool_get_lvf(pl);
-	la = (cur - lock->l_last_used) / HZ;
-	lv = lvf * la * unused;
-
-	/* Inform pool about current CLV to see it via debugfs. */
-	ldlm_pool_set_clv(pl, lv);
-
-	/* Stop when SLV is not yet come from server or lv is smaller than
-	 * it is.
-	 */
-	if (slv == 0 || lv < slv)
-		return LDLM_POLICY_KEEP_LOCK;
-
-	return LDLM_POLICY_CANCEL_LOCK;
-}
-
-/**
- * Callback function for debugfs used policy. Makes decision whether to keep
- * \a lock in LRU for current \a LRU size \a unused, added in current scan \a
- * added and number of locks to be preferably canceled \a count.
- *
- * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
- *
- * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
- */
-static enum ldlm_policy_res ldlm_cancel_passed_policy(struct ldlm_namespace *ns,
-						      struct ldlm_lock *lock,
-						      int unused, int added,
-						      int count)
-{
-	/* Stop LRU processing when we reach past @count or have checked all
-	 * locks in LRU.
-	 */
-	return (added >= count) ?
-		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
-}
-
-/**
- * Callback function for aged policy. Makes decision whether to keep \a lock in
- * LRU for current LRU size \a unused, added in current scan \a added and
- * number of locks to be preferably canceled \a count.
- *
- * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
- *
- * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
- */
-static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
-						    struct ldlm_lock *lock,
-						    int unused, int added,
-						    int count)
-{
-	if ((added >= count) &&
-	    time_before(jiffies, lock->l_last_used + ns->ns_max_age))
-		return LDLM_POLICY_KEEP_LOCK;
-
-	return LDLM_POLICY_CANCEL_LOCK;
-}
-
-static enum ldlm_policy_res
-ldlm_cancel_lrur_no_wait_policy(struct ldlm_namespace *ns,
-				struct ldlm_lock *lock,
-				int unused, int added,
-				int count)
-{
-	enum ldlm_policy_res result;
-
-	result = ldlm_cancel_lrur_policy(ns, lock, unused, added, count);
-	if (result == LDLM_POLICY_KEEP_LOCK)
-		return result;
-
-	return ldlm_cancel_no_wait_policy(ns, lock, unused, added, count);
-}
-
-/**
- * Callback function for default policy. Makes decision whether to keep \a lock
- * in LRU for current LRU size \a unused, added in current scan \a added and
- * number of locks to be preferably canceled \a count.
- *
- * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
- *
- * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
- */
-static enum ldlm_policy_res
-ldlm_cancel_default_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
-			   int unused, int added, int count)
-{
-	/* Stop LRU processing when we reach past count or have checked all
-	 * locks in LRU.
-	 */
-	return (added >= count) ?
-		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
-}
-
-typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
-						      struct ldlm_namespace *,
-						      struct ldlm_lock *, int,
-						      int, int);
-
-static ldlm_cancel_lru_policy_t
-ldlm_cancel_lru_policy(struct ldlm_namespace *ns, int flags)
-{
-	if (flags & LDLM_LRU_FLAG_NO_WAIT)
-		return ldlm_cancel_no_wait_policy;
-
-	if (ns_connect_lru_resize(ns)) {
-		if (flags & LDLM_LRU_FLAG_SHRINK)
-			/* We kill passed number of old locks. */
-			return ldlm_cancel_passed_policy;
-		else if (flags & LDLM_LRU_FLAG_LRUR)
-			return ldlm_cancel_lrur_policy;
-		else if (flags & LDLM_LRU_FLAG_PASSED)
-			return ldlm_cancel_passed_policy;
-		else if (flags & LDLM_LRU_FLAG_LRUR_NO_WAIT)
-			return ldlm_cancel_lrur_no_wait_policy;
-	} else {
-		if (flags & LDLM_LRU_FLAG_AGED)
-			return ldlm_cancel_aged_policy;
-	}
-
-	return ldlm_cancel_default_policy;
-}
-
-/**
- * - Free space in LRU for \a count new locks,
- *   redundant unused locks are canceled locally;
- * - also cancel locally unused aged locks;
- * - do not cancel more than \a max locks;
- * - GET the found locks and add them into the \a cancels list.
- *
- * A client lock can be added to the l_bl_ast list only when it is
- * marked LDLM_FL_CANCELING. Otherwise, somebody is already doing
- * CANCEL.  There are the following use cases:
- * ldlm_cancel_resource_local(), ldlm_cancel_lru_local() and
- * ldlm_cli_cancel(), which check and set this flag properly. As any
- * attempt to cancel a lock rely on this flag, l_bl_ast list is accessed
- * later without any special locking.
- *
- * Calling policies for enabled LRU resize:
- * ----------------------------------------
- * flags & LDLM_LRU_FLAG_LRUR	- use LRU resize policy (SLV from server) to
- *				  cancel not more than \a count locks;
- *
- * flags & LDLM_LRU_FLAG_PASSED - cancel \a count number of old locks (located
- *				  at the beginning of LRU list);
- *
- * flags & LDLM_LRU_FLAG_SHRINK - cancel not more than \a count locks according
- *				  to memory pressure policy function;
- *
- * flags & LDLM_LRU_FLAG_AGED   - cancel \a count locks according to
- *				  "aged policy".
- *
- * flags & LDLM_LRU_FLAG_NO_WAIT - cancel as many unused locks as possible
- *				   (typically before replaying locks) w/o
- *				   sending any RPCs or waiting for any
- *				   outstanding RPC to complete.
- */
-static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
-				 struct list_head *cancels, int count, int max,
-				 int flags)
-{
-	ldlm_cancel_lru_policy_t pf;
-	struct ldlm_lock *lock, *next;
-	int added = 0, unused, remained;
-	int no_wait = flags &
-		(LDLM_LRU_FLAG_NO_WAIT | LDLM_LRU_FLAG_LRUR_NO_WAIT);
-
-	spin_lock(&ns->ns_lock);
-	unused = ns->ns_nr_unused;
-	remained = unused;
-
-	if (!ns_connect_lru_resize(ns))
-		count += unused - ns->ns_max_unused;
-
-	pf = ldlm_cancel_lru_policy(ns, flags);
-	LASSERT(pf);
-
-	while (!list_empty(&ns->ns_unused_list)) {
-		enum ldlm_policy_res result;
-		time_t last_use = 0;
-
-		/* all unused locks */
-		if (remained-- <= 0)
-			break;
-
-		/* For any flags, stop scanning if @max is reached. */
-		if (max && added >= max)
-			break;
-
-		list_for_each_entry_safe(lock, next, &ns->ns_unused_list,
-					 l_lru) {
-			/* No locks which got blocking requests. */
-			LASSERT(!ldlm_is_bl_ast(lock));
-
-			if (no_wait && ldlm_is_skipped(lock))
-				/* already processed */
-				continue;
-
-			last_use = lock->l_last_used;
-			if (last_use == jiffies)
-				continue;
-
-			/* Somebody is already doing CANCEL. No need for this
-			 * lock in LRU, do not traverse it again.
-			 */
-			if (!ldlm_is_canceling(lock))
-				break;
-
-			ldlm_lock_remove_from_lru_nolock(lock);
-		}
-		if (&lock->l_lru == &ns->ns_unused_list)
-			break;
-
-		LDLM_LOCK_GET(lock);
-		spin_unlock(&ns->ns_lock);
-		lu_ref_add(&lock->l_reference, __func__, current);
-
-		/* Pass the lock through the policy filter and see if it
-		 * should stay in LRU.
-		 *
-		 * Even for shrinker policy we stop scanning if
-		 * we find a lock that should stay in the cache.
-		 * We should take into account lock age anyway
-		 * as a new lock is a valuable resource even if
-		 * it has a low weight.
-		 *
-		 * That is, for shrinker policy we drop only
-		 * old locks, but additionally choose them by
-		 * their weight. Big extent locks will stay in
-		 * the cache.
-		 */
-		result = pf(ns, lock, unused, added, count);
-		if (result == LDLM_POLICY_KEEP_LOCK) {
-			lu_ref_del(&lock->l_reference,
-				   __func__, current);
-			LDLM_LOCK_RELEASE(lock);
-			spin_lock(&ns->ns_lock);
-			break;
-		}
-		if (result == LDLM_POLICY_SKIP_LOCK) {
-			lu_ref_del(&lock->l_reference,
-				   __func__, current);
-			LDLM_LOCK_RELEASE(lock);
-			spin_lock(&ns->ns_lock);
-			continue;
-		}
-
-		lock_res_and_lock(lock);
-		/* Check flags again under the lock. */
-		if (ldlm_is_canceling(lock) ||
-		    (ldlm_lock_remove_from_lru_check(lock, last_use) == 0)) {
-			/* Another thread is removing lock from LRU, or
-			 * somebody is already doing CANCEL, or there
-			 * is a blocking request which will send cancel
-			 * by itself, or the lock is no longer unused or
-			 * the lock has been used since the pf() call and
-			 * pages could be put under it.
-			 */
-			unlock_res_and_lock(lock);
-			lu_ref_del(&lock->l_reference,
-				   __func__, current);
-			LDLM_LOCK_RELEASE(lock);
-			spin_lock(&ns->ns_lock);
-			continue;
-		}
-		LASSERT(!lock->l_readers && !lock->l_writers);
-
-		/* If we have chosen to cancel this lock voluntarily, we
-		 * better send cancel notification to server, so that it
-		 * frees appropriate state. This might lead to a race
-		 * where while we are doing cancel here, server is also
-		 * silently cancelling this lock.
-		 */
-		ldlm_clear_cancel_on_block(lock);
-
-		/* Setting the CBPENDING flag is a little misleading,
-		 * but prevents an important race; namely, once
-		 * CBPENDING is set, the lock can accumulate no more
-		 * readers/writers. Since readers and writers are
-		 * already zero here, ldlm_lock_decref() won't see
-		 * this flag and call l_blocking_ast
-		 */
-		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_CANCELING;
-
-		/* We can't re-add to l_lru as it confuses the
-		 * refcounting in ldlm_lock_remove_from_lru() if an AST
-		 * arrives after we drop lr_lock below. We use l_bl_ast
-		 * and can't use l_pending_chain as it is used both on
-		 * server and client nevertheless bug 5666 says it is
-		 * used only on server
-		 */
-		LASSERT(list_empty(&lock->l_bl_ast));
-		list_add(&lock->l_bl_ast, cancels);
-		unlock_res_and_lock(lock);
-		lu_ref_del(&lock->l_reference, __func__, current);
-		spin_lock(&ns->ns_lock);
-		added++;
-		unused--;
-	}
-	spin_unlock(&ns->ns_lock);
-	return added;
-}
-
-int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
-			  struct list_head *cancels, int count, int max,
-			  enum ldlm_cancel_flags cancel_flags, int flags)
-{
-	int added;
-
-	added = ldlm_prepare_lru_list(ns, cancels, count, max, flags);
-	if (added <= 0)
-		return added;
-	return ldlm_cli_cancel_list_local(cancels, added, cancel_flags);
-}
-
-/**
- * Cancel@least \a nr locks from given namespace LRU.
- *
- * When called with LCF_ASYNC the blocking callback will be handled
- * in a thread and this function will return after the thread has been
- * asked to call the callback.  When called with LCF_ASYNC the blocking
- * callback will be performed in this function.
- */
-int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
-		    enum ldlm_cancel_flags cancel_flags,
-		    int flags)
-{
-	LIST_HEAD(cancels);
-	int count, rc;
-
-	/* Just prepare the list of locks, do not actually cancel them yet.
-	 * Locks are cancelled later in a separate thread.
-	 */
-	count = ldlm_prepare_lru_list(ns, &cancels, nr, 0, flags);
-	rc = ldlm_bl_to_thread_list(ns, NULL, &cancels, count, cancel_flags);
-	if (rc == 0)
-		return count;
-
-	return 0;
-}
-
-/**
- * Find and cancel locally unused locks found on resource, matched to the
- * given policy, mode. GET the found locks and add them into the \a cancels
- * list.
- */
-int ldlm_cancel_resource_local(struct ldlm_resource *res,
-			       struct list_head *cancels,
-			       union ldlm_policy_data *policy,
-			       enum ldlm_mode mode, __u64 lock_flags,
-			       enum ldlm_cancel_flags cancel_flags,
-			       void *opaque)
-{
-	struct ldlm_lock *lock;
-	int count = 0;
-
-	lock_res(res);
-	list_for_each_entry(lock, &res->lr_granted, l_res_link) {
-		if (opaque && lock->l_ast_data != opaque) {
-			LDLM_ERROR(lock, "data %p doesn't match opaque %p",
-				   lock->l_ast_data, opaque);
-			continue;
-		}
-
-		if (lock->l_readers || lock->l_writers)
-			continue;
-
-		/* If somebody is already doing CANCEL, or blocking AST came,
-		 * skip this lock.
-		 */
-		if (ldlm_is_bl_ast(lock) || ldlm_is_canceling(lock))
-			continue;
-
-		if (lockmode_compat(lock->l_granted_mode, mode))
-			continue;
-
-		/* If policy is given and this is IBITS lock, add to list only
-		 * those locks that match by policy.
-		 */
-		if (policy && (lock->l_resource->lr_type == LDLM_IBITS) &&
-		    !(lock->l_policy_data.l_inodebits.bits &
-		      policy->l_inodebits.bits))
-			continue;
-
-		/* See CBPENDING comment in ldlm_cancel_lru */
-		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_CANCELING |
-				 lock_flags;
-
-		LASSERT(list_empty(&lock->l_bl_ast));
-		list_add(&lock->l_bl_ast, cancels);
-		LDLM_LOCK_GET(lock);
-		count++;
-	}
-	unlock_res(res);
-
-	return ldlm_cli_cancel_list_local(cancels, count, cancel_flags);
-}
-EXPORT_SYMBOL(ldlm_cancel_resource_local);
-
-/**
- * Cancel client-side locks from a list and send/prepare cancel RPCs to the
- * server.
- * If \a req is NULL, send CANCEL request to server with handles of locks
- * in the \a cancels. If EARLY_CANCEL is not supported, send CANCEL requests
- * separately per lock.
- * If \a req is not NULL, put handles of locks in \a cancels into the request
- * buffer at the offset \a off.
- * Destroy \a cancels at the end.
- */
-int ldlm_cli_cancel_list(struct list_head *cancels, int count,
-			 struct ptlrpc_request *req,
-			 enum ldlm_cancel_flags flags)
-{
-	struct ldlm_lock *lock;
-	int res = 0;
-
-	if (list_empty(cancels) || count == 0)
-		return 0;
-
-	/* XXX: requests (both batched and not) could be sent in parallel.
-	 * Usually it is enough to have just 1 RPC, but it is possible that
-	 * there are too many locks to be cancelled in LRU or on a resource.
-	 * It would also speed up the case when the server does not support
-	 * the feature.
-	 */
-	while (count > 0) {
-		LASSERT(!list_empty(cancels));
-		lock = list_first_entry(cancels, struct ldlm_lock, l_bl_ast);
-		LASSERT(lock->l_conn_export);
-
-		if (exp_connect_cancelset(lock->l_conn_export)) {
-			res = count;
-			if (req)
-				ldlm_cancel_pack(req, cancels, count);
-			else
-				res = ldlm_cli_cancel_req(lock->l_conn_export,
-							  cancels, count,
-							  flags);
-		} else {
-			res = ldlm_cli_cancel_req(lock->l_conn_export,
-						  cancels, 1, flags);
-		}
-
-		if (res < 0) {
-			CDEBUG_LIMIT(res == -ESHUTDOWN ? D_DLMTRACE : D_ERROR,
-				     "%s: %d\n", __func__, res);
-			res = count;
-		}
-
-		count -= res;
-		ldlm_lock_list_put(cancels, l_bl_ast, res);
-	}
-	LASSERT(count == 0);
-	return 0;
-}
-EXPORT_SYMBOL(ldlm_cli_cancel_list);
-
-/**
- * Cancel all locks on a resource that have 0 readers/writers.
- *
- * If flags & LDLM_FL_LOCAL_ONLY, throw the locks away without trying
- * to notify the server.
- */
-int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
-				    const struct ldlm_res_id *res_id,
-				    union ldlm_policy_data *policy,
-				    enum ldlm_mode mode,
-				    enum ldlm_cancel_flags flags,
-				    void *opaque)
-{
-	struct ldlm_resource *res;
-	LIST_HEAD(cancels);
-	int count;
-	int rc;
-
-	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
-	if (IS_ERR(res)) {
-		/* This is not a problem. */
-		CDEBUG(D_INFO, "No resource %llu\n", res_id->name[0]);
-		return 0;
-	}
-
-	LDLM_RESOURCE_ADDREF(res);
-	count = ldlm_cancel_resource_local(res, &cancels, policy, mode,
-					   0, flags | LCF_BL_AST, opaque);
-	rc = ldlm_cli_cancel_list(&cancels, count, NULL, flags);
-	if (rc != ELDLM_OK)
-		CERROR("canceling unused lock " DLDLMRES ": rc = %d\n",
-		       PLDLMRES(res), rc);
-
-	LDLM_RESOURCE_DELREF(res);
-	ldlm_resource_putref(res);
-	return 0;
-}
-EXPORT_SYMBOL(ldlm_cli_cancel_unused_resource);
-
-struct ldlm_cli_cancel_arg {
-	int     lc_flags;
-	void   *lc_opaque;
-};
-
-static int ldlm_cli_hash_cancel_unused(struct cfs_hash *hs,
-				       struct cfs_hash_bd *bd,
-				       struct hlist_node *hnode, void *arg)
-{
-	struct ldlm_resource	   *res = cfs_hash_object(hs, hnode);
-	struct ldlm_cli_cancel_arg     *lc = arg;
-
-	ldlm_cli_cancel_unused_resource(ldlm_res_to_ns(res), &res->lr_name,
-					NULL, LCK_MINMODE,
-					lc->lc_flags, lc->lc_opaque);
-	/* must return 0 for hash iteration */
-	return 0;
-}
-
-/**
- * Cancel all locks on a namespace (or a specific resource, if given)
- * that have 0 readers/writers.
- *
- * If flags & LCF_LOCAL, throw the locks away without trying
- * to notify the server.
- */
-int ldlm_cli_cancel_unused(struct ldlm_namespace *ns,
-			   const struct ldlm_res_id *res_id,
-			   enum ldlm_cancel_flags flags, void *opaque)
-{
-	struct ldlm_cli_cancel_arg arg = {
-		.lc_flags       = flags,
-		.lc_opaque      = opaque,
-	};
-
-	if (!ns)
-		return ELDLM_OK;
-
-	if (res_id) {
-		return ldlm_cli_cancel_unused_resource(ns, res_id, NULL,
-						       LCK_MINMODE, flags,
-						       opaque);
-	} else {
-		cfs_hash_for_each_nolock(ns->ns_rs_hash,
-					 ldlm_cli_hash_cancel_unused, &arg, 0);
-		return ELDLM_OK;
-	}
-}
-EXPORT_SYMBOL(ldlm_cli_cancel_unused);
-
-/* Lock iterators. */
-
-static int ldlm_resource_foreach(struct ldlm_resource *res,
-				 ldlm_iterator_t iter, void *closure)
-{
-	struct ldlm_lock *tmp;
-	struct ldlm_lock *lock;
-	int rc = LDLM_ITER_CONTINUE;
-
-	if (!res)
-		return LDLM_ITER_CONTINUE;
-
-	lock_res(res);
-	list_for_each_entry_safe(lock, tmp, &res->lr_granted, l_res_link) {
-		if (iter(lock, closure) == LDLM_ITER_STOP) {
-			rc = LDLM_ITER_STOP;
-			goto out;
-		}
-	}
-
-	list_for_each_entry_safe(lock, tmp, &res->lr_waiting, l_res_link) {
-		if (iter(lock, closure) == LDLM_ITER_STOP) {
-			rc = LDLM_ITER_STOP;
-			goto out;
-		}
-	}
- out:
-	unlock_res(res);
-	return rc;
-}
-
-struct iter_helper_data {
-	ldlm_iterator_t iter;
-	void *closure;
-};
-
-static int ldlm_iter_helper(struct ldlm_lock *lock, void *closure)
-{
-	struct iter_helper_data *helper = closure;
-
-	return helper->iter(lock, helper->closure);
-}
-
-static int ldlm_res_iter_helper(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-				struct hlist_node *hnode, void *arg)
-
-{
-	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
-
-	return ldlm_resource_foreach(res, ldlm_iter_helper, arg) ==
-	       LDLM_ITER_STOP;
-}
-
-static void ldlm_namespace_foreach(struct ldlm_namespace *ns,
-				   ldlm_iterator_t iter, void *closure)
-
-{
-	struct iter_helper_data helper = {
-		.iter		= iter,
-		.closure	= closure,
-	};
-
-	cfs_hash_for_each_nolock(ns->ns_rs_hash,
-				 ldlm_res_iter_helper, &helper, 0);
-}
-
-/* non-blocking function to manipulate a lock whose cb_data is being put away.
- * return  0:  find no resource
- *       > 0:  must be LDLM_ITER_STOP/LDLM_ITER_CONTINUE.
- *       < 0:  errors
- */
-int ldlm_resource_iterate(struct ldlm_namespace *ns,
-			  const struct ldlm_res_id *res_id,
-			  ldlm_iterator_t iter, void *data)
-{
-	struct ldlm_resource *res;
-	int rc;
-
-	LASSERTF(ns, "must pass in namespace\n");
-
-	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
-	if (IS_ERR(res))
-		return 0;
-
-	LDLM_RESOURCE_ADDREF(res);
-	rc = ldlm_resource_foreach(res, iter, data);
-	LDLM_RESOURCE_DELREF(res);
-	ldlm_resource_putref(res);
-	return rc;
-}
-EXPORT_SYMBOL(ldlm_resource_iterate);
-
-/* Lock replay */
-
-static int ldlm_chain_lock_for_replay(struct ldlm_lock *lock, void *closure)
-{
-	struct list_head *list = closure;
-
-	/* we use l_pending_chain here, because it's unused on clients. */
-	LASSERTF(list_empty(&lock->l_pending_chain),
-		 "lock %p next %p prev %p\n",
-		 lock, &lock->l_pending_chain.next,
-		 &lock->l_pending_chain.prev);
-	/* bug 9573: don't replay locks left after eviction, or
-	 * bug 17614: locks being actively cancelled. Get a reference
-	 * on a lock so that it does not disappear under us (e.g. due to cancel)
-	 */
-	if (!(lock->l_flags & (LDLM_FL_FAILED | LDLM_FL_BL_DONE))) {
-		list_add(&lock->l_pending_chain, list);
-		LDLM_LOCK_GET(lock);
-	}
-
-	return LDLM_ITER_CONTINUE;
-}
-
-static int replay_lock_interpret(const struct lu_env *env,
-				 struct ptlrpc_request *req,
-				 struct ldlm_async_args *aa, int rc)
-{
-	struct ldlm_lock     *lock;
-	struct ldlm_reply    *reply;
-	struct obd_export    *exp;
-
-	atomic_dec(&req->rq_import->imp_replay_inflight);
-	if (rc != ELDLM_OK)
-		goto out;
-
-	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
-	if (!reply) {
-		rc = -EPROTO;
-		goto out;
-	}
-
-	lock = ldlm_handle2lock(&aa->lock_handle);
-	if (!lock) {
-		CERROR("received replay ack for unknown local cookie %#llx remote cookie %#llx from server %s id %s\n",
-		       aa->lock_handle.cookie, reply->lock_handle.cookie,
-		       req->rq_export->exp_client_uuid.uuid,
-		       libcfs_id2str(req->rq_peer));
-		rc = -ESTALE;
-		goto out;
-	}
-
-	/* Key change rehash lock in per-export hash with new key */
-	exp = req->rq_export;
-	lock->l_remote_handle = reply->lock_handle;
-
-	LDLM_DEBUG(lock, "replayed lock:");
-	ptlrpc_import_recovery_state_machine(req->rq_import);
-	LDLM_LOCK_PUT(lock);
-out:
-	if (rc != ELDLM_OK)
-		ptlrpc_connect_import(req->rq_import);
-
-	return rc;
-}
-
-static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
-{
-	struct ptlrpc_request *req;
-	struct ldlm_async_args *aa;
-	struct ldlm_request   *body;
-	int flags;
-
-	/* Bug 11974: Do not replay a lock which is actively being canceled */
-	if (ldlm_is_bl_done(lock)) {
-		LDLM_DEBUG(lock, "Not replaying canceled lock:");
-		return 0;
-	}
-
-	/* If this is reply-less callback lock, we cannot replay it, since
-	 * server might have long dropped it, but notification of that event was
-	 * lost by network. (and server granted conflicting lock already)
-	 */
-	if (ldlm_is_cancel_on_block(lock)) {
-		LDLM_DEBUG(lock, "Not replaying reply-less lock:");
-		ldlm_lock_cancel(lock);
-		return 0;
-	}
-
-	/*
-	 * If granted mode matches the requested mode, this lock is granted.
-	 *
-	 * If they differ, but we have a granted mode, then we were granted
-	 * one mode and now want another: ergo, converting.
-	 *
-	 * If we haven't been granted anything and are on a resource list,
-	 * then we're blocked/waiting.
-	 *
-	 * If we haven't been granted anything and we're NOT on a resource list,
-	 * then we haven't got a reply yet and don't have a known disposition.
-	 * This happens whenever a lock enqueue is the request that triggers
-	 * recovery.
-	 */
-	if (lock->l_granted_mode == lock->l_req_mode)
-		flags = LDLM_FL_REPLAY | LDLM_FL_BLOCK_GRANTED;
-	else if (lock->l_granted_mode)
-		flags = LDLM_FL_REPLAY | LDLM_FL_BLOCK_CONV;
-	else if (!list_empty(&lock->l_res_link))
-		flags = LDLM_FL_REPLAY | LDLM_FL_BLOCK_WAIT;
-	else
-		flags = LDLM_FL_REPLAY;
-
-	req = ptlrpc_request_alloc_pack(imp, &RQF_LDLM_ENQUEUE,
-					LUSTRE_DLM_VERSION, LDLM_ENQUEUE);
-	if (!req)
-		return -ENOMEM;
-
-	/* We're part of recovery, so don't wait for it. */
-	req->rq_send_state = LUSTRE_IMP_REPLAY_LOCKS;
-
-	body = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
-	ldlm_lock2desc(lock, &body->lock_desc);
-	body->lock_flags = ldlm_flags_to_wire(flags);
-
-	ldlm_lock2handle(lock, &body->lock_handle[0]);
-	if (lock->l_lvb_len > 0)
-		req_capsule_extend(&req->rq_pill, &RQF_LDLM_ENQUEUE_LVB);
-	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER,
-			     lock->l_lvb_len);
-	ptlrpc_request_set_replen(req);
-	/* notify the server we've replayed all requests.
-	 * also, we mark the request to be put on a dedicated
-	 * queue to be processed after all request replayes.
-	 * bug 6063
-	 */
-	lustre_msg_set_flags(req->rq_reqmsg, MSG_REQ_REPLAY_DONE);
-
-	LDLM_DEBUG(lock, "replaying lock:");
-
-	atomic_inc(&req->rq_import->imp_replay_inflight);
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
-	aa->lock_handle = body->lock_handle[0];
-	req->rq_interpret_reply = (ptlrpc_interpterer_t)replay_lock_interpret;
-	ptlrpcd_add_req(req);
-
-	return 0;
-}
-
-/**
- * Cancel as many unused locks as possible before replay. since we are
- * in recovery, we can't wait for any outstanding RPCs to send any RPC
- * to the server.
- *
- * Called only in recovery before replaying locks. there is no need to
- * replay locks that are unused. since the clients may hold thousands of
- * cached unused locks, dropping the unused locks can greatly reduce the
- * load on the servers at recovery time.
- */
-static void ldlm_cancel_unused_locks_for_replay(struct ldlm_namespace *ns)
-{
-	int canceled;
-	LIST_HEAD(cancels);
-
-	CDEBUG(D_DLMTRACE,
-	       "Dropping as many unused locks as possible before replay for namespace %s (%d)\n",
-	       ldlm_ns_name(ns), ns->ns_nr_unused);
-
-	/* We don't need to care whether or not LRU resize is enabled
-	 * because the LDLM_LRU_FLAG_NO_WAIT policy doesn't use the
-	 * count parameter
-	 */
-	canceled = ldlm_cancel_lru_local(ns, &cancels, ns->ns_nr_unused, 0,
-					 LCF_LOCAL, LDLM_LRU_FLAG_NO_WAIT);
-
-	CDEBUG(D_DLMTRACE, "Canceled %d unused locks from namespace %s\n",
-	       canceled, ldlm_ns_name(ns));
-}
-
-int ldlm_replay_locks(struct obd_import *imp)
-{
-	struct ldlm_namespace *ns = imp->imp_obd->obd_namespace;
-	LIST_HEAD(list);
-	struct ldlm_lock *lock, *next;
-	int rc = 0;
-
-	LASSERT(atomic_read(&imp->imp_replay_inflight) == 0);
-
-	/* don't replay locks if import failed recovery */
-	if (imp->imp_vbr_failed)
-		return 0;
-
-	/* ensure this doesn't fall to 0 before all have been queued */
-	atomic_inc(&imp->imp_replay_inflight);
-
-	if (ldlm_cancel_unused_locks_before_replay)
-		ldlm_cancel_unused_locks_for_replay(ns);
-
-	ldlm_namespace_foreach(ns, ldlm_chain_lock_for_replay, &list);
-
-	list_for_each_entry_safe(lock, next, &list, l_pending_chain) {
-		list_del_init(&lock->l_pending_chain);
-		if (rc) {
-			LDLM_LOCK_RELEASE(lock);
-			continue; /* or try to do the rest? */
-		}
-		rc = replay_one_lock(imp, lock);
-		LDLM_LOCK_RELEASE(lock);
-	}
-
-	atomic_dec(&imp->imp_replay_inflight);
-
-	return rc;
-}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
deleted file mode 100644
index 3946d62ff009..000000000000
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ /dev/null
@@ -1,1318 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2010, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/ldlm/ldlm_resource.c
- *
- * Author: Phil Schwan <phil@clusterfs.com>
- * Author: Peter Braam <braam@clusterfs.com>
- */
-
-#define DEBUG_SUBSYSTEM S_LDLM
-#include <lustre_dlm.h>
-#include <lustre_fid.h>
-#include <obd_class.h>
-#include "ldlm_internal.h"
-#include <linux/libcfs/libcfs_hash.h>
-
-struct kmem_cache *ldlm_resource_slab, *ldlm_lock_slab;
-
-int ldlm_srv_namespace_nr;
-int ldlm_cli_namespace_nr;
-
-struct mutex ldlm_srv_namespace_lock;
-LIST_HEAD(ldlm_srv_namespace_list);
-
-struct mutex ldlm_cli_namespace_lock;
-/* Client Namespaces that have active resources in them.
- * Once all resources go away, ldlm_poold moves such namespaces to the
- * inactive list
- */
-LIST_HEAD(ldlm_cli_active_namespace_list);
-/* Client namespaces that don't have any locks in them */
-static LIST_HEAD(ldlm_cli_inactive_namespace_list);
-
-static struct dentry *ldlm_debugfs_dir;
-static struct dentry *ldlm_ns_debugfs_dir;
-struct dentry *ldlm_svc_debugfs_dir;
-
-/* during debug dump certain amount of granted locks for one resource to avoid
- * DDOS.
- */
-static unsigned int ldlm_dump_granted_max = 256;
-
-static ssize_t
-lprocfs_wr_dump_ns(struct file *file, const char __user *buffer,
-		   size_t count, loff_t *off)
-{
-	ldlm_dump_all_namespaces(LDLM_NAMESPACE_SERVER, D_DLMTRACE);
-	ldlm_dump_all_namespaces(LDLM_NAMESPACE_CLIENT, D_DLMTRACE);
-	return count;
-}
-
-LPROC_SEQ_FOPS_WR_ONLY(ldlm, dump_ns);
-
-static int ldlm_rw_uint_seq_show(struct seq_file *m, void *v)
-{
-	seq_printf(m, "%u\n", *(unsigned int *)m->private);
-	return 0;
-}
-
-static ssize_t
-ldlm_rw_uint_seq_write(struct file *file, const char __user *buffer,
-		       size_t count, loff_t *off)
-{
-	struct seq_file *seq = file->private_data;
-
-	if (count == 0)
-		return 0;
-	return kstrtouint_from_user(buffer, count, 0,
-				    (unsigned int *)seq->private);
-}
-
-LPROC_SEQ_FOPS(ldlm_rw_uint);
-
-static struct lprocfs_vars ldlm_debugfs_list[] = {
-	{ "dump_namespaces", &ldlm_dump_ns_fops, NULL, 0222 },
-	{ "dump_granted_max", &ldlm_rw_uint_fops, &ldlm_dump_granted_max },
-	{ NULL }
-};
-
-void ldlm_debugfs_setup(void)
-{
-	ldlm_debugfs_dir = debugfs_create_dir(OBD_LDLM_DEVICENAME,
-					      debugfs_lustre_root);
-
-	ldlm_ns_debugfs_dir = debugfs_create_dir("namespaces",
-						 ldlm_debugfs_dir);
-
-	ldlm_svc_debugfs_dir = debugfs_create_dir("services", ldlm_debugfs_dir);
-
-	ldebugfs_add_vars(ldlm_debugfs_dir, ldlm_debugfs_list, NULL);
-}
-
-void ldlm_debugfs_cleanup(void)
-{
-	debugfs_remove_recursive(ldlm_svc_debugfs_dir);
-	debugfs_remove_recursive(ldlm_ns_debugfs_dir);
-	debugfs_remove_recursive(ldlm_debugfs_dir);
-}
-
-static ssize_t resource_count_show(struct kobject *kobj, struct attribute *attr,
-				   char *buf)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-	__u64		  res = 0;
-	struct cfs_hash_bd	  bd;
-	int		    i;
-
-	/* result is not strictly consistent */
-	cfs_hash_for_each_bucket(ns->ns_rs_hash, &bd, i)
-		res += cfs_hash_bd_count_get(&bd);
-	return sprintf(buf, "%lld\n", res);
-}
-LUSTRE_RO_ATTR(resource_count);
-
-static ssize_t lock_count_show(struct kobject *kobj, struct attribute *attr,
-			       char *buf)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-	__u64		  locks;
-
-	locks = lprocfs_stats_collector(ns->ns_stats, LDLM_NSS_LOCKS,
-					LPROCFS_FIELDS_FLAGS_SUM);
-	return sprintf(buf, "%lld\n", locks);
-}
-LUSTRE_RO_ATTR(lock_count);
-
-static ssize_t lock_unused_count_show(struct kobject *kobj,
-				      struct attribute *attr,
-				      char *buf)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-
-	return sprintf(buf, "%d\n", ns->ns_nr_unused);
-}
-LUSTRE_RO_ATTR(lock_unused_count);
-
-static ssize_t lru_size_show(struct kobject *kobj, struct attribute *attr,
-			     char *buf)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-	__u32 *nr = &ns->ns_max_unused;
-
-	if (ns_connect_lru_resize(ns))
-		nr = &ns->ns_nr_unused;
-	return sprintf(buf, "%u\n", *nr);
-}
-
-static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
-			      const char *buffer, size_t count)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-	unsigned long tmp;
-	int lru_resize;
-	int err;
-
-	if (strncmp(buffer, "clear", 5) == 0) {
-		CDEBUG(D_DLMTRACE,
-		       "dropping all unused locks from namespace %s\n",
-		       ldlm_ns_name(ns));
-		if (ns_connect_lru_resize(ns)) {
-			int canceled, unused  = ns->ns_nr_unused;
-
-			/* Try to cancel all @ns_nr_unused locks. */
-			canceled = ldlm_cancel_lru(ns, unused, 0,
-						   LDLM_LRU_FLAG_PASSED);
-			if (canceled < unused) {
-				CDEBUG(D_DLMTRACE,
-				       "not all requested locks are canceled, requested: %d, canceled: %d\n",
-				       unused,
-				       canceled);
-				return -EINVAL;
-			}
-		} else {
-			tmp = ns->ns_max_unused;
-			ns->ns_max_unused = 0;
-			ldlm_cancel_lru(ns, 0, 0, LDLM_LRU_FLAG_PASSED);
-			ns->ns_max_unused = tmp;
-		}
-		return count;
-	}
-
-	err = kstrtoul(buffer, 10, &tmp);
-	if (err != 0) {
-		CERROR("lru_size: invalid value written\n");
-		return -EINVAL;
-	}
-	lru_resize = (tmp == 0);
-
-	if (ns_connect_lru_resize(ns)) {
-		if (!lru_resize)
-			ns->ns_max_unused = (unsigned int)tmp;
-
-		if (tmp > ns->ns_nr_unused)
-			tmp = ns->ns_nr_unused;
-		tmp = ns->ns_nr_unused - tmp;
-
-		CDEBUG(D_DLMTRACE,
-		       "changing namespace %s unused locks from %u to %u\n",
-		       ldlm_ns_name(ns), ns->ns_nr_unused,
-		       (unsigned int)tmp);
-		ldlm_cancel_lru(ns, tmp, LCF_ASYNC, LDLM_LRU_FLAG_PASSED);
-
-		if (!lru_resize) {
-			CDEBUG(D_DLMTRACE,
-			       "disable lru_resize for namespace %s\n",
-			       ldlm_ns_name(ns));
-			ns->ns_connect_flags &= ~OBD_CONNECT_LRU_RESIZE;
-		}
-	} else {
-		CDEBUG(D_DLMTRACE,
-		       "changing namespace %s max_unused from %u to %u\n",
-		       ldlm_ns_name(ns), ns->ns_max_unused,
-		       (unsigned int)tmp);
-		ns->ns_max_unused = (unsigned int)tmp;
-		ldlm_cancel_lru(ns, 0, LCF_ASYNC, LDLM_LRU_FLAG_PASSED);
-
-		/* Make sure that LRU resize was originally supported before
-		 * turning it on here.
-		 */
-		if (lru_resize &&
-		    (ns->ns_orig_connect_flags & OBD_CONNECT_LRU_RESIZE)) {
-			CDEBUG(D_DLMTRACE,
-			       "enable lru_resize for namespace %s\n",
-			       ldlm_ns_name(ns));
-			ns->ns_connect_flags |= OBD_CONNECT_LRU_RESIZE;
-		}
-	}
-
-	return count;
-}
-LUSTRE_RW_ATTR(lru_size);
-
-static ssize_t lru_max_age_show(struct kobject *kobj, struct attribute *attr,
-				char *buf)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-
-	return sprintf(buf, "%u\n", ns->ns_max_age);
-}
-
-static ssize_t lru_max_age_store(struct kobject *kobj, struct attribute *attr,
-				 const char *buffer, size_t count)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-	unsigned long tmp;
-	int err;
-
-	err = kstrtoul(buffer, 10, &tmp);
-	if (err != 0)
-		return -EINVAL;
-
-	ns->ns_max_age = tmp;
-
-	return count;
-}
-LUSTRE_RW_ATTR(lru_max_age);
-
-static ssize_t early_lock_cancel_show(struct kobject *kobj,
-				      struct attribute *attr,
-				      char *buf)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-
-	return sprintf(buf, "%d\n", ns_connect_cancelset(ns));
-}
-
-static ssize_t early_lock_cancel_store(struct kobject *kobj,
-				       struct attribute *attr,
-				       const char *buffer,
-				       size_t count)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-	unsigned long supp = -1;
-	int rc;
-
-	rc = kstrtoul(buffer, 10, &supp);
-	if (rc < 0)
-		return rc;
-
-	if (supp == 0)
-		ns->ns_connect_flags &= ~OBD_CONNECT_CANCELSET;
-	else if (ns->ns_orig_connect_flags & OBD_CONNECT_CANCELSET)
-		ns->ns_connect_flags |= OBD_CONNECT_CANCELSET;
-	return count;
-}
-LUSTRE_RW_ATTR(early_lock_cancel);
-
-/* These are for namespaces in /sys/fs/lustre/ldlm/namespaces/ */
-static struct attribute *ldlm_ns_attrs[] = {
-	&lustre_attr_resource_count.attr,
-	&lustre_attr_lock_count.attr,
-	&lustre_attr_lock_unused_count.attr,
-	&lustre_attr_lru_size.attr,
-	&lustre_attr_lru_max_age.attr,
-	&lustre_attr_early_lock_cancel.attr,
-	NULL,
-};
-
-static void ldlm_ns_release(struct kobject *kobj)
-{
-	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
-						 ns_kobj);
-	complete(&ns->ns_kobj_unregister);
-}
-
-static struct kobj_type ldlm_ns_ktype = {
-	.default_attrs  = ldlm_ns_attrs,
-	.sysfs_ops      = &lustre_sysfs_ops,
-	.release        = ldlm_ns_release,
-};
-
-static void ldlm_namespace_debugfs_unregister(struct ldlm_namespace *ns)
-{
-	debugfs_remove_recursive(ns->ns_debugfs_entry);
-
-	if (ns->ns_stats)
-		lprocfs_free_stats(&ns->ns_stats);
-}
-
-static void ldlm_namespace_sysfs_unregister(struct ldlm_namespace *ns)
-{
-	kobject_put(&ns->ns_kobj);
-	wait_for_completion(&ns->ns_kobj_unregister);
-}
-
-static int ldlm_namespace_sysfs_register(struct ldlm_namespace *ns)
-{
-	int err;
-
-	ns->ns_kobj.kset = ldlm_ns_kset;
-	init_completion(&ns->ns_kobj_unregister);
-	err = kobject_init_and_add(&ns->ns_kobj, &ldlm_ns_ktype, NULL,
-				   "%s", ldlm_ns_name(ns));
-
-	ns->ns_stats = lprocfs_alloc_stats(LDLM_NSS_LAST, 0);
-	if (!ns->ns_stats) {
-		kobject_put(&ns->ns_kobj);
-		return -ENOMEM;
-	}
-
-	lprocfs_counter_init(ns->ns_stats, LDLM_NSS_LOCKS,
-			     LPROCFS_CNTR_AVGMINMAX, "locks", "locks");
-
-	return err;
-}
-
-static int ldlm_namespace_debugfs_register(struct ldlm_namespace *ns)
-{
-	struct dentry *ns_entry;
-
-	if (!IS_ERR_OR_NULL(ns->ns_debugfs_entry)) {
-		ns_entry = ns->ns_debugfs_entry;
-	} else {
-		ns_entry = debugfs_create_dir(ldlm_ns_name(ns),
-					      ldlm_ns_debugfs_dir);
-		if (!ns_entry)
-			return -ENOMEM;
-		ns->ns_debugfs_entry = ns_entry;
-	}
-
-	return 0;
-}
-
-#undef MAX_STRING_SIZE
-
-static struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
-{
-	LASSERT(res);
-	LASSERT(res != LP_POISON);
-	atomic_inc(&res->lr_refcount);
-	CDEBUG(D_INFO, "getref res: %p count: %d\n", res,
-	       atomic_read(&res->lr_refcount));
-	return res;
-}
-
-static unsigned int ldlm_res_hop_hash(struct cfs_hash *hs,
-				      const void *key, unsigned int mask)
-{
-	const struct ldlm_res_id     *id  = key;
-	unsigned int		val = 0;
-	unsigned int		i;
-
-	for (i = 0; i < RES_NAME_SIZE; i++)
-		val += id->name[i];
-	return val & mask;
-}
-
-static unsigned int ldlm_res_hop_fid_hash(struct cfs_hash *hs,
-					  const void *key, unsigned int mask)
-{
-	const struct ldlm_res_id *id = key;
-	struct lu_fid       fid;
-	__u32	       hash;
-	__u32	       val;
-
-	fid.f_seq = id->name[LUSTRE_RES_ID_SEQ_OFF];
-	fid.f_oid = (__u32)id->name[LUSTRE_RES_ID_VER_OID_OFF];
-	fid.f_ver = (__u32)(id->name[LUSTRE_RES_ID_VER_OID_OFF] >> 32);
-
-	hash = fid_flatten32(&fid);
-	hash += (hash >> 4) + (hash << 12); /* mixing oid and seq */
-	if (id->name[LUSTRE_RES_ID_HSH_OFF] != 0) {
-		val = id->name[LUSTRE_RES_ID_HSH_OFF];
-		hash += (val >> 5) + (val << 11);
-	} else {
-		val = fid_oid(&fid);
-	}
-	hash = hash_long(hash, hs->hs_bkt_bits);
-	/* give me another random factor */
-	hash -= hash_long((unsigned long)hs, val % 11 + 3);
-
-	hash <<= hs->hs_cur_bits - hs->hs_bkt_bits;
-	hash |= ldlm_res_hop_hash(hs, key, CFS_HASH_NBKT(hs) - 1);
-
-	return hash & mask;
-}
-
-static void *ldlm_res_hop_key(struct hlist_node *hnode)
-{
-	struct ldlm_resource   *res;
-
-	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-	return &res->lr_name;
-}
-
-static int ldlm_res_hop_keycmp(const void *key, struct hlist_node *hnode)
-{
-	struct ldlm_resource   *res;
-
-	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-	return ldlm_res_eq((const struct ldlm_res_id *)key,
-			   (const struct ldlm_res_id *)&res->lr_name);
-}
-
-static void *ldlm_res_hop_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct ldlm_resource, lr_hash);
-}
-
-static void ldlm_res_hop_get_locked(struct cfs_hash *hs,
-				    struct hlist_node *hnode)
-{
-	struct ldlm_resource *res;
-
-	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-	ldlm_resource_getref(res);
-}
-
-static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-	struct ldlm_resource *res;
-
-	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-	ldlm_resource_putref(res);
-}
-
-static struct cfs_hash_ops ldlm_ns_hash_ops = {
-	.hs_hash	= ldlm_res_hop_hash,
-	.hs_key		= ldlm_res_hop_key,
-	.hs_keycmp      = ldlm_res_hop_keycmp,
-	.hs_keycpy      = NULL,
-	.hs_object      = ldlm_res_hop_object,
-	.hs_get		= ldlm_res_hop_get_locked,
-	.hs_put		= ldlm_res_hop_put
-};
-
-static struct cfs_hash_ops ldlm_ns_fid_hash_ops = {
-	.hs_hash	= ldlm_res_hop_fid_hash,
-	.hs_key		= ldlm_res_hop_key,
-	.hs_keycmp      = ldlm_res_hop_keycmp,
-	.hs_keycpy      = NULL,
-	.hs_object      = ldlm_res_hop_object,
-	.hs_get		= ldlm_res_hop_get_locked,
-	.hs_put		= ldlm_res_hop_put
-};
-
-struct ldlm_ns_hash_def {
-	enum ldlm_ns_type nsd_type;
-	/** hash bucket bits */
-	unsigned int	nsd_bkt_bits;
-	/** hash bits */
-	unsigned int	nsd_all_bits;
-	/** hash operations */
-	struct cfs_hash_ops *nsd_hops;
-};
-
-static struct ldlm_ns_hash_def ldlm_ns_hash_defs[] = {
-	{
-		.nsd_type       = LDLM_NS_TYPE_MDC,
-		.nsd_bkt_bits   = 11,
-		.nsd_all_bits   = 16,
-		.nsd_hops       = &ldlm_ns_fid_hash_ops,
-	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_MDT,
-		.nsd_bkt_bits   = 14,
-		.nsd_all_bits   = 21,
-		.nsd_hops       = &ldlm_ns_fid_hash_ops,
-	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_OSC,
-		.nsd_bkt_bits   = 8,
-		.nsd_all_bits   = 12,
-		.nsd_hops       = &ldlm_ns_hash_ops,
-	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_OST,
-		.nsd_bkt_bits   = 11,
-		.nsd_all_bits   = 17,
-		.nsd_hops       = &ldlm_ns_hash_ops,
-	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_MGC,
-		.nsd_bkt_bits   = 4,
-		.nsd_all_bits   = 4,
-		.nsd_hops       = &ldlm_ns_hash_ops,
-	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_MGT,
-		.nsd_bkt_bits   = 4,
-		.nsd_all_bits   = 4,
-		.nsd_hops       = &ldlm_ns_hash_ops,
-	},
-	{
-		.nsd_type       = LDLM_NS_TYPE_UNKNOWN,
-	},
-};
-
-/** Register \a ns in the list of namespaces */
-static void ldlm_namespace_register(struct ldlm_namespace *ns,
-				    enum ldlm_side client)
-{
-	mutex_lock(ldlm_namespace_lock(client));
-	LASSERT(list_empty(&ns->ns_list_chain));
-	list_add(&ns->ns_list_chain, &ldlm_cli_inactive_namespace_list);
-	ldlm_namespace_nr_inc(client);
-	mutex_unlock(ldlm_namespace_lock(client));
-}
-
-/**
- * Create and initialize new empty namespace.
- */
-struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
-					  enum ldlm_side client,
-					  enum ldlm_appetite apt,
-					  enum ldlm_ns_type ns_type)
-{
-	struct ldlm_namespace *ns = NULL;
-	struct ldlm_ns_bucket *nsb;
-	struct ldlm_ns_hash_def    *nsd;
-	struct cfs_hash_bd	  bd;
-	int		    idx;
-	int		    rc;
-
-	LASSERT(obd);
-
-	rc = ldlm_get_ref();
-	if (rc) {
-		CERROR("ldlm_get_ref failed: %d\n", rc);
-		return NULL;
-	}
-
-	for (idx = 0;; idx++) {
-		nsd = &ldlm_ns_hash_defs[idx];
-		if (nsd->nsd_type == LDLM_NS_TYPE_UNKNOWN) {
-			CERROR("Unknown type %d for ns %s\n", ns_type, name);
-			goto out_ref;
-		}
-
-		if (nsd->nsd_type == ns_type)
-			break;
-	}
-
-	ns = kzalloc(sizeof(*ns), GFP_NOFS);
-	if (!ns)
-		goto out_ref;
-
-	ns->ns_rs_hash = cfs_hash_create(name,
-					 nsd->nsd_all_bits, nsd->nsd_all_bits,
-					 nsd->nsd_bkt_bits, sizeof(*nsb),
-					 CFS_HASH_MIN_THETA,
-					 CFS_HASH_MAX_THETA,
-					 nsd->nsd_hops,
-					 CFS_HASH_DEPTH |
-					 CFS_HASH_BIGNAME |
-					 CFS_HASH_SPIN_BKTLOCK |
-					 CFS_HASH_NO_ITEMREF);
-	if (!ns->ns_rs_hash)
-		goto out_ns;
-
-	cfs_hash_for_each_bucket(ns->ns_rs_hash, &bd, idx) {
-		nsb = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
-		at_init(&nsb->nsb_at_estimate, ldlm_enqueue_min, 0);
-		nsb->nsb_namespace = ns;
-	}
-
-	ns->ns_obd      = obd;
-	ns->ns_appetite = apt;
-	ns->ns_client   = client;
-	ns->ns_name     = kstrdup(name, GFP_KERNEL);
-	if (!ns->ns_name)
-		goto out_hash;
-
-	INIT_LIST_HEAD(&ns->ns_list_chain);
-	INIT_LIST_HEAD(&ns->ns_unused_list);
-	spin_lock_init(&ns->ns_lock);
-	atomic_set(&ns->ns_bref, 0);
-	init_waitqueue_head(&ns->ns_waitq);
-
-	ns->ns_max_parallel_ast   = LDLM_DEFAULT_PARALLEL_AST_LIMIT;
-	ns->ns_nr_unused	  = 0;
-	ns->ns_max_unused	 = LDLM_DEFAULT_LRU_SIZE;
-	ns->ns_max_age	    = LDLM_DEFAULT_MAX_ALIVE;
-	ns->ns_orig_connect_flags = 0;
-	ns->ns_connect_flags      = 0;
-	ns->ns_stopping	   = 0;
-
-	rc = ldlm_namespace_sysfs_register(ns);
-	if (rc != 0) {
-		CERROR("Can't initialize ns sysfs, rc %d\n", rc);
-		goto out_hash;
-	}
-
-	rc = ldlm_namespace_debugfs_register(ns);
-	if (rc != 0) {
-		CERROR("Can't initialize ns proc, rc %d\n", rc);
-		goto out_sysfs;
-	}
-
-	idx = ldlm_namespace_nr_read(client);
-	rc = ldlm_pool_init(&ns->ns_pool, ns, idx, client);
-	if (rc) {
-		CERROR("Can't initialize lock pool, rc %d\n", rc);
-		goto out_proc;
-	}
-
-	ldlm_namespace_register(ns, client);
-	return ns;
-out_proc:
-	ldlm_namespace_debugfs_unregister(ns);
-out_sysfs:
-	ldlm_namespace_sysfs_unregister(ns);
-	ldlm_namespace_cleanup(ns, 0);
-out_hash:
-	kfree(ns->ns_name);
-	cfs_hash_putref(ns->ns_rs_hash);
-out_ns:
-	kfree(ns);
-out_ref:
-	ldlm_put_ref();
-	return NULL;
-}
-EXPORT_SYMBOL(ldlm_namespace_new);
-
-extern struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
-
-/**
- * Cancel and destroy all locks on a resource.
- *
- * If flags contains FL_LOCAL_ONLY, don't try to tell the server, just
- * clean up.  This is currently only used for recovery, and we make
- * certain assumptions as a result--notably, that we shouldn't cancel
- * locks with refs.
- */
-static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
-			     __u64 flags)
-{
-	int rc = 0;
-	bool local_only = !!(flags & LDLM_FL_LOCAL_ONLY);
-
-	do {
-		struct ldlm_lock *lock = NULL, *tmp;
-		struct lustre_handle lockh;
-
-		/* First, we look for non-cleaned-yet lock
-		 * all cleaned locks are marked by CLEANED flag.
-		 */
-		lock_res(res);
-		list_for_each_entry(tmp, q, l_res_link) {
-			if (ldlm_is_cleaned(tmp))
-				continue;
-
-			lock = tmp;
-			LDLM_LOCK_GET(lock);
-			ldlm_set_cleaned(lock);
-			break;
-		}
-
-		if (!lock) {
-			unlock_res(res);
-			break;
-		}
-
-		/* Set CBPENDING so nothing in the cancellation path
-		 * can match this lock.
-		 */
-		ldlm_set_cbpending(lock);
-		ldlm_set_failed(lock);
-		lock->l_flags |= flags;
-
-		/* ... without sending a CANCEL message for local_only. */
-		if (local_only)
-			ldlm_set_local_only(lock);
-
-		if (local_only && (lock->l_readers || lock->l_writers)) {
-			/* This is a little bit gross, but much better than the
-			 * alternative: pretend that we got a blocking AST from
-			 * the server, so that when the lock is decref'd, it
-			 * will go away ...
-			 */
-			unlock_res(res);
-			LDLM_DEBUG(lock, "setting FL_LOCAL_ONLY");
-			if (lock->l_flags & LDLM_FL_FAIL_LOC) {
-				set_current_state(TASK_UNINTERRUPTIBLE);
-				schedule_timeout(4 * HZ);
-				set_current_state(TASK_RUNNING);
-			}
-			if (lock->l_completion_ast)
-				lock->l_completion_ast(lock, LDLM_FL_FAILED,
-						       NULL);
-			LDLM_LOCK_RELEASE(lock);
-			continue;
-		}
-
-		unlock_res(res);
-		ldlm_lock2handle(lock, &lockh);
-		rc = ldlm_cli_cancel(&lockh, LCF_LOCAL);
-		if (rc)
-			CERROR("ldlm_cli_cancel: %d\n", rc);
-		LDLM_LOCK_RELEASE(lock);
-	} while (1);
-}
-
-static int ldlm_resource_clean(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			       struct hlist_node *hnode, void *arg)
-{
-	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
-	__u64 flags = *(__u64 *)arg;
-
-	cleanup_resource(res, &res->lr_granted, flags);
-	cleanup_resource(res, &res->lr_waiting, flags);
-
-	return 0;
-}
-
-static int ldlm_resource_complain(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-				  struct hlist_node *hnode, void *arg)
-{
-	struct ldlm_resource  *res = cfs_hash_object(hs, hnode);
-
-	lock_res(res);
-	CERROR("%s: namespace resource " DLDLMRES
-	       " (%p) refcount nonzero (%d) after lock cleanup; forcing cleanup.\n",
-	       ldlm_ns_name(ldlm_res_to_ns(res)), PLDLMRES(res), res,
-	       atomic_read(&res->lr_refcount) - 1);
-
-	ldlm_resource_dump(D_ERROR, res);
-	unlock_res(res);
-	return 0;
-}
-
-/**
- * Cancel and destroy all locks in the namespace.
- *
- * Typically used during evictions when server notified client that it was
- * evicted and all of its state needs to be destroyed.
- * Also used during shutdown.
- */
-int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags)
-{
-	if (!ns) {
-		CDEBUG(D_INFO, "NULL ns, skipping cleanup\n");
-		return ELDLM_OK;
-	}
-
-	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_clean,
-				 &flags, 0);
-	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_complain,
-				 NULL, 0);
-	return ELDLM_OK;
-}
-EXPORT_SYMBOL(ldlm_namespace_cleanup);
-
-/**
- * Attempts to free namespace.
- *
- * Only used when namespace goes away, like during an unmount.
- */
-static int __ldlm_namespace_free(struct ldlm_namespace *ns, int force)
-{
-	/* At shutdown time, don't call the cancellation callback */
-	ldlm_namespace_cleanup(ns, force ? LDLM_FL_LOCAL_ONLY : 0);
-
-	if (atomic_read(&ns->ns_bref) > 0) {
-		int rc;
-
-		CDEBUG(D_DLMTRACE,
-		       "dlm namespace %s free waiting on refcount %d\n",
-		       ldlm_ns_name(ns), atomic_read(&ns->ns_bref));
-force_wait:
-		if (force)
-			rc = wait_event_idle_timeout(ns->ns_waitq,
-						     atomic_read(&ns->ns_bref) == 0,
-						     obd_timeout * HZ / 4) ? 0 : -ETIMEDOUT;
-		else
-			rc = l_wait_event_abortable(ns->ns_waitq,
-						    atomic_read(&ns->ns_bref) == 0);
-
-		/* Forced cleanups should be able to reclaim all references,
-		 * so it's safe to wait forever... we can't leak locks...
-		 */
-		if (force && rc == -ETIMEDOUT) {
-			LCONSOLE_ERROR("Forced cleanup waiting for %s namespace with %d resources in use, (rc=%d)\n",
-				       ldlm_ns_name(ns),
-				       atomic_read(&ns->ns_bref), rc);
-			goto force_wait;
-		}
-
-		if (atomic_read(&ns->ns_bref)) {
-			LCONSOLE_ERROR("Cleanup waiting for %s namespace with %d resources in use, (rc=%d)\n",
-				       ldlm_ns_name(ns),
-				       atomic_read(&ns->ns_bref), rc);
-			return ELDLM_NAMESPACE_EXISTS;
-		}
-		CDEBUG(D_DLMTRACE, "dlm namespace %s free done waiting\n",
-		       ldlm_ns_name(ns));
-	}
-
-	return ELDLM_OK;
-}
-
-/**
- * Performs various cleanups for passed \a ns to make it drop refc and be
- * ready for freeing. Waits for refc == 0.
- *
- * The following is done:
- * (0) Unregister \a ns from its list to make inaccessible for potential
- * users like pools thread and others;
- * (1) Clear all locks in \a ns.
- */
-void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
-			       struct obd_import *imp,
-			       int force)
-{
-	int rc;
-
-	if (!ns)
-		return;
-
-	spin_lock(&ns->ns_lock);
-	ns->ns_stopping = 1;
-	spin_unlock(&ns->ns_lock);
-
-	/*
-	 * Can fail with -EINTR when force == 0 in which case try harder.
-	 */
-	rc = __ldlm_namespace_free(ns, force);
-	if (rc != ELDLM_OK) {
-		if (imp) {
-			ptlrpc_disconnect_import(imp, 0);
-			ptlrpc_invalidate_import(imp);
-		}
-
-		/*
-		 * With all requests dropped and the import inactive
-		 * we are guaranteed all reference will be dropped.
-		 */
-		rc = __ldlm_namespace_free(ns, 1);
-		LASSERT(rc == 0);
-	}
-}
-
-/** Unregister \a ns from the list of namespaces. */
-static void ldlm_namespace_unregister(struct ldlm_namespace *ns,
-				      enum ldlm_side client)
-{
-	mutex_lock(ldlm_namespace_lock(client));
-	LASSERT(!list_empty(&ns->ns_list_chain));
-	/* Some asserts and possibly other parts of the code are still
-	 * using list_empty(&ns->ns_list_chain). This is why it is
-	 * important to use list_del_init() here.
-	 */
-	list_del_init(&ns->ns_list_chain);
-	ldlm_namespace_nr_dec(client);
-	mutex_unlock(ldlm_namespace_lock(client));
-}
-
-/**
- * Performs freeing memory structures related to \a ns. This is only done
- * when ldlm_namespce_free_prior() successfully removed all resources
- * referencing \a ns and its refc == 0.
- */
-void ldlm_namespace_free_post(struct ldlm_namespace *ns)
-{
-	if (!ns)
-		return;
-
-	/* Make sure that nobody can find this ns in its list. */
-	ldlm_namespace_unregister(ns, ns->ns_client);
-	/* Fini pool _before_ parent proc dir is removed. This is important as
-	 * ldlm_pool_fini() removes own proc dir which is child to @dir.
-	 * Removing it after @dir may cause oops.
-	 */
-	ldlm_pool_fini(&ns->ns_pool);
-
-	ldlm_namespace_debugfs_unregister(ns);
-	ldlm_namespace_sysfs_unregister(ns);
-	cfs_hash_putref(ns->ns_rs_hash);
-	kfree(ns->ns_name);
-	/* Namespace \a ns should be not on list at this time, otherwise
-	 * this will cause issues related to using freed \a ns in poold
-	 * thread.
-	 */
-	LASSERT(list_empty(&ns->ns_list_chain));
-	kfree(ns);
-	ldlm_put_ref();
-}
-
-void ldlm_namespace_get(struct ldlm_namespace *ns)
-{
-	atomic_inc(&ns->ns_bref);
-}
-
-/* This is only for callers that care about refcount */
-static int ldlm_namespace_get_return(struct ldlm_namespace *ns)
-{
-	return atomic_inc_return(&ns->ns_bref);
-}
-
-void ldlm_namespace_put(struct ldlm_namespace *ns)
-{
-	if (atomic_dec_and_lock(&ns->ns_bref, &ns->ns_lock)) {
-		wake_up(&ns->ns_waitq);
-		spin_unlock(&ns->ns_lock);
-	}
-}
-
-/** Should be called with ldlm_namespace_lock(client) taken. */
-void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *ns,
-					  enum ldlm_side client)
-{
-	LASSERT(!list_empty(&ns->ns_list_chain));
-	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
-	list_move_tail(&ns->ns_list_chain, ldlm_namespace_list(client));
-}
-
-/** Should be called with ldlm_namespace_lock(client) taken. */
-void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
-					    enum ldlm_side client)
-{
-	LASSERT(!list_empty(&ns->ns_list_chain));
-	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
-	list_move_tail(&ns->ns_list_chain, &ldlm_cli_inactive_namespace_list);
-}
-
-/** Should be called with ldlm_namespace_lock(client) taken. */
-struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side client)
-{
-	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
-	LASSERT(!list_empty(ldlm_namespace_list(client)));
-	return container_of(ldlm_namespace_list(client)->next,
-		struct ldlm_namespace, ns_list_chain);
-}
-
-/** Create and initialize new resource. */
-static struct ldlm_resource *ldlm_resource_new(void)
-{
-	struct ldlm_resource *res;
-	int idx;
-
-	res = kmem_cache_zalloc(ldlm_resource_slab, GFP_NOFS);
-	if (!res)
-		return NULL;
-
-	INIT_LIST_HEAD(&res->lr_granted);
-	INIT_LIST_HEAD(&res->lr_waiting);
-
-	/* Initialize interval trees for each lock mode. */
-	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
-		res->lr_itree[idx].lit_size = 0;
-		res->lr_itree[idx].lit_mode = 1 << idx;
-		res->lr_itree[idx].lit_root = RB_ROOT_CACHED;
-	}
-
-	atomic_set(&res->lr_refcount, 1);
-	spin_lock_init(&res->lr_lock);
-	lu_ref_init(&res->lr_reference);
-
-	/* The creator of the resource must unlock the mutex after LVB
-	 * initialization.
-	 */
-	mutex_init(&res->lr_lvb_mutex);
-	mutex_lock(&res->lr_lvb_mutex);
-
-	return res;
-}
-
-/**
- * Return a reference to resource with given name, creating it if necessary.
- * Args: namespace with ns_lock unlocked
- * Locks: takes and releases NS hash-lock and res->lr_lock
- * Returns: referenced, unlocked ldlm_resource or NULL
- */
-struct ldlm_resource *
-ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
-		  const struct ldlm_res_id *name, enum ldlm_type type,
-		  int create)
-{
-	struct hlist_node     *hnode;
-	struct ldlm_resource *res = NULL;
-	struct cfs_hash_bd	 bd;
-	__u64		 version;
-	int		      ns_refcount = 0;
-	int rc;
-
-	LASSERT(!parent);
-	LASSERT(ns->ns_rs_hash);
-	LASSERT(name->name[0] != 0);
-
-	cfs_hash_bd_get_and_lock(ns->ns_rs_hash, (void *)name, &bd, 0);
-	hnode = cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
-	if (hnode) {
-		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
-		goto lvbo_init;
-	}
-
-	version = cfs_hash_bd_version_get(&bd);
-	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
-
-	if (create == 0)
-		return ERR_PTR(-ENOENT);
-
-	LASSERTF(type >= LDLM_MIN_TYPE && type < LDLM_MAX_TYPE,
-		 "type: %d\n", type);
-	res = ldlm_resource_new();
-	if (!res)
-		return ERR_PTR(-ENOMEM);
-
-	res->lr_ns_bucket  = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
-	res->lr_name       = *name;
-	res->lr_type       = type;
-
-	cfs_hash_bd_lock(ns->ns_rs_hash, &bd, 1);
-	hnode = (version == cfs_hash_bd_version_get(&bd)) ?  NULL :
-		cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
-
-	if (hnode) {
-		/* Someone won the race and already added the resource. */
-		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
-		/* Clean lu_ref for failed resource. */
-		lu_ref_fini(&res->lr_reference);
-		/* We have taken lr_lvb_mutex. Drop it. */
-		mutex_unlock(&res->lr_lvb_mutex);
-		kmem_cache_free(ldlm_resource_slab, res);
-lvbo_init:
-		res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-		/* Synchronize with regard to resource creation. */
-		if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
-			mutex_lock(&res->lr_lvb_mutex);
-			mutex_unlock(&res->lr_lvb_mutex);
-		}
-
-		if (unlikely(res->lr_lvb_len < 0)) {
-			rc = res->lr_lvb_len;
-			ldlm_resource_putref(res);
-			res = ERR_PTR(rc);
-		}
-		return res;
-	}
-	/* We won! Let's add the resource. */
-	cfs_hash_bd_add_locked(ns->ns_rs_hash, &bd, &res->lr_hash);
-	if (cfs_hash_bd_count_get(&bd) == 1)
-		ns_refcount = ldlm_namespace_get_return(ns);
-
-	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
-	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CREATE_RESOURCE, 2);
-		rc = ns->ns_lvbo->lvbo_init(res);
-		if (rc < 0) {
-			CERROR("%s: lvbo_init failed for resource %#llx:%#llx: rc = %d\n",
-			       ns->ns_obd->obd_name, name->name[0],
-			       name->name[1], rc);
-			res->lr_lvb_len = rc;
-			mutex_unlock(&res->lr_lvb_mutex);
-			ldlm_resource_putref(res);
-			return ERR_PTR(rc);
-		}
-	}
-
-	/* We create resource with locked lr_lvb_mutex. */
-	mutex_unlock(&res->lr_lvb_mutex);
-
-	/* Let's see if we happened to be the very first resource in this
-	 * namespace. If so, and this is a client namespace, we need to move
-	 * the namespace into the active namespaces list to be patrolled by
-	 * the ldlm_poold.
-	 */
-	if (ns_refcount == 1) {
-		mutex_lock(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
-		ldlm_namespace_move_to_active_locked(ns, LDLM_NAMESPACE_CLIENT);
-		mutex_unlock(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
-	}
-
-	return res;
-}
-EXPORT_SYMBOL(ldlm_resource_get);
-
-static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
-					 struct ldlm_resource *res)
-{
-	struct ldlm_ns_bucket *nsb = res->lr_ns_bucket;
-	struct ldlm_namespace *ns = nsb->nsb_namespace;
-
-	if (!list_empty(&res->lr_granted)) {
-		ldlm_resource_dump(D_ERROR, res);
-		LBUG();
-	}
-
-	if (!list_empty(&res->lr_waiting)) {
-		ldlm_resource_dump(D_ERROR, res);
-		LBUG();
-	}
-
-	cfs_hash_bd_del_locked(ns->ns_rs_hash,
-			       bd, &res->lr_hash);
-	lu_ref_fini(&res->lr_reference);
-	cfs_hash_bd_unlock(ns->ns_rs_hash, bd, 1);
-	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_free)
-		ns->ns_lvbo->lvbo_free(res);
-	if (cfs_hash_bd_count_get(bd) == 0)
-		ldlm_namespace_put(ns);
-	kmem_cache_free(ldlm_resource_slab, res);
-}
-
-void ldlm_resource_putref(struct ldlm_resource *res)
-{
-	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
-	struct cfs_hash_bd   bd;
-
-	LASSERT_ATOMIC_GT_LT(&res->lr_refcount, 0, LI_POISON);
-	CDEBUG(D_INFO, "putref res: %p count: %d\n",
-	       res, atomic_read(&res->lr_refcount) - 1);
-
-	cfs_hash_bd_get(ns->ns_rs_hash, &res->lr_name, &bd);
-	if (cfs_hash_bd_dec_and_lock(ns->ns_rs_hash, &bd, &res->lr_refcount))
-		__ldlm_resource_putref_final(&bd, res);
-}
-EXPORT_SYMBOL(ldlm_resource_putref);
-
-/**
- * Add a lock into a given resource into specified lock list.
- */
-void ldlm_resource_add_lock(struct ldlm_resource *res, struct list_head *head,
-			    struct ldlm_lock *lock)
-{
-	check_res_locked(res);
-
-	LDLM_DEBUG(lock, "About to add this lock:");
-
-	if (ldlm_is_destroyed(lock)) {
-		CDEBUG(D_OTHER, "Lock destroyed, not adding to resource\n");
-		return;
-	}
-
-	LASSERT(list_empty(&lock->l_res_link));
-
-	list_add_tail(&lock->l_res_link, head);
-}
-
-void ldlm_resource_unlink_lock(struct ldlm_lock *lock)
-{
-	int type = lock->l_resource->lr_type;
-
-	check_res_locked(lock->l_resource);
-	if (type == LDLM_IBITS || type == LDLM_PLAIN)
-		ldlm_unlink_lock_skiplist(lock);
-	else if (type == LDLM_EXTENT)
-		ldlm_extent_unlink_lock(lock);
-	list_del_init(&lock->l_res_link);
-}
-EXPORT_SYMBOL(ldlm_resource_unlink_lock);
-
-void ldlm_res2desc(struct ldlm_resource *res, struct ldlm_resource_desc *desc)
-{
-	desc->lr_type = res->lr_type;
-	desc->lr_name = res->lr_name;
-}
-
-/**
- * Print information about all locks in all namespaces on this node to debug
- * log.
- */
-void ldlm_dump_all_namespaces(enum ldlm_side client, int level)
-{
-	struct ldlm_namespace *ns;
-
-	if (!((libcfs_debug | D_ERROR) & level))
-		return;
-
-	mutex_lock(ldlm_namespace_lock(client));
-
-	list_for_each_entry(ns, ldlm_namespace_list(client), ns_list_chain)
-		ldlm_namespace_dump(level, ns);
-
-	mutex_unlock(ldlm_namespace_lock(client));
-}
-
-static int ldlm_res_hash_dump(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			      struct hlist_node *hnode, void *arg)
-{
-	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
-	int    level = (int)(unsigned long)arg;
-
-	lock_res(res);
-	ldlm_resource_dump(level, res);
-	unlock_res(res);
-
-	return 0;
-}
-
-/**
- * Print information about all locks in this namespace on this node to debug
- * log.
- */
-void ldlm_namespace_dump(int level, struct ldlm_namespace *ns)
-{
-	if (!((libcfs_debug | D_ERROR) & level))
-		return;
-
-	CDEBUG(level, "--- Namespace: %s (rc: %d, side: client)\n",
-	       ldlm_ns_name(ns), atomic_read(&ns->ns_bref));
-
-	if (time_before(jiffies, ns->ns_next_dump))
-		return;
-
-	cfs_hash_for_each_nolock(ns->ns_rs_hash,
-				 ldlm_res_hash_dump,
-				 (void *)(unsigned long)level, 0);
-	spin_lock(&ns->ns_lock);
-	ns->ns_next_dump = jiffies + 10 * HZ;
-	spin_unlock(&ns->ns_lock);
-}
-
-/**
- * Print information about all locks in this resource to debug log.
- */
-void ldlm_resource_dump(int level, struct ldlm_resource *res)
-{
-	struct ldlm_lock *lock;
-	unsigned int granted = 0;
-
-	BUILD_BUG_ON(RES_NAME_SIZE != 4);
-
-	if (!((libcfs_debug | D_ERROR) & level))
-		return;
-
-	CDEBUG(level, "--- Resource: " DLDLMRES " (%p) refcount = %d\n",
-	       PLDLMRES(res), res, atomic_read(&res->lr_refcount));
-
-	if (!list_empty(&res->lr_granted)) {
-		CDEBUG(level, "Granted locks (in reverse order):\n");
-		list_for_each_entry_reverse(lock, &res->lr_granted,
-					    l_res_link) {
-			LDLM_DEBUG_LIMIT(level, lock, "###");
-			if (!(level & D_CANTMASK) &&
-			    ++granted > ldlm_dump_granted_max) {
-				CDEBUG(level,
-				       "only dump %d granted locks to avoid DDOS.\n",
-				       granted);
-				break;
-			}
-		}
-	}
-	if (!list_empty(&res->lr_waiting)) {
-		CDEBUG(level, "Waiting locks:\n");
-		list_for_each_entry(lock, &res->lr_waiting, l_res_link)
-			LDLM_DEBUG_LIMIT(level, lock, "###");
-	}
-}
-EXPORT_SYMBOL(ldlm_resource_dump);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/Makefile b/drivers/staging/lustre/lustre/ptlrpc/Makefile
index 77f8eabb2e28..aa152e652002 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/Makefile
+++ b/drivers/staging/lustre/lustre/ptlrpc/Makefile
@@ -3,14 +3,14 @@ subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += ptlrpc.o
-LDLM := ../../lustre/ldlm/
 
-ldlm_objs := $(LDLM)l_lock.o $(LDLM)ldlm_lock.o
-ldlm_objs += $(LDLM)ldlm_resource.o $(LDLM)ldlm_lib.o
-ldlm_objs += $(LDLM)ldlm_plain.o $(LDLM)ldlm_extent.o
-ldlm_objs += $(LDLM)ldlm_request.o $(LDLM)ldlm_lockd.o
-ldlm_objs += $(LDLM)ldlm_flock.o $(LDLM)ldlm_inodebits.o
-ldlm_objs += $(LDLM)ldlm_pool.o
+ldlm_objs := l_lock.o ldlm_lock.o
+ldlm_objs += ldlm_resource.o ldlm_lib.o
+ldlm_objs += ldlm_plain.o ldlm_extent.o
+ldlm_objs += ldlm_request.o ldlm_lockd.o
+ldlm_objs += ldlm_flock.o ldlm_inodebits.o
+ldlm_objs += ldlm_pool.o
+
 ptlrpc_objs := client.o recover.o connection.o niobuf.o pack_generic.o
 ptlrpc_objs += events.o ptlrpc_module.o service.o pinger.o
 ptlrpc_objs += llog_net.o llog_client.o import.o ptlrpcd.o
diff --git a/drivers/staging/lustre/lustre/ptlrpc/l_lock.c b/drivers/staging/lustre/lustre/ptlrpc/l_lock.c
new file mode 100644
index 000000000000..296259aa51e6
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/l_lock.c
@@ -0,0 +1,73 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2012, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+
+#include <lustre_dlm.h>
+#include <lustre_lib.h>
+
+/**
+ * Lock a lock and its resource.
+ *
+ * LDLM locking uses resource to serialize access to locks
+ * but there is a case when we change resource of lock upon
+ * enqueue reply. We rely on lock->l_resource = new_res
+ * being an atomic operation.
+ */
+struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
+				__acquires(&lock->l_lock)
+				__acquires(&lock->l_resource->lr_lock)
+{
+	spin_lock(&lock->l_lock);
+
+	lock_res(lock->l_resource);
+
+	ldlm_set_res_locked(lock);
+	return lock->l_resource;
+}
+EXPORT_SYMBOL(lock_res_and_lock);
+
+/**
+ * Unlock a lock and its resource previously locked with lock_res_and_lock
+ */
+void unlock_res_and_lock(struct ldlm_lock *lock)
+		__releases(&lock->l_resource->lr_lock)
+		__releases(&lock->l_lock)
+{
+	/* on server-side resource of lock doesn't change */
+	ldlm_clear_res_locked(lock);
+
+	unlock_res(lock->l_resource);
+	spin_unlock(&lock->l_lock);
+}
+EXPORT_SYMBOL(unlock_res_and_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_extent.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_extent.c
new file mode 100644
index 000000000000..225c023b0bba
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_extent.c
@@ -0,0 +1,206 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2010, 2012, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/ldlm/ldlm_extent.c
+ *
+ * Author: Peter Braam <braam@clusterfs.com>
+ * Author: Phil Schwan <phil@clusterfs.com>
+ */
+
+/**
+ * This file contains implementation of EXTENT lock type
+ *
+ * EXTENT lock type is for locking a contiguous range of values, represented
+ * by 64-bit starting and ending offsets (inclusive). There are several extent
+ * lock modes, some of which may be mutually incompatible. Extent locks are
+ * considered incompatible if their modes are incompatible and their extents
+ * intersect.  See the lock mode compatibility matrix in lustre_dlm.h.
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+#include <lustre_dlm.h>
+#include <obd_support.h>
+#include <obd.h>
+#include <obd_class.h>
+#include <lustre_lib.h>
+#include "ldlm_internal.h"
+#include <linux/interval_tree_generic.h>
+
+#define START(node) ((node)->l_policy_data.l_extent.start)
+#define LAST(node) ((node)->l_policy_data.l_extent.end)
+INTERVAL_TREE_DEFINE(struct ldlm_lock, l_rb, __u64, __subtree_last,
+		     START, LAST, static, extent);
+
+/* When a lock is cancelled by a client, the KMS may undergo change if this
+ * is the "highest lock".  This function returns the new KMS value.
+ * Caller must hold lr_lock already.
+ *
+ * NB: A lock on [x,y] protects a KMS of up to y + 1 bytes!
+ */
+__u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
+{
+	struct ldlm_resource *res = lock->l_resource;
+	struct ldlm_lock *lck;
+	__u64 kms = 0;
+
+	/* don't let another thread in ldlm_extent_shift_kms race in
+	 * just after we finish and take our lock into account in its
+	 * calculation of the kms
+	 */
+	ldlm_set_kms_ignore(lock);
+
+	list_for_each_entry(lck, &res->lr_granted, l_res_link) {
+
+		if (ldlm_is_kms_ignore(lck))
+			continue;
+
+		if (lck->l_policy_data.l_extent.end >= old_kms)
+			return old_kms;
+
+		/* This extent _has_ to be smaller than old_kms (checked above)
+		 * so kms can only ever be smaller or the same as old_kms.
+		 */
+		if (lck->l_policy_data.l_extent.end + 1 > kms)
+			kms = lck->l_policy_data.l_extent.end + 1;
+	}
+	LASSERTF(kms <= old_kms, "kms %llu old_kms %llu\n", kms, old_kms);
+
+	return kms;
+}
+EXPORT_SYMBOL(ldlm_extent_shift_kms);
+
+static inline int lock_mode_to_index(enum ldlm_mode mode)
+{
+	int index;
+
+	LASSERT(mode != 0);
+	LASSERT(is_power_of_2(mode));
+	for (index = -1; mode; index++)
+		mode >>= 1;
+	LASSERT(index < LCK_MODE_NUM);
+	return index;
+}
+
+/** Add newly granted lock into interval tree for the resource. */
+void ldlm_extent_add_lock(struct ldlm_resource *res,
+			  struct ldlm_lock *lock)
+{
+	struct ldlm_interval_tree *tree;
+	int idx;
+
+	LASSERT(lock->l_granted_mode == lock->l_req_mode);
+
+	LASSERT(RB_EMPTY_NODE(&lock->l_rb));
+
+	idx = lock_mode_to_index(lock->l_granted_mode);
+	LASSERT(lock->l_granted_mode == 1 << idx);
+	LASSERT(lock->l_granted_mode == res->lr_itree[idx].lit_mode);
+
+	tree = &res->lr_itree[idx];
+	extent_insert(lock, &tree->lit_root);
+	tree->lit_size++;
+
+	/* even though we use interval tree to manage the extent lock, we also
+	 * add the locks into grant list, for debug purpose, ..
+	 */
+	ldlm_resource_add_lock(res, &res->lr_granted, lock);
+
+	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_GRANT_CHECK)) {
+		struct ldlm_lock *lck;
+
+		list_for_each_entry_reverse(lck, &res->lr_granted,
+					    l_res_link) {
+			if (lck == lock)
+				continue;
+			if (lockmode_compat(lck->l_granted_mode,
+					    lock->l_granted_mode))
+				continue;
+			if (ldlm_extent_overlap(&lck->l_req_extent,
+						&lock->l_req_extent)) {
+				CDEBUG(D_ERROR,
+				       "granting conflicting lock %p %p\n",
+				       lck, lock);
+				ldlm_resource_dump(D_ERROR, res);
+				LBUG();
+			}
+		}
+	}
+}
+
+/** Remove cancelled lock from resource interval tree. */
+void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
+{
+	struct ldlm_resource *res = lock->l_resource;
+	struct ldlm_interval_tree *tree;
+	int idx;
+
+	if (RB_EMPTY_NODE(&lock->l_rb)) /* duplicate unlink */
+		return;
+
+	idx = lock_mode_to_index(lock->l_granted_mode);
+	LASSERT(lock->l_granted_mode == 1 << idx);
+	tree = &res->lr_itree[idx];
+
+	tree->lit_size--;
+	extent_remove(lock, &tree->lit_root);
+}
+
+void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				      union ldlm_policy_data *lpolicy)
+{
+	lpolicy->l_extent.start = wpolicy->l_extent.start;
+	lpolicy->l_extent.end = wpolicy->l_extent.end;
+	lpolicy->l_extent.gid = wpolicy->l_extent.gid;
+}
+
+void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
+				      union ldlm_wire_policy_data *wpolicy)
+{
+	memset(wpolicy, 0, sizeof(*wpolicy));
+	wpolicy->l_extent.start = lpolicy->l_extent.start;
+	wpolicy->l_extent.end = lpolicy->l_extent.end;
+	wpolicy->l_extent.gid = lpolicy->l_extent.gid;
+}
+
+void ldlm_extent_search(struct rb_root_cached *root,
+			__u64 start, __u64 end,
+			bool (*matches)(struct ldlm_lock *lock, void *data),
+			void *data)
+{
+	struct ldlm_lock *lock;
+
+	for (lock = extent_iter_first(root, start, end);
+	     lock;
+	     lock = extent_iter_next(lock, start, end))
+		if (matches(lock, data))
+			break;
+}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_flock.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_flock.c
new file mode 100644
index 000000000000..94f3b1e49896
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_flock.c
@@ -0,0 +1,486 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2003 Hewlett-Packard Development Company LP.
+ * Developed under the sponsorship of the US Government under
+ * Subcontract No. B514193
+ *
+ * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2010, 2012, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+
+/**
+ * This file implements POSIX lock type for Lustre.
+ * Its policy properties are start and end of extent and PID.
+ *
+ * These locks are only done through MDS due to POSIX semantics requiring
+ * e.g. that locks could be only partially released and as such split into
+ * two parts, and also that two adjacent locks from the same process may be
+ * merged into a single wider lock.
+ *
+ * Lock modes are mapped like this:
+ * PR and PW for READ and WRITE locks
+ * NL to request a releasing of a portion of the lock
+ *
+ * These flock locks never timeout.
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+
+#include <lustre_dlm.h>
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_lib.h>
+#include <linux/list.h>
+#include "ldlm_internal.h"
+
+static inline int
+ldlm_same_flock_owner(struct ldlm_lock *lock, struct ldlm_lock *new)
+{
+	return((new->l_policy_data.l_flock.owner ==
+		lock->l_policy_data.l_flock.owner) &&
+	       (new->l_export == lock->l_export));
+}
+
+static inline int
+ldlm_flocks_overlap(struct ldlm_lock *lock, struct ldlm_lock *new)
+{
+	return((new->l_policy_data.l_flock.start <=
+		lock->l_policy_data.l_flock.end) &&
+	       (new->l_policy_data.l_flock.end >=
+		lock->l_policy_data.l_flock.start));
+}
+
+static inline void
+ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode)
+{
+	LDLM_DEBUG(lock, "%s(mode: %d)",
+		   __func__, mode);
+
+	list_del_init(&lock->l_res_link);
+
+	/* client side - set a flag to prevent sending a CANCEL */
+	lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_CBPENDING;
+
+	/* when reaching here, it is under lock_res_and_lock(). Thus,
+	 * need call the nolock version of ldlm_lock_decref_internal
+	 */
+	ldlm_lock_decref_internal_nolock(lock, mode);
+
+	ldlm_lock_destroy_nolock(lock);
+}
+
+/**
+ * Process a granting attempt for flock lock.
+ * Must be called under ns lock held.
+ *
+ * This function looks for any conflicts for \a lock in the granted or
+ * waiting queues. The lock is granted if no conflicts are found in
+ * either queue.
+ *
+ * It is also responsible for splitting a lock if a portion of the lock
+ * is released.
+ *
+ */
+static int ldlm_process_flock_lock(struct ldlm_lock *req)
+{
+	struct ldlm_resource *res = req->l_resource;
+	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
+	struct ldlm_lock *tmp;
+	struct ldlm_lock *lock;
+	struct ldlm_lock *new = req;
+	struct ldlm_lock *new2 = NULL;
+	enum ldlm_mode mode = req->l_req_mode;
+	int added = (mode == LCK_NL);
+	int splitted = 0;
+	const struct ldlm_callback_suite null_cbs = { };
+
+	CDEBUG(D_DLMTRACE,
+	       "owner %llu pid %u mode %u start %llu end %llu\n",
+	       new->l_policy_data.l_flock.owner,
+	       new->l_policy_data.l_flock.pid, mode,
+	       req->l_policy_data.l_flock.start,
+	       req->l_policy_data.l_flock.end);
+
+	/* No blocking ASTs are sent to the clients for
+	 * Posix file & record locks
+	 */
+	req->l_blocking_ast = NULL;
+
+reprocess:
+	/* This loop determines where this processes locks start
+	 * in the resource lr_granted list.
+	 */
+	list_for_each_entry(lock, &res->lr_granted, l_res_link)
+		if (ldlm_same_flock_owner(lock, req))
+			break;
+
+	/* Scan the locks owned by this process to find the insertion point
+	 * (as locks are ordered), and to handle overlaps.
+	 * We may have to merge or split existing locks.
+	 */
+	list_for_each_entry_safe_from(lock, tmp, &res->lr_granted, l_res_link) {
+
+		if (!ldlm_same_flock_owner(lock, new))
+			break;
+
+		if (lock->l_granted_mode == mode) {
+			/* If the modes are the same then we need to process
+			 * locks that overlap OR adjoin the new lock. The extra
+			 * logic condition is necessary to deal with arithmetic
+			 * overflow and underflow.
+			 */
+			if ((new->l_policy_data.l_flock.start >
+			     (lock->l_policy_data.l_flock.end + 1)) &&
+			    (lock->l_policy_data.l_flock.end != OBD_OBJECT_EOF))
+				continue;
+
+			if ((new->l_policy_data.l_flock.end <
+			     (lock->l_policy_data.l_flock.start - 1)) &&
+			    (lock->l_policy_data.l_flock.start != 0))
+				break;
+
+			if (new->l_policy_data.l_flock.start <
+			    lock->l_policy_data.l_flock.start) {
+				lock->l_policy_data.l_flock.start =
+					new->l_policy_data.l_flock.start;
+			} else {
+				new->l_policy_data.l_flock.start =
+					lock->l_policy_data.l_flock.start;
+			}
+
+			if (new->l_policy_data.l_flock.end >
+			    lock->l_policy_data.l_flock.end) {
+				lock->l_policy_data.l_flock.end =
+					new->l_policy_data.l_flock.end;
+			} else {
+				new->l_policy_data.l_flock.end =
+					lock->l_policy_data.l_flock.end;
+			}
+
+			if (added) {
+				ldlm_flock_destroy(lock, mode);
+			} else {
+				new = lock;
+				added = 1;
+			}
+			continue;
+		}
+
+		if (new->l_policy_data.l_flock.start >
+		    lock->l_policy_data.l_flock.end)
+			continue;
+
+		if (new->l_policy_data.l_flock.end <
+		    lock->l_policy_data.l_flock.start)
+			break;
+
+		if (new->l_policy_data.l_flock.start <=
+		    lock->l_policy_data.l_flock.start) {
+			if (new->l_policy_data.l_flock.end <
+			    lock->l_policy_data.l_flock.end) {
+				lock->l_policy_data.l_flock.start =
+					new->l_policy_data.l_flock.end + 1;
+				break;
+			}
+			ldlm_flock_destroy(lock, lock->l_req_mode);
+			continue;
+		}
+		if (new->l_policy_data.l_flock.end >=
+		    lock->l_policy_data.l_flock.end) {
+			lock->l_policy_data.l_flock.end =
+				new->l_policy_data.l_flock.start - 1;
+			continue;
+		}
+
+		/* split the existing lock into two locks */
+
+		/* if this is an F_UNLCK operation then we could avoid
+		 * allocating a new lock and use the req lock passed in
+		 * with the request but this would complicate the reply
+		 * processing since updates to req get reflected in the
+		 * reply. The client side replays the lock request so
+		 * it must see the original lock data in the reply.
+		 */
+
+		/* XXX - if ldlm_lock_new() can sleep we should
+		 * release the lr_lock, allocate the new lock,
+		 * and restart processing this lock.
+		 */
+		if (!new2) {
+			unlock_res_and_lock(req);
+			new2 = ldlm_lock_create(ns, &res->lr_name, LDLM_FLOCK,
+						lock->l_granted_mode, &null_cbs,
+						NULL, 0, LVB_T_NONE);
+			lock_res_and_lock(req);
+			if (IS_ERR(new2)) {
+				ldlm_flock_destroy(req, lock->l_granted_mode);
+				return LDLM_ITER_STOP;
+			}
+			goto reprocess;
+		}
+
+		splitted = 1;
+
+		new2->l_granted_mode = lock->l_granted_mode;
+		new2->l_policy_data.l_flock.pid =
+			new->l_policy_data.l_flock.pid;
+		new2->l_policy_data.l_flock.owner =
+			new->l_policy_data.l_flock.owner;
+		new2->l_policy_data.l_flock.start =
+			lock->l_policy_data.l_flock.start;
+		new2->l_policy_data.l_flock.end =
+			new->l_policy_data.l_flock.start - 1;
+		lock->l_policy_data.l_flock.start =
+			new->l_policy_data.l_flock.end + 1;
+		new2->l_conn_export = lock->l_conn_export;
+		if (lock->l_export)
+			new2->l_export = class_export_lock_get(lock->l_export,
+							       new2);
+		ldlm_lock_addref_internal_nolock(new2,
+						 lock->l_granted_mode);
+
+		/* insert new2 at lock */
+		ldlm_resource_add_lock(res, &lock->l_res_link, new2);
+		LDLM_LOCK_RELEASE(new2);
+		break;
+	}
+
+	/* if new2 is created but never used, destroy it*/
+	if (splitted == 0 && new2)
+		ldlm_lock_destroy_nolock(new2);
+
+	/* At this point we're granting the lock request. */
+	req->l_granted_mode = req->l_req_mode;
+
+	if (!added) {
+		list_del_init(&req->l_res_link);
+		/* insert new lock before "lock", which might be the
+		 * next lock for this owner, or might be the first
+		 * lock for the next owner, or might not be a lock at
+		 * all, but instead points at the head of the list
+		 */
+		ldlm_resource_add_lock(res, &lock->l_res_link, req);
+	}
+
+	/* In case we're reprocessing the requested lock we can't destroy
+	 * it until after calling ldlm_add_ast_work_item() above so that laawi()
+	 * can bump the reference count on \a req. Otherwise \a req
+	 * could be freed before the completion AST can be sent.
+	 */
+	if (added)
+		ldlm_flock_destroy(req, mode);
+
+	ldlm_resource_dump(D_INFO, res);
+	return LDLM_ITER_CONTINUE;
+}
+
+/**
+ * Flock completion callback function.
+ *
+ * \param lock [in,out]: A lock to be handled
+ * \param flags    [in]: flags
+ * \param *data    [in]: ldlm_work_cp_ast_lock() will use ldlm_cb_set_arg
+ *
+ * \retval 0    : success
+ * \retval <0   : failure
+ */
+int
+ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
+{
+	struct file_lock		*getlk = lock->l_ast_data;
+	int				rc = 0;
+
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT2, 4);
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT3)) {
+		lock_res_and_lock(lock);
+		lock->l_flags |= LDLM_FL_FAIL_LOC;
+		unlock_res_and_lock(lock);
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT3, 4);
+	}
+	CDEBUG(D_DLMTRACE, "flags: 0x%llx data: %p getlk: %p\n",
+	       flags, data, getlk);
+
+	LASSERT(flags != LDLM_FL_WAIT_NOREPROC);
+
+	if (flags & LDLM_FL_FAILED)
+		goto granted;
+
+	if (!(flags & LDLM_FL_BLOCKED_MASK)) {
+		if (!data)
+			/* mds granted the lock in the reply */
+			goto granted;
+		/* CP AST RPC: lock get granted, wake it up */
+		wake_up(&lock->l_waitq);
+		return 0;
+	}
+
+	LDLM_DEBUG(lock,
+		   "client-side enqueue returned a blocked lock, sleeping");
+
+	/* Go to sleep until the lock is granted. */
+	rc = l_wait_event_abortable(lock->l_waitq, is_granted_or_cancelled(lock));
+
+	if (rc) {
+		lock_res_and_lock(lock);
+
+		/* client side - set flag to prevent lock from being put on LRU list */
+		ldlm_set_cbpending(lock);
+		unlock_res_and_lock(lock);
+
+		LDLM_DEBUG(lock, "client-side enqueue waking up: failed (%d)",
+			   rc);
+		return rc;
+	}
+
+granted:
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT, 10);
+
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT4)) {
+		lock_res_and_lock(lock);
+		/* DEADLOCK is always set with CBPENDING */
+		lock->l_flags |= LDLM_FL_FLOCK_DEADLOCK | LDLM_FL_CBPENDING;
+		unlock_res_and_lock(lock);
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT4, 4);
+	}
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT5)) {
+		lock_res_and_lock(lock);
+		/* DEADLOCK is always set with CBPENDING */
+		lock->l_flags |= LDLM_FL_FAIL_LOC |
+				 LDLM_FL_FLOCK_DEADLOCK | LDLM_FL_CBPENDING;
+		unlock_res_and_lock(lock);
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT5, 4);
+	}
+
+	lock_res_and_lock(lock);
+
+	/*
+	 * Protect against race where lock could have been just destroyed
+	 * due to overlap in ldlm_process_flock_lock().
+	 */
+	if (ldlm_is_destroyed(lock)) {
+		unlock_res_and_lock(lock);
+		LDLM_DEBUG(lock, "client-side enqueue waking up: destroyed");
+		/*
+		 * An error is still to be returned, to propagate it up to
+		 * ldlm_cli_enqueue_fini() caller.
+		 */
+		return -EIO;
+	}
+
+	/* ldlm_lock_enqueue() has already placed lock on the granted list. */
+	ldlm_resource_unlink_lock(lock);
+
+	/*
+	 * Import invalidation. We need to actually release the lock
+	 * references being held, so that it can go away. No point in
+	 * holding the lock even if app still believes it has it, since
+	 * server already dropped it anyway. Only for granted locks too.
+	 */
+	/* Do the same for DEADLOCK'ed locks. */
+	if (ldlm_is_failed(lock) || ldlm_is_flock_deadlock(lock)) {
+		int mode;
+
+		if (flags & LDLM_FL_TEST_LOCK)
+			LASSERT(ldlm_is_test_lock(lock));
+
+		if (ldlm_is_test_lock(lock) || ldlm_is_flock_deadlock(lock))
+			mode = getlk->fl_type;
+		else
+			mode = lock->l_granted_mode;
+
+		if (ldlm_is_flock_deadlock(lock)) {
+			LDLM_DEBUG(lock,
+				   "client-side enqueue deadlock received");
+			rc = -EDEADLK;
+		}
+		ldlm_flock_destroy(lock, mode);
+		unlock_res_and_lock(lock);
+
+		/* Need to wake up the waiter if we were evicted */
+		wake_up(&lock->l_waitq);
+
+		/*
+		 * An error is still to be returned, to propagate it up to
+		 * ldlm_cli_enqueue_fini() caller.
+		 */
+		return rc ? : -EIO;
+	}
+
+	LDLM_DEBUG(lock, "client-side enqueue granted");
+
+	if (flags & LDLM_FL_TEST_LOCK) {
+		/* fcntl(F_GETLK) request */
+		/* The old mode was saved in getlk->fl_type so that if the mode
+		 * in the lock changes we can decref the appropriate refcount.
+		 */
+		LASSERT(ldlm_is_test_lock(lock));
+		ldlm_flock_destroy(lock, getlk->fl_type);
+		switch (lock->l_granted_mode) {
+		case LCK_PR:
+			getlk->fl_type = F_RDLCK;
+			break;
+		case LCK_PW:
+			getlk->fl_type = F_WRLCK;
+			break;
+		default:
+			getlk->fl_type = F_UNLCK;
+		}
+		getlk->fl_pid = -(pid_t)lock->l_policy_data.l_flock.pid;
+		getlk->fl_start = (loff_t)lock->l_policy_data.l_flock.start;
+		getlk->fl_end = (loff_t)lock->l_policy_data.l_flock.end;
+	} else {
+		/* We need to reprocess the lock to do merges or splits
+		 * with existing locks owned by this process.
+		 */
+		ldlm_process_flock_lock(lock);
+	}
+	unlock_res_and_lock(lock);
+	return rc;
+}
+EXPORT_SYMBOL(ldlm_flock_completion_ast);
+
+void ldlm_flock_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				     union ldlm_policy_data *lpolicy)
+{
+	lpolicy->l_flock.start = wpolicy->l_flock.lfw_start;
+	lpolicy->l_flock.end = wpolicy->l_flock.lfw_end;
+	lpolicy->l_flock.pid = wpolicy->l_flock.lfw_pid;
+	lpolicy->l_flock.owner = wpolicy->l_flock.lfw_owner;
+}
+
+void ldlm_flock_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
+				     union ldlm_wire_policy_data *wpolicy)
+{
+	memset(wpolicy, 0, sizeof(*wpolicy));
+	wpolicy->l_flock.lfw_start = lpolicy->l_flock.start;
+	wpolicy->l_flock.lfw_end = lpolicy->l_flock.end;
+	wpolicy->l_flock.lfw_pid = lpolicy->l_flock.pid;
+	wpolicy->l_flock.lfw_owner = lpolicy->l_flock.owner;
+}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_inodebits.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_inodebits.c
new file mode 100644
index 000000000000..2926208cdfa1
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_inodebits.c
@@ -0,0 +1,69 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/ldlm/ldlm_inodebits.c
+ *
+ * Author: Peter Braam <braam@clusterfs.com>
+ * Author: Phil Schwan <phil@clusterfs.com>
+ */
+
+/**
+ * This file contains implementation of IBITS lock type
+ *
+ * IBITS lock type contains a bit mask determining various properties of an
+ * object. The meanings of specific bits are specific to the caller and are
+ * opaque to LDLM code.
+ *
+ * Locks with intersecting bitmasks and conflicting lock modes (e.g.  LCK_PW)
+ * are considered conflicting.  See the lock mode compatibility matrix
+ * in lustre_dlm.h.
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+
+#include <lustre_dlm.h>
+#include <obd_support.h>
+#include <lustre_lib.h>
+#include "ldlm_internal.h"
+
+void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				     union ldlm_policy_data *lpolicy)
+{
+	lpolicy->l_inodebits.bits = wpolicy->l_inodebits.bits;
+}
+
+void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
+				     union ldlm_wire_policy_data *wpolicy)
+{
+	memset(wpolicy, 0, sizeof(*wpolicy));
+	wpolicy->l_inodebits.bits = lpolicy->l_inodebits.bits;
+}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ldlm_internal.h
new file mode 100644
index 000000000000..60a15b963c8a
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_internal.h
@@ -0,0 +1,329 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+
+#define MAX_STRING_SIZE 128
+
+extern int ldlm_srv_namespace_nr;
+extern int ldlm_cli_namespace_nr;
+extern struct mutex ldlm_srv_namespace_lock;
+extern struct list_head ldlm_srv_namespace_list;
+extern struct mutex ldlm_cli_namespace_lock;
+extern struct list_head ldlm_cli_active_namespace_list;
+
+static inline int ldlm_namespace_nr_read(enum ldlm_side client)
+{
+	return client == LDLM_NAMESPACE_SERVER ?
+		ldlm_srv_namespace_nr : ldlm_cli_namespace_nr;
+}
+
+static inline void ldlm_namespace_nr_inc(enum ldlm_side client)
+{
+	if (client == LDLM_NAMESPACE_SERVER)
+		ldlm_srv_namespace_nr++;
+	else
+		ldlm_cli_namespace_nr++;
+}
+
+static inline void ldlm_namespace_nr_dec(enum ldlm_side client)
+{
+	if (client == LDLM_NAMESPACE_SERVER)
+		ldlm_srv_namespace_nr--;
+	else
+		ldlm_cli_namespace_nr--;
+}
+
+static inline struct list_head *ldlm_namespace_list(enum ldlm_side client)
+{
+	return client == LDLM_NAMESPACE_SERVER ?
+		&ldlm_srv_namespace_list : &ldlm_cli_active_namespace_list;
+}
+
+static inline struct mutex *ldlm_namespace_lock(enum ldlm_side client)
+{
+	return client == LDLM_NAMESPACE_SERVER ?
+		&ldlm_srv_namespace_lock : &ldlm_cli_namespace_lock;
+}
+
+/* ns_bref is the number of resources in this namespace */
+static inline int ldlm_ns_empty(struct ldlm_namespace *ns)
+{
+	return atomic_read(&ns->ns_bref) == 0;
+}
+
+void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *ns,
+					  enum ldlm_side client);
+void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
+					    enum ldlm_side client);
+struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side client);
+
+/* ldlm_request.c */
+/* Cancel lru flag, it indicates we cancel aged locks. */
+enum {
+	LDLM_LRU_FLAG_AGED	= BIT(0), /* Cancel old non-LRU resize locks */
+	LDLM_LRU_FLAG_PASSED	= BIT(1), /* Cancel passed number of locks. */
+	LDLM_LRU_FLAG_SHRINK	= BIT(2), /* Cancel locks from shrinker. */
+	LDLM_LRU_FLAG_LRUR	= BIT(3), /* Cancel locks from lru resize. */
+	LDLM_LRU_FLAG_NO_WAIT	= BIT(4), /* Cancel locks w/o blocking (neither
+					   * sending nor waiting for any rpcs)
+					   */
+	LDLM_LRU_FLAG_LRUR_NO_WAIT = BIT(5), /* LRUR + NO_WAIT */
+};
+
+int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
+		    enum ldlm_cancel_flags sync, int flags);
+int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
+			  struct list_head *cancels, int count, int max,
+			  enum ldlm_cancel_flags cancel_flags, int flags);
+extern unsigned int ldlm_enqueue_min;
+extern unsigned int ldlm_cancel_unused_locks_before_replay;
+
+/* ldlm_lock.c */
+
+struct ldlm_cb_set_arg {
+	struct ptlrpc_request_set	*set;
+	int				 type; /* LDLM_{CP,BL,GL}_CALLBACK */
+	atomic_t			 restart;
+	struct list_head			*list;
+	union ldlm_gl_desc		*gl_desc; /* glimpse AST descriptor */
+};
+
+enum ldlm_desc_ast_t {
+	LDLM_WORK_BL_AST,
+	LDLM_WORK_CP_AST,
+	LDLM_WORK_REVOKE_AST,
+	LDLM_WORK_GL_AST
+};
+
+void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list);
+int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
+		  enum req_location loc, void *data, int size);
+struct ldlm_lock *
+ldlm_lock_create(struct ldlm_namespace *ns, const struct ldlm_res_id *id,
+		 enum ldlm_type type, enum ldlm_mode mode,
+		 const struct ldlm_callback_suite *cbs,
+		 void *data, __u32 lvb_len, enum lvb_type lvb_type);
+enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
+				  struct ldlm_lock **lock, void *cookie,
+				  __u64 *flags);
+void ldlm_lock_addref_internal(struct ldlm_lock *lock, enum ldlm_mode mode);
+void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
+				      enum ldlm_mode mode);
+void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode);
+void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
+				      enum ldlm_mode mode);
+int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
+		      enum ldlm_desc_ast_t ast_type);
+int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use);
+#define ldlm_lock_remove_from_lru(lock) ldlm_lock_remove_from_lru_check(lock, 0)
+int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock);
+void ldlm_lock_destroy_nolock(struct ldlm_lock *lock);
+
+/* ldlm_lockd.c */
+int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
+			   struct ldlm_lock *lock);
+int ldlm_bl_to_thread_list(struct ldlm_namespace *ns,
+			   struct ldlm_lock_desc *ld,
+			   struct list_head *cancels, int count,
+			   enum ldlm_cancel_flags cancel_flags);
+int ldlm_bl_thread_wakeup(void);
+
+void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
+			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock);
+
+extern struct kmem_cache *ldlm_resource_slab;
+extern struct kset *ldlm_ns_kset;
+
+/* ldlm_lockd.c & ldlm_lock.c */
+extern struct kmem_cache *ldlm_lock_slab;
+
+/* ldlm_extent.c */
+void ldlm_extent_add_lock(struct ldlm_resource *res, struct ldlm_lock *lock);
+void ldlm_extent_unlink_lock(struct ldlm_lock *lock);
+void ldlm_extent_search(struct rb_root_cached *root,
+			__u64 start, __u64 end,
+			bool (*matches)(struct ldlm_lock *lock, void *data),
+			void *data);
+
+/* l_lock.c */
+void l_check_ns_lock(struct ldlm_namespace *ns);
+void l_check_no_ns_lock(struct ldlm_namespace *ns);
+
+extern struct dentry *ldlm_svc_debugfs_dir;
+
+struct ldlm_state {
+	struct ptlrpc_service *ldlm_cb_service;
+	struct ptlrpc_service *ldlm_cancel_service;
+	struct ptlrpc_client *ldlm_client;
+	struct ptlrpc_connection *ldlm_server_conn;
+	struct ldlm_bl_pool *ldlm_bl_pool;
+};
+
+/* ldlm_pool.c */
+__u64 ldlm_pool_get_slv(struct ldlm_pool *pl);
+void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv);
+__u32 ldlm_pool_get_lvf(struct ldlm_pool *pl);
+
+int ldlm_init(void);
+void ldlm_exit(void);
+
+enum ldlm_policy_res {
+	LDLM_POLICY_CANCEL_LOCK,
+	LDLM_POLICY_KEEP_LOCK,
+	LDLM_POLICY_SKIP_LOCK
+};
+
+#define LDLM_POOL_SYSFS_PRINT_int(v) sprintf(buf, "%d\n", v)
+#define LDLM_POOL_SYSFS_SET_int(a, b) { a = b; }
+#define LDLM_POOL_SYSFS_PRINT_u64(v) sprintf(buf, "%lld\n", v)
+#define LDLM_POOL_SYSFS_SET_u64(a, b) { a = b; }
+#define LDLM_POOL_SYSFS_PRINT_atomic(v) sprintf(buf, "%d\n", atomic_read(&v))
+#define LDLM_POOL_SYSFS_SET_atomic(a, b) atomic_set(&a, b)
+
+#define LDLM_POOL_SYSFS_READER_SHOW(var, type)				    \
+	static ssize_t var##_show(struct kobject *kobj,			    \
+				  struct attribute *attr,		    \
+				  char *buf)				    \
+	{								    \
+		struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, \
+						    pl_kobj);		    \
+		type tmp;						    \
+									    \
+		spin_lock(&pl->pl_lock);				    \
+		tmp = pl->pl_##var;					    \
+		spin_unlock(&pl->pl_lock);				    \
+									    \
+		return LDLM_POOL_SYSFS_PRINT_##type(tmp);		    \
+	}								    \
+	struct __##var##__dummy_read {; } /* semicolon catcher */
+
+#define LDLM_POOL_SYSFS_WRITER_STORE(var, type)				    \
+	static ssize_t var##_store(struct kobject *kobj,		    \
+				     struct attribute *attr,		    \
+				     const char *buffer,		    \
+				     size_t count)			    \
+	{								    \
+		struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, \
+						    pl_kobj);		    \
+		unsigned long tmp;					    \
+		int rc;							    \
+									    \
+		rc = kstrtoul(buffer, 10, &tmp);			    \
+		if (rc < 0) {						    \
+			return rc;					    \
+		}							    \
+									    \
+		spin_lock(&pl->pl_lock);				    \
+		LDLM_POOL_SYSFS_SET_##type(pl->pl_##var, tmp);		    \
+		spin_unlock(&pl->pl_lock);				    \
+									    \
+		return count;						    \
+	}								    \
+	struct __##var##__dummy_write {; } /* semicolon catcher */
+
+#define LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(var, type)			    \
+	static ssize_t var##_show(struct kobject *kobj,		    \
+				    struct attribute *attr,		    \
+				    char *buf)				    \
+	{								    \
+		struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, \
+						    pl_kobj);		    \
+									    \
+		return LDLM_POOL_SYSFS_PRINT_##type(pl->pl_##var);	    \
+	}								    \
+	struct __##var##__dummy_read {; } /* semicolon catcher */
+
+#define LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(var, type)			    \
+	static ssize_t var##_store(struct kobject *kobj,		    \
+				     struct attribute *attr,		    \
+				     const char *buffer,		    \
+				     size_t count)			    \
+	{								    \
+		struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool, \
+						    pl_kobj);		    \
+		unsigned long tmp;					    \
+		int rc;							    \
+									    \
+		rc = kstrtoul(buffer, 10, &tmp);			    \
+		if (rc < 0) {						    \
+			return rc;					    \
+		}							    \
+									    \
+		LDLM_POOL_SYSFS_SET_##type(pl->pl_##var, tmp);		    \
+									    \
+		return count;						    \
+	}								    \
+	struct __##var##__dummy_write {; } /* semicolon catcher */
+
+static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
+{
+	int ret = 0;
+
+	lock_res_and_lock(lock);
+	if ((lock->l_req_mode == lock->l_granted_mode) &&
+	    !ldlm_is_cp_reqd(lock))
+		ret = 1;
+	else if (ldlm_is_failed(lock) || ldlm_is_cancel(lock))
+		ret = 1;
+	unlock_res_and_lock(lock);
+
+	return ret;
+}
+
+typedef void (*ldlm_policy_wire_to_local_t)(const union ldlm_wire_policy_data *,
+					    union ldlm_policy_data *);
+
+typedef void (*ldlm_policy_local_to_wire_t)(const union ldlm_policy_data *,
+					    union ldlm_wire_policy_data *);
+
+void ldlm_plain_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				     union ldlm_policy_data *lpolicy);
+void ldlm_plain_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
+				     union ldlm_wire_policy_data *wpolicy);
+void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				     union ldlm_policy_data *lpolicy);
+void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
+				     union ldlm_wire_policy_data *wpolicy);
+void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				      union ldlm_policy_data *lpolicy);
+void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
+				      union ldlm_wire_policy_data *wpolicy);
+void ldlm_flock_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				     union ldlm_policy_data *lpolicy);
+void ldlm_flock_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
+				     union ldlm_wire_policy_data *wpolicy);
+
+static inline bool ldlm_res_eq(const struct ldlm_res_id *res0,
+			       const struct ldlm_res_id *res1)
+{
+	return memcmp(res0, res1, sizeof(*res0)) == 0;
+}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_lib.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_lib.c
new file mode 100644
index 000000000000..0aa4f234a4f4
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_lib.c
@@ -0,0 +1,842 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2010, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+
+/**
+ * This file deals with various client/target related logic including recovery.
+ *
+ * TODO: This code more logically belongs in the ptlrpc module than in ldlm and
+ * should be moved.
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+
+#include <obd.h>
+#include <obd_class.h>
+#include <lustre_dlm.h>
+#include <lustre_net.h>
+#include <lustre_sec.h>
+#include "ldlm_internal.h"
+
+/* @priority: If non-zero, move the selected connection to the list head.
+ * @create: If zero, only search in existing connections.
+ */
+static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
+			   int priority, int create)
+{
+	struct ptlrpc_connection *ptlrpc_conn;
+	struct obd_import_conn *imp_conn = NULL, *item;
+	int rc = 0;
+
+	if (!create && !priority) {
+		CDEBUG(D_HA, "Nothing to do\n");
+		return -EINVAL;
+	}
+
+	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid);
+	if (!ptlrpc_conn) {
+		CDEBUG(D_HA, "can't find connection %s\n", uuid->uuid);
+		return -ENOENT;
+	}
+
+	if (create) {
+		imp_conn = kzalloc(sizeof(*imp_conn), GFP_NOFS);
+		if (!imp_conn) {
+			rc = -ENOMEM;
+			goto out_put;
+		}
+	}
+
+	spin_lock(&imp->imp_lock);
+	list_for_each_entry(item, &imp->imp_conn_list, oic_item) {
+		if (obd_uuid_equals(uuid, &item->oic_uuid)) {
+			if (priority) {
+				list_del(&item->oic_item);
+				list_add(&item->oic_item,
+					 &imp->imp_conn_list);
+				item->oic_last_attempt = 0;
+			}
+			CDEBUG(D_HA, "imp %p@%s: found existing conn %s%s\n",
+			       imp, imp->imp_obd->obd_name, uuid->uuid,
+			       (priority ? ", moved to head" : ""));
+			spin_unlock(&imp->imp_lock);
+			rc = 0;
+			goto out_free;
+		}
+	}
+	/* No existing import connection found for \a uuid. */
+	if (create) {
+		imp_conn->oic_conn = ptlrpc_conn;
+		imp_conn->oic_uuid = *uuid;
+		imp_conn->oic_last_attempt = 0;
+		if (priority)
+			list_add(&imp_conn->oic_item, &imp->imp_conn_list);
+		else
+			list_add_tail(&imp_conn->oic_item,
+				      &imp->imp_conn_list);
+		CDEBUG(D_HA, "imp %p@%s: add connection %s at %s\n",
+		       imp, imp->imp_obd->obd_name, uuid->uuid,
+		       (priority ? "head" : "tail"));
+	} else {
+		spin_unlock(&imp->imp_lock);
+		rc = -ENOENT;
+		goto out_free;
+	}
+
+	spin_unlock(&imp->imp_lock);
+	return 0;
+out_free:
+	kfree(imp_conn);
+out_put:
+	ptlrpc_connection_put(ptlrpc_conn);
+	return rc;
+}
+
+int import_set_conn_priority(struct obd_import *imp, struct obd_uuid *uuid)
+{
+	return import_set_conn(imp, uuid, 1, 0);
+}
+
+int client_import_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
+			   int priority)
+{
+	return import_set_conn(imp, uuid, priority, 1);
+}
+EXPORT_SYMBOL(client_import_add_conn);
+
+int client_import_del_conn(struct obd_import *imp, struct obd_uuid *uuid)
+{
+	struct obd_import_conn *imp_conn;
+	struct obd_export *dlmexp;
+	int rc = -ENOENT;
+
+	spin_lock(&imp->imp_lock);
+	if (list_empty(&imp->imp_conn_list)) {
+		LASSERT(!imp->imp_connection);
+		goto out;
+	}
+
+	list_for_each_entry(imp_conn, &imp->imp_conn_list, oic_item) {
+		if (!obd_uuid_equals(uuid, &imp_conn->oic_uuid))
+			continue;
+		LASSERT(imp_conn->oic_conn);
+
+		if (imp_conn == imp->imp_conn_current) {
+			LASSERT(imp_conn->oic_conn == imp->imp_connection);
+
+			if (imp->imp_state != LUSTRE_IMP_CLOSED &&
+			    imp->imp_state != LUSTRE_IMP_DISCON) {
+				CERROR("can't remove current connection\n");
+				rc = -EBUSY;
+				goto out;
+			}
+
+			ptlrpc_connection_put(imp->imp_connection);
+			imp->imp_connection = NULL;
+
+			dlmexp = class_conn2export(&imp->imp_dlm_handle);
+			if (dlmexp && dlmexp->exp_connection) {
+				LASSERT(dlmexp->exp_connection ==
+					imp_conn->oic_conn);
+				ptlrpc_connection_put(dlmexp->exp_connection);
+				dlmexp->exp_connection = NULL;
+			}
+
+			if (dlmexp)
+				class_export_put(dlmexp);
+		}
+
+		list_del(&imp_conn->oic_item);
+		ptlrpc_connection_put(imp_conn->oic_conn);
+		kfree(imp_conn);
+		CDEBUG(D_HA, "imp %p@%s: remove connection %s\n",
+		       imp, imp->imp_obd->obd_name, uuid->uuid);
+		rc = 0;
+		break;
+	}
+out:
+	spin_unlock(&imp->imp_lock);
+	if (rc == -ENOENT)
+		CERROR("connection %s not found\n", uuid->uuid);
+	return rc;
+}
+EXPORT_SYMBOL(client_import_del_conn);
+
+/**
+ * Find conn UUID by peer NID. \a peer is a server NID. This function is used
+ * to find a conn uuid of \a imp which can reach \a peer.
+ */
+int client_import_find_conn(struct obd_import *imp, lnet_nid_t peer,
+			    struct obd_uuid *uuid)
+{
+	struct obd_import_conn *conn;
+	int rc = -ENOENT;
+
+	spin_lock(&imp->imp_lock);
+	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
+		/* Check if conn UUID does have this peer NID. */
+		if (class_check_uuid(&conn->oic_uuid, peer)) {
+			*uuid = conn->oic_uuid;
+			rc = 0;
+			break;
+		}
+	}
+	spin_unlock(&imp->imp_lock);
+	return rc;
+}
+EXPORT_SYMBOL(client_import_find_conn);
+
+void client_destroy_import(struct obd_import *imp)
+{
+	/* Drop security policy instance after all RPCs have finished/aborted
+	 * to let all busy contexts be released.
+	 */
+	class_import_get(imp);
+	class_destroy_import(imp);
+	sptlrpc_import_sec_put(imp);
+	class_import_put(imp);
+}
+EXPORT_SYMBOL(client_destroy_import);
+
+/* Configure an RPC client OBD device.
+ *
+ * lcfg parameters:
+ * 1 - client UUID
+ * 2 - server UUID
+ * 3 - inactive-on-startup
+ */
+int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
+{
+	struct client_obd *cli = &obddev->u.cli;
+	struct obd_import *imp;
+	struct obd_uuid server_uuid;
+	int rq_portal, rp_portal, connect_op;
+	char *name = obddev->obd_type->typ_name;
+	enum ldlm_ns_type ns_type = LDLM_NS_TYPE_UNKNOWN;
+	int rc;
+
+	/* In a more perfect world, we would hang a ptlrpc_client off of
+	 * obd_type and just use the values from there.
+	 */
+	if (!strcmp(name, LUSTRE_OSC_NAME)) {
+		rq_portal = OST_REQUEST_PORTAL;
+		rp_portal = OSC_REPLY_PORTAL;
+		connect_op = OST_CONNECT;
+		cli->cl_sp_me = LUSTRE_SP_CLI;
+		cli->cl_sp_to = LUSTRE_SP_OST;
+		ns_type = LDLM_NS_TYPE_OSC;
+	} else if (!strcmp(name, LUSTRE_MDC_NAME) ||
+		   !strcmp(name, LUSTRE_LWP_NAME)) {
+		rq_portal = MDS_REQUEST_PORTAL;
+		rp_portal = MDC_REPLY_PORTAL;
+		connect_op = MDS_CONNECT;
+		cli->cl_sp_me = LUSTRE_SP_CLI;
+		cli->cl_sp_to = LUSTRE_SP_MDT;
+		ns_type = LDLM_NS_TYPE_MDC;
+	} else if (!strcmp(name, LUSTRE_MGC_NAME)) {
+		rq_portal = MGS_REQUEST_PORTAL;
+		rp_portal = MGC_REPLY_PORTAL;
+		connect_op = MGS_CONNECT;
+		cli->cl_sp_me = LUSTRE_SP_MGC;
+		cli->cl_sp_to = LUSTRE_SP_MGS;
+		cli->cl_flvr_mgc.sf_rpc = SPTLRPC_FLVR_INVALID;
+		ns_type = LDLM_NS_TYPE_MGC;
+	} else {
+		CERROR("unknown client OBD type \"%s\", can't setup\n",
+		       name);
+		return -EINVAL;
+	}
+
+	if (LUSTRE_CFG_BUFLEN(lcfg, 1) < 1) {
+		CERROR("requires a TARGET UUID\n");
+		return -EINVAL;
+	}
+
+	if (LUSTRE_CFG_BUFLEN(lcfg, 1) > 37) {
+		CERROR("client UUID must be less than 38 characters\n");
+		return -EINVAL;
+	}
+
+	if (LUSTRE_CFG_BUFLEN(lcfg, 2) < 1) {
+		CERROR("setup requires a SERVER UUID\n");
+		return -EINVAL;
+	}
+
+	if (LUSTRE_CFG_BUFLEN(lcfg, 2) > 37) {
+		CERROR("target UUID must be less than 38 characters\n");
+		return -EINVAL;
+	}
+
+	init_rwsem(&cli->cl_sem);
+	cli->cl_conn_count = 0;
+	memcpy(server_uuid.uuid, lustre_cfg_buf(lcfg, 2),
+	       min_t(unsigned int, LUSTRE_CFG_BUFLEN(lcfg, 2),
+		     sizeof(server_uuid)));
+
+	cli->cl_dirty_pages = 0;
+	cli->cl_avail_grant = 0;
+	/* FIXME: Should limit this for the sum of all cl_dirty_max_pages. */
+	/*
+	 * cl_dirty_max_pages may be changed at connect time in
+	 * ptlrpc_connect_interpret().
+	 */
+	client_adjust_max_dirty(cli);
+	INIT_LIST_HEAD(&cli->cl_cache_waiters);
+	INIT_LIST_HEAD(&cli->cl_loi_ready_list);
+	INIT_LIST_HEAD(&cli->cl_loi_hp_ready_list);
+	INIT_LIST_HEAD(&cli->cl_loi_write_list);
+	INIT_LIST_HEAD(&cli->cl_loi_read_list);
+	spin_lock_init(&cli->cl_loi_list_lock);
+	atomic_set(&cli->cl_pending_w_pages, 0);
+	atomic_set(&cli->cl_pending_r_pages, 0);
+	cli->cl_r_in_flight = 0;
+	cli->cl_w_in_flight = 0;
+
+	spin_lock_init(&cli->cl_read_rpc_hist.oh_lock);
+	spin_lock_init(&cli->cl_write_rpc_hist.oh_lock);
+	spin_lock_init(&cli->cl_read_page_hist.oh_lock);
+	spin_lock_init(&cli->cl_write_page_hist.oh_lock);
+	spin_lock_init(&cli->cl_read_offset_hist.oh_lock);
+	spin_lock_init(&cli->cl_write_offset_hist.oh_lock);
+
+	/* lru for osc. */
+	INIT_LIST_HEAD(&cli->cl_lru_osc);
+	atomic_set(&cli->cl_lru_shrinkers, 0);
+	atomic_long_set(&cli->cl_lru_busy, 0);
+	atomic_long_set(&cli->cl_lru_in_list, 0);
+	INIT_LIST_HEAD(&cli->cl_lru_list);
+	spin_lock_init(&cli->cl_lru_list_lock);
+	atomic_long_set(&cli->cl_unstable_count, 0);
+	INIT_LIST_HEAD(&cli->cl_shrink_list);
+
+	init_waitqueue_head(&cli->cl_destroy_waitq);
+	atomic_set(&cli->cl_destroy_in_flight, 0);
+	/* Turn on checksumming by default. */
+	cli->cl_checksum = 1;
+	/*
+	 * The supported checksum types will be worked out at connect time
+	 * Set cl_chksum* to CRC32 for now to avoid returning screwed info
+	 * through procfs.
+	 */
+	cli->cl_cksum_type = OBD_CKSUM_CRC32;
+	cli->cl_supp_cksum_types = OBD_CKSUM_CRC32;
+	atomic_set(&cli->cl_resends, OSC_DEFAULT_RESENDS);
+
+	/*
+	 * Set it to possible maximum size. It may be reduced by ocd_brw_size
+	 * from OFD after connecting.
+	 */
+	cli->cl_max_pages_per_rpc = PTLRPC_MAX_BRW_PAGES;
+
+	/*
+	 * set cl_chunkbits default value to PAGE_CACHE_SHIFT,
+	 * it will be updated at OSC connection time.
+	 */
+	cli->cl_chunkbits = PAGE_SHIFT;
+
+	if (!strcmp(name, LUSTRE_MDC_NAME))
+		cli->cl_max_rpcs_in_flight = OBD_MAX_RIF_DEFAULT;
+	else if (totalram_pages >> (20 - PAGE_SHIFT) <= 128 /* MB */)
+		cli->cl_max_rpcs_in_flight = 2;
+	else if (totalram_pages >> (20 - PAGE_SHIFT) <= 256 /* MB */)
+		cli->cl_max_rpcs_in_flight = 3;
+	else if (totalram_pages >> (20 - PAGE_SHIFT) <= 512 /* MB */)
+		cli->cl_max_rpcs_in_flight = 4;
+	else
+		cli->cl_max_rpcs_in_flight = OBD_MAX_RIF_DEFAULT;
+
+	spin_lock_init(&cli->cl_mod_rpcs_lock);
+	spin_lock_init(&cli->cl_mod_rpcs_hist.oh_lock);
+	cli->cl_max_mod_rpcs_in_flight = 0;
+	cli->cl_mod_rpcs_in_flight = 0;
+	cli->cl_close_rpcs_in_flight = 0;
+	init_waitqueue_head(&cli->cl_mod_rpcs_waitq);
+	cli->cl_mod_tag_bitmap = NULL;
+
+	if (connect_op == MDS_CONNECT) {
+		cli->cl_max_mod_rpcs_in_flight = cli->cl_max_rpcs_in_flight - 1;
+		cli->cl_mod_tag_bitmap = kcalloc(BITS_TO_LONGS(OBD_MAX_RIF_MAX),
+						 sizeof(long), GFP_NOFS);
+		if (!cli->cl_mod_tag_bitmap) {
+			rc = -ENOMEM;
+			goto err;
+		}
+	}
+
+	rc = ldlm_get_ref();
+	if (rc) {
+		CERROR("ldlm_get_ref failed: %d\n", rc);
+		goto err;
+	}
+
+	ptlrpc_init_client(rq_portal, rp_portal, name,
+			   &obddev->obd_ldlm_client);
+
+	imp = class_new_import(obddev);
+	if (!imp) {
+		rc = -ENOENT;
+		goto err_ldlm;
+	}
+	imp->imp_client = &obddev->obd_ldlm_client;
+	imp->imp_connect_op = connect_op;
+	memcpy(cli->cl_target_uuid.uuid, lustre_cfg_buf(lcfg, 1),
+	       LUSTRE_CFG_BUFLEN(lcfg, 1));
+	class_import_put(imp);
+
+	rc = client_import_add_conn(imp, &server_uuid, 1);
+	if (rc) {
+		CERROR("can't add initial connection\n");
+		goto err_import;
+	}
+
+	cli->cl_import = imp;
+	/* cli->cl_max_mds_easize updated by mdc_init_ea_size() */
+	cli->cl_max_mds_easize = sizeof(struct lov_mds_md_v3);
+
+	if (LUSTRE_CFG_BUFLEN(lcfg, 3) > 0) {
+		if (!strcmp(lustre_cfg_string(lcfg, 3), "inactive")) {
+			CDEBUG(D_HA, "marking %s %s->%s as inactive\n",
+			       name, obddev->obd_name,
+			       cli->cl_target_uuid.uuid);
+			spin_lock(&imp->imp_lock);
+			imp->imp_deactive = 1;
+			spin_unlock(&imp->imp_lock);
+		}
+	}
+
+	obddev->obd_namespace = ldlm_namespace_new(obddev, obddev->obd_name,
+						   LDLM_NAMESPACE_CLIENT,
+						   LDLM_NAMESPACE_GREEDY,
+						   ns_type);
+	if (!obddev->obd_namespace) {
+		CERROR("Unable to create client namespace - %s\n",
+		       obddev->obd_name);
+		rc = -ENOMEM;
+		goto err_import;
+	}
+
+	return rc;
+
+err_import:
+	class_destroy_import(imp);
+err_ldlm:
+	ldlm_put_ref();
+err:
+	kfree(cli->cl_mod_tag_bitmap);
+	cli->cl_mod_tag_bitmap = NULL;
+	return rc;
+}
+EXPORT_SYMBOL(client_obd_setup);
+
+int client_obd_cleanup(struct obd_device *obddev)
+{
+	struct client_obd *cli = &obddev->u.cli;
+
+	ldlm_namespace_free_post(obddev->obd_namespace);
+	obddev->obd_namespace = NULL;
+
+	obd_cleanup_client_import(obddev);
+	LASSERT(!obddev->u.cli.cl_import);
+
+	ldlm_put_ref();
+
+	kfree(cli->cl_mod_tag_bitmap);
+	cli->cl_mod_tag_bitmap = NULL;
+
+	return 0;
+}
+EXPORT_SYMBOL(client_obd_cleanup);
+
+/* ->o_connect() method for client side (OSC and MDC and MGC) */
+int client_connect_import(const struct lu_env *env,
+			  struct obd_export **exp,
+			  struct obd_device *obd, struct obd_uuid *cluuid,
+			  struct obd_connect_data *data, void *localdata)
+{
+	struct client_obd       *cli    = &obd->u.cli;
+	struct obd_import       *imp    = cli->cl_import;
+	struct obd_connect_data *ocd;
+	struct lustre_handle    conn    = { 0 };
+	bool is_mdc = false;
+	int		     rc;
+
+	*exp = NULL;
+	down_write(&cli->cl_sem);
+	if (cli->cl_conn_count > 0) {
+		rc = -EALREADY;
+		goto out_sem;
+	}
+
+	rc = class_connect(&conn, obd, cluuid);
+	if (rc)
+		goto out_sem;
+
+	cli->cl_conn_count++;
+	*exp = class_conn2export(&conn);
+
+	LASSERT(obd->obd_namespace);
+
+	imp->imp_dlm_handle = conn;
+	rc = ptlrpc_init_import(imp);
+	if (rc != 0)
+		goto out_ldlm;
+
+	ocd = &imp->imp_connect_data;
+	if (data) {
+		*ocd = *data;
+		is_mdc = !strncmp(imp->imp_obd->obd_type->typ_name,
+				  LUSTRE_MDC_NAME, 3);
+		if (is_mdc)
+			data->ocd_connect_flags |= OBD_CONNECT_MULTIMODRPCS;
+		imp->imp_connect_flags_orig = data->ocd_connect_flags;
+	}
+
+	rc = ptlrpc_connect_import(imp);
+	if (rc != 0) {
+		if (data && is_mdc)
+			data->ocd_connect_flags &= ~OBD_CONNECT_MULTIMODRPCS;
+		LASSERT(imp->imp_state == LUSTRE_IMP_DISCON);
+		goto out_ldlm;
+	}
+	LASSERT(*exp && (*exp)->exp_connection);
+
+	if (data) {
+		LASSERTF((ocd->ocd_connect_flags & data->ocd_connect_flags) ==
+			 ocd->ocd_connect_flags, "old %#llx, new %#llx\n",
+			 data->ocd_connect_flags, ocd->ocd_connect_flags);
+		data->ocd_connect_flags = ocd->ocd_connect_flags;
+		/* clear the flag as it was not set and is not known
+		 * by upper layers
+		 */
+		if (is_mdc)
+			data->ocd_connect_flags &= ~OBD_CONNECT_MULTIMODRPCS;
+	}
+
+	ptlrpc_pinger_add_import(imp);
+
+	if (rc) {
+out_ldlm:
+		cli->cl_conn_count--;
+		class_disconnect(*exp);
+		*exp = NULL;
+	}
+out_sem:
+	up_write(&cli->cl_sem);
+
+	return rc;
+}
+EXPORT_SYMBOL(client_connect_import);
+
+int client_disconnect_export(struct obd_export *exp)
+{
+	struct obd_device *obd = class_exp2obd(exp);
+	struct client_obd *cli;
+	struct obd_import *imp;
+	int rc = 0, err;
+
+	if (!obd) {
+		CERROR("invalid export for disconnect: exp %p cookie %#llx\n",
+		       exp, exp ? exp->exp_handle.h_cookie : -1);
+		return -EINVAL;
+	}
+
+	cli = &obd->u.cli;
+	imp = cli->cl_import;
+
+	down_write(&cli->cl_sem);
+	CDEBUG(D_INFO, "disconnect %s - %zu\n", obd->obd_name,
+	       cli->cl_conn_count);
+
+	if (!cli->cl_conn_count) {
+		CERROR("disconnecting disconnected device (%s)\n",
+		       obd->obd_name);
+		rc = -EINVAL;
+		goto out_disconnect;
+	}
+
+	cli->cl_conn_count--;
+	if (cli->cl_conn_count) {
+		rc = 0;
+		goto out_disconnect;
+	}
+
+	/* Mark import deactivated now, so we don't try to reconnect if any
+	 * of the cleanup RPCs fails (e.g. LDLM cancel, etc).  We don't
+	 * fully deactivate the import, or that would drop all requests.
+	 */
+	spin_lock(&imp->imp_lock);
+	imp->imp_deactive = 1;
+	spin_unlock(&imp->imp_lock);
+
+	/* Some non-replayable imports (MDS's OSCs) are pinged, so just
+	 * delete it regardless.  (It's safe to delete an import that was
+	 * never added.)
+	 */
+	(void)ptlrpc_pinger_del_import(imp);
+
+	if (obd->obd_namespace) {
+		/* obd_force == local only */
+		ldlm_cli_cancel_unused(obd->obd_namespace, NULL,
+				       obd->obd_force ? LCF_LOCAL : 0, NULL);
+		ldlm_namespace_free_prior(obd->obd_namespace, imp,
+					  obd->obd_force);
+	}
+
+	/* There's no need to hold sem while disconnecting an import,
+	 * and it may actually cause deadlock in GSS.
+	 */
+	up_write(&cli->cl_sem);
+	rc = ptlrpc_disconnect_import(imp, 0);
+	down_write(&cli->cl_sem);
+
+	ptlrpc_invalidate_import(imp);
+
+out_disconnect:
+	/* Use server style - class_disconnect should be always called for
+	 * o_disconnect.
+	 */
+	err = class_disconnect(exp);
+	if (!rc && err)
+		rc = err;
+
+	up_write(&cli->cl_sem);
+
+	return rc;
+}
+EXPORT_SYMBOL(client_disconnect_export);
+
+/**
+ * Packs current SLV and Limit into \a req.
+ */
+int target_pack_pool_reply(struct ptlrpc_request *req)
+{
+	struct obd_device *obd;
+
+	/* Check that we still have all structures alive as this may
+	 * be some late RPC at shutdown time.
+	 */
+	if (unlikely(!req->rq_export || !req->rq_export->exp_obd ||
+		     !exp_connect_lru_resize(req->rq_export))) {
+		lustre_msg_set_slv(req->rq_repmsg, 0);
+		lustre_msg_set_limit(req->rq_repmsg, 0);
+		return 0;
+	}
+
+	/* OBD is alive here as export is alive, which we checked above. */
+	obd = req->rq_export->exp_obd;
+
+	read_lock(&obd->obd_pool_lock);
+	lustre_msg_set_slv(req->rq_repmsg, obd->obd_pool_slv);
+	lustre_msg_set_limit(req->rq_repmsg, obd->obd_pool_limit);
+	read_unlock(&obd->obd_pool_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(target_pack_pool_reply);
+
+static int
+target_send_reply_msg(struct ptlrpc_request *req, int rc, int fail_id)
+{
+	if (OBD_FAIL_CHECK_ORSET(fail_id & ~OBD_FAIL_ONCE, OBD_FAIL_ONCE)) {
+		DEBUG_REQ(D_ERROR, req, "dropping reply");
+		return -ECOMM;
+	}
+
+	if (unlikely(rc)) {
+		DEBUG_REQ(D_NET, req, "processing error (%d)", rc);
+		req->rq_status = rc;
+		return ptlrpc_send_error(req, 1);
+	}
+
+	DEBUG_REQ(D_NET, req, "sending reply");
+	return ptlrpc_send_reply(req, PTLRPC_REPLY_MAYBE_DIFFICULT);
+}
+
+void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
+{
+	struct ptlrpc_service_part *svcpt;
+	int			netrc;
+	struct ptlrpc_reply_state *rs;
+	struct obd_export	 *exp;
+
+	if (req->rq_no_reply)
+		return;
+
+	svcpt = req->rq_rqbd->rqbd_svcpt;
+	rs = req->rq_reply_state;
+	if (!rs || !rs->rs_difficult) {
+		/* no notifiers */
+		target_send_reply_msg(req, rc, fail_id);
+		return;
+	}
+
+	/* must be an export if locks saved */
+	LASSERT(req->rq_export);
+	/* req/reply consistent */
+	LASSERT(rs->rs_svcpt == svcpt);
+
+	/* "fresh" reply */
+	LASSERT(!rs->rs_scheduled);
+	LASSERT(!rs->rs_scheduled_ever);
+	LASSERT(!rs->rs_handled);
+	LASSERT(!rs->rs_on_net);
+	LASSERT(!rs->rs_export);
+	LASSERT(list_empty(&rs->rs_obd_list));
+	LASSERT(list_empty(&rs->rs_exp_list));
+
+	exp = class_export_get(req->rq_export);
+
+	/* disable reply scheduling while I'm setting up */
+	rs->rs_scheduled = 1;
+	rs->rs_on_net    = 1;
+	rs->rs_xid       = req->rq_xid;
+	rs->rs_transno   = req->rq_transno;
+	rs->rs_export    = exp;
+	rs->rs_opc       = lustre_msg_get_opc(req->rq_reqmsg);
+
+	spin_lock(&exp->exp_uncommitted_replies_lock);
+	CDEBUG(D_NET, "rs transno = %llu, last committed = %llu\n",
+	       rs->rs_transno, exp->exp_last_committed);
+	if (rs->rs_transno > exp->exp_last_committed) {
+		/* not committed already */
+		list_add_tail(&rs->rs_obd_list,
+			      &exp->exp_uncommitted_replies);
+	}
+	spin_unlock(&exp->exp_uncommitted_replies_lock);
+
+	spin_lock(&exp->exp_lock);
+	list_add_tail(&rs->rs_exp_list, &exp->exp_outstanding_replies);
+	spin_unlock(&exp->exp_lock);
+
+	netrc = target_send_reply_msg(req, rc, fail_id);
+
+	spin_lock(&svcpt->scp_rep_lock);
+
+	atomic_inc(&svcpt->scp_nreps_difficult);
+
+	if (netrc != 0) {
+		/* error sending: reply is off the net.  Also we need +1
+		 * reply ref until ptlrpc_handle_rs() is done
+		 * with the reply state (if the send was successful, there
+		 * would have been +1 ref for the net, which
+		 * reply_out_callback leaves alone)
+		 */
+		rs->rs_on_net = 0;
+		ptlrpc_rs_addref(rs);
+	}
+
+	spin_lock(&rs->rs_lock);
+	if (rs->rs_transno <= exp->exp_last_committed ||
+	    (!rs->rs_on_net && !rs->rs_no_ack) ||
+	    list_empty(&rs->rs_exp_list) ||     /* completed already */
+	    list_empty(&rs->rs_obd_list)) {
+		CDEBUG(D_HA, "Schedule reply immediately\n");
+		ptlrpc_dispatch_difficult_reply(rs);
+	} else {
+		list_add(&rs->rs_list, &svcpt->scp_rep_active);
+		rs->rs_scheduled = 0;	/* allow notifier to schedule */
+	}
+	spin_unlock(&rs->rs_lock);
+	spin_unlock(&svcpt->scp_rep_lock);
+}
+EXPORT_SYMBOL(target_send_reply);
+
+enum ldlm_mode lck_compat_array[] = {
+	[LCK_EX]	= LCK_COMPAT_EX,
+	[LCK_PW]	= LCK_COMPAT_PW,
+	[LCK_PR]	= LCK_COMPAT_PR,
+	[LCK_CW]	= LCK_COMPAT_CW,
+	[LCK_CR]	= LCK_COMPAT_CR,
+	[LCK_NL]	= LCK_COMPAT_NL,
+	[LCK_GROUP]	= LCK_COMPAT_GROUP,
+	[LCK_COS]	= LCK_COMPAT_COS,
+};
+
+/**
+ * Rather arbitrary mapping from LDLM error codes to errno values. This should
+ * not escape to the user level.
+ */
+int ldlm_error2errno(enum ldlm_error error)
+{
+	int result;
+
+	switch (error) {
+	case ELDLM_OK:
+	case ELDLM_LOCK_MATCHED:
+		result = 0;
+		break;
+	case ELDLM_LOCK_CHANGED:
+		result = -ESTALE;
+		break;
+	case ELDLM_LOCK_ABORTED:
+		result = -ENAVAIL;
+		break;
+	case ELDLM_LOCK_REPLACED:
+		result = -ESRCH;
+		break;
+	case ELDLM_NO_LOCK_DATA:
+		result = -ENOENT;
+		break;
+	case ELDLM_NAMESPACE_EXISTS:
+		result = -EEXIST;
+		break;
+	case ELDLM_BAD_NAMESPACE:
+		result = -EBADF;
+		break;
+	default:
+		if (((int)error) < 0)  /* cast to signed type */
+			result = error; /* as enum ldlm_error can be unsigned */
+		else {
+			CERROR("Invalid DLM result code: %d\n", error);
+			result = -EPROTO;
+		}
+	}
+	return result;
+}
+EXPORT_SYMBOL(ldlm_error2errno);
+
+#if LUSTRE_TRACKS_LOCK_EXP_REFS
+void ldlm_dump_export_locks(struct obd_export *exp)
+{
+	spin_lock(&exp->exp_locks_list_guard);
+	if (!list_empty(&exp->exp_locks_list)) {
+		struct ldlm_lock *lock;
+
+		CERROR("dumping locks for export %p,ignore if the unmount doesn't hang\n",
+		       exp);
+		list_for_each_entry(lock, &exp->exp_locks_list,
+				    l_exp_refs_link)
+			LDLM_ERROR(lock, "lock:");
+	}
+	spin_unlock(&exp->exp_locks_list_guard);
+}
+#endif
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_lock.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_lock.c
new file mode 100644
index 000000000000..2fb2e088dc87
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_lock.c
@@ -0,0 +1,2103 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2010, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/ldlm/ldlm_lock.c
+ *
+ * Author: Peter Braam <braam@clusterfs.com>
+ * Author: Phil Schwan <phil@clusterfs.com>
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+
+#include <lustre_intent.h>
+#include <lustre_swab.h>
+#include <obd_class.h>
+#include "ldlm_internal.h"
+
+/* lock types */
+char *ldlm_lockname[] = {
+	[0]		= "--",
+	[LCK_EX]	= "EX",
+	[LCK_PW]	= "PW",
+	[LCK_PR]	= "PR",
+	[LCK_CW]	= "CW",
+	[LCK_CR]	= "CR",
+	[LCK_NL]	= "NL",
+	[LCK_GROUP]	= "GROUP",
+	[LCK_COS]	= "COS",
+};
+EXPORT_SYMBOL(ldlm_lockname);
+
+static char *ldlm_typename[] = {
+	[LDLM_PLAIN]	= "PLN",
+	[LDLM_EXTENT]	= "EXT",
+	[LDLM_FLOCK]	= "FLK",
+	[LDLM_IBITS]	= "IBT",
+};
+
+static ldlm_policy_wire_to_local_t ldlm_policy_wire_to_local[] = {
+	[LDLM_PLAIN - LDLM_MIN_TYPE]	= ldlm_plain_policy_wire_to_local,
+	[LDLM_EXTENT - LDLM_MIN_TYPE]	= ldlm_extent_policy_wire_to_local,
+	[LDLM_FLOCK - LDLM_MIN_TYPE]	= ldlm_flock_policy_wire_to_local,
+	[LDLM_IBITS - LDLM_MIN_TYPE]	= ldlm_ibits_policy_wire_to_local,
+};
+
+static ldlm_policy_local_to_wire_t ldlm_policy_local_to_wire[] = {
+	[LDLM_PLAIN - LDLM_MIN_TYPE]	= ldlm_plain_policy_local_to_wire,
+	[LDLM_EXTENT - LDLM_MIN_TYPE]	= ldlm_extent_policy_local_to_wire,
+	[LDLM_FLOCK - LDLM_MIN_TYPE]	= ldlm_flock_policy_local_to_wire,
+	[LDLM_IBITS - LDLM_MIN_TYPE]	= ldlm_ibits_policy_local_to_wire,
+};
+
+/**
+ * Converts lock policy from local format to on the wire lock_desc format
+ */
+static void ldlm_convert_policy_to_wire(enum ldlm_type type,
+					const union ldlm_policy_data *lpolicy,
+					union ldlm_wire_policy_data *wpolicy)
+{
+	ldlm_policy_local_to_wire_t convert;
+
+	convert = ldlm_policy_local_to_wire[type - LDLM_MIN_TYPE];
+
+	convert(lpolicy, wpolicy);
+}
+
+/**
+ * Converts lock policy from on the wire lock_desc format to local format
+ */
+void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
+				  const union ldlm_wire_policy_data *wpolicy,
+				  union ldlm_policy_data *lpolicy)
+{
+	ldlm_policy_wire_to_local_t convert;
+
+	convert = ldlm_policy_wire_to_local[type - LDLM_MIN_TYPE];
+
+	convert(wpolicy, lpolicy);
+}
+
+const char *ldlm_it2str(enum ldlm_intent_flags it)
+{
+	switch (it) {
+	case IT_OPEN:
+		return "open";
+	case IT_CREAT:
+		return "creat";
+	case (IT_OPEN | IT_CREAT):
+		return "open|creat";
+	case IT_READDIR:
+		return "readdir";
+	case IT_GETATTR:
+		return "getattr";
+	case IT_LOOKUP:
+		return "lookup";
+	case IT_UNLINK:
+		return "unlink";
+	case IT_GETXATTR:
+		return "getxattr";
+	case IT_LAYOUT:
+		return "layout";
+	default:
+		CERROR("Unknown intent 0x%08x\n", it);
+		return "UNKNOWN";
+	}
+}
+EXPORT_SYMBOL(ldlm_it2str);
+
+/*
+ * REFCOUNTED LOCK OBJECTS
+ */
+
+/**
+ * Get a reference on a lock.
+ *
+ * Lock refcounts, during creation:
+ *   - one special one for allocation, dec'd only once in destroy
+ *   - one for being a lock that's in-use
+ *   - one for the addref associated with a new lock
+ */
+struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock)
+{
+	atomic_inc(&lock->l_refc);
+	return lock;
+}
+EXPORT_SYMBOL(ldlm_lock_get);
+
+/**
+ * Release lock reference.
+ *
+ * Also frees the lock if it was last reference.
+ */
+void ldlm_lock_put(struct ldlm_lock *lock)
+{
+	LASSERT(lock->l_resource != LP_POISON);
+	LASSERT(atomic_read(&lock->l_refc) > 0);
+	if (atomic_dec_and_test(&lock->l_refc)) {
+		struct ldlm_resource *res;
+
+		LDLM_DEBUG(lock,
+			   "final lock_put on destroyed lock, freeing it.");
+
+		res = lock->l_resource;
+		LASSERT(ldlm_is_destroyed(lock));
+		LASSERT(list_empty(&lock->l_res_link));
+		LASSERT(list_empty(&lock->l_pending_chain));
+
+		lprocfs_counter_decr(ldlm_res_to_ns(res)->ns_stats,
+				     LDLM_NSS_LOCKS);
+		lu_ref_del(&res->lr_reference, "lock", lock);
+		ldlm_resource_putref(res);
+		lock->l_resource = NULL;
+		if (lock->l_export) {
+			class_export_lock_put(lock->l_export, lock);
+			lock->l_export = NULL;
+		}
+
+		kfree(lock->l_lvb_data);
+
+		lu_ref_fini(&lock->l_reference);
+		OBD_FREE_RCU(lock, sizeof(*lock), &lock->l_handle);
+	}
+}
+EXPORT_SYMBOL(ldlm_lock_put);
+
+/**
+ * Removes LDLM lock \a lock from LRU. Assumes LRU is already locked.
+ */
+int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock)
+{
+	int rc = 0;
+
+	if (!list_empty(&lock->l_lru)) {
+		struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
+
+		LASSERT(lock->l_resource->lr_type != LDLM_FLOCK);
+		list_del_init(&lock->l_lru);
+		LASSERT(ns->ns_nr_unused > 0);
+		ns->ns_nr_unused--;
+		rc = 1;
+	}
+	return rc;
+}
+
+/**
+ * Removes LDLM lock \a lock from LRU. Obtains the LRU lock first.
+ *
+ * If \a last_use is non-zero, it will remove the lock from LRU only if
+ * it matches lock's l_last_used.
+ *
+ * \retval 0 if \a last_use is set, the lock is not in LRU list or \a last_use
+ *           doesn't match lock's l_last_used;
+ *           otherwise, the lock hasn't been in the LRU list.
+ * \retval 1 the lock was in LRU list and removed.
+ */
+int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use)
+{
+	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
+	int rc = 0;
+
+	spin_lock(&ns->ns_lock);
+	if (last_use == 0 || last_use == lock->l_last_used)
+		rc = ldlm_lock_remove_from_lru_nolock(lock);
+	spin_unlock(&ns->ns_lock);
+
+	return rc;
+}
+
+/**
+ * Adds LDLM lock \a lock to namespace LRU. Assumes LRU is already locked.
+ */
+static void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
+{
+	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
+
+	lock->l_last_used = jiffies;
+	LASSERT(list_empty(&lock->l_lru));
+	LASSERT(lock->l_resource->lr_type != LDLM_FLOCK);
+	list_add_tail(&lock->l_lru, &ns->ns_unused_list);
+	ldlm_clear_skipped(lock);
+	LASSERT(ns->ns_nr_unused >= 0);
+	ns->ns_nr_unused++;
+}
+
+/**
+ * Adds LDLM lock \a lock to namespace LRU. Obtains necessary LRU locks
+ * first.
+ */
+static void ldlm_lock_add_to_lru(struct ldlm_lock *lock)
+{
+	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
+
+	spin_lock(&ns->ns_lock);
+	ldlm_lock_add_to_lru_nolock(lock);
+	spin_unlock(&ns->ns_lock);
+}
+
+/**
+ * Moves LDLM lock \a lock that is already in namespace LRU to the tail of
+ * the LRU. Performs necessary LRU locking
+ */
+static void ldlm_lock_touch_in_lru(struct ldlm_lock *lock)
+{
+	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
+
+	spin_lock(&ns->ns_lock);
+	if (!list_empty(&lock->l_lru)) {
+		ldlm_lock_remove_from_lru_nolock(lock);
+		ldlm_lock_add_to_lru_nolock(lock);
+	}
+	spin_unlock(&ns->ns_lock);
+}
+
+/**
+ * Helper to destroy a locked lock.
+ *
+ * Used by ldlm_lock_destroy and ldlm_lock_destroy_nolock
+ * Must be called with l_lock and lr_lock held.
+ *
+ * Does not actually free the lock data, but rather marks the lock as
+ * destroyed by setting l_destroyed field in the lock to 1.  Destroys a
+ * handle->lock association too, so that the lock can no longer be found
+ * and removes the lock from LRU list.  Actual lock freeing occurs when
+ * last lock reference goes away.
+ *
+ * Original comment (of some historical value):
+ * This used to have a 'strict' flag, which recovery would use to mark an
+ * in-use lock as needing-to-die.  Lest I am ever tempted to put it back, I
+ * shall explain why it's gone: with the new hash table scheme, once you call
+ * ldlm_lock_destroy, you can never drop your final references on this lock.
+ * Because it's not in the hash table anymore.  -phil
+ */
+static int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
+{
+	if (lock->l_readers || lock->l_writers) {
+		LDLM_ERROR(lock, "lock still has references");
+		LBUG();
+	}
+
+	if (!list_empty(&lock->l_res_link)) {
+		LDLM_ERROR(lock, "lock still on resource");
+		LBUG();
+	}
+
+	if (ldlm_is_destroyed(lock)) {
+		LASSERT(list_empty(&lock->l_lru));
+		return 0;
+	}
+	ldlm_set_destroyed(lock);
+
+	ldlm_lock_remove_from_lru(lock);
+	class_handle_unhash(&lock->l_handle);
+
+	return 1;
+}
+
+/**
+ * Destroys a LDLM lock \a lock. Performs necessary locking first.
+ */
+static void ldlm_lock_destroy(struct ldlm_lock *lock)
+{
+	int first;
+
+	lock_res_and_lock(lock);
+	first = ldlm_lock_destroy_internal(lock);
+	unlock_res_and_lock(lock);
+
+	/* drop reference from hashtable only for first destroy */
+	if (first) {
+		lu_ref_del(&lock->l_reference, "hash", lock);
+		LDLM_LOCK_RELEASE(lock);
+	}
+}
+
+/**
+ * Destroys a LDLM lock \a lock that is already locked.
+ */
+void ldlm_lock_destroy_nolock(struct ldlm_lock *lock)
+{
+	int first;
+
+	first = ldlm_lock_destroy_internal(lock);
+	/* drop reference from hashtable only for first destroy */
+	if (first) {
+		lu_ref_del(&lock->l_reference, "hash", lock);
+		LDLM_LOCK_RELEASE(lock);
+	}
+}
+
+/* this is called by portals_handle2object with the handle lock taken */
+static void lock_handle_addref(void *lock)
+{
+	LDLM_LOCK_GET((struct ldlm_lock *)lock);
+}
+
+static void lock_handle_free(void *lock, int size)
+{
+	LASSERT(size == sizeof(struct ldlm_lock));
+	kmem_cache_free(ldlm_lock_slab, lock);
+}
+
+static struct portals_handle_ops lock_handle_ops = {
+	.hop_addref = lock_handle_addref,
+	.hop_free   = lock_handle_free,
+};
+
+/**
+ *
+ * Allocate and initialize new lock structure.
+ *
+ * usage: pass in a resource on which you have done ldlm_resource_get
+ *	new lock will take over the refcount.
+ * returns: lock with refcount 2 - one for current caller and one for remote
+ */
+static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
+{
+	struct ldlm_lock *lock;
+
+	LASSERT(resource);
+
+	lock = kmem_cache_zalloc(ldlm_lock_slab, GFP_NOFS);
+	if (!lock)
+		return NULL;
+
+	spin_lock_init(&lock->l_lock);
+	lock->l_resource = resource;
+	lu_ref_add(&resource->lr_reference, "lock", lock);
+
+	atomic_set(&lock->l_refc, 2);
+	INIT_LIST_HEAD(&lock->l_res_link);
+	INIT_LIST_HEAD(&lock->l_lru);
+	INIT_LIST_HEAD(&lock->l_pending_chain);
+	INIT_LIST_HEAD(&lock->l_bl_ast);
+	INIT_LIST_HEAD(&lock->l_cp_ast);
+	INIT_LIST_HEAD(&lock->l_rk_ast);
+	init_waitqueue_head(&lock->l_waitq);
+	lock->l_blocking_lock = NULL;
+	INIT_LIST_HEAD(&lock->l_sl_mode);
+	INIT_LIST_HEAD(&lock->l_sl_policy);
+	RB_CLEAR_NODE(&lock->l_rb);
+
+	lprocfs_counter_incr(ldlm_res_to_ns(resource)->ns_stats,
+			     LDLM_NSS_LOCKS);
+	INIT_LIST_HEAD(&lock->l_handle.h_link);
+	class_handle_hash(&lock->l_handle, &lock_handle_ops);
+
+	lu_ref_init(&lock->l_reference);
+	lu_ref_add(&lock->l_reference, "hash", lock);
+	lock->l_callback_timeout = 0;
+
+#if LUSTRE_TRACKS_LOCK_EXP_REFS
+	INIT_LIST_HEAD(&lock->l_exp_refs_link);
+	lock->l_exp_refs_nr = 0;
+	lock->l_exp_refs_target = NULL;
+#endif
+
+	return lock;
+}
+
+/**
+ * Moves LDLM lock \a lock to another resource.
+ * This is used on client when server returns some other lock than requested
+ * (typically as a result of intent operation)
+ */
+int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
+			      const struct ldlm_res_id *new_resid)
+{
+	struct ldlm_resource *oldres = lock->l_resource;
+	struct ldlm_resource *newres;
+	int type;
+
+	lock_res_and_lock(lock);
+	if (memcmp(new_resid, &lock->l_resource->lr_name,
+		   sizeof(lock->l_resource->lr_name)) == 0) {
+		/* Nothing to do */
+		unlock_res_and_lock(lock);
+		return 0;
+	}
+
+	LASSERT(new_resid->name[0] != 0);
+
+	/* This function assumes that the lock isn't on any lists */
+	LASSERT(list_empty(&lock->l_res_link));
+
+	type = oldres->lr_type;
+	unlock_res_and_lock(lock);
+
+	newres = ldlm_resource_get(ns, NULL, new_resid, type, 1);
+	if (IS_ERR(newres))
+		return PTR_ERR(newres);
+
+	lu_ref_add(&newres->lr_reference, "lock", lock);
+	/*
+	 * To flip the lock from the old to the new resource, lock, oldres and
+	 * newres have to be locked. Resource spin-locks are nested within
+	 * lock->l_lock, and are taken in the memory address order to avoid
+	 * dead-locks.
+	 */
+	spin_lock(&lock->l_lock);
+	oldres = lock->l_resource;
+	if (oldres < newres) {
+		lock_res(oldres);
+		lock_res_nested(newres, LRT_NEW);
+	} else {
+		lock_res(newres);
+		lock_res_nested(oldres, LRT_NEW);
+	}
+	LASSERT(memcmp(new_resid, &oldres->lr_name,
+		       sizeof(oldres->lr_name)) != 0);
+	lock->l_resource = newres;
+	unlock_res(oldres);
+	unlock_res_and_lock(lock);
+
+	/* ...and the flowers are still standing! */
+	lu_ref_del(&oldres->lr_reference, "lock", lock);
+	ldlm_resource_putref(oldres);
+
+	return 0;
+}
+
+/** \defgroup ldlm_handles LDLM HANDLES
+ * Ways to get hold of locks without any addresses.
+ * @{
+ */
+
+/**
+ * Fills in handle for LDLM lock \a lock into supplied \a lockh
+ * Does not take any references.
+ */
+void ldlm_lock2handle(const struct ldlm_lock *lock, struct lustre_handle *lockh)
+{
+	lockh->cookie = lock->l_handle.h_cookie;
+}
+EXPORT_SYMBOL(ldlm_lock2handle);
+
+/**
+ * Obtain a lock reference by handle.
+ *
+ * if \a flags: atomically get the lock and set the flags.
+ *	      Return NULL if flag already set
+ */
+struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
+				     __u64 flags)
+{
+	struct ldlm_lock *lock;
+
+	LASSERT(handle);
+
+	lock = class_handle2object(handle->cookie, NULL);
+	if (!lock)
+		return NULL;
+
+	if (lock->l_export && lock->l_export->exp_failed) {
+		CDEBUG(D_INFO, "lock export failed: lock %p, exp %p\n",
+		       lock, lock->l_export);
+		LDLM_LOCK_PUT(lock);
+		return NULL;
+	}
+
+	/* It's unlikely but possible that someone marked the lock as
+	 * destroyed after we did handle2object on it
+	 */
+	if (flags == 0 && !ldlm_is_destroyed(lock)) {
+		lu_ref_add(&lock->l_reference, "handle", current);
+		return lock;
+	}
+
+	lock_res_and_lock(lock);
+
+	LASSERT(lock->l_resource);
+
+	lu_ref_add_atomic(&lock->l_reference, "handle", current);
+	if (unlikely(ldlm_is_destroyed(lock))) {
+		unlock_res_and_lock(lock);
+		CDEBUG(D_INFO, "lock already destroyed: lock %p\n", lock);
+		LDLM_LOCK_PUT(lock);
+		return NULL;
+	}
+
+	if (flags) {
+		if (lock->l_flags & flags) {
+			unlock_res_and_lock(lock);
+			LDLM_LOCK_PUT(lock);
+			return NULL;
+		}
+
+		lock->l_flags |= flags;
+	}
+
+	unlock_res_and_lock(lock);
+	return lock;
+}
+EXPORT_SYMBOL(__ldlm_handle2lock);
+/** @} ldlm_handles */
+
+/**
+ * Fill in "on the wire" representation for given LDLM lock into supplied
+ * lock descriptor \a desc structure.
+ */
+void ldlm_lock2desc(struct ldlm_lock *lock, struct ldlm_lock_desc *desc)
+{
+	ldlm_res2desc(lock->l_resource, &desc->l_resource);
+	desc->l_req_mode = lock->l_req_mode;
+	desc->l_granted_mode = lock->l_granted_mode;
+	ldlm_convert_policy_to_wire(lock->l_resource->lr_type,
+				    &lock->l_policy_data,
+				    &desc->l_policy_data);
+}
+
+/**
+ * Add a lock to list of conflicting locks to send AST to.
+ *
+ * Only add if we have not sent a blocking AST to the lock yet.
+ */
+static void ldlm_add_bl_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
+				  struct list_head *work_list)
+{
+	if (!ldlm_is_ast_sent(lock)) {
+		LDLM_DEBUG(lock, "lock incompatible; sending blocking AST.");
+		ldlm_set_ast_sent(lock);
+		/* If the enqueuing client said so, tell the AST recipient to
+		 * discard dirty data, rather than writing back.
+		 */
+		if (ldlm_is_ast_discard_data(new))
+			ldlm_set_discard_data(lock);
+		LASSERT(list_empty(&lock->l_bl_ast));
+		list_add(&lock->l_bl_ast, work_list);
+		LDLM_LOCK_GET(lock);
+		LASSERT(!lock->l_blocking_lock);
+		lock->l_blocking_lock = LDLM_LOCK_GET(new);
+	}
+}
+
+/**
+ * Add a lock to list of just granted locks to send completion AST to.
+ */
+static void ldlm_add_cp_work_item(struct ldlm_lock *lock,
+				  struct list_head *work_list)
+{
+	if (!ldlm_is_cp_reqd(lock)) {
+		ldlm_set_cp_reqd(lock);
+		LDLM_DEBUG(lock, "lock granted; sending completion AST.");
+		LASSERT(list_empty(&lock->l_cp_ast));
+		list_add(&lock->l_cp_ast, work_list);
+		LDLM_LOCK_GET(lock);
+	}
+}
+
+/**
+ * Aggregator function to add AST work items into a list. Determines
+ * what sort of an AST work needs to be done and calls the proper
+ * adding function.
+ * Must be called with lr_lock held.
+ */
+static void ldlm_add_ast_work_item(struct ldlm_lock *lock,
+				   struct ldlm_lock *new,
+				   struct list_head *work_list)
+{
+	check_res_locked(lock->l_resource);
+	if (new)
+		ldlm_add_bl_work_item(lock, new, work_list);
+	else
+		ldlm_add_cp_work_item(lock, work_list);
+}
+
+/**
+ * Add specified reader/writer reference to LDLM lock with handle \a lockh.
+ * r/w reference type is determined by \a mode
+ * Calls ldlm_lock_addref_internal.
+ */
+void ldlm_lock_addref(const struct lustre_handle *lockh, enum ldlm_mode mode)
+{
+	struct ldlm_lock *lock;
+
+	lock = ldlm_handle2lock(lockh);
+	LASSERTF(lock, "Non-existing lock: %llx\n", lockh->cookie);
+	ldlm_lock_addref_internal(lock, mode);
+	LDLM_LOCK_PUT(lock);
+}
+EXPORT_SYMBOL(ldlm_lock_addref);
+
+/**
+ * Helper function.
+ * Add specified reader/writer reference to LDLM lock \a lock.
+ * r/w reference type is determined by \a mode
+ * Removes lock from LRU if it is there.
+ * Assumes the LDLM lock is already locked.
+ */
+void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
+				      enum ldlm_mode mode)
+{
+	ldlm_lock_remove_from_lru(lock);
+	if (mode & (LCK_NL | LCK_CR | LCK_PR)) {
+		lock->l_readers++;
+		lu_ref_add_atomic(&lock->l_reference, "reader", lock);
+	}
+	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS)) {
+		lock->l_writers++;
+		lu_ref_add_atomic(&lock->l_reference, "writer", lock);
+	}
+	LDLM_LOCK_GET(lock);
+	lu_ref_add_atomic(&lock->l_reference, "user", lock);
+	LDLM_DEBUG(lock, "ldlm_lock_addref(%s)", ldlm_lockname[mode]);
+}
+
+/**
+ * Attempts to add reader/writer reference to a lock with handle \a lockh, and
+ * fails if lock is already LDLM_FL_CBPENDING or destroyed.
+ *
+ * \retval 0 success, lock was addref-ed
+ *
+ * \retval -EAGAIN lock is being canceled.
+ */
+int ldlm_lock_addref_try(const struct lustre_handle *lockh, enum ldlm_mode mode)
+{
+	struct ldlm_lock *lock;
+	int	       result;
+
+	result = -EAGAIN;
+	lock = ldlm_handle2lock(lockh);
+	if (lock) {
+		lock_res_and_lock(lock);
+		if (lock->l_readers != 0 || lock->l_writers != 0 ||
+		    !ldlm_is_cbpending(lock)) {
+			ldlm_lock_addref_internal_nolock(lock, mode);
+			result = 0;
+		}
+		unlock_res_and_lock(lock);
+		LDLM_LOCK_PUT(lock);
+	}
+	return result;
+}
+EXPORT_SYMBOL(ldlm_lock_addref_try);
+
+/**
+ * Add specified reader/writer reference to LDLM lock \a lock.
+ * Locks LDLM lock and calls ldlm_lock_addref_internal_nolock to do the work.
+ * Only called for local locks.
+ */
+void ldlm_lock_addref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
+{
+	lock_res_and_lock(lock);
+	ldlm_lock_addref_internal_nolock(lock, mode);
+	unlock_res_and_lock(lock);
+}
+
+/**
+ * Removes reader/writer reference for LDLM lock \a lock.
+ * Assumes LDLM lock is already locked.
+ * only called in ldlm_flock_destroy and for local locks.
+ * Does NOT add lock to LRU if no r/w references left to accommodate flock locks
+ * that cannot be placed in LRU.
+ */
+void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
+				      enum ldlm_mode mode)
+{
+	LDLM_DEBUG(lock, "ldlm_lock_decref(%s)", ldlm_lockname[mode]);
+	if (mode & (LCK_NL | LCK_CR | LCK_PR)) {
+		LASSERT(lock->l_readers > 0);
+		lu_ref_del(&lock->l_reference, "reader", lock);
+		lock->l_readers--;
+	}
+	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS)) {
+		LASSERT(lock->l_writers > 0);
+		lu_ref_del(&lock->l_reference, "writer", lock);
+		lock->l_writers--;
+	}
+
+	lu_ref_del(&lock->l_reference, "user", lock);
+	LDLM_LOCK_RELEASE(lock);    /* matches the LDLM_LOCK_GET() in addref */
+}
+
+/**
+ * Removes reader/writer reference for LDLM lock \a lock.
+ * Locks LDLM lock first.
+ * If the lock is determined to be client lock on a client and r/w refcount
+ * drops to zero and the lock is not blocked, the lock is added to LRU lock
+ * on the namespace.
+ * For blocked LDLM locks if r/w count drops to zero, blocking_ast is called.
+ */
+void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
+{
+	struct ldlm_namespace *ns;
+
+	lock_res_and_lock(lock);
+
+	ns = ldlm_lock_to_ns(lock);
+
+	ldlm_lock_decref_internal_nolock(lock, mode);
+
+	if ((ldlm_is_local(lock) || lock->l_req_mode == LCK_GROUP) &&
+	    !lock->l_readers && !lock->l_writers) {
+		/* If this is a local lock on a server namespace and this was
+		 * the last reference, cancel the lock.
+		 *
+		 * Group locks are special:
+		 * They must not go in LRU, but they are not called back
+		 * like non-group locks, instead they are manually released.
+		 * They have an l_writers reference which they keep until
+		 * they are manually released, so we remove them when they have
+		 * no more reader or writer references. - LU-6368
+		 */
+		ldlm_set_cbpending(lock);
+	}
+
+	if (!lock->l_readers && !lock->l_writers && ldlm_is_cbpending(lock)) {
+		/* If we received a blocked AST and this was the last reference,
+		 * run the callback.
+		 */
+		LDLM_DEBUG(lock, "final decref done on cbpending lock");
+
+		LDLM_LOCK_GET(lock); /* dropped by bl thread */
+		ldlm_lock_remove_from_lru(lock);
+		unlock_res_and_lock(lock);
+
+		if (ldlm_is_fail_loc(lock))
+			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
+
+		if (ldlm_is_atomic_cb(lock) ||
+		    ldlm_bl_to_thread_lock(ns, NULL, lock) != 0)
+			ldlm_handle_bl_callback(ns, NULL, lock);
+	} else if (!lock->l_readers && !lock->l_writers &&
+		   !ldlm_is_no_lru(lock) && !ldlm_is_bl_ast(lock)) {
+		LDLM_DEBUG(lock, "add lock into lru list");
+
+		/* If this is a client-side namespace and this was the last
+		 * reference, put it on the LRU.
+		 */
+		ldlm_lock_add_to_lru(lock);
+		unlock_res_and_lock(lock);
+
+		if (ldlm_is_fail_loc(lock))
+			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
+
+		/* Call ldlm_cancel_lru() only if EARLY_CANCEL and LRU RESIZE
+		 * are not supported by the server, otherwise, it is done on
+		 * enqueue.
+		 */
+		if (!exp_connect_cancelset(lock->l_conn_export) &&
+		    !ns_connect_lru_resize(ns))
+			ldlm_cancel_lru(ns, 0, LCF_ASYNC, 0);
+	} else {
+		LDLM_DEBUG(lock, "do not add lock into lru list");
+		unlock_res_and_lock(lock);
+	}
+}
+
+/**
+ * Decrease reader/writer refcount for LDLM lock with handle \a lockh
+ */
+void ldlm_lock_decref(const struct lustre_handle *lockh, enum ldlm_mode mode)
+{
+	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
+
+	LASSERTF(lock, "Non-existing lock: %#llx\n", lockh->cookie);
+	ldlm_lock_decref_internal(lock, mode);
+	LDLM_LOCK_PUT(lock);
+}
+EXPORT_SYMBOL(ldlm_lock_decref);
+
+/**
+ * Decrease reader/writer refcount for LDLM lock with handle
+ * \a lockh and mark it for subsequent cancellation once r/w refcount
+ * drops to zero instead of putting into LRU.
+ */
+void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh,
+				 enum ldlm_mode mode)
+{
+	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
+
+	LASSERT(lock);
+
+	LDLM_DEBUG(lock, "ldlm_lock_decref(%s)", ldlm_lockname[mode]);
+	lock_res_and_lock(lock);
+	ldlm_set_cbpending(lock);
+	unlock_res_and_lock(lock);
+	ldlm_lock_decref_internal(lock, mode);
+	LDLM_LOCK_PUT(lock);
+}
+EXPORT_SYMBOL(ldlm_lock_decref_and_cancel);
+
+struct sl_insert_point {
+	struct list_head *res_link;
+	struct list_head *mode_link;
+	struct list_head *policy_link;
+};
+
+/**
+ * Finds a position to insert the new lock into granted lock list.
+ *
+ * Used for locks eligible for skiplist optimization.
+ *
+ * Parameters:
+ *      queue [input]:  the granted list where search acts on;
+ *      req [input]:    the lock whose position to be located;
+ *      prev [output]:  positions within 3 lists to insert @req to
+ * Return Value:
+ *      filled @prev
+ * NOTE: called by
+ *  - ldlm_grant_lock_with_skiplist
+ */
+static void search_granted_lock(struct list_head *queue,
+				struct ldlm_lock *req,
+				struct sl_insert_point *prev)
+{
+	struct ldlm_lock *lock, *mode_end, *policy_end;
+
+	list_for_each_entry(lock, queue, l_res_link) {
+
+		mode_end = list_prev_entry(lock, l_sl_mode);
+
+		if (lock->l_req_mode != req->l_req_mode) {
+			/* jump to last lock of mode group */
+			lock = mode_end;
+			continue;
+		}
+
+		/* suitable mode group is found */
+		if (lock->l_resource->lr_type == LDLM_PLAIN) {
+			/* insert point is last lock of the mode group */
+			prev->res_link = &mode_end->l_res_link;
+			prev->mode_link = &mode_end->l_sl_mode;
+			prev->policy_link = &req->l_sl_policy;
+			return;
+		}
+
+		if (lock->l_resource->lr_type == LDLM_IBITS) {
+			for (;;) {
+				policy_end =
+					list_prev_entry(lock, l_sl_policy);
+
+				if (lock->l_policy_data.l_inodebits.bits ==
+				    req->l_policy_data.l_inodebits.bits) {
+					/* insert point is last lock of
+					 * the policy group
+					 */
+					prev->res_link =
+						&policy_end->l_res_link;
+					prev->mode_link =
+						&policy_end->l_sl_mode;
+					prev->policy_link =
+						&policy_end->l_sl_policy;
+					return;
+				}
+
+				if (policy_end == mode_end)
+					/* done with mode group */
+					break;
+
+				/* go to next policy group within mode group */
+				lock = list_next_entry(policy_end, l_res_link);
+			}  /* loop over policy groups within the mode group */
+
+			/* insert point is last lock of the mode group,
+			 * new policy group is started
+			 */
+			prev->res_link = &mode_end->l_res_link;
+			prev->mode_link = &mode_end->l_sl_mode;
+			prev->policy_link = &req->l_sl_policy;
+			return;
+		}
+
+		LDLM_ERROR(lock, "is not LDLM_PLAIN or LDLM_IBITS lock");
+		LBUG();
+	}
+
+	/* insert point is last lock on the queue,
+	 * new mode group and new policy group are started
+	 */
+	prev->res_link = queue->prev;
+	prev->mode_link = &req->l_sl_mode;
+	prev->policy_link = &req->l_sl_policy;
+}
+
+/**
+ * Add a lock into resource granted list after a position described by
+ * \a prev.
+ */
+static void ldlm_granted_list_add_lock(struct ldlm_lock *lock,
+				       struct sl_insert_point *prev)
+{
+	struct ldlm_resource *res = lock->l_resource;
+
+	check_res_locked(res);
+
+	ldlm_resource_dump(D_INFO, res);
+	LDLM_DEBUG(lock, "About to add lock:");
+
+	if (ldlm_is_destroyed(lock)) {
+		CDEBUG(D_OTHER, "Lock destroyed, not adding to resource\n");
+		return;
+	}
+
+	LASSERT(list_empty(&lock->l_res_link));
+	LASSERT(list_empty(&lock->l_sl_mode));
+	LASSERT(list_empty(&lock->l_sl_policy));
+
+	/*
+	 * lock->link == prev->link means lock is first starting the group.
+	 * Don't re-add to itself to suppress kernel warnings.
+	 */
+	if (&lock->l_res_link != prev->res_link)
+		list_add(&lock->l_res_link, prev->res_link);
+	if (&lock->l_sl_mode != prev->mode_link)
+		list_add(&lock->l_sl_mode, prev->mode_link);
+	if (&lock->l_sl_policy != prev->policy_link)
+		list_add(&lock->l_sl_policy, prev->policy_link);
+}
+
+/**
+ * Add a lock to granted list on a resource maintaining skiplist
+ * correctness.
+ */
+static void ldlm_grant_lock_with_skiplist(struct ldlm_lock *lock)
+{
+	struct sl_insert_point prev;
+
+	LASSERT(lock->l_req_mode == lock->l_granted_mode);
+
+	search_granted_lock(&lock->l_resource->lr_granted, lock, &prev);
+	ldlm_granted_list_add_lock(lock, &prev);
+}
+
+/**
+ * Perform lock granting bookkeeping.
+ *
+ * Includes putting the lock into granted list and updating lock mode.
+ * NOTE: called by
+ *  - ldlm_lock_enqueue
+ *  - ldlm_reprocess_queue
+ *  - ldlm_lock_convert
+ *
+ * must be called with lr_lock held
+ */
+void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
+{
+	struct ldlm_resource *res = lock->l_resource;
+
+	check_res_locked(res);
+
+	lock->l_granted_mode = lock->l_req_mode;
+
+	if (work_list && lock->l_completion_ast)
+		ldlm_add_ast_work_item(lock, NULL, work_list);
+
+	if (res->lr_type == LDLM_PLAIN || res->lr_type == LDLM_IBITS) {
+		ldlm_grant_lock_with_skiplist(lock);
+	} else if (res->lr_type == LDLM_EXTENT) {
+		ldlm_extent_add_lock(res, lock);
+	} else if (res->lr_type == LDLM_FLOCK) {
+		/*
+		 * We should not add locks to granted list in
+		 * the following cases:
+		 * - this is an UNLOCK but not a real lock;
+		 * - this is a TEST lock;
+		 * - this is a F_CANCELLK lock (async flock has req_mode == 0)
+		 * - this is a deadlock (flock cannot be granted)
+		 */
+		if (!lock->l_req_mode || lock->l_req_mode == LCK_NL ||
+		    ldlm_is_test_lock(lock) || ldlm_is_flock_deadlock(lock))
+			return;
+		ldlm_resource_add_lock(res, &res->lr_granted, lock);
+	} else {
+		LBUG();
+	}
+
+	ldlm_pool_add(&ldlm_res_to_ns(res)->ns_pool, lock);
+}
+
+/**
+ * Describe the overlap between two locks.  itree_overlap_cb data.
+ */
+struct lock_match_data {
+	struct ldlm_lock	*lmd_old;
+	struct ldlm_lock	*lmd_lock;
+	enum ldlm_mode		*lmd_mode;
+	union ldlm_policy_data	*lmd_policy;
+	__u64			 lmd_flags;
+	int			 lmd_unref;
+};
+
+/**
+ * Check if the given @lock meets the criteria for a match.
+ * A reference on the lock is taken if matched.
+ *
+ * \param lock	test-against this lock
+ * \param data	parameters
+ */
+static bool lock_matches(struct ldlm_lock *lock, void *vdata)
+{
+	struct lock_match_data *data = vdata;
+	union ldlm_policy_data *lpol = &lock->l_policy_data;
+	enum ldlm_mode match;
+
+	if (lock == data->lmd_old)
+		return true;
+
+	/*
+	 * Check if this lock can be matched.
+	 * Used by LU-2919(exclusive open) for open lease lock
+	 */
+	if (ldlm_is_excl(lock))
+		return false;
+
+	/*
+	 * llite sometimes wants to match locks that will be
+	 * canceled when their users drop, but we allow it to match
+	 * if it passes in CBPENDING and the lock still has users.
+	 * this is generally only going to be used by children
+	 * whose parents already hold a lock so forward progress
+	 * can still happen.
+	 */
+	if (ldlm_is_cbpending(lock) &&
+	    !(data->lmd_flags & LDLM_FL_CBPENDING))
+		return false;
+
+	if (!data->lmd_unref && ldlm_is_cbpending(lock) &&
+	    !lock->l_readers && !lock->l_writers)
+		return false;
+
+	if (!(lock->l_req_mode & *data->lmd_mode))
+		return false;
+	match = lock->l_req_mode;
+
+	switch (lock->l_resource->lr_type) {
+	case LDLM_EXTENT:
+		if (lpol->l_extent.start > data->lmd_policy->l_extent.start ||
+		    lpol->l_extent.end < data->lmd_policy->l_extent.end)
+			return false;
+
+		if (unlikely(match == LCK_GROUP) &&
+		    data->lmd_policy->l_extent.gid != LDLM_GID_ANY &&
+		    lpol->l_extent.gid != data->lmd_policy->l_extent.gid)
+			return false;
+		break;
+	case LDLM_IBITS:
+		/*
+		 * We match if we have existing lock with same or wider set
+		 * of bits.
+		 */
+		if ((lpol->l_inodebits.bits &
+		     data->lmd_policy->l_inodebits.bits) !=
+		    data->lmd_policy->l_inodebits.bits)
+			return false;
+		break;
+	default:
+		break;
+	}
+	/*
+	 * We match if we have existing lock with same or wider set
+	 * of bits.
+	 */
+	if (!data->lmd_unref && LDLM_HAVE_MASK(lock, GONE))
+		return false;
+
+	if (!equi(data->lmd_flags & LDLM_FL_LOCAL_ONLY, ldlm_is_local(lock)))
+		return false;
+
+	if (data->lmd_flags & LDLM_FL_TEST_LOCK) {
+		LDLM_LOCK_GET(lock);
+		ldlm_lock_touch_in_lru(lock);
+	} else {
+		ldlm_lock_addref_internal_nolock(lock, match);
+	}
+
+	*data->lmd_mode = match;
+	data->lmd_lock = lock;
+
+	return true;
+}
+
+/**
+ * Search for a lock with given parameters in interval trees.
+ *
+ * \param res	search for a lock in this resource
+ * \param data	parameters
+ *
+ * \retval	a referenced lock or NULL.
+ */
+static struct ldlm_lock *search_itree(struct ldlm_resource *res,
+				      struct lock_match_data *data)
+{
+	int idx;
+
+	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
+		struct ldlm_interval_tree *tree = &res->lr_itree[idx];
+
+		if (RB_EMPTY_ROOT(&tree->lit_root.rb_root))
+			continue;
+
+		if (!(tree->lit_mode & *data->lmd_mode))
+			continue;
+
+		ldlm_extent_search(&tree->lit_root,
+				   data->lmd_policy->l_extent.start,
+				   data->lmd_policy->l_extent.end,
+				   lock_matches, data);
+	}
+	return data->lmd_lock;
+}
+
+/**
+ * Search for a lock with given properties in a queue.
+ *
+ * \param queue	search for a lock in this queue
+ * \param data	parameters
+ *
+ * \retval	a referenced lock or NULL.
+ */
+static struct ldlm_lock *search_queue(struct list_head *queue,
+				      struct lock_match_data *data)
+{
+	struct ldlm_lock *lock;
+
+	list_for_each_entry(lock, queue, l_res_link)
+		if (lock_matches(lock, data))
+			return data->lmd_lock;
+	return NULL;
+}
+
+void ldlm_lock_fail_match_locked(struct ldlm_lock *lock)
+{
+	if ((lock->l_flags & LDLM_FL_FAIL_NOTIFIED) == 0) {
+		lock->l_flags |= LDLM_FL_FAIL_NOTIFIED;
+		wake_up_all(&lock->l_waitq);
+	}
+}
+
+/**
+ * Mark lock as "matchable" by OST.
+ *
+ * Used to prevent certain races in LOV/OSC where the lock is granted, but LVB
+ * is not yet valid.
+ * Assumes LDLM lock is already locked.
+ */
+void ldlm_lock_allow_match_locked(struct ldlm_lock *lock)
+{
+	ldlm_set_lvb_ready(lock);
+	wake_up_all(&lock->l_waitq);
+}
+EXPORT_SYMBOL(ldlm_lock_allow_match_locked);
+
+/**
+ * Mark lock as "matchable" by OST.
+ * Locks the lock and then \see ldlm_lock_allow_match_locked
+ */
+void ldlm_lock_allow_match(struct ldlm_lock *lock)
+{
+	lock_res_and_lock(lock);
+	ldlm_lock_allow_match_locked(lock);
+	unlock_res_and_lock(lock);
+}
+EXPORT_SYMBOL(ldlm_lock_allow_match);
+
+/**
+ * Attempt to find a lock with specified properties.
+ *
+ * Typically returns a reference to matched lock unless LDLM_FL_TEST_LOCK is
+ * set in \a flags
+ *
+ * Can be called in two ways:
+ *
+ * If 'ns' is NULL, then lockh describes an existing lock that we want to look
+ * for a duplicate of.
+ *
+ * Otherwise, all of the fields must be filled in, to match against.
+ *
+ * If 'flags' contains LDLM_FL_LOCAL_ONLY, then only match local locks on the
+ *     server (ie, connh is NULL)
+ * If 'flags' contains LDLM_FL_BLOCK_GRANTED, then only locks on the granted
+ *     list will be considered
+ * If 'flags' contains LDLM_FL_CBPENDING, then locks that have been marked
+ *     to be canceled can still be matched as long as they still have reader
+ *     or writer referneces
+ * If 'flags' contains LDLM_FL_TEST_LOCK, then don't actually reference a lock,
+ *     just tell us if we would have matched.
+ *
+ * \retval 1 if it finds an already-existing lock that is compatible; in this
+ * case, lockh is filled in with a addref()ed lock
+ *
+ * We also check security context, and if that fails we simply return 0 (to
+ * keep caller code unchanged), the context failure will be discovered by
+ * caller sometime later.
+ */
+enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
+			       const struct ldlm_res_id *res_id,
+			       enum ldlm_type type,
+			       union ldlm_policy_data *policy,
+			       enum ldlm_mode mode,
+			       struct lustre_handle *lockh, int unref)
+{
+	struct lock_match_data data = {
+		.lmd_old	= NULL,
+		.lmd_lock	= NULL,
+		.lmd_mode	= &mode,
+		.lmd_policy	= policy,
+		.lmd_flags	= flags,
+		.lmd_unref	= unref,
+	};
+	struct ldlm_resource *res;
+	struct ldlm_lock *lock;
+	int rc = 0;
+
+	if (!ns) {
+		data.lmd_old = ldlm_handle2lock(lockh);
+		LASSERT(data.lmd_old);
+
+		ns = ldlm_lock_to_ns(data.lmd_old);
+		res_id = &data.lmd_old->l_resource->lr_name;
+		type = data.lmd_old->l_resource->lr_type;
+		*data.lmd_mode = data.lmd_old->l_req_mode;
+	}
+
+	res = ldlm_resource_get(ns, NULL, res_id, type, 0);
+	if (IS_ERR(res)) {
+		LASSERT(!data.lmd_old);
+		return 0;
+	}
+
+	LDLM_RESOURCE_ADDREF(res);
+	lock_res(res);
+
+	if (res->lr_type == LDLM_EXTENT)
+		lock = search_itree(res, &data);
+	else
+		lock = search_queue(&res->lr_granted, &data);
+	if (lock) {
+		rc = 1;
+		goto out;
+	}
+	if (flags & LDLM_FL_BLOCK_GRANTED) {
+		rc = 0;
+		goto out;
+	}
+	lock = search_queue(&res->lr_waiting, &data);
+	if (lock) {
+		rc = 1;
+		goto out;
+	}
+out:
+	unlock_res(res);
+	LDLM_RESOURCE_DELREF(res);
+	ldlm_resource_putref(res);
+
+	if (lock) {
+		ldlm_lock2handle(lock, lockh);
+		if ((flags & LDLM_FL_LVB_READY) && !ldlm_is_lvb_ready(lock)) {
+			__u64 wait_flags = LDLM_FL_LVB_READY |
+				LDLM_FL_DESTROYED | LDLM_FL_FAIL_NOTIFIED;
+
+			if (lock->l_completion_ast) {
+				int err = lock->l_completion_ast(lock,
+							  LDLM_FL_WAIT_NOREPROC,
+								 NULL);
+				if (err) {
+					if (flags & LDLM_FL_TEST_LOCK)
+						LDLM_LOCK_RELEASE(lock);
+					else
+						ldlm_lock_decref_internal(lock,
+									  mode);
+					rc = 0;
+					goto out2;
+				}
+			}
+
+			/* XXX FIXME see comment on CAN_MATCH in lustre_dlm.h */
+			wait_event_idle_timeout(lock->l_waitq,
+						lock->l_flags & wait_flags,
+						obd_timeout * HZ);
+			if (!ldlm_is_lvb_ready(lock)) {
+				if (flags & LDLM_FL_TEST_LOCK)
+					LDLM_LOCK_RELEASE(lock);
+				else
+					ldlm_lock_decref_internal(lock, mode);
+				rc = 0;
+			}
+		}
+	}
+ out2:
+	if (rc) {
+		LDLM_DEBUG(lock, "matched (%llu %llu)",
+			   (type == LDLM_PLAIN || type == LDLM_IBITS) ?
+				res_id->name[2] : policy->l_extent.start,
+			   (type == LDLM_PLAIN || type == LDLM_IBITS) ?
+				res_id->name[3] : policy->l_extent.end);
+
+		/* check user's security context */
+		if (lock->l_conn_export &&
+		    sptlrpc_import_check_ctx(
+				class_exp2cliimp(lock->l_conn_export))) {
+			if (!(flags & LDLM_FL_TEST_LOCK))
+				ldlm_lock_decref_internal(lock, mode);
+			rc = 0;
+		}
+
+		if (flags & LDLM_FL_TEST_LOCK)
+			LDLM_LOCK_RELEASE(lock);
+
+	} else if (!(flags & LDLM_FL_TEST_LOCK)) {/*less verbose for test-only*/
+		LDLM_DEBUG_NOLOCK("not matched ns %p type %u mode %u res %llu/%llu (%llu %llu)",
+				  ns, type, mode, res_id->name[0],
+				  res_id->name[1],
+				  (type == LDLM_PLAIN || type == LDLM_IBITS) ?
+					res_id->name[2] : policy->l_extent.start,
+				  (type == LDLM_PLAIN || type == LDLM_IBITS) ?
+					res_id->name[3] : policy->l_extent.end);
+	}
+	if (data.lmd_old)
+		LDLM_LOCK_PUT(data.lmd_old);
+
+	return rc ? mode : 0;
+}
+EXPORT_SYMBOL(ldlm_lock_match);
+
+enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
+					   __u64 *bits)
+{
+	struct ldlm_lock *lock;
+	enum ldlm_mode mode = 0;
+
+	lock = ldlm_handle2lock(lockh);
+	if (lock) {
+		lock_res_and_lock(lock);
+		if (LDLM_HAVE_MASK(lock, GONE))
+			goto out;
+
+		if (ldlm_is_cbpending(lock) &&
+		    lock->l_readers == 0 && lock->l_writers == 0)
+			goto out;
+
+		if (bits)
+			*bits = lock->l_policy_data.l_inodebits.bits;
+		mode = lock->l_granted_mode;
+		ldlm_lock_addref_internal_nolock(lock, mode);
+	}
+
+out:
+	if (lock) {
+		unlock_res_and_lock(lock);
+		LDLM_LOCK_PUT(lock);
+	}
+	return mode;
+}
+EXPORT_SYMBOL(ldlm_revalidate_lock_handle);
+
+/** The caller must guarantee that the buffer is large enough. */
+int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
+		  enum req_location loc, void *data, int size)
+{
+	void *lvb;
+
+	LASSERT(data);
+	LASSERT(size >= 0);
+
+	switch (lock->l_lvb_type) {
+	case LVB_T_OST:
+		if (size == sizeof(struct ost_lvb)) {
+			if (loc == RCL_CLIENT)
+				lvb = req_capsule_client_swab_get(pill,
+								  &RMF_DLM_LVB,
+							lustre_swab_ost_lvb);
+			else
+				lvb = req_capsule_server_swab_get(pill,
+								  &RMF_DLM_LVB,
+							lustre_swab_ost_lvb);
+			if (unlikely(!lvb)) {
+				LDLM_ERROR(lock, "no LVB");
+				return -EPROTO;
+			}
+
+			memcpy(data, lvb, size);
+		} else if (size == sizeof(struct ost_lvb_v1)) {
+			struct ost_lvb *olvb = data;
+
+			if (loc == RCL_CLIENT)
+				lvb = req_capsule_client_swab_get(pill,
+								  &RMF_DLM_LVB,
+							lustre_swab_ost_lvb_v1);
+			else
+				lvb = req_capsule_server_sized_swab_get(pill,
+						&RMF_DLM_LVB, size,
+						lustre_swab_ost_lvb_v1);
+			if (unlikely(!lvb)) {
+				LDLM_ERROR(lock, "no LVB");
+				return -EPROTO;
+			}
+
+			memcpy(data, lvb, size);
+			olvb->lvb_mtime_ns = 0;
+			olvb->lvb_atime_ns = 0;
+			olvb->lvb_ctime_ns = 0;
+		} else {
+			LDLM_ERROR(lock, "Replied unexpected ost LVB size %d",
+				   size);
+			return -EINVAL;
+		}
+		break;
+	case LVB_T_LQUOTA:
+		if (size == sizeof(struct lquota_lvb)) {
+			if (loc == RCL_CLIENT)
+				lvb = req_capsule_client_swab_get(pill,
+								  &RMF_DLM_LVB,
+							lustre_swab_lquota_lvb);
+			else
+				lvb = req_capsule_server_swab_get(pill,
+								  &RMF_DLM_LVB,
+							lustre_swab_lquota_lvb);
+			if (unlikely(!lvb)) {
+				LDLM_ERROR(lock, "no LVB");
+				return -EPROTO;
+			}
+
+			memcpy(data, lvb, size);
+		} else {
+			LDLM_ERROR(lock,
+				   "Replied unexpected lquota LVB size %d",
+				   size);
+			return -EINVAL;
+		}
+		break;
+	case LVB_T_LAYOUT:
+		if (size == 0)
+			break;
+
+		if (loc == RCL_CLIENT)
+			lvb = req_capsule_client_get(pill, &RMF_DLM_LVB);
+		else
+			lvb = req_capsule_server_get(pill, &RMF_DLM_LVB);
+		if (unlikely(!lvb)) {
+			LDLM_ERROR(lock, "no LVB");
+			return -EPROTO;
+		}
+
+		memcpy(data, lvb, size);
+		break;
+	default:
+		LDLM_ERROR(lock, "Unknown LVB type: %d", lock->l_lvb_type);
+		dump_stack();
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/**
+ * Create and fill in new LDLM lock with specified properties.
+ * Returns a referenced lock
+ */
+struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
+				   const struct ldlm_res_id *res_id,
+				   enum ldlm_type type,
+				   enum ldlm_mode mode,
+				   const struct ldlm_callback_suite *cbs,
+				   void *data, __u32 lvb_len,
+				   enum lvb_type lvb_type)
+{
+	struct ldlm_lock *lock;
+	struct ldlm_resource *res;
+	int rc;
+
+	res = ldlm_resource_get(ns, NULL, res_id, type, 1);
+	if (IS_ERR(res))
+		return ERR_CAST(res);
+
+	lock = ldlm_lock_new(res);
+	if (!lock) {
+		ldlm_resource_putref(res);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	lock->l_req_mode = mode;
+	lock->l_ast_data = data;
+	lock->l_pid = current->pid;
+	if (cbs) {
+		lock->l_blocking_ast = cbs->lcs_blocking;
+		lock->l_completion_ast = cbs->lcs_completion;
+		lock->l_glimpse_ast = cbs->lcs_glimpse;
+	}
+
+	if (lvb_len) {
+		lock->l_lvb_len = lvb_len;
+		lock->l_lvb_data = kzalloc(lvb_len, GFP_NOFS);
+		if (!lock->l_lvb_data) {
+			rc = -ENOMEM;
+			goto out;
+		}
+	}
+
+	lock->l_lvb_type = lvb_type;
+	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_NEW_LOCK)) {
+		rc = -ENOENT;
+		goto out;
+	}
+
+	return lock;
+
+out:
+	ldlm_lock_destroy(lock);
+	LDLM_LOCK_RELEASE(lock);
+	return ERR_PTR(rc);
+}
+
+
+
+/**
+ * Enqueue (request) a lock.
+ * On the client this is called from ldlm_cli_enqueue_fini
+ * after we already got an initial reply from the server with some status.
+ *
+ * Does not block. As a result of enqueue the lock would be put
+ * into granted or waiting list.
+ */
+enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
+				  struct ldlm_lock **lockp,
+				  void *cookie, __u64 *flags)
+{
+	struct ldlm_lock *lock = *lockp;
+	struct ldlm_resource *res = lock->l_resource;
+
+	lock_res_and_lock(lock);
+	if (lock->l_req_mode == lock->l_granted_mode) {
+		/* The server returned a blocked lock, but it was granted
+		 * before we got a chance to actually enqueue it.  We don't
+		 * need to do anything else.
+		 */
+		*flags &= ~LDLM_FL_BLOCKED_MASK;
+		goto out;
+	}
+
+	ldlm_resource_unlink_lock(lock);
+
+	/* Some flags from the enqueue want to make it into the AST, via the
+	 * lock's l_flags.
+	 */
+	if (*flags & LDLM_FL_AST_DISCARD_DATA)
+		ldlm_set_ast_discard_data(lock);
+	if (*flags & LDLM_FL_TEST_LOCK)
+		ldlm_set_test_lock(lock);
+
+	/*
+	 * This distinction between local lock trees is very important; a client
+	 * namespace only has information about locks taken by that client, and
+	 * thus doesn't have enough information to decide for itself if it can
+	 * be granted (below).  In this case, we do exactly what the server
+	 * tells us to do, as dictated by the 'flags'.
+	 */
+	if (*flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED))
+		ldlm_resource_add_lock(res, &res->lr_waiting, lock);
+	else
+		ldlm_grant_lock(lock, NULL);
+
+out:
+	unlock_res_and_lock(lock);
+	return ELDLM_OK;
+}
+
+/**
+ * Process a call to blocking AST callback for a lock in ast_work list
+ */
+static int
+ldlm_work_bl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
+{
+	struct ldlm_cb_set_arg *arg = opaq;
+	struct ldlm_lock_desc   d;
+	int		     rc;
+	struct ldlm_lock       *lock;
+
+	if (list_empty(arg->list))
+		return -ENOENT;
+
+	lock = list_first_entry(arg->list, struct ldlm_lock, l_bl_ast);
+
+	/* nobody should touch l_bl_ast */
+	lock_res_and_lock(lock);
+	list_del_init(&lock->l_bl_ast);
+
+	LASSERT(ldlm_is_ast_sent(lock));
+	LASSERT(lock->l_bl_ast_run == 0);
+	LASSERT(lock->l_blocking_lock);
+	lock->l_bl_ast_run++;
+	unlock_res_and_lock(lock);
+
+	ldlm_lock2desc(lock->l_blocking_lock, &d);
+
+	rc = lock->l_blocking_ast(lock, &d, (void *)arg, LDLM_CB_BLOCKING);
+	LDLM_LOCK_RELEASE(lock->l_blocking_lock);
+	lock->l_blocking_lock = NULL;
+	LDLM_LOCK_RELEASE(lock);
+
+	return rc;
+}
+
+/**
+ * Process a call to completion AST callback for a lock in ast_work list
+ */
+static int
+ldlm_work_cp_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
+{
+	struct ldlm_cb_set_arg  *arg = opaq;
+	int		      rc = 0;
+	struct ldlm_lock	*lock;
+	ldlm_completion_callback completion_callback;
+
+	if (list_empty(arg->list))
+		return -ENOENT;
+
+	lock = list_first_entry(arg->list, struct ldlm_lock, l_cp_ast);
+
+	/* It's possible to receive a completion AST before we've set
+	 * the l_completion_ast pointer: either because the AST arrived
+	 * before the reply, or simply because there's a small race
+	 * window between receiving the reply and finishing the local
+	 * enqueue. (bug 842)
+	 *
+	 * This can't happen with the blocking_ast, however, because we
+	 * will never call the local blocking_ast until we drop our
+	 * reader/writer reference, which we won't do until we get the
+	 * reply and finish enqueueing.
+	 */
+
+	/* nobody should touch l_cp_ast */
+	lock_res_and_lock(lock);
+	list_del_init(&lock->l_cp_ast);
+	LASSERT(ldlm_is_cp_reqd(lock));
+	/* save l_completion_ast since it can be changed by
+	 * mds_intent_policy(), see bug 14225
+	 */
+	completion_callback = lock->l_completion_ast;
+	ldlm_clear_cp_reqd(lock);
+	unlock_res_and_lock(lock);
+
+	if (completion_callback)
+		rc = completion_callback(lock, 0, (void *)arg);
+	LDLM_LOCK_RELEASE(lock);
+
+	return rc;
+}
+
+/**
+ * Process a call to revocation AST callback for a lock in ast_work list
+ */
+static int
+ldlm_work_revoke_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
+{
+	struct ldlm_cb_set_arg *arg = opaq;
+	struct ldlm_lock_desc   desc;
+	int		     rc;
+	struct ldlm_lock       *lock;
+
+	if (list_empty(arg->list))
+		return -ENOENT;
+
+	lock = list_first_entry(arg->list, struct ldlm_lock, l_rk_ast);
+	list_del_init(&lock->l_rk_ast);
+
+	/* the desc just pretend to exclusive */
+	ldlm_lock2desc(lock, &desc);
+	desc.l_req_mode = LCK_EX;
+	desc.l_granted_mode = 0;
+
+	rc = lock->l_blocking_ast(lock, &desc, (void *)arg, LDLM_CB_BLOCKING);
+	LDLM_LOCK_RELEASE(lock);
+
+	return rc;
+}
+
+/**
+ * Process a call to glimpse AST callback for a lock in ast_work list
+ */
+static int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
+{
+	struct ldlm_cb_set_arg		*arg = opaq;
+	struct ldlm_glimpse_work	*gl_work;
+	struct ldlm_lock		*lock;
+	int				 rc = 0;
+
+	if (list_empty(arg->list))
+		return -ENOENT;
+
+	gl_work = list_first_entry(arg->list, struct ldlm_glimpse_work,
+			     gl_list);
+	list_del_init(&gl_work->gl_list);
+
+	lock = gl_work->gl_lock;
+
+	/* transfer the glimpse descriptor to ldlm_cb_set_arg */
+	arg->gl_desc = gl_work->gl_desc;
+
+	/* invoke the actual glimpse callback */
+	if (lock->l_glimpse_ast(lock, (void *)arg) == 0)
+		rc = 1;
+
+	LDLM_LOCK_RELEASE(lock);
+
+	if ((gl_work->gl_flags & LDLM_GL_WORK_NOFREE) == 0)
+		kfree(gl_work);
+
+	return rc;
+}
+
+/**
+ * Process list of locks in need of ASTs being sent.
+ *
+ * Used on server to send multiple ASTs together instead of sending one by
+ * one.
+ */
+int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
+		      enum ldlm_desc_ast_t ast_type)
+{
+	struct ldlm_cb_set_arg *arg;
+	set_producer_func       work_ast_lock;
+	int		     rc;
+
+	if (list_empty(rpc_list))
+		return 0;
+
+	arg = kzalloc(sizeof(*arg), GFP_NOFS);
+	if (!arg)
+		return -ENOMEM;
+
+	atomic_set(&arg->restart, 0);
+	arg->list = rpc_list;
+
+	switch (ast_type) {
+	case LDLM_WORK_BL_AST:
+		arg->type = LDLM_BL_CALLBACK;
+		work_ast_lock = ldlm_work_bl_ast_lock;
+		break;
+	case LDLM_WORK_CP_AST:
+		arg->type = LDLM_CP_CALLBACK;
+		work_ast_lock = ldlm_work_cp_ast_lock;
+		break;
+	case LDLM_WORK_REVOKE_AST:
+		arg->type = LDLM_BL_CALLBACK;
+		work_ast_lock = ldlm_work_revoke_ast_lock;
+		break;
+	case LDLM_WORK_GL_AST:
+		arg->type = LDLM_GL_CALLBACK;
+		work_ast_lock = ldlm_work_gl_ast_lock;
+		break;
+	default:
+		LBUG();
+	}
+
+	/* We create a ptlrpc request set with flow control extension.
+	 * This request set will use the work_ast_lock function to produce new
+	 * requests and will send a new request each time one completes in order
+	 * to keep the number of requests in flight to ns_max_parallel_ast
+	 */
+	arg->set = ptlrpc_prep_fcset(ns->ns_max_parallel_ast ? : UINT_MAX,
+				     work_ast_lock, arg);
+	if (!arg->set) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	ptlrpc_set_wait(arg->set);
+	ptlrpc_set_destroy(arg->set);
+
+	rc = atomic_read(&arg->restart) ? -ERESTART : 0;
+	goto out;
+out:
+	kfree(arg);
+	return rc;
+}
+
+static bool is_bl_done(struct ldlm_lock *lock)
+{
+	bool bl_done = true;
+
+	if (!ldlm_is_bl_done(lock)) {
+		lock_res_and_lock(lock);
+		bl_done = ldlm_is_bl_done(lock);
+		unlock_res_and_lock(lock);
+	}
+
+	return bl_done;
+}
+
+/**
+ * Helper function to call blocking AST for LDLM lock \a lock in a
+ * "cancelling" mode.
+ */
+void ldlm_cancel_callback(struct ldlm_lock *lock)
+{
+	check_res_locked(lock->l_resource);
+	if (!ldlm_is_cancel(lock)) {
+		ldlm_set_cancel(lock);
+		if (lock->l_blocking_ast) {
+			unlock_res_and_lock(lock);
+			lock->l_blocking_ast(lock, NULL, lock->l_ast_data,
+					     LDLM_CB_CANCELING);
+			lock_res_and_lock(lock);
+		} else {
+			LDLM_DEBUG(lock, "no blocking ast");
+		}
+		/* only canceller can set bl_done bit */
+		ldlm_set_bl_done(lock);
+		wake_up_all(&lock->l_waitq);
+	} else if (!ldlm_is_bl_done(lock)) {
+		/*
+		 * The lock is guaranteed to have been canceled once
+		 * returning from this function.
+		 */
+		unlock_res_and_lock(lock);
+		wait_event_idle(lock->l_waitq, is_bl_done(lock));
+		lock_res_and_lock(lock);
+	}
+}
+
+/**
+ * Remove skiplist-enabled LDLM lock \a req from granted list
+ */
+void ldlm_unlink_lock_skiplist(struct ldlm_lock *req)
+{
+	if (req->l_resource->lr_type != LDLM_PLAIN &&
+	    req->l_resource->lr_type != LDLM_IBITS)
+		return;
+
+	list_del_init(&req->l_sl_policy);
+	list_del_init(&req->l_sl_mode);
+}
+
+/**
+ * Attempts to cancel LDLM lock \a lock that has no reader/writer references.
+ */
+void ldlm_lock_cancel(struct ldlm_lock *lock)
+{
+	struct ldlm_resource *res;
+	struct ldlm_namespace *ns;
+
+	lock_res_and_lock(lock);
+
+	res = lock->l_resource;
+	ns  = ldlm_res_to_ns(res);
+
+	/* Please do not, no matter how tempting, remove this LBUG without
+	 * talking to me first. -phik
+	 */
+	if (lock->l_readers || lock->l_writers) {
+		LDLM_ERROR(lock, "lock still has references");
+		LBUG();
+	}
+
+	/* Releases cancel callback. */
+	ldlm_cancel_callback(lock);
+
+	ldlm_resource_unlink_lock(lock);
+	ldlm_lock_destroy_nolock(lock);
+
+	if (lock->l_granted_mode == lock->l_req_mode)
+		ldlm_pool_del(&ns->ns_pool, lock);
+
+	/* Make sure we will not be called again for same lock what is possible
+	 * if not to zero out lock->l_granted_mode
+	 */
+	lock->l_granted_mode = LCK_MINMODE;
+	unlock_res_and_lock(lock);
+}
+EXPORT_SYMBOL(ldlm_lock_cancel);
+
+/**
+ * Set opaque data into the lock that only makes sense to upper layer.
+ */
+int ldlm_lock_set_data(const struct lustre_handle *lockh, void *data)
+{
+	struct ldlm_lock *lock = ldlm_handle2lock(lockh);
+	int rc = -EINVAL;
+
+	if (lock) {
+		if (!lock->l_ast_data)
+			lock->l_ast_data = data;
+		if (lock->l_ast_data == data)
+			rc = 0;
+		LDLM_LOCK_PUT(lock);
+	}
+	return rc;
+}
+EXPORT_SYMBOL(ldlm_lock_set_data);
+
+struct export_cl_data {
+	struct obd_export	*ecl_exp;
+	int			ecl_loop;
+};
+
+/**
+ * Print lock with lock handle \a lockh description into debug log.
+ *
+ * Used when printing all locks on a resource for debug purposes.
+ */
+void ldlm_lock_dump_handle(int level, const struct lustre_handle *lockh)
+{
+	struct ldlm_lock *lock;
+
+	if (!((libcfs_debug | D_ERROR) & level))
+		return;
+
+	lock = ldlm_handle2lock(lockh);
+	if (!lock)
+		return;
+
+	LDLM_DEBUG_LIMIT(level, lock, "###");
+
+	LDLM_LOCK_PUT(lock);
+}
+EXPORT_SYMBOL(ldlm_lock_dump_handle);
+
+/**
+ * Print lock information with custom message into debug log.
+ * Helper function.
+ */
+void _ldlm_lock_debug(struct ldlm_lock *lock,
+		      struct libcfs_debug_msg_data *msgdata,
+		      const char *fmt, ...)
+{
+	va_list args;
+	struct obd_export *exp = lock->l_export;
+	struct ldlm_resource *resource = lock->l_resource;
+	char *nid = "local";
+
+	va_start(args, fmt);
+
+	if (exp && exp->exp_connection) {
+		nid = libcfs_nid2str(exp->exp_connection->c_peer.nid);
+	} else if (exp && exp->exp_obd) {
+		struct obd_import *imp = exp->exp_obd->u.cli.cl_import;
+
+		nid = libcfs_nid2str(imp->imp_connection->c_peer.nid);
+	}
+
+	if (!resource) {
+		libcfs_debug_vmsg2(msgdata, fmt, args,
+				   " ns: \?\? lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: \?\? rrc=\?\? type: \?\?\? flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				   lock,
+				   lock->l_handle.h_cookie,
+				   atomic_read(&lock->l_refc),
+				   lock->l_readers, lock->l_writers,
+				   ldlm_lockname[lock->l_granted_mode],
+				   ldlm_lockname[lock->l_req_mode],
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
+				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   lock->l_pid, lock->l_callback_timeout,
+				   lock->l_lvb_type);
+		va_end(args);
+		return;
+	}
+
+	switch (resource->lr_type) {
+	case LDLM_EXTENT:
+		libcfs_debug_vmsg2(msgdata, fmt, args,
+				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s [%llu->%llu] (req %llu->%llu) flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				   ldlm_lock_to_ns_name(lock), lock,
+				   lock->l_handle.h_cookie,
+				   atomic_read(&lock->l_refc),
+				   lock->l_readers, lock->l_writers,
+				   ldlm_lockname[lock->l_granted_mode],
+				   ldlm_lockname[lock->l_req_mode],
+				   PLDLMRES(resource),
+				   atomic_read(&resource->lr_refcount),
+				   ldlm_typename[resource->lr_type],
+				   lock->l_policy_data.l_extent.start,
+				   lock->l_policy_data.l_extent.end,
+				   lock->l_req_extent.start,
+				   lock->l_req_extent.end,
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
+				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   lock->l_pid, lock->l_callback_timeout,
+				   lock->l_lvb_type);
+		break;
+
+	case LDLM_FLOCK:
+		libcfs_debug_vmsg2(msgdata, fmt, args,
+				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s pid: %d [%llu->%llu] flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu\n",
+				   ldlm_lock_to_ns_name(lock), lock,
+				   lock->l_handle.h_cookie,
+				   atomic_read(&lock->l_refc),
+				   lock->l_readers, lock->l_writers,
+				   ldlm_lockname[lock->l_granted_mode],
+				   ldlm_lockname[lock->l_req_mode],
+				   PLDLMRES(resource),
+				   atomic_read(&resource->lr_refcount),
+				   ldlm_typename[resource->lr_type],
+				   lock->l_policy_data.l_flock.pid,
+				   lock->l_policy_data.l_flock.start,
+				   lock->l_policy_data.l_flock.end,
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
+				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   lock->l_pid, lock->l_callback_timeout);
+		break;
+
+	case LDLM_IBITS:
+		libcfs_debug_vmsg2(msgdata, fmt, args,
+				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				   ldlm_lock_to_ns_name(lock),
+				   lock, lock->l_handle.h_cookie,
+				   atomic_read(&lock->l_refc),
+				   lock->l_readers, lock->l_writers,
+				   ldlm_lockname[lock->l_granted_mode],
+				   ldlm_lockname[lock->l_req_mode],
+				   PLDLMRES(resource),
+				   lock->l_policy_data.l_inodebits.bits,
+				   atomic_read(&resource->lr_refcount),
+				   ldlm_typename[resource->lr_type],
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
+				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   lock->l_pid, lock->l_callback_timeout,
+				   lock->l_lvb_type);
+		break;
+
+	default:
+		libcfs_debug_vmsg2(msgdata, fmt, args,
+				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
+				   ldlm_lock_to_ns_name(lock),
+				   lock, lock->l_handle.h_cookie,
+				   atomic_read(&lock->l_refc),
+				   lock->l_readers, lock->l_writers,
+				   ldlm_lockname[lock->l_granted_mode],
+				   ldlm_lockname[lock->l_req_mode],
+				   PLDLMRES(resource),
+				   atomic_read(&resource->lr_refcount),
+				   ldlm_typename[resource->lr_type],
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
+				   exp ? atomic_read(&exp->exp_refcount) : -99,
+				   lock->l_pid, lock->l_callback_timeout,
+				   lock->l_lvb_type);
+		break;
+	}
+	va_end(args);
+}
+EXPORT_SYMBOL(_ldlm_lock_debug);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_lockd.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_lockd.c
new file mode 100644
index 000000000000..f410ef6c02ef
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_lockd.c
@@ -0,0 +1,1154 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2010, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/ldlm/ldlm_lockd.c
+ *
+ * Author: Peter Braam <braam@clusterfs.com>
+ * Author: Phil Schwan <phil@clusterfs.com>
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+
+#include <linux/kthread.h>
+#include <linux/sched/mm.h>
+#include <lustre_dlm.h>
+#include <obd_class.h>
+#include <linux/list.h>
+#include "ldlm_internal.h"
+
+static int ldlm_num_threads;
+module_param(ldlm_num_threads, int, 0444);
+MODULE_PARM_DESC(ldlm_num_threads, "number of DLM service threads to start");
+
+static char *ldlm_cpts;
+module_param(ldlm_cpts, charp, 0444);
+MODULE_PARM_DESC(ldlm_cpts, "CPU partitions ldlm threads should run on");
+
+static struct mutex	ldlm_ref_mutex;
+static int ldlm_refcount;
+
+static struct kobject *ldlm_kobj;
+struct kset *ldlm_ns_kset;
+static struct kset *ldlm_svc_kset;
+
+struct ldlm_cb_async_args {
+	struct ldlm_cb_set_arg *ca_set_arg;
+	struct ldlm_lock       *ca_lock;
+};
+
+/* LDLM state */
+
+static struct ldlm_state *ldlm_state;
+
+#define ELT_STOPPED   0
+#define ELT_READY     1
+#define ELT_TERMINATE 2
+
+struct ldlm_bl_pool {
+	spinlock_t		blp_lock;
+
+	/*
+	 * blp_prio_list is used for callbacks that should be handled
+	 * as a priority. It is used for LDLM_FL_DISCARD_DATA requests.
+	 * see bug 13843
+	 */
+	struct list_head	      blp_prio_list;
+
+	/*
+	 * blp_list is used for all other callbacks which are likely
+	 * to take longer to process.
+	 */
+	struct list_head	      blp_list;
+
+	wait_queue_head_t	     blp_waitq;
+	struct completion	blp_comp;
+	atomic_t	    blp_num_threads;
+	atomic_t	    blp_busy_threads;
+	int		     blp_min_threads;
+	int		     blp_max_threads;
+};
+
+struct ldlm_bl_work_item {
+	struct list_head	      blwi_entry;
+	struct ldlm_namespace  *blwi_ns;
+	struct ldlm_lock_desc   blwi_ld;
+	struct ldlm_lock       *blwi_lock;
+	struct list_head	      blwi_head;
+	int		     blwi_count;
+	struct completion	blwi_comp;
+	enum ldlm_cancel_flags  blwi_flags;
+	int		     blwi_mem_pressure;
+};
+
+/**
+ * Callback handler for receiving incoming blocking ASTs.
+ *
+ * This can only happen on client side.
+ */
+void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
+			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock)
+{
+	int do_ast;
+
+	LDLM_DEBUG(lock, "client blocking AST callback handler");
+
+	lock_res_and_lock(lock);
+	ldlm_set_cbpending(lock);
+
+	if (ldlm_is_cancel_on_block(lock))
+		ldlm_set_cancel(lock);
+
+	do_ast = !lock->l_readers && !lock->l_writers;
+	unlock_res_and_lock(lock);
+
+	if (do_ast) {
+		CDEBUG(D_DLMTRACE,
+		       "Lock %p already unused, calling callback (%p)\n", lock,
+		       lock->l_blocking_ast);
+		if (lock->l_blocking_ast)
+			lock->l_blocking_ast(lock, ld, lock->l_ast_data,
+					     LDLM_CB_BLOCKING);
+	} else {
+		CDEBUG(D_DLMTRACE,
+		       "Lock %p is referenced, will be cancelled later\n",
+		       lock);
+	}
+
+	LDLM_DEBUG(lock, "client blocking callback handler END");
+	LDLM_LOCK_RELEASE(lock);
+}
+
+/**
+ * Callback handler for receiving incoming completion ASTs.
+ *
+ * This only can happen on client side.
+ */
+static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
+				    struct ldlm_namespace *ns,
+				    struct ldlm_request *dlm_req,
+				    struct ldlm_lock *lock)
+{
+	int lvb_len;
+	LIST_HEAD(ast_list);
+	int rc = 0;
+
+	LDLM_DEBUG(lock, "client completion callback handler START");
+
+	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE)) {
+		int to = HZ;
+
+		while (to > 0) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			schedule_timeout(to);
+			if (lock->l_granted_mode == lock->l_req_mode ||
+			    ldlm_is_destroyed(lock))
+				break;
+		}
+	}
+
+	lvb_len = req_capsule_get_size(&req->rq_pill, &RMF_DLM_LVB, RCL_CLIENT);
+	if (lvb_len < 0) {
+		LDLM_ERROR(lock, "Fail to get lvb_len, rc = %d", lvb_len);
+		rc = lvb_len;
+		goto out;
+	} else if (lvb_len > 0) {
+		if (lock->l_lvb_len > 0) {
+			/* for extent lock, lvb contains ost_lvb{}. */
+			LASSERT(lock->l_lvb_data);
+
+			if (unlikely(lock->l_lvb_len < lvb_len)) {
+				LDLM_ERROR(lock,
+					   "Replied LVB is larger than expectation, expected = %d, replied = %d",
+					   lock->l_lvb_len, lvb_len);
+				rc = -EINVAL;
+				goto out;
+			}
+		} else if (ldlm_has_layout(lock)) { /* for layout lock, lvb has
+						     * variable length
+						     */
+			void *lvb_data;
+
+			lvb_data = kzalloc(lvb_len, GFP_NOFS);
+			if (!lvb_data) {
+				LDLM_ERROR(lock, "No memory: %d.\n", lvb_len);
+				rc = -ENOMEM;
+				goto out;
+			}
+
+			lock_res_and_lock(lock);
+			LASSERT(!lock->l_lvb_data);
+			lock->l_lvb_type = LVB_T_LAYOUT;
+			lock->l_lvb_data = lvb_data;
+			lock->l_lvb_len = lvb_len;
+			unlock_res_and_lock(lock);
+		}
+	}
+
+	lock_res_and_lock(lock);
+	if (ldlm_is_destroyed(lock) ||
+	    lock->l_granted_mode == lock->l_req_mode) {
+		/* bug 11300: the lock has already been granted */
+		unlock_res_and_lock(lock);
+		LDLM_DEBUG(lock, "Double grant race happened");
+		rc = 0;
+		goto out;
+	}
+
+	/* If we receive the completion AST before the actual enqueue returned,
+	 * then we might need to switch lock modes, resources, or extents.
+	 */
+	if (dlm_req->lock_desc.l_granted_mode != lock->l_req_mode) {
+		lock->l_req_mode = dlm_req->lock_desc.l_granted_mode;
+		LDLM_DEBUG(lock, "completion AST, new lock mode");
+	}
+
+	if (lock->l_resource->lr_type != LDLM_PLAIN) {
+		ldlm_convert_policy_to_local(req->rq_export,
+					  dlm_req->lock_desc.l_resource.lr_type,
+					  &dlm_req->lock_desc.l_policy_data,
+					  &lock->l_policy_data);
+		LDLM_DEBUG(lock, "completion AST, new policy data");
+	}
+
+	ldlm_resource_unlink_lock(lock);
+	if (memcmp(&dlm_req->lock_desc.l_resource.lr_name,
+		   &lock->l_resource->lr_name,
+		   sizeof(lock->l_resource->lr_name)) != 0) {
+		unlock_res_and_lock(lock);
+		rc = ldlm_lock_change_resource(ns, lock,
+				&dlm_req->lock_desc.l_resource.lr_name);
+		if (rc < 0) {
+			LDLM_ERROR(lock, "Failed to allocate resource");
+			goto out;
+		}
+		LDLM_DEBUG(lock, "completion AST, new resource");
+		CERROR("change resource!\n");
+		lock_res_and_lock(lock);
+	}
+
+	if (dlm_req->lock_flags & LDLM_FL_AST_SENT) {
+		/* BL_AST locks are not needed in LRU.
+		 * Let ldlm_cancel_lru() be fast.
+		 */
+		ldlm_lock_remove_from_lru(lock);
+		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_BL_AST;
+		LDLM_DEBUG(lock, "completion AST includes blocking AST");
+	}
+
+	if (lock->l_lvb_len > 0) {
+		rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_CLIENT,
+				   lock->l_lvb_data, lvb_len);
+		if (rc < 0) {
+			unlock_res_and_lock(lock);
+			goto out;
+		}
+	}
+
+	ldlm_grant_lock(lock, &ast_list);
+	unlock_res_and_lock(lock);
+
+	LDLM_DEBUG(lock, "callback handler finished, about to run_ast_work");
+
+	/* Let Enqueue to call osc_lock_upcall() and initialize l_ast_data */
+	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 2);
+
+	ldlm_run_ast_work(ns, &ast_list, LDLM_WORK_CP_AST);
+
+	LDLM_DEBUG_NOLOCK("client completion callback handler END (lock %p)",
+			  lock);
+	goto out;
+
+out:
+	if (rc < 0) {
+		lock_res_and_lock(lock);
+		ldlm_set_failed(lock);
+		unlock_res_and_lock(lock);
+		wake_up(&lock->l_waitq);
+	}
+	LDLM_LOCK_RELEASE(lock);
+}
+
+/**
+ * Callback handler for receiving incoming glimpse ASTs.
+ *
+ * This only can happen on client side.  After handling the glimpse AST
+ * we also consider dropping the lock here if it is unused locally for a
+ * long time.
+ */
+static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
+				    struct ldlm_namespace *ns,
+				    struct ldlm_request *dlm_req,
+				    struct ldlm_lock *lock)
+{
+	int rc = -ENOSYS;
+
+	LDLM_DEBUG(lock, "client glimpse AST callback handler");
+
+	if (lock->l_glimpse_ast)
+		rc = lock->l_glimpse_ast(lock, req);
+
+	if (req->rq_repmsg) {
+		ptlrpc_reply(req);
+	} else {
+		req->rq_status = rc;
+		ptlrpc_error(req);
+	}
+
+	lock_res_and_lock(lock);
+	if (lock->l_granted_mode == LCK_PW &&
+	    !lock->l_readers && !lock->l_writers &&
+	    time_after(jiffies,
+		       lock->l_last_used + 10 * HZ)) {
+		unlock_res_and_lock(lock);
+		if (ldlm_bl_to_thread_lock(ns, NULL, lock))
+			ldlm_handle_bl_callback(ns, NULL, lock);
+
+		return;
+	}
+	unlock_res_and_lock(lock);
+	LDLM_LOCK_RELEASE(lock);
+}
+
+static int ldlm_callback_reply(struct ptlrpc_request *req, int rc)
+{
+	if (req->rq_no_reply)
+		return 0;
+
+	req->rq_status = rc;
+	if (!req->rq_packed_final) {
+		rc = lustre_pack_reply(req, 1, NULL, NULL);
+		if (rc)
+			return rc;
+	}
+	return ptlrpc_reply(req);
+}
+
+static int __ldlm_bl_to_thread(struct ldlm_bl_work_item *blwi,
+			       enum ldlm_cancel_flags cancel_flags)
+{
+	struct ldlm_bl_pool *blp = ldlm_state->ldlm_bl_pool;
+
+	spin_lock(&blp->blp_lock);
+	if (blwi->blwi_lock && ldlm_is_discard_data(blwi->blwi_lock)) {
+		/* add LDLM_FL_DISCARD_DATA requests to the priority list */
+		list_add_tail(&blwi->blwi_entry, &blp->blp_prio_list);
+	} else {
+		/* other blocking callbacks are added to the regular list */
+		list_add_tail(&blwi->blwi_entry, &blp->blp_list);
+	}
+	spin_unlock(&blp->blp_lock);
+
+	wake_up(&blp->blp_waitq);
+
+	/* can not check blwi->blwi_flags as blwi could be already freed in
+	 * LCF_ASYNC mode
+	 */
+	if (!(cancel_flags & LCF_ASYNC))
+		wait_for_completion(&blwi->blwi_comp);
+
+	return 0;
+}
+
+static inline void init_blwi(struct ldlm_bl_work_item *blwi,
+			     struct ldlm_namespace *ns,
+			     struct ldlm_lock_desc *ld,
+			     struct list_head *cancels, int count,
+			     struct ldlm_lock *lock,
+			     enum ldlm_cancel_flags cancel_flags)
+{
+	init_completion(&blwi->blwi_comp);
+	INIT_LIST_HEAD(&blwi->blwi_head);
+
+	if (current->flags & PF_MEMALLOC)
+		blwi->blwi_mem_pressure = 1;
+
+	blwi->blwi_ns = ns;
+	blwi->blwi_flags = cancel_flags;
+	if (ld)
+		blwi->blwi_ld = *ld;
+	if (count) {
+		list_add(&blwi->blwi_head, cancels);
+		list_del_init(cancels);
+		blwi->blwi_count = count;
+	} else {
+		blwi->blwi_lock = lock;
+	}
+}
+
+/**
+ * Queues a list of locks \a cancels containing \a count locks
+ * for later processing by a blocking thread.  If \a count is zero,
+ * then the lock referenced as \a lock is queued instead.
+ *
+ * The blocking thread would then call ->l_blocking_ast callback in the lock.
+ * If list addition fails an error is returned and caller is supposed to
+ * call ->l_blocking_ast itself.
+ */
+static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
+			     struct ldlm_lock_desc *ld,
+			     struct ldlm_lock *lock,
+			     struct list_head *cancels, int count,
+			     enum ldlm_cancel_flags cancel_flags)
+{
+	if (cancels && count == 0)
+		return 0;
+
+	if (cancel_flags & LCF_ASYNC) {
+		struct ldlm_bl_work_item *blwi;
+
+		blwi = kzalloc(sizeof(*blwi), GFP_NOFS);
+		if (!blwi)
+			return -ENOMEM;
+		init_blwi(blwi, ns, ld, cancels, count, lock, cancel_flags);
+
+		return __ldlm_bl_to_thread(blwi, cancel_flags);
+	} else {
+		/* if it is synchronous call do minimum mem alloc, as it could
+		 * be triggered from kernel shrinker
+		 */
+		struct ldlm_bl_work_item blwi;
+
+		memset(&blwi, 0, sizeof(blwi));
+		init_blwi(&blwi, ns, ld, cancels, count, lock, cancel_flags);
+		return __ldlm_bl_to_thread(&blwi, cancel_flags);
+	}
+}
+
+int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
+			   struct ldlm_lock *lock)
+{
+	return ldlm_bl_to_thread(ns, ld, lock, NULL, 0, LCF_ASYNC);
+}
+
+int ldlm_bl_to_thread_list(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
+			   struct list_head *cancels, int count,
+			   enum ldlm_cancel_flags cancel_flags)
+{
+	return ldlm_bl_to_thread(ns, ld, NULL, cancels, count, cancel_flags);
+}
+
+int ldlm_bl_thread_wakeup(void)
+{
+	wake_up(&ldlm_state->ldlm_bl_pool->blp_waitq);
+	return 0;
+}
+
+/* Setinfo coming from Server (eg MDT) to Client (eg MDC)! */
+static int ldlm_handle_setinfo(struct ptlrpc_request *req)
+{
+	struct obd_device *obd = req->rq_export->exp_obd;
+	char *key;
+	void *val;
+	int keylen, vallen;
+	int rc = -ENOSYS;
+
+	DEBUG_REQ(D_HSM, req, "%s: handle setinfo\n", obd->obd_name);
+
+	req_capsule_set(&req->rq_pill, &RQF_OBD_SET_INFO);
+
+	key = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_KEY);
+	if (!key) {
+		DEBUG_REQ(D_IOCTL, req, "no set_info key");
+		return -EFAULT;
+	}
+	keylen = req_capsule_get_size(&req->rq_pill, &RMF_SETINFO_KEY,
+				      RCL_CLIENT);
+	val = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_VAL);
+	if (!val) {
+		DEBUG_REQ(D_IOCTL, req, "no set_info val");
+		return -EFAULT;
+	}
+	vallen = req_capsule_get_size(&req->rq_pill, &RMF_SETINFO_VAL,
+				      RCL_CLIENT);
+
+	/* We are responsible for swabbing contents of val */
+
+	if (KEY_IS(KEY_HSM_COPYTOOL_SEND))
+		/* Pass it on to mdc (the "export" in this case) */
+		rc = obd_set_info_async(req->rq_svc_thread->t_env,
+					req->rq_export,
+					sizeof(KEY_HSM_COPYTOOL_SEND),
+					KEY_HSM_COPYTOOL_SEND,
+					vallen, val, NULL);
+	else
+		DEBUG_REQ(D_WARNING, req, "ignoring unknown key %s", key);
+
+	return rc;
+}
+
+static inline void ldlm_callback_errmsg(struct ptlrpc_request *req,
+					const char *msg, int rc,
+					const struct lustre_handle *handle)
+{
+	DEBUG_REQ((req->rq_no_reply || rc) ? D_WARNING : D_DLMTRACE, req,
+		  "%s: [nid %s] [rc %d] [lock %#llx]",
+		  msg, libcfs_id2str(req->rq_peer), rc,
+		  handle ? handle->cookie : 0);
+	if (req->rq_no_reply)
+		CWARN("No reply was sent, maybe cause bug 21636.\n");
+	else if (rc)
+		CWARN("Send reply failed, maybe cause bug 21636.\n");
+}
+
+/* TODO: handle requests in a similar way as MDT: see mdt_handle_common() */
+static int ldlm_callback_handler(struct ptlrpc_request *req)
+{
+	struct ldlm_namespace *ns;
+	struct ldlm_request *dlm_req;
+	struct ldlm_lock *lock;
+	int rc;
+
+	/* Requests arrive in sender's byte order.  The ptlrpc service
+	 * handler has already checked and, if necessary, byte-swapped the
+	 * incoming request message body, but I am responsible for the
+	 * message buffers.
+	 */
+
+	/* do nothing for sec context finalize */
+	if (lustre_msg_get_opc(req->rq_reqmsg) == SEC_CTX_FINI)
+		return 0;
+
+	req_capsule_init(&req->rq_pill, req, RCL_SERVER);
+
+	if (!req->rq_export) {
+		rc = ldlm_callback_reply(req, -ENOTCONN);
+		ldlm_callback_errmsg(req, "Operate on unconnected server",
+				     rc, NULL);
+		return 0;
+	}
+
+	LASSERT(req->rq_export->exp_obd);
+
+	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
+	case LDLM_BL_CALLBACK:
+		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_BL_CALLBACK_NET)) {
+			if (cfs_fail_err)
+				ldlm_callback_reply(req, -(int)cfs_fail_err);
+			return 0;
+		}
+		break;
+	case LDLM_CP_CALLBACK:
+		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CP_CALLBACK_NET))
+			return 0;
+		break;
+	case LDLM_GL_CALLBACK:
+		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_GL_CALLBACK_NET))
+			return 0;
+		break;
+	case LDLM_SET_INFO:
+		rc = ldlm_handle_setinfo(req);
+		ldlm_callback_reply(req, rc);
+		return 0;
+	default:
+		CERROR("unknown opcode %u\n",
+		       lustre_msg_get_opc(req->rq_reqmsg));
+		ldlm_callback_reply(req, -EPROTO);
+		return 0;
+	}
+
+	ns = req->rq_export->exp_obd->obd_namespace;
+	LASSERT(ns);
+
+	req_capsule_set(&req->rq_pill, &RQF_LDLM_CALLBACK);
+
+	dlm_req = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
+	if (!dlm_req) {
+		rc = ldlm_callback_reply(req, -EPROTO);
+		ldlm_callback_errmsg(req, "Operate without parameter", rc,
+				     NULL);
+		return 0;
+	}
+
+	/* Force a known safe race, send a cancel to the server for a lock
+	 * which the server has already started a blocking callback on.
+	 */
+	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE) &&
+	    lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK) {
+		rc = ldlm_cli_cancel(&dlm_req->lock_handle[0], 0);
+		if (rc < 0)
+			CERROR("ldlm_cli_cancel: %d\n", rc);
+	}
+
+	lock = ldlm_handle2lock_long(&dlm_req->lock_handle[0], 0);
+	if (!lock) {
+		CDEBUG(D_DLMTRACE,
+		       "callback on lock %#llx - lock disappeared\n",
+		       dlm_req->lock_handle[0].cookie);
+		rc = ldlm_callback_reply(req, -EINVAL);
+		ldlm_callback_errmsg(req, "Operate with invalid parameter", rc,
+				     &dlm_req->lock_handle[0]);
+		return 0;
+	}
+
+	if (ldlm_is_fail_loc(lock) &&
+	    lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK)
+		OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
+
+	/* Copy hints/flags (e.g. LDLM_FL_DISCARD_DATA) from AST. */
+	lock_res_and_lock(lock);
+	lock->l_flags |= ldlm_flags_from_wire(dlm_req->lock_flags &
+					      LDLM_FL_AST_MASK);
+	if (lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK) {
+		/* If somebody cancels lock and cache is already dropped,
+		 * or lock is failed before cp_ast received on client,
+		 * we can tell the server we have no lock. Otherwise, we
+		 * should send cancel after dropping the cache.
+		 */
+		if ((ldlm_is_canceling(lock) && ldlm_is_bl_done(lock)) ||
+		    ldlm_is_failed(lock)) {
+			LDLM_DEBUG(lock,
+				   "callback on lock %#llx - lock disappeared",
+				   dlm_req->lock_handle[0].cookie);
+			unlock_res_and_lock(lock);
+			LDLM_LOCK_RELEASE(lock);
+			rc = ldlm_callback_reply(req, -EINVAL);
+			ldlm_callback_errmsg(req, "Operate on stale lock", rc,
+					     &dlm_req->lock_handle[0]);
+			return 0;
+		}
+		/* BL_AST locks are not needed in LRU.
+		 * Let ldlm_cancel_lru() be fast.
+		 */
+		ldlm_lock_remove_from_lru(lock);
+		ldlm_set_bl_ast(lock);
+	}
+	unlock_res_and_lock(lock);
+
+	/* We want the ost thread to get this reply so that it can respond
+	 * to ost requests (write cache writeback) that might be triggered
+	 * in the callback.
+	 *
+	 * But we'd also like to be able to indicate in the reply that we're
+	 * cancelling right now, because it's unused, or have an intent result
+	 * in the reply, so we might have to push the responsibility for sending
+	 * the reply down into the AST handlers, alas.
+	 */
+
+	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
+	case LDLM_BL_CALLBACK:
+		CDEBUG(D_INODE, "blocking ast\n");
+		req_capsule_extend(&req->rq_pill, &RQF_LDLM_BL_CALLBACK);
+		if (!ldlm_is_cancel_on_block(lock)) {
+			rc = ldlm_callback_reply(req, 0);
+			if (req->rq_no_reply || rc)
+				ldlm_callback_errmsg(req, "Normal process", rc,
+						     &dlm_req->lock_handle[0]);
+		}
+		if (ldlm_bl_to_thread_lock(ns, &dlm_req->lock_desc, lock))
+			ldlm_handle_bl_callback(ns, &dlm_req->lock_desc, lock);
+		break;
+	case LDLM_CP_CALLBACK:
+		CDEBUG(D_INODE, "completion ast\n");
+		req_capsule_extend(&req->rq_pill, &RQF_LDLM_CP_CALLBACK);
+		ldlm_callback_reply(req, 0);
+		ldlm_handle_cp_callback(req, ns, dlm_req, lock);
+		break;
+	case LDLM_GL_CALLBACK:
+		CDEBUG(D_INODE, "glimpse ast\n");
+		req_capsule_extend(&req->rq_pill, &RQF_LDLM_GL_CALLBACK);
+		ldlm_handle_gl_callback(req, ns, dlm_req, lock);
+		break;
+	default:
+		LBUG();			 /* checked above */
+	}
+
+	return 0;
+}
+
+static int ldlm_bl_get_work(struct ldlm_bl_pool *blp,
+			    struct ldlm_bl_work_item **p_blwi,
+			    struct obd_export **p_exp)
+{
+	int num_th = atomic_read(&blp->blp_num_threads);
+	struct ldlm_bl_work_item *blwi = NULL;
+	static unsigned int num_bl;
+
+	spin_lock(&blp->blp_lock);
+	/* process a request from the blp_list at least every blp_num_threads */
+	if (!list_empty(&blp->blp_list) &&
+	    (list_empty(&blp->blp_prio_list) || num_bl == 0))
+		blwi = list_first_entry(&blp->blp_list,
+					struct ldlm_bl_work_item, blwi_entry);
+	else
+		if (!list_empty(&blp->blp_prio_list))
+			blwi = list_first_entry(&blp->blp_prio_list,
+						struct ldlm_bl_work_item,
+						blwi_entry);
+
+	if (blwi) {
+		if (++num_bl >= num_th)
+			num_bl = 0;
+		list_del(&blwi->blwi_entry);
+	}
+	spin_unlock(&blp->blp_lock);
+	*p_blwi = blwi;
+
+	return (*p_blwi || *p_exp) ? 1 : 0;
+}
+
+/* This only contains temporary data until the thread starts */
+struct ldlm_bl_thread_data {
+	struct ldlm_bl_pool	*bltd_blp;
+	struct completion	bltd_comp;
+	int			bltd_num;
+};
+
+static int ldlm_bl_thread_main(void *arg);
+
+static int ldlm_bl_thread_start(struct ldlm_bl_pool *blp, bool check_busy)
+{
+	struct ldlm_bl_thread_data bltd = { .bltd_blp = blp };
+	struct task_struct *task;
+
+	init_completion(&bltd.bltd_comp);
+
+	bltd.bltd_num = atomic_inc_return(&blp->blp_num_threads);
+	if (bltd.bltd_num >= blp->blp_max_threads) {
+		atomic_dec(&blp->blp_num_threads);
+		return 0;
+	}
+
+	LASSERTF(bltd.bltd_num > 0, "thread num:%d\n", bltd.bltd_num);
+	if (check_busy &&
+	    atomic_read(&blp->blp_busy_threads) < (bltd.bltd_num - 1)) {
+		atomic_dec(&blp->blp_num_threads);
+		return 0;
+	}
+
+	task = kthread_run(ldlm_bl_thread_main, &bltd, "ldlm_bl_%02d",
+			   bltd.bltd_num);
+	if (IS_ERR(task)) {
+		CERROR("cannot start LDLM thread ldlm_bl_%02d: rc %ld\n",
+		       bltd.bltd_num, PTR_ERR(task));
+		atomic_dec(&blp->blp_num_threads);
+		return PTR_ERR(task);
+	}
+	wait_for_completion(&bltd.bltd_comp);
+
+	return 0;
+}
+
+/* Not fatal if racy and have a few too many threads */
+static int ldlm_bl_thread_need_create(struct ldlm_bl_pool *blp,
+				      struct ldlm_bl_work_item *blwi)
+{
+	if (atomic_read(&blp->blp_num_threads) >= blp->blp_max_threads)
+		return 0;
+
+	if (atomic_read(&blp->blp_busy_threads) <
+	    atomic_read(&blp->blp_num_threads))
+		return 0;
+
+	if (blwi && (!blwi->blwi_ns || blwi->blwi_mem_pressure))
+		return 0;
+
+	return 1;
+}
+
+static int ldlm_bl_thread_blwi(struct ldlm_bl_pool *blp,
+			       struct ldlm_bl_work_item *blwi)
+{
+	unsigned int flags = 0;
+
+	if (!blwi->blwi_ns)
+		/* added by ldlm_cleanup() */
+		return LDLM_ITER_STOP;
+
+	if (blwi->blwi_mem_pressure)
+		flags = memalloc_noreclaim_save();
+
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL2, 4);
+
+	if (blwi->blwi_count) {
+		int count;
+
+		/*
+		 * The special case when we cancel locks in lru
+		 * asynchronously, we pass the list of locks here.
+		 * Thus locks are marked LDLM_FL_CANCELING, but NOT
+		 * canceled locally yet.
+		 */
+		count = ldlm_cli_cancel_list_local(&blwi->blwi_head,
+						   blwi->blwi_count,
+						   LCF_BL_AST);
+		ldlm_cli_cancel_list(&blwi->blwi_head, count, NULL,
+				     blwi->blwi_flags);
+	} else {
+		ldlm_handle_bl_callback(blwi->blwi_ns, &blwi->blwi_ld,
+					blwi->blwi_lock);
+	}
+	if (blwi->blwi_mem_pressure)
+		memalloc_noreclaim_restore(flags);
+
+	if (blwi->blwi_flags & LCF_ASYNC)
+		kfree(blwi);
+	else
+		complete(&blwi->blwi_comp);
+
+	return 0;
+}
+
+/**
+ * Main blocking requests processing thread.
+ *
+ * Callers put locks into its queue by calling ldlm_bl_to_thread.
+ * This thread in the end ends up doing actual call to ->l_blocking_ast
+ * for queued locks.
+ */
+static int ldlm_bl_thread_main(void *arg)
+{
+	struct ldlm_bl_pool *blp;
+	struct ldlm_bl_thread_data *bltd = arg;
+
+	blp = bltd->bltd_blp;
+
+	complete(&bltd->bltd_comp);
+	/* cannot use bltd after this, it is only on caller's stack */
+
+	while (1) {
+		struct ldlm_bl_work_item *blwi = NULL;
+		struct obd_export *exp = NULL;
+		int rc;
+
+		rc = ldlm_bl_get_work(blp, &blwi, &exp);
+		if (!rc)
+			wait_event_idle_exclusive(blp->blp_waitq,
+						  ldlm_bl_get_work(blp, &blwi,
+								   &exp));
+		atomic_inc(&blp->blp_busy_threads);
+
+		if (ldlm_bl_thread_need_create(blp, blwi))
+			/* discard the return value, we tried */
+			ldlm_bl_thread_start(blp, true);
+
+		if (blwi)
+			rc = ldlm_bl_thread_blwi(blp, blwi);
+
+		atomic_dec(&blp->blp_busy_threads);
+
+		if (rc == LDLM_ITER_STOP)
+			break;
+	}
+
+	atomic_dec(&blp->blp_num_threads);
+	complete(&blp->blp_comp);
+	return 0;
+}
+
+static int ldlm_setup(void);
+static int ldlm_cleanup(void);
+
+int ldlm_get_ref(void)
+{
+	int rc = 0;
+
+	rc = ptlrpc_inc_ref();
+	if (rc)
+		return rc;
+
+	mutex_lock(&ldlm_ref_mutex);
+	if (++ldlm_refcount == 1) {
+		rc = ldlm_setup();
+		if (rc)
+			ldlm_refcount--;
+	}
+	mutex_unlock(&ldlm_ref_mutex);
+
+	if (rc)
+		ptlrpc_dec_ref();
+
+	return rc;
+}
+
+void ldlm_put_ref(void)
+{
+	int rc = 0;
+	mutex_lock(&ldlm_ref_mutex);
+	if (ldlm_refcount == 1) {
+		rc = ldlm_cleanup();
+
+		if (rc)
+			CERROR("ldlm_cleanup failed: %d\n", rc);
+		else
+			ldlm_refcount--;
+	} else {
+		ldlm_refcount--;
+	}
+	mutex_unlock(&ldlm_ref_mutex);
+	if (!rc)
+		ptlrpc_dec_ref();
+}
+
+static ssize_t cancel_unused_locks_before_replay_show(struct kobject *kobj,
+						      struct attribute *attr,
+						      char *buf)
+{
+	return sprintf(buf, "%d\n", ldlm_cancel_unused_locks_before_replay);
+}
+
+static ssize_t cancel_unused_locks_before_replay_store(struct kobject *kobj,
+						       struct attribute *attr,
+						       const char *buffer,
+						       size_t count)
+{
+	int rc;
+	unsigned long val;
+
+	rc = kstrtoul(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	ldlm_cancel_unused_locks_before_replay = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(cancel_unused_locks_before_replay);
+
+/* These are for root of /sys/fs/lustre/ldlm */
+static struct attribute *ldlm_attrs[] = {
+	&lustre_attr_cancel_unused_locks_before_replay.attr,
+	NULL,
+};
+
+static const struct attribute_group ldlm_attr_group = {
+	.attrs = ldlm_attrs,
+};
+
+static int ldlm_setup(void)
+{
+	static struct ptlrpc_service_conf	conf;
+	struct ldlm_bl_pool			*blp = NULL;
+	int rc = 0;
+	int i;
+
+	if (ldlm_state)
+		return -EALREADY;
+
+	ldlm_state = kzalloc(sizeof(*ldlm_state), GFP_NOFS);
+	if (!ldlm_state)
+		return -ENOMEM;
+
+	ldlm_kobj = kobject_create_and_add("ldlm", lustre_kobj);
+	if (!ldlm_kobj) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	rc = sysfs_create_group(ldlm_kobj, &ldlm_attr_group);
+	if (rc)
+		goto out;
+
+	ldlm_ns_kset = kset_create_and_add("namespaces", NULL, ldlm_kobj);
+	if (!ldlm_ns_kset) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	ldlm_svc_kset = kset_create_and_add("services", NULL, ldlm_kobj);
+	if (!ldlm_svc_kset) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	ldlm_debugfs_setup();
+
+	memset(&conf, 0, sizeof(conf));
+	conf = (typeof(conf)) {
+		.psc_name		= "ldlm_cbd",
+		.psc_watchdog_factor	= 2,
+		.psc_buf		= {
+			.bc_nbufs		= LDLM_CLIENT_NBUFS,
+			.bc_buf_size		= LDLM_BUFSIZE,
+			.bc_req_max_size	= LDLM_MAXREQSIZE,
+			.bc_rep_max_size	= LDLM_MAXREPSIZE,
+			.bc_req_portal		= LDLM_CB_REQUEST_PORTAL,
+			.bc_rep_portal		= LDLM_CB_REPLY_PORTAL,
+		},
+		.psc_thr		= {
+			.tc_thr_name		= "ldlm_cb",
+			.tc_thr_factor		= LDLM_THR_FACTOR,
+			.tc_nthrs_init		= LDLM_NTHRS_INIT,
+			.tc_nthrs_base		= LDLM_NTHRS_BASE,
+			.tc_nthrs_max		= LDLM_NTHRS_MAX,
+			.tc_nthrs_user		= ldlm_num_threads,
+			.tc_cpu_affinity	= 1,
+			.tc_ctx_tags		= LCT_MD_THREAD | LCT_DT_THREAD,
+		},
+		.psc_cpt		= {
+			.cc_pattern		= ldlm_cpts,
+		},
+		.psc_ops		= {
+			.so_req_handler		= ldlm_callback_handler,
+		},
+	};
+	ldlm_state->ldlm_cb_service =
+			ptlrpc_register_service(&conf, ldlm_svc_kset,
+						ldlm_svc_debugfs_dir);
+	if (IS_ERR(ldlm_state->ldlm_cb_service)) {
+		CERROR("failed to start service\n");
+		rc = PTR_ERR(ldlm_state->ldlm_cb_service);
+		ldlm_state->ldlm_cb_service = NULL;
+		goto out;
+	}
+
+	blp = kzalloc(sizeof(*blp), GFP_NOFS);
+	if (!blp) {
+		rc = -ENOMEM;
+		goto out;
+	}
+	ldlm_state->ldlm_bl_pool = blp;
+
+	spin_lock_init(&blp->blp_lock);
+	INIT_LIST_HEAD(&blp->blp_list);
+	INIT_LIST_HEAD(&blp->blp_prio_list);
+	init_waitqueue_head(&blp->blp_waitq);
+	atomic_set(&blp->blp_num_threads, 0);
+	atomic_set(&blp->blp_busy_threads, 0);
+
+	if (ldlm_num_threads == 0) {
+		blp->blp_min_threads = LDLM_NTHRS_INIT;
+		blp->blp_max_threads = LDLM_NTHRS_MAX;
+	} else {
+		blp->blp_min_threads = min_t(int, LDLM_NTHRS_MAX,
+					     max_t(int, LDLM_NTHRS_INIT,
+						   ldlm_num_threads));
+
+		blp->blp_max_threads = blp->blp_min_threads;
+	}
+
+	for (i = 0; i < blp->blp_min_threads; i++) {
+		rc = ldlm_bl_thread_start(blp, false);
+		if (rc < 0)
+			goto out;
+	}
+
+	rc = ldlm_pools_init();
+	if (rc) {
+		CERROR("Failed to initialize LDLM pools: %d\n", rc);
+		goto out;
+	}
+	return 0;
+
+ out:
+	ldlm_cleanup();
+	return rc;
+}
+
+static int ldlm_cleanup(void)
+{
+	if (!list_empty(ldlm_namespace_list(LDLM_NAMESPACE_SERVER)) ||
+	    !list_empty(ldlm_namespace_list(LDLM_NAMESPACE_CLIENT))) {
+		CERROR("ldlm still has namespaces; clean these up first.\n");
+		ldlm_dump_all_namespaces(LDLM_NAMESPACE_SERVER, D_DLMTRACE);
+		ldlm_dump_all_namespaces(LDLM_NAMESPACE_CLIENT, D_DLMTRACE);
+		return -EBUSY;
+	}
+
+	ldlm_pools_fini();
+
+	if (ldlm_state->ldlm_bl_pool) {
+		struct ldlm_bl_pool *blp = ldlm_state->ldlm_bl_pool;
+
+		while (atomic_read(&blp->blp_num_threads) > 0) {
+			struct ldlm_bl_work_item blwi = { .blwi_ns = NULL };
+
+			init_completion(&blp->blp_comp);
+
+			spin_lock(&blp->blp_lock);
+			list_add_tail(&blwi.blwi_entry, &blp->blp_list);
+			wake_up(&blp->blp_waitq);
+			spin_unlock(&blp->blp_lock);
+
+			wait_for_completion(&blp->blp_comp);
+		}
+
+		kfree(blp);
+	}
+
+	if (ldlm_state->ldlm_cb_service)
+		ptlrpc_unregister_service(ldlm_state->ldlm_cb_service);
+
+	if (ldlm_ns_kset)
+		kset_unregister(ldlm_ns_kset);
+	if (ldlm_svc_kset)
+		kset_unregister(ldlm_svc_kset);
+	if (ldlm_kobj) {
+		sysfs_remove_group(ldlm_kobj, &ldlm_attr_group);
+		kobject_put(ldlm_kobj);
+	}
+
+	ldlm_debugfs_cleanup();
+
+	kfree(ldlm_state);
+	ldlm_state = NULL;
+
+	return 0;
+}
+
+int ldlm_init(void)
+{
+	mutex_init(&ldlm_ref_mutex);
+	mutex_init(ldlm_namespace_lock(LDLM_NAMESPACE_SERVER));
+	mutex_init(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
+	ldlm_resource_slab = kmem_cache_create("ldlm_resources",
+					       sizeof(struct ldlm_resource), 0,
+					       SLAB_HWCACHE_ALIGN, NULL);
+	if (!ldlm_resource_slab)
+		return -ENOMEM;
+
+	ldlm_lock_slab = kmem_cache_create("ldlm_locks",
+					   sizeof(struct ldlm_lock), 0,
+					   SLAB_HWCACHE_ALIGN |
+					   SLAB_TYPESAFE_BY_RCU, NULL);
+	if (!ldlm_lock_slab) {
+		kmem_cache_destroy(ldlm_resource_slab);
+		return -ENOMEM;
+	}
+
+#if LUSTRE_TRACKS_LOCK_EXP_REFS
+	class_export_dump_hook = ldlm_dump_export_locks;
+#endif
+	return 0;
+}
+
+void ldlm_exit(void)
+{
+	if (ldlm_refcount)
+		CERROR("ldlm_refcount is %d in %s!\n", ldlm_refcount, __func__);
+	kmem_cache_destroy(ldlm_resource_slab);
+	/* ldlm_lock_put() use RCU to call ldlm_lock_free, so need call
+	 * synchronize_rcu() to wait a grace period elapsed, so that
+	 * ldlm_lock_free() get a chance to be called.
+	 */
+	synchronize_rcu();
+	kmem_cache_destroy(ldlm_lock_slab);
+}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_plain.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_plain.c
new file mode 100644
index 000000000000..33b5a3f96fcb
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_plain.c
@@ -0,0 +1,68 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/ldlm/ldlm_plain.c
+ *
+ * Author: Peter Braam <braam@clusterfs.com>
+ * Author: Phil Schwan <phil@clusterfs.com>
+ */
+
+/**
+ * This file contains implementation of PLAIN lock type.
+ *
+ * PLAIN locks are the simplest form of LDLM locking, and are used when
+ * there only needs to be a single lock on a resource. This avoids some
+ * of the complexity of EXTENT and IBITS lock types, but doesn't allow
+ * different "parts" of a resource to be locked concurrently.  Example
+ * use cases for PLAIN locks include locking of MGS configuration logs
+ * and (as of Lustre 2.4) quota records.
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+
+#include <lustre_dlm.h>
+#include <obd_support.h>
+#include <lustre_lib.h>
+
+#include "ldlm_internal.h"
+
+void ldlm_plain_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				     union ldlm_policy_data *lpolicy)
+{
+	/* No policy for plain locks */
+}
+
+void ldlm_plain_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
+				     union ldlm_wire_policy_data *wpolicy)
+{
+	/* No policy for plain locks */
+}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_pool.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_pool.c
new file mode 100644
index 000000000000..36d14ee4e5b1
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_pool.c
@@ -0,0 +1,1013 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2010, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/ldlm/ldlm_pool.c
+ *
+ * Author: Yury Umanets <umka@clusterfs.com>
+ */
+
+/*
+ * Idea of this code is rather simple. Each second, for each server namespace
+ * we have SLV - server lock volume which is calculated on current number of
+ * granted locks, grant speed for past period, etc - that is, locking load.
+ * This SLV number may be thought as a flow definition for simplicity. It is
+ * sent to clients with each occasion to let them know what is current load
+ * situation on the server. By default, at the beginning, SLV on server is
+ * set max value which is calculated as the following: allow to one client
+ * have all locks of limit ->pl_limit for 10h.
+ *
+ * Next, on clients, number of cached locks is not limited artificially in any
+ * way as it was before. Instead, client calculates CLV, that is, client lock
+ * volume for each lock and compares it with last SLV from the server. CLV is
+ * calculated as the number of locks in LRU * lock live time in seconds. If
+ * CLV > SLV - lock is canceled.
+ *
+ * Client has LVF, that is, lock volume factor which regulates how much
+ * sensitive client should be about last SLV from server. The higher LVF is the
+ * more locks will be canceled on client. Default value for it is 1. Setting LVF
+ * to 2 means that client will cancel locks 2 times faster.
+ *
+ * Locks on a client will be canceled more intensively in these cases:
+ * (1) if SLV is smaller, that is, load is higher on the server;
+ * (2) client has a lot of locks (the more locks are held by client, the bigger
+ *     chances that some of them should be canceled);
+ * (3) client has old locks (taken some time ago);
+ *
+ * Thus, according to flow paradigm that we use for better understanding SLV,
+ * CLV is the volume of particle in flow described by SLV. According to this,
+ * if flow is getting thinner, more and more particles become outside of it and
+ * as particles are locks, they should be canceled.
+ *
+ * General idea of this belongs to Vitaly Fertman (vitaly at clusterfs.com).
+ * Andreas Dilger (adilger at clusterfs.com) proposed few nice ideas like using
+ * LVF and many cleanups. Flow definition to allow more easy understanding of
+ * the logic belongs to Nikita Danilov (nikita at clusterfs.com) as well as many
+ * cleanups and fixes. And design and implementation are done by Yury Umanets
+ * (umka at clusterfs.com).
+ *
+ * Glossary for terms used:
+ *
+ * pl_limit - Number of allowed locks in pool. Applies to server and client
+ * side (tunable);
+ *
+ * pl_granted - Number of granted locks (calculated);
+ * pl_grant_rate - Number of granted locks for last T (calculated);
+ * pl_cancel_rate - Number of canceled locks for last T (calculated);
+ * pl_grant_speed - Grant speed (GR - CR) for last T (calculated);
+ * pl_grant_plan - Planned number of granted locks for next T (calculated);
+ * pl_server_lock_volume - Current server lock volume (calculated);
+ *
+ * As it may be seen from list above, we have few possible tunables which may
+ * affect behavior much. They all may be modified via sysfs. However, they also
+ * give a possibility for constructing few pre-defined behavior policies. If
+ * none of predefines is suitable for a working pattern being used, new one may
+ * be "constructed" via sysfs tunables.
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+
+#include <lustre_dlm.h>
+#include <cl_object.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include "ldlm_internal.h"
+
+/*
+ * 50 ldlm locks for 1MB of RAM.
+ */
+#define LDLM_POOL_HOST_L ((NUM_CACHEPAGES >> (20 - PAGE_SHIFT)) * 50)
+
+/*
+ * Maximal possible grant step plan in %.
+ */
+#define LDLM_POOL_MAX_GSP (30)
+
+/*
+ * Minimal possible grant step plan in %.
+ */
+#define LDLM_POOL_MIN_GSP (1)
+
+/*
+ * This controls the speed of reaching LDLM_POOL_MAX_GSP
+ * with increasing thread period.
+ */
+#define LDLM_POOL_GSP_STEP_SHIFT (2)
+
+/*
+ * LDLM_POOL_GSP% of all locks is default GP.
+ */
+#define LDLM_POOL_GP(L)   (((L) * LDLM_POOL_MAX_GSP) / 100)
+
+/*
+ * Max age for locks on clients.
+ */
+#define LDLM_POOL_MAX_AGE (36000)
+
+/*
+ * The granularity of SLV calculation.
+ */
+#define LDLM_POOL_SLV_SHIFT (10)
+
+static inline __u64 dru(__u64 val, __u32 shift, int round_up)
+{
+	return (val + (round_up ? (1 << shift) - 1 : 0)) >> shift;
+}
+
+static inline __u64 ldlm_pool_slv_max(__u32 L)
+{
+	/*
+	 * Allow to have all locks for 1 client for 10 hrs.
+	 * Formula is the following: limit * 10h / 1 client.
+	 */
+	__u64 lim = (__u64)L *  LDLM_POOL_MAX_AGE / 1;
+	return lim;
+}
+
+static inline __u64 ldlm_pool_slv_min(__u32 L)
+{
+	return 1;
+}
+
+enum {
+	LDLM_POOL_FIRST_STAT = 0,
+	LDLM_POOL_GRANTED_STAT = LDLM_POOL_FIRST_STAT,
+	LDLM_POOL_GRANT_STAT,
+	LDLM_POOL_CANCEL_STAT,
+	LDLM_POOL_GRANT_RATE_STAT,
+	LDLM_POOL_CANCEL_RATE_STAT,
+	LDLM_POOL_GRANT_PLAN_STAT,
+	LDLM_POOL_SLV_STAT,
+	LDLM_POOL_SHRINK_REQTD_STAT,
+	LDLM_POOL_SHRINK_FREED_STAT,
+	LDLM_POOL_RECALC_STAT,
+	LDLM_POOL_TIMING_STAT,
+	LDLM_POOL_LAST_STAT
+};
+
+/**
+ * Calculates suggested grant_step in % of available locks for passed
+ * \a period. This is later used in grant_plan calculations.
+ */
+static inline int ldlm_pool_t2gsp(unsigned int t)
+{
+	/*
+	 * This yields 1% grant step for anything below LDLM_POOL_GSP_STEP
+	 * and up to 30% for anything higher than LDLM_POOL_GSP_STEP.
+	 *
+	 * How this will affect execution is the following:
+	 *
+	 * - for thread period 1s we will have grant_step 1% which good from
+	 * pov of taking some load off from server and push it out to clients.
+	 * This is like that because 1% for grant_step means that server will
+	 * not allow clients to get lots of locks in short period of time and
+	 * keep all old locks in their caches. Clients will always have to
+	 * get some locks back if they want to take some new;
+	 *
+	 * - for thread period 10s (which is default) we will have 23% which
+	 * means that clients will have enough of room to take some new locks
+	 * without getting some back. All locks from this 23% which were not
+	 * taken by clients in current period will contribute in SLV growing.
+	 * SLV growing means more locks cached on clients until limit or grant
+	 * plan is reached.
+	 */
+	return LDLM_POOL_MAX_GSP -
+		((LDLM_POOL_MAX_GSP - LDLM_POOL_MIN_GSP) >>
+		 (t >> LDLM_POOL_GSP_STEP_SHIFT));
+}
+
+/**
+ * Recalculates next stats on passed \a pl.
+ *
+ * \pre ->pl_lock is locked.
+ */
+static void ldlm_pool_recalc_stats(struct ldlm_pool *pl)
+{
+	int grant_plan = pl->pl_grant_plan;
+	__u64 slv = pl->pl_server_lock_volume;
+	int granted = atomic_read(&pl->pl_granted);
+	int grant_rate = atomic_read(&pl->pl_grant_rate);
+	int cancel_rate = atomic_read(&pl->pl_cancel_rate);
+
+	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_SLV_STAT,
+			    slv);
+	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_GRANTED_STAT,
+			    granted);
+	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_GRANT_RATE_STAT,
+			    grant_rate);
+	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_GRANT_PLAN_STAT,
+			    grant_plan);
+	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_CANCEL_RATE_STAT,
+			    cancel_rate);
+}
+
+/**
+ * Sets SLV and Limit from container_of(pl, struct ldlm_namespace,
+ * ns_pool)->ns_obd tp passed \a pl.
+ */
+static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
+{
+	struct obd_device *obd;
+
+	/*
+	 * Get new SLV and Limit from obd which is updated with coming
+	 * RPCs.
+	 */
+	obd = container_of(pl, struct ldlm_namespace,
+			   ns_pool)->ns_obd;
+	read_lock(&obd->obd_pool_lock);
+	pl->pl_server_lock_volume = obd->obd_pool_slv;
+	atomic_set(&pl->pl_limit, obd->obd_pool_limit);
+	read_unlock(&obd->obd_pool_lock);
+}
+
+/**
+ * Recalculates client size pool \a pl according to current SLV and Limit.
+ */
+static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
+{
+	time64_t recalc_interval_sec;
+	int ret;
+
+	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+	if (recalc_interval_sec < pl->pl_recalc_period)
+		return 0;
+
+	spin_lock(&pl->pl_lock);
+	/*
+	 * Check if we need to recalc lists now.
+	 */
+	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+	if (recalc_interval_sec < pl->pl_recalc_period) {
+		spin_unlock(&pl->pl_lock);
+		return 0;
+	}
+
+	/*
+	 * Make sure that pool knows last SLV and Limit from obd.
+	 */
+	ldlm_cli_pool_pop_slv(pl);
+
+	spin_unlock(&pl->pl_lock);
+
+	/*
+	 * Do not cancel locks in case lru resize is disabled for this ns.
+	 */
+	if (!ns_connect_lru_resize(container_of(pl, struct ldlm_namespace,
+						ns_pool))) {
+		ret = 0;
+		goto out;
+	}
+
+	/*
+	 * In the time of canceling locks on client we do not need to maintain
+	 * sharp timing, we only want to cancel locks asap according to new SLV.
+	 * It may be called when SLV has changed much, this is why we do not
+	 * take into account pl->pl_recalc_time here.
+	 */
+	ret = ldlm_cancel_lru(container_of(pl, struct ldlm_namespace, ns_pool),
+			      0, LCF_ASYNC, LDLM_LRU_FLAG_LRUR);
+
+out:
+	spin_lock(&pl->pl_lock);
+	/*
+	 * Time of LRU resizing might be longer than period,
+	 * so update after LRU resizing rather than before it.
+	 */
+	pl->pl_recalc_time = ktime_get_real_seconds();
+	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_TIMING_STAT,
+			    recalc_interval_sec);
+	spin_unlock(&pl->pl_lock);
+	return ret;
+}
+
+/**
+ * This function is main entry point for memory pressure handling on client
+ * side.  Main goal of this function is to cancel some number of locks on
+ * passed \a pl according to \a nr and \a gfp_mask.
+ */
+static int ldlm_cli_pool_shrink(struct ldlm_pool *pl,
+				int nr, gfp_t gfp_mask)
+{
+	struct ldlm_namespace *ns;
+	int unused;
+
+	ns = container_of(pl, struct ldlm_namespace, ns_pool);
+
+	/*
+	 * Do not cancel locks in case lru resize is disabled for this ns.
+	 */
+	if (!ns_connect_lru_resize(ns))
+		return 0;
+
+	/*
+	 * Make sure that pool knows last SLV and Limit from obd.
+	 */
+	ldlm_cli_pool_pop_slv(pl);
+
+	spin_lock(&ns->ns_lock);
+	unused = ns->ns_nr_unused;
+	spin_unlock(&ns->ns_lock);
+
+	if (nr == 0)
+		return (unused / 100) * sysctl_vfs_cache_pressure;
+	else
+		return ldlm_cancel_lru(ns, nr, LCF_ASYNC, LDLM_LRU_FLAG_SHRINK);
+}
+
+static const struct ldlm_pool_ops ldlm_cli_pool_ops = {
+	.po_recalc = ldlm_cli_pool_recalc,
+	.po_shrink = ldlm_cli_pool_shrink
+};
+
+/**
+ * Pool recalc wrapper. Will call either client or server pool recalc callback
+ * depending what pool \a pl is used.
+ */
+static int ldlm_pool_recalc(struct ldlm_pool *pl)
+{
+	u32 recalc_interval_sec;
+	int count;
+
+	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+	if (recalc_interval_sec > 0) {
+		spin_lock(&pl->pl_lock);
+		recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+
+		if (recalc_interval_sec > 0) {
+			/*
+			 * Update pool statistics every 1s.
+			 */
+			ldlm_pool_recalc_stats(pl);
+
+			/*
+			 * Zero out all rates and speed for the last period.
+			 */
+			atomic_set(&pl->pl_grant_rate, 0);
+			atomic_set(&pl->pl_cancel_rate, 0);
+		}
+		spin_unlock(&pl->pl_lock);
+	}
+
+	if (pl->pl_ops->po_recalc) {
+		count = pl->pl_ops->po_recalc(pl);
+		lprocfs_counter_add(pl->pl_stats, LDLM_POOL_RECALC_STAT,
+				    count);
+	}
+
+	recalc_interval_sec = pl->pl_recalc_time - ktime_get_real_seconds() +
+			      pl->pl_recalc_period;
+	if (recalc_interval_sec <= 0) {
+		/* DEBUG: should be re-removed after LU-4536 is fixed */
+		CDEBUG(D_DLMTRACE,
+		       "%s: Negative interval(%ld), too short period(%ld)\n",
+		       pl->pl_name, (long)recalc_interval_sec,
+		       (long)pl->pl_recalc_period);
+
+		/* Prevent too frequent recalculation. */
+		recalc_interval_sec = 1;
+	}
+
+	return recalc_interval_sec;
+}
+
+/*
+ * Pool shrink wrapper. Will call either client or server pool recalc callback
+ * depending what pool pl is used. When nr == 0, just return the number of
+ * freeable locks. Otherwise, return the number of canceled locks.
+ */
+static int ldlm_pool_shrink(struct ldlm_pool *pl, int nr, gfp_t gfp_mask)
+{
+	int cancel = 0;
+
+	if (pl->pl_ops->po_shrink) {
+		cancel = pl->pl_ops->po_shrink(pl, nr, gfp_mask);
+		if (nr > 0) {
+			lprocfs_counter_add(pl->pl_stats,
+					    LDLM_POOL_SHRINK_REQTD_STAT,
+					    nr);
+			lprocfs_counter_add(pl->pl_stats,
+					    LDLM_POOL_SHRINK_FREED_STAT,
+					    cancel);
+			CDEBUG(D_DLMTRACE,
+			       "%s: request to shrink %d locks, shrunk %d\n",
+			       pl->pl_name, nr, cancel);
+		}
+	}
+	return cancel;
+}
+
+static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
+{
+	int granted, grant_rate, cancel_rate;
+	int grant_speed, lvf;
+	struct ldlm_pool *pl = m->private;
+	__u64 slv, clv;
+	__u32 limit;
+
+	spin_lock(&pl->pl_lock);
+	slv = pl->pl_server_lock_volume;
+	clv = pl->pl_client_lock_volume;
+	limit = atomic_read(&pl->pl_limit);
+	granted = atomic_read(&pl->pl_granted);
+	grant_rate = atomic_read(&pl->pl_grant_rate);
+	cancel_rate = atomic_read(&pl->pl_cancel_rate);
+	grant_speed = grant_rate - cancel_rate;
+	lvf = atomic_read(&pl->pl_lock_volume_factor);
+	spin_unlock(&pl->pl_lock);
+
+	seq_printf(m, "LDLM pool state (%s):\n"
+		      "  SLV: %llu\n"
+		      "  CLV: %llu\n"
+		      "  LVF: %d\n",
+		      pl->pl_name, slv, clv, lvf);
+
+	seq_printf(m, "  GR:  %d\n  CR:  %d\n  GS:  %d\n"
+		      "  G:   %d\n  L:   %d\n",
+		      grant_rate, cancel_rate, grant_speed,
+		      granted, limit);
+
+	return 0;
+}
+
+LPROC_SEQ_FOPS_RO(lprocfs_pool_state);
+
+static ssize_t grant_speed_show(struct kobject *kobj, struct attribute *attr,
+				char *buf)
+{
+	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool,
+					    pl_kobj);
+
+	int	       grant_speed;
+
+	spin_lock(&pl->pl_lock);
+	/* serialize with ldlm_pool_recalc */
+	grant_speed = atomic_read(&pl->pl_grant_rate) -
+			atomic_read(&pl->pl_cancel_rate);
+	spin_unlock(&pl->pl_lock);
+	return sprintf(buf, "%d\n", grant_speed);
+}
+LUSTRE_RO_ATTR(grant_speed);
+
+LDLM_POOL_SYSFS_READER_SHOW(grant_plan, int);
+LUSTRE_RO_ATTR(grant_plan);
+
+LDLM_POOL_SYSFS_READER_SHOW(recalc_period, int);
+LDLM_POOL_SYSFS_WRITER_STORE(recalc_period, int);
+LUSTRE_RW_ATTR(recalc_period);
+
+LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(server_lock_volume, u64);
+LUSTRE_RO_ATTR(server_lock_volume);
+
+LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(limit, atomic);
+LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(limit, atomic);
+LUSTRE_RW_ATTR(limit);
+
+LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(granted, atomic);
+LUSTRE_RO_ATTR(granted);
+
+LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(cancel_rate, atomic);
+LUSTRE_RO_ATTR(cancel_rate);
+
+LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(grant_rate, atomic);
+LUSTRE_RO_ATTR(grant_rate);
+
+LDLM_POOL_SYSFS_READER_NOLOCK_SHOW(lock_volume_factor, atomic);
+LDLM_POOL_SYSFS_WRITER_NOLOCK_STORE(lock_volume_factor, atomic);
+LUSTRE_RW_ATTR(lock_volume_factor);
+
+#define LDLM_POOL_ADD_VAR(name, var, ops)			\
+	do {							\
+		snprintf(var_name, MAX_STRING_SIZE, #name);	\
+		pool_vars[0].data = var;			\
+		pool_vars[0].fops = ops;			\
+		ldebugfs_add_vars(pl->pl_debugfs_entry, pool_vars, NULL);\
+	} while (0)
+
+/* These are for pools in /sys/fs/lustre/ldlm/namespaces/.../pool */
+static struct attribute *ldlm_pl_attrs[] = {
+	&lustre_attr_grant_speed.attr,
+	&lustre_attr_grant_plan.attr,
+	&lustre_attr_recalc_period.attr,
+	&lustre_attr_server_lock_volume.attr,
+	&lustre_attr_limit.attr,
+	&lustre_attr_granted.attr,
+	&lustre_attr_cancel_rate.attr,
+	&lustre_attr_grant_rate.attr,
+	&lustre_attr_lock_volume_factor.attr,
+	NULL,
+};
+
+static void ldlm_pl_release(struct kobject *kobj)
+{
+	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool,
+					    pl_kobj);
+	complete(&pl->pl_kobj_unregister);
+}
+
+static struct kobj_type ldlm_pl_ktype = {
+	.default_attrs	= ldlm_pl_attrs,
+	.sysfs_ops	= &lustre_sysfs_ops,
+	.release	= ldlm_pl_release,
+};
+
+static int ldlm_pool_sysfs_init(struct ldlm_pool *pl)
+{
+	struct ldlm_namespace *ns = container_of(pl, struct ldlm_namespace,
+						 ns_pool);
+	int err;
+
+	init_completion(&pl->pl_kobj_unregister);
+	err = kobject_init_and_add(&pl->pl_kobj, &ldlm_pl_ktype, &ns->ns_kobj,
+				   "pool");
+
+	return err;
+}
+
+static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
+{
+	struct ldlm_namespace *ns = container_of(pl, struct ldlm_namespace,
+						 ns_pool);
+	struct dentry *debugfs_ns_parent;
+	struct lprocfs_vars pool_vars[2];
+	char *var_name = NULL;
+	int rc = 0;
+
+	var_name = kzalloc(MAX_STRING_SIZE + 1, GFP_NOFS);
+	if (!var_name)
+		return -ENOMEM;
+
+	debugfs_ns_parent = ns->ns_debugfs_entry;
+	if (IS_ERR_OR_NULL(debugfs_ns_parent)) {
+		CERROR("%s: debugfs entry is not initialized\n",
+		       ldlm_ns_name(ns));
+		rc = -EINVAL;
+		goto out_free_name;
+	}
+	pl->pl_debugfs_entry = debugfs_create_dir("pool", debugfs_ns_parent);
+
+	var_name[MAX_STRING_SIZE] = '\0';
+	memset(pool_vars, 0, sizeof(pool_vars));
+	pool_vars[0].name = var_name;
+
+	LDLM_POOL_ADD_VAR(state, pl, &lprocfs_pool_state_fops);
+
+	pl->pl_stats = lprocfs_alloc_stats(LDLM_POOL_LAST_STAT -
+					   LDLM_POOL_FIRST_STAT, 0);
+	if (!pl->pl_stats) {
+		rc = -ENOMEM;
+		goto out_free_name;
+	}
+
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANTED_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "granted", "locks");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "grant", "locks");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_CANCEL_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "cancel", "locks");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_RATE_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "grant_rate", "locks/s");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_CANCEL_RATE_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "cancel_rate", "locks/s");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_PLAN_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "grant_plan", "locks/s");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SLV_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "slv", "slv");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SHRINK_REQTD_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "shrink_request", "locks");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SHRINK_FREED_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "shrink_freed", "locks");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_RECALC_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "recalc_freed", "locks");
+	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_TIMING_STAT,
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
+			     "recalc_timing", "sec");
+	debugfs_create_file("stats", 0644, pl->pl_debugfs_entry, pl->pl_stats,
+			    &lprocfs_stats_seq_fops);
+
+out_free_name:
+	kfree(var_name);
+	return rc;
+}
+
+static void ldlm_pool_sysfs_fini(struct ldlm_pool *pl)
+{
+	kobject_put(&pl->pl_kobj);
+	wait_for_completion(&pl->pl_kobj_unregister);
+}
+
+static void ldlm_pool_debugfs_fini(struct ldlm_pool *pl)
+{
+	if (pl->pl_stats) {
+		lprocfs_free_stats(&pl->pl_stats);
+		pl->pl_stats = NULL;
+	}
+	debugfs_remove_recursive(pl->pl_debugfs_entry);
+}
+
+int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
+		   int idx, enum ldlm_side client)
+{
+	int rc;
+
+	spin_lock_init(&pl->pl_lock);
+	atomic_set(&pl->pl_granted, 0);
+	pl->pl_recalc_time = ktime_get_real_seconds();
+	atomic_set(&pl->pl_lock_volume_factor, 1);
+
+	atomic_set(&pl->pl_grant_rate, 0);
+	atomic_set(&pl->pl_cancel_rate, 0);
+	pl->pl_grant_plan = LDLM_POOL_GP(LDLM_POOL_HOST_L);
+
+	snprintf(pl->pl_name, sizeof(pl->pl_name), "ldlm-pool-%s-%d",
+		 ldlm_ns_name(ns), idx);
+
+	atomic_set(&pl->pl_limit, 1);
+	pl->pl_server_lock_volume = 0;
+	pl->pl_ops = &ldlm_cli_pool_ops;
+	pl->pl_recalc_period = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
+	pl->pl_client_lock_volume = 0;
+	rc = ldlm_pool_debugfs_init(pl);
+	if (rc)
+		return rc;
+
+	rc = ldlm_pool_sysfs_init(pl);
+	if (rc)
+		return rc;
+
+	CDEBUG(D_DLMTRACE, "Lock pool %s is initialized\n", pl->pl_name);
+
+	return rc;
+}
+
+void ldlm_pool_fini(struct ldlm_pool *pl)
+{
+	ldlm_pool_sysfs_fini(pl);
+	ldlm_pool_debugfs_fini(pl);
+
+	/*
+	 * Pool should not be used after this point. We can't free it here as
+	 * it lives in struct ldlm_namespace, but still interested in catching
+	 * any abnormal using cases.
+	 */
+	POISON(pl, 0x5a, sizeof(*pl));
+}
+
+/**
+ * Add new taken ldlm lock \a lock into pool \a pl accounting.
+ */
+void ldlm_pool_add(struct ldlm_pool *pl, struct ldlm_lock *lock)
+{
+	/*
+	 * FLOCK locks are special in a sense that they are almost never
+	 * cancelled, instead special kind of lock is used to drop them.
+	 * also there is no LRU for flock locks, so no point in tracking
+	 * them anyway.
+	 */
+	if (lock->l_resource->lr_type == LDLM_FLOCK)
+		return;
+
+	atomic_inc(&pl->pl_granted);
+	atomic_inc(&pl->pl_grant_rate);
+	lprocfs_counter_incr(pl->pl_stats, LDLM_POOL_GRANT_STAT);
+	/*
+	 * Do not do pool recalc for client side as all locks which
+	 * potentially may be canceled has already been packed into
+	 * enqueue/cancel rpc. Also we do not want to run out of stack
+	 * with too long call paths.
+	 */
+}
+
+/**
+ * Remove ldlm lock \a lock from pool \a pl accounting.
+ */
+void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock)
+{
+	/*
+	 * Filter out FLOCK locks. Read above comment in ldlm_pool_add().
+	 */
+	if (lock->l_resource->lr_type == LDLM_FLOCK)
+		return;
+
+	LASSERT(atomic_read(&pl->pl_granted) > 0);
+	atomic_dec(&pl->pl_granted);
+	atomic_inc(&pl->pl_cancel_rate);
+
+	lprocfs_counter_incr(pl->pl_stats, LDLM_POOL_CANCEL_STAT);
+}
+
+/**
+ * Returns current \a pl SLV.
+ *
+ * \pre ->pl_lock is not locked.
+ */
+__u64 ldlm_pool_get_slv(struct ldlm_pool *pl)
+{
+	__u64 slv;
+
+	spin_lock(&pl->pl_lock);
+	slv = pl->pl_server_lock_volume;
+	spin_unlock(&pl->pl_lock);
+	return slv;
+}
+
+/**
+ * Sets passed \a clv to \a pl.
+ *
+ * \pre ->pl_lock is not locked.
+ */
+void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv)
+{
+	spin_lock(&pl->pl_lock);
+	pl->pl_client_lock_volume = clv;
+	spin_unlock(&pl->pl_lock);
+}
+
+/**
+ * Returns current LVF from \a pl.
+ */
+__u32 ldlm_pool_get_lvf(struct ldlm_pool *pl)
+{
+	return atomic_read(&pl->pl_lock_volume_factor);
+}
+
+static int ldlm_pool_granted(struct ldlm_pool *pl)
+{
+	return atomic_read(&pl->pl_granted);
+}
+
+/*
+ * count locks from all namespaces (if possible). Returns number of
+ * cached locks.
+ */
+static unsigned long ldlm_pools_count(enum ldlm_side client, gfp_t gfp_mask)
+{
+	unsigned long total = 0;
+	int nr_ns;
+	struct ldlm_namespace *ns;
+	struct ldlm_namespace *ns_old = NULL; /* loop detection */
+
+	if (client == LDLM_NAMESPACE_CLIENT && !(gfp_mask & __GFP_FS))
+		return 0;
+
+	CDEBUG(D_DLMTRACE, "Request to count %s locks from all pools\n",
+	       client == LDLM_NAMESPACE_CLIENT ? "client" : "server");
+
+	/*
+	 * Find out how many resources we may release.
+	 */
+	for (nr_ns = ldlm_namespace_nr_read(client);
+	     nr_ns > 0; nr_ns--) {
+		mutex_lock(ldlm_namespace_lock(client));
+		if (list_empty(ldlm_namespace_list(client))) {
+			mutex_unlock(ldlm_namespace_lock(client));
+			return 0;
+		}
+		ns = ldlm_namespace_first_locked(client);
+
+		if (ns == ns_old) {
+			mutex_unlock(ldlm_namespace_lock(client));
+			break;
+		}
+
+		if (ldlm_ns_empty(ns)) {
+			ldlm_namespace_move_to_inactive_locked(ns, client);
+			mutex_unlock(ldlm_namespace_lock(client));
+			continue;
+		}
+
+		if (!ns_old)
+			ns_old = ns;
+
+		ldlm_namespace_get(ns);
+		ldlm_namespace_move_to_active_locked(ns, client);
+		mutex_unlock(ldlm_namespace_lock(client));
+		total += ldlm_pool_shrink(&ns->ns_pool, 0, gfp_mask);
+		ldlm_namespace_put(ns);
+	}
+
+	return total;
+}
+
+static unsigned long ldlm_pools_scan(enum ldlm_side client, int nr,
+				     gfp_t gfp_mask)
+{
+	unsigned long freed = 0;
+	int tmp, nr_ns;
+	struct ldlm_namespace *ns;
+
+	if (client == LDLM_NAMESPACE_CLIENT && !(gfp_mask & __GFP_FS))
+		return -1;
+
+	/*
+	 * Shrink at least ldlm_namespace_nr_read(client) namespaces.
+	 */
+	for (tmp = nr_ns = ldlm_namespace_nr_read(client);
+	     tmp > 0; tmp--) {
+		int cancel, nr_locks;
+
+		/*
+		 * Do not call shrink under ldlm_namespace_lock(client)
+		 */
+		mutex_lock(ldlm_namespace_lock(client));
+		if (list_empty(ldlm_namespace_list(client))) {
+			mutex_unlock(ldlm_namespace_lock(client));
+			break;
+		}
+		ns = ldlm_namespace_first_locked(client);
+		ldlm_namespace_get(ns);
+		ldlm_namespace_move_to_active_locked(ns, client);
+		mutex_unlock(ldlm_namespace_lock(client));
+
+		nr_locks = ldlm_pool_granted(&ns->ns_pool);
+		/*
+		 * We use to shrink propotionally but with new shrinker API,
+		 * we lost the total number of freeable locks.
+		 */
+		cancel = 1 + min_t(int, nr_locks, nr / nr_ns);
+		freed += ldlm_pool_shrink(&ns->ns_pool, cancel, gfp_mask);
+		ldlm_namespace_put(ns);
+	}
+	/*
+	 * we only decrease the SLV in server pools shrinker, return
+	 * SHRINK_STOP to kernel to avoid needless loop. LU-1128
+	 */
+	return freed;
+}
+
+static unsigned long ldlm_pools_cli_count(struct shrinker *s,
+					  struct shrink_control *sc)
+{
+	return ldlm_pools_count(LDLM_NAMESPACE_CLIENT, sc->gfp_mask);
+}
+
+static unsigned long ldlm_pools_cli_scan(struct shrinker *s,
+					 struct shrink_control *sc)
+{
+	return ldlm_pools_scan(LDLM_NAMESPACE_CLIENT, sc->nr_to_scan,
+			       sc->gfp_mask);
+}
+
+static void ldlm_pools_recalc(struct work_struct *ws);
+static DECLARE_DELAYED_WORK(ldlm_recalc_pools, ldlm_pools_recalc);
+
+static void ldlm_pools_recalc(struct work_struct *ws)
+{
+	enum ldlm_side client = LDLM_NAMESPACE_CLIENT;
+	struct ldlm_namespace *ns;
+	struct ldlm_namespace *ns_old = NULL;
+	/* seconds of sleep if no active namespaces */
+	int time = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
+	int nr;
+
+	/*
+	 * Recalc at least ldlm_namespace_nr_read(client) namespaces.
+	 */
+	for (nr = ldlm_namespace_nr_read(client); nr > 0; nr--) {
+		int     skip;
+		/*
+		 * Lock the list, get first @ns in the list, getref, move it
+		 * to the tail, unlock and call pool recalc. This way we avoid
+		 * calling recalc under @ns lock what is really good as we get
+		 * rid of potential deadlock on client nodes when canceling
+		 * locks synchronously.
+		 */
+		mutex_lock(ldlm_namespace_lock(client));
+		if (list_empty(ldlm_namespace_list(client))) {
+			mutex_unlock(ldlm_namespace_lock(client));
+			break;
+		}
+		ns = ldlm_namespace_first_locked(client);
+
+		if (ns_old == ns) { /* Full pass complete */
+			mutex_unlock(ldlm_namespace_lock(client));
+			break;
+		}
+
+		/* We got an empty namespace, need to move it back to inactive
+		 * list.
+		 * The race with parallel resource creation is fine:
+		 * - If they do namespace_get before our check, we fail the
+		 *   check and they move this item to the end of the list anyway
+		 * - If we do the check and then they do namespace_get, then
+		 *   we move the namespace to inactive and they will move
+		 *   it back to active (synchronised by the lock, so no clash
+		 *   there).
+		 */
+		if (ldlm_ns_empty(ns)) {
+			ldlm_namespace_move_to_inactive_locked(ns, client);
+			mutex_unlock(ldlm_namespace_lock(client));
+			continue;
+		}
+
+		if (!ns_old)
+			ns_old = ns;
+
+		spin_lock(&ns->ns_lock);
+		/*
+		 * skip ns which is being freed, and we don't want to increase
+		 * its refcount again, not even temporarily. bz21519 & LU-499.
+		 */
+		if (ns->ns_stopping) {
+			skip = 1;
+		} else {
+			skip = 0;
+			ldlm_namespace_get(ns);
+		}
+		spin_unlock(&ns->ns_lock);
+
+		ldlm_namespace_move_to_active_locked(ns, client);
+		mutex_unlock(ldlm_namespace_lock(client));
+
+		/*
+		 * After setup is done - recalc the pool.
+		 */
+		if (!skip) {
+			int ttime = ldlm_pool_recalc(&ns->ns_pool);
+
+			if (ttime < time)
+				time = ttime;
+
+			ldlm_namespace_put(ns);
+		}
+	}
+
+	/* Wake up the blocking threads from time to time. */
+	ldlm_bl_thread_wakeup();
+
+	schedule_delayed_work(&ldlm_recalc_pools, time * HZ);
+}
+
+static int ldlm_pools_thread_start(void)
+{
+	schedule_delayed_work(&ldlm_recalc_pools, 0);
+
+	return 0;
+}
+
+static void ldlm_pools_thread_stop(void)
+{
+	cancel_delayed_work_sync(&ldlm_recalc_pools);
+}
+
+static struct shrinker ldlm_pools_cli_shrinker = {
+	.count_objects	= ldlm_pools_cli_count,
+	.scan_objects	= ldlm_pools_cli_scan,
+	.seeks		= DEFAULT_SEEKS,
+};
+
+int ldlm_pools_init(void)
+{
+	int rc;
+
+	rc = ldlm_pools_thread_start();
+	if (!rc)
+		rc = register_shrinker(&ldlm_pools_cli_shrinker);
+
+	return rc;
+}
+
+void ldlm_pools_fini(void)
+{
+	unregister_shrinker(&ldlm_pools_cli_shrinker);
+
+	ldlm_pools_thread_stop();
+}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_request.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_request.c
new file mode 100644
index 000000000000..cdc52eed6d85
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_request.c
@@ -0,0 +1,2033 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2010, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+/**
+ * This file contains Asynchronous System Trap (AST) handlers and related
+ * LDLM request-processing routines.
+ *
+ * An AST is a callback issued on a lock when its state is changed. There are
+ * several different types of ASTs (callbacks) registered for each lock:
+ *
+ * - completion AST: when a lock is enqueued by some process, but cannot be
+ *   granted immediately due to other conflicting locks on the same resource,
+ *   the completion AST is sent to notify the caller when the lock is
+ *   eventually granted
+ *
+ * - blocking AST: when a lock is granted to some process, if another process
+ *   enqueues a conflicting (blocking) lock on a resource, a blocking AST is
+ *   sent to notify the holder(s) of the lock(s) of the conflicting lock
+ *   request. The lock holder(s) must release their lock(s) on that resource in
+ *   a timely manner or be evicted by the server.
+ *
+ * - glimpse AST: this is used when a process wants information about a lock
+ *   (i.e. the lock value block (LVB)) but does not necessarily require holding
+ *   the lock. If the resource is locked, the lock holder(s) are sent glimpse
+ *   ASTs and the LVB is returned to the caller, and lock holder(s) may CANCEL
+ *   their lock(s) if they are idle. If the resource is not locked, the server
+ *   may grant the lock.
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+
+#include <lustre_errno.h>
+#include <lustre_dlm.h>
+#include <obd_class.h>
+#include <obd.h>
+#include <linux/libcfs/libcfs_hash.h>
+
+#include "ldlm_internal.h"
+
+unsigned int ldlm_enqueue_min = OBD_TIMEOUT_DEFAULT;
+module_param(ldlm_enqueue_min, uint, 0644);
+MODULE_PARM_DESC(ldlm_enqueue_min, "lock enqueue timeout minimum");
+
+/* in client side, whether the cached locks will be canceled before replay */
+unsigned int ldlm_cancel_unused_locks_before_replay = 1;
+
+struct ldlm_async_args {
+	struct lustre_handle lock_handle;
+};
+
+/**
+ * ldlm_request_bufsize
+ *
+ * @count:	number of ldlm handles
+ * @type:	ldlm opcode
+ *
+ * If opcode=LDLM_ENQUEUE, 1 slot is already occupied,
+ * LDLM_LOCKREQ_HANDLE -1 slots are available.
+ * Otherwise, LDLM_LOCKREQ_HANDLE slots are available.
+ *
+ * Return:	size of the request buffer
+ */
+static int ldlm_request_bufsize(int count, int type)
+{
+	int avail = LDLM_LOCKREQ_HANDLES;
+
+	if (type == LDLM_ENQUEUE)
+		avail -= LDLM_ENQUEUE_CANCEL_OFF;
+
+	if (count > avail)
+		avail = (count - avail) * sizeof(struct lustre_handle);
+	else
+		avail = 0;
+
+	return sizeof(struct ldlm_request) + avail;
+}
+
+static void ldlm_expired_completion_wait(struct ldlm_lock *lock, __u32 conn_cnt)
+{
+	struct obd_import *imp;
+	struct obd_device *obd;
+
+	if (!lock->l_conn_export) {
+		static unsigned long next_dump, last_dump;
+
+		LDLM_ERROR(lock,
+			   "lock timed out (enqueued at %lld, %llds ago); not entering recovery in server code, just going back to sleep",
+			   (s64)lock->l_last_activity,
+			   (s64)(ktime_get_real_seconds() -
+				 lock->l_last_activity));
+		if (time_after(jiffies, next_dump)) {
+			last_dump = next_dump;
+			next_dump = jiffies + 300 * HZ;
+			ldlm_namespace_dump(D_DLMTRACE,
+					    ldlm_lock_to_ns(lock));
+			if (last_dump == 0)
+				libcfs_debug_dumplog();
+		}
+		return;
+	}
+
+	obd = lock->l_conn_export->exp_obd;
+	imp = obd->u.cli.cl_import;
+	ptlrpc_fail_import(imp, conn_cnt);
+	LDLM_ERROR(lock,
+		   "lock timed out (enqueued at %lld, %llds ago), entering recovery for %s@%s",
+		   (s64)lock->l_last_activity,
+		   (s64)(ktime_get_real_seconds() - lock->l_last_activity),
+		   obd2cli_tgt(obd), imp->imp_connection->c_remote_uuid.uuid);
+}
+
+/**
+ * Calculate the Completion timeout (covering enqueue, BL AST, data flush,
+ * lock cancel, and their replies). Used for lock completion timeout on the
+ * client side.
+ *
+ * \param[in] lock	lock which is waiting the completion callback
+ *
+ * \retval		timeout in seconds to wait for the server reply
+ */
+/* We use the same basis for both server side and client side functions
+ * from a single node.
+ */
+static unsigned int ldlm_cp_timeout(struct ldlm_lock *lock)
+{
+	unsigned int timeout;
+
+	if (AT_OFF)
+		return obd_timeout;
+
+	/*
+	 * Wait a long time for enqueue - server may have to callback a
+	 * lock from another client.  Server will evict the other client if it
+	 * doesn't respond reasonably, and then give us the lock.
+	 */
+	timeout = at_get(ldlm_lock_to_ns_at(lock));
+	return max(3 * timeout, ldlm_enqueue_min);
+}
+
+/**
+ * Helper function for ldlm_completion_ast(), updating timings when lock is
+ * actually granted.
+ */
+static int ldlm_completion_tail(struct ldlm_lock *lock, void *data)
+{
+	long delay;
+	int result = 0;
+
+	if (ldlm_is_destroyed(lock) || ldlm_is_failed(lock)) {
+		LDLM_DEBUG(lock, "client-side enqueue: destroyed");
+		result = -EIO;
+	} else if (!data) {
+		LDLM_DEBUG(lock, "client-side enqueue: granted");
+	} else {
+		/* Take into AT only CP RPC, not immediately granted locks */
+		delay = ktime_get_real_seconds() - lock->l_last_activity;
+		LDLM_DEBUG(lock, "client-side enqueue: granted after %lds",
+			   delay);
+
+		/* Update our time estimate */
+		at_measured(ldlm_lock_to_ns_at(lock), delay);
+	}
+	return result;
+}
+
+/**
+ * Generic LDLM "completion" AST. This is called in several cases:
+ *
+ *     - when a reply to an ENQUEUE RPC is received from the server
+ *       (ldlm_cli_enqueue_fini()). Lock might be granted or not granted at
+ *       this point (determined by flags);
+ *
+ *     - when LDLM_CP_CALLBACK RPC comes to client to notify it that lock has
+ *       been granted;
+ *
+ *     - when ldlm_lock_match(LDLM_FL_LVB_READY) is about to wait until lock
+ *       gets correct lvb;
+ *
+ *     - to force all locks when resource is destroyed (cleanup_resource());
+ *
+ *     - during lock conversion (not used currently).
+ *
+ * If lock is not granted in the first case, this function waits until second
+ * or penultimate cases happen in some other thread.
+ *
+ */
+int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
+{
+	/* XXX ALLOCATE - 160 bytes */
+	struct obd_device *obd;
+	struct obd_import *imp = NULL;
+	__u32 timeout;
+	__u32 conn_cnt = 0;
+	int rc = 0;
+
+	if (flags == LDLM_FL_WAIT_NOREPROC) {
+		LDLM_DEBUG(lock, "client-side enqueue waiting on pending lock");
+		goto noreproc;
+	}
+
+	if (!(flags & LDLM_FL_BLOCKED_MASK)) {
+		wake_up(&lock->l_waitq);
+		return 0;
+	}
+
+	LDLM_DEBUG(lock,
+		   "client-side enqueue returned a blocked lock, sleeping");
+
+noreproc:
+
+	obd = class_exp2obd(lock->l_conn_export);
+
+	/* if this is a local lock, then there is no import */
+	if (obd)
+		imp = obd->u.cli.cl_import;
+
+	timeout = ldlm_cp_timeout(lock);
+
+	lock->l_last_activity = ktime_get_real_seconds();
+
+	if (imp) {
+		spin_lock(&imp->imp_lock);
+		conn_cnt = imp->imp_conn_cnt;
+		spin_unlock(&imp->imp_lock);
+	}
+	if (OBD_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
+				 OBD_FAIL_LDLM_CP_BL_RACE | OBD_FAIL_ONCE)) {
+		ldlm_set_fail_loc(lock);
+		rc = -EINTR;
+	} else {
+		/* Go to sleep until the lock is granted or canceled. */
+		if (!ldlm_is_no_timeout(lock)) {
+			/* Wait uninterruptible for a while first */
+			rc = wait_event_idle_timeout(lock->l_waitq,
+						     is_granted_or_cancelled(lock),
+						     timeout * HZ);
+			if (rc == 0)
+				ldlm_expired_completion_wait(lock, conn_cnt);
+		}
+		/* Now wait abortable */
+		if (rc == 0)
+			rc = l_wait_event_abortable(lock->l_waitq,
+						    is_granted_or_cancelled(lock));
+		else
+			rc = 0;
+	}
+
+	if (rc) {
+		LDLM_DEBUG(lock, "client-side enqueue waking up: failed (%d)",
+			   rc);
+		return rc;
+	}
+
+	return ldlm_completion_tail(lock, data);
+}
+EXPORT_SYMBOL(ldlm_completion_ast);
+
+static void failed_lock_cleanup(struct ldlm_namespace *ns,
+				struct ldlm_lock *lock, int mode)
+{
+	int need_cancel = 0;
+
+	/* Set a flag to prevent us from sending a CANCEL (bug 407) */
+	lock_res_and_lock(lock);
+	/* Check that lock is not granted or failed, we might race. */
+	if ((lock->l_req_mode != lock->l_granted_mode) &&
+	    !ldlm_is_failed(lock)) {
+		/* Make sure that this lock will not be found by raced
+		 * bl_ast and -EINVAL reply is sent to server anyways.
+		 * bug 17645
+		 */
+		lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_FAILED |
+				 LDLM_FL_ATOMIC_CB | LDLM_FL_CBPENDING;
+		need_cancel = 1;
+	}
+	unlock_res_and_lock(lock);
+
+	if (need_cancel)
+		LDLM_DEBUG(lock,
+			   "setting FL_LOCAL_ONLY | LDLM_FL_FAILED | LDLM_FL_ATOMIC_CB | LDLM_FL_CBPENDING");
+	else
+		LDLM_DEBUG(lock, "lock was granted or failed in race");
+
+	/* XXX - HACK because we shouldn't call ldlm_lock_destroy()
+	 *       from llite/file.c/ll_file_flock().
+	 */
+	/* This code makes for the fact that we do not have blocking handler on
+	 * a client for flock locks. As such this is the place where we must
+	 * completely kill failed locks. (interrupted and those that
+	 * were waiting to be granted when server evicted us.
+	 */
+	if (lock->l_resource->lr_type == LDLM_FLOCK) {
+		lock_res_and_lock(lock);
+		if (!ldlm_is_destroyed(lock)) {
+			ldlm_resource_unlink_lock(lock);
+			ldlm_lock_decref_internal_nolock(lock, mode);
+			ldlm_lock_destroy_nolock(lock);
+		}
+		unlock_res_and_lock(lock);
+	} else {
+		ldlm_lock_decref_internal(lock, mode);
+	}
+}
+
+/**
+ * Finishing portion of client lock enqueue code.
+ *
+ * Called after receiving reply from server.
+ */
+int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
+			  enum ldlm_type type, __u8 with_policy,
+			  enum ldlm_mode mode,
+			  __u64 *flags, void *lvb, __u32 lvb_len,
+			  const struct lustre_handle *lockh, int rc)
+{
+	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
+	int is_replay = *flags & LDLM_FL_REPLAY;
+	struct ldlm_lock *lock;
+	struct ldlm_reply *reply;
+	int cleanup_phase = 1;
+
+	lock = ldlm_handle2lock(lockh);
+	/* ldlm_cli_enqueue is holding a reference on this lock. */
+	if (!lock) {
+		LASSERT(type == LDLM_FLOCK);
+		return -ENOLCK;
+	}
+
+	LASSERTF(ergo(lvb_len != 0, lvb_len == lock->l_lvb_len),
+		 "lvb_len = %d, l_lvb_len = %d\n", lvb_len, lock->l_lvb_len);
+
+	if (rc != ELDLM_OK) {
+		LASSERT(!is_replay);
+		LDLM_DEBUG(lock, "client-side enqueue END (%s)",
+			   rc == ELDLM_LOCK_ABORTED ? "ABORTED" : "FAILED");
+
+		if (rc != ELDLM_LOCK_ABORTED)
+			goto cleanup;
+	}
+
+	/* Before we return, swab the reply */
+	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
+	if (!reply) {
+		rc = -EPROTO;
+		goto cleanup;
+	}
+
+	if (lvb_len > 0) {
+		int size = 0;
+
+		size = req_capsule_get_size(&req->rq_pill, &RMF_DLM_LVB,
+					    RCL_SERVER);
+		if (size < 0) {
+			LDLM_ERROR(lock, "Fail to get lvb_len, rc = %d", size);
+			rc = size;
+			goto cleanup;
+		} else if (unlikely(size > lvb_len)) {
+			LDLM_ERROR(lock,
+				   "Replied LVB is larger than expectation, expected = %d, replied = %d",
+				   lvb_len, size);
+			rc = -EINVAL;
+			goto cleanup;
+		}
+		lvb_len = size;
+	}
+
+	if (rc == ELDLM_LOCK_ABORTED) {
+		if (lvb_len > 0 && lvb)
+			rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_SERVER,
+					   lvb, lvb_len);
+		if (rc == 0)
+			rc = ELDLM_LOCK_ABORTED;
+		goto cleanup;
+	}
+
+	/* lock enqueued on the server */
+	cleanup_phase = 0;
+
+	lock_res_and_lock(lock);
+	lock->l_remote_handle = reply->lock_handle;
+
+	*flags = ldlm_flags_from_wire(reply->lock_flags);
+	lock->l_flags |= ldlm_flags_from_wire(reply->lock_flags &
+					      LDLM_FL_INHERIT_MASK);
+	unlock_res_and_lock(lock);
+
+	CDEBUG(D_INFO, "local: %p, remote cookie: %#llx, flags: 0x%llx\n",
+	       lock, reply->lock_handle.cookie, *flags);
+
+	/* If enqueue returned a blocked lock but the completion handler has
+	 * already run, then it fixed up the resource and we don't need to do it
+	 * again.
+	 */
+	if ((*flags) & LDLM_FL_LOCK_CHANGED) {
+		int newmode = reply->lock_desc.l_req_mode;
+
+		LASSERT(!is_replay);
+		if (newmode && newmode != lock->l_req_mode) {
+			LDLM_DEBUG(lock, "server returned different mode %s",
+				   ldlm_lockname[newmode]);
+			lock->l_req_mode = newmode;
+		}
+
+		if (!ldlm_res_eq(&reply->lock_desc.l_resource.lr_name,
+				 &lock->l_resource->lr_name)) {
+			CDEBUG(D_INFO,
+			       "remote intent success, locking " DLDLMRES " instead of " DLDLMRES "\n",
+			       PLDLMRES(&reply->lock_desc.l_resource),
+			       PLDLMRES(lock->l_resource));
+
+			rc = ldlm_lock_change_resource(ns, lock,
+					&reply->lock_desc.l_resource.lr_name);
+			if (rc || !lock->l_resource) {
+				rc = -ENOMEM;
+				goto cleanup;
+			}
+			LDLM_DEBUG(lock, "client-side enqueue, new resource");
+		}
+		if (with_policy)
+			if (!(type == LDLM_IBITS &&
+			      !(exp_connect_flags(exp) & OBD_CONNECT_IBITS)))
+				/* We assume lock type cannot change on server*/
+				ldlm_convert_policy_to_local(exp,
+						lock->l_resource->lr_type,
+						&reply->lock_desc.l_policy_data,
+						&lock->l_policy_data);
+		if (type != LDLM_PLAIN)
+			LDLM_DEBUG(lock,
+				   "client-side enqueue, new policy data");
+	}
+
+	if ((*flags) & LDLM_FL_AST_SENT) {
+		lock_res_and_lock(lock);
+		lock->l_flags |= LDLM_FL_CBPENDING |  LDLM_FL_BL_AST;
+		unlock_res_and_lock(lock);
+		LDLM_DEBUG(lock, "enqueue reply includes blocking AST");
+	}
+
+	/* If the lock has already been granted by a completion AST, don't
+	 * clobber the LVB with an older one.
+	 */
+	if (lvb_len > 0) {
+		/* We must lock or a racing completion might update lvb without
+		 * letting us know and we'll clobber the correct value.
+		 * Cannot unlock after the check either, as that still leaves
+		 * a tiny window for completion to get in
+		 */
+		lock_res_and_lock(lock);
+		if (lock->l_req_mode != lock->l_granted_mode)
+			rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_SERVER,
+					   lock->l_lvb_data, lvb_len);
+		unlock_res_and_lock(lock);
+		if (rc < 0) {
+			cleanup_phase = 1;
+			goto cleanup;
+		}
+	}
+
+	if (!is_replay) {
+		rc = ldlm_lock_enqueue(ns, &lock, NULL, flags);
+		if (lock->l_completion_ast) {
+			int err = lock->l_completion_ast(lock, *flags, NULL);
+
+			if (!rc)
+				rc = err;
+			if (rc)
+				cleanup_phase = 1;
+		}
+	}
+
+	if (lvb_len > 0 && lvb) {
+		/* Copy the LVB here, and not earlier, because the completion
+		 * AST (if any) can override what we got in the reply
+		 */
+		memcpy(lvb, lock->l_lvb_data, lvb_len);
+	}
+
+	LDLM_DEBUG(lock, "client-side enqueue END");
+cleanup:
+	if (cleanup_phase == 1 && rc)
+		failed_lock_cleanup(ns, lock, mode);
+	/* Put lock 2 times, the second reference is held by ldlm_cli_enqueue */
+	LDLM_LOCK_PUT(lock);
+	LDLM_LOCK_RELEASE(lock);
+	return rc;
+}
+EXPORT_SYMBOL(ldlm_cli_enqueue_fini);
+
+/**
+ * Estimate number of lock handles that would fit into request of given
+ * size.  PAGE_SIZE-512 is to allow TCP/IP and LNET headers to fit into
+ * a single page on the send/receive side. XXX: 512 should be changed to
+ * more adequate value.
+ */
+static inline int ldlm_req_handles_avail(int req_size, int off)
+{
+	int avail;
+
+	avail = min_t(int, LDLM_MAXREQSIZE, PAGE_SIZE - 512) - req_size;
+	if (likely(avail >= 0))
+		avail /= (int)sizeof(struct lustre_handle);
+	else
+		avail = 0;
+	avail += LDLM_LOCKREQ_HANDLES - off;
+
+	return avail;
+}
+
+static inline int ldlm_capsule_handles_avail(struct req_capsule *pill,
+					     enum req_location loc,
+					     int off)
+{
+	u32 size = req_capsule_msg_size(pill, loc);
+
+	return ldlm_req_handles_avail(size, off);
+}
+
+static inline int ldlm_format_handles_avail(struct obd_import *imp,
+					    const struct req_format *fmt,
+					    enum req_location loc, int off)
+{
+	u32 size = req_capsule_fmt_size(imp->imp_msg_magic, fmt, loc);
+
+	return ldlm_req_handles_avail(size, off);
+}
+
+/**
+ * Cancel LRU locks and pack them into the enqueue request. Pack there the given
+ * \a count locks in \a cancels.
+ *
+ * This is to be called by functions preparing their own requests that
+ * might contain lists of locks to cancel in addition to actual operation
+ * that needs to be performed.
+ */
+int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
+		      int version, int opc, int canceloff,
+		      struct list_head *cancels, int count)
+{
+	struct ldlm_namespace   *ns = exp->exp_obd->obd_namespace;
+	struct req_capsule      *pill = &req->rq_pill;
+	struct ldlm_request     *dlm = NULL;
+	int flags, avail, to_free, pack = 0;
+	LIST_HEAD(head);
+	int rc;
+
+	if (!cancels)
+		cancels = &head;
+	if (ns_connect_cancelset(ns)) {
+		/* Estimate the amount of available space in the request. */
+		req_capsule_filled_sizes(pill, RCL_CLIENT);
+		avail = ldlm_capsule_handles_avail(pill, RCL_CLIENT, canceloff);
+
+		flags = ns_connect_lru_resize(ns) ?
+			LDLM_LRU_FLAG_LRUR_NO_WAIT : LDLM_LRU_FLAG_AGED;
+		to_free = !ns_connect_lru_resize(ns) &&
+			  opc == LDLM_ENQUEUE ? 1 : 0;
+
+		/* Cancel LRU locks here _only_ if the server supports
+		 * EARLY_CANCEL. Otherwise we have to send extra CANCEL
+		 * RPC, which will make us slower.
+		 */
+		if (avail > count)
+			count += ldlm_cancel_lru_local(ns, cancels, to_free,
+						       avail - count, 0, flags);
+		if (avail > count)
+			pack = count;
+		else
+			pack = avail;
+		req_capsule_set_size(pill, &RMF_DLM_REQ, RCL_CLIENT,
+				     ldlm_request_bufsize(pack, opc));
+	}
+
+	rc = ptlrpc_request_pack(req, version, opc);
+	if (rc) {
+		ldlm_lock_list_put(cancels, l_bl_ast, count);
+		return rc;
+	}
+
+	if (ns_connect_cancelset(ns)) {
+		if (canceloff) {
+			dlm = req_capsule_client_get(pill, &RMF_DLM_REQ);
+			LASSERT(dlm);
+			/* Skip first lock handler in ldlm_request_pack(),
+			 * this method will increment @lock_count according
+			 * to the lock handle amount actually written to
+			 * the buffer.
+			 */
+			dlm->lock_count = canceloff;
+		}
+		/* Pack into the request @pack lock handles. */
+		ldlm_cli_cancel_list(cancels, pack, req, 0);
+		/* Prepare and send separate cancel RPC for others. */
+		ldlm_cli_cancel_list(cancels, count - pack, NULL, 0);
+	} else {
+		ldlm_lock_list_put(cancels, l_bl_ast, count);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(ldlm_prep_elc_req);
+
+int ldlm_prep_enqueue_req(struct obd_export *exp, struct ptlrpc_request *req,
+			  struct list_head *cancels, int count)
+{
+	return ldlm_prep_elc_req(exp, req, LUSTRE_DLM_VERSION, LDLM_ENQUEUE,
+				 LDLM_ENQUEUE_CANCEL_OFF, cancels, count);
+}
+EXPORT_SYMBOL(ldlm_prep_enqueue_req);
+
+static struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp,
+						int lvb_len)
+{
+	struct ptlrpc_request *req;
+	int rc;
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_LDLM_ENQUEUE);
+	if (!req)
+		return ERR_PTR(-ENOMEM);
+
+	rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
+	if (rc) {
+		ptlrpc_request_free(req);
+		return ERR_PTR(rc);
+	}
+
+	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER, lvb_len);
+	ptlrpc_request_set_replen(req);
+	return req;
+}
+
+/**
+ * Client-side lock enqueue.
+ *
+ * If a request has some specific initialisation it is passed in \a reqp,
+ * otherwise it is created in ldlm_cli_enqueue.
+ *
+ * Supports sync and async requests, pass \a async flag accordingly. If a
+ * request was created in ldlm_cli_enqueue and it is the async request,
+ * pass it to the caller in \a reqp.
+ */
+int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
+		     struct ldlm_enqueue_info *einfo,
+		     const struct ldlm_res_id *res_id,
+		     union ldlm_policy_data const *policy, __u64 *flags,
+		     void *lvb, __u32 lvb_len, enum lvb_type lvb_type,
+		     struct lustre_handle *lockh, int async)
+{
+	struct ldlm_namespace *ns;
+	struct ldlm_lock      *lock;
+	struct ldlm_request   *body;
+	int		    is_replay = *flags & LDLM_FL_REPLAY;
+	int		    req_passed_in = 1;
+	int		    rc, err;
+	struct ptlrpc_request *req;
+
+	ns = exp->exp_obd->obd_namespace;
+
+	/* If we're replaying this lock, just check some invariants.
+	 * If we're creating a new lock, get everything all setup nicely.
+	 */
+	if (is_replay) {
+		lock = ldlm_handle2lock_long(lockh, 0);
+		LASSERT(lock);
+		LDLM_DEBUG(lock, "client-side enqueue START");
+		LASSERT(exp == lock->l_conn_export);
+	} else {
+		const struct ldlm_callback_suite cbs = {
+			.lcs_completion = einfo->ei_cb_cp,
+			.lcs_blocking	= einfo->ei_cb_bl,
+			.lcs_glimpse	= einfo->ei_cb_gl
+		};
+		lock = ldlm_lock_create(ns, res_id, einfo->ei_type,
+					einfo->ei_mode, &cbs, einfo->ei_cbdata,
+					lvb_len, lvb_type);
+		if (IS_ERR(lock))
+			return PTR_ERR(lock);
+		/* for the local lock, add the reference */
+		ldlm_lock_addref_internal(lock, einfo->ei_mode);
+		ldlm_lock2handle(lock, lockh);
+		if (policy)
+			lock->l_policy_data = *policy;
+
+		if (einfo->ei_type == LDLM_EXTENT) {
+			/* extent lock without policy is a bug */
+			if (!policy)
+				LBUG();
+
+			lock->l_req_extent = policy->l_extent;
+		}
+		LDLM_DEBUG(lock, "client-side enqueue START, flags %llx",
+			   *flags);
+	}
+
+	lock->l_conn_export = exp;
+	lock->l_export = NULL;
+	lock->l_blocking_ast = einfo->ei_cb_bl;
+	lock->l_flags |= (*flags & (LDLM_FL_NO_LRU | LDLM_FL_EXCL));
+	lock->l_last_activity = ktime_get_real_seconds();
+
+	/* lock not sent to server yet */
+	if (!reqp || !*reqp) {
+		req = ldlm_enqueue_pack(exp, lvb_len);
+		if (IS_ERR(req)) {
+			failed_lock_cleanup(ns, lock, einfo->ei_mode);
+			LDLM_LOCK_RELEASE(lock);
+			return PTR_ERR(req);
+		}
+
+		req_passed_in = 0;
+		if (reqp)
+			*reqp = req;
+	} else {
+		int len;
+
+		req = *reqp;
+		len = req_capsule_get_size(&req->rq_pill, &RMF_DLM_REQ,
+					   RCL_CLIENT);
+		LASSERTF(len >= sizeof(*body), "buflen[%d] = %d, not %d\n",
+			 DLM_LOCKREQ_OFF, len, (int)sizeof(*body));
+	}
+
+	/* Dump lock data into the request buffer */
+	body = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
+	ldlm_lock2desc(lock, &body->lock_desc);
+	body->lock_flags = ldlm_flags_to_wire(*flags);
+	body->lock_handle[0] = *lockh;
+
+	if (async) {
+		LASSERT(reqp);
+		return 0;
+	}
+
+	LDLM_DEBUG(lock, "sending request");
+
+	rc = ptlrpc_queue_wait(req);
+
+	err = ldlm_cli_enqueue_fini(exp, req, einfo->ei_type, policy ? 1 : 0,
+				    einfo->ei_mode, flags, lvb, lvb_len,
+				    lockh, rc);
+
+	/* If ldlm_cli_enqueue_fini did not find the lock, we need to free
+	 * one reference that we took
+	 */
+	if (err == -ENOLCK)
+		LDLM_LOCK_RELEASE(lock);
+	else
+		rc = err;
+
+	if (!req_passed_in && req) {
+		ptlrpc_req_finished(req);
+		if (reqp)
+			*reqp = NULL;
+	}
+
+	return rc;
+}
+EXPORT_SYMBOL(ldlm_cli_enqueue);
+
+/**
+ * Cancel locks locally.
+ * Returns:
+ * \retval LDLM_FL_LOCAL_ONLY if there is no need for a CANCEL RPC to the server
+ * \retval LDLM_FL_CANCELING otherwise;
+ * \retval LDLM_FL_BL_AST if there is a need for a separate CANCEL RPC.
+ */
+static __u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
+{
+	__u64 rc = LDLM_FL_LOCAL_ONLY;
+
+	if (lock->l_conn_export) {
+		bool local_only;
+
+		LDLM_DEBUG(lock, "client-side cancel");
+		/* Set this flag to prevent others from getting new references*/
+		lock_res_and_lock(lock);
+		ldlm_set_cbpending(lock);
+		local_only = !!(lock->l_flags &
+				(LDLM_FL_LOCAL_ONLY | LDLM_FL_CANCEL_ON_BLOCK));
+		ldlm_cancel_callback(lock);
+		rc = ldlm_is_bl_ast(lock) ? LDLM_FL_BL_AST : LDLM_FL_CANCELING;
+		unlock_res_and_lock(lock);
+
+		if (local_only) {
+			CDEBUG(D_DLMTRACE,
+			       "not sending request (at caller's instruction)\n");
+			rc = LDLM_FL_LOCAL_ONLY;
+		}
+		ldlm_lock_cancel(lock);
+	} else {
+		LDLM_ERROR(lock, "Trying to cancel local lock");
+		LBUG();
+	}
+
+	return rc;
+}
+
+/**
+ * Pack \a count locks in \a head into ldlm_request buffer of request \a req.
+ */
+static void ldlm_cancel_pack(struct ptlrpc_request *req,
+			     struct list_head *head, int count)
+{
+	struct ldlm_request *dlm;
+	struct ldlm_lock *lock;
+	int max, packed = 0;
+
+	dlm = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
+	LASSERT(dlm);
+
+	/* Check the room in the request buffer. */
+	max = req_capsule_get_size(&req->rq_pill, &RMF_DLM_REQ, RCL_CLIENT) -
+		sizeof(struct ldlm_request);
+	max /= sizeof(struct lustre_handle);
+	max += LDLM_LOCKREQ_HANDLES;
+	LASSERT(max >= dlm->lock_count + count);
+
+	/* XXX: it would be better to pack lock handles grouped by resource.
+	 * so that the server cancel would call filter_lvbo_update() less
+	 * frequently.
+	 */
+	list_for_each_entry(lock, head, l_bl_ast) {
+		if (!count--)
+			break;
+		LASSERT(lock->l_conn_export);
+		/* Pack the lock handle to the given request buffer. */
+		LDLM_DEBUG(lock, "packing");
+		dlm->lock_handle[dlm->lock_count++] = lock->l_remote_handle;
+		packed++;
+	}
+	CDEBUG(D_DLMTRACE, "%d locks packed\n", packed);
+}
+
+/**
+ * Prepare and send a batched cancel RPC. It will include \a count lock
+ * handles of locks given in \a cancels list.
+ */
+static int ldlm_cli_cancel_req(struct obd_export *exp,
+			       struct list_head *cancels,
+			       int count, enum ldlm_cancel_flags flags)
+{
+	struct ptlrpc_request *req = NULL;
+	struct obd_import *imp;
+	int free, sent = 0;
+	int rc = 0;
+
+	LASSERT(exp);
+	LASSERT(count > 0);
+
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL, cfs_fail_val);
+
+	if (CFS_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_RACE))
+		return count;
+
+	free = ldlm_format_handles_avail(class_exp2cliimp(exp),
+					 &RQF_LDLM_CANCEL, RCL_CLIENT, 0);
+	if (count > free)
+		count = free;
+
+	while (1) {
+		imp = class_exp2cliimp(exp);
+		if (!imp || imp->imp_invalid) {
+			CDEBUG(D_DLMTRACE,
+			       "skipping cancel on invalid import %p\n", imp);
+			return count;
+		}
+
+		req = ptlrpc_request_alloc(imp, &RQF_LDLM_CANCEL);
+		if (!req) {
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		req_capsule_filled_sizes(&req->rq_pill, RCL_CLIENT);
+		req_capsule_set_size(&req->rq_pill, &RMF_DLM_REQ, RCL_CLIENT,
+				     ldlm_request_bufsize(count, LDLM_CANCEL));
+
+		rc = ptlrpc_request_pack(req, LUSTRE_DLM_VERSION, LDLM_CANCEL);
+		if (rc) {
+			ptlrpc_request_free(req);
+			goto out;
+		}
+
+		req->rq_request_portal = LDLM_CANCEL_REQUEST_PORTAL;
+		req->rq_reply_portal = LDLM_CANCEL_REPLY_PORTAL;
+		ptlrpc_at_set_req_timeout(req);
+
+		ldlm_cancel_pack(req, cancels, count);
+
+		ptlrpc_request_set_replen(req);
+		if (flags & LCF_ASYNC) {
+			ptlrpcd_add_req(req);
+			sent = count;
+			goto out;
+		}
+
+		rc = ptlrpc_queue_wait(req);
+		if (rc == LUSTRE_ESTALE) {
+			CDEBUG(D_DLMTRACE,
+			       "client/server (nid %s) out of sync -- not fatal\n",
+			       libcfs_nid2str(req->rq_import->
+					      imp_connection->c_peer.nid));
+			rc = 0;
+		} else if (rc == -ETIMEDOUT && /* check there was no reconnect*/
+			   req->rq_import_generation == imp->imp_generation) {
+			ptlrpc_req_finished(req);
+			continue;
+		} else if (rc != ELDLM_OK) {
+			/* -ESHUTDOWN is common on umount */
+			CDEBUG_LIMIT(rc == -ESHUTDOWN ? D_DLMTRACE : D_ERROR,
+				     "Got rc %d from cancel RPC: canceling anyway\n",
+				     rc);
+			break;
+		}
+		sent = count;
+		break;
+	}
+
+	ptlrpc_req_finished(req);
+out:
+	return sent ? sent : rc;
+}
+
+static inline struct ldlm_pool *ldlm_imp2pl(struct obd_import *imp)
+{
+	return &imp->imp_obd->obd_namespace->ns_pool;
+}
+
+/**
+ * Update client's OBD pool related fields with new SLV and Limit from \a req.
+ */
+int ldlm_cli_update_pool(struct ptlrpc_request *req)
+{
+	struct obd_device *obd;
+	__u64 new_slv;
+	__u32 new_limit;
+
+	if (unlikely(!req->rq_import || !req->rq_import->imp_obd ||
+		     !imp_connect_lru_resize(req->rq_import))) {
+		/*
+		 * Do nothing for corner cases.
+		 */
+		return 0;
+	}
+
+	/* In some cases RPC may contain SLV and limit zeroed out. This
+	 * is the case when server does not support LRU resize feature.
+	 * This is also possible in some recovery cases when server-side
+	 * reqs have no reference to the OBD export and thus access to
+	 * server-side namespace is not possible.
+	 */
+	if (lustre_msg_get_slv(req->rq_repmsg) == 0 ||
+	    lustre_msg_get_limit(req->rq_repmsg) == 0) {
+		DEBUG_REQ(D_HA, req,
+			  "Zero SLV or Limit found (SLV: %llu, Limit: %u)",
+			  lustre_msg_get_slv(req->rq_repmsg),
+			  lustre_msg_get_limit(req->rq_repmsg));
+		return 0;
+	}
+
+	new_limit = lustre_msg_get_limit(req->rq_repmsg);
+	new_slv = lustre_msg_get_slv(req->rq_repmsg);
+	obd = req->rq_import->imp_obd;
+
+	/* Set new SLV and limit in OBD fields to make them accessible
+	 * to the pool thread. We do not access obd_namespace and pool
+	 * directly here as there is no reliable way to make sure that
+	 * they are still alive at cleanup time. Evil races are possible
+	 * which may cause Oops at that time.
+	 */
+	write_lock(&obd->obd_pool_lock);
+	obd->obd_pool_slv = new_slv;
+	obd->obd_pool_limit = new_limit;
+	write_unlock(&obd->obd_pool_lock);
+
+	return 0;
+}
+
+/**
+ * Client side lock cancel.
+ *
+ * Lock must not have any readers or writers by this time.
+ */
+int ldlm_cli_cancel(const struct lustre_handle *lockh,
+		    enum ldlm_cancel_flags cancel_flags)
+{
+	struct obd_export *exp;
+	int avail, flags, count = 1;
+	__u64 rc = 0;
+	struct ldlm_namespace *ns;
+	struct ldlm_lock *lock;
+	LIST_HEAD(cancels);
+
+	lock = ldlm_handle2lock_long(lockh, 0);
+	if (!lock) {
+		LDLM_DEBUG_NOLOCK("lock is already being destroyed");
+		return 0;
+	}
+
+	lock_res_and_lock(lock);
+	/* Lock is being canceled and the caller doesn't want to wait */
+	if (ldlm_is_canceling(lock) && (cancel_flags & LCF_ASYNC)) {
+		unlock_res_and_lock(lock);
+		LDLM_LOCK_RELEASE(lock);
+		return 0;
+	}
+
+	ldlm_set_canceling(lock);
+	unlock_res_and_lock(lock);
+
+	rc = ldlm_cli_cancel_local(lock);
+	if (rc == LDLM_FL_LOCAL_ONLY || cancel_flags & LCF_LOCAL) {
+		LDLM_LOCK_RELEASE(lock);
+		return 0;
+	}
+	/* Even if the lock is marked as LDLM_FL_BL_AST, this is a LDLM_CANCEL
+	 * RPC which goes to canceld portal, so we can cancel other LRU locks
+	 * here and send them all as one LDLM_CANCEL RPC.
+	 */
+	LASSERT(list_empty(&lock->l_bl_ast));
+	list_add(&lock->l_bl_ast, &cancels);
+
+	exp = lock->l_conn_export;
+	if (exp_connect_cancelset(exp)) {
+		avail = ldlm_format_handles_avail(class_exp2cliimp(exp),
+						  &RQF_LDLM_CANCEL,
+						  RCL_CLIENT, 0);
+		LASSERT(avail > 0);
+
+		ns = ldlm_lock_to_ns(lock);
+		flags = ns_connect_lru_resize(ns) ?
+			LDLM_LRU_FLAG_LRUR : LDLM_LRU_FLAG_AGED;
+		count += ldlm_cancel_lru_local(ns, &cancels, 0, avail - 1,
+					       LCF_BL_AST, flags);
+	}
+	ldlm_cli_cancel_list(&cancels, count, NULL, cancel_flags);
+	return 0;
+}
+EXPORT_SYMBOL(ldlm_cli_cancel);
+
+/**
+ * Locally cancel up to \a count locks in list \a cancels.
+ * Return the number of cancelled locks.
+ */
+int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
+			       enum ldlm_cancel_flags flags)
+{
+	LIST_HEAD(head);
+	struct ldlm_lock *lock, *next;
+	int left = 0, bl_ast = 0;
+	__u64 rc;
+
+	left = count;
+	list_for_each_entry_safe(lock, next, cancels, l_bl_ast) {
+		if (left-- == 0)
+			break;
+
+		if (flags & LCF_LOCAL) {
+			rc = LDLM_FL_LOCAL_ONLY;
+			ldlm_lock_cancel(lock);
+		} else {
+			rc = ldlm_cli_cancel_local(lock);
+		}
+		/* Until we have compound requests and can send LDLM_CANCEL
+		 * requests batched with generic RPCs, we need to send cancels
+		 * with the LDLM_FL_BL_AST flag in a separate RPC from
+		 * the one being generated now.
+		 */
+		if (!(flags & LCF_BL_AST) && (rc == LDLM_FL_BL_AST)) {
+			LDLM_DEBUG(lock, "Cancel lock separately");
+			list_del_init(&lock->l_bl_ast);
+			list_add(&lock->l_bl_ast, &head);
+			bl_ast++;
+			continue;
+		}
+		if (rc == LDLM_FL_LOCAL_ONLY) {
+			/* CANCEL RPC should not be sent to server. */
+			list_del_init(&lock->l_bl_ast);
+			LDLM_LOCK_RELEASE(lock);
+			count--;
+		}
+	}
+	if (bl_ast > 0) {
+		count -= bl_ast;
+		ldlm_cli_cancel_list(&head, bl_ast, NULL, 0);
+	}
+
+	return count;
+}
+
+/**
+ * Cancel as many locks as possible w/o sending any RPCs (e.g. to write back
+ * dirty data, to close a file, ...) or waiting for any RPCs in-flight (e.g.
+ * readahead requests, ...)
+ */
+static enum ldlm_policy_res
+ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
+			   int unused, int added, int count)
+{
+	enum ldlm_policy_res result = LDLM_POLICY_CANCEL_LOCK;
+
+	/* don't check added & count since we want to process all locks
+	 * from unused list.
+	 * It's fine to not take lock to access lock->l_resource since
+	 * the lock has already been granted so it won't change.
+	 */
+	switch (lock->l_resource->lr_type) {
+	case LDLM_EXTENT:
+	case LDLM_IBITS:
+		if (ns->ns_cancel && ns->ns_cancel(lock) != 0)
+			break;
+		/* fall through */
+	default:
+		result = LDLM_POLICY_SKIP_LOCK;
+		lock_res_and_lock(lock);
+		ldlm_set_skipped(lock);
+		unlock_res_and_lock(lock);
+		break;
+	}
+
+	return result;
+}
+
+/**
+ * Callback function for LRU-resize policy. Decides whether to keep
+ * \a lock in LRU for current \a LRU size \a unused, added in current
+ * scan \a added and number of locks to be preferably canceled \a count.
+ *
+ * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ *
+ * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
+ */
+static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
+						    struct ldlm_lock *lock,
+						    int unused, int added,
+						    int count)
+{
+	unsigned long cur = jiffies;
+	struct ldlm_pool *pl = &ns->ns_pool;
+	__u64 slv, lvf, lv;
+	unsigned long la;
+
+	/* Stop LRU processing when we reach past @count or have checked all
+	 * locks in LRU.
+	 */
+	if (count && added >= count)
+		return LDLM_POLICY_KEEP_LOCK;
+
+	/*
+	 * Despite of the LV, It doesn't make sense to keep the lock which
+	 * is unused for ns_max_age time.
+	 */
+	if (time_after(jiffies, lock->l_last_used + ns->ns_max_age))
+		return LDLM_POLICY_CANCEL_LOCK;
+
+	slv = ldlm_pool_get_slv(pl);
+	lvf = ldlm_pool_get_lvf(pl);
+	la = (cur - lock->l_last_used) / HZ;
+	lv = lvf * la * unused;
+
+	/* Inform pool about current CLV to see it via debugfs. */
+	ldlm_pool_set_clv(pl, lv);
+
+	/* Stop when SLV is not yet come from server or lv is smaller than
+	 * it is.
+	 */
+	if (slv == 0 || lv < slv)
+		return LDLM_POLICY_KEEP_LOCK;
+
+	return LDLM_POLICY_CANCEL_LOCK;
+}
+
+/**
+ * Callback function for debugfs used policy. Makes decision whether to keep
+ * \a lock in LRU for current \a LRU size \a unused, added in current scan \a
+ * added and number of locks to be preferably canceled \a count.
+ *
+ * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ *
+ * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
+ */
+static enum ldlm_policy_res ldlm_cancel_passed_policy(struct ldlm_namespace *ns,
+						      struct ldlm_lock *lock,
+						      int unused, int added,
+						      int count)
+{
+	/* Stop LRU processing when we reach past @count or have checked all
+	 * locks in LRU.
+	 */
+	return (added >= count) ?
+		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
+}
+
+/**
+ * Callback function for aged policy. Makes decision whether to keep \a lock in
+ * LRU for current LRU size \a unused, added in current scan \a added and
+ * number of locks to be preferably canceled \a count.
+ *
+ * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ *
+ * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
+ */
+static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
+						    struct ldlm_lock *lock,
+						    int unused, int added,
+						    int count)
+{
+	if ((added >= count) &&
+	    time_before(jiffies, lock->l_last_used + ns->ns_max_age))
+		return LDLM_POLICY_KEEP_LOCK;
+
+	return LDLM_POLICY_CANCEL_LOCK;
+}
+
+static enum ldlm_policy_res
+ldlm_cancel_lrur_no_wait_policy(struct ldlm_namespace *ns,
+				struct ldlm_lock *lock,
+				int unused, int added,
+				int count)
+{
+	enum ldlm_policy_res result;
+
+	result = ldlm_cancel_lrur_policy(ns, lock, unused, added, count);
+	if (result == LDLM_POLICY_KEEP_LOCK)
+		return result;
+
+	return ldlm_cancel_no_wait_policy(ns, lock, unused, added, count);
+}
+
+/**
+ * Callback function for default policy. Makes decision whether to keep \a lock
+ * in LRU for current LRU size \a unused, added in current scan \a added and
+ * number of locks to be preferably canceled \a count.
+ *
+ * \retval LDLM_POLICY_KEEP_LOCK keep lock in LRU in stop scanning
+ *
+ * \retval LDLM_POLICY_CANCEL_LOCK cancel lock from LRU
+ */
+static enum ldlm_policy_res
+ldlm_cancel_default_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
+			   int unused, int added, int count)
+{
+	/* Stop LRU processing when we reach past count or have checked all
+	 * locks in LRU.
+	 */
+	return (added >= count) ?
+		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
+}
+
+typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
+						      struct ldlm_namespace *,
+						      struct ldlm_lock *, int,
+						      int, int);
+
+static ldlm_cancel_lru_policy_t
+ldlm_cancel_lru_policy(struct ldlm_namespace *ns, int flags)
+{
+	if (flags & LDLM_LRU_FLAG_NO_WAIT)
+		return ldlm_cancel_no_wait_policy;
+
+	if (ns_connect_lru_resize(ns)) {
+		if (flags & LDLM_LRU_FLAG_SHRINK)
+			/* We kill passed number of old locks. */
+			return ldlm_cancel_passed_policy;
+		else if (flags & LDLM_LRU_FLAG_LRUR)
+			return ldlm_cancel_lrur_policy;
+		else if (flags & LDLM_LRU_FLAG_PASSED)
+			return ldlm_cancel_passed_policy;
+		else if (flags & LDLM_LRU_FLAG_LRUR_NO_WAIT)
+			return ldlm_cancel_lrur_no_wait_policy;
+	} else {
+		if (flags & LDLM_LRU_FLAG_AGED)
+			return ldlm_cancel_aged_policy;
+	}
+
+	return ldlm_cancel_default_policy;
+}
+
+/**
+ * - Free space in LRU for \a count new locks,
+ *   redundant unused locks are canceled locally;
+ * - also cancel locally unused aged locks;
+ * - do not cancel more than \a max locks;
+ * - GET the found locks and add them into the \a cancels list.
+ *
+ * A client lock can be added to the l_bl_ast list only when it is
+ * marked LDLM_FL_CANCELING. Otherwise, somebody is already doing
+ * CANCEL.  There are the following use cases:
+ * ldlm_cancel_resource_local(), ldlm_cancel_lru_local() and
+ * ldlm_cli_cancel(), which check and set this flag properly. As any
+ * attempt to cancel a lock rely on this flag, l_bl_ast list is accessed
+ * later without any special locking.
+ *
+ * Calling policies for enabled LRU resize:
+ * ----------------------------------------
+ * flags & LDLM_LRU_FLAG_LRUR	- use LRU resize policy (SLV from server) to
+ *				  cancel not more than \a count locks;
+ *
+ * flags & LDLM_LRU_FLAG_PASSED - cancel \a count number of old locks (located
+ *				  at the beginning of LRU list);
+ *
+ * flags & LDLM_LRU_FLAG_SHRINK - cancel not more than \a count locks according
+ *				  to memory pressure policy function;
+ *
+ * flags & LDLM_LRU_FLAG_AGED   - cancel \a count locks according to
+ *				  "aged policy".
+ *
+ * flags & LDLM_LRU_FLAG_NO_WAIT - cancel as many unused locks as possible
+ *				   (typically before replaying locks) w/o
+ *				   sending any RPCs or waiting for any
+ *				   outstanding RPC to complete.
+ */
+static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
+				 struct list_head *cancels, int count, int max,
+				 int flags)
+{
+	ldlm_cancel_lru_policy_t pf;
+	struct ldlm_lock *lock, *next;
+	int added = 0, unused, remained;
+	int no_wait = flags &
+		(LDLM_LRU_FLAG_NO_WAIT | LDLM_LRU_FLAG_LRUR_NO_WAIT);
+
+	spin_lock(&ns->ns_lock);
+	unused = ns->ns_nr_unused;
+	remained = unused;
+
+	if (!ns_connect_lru_resize(ns))
+		count += unused - ns->ns_max_unused;
+
+	pf = ldlm_cancel_lru_policy(ns, flags);
+	LASSERT(pf);
+
+	while (!list_empty(&ns->ns_unused_list)) {
+		enum ldlm_policy_res result;
+		time_t last_use = 0;
+
+		/* all unused locks */
+		if (remained-- <= 0)
+			break;
+
+		/* For any flags, stop scanning if @max is reached. */
+		if (max && added >= max)
+			break;
+
+		list_for_each_entry_safe(lock, next, &ns->ns_unused_list,
+					 l_lru) {
+			/* No locks which got blocking requests. */
+			LASSERT(!ldlm_is_bl_ast(lock));
+
+			if (no_wait && ldlm_is_skipped(lock))
+				/* already processed */
+				continue;
+
+			last_use = lock->l_last_used;
+			if (last_use == jiffies)
+				continue;
+
+			/* Somebody is already doing CANCEL. No need for this
+			 * lock in LRU, do not traverse it again.
+			 */
+			if (!ldlm_is_canceling(lock))
+				break;
+
+			ldlm_lock_remove_from_lru_nolock(lock);
+		}
+		if (&lock->l_lru == &ns->ns_unused_list)
+			break;
+
+		LDLM_LOCK_GET(lock);
+		spin_unlock(&ns->ns_lock);
+		lu_ref_add(&lock->l_reference, __func__, current);
+
+		/* Pass the lock through the policy filter and see if it
+		 * should stay in LRU.
+		 *
+		 * Even for shrinker policy we stop scanning if
+		 * we find a lock that should stay in the cache.
+		 * We should take into account lock age anyway
+		 * as a new lock is a valuable resource even if
+		 * it has a low weight.
+		 *
+		 * That is, for shrinker policy we drop only
+		 * old locks, but additionally choose them by
+		 * their weight. Big extent locks will stay in
+		 * the cache.
+		 */
+		result = pf(ns, lock, unused, added, count);
+		if (result == LDLM_POLICY_KEEP_LOCK) {
+			lu_ref_del(&lock->l_reference,
+				   __func__, current);
+			LDLM_LOCK_RELEASE(lock);
+			spin_lock(&ns->ns_lock);
+			break;
+		}
+		if (result == LDLM_POLICY_SKIP_LOCK) {
+			lu_ref_del(&lock->l_reference,
+				   __func__, current);
+			LDLM_LOCK_RELEASE(lock);
+			spin_lock(&ns->ns_lock);
+			continue;
+		}
+
+		lock_res_and_lock(lock);
+		/* Check flags again under the lock. */
+		if (ldlm_is_canceling(lock) ||
+		    (ldlm_lock_remove_from_lru_check(lock, last_use) == 0)) {
+			/* Another thread is removing lock from LRU, or
+			 * somebody is already doing CANCEL, or there
+			 * is a blocking request which will send cancel
+			 * by itself, or the lock is no longer unused or
+			 * the lock has been used since the pf() call and
+			 * pages could be put under it.
+			 */
+			unlock_res_and_lock(lock);
+			lu_ref_del(&lock->l_reference,
+				   __func__, current);
+			LDLM_LOCK_RELEASE(lock);
+			spin_lock(&ns->ns_lock);
+			continue;
+		}
+		LASSERT(!lock->l_readers && !lock->l_writers);
+
+		/* If we have chosen to cancel this lock voluntarily, we
+		 * better send cancel notification to server, so that it
+		 * frees appropriate state. This might lead to a race
+		 * where while we are doing cancel here, server is also
+		 * silently cancelling this lock.
+		 */
+		ldlm_clear_cancel_on_block(lock);
+
+		/* Setting the CBPENDING flag is a little misleading,
+		 * but prevents an important race; namely, once
+		 * CBPENDING is set, the lock can accumulate no more
+		 * readers/writers. Since readers and writers are
+		 * already zero here, ldlm_lock_decref() won't see
+		 * this flag and call l_blocking_ast
+		 */
+		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_CANCELING;
+
+		/* We can't re-add to l_lru as it confuses the
+		 * refcounting in ldlm_lock_remove_from_lru() if an AST
+		 * arrives after we drop lr_lock below. We use l_bl_ast
+		 * and can't use l_pending_chain as it is used both on
+		 * server and client nevertheless bug 5666 says it is
+		 * used only on server
+		 */
+		LASSERT(list_empty(&lock->l_bl_ast));
+		list_add(&lock->l_bl_ast, cancels);
+		unlock_res_and_lock(lock);
+		lu_ref_del(&lock->l_reference, __func__, current);
+		spin_lock(&ns->ns_lock);
+		added++;
+		unused--;
+	}
+	spin_unlock(&ns->ns_lock);
+	return added;
+}
+
+int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
+			  struct list_head *cancels, int count, int max,
+			  enum ldlm_cancel_flags cancel_flags, int flags)
+{
+	int added;
+
+	added = ldlm_prepare_lru_list(ns, cancels, count, max, flags);
+	if (added <= 0)
+		return added;
+	return ldlm_cli_cancel_list_local(cancels, added, cancel_flags);
+}
+
+/**
+ * Cancel@least \a nr locks from given namespace LRU.
+ *
+ * When called with LCF_ASYNC the blocking callback will be handled
+ * in a thread and this function will return after the thread has been
+ * asked to call the callback.  When called with LCF_ASYNC the blocking
+ * callback will be performed in this function.
+ */
+int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
+		    enum ldlm_cancel_flags cancel_flags,
+		    int flags)
+{
+	LIST_HEAD(cancels);
+	int count, rc;
+
+	/* Just prepare the list of locks, do not actually cancel them yet.
+	 * Locks are cancelled later in a separate thread.
+	 */
+	count = ldlm_prepare_lru_list(ns, &cancels, nr, 0, flags);
+	rc = ldlm_bl_to_thread_list(ns, NULL, &cancels, count, cancel_flags);
+	if (rc == 0)
+		return count;
+
+	return 0;
+}
+
+/**
+ * Find and cancel locally unused locks found on resource, matched to the
+ * given policy, mode. GET the found locks and add them into the \a cancels
+ * list.
+ */
+int ldlm_cancel_resource_local(struct ldlm_resource *res,
+			       struct list_head *cancels,
+			       union ldlm_policy_data *policy,
+			       enum ldlm_mode mode, __u64 lock_flags,
+			       enum ldlm_cancel_flags cancel_flags,
+			       void *opaque)
+{
+	struct ldlm_lock *lock;
+	int count = 0;
+
+	lock_res(res);
+	list_for_each_entry(lock, &res->lr_granted, l_res_link) {
+		if (opaque && lock->l_ast_data != opaque) {
+			LDLM_ERROR(lock, "data %p doesn't match opaque %p",
+				   lock->l_ast_data, opaque);
+			continue;
+		}
+
+		if (lock->l_readers || lock->l_writers)
+			continue;
+
+		/* If somebody is already doing CANCEL, or blocking AST came,
+		 * skip this lock.
+		 */
+		if (ldlm_is_bl_ast(lock) || ldlm_is_canceling(lock))
+			continue;
+
+		if (lockmode_compat(lock->l_granted_mode, mode))
+			continue;
+
+		/* If policy is given and this is IBITS lock, add to list only
+		 * those locks that match by policy.
+		 */
+		if (policy && (lock->l_resource->lr_type == LDLM_IBITS) &&
+		    !(lock->l_policy_data.l_inodebits.bits &
+		      policy->l_inodebits.bits))
+			continue;
+
+		/* See CBPENDING comment in ldlm_cancel_lru */
+		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_CANCELING |
+				 lock_flags;
+
+		LASSERT(list_empty(&lock->l_bl_ast));
+		list_add(&lock->l_bl_ast, cancels);
+		LDLM_LOCK_GET(lock);
+		count++;
+	}
+	unlock_res(res);
+
+	return ldlm_cli_cancel_list_local(cancels, count, cancel_flags);
+}
+EXPORT_SYMBOL(ldlm_cancel_resource_local);
+
+/**
+ * Cancel client-side locks from a list and send/prepare cancel RPCs to the
+ * server.
+ * If \a req is NULL, send CANCEL request to server with handles of locks
+ * in the \a cancels. If EARLY_CANCEL is not supported, send CANCEL requests
+ * separately per lock.
+ * If \a req is not NULL, put handles of locks in \a cancels into the request
+ * buffer at the offset \a off.
+ * Destroy \a cancels at the end.
+ */
+int ldlm_cli_cancel_list(struct list_head *cancels, int count,
+			 struct ptlrpc_request *req,
+			 enum ldlm_cancel_flags flags)
+{
+	struct ldlm_lock *lock;
+	int res = 0;
+
+	if (list_empty(cancels) || count == 0)
+		return 0;
+
+	/* XXX: requests (both batched and not) could be sent in parallel.
+	 * Usually it is enough to have just 1 RPC, but it is possible that
+	 * there are too many locks to be cancelled in LRU or on a resource.
+	 * It would also speed up the case when the server does not support
+	 * the feature.
+	 */
+	while (count > 0) {
+		LASSERT(!list_empty(cancels));
+		lock = list_first_entry(cancels, struct ldlm_lock, l_bl_ast);
+		LASSERT(lock->l_conn_export);
+
+		if (exp_connect_cancelset(lock->l_conn_export)) {
+			res = count;
+			if (req)
+				ldlm_cancel_pack(req, cancels, count);
+			else
+				res = ldlm_cli_cancel_req(lock->l_conn_export,
+							  cancels, count,
+							  flags);
+		} else {
+			res = ldlm_cli_cancel_req(lock->l_conn_export,
+						  cancels, 1, flags);
+		}
+
+		if (res < 0) {
+			CDEBUG_LIMIT(res == -ESHUTDOWN ? D_DLMTRACE : D_ERROR,
+				     "%s: %d\n", __func__, res);
+			res = count;
+		}
+
+		count -= res;
+		ldlm_lock_list_put(cancels, l_bl_ast, res);
+	}
+	LASSERT(count == 0);
+	return 0;
+}
+EXPORT_SYMBOL(ldlm_cli_cancel_list);
+
+/**
+ * Cancel all locks on a resource that have 0 readers/writers.
+ *
+ * If flags & LDLM_FL_LOCAL_ONLY, throw the locks away without trying
+ * to notify the server.
+ */
+int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
+				    const struct ldlm_res_id *res_id,
+				    union ldlm_policy_data *policy,
+				    enum ldlm_mode mode,
+				    enum ldlm_cancel_flags flags,
+				    void *opaque)
+{
+	struct ldlm_resource *res;
+	LIST_HEAD(cancels);
+	int count;
+	int rc;
+
+	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
+	if (IS_ERR(res)) {
+		/* This is not a problem. */
+		CDEBUG(D_INFO, "No resource %llu\n", res_id->name[0]);
+		return 0;
+	}
+
+	LDLM_RESOURCE_ADDREF(res);
+	count = ldlm_cancel_resource_local(res, &cancels, policy, mode,
+					   0, flags | LCF_BL_AST, opaque);
+	rc = ldlm_cli_cancel_list(&cancels, count, NULL, flags);
+	if (rc != ELDLM_OK)
+		CERROR("canceling unused lock " DLDLMRES ": rc = %d\n",
+		       PLDLMRES(res), rc);
+
+	LDLM_RESOURCE_DELREF(res);
+	ldlm_resource_putref(res);
+	return 0;
+}
+EXPORT_SYMBOL(ldlm_cli_cancel_unused_resource);
+
+struct ldlm_cli_cancel_arg {
+	int     lc_flags;
+	void   *lc_opaque;
+};
+
+static int ldlm_cli_hash_cancel_unused(struct cfs_hash *hs,
+				       struct cfs_hash_bd *bd,
+				       struct hlist_node *hnode, void *arg)
+{
+	struct ldlm_resource	   *res = cfs_hash_object(hs, hnode);
+	struct ldlm_cli_cancel_arg     *lc = arg;
+
+	ldlm_cli_cancel_unused_resource(ldlm_res_to_ns(res), &res->lr_name,
+					NULL, LCK_MINMODE,
+					lc->lc_flags, lc->lc_opaque);
+	/* must return 0 for hash iteration */
+	return 0;
+}
+
+/**
+ * Cancel all locks on a namespace (or a specific resource, if given)
+ * that have 0 readers/writers.
+ *
+ * If flags & LCF_LOCAL, throw the locks away without trying
+ * to notify the server.
+ */
+int ldlm_cli_cancel_unused(struct ldlm_namespace *ns,
+			   const struct ldlm_res_id *res_id,
+			   enum ldlm_cancel_flags flags, void *opaque)
+{
+	struct ldlm_cli_cancel_arg arg = {
+		.lc_flags       = flags,
+		.lc_opaque      = opaque,
+	};
+
+	if (!ns)
+		return ELDLM_OK;
+
+	if (res_id) {
+		return ldlm_cli_cancel_unused_resource(ns, res_id, NULL,
+						       LCK_MINMODE, flags,
+						       opaque);
+	} else {
+		cfs_hash_for_each_nolock(ns->ns_rs_hash,
+					 ldlm_cli_hash_cancel_unused, &arg, 0);
+		return ELDLM_OK;
+	}
+}
+EXPORT_SYMBOL(ldlm_cli_cancel_unused);
+
+/* Lock iterators. */
+
+static int ldlm_resource_foreach(struct ldlm_resource *res,
+				 ldlm_iterator_t iter, void *closure)
+{
+	struct ldlm_lock *tmp;
+	struct ldlm_lock *lock;
+	int rc = LDLM_ITER_CONTINUE;
+
+	if (!res)
+		return LDLM_ITER_CONTINUE;
+
+	lock_res(res);
+	list_for_each_entry_safe(lock, tmp, &res->lr_granted, l_res_link) {
+		if (iter(lock, closure) == LDLM_ITER_STOP) {
+			rc = LDLM_ITER_STOP;
+			goto out;
+		}
+	}
+
+	list_for_each_entry_safe(lock, tmp, &res->lr_waiting, l_res_link) {
+		if (iter(lock, closure) == LDLM_ITER_STOP) {
+			rc = LDLM_ITER_STOP;
+			goto out;
+		}
+	}
+ out:
+	unlock_res(res);
+	return rc;
+}
+
+struct iter_helper_data {
+	ldlm_iterator_t iter;
+	void *closure;
+};
+
+static int ldlm_iter_helper(struct ldlm_lock *lock, void *closure)
+{
+	struct iter_helper_data *helper = closure;
+
+	return helper->iter(lock, helper->closure);
+}
+
+static int ldlm_res_iter_helper(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+				struct hlist_node *hnode, void *arg)
+
+{
+	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
+
+	return ldlm_resource_foreach(res, ldlm_iter_helper, arg) ==
+	       LDLM_ITER_STOP;
+}
+
+static void ldlm_namespace_foreach(struct ldlm_namespace *ns,
+				   ldlm_iterator_t iter, void *closure)
+
+{
+	struct iter_helper_data helper = {
+		.iter		= iter,
+		.closure	= closure,
+	};
+
+	cfs_hash_for_each_nolock(ns->ns_rs_hash,
+				 ldlm_res_iter_helper, &helper, 0);
+}
+
+/* non-blocking function to manipulate a lock whose cb_data is being put away.
+ * return  0:  find no resource
+ *       > 0:  must be LDLM_ITER_STOP/LDLM_ITER_CONTINUE.
+ *       < 0:  errors
+ */
+int ldlm_resource_iterate(struct ldlm_namespace *ns,
+			  const struct ldlm_res_id *res_id,
+			  ldlm_iterator_t iter, void *data)
+{
+	struct ldlm_resource *res;
+	int rc;
+
+	LASSERTF(ns, "must pass in namespace\n");
+
+	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
+	if (IS_ERR(res))
+		return 0;
+
+	LDLM_RESOURCE_ADDREF(res);
+	rc = ldlm_resource_foreach(res, iter, data);
+	LDLM_RESOURCE_DELREF(res);
+	ldlm_resource_putref(res);
+	return rc;
+}
+EXPORT_SYMBOL(ldlm_resource_iterate);
+
+/* Lock replay */
+
+static int ldlm_chain_lock_for_replay(struct ldlm_lock *lock, void *closure)
+{
+	struct list_head *list = closure;
+
+	/* we use l_pending_chain here, because it's unused on clients. */
+	LASSERTF(list_empty(&lock->l_pending_chain),
+		 "lock %p next %p prev %p\n",
+		 lock, &lock->l_pending_chain.next,
+		 &lock->l_pending_chain.prev);
+	/* bug 9573: don't replay locks left after eviction, or
+	 * bug 17614: locks being actively cancelled. Get a reference
+	 * on a lock so that it does not disappear under us (e.g. due to cancel)
+	 */
+	if (!(lock->l_flags & (LDLM_FL_FAILED | LDLM_FL_BL_DONE))) {
+		list_add(&lock->l_pending_chain, list);
+		LDLM_LOCK_GET(lock);
+	}
+
+	return LDLM_ITER_CONTINUE;
+}
+
+static int replay_lock_interpret(const struct lu_env *env,
+				 struct ptlrpc_request *req,
+				 struct ldlm_async_args *aa, int rc)
+{
+	struct ldlm_lock     *lock;
+	struct ldlm_reply    *reply;
+	struct obd_export    *exp;
+
+	atomic_dec(&req->rq_import->imp_replay_inflight);
+	if (rc != ELDLM_OK)
+		goto out;
+
+	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
+	if (!reply) {
+		rc = -EPROTO;
+		goto out;
+	}
+
+	lock = ldlm_handle2lock(&aa->lock_handle);
+	if (!lock) {
+		CERROR("received replay ack for unknown local cookie %#llx remote cookie %#llx from server %s id %s\n",
+		       aa->lock_handle.cookie, reply->lock_handle.cookie,
+		       req->rq_export->exp_client_uuid.uuid,
+		       libcfs_id2str(req->rq_peer));
+		rc = -ESTALE;
+		goto out;
+	}
+
+	/* Key change rehash lock in per-export hash with new key */
+	exp = req->rq_export;
+	lock->l_remote_handle = reply->lock_handle;
+
+	LDLM_DEBUG(lock, "replayed lock:");
+	ptlrpc_import_recovery_state_machine(req->rq_import);
+	LDLM_LOCK_PUT(lock);
+out:
+	if (rc != ELDLM_OK)
+		ptlrpc_connect_import(req->rq_import);
+
+	return rc;
+}
+
+static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
+{
+	struct ptlrpc_request *req;
+	struct ldlm_async_args *aa;
+	struct ldlm_request   *body;
+	int flags;
+
+	/* Bug 11974: Do not replay a lock which is actively being canceled */
+	if (ldlm_is_bl_done(lock)) {
+		LDLM_DEBUG(lock, "Not replaying canceled lock:");
+		return 0;
+	}
+
+	/* If this is reply-less callback lock, we cannot replay it, since
+	 * server might have long dropped it, but notification of that event was
+	 * lost by network. (and server granted conflicting lock already)
+	 */
+	if (ldlm_is_cancel_on_block(lock)) {
+		LDLM_DEBUG(lock, "Not replaying reply-less lock:");
+		ldlm_lock_cancel(lock);
+		return 0;
+	}
+
+	/*
+	 * If granted mode matches the requested mode, this lock is granted.
+	 *
+	 * If they differ, but we have a granted mode, then we were granted
+	 * one mode and now want another: ergo, converting.
+	 *
+	 * If we haven't been granted anything and are on a resource list,
+	 * then we're blocked/waiting.
+	 *
+	 * If we haven't been granted anything and we're NOT on a resource list,
+	 * then we haven't got a reply yet and don't have a known disposition.
+	 * This happens whenever a lock enqueue is the request that triggers
+	 * recovery.
+	 */
+	if (lock->l_granted_mode == lock->l_req_mode)
+		flags = LDLM_FL_REPLAY | LDLM_FL_BLOCK_GRANTED;
+	else if (lock->l_granted_mode)
+		flags = LDLM_FL_REPLAY | LDLM_FL_BLOCK_CONV;
+	else if (!list_empty(&lock->l_res_link))
+		flags = LDLM_FL_REPLAY | LDLM_FL_BLOCK_WAIT;
+	else
+		flags = LDLM_FL_REPLAY;
+
+	req = ptlrpc_request_alloc_pack(imp, &RQF_LDLM_ENQUEUE,
+					LUSTRE_DLM_VERSION, LDLM_ENQUEUE);
+	if (!req)
+		return -ENOMEM;
+
+	/* We're part of recovery, so don't wait for it. */
+	req->rq_send_state = LUSTRE_IMP_REPLAY_LOCKS;
+
+	body = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
+	ldlm_lock2desc(lock, &body->lock_desc);
+	body->lock_flags = ldlm_flags_to_wire(flags);
+
+	ldlm_lock2handle(lock, &body->lock_handle[0]);
+	if (lock->l_lvb_len > 0)
+		req_capsule_extend(&req->rq_pill, &RQF_LDLM_ENQUEUE_LVB);
+	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER,
+			     lock->l_lvb_len);
+	ptlrpc_request_set_replen(req);
+	/* notify the server we've replayed all requests.
+	 * also, we mark the request to be put on a dedicated
+	 * queue to be processed after all request replayes.
+	 * bug 6063
+	 */
+	lustre_msg_set_flags(req->rq_reqmsg, MSG_REQ_REPLAY_DONE);
+
+	LDLM_DEBUG(lock, "replaying lock:");
+
+	atomic_inc(&req->rq_import->imp_replay_inflight);
+	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
+	aa = ptlrpc_req_async_args(req);
+	aa->lock_handle = body->lock_handle[0];
+	req->rq_interpret_reply = (ptlrpc_interpterer_t)replay_lock_interpret;
+	ptlrpcd_add_req(req);
+
+	return 0;
+}
+
+/**
+ * Cancel as many unused locks as possible before replay. since we are
+ * in recovery, we can't wait for any outstanding RPCs to send any RPC
+ * to the server.
+ *
+ * Called only in recovery before replaying locks. there is no need to
+ * replay locks that are unused. since the clients may hold thousands of
+ * cached unused locks, dropping the unused locks can greatly reduce the
+ * load on the servers at recovery time.
+ */
+static void ldlm_cancel_unused_locks_for_replay(struct ldlm_namespace *ns)
+{
+	int canceled;
+	LIST_HEAD(cancels);
+
+	CDEBUG(D_DLMTRACE,
+	       "Dropping as many unused locks as possible before replay for namespace %s (%d)\n",
+	       ldlm_ns_name(ns), ns->ns_nr_unused);
+
+	/* We don't need to care whether or not LRU resize is enabled
+	 * because the LDLM_LRU_FLAG_NO_WAIT policy doesn't use the
+	 * count parameter
+	 */
+	canceled = ldlm_cancel_lru_local(ns, &cancels, ns->ns_nr_unused, 0,
+					 LCF_LOCAL, LDLM_LRU_FLAG_NO_WAIT);
+
+	CDEBUG(D_DLMTRACE, "Canceled %d unused locks from namespace %s\n",
+	       canceled, ldlm_ns_name(ns));
+}
+
+int ldlm_replay_locks(struct obd_import *imp)
+{
+	struct ldlm_namespace *ns = imp->imp_obd->obd_namespace;
+	LIST_HEAD(list);
+	struct ldlm_lock *lock, *next;
+	int rc = 0;
+
+	LASSERT(atomic_read(&imp->imp_replay_inflight) == 0);
+
+	/* don't replay locks if import failed recovery */
+	if (imp->imp_vbr_failed)
+		return 0;
+
+	/* ensure this doesn't fall to 0 before all have been queued */
+	atomic_inc(&imp->imp_replay_inflight);
+
+	if (ldlm_cancel_unused_locks_before_replay)
+		ldlm_cancel_unused_locks_for_replay(ns);
+
+	ldlm_namespace_foreach(ns, ldlm_chain_lock_for_replay, &list);
+
+	list_for_each_entry_safe(lock, next, &list, l_pending_chain) {
+		list_del_init(&lock->l_pending_chain);
+		if (rc) {
+			LDLM_LOCK_RELEASE(lock);
+			continue; /* or try to do the rest? */
+		}
+		rc = replay_one_lock(imp, lock);
+		LDLM_LOCK_RELEASE(lock);
+	}
+
+	atomic_dec(&imp->imp_replay_inflight);
+
+	return rc;
+}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ldlm_resource.c b/drivers/staging/lustre/lustre/ptlrpc/ldlm_resource.c
new file mode 100644
index 000000000000..3946d62ff009
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ptlrpc/ldlm_resource.c
@@ -0,0 +1,1318 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2010, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/ldlm/ldlm_resource.c
+ *
+ * Author: Phil Schwan <phil@clusterfs.com>
+ * Author: Peter Braam <braam@clusterfs.com>
+ */
+
+#define DEBUG_SUBSYSTEM S_LDLM
+#include <lustre_dlm.h>
+#include <lustre_fid.h>
+#include <obd_class.h>
+#include "ldlm_internal.h"
+#include <linux/libcfs/libcfs_hash.h>
+
+struct kmem_cache *ldlm_resource_slab, *ldlm_lock_slab;
+
+int ldlm_srv_namespace_nr;
+int ldlm_cli_namespace_nr;
+
+struct mutex ldlm_srv_namespace_lock;
+LIST_HEAD(ldlm_srv_namespace_list);
+
+struct mutex ldlm_cli_namespace_lock;
+/* Client Namespaces that have active resources in them.
+ * Once all resources go away, ldlm_poold moves such namespaces to the
+ * inactive list
+ */
+LIST_HEAD(ldlm_cli_active_namespace_list);
+/* Client namespaces that don't have any locks in them */
+static LIST_HEAD(ldlm_cli_inactive_namespace_list);
+
+static struct dentry *ldlm_debugfs_dir;
+static struct dentry *ldlm_ns_debugfs_dir;
+struct dentry *ldlm_svc_debugfs_dir;
+
+/* during debug dump certain amount of granted locks for one resource to avoid
+ * DDOS.
+ */
+static unsigned int ldlm_dump_granted_max = 256;
+
+static ssize_t
+lprocfs_wr_dump_ns(struct file *file, const char __user *buffer,
+		   size_t count, loff_t *off)
+{
+	ldlm_dump_all_namespaces(LDLM_NAMESPACE_SERVER, D_DLMTRACE);
+	ldlm_dump_all_namespaces(LDLM_NAMESPACE_CLIENT, D_DLMTRACE);
+	return count;
+}
+
+LPROC_SEQ_FOPS_WR_ONLY(ldlm, dump_ns);
+
+static int ldlm_rw_uint_seq_show(struct seq_file *m, void *v)
+{
+	seq_printf(m, "%u\n", *(unsigned int *)m->private);
+	return 0;
+}
+
+static ssize_t
+ldlm_rw_uint_seq_write(struct file *file, const char __user *buffer,
+		       size_t count, loff_t *off)
+{
+	struct seq_file *seq = file->private_data;
+
+	if (count == 0)
+		return 0;
+	return kstrtouint_from_user(buffer, count, 0,
+				    (unsigned int *)seq->private);
+}
+
+LPROC_SEQ_FOPS(ldlm_rw_uint);
+
+static struct lprocfs_vars ldlm_debugfs_list[] = {
+	{ "dump_namespaces", &ldlm_dump_ns_fops, NULL, 0222 },
+	{ "dump_granted_max", &ldlm_rw_uint_fops, &ldlm_dump_granted_max },
+	{ NULL }
+};
+
+void ldlm_debugfs_setup(void)
+{
+	ldlm_debugfs_dir = debugfs_create_dir(OBD_LDLM_DEVICENAME,
+					      debugfs_lustre_root);
+
+	ldlm_ns_debugfs_dir = debugfs_create_dir("namespaces",
+						 ldlm_debugfs_dir);
+
+	ldlm_svc_debugfs_dir = debugfs_create_dir("services", ldlm_debugfs_dir);
+
+	ldebugfs_add_vars(ldlm_debugfs_dir, ldlm_debugfs_list, NULL);
+}
+
+void ldlm_debugfs_cleanup(void)
+{
+	debugfs_remove_recursive(ldlm_svc_debugfs_dir);
+	debugfs_remove_recursive(ldlm_ns_debugfs_dir);
+	debugfs_remove_recursive(ldlm_debugfs_dir);
+}
+
+static ssize_t resource_count_show(struct kobject *kobj, struct attribute *attr,
+				   char *buf)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	__u64		  res = 0;
+	struct cfs_hash_bd	  bd;
+	int		    i;
+
+	/* result is not strictly consistent */
+	cfs_hash_for_each_bucket(ns->ns_rs_hash, &bd, i)
+		res += cfs_hash_bd_count_get(&bd);
+	return sprintf(buf, "%lld\n", res);
+}
+LUSTRE_RO_ATTR(resource_count);
+
+static ssize_t lock_count_show(struct kobject *kobj, struct attribute *attr,
+			       char *buf)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	__u64		  locks;
+
+	locks = lprocfs_stats_collector(ns->ns_stats, LDLM_NSS_LOCKS,
+					LPROCFS_FIELDS_FLAGS_SUM);
+	return sprintf(buf, "%lld\n", locks);
+}
+LUSTRE_RO_ATTR(lock_count);
+
+static ssize_t lock_unused_count_show(struct kobject *kobj,
+				      struct attribute *attr,
+				      char *buf)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+
+	return sprintf(buf, "%d\n", ns->ns_nr_unused);
+}
+LUSTRE_RO_ATTR(lock_unused_count);
+
+static ssize_t lru_size_show(struct kobject *kobj, struct attribute *attr,
+			     char *buf)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	__u32 *nr = &ns->ns_max_unused;
+
+	if (ns_connect_lru_resize(ns))
+		nr = &ns->ns_nr_unused;
+	return sprintf(buf, "%u\n", *nr);
+}
+
+static ssize_t lru_size_store(struct kobject *kobj, struct attribute *attr,
+			      const char *buffer, size_t count)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	unsigned long tmp;
+	int lru_resize;
+	int err;
+
+	if (strncmp(buffer, "clear", 5) == 0) {
+		CDEBUG(D_DLMTRACE,
+		       "dropping all unused locks from namespace %s\n",
+		       ldlm_ns_name(ns));
+		if (ns_connect_lru_resize(ns)) {
+			int canceled, unused  = ns->ns_nr_unused;
+
+			/* Try to cancel all @ns_nr_unused locks. */
+			canceled = ldlm_cancel_lru(ns, unused, 0,
+						   LDLM_LRU_FLAG_PASSED);
+			if (canceled < unused) {
+				CDEBUG(D_DLMTRACE,
+				       "not all requested locks are canceled, requested: %d, canceled: %d\n",
+				       unused,
+				       canceled);
+				return -EINVAL;
+			}
+		} else {
+			tmp = ns->ns_max_unused;
+			ns->ns_max_unused = 0;
+			ldlm_cancel_lru(ns, 0, 0, LDLM_LRU_FLAG_PASSED);
+			ns->ns_max_unused = tmp;
+		}
+		return count;
+	}
+
+	err = kstrtoul(buffer, 10, &tmp);
+	if (err != 0) {
+		CERROR("lru_size: invalid value written\n");
+		return -EINVAL;
+	}
+	lru_resize = (tmp == 0);
+
+	if (ns_connect_lru_resize(ns)) {
+		if (!lru_resize)
+			ns->ns_max_unused = (unsigned int)tmp;
+
+		if (tmp > ns->ns_nr_unused)
+			tmp = ns->ns_nr_unused;
+		tmp = ns->ns_nr_unused - tmp;
+
+		CDEBUG(D_DLMTRACE,
+		       "changing namespace %s unused locks from %u to %u\n",
+		       ldlm_ns_name(ns), ns->ns_nr_unused,
+		       (unsigned int)tmp);
+		ldlm_cancel_lru(ns, tmp, LCF_ASYNC, LDLM_LRU_FLAG_PASSED);
+
+		if (!lru_resize) {
+			CDEBUG(D_DLMTRACE,
+			       "disable lru_resize for namespace %s\n",
+			       ldlm_ns_name(ns));
+			ns->ns_connect_flags &= ~OBD_CONNECT_LRU_RESIZE;
+		}
+	} else {
+		CDEBUG(D_DLMTRACE,
+		       "changing namespace %s max_unused from %u to %u\n",
+		       ldlm_ns_name(ns), ns->ns_max_unused,
+		       (unsigned int)tmp);
+		ns->ns_max_unused = (unsigned int)tmp;
+		ldlm_cancel_lru(ns, 0, LCF_ASYNC, LDLM_LRU_FLAG_PASSED);
+
+		/* Make sure that LRU resize was originally supported before
+		 * turning it on here.
+		 */
+		if (lru_resize &&
+		    (ns->ns_orig_connect_flags & OBD_CONNECT_LRU_RESIZE)) {
+			CDEBUG(D_DLMTRACE,
+			       "enable lru_resize for namespace %s\n",
+			       ldlm_ns_name(ns));
+			ns->ns_connect_flags |= OBD_CONNECT_LRU_RESIZE;
+		}
+	}
+
+	return count;
+}
+LUSTRE_RW_ATTR(lru_size);
+
+static ssize_t lru_max_age_show(struct kobject *kobj, struct attribute *attr,
+				char *buf)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+
+	return sprintf(buf, "%u\n", ns->ns_max_age);
+}
+
+static ssize_t lru_max_age_store(struct kobject *kobj, struct attribute *attr,
+				 const char *buffer, size_t count)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	unsigned long tmp;
+	int err;
+
+	err = kstrtoul(buffer, 10, &tmp);
+	if (err != 0)
+		return -EINVAL;
+
+	ns->ns_max_age = tmp;
+
+	return count;
+}
+LUSTRE_RW_ATTR(lru_max_age);
+
+static ssize_t early_lock_cancel_show(struct kobject *kobj,
+				      struct attribute *attr,
+				      char *buf)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+
+	return sprintf(buf, "%d\n", ns_connect_cancelset(ns));
+}
+
+static ssize_t early_lock_cancel_store(struct kobject *kobj,
+				       struct attribute *attr,
+				       const char *buffer,
+				       size_t count)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	unsigned long supp = -1;
+	int rc;
+
+	rc = kstrtoul(buffer, 10, &supp);
+	if (rc < 0)
+		return rc;
+
+	if (supp == 0)
+		ns->ns_connect_flags &= ~OBD_CONNECT_CANCELSET;
+	else if (ns->ns_orig_connect_flags & OBD_CONNECT_CANCELSET)
+		ns->ns_connect_flags |= OBD_CONNECT_CANCELSET;
+	return count;
+}
+LUSTRE_RW_ATTR(early_lock_cancel);
+
+/* These are for namespaces in /sys/fs/lustre/ldlm/namespaces/ */
+static struct attribute *ldlm_ns_attrs[] = {
+	&lustre_attr_resource_count.attr,
+	&lustre_attr_lock_count.attr,
+	&lustre_attr_lock_unused_count.attr,
+	&lustre_attr_lru_size.attr,
+	&lustre_attr_lru_max_age.attr,
+	&lustre_attr_early_lock_cancel.attr,
+	NULL,
+};
+
+static void ldlm_ns_release(struct kobject *kobj)
+{
+	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
+						 ns_kobj);
+	complete(&ns->ns_kobj_unregister);
+}
+
+static struct kobj_type ldlm_ns_ktype = {
+	.default_attrs  = ldlm_ns_attrs,
+	.sysfs_ops      = &lustre_sysfs_ops,
+	.release        = ldlm_ns_release,
+};
+
+static void ldlm_namespace_debugfs_unregister(struct ldlm_namespace *ns)
+{
+	debugfs_remove_recursive(ns->ns_debugfs_entry);
+
+	if (ns->ns_stats)
+		lprocfs_free_stats(&ns->ns_stats);
+}
+
+static void ldlm_namespace_sysfs_unregister(struct ldlm_namespace *ns)
+{
+	kobject_put(&ns->ns_kobj);
+	wait_for_completion(&ns->ns_kobj_unregister);
+}
+
+static int ldlm_namespace_sysfs_register(struct ldlm_namespace *ns)
+{
+	int err;
+
+	ns->ns_kobj.kset = ldlm_ns_kset;
+	init_completion(&ns->ns_kobj_unregister);
+	err = kobject_init_and_add(&ns->ns_kobj, &ldlm_ns_ktype, NULL,
+				   "%s", ldlm_ns_name(ns));
+
+	ns->ns_stats = lprocfs_alloc_stats(LDLM_NSS_LAST, 0);
+	if (!ns->ns_stats) {
+		kobject_put(&ns->ns_kobj);
+		return -ENOMEM;
+	}
+
+	lprocfs_counter_init(ns->ns_stats, LDLM_NSS_LOCKS,
+			     LPROCFS_CNTR_AVGMINMAX, "locks", "locks");
+
+	return err;
+}
+
+static int ldlm_namespace_debugfs_register(struct ldlm_namespace *ns)
+{
+	struct dentry *ns_entry;
+
+	if (!IS_ERR_OR_NULL(ns->ns_debugfs_entry)) {
+		ns_entry = ns->ns_debugfs_entry;
+	} else {
+		ns_entry = debugfs_create_dir(ldlm_ns_name(ns),
+					      ldlm_ns_debugfs_dir);
+		if (!ns_entry)
+			return -ENOMEM;
+		ns->ns_debugfs_entry = ns_entry;
+	}
+
+	return 0;
+}
+
+#undef MAX_STRING_SIZE
+
+static struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
+{
+	LASSERT(res);
+	LASSERT(res != LP_POISON);
+	atomic_inc(&res->lr_refcount);
+	CDEBUG(D_INFO, "getref res: %p count: %d\n", res,
+	       atomic_read(&res->lr_refcount));
+	return res;
+}
+
+static unsigned int ldlm_res_hop_hash(struct cfs_hash *hs,
+				      const void *key, unsigned int mask)
+{
+	const struct ldlm_res_id     *id  = key;
+	unsigned int		val = 0;
+	unsigned int		i;
+
+	for (i = 0; i < RES_NAME_SIZE; i++)
+		val += id->name[i];
+	return val & mask;
+}
+
+static unsigned int ldlm_res_hop_fid_hash(struct cfs_hash *hs,
+					  const void *key, unsigned int mask)
+{
+	const struct ldlm_res_id *id = key;
+	struct lu_fid       fid;
+	__u32	       hash;
+	__u32	       val;
+
+	fid.f_seq = id->name[LUSTRE_RES_ID_SEQ_OFF];
+	fid.f_oid = (__u32)id->name[LUSTRE_RES_ID_VER_OID_OFF];
+	fid.f_ver = (__u32)(id->name[LUSTRE_RES_ID_VER_OID_OFF] >> 32);
+
+	hash = fid_flatten32(&fid);
+	hash += (hash >> 4) + (hash << 12); /* mixing oid and seq */
+	if (id->name[LUSTRE_RES_ID_HSH_OFF] != 0) {
+		val = id->name[LUSTRE_RES_ID_HSH_OFF];
+		hash += (val >> 5) + (val << 11);
+	} else {
+		val = fid_oid(&fid);
+	}
+	hash = hash_long(hash, hs->hs_bkt_bits);
+	/* give me another random factor */
+	hash -= hash_long((unsigned long)hs, val % 11 + 3);
+
+	hash <<= hs->hs_cur_bits - hs->hs_bkt_bits;
+	hash |= ldlm_res_hop_hash(hs, key, CFS_HASH_NBKT(hs) - 1);
+
+	return hash & mask;
+}
+
+static void *ldlm_res_hop_key(struct hlist_node *hnode)
+{
+	struct ldlm_resource   *res;
+
+	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
+	return &res->lr_name;
+}
+
+static int ldlm_res_hop_keycmp(const void *key, struct hlist_node *hnode)
+{
+	struct ldlm_resource   *res;
+
+	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
+	return ldlm_res_eq((const struct ldlm_res_id *)key,
+			   (const struct ldlm_res_id *)&res->lr_name);
+}
+
+static void *ldlm_res_hop_object(struct hlist_node *hnode)
+{
+	return hlist_entry(hnode, struct ldlm_resource, lr_hash);
+}
+
+static void ldlm_res_hop_get_locked(struct cfs_hash *hs,
+				    struct hlist_node *hnode)
+{
+	struct ldlm_resource *res;
+
+	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
+	ldlm_resource_getref(res);
+}
+
+static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
+{
+	struct ldlm_resource *res;
+
+	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
+	ldlm_resource_putref(res);
+}
+
+static struct cfs_hash_ops ldlm_ns_hash_ops = {
+	.hs_hash	= ldlm_res_hop_hash,
+	.hs_key		= ldlm_res_hop_key,
+	.hs_keycmp      = ldlm_res_hop_keycmp,
+	.hs_keycpy      = NULL,
+	.hs_object      = ldlm_res_hop_object,
+	.hs_get		= ldlm_res_hop_get_locked,
+	.hs_put		= ldlm_res_hop_put
+};
+
+static struct cfs_hash_ops ldlm_ns_fid_hash_ops = {
+	.hs_hash	= ldlm_res_hop_fid_hash,
+	.hs_key		= ldlm_res_hop_key,
+	.hs_keycmp      = ldlm_res_hop_keycmp,
+	.hs_keycpy      = NULL,
+	.hs_object      = ldlm_res_hop_object,
+	.hs_get		= ldlm_res_hop_get_locked,
+	.hs_put		= ldlm_res_hop_put
+};
+
+struct ldlm_ns_hash_def {
+	enum ldlm_ns_type nsd_type;
+	/** hash bucket bits */
+	unsigned int	nsd_bkt_bits;
+	/** hash bits */
+	unsigned int	nsd_all_bits;
+	/** hash operations */
+	struct cfs_hash_ops *nsd_hops;
+};
+
+static struct ldlm_ns_hash_def ldlm_ns_hash_defs[] = {
+	{
+		.nsd_type       = LDLM_NS_TYPE_MDC,
+		.nsd_bkt_bits   = 11,
+		.nsd_all_bits   = 16,
+		.nsd_hops       = &ldlm_ns_fid_hash_ops,
+	},
+	{
+		.nsd_type       = LDLM_NS_TYPE_MDT,
+		.nsd_bkt_bits   = 14,
+		.nsd_all_bits   = 21,
+		.nsd_hops       = &ldlm_ns_fid_hash_ops,
+	},
+	{
+		.nsd_type       = LDLM_NS_TYPE_OSC,
+		.nsd_bkt_bits   = 8,
+		.nsd_all_bits   = 12,
+		.nsd_hops       = &ldlm_ns_hash_ops,
+	},
+	{
+		.nsd_type       = LDLM_NS_TYPE_OST,
+		.nsd_bkt_bits   = 11,
+		.nsd_all_bits   = 17,
+		.nsd_hops       = &ldlm_ns_hash_ops,
+	},
+	{
+		.nsd_type       = LDLM_NS_TYPE_MGC,
+		.nsd_bkt_bits   = 4,
+		.nsd_all_bits   = 4,
+		.nsd_hops       = &ldlm_ns_hash_ops,
+	},
+	{
+		.nsd_type       = LDLM_NS_TYPE_MGT,
+		.nsd_bkt_bits   = 4,
+		.nsd_all_bits   = 4,
+		.nsd_hops       = &ldlm_ns_hash_ops,
+	},
+	{
+		.nsd_type       = LDLM_NS_TYPE_UNKNOWN,
+	},
+};
+
+/** Register \a ns in the list of namespaces */
+static void ldlm_namespace_register(struct ldlm_namespace *ns,
+				    enum ldlm_side client)
+{
+	mutex_lock(ldlm_namespace_lock(client));
+	LASSERT(list_empty(&ns->ns_list_chain));
+	list_add(&ns->ns_list_chain, &ldlm_cli_inactive_namespace_list);
+	ldlm_namespace_nr_inc(client);
+	mutex_unlock(ldlm_namespace_lock(client));
+}
+
+/**
+ * Create and initialize new empty namespace.
+ */
+struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
+					  enum ldlm_side client,
+					  enum ldlm_appetite apt,
+					  enum ldlm_ns_type ns_type)
+{
+	struct ldlm_namespace *ns = NULL;
+	struct ldlm_ns_bucket *nsb;
+	struct ldlm_ns_hash_def    *nsd;
+	struct cfs_hash_bd	  bd;
+	int		    idx;
+	int		    rc;
+
+	LASSERT(obd);
+
+	rc = ldlm_get_ref();
+	if (rc) {
+		CERROR("ldlm_get_ref failed: %d\n", rc);
+		return NULL;
+	}
+
+	for (idx = 0;; idx++) {
+		nsd = &ldlm_ns_hash_defs[idx];
+		if (nsd->nsd_type == LDLM_NS_TYPE_UNKNOWN) {
+			CERROR("Unknown type %d for ns %s\n", ns_type, name);
+			goto out_ref;
+		}
+
+		if (nsd->nsd_type == ns_type)
+			break;
+	}
+
+	ns = kzalloc(sizeof(*ns), GFP_NOFS);
+	if (!ns)
+		goto out_ref;
+
+	ns->ns_rs_hash = cfs_hash_create(name,
+					 nsd->nsd_all_bits, nsd->nsd_all_bits,
+					 nsd->nsd_bkt_bits, sizeof(*nsb),
+					 CFS_HASH_MIN_THETA,
+					 CFS_HASH_MAX_THETA,
+					 nsd->nsd_hops,
+					 CFS_HASH_DEPTH |
+					 CFS_HASH_BIGNAME |
+					 CFS_HASH_SPIN_BKTLOCK |
+					 CFS_HASH_NO_ITEMREF);
+	if (!ns->ns_rs_hash)
+		goto out_ns;
+
+	cfs_hash_for_each_bucket(ns->ns_rs_hash, &bd, idx) {
+		nsb = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
+		at_init(&nsb->nsb_at_estimate, ldlm_enqueue_min, 0);
+		nsb->nsb_namespace = ns;
+	}
+
+	ns->ns_obd      = obd;
+	ns->ns_appetite = apt;
+	ns->ns_client   = client;
+	ns->ns_name     = kstrdup(name, GFP_KERNEL);
+	if (!ns->ns_name)
+		goto out_hash;
+
+	INIT_LIST_HEAD(&ns->ns_list_chain);
+	INIT_LIST_HEAD(&ns->ns_unused_list);
+	spin_lock_init(&ns->ns_lock);
+	atomic_set(&ns->ns_bref, 0);
+	init_waitqueue_head(&ns->ns_waitq);
+
+	ns->ns_max_parallel_ast   = LDLM_DEFAULT_PARALLEL_AST_LIMIT;
+	ns->ns_nr_unused	  = 0;
+	ns->ns_max_unused	 = LDLM_DEFAULT_LRU_SIZE;
+	ns->ns_max_age	    = LDLM_DEFAULT_MAX_ALIVE;
+	ns->ns_orig_connect_flags = 0;
+	ns->ns_connect_flags      = 0;
+	ns->ns_stopping	   = 0;
+
+	rc = ldlm_namespace_sysfs_register(ns);
+	if (rc != 0) {
+		CERROR("Can't initialize ns sysfs, rc %d\n", rc);
+		goto out_hash;
+	}
+
+	rc = ldlm_namespace_debugfs_register(ns);
+	if (rc != 0) {
+		CERROR("Can't initialize ns proc, rc %d\n", rc);
+		goto out_sysfs;
+	}
+
+	idx = ldlm_namespace_nr_read(client);
+	rc = ldlm_pool_init(&ns->ns_pool, ns, idx, client);
+	if (rc) {
+		CERROR("Can't initialize lock pool, rc %d\n", rc);
+		goto out_proc;
+	}
+
+	ldlm_namespace_register(ns, client);
+	return ns;
+out_proc:
+	ldlm_namespace_debugfs_unregister(ns);
+out_sysfs:
+	ldlm_namespace_sysfs_unregister(ns);
+	ldlm_namespace_cleanup(ns, 0);
+out_hash:
+	kfree(ns->ns_name);
+	cfs_hash_putref(ns->ns_rs_hash);
+out_ns:
+	kfree(ns);
+out_ref:
+	ldlm_put_ref();
+	return NULL;
+}
+EXPORT_SYMBOL(ldlm_namespace_new);
+
+extern struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
+
+/**
+ * Cancel and destroy all locks on a resource.
+ *
+ * If flags contains FL_LOCAL_ONLY, don't try to tell the server, just
+ * clean up.  This is currently only used for recovery, and we make
+ * certain assumptions as a result--notably, that we shouldn't cancel
+ * locks with refs.
+ */
+static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
+			     __u64 flags)
+{
+	int rc = 0;
+	bool local_only = !!(flags & LDLM_FL_LOCAL_ONLY);
+
+	do {
+		struct ldlm_lock *lock = NULL, *tmp;
+		struct lustre_handle lockh;
+
+		/* First, we look for non-cleaned-yet lock
+		 * all cleaned locks are marked by CLEANED flag.
+		 */
+		lock_res(res);
+		list_for_each_entry(tmp, q, l_res_link) {
+			if (ldlm_is_cleaned(tmp))
+				continue;
+
+			lock = tmp;
+			LDLM_LOCK_GET(lock);
+			ldlm_set_cleaned(lock);
+			break;
+		}
+
+		if (!lock) {
+			unlock_res(res);
+			break;
+		}
+
+		/* Set CBPENDING so nothing in the cancellation path
+		 * can match this lock.
+		 */
+		ldlm_set_cbpending(lock);
+		ldlm_set_failed(lock);
+		lock->l_flags |= flags;
+
+		/* ... without sending a CANCEL message for local_only. */
+		if (local_only)
+			ldlm_set_local_only(lock);
+
+		if (local_only && (lock->l_readers || lock->l_writers)) {
+			/* This is a little bit gross, but much better than the
+			 * alternative: pretend that we got a blocking AST from
+			 * the server, so that when the lock is decref'd, it
+			 * will go away ...
+			 */
+			unlock_res(res);
+			LDLM_DEBUG(lock, "setting FL_LOCAL_ONLY");
+			if (lock->l_flags & LDLM_FL_FAIL_LOC) {
+				set_current_state(TASK_UNINTERRUPTIBLE);
+				schedule_timeout(4 * HZ);
+				set_current_state(TASK_RUNNING);
+			}
+			if (lock->l_completion_ast)
+				lock->l_completion_ast(lock, LDLM_FL_FAILED,
+						       NULL);
+			LDLM_LOCK_RELEASE(lock);
+			continue;
+		}
+
+		unlock_res(res);
+		ldlm_lock2handle(lock, &lockh);
+		rc = ldlm_cli_cancel(&lockh, LCF_LOCAL);
+		if (rc)
+			CERROR("ldlm_cli_cancel: %d\n", rc);
+		LDLM_LOCK_RELEASE(lock);
+	} while (1);
+}
+
+static int ldlm_resource_clean(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			       struct hlist_node *hnode, void *arg)
+{
+	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
+	__u64 flags = *(__u64 *)arg;
+
+	cleanup_resource(res, &res->lr_granted, flags);
+	cleanup_resource(res, &res->lr_waiting, flags);
+
+	return 0;
+}
+
+static int ldlm_resource_complain(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+				  struct hlist_node *hnode, void *arg)
+{
+	struct ldlm_resource  *res = cfs_hash_object(hs, hnode);
+
+	lock_res(res);
+	CERROR("%s: namespace resource " DLDLMRES
+	       " (%p) refcount nonzero (%d) after lock cleanup; forcing cleanup.\n",
+	       ldlm_ns_name(ldlm_res_to_ns(res)), PLDLMRES(res), res,
+	       atomic_read(&res->lr_refcount) - 1);
+
+	ldlm_resource_dump(D_ERROR, res);
+	unlock_res(res);
+	return 0;
+}
+
+/**
+ * Cancel and destroy all locks in the namespace.
+ *
+ * Typically used during evictions when server notified client that it was
+ * evicted and all of its state needs to be destroyed.
+ * Also used during shutdown.
+ */
+int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags)
+{
+	if (!ns) {
+		CDEBUG(D_INFO, "NULL ns, skipping cleanup\n");
+		return ELDLM_OK;
+	}
+
+	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_clean,
+				 &flags, 0);
+	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_complain,
+				 NULL, 0);
+	return ELDLM_OK;
+}
+EXPORT_SYMBOL(ldlm_namespace_cleanup);
+
+/**
+ * Attempts to free namespace.
+ *
+ * Only used when namespace goes away, like during an unmount.
+ */
+static int __ldlm_namespace_free(struct ldlm_namespace *ns, int force)
+{
+	/* At shutdown time, don't call the cancellation callback */
+	ldlm_namespace_cleanup(ns, force ? LDLM_FL_LOCAL_ONLY : 0);
+
+	if (atomic_read(&ns->ns_bref) > 0) {
+		int rc;
+
+		CDEBUG(D_DLMTRACE,
+		       "dlm namespace %s free waiting on refcount %d\n",
+		       ldlm_ns_name(ns), atomic_read(&ns->ns_bref));
+force_wait:
+		if (force)
+			rc = wait_event_idle_timeout(ns->ns_waitq,
+						     atomic_read(&ns->ns_bref) == 0,
+						     obd_timeout * HZ / 4) ? 0 : -ETIMEDOUT;
+		else
+			rc = l_wait_event_abortable(ns->ns_waitq,
+						    atomic_read(&ns->ns_bref) == 0);
+
+		/* Forced cleanups should be able to reclaim all references,
+		 * so it's safe to wait forever... we can't leak locks...
+		 */
+		if (force && rc == -ETIMEDOUT) {
+			LCONSOLE_ERROR("Forced cleanup waiting for %s namespace with %d resources in use, (rc=%d)\n",
+				       ldlm_ns_name(ns),
+				       atomic_read(&ns->ns_bref), rc);
+			goto force_wait;
+		}
+
+		if (atomic_read(&ns->ns_bref)) {
+			LCONSOLE_ERROR("Cleanup waiting for %s namespace with %d resources in use, (rc=%d)\n",
+				       ldlm_ns_name(ns),
+				       atomic_read(&ns->ns_bref), rc);
+			return ELDLM_NAMESPACE_EXISTS;
+		}
+		CDEBUG(D_DLMTRACE, "dlm namespace %s free done waiting\n",
+		       ldlm_ns_name(ns));
+	}
+
+	return ELDLM_OK;
+}
+
+/**
+ * Performs various cleanups for passed \a ns to make it drop refc and be
+ * ready for freeing. Waits for refc == 0.
+ *
+ * The following is done:
+ * (0) Unregister \a ns from its list to make inaccessible for potential
+ * users like pools thread and others;
+ * (1) Clear all locks in \a ns.
+ */
+void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
+			       struct obd_import *imp,
+			       int force)
+{
+	int rc;
+
+	if (!ns)
+		return;
+
+	spin_lock(&ns->ns_lock);
+	ns->ns_stopping = 1;
+	spin_unlock(&ns->ns_lock);
+
+	/*
+	 * Can fail with -EINTR when force == 0 in which case try harder.
+	 */
+	rc = __ldlm_namespace_free(ns, force);
+	if (rc != ELDLM_OK) {
+		if (imp) {
+			ptlrpc_disconnect_import(imp, 0);
+			ptlrpc_invalidate_import(imp);
+		}
+
+		/*
+		 * With all requests dropped and the import inactive
+		 * we are guaranteed all reference will be dropped.
+		 */
+		rc = __ldlm_namespace_free(ns, 1);
+		LASSERT(rc == 0);
+	}
+}
+
+/** Unregister \a ns from the list of namespaces. */
+static void ldlm_namespace_unregister(struct ldlm_namespace *ns,
+				      enum ldlm_side client)
+{
+	mutex_lock(ldlm_namespace_lock(client));
+	LASSERT(!list_empty(&ns->ns_list_chain));
+	/* Some asserts and possibly other parts of the code are still
+	 * using list_empty(&ns->ns_list_chain). This is why it is
+	 * important to use list_del_init() here.
+	 */
+	list_del_init(&ns->ns_list_chain);
+	ldlm_namespace_nr_dec(client);
+	mutex_unlock(ldlm_namespace_lock(client));
+}
+
+/**
+ * Performs freeing memory structures related to \a ns. This is only done
+ * when ldlm_namespce_free_prior() successfully removed all resources
+ * referencing \a ns and its refc == 0.
+ */
+void ldlm_namespace_free_post(struct ldlm_namespace *ns)
+{
+	if (!ns)
+		return;
+
+	/* Make sure that nobody can find this ns in its list. */
+	ldlm_namespace_unregister(ns, ns->ns_client);
+	/* Fini pool _before_ parent proc dir is removed. This is important as
+	 * ldlm_pool_fini() removes own proc dir which is child to @dir.
+	 * Removing it after @dir may cause oops.
+	 */
+	ldlm_pool_fini(&ns->ns_pool);
+
+	ldlm_namespace_debugfs_unregister(ns);
+	ldlm_namespace_sysfs_unregister(ns);
+	cfs_hash_putref(ns->ns_rs_hash);
+	kfree(ns->ns_name);
+	/* Namespace \a ns should be not on list at this time, otherwise
+	 * this will cause issues related to using freed \a ns in poold
+	 * thread.
+	 */
+	LASSERT(list_empty(&ns->ns_list_chain));
+	kfree(ns);
+	ldlm_put_ref();
+}
+
+void ldlm_namespace_get(struct ldlm_namespace *ns)
+{
+	atomic_inc(&ns->ns_bref);
+}
+
+/* This is only for callers that care about refcount */
+static int ldlm_namespace_get_return(struct ldlm_namespace *ns)
+{
+	return atomic_inc_return(&ns->ns_bref);
+}
+
+void ldlm_namespace_put(struct ldlm_namespace *ns)
+{
+	if (atomic_dec_and_lock(&ns->ns_bref, &ns->ns_lock)) {
+		wake_up(&ns->ns_waitq);
+		spin_unlock(&ns->ns_lock);
+	}
+}
+
+/** Should be called with ldlm_namespace_lock(client) taken. */
+void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *ns,
+					  enum ldlm_side client)
+{
+	LASSERT(!list_empty(&ns->ns_list_chain));
+	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
+	list_move_tail(&ns->ns_list_chain, ldlm_namespace_list(client));
+}
+
+/** Should be called with ldlm_namespace_lock(client) taken. */
+void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
+					    enum ldlm_side client)
+{
+	LASSERT(!list_empty(&ns->ns_list_chain));
+	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
+	list_move_tail(&ns->ns_list_chain, &ldlm_cli_inactive_namespace_list);
+}
+
+/** Should be called with ldlm_namespace_lock(client) taken. */
+struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side client)
+{
+	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
+	LASSERT(!list_empty(ldlm_namespace_list(client)));
+	return container_of(ldlm_namespace_list(client)->next,
+		struct ldlm_namespace, ns_list_chain);
+}
+
+/** Create and initialize new resource. */
+static struct ldlm_resource *ldlm_resource_new(void)
+{
+	struct ldlm_resource *res;
+	int idx;
+
+	res = kmem_cache_zalloc(ldlm_resource_slab, GFP_NOFS);
+	if (!res)
+		return NULL;
+
+	INIT_LIST_HEAD(&res->lr_granted);
+	INIT_LIST_HEAD(&res->lr_waiting);
+
+	/* Initialize interval trees for each lock mode. */
+	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
+		res->lr_itree[idx].lit_size = 0;
+		res->lr_itree[idx].lit_mode = 1 << idx;
+		res->lr_itree[idx].lit_root = RB_ROOT_CACHED;
+	}
+
+	atomic_set(&res->lr_refcount, 1);
+	spin_lock_init(&res->lr_lock);
+	lu_ref_init(&res->lr_reference);
+
+	/* The creator of the resource must unlock the mutex after LVB
+	 * initialization.
+	 */
+	mutex_init(&res->lr_lvb_mutex);
+	mutex_lock(&res->lr_lvb_mutex);
+
+	return res;
+}
+
+/**
+ * Return a reference to resource with given name, creating it if necessary.
+ * Args: namespace with ns_lock unlocked
+ * Locks: takes and releases NS hash-lock and res->lr_lock
+ * Returns: referenced, unlocked ldlm_resource or NULL
+ */
+struct ldlm_resource *
+ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
+		  const struct ldlm_res_id *name, enum ldlm_type type,
+		  int create)
+{
+	struct hlist_node     *hnode;
+	struct ldlm_resource *res = NULL;
+	struct cfs_hash_bd	 bd;
+	__u64		 version;
+	int		      ns_refcount = 0;
+	int rc;
+
+	LASSERT(!parent);
+	LASSERT(ns->ns_rs_hash);
+	LASSERT(name->name[0] != 0);
+
+	cfs_hash_bd_get_and_lock(ns->ns_rs_hash, (void *)name, &bd, 0);
+	hnode = cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
+	if (hnode) {
+		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
+		goto lvbo_init;
+	}
+
+	version = cfs_hash_bd_version_get(&bd);
+	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
+
+	if (create == 0)
+		return ERR_PTR(-ENOENT);
+
+	LASSERTF(type >= LDLM_MIN_TYPE && type < LDLM_MAX_TYPE,
+		 "type: %d\n", type);
+	res = ldlm_resource_new();
+	if (!res)
+		return ERR_PTR(-ENOMEM);
+
+	res->lr_ns_bucket  = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
+	res->lr_name       = *name;
+	res->lr_type       = type;
+
+	cfs_hash_bd_lock(ns->ns_rs_hash, &bd, 1);
+	hnode = (version == cfs_hash_bd_version_get(&bd)) ?  NULL :
+		cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
+
+	if (hnode) {
+		/* Someone won the race and already added the resource. */
+		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
+		/* Clean lu_ref for failed resource. */
+		lu_ref_fini(&res->lr_reference);
+		/* We have taken lr_lvb_mutex. Drop it. */
+		mutex_unlock(&res->lr_lvb_mutex);
+		kmem_cache_free(ldlm_resource_slab, res);
+lvbo_init:
+		res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
+		/* Synchronize with regard to resource creation. */
+		if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
+			mutex_lock(&res->lr_lvb_mutex);
+			mutex_unlock(&res->lr_lvb_mutex);
+		}
+
+		if (unlikely(res->lr_lvb_len < 0)) {
+			rc = res->lr_lvb_len;
+			ldlm_resource_putref(res);
+			res = ERR_PTR(rc);
+		}
+		return res;
+	}
+	/* We won! Let's add the resource. */
+	cfs_hash_bd_add_locked(ns->ns_rs_hash, &bd, &res->lr_hash);
+	if (cfs_hash_bd_count_get(&bd) == 1)
+		ns_refcount = ldlm_namespace_get_return(ns);
+
+	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
+	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CREATE_RESOURCE, 2);
+		rc = ns->ns_lvbo->lvbo_init(res);
+		if (rc < 0) {
+			CERROR("%s: lvbo_init failed for resource %#llx:%#llx: rc = %d\n",
+			       ns->ns_obd->obd_name, name->name[0],
+			       name->name[1], rc);
+			res->lr_lvb_len = rc;
+			mutex_unlock(&res->lr_lvb_mutex);
+			ldlm_resource_putref(res);
+			return ERR_PTR(rc);
+		}
+	}
+
+	/* We create resource with locked lr_lvb_mutex. */
+	mutex_unlock(&res->lr_lvb_mutex);
+
+	/* Let's see if we happened to be the very first resource in this
+	 * namespace. If so, and this is a client namespace, we need to move
+	 * the namespace into the active namespaces list to be patrolled by
+	 * the ldlm_poold.
+	 */
+	if (ns_refcount == 1) {
+		mutex_lock(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
+		ldlm_namespace_move_to_active_locked(ns, LDLM_NAMESPACE_CLIENT);
+		mutex_unlock(ldlm_namespace_lock(LDLM_NAMESPACE_CLIENT));
+	}
+
+	return res;
+}
+EXPORT_SYMBOL(ldlm_resource_get);
+
+static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
+					 struct ldlm_resource *res)
+{
+	struct ldlm_ns_bucket *nsb = res->lr_ns_bucket;
+	struct ldlm_namespace *ns = nsb->nsb_namespace;
+
+	if (!list_empty(&res->lr_granted)) {
+		ldlm_resource_dump(D_ERROR, res);
+		LBUG();
+	}
+
+	if (!list_empty(&res->lr_waiting)) {
+		ldlm_resource_dump(D_ERROR, res);
+		LBUG();
+	}
+
+	cfs_hash_bd_del_locked(ns->ns_rs_hash,
+			       bd, &res->lr_hash);
+	lu_ref_fini(&res->lr_reference);
+	cfs_hash_bd_unlock(ns->ns_rs_hash, bd, 1);
+	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_free)
+		ns->ns_lvbo->lvbo_free(res);
+	if (cfs_hash_bd_count_get(bd) == 0)
+		ldlm_namespace_put(ns);
+	kmem_cache_free(ldlm_resource_slab, res);
+}
+
+void ldlm_resource_putref(struct ldlm_resource *res)
+{
+	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
+	struct cfs_hash_bd   bd;
+
+	LASSERT_ATOMIC_GT_LT(&res->lr_refcount, 0, LI_POISON);
+	CDEBUG(D_INFO, "putref res: %p count: %d\n",
+	       res, atomic_read(&res->lr_refcount) - 1);
+
+	cfs_hash_bd_get(ns->ns_rs_hash, &res->lr_name, &bd);
+	if (cfs_hash_bd_dec_and_lock(ns->ns_rs_hash, &bd, &res->lr_refcount))
+		__ldlm_resource_putref_final(&bd, res);
+}
+EXPORT_SYMBOL(ldlm_resource_putref);
+
+/**
+ * Add a lock into a given resource into specified lock list.
+ */
+void ldlm_resource_add_lock(struct ldlm_resource *res, struct list_head *head,
+			    struct ldlm_lock *lock)
+{
+	check_res_locked(res);
+
+	LDLM_DEBUG(lock, "About to add this lock:");
+
+	if (ldlm_is_destroyed(lock)) {
+		CDEBUG(D_OTHER, "Lock destroyed, not adding to resource\n");
+		return;
+	}
+
+	LASSERT(list_empty(&lock->l_res_link));
+
+	list_add_tail(&lock->l_res_link, head);
+}
+
+void ldlm_resource_unlink_lock(struct ldlm_lock *lock)
+{
+	int type = lock->l_resource->lr_type;
+
+	check_res_locked(lock->l_resource);
+	if (type == LDLM_IBITS || type == LDLM_PLAIN)
+		ldlm_unlink_lock_skiplist(lock);
+	else if (type == LDLM_EXTENT)
+		ldlm_extent_unlink_lock(lock);
+	list_del_init(&lock->l_res_link);
+}
+EXPORT_SYMBOL(ldlm_resource_unlink_lock);
+
+void ldlm_res2desc(struct ldlm_resource *res, struct ldlm_resource_desc *desc)
+{
+	desc->lr_type = res->lr_type;
+	desc->lr_name = res->lr_name;
+}
+
+/**
+ * Print information about all locks in all namespaces on this node to debug
+ * log.
+ */
+void ldlm_dump_all_namespaces(enum ldlm_side client, int level)
+{
+	struct ldlm_namespace *ns;
+
+	if (!((libcfs_debug | D_ERROR) & level))
+		return;
+
+	mutex_lock(ldlm_namespace_lock(client));
+
+	list_for_each_entry(ns, ldlm_namespace_list(client), ns_list_chain)
+		ldlm_namespace_dump(level, ns);
+
+	mutex_unlock(ldlm_namespace_lock(client));
+}
+
+static int ldlm_res_hash_dump(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			      struct hlist_node *hnode, void *arg)
+{
+	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
+	int    level = (int)(unsigned long)arg;
+
+	lock_res(res);
+	ldlm_resource_dump(level, res);
+	unlock_res(res);
+
+	return 0;
+}
+
+/**
+ * Print information about all locks in this namespace on this node to debug
+ * log.
+ */
+void ldlm_namespace_dump(int level, struct ldlm_namespace *ns)
+{
+	if (!((libcfs_debug | D_ERROR) & level))
+		return;
+
+	CDEBUG(level, "--- Namespace: %s (rc: %d, side: client)\n",
+	       ldlm_ns_name(ns), atomic_read(&ns->ns_bref));
+
+	if (time_before(jiffies, ns->ns_next_dump))
+		return;
+
+	cfs_hash_for_each_nolock(ns->ns_rs_hash,
+				 ldlm_res_hash_dump,
+				 (void *)(unsigned long)level, 0);
+	spin_lock(&ns->ns_lock);
+	ns->ns_next_dump = jiffies + 10 * HZ;
+	spin_unlock(&ns->ns_lock);
+}
+
+/**
+ * Print information about all locks in this resource to debug log.
+ */
+void ldlm_resource_dump(int level, struct ldlm_resource *res)
+{
+	struct ldlm_lock *lock;
+	unsigned int granted = 0;
+
+	BUILD_BUG_ON(RES_NAME_SIZE != 4);
+
+	if (!((libcfs_debug | D_ERROR) & level))
+		return;
+
+	CDEBUG(level, "--- Resource: " DLDLMRES " (%p) refcount = %d\n",
+	       PLDLMRES(res), res, atomic_read(&res->lr_refcount));
+
+	if (!list_empty(&res->lr_granted)) {
+		CDEBUG(level, "Granted locks (in reverse order):\n");
+		list_for_each_entry_reverse(lock, &res->lr_granted,
+					    l_res_link) {
+			LDLM_DEBUG_LIMIT(level, lock, "###");
+			if (!(level & D_CANTMASK) &&
+			    ++granted > ldlm_dump_granted_max) {
+				CDEBUG(level,
+				       "only dump %d granted locks to avoid DDOS.\n",
+				       granted);
+				break;
+			}
+		}
+	}
+	if (!list_empty(&res->lr_waiting)) {
+		CDEBUG(level, "Waiting locks:\n");
+		list_for_each_entry(lock, &res->lr_waiting, l_res_link)
+			LDLM_DEBUG_LIMIT(level, lock, "###");
+	}
+}
+EXPORT_SYMBOL(ldlm_resource_dump);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 134b74234519..09ccb3fdabba 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -36,7 +36,7 @@
 #ifndef PTLRPC_INTERNAL_H
 #define PTLRPC_INTERNAL_H
 
-#include "../ldlm/ldlm_internal.h"
+#include "ldlm_internal.h"
 
 struct ldlm_namespace;
 struct obd_import;
