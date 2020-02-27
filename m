From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:16 -0500
Subject: [lustre-devel] [PATCH 148/622] lustre: llite: optimize read on open
 pages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-149-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@uber.com>

Current read-on-open implementation does allocate cl_page after data
are piggied back by open request, which is expensive and not
necessary.

This patch improves the case by just adding the pages into page cache.
As long as those pages will be discarded at lock revocation, there
should be no concerns.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11427
Lustre-commit: 02e766f5ed95 ("LU-11427 llite: optimize read on open pages")
Signed-off-by: Jinshan Xiong <jinshan.xiong@uber.com>
Reviewed-on: https://review.whamcloud.com/33234
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c  | 58 +++++--------------------------------------------
 fs/lustre/llite/namei.c |  7 +++++-
 2 files changed, 11 insertions(+), 54 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index a46f5d3..2fd906f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -420,14 +420,10 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	struct page *vmpage;
 	struct niobuf_remote *rnb;
 	char *data;
-	struct lu_env *env;
-	struct cl_io *io;
-	u16 refcheck;
 	struct lustre_handle lockh;
 	struct ldlm_lock *lock;
 	unsigned long index, start;
 	struct niobuf_local lnb;
-	int rc;
 	bool dom_lock = false;
 
 	if (!obj)
@@ -440,37 +436,21 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 			dom_lock = ldlm_has_dom(lock);
 		LDLM_LOCK_PUT(lock);
 	}
-
 	if (!dom_lock)
 		return;
 
-	env = cl_env_get(&refcheck);
-	if (IS_ERR(env))
-		return;
-
 	if (!req_capsule_has_field(&req->rq_pill, &RMF_NIOBUF_INLINE,
-				   RCL_SERVER)) {
-		rc = -ENODATA;
-		goto out_env;
-	}
+				   RCL_SERVER))
+		return;
 
 	rnb = req_capsule_server_get(&req->rq_pill, &RMF_NIOBUF_INLINE);
-	data = (char *)rnb + sizeof(*rnb);
-
-	if (!rnb || rnb->rnb_len == 0) {
-		rc = 0;
-		goto out_env;
-	}
+	if (!rnb || rnb->rnb_len == 0)
+		return;
 
 	CDEBUG(D_INFO, "Get data buffer along with open, len %i, i_size %llu\n",
 	       rnb->rnb_len, i_size_read(inode));
 
-	io = vvp_env_thread_io(env);
-	io->ci_obj = obj;
-	io->ci_ignore_layout = 1;
-	rc = cl_io_init(env, io, CIT_MISC, obj);
-	if (rc)
-		goto out_io;
+	data = (char *)rnb + sizeof(*rnb);
 
 	lnb.lnb_file_offset = rnb->rnb_offset;
 	start = lnb.lnb_file_offset / PAGE_SIZE;
@@ -478,8 +458,6 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	LASSERT(lnb.lnb_file_offset % PAGE_SIZE == 0);
 	lnb.lnb_page_offset = 0;
 	do {
-		struct cl_page *clp;
-
 		lnb.lnb_data = data + (index << PAGE_SHIFT);
 		lnb.lnb_len = rnb->rnb_len - (index << PAGE_SHIFT);
 		if (lnb.lnb_len > PAGE_SIZE)
@@ -495,35 +473,9 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 			      PTR_ERR(vmpage));
 			break;
 		}
-		lock_page(vmpage);
-		if (!vmpage->mapping) {
-			unlock_page(vmpage);
-			put_page(vmpage);
-			/* page was truncated */
-			rc = -ENODATA;
-			goto out_io;
-		}
-		clp = cl_page_find(env, obj, vmpage->index, vmpage,
-				   CPT_CACHEABLE);
-		if (IS_ERR(clp)) {
-			unlock_page(vmpage);
-			put_page(vmpage);
-			rc = PTR_ERR(clp);
-			goto out_io;
-		}
-
-		/* export page */
-		cl_page_export(env, clp, 1);
-		cl_page_put(env, clp);
-		unlock_page(vmpage);
 		put_page(vmpage);
 		index++;
 	} while (rnb->rnb_len > (index << PAGE_SHIFT));
-	rc = 0;
-out_io:
-	cl_io_fini(env, io);
-out_env:
-	cl_env_put(env, &refcheck);
 }
 
 static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 4ac62b2..530c2df 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -185,8 +185,13 @@ int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 	int rc;
 	u16 refcheck;
 
-	if (!lli->lli_clob)
+	if (!lli->lli_clob) {
+		/* Due to DoM read on open, there may exist pages for Lustre
+		 * regular file even though cl_object is not set up yet.
+		 */
+		truncate_inode_pages(inode->i_mapping, 0);
 		return 0;
+	}
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
-- 
1.8.3.1
