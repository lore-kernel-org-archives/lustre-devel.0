From: James Simmons <jsimmons@infradead.org>
Date: Fri, 19 Aug 2016 14:07:26 -0400
Subject: [lustre-devel] [PATCH 2/7] staging: lustre: llite: move dir cache
	to MDC layer
In-Reply-To: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471630051-26700-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Move directory entries cache from llite to MDC, so client
side dir stripe will use independent hash function(in LMV),
which does not need to be tightly coupled with the backend
storage dir-entry hash function. With striped directory, it
will be 2-tier hash, LMV calculate hash value according to the
name and hash-type in layout, then each MDT will store these
entry in disk by its own hash.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-on: http://review.whamcloud.com/7043
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_lite.h    |   11 -
 drivers/staging/lustre/lustre/llite/dir.c          |  334 +------------
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    8 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  531 ++++++++++++++++++++
 6 files changed, 563 insertions(+), 335 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lite.h b/drivers/staging/lustre/lustre/include/lustre_lite.h
index a3d7573..e2f3767 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lite.h
@@ -80,17 +80,6 @@ static inline void ll_dir_chain_fini(struct ll_dir_chain *chain)
 {
 }
 
-static inline unsigned long hash_x_index(__u64 hash, int hash64)
-{
-	if (BITS_PER_LONG == 32 && hash64)
-		hash >>= 32;
-	/* save hash 0 as index 0 because otherwise we'll save it at
-	 * page index end (~0UL) and it causes truncate_inode_pages_range()
-	 * to loop forever.
-	 */
-	return ~0UL - (hash + !hash);
-}
-
 /** @} lite */
 
 #endif
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index ed09015..532047b 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -134,111 +134,35 @@
  * for this integrated page will be adjusted. See lmv_adjust_dirpages().
  *
  */
-
-/* returns the page unlocked, but with a reference */
-static int ll_dir_filler(void *_hash, struct page *page0)
+struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
+			     __u64 offset, struct ll_dir_chain *chain)
 {
-	struct inode *inode = page0->mapping->host;
-	int hash64 = ll_i2sbi(inode)->ll_flags & LL_SBI_64BIT_HASH;
-	struct obd_export *exp = ll_i2sbi(inode)->ll_md_exp;
-	struct ptlrpc_request *request;
-	struct mdt_body *body;
-	struct md_op_data *op_data;
-	__u64 hash = *((__u64 *)_hash);
-	struct page **page_pool;
+	struct md_callback cb_op;
 	struct page *page;
-	struct lu_dirpage *dp;
-	int max_pages = ll_i2sbi(inode)->ll_md_brw_pages;
-	int nrdpgs = 0; /* number of pages read actually */
-	int npages;
-	int i;
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) hash %llu\n",
-	       PFID(ll_inode2fid(inode)), inode, hash);
-
-	LASSERT(max_pages > 0 && max_pages <= MD_MAX_BRW_PAGES);
-
-	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
-				     LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
-
-	page_pool = kcalloc(max_pages, sizeof(page), GFP_NOFS);
-	if (page_pool) {
-		page_pool[0] = page0;
-	} else {
-		page_pool = &page0;
-		max_pages = 1;
-	}
-	for (npages = 1; npages < max_pages; npages++) {
-		page = page_cache_alloc_cold(inode->i_mapping);
-		if (!page)
-			break;
-		page_pool[npages] = page;
-	}
-
-	op_data->op_npages = npages;
-	op_data->op_offset = hash;
-	rc = md_readpage(exp, op_data, page_pool, &request);
-	ll_finish_md_op_data(op_data);
-	if (rc < 0) {
-		/* page0 is special, which was added into page cache early */
-		delete_from_page_cache(page0);
-	} else if (rc == 0) {
-		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
-		/* Checked by mdc_readpage() */
-		if (body->mbo_valid & OBD_MD_FLSIZE)
-			i_size_write(inode, body->mbo_size);
-
-		nrdpgs = (request->rq_bulk->bd_nob_transferred+PAGE_SIZE-1)
-			 >> PAGE_SHIFT;
-		SetPageUptodate(page0);
-	}
-	unlock_page(page0);
-	ptlrpc_req_finished(request);
-
-	CDEBUG(D_VFSTRACE, "read %d/%d pages\n", nrdpgs, npages);
-
-	for (i = 1; i < npages; i++) {
-		unsigned long offset;
-		int ret;
-
-		page = page_pool[i];
-
-		if (rc < 0 || i >= nrdpgs) {
-			put_page(page);
-			continue;
-		}
-
-		SetPageUptodate(page);
-
-		dp = kmap(page);
-		hash = le64_to_cpu(dp->ldp_hash_start);
-		kunmap(page);
-
-		offset = hash_x_index(hash, hash64);
-
-		prefetchw(&page->flags);
-		ret = add_to_page_cache_lru(page, inode->i_mapping, offset,
-					    GFP_NOFS);
-		if (ret == 0) {
-			unlock_page(page);
-		} else {
-			CDEBUG(D_VFSTRACE, "page %lu add to page cache failed: %d\n",
-			       offset, ret);
-		}
-		put_page(page);
-	}
+	cb_op.md_blocking_ast = ll_md_blocking_ast;
+	rc = md_read_page(ll_i2mdexp(dir), op_data, &cb_op, offset, &page);
+	if (rc)
+		return ERR_PTR(rc);
 
-	if (page_pool != &page0)
-		kfree(page_pool);
-	return rc;
+	return page;
 }
 
 void ll_release_page(struct inode *inode, struct page *page, bool remove)
 {
 	kunmap(page);
+
+	/*
+	 * Always remove the page for striped dir, because the page is
+	 * built from temporarily in LMV layer
+	 */
+	if (inode && S_ISDIR(inode->i_mode) &&
+	    ll_i2info(inode)->lli_lsm_md) {
+		__free_page(page);
+		return;
+	}
+
 	if (remove) {
 		lock_page(page);
 		if (likely(page->mapping))
@@ -248,226 +172,6 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
 	put_page(page);
 }
 
-/*
- * Find, kmap and return page that contains given hash.
- */
-static struct page *ll_dir_page_locate(struct inode *dir, __u64 *hash,
-				       __u64 *start, __u64 *end)
-{
-	int hash64 = ll_i2sbi(dir)->ll_flags & LL_SBI_64BIT_HASH;
-	struct address_space *mapping = dir->i_mapping;
-	/*
-	 * Complement of hash is used as an index so that
-	 * radix_tree_gang_lookup() can be used to find a page with starting
-	 * hash _smaller_ than one we are looking for.
-	 */
-	unsigned long offset = hash_x_index(*hash, hash64);
-	struct page *page;
-	int found;
-
-	spin_lock_irq(&mapping->tree_lock);
-	found = radix_tree_gang_lookup(&mapping->page_tree,
-				       (void **)&page, offset, 1);
-	if (found > 0 && !radix_tree_exceptional_entry(page)) {
-		struct lu_dirpage *dp;
-
-		get_page(page);
-		spin_unlock_irq(&mapping->tree_lock);
-		/*
-		 * In contrast to find_lock_page() we are sure that directory
-		 * page cannot be truncated (while DLM lock is held) and,
-		 * hence, can avoid restart.
-		 *
-		 * In fact, page cannot be locked here at all, because
-		 * ll_dir_filler() does synchronous io.
-		 */
-		wait_on_page_locked(page);
-		if (PageUptodate(page)) {
-			dp = kmap(page);
-			if (BITS_PER_LONG == 32 && hash64) {
-				*start = le64_to_cpu(dp->ldp_hash_start) >> 32;
-				*end   = le64_to_cpu(dp->ldp_hash_end) >> 32;
-				*hash  = *hash >> 32;
-			} else {
-				*start = le64_to_cpu(dp->ldp_hash_start);
-				*end   = le64_to_cpu(dp->ldp_hash_end);
-			}
-			LASSERTF(*start <= *hash, "start = %#llx,end = %#llx,hash = %#llx\n",
-				 *start, *end, *hash);
-			CDEBUG(D_VFSTRACE, "page %lu [%llu %llu], hash %llu\n",
-			       offset, *start, *end, *hash);
-			if (*hash > *end) {
-				ll_release_page(dir, page, false);
-				page = NULL;
-			} else if (*end != *start && *hash == *end) {
-				/*
-				 * upon hash collision, remove this page,
-				 * otherwise put page reference, and
-				 * ll_get_dir_page() will issue RPC to fetch
-				 * the page we want.
-				 */
-				ll_release_page(dir, page,
-						le32_to_cpu(dp->ldp_flags) &
-						LDF_COLLIDE);
-				page = NULL;
-			}
-		} else {
-			put_page(page);
-			page = ERR_PTR(-EIO);
-		}
-
-	} else {
-		spin_unlock_irq(&mapping->tree_lock);
-		page = NULL;
-	}
-	return page;
-}
-
-struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
-			     __u64 hash, struct ll_dir_chain *chain)
-{
-	ldlm_policy_data_t policy = {.l_inodebits = {MDS_INODELOCK_UPDATE} };
-	struct address_space *mapping = dir->i_mapping;
-	struct lustre_handle lockh;
-	struct lu_dirpage *dp;
-	struct page *page;
-	enum ldlm_mode mode;
-	int rc;
-	__u64 start = 0;
-	__u64 end = 0;
-	__u64 lhash = hash;
-	struct ll_inode_info *lli = ll_i2info(dir);
-	int hash64 = ll_i2sbi(dir)->ll_flags & LL_SBI_64BIT_HASH;
-
-	mode = LCK_PR;
-	rc = md_lock_match(ll_i2sbi(dir)->ll_md_exp, LDLM_FL_BLOCK_GRANTED,
-			   ll_inode2fid(dir), LDLM_IBITS, &policy, mode, &lockh);
-	if (!rc) {
-		struct ldlm_enqueue_info einfo = {
-			.ei_type = LDLM_IBITS,
-			.ei_mode = mode,
-			.ei_cb_bl = ll_md_blocking_ast,
-			.ei_cb_cp = ldlm_completion_ast,
-		};
-		struct lookup_intent it = { .it_op = IT_READDIR };
-		struct ptlrpc_request *request;
-		struct md_op_data *op_data;
-
-		op_data = ll_prep_md_op_data(NULL, dir, dir, NULL, 0, 0,
-					     LUSTRE_OPC_ANY, NULL);
-		if (IS_ERR(op_data))
-			return (void *)op_data;
-
-		rc = md_enqueue(ll_i2sbi(dir)->ll_md_exp, &einfo, &it,
-				op_data, &lockh, NULL, 0, NULL, 0);
-
-		ll_finish_md_op_data(op_data);
-
-		request = (struct ptlrpc_request *)it.it_request;
-		if (request)
-			ptlrpc_req_finished(request);
-		if (rc < 0) {
-			CERROR("lock enqueue: " DFID "@%llu: rc %d\n",
-			       PFID(ll_inode2fid(dir)), hash, rc);
-			return ERR_PTR(rc);
-		}
-
-		CDEBUG(D_INODE, "setting lr_lvb_inode to inode "DFID"(%p)\n",
-		       PFID(ll_inode2fid(dir)), dir);
-		md_set_lock_data(ll_i2sbi(dir)->ll_md_exp,
-				 &it.it_lock_handle, dir, NULL);
-	} else {
-		/* for cross-ref object, l_ast_data of the lock may not be set,
-		 * we reset it here
-		 */
-		md_set_lock_data(ll_i2sbi(dir)->ll_md_exp, &lockh.cookie,
-				 dir, NULL);
-	}
-	ldlm_lock_dump_handle(D_OTHER, &lockh);
-
-	mutex_lock(&lli->lli_readdir_mutex);
-	page = ll_dir_page_locate(dir, &lhash, &start, &end);
-	if (IS_ERR(page)) {
-		CERROR("dir page locate: "DFID" at %llu: rc %ld\n",
-		       PFID(ll_inode2fid(dir)), lhash, PTR_ERR(page));
-		goto out_unlock;
-	} else if (page) {
-		/*
-		 * XXX nikita: not entirely correct handling of a corner case:
-		 * suppose hash chain of entries with hash value HASH crosses
-		 * border between pages P0 and P1. First both P0 and P1 are
-		 * cached, seekdir() is called for some entry from the P0 part
-		 * of the chain. Later P0 goes out of cache. telldir(HASH)
-		 * happens and finds P1, as it starts with matching hash
-		 * value. Remaining entries from P0 part of the chain are
-		 * skipped. (Is that really a bug?)
-		 *
-		 * Possible solutions: 0. don't cache P1 is such case, handle
-		 * it as an "overflow" page. 1. invalidate all pages at
-		 * once. 2. use HASH|1 as an index for P1.
-		 */
-		goto hash_collision;
-	}
-
-	page = read_cache_page(mapping, hash_x_index(hash, hash64),
-			       ll_dir_filler, &lhash);
-	if (IS_ERR(page)) {
-		CERROR("read cache page: "DFID" at %llu: rc %ld\n",
-		       PFID(ll_inode2fid(dir)), hash, PTR_ERR(page));
-		goto out_unlock;
-	}
-
-	wait_on_page_locked(page);
-	(void)kmap(page);
-	if (!PageUptodate(page)) {
-		CERROR("page not updated: "DFID" at %llu: rc %d\n",
-		       PFID(ll_inode2fid(dir)), hash, -5);
-		goto fail;
-	}
-	if (!PageChecked(page))
-		/* XXX: check page format later */
-		SetPageChecked(page);
-	if (PageError(page)) {
-		CERROR("page error: "DFID" at %llu: rc %d\n",
-		       PFID(ll_inode2fid(dir)), hash, -5);
-		goto fail;
-	}
-hash_collision:
-	dp = page_address(page);
-	if (BITS_PER_LONG == 32 && hash64) {
-		start = le64_to_cpu(dp->ldp_hash_start) >> 32;
-		end   = le64_to_cpu(dp->ldp_hash_end) >> 32;
-		lhash = hash >> 32;
-	} else {
-		start = le64_to_cpu(dp->ldp_hash_start);
-		end   = le64_to_cpu(dp->ldp_hash_end);
-		lhash = hash;
-	}
-	if (end == start) {
-		LASSERT(start == lhash);
-		CWARN("Page-wide hash collision: %llu\n", end);
-		if (BITS_PER_LONG == 32 && hash64)
-			CWARN("Real page-wide hash collision at [%llu %llu] with hash %llu\n",
-			      le64_to_cpu(dp->ldp_hash_start),
-			      le64_to_cpu(dp->ldp_hash_end), hash);
-		/*
-		 * Fetch whole overflow chain...
-		 *
-		 * XXX not yet.
-		 */
-		goto fail;
-	}
-out_unlock:
-	mutex_unlock(&lli->lli_readdir_mutex);
-	ldlm_lock_decref(&lockh, mode);
-	return page;
-
-fail:
-	ll_release_page(dir, page, true);
-	page = ERR_PTR(-EIO);
-	goto out_unlock;
-}
-
 /**
  * return IF_* type for given lu_dirent entry.
  * IF_* flag shld be converted to particular OS file type in
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index b4e843a..a5a3023 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -665,7 +665,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 int ll_get_mdt_idx(struct inode *inode);
 int ll_get_mdt_idx_by_fid(struct ll_sb_info *sbi, const struct lu_fid *fid);
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
-			     __u64 hash, struct ll_dir_chain *chain);
+			     __u64 offset, struct ll_dir_chain *chain);
 void ll_release_page(struct inode *inode, struct page *page, bool remove);
 
 /* llite/namei.c */
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 454c33e..dfd51af 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1035,7 +1035,7 @@ static int ll_statahead_thread(void *arg)
 	struct ll_statahead_info *sai    = ll_sai_get(plli->lli_sai);
 	struct ptlrpc_thread     *thread = &sai->sai_thread;
 	struct ptlrpc_thread *agl_thread = &sai->sai_agl_thread;
-	struct page	      *page;
+	struct page	      *page = NULL;
 	__u64		     pos    = 0;
 	int		       first  = 0;
 	int		       rc     = 0;
@@ -1166,8 +1166,7 @@ interpret_it:
 					if (!list_empty(&sai->sai_entries_received))
 						goto interpret_it;
 
-					if (unlikely(
-						!thread_is_running(thread))) {
+					if (unlikely(!thread_is_running(thread))) {
 						ll_release_page(dir, page, false);
 						rc = 0;
 						goto out;
@@ -1182,10 +1181,10 @@ interpret_it:
 
 				goto keep_it;
 			}
-
 do_it:
 			ll_statahead_one(parent, name, namelen);
 		}
+
 		pos = le64_to_cpu(dp->ldp_hash_end);
 		if (pos == MDS_DIR_END_OFF) {
 			/*
@@ -1232,14 +1231,12 @@ do_it:
 			 * Normal case: continue to the next page.
 			 */
 			ll_release_page(dir, page,
-					le32_to_cpu(dp->ldp_flags) &
-					LDF_COLLIDE);
+					le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
 			sai->sai_in_readpage = 1;
 			page = ll_get_dir_page(dir, op_data, pos, &chain);
 			sai->sai_in_readpage = 0;
 		}
 	}
-
 out:
 	ll_finish_md_op_data(op_data);
 	if (sai->sai_agl_valid) {
@@ -1455,7 +1452,6 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			page = ll_get_dir_page(dir, op_data, pos, &chain);
 		}
 	}
-
 out:
 	ll_dir_chain_fini(&chain);
 	ll_finish_md_op_data(op_data);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 1901b93..492ebbc 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -135,4 +135,12 @@ static inline int mdc_prep_elc_req(struct obd_export *exp,
 				 count);
 }
 
+static inline unsigned long hash_x_index(__u64 hash, int hash64)
+{
+	if (BITS_PER_LONG == 32 && hash64)
+		hash >>= 32;
+	/* save hash 0 with hash 1 */
+	return ~0UL - (hash + !hash);
+}
+
 #endif
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 74ddec3..9ad855f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1019,6 +1019,536 @@ restart_bulk:
 	return 0;
 }
 
+static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
+		       u64 offset, struct page **pages, int npages,
+		       struct ptlrpc_request **request)
+{
+	struct ptlrpc_bulk_desc *desc;
+	struct ptlrpc_request *req;
+	wait_queue_head_t waitq;
+	struct l_wait_info lwi;
+	int resends = 0;
+	int rc;
+	int i;
+
+	*request = NULL;
+	init_waitqueue_head(&waitq);
+
+restart_bulk:
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_READPAGE);
+	if (!req)
+		return -ENOMEM;
+
+	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_READPAGE);
+	if (rc) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+
+	req->rq_request_portal = MDS_READPAGE_PORTAL;
+	ptlrpc_at_set_req_timeout(req);
+
+	desc = ptlrpc_prep_bulk_imp(req, npages, 1, BULK_PUT_SINK,
+				    MDS_BULK_PORTAL);
+	if (!desc) {
+		ptlrpc_request_free(req);
+		return -ENOMEM;
+	}
+
+	/* NB req now owns desc and will free it when it gets freed */
+	for (i = 0; i < npages; i++)
+		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_SIZE);
+
+	mdc_readdir_pack(req, offset, PAGE_SIZE * npages, fid);
+
+	ptlrpc_request_set_replen(req);
+	rc = ptlrpc_queue_wait(req);
+	if (rc) {
+		ptlrpc_req_finished(req);
+		if (rc != -ETIMEDOUT)
+			return rc;
+
+		resends++;
+		if (!client_should_resend(resends, &exp->exp_obd->u.cli)) {
+			CERROR("%s: too many resend retries: rc = %d\n",
+			       exp->exp_obd->obd_name, -EIO);
+			return -EIO;
+		}
+		lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(resends), NULL, NULL,
+				       NULL);
+		l_wait_event(waitq, 0, &lwi);
+
+		goto restart_bulk;
+	}
+
+	rc = sptlrpc_cli_unwrap_bulk_read(req, req->rq_bulk,
+					  req->rq_bulk->bd_nob_transferred);
+	if (rc < 0) {
+		ptlrpc_req_finished(req);
+		return rc;
+	}
+
+	if (req->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK) {
+		CERROR("%s: unexpected bytes transferred: %d (%ld expected)\n",
+		       exp->exp_obd->obd_name, req->rq_bulk->bd_nob_transferred,
+		       PAGE_SIZE * npages);
+		ptlrpc_req_finished(req);
+		return -EPROTO;
+	}
+
+	*request = req;
+	return 0;
+}
+
+static void mdc_release_page(struct page *page, int remove)
+{
+	if (remove) {
+		lock_page(page);
+		if (likely(page->mapping))
+			truncate_complete_page(page->mapping, page);
+		unlock_page(page);
+	}
+	put_page(page);
+}
+
+static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
+				    __u64 *start, __u64 *end, int hash64)
+{
+	/*
+	 * Complement of hash is used as an index so that
+	 * radix_tree_gang_lookup() can be used to find a page with starting
+	 * hash _smaller_ than one we are looking for.
+	 */
+	unsigned long offset = hash_x_index(*hash, hash64);
+	struct page *page;
+	int found;
+
+	spin_lock_irq(&mapping->tree_lock);
+	found = radix_tree_gang_lookup(&mapping->page_tree,
+				       (void **)&page, offset, 1);
+	if (found > 0 && !radix_tree_exceptional_entry(page)) {
+		struct lu_dirpage *dp;
+
+		get_page(page);
+		spin_unlock_irq(&mapping->tree_lock);
+		/*
+		 * In contrast to find_lock_page() we are sure that directory
+		 * page cannot be truncated (while DLM lock is held) and,
+		 * hence, can avoid restart.
+		 *
+		 * In fact, page cannot be locked here at all, because
+		 * mdc_read_page_remote does synchronous io.
+		 */
+		wait_on_page_locked(page);
+		if (PageUptodate(page)) {
+			dp = kmap(page);
+			if (BITS_PER_LONG == 32 && hash64) {
+				*start = le64_to_cpu(dp->ldp_hash_start) >> 32;
+				*end   = le64_to_cpu(dp->ldp_hash_end) >> 32;
+				*hash  = *hash >> 32;
+			} else {
+				*start = le64_to_cpu(dp->ldp_hash_start);
+				*end   = le64_to_cpu(dp->ldp_hash_end);
+			}
+			if (unlikely(*start == 1 && *hash == 0))
+				*hash = *start;
+			else
+				LASSERTF(*start <= *hash, "start = %#llx,end = %#llx,hash = %#llx\n",
+					 *start, *end, *hash);
+			CDEBUG(D_VFSTRACE, "offset %lx [%#llx %#llx], hash %#llx\n",
+			       offset, *start, *end, *hash);
+			if (*hash > *end) {
+				kunmap(page);
+				mdc_release_page(page, 0);
+				page = NULL;
+			} else if (*end != *start && *hash == *end) {
+				/*
+				 * upon hash collision, remove this page,
+				 * otherwise put page reference, and
+				 * mdc_read_page_remote() will issue RPC to
+				 * fetch the page we want.
+				 */
+				kunmap(page);
+				mdc_release_page(page,
+						 le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
+				page = NULL;
+			}
+		} else {
+			put_page(page);
+			page = ERR_PTR(-EIO);
+		}
+	} else {
+		spin_unlock_irq(&mapping->tree_lock);
+		page = NULL;
+	}
+	return page;
+}
+
+/*
+ * Adjust a set of pages, each page containing an array of lu_dirpages,
+ * so that each page can be used as a single logical lu_dirpage.
+ *
+ * A lu_dirpage is laid out as follows, where s = ldp_hash_start,
+ * e = ldp_hash_end, f = ldp_flags, p = padding, and each "ent" is a
+ * struct lu_dirent.  It has size up to LU_PAGE_SIZE. The ldp_hash_end
+ * value is used as a cookie to request the next lu_dirpage in a
+ * directory listing that spans multiple pages (two in this example):
+ *   ________
+ *  |        |
+ * .|--------v-------   -----.
+ * |s|e|f|p|ent|ent| ... |ent|
+ * '--|--------------   -----'   Each PAGE contains a single
+ *    '------.                   lu_dirpage.
+ * .---------v-------   -----.
+ * |s|e|f|p|ent| 0 | ... | 0 |
+ * '-----------------   -----'
+ *
+ * However, on hosts where the native VM page size (PAGE_SIZE) is
+ * larger than LU_PAGE_SIZE, a single host page may contain multiple
+ * lu_dirpages. After reading the lu_dirpages from the MDS, the
+ * ldp_hash_end of the first lu_dirpage refers to the one immediately
+ * after it in the same PAGE (arrows simplified for brevity, but
+ * in general e0==s1, e1==s2, etc.):
+ *
+ * .--------------------   -----.
+ * |s0|e0|f0|p|ent|ent| ... |ent|
+ * |---v----------------   -----|
+ * |s1|e1|f1|p|ent|ent| ... |ent|
+ * |---v----------------   -----|  Here, each PAGE contains
+ *             ...                 multiple lu_dirpages.
+ * |---v----------------   -----|
+ * |s'|e'|f'|p|ent|ent| ... |ent|
+ * '---|----------------   -----'
+ *     v
+ * .----------------------------.
+ * |        next PAGE           |
+ *
+ * This structure is transformed into a single logical lu_dirpage as follows:
+ *
+ * - Replace e0 with e' so the request for the next lu_dirpage gets the page
+ *   labeled 'next PAGE'.
+ *
+ * - Copy the LDF_COLLIDE flag from f' to f0 to correctly reflect whether
+ *   a hash collision with the next page exists.
+ *
+ * - Adjust the lde_reclen of the ending entry of each lu_dirpage to span
+ *   to the first entry of the next lu_dirpage.
+ */
+#if PAGE_SIZE > LU_PAGE_SIZE
+static void mdc_adjust_dirpages(struct page **pages, int cfs_pgs, int lu_pgs)
+{
+	int i;
+
+	for (i = 0; i < cfs_pgs; i++) {
+		__u64 hash_end = le64_to_cpu(dp->ldp_hash_end);
+		__u32 flags = le32_to_cpu(dp->ldp_flags);
+		struct lu_dirpage *dp = kmap(pages[i]);
+		struct lu_dirpage *first = dp;
+		struct lu_dirent *end_dirent = NULL;
+		struct lu_dirent *ent;
+
+		while (--lu_pgs > 0) {
+			ent = lu_dirent_start(dp);
+			for (end_dirent = ent; ent;
+			     end_dirent = ent, ent = lu_dirent_next(ent));
+
+			/* Advance dp to next lu_dirpage. */
+			dp = (struct lu_dirpage *)((char *)dp + LU_PAGE_SIZE);
+
+			/* Check if we've reached the end of the CFS_PAGE. */
+			if (!((unsigned long)dp & ~PAGE_MASK))
+				break;
+
+			/* Save the hash and flags of this lu_dirpage. */
+			hash_end = le64_to_cpu(dp->ldp_hash_end);
+			flags = le32_to_cpu(dp->ldp_flags);
+
+			/* Check if lu_dirpage contains no entries. */
+			if (!end_dirent)
+				break;
+
+			/*
+			 * Enlarge the end entry lde_reclen from 0 to
+			 * first entry of next lu_dirpage.
+			 */
+			LASSERT(!le16_to_cpu(end_dirent->lde_reclen));
+			end_dirent->lde_reclen =
+				cpu_to_le16((char *)(dp->ldp_entries) -
+					    (char *)end_dirent);
+		}
+
+		first->ldp_hash_end = hash_end;
+		first->ldp_flags &= ~cpu_to_le32(LDF_COLLIDE);
+		first->ldp_flags |= flags & cpu_to_le32(LDF_COLLIDE);
+
+		kunmap(pages[i]);
+	}
+	LASSERTF(lu_pgs == 0, "left = %d", lu_pgs);
+}
+#else
+#define mdc_adjust_dirpages(pages, cfs_pgs, lu_pgs) do {} while (0)
+#endif  /* PAGE_SIZE > LU_PAGE_SIZE */
+
+/* parameters for readdir page */
+struct readpage_param {
+	struct md_op_data	*rp_mod;
+	__u64			rp_off;
+	int			rp_hash64;
+	struct obd_export	*rp_exp;
+	struct md_callback	*rp_cb;
+};
+
+/**
+ * Read pages from server.
+ *
+ * Page in MDS_READPAGE RPC is packed in LU_PAGE_SIZE, and each page contains
+ * a header lu_dirpage which describes the start/end hash, and whether this
+ * page is empty (contains no dir entry) or hash collide with next page.
+ * After client receives reply, several pages will be integrated into dir page
+ * in PAGE_SIZE (if PAGE_SIZE greater than LU_PAGE_SIZE), and the
+ * lu_dirpage for this integrated page will be adjusted.
+ **/
+static int mdc_read_page_remote(void *data, struct page *page0)
+{
+	struct readpage_param *rp = data;
+	struct page **page_pool;
+	struct page *page;
+	struct lu_dirpage *dp;
+	int rd_pgs = 0; /* number of pages read actually */
+	int npages;
+	struct md_op_data *op_data = rp->rp_mod;
+	struct ptlrpc_request *req;
+	int max_pages = op_data->op_max_pages;
+	struct inode *inode;
+	struct lu_fid *fid;
+	int i;
+	int rc;
+
+	LASSERT(max_pages > 0 && max_pages <= PTLRPC_MAX_BRW_PAGES);
+	inode = op_data->op_data;
+	fid = &op_data->op_fid1;
+	LASSERT(inode);
+
+	page_pool = kcalloc(max_pages, sizeof(page), GFP_NOFS);
+	if (page_pool) {
+		page_pool[0] = page0;
+	} else {
+		page_pool = &page0;
+		max_pages = 1;
+	}
+
+	for (npages = 1; npages < max_pages; npages++) {
+		page = page_cache_alloc_cold(inode->i_mapping);
+		if (!page)
+			break;
+		page_pool[npages] = page;
+	}
+
+	rc = mdc_getpage(rp->rp_exp, fid, rp->rp_off, page_pool, npages, &req);
+	if (!rc) {
+		int lu_pgs = req->rq_bulk->bd_nob_transferred;
+
+		rd_pgs = (req->rq_bulk->bd_nob_transferred +
+			  PAGE_SIZE - 1) >> PAGE_SHIFT;
+		lu_pgs >>= LU_PAGE_SHIFT;
+		LASSERT(!(req->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK));
+
+		CDEBUG(D_INODE, "read %d(%d)/%d pages\n", rd_pgs, lu_pgs,
+		       op_data->op_npages);
+
+		mdc_adjust_dirpages(page_pool, rd_pgs, lu_pgs);
+
+		SetPageUptodate(page0);
+	}
+
+	unlock_page(page0);
+	ptlrpc_req_finished(req);
+	CDEBUG(D_CACHE, "read %d/%d pages\n", rd_pgs, npages);
+	for (i = 1; i < npages; i++) {
+		unsigned long offset;
+		__u64 hash;
+		int ret;
+
+		page = page_pool[i];
+
+		if (rc < 0 || i >= rd_pgs) {
+			put_page(page);
+			continue;
+		}
+
+		SetPageUptodate(page);
+
+		dp = kmap(page);
+		hash = le64_to_cpu(dp->ldp_hash_start);
+		kunmap(page);
+
+		offset = hash_x_index(hash, rp->rp_hash64);
+
+		prefetchw(&page->flags);
+		ret = add_to_page_cache_lru(page, inode->i_mapping, offset,
+					    GFP_KERNEL);
+		if (!ret)
+			unlock_page(page);
+		else
+			CDEBUG(D_VFSTRACE, "page %lu add to page cache failed: rc = %d\n",
+			       offset, ret);
+		put_page(page);
+	}
+
+	if (page_pool != &page0)
+		kfree(page_pool);
+
+	return rc;
+}
+
+/**
+ * Read dir page from cache first, if it can not find it, read it from
+ * server and add into the cache.
+ *
+ * \param[in] exp	MDC export
+ * \param[in] op_data	client MD stack parameters, transferring parameters
+ *			between different layers on client MD stack.
+ * \param[in] cb_op	callback required for ldlm lock enqueue during
+ *			read page
+ * \param[in] hash_offset the hash offset of the page to be read
+ * \param[in] ppage	the page to be read
+ *
+ * retval		= 0 get the page successfully
+ *			errno(<0) get the page failed
+ */
+static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
+			 struct md_callback *cb_op, __u64 hash_offset,
+			 struct page **ppage)
+{
+	struct lookup_intent it = { .it_op = IT_READDIR };
+	struct page *page;
+	struct inode *dir = op_data->op_data;
+	struct address_space *mapping;
+	struct lu_dirpage *dp;
+	__u64 start = 0;
+	__u64 end = 0;
+	struct lustre_handle lockh;
+	struct ptlrpc_request *enq_req = NULL;
+	struct readpage_param rp_param;
+	int rc;
+
+	*ppage = NULL;
+
+	LASSERT(dir);
+	mapping = dir->i_mapping;
+
+	rc = mdc_intent_lock(exp, op_data, NULL, 0, &it, 0, &enq_req,
+			     cb_op->md_blocking_ast, 0);
+	if (enq_req)
+		ptlrpc_req_finished(enq_req);
+
+	if (rc < 0) {
+		CERROR("%s: "DFID" lock enqueue fails: rc = %d\n",
+		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1), rc);
+		return rc;
+	}
+
+	rc = 0;
+	mdc_set_lock_data(exp, &it.it_lock_handle, dir, NULL);
+
+	rp_param.rp_off = hash_offset;
+	rp_param.rp_hash64 = op_data->op_cli_flags & CLI_HASH64;
+	page = mdc_page_locate(mapping, &rp_param.rp_off, &start, &end,
+			       rp_param.rp_hash64);
+	if (IS_ERR(page)) {
+		CERROR("%s: dir page locate: "DFID" at %llu: rc %ld\n",
+		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
+		       rp_param.rp_off, PTR_ERR(page));
+		rc = PTR_ERR(page);
+		goto out_unlock;
+	} else if (page) {
+		/*
+		 * XXX nikita: not entirely correct handling of a corner case:
+		 * suppose hash chain of entries with hash value HASH crosses
+		 * border between pages P0 and P1. First both P0 and P1 are
+		 * cached, seekdir() is called for some entry from the P0 part
+		 * of the chain. Later P0 goes out of cache. telldir(HASH)
+		 * happens and finds P1, as it starts with matching hash
+		 * value. Remaining entries from P0 part of the chain are
+		 * skipped. (Is that really a bug?)
+		 *
+		 * Possible solutions: 0. don't cache P1 is such case, handle
+		 * it as an "overflow" page. 1. invalidate all pages at
+		 * once. 2. use HASH|1 as an index for P1.
+		 */
+		goto hash_collision;
+	}
+
+	rp_param.rp_exp = exp;
+	rp_param.rp_mod = op_data;
+	page = read_cache_page(mapping,
+			       hash_x_index(rp_param.rp_off,
+					    rp_param.rp_hash64),
+			       mdc_read_page_remote, &rp_param);
+	if (IS_ERR(page)) {
+		CERROR("%s: read cache page: "DFID" at %llu: rc %ld\n",
+		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
+		       rp_param.rp_off, PTR_ERR(page));
+		rc = PTR_ERR(page);
+		goto out_unlock;
+	}
+
+	wait_on_page_locked(page);
+	(void)kmap(page);
+	if (!PageUptodate(page)) {
+		CERROR("%s: page not updated: "DFID" at %llu: rc %d\n",
+		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
+		       rp_param.rp_off, -5);
+		goto fail;
+	}
+	if (!PageChecked(page))
+		SetPageChecked(page);
+	if (PageError(page)) {
+		CERROR("%s: page error: "DFID" at %llu: rc %d\n",
+		       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
+		       rp_param.rp_off, -5);
+		goto fail;
+	}
+
+hash_collision:
+	dp = page_address(page);
+	if (BITS_PER_LONG == 32 && rp_param.rp_hash64) {
+		start = le64_to_cpu(dp->ldp_hash_start) >> 32;
+		end = le64_to_cpu(dp->ldp_hash_end) >> 32;
+		rp_param.rp_off = hash_offset >> 32;
+	} else {
+		start = le64_to_cpu(dp->ldp_hash_start);
+		end = le64_to_cpu(dp->ldp_hash_end);
+		rp_param.rp_off = hash_offset;
+	}
+	if (end == start) {
+		LASSERT(start == rp_param.rp_off);
+		CWARN("Page-wide hash collision: %#lx\n", (unsigned long)end);
+#if BITS_PER_LONG == 32
+		CWARN("Real page-wide hash collision at [%llu %llu] with hash %llu\n",
+		      le64_to_cpu(dp->ldp_hash_start),
+		      le64_to_cpu(dp->ldp_hash_end), hash_offset);
+#endif
+		/*
+		 * Fetch whole overflow chain...
+		 *
+		 * XXX not yet.
+		 */
+		goto fail;
+	}
+	*ppage = page;
+out_unlock:
+	lockh.cookie = it.it_lock_handle;
+	ldlm_lock_decref(&lockh, it.it_lock_mode);
+	it.it_lock_handle = 0;
+	return rc;
+fail:
+	kunmap(page);
+	mdc_release_page(page, 1);
+	rc = -EIO;
+	goto out_unlock;
+}
+
 static int mdc_statfs(const struct lu_env *env,
 		      struct obd_export *exp, struct obd_statfs *osfs,
 		      __u64 max_age, __u32 flags)
@@ -2450,6 +2980,7 @@ static struct md_ops mdc_md_ops = {
 	.getxattr		= mdc_getxattr,
 	.sync			= mdc_sync,
 	.readpage		= mdc_readpage,
+	.read_page		= mdc_read_page,
 	.unlink			= mdc_unlink,
 	.cancel_unused		= mdc_cancel_unused,
 	.init_ea_size		= mdc_init_ea_size,
-- 
1.7.1
