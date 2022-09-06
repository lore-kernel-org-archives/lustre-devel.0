Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E6B32ECAAA1
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:23 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lq4Rw5z1y6T;
	Mon,  5 Sep 2022 18:56:23 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l60ZXMz1y6W
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B6BDB100B000;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AC1DA58992; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:20 -0400
Message-Id: <1662429337-18737-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/24] lustre: llite: simplify callback
 handling for async getattr
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

If the statahead entry is a striped directory, it may generate
new RPCs in the ptlrpcd interpret context to obtain the
attributes for slaves of the striped directory:
  @ll_prep_inode()->@lmv_revaildate_slaves()
This is dangerous and may result in deadlock in ptlrpcd interpret
context, thus we use work queue to handle these extra RPCs.
Add sanity 123d to verify that it works correctly.

According to the benchmark result, the workload "ls -l" to a large
directory on a client without any caching (server and client),
containing 1M files (47001 bytes) shows the results with measured
elapsed time:
- w/o patch:    180 seconds;
- w patch:      181 seconds;

There is no any obvious performance regession.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14139
Lustre-commit: 509d7305ce8a01351 ("LU-14139 llite: simplify callback handling for async getattr")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/45648
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_intent.h |   2 +
 fs/lustre/include/obd.h           |  27 +--
 fs/lustre/include/obd_class.h     |   4 +-
 fs/lustre/llite/llite_internal.h  |  17 +-
 fs/lustre/llite/llite_lib.c       |   8 +
 fs/lustre/llite/statahead.c       | 380 +++++++++++++++++++-------------------
 fs/lustre/lmv/lmv_obd.c           |   6 +-
 fs/lustre/mdc/mdc_internal.h      |   3 +-
 fs/lustre/mdc/mdc_locks.c         |  30 +--
 9 files changed, 241 insertions(+), 236 deletions(-)

diff --git a/fs/lustre/include/lustre_intent.h b/fs/lustre/include/lustre_intent.h
index e7d81f6..298270b 100644
--- a/fs/lustre/include/lustre_intent.h
+++ b/fs/lustre/include/lustre_intent.h
@@ -50,6 +50,8 @@ struct lookup_intent {
 	u64			it_remote_lock_handle;
 	struct ptlrpc_request	*it_request;
 	unsigned int		it_lock_set:1;
+	unsigned int		it_extra_rpc_check:1;
+	unsigned int		it_extra_rpc_need:1;
 };
 
 static inline int it_disposition(struct lookup_intent *it, int flag)
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index c5e2a24..c452da7 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -834,18 +834,19 @@ struct md_readdir_info {
 	int mr_partial_readdir_rc;
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
+struct md_op_item;
+typedef int (*md_op_item_cb_t)(struct req_capsule *pill,
+			       struct md_op_item *item,
+			       int rc);
+
+struct md_op_item {
+	struct md_op_data		 mop_data;
+	struct lookup_intent		 mop_it;
+	struct lustre_handle		 mop_lockh;
+	struct ldlm_enqueue_info	 mop_einfo;
+	md_op_item_cb_t                  mop_cb;
+	void				*mop_cbdata;
+	struct inode			*mop_dir;
 };
 
 struct obd_ops {
@@ -1078,7 +1079,7 @@ struct md_ops {
 				struct lu_fid *fid);
 
 	int (*intent_getattr_async)(struct obd_export *exp,
-				    struct md_enqueue_info *minfo);
+				    struct md_op_item *item);
 
 	int (*revalidate_lock)(struct obd_export *, struct lookup_intent *,
 			       struct lu_fid *, u64 *bits);
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index f603140..80ff4e8 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1593,7 +1593,7 @@ static inline int md_init_ea_size(struct obd_export *exp, u32 easize,
 }
 
 static inline int md_intent_getattr_async(struct obd_export *exp,
-					  struct md_enqueue_info *minfo)
+					  struct md_op_item *item)
 {
 	int rc;
 
@@ -1604,7 +1604,7 @@ static inline int md_intent_getattr_async(struct obd_export *exp,
 	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
 			     LPROC_MD_INTENT_GETATTR_ASYNC);
 
-	return MDP(exp->exp_obd, intent_getattr_async)(exp, minfo);
+	return MDP(exp->exp_obd, intent_getattr_async)(exp, item);
 }
 
 static inline int md_revalidate_lock(struct obd_export *exp,
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index b018515..e7f703a 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1504,17 +1504,12 @@ struct ll_statahead_info {
 					     * is not a hidden one
 					     */
 	unsigned int	    sai_skip_hidden;/* skipped hidden dentry count */
-	unsigned int	    sai_ls_all:1,   /* "ls -al", do stat-ahead for
-					     * hidden entries
-					     */
-				sai_in_readpage:1;/* statahead in readdir() */
+	unsigned int		sai_ls_all:1; /* "ls -al", do stat-ahead for
+					       * hidden entries
+					       */
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
@@ -1522,6 +1517,12 @@ struct ll_statahead_info {
 	atomic_t		sai_cache_count; /* entry count in cache */
 };
 
+struct ll_interpret_work {
+	struct work_struct	 lpw_work;
+	struct md_op_item	*lpw_item;
+	struct req_capsule	*lpw_pill;
+};
+
 int ll_revalidate_statahead(struct inode *dir, struct dentry **dentry,
 			    bool unplug);
 int ll_start_statahead(struct inode *dir, struct dentry *dentry, bool agl);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 5931258..0bffe5e 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3080,6 +3080,14 @@ int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 	if (rc)
 		goto out;
 
+	if (S_ISDIR(md.body->mbo_mode) && md.lmv && lmv_dir_striped(md.lmv) &&
+	    it && it->it_extra_rpc_check) {
+		/* TODO: Check @lsm unchanged via @lsm_md_eq. */
+		it->it_extra_rpc_need = 1;
+		rc = -EAGAIN;
+		goto out;
+	}
+
 	/*
 	 * clear default_lmv only if intent_getattr reply doesn't contain it.
 	 * but it needs to be done after iget, check this early because
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index c6779eb..5662f44 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -56,13 +56,12 @@ enum se_stat {
 
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
@@ -74,10 +73,6 @@ struct sa_entry {
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
@@ -137,12 +132,6 @@ static inline int sa_sent_full(struct ll_statahead_info *sai)
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
@@ -328,61 +317,61 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 }
 
 /* finish async stat RPC arguments */
-static void sa_fini_data(struct md_enqueue_info *minfo)
+static void sa_fini_data(struct md_op_item *item)
 {
-	struct md_op_data *op_data = &minfo->mi_data;
+	struct md_op_data *op_data = &item->mop_data;
 
 	if (op_data->op_flags & MF_OPNAME_KMALLOCED)
 		/* allocated via ll_setup_filename called from sa_prep_data */
 		kfree(op_data->op_name);
-	ll_unlock_md_op_lsm(&minfo->mi_data);
-	iput(minfo->mi_dir);
-	kfree(minfo);
+	ll_unlock_md_op_lsm(op_data);
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
+		return (struct md_op_item *)op_data;
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
 	einfo->ei_req_slot = 1;
 
-	return minfo;
+	return item;
 }
 
 /*
@@ -393,22 +382,8 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
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
@@ -465,7 +440,6 @@ static struct ll_statahead_info *ll_sai_alloc(struct dentry *dentry)
 	sai->sai_index = 1;
 	init_waitqueue_head(&sai->sai_waitq);
 
-	INIT_LIST_HEAD(&sai->sai_interim_entries);
 	INIT_LIST_HEAD(&sai->sai_entries);
 	INIT_LIST_HEAD(&sai->sai_agls);
 
@@ -528,7 +502,6 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 		LASSERT(sai->sai_task == NULL);
 		LASSERT(sai->sai_agl_task == NULL);
 		LASSERT(sai->sai_sent == sai->sai_replied);
-		LASSERT(!sa_has_callback(sai));
 
 		list_for_each_entry_safe(entry, next, &sai->sai_entries,
 					 se_list)
@@ -618,52 +591,18 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 	iput(inode);
 }
 
-/*
- * prepare inode for sa entry, add it into agl list, now sa_entry is ready
- * to be used by scanner process.
- */
-static void sa_instantiate(struct ll_statahead_info *sai,
-			   struct sa_entry *entry)
+static int ll_statahead_interpret_common(struct inode *dir,
+					 struct ll_statahead_info *sai,
+					 struct req_capsule *pill,
+					 struct lookup_intent *it,
+					 struct sa_entry *entry,
+					 struct mdt_body *body)
 {
-	struct inode *dir = sai->sai_dentry->d_inode;
 	struct inode *child;
-	struct md_enqueue_info *minfo;
-	struct lookup_intent *it;
-	struct ptlrpc_request *req;
-	struct mdt_body	*body;
-	int rc = 0;
-
-	LASSERT(entry->se_handle != 0);
-
-	minfo = entry->se_minfo;
-	it = &minfo->mi_it;
-	req = entry->se_req;
-	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	if (!body) {
-		rc = -EFAULT;
-		goto out;
-	}
+	int rc;
 
 	child = entry->se_inode;
-	/* revalidate; unlinked and re-created with the same name */
-	if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2, &body->mbo_fid1))) {
-		if (child) {
-			entry->se_inode = NULL;
-			iput(child);
-		}
-		/* The mdt_body is invalid. Skip this entry */
-		rc = -EAGAIN;
-		goto out;
-	}
-
-	it->it_lock_handle = entry->se_handle;
-	rc = md_revalidate_lock(ll_i2mdexp(dir), it, ll_inode2fid(dir), NULL);
-	if (rc != 1) {
-		rc = -EAGAIN;
-		goto out;
-	}
-
-	rc = ll_prep_inode(&child, &req->rq_pill, dir->i_sb, it);
+	rc = ll_prep_inode(&child, pill, dir->i_sb, it);
 	if (rc)
 		goto out;
 
@@ -671,10 +610,8 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 	 * inode now to save an extra getxattr.
 	 */
 	if (body->mbo_valid & OBD_MD_ENCCTX) {
-		void *encctx = req_capsule_server_get(&req->rq_pill,
-						      &RMF_FILE_ENCCTX);
-		u32 encctxlen = req_capsule_get_size(&req->rq_pill,
-						     &RMF_FILE_ENCCTX,
+		void *encctx = req_capsule_server_get(pill, &RMF_FILE_ENCCTX);
+		u32 encctxlen = req_capsule_get_size(pill, &RMF_FILE_ENCCTX,
 						     RCL_SERVER);
 
 		if (encctxlen) {
@@ -691,7 +628,7 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 		}
 	}
 
-	CDEBUG(D_READA, "%s: setting %.*s" DFID " l_data to inode %p\n",
+	CDEBUG(D_READA, "%s: setting %.*s"DFID" l_data to inode %p\n",
 	       ll_i2sbi(dir)->ll_fsname, entry->se_qstr.len,
 	       entry->se_qstr.name, PFID(ll_inode2fid(child)), child);
 	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, child, it, NULL);
@@ -700,51 +637,100 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 
 	if (agl_should_run(sai, child))
 		ll_agl_add(sai, child, entry->se_index);
-
 out:
+	return rc;
+}
+
+static void ll_statahead_interpret_fini(struct ll_inode_info *lli,
+					struct ll_statahead_info *sai,
+					struct md_op_item *item,
+					struct sa_entry *entry,
+					struct ptlrpc_request *req,
+					int rc)
+{
 	/*
-	 * sa_make_ready() will drop ldlm ibits lock refcount by calling
+	 * First it will drop ldlm ibits lock refcount by calling
 	 * ll_intent_drop_lock() in spite of failures. Do not worry about
 	 * calling ll_intent_drop_lock() more than once.
 	 */
+	ll_intent_release(&item->mop_it);
+	sa_fini_data(item);
+	if (req)
+		ptlrpc_req_finished(req);
 	sa_make_ready(sai, entry, rc);
+
+	spin_lock(&lli->lli_sa_lock);
+	sai->sai_replied++;
+	spin_unlock(&lli->lli_sa_lock);
 }
 
-/* once there are async stat replies, instantiate sa_entry from replies */
-static void sa_handle_callback(struct ll_statahead_info *sai)
+static void ll_statahead_interpret_work(struct work_struct *data)
 {
-	struct ll_inode_info *lli;
+	struct ll_interpret_work *work = container_of(data,
+						     struct ll_interpret_work,
+						     lpw_work);
+	struct md_op_item *item = work->lpw_item;
+	struct req_capsule *pill = work->lpw_pill;
+	struct inode *dir = item->mop_dir;
+	struct ll_inode_info *lli = ll_i2info(dir);
+	struct ll_statahead_info *sai = lli->lli_sai;
+	struct lookup_intent *it;
+	struct sa_entry *entry;
+	struct mdt_body *body;
+	struct inode *child;
+	int rc;
 
-	lli = ll_i2info(sai->sai_dentry->d_inode);
+	entry = (struct sa_entry *)item->mop_cbdata;
+	LASSERT(entry->se_handle != 0);
 
-	spin_lock(&lli->lli_sa_lock);
-	while (sa_has_callback(sai)) {
-		struct sa_entry *entry;
+	it = &item->mop_it;
+	body = req_capsule_server_get(pill, &RMF_MDT_BODY);
+	if (!body) {
+		rc = -EFAULT;
+		goto out;
+	}
 
-		entry = list_first_entry(&sai->sai_interim_entries,
-					 struct sa_entry, se_list);
-		list_del_init(&entry->se_list);
-		spin_unlock(&lli->lli_sa_lock);
+	child = entry->se_inode;
+	/* revalidate; unlinked and re-created with the same name */
+	if (unlikely(!lu_fid_eq(&item->mop_data.op_fid2, &body->mbo_fid1))) {
+		if (child) {
+			entry->se_inode = NULL;
+			iput(child);
+		}
+		/* The mdt_body is invalid. Skip this entry */
+		rc = -EAGAIN;
+		goto out;
+	}
 
-		sa_instantiate(sai, entry);
-		spin_lock(&lli->lli_sa_lock);
+	it->it_lock_handle = entry->se_handle;
+	rc = md_revalidate_lock(ll_i2mdexp(dir), it, ll_inode2fid(dir), NULL);
+	if (rc != 1) {
+		rc = -EAGAIN;
+		goto out;
 	}
-	spin_unlock(&lli->lli_sa_lock);
+
+	LASSERT(it->it_extra_rpc_check == 0);
+	rc = ll_statahead_interpret_common(dir, sai, pill, it, entry, body);
+out:
+	ll_statahead_interpret_fini(lli, sai, item, entry, pill->rc_req, rc);
+	kfree(work);
 }
 
 /*
- * callback for async stat RPC, because this is called in ptlrpcd context, we
- * only put sa_entry in sai_interim_entries, and wake up statahead thread to
- * really prepare inode and instantiate sa_entry later.
+ * Callback for async stat RPC, this is called in ptlrpcd context. It prepares
+ * the inode and set lock data directly in the ptlrpcd context. It will wake up
+ * the directory listing process if the dentry is the waiting one.
  */
-static int ll_statahead_interpret(struct ptlrpc_request *req,
-				  struct md_enqueue_info *minfo, int rc)
+static int ll_statahead_interpret(struct req_capsule *pill,
+				  struct md_op_item *item, int rc)
 {
-	struct lookup_intent *it = &minfo->mi_it;
-	struct inode *dir = minfo->mi_dir;
+	struct lookup_intent *it = &item->mop_it;
+	struct inode *dir = item->mop_dir;
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
-	struct sa_entry *entry = (struct sa_entry *)minfo->mi_cbdata;
+	struct sa_entry *entry = (struct sa_entry *)item->mop_cbdata;
+	struct mdt_body *body;
+	struct inode *child;
 	u64 handle = 0;
 
 	if (it_disposition(it, DISP_LOOKUP_NEG))
@@ -760,10 +746,37 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	CDEBUG(D_READA, "sa_entry %.*s rc %d\n",
 	       entry->se_qstr.len, entry->se_qstr.name, rc);
 
-	if (rc) {
-		ll_intent_release(it);
-		sa_fini_data(minfo);
-	} else {
+	if (rc)
+		goto out;
+
+	body = req_capsule_server_get(pill, &RMF_MDT_BODY);
+	if (!body) {
+		rc = -EFAULT;
+		goto out;
+	}
+
+	child = entry->se_inode;
+	/* revalidate; unlinked and re-created with the same name */
+	if (unlikely(!lu_fid_eq(&item->mop_data.op_fid2, &body->mbo_fid1))) {
+		if (child) {
+			entry->se_inode = NULL;
+			iput(child);
+		}
+		/* The mdt_body is invalid. Skip this entry */
+		rc = -EAGAIN;
+		goto out;
+	}
+
+	entry->se_handle = it->it_lock_handle;
+	/*
+	 * In ptlrpcd context, it is not allowed to generate new RPCs
+	 * especially for striped directories.
+	 */
+	it->it_extra_rpc_check = 1;
+	rc = ll_statahead_interpret_common(dir, sai, pill, it, entry, body);
+	if (rc == -EAGAIN && it->it_extra_rpc_need) {
+		struct ll_interpret_work *work;
+
 		/*
 		 * release ibits lock ASAP to avoid deadlock when statahead
 		 * thread enqueues lock on parent in readdir and another
@@ -772,53 +785,53 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 		 */
 		handle = it->it_lock_handle;
 		ll_intent_drop_lock(it);
-		ll_unlock_md_op_lsm(&minfo->mi_data);
-	}
-
-	spin_lock(&lli->lli_sa_lock);
-	if (rc) {
-		if (__sa_make_ready(sai, entry, rc))
-			wake_up(&sai->sai_waitq);
-	} else {
-		int first = 0;
+		ll_unlock_md_op_lsm(&item->mop_data);
+		it->it_extra_rpc_check = 0;
+		it->it_extra_rpc_need = 0;
 
-		entry->se_minfo = minfo;
-		entry->se_req = ptlrpc_request_addref(req);
 		/*
-		 * Release the async ibits lock ASAP to avoid deadlock
-		 * when statahead thread tries to enqueue lock on parent
-		 * for readpage and other tries to enqueue lock on child
-		 * with parent's lock held, for example: unlink.
+		 * If the stat-ahead entry is a striped directory, there are two
+		 * solutions:
+		 * 1. It can drop the result, let the scanning process do stat()
+		 * on the striped directory in synchronous way. By this way, it
+		 * can avoid to generate new RPCs to obtain the attributes for
+		 * slaves of the striped directory in the ptlrpcd context as it
+		 * is dangerous of blocking in ptlrpcd thread.
+		 * 2. Use work queue or the separate statahead thread to handle
+		 * the extra RPCs (@ll_prep_inode->@lmv_revalidate_slaves).
+		 * Here we adopt the second solution.
 		 */
-		entry->se_handle = handle;
-		if (!sa_has_callback(sai))
-			first = 1;
-
-		list_add_tail(&entry->se_list, &sai->sai_interim_entries);
-
-		if (first && sai->sai_task)
-			wake_up_process(sai->sai_task);
+		work = kmalloc(sizeof(*work), GFP_ATOMIC);
+		if (!work) {
+			rc = -ENOMEM;
+			goto out;
+		}
+		INIT_WORK(&work->lpw_work, ll_statahead_interpret_work);
+		work->lpw_item = item;
+		work->lpw_pill = pill;
+		ptlrpc_request_addref(pill->rc_req);
+		schedule_work(&work->lpw_work);
+		return 0;
 	}
-	sai->sai_replied++;
-
-	spin_unlock(&lli->lli_sa_lock);
 
+out:
+	ll_statahead_interpret_fini(lli, sai, item, entry, NULL, rc);
 	return rc;
 }
 
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
@@ -838,7 +851,7 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 		.it_op = IT_GETATTR,
 		.it_lock_handle = 0
 	};
-	struct md_enqueue_info *minfo;
+	struct md_op_item *item;
 	int rc;
 
 	if (unlikely(!inode))
@@ -847,9 +860,9 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
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
@@ -857,15 +870,15 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
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
@@ -1040,10 +1053,8 @@ static int ll_statahead_thread(void *arg)
 			break;
 		}
 
-		sai->sai_in_readpage = 1;
 		page = ll_get_dir_page(dir, op_data, pos, NULL);
 		ll_unlock_md_op_lsm(op_data);
-		sai->sai_in_readpage = 0;
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
 			CDEBUG(D_READA,
@@ -1108,11 +1119,6 @@ static int ll_statahead_thread(void *arg)
 
 			while (({set_current_state(TASK_IDLE);
 				 sai->sai_task; })) {
-				if (sa_has_callback(sai)) {
-					__set_current_state(TASK_RUNNING);
-					sa_handle_callback(sai);
-				}
-
 				spin_lock(&lli->lli_agl_lock);
 				while (sa_sent_full(sai) &&
 				       !agl_list_empty(sai)) {
@@ -1191,16 +1197,11 @@ static int ll_statahead_thread(void *arg)
 
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
@@ -1215,9 +1216,6 @@ static int ll_statahead_thread(void *arg)
 		msleep(125);
 	}
 
-	/* release resources held by statahead RPCs */
-	sa_handle_callback(sai);
-
 	CDEBUG(D_READA, "statahead thread stopped: sai %p, parent %pd\n",
 	       sai, parent);
 
@@ -1502,10 +1500,6 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		goto out_unplug;
 	}
 
-	/* if statahead is busy in readdir, help it do post-work */
-	if (!sa_ready(entry) && sai->sai_in_readpage)
-		sa_handle_callback(sai);
-
 	if (!sa_ready(entry)) {
 		spin_lock(&lli->lli_sa_lock);
 		sai->sai_index_wait = entry->se_index;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 0988b1a..e10d1bf 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3626,9 +3626,9 @@ static int lmv_clear_open_replay_data(struct obd_export *exp,
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
@@ -3652,7 +3652,7 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
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
index ae55cc3..31c5bc0 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -49,7 +49,7 @@
 
 struct mdc_getattr_args {
 	struct obd_export	*ga_exp;
-	struct md_enqueue_info	*ga_minfo;
+	struct md_op_item	*ga_item;
 };
 
 int it_open_error(int phase, struct lookup_intent *it)
@@ -1365,10 +1365,10 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
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
 
@@ -1393,18 +1393,18 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	if (rc)
 		goto out;
 
-	rc = mdc_finish_intent_lock(exp, req, &minfo->mi_data, it, lockh);
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
@@ -1433,11 +1433,11 @@ int mdc_intent_getattr_async(struct obd_export *exp,
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
@@ -1445,7 +1445,7 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 
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
