Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 624F9C07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:30 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 18A676112D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18A676112D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AC6CB34F9C6;
	Mon, 19 Jul 2021 05:32:24 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 94F3934F962
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:17 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8D39E6B7;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8532DBD1CB; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:31:57 -0400
Message-Id: <1626697933-6971-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/18] lustre: llite: simplify callback
 handling for async getattr
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

In this patch, it prepares the inode and set lock data directly in
the callback interpret of the intent async getattr RPC request (in
ptlrpcd context), simplifies the old impementation that defer this
work in the statahead thread.

According to the benchmark result, the workload "ls -l" to a large
directory on a client without any caching (server and client),
containing 1M files (47001 bytes) shows the results with measured
elapsed time:
  - w/o patch:  180 seconds;
  - w patch:    181 seconds;

There is no any obvious performance regession.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14139
Lustre-commit: cbaaa7cde45f593 ("LU-14139 llite: simplify callback handling for async getattr")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/40712
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h          |  34 ++--
 fs/lustre/include/obd_class.h    |   4 +-
 fs/lustre/llite/llite_internal.h |   7 +-
 fs/lustre/llite/statahead.c      | 343 ++++++++++++++-------------------------
 fs/lustre/lmv/lmv_obd.c          |   6 +-
 fs/lustre/mdc/mdc_internal.h     |   3 +-
 fs/lustre/mdc/mdc_locks.c        |  31 ++--
 7 files changed, 160 insertions(+), 268 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 86d7839..eeb6262 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -818,18 +818,24 @@ struct md_callback {
 			       void *data, int flag);
 };
 
-struct md_enqueue_info;
-/* metadata stat-ahead */
-
-struct md_enqueue_info {
-	struct md_op_data		mi_data;
-	struct lookup_intent		mi_it;
-	struct lustre_handle		mi_lockh;
-	struct inode		       *mi_dir;
-	struct ldlm_enqueue_info	mi_einfo;
-	int (*mi_cb)(struct ptlrpc_request *req,
-		     struct md_enqueue_info *minfo, int rc);
-	void			       *mi_cbdata;
+enum md_opcode {
+	MD_OP_NONE	= 0,
+	MD_OP_GETATTR	= 1,
+	MD_OP_MAX,
+};
+
+struct md_op_item {
+	enum md_opcode			mop_opc;
+	struct md_op_data		mop_data;
+	struct lookup_intent		mop_it;
+	struct lustre_handle		mop_lockh;
+	struct ldlm_enqueue_info	mop_einfo;
+	int (*mop_cb)(struct req_capsule *pill,
+		      struct md_op_item *item,
+		      int rc);
+	void			       *mop_cbdata;
+	struct inode		       *mop_dir;
+	u64				mop_lock_flags;
 };
 
 struct obd_ops {
@@ -1060,8 +1066,8 @@ struct md_ops {
 				const char *name, int namelen,
 				struct lu_fid *fid);
 
-	int (*intent_getattr_async)(struct obd_export *,
-				    struct md_enqueue_info *);
+	int (*intent_getattr_async)(struct obd_export *exp,
+				    struct md_op_item *item);
 
 	int (*revalidate_lock)(struct obd_export *, struct lookup_intent *,
 			       struct lu_fid *, u64 *bits);
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index f2a3d2b..ad9b2fc 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1594,7 +1594,7 @@ static inline int md_init_ea_size(struct obd_export *exp, u32 easize,
 }
 
 static inline int md_intent_getattr_async(struct obd_export *exp,
-					  struct md_enqueue_info *minfo)
+					  struct md_op_item *item)
 {
 	int rc;
 
@@ -1605,7 +1605,7 @@ static inline int md_intent_getattr_async(struct obd_export *exp,
 	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
 			     LPROC_MD_INTENT_GETATTR_ASYNC);
 
-	return MDP(exp->exp_obd, intent_getattr_async)(exp, minfo);
+	return MDP(exp->exp_obd, intent_getattr_async)(exp, item);
 }
 
 static inline int md_revalidate_lock(struct obd_export *exp,
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index a073d6d..1d5255e 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1477,17 +1477,12 @@ struct ll_statahead_info {
 					     * is not a hidden one
 					     */
 	unsigned int	    sai_skip_hidden;/* skipped hidden dentry count */
-	unsigned int	    sai_ls_all:1,   /* "ls -al", do stat-ahead for
+	unsigned int	    sai_ls_all:1;   /* "ls -al", do stat-ahead for
 					     * hidden entries
 					     */
-				sai_in_readpage:1;/* statahead in readdir() */
 	wait_queue_head_t	sai_waitq;      /* stat-ahead wait queue */
 	struct task_struct     *sai_task;       /* stat-ahead thread */
 	struct task_struct     *sai_agl_task;   /* AGL thread */
-	struct list_head	sai_interim_entries; /* entries which got async
-						      * stat reply, but not
-						      * instantiated
-						      */
 	struct list_head	sai_entries;	/* completed entries */
 	struct list_head	sai_agls;	/* AGLs to be sent */
 	struct list_head	sai_cache[LL_SA_CACHE_SIZE];
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 40ea206..becd0e1 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -55,13 +55,12 @@ enum se_stat {
 
 /*
  * sa_entry is not refcounted: statahead thread allocates it and do async stat,
- * and in async stat callback ll_statahead_interpret() will add it into
- * sai_interim_entries, later statahead thread will call sa_handle_callback() to
- * instantiate entry and move it into sai_entries, and then only scanner process
- * can access and free it.
+ * and in async stat callback ll_statahead_interpret() will prepare the inode
+ * and set lock data in the ptlrpcd context. Then the scanner process will be
+ * woken up if this entry is the waiting one, can access and free it.
  */
 struct sa_entry {
-	/* link into sai_interim_entries or sai_entries */
+	/* link into sai_entries */
 	struct list_head	se_list;
 	/* link into sai hash table locally */
 	struct list_head	se_hash;
@@ -73,10 +72,6 @@ struct sa_entry {
 	enum se_stat		se_state;
 	/* entry size, contains name */
 	int			se_size;
-	/* pointer to async getattr enqueue info */
-	struct md_enqueue_info	*se_minfo;
-	/* pointer to the async getattr request */
-	struct ptlrpc_request	*se_req;
 	/* pointer to the target inode */
 	struct inode		*se_inode;
 	/* entry name */
@@ -113,9 +108,7 @@ static inline int sa_hash(int val)
 	spin_unlock(&sai->sai_cache_lock[i]);
 }
 
-/*
- * Remove entry from SA table.
- */
+/* unhash entry from sai_cache */
 static inline void
 sa_unhash(struct ll_statahead_info *sai, struct sa_entry *entry)
 {
@@ -138,12 +131,6 @@ static inline int sa_sent_full(struct ll_statahead_info *sai)
 	return atomic_read(&sai->sai_cache_count) >= sai->sai_max;
 }
 
-/* got async stat replies */
-static inline int sa_has_callback(struct ll_statahead_info *sai)
-{
-	return !list_empty(&sai->sai_interim_entries);
-}
-
 static inline int agl_list_empty(struct ll_statahead_info *sai)
 {
 	return list_empty(&sai->sai_agls);
@@ -267,8 +254,8 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 }
 
 /* called by scanner after use, sa_entry will be killed */
-static void sa_put(struct ll_statahead_info *sai, struct sa_entry *entry,
-		   struct ll_inode_info *lli)
+static void
+sa_put(struct ll_statahead_info *sai, struct sa_entry *entry)
 {
 	struct sa_entry *tmp, *next;
 
@@ -295,11 +282,6 @@ static void sa_put(struct ll_statahead_info *sai, struct sa_entry *entry,
 			break;
 		sa_kill(sai, tmp);
 	}
-
-	spin_lock(&lli->lli_sa_lock);
-	if (sai->sai_task)
-		wake_up_process(sai->sai_task);
-	spin_unlock(&lli->lli_sa_lock);
 }
 
 /*
@@ -334,55 +316,55 @@ static void sa_put(struct ll_statahead_info *sai, struct sa_entry *entry,
 }
 
 /* finish async stat RPC arguments */
-static void sa_fini_data(struct md_enqueue_info *minfo)
+static void sa_fini_data(struct md_op_item *item)
 {
-	ll_unlock_md_op_lsm(&minfo->mi_data);
-	iput(minfo->mi_dir);
-	kfree(minfo);
+	ll_unlock_md_op_lsm(&item->mop_data);
+	iput(item->mop_dir);
+	kfree(item);
 }
 
-static int ll_statahead_interpret(struct ptlrpc_request *req,
-				  struct md_enqueue_info *minfo, int rc);
+static int ll_statahead_interpret(struct req_capsule *pill,
+				  struct md_op_item *item, int rc);
 
 /*
  * prepare arguments for async stat RPC.
  */
-static struct md_enqueue_info *
+static struct md_op_item *
 sa_prep_data(struct inode *dir, struct inode *child, struct sa_entry *entry)
 {
-	struct md_enqueue_info   *minfo;
+	struct md_op_item *item;
 	struct ldlm_enqueue_info *einfo;
-	struct md_op_data        *op_data;
+	struct md_op_data *op_data;
 
-	minfo = kzalloc(sizeof(*minfo), GFP_NOFS);
-	if (!minfo)
+	item = kzalloc(sizeof(*item), GFP_NOFS);
+	if (!item)
 		return ERR_PTR(-ENOMEM);
 
-	op_data = ll_prep_md_op_data(&minfo->mi_data, dir, child,
+	op_data = ll_prep_md_op_data(&item->mop_data, dir, child,
 				     entry->se_qstr.name, entry->se_qstr.len, 0,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data)) {
-		kfree(minfo);
-		return (struct md_enqueue_info *)op_data;
+		kfree(item);
+		return ERR_CAST(item);
 	}
 
 	if (!child)
 		op_data->op_fid2 = entry->se_fid;
 
-	minfo->mi_it.it_op = IT_GETATTR;
-	minfo->mi_dir = igrab(dir);
-	minfo->mi_cb = ll_statahead_interpret;
-	minfo->mi_cbdata = entry;
-
-	einfo = &minfo->mi_einfo;
-	einfo->ei_type   = LDLM_IBITS;
-	einfo->ei_mode   = it_to_lock_mode(&minfo->mi_it);
-	einfo->ei_cb_bl  = ll_md_blocking_ast;
-	einfo->ei_cb_cp  = ldlm_completion_ast;
-	einfo->ei_cb_gl  = NULL;
+	item->mop_it.it_op = IT_GETATTR;
+	item->mop_dir = igrab(dir);
+	item->mop_cb = ll_statahead_interpret;
+	item->mop_cbdata = entry;
+
+	einfo = &item->mop_einfo;
+	einfo->ei_type = LDLM_IBITS;
+	einfo->ei_mode = it_to_lock_mode(&item->mop_it);
+	einfo->ei_cb_bl = ll_md_blocking_ast;
+	einfo->ei_cb_cp = ldlm_completion_ast;
+	einfo->ei_cb_gl = NULL;
 	einfo->ei_cbdata = NULL;
 
-	return minfo;
+	return item;
 }
 
 /*
@@ -393,22 +375,8 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 sa_make_ready(struct ll_statahead_info *sai, struct sa_entry *entry, int ret)
 {
 	struct ll_inode_info *lli = ll_i2info(sai->sai_dentry->d_inode);
-	struct md_enqueue_info *minfo = entry->se_minfo;
-	struct ptlrpc_request *req = entry->se_req;
 	bool wakeup;
 
-	/* release resources used in RPC */
-	if (minfo) {
-		entry->se_minfo = NULL;
-		ll_intent_release(&minfo->mi_it);
-		sa_fini_data(minfo);
-	}
-
-	if (req) {
-		entry->se_req = NULL;
-		ptlrpc_req_finished(req);
-	}
-
 	spin_lock(&lli->lli_sa_lock);
 	wakeup = __sa_make_ready(sai, entry, ret);
 	spin_unlock(&lli->lli_sa_lock);
@@ -465,7 +433,6 @@ static struct ll_statahead_info *ll_sai_alloc(struct dentry *dentry)
 	sai->sai_index = 1;
 	init_waitqueue_head(&sai->sai_waitq);
 
-	INIT_LIST_HEAD(&sai->sai_interim_entries);
 	INIT_LIST_HEAD(&sai->sai_entries);
 	INIT_LIST_HEAD(&sai->sai_agls);
 
@@ -528,7 +495,6 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 		LASSERT(sai->sai_task == NULL);
 		LASSERT(sai->sai_agl_task == NULL);
 		LASSERT(sai->sai_sent == sai->sai_replied);
-		LASSERT(!sa_has_callback(sai));
 
 		list_for_each_entry_safe(entry, next, &sai->sai_entries,
 					 se_list)
@@ -619,26 +585,63 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 }
 
 /*
- * prepare inode for sa entry, add it into agl list, now sa_entry is ready
- * to be used by scanner process.
+ * Callback for async stat RPC, this is called in ptlrpcd context. It prepares
+ * the inode and set lock data directly in the ptlrpcd context. It will wake up
+ * the directory listing process if the dentry is the waiting one.
  */
-static void sa_instantiate(struct ll_statahead_info *sai,
-			   struct sa_entry *entry)
+static int ll_statahead_interpret(struct req_capsule *pill,
+				  struct md_op_item *item, int rc)
 {
-	struct inode *dir = sai->sai_dentry->d_inode;
-	struct inode *child;
-	struct md_enqueue_info *minfo;
-	struct lookup_intent *it;
-	struct ptlrpc_request *req;
+	struct lookup_intent *it = &item->mop_it;
+	struct inode *dir = item->mop_dir;
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct ll_statahead_info *sai = lli->lli_sai;
+	struct sa_entry *entry = (struct sa_entry *)item->mop_cbdata;
 	struct mdt_body	*body;
-	int rc = 0;
+	struct inode *child;
+	u64 handle = 0;
+
+	if (it_disposition(it, DISP_LOOKUP_NEG))
+		rc = -ENOENT;
 
-	LASSERT(entry->se_handle != 0);
+	/*
+	 * because statahead thread will wait for all inflight RPC to finish,
+	 * sai should be always valid, no need to refcount
+	 */
+	LASSERT(sai);
+	LASSERT(entry);
 
-	minfo = entry->se_minfo;
-	it = &minfo->mi_it;
-	req = entry->se_req;
-	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+	CDEBUG(D_READA, "sa_entry %.*s rc %d\n",
+	       entry->se_qstr.len, entry->se_qstr.name, rc);
+
+	if (rc != 0) {
+		ll_intent_release(it);
+		sa_fini_data(item);
+	} else {
+		/*
+		 * release ibits lock ASAP to avoid deadlock when statahead
+		 * thread enqueues lock on parent in readdir and another
+		 * process enqueues lock on child with parent lock held, eg.
+		 * unlink.
+		 */
+		handle = it->it_lock_handle;
+		ll_intent_drop_lock(it);
+		ll_unlock_md_op_lsm(&item->mop_data);
+	}
+
+	if (rc != 0) {
+		spin_lock(&lli->lli_sa_lock);
+		if (__sa_make_ready(sai, entry, rc))
+			wake_up(&sai->sai_waitq);
+
+		sai->sai_replied++;
+		spin_unlock(&lli->lli_sa_lock);
+
+		return rc;
+	}
+
+	entry->se_handle = handle;
+	body = req_capsule_server_get(pill, &RMF_MDT_BODY);
 	if (!body) {
 		rc = -EFAULT;
 		goto out;
@@ -646,7 +649,7 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 
 	child = entry->se_inode;
 	/* revalidate; unlinked and re-created with the same name */
-	if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2, &body->mbo_fid1))) {
+	if (unlikely(!lu_fid_eq(&item->mop_data.op_fid2, &body->mbo_fid1))) {
 		if (child) {
 			entry->se_inode = NULL;
 			iput(child);
@@ -663,7 +666,7 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 		goto out;
 	}
 
-	rc = ll_prep_inode(&child, &req->rq_pill, dir->i_sb, it);
+	rc = ll_prep_inode(&child, pill, dir->i_sb, it);
 	if (rc)
 		goto out;
 
@@ -676,107 +679,18 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 
 	if (agl_should_run(sai, child))
 		ll_agl_add(sai, child, entry->se_index);
-
 out:
 	/*
-	 * sa_make_ready() will drop ldlm ibits lock refcount by calling
+	 * First it will drop ldlm ibits lock refcount by calling
 	 * ll_intent_drop_lock() in spite of failures. Do not worry about
 	 * calling ll_intent_drop_lock() more than once.
 	 */
+	ll_intent_release(&item->mop_it);
+	sa_fini_data(item);
 	sa_make_ready(sai, entry, rc);
-}
-
-/* once there are async stat replies, instantiate sa_entry from replies */
-static void sa_handle_callback(struct ll_statahead_info *sai)
-{
-	struct ll_inode_info *lli;
-
-	lli = ll_i2info(sai->sai_dentry->d_inode);
 
 	spin_lock(&lli->lli_sa_lock);
-	while (sa_has_callback(sai)) {
-		struct sa_entry *entry;
-
-		entry = list_first_entry(&sai->sai_interim_entries,
-					 struct sa_entry, se_list);
-		list_del_init(&entry->se_list);
-		spin_unlock(&lli->lli_sa_lock);
-
-		sa_instantiate(sai, entry);
-		spin_lock(&lli->lli_sa_lock);
-	}
-	spin_unlock(&lli->lli_sa_lock);
-}
-
-/*
- * callback for async stat, because this is called in ptlrpcd context, we only
- * put sa_entry in sai_cb_entries list, and let sa_handle_callback() to really
- * prepare inode and instantiate sa_entry later.
- */
-static int ll_statahead_interpret(struct ptlrpc_request *req,
-				  struct md_enqueue_info *minfo, int rc)
-{
-	struct lookup_intent *it = &minfo->mi_it;
-	struct inode *dir = minfo->mi_dir;
-	struct ll_inode_info *lli = ll_i2info(dir);
-	struct ll_statahead_info *sai = lli->lli_sai;
-	struct sa_entry *entry = (struct sa_entry *)minfo->mi_cbdata;
-	u64 handle = 0;
-
-	if (it_disposition(it, DISP_LOOKUP_NEG))
-		rc = -ENOENT;
-
-	/*
-	 * because statahead thread will wait for all inflight RPC to finish,
-	 * sai should be always valid, no need to refcount
-	 */
-	LASSERT(sai);
-	LASSERT(entry);
-
-	CDEBUG(D_READA, "sa_entry %.*s rc %d\n",
-	       entry->se_qstr.len, entry->se_qstr.name, rc);
-
-	if (rc) {
-		ll_intent_release(it);
-		sa_fini_data(minfo);
-	} else {
-		/*
-		 * release ibits lock ASAP to avoid deadlock when statahead
-		 * thread enqueues lock on parent in readdir and another
-		 * process enqueues lock on child with parent lock held, eg.
-		 * unlink.
-		 */
-		handle = it->it_lock_handle;
-		ll_intent_drop_lock(it);
-		ll_unlock_md_op_lsm(&minfo->mi_data);
-	}
-
-	spin_lock(&lli->lli_sa_lock);
-	if (rc) {
-		if (__sa_make_ready(sai, entry, rc))
-			wake_up(&sai->sai_waitq);
-	} else {
-		int first = 0;
-
-		entry->se_minfo = minfo;
-		entry->se_req = ptlrpc_request_addref(req);
-		/*
-		 * Release the async ibits lock ASAP to avoid deadlock
-		 * when statahead thread tries to enqueue lock on parent
-		 * for readpage and other tries to enqueue lock on child
-		 * with parent's lock held, for example: unlink.
-		 */
-		entry->se_handle = handle;
-		if (!sa_has_callback(sai))
-			first = 1;
-
-		list_add_tail(&entry->se_list, &sai->sai_interim_entries);
-
-		if (first && sai->sai_task)
-			wake_up_process(sai->sai_task);
-	}
 	sai->sai_replied++;
-
 	spin_unlock(&lli->lli_sa_lock);
 
 	return rc;
@@ -785,16 +699,16 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 /* async stat for file not found in dcache */
 static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 {
-	struct md_enqueue_info *minfo;
+	struct md_op_item *item;
 	int rc;
 
-	minfo = sa_prep_data(dir, NULL, entry);
-	if (IS_ERR(minfo))
-		return PTR_ERR(minfo);
+	item = sa_prep_data(dir, NULL, entry);
+	if (IS_ERR(item))
+		return PTR_ERR(item);
 
-	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo);
+	rc = md_intent_getattr_async(ll_i2mdexp(dir), item);
 	if (rc)
-		sa_fini_data(minfo);
+		sa_fini_data(item);
 
 	return rc;
 }
@@ -814,7 +728,7 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 		.it_op = IT_GETATTR,
 		.it_lock_handle = 0
 	};
-	struct md_enqueue_info *minfo;
+	struct md_op_item *item;
 	int rc;
 
 	if (unlikely(!inode))
@@ -823,9 +737,9 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 	if (d_mountpoint(dentry))
 		return 1;
 
-	minfo = sa_prep_data(dir, inode, entry);
-	if (IS_ERR(minfo))
-		return PTR_ERR(minfo);
+	item = sa_prep_data(dir, inode, entry);
+	if (IS_ERR(item))
+		return PTR_ERR(item);
 
 	entry->se_inode = igrab(inode);
 	rc = md_revalidate_lock(ll_i2mdexp(dir), &it, ll_inode2fid(inode),
@@ -833,15 +747,15 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 	if (rc == 1) {
 		entry->se_handle = it.it_lock_handle;
 		ll_intent_release(&it);
-		sa_fini_data(minfo);
+		sa_fini_data(item);
 		return 1;
 	}
 
-	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo);
+	rc = md_intent_getattr_async(ll_i2mdexp(dir), item);
 	if (rc) {
 		entry->se_inode = NULL;
 		iput(inode);
-		sa_fini_data(minfo);
+		sa_fini_data(item);
 	}
 
 	return rc;
@@ -934,14 +848,14 @@ static void ll_stop_agl(struct ll_statahead_info *sai)
 		return;
 
 	CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
-	       sai, (unsigned int)sai->sai_agl_task->pid);
-	kthread_stop(sai->sai_agl_task);
+	       sai, (unsigned int)agl_task->pid);
+	kthread_stop(agl_task);
 
-	sai->sai_agl_task = NULL;
 	spin_lock(&plli->lli_agl_lock);
-	while ((clli = list_first_entry_or_null(&sai->sai_agls,
-						struct ll_inode_info,
-						lli_agl_list)) != NULL) {
+	clli = list_first_entry_or_null(&sai->sai_agls,
+					struct ll_inode_info,
+					lli_agl_list);
+	if (clli) {
 		list_del_init(&clli->lli_agl_list);
 		spin_unlock(&plli->lli_agl_lock);
 		clli->lli_agl_index = 0;
@@ -950,7 +864,7 @@ static void ll_stop_agl(struct ll_statahead_info *sai)
 	}
 	spin_unlock(&plli->lli_agl_lock);
 	CDEBUG(D_READA, "agl thread stopped: sai %p, parent %pd\n",
-	       sai, sai->sai_dentry);
+	       sai, parent);
 	ll_sai_put(sai);
 }
 
@@ -1014,10 +928,8 @@ static int ll_statahead_thread(void *arg)
 			break;
 		}
 
-		sai->sai_in_readpage = 1;
 		page = ll_get_dir_page(dir, op_data, pos);
 		ll_unlock_md_op_lsm(op_data);
-		sai->sai_in_readpage = 0;
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
 			CDEBUG(D_READA,
@@ -1081,14 +993,9 @@ static int ll_statahead_thread(void *arg)
 
 			while (({set_current_state(TASK_IDLE);
 				 sai->sai_task; })) {
-				if (sa_has_callback(sai)) {
-					__set_current_state(TASK_RUNNING);
-					sa_handle_callback(sai);
-				}
-
 				spin_lock(&lli->lli_agl_lock);
 				while (sa_sent_full(sai) &&
-				       !agl_list_empty(sai)) {
+				       !list_empty(&sai->sai_agls)) {
 					struct ll_inode_info *clli;
 
 					__set_current_state(TASK_RUNNING);
@@ -1140,16 +1047,11 @@ static int ll_statahead_thread(void *arg)
 
 	/*
 	 * statahead is finished, but statahead entries need to be cached, wait
-	 * for file release to stop me.
+	 * for file release closedir() call to stop me.
 	 */
 	while (({set_current_state(TASK_IDLE);
 		 sai->sai_task; })) {
-		if (sa_has_callback(sai)) {
-			__set_current_state(TASK_RUNNING);
-			sa_handle_callback(sai);
-		} else {
-			schedule();
-		}
+		schedule();
 	}
 	__set_current_state(TASK_RUNNING);
 out:
@@ -1159,13 +1061,9 @@ static int ll_statahead_thread(void *arg)
 	 * wait for inflight statahead RPCs to finish, and then we can free sai
 	 * safely because statahead RPC will access sai data
 	 */
-	while (sai->sai_sent != sai->sai_replied) {
+	while (sai->sai_sent != sai->sai_replied)
 		/* in case we're not woken up, timeout wait */
 		msleep(125);
-	}
-
-	/* release resources held by statahead RPCs */
-	sa_handle_callback(sai);
 
 	CDEBUG(D_READA, "statahead thread stopped: sai %p, parent %pd\n",
 	       sai, parent);
@@ -1173,8 +1071,8 @@ static int ll_statahead_thread(void *arg)
 	spin_lock(&lli->lli_sa_lock);
 	sai->sai_task = NULL;
 	spin_unlock(&lli->lli_sa_lock);
-
 	wake_up(&sai->sai_waitq);
+
 	ll_sai_put(sai);
 
 	return rc;
@@ -1200,8 +1098,8 @@ void ll_authorize_statahead(struct inode *dir, void *key)
 }
 
 /*
- * deauthorize opened dir handle @key to statahead, but statahead thread may
- * still be running, notify it to quit.
+ * deauthorize opened dir handle @key to statahead, and notify statahead thread
+ * to quit if it's running.
  */
 void ll_deauthorize_statahead(struct inode *dir, void *key)
 {
@@ -1427,10 +1325,6 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		goto out_unplug;
 	}
 
-	/* if statahead is busy in readdir, help it do post-work */
-	if (!sa_ready(entry) && sai->sai_in_readpage)
-		sa_handle_callback(sai);
-
 	if (!sa_ready(entry)) {
 		spin_lock(&lli->lli_sa_lock);
 		sai->sai_index_wait = entry->se_index;
@@ -1507,7 +1401,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 	 */
 	ldd = ll_d2d(*dentryp);
 	ldd->lld_sa_generation = lli->lli_sa_generation;
-	sa_put(sai, entry, lli);
+	sa_put(sai, entry);
 	spin_lock(&lli->lli_sa_lock);
 	if (sai->sai_task)
 		wake_up_process(sai->sai_task);
@@ -1591,7 +1485,6 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry,
 		spin_lock(&lli->lli_sa_lock);
 		lli->lli_sai = NULL;
 		spin_unlock(&lli->lli_sa_lock);
-		atomic_dec(&ll_i2sbi(parent->d_inode)->ll_sa_running);
 		rc = PTR_ERR(task);
 		CERROR("can't start ll_sa thread, rc : %d\n", rc);
 		goto out;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 56d22d1..ac88d20 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3431,9 +3431,9 @@ static int lmv_clear_open_replay_data(struct obd_export *exp,
 }
 
 static int lmv_intent_getattr_async(struct obd_export *exp,
-				    struct md_enqueue_info *minfo)
+				    struct md_op_item *item)
 {
-	struct md_op_data *op_data = &minfo->mi_data;
+	struct md_op_data *op_data = &item->mop_data;
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *ptgt = NULL;
@@ -3457,7 +3457,7 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 	if (ctgt != ptgt)
 		return -EREMOTE;
 
-	return md_intent_getattr_async(ptgt->ltd_exp, minfo);
+	return md_intent_getattr_async(ptgt->ltd_exp, item);
 }
 
 static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index fab40bd..2416607 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -130,8 +130,7 @@ int mdc_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 			struct lu_fid *fid, u64 *bits);
 
-int mdc_intent_getattr_async(struct obd_export *exp,
-			     struct md_enqueue_info *minfo);
+int mdc_intent_getattr_async(struct obd_export *exp, struct md_op_item *item);
 
 enum ldlm_mode mdc_lock_match(struct obd_export *exp, u64 flags,
 			      const struct lu_fid *fid, enum ldlm_type type,
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 4135c3a..a0fcab0 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -49,7 +49,7 @@
 
 struct mdc_getattr_args {
 	struct obd_export	*ga_exp;
-	struct md_enqueue_info	*ga_minfo;
+	struct md_op_item	*ga_item;
 };
 
 int it_open_error(int phase, struct lookup_intent *it)
@@ -1360,10 +1360,10 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 {
 	struct mdc_getattr_args *ga = args;
 	struct obd_export *exp = ga->ga_exp;
-	struct md_enqueue_info *minfo = ga->ga_minfo;
-	struct ldlm_enqueue_info *einfo = &minfo->mi_einfo;
-	struct lookup_intent *it = &minfo->mi_it;
-	struct lustre_handle *lockh = &minfo->mi_lockh;
+	struct md_op_item *item = ga->ga_item;
+	struct ldlm_enqueue_info *einfo = &item->mop_einfo;
+	struct lookup_intent *it = &item->mop_it;
+	struct lustre_handle *lockh = &item->mop_lockh;
 	struct ldlm_reply *lockrep;
 	u64 flags = LDLM_FL_HAS_INTENT;
 
@@ -1388,18 +1388,17 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	if (rc)
 		goto out;
 
-	rc = mdc_finish_intent_lock(exp, req, &minfo->mi_data, it, lockh);
-
+	rc = mdc_finish_intent_lock(exp, req, &item->mop_data, it, lockh);
 out:
-	minfo->mi_cb(req, minfo, rc);
+	item->mop_cb(&req->rq_pill, item, rc);
 	return 0;
 }
 
 int mdc_intent_getattr_async(struct obd_export *exp,
-			     struct md_enqueue_info *minfo)
+			     struct md_op_item *item)
 {
-	struct md_op_data *op_data = &minfo->mi_data;
-	struct lookup_intent *it = &minfo->mi_it;
+	struct md_op_data *op_data = &item->mop_data;
+	struct lookup_intent *it = &item->mop_it;
 	struct ptlrpc_request *req;
 	struct mdc_getattr_args *ga;
 	struct ldlm_res_id res_id;
@@ -1428,11 +1427,11 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	 * to avoid possible races. It is safe to have glimpse handler
 	 * for non-DOM locks and costs nothing.
 	 */
-	if (!minfo->mi_einfo.ei_cb_gl)
-		minfo->mi_einfo.ei_cb_gl = mdc_ldlm_glimpse_ast;
+	if (!item->mop_einfo.ei_cb_gl)
+		item->mop_einfo.ei_cb_gl = mdc_ldlm_glimpse_ast;
 
-	rc = ldlm_cli_enqueue(exp, &req, &minfo->mi_einfo, &res_id, &policy,
-			      &flags, NULL, 0, LVB_T_NONE, &minfo->mi_lockh, 1);
+	rc = ldlm_cli_enqueue(exp, &req, &item->mop_einfo, &res_id, &policy,
+			      &flags, NULL, 0, LVB_T_NONE, &item->mop_lockh, 1);
 	if (rc < 0) {
 		ptlrpc_req_finished(req);
 		return rc;
@@ -1440,7 +1439,7 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 
 	ga = ptlrpc_req_async_args(ga, req);
 	ga->ga_exp = exp;
-	ga->ga_minfo = minfo;
+	ga->ga_item = item;
 
 	req->rq_interpret_reply = mdc_intent_getattr_async_interpret;
 	ptlrpcd_add_req(req);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
