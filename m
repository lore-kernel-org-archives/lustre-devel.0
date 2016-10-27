From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:53 -0400
Subject: [lustre-devel] [PATCH 19/29] staging: lustre: ldlm: reclaim granted
	locks defensively
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

It was discovered that to many ldlm locks where being
created on the server side to the point of memory
exhaustion. The work of LU-6529 introduced watermarks
to avoid this memory exhaustion. This is the client
side part of this work for the upstream client.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6529
Reviewed-on: http://review.whamcloud.com/14931
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6929
Reviewed-on: http://review.whamcloud.com/15813
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    2 +-
 drivers/staging/lustre/lnet/libcfs/hash.c          |   24 +++++++++++++++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    8 ++++--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   15 ++++--------
 5 files changed, 31 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 6949a18..f2b4399 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -705,7 +705,7 @@ typedef int (*cfs_hash_for_each_cb_t)(struct cfs_hash *hs,
 cfs_hash_for_each_safe(struct cfs_hash *hs, cfs_hash_for_each_cb_t, void *data);
 int
 cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t,
-			 void *data);
+			 void *data, int start);
 int
 cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t,
 			void *data);
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 23283b6..997b8a5 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -1552,7 +1552,7 @@ struct cfs_hash_cond_arg {
  */
 static int
 cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-			void *data)
+			void *data, int start)
 {
 	struct hlist_node *hnode;
 	struct hlist_node *tmp;
@@ -1560,18 +1560,25 @@ struct cfs_hash_cond_arg {
 	__u32 version;
 	int count = 0;
 	int stop_on_change;
-	int rc;
+	int end = -1;
+	int rc = 0;
 	int i;
 
 	stop_on_change = cfs_hash_with_rehash_key(hs) ||
 			 !cfs_hash_with_no_itemref(hs) ||
 			 !hs->hs_ops->hs_put_locked;
 	cfs_hash_lock(hs, 0);
+again:
 	LASSERT(!cfs_hash_is_rehashing(hs));
 
 	cfs_hash_for_each_bucket(hs, &bd, i) {
 		struct hlist_head *hhead;
 
+		if (i < start)
+			continue;
+		else if (end > 0 && i >= end)
+			break;
+
 		cfs_hash_bd_lock(hs, &bd, 0);
 		version = cfs_hash_bd_version_get(&bd);
 
@@ -1611,14 +1618,19 @@ struct cfs_hash_cond_arg {
 		if (rc) /* callback wants to break iteration */
 			break;
 	}
-	cfs_hash_unlock(hs, 0);
+	if (start > 0 && !rc) {
+		end = start;
+		start = 0;
+		goto again;
+	}
 
+	cfs_hash_unlock(hs, 0);
 	return count;
 }
 
 int
 cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-			 void *data)
+			 void *data, int start)
 {
 	if (cfs_hash_with_no_lock(hs) ||
 	    cfs_hash_with_rehash_key(hs) ||
@@ -1630,7 +1642,7 @@ struct cfs_hash_cond_arg {
 		return -EOPNOTSUPP;
 
 	cfs_hash_for_each_enter(hs);
-	cfs_hash_for_each_relax(hs, func, data);
+	cfs_hash_for_each_relax(hs, func, data, start);
 	cfs_hash_for_each_exit(hs);
 
 	return 0;
@@ -1662,7 +1674,7 @@ struct cfs_hash_cond_arg {
 		return -EOPNOTSUPP;
 
 	cfs_hash_for_each_enter(hs);
-	while (cfs_hash_for_each_relax(hs, func, data)) {
+	while (cfs_hash_for_each_relax(hs, func, data, 0)) {
 		CDEBUG(D_INFO, "Try to empty hash: %s, loop: %u\n",
 		       hs->hs_name, i++);
 	}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index ac1927c..43856ff 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1729,7 +1729,7 @@ int ldlm_cli_cancel_unused(struct ldlm_namespace *ns,
 						       opaque);
 	} else {
 		cfs_hash_for_each_nolock(ns->ns_rs_hash,
-					 ldlm_cli_hash_cancel_unused, &arg);
+					 ldlm_cli_hash_cancel_unused, &arg, 0);
 		return ELDLM_OK;
 	}
 }
@@ -1802,7 +1802,7 @@ static void ldlm_namespace_foreach(struct ldlm_namespace *ns,
 	};
 
 	cfs_hash_for_each_nolock(ns->ns_rs_hash,
-				 ldlm_res_iter_helper, &helper);
+				 ldlm_res_iter_helper, &helper, 0);
 }
 
 /* non-blocking function to manipulate a lock whose cb_data is being put away.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 07cb955..c452400 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -855,8 +855,10 @@ int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags)
 		return ELDLM_OK;
 	}
 
-	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_clean, &flags);
-	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_complain, NULL);
+	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_clean,
+				 &flags, 0);
+	cfs_hash_for_each_nolock(ns->ns_rs_hash, ldlm_resource_complain,
+				 NULL, 0);
 	return ELDLM_OK;
 }
 EXPORT_SYMBOL(ldlm_namespace_cleanup);
@@ -1352,7 +1354,7 @@ void ldlm_namespace_dump(int level, struct ldlm_namespace *ns)
 
 	cfs_hash_for_each_nolock(ns->ns_rs_hash,
 				 ldlm_res_hash_dump,
-				 (void *)(unsigned long)level);
+				 (void *)(unsigned long)level, 0);
 	spin_lock(&ns->ns_lock);
 	ns->ns_next_dump = cfs_time_shift(10);
 	spin_unlock(&ns->ns_lock);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 9bc5314..42a128f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -760,12 +760,6 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
-	if (req && it && it->it_op & IT_CREAT)
-		/* ask ptlrpc not to resend on EINPROGRESS since we have our own
-		 * retry logic
-		 */
-		req->rq_no_retry_einprogress = 1;
-
 	if (resends) {
 		req->rq_generation_set = 1;
 		req->rq_import_generation = generation;
@@ -824,11 +818,12 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	lockrep->lock_policy_res2 =
 		ptlrpc_status_ntoh(lockrep->lock_policy_res2);
 
-	/* Retry the create infinitely when we get -EINPROGRESS from
-	 * server. This is required by the new quota design.
+	/*
+	 * Retry infinitely when the server returns -EINPROGRESS for the
+	 * intent operation, when server returns -EINPROGRESS for acquiring
+	 * intent lock, we'll retry in after_reply().
 	 */
-	if (it->it_op & IT_CREAT &&
-	    (int)lockrep->lock_policy_res2 == -EINPROGRESS) {
+	if (it->it_op && (int)lockrep->lock_policy_res2 == -EINPROGRESS) {
 		mdc_clear_replay_flag(req, rc);
 		ptlrpc_req_finished(req);
 		resends++;
-- 
1.7.1
