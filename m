From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:32 -0400
Subject: [lustre-devel] [PATCH 36/41] staging: lustre: ldlm: interval tree
	search in ldlm_lock_match()
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly_fertman@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Vitaly Fertman <vitaly_fertman@xyratex.com>

replace the linear search by interval_tree one for granted list
in ldlm_lock_match()

Signed-off-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5739
Xyratex-bug-id: MRP-2089
Reviewed-on: http://review.whamcloud.com/12294
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c |  249 ++++++++++++++++--------
 1 files changed, 171 insertions(+), 78 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 22b4a52..f2044ec 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1043,88 +1043,173 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
 }
 
 /**
- * Search for a lock with given properties in a queue.
+ * Describe the overlap between two locks.  itree_overlap_cb data.
+ */
+struct lock_match_data {
+	struct ldlm_lock	*lmd_old;
+	struct ldlm_lock	*lmd_lock;
+	enum ldlm_mode		*lmd_mode;
+	ldlm_policy_data_t	*lmd_policy;
+	__u64			 lmd_flags;
+	int			 lmd_unref;
+};
+
+/**
+ * Check if the given @lock meets the criteria for a match.
+ * A reference on the lock is taken if matched.
  *
- * \retval a referenced lock or NULL.  See the flag descriptions below, in the
- * comment above ldlm_lock_match
+ * \param lock	test-against this lock
+ * \param data	parameters
  */
-static struct ldlm_lock *search_queue(struct list_head *queue,
-				      enum ldlm_mode *mode,
-				      ldlm_policy_data_t *policy,
-				      struct ldlm_lock *old_lock,
-				      __u64 flags, int unref)
+static int lock_matches(struct ldlm_lock *lock, struct lock_match_data *data)
 {
-	struct ldlm_lock *lock;
-	struct list_head       *tmp;
+	ldlm_policy_data_t *lpol = &lock->l_policy_data;
+	enum ldlm_mode match;
 
-	list_for_each(tmp, queue) {
-		enum ldlm_mode match;
+	if (lock == data->lmd_old)
+		return INTERVAL_ITER_STOP;
 
-		lock = list_entry(tmp, struct ldlm_lock, l_res_link);
+	/*
+	 * Check if this lock can be matched.
+	 * Used by LU-2919(exclusive open) for open lease lock
+	 */
+	if (ldlm_is_excl(lock))
+		return INTERVAL_ITER_CONT;
 
-		if (lock == old_lock)
-			break;
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
+		return INTERVAL_ITER_CONT;
 
-		/* Check if this lock can be matched.
-		 * Used by LU-2919(exclusive open) for open lease lock
-		 */
-		if (ldlm_is_excl(lock))
-			continue;
+	if (!data->lmd_unref && ldlm_is_cbpending(lock) &&
+	    !lock->l_readers && !lock->l_writers)
+		return INTERVAL_ITER_CONT;
 
-		/* llite sometimes wants to match locks that will be
-		 * canceled when their users drop, but we allow it to match
-		 * if it passes in CBPENDING and the lock still has users.
-		 * this is generally only going to be used by children
-		 * whose parents already hold a lock so forward progress
-		 * can still happen.
-		 */
-		if (ldlm_is_cbpending(lock) && !(flags & LDLM_FL_CBPENDING))
-			continue;
-		if (!unref && ldlm_is_cbpending(lock) &&
-		    lock->l_readers == 0 && lock->l_writers == 0)
-			continue;
+	if (!(lock->l_req_mode & *data->lmd_mode))
+		return INTERVAL_ITER_CONT;
+	match = lock->l_req_mode;
 
-		if (!(lock->l_req_mode & *mode))
-			continue;
-		match = lock->l_req_mode;
-
-		if (lock->l_resource->lr_type == LDLM_EXTENT &&
-		    (lock->l_policy_data.l_extent.start >
-		     policy->l_extent.start ||
-		     lock->l_policy_data.l_extent.end < policy->l_extent.end))
-			continue;
+	switch (lock->l_resource->lr_type) {
+	case LDLM_EXTENT:
+		if (lpol->l_extent.start > data->lmd_policy->l_extent.start ||
+		    lpol->l_extent.end < data->lmd_policy->l_extent.end)
+			return INTERVAL_ITER_CONT;
 
 		if (unlikely(match == LCK_GROUP) &&
-		    lock->l_resource->lr_type == LDLM_EXTENT &&
-		    policy->l_extent.gid != LDLM_GID_ANY &&
-		    lock->l_policy_data.l_extent.gid != policy->l_extent.gid)
-			continue;
-
-		/* We match if we have existing lock with same or wider set
+		    data->lmd_policy->l_extent.gid != LDLM_GID_ANY &&
+		    lpol->l_extent.gid != data->lmd_policy->l_extent.gid)
+			return INTERVAL_ITER_CONT;
+		break;
+	case LDLM_IBITS:
+		/*
+		 * We match if we have existing lock with same or wider set
 		 * of bits.
 		 */
-		if (lock->l_resource->lr_type == LDLM_IBITS &&
-		    ((lock->l_policy_data.l_inodebits.bits &
-		      policy->l_inodebits.bits) !=
-		      policy->l_inodebits.bits))
-			continue;
+		if ((lpol->l_inodebits.bits &
+		     data->lmd_policy->l_inodebits.bits) !=
+		    data->lmd_policy->l_inodebits.bits)
+			return INTERVAL_ITER_CONT;
+		break;
+	default:
+		break;
+	}
+	/*
+	 * We match if we have existing lock with same or wider set
+	 * of bits.
+	 */
+	if (!data->lmd_unref && LDLM_HAVE_MASK(lock, GONE))
+		return INTERVAL_ITER_CONT;
+
+	if ((data->lmd_flags & LDLM_FL_LOCAL_ONLY) &&
+	    !ldlm_is_local(lock))
+		return INTERVAL_ITER_CONT;
 
-		if (!unref && LDLM_HAVE_MASK(lock, GONE))
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
+	return INTERVAL_ITER_STOP;
+}
+
+static unsigned int itree_overlap_cb(struct interval_node *in, void *args)
+{
+	struct ldlm_interval *node = to_ldlm_interval(in);
+	struct lock_match_data *data = args;
+	struct ldlm_lock *lock;
+	int rc;
+
+	list_for_each_entry(lock, &node->li_group, l_sl_policy) {
+		rc = lock_matches(lock, data);
+		if (rc == INTERVAL_ITER_STOP)
+			return INTERVAL_ITER_STOP;
+	}
+	return INTERVAL_ITER_CONT;
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
+	struct interval_node_extent ext = {
+		.start	= data->lmd_policy->l_extent.start,
+		.end	= data->lmd_policy->l_extent.end
+	};
+	int idx;
+
+	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
+		struct ldlm_interval_tree *tree = &res->lr_itree[idx];
+
+		if (!tree->lit_root)
 			continue;
 
-		if ((flags & LDLM_FL_LOCAL_ONLY) && !ldlm_is_local(lock))
+		if (!(tree->lit_mode & *data->lmd_mode))
 			continue;
 
-		if (flags & LDLM_FL_TEST_LOCK) {
-			LDLM_LOCK_GET(lock);
-			ldlm_lock_touch_in_lru(lock);
-		} else {
-			ldlm_lock_addref_internal_nolock(lock, match);
-		}
-		*mode = match;
-		return lock;
+		interval_search(tree->lit_root, &ext,
+				itree_overlap_cb, data);
 	}
+	return data->lmd_lock;
+}
 
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
+	int rc;
+
+	list_for_each_entry(lock, queue, l_res_link) {
+		rc = lock_matches(lock, data);
+		if (rc == INTERVAL_ITER_STOP)
+			return data->lmd_lock;
+	}
 	return NULL;
 }
 
@@ -1199,31 +1284,41 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 			       enum ldlm_mode mode,
 			       struct lustre_handle *lockh, int unref)
 {
+	struct lock_match_data data = {
+		.lmd_old	= NULL,
+		.lmd_lock	= NULL,
+		.lmd_mode	= &mode,
+		.lmd_policy	= policy,
+		.lmd_flags	= flags,
+		.lmd_unref	= unref,
+	};
 	struct ldlm_resource *res;
-	struct ldlm_lock *lock, *old_lock = NULL;
+	struct ldlm_lock *lock;
 	int rc = 0;
 
 	if (!ns) {
-		old_lock = ldlm_handle2lock(lockh);
-		LASSERT(old_lock);
+		data.lmd_old = ldlm_handle2lock(lockh);
+		LASSERT(data.lmd_old);
 
-		ns = ldlm_lock_to_ns(old_lock);
-		res_id = &old_lock->l_resource->lr_name;
-		type = old_lock->l_resource->lr_type;
-		mode = old_lock->l_req_mode;
+		ns = ldlm_lock_to_ns(data.lmd_old);
+		res_id = &data.lmd_old->l_resource->lr_name;
+		type = data.lmd_old->l_resource->lr_type;
+		*data.lmd_mode = data.lmd_old->l_req_mode;
 	}
 
 	res = ldlm_resource_get(ns, NULL, res_id, type, 0);
 	if (IS_ERR(res)) {
-		LASSERT(!old_lock);
+		LASSERT(!data.lmd_old);
 		return 0;
 	}
 
 	LDLM_RESOURCE_ADDREF(res);
 	lock_res(res);
 
-	lock = search_queue(&res->lr_granted, &mode, policy, old_lock,
-			    flags, unref);
+	if (res->lr_type == LDLM_EXTENT)
+		lock = search_itree(res, &data);
+	else
+		lock = search_queue(&res->lr_granted, &data);
 	if (lock) {
 		rc = 1;
 		goto out;
@@ -1232,14 +1327,12 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 		rc = 0;
 		goto out;
 	}
-	lock = search_queue(&res->lr_waiting, &mode, policy, old_lock,
-			    flags, unref);
+	lock = search_queue(&res->lr_waiting, &data);
 	if (lock) {
 		rc = 1;
 		goto out;
 	}
-
- out:
+out:
 	unlock_res(res);
 	LDLM_RESOURCE_DELREF(res);
 	ldlm_resource_putref(res);
@@ -1311,8 +1404,8 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 				  (type == LDLM_PLAIN || type == LDLM_IBITS) ?
 					res_id->name[3] : policy->l_extent.end);
 	}
-	if (old_lock)
-		LDLM_LOCK_PUT(old_lock);
+	if (data.lmd_old)
+		LDLM_LOCK_PUT(data.lmd_old);
 
 	return rc ? mode : 0;
 }
-- 
1.7.1
