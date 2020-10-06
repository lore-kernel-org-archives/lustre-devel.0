From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:41 -0400
Subject: [lustre-devel] [PATCH 02/42] lustre: dom: lock cancel to drop pages
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Prevent stale pages after lock cancel by creating
cl_page connection for read-on-open pages.

This reverts 99565b37fc to fix the problem.
Since VM pages are connected to cl_object they can be
found and discarded by CLIO properly.

Fixes: 99565b37fc ("lustre: llite: optimize read on open pages")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13759
Lustre-commit: e95eca236471c ("LU-13759 dom: lock cancel to drop pages")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39401
Reviewed-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c           | 66 +++++++++++++++++++++++++++++-----------
 fs/lustre/llite/llite_internal.h |  3 +-
 fs/lustre/llite/namei.c          | 15 +++------
 fs/lustre/mdc/mdc_dev.c          |  5 +++
 4 files changed, 59 insertions(+), 30 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 17c2d88..d872cf3 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -460,9 +460,10 @@ static inline int ll_dom_readpage(void *data, struct page *page)
 	return rc;
 }
 
-void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
-			struct lookup_intent *it)
+void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req)
 {
+	struct lu_env *env;
+	struct cl_io *io;
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct cl_object *obj = lli->lli_clob;
 	struct address_space *mapping = inode->i_mapping;
@@ -472,6 +473,8 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	char *data;
 	unsigned long index, start;
 	struct niobuf_local lnb;
+	u16 refcheck;
+	int rc;
 
 	if (!obj)
 		return;
@@ -504,6 +507,16 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 		return;
 	}
 
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return;
+	io = vvp_env_thread_io(env);
+	io->ci_obj = obj;
+	io->ci_ignore_layout = 1;
+	rc = cl_io_init(env, io, CIT_MISC, obj);
+	if (rc)
+		goto out_io;
+
 	CDEBUG(D_INFO, "Get data along with open at %llu len %i, size %llu\n",
 	       rnb->rnb_offset, rnb->rnb_len, body->mbo_dom_size);
 
@@ -515,6 +528,8 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	LASSERT((lnb.lnb_file_offset & ~PAGE_MASK) == 0);
 	lnb.lnb_page_offset = 0;
 	do {
+		struct cl_page *page;
+
 		lnb.lnb_data = data + (index << PAGE_SHIFT);
 		lnb.lnb_len = rnb->rnb_len - (index << PAGE_SHIFT);
 		if (lnb.lnb_len > PAGE_SIZE)
@@ -530,9 +545,32 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 			      PTR_ERR(vmpage));
 			break;
 		}
+		lock_page(vmpage);
+		if (!vmpage->mapping) {
+			unlock_page(vmpage);
+			put_page(vmpage);
+			/* page was truncated */
+			break;
+		}
+		/* attach VM page to CL page cache */
+		page = cl_page_find(env, obj, vmpage->index, vmpage,
+				    CPT_CACHEABLE);
+		if (IS_ERR(page)) {
+			ClearPageUptodate(vmpage);
+			unlock_page(vmpage);
+			put_page(vmpage);
+			break;
+		}
+		cl_page_export(env, page, 1);
+		cl_page_put(env, page);
+		unlock_page(vmpage);
 		put_page(vmpage);
 		index++;
 	} while (rnb->rnb_len > (index << PAGE_SHIFT));
+
+out_io:
+	cl_io_fini(env, io);
+	cl_env_put(env, &refcheck);
 }
 
 static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
@@ -616,27 +654,21 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	rc = ll_prep_inode(&inode, req, NULL, itp);
 
 	if (!rc && itp->it_lock_mode) {
-		struct lustre_handle handle = {.cookie = itp->it_lock_handle};
-		struct ldlm_lock *lock;
-		bool has_dom_bit = false;
+		u64 bits = 0;
 
 		/* If we got a lock back and it has a LOOKUP bit set,
 		 * make sure the dentry is marked as valid so we can find it.
 		 * We don't need to care about actual hashing since other bits
 		 * of kernel will deal with that later.
 		 */
-		lock = ldlm_handle2lock(&handle);
-		if (lock) {
-			has_dom_bit = ldlm_has_dom(lock);
-			if (lock->l_policy_data.l_inodebits.bits &
-			    MDS_INODELOCK_LOOKUP)
-				d_lustre_revalidate(de);
-
-			LDLM_LOCK_PUT(lock);
-		}
-		ll_set_lock_data(sbi->ll_md_exp, inode, itp, NULL);
-		if (has_dom_bit)
-			ll_dom_finish_open(inode, req, itp);
+		ll_set_lock_data(sbi->ll_md_exp, inode, itp, &bits);
+		if (bits & MDS_INODELOCK_LOOKUP)
+			d_lustre_revalidate(de);
+		/* if DoM bit returned along with LAYOUT bit then there
+		 * can be read-on-open data returned.
+		 */
+		if (bits & MDS_INODELOCK_DOM && bits & MDS_INODELOCK_LAYOUT)
+			ll_dom_finish_open(inode, req);
 	}
 
 out:
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 89783fb..8a0c40c 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1156,8 +1156,7 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
 			struct lov_user_md **kbuf);
 
-void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
-			struct lookup_intent *it);
+void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req);
 
 /* Compute expected user md size when passing in a md from user space */
 static inline ssize_t ll_lov_user_md_size(const struct lov_user_md *lum)
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index a268c93..014a470 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -186,14 +186,6 @@ static int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 	u16 refcheck;
 	int rc;
 
-	if (!lli->lli_clob) {
-		/* Due to DoM read on open, there may exist pages for Lustre
-		 * regular file even though cl_object is not set up yet.
-		 */
-		truncate_inode_pages(inode->i_mapping, 0);
-		return 0;
-	}
-
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
 		return PTR_ERR(env);
@@ -659,10 +651,11 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			}
 		}
 
-		if (it->it_op & IT_OPEN)
-			ll_dom_finish_open(inode, request, it);
-
 		ll_set_lock_data(ll_i2sbi(parent)->ll_md_exp, inode, it, &bits);
+		/* OPEN can return data if lock has DoM+LAYOUT bits set */
+		if (it->it_op & IT_OPEN &&
+		    bits & MDS_INODELOCK_DOM && bits & MDS_INODELOCK_LAYOUT)
+			ll_dom_finish_open(inode, request);
 
 		/* We used to query real size from OSTs here, but actually
 		 * this is not needed. For stat() calls size would be updated
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index eb2cc91..d6d98ae 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1406,6 +1406,11 @@ int mdc_object_prune(const struct lu_env *env, struct cl_object *obj)
 static int mdc_object_flush(const struct lu_env *env, struct cl_object *obj,
 			    struct ldlm_lock *lock)
 {
+	/* if lock cancel is initiated from llite then it is combined
+	 * lock with DOM bit and it may have no l_ast_data initialized yet,
+	 * so init it here with given osc_object.
+	 */
+	mdc_set_dom_lock_data(lock, cl2osc(obj));
 	return mdc_dlm_blocking_ast0(env, lock, LDLM_CB_CANCELING);
 }
 
-- 
1.8.3.1
