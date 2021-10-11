Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB283C433F5
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6E61A60EB6
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 6E61A60EB6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 81731380DD4;
	Mon, 11 Oct 2021 10:41:04 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 48DBB21FB84
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:54 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id ABC55264;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A42D5D5A46; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:33 -0400
Message-Id: <1633974049-26490-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/20] lustre: llite: move env contexts to
 ll_inode_info level
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

From: Sebastien Buisson <sbuisson@ddn.com>

Contrary to file, inode is always available, so move the list of
env contexts from the file data to the ll_inode_info level.
This is needed because we will have to handle env properties in
ll_get_context() and ll_xattr_list()/ll_listxattr().
This also requires changing lli_lock from a spinlock to an rwlock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14677
Lustre-commit: 4756af02e1297d145 ("LU-14677 llite: move env contexts to ll_inode_info level")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15027
Lustre-commit: 3fb7b6271855c0b12 ("LU-15027 sec: initialize ll_inode_info for fake inode")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/44198
Reviewed-on: https://review.whamcloud.com/45023
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/acl.c            |  4 ++--
 fs/lustre/llite/file.c           |  9 +++------
 fs/lustre/llite/llite_internal.h | 18 ++++++++----------
 fs/lustre/llite/llite_lib.c      |  4 +++-
 fs/lustre/llite/llite_mmap.c     | 17 +++++++----------
 fs/lustre/llite/namei.c          |  1 +
 fs/lustre/llite/rw.c             | 36 ++++++++++++++++++------------------
 fs/lustre/llite/rw26.c           |  5 +++--
 fs/lustre/llite/xattr.c          |  4 ++--
 9 files changed, 47 insertions(+), 51 deletions(-)

diff --git a/fs/lustre/llite/acl.c b/fs/lustre/llite/acl.c
index f4cc149..bd045cc 100644
--- a/fs/lustre/llite/acl.c
+++ b/fs/lustre/llite/acl.c
@@ -41,10 +41,10 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct posix_acl *acl = NULL;
 
-	spin_lock(&lli->lli_lock);
+	read_lock(&lli->lli_lock);
 	/* VFS' acl_permission_check->check_acl will release the refcount */
 	acl = posix_acl_dup(lli->lli_posix_acl);
-	spin_unlock(&lli->lli_lock);
+	read_unlock(&lli->lli_lock);
 
 	return acl;
 }
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 9dd5c8c..ad1c07e 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -751,10 +751,6 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 	/* turn off the kernel's read-ahead */
 	file->f_ra.ra_pages = 0;
 
-	/* ll_cl_context initialize */
-	rwlock_init(&fd->fd_lock);
-	INIT_LIST_HEAD(&fd->fd_lccs);
-
 	return 0;
 }
 
@@ -1718,9 +1714,10 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 
 			range_locked = true;
 		}
-		ll_cl_add(file, env, io, LCC_RW);
+		ll_cl_add(inode, env, io, LCC_RW);
 		rc = cl_io_loop(env, io);
-		ll_cl_remove(file, env);
+		ll_cl_remove(inode, env);
+
 		if (range_locked && !is_parallel_dio) {
 			CDEBUG(D_VFSTRACE, "Range unlock [%llu, %llu]\n",
 			       range.rl_start,
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 25bd460..cfeec14 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -123,8 +123,7 @@ struct ll_trunc_sem {
 
 struct ll_inode_info {
 	u32				lli_inode_magic;
-
-	spinlock_t			lli_lock;
+	rwlock_t			lli_lock;
 	unsigned long			lli_flags;
 	struct posix_acl		*lli_posix_acl;
 
@@ -280,7 +279,8 @@ struct ll_inode_info {
 
 	struct rw_semaphore		lli_xattrs_list_rwsem;
 	struct mutex			lli_xattrs_enq_lock;
-	struct list_head		lli_xattrs;/* ll_xattr_entry->xe_list */
+	struct list_head		lli_xattrs; /* ll_xattr_entry->xe_list */
+	struct list_head		lli_lccs; /* list of ll_cl_context */
 };
 
 static inline void ll_trunc_sem_init(struct ll_trunc_sem *sem)
@@ -376,11 +376,11 @@ static inline void lli_clear_acl(struct ll_inode_info *lli)
 static inline void lli_replace_acl(struct ll_inode_info *lli,
 				   struct lustre_md *md)
 {
-	spin_lock(&lli->lli_lock);
+	write_lock(&lli->lli_lock);
 	if (lli->lli_posix_acl)
 		posix_acl_release(lli->lli_posix_acl);
 	lli->lli_posix_acl = md->posix_acl;
-	spin_unlock(&lli->lli_lock);
+	write_unlock(&lli->lli_lock);
 }
 #else
 static inline void lli_clear_acl(struct ll_inode_info *lli)
@@ -941,8 +941,6 @@ struct ll_file_data {
 	 */
 	bool fd_write_failed;
 	bool ll_lock_no_expand;
-	rwlock_t fd_lock; /* protect lcc list */
-	struct list_head fd_lccs; /* list of ll_cl_context */
 	/* Used by mirrored file to lead IOs to a specific mirror, usually
 	 * for mirror resync. 0 means default.
 	 */
@@ -1107,10 +1105,10 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
 
 enum lcc_type;
-void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io,
+void ll_cl_add(struct inode *inode, const struct lu_env *env, struct cl_io *io,
 	       enum lcc_type type);
-void ll_cl_remove(struct file *file, const struct lu_env *env);
-struct ll_cl_context *ll_cl_find(struct file *file);
+void ll_cl_remove(struct inode *inode, const struct lu_env *env);
+struct ll_cl_context *ll_cl_find(struct inode *inode);
 
 static inline void mapping_clear_exiting(struct address_space *mapping)
 {
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 7a822b8..9ff881c 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1080,7 +1080,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 {
 	lli->lli_inode_magic = LLI_INODE_MAGIC;
 	lli->lli_flags = 0;
-	spin_lock_init(&lli->lli_lock);
+	rwlock_init(&lli->lli_lock);
 	lli->lli_posix_acl = NULL;
 	/* Do not set lli_fid, it has been initialized already. */
 	fid_zero(&lli->lli_pfid);
@@ -1132,6 +1132,8 @@ void ll_lli_init(struct ll_inode_info *lli)
 	}
 	mutex_init(&lli->lli_layout_mutex);
 	memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
+	/* ll_cl_context initialize */
+	INIT_LIST_HEAD(&lli->lli_lccs);
 }
 
 int ll_fill_super(struct super_block *sb)
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 8238a4e..8047786 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -270,6 +270,7 @@ static inline vm_fault_t to_fault_error(int result)
  */
 static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	struct inode *inode = file_inode(vma->vm_file);
 	struct lu_env *env;
 	struct cl_io *io;
 	struct vvp_io *vio = NULL;
@@ -282,15 +283,15 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (IS_ERR(env))
 		return VM_FAULT_ERROR;
 
-	if (ll_sbi_has_fast_read(ll_i2sbi(file_inode(vma->vm_file)))) {
+	if (ll_sbi_has_fast_read(ll_i2sbi(inode))) {
 		/* do fast fault */
 		bool has_retry = vmf->flags & FAULT_FLAG_RETRY_NOWAIT;
 
 		/* To avoid loops, instruct downstream to not drop mmap_sem */
 		vmf->flags |= FAULT_FLAG_RETRY_NOWAIT;
-		ll_cl_add(vma->vm_file, env, NULL, LCC_MMAP);
+		ll_cl_add(inode, env, NULL, LCC_MMAP);
 		fault_ret = filemap_fault(vmf);
-		ll_cl_remove(vma->vm_file, env);
+		ll_cl_remove(inode, env);
 		if (has_retry)
 			vmf->flags &= ~FAULT_FLAG_RETRY_NOWAIT;
 
@@ -318,8 +319,6 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	result = io->ci_result;
 	if (result == 0) {
-		struct file *vm_file = vma->vm_file;
-
 		vio = vvp_env_io(env);
 		vio->u.fault.ft_vma = vma;
 		vio->u.fault.ft_vmpage = NULL;
@@ -327,15 +326,13 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		vio->u.fault.ft_flags = 0;
 		vio->u.fault.ft_flags_valid = false;
 
-		get_file(vm_file);
-
 		/* May call ll_readpage() */
-		ll_cl_add(vm_file, env, io, LCC_MMAP);
+		ll_cl_add(inode, env, io, LCC_MMAP);
 
 		result = cl_io_loop(env, io);
 
-		ll_cl_remove(vm_file, env);
-		fput(vm_file);
+		ll_cl_remove(inode, env);
+
 		/* ft_flags are only valid if we reached
 		 * the call to filemap_fault
 		 */
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 1812c09..781bb16 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1604,6 +1604,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 			}
 			fakeinode->i_sb = dchild->d_sb;
 			fakeinode->i_mode |= S_IFLNK;
+			ll_lli_init(ll_i2info(fakeinode));
 			err = ll_set_encflags(fakeinode,
 					      op_data->op_file_encctx,
 					      op_data->op_file_encctx_size,
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 48984aa..c9f29ef 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1567,28 +1567,28 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	return result;
 }
 
-struct ll_cl_context *ll_cl_find(struct file *file)
+struct ll_cl_context *ll_cl_find(struct inode *inode)
 {
-	struct ll_file_data *fd = file->private_data;
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_cl_context *lcc;
 	struct ll_cl_context *found = NULL;
 
-	read_lock(&fd->fd_lock);
-	list_for_each_entry(lcc, &fd->fd_lccs, lcc_list) {
+	read_lock(&lli->lli_lock);
+	list_for_each_entry(lcc, &lli->lli_lccs, lcc_list) {
 		if (lcc->lcc_cookie == current) {
 			found = lcc;
 			break;
 		}
 	}
-	read_unlock(&fd->fd_lock);
+	read_unlock(&lli->lli_lock);
 
 	return found;
 }
 
-void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io,
+void ll_cl_add(struct inode *inode, const struct lu_env *env, struct cl_io *io,
 	       enum lcc_type type)
 {
-	struct ll_file_data *fd = file->private_data;
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_cl_context *lcc = &ll_env_info(env)->lti_io_ctx;
 
 	memset(lcc, 0, sizeof(*lcc));
@@ -1598,19 +1598,19 @@ void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io,
 	lcc->lcc_io = io;
 	lcc->lcc_type = type;
 
-	write_lock(&fd->fd_lock);
-	list_add(&lcc->lcc_list, &fd->fd_lccs);
-	write_unlock(&fd->fd_lock);
+	write_lock(&lli->lli_lock);
+	list_add(&lcc->lcc_list, &lli->lli_lccs);
+	write_unlock(&lli->lli_lock);
 }
 
-void ll_cl_remove(struct file *file, const struct lu_env *env)
+void ll_cl_remove(struct inode *inode, const struct lu_env *env)
 {
-	struct ll_file_data *fd = file->private_data;
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_cl_context *lcc = &ll_env_info(env)->lti_io_ctx;
 
-	write_lock(&fd->fd_lock);
+	write_lock(&lli->lli_lock);
 	list_del_init(&lcc->lcc_list);
-	write_unlock(&fd->fd_lock);
+	write_unlock(&lli->lli_lock);
 }
 
 int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
@@ -1815,15 +1815,16 @@ static bool ll_use_fast_io(struct file *file,
 
 int ll_readpage(struct file *file, struct page *vmpage)
 {
-	struct cl_object *clob = ll_i2info(file_inode(file))->lli_clob;
+	struct inode *inode = file_inode(file);
+	struct cl_object *clob = ll_i2info(inode)->lli_clob;
 	struct ll_cl_context *lcc;
 	const struct lu_env *env = NULL;
 	struct cl_io *io = NULL;
 	struct cl_page *page;
-	struct ll_sb_info *sbi = ll_i2sbi(file_inode(file));
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	int result;
 
-	lcc = ll_cl_find(file);
+	lcc = ll_cl_find(inode);
 	if (lcc) {
 		env = lcc->lcc_env;
 		io = lcc->lcc_io;
@@ -1833,7 +1834,6 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		struct ll_file_data *fd = file->private_data;
 		struct ll_readahead_state *ras = &fd->fd_ras;
 		struct lu_env *local_env = NULL;
-		struct inode *inode = file_inode(file);
 		struct vvp_page *vpg;
 
 		result = -ENODATA;
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index e5d80cb..0a271b9 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -355,7 +355,7 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	if (ll_iov_iter_alignment(iter) & ~PAGE_MASK)
 		return -EINVAL;
 
-	lcc = ll_cl_find(file);
+	lcc = ll_cl_find(inode);
 	if (!lcc)
 		return -EIO;
 
@@ -518,6 +518,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	const struct lu_env *env = NULL;
 	struct cl_io *io = NULL;
 	struct cl_page *page = NULL;
+	struct inode *inode = file_inode(file);
 	struct cl_object *clob = ll_i2info(mapping->host)->lli_clob;
 	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *vmpage = NULL;
@@ -527,7 +528,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 
 	CDEBUG(D_VFSTRACE, "Writing %lu of %d to %d bytes\n", index, from, len);
 
-	lcc = ll_cl_find(file);
+	lcc = ll_cl_find(inode);
 	if (!lcc) {
 		vmpage = grab_cache_page_nowait(mapping, index);
 		result = ll_tiny_write_begin(vmpage, mapping);
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index cd973eb..001c828 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -453,9 +453,9 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 		struct ll_inode_info *lli = ll_i2info(inode);
 		struct posix_acl *acl;
 
-		spin_lock(&lli->lli_lock);
+		read_lock(&lli->lli_lock);
 		acl = posix_acl_dup(lli->lli_posix_acl);
-		spin_unlock(&lli->lli_lock);
+		read_unlock(&lli->lli_lock);
 
 		if (!acl)
 			return -ENODATA;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
