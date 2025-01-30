Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 81D56C0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:28:39 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLdH5NnTz214p;
	Thu, 30 Jan 2025 06:14:59 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYv582Xz1xhB
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:12:03 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0A82318236A;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 083D5106BE17; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:01 -0500
Message-ID: <20250130141115.950749-12-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 11/25] lustre: nrs: change nrs policies at
 run time
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
Cc: Feng Lei <flei@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Etienne AUJAMES <eaujames@ddn.com>

This patch take extra references on policy to avoid stop a NRS policy
with pending/queued request in it.

It uses a new refcount_t "pol_start_ref" for this purpose to keep
track of policy usage in started state. It enables to safely stop a
policy without "nrs_lock" and avoids to sleep in the spinlock.

It adds a wait queue field "pol_wq" in "struct ptlrpc_nrs_policy" to
wait all queued request in a stopping policy to be drained when
restarting policy with a different argument.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14976
Lustre-commit: c098c09564a125dd4 ("LU-14976 nrs: change nrs policies at run time")
Signed-off-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48523
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Feng Lei <flei@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_nrs.h |  12 ++-
 fs/lustre/ptlrpc/nrs.c         | 166 ++++++++++++++++++++++-----------
 fs/lustre/ptlrpc/nrs_delay.c   |   3 +-
 fs/lustre/ptlrpc/nrs_fifo.c    |   2 +-
 4 files changed, 128 insertions(+), 55 deletions(-)

diff --git a/fs/lustre/include/lustre_nrs.h b/fs/lustre/include/lustre_nrs.h
index 0e0dd73cadac..bca6b76aa699 100644
--- a/fs/lustre/include/lustre_nrs.h
+++ b/fs/lustre/include/lustre_nrs.h
@@ -100,10 +100,12 @@ struct ptlrpc_nrs_pol_ops {
 	 * initialize their resources here; this operation is optional.
 	 *
 	 * @policy:	The policy being started
+	 * @arg:	A generic char buffer
 	 *
 	 * \see nrs_policy_start_locked()
 	 */
-	int	(*op_policy_start)(struct ptlrpc_nrs_policy *policy);
+	int	(*op_policy_start)(struct ptlrpc_nrs_policy *policy,
+				   char *arg);
 	/**
 	 * Called when deactivating a policy via lprocfs; policies deallocate
 	 * their resources here; this operation is optional
@@ -616,6 +618,10 @@ struct ptlrpc_nrs_policy {
 	 * Usage Reference count taken on the policy instance
 	 */
 	long				pol_ref;
+	/**
+	 * Usage Reference count taken for a started policy
+	 */
+	refcount_t			pol_start_ref;
 	/**
 	 * Human-readable policy argument
 	 */
@@ -632,6 +638,10 @@ struct ptlrpc_nrs_policy {
 	 * Policy descriptor for this policy instance.
 	 */
 	struct ptlrpc_nrs_pol_desc     *pol_desc;
+	/**
+	 * Policy wait queue
+	 */
+	wait_queue_head_t		pol_wq;
 };
 
 /**
diff --git a/fs/lustre/ptlrpc/nrs.c b/fs/lustre/ptlrpc/nrs.c
index dd36d182d11e..661bba7a0f06 100644
--- a/fs/lustre/ptlrpc/nrs.c
+++ b/fs/lustre/ptlrpc/nrs.c
@@ -59,6 +59,7 @@ static int nrs_policy_init(struct ptlrpc_nrs_policy *policy)
 static void nrs_policy_fini(struct ptlrpc_nrs_policy *policy)
 {
 	LASSERT(policy->pol_ref == 0);
+	LASSERT(refcount_read(&policy->pol_start_ref) == 0);
 	LASSERT(policy->pol_req_queued == 0);
 
 	if (policy->pol_desc->pd_ops->op_policy_fini)
@@ -92,13 +93,35 @@ static void __nrs_policy_stop(struct ptlrpc_nrs_policy *policy)
 		policy->pol_req_started == 0);
 
 	policy->pol_private = NULL;
+	policy->pol_arg[0] = '\0';
 
 	policy->pol_state = NRS_POL_STATE_STOPPED;
+	wake_up(&policy->pol_wq);
 
 	if (atomic_dec_and_test(&policy->pol_desc->pd_refs))
 		module_put(policy->pol_desc->pd_owner);
 }
 
+/**
+ * Increases the policy's usage started reference count.
+ */
+static inline void nrs_policy_started_get(struct ptlrpc_nrs_policy *policy)
+{
+	refcount_inc(&policy->pol_start_ref);
+}
+
+/**
+ * Decreases the policy's usage started reference count, and stops the policy
+ * in case it was already stopping and have no more outstanding usage
+ * references (which indicates it has no more queued or started requests, and
+ * can be safely stopped).
+ */
+static void nrs_policy_started_put(struct ptlrpc_nrs_policy *policy)
+{
+	if (refcount_dec_and_test(&policy->pol_start_ref))
+		__nrs_policy_stop(policy);
+}
+
 static int nrs_policy_stop_locked(struct ptlrpc_nrs_policy *policy)
 {
 	struct ptlrpc_nrs *nrs = policy->pol_nrs;
@@ -123,9 +146,18 @@ static int nrs_policy_stop_locked(struct ptlrpc_nrs_policy *policy)
 		nrs->nrs_policy_fallback = NULL;
 	}
 
-	/* I have the only refcount */
-	if (policy->pol_ref == 1)
-		__nrs_policy_stop(policy);
+	/* Drop started ref and wait for requests to be drained */
+	spin_unlock(&nrs->nrs_lock);
+	nrs_policy_started_put(policy);
+
+	wait_event_timeout(policy->pol_wq,
+			   policy->pol_state == NRS_POL_STATE_STOPPED,
+			   30 * HZ);
+
+	spin_lock(&nrs->nrs_lock);
+
+	if (policy->pol_state != NRS_POL_STATE_STOPPED)
+		return -EBUSY;
 
 	return 0;
 }
@@ -149,8 +181,10 @@ static void nrs_policy_stop_primary(struct ptlrpc_nrs *nrs)
 	LASSERT(tmp->pol_state == NRS_POL_STATE_STARTED);
 	tmp->pol_state = NRS_POL_STATE_STOPPING;
 
-	if (tmp->pol_ref == 0)
-		__nrs_policy_stop(tmp);
+	/* Drop started ref to free the policy */
+	spin_unlock(&nrs->nrs_lock);
+	nrs_policy_started_put(tmp);
+	spin_lock(&nrs->nrs_lock);
 }
 
 /**
@@ -172,7 +206,7 @@ static void nrs_policy_stop_primary(struct ptlrpc_nrs *nrs)
  * references on the policy to ptlrpc_nrs_pol_stae::NRS_POL_STATE_STOPPED. In
  * this case, the fallback policy is only left active in the NRS head.
  */
-static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy)
+static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy, char *arg)
 {
 	struct ptlrpc_nrs *nrs = policy->pol_nrs;
 	int rc = 0;
@@ -189,6 +223,11 @@ static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy)
 	if (policy->pol_state == NRS_POL_STATE_STOPPING)
 		return -EAGAIN;
 
+	if (arg && strlen(arg) >= sizeof(policy->pol_arg)) {
+		CWARN("NRS: arg '%s' is too long\n", arg);
+		return -EINVAL;
+	}
+
 	if (policy->pol_flags & PTLRPC_NRS_FL_FALLBACK) {
 		/**
 		 * This is for cases in which the user sets the policy to the
@@ -215,8 +254,20 @@ static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy)
 		if (!nrs->nrs_policy_fallback)
 			return -EPERM;
 
-		if (policy->pol_state == NRS_POL_STATE_STARTED)
-			return 0;
+		if (policy->pol_state == NRS_POL_STATE_STARTED) {
+			/**
+			 * If the policy argument now is different from the last time,
+			 * stop the policy first and start it again with the new
+			 * argument.
+			 */
+			if ((!arg && strlen(policy->pol_arg) == 0) ||
+			    (arg && strcmp(policy->pol_arg, arg) == 0))
+				return 0;
+
+			rc = nrs_policy_stop_locked(policy);
+			if (rc)
+				return rc;
+		}
 	}
 
 	/**
@@ -241,7 +292,7 @@ static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy)
 	if (policy->pol_desc->pd_ops->op_policy_start) {
 		spin_unlock(&nrs->nrs_lock);
 
-		rc = policy->pol_desc->pd_ops->op_policy_start(policy);
+		rc = policy->pol_desc->pd_ops->op_policy_start(policy, arg);
 
 		spin_lock(&nrs->nrs_lock);
 		if (rc != 0) {
@@ -253,6 +304,11 @@ static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy)
 		}
 	}
 
+	if (arg)
+		strlcpy(policy->pol_arg, arg, sizeof(policy->pol_arg));
+
+	/* take the started reference */
+	refcount_set(&policy->pol_start_ref, 1);
 	policy->pol_state = NRS_POL_STATE_STARTED;
 
 	if (policy->pol_flags & PTLRPC_NRS_FL_FALLBACK) {
@@ -279,34 +335,23 @@ static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy)
 }
 
 /**
- * Increases the policy's usage reference count.
+ * Increases the policy's usage reference count (caller count).
  */
 static inline void nrs_policy_get_locked(struct ptlrpc_nrs_policy *policy)
+__must_hold(&policy->pol_nrs->nrs_lock)
 {
 	policy->pol_ref++;
 }
 
 /**
- * Decreases the policy's usage reference count, and stops the policy in case it
- * was already stopping and have no more outstanding usage references (which
- * indicates it has no more queued or started requests, and can be safely
- * stopped).
+ * Decreases the policy's usage reference count.
  */
 static void nrs_policy_put_locked(struct ptlrpc_nrs_policy *policy)
+__must_hold(&policy->pol_nrs->nrs_lock)
 {
 	LASSERT(policy->pol_ref > 0);
 
 	policy->pol_ref--;
-	if (unlikely(policy->pol_ref == 0 &&
-		     policy->pol_state == NRS_POL_STATE_STOPPING))
-		__nrs_policy_stop(policy);
-}
-
-static void nrs_policy_put(struct ptlrpc_nrs_policy *policy)
-{
-	spin_lock(&policy->pol_nrs->nrs_lock);
-	nrs_policy_put_locked(policy);
-	spin_unlock(&policy->pol_nrs->nrs_lock);
 }
 
 /**
@@ -428,11 +473,11 @@ static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
 	spin_lock(&nrs->nrs_lock);
 
 	fallback = nrs->nrs_policy_fallback;
-	nrs_policy_get_locked(fallback);
+	nrs_policy_started_get(fallback);
 
 	primary = nrs->nrs_policy_primary;
 	if (primary)
-		nrs_policy_get_locked(primary);
+		nrs_policy_started_get(primary);
 
 	spin_unlock(&nrs->nrs_lock);
 
@@ -452,7 +497,7 @@ static void nrs_resource_get_safe(struct ptlrpc_nrs *nrs,
 		 * request.
 		 */
 		if (!resp[NRS_RES_PRIMARY])
-			nrs_policy_put(primary);
+			nrs_policy_started_put(primary);
 	}
 }
 
@@ -481,8 +526,10 @@ static void nrs_resource_put_safe(struct ptlrpc_nrs_resource **resp)
 	}
 
 	for (i = 0; i < NRS_RES_MAX; i++) {
-		if (pols[i])
-			nrs_policy_put(pols[i]);
+		if (!pols[i])
+			continue;
+
+		nrs_policy_started_put(pols[i]);
 	}
 }
 
@@ -510,6 +557,10 @@ struct ptlrpc_nrs_request *nrs_request_get(struct ptlrpc_nrs_policy *policy,
 
 	LASSERT(policy->pol_req_queued > 0);
 
+	/* for a non-started policy, use force mode to drain requests */
+	if (unlikely(policy->pol_state != NRS_POL_STATE_STARTED))
+		force = true;
+
 	nrq = policy->pol_desc->pd_ops->op_req_get(policy, peek, force);
 
 	LASSERT(ergo(nrq, nrs_request_policy(nrq) == policy));
@@ -548,6 +599,11 @@ static inline void nrs_request_enqueue(struct ptlrpc_nrs_request *nrq)
 		if (rc == 0) {
 			policy->pol_nrs->nrs_req_queued++;
 			policy->pol_req_queued++;
+			/**
+			 * Take an extra ref to avoid stopping policy with
+			 * pending request in it
+			 */
+			nrs_policy_started_get(policy);
 			return;
 		}
 	}
@@ -632,7 +688,7 @@ static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 		 * Start \e policy
 		 */
 	case PTLRPC_NRS_CTL_START:
-		rc = nrs_policy_start_locked(policy);
+		rc = nrs_policy_start_locked(policy, arg);
 		break;
 	}
 out:
@@ -657,47 +713,50 @@ static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 static int nrs_policy_unregister(struct ptlrpc_nrs *nrs, char *name)
 {
 	struct ptlrpc_nrs_policy *policy = NULL;
+	int rc = 0;
 
 	spin_lock(&nrs->nrs_lock);
 
 	policy = nrs_policy_find_locked(nrs, name);
 	if (!policy) {
-		spin_unlock(&nrs->nrs_lock);
-
-		CERROR("Can't find NRS policy %s\n", name);
-		return -ENOENT;
+		rc = -ENOENT;
+		CERROR("NRS: cannot find policy '%s': rc = %d\n", name, rc);
+		goto out_unlock;
 	}
 
 	if (policy->pol_ref > 1) {
-		CERROR("Policy %s is busy with %d references\n", name,
-		       (int)policy->pol_ref);
-		nrs_policy_put_locked(policy);
-
-		spin_unlock(&nrs->nrs_lock);
-		return -EBUSY;
+		rc = -EBUSY;
+		CERROR("NRS: policy '%s' is busy with %ld references: rc = %d",
+		       name, policy->pol_ref, rc);
+		goto out_put;
 	}
 
 	LASSERT(policy->pol_req_queued == 0);
 	LASSERT(policy->pol_req_started == 0);
 
 	if (policy->pol_state != NRS_POL_STATE_STOPPED) {
-		nrs_policy_stop_locked(policy);
-		LASSERT(policy->pol_state == NRS_POL_STATE_STOPPED);
+		rc = nrs_policy_stop_locked(policy);
+		if (rc) {
+			CERROR("NRS: failed to stop policy '%s' with refcount %d: rc = %d\n",
+			       name, refcount_read(&policy->pol_start_ref), rc);
+			goto out_put;
+		}
 	}
 
+	LASSERT(!policy->pol_private);
 	list_del(&policy->pol_list);
 	nrs->nrs_num_pols--;
-
+out_put:
 	nrs_policy_put_locked(policy);
-
+out_unlock:
 	spin_unlock(&nrs->nrs_lock);
 
-	nrs_policy_fini(policy);
-
-	LASSERT(!policy->pol_private);
-	kfree(policy);
+	if (rc == 0) {
+		nrs_policy_fini(policy);
+		kfree(policy);
+	}
 
-	return 0;
+	return rc;
 }
 
 /**
@@ -738,6 +797,8 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 	INIT_LIST_HEAD(&policy->pol_list);
 	INIT_LIST_HEAD(&policy->pol_list_queued);
 
+	init_waitqueue_head(&policy->pol_wq);
+
 	rc = nrs_policy_init(policy);
 	if (rc != 0) {
 		kfree(policy);
@@ -764,7 +825,7 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 	nrs->nrs_num_pols++;
 
 	if (policy->pol_flags & PTLRPC_NRS_FL_REG_START)
-		rc = nrs_policy_start_locked(policy);
+		rc = nrs_policy_start_locked(policy, NULL);
 
 	spin_unlock(&nrs->nrs_lock);
 
@@ -1425,6 +1486,9 @@ static void nrs_request_removed(struct ptlrpc_nrs_policy *policy)
 		list_move_tail(&policy->pol_list_queued,
 			       &policy->pol_nrs->nrs_policy_queued);
 	}
+
+	/* remove the extra ref for policy pending requests */
+	nrs_policy_started_put(policy);
 }
 
 /**
@@ -1613,5 +1677,3 @@ void ptlrpc_nrs_fini(void)
 		kfree(desc);
 	}
 }
-
-/** @} nrs */
diff --git a/fs/lustre/ptlrpc/nrs_delay.c b/fs/lustre/ptlrpc/nrs_delay.c
index b249749d010a..0ca6ad1481b2 100644
--- a/fs/lustre/ptlrpc/nrs_delay.c
+++ b/fs/lustre/ptlrpc/nrs_delay.c
@@ -102,6 +102,7 @@ static struct binheap_ops nrs_delay_heap_ops = {
  * the delay-specific private data structure.
  *
  * @policy	The policy to start
+ * @arg		Generic char buffer; unused in this policy
  *
  * Return:	-ENOMEM OOM error
  *		0 success
@@ -109,7 +110,7 @@ static struct binheap_ops nrs_delay_heap_ops = {
  * \see nrs_policy_register()
  * \see nrs_policy_ctl()
  */
-static int nrs_delay_start(struct ptlrpc_nrs_policy *policy)
+static int nrs_delay_start(struct ptlrpc_nrs_policy *policy, char *arg)
 {
 	struct nrs_delay_data *delay_data;
 
diff --git a/fs/lustre/ptlrpc/nrs_fifo.c b/fs/lustre/ptlrpc/nrs_fifo.c
index 1689616e3949..227fe5ed11e5 100644
--- a/fs/lustre/ptlrpc/nrs_fifo.c
+++ b/fs/lustre/ptlrpc/nrs_fifo.c
@@ -74,7 +74,7 @@
  * \see nrs_policy_register()
  * \see nrs_policy_ctl()
  */
-static int nrs_fifo_start(struct ptlrpc_nrs_policy *policy)
+static int nrs_fifo_start(struct ptlrpc_nrs_policy *policy, char *arg)
 {
 	struct nrs_fifo_head *head;
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
