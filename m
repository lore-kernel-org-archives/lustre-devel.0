Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 783CDECAAA1
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:24:34 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MynfR1Wh7z20rR;
	Thu, 27 Oct 2022 07:11:27 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Myndq3bHwz1y5x
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:10:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 895C91009106;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8699EFD4F2; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:37 -0400
Message-Id: <1666879542-10737-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/15] lustre: statahead: avoid to block
 ptlrpcd interpret context
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

If a stat-ahead entry is a striped directory or a regular file
with layout change, it will generate a new RPC and block ptlrpcd
interpret context for a long time.
However, it is dangerous of blocking in ptlrpcd thread as it may
result in deadlock.

The following is the stack trace for the timeout of replay-dual
test_26:
task:ptlrpcd_00_01   state:I stack:    0 pid: 8026 ppid:     2
osc_extent_wait+0x44d/0x560 [osc]
osc_cache_wait_range+0x2b8/0x930 [osc]
osc_io_fsync_end+0x67/0x80 [osc]
cl_io_end+0x58/0x130 [obdclass]
lov_io_end_wrapper+0xcf/0xe0 [lov]
lov_io_fsync_end+0x6f/0x1c0 [lov]
cl_io_end+0x58/0x130 [obdclass]
cl_io_loop+0xa7/0x200 [obdclass]
cl_sync_file_range+0x2c9/0x340 [lustre]
vvp_prune+0x5d/0x1e0 [lustre]
cl_object_prune+0x58/0x130 [obdclass]
lov_layout_change.isra.47+0x1ba/0x640 [lov]
lov_conf_set+0x38d/0x4e0 [lov]
cl_conf_set+0x60/0x140 [obdclass]
cl_file_inode_init+0xc8/0x380 [lustre]
ll_update_inode+0x432/0x6e0 [lustre]
ll_iget+0x227/0x320 [lustre]
ll_prep_inode+0x344/0xb60 [lustre]
ll_statahead_interpret_common.isra.26+0x69/0x830 [lustre]
ll_statahead_interpret+0x2c8/0x5b0 [lustre]
mdc_intent_getattr_async_interpret+0x14a/0x3e0 [mdc]
ptlrpc_check_set+0x5b8/0x1fe0 [ptlrpc]
ptlrpcd+0x6c6/0xa50 [ptlrpc]

In this patch, we use work queue to handle the extra RPC and long
wait in a separate thread for a striped directory and a regular
file with layout change:
    (@ll_prep_inode->@lmv_revalidate_slaves);
    (@ll_prep_inode->@lov_layout_change->osc_cache_wait_range)

WC-bug-id: https://jira.whamcloud.com/browse/LU-16139
Lustre-commit: 2e089743901433855 ("LU-16139 statahead: avoid to block ptlrpcd interpret context")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48451
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_intent.h |   2 -
 fs/lustre/include/obd.h           |   6 +-
 fs/lustre/llite/llite_internal.h  |   6 --
 fs/lustre/llite/llite_lib.c       |   8 --
 fs/lustre/llite/statahead.c       | 173 +++++++++++++++-----------------------
 fs/lustre/mdc/mdc_locks.c         |   3 +-
 6 files changed, 73 insertions(+), 125 deletions(-)

diff --git a/fs/lustre/include/lustre_intent.h b/fs/lustre/include/lustre_intent.h
index 298270b..e7d81f6 100644
--- a/fs/lustre/include/lustre_intent.h
+++ b/fs/lustre/include/lustre_intent.h
@@ -50,8 +50,6 @@ struct lookup_intent {
 	u64			it_remote_lock_handle;
 	struct ptlrpc_request	*it_request;
 	unsigned int		it_lock_set:1;
-	unsigned int		it_extra_rpc_check:1;
-	unsigned int		it_extra_rpc_need:1;
 };
 
 static inline int it_disposition(struct lookup_intent *it, int flag)
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index c452da7..16f66ea 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -835,9 +835,7 @@ struct md_readdir_info {
 };
 
 struct md_op_item;
-typedef int (*md_op_item_cb_t)(struct req_capsule *pill,
-			       struct md_op_item *item,
-			       int rc);
+typedef int (*md_op_item_cb_t)(struct md_op_item *item, int rc);
 
 struct md_op_item {
 	struct md_op_data		 mop_data;
@@ -847,6 +845,8 @@ struct md_op_item {
 	md_op_item_cb_t                  mop_cb;
 	void				*mop_cbdata;
 	struct inode			*mop_dir;
+	struct req_capsule		*mop_pill;
+	struct work_struct		 mop_work;
 };
 
 struct obd_ops {
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index e7e4387..d245dd8 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1517,12 +1517,6 @@ struct ll_statahead_info {
 	atomic_t		sai_cache_count; /* entry count in cache */
 };
 
-struct ll_interpret_work {
-	struct work_struct	 lpw_work;
-	struct md_op_item	*lpw_item;
-	struct req_capsule	*lpw_pill;
-};
-
 int ll_revalidate_statahead(struct inode *dir, struct dentry **dentry,
 			    bool unplug);
 int ll_start_statahead(struct inode *dir, struct dentry *dentry, bool agl);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 645fbd9..130a723 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3095,14 +3095,6 @@ int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 	if (rc)
 		goto out;
 
-	if (S_ISDIR(md.body->mbo_mode) && md.lmv && lmv_dir_striped(md.lmv) &&
-	    it && it->it_extra_rpc_check) {
-		/* TODO: Check @lsm unchanged via @lsm_md_eq. */
-		it->it_extra_rpc_need = 1;
-		rc = -EAGAIN;
-		goto out;
-	}
-
 	/*
 	 * clear default_lmv only if intent_getattr reply doesn't contain it.
 	 * but it needs to be done after iget, check this early because
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 1f1fafd..e6ea2ee 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -329,8 +329,7 @@ static void sa_fini_data(struct md_op_item *item)
 	kfree(item);
 }
 
-static int ll_statahead_interpret(struct req_capsule *pill,
-				  struct md_op_item *item, int rc);
+static int ll_statahead_interpret(struct md_op_item *item, int rc);
 
 /*
  * prepare arguments for async stat RPC.
@@ -591,56 +590,6 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
 	iput(inode);
 }
 
-static int ll_statahead_interpret_common(struct inode *dir,
-					 struct ll_statahead_info *sai,
-					 struct req_capsule *pill,
-					 struct lookup_intent *it,
-					 struct sa_entry *entry,
-					 struct mdt_body *body)
-{
-	struct inode *child;
-	int rc;
-
-	child = entry->se_inode;
-	rc = ll_prep_inode(&child, pill, dir->i_sb, it);
-	if (rc)
-		goto out;
-
-	/* If encryption context was returned by MDT, put it in
-	 * inode now to save an extra getxattr.
-	 */
-	if (body->mbo_valid & OBD_MD_ENCCTX) {
-		void *encctx = req_capsule_server_get(pill, &RMF_FILE_ENCCTX);
-		u32 encctxlen = req_capsule_get_size(pill, &RMF_FILE_ENCCTX,
-						     RCL_SERVER);
-
-		if (encctxlen) {
-			CDEBUG(D_SEC,
-			       "server returned encryption ctx for "DFID"\n",
-			       PFID(ll_inode2fid(child)));
-			rc = ll_xattr_cache_insert(child,
-						   xattr_for_enc(child),
-						   encctx, encctxlen);
-			if (rc)
-				CWARN("%s: cannot set enc ctx for "DFID": rc = %d\n",
-				      ll_i2sbi(child)->ll_fsname,
-				      PFID(ll_inode2fid(child)), rc);
-		}
-	}
-
-	CDEBUG(D_READA, "%s: setting %.*s"DFID" l_data to inode %p\n",
-	       ll_i2sbi(dir)->ll_fsname, entry->se_qstr.len,
-	       entry->se_qstr.name, PFID(ll_inode2fid(child)), child);
-	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, child, it, NULL);
-
-	entry->se_inode = child;
-
-	if (agl_should_run(sai, child))
-		ll_agl_add(sai, child, entry->se_index);
-out:
-	return rc;
-}
-
 static void ll_statahead_interpret_fini(struct ll_inode_info *lli,
 					struct ll_statahead_info *sai,
 					struct md_op_item *item,
@@ -664,13 +613,11 @@ static void ll_statahead_interpret_fini(struct ll_inode_info *lli,
 	spin_unlock(&lli->lli_sa_lock);
 }
 
-static void ll_statahead_interpret_work(struct work_struct *data)
+static void ll_statahead_interpret_work(struct work_struct *work)
 {
-	struct ll_interpret_work *work = container_of(data,
-						     struct ll_interpret_work,
-						     lpw_work);
-	struct md_op_item *item = work->lpw_item;
-	struct req_capsule *pill = work->lpw_pill;
+	struct md_op_item *item = container_of(work, struct md_op_item,
+					       mop_work);
+	struct req_capsule *pill = item->mop_pill;
 	struct inode *dir = item->mop_dir;
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
@@ -709,11 +656,43 @@ static void ll_statahead_interpret_work(struct work_struct *data)
 		goto out;
 	}
 
-	LASSERT(it->it_extra_rpc_check == 0);
-	rc = ll_statahead_interpret_common(dir, sai, pill, it, entry, body);
+	rc = ll_prep_inode(&child, pill, dir->i_sb, it);
+	if (rc)
+		goto out;
+
+	/* If encryption context was returned by MDT, put it in
+	 * inode now to save an extra getxattr.
+	 */
+	if (body->mbo_valid & OBD_MD_ENCCTX) {
+		void *encctx = req_capsule_server_get(pill, &RMF_FILE_ENCCTX);
+		u32 encctxlen = req_capsule_get_size(pill, &RMF_FILE_ENCCTX,
+						     RCL_SERVER);
+
+		if (encctxlen) {
+			CDEBUG(D_SEC,
+			       "server returned encryption ctx for "DFID"\n",
+			       PFID(ll_inode2fid(child)));
+			rc = ll_xattr_cache_insert(child,
+						   xattr_for_enc(child),
+						   encctx, encctxlen);
+			if (rc)
+				CWARN("%s: cannot set enc ctx for "DFID": rc = %d\n",
+				      ll_i2sbi(child)->ll_fsname,
+				      PFID(ll_inode2fid(child)), rc);
+		}
+	}
+
+	CDEBUG(D_READA, "%s: setting %.*s"DFID" l_data to inode %p\n",
+	       ll_i2sbi(dir)->ll_fsname, entry->se_qstr.len,
+	       entry->se_qstr.name, PFID(ll_inode2fid(child)), child);
+	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, child, it, NULL);
+
+	entry->se_inode = child;
+
+	if (agl_should_run(sai, child))
+		ll_agl_add(sai, child, entry->se_index);
 out:
 	ll_statahead_interpret_fini(lli, sai, item, entry, pill->rc_req, rc);
-	kfree(work);
 }
 
 /*
@@ -721,14 +700,15 @@ static void ll_statahead_interpret_work(struct work_struct *data)
  * the inode and set lock data directly in the ptlrpcd context. It will wake up
  * the directory listing process if the dentry is the waiting one.
  */
-static int ll_statahead_interpret(struct req_capsule *pill,
-				  struct md_op_item *item, int rc)
+static int ll_statahead_interpret(struct md_op_item *item, int rc)
 {
+	struct req_capsule *pill = item->mop_pill;
 	struct lookup_intent *it = &item->mop_it;
 	struct inode *dir = item->mop_dir;
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
 	struct sa_entry *entry = (struct sa_entry *)item->mop_cbdata;
+	struct work_struct *work = &item->mop_work;
 	struct mdt_body *body;
 	struct inode *child;
 	u64 handle = 0;
@@ -770,50 +750,33 @@ static int ll_statahead_interpret(struct req_capsule *pill,
 	entry->se_handle = it->it_lock_handle;
 	/*
 	 * In ptlrpcd context, it is not allowed to generate new RPCs
-	 * especially for striped directories.
+	 * especially for striped directories or regular files with layout
+	 * change.
 	 */
-	it->it_extra_rpc_check = 1;
-	rc = ll_statahead_interpret_common(dir, sai, pill, it, entry, body);
-	if (rc == -EAGAIN && it->it_extra_rpc_need) {
-		struct ll_interpret_work *work;
-
-		/*
-		 * release ibits lock ASAP to avoid deadlock when statahead
-		 * thread enqueues lock on parent in readdir and another
-		 * process enqueues lock on child with parent lock held, eg.
-		 * unlink.
-		 */
-		handle = it->it_lock_handle;
-		ll_intent_drop_lock(it);
-		ll_unlock_md_op_lsm(&item->mop_data);
-		it->it_extra_rpc_check = 0;
-		it->it_extra_rpc_need = 0;
-
-		/*
-		 * If the stat-ahead entry is a striped directory, there are two
-		 * solutions:
-		 * 1. It can drop the result, let the scanning process do stat()
-		 * on the striped directory in synchronous way. By this way, it
-		 * can avoid to generate new RPCs to obtain the attributes for
-		 * slaves of the striped directory in the ptlrpcd context as it
-		 * is dangerous of blocking in ptlrpcd thread.
-		 * 2. Use work queue or the separate statahead thread to handle
-		 * the extra RPCs (@ll_prep_inode->@lmv_revalidate_slaves).
-		 * Here we adopt the second solution.
-		 */
-		work = kmalloc(sizeof(*work), GFP_ATOMIC);
-		if (!work) {
-			rc = -ENOMEM;
-			goto out;
-		}
-		INIT_WORK(&work->lpw_work, ll_statahead_interpret_work);
-		work->lpw_item = item;
-		work->lpw_pill = pill;
-		ptlrpc_request_addref(pill->rc_req);
-		schedule_work(&work->lpw_work);
-		return 0;
-	}
+	/*
+	 * release ibits lock ASAP to avoid deadlock when statahead
+	 * thread enqueues lock on parent in readdir and another
+	 * process enqueues lock on child with parent lock held, eg.
+	 * unlink.
+	 */
+	handle = it->it_lock_handle;
+	ll_intent_drop_lock(it);
+	ll_unlock_md_op_lsm(&item->mop_data);
 
+	/*
+	 * If the statahead entry is a striped directory or regular file with
+	 * layout change, it will generate a new RPC and long wait in the
+	 * ptlrpcd context.
+	 * However, it is dangerous of blocking in ptlrpcd thread.
+	 * Here we use work queue or the separate statahead thread to handle
+	 * the extra RPC and long wait:
+	 *	(@ll_prep_inode->@lmv_revalidate_slaves);
+	 *	(@ll_prep_inode->@lov_layout_change->osc_cache_wait_range);
+	 */
+	INIT_WORK(work, ll_statahead_interpret_work);
+	ptlrpc_request_addref(pill->rc_req);
+	schedule_work(work);
+	return 0;
 out:
 	ll_statahead_interpret_fini(lli, sai, item, entry, NULL, rc);
 	return rc;
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 31c5bc0..f36e0ec 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -1396,7 +1396,8 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	rc = mdc_finish_intent_lock(exp, req, &item->mop_data, it, lockh);
 
 out:
-	item->mop_cb(&req->rq_pill, item, rc);
+	item->mop_pill = &req->rq_pill;
+	item->mop_cb(item, rc);
 	return 0;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
