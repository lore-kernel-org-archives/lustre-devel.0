Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBBD2C4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:05 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8F75E60F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 8F75E60F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 31C02352D70;
	Mon,  2 Aug 2021 12:51:04 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8300E35286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5F8BE1007AB9;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 59E16C2F46; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:27 -0400
Message-Id: <1627933851-7603-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/25] lustre: llite: revert 'simplify
 callback handling for async getattr'
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

From: Andreas Dilger <adilger@whamcloud.com>

This reverts commit 248f68f27de7d18c58a44114a46259141ca53115.

This is causing process hangs and timeouts during file removal.

Fixes: 248f68f27d ("lustre: llite: simplify callback handling for async getattr")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14868
Lustre-commit: e90794af4bfac3a5 ("U-14868 llite: revert 'simplify callback handling for async getattr'")
Reviewed-on: https://review.whamcloud.com/44371
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h          |  32 ++--
 fs/lustre/include/obd_class.h    |   4 +-
 fs/lustre/llite/llite_internal.h |   7 +-
 fs/lustre/llite/statahead.c      | 319 ++++++++++++++++++++++++++-------------
 fs/lustre/lmv/lmv_obd.c          |   6 +-
 fs/lustre/mdc/mdc_internal.h     |   3 +-
 fs/lustre/mdc/mdc_locks.c        |  31 ++--
 7 files changed, 252 insertions(+), 150 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index eeb6262..f619342 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -818,24 +818,18 @@ struct md_callback {
 			       void *data, int flag);
 };
 
-enum md_opcode {
-	MD_OP_NONE	= 0,
-	MD_OP_GETATTR	= 1,
-	MD_OP_MAX,
-};
-
-struct md_op_item {
-	enum md_opcode			mop_opc;
-	struct md_op_data		mop_data;
-	struct lookup_intent		mop_it;
-	struct lustre_handle		mop_lockh;
-	struct ldlm_enqueue_info	mop_einfo;
-	int (*mop_cb)(struct req_capsule *pill,
-		      struct md_op_item *item,
-		      int rc);
-	void			       *mop_cbdata;
-	struct inode		       *mop_dir;
-	u64				mop_lock_flags;
+struct md_enqueue_info;
+/* metadata stat-ahead */
+
+struct md_enqueue_info {
+	struct md_op_data		mi_data;
+	struct lookup_intent		mi_it;
+	struct lustre_handle		mi_lockh;
+	struct inode		       *mi_dir;
+	struct ldlm_enqueue_info	mi_einfo;
+	int (*mi_cb)(struct ptlrpc_request *req,
+		     struct md_enqueue_info *minfo, int rc);
+	void			       *mi_cbdata;
 };
 
 struct obd_ops {
@@ -1067,7 +1061,7 @@ struct md_ops {
 				struct lu_fid *fid);
 
 	int (*intent_getattr_async)(struct obd_export *exp,
-				    struct md_op_item *item);
+				    struct md_enqueue_info *minfo);
 
 	int (*revalidate_lock)(struct obd_export *, struct lookup_intent *,
 			       struct lu_fid *, u64 *bits);
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index ad9b2fc..f2a3d2b 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1594,7 +1594,7 @@ static inline int md_init_ea_size(struct obd_export *exp, u32 easize,
 }
 
 static inline int md_intent_getattr_async(struct obd_export *exp,
-					  struct md_op_item *item)
+					  struct md_enqueue_info *minfo)
 {
 	int rc;
 
@@ -1605,7 +1605,7 @@ static inline int md_intent_getattr_async(struct obd_export *exp,
 	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
 			     LPROC_MD_INTENT_GETATTR_ASYNC);
 
-	return MDP(exp->exp_obd, intent_getattr_async)(exp, item);
+	return MDP(exp->exp_obd, intent_getattr_async)(exp, minfo);
 }
 
 static inline int md_revalidate_lock(struct obd_export *exp,
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 6cae741..2247806 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1480,12 +1480,17 @@ struct ll_statahead_info {
 					     * is not a hidden one
 					     */
 	unsigned int	    sai_skip_hidden;/* skipped hidden dentry count */
-	unsigned int	    sai_ls_all:1;   /* "ls -al", do stat-ahead for
+	unsigned int	    sai_ls_all:1,   /* "ls -al", do stat-ahead for
 					     * hidden entries
 					     */
+				sai_in_readpage:1;/* statahead in readdir() */
 	wait_queue_head_t	sai_waitq;      /* stat-ahead wait queue */
 	struct task_struct     *sai_task;       /* stat-ahead thread */
 	struct task_struct     *sai_agl_task;   /* AGL thread */
+	struct list_head	sai_interim_entries; /* entries which got async
+						      * stat reply, but not
+						      * instantiated
+						      */
 	struct list_head	sai_entries;	/* completed entries */
 	struct list_head	sai_agls;	/* AGLs to be sent */
 	struct list_head	sai_cache[LL_SA_CACHE_SIZE];
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index becd0e1..8930f61 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -32,6 +32,7 @@
 
 #include <linux/fs.h>
 #include <linux/sched.h>
+#include <linux/kthread.h>
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
@@ -55,12 +56,13 @@ enum se_stat {
 
 /*
  * sa_entry is not refcounted: statahead thread allocates it and do async stat,
- * and in async stat callback ll_statahead_interpret() will prepare the inode
- * and set lock data in the ptlrpcd context. Then the scanner process will be
- * woken up if this entry is the waiting one, can access and free it.
+ * and in async stat callback ll_statahead_interpret() will add it into
+ * sai_interim_entries, later statahead thread will call sa_handle_callback() to
+ * instantiate entry and move it into sai_entries, and then only scanner process
+ * can access and free it.
  */
 struct sa_entry {
-	/* link into sai_entries */
+	/* link into sai_interim_entries or sai_entries */
 	struct list_head	se_list;
 	/* link into sai hash table locally */
 	struct list_head	se_hash;
@@ -72,6 +74,10 @@ struct sa_entry {
 	enum se_stat		se_state;
 	/* entry size, contains name */
 	int			se_size;
+	/* pointer to async getattr enqueue info */
+	struct md_enqueue_info	*se_minfo;
+	/* pointer to the async getattr request */
+	struct ptlrpc_request	*se_req;
 	/* pointer to the target inode */
 	struct inode		*se_inode;
 	/* entry name */
@@ -131,6 +137,12 @@ static inline int sa_sent_full(struct ll_statahead_info *sai)
 	return atomic_read(&sai->sai_cache_count) >= sai->sai_max;
 }
 
+/* got async stat replies */
+static inline int sa_has_callback(struct ll_statahead_info *sai)
+{
+	return !list_empty(&sai->sai_interim_entries);
+}
+
 static inline int agl_list_empty(struct ll_statahead_info *sai)
 {
 	return list_empty(&sai->sai_agls);
@@ -316,55 +328,55 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 }
 
 /* finish async stat RPC arguments */
-static void sa_fini_data(struct md_op_item *item)
+static void sa_fini_data(struct md_enqueue_info *minfo)
 {
-	ll_unlock_md_op_lsm(&item->mop_data);
-	iput(item->mop_dir);
-	kfree(item);
+	ll_unlock_md_op_lsm(&minfo->mi_data);
+	iput(minfo->mi_dir);
+	kfree(minfo);
 }
 
-static int ll_statahead_interpret(struct req_capsule *pill,
-				  struct md_op_item *item, int rc);
+static int ll_statahead_interpret(struct ptlrpc_request *req,
+				  struct md_enqueue_info *minfo, int rc);
 
 /*
  * prepare arguments for async stat RPC.
  */
-static struct md_op_item *
+static struct md_enqueue_info *
 sa_prep_data(struct inode *dir, struct inode *child, struct sa_entry *entry)
 {
-	struct md_op_item *item;
+	struct md_enqueue_info   *minfo;
 	struct ldlm_enqueue_info *einfo;
-	struct md_op_data *op_data;
+	struct md_op_data        *op_data;
 
-	item = kzalloc(sizeof(*item), GFP_NOFS);
-	if (!item)
+	minfo = kzalloc(sizeof(*minfo), GFP_NOFS);
+	if (!minfo)
 		return ERR_PTR(-ENOMEM);
 
-	op_data = ll_prep_md_op_data(&item->mop_data, dir, child,
+	op_data = ll_prep_md_op_data(&minfo->mi_data, dir, child,
 				     entry->se_qstr.name, entry->se_qstr.len, 0,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data)) {
-		kfree(item);
-		return ERR_CAST(item);
+		kfree(minfo);
+		return (struct md_enqueue_info *)op_data;
 	}
 
 	if (!child)
 		op_data->op_fid2 = entry->se_fid;
 
-	item->mop_it.it_op = IT_GETATTR;
-	item->mop_dir = igrab(dir);
-	item->mop_cb = ll_statahead_interpret;
-	item->mop_cbdata = entry;
-
-	einfo = &item->mop_einfo;
-	einfo->ei_type = LDLM_IBITS;
-	einfo->ei_mode = it_to_lock_mode(&item->mop_it);
-	einfo->ei_cb_bl = ll_md_blocking_ast;
-	einfo->ei_cb_cp = ldlm_completion_ast;
-	einfo->ei_cb_gl = NULL;
+	minfo->mi_it.it_op = IT_GETATTR;
+	minfo->mi_dir = igrab(dir);
+	minfo->mi_cb = ll_statahead_interpret;
+	minfo->mi_cbdata = entry;
+
+	einfo = &minfo->mi_einfo;
+	einfo->ei_type   = LDLM_IBITS;
+	einfo->ei_mode   = it_to_lock_mode(&minfo->mi_it);
+	einfo->ei_cb_bl  = ll_md_blocking_ast;
+	einfo->ei_cb_cp  = ldlm_completion_ast;
+	einfo->ei_cb_gl  = NULL;
 	einfo->ei_cbdata = NULL;
 
-	return item;
+	return minfo;
 }
 
 /*
@@ -375,8 +387,22 @@ static int ll_statahead_interpret(struct req_capsule *pill,
 sa_make_ready(struct ll_statahead_info *sai, struct sa_entry *entry, int ret)
 {
 	struct ll_inode_info *lli = ll_i2info(sai->sai_dentry->d_inode);
+	struct md_enqueue_info *minfo = entry->se_minfo;
+	struct ptlrpc_request *req = entry->se_req;
 	bool wakeup;
 
+	/* release resources used in RPC */
+	if (minfo) {
+		entry->se_minfo = NULL;
+		ll_intent_release(&minfo->mi_it);
+		sa_fini_data(minfo);
+	}
+
+	if (req) {
+		entry->se_req = NULL;
+		ptlrpc_req_finished(req);
+	}
+
 	spin_lock(&lli->lli_sa_lock);
 	wakeup = __sa_make_ready(sai, entry, ret);
 	spin_unlock(&lli->lli_sa_lock);
@@ -433,6 +459,7 @@ static struct ll_statahead_info *ll_sai_alloc(struct dentry *dentry)
 	sai->sai_index = 1;
 	init_waitqueue_head(&sai->sai_waitq);
 
+	INIT_LIST_HEAD(&sai->sai_interim_entries);
 	INIT_LIST_HEAD(&sai->sai_entries);
 	INIT_LIST_HEAD(&sai->sai_agls);
 
@@ -495,6 +522,7 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 		LASSERT(sai->sai_task == NULL);
 		LASSERT(sai->sai_agl_task == NULL);
 		LASSERT(sai->sai_sent == sai->sai_replied);
+		LASSERT(!sa_has_callback(sai));
 
 		list_for_each_entry_safe(entry, next, &sai->sai_entries,
 					 se_list)
@@ -585,63 +613,26 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 }
 
 /*
- * Callback for async stat RPC, this is called in ptlrpcd context. It prepares
- * the inode and set lock data directly in the ptlrpcd context. It will wake up
- * the directory listing process if the dentry is the waiting one.
+ * prepare inode for sa entry, add it into agl list, now sa_entry is ready
+ * to be used by scanner process.
  */
-static int ll_statahead_interpret(struct req_capsule *pill,
-				  struct md_op_item *item, int rc)
+static void sa_instantiate(struct ll_statahead_info *sai,
+			   struct sa_entry *entry)
 {
-	struct lookup_intent *it = &item->mop_it;
-	struct inode *dir = item->mop_dir;
-	struct ll_inode_info *lli = ll_i2info(dir);
-	struct ll_statahead_info *sai = lli->lli_sai;
-	struct sa_entry *entry = (struct sa_entry *)item->mop_cbdata;
-	struct mdt_body	*body;
+	struct inode *dir = sai->sai_dentry->d_inode;
 	struct inode *child;
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
-	if (rc != 0) {
-		ll_intent_release(it);
-		sa_fini_data(item);
-	} else {
-		/*
-		 * release ibits lock ASAP to avoid deadlock when statahead
-		 * thread enqueues lock on parent in readdir and another
-		 * process enqueues lock on child with parent lock held, eg.
-		 * unlink.
-		 */
-		handle = it->it_lock_handle;
-		ll_intent_drop_lock(it);
-		ll_unlock_md_op_lsm(&item->mop_data);
-	}
-
-	if (rc != 0) {
-		spin_lock(&lli->lli_sa_lock);
-		if (__sa_make_ready(sai, entry, rc))
-			wake_up(&sai->sai_waitq);
-
-		sai->sai_replied++;
-		spin_unlock(&lli->lli_sa_lock);
+	struct md_enqueue_info *minfo;
+	struct lookup_intent *it;
+	struct ptlrpc_request *req;
+	struct mdt_body	*body;
+	int rc = 0;
 
-		return rc;
-	}
+	LASSERT(entry->se_handle != 0);
 
-	entry->se_handle = handle;
-	body = req_capsule_server_get(pill, &RMF_MDT_BODY);
+	minfo = entry->se_minfo;
+	it = &minfo->mi_it;
+	req = entry->se_req;
+	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 	if (!body) {
 		rc = -EFAULT;
 		goto out;
@@ -649,7 +640,7 @@ static int ll_statahead_interpret(struct req_capsule *pill,
 
 	child = entry->se_inode;
 	/* revalidate; unlinked and re-created with the same name */
-	if (unlikely(!lu_fid_eq(&item->mop_data.op_fid2, &body->mbo_fid1))) {
+	if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2, &body->mbo_fid1))) {
 		if (child) {
 			entry->se_inode = NULL;
 			iput(child);
@@ -666,7 +657,7 @@ static int ll_statahead_interpret(struct req_capsule *pill,
 		goto out;
 	}
 
-	rc = ll_prep_inode(&child, pill, dir->i_sb, it);
+	rc = ll_prep_inode(&child, &req->rq_pill, dir->i_sb, it);
 	if (rc)
 		goto out;
 
@@ -679,18 +670,107 @@ static int ll_statahead_interpret(struct req_capsule *pill,
 
 	if (agl_should_run(sai, child))
 		ll_agl_add(sai, child, entry->se_index);
+
 out:
 	/*
-	 * First it will drop ldlm ibits lock refcount by calling
+	 * sa_make_ready() will drop ldlm ibits lock refcount by calling
 	 * ll_intent_drop_lock() in spite of failures. Do not worry about
 	 * calling ll_intent_drop_lock() more than once.
 	 */
-	ll_intent_release(&item->mop_it);
-	sa_fini_data(item);
 	sa_make_ready(sai, entry, rc);
+}
+
+/* once there are async stat replies, instantiate sa_entry from replies */
+static void sa_handle_callback(struct ll_statahead_info *sai)
+{
+	struct ll_inode_info *lli;
+
+	lli = ll_i2info(sai->sai_dentry->d_inode);
 
 	spin_lock(&lli->lli_sa_lock);
+	while (sa_has_callback(sai)) {
+		struct sa_entry *entry;
+
+		entry = list_first_entry(&sai->sai_interim_entries,
+					 struct sa_entry, se_list);
+		list_del_init(&entry->se_list);
+		spin_unlock(&lli->lli_sa_lock);
+
+		sa_instantiate(sai, entry);
+		spin_lock(&lli->lli_sa_lock);
+	}
+	spin_unlock(&lli->lli_sa_lock);
+}
+
+/*
+ * callback for async stat RPC, because this is called in ptlrpcd context, we
+ * only put sa_entry in sai_interim_entries, and wake up statahead thread to
+ * really prepare inode and instantiate sa_entry later.
+ */
+static int ll_statahead_interpret(struct ptlrpc_request *req,
+				  struct md_enqueue_info *minfo, int rc)
+{
+	struct lookup_intent *it = &minfo->mi_it;
+	struct inode *dir = minfo->mi_dir;
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct ll_statahead_info *sai = lli->lli_sai;
+	struct sa_entry *entry = (struct sa_entry *)minfo->mi_cbdata;
+	u64 handle = 0;
+
+	if (it_disposition(it, DISP_LOOKUP_NEG))
+		rc = -ENOENT;
+
+	/*
+	 * because statahead thread will wait for all inflight RPC to finish,
+	 * sai should be always valid, no need to refcount
+	 */
+	LASSERT(sai);
+	LASSERT(entry);
+
+	CDEBUG(D_READA, "sa_entry %.*s rc %d\n",
+	       entry->se_qstr.len, entry->se_qstr.name, rc);
+
+	if (rc) {
+		ll_intent_release(it);
+		sa_fini_data(minfo);
+	} else {
+		/*
+		 * release ibits lock ASAP to avoid deadlock when statahead
+		 * thread enqueues lock on parent in readdir and another
+		 * process enqueues lock on child with parent lock held, eg.
+		 * unlink.
+		 */
+		handle = it->it_lock_handle;
+		ll_intent_drop_lock(it);
+		ll_unlock_md_op_lsm(&minfo->mi_data);
+	}
+
+	spin_lock(&lli->lli_sa_lock);
+	if (rc) {
+		if (__sa_make_ready(sai, entry, rc))
+			wake_up(&sai->sai_waitq);
+	} else {
+		int first = 0;
+
+		entry->se_minfo = minfo;
+		entry->se_req = ptlrpc_request_addref(req);
+		/*
+		 * Release the async ibits lock ASAP to avoid deadlock
+		 * when statahead thread tries to enqueue lock on parent
+		 * for readpage and other tries to enqueue lock on child
+		 * with parent's lock held, for example: unlink.
+		 */
+		entry->se_handle = handle;
+		if (!sa_has_callback(sai))
+			first = 1;
+
+		list_add_tail(&entry->se_list, &sai->sai_interim_entries);
+
+		if (first && sai->sai_task)
+			wake_up_process(sai->sai_task);
+	}
 	sai->sai_replied++;
+
 	spin_unlock(&lli->lli_sa_lock);
 
 	return rc;
@@ -699,16 +779,16 @@ static int ll_statahead_interpret(struct req_capsule *pill,
 /* async stat for file not found in dcache */
 static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 {
-	struct md_op_item *item;
+	struct md_enqueue_info *minfo;
 	int rc;
 
-	item = sa_prep_data(dir, NULL, entry);
-	if (IS_ERR(item))
-		return PTR_ERR(item);
+	minfo = sa_prep_data(dir, NULL, entry);
+	if (IS_ERR(minfo))
+		return PTR_ERR(minfo);
 
-	rc = md_intent_getattr_async(ll_i2mdexp(dir), item);
+	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo);
 	if (rc)
-		sa_fini_data(item);
+		sa_fini_data(minfo);
 
 	return rc;
 }
@@ -728,7 +808,7 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 		.it_op = IT_GETATTR,
 		.it_lock_handle = 0
 	};
-	struct md_op_item *item;
+	struct md_enqueue_info *minfo;
 	int rc;
 
 	if (unlikely(!inode))
@@ -737,9 +817,9 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 	if (d_mountpoint(dentry))
 		return 1;
 
-	item = sa_prep_data(dir, inode, entry);
-	if (IS_ERR(item))
-		return PTR_ERR(item);
+	minfo = sa_prep_data(dir, inode, entry);
+	if (IS_ERR(minfo))
+		return PTR_ERR(minfo);
 
 	entry->se_inode = igrab(inode);
 	rc = md_revalidate_lock(ll_i2mdexp(dir), &it, ll_inode2fid(inode),
@@ -747,15 +827,15 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 	if (rc == 1) {
 		entry->se_handle = it.it_lock_handle;
 		ll_intent_release(&it);
-		sa_fini_data(item);
+		sa_fini_data(minfo);
 		return 1;
 	}
 
-	rc = md_intent_getattr_async(ll_i2mdexp(dir), item);
+	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo);
 	if (rc) {
 		entry->se_inode = NULL;
 		iput(inode);
-		sa_fini_data(item);
+		sa_fini_data(minfo);
 	}
 
 	return rc;
@@ -815,6 +895,9 @@ static int ll_agl_thread(void *arg)
 	while (({set_current_state(TASK_IDLE);
 		 !kthread_should_stop(); })) {
 		spin_lock(&plli->lli_agl_lock);
+		/* The statahead thread maybe help to process AGL entries,
+		 * so check whether list empty again.
+		 */
 		clli = list_first_entry_or_null(&sai->sai_agls,
 						struct ll_inode_info,
 						lli_agl_list);
@@ -852,10 +935,9 @@ static void ll_stop_agl(struct ll_statahead_info *sai)
 	kthread_stop(agl_task);
 
 	spin_lock(&plli->lli_agl_lock);
-	clli = list_first_entry_or_null(&sai->sai_agls,
-					struct ll_inode_info,
-					lli_agl_list);
-	if (clli) {
+	while ((clli = list_first_entry_or_null(&sai->sai_agls,
+						struct ll_inode_info,
+						lli_agl_list)) != NULL) {
 		list_del_init(&clli->lli_agl_list);
 		spin_unlock(&plli->lli_agl_lock);
 		clli->lli_agl_index = 0;
@@ -928,8 +1010,10 @@ static int ll_statahead_thread(void *arg)
 			break;
 		}
 
+		sai->sai_in_readpage = 1;
 		page = ll_get_dir_page(dir, op_data, pos);
 		ll_unlock_md_op_lsm(op_data);
+		sai->sai_in_readpage = 0;
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
 			CDEBUG(D_READA,
@@ -993,9 +1077,14 @@ static int ll_statahead_thread(void *arg)
 
 			while (({set_current_state(TASK_IDLE);
 				 sai->sai_task; })) {
+				if (sa_has_callback(sai)) {
+					__set_current_state(TASK_RUNNING);
+					sa_handle_callback(sai);
+				}
+
 				spin_lock(&lli->lli_agl_lock);
 				while (sa_sent_full(sai) &&
-				       !list_empty(&sai->sai_agls)) {
+				       !agl_list_empty(sai)) {
 					struct ll_inode_info *clli;
 
 					__set_current_state(TASK_RUNNING);
@@ -1047,11 +1136,16 @@ static int ll_statahead_thread(void *arg)
 
 	/*
 	 * statahead is finished, but statahead entries need to be cached, wait
-	 * for file release closedir() call to stop me.
+	 * for file release to stop me.
 	 */
 	while (({set_current_state(TASK_IDLE);
 		 sai->sai_task; })) {
-		schedule();
+		if (sa_has_callback(sai)) {
+			__set_current_state(TASK_RUNNING);
+			sa_handle_callback(sai);
+		} else {
+			schedule();
+		}
 	}
 	__set_current_state(TASK_RUNNING);
 out:
@@ -1061,9 +1155,13 @@ static int ll_statahead_thread(void *arg)
 	 * wait for inflight statahead RPCs to finish, and then we can free sai
 	 * safely because statahead RPC will access sai data
 	 */
-	while (sai->sai_sent != sai->sai_replied)
+	while (sai->sai_sent != sai->sai_replied) {
 		/* in case we're not woken up, timeout wait */
 		msleep(125);
+	}
+
+	/* release resources held by statahead RPCs */
+	sa_handle_callback(sai);
 
 	CDEBUG(D_READA, "statahead thread stopped: sai %p, parent %pd\n",
 	       sai, parent);
@@ -1325,6 +1423,10 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		goto out_unplug;
 	}
 
+	/* if statahead is busy in readdir, help it do post-work */
+	if (!sa_ready(entry) && sai->sai_in_readpage)
+		sa_handle_callback(sai);
+
 	if (!sa_ready(entry)) {
 		spin_lock(&lli->lli_sa_lock);
 		sai->sai_index_wait = entry->se_index;
@@ -1497,7 +1599,6 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry,
 	sai->sai_task = task;
 
 	wake_up_process(task);
-
 	/*
 	 * We don't stat-ahead for the first dirent since we are already in
 	 * lookup.
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 1d9b830..71bf7811 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3438,9 +3438,9 @@ static int lmv_clear_open_replay_data(struct obd_export *exp,
 }
 
 static int lmv_intent_getattr_async(struct obd_export *exp,
-				    struct md_op_item *item)
+				    struct md_enqueue_info *minfo)
 {
-	struct md_op_data *op_data = &item->mop_data;
+	struct md_op_data *op_data = &minfo->mi_data;
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *ptgt = NULL;
@@ -3464,7 +3464,7 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 	if (ctgt != ptgt)
 		return -EREMOTE;
 
-	return md_intent_getattr_async(ptgt->ltd_exp, item);
+	return md_intent_getattr_async(ptgt->ltd_exp, minfo);
 }
 
 static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 2416607..fab40bd 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -130,7 +130,8 @@ int mdc_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 			struct lu_fid *fid, u64 *bits);
 
-int mdc_intent_getattr_async(struct obd_export *exp, struct md_op_item *item);
+int mdc_intent_getattr_async(struct obd_export *exp,
+			     struct md_enqueue_info *minfo);
 
 enum ldlm_mode mdc_lock_match(struct obd_export *exp, u64 flags,
 			      const struct lu_fid *fid, enum ldlm_type type,
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index a0fcab0..4135c3a 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -49,7 +49,7 @@
 
 struct mdc_getattr_args {
 	struct obd_export	*ga_exp;
-	struct md_op_item	*ga_item;
+	struct md_enqueue_info	*ga_minfo;
 };
 
 int it_open_error(int phase, struct lookup_intent *it)
@@ -1360,10 +1360,10 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 {
 	struct mdc_getattr_args *ga = args;
 	struct obd_export *exp = ga->ga_exp;
-	struct md_op_item *item = ga->ga_item;
-	struct ldlm_enqueue_info *einfo = &item->mop_einfo;
-	struct lookup_intent *it = &item->mop_it;
-	struct lustre_handle *lockh = &item->mop_lockh;
+	struct md_enqueue_info *minfo = ga->ga_minfo;
+	struct ldlm_enqueue_info *einfo = &minfo->mi_einfo;
+	struct lookup_intent *it = &minfo->mi_it;
+	struct lustre_handle *lockh = &minfo->mi_lockh;
 	struct ldlm_reply *lockrep;
 	u64 flags = LDLM_FL_HAS_INTENT;
 
@@ -1388,17 +1388,18 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	if (rc)
 		goto out;
 
-	rc = mdc_finish_intent_lock(exp, req, &item->mop_data, it, lockh);
+	rc = mdc_finish_intent_lock(exp, req, &minfo->mi_data, it, lockh);
+
 out:
-	item->mop_cb(&req->rq_pill, item, rc);
+	minfo->mi_cb(req, minfo, rc);
 	return 0;
 }
 
 int mdc_intent_getattr_async(struct obd_export *exp,
-			     struct md_op_item *item)
+			     struct md_enqueue_info *minfo)
 {
-	struct md_op_data *op_data = &item->mop_data;
-	struct lookup_intent *it = &item->mop_it;
+	struct md_op_data *op_data = &minfo->mi_data;
+	struct lookup_intent *it = &minfo->mi_it;
 	struct ptlrpc_request *req;
 	struct mdc_getattr_args *ga;
 	struct ldlm_res_id res_id;
@@ -1427,11 +1428,11 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	 * to avoid possible races. It is safe to have glimpse handler
 	 * for non-DOM locks and costs nothing.
 	 */
-	if (!item->mop_einfo.ei_cb_gl)
-		item->mop_einfo.ei_cb_gl = mdc_ldlm_glimpse_ast;
+	if (!minfo->mi_einfo.ei_cb_gl)
+		minfo->mi_einfo.ei_cb_gl = mdc_ldlm_glimpse_ast;
 
-	rc = ldlm_cli_enqueue(exp, &req, &item->mop_einfo, &res_id, &policy,
-			      &flags, NULL, 0, LVB_T_NONE, &item->mop_lockh, 1);
+	rc = ldlm_cli_enqueue(exp, &req, &minfo->mi_einfo, &res_id, &policy,
+			      &flags, NULL, 0, LVB_T_NONE, &minfo->mi_lockh, 1);
 	if (rc < 0) {
 		ptlrpc_req_finished(req);
 		return rc;
@@ -1439,7 +1440,7 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 
 	ga = ptlrpc_req_async_args(ga, req);
 	ga->ga_exp = exp;
-	ga->ga_item = item;
+	ga->ga_minfo = minfo;
 
 	req->rq_interpret_reply = mdc_intent_getattr_async_interpret;
 	ptlrpcd_add_req(req);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
