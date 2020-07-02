From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:46 -0400
Subject: [lustre-devel] [PATCH 06/18] lustre: sec: support truncate for
 encrypted files
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Truncation of encrypted files is not a trivial operation. The page
corresponding to the point where truncation occurs must be read,
decrypted, zeroed after truncation point, re-encrypted and then
written back.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: adf46db962f65 ("LU-12275 sec: support truncate for encrypted files")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/37794
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c      |   7 ++
 fs/lustre/llite/llite_lib.c | 182 +++++++++++++++++++++++++++++++++++++++++++-
 fs/lustre/llite/rw.c        |  13 +++-
 fs/lustre/llite/vvp_io.c    |   9 ++-
 fs/lustre/osc/osc_request.c |   7 +-
 5 files changed, 211 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 3b04952..55ae2b3 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2086,6 +2086,13 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 			goto out;
 
 		rc = ll_file_getstripe(inode, arg, lum_size);
+		if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode) &&
+		    ll_i2info(inode)->lli_clob) {
+			struct iattr attr = { 0 };
+
+			rc = cl_setattr_ost(ll_i2info(inode)->lli_clob, &attr,
+					    OP_XVALID_FLAGS, LUSTRE_ENCRYPT_FL);
+		}
 	}
 
 	cl_lov_delay_create_clear(&file->f_flags);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index aad19a2..0db9eae 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1665,6 +1665,164 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
 	return rc;
 }
 
+/**
+ * Zero portion of page that is part of @inode.
+ * This implies, if necessary:
+ * - taking cl_lock on range corresponding to concerned page
+ * - grabbing vm page
+ * - associating cl_page
+ * - proceeding to clio read
+ * - zeroing range in page
+ * - proceeding to cl_page flush
+ * - releasing cl_lock
+ *
+ * @inode	inode
+ * @inde	page index
+ * @offset	offset in page to start zero from
+ * @len	len to zero
+ *
+ * Return:	0 on success
+ *		errno on failure
+ */
+int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
+		    unsigned int len)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct cl_object *clob = lli->lli_clob;
+	u16 refcheck;
+	struct lu_env *env = NULL;
+	struct cl_io *io = NULL;
+	struct cl_page *clpage = NULL;
+	struct page *vmpage = NULL;
+	unsigned int from = index << PAGE_SHIFT;
+	struct cl_lock *lock = NULL;
+	struct cl_lock_descr *descr = NULL;
+	struct cl_2queue *queue = NULL;
+	struct cl_sync_io *anchor = NULL;
+	bool holdinglock = false;
+	bool lockedbymyself = true;
+	int rc;
+
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	io = vvp_env_thread_io(env);
+	io->ci_obj = clob;
+	rc = cl_io_rw_init(env, io, CIT_WRITE, from, PAGE_SIZE);
+	if (rc)
+		goto putenv;
+
+	lock = vvp_env_lock(env);
+	descr = &lock->cll_descr;
+	descr->cld_obj = io->ci_obj;
+	descr->cld_start = cl_index(io->ci_obj, from);
+	descr->cld_end = cl_index(io->ci_obj, from + PAGE_SIZE - 1);
+	descr->cld_mode = CLM_WRITE;
+	descr->cld_enq_flags = CEF_MUST | CEF_NONBLOCK;
+
+	/* request lock for page */
+	rc = cl_lock_request(env, io, lock);
+	/* -ECANCELED indicates a matching lock with a different extent
+	 * was already present, and -EEXIST indicates a matching lock
+	 * on exactly the same extent was already present.
+	 * In both cases it means we are covered.
+	 */
+	if (rc == -ECANCELED || rc == -EEXIST)
+		rc = 0;
+	else if (rc < 0)
+		goto iofini;
+	else
+		holdinglock = true;
+
+	/* grab page */
+	vmpage = grab_cache_page_nowait(inode->i_mapping, index);
+	if (!vmpage) {
+		rc = -EOPNOTSUPP;
+		goto rellock;
+	}
+
+	if (!PageDirty(vmpage)) {
+		/* associate cl_page */
+		clpage = cl_page_find(env, clob, vmpage->index,
+				      vmpage, CPT_CACHEABLE);
+		if (IS_ERR(clpage)) {
+			rc = PTR_ERR(clpage);
+			goto pagefini;
+		}
+
+		cl_page_assume(env, io, clpage);
+	}
+
+	if (!PageUptodate(vmpage) && !PageDirty(vmpage) &&
+	    !PageWriteback(vmpage)) {
+		/* read page */
+		/* set PagePrivate2 to detect special case of empty page
+		 * in osc_brw_fini_request()
+		 */
+		SetPagePrivate2(vmpage);
+		rc = ll_io_read_page(env, io, clpage, NULL);
+		if (!PagePrivate2(vmpage))
+			/* PagePrivate2 was cleared in osc_brw_fini_request()
+			 * meaning we read an empty page. In this case, in order
+			 * to avoid allocating unnecessary block in truncated
+			 * file, we must not zero and write as below. Subsequent
+			 * server-side truncate will handle things correctly.
+			 */
+			goto clpfini;
+		ClearPagePrivate2(vmpage);
+		if (rc)
+			goto clpfini;
+		lockedbymyself = trylock_page(vmpage);
+		cl_page_assume(env, io, clpage);
+	}
+
+	/* zero range in page */
+	zero_user(vmpage, offset, len);
+
+	if (holdinglock && clpage) {
+		/* explicitly write newly modified page */
+		queue = &io->ci_queue;
+		cl_2queue_init(queue);
+		anchor = &vvp_env_info(env)->vti_anchor;
+		cl_sync_io_init(anchor, 1);
+		clpage->cp_sync_io = anchor;
+		cl_page_list_add(&queue->c2_qin, clpage);
+		rc = cl_io_submit_rw(env, io, CRT_WRITE, queue);
+		if (rc)
+			goto queuefini1;
+		rc = cl_sync_io_wait(env, anchor, 0);
+		if (rc)
+			goto queuefini2;
+		cl_page_assume(env, io, clpage);
+
+queuefini2:
+		cl_2queue_discard(env, io, queue);
+queuefini1:
+		cl_2queue_disown(env, io, queue);
+		cl_2queue_fini(env, queue);
+	}
+
+clpfini:
+	if (clpage)
+		cl_page_put(env, clpage);
+pagefini:
+	if (lockedbymyself) {
+		unlock_page(vmpage);
+		put_page(vmpage);
+	}
+rellock:
+	if (holdinglock)
+		cl_lock_release(env, lock);
+iofini:
+	cl_io_fini(env, io);
+putenv:
+	if (env)
+		cl_env_put(env, &refcheck);
+
+	return rc;
+}
+
 /* If this inode has objects allocated to it (lsm != NULL), then the OST
  * object(s) determine the file size and mtime.  Otherwise, the MDS will
  * keep these values until such a time that objects are allocated for it.
@@ -1798,6 +1956,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 				goto out;
 			}
 		} else {
+			unsigned int flags = 0;
+
 			/* For truncate and utimes sending attributes to OSTs,
 			 * setting mtime/atime to the past will be performed
 			 * under PW [0:EOF] extent lock (new_size:EOF for
@@ -1806,8 +1966,23 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 			 * it is necessary due to possible time
 			 * de-synchronization between MDT inode and OST objects
 			 */
+			if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode) &&
+			    attr->ia_valid & ATTR_SIZE) {
+				xvalid |= OP_XVALID_FLAGS;
+				flags = LUSTRE_ENCRYPT_FL;
+				if (attr->ia_size & ~PAGE_MASK) {
+					pgoff_t offset;
+
+					offset = attr->ia_size & (PAGE_SIZE - 1);
+					rc = ll_io_zero_page(inode,
+							     attr->ia_size >> PAGE_SHIFT,
+							     offset, PAGE_SIZE - offset);
+					if (rc)
+						goto out;
+				}
+			}
 			rc = cl_setattr_ost(ll_i2info(inode)->lli_clob,
-					    attr, xvalid, 0);
+					    attr, xvalid, flags);
 		}
 	}
 
@@ -1875,6 +2050,11 @@ int ll_setattr(struct dentry *de, struct iattr *attr)
 {
 	int mode = d_inode(de)->i_mode;
 	enum op_xvalid xvalid = 0;
+	int rc;
+
+	rc = llcrypt_prepare_setattr(de, attr);
+	if (rc)
+		return rc;
 
 	if ((attr->ia_valid & (ATTR_CTIME | ATTR_SIZE | ATTR_MODE)) ==
 			      (ATTR_CTIME | ATTR_SIZE | ATTR_MODE))
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index ff8f3c6..54f0b9a 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1453,8 +1453,8 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 			   struct cl_page *page, struct file *file)
 {
 	struct inode *inode = vvp_object_inode(page->cp_obj);
-	struct ll_file_data *fd = file->private_data;
-	struct ll_readahead_state *ras = &fd->fd_ras;
+	struct ll_file_data *fd = NULL;
+	struct ll_readahead_state *ras = NULL;
 	struct cl_2queue *queue = &io->ci_queue;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct cl_sync_io *anchor = NULL;
@@ -1464,10 +1464,15 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	struct vvp_page *vpg;
 	bool uptodate;
 
+	if (file) {
+		fd = file->private_data;
+		ras = &fd->fd_ras;
+	}
+
 	vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
 	uptodate = vpg->vpg_defer_uptodate;
 
-	if (ll_readahead_enabled(sbi) && !vpg->vpg_ra_updated) {
+	if (ll_readahead_enabled(sbi) && !vpg->vpg_ra_updated && ras) {
 		struct vvp_io *vio = vvp_env_io(env);
 		enum ras_update_flags flags = 0;
 
@@ -1494,7 +1499,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	io_start_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos);
 	io_end_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos +
 				io->u.ci_rw.crw_count - 1);
-	if (ll_readahead_enabled(sbi)) {
+	if (ll_readahead_enabled(sbi) && ras) {
 		rc2 = ll_readahead(env, io, &queue->c2_qin, ras,
 				   uptodate, file);
 		CDEBUG(D_READA, DFID " %d pages read ahead at %lu\n",
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 371d988..8df5d39 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -620,7 +620,14 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 	u32 enqflags = 0;
 
 	if (cl_io_is_trunc(io)) {
-		if (io->u.ci_setattr.sa_attr.lvb_size == 0)
+		struct inode *inode = vvp_object_inode(io->ci_obj);
+
+		/* set enqueue flags to CEF_MUST in case of encrypted file,
+		 * to prevent lockless truncate
+		 */
+		if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode))
+			enqflags = CEF_MUST;
+		else if (io->u.ci_setattr.sa_attr.lvb_size == 0)
 			enqflags = CEF_DISCARD_DATA;
 	} else if (cl_io_is_fallocate(io)) {
 		lock_start = io->u.ci_setattr.sa_falloc_offset;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index b27a259..1968d62 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2084,8 +2084,13 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 					break;
 				p++;
 			}
-			if (p - q == PAGE_SIZE / sizeof(*p))
+			if (p - q == PAGE_SIZE / sizeof(*p)) {
+				/* if page is empty forward info to upper layers
+				 * (ll_io_zero_page) by clearing PagePrivate2
+				 */
+				ClearPagePrivate2(pg->pg);
 				continue;
+			}
 
 			rc = llcrypt_decrypt_pagecache_blocks(pg->pg,
 							      PAGE_SIZE, 0);
-- 
1.8.3.1
