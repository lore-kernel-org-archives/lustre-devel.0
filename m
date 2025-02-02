Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 73FDDC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:01:33 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFn4lvYz213M;
	Sun, 02 Feb 2025 12:50:05 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMFW4Dnbz2127
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:49:51 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 258AA182375;
 Sun,  2 Feb 2025 15:46:42 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 24414106BE15; Sun,  2 Feb 2025 15:46:42 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:33 -0500
Message-ID: <20250202204633.1148872-34-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 33/33] lustre: ldlm: convert ldlm extent
 locks to linux extent-tree
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Yang Sheng <ys@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

The original work for coverting ldlm_extent locks to the
standard linux extent tree has some bugs which could lead
to kernel crashes such as:

LustreError: 10543:0:(osc_cache.c:1141:osc_extent_make_ready()) ASSERTION( last_oap_count > 0 ) failed: last_oap_count 0
LustreError: 10543:0:(osc_cache.c:1141:osc_extent_make_ready()) LBUG
Pid: 10543, comm: ldlm_bl_05 3.10.0-7.9-debug #1 SMP Mon Feb 1 17:33:41 EST 2021
Call Trace:
[<0>] libcfs_call_trace+0x90/0xf0 [libcfs]
[<0>] lbug_with_loc+0x4c/0xa0 [libcfs]
[<0>] osc_extent_make_ready+0xb66/0xe60 [osc]
[<0>] osc_cache_writeback_range+0x4d3/0xfd0 [osc]
[<0>] osc_lock_flush+0x195/0x290 [osc]
[<0>] osc_ldlm_blocking_ast+0x2f8/0x3e0 [osc]
[<0>] ldlm_cancel_callback+0x84/0x320 [ptlrpc]
[<0>] ldlm_cli_cancel_local+0xd1/0x420 [ptlrpc]
[<0>] ldlm_cli_cancel+0x10c/0x560 [ptlrpc]
[<0>] osc_ldlm_blocking_ast+0x17a/0x3e0 [osc]
[<0>] ldlm_handle_bl_callback+0xc5/0x3e0 [ptlrpc]
[<0>] ldlm_bl_thread_main+0x5bf/0xae0 [ptlrpc]
[<0>] kthread+0xe4/0xf0

This work fixes up the kms handling code and brings us into sync
with later work on the interval tree cleanup done.

Fixes: d5aaf4d1355 ("lustre: convert ldlm extent locks to linux extent-tree")
WC-bug-id: https://jira.whamcloud.com/browse/LU-11085
Lustre-commit: d2ff746a997395e6a ("LU-11085 ldlm: convert ldlm extent locks to linux extent-tree")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/41792
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 22 ++++++++++-----
 fs/lustre/ldlm/ldlm_extent.c   | 47 ++++++++++++++++++++++----------
 fs/lustre/ldlm/ldlm_lock.c     | 49 ++++++++++++++++------------------
 fs/lustre/ldlm/ldlm_lockd.c    |  5 ++--
 4 files changed, 75 insertions(+), 48 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index a3a339f82d1a..4217a8ad4501 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -48,6 +48,7 @@
 #include <lustre_net.h>
 #include <lustre_import.h>
 #include <lustre_handles.h>
+#include <linux/interval_tree_generic.h>
 #include <lu_ref.h>
 
 #include "lustre_dlm_flags.h"
@@ -574,7 +575,7 @@ struct ldlm_glimpse_work {
  * Interval tree for extent locks.
  * The interval tree must be accessed under the resource lock.
  * Interval trees are used for granted extent locks to speed up conflicts
- * lookup. See ldlm/interval_tree.c for more details.
+ * lookup.
  */
 struct ldlm_interval_tree {
 	/** Tree size. */
@@ -666,11 +667,14 @@ struct ldlm_lock {
 	 * Protected by lr_lock in struct ldlm_resource.
 	 */
 	struct list_head		l_res_link;
+
 	/**
-	 * Interval-tree node for ldlm_extent.
+	 * Internal structure per lock type..
 	 */
+	/* LDLM_EXTENT locks only */
+	struct ldlm_extent		l_req_extent;
 	struct rb_node			l_rb;
-	u64				__subtree_last;
+	u64				l_subtree_last;
 
 	/**
 	 * Requested mode.
@@ -750,9 +754,6 @@ struct ldlm_lock {
 	 */
 	ktime_t				l_last_used;
 
-	/** Originally requested extent for the extent lock. */
-	struct ldlm_extent		l_req_extent;
-
 	/*
 	 * Client-side-only members.
 	 */
@@ -858,6 +859,15 @@ enum ldlm_match_flags {
 	LDLM_MATCH_GROUP	= BIT(4),
 };
 
+#define extent_last(tree) rb_entry_safe(rb_last(&tree->lit_root.rb_root),\
+					struct ldlm_lock, l_rb)
+#define extent_first(tree) rb_entry_safe(rb_first(&tree->lit_root.rb_root),\
+					 struct ldlm_lock, l_rb)
+#define extent_top(tree) rb_entry_safe(tree->lit_root.rb_root.rb_node, \
+				       struct ldlm_lock, l_rb)
+#define extent_prev(lock) rb_entry_safe(rb_prev(&lock->l_rb),		\
+					struct ldlm_lock, l_rb)
+
 /**
  * Describe the overlap between two locks.  itree_overlap_cb data.
  */
diff --git a/fs/lustre/ldlm/ldlm_extent.c b/fs/lustre/ldlm/ldlm_extent.c
index 15ce512cf10c..489de60822bb 100644
--- a/fs/lustre/ldlm/ldlm_extent.c
+++ b/fs/lustre/ldlm/ldlm_extent.c
@@ -63,7 +63,7 @@
 
 #define START(node) ISTART((node)->l_policy_data.l_extent.end)
 #define LAST(node) IEND((node)->l_policy_data.l_extent.start)
-INTERVAL_TREE_DEFINE(struct ldlm_lock, l_rb, u64, __subtree_last,
+INTERVAL_TREE_DEFINE(struct ldlm_lock, l_rb, u64, l_subtree_last,
 		     START, LAST, static, extent);
 
 /* When a lock is cancelled by a client, the KMS may undergo change if this
@@ -81,7 +81,7 @@ u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms)
 	struct ldlm_lock *lck;
 	u64 kms = 0;
 	int idx = 0;
-	bool complete;
+	bool complete = false;
 
 	/* don't let another thread in ldlm_extent_shift_kms race in
 	 * just after we finish and take our lock into account in its
@@ -90,22 +90,27 @@ u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms)
 	ldlm_set_kms_ignore(lock);
 
 	/* We iterate over the lock trees, looking for the largest kms
-	 * smaller than the current one.  Note that each tree is
-	 * iterated starting a largest end, because the interval tree
-	 * is stored last-to-first order.
+	 * smaller than the current one.
 	 */
 	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
 		tree = &res->lr_itree[idx];
 
-		for (lck = extent_iter_first(&tree->lit_root, 0, U64_MAX);
+		/* If our already known kms is >= than the highest 'end' in
+		 * this tree, we don't need to check this tree, because
+		 * the kms from a tree can be lower than in_max_high (due to
+		 * kms_ignore), but it can never be higher.
+		 */
+		lck = extent_top(tree);
+		if (!lck || kms >= lck->l_subtree_last)
+			continue;
+
+		for (lck = extent_last(tree);
 		     lck;
-		     lck = extent_iter_next(lck, 0, U64_MAX)) {
+		     lck = extent_prev(lck)) {
 			if (ldlm_is_kms_ignore(lck))
 				continue;
 
-			/* This is the last lock-end that doesn't ignore
-			 * kms.
-			 * If it has a greater or equal kms, we are not
+			/* If this lock has a greater or equal kms, we are not
 			 * the highest lock (or we share that distinction
 			 * with another lock), and don't need to update KMS.
 			 * Record old_kms and stop looking.
@@ -114,9 +119,21 @@ u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms)
 			    lck->l_policy_data.l_extent.end + 1 >= old_kms) {
 				kms = old_kms;
 				complete = true;
-			} else
+				break;
+			}
+			if (lck->l_policy_data.l_extent.end + 1 > kms)
 				kms = lck->l_policy_data.l_extent.end + 1;
-			break;
+
+			/* Since we start with the highest lock and work
+			 * down, for PW locks, we only need to check if we
+			 * should update the kms, then stop walking the tree.
+			 * PR locks are not exclusive, so the highest start
+			 * does not imply the highest end and we must
+			 * continue.  (Only one group lock is allowed per
+			 * resource, so this is irrelevant for group locks.)
+			 */
+			if (lck->l_granted_mode == LCK_PW)
+				break;
 		}
 
 		/* this tells us we're not the highest lock, so we don't need
@@ -126,8 +143,7 @@ u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms)
 			break;
 	}
 
-	LASSERTF(kms <= old_kms, "kms %llu old_kms %llu\n", kms,
-		 old_kms);
+	LASSERTF(kms <= old_kms, "kms %llu old_kms %llu\n", kms, old_kms);
 
 	return kms;
 }
@@ -204,8 +220,11 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 	LASSERT(lock->l_granted_mode == BIT(idx));
 	tree = &res->lr_itree[idx];
 
+	LASSERT(!RB_EMPTY_ROOT(&tree->lit_root.rb_root));
+
 	tree->lit_size--;
 	extent_remove(lock, &tree->lit_root);
+	RB_CLEAR_NODE(&lock->l_rb);
 }
 
 void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 5fcae3864483..739798bd95d9 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -182,8 +182,6 @@ void ldlm_lock_put(struct ldlm_lock *lock)
 		lprocfs_counter_decr(ldlm_res_to_ns(res)->ns_stats,
 				     LDLM_NSS_LOCKS);
 		lu_ref_del(&res->lr_reference, "lock", lock);
-		ldlm_resource_putref(res);
-		lock->l_resource = NULL;
 		if (lock->l_export) {
 			class_export_lock_put(lock->l_export, lock);
 			lock->l_export = NULL;
@@ -191,6 +189,8 @@ void ldlm_lock_put(struct ldlm_lock *lock)
 
 		kvfree(lock->l_lvb_data);
 
+		ldlm_resource_putref(res);
+		lock->l_resource = NULL;
 		lu_ref_fini(&lock->l_reference);
 		call_rcu(&lock->l_handle.h_rcu, lock_handle_free);
 	}
@@ -399,6 +399,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	lock->l_blocking_lock = NULL;
 	INIT_LIST_HEAD(&lock->l_sl_mode);
 	INIT_LIST_HEAD(&lock->l_sl_policy);
+	/* LDLM_EXTENT */
 	RB_CLEAR_NODE(&lock->l_rb);
 
 	lprocfs_counter_incr(ldlm_res_to_ns(resource)->ns_stats,
@@ -1042,6 +1043,8 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
  *
  * @lock	test-against this lock
  * @data	parameters
+ *
+ * RETURN	returns true if @lock matches @data, false otherwise
  */
 static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 {
@@ -1052,15 +1055,13 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 	if (lock == data->lmd_old)
 		return true;
 
-	/*
-	 * Check if this lock can be matched.
+	/* Check if this lock can be matched.
 	 * Used by LU-2919(exclusive open) for open lease lock
 	 */
 	if (ldlm_is_excl(lock))
 		return false;
 
-	/*
-	 * llite sometimes wants to match locks that will be
+	/* llite sometimes wants to match locks that will be
 	 * canceled when their users drop, but we allow it to match
 	 * if it passes in CBPENDING and the lock still has users.
 	 * this is generally only going to be used by children
@@ -1106,10 +1107,7 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 			return false;
 		break;
 	case LDLM_IBITS:
-		/*
-		 * We match if we have existing lock with same or wider set
-		 * of bits.
-		 */
+		/* We match with existing lock with same or wider set of bits. */
 		if ((lpol->l_inodebits.bits &
 		     data->lmd_policy->l_inodebits.bits) !=
 		    data->lmd_policy->l_inodebits.bits)
@@ -1124,10 +1122,8 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 	default:
 		break;
 	}
-	/*
-	 * We match if we have existing lock with same or wider set
-	 * of bits.
-	 */
+
+	/* We match if we have existing lock with same or wider set of bits. */
 	if (!(data->lmd_match & LDLM_MATCH_UNREF) && LDLM_HAVE_MASK(lock, GONE))
 		return false;
 
@@ -1168,16 +1164,13 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 struct ldlm_lock *search_itree(struct ldlm_resource *res,
 			       struct ldlm_match_data *data)
 {
-	struct ldlm_extent ext = {
-		.start	= data->lmd_policy->l_extent.start,
-		.end	= data->lmd_policy->l_extent.end
-	};
+	u64 end = data->lmd_policy->l_extent.end;
 	int idx;
 
 	data->lmd_lock = NULL;
 
 	if (data->lmd_match & LDLM_MATCH_RIGHT)
-		ext.end = OBD_OBJECT_EOF;
+		end = OBD_OBJECT_EOF;
 
 	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
 		struct ldlm_interval_tree *tree = &res->lr_itree[idx];
@@ -1188,7 +1181,9 @@ struct ldlm_lock *search_itree(struct ldlm_resource *res,
 		if (!(tree->lit_mode & *data->lmd_mode))
 			continue;
 
-		ldlm_extent_search(&tree->lit_root, ext.start, ext.end,
+		ldlm_extent_search(&tree->lit_root,
+				   data->lmd_policy->l_extent.start,
+				   end,
 				   lock_matches, data);
 		if (data->lmd_lock)
 			return data->lmd_lock;
@@ -1557,7 +1552,7 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 {
 	struct ldlm_lock *lock;
 	struct ldlm_resource *res;
-	int rc;
+	int rc = 0;
 
 	res = ldlm_resource_get(ns, res_id, type, 1);
 	if (IS_ERR(res))
@@ -1603,11 +1598,13 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 
 /**
  * Enqueue (request) a lock.
- * On the client this is called from ldlm_cli_enqueue_fini
- * after we already got an initial reply from the server with some status.
  *
  * Does not block. As a result of enqueue the lock would be put
  * into granted or waiting list.
+ *
+ * If namespace has intent policy sent and the lock has LDLM_FL_HAS_INTENT flag
+ * set, skip all the enqueueing and delegate lock processing to intent policy
+ * function.
  */
 enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
 				  struct ldlm_namespace *ns,
@@ -1616,6 +1613,7 @@ enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
 {
 	struct ldlm_lock *lock = *lockp;
 	struct ldlm_resource *res;
+	enum ldlm_error rc = ELDLM_OK;
 
 	res = lock_res_and_lock(lock);
 	if (ldlm_is_granted(lock)) {
@@ -1637,8 +1635,7 @@ enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
 	if (*flags & LDLM_FL_TEST_LOCK)
 		ldlm_set_test_lock(lock);
 
-	/*
-	 * This distinction between local lock trees is very important; a client
+	/* This distinction between local lock trees is very important; a client
 	 * namespace only has information about locks taken by that client, and
 	 * thus doesn't have enough information to decide for itself if it can
 	 * be granted (below).  In this case, we do exactly what the server
@@ -1651,7 +1648,7 @@ enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
 
 out:
 	unlock_res_and_lock(lock);
-	return ELDLM_OK;
+	return rc;
 }
 
 /**
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index a839ff2177d1..46ab61e78231 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -1283,17 +1283,18 @@ int ldlm_init(void)
 						    0, SLAB_HWCACHE_ALIGN,
 						    NULL);
 	if (!ldlm_interval_tree_slab)
-		goto out_lock;
+		goto out_lock_slab;
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 	class_export_dump_hook = ldlm_dump_export_locks;
 #endif
 	return 0;
 
-out_lock:
+out_lock_slab:
 	kmem_cache_destroy(ldlm_lock_slab);
 out_resource:
 	kmem_cache_destroy(ldlm_resource_slab);
+
 	return -ENOMEM;
 }
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
