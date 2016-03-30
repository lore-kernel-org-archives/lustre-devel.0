From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:03 -0400
Subject: [lustre-devel] [PATCH 31/43] staging/lustre/llite: use vui prefix
	for struct vvp_io members
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-32-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Rename members of struct vvp_io to used to start with vui_ rather than
cui_.  Rename several instances of struct vvp_io * from cio to vio.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/13363
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c         |  20 ++--
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  34 +++---
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   6 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  24 ++--
 drivers/staging/lustre/lustre/llite/rw26.c         |  20 ++--
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  38 +++---
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 131 +++++++++++----------
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   4 +-
 8 files changed, 139 insertions(+), 138 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 27e7e65..63aa080 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1135,18 +1135,18 @@ restart:
 	ll_io_init(io, file, iot == CIT_WRITE);
 
 	if (cl_io_rw_init(env, io, iot, *ppos, count) == 0) {
-		struct vvp_io *cio = vvp_env_io(env);
+		struct vvp_io *vio = vvp_env_io(env);
 		int write_mutex_locked = 0;
 
-		cio->cui_fd  = LUSTRE_FPRIVATE(file);
-		cio->cui_io_subtype = args->via_io_subtype;
+		vio->vui_fd  = LUSTRE_FPRIVATE(file);
+		vio->vui_io_subtype = args->via_io_subtype;
 
-		switch (cio->cui_io_subtype) {
+		switch (vio->vui_io_subtype) {
 		case IO_NORMAL:
-			cio->cui_iter = args->u.normal.via_iter;
-			cio->cui_iocb = args->u.normal.via_iocb;
+			vio->vui_iter = args->u.normal.via_iter;
+			vio->vui_iocb = args->u.normal.via_iocb;
 			if ((iot == CIT_WRITE) &&
-			    !(cio->cui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
+			    !(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
 				if (mutex_lock_interruptible(&lli->
 							       lli_write_mutex)) {
 					result = -ERESTARTSYS;
@@ -1157,11 +1157,11 @@ restart:
 			down_read(&lli->lli_trunc_sem);
 			break;
 		case IO_SPLICE:
-			cio->u.splice.cui_pipe = args->u.splice.via_pipe;
-			cio->u.splice.cui_flags = args->u.splice.via_flags;
+			vio->u.splice.vui_pipe = args->u.splice.via_pipe;
+			vio->u.splice.vui_flags = args->u.splice.via_flags;
 			break;
 		default:
-			CERROR("Unknown IO type - %u\n", cio->cui_io_subtype);
+			CERROR("Unknown IO type - %u\n", vio->vui_io_subtype);
 			LBUG();
 		}
 		result = cl_io_loop(env, io);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 9a9d706..630c371 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -210,19 +210,19 @@ int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 			  __u32 enqflags, enum cl_lock_mode mode,
 			  pgoff_t start, pgoff_t end)
 {
-	struct vvp_io *cio = vvp_env_io(env);
-	struct cl_lock_descr   *descr = &cio->cui_link.cill_descr;
+	struct vvp_io          *vio   = vvp_env_io(env);
+	struct cl_lock_descr   *descr = &vio->vui_link.cill_descr;
 	struct cl_object       *obj   = io->ci_obj;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	CDEBUG(D_VFSTRACE, "lock: %d [%lu, %lu]\n", mode, start, end);
 
-	memset(&cio->cui_link, 0, sizeof(cio->cui_link));
+	memset(&vio->vui_link, 0, sizeof(vio->vui_link));
 
-	if (cio->cui_fd && (cio->cui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
+	if (vio->vui_fd && (vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
 		descr->cld_mode = CLM_GROUP;
-		descr->cld_gid  = cio->cui_fd->fd_grouplock.cg_gid;
+		descr->cld_gid  = vio->vui_fd->fd_grouplock.cg_gid;
 	} else {
 		descr->cld_mode  = mode;
 	}
@@ -231,19 +231,19 @@ int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 	descr->cld_end   = end;
 	descr->cld_enq_flags = enqflags;
 
-	cl_io_lock_add(env, io, &cio->cui_link);
+	cl_io_lock_add(env, io, &vio->vui_link);
 	return 0;
 }
 
 void vvp_io_update_iov(const struct lu_env *env,
-		       struct vvp_io *cio, struct cl_io *io)
+		       struct vvp_io *vio, struct cl_io *io)
 {
 	size_t size = io->u.ci_rw.crw_count;
 
-	if (!cl_is_normalio(env, io) || !cio->cui_iter)
+	if (!cl_is_normalio(env, io) || !vio->vui_iter)
 		return;
 
-	iov_iter_truncate(cio->cui_iter, size);
+	iov_iter_truncate(vio->vui_iter, size);
 }
 
 int vvp_io_one_lock(const struct lu_env *env, struct cl_io *io,
@@ -266,7 +266,7 @@ void vvp_io_advance(const struct lu_env *env,
 		    const struct cl_io_slice *ios,
 		    size_t nob)
 {
-	struct vvp_io    *cio = cl2vvp_io(env, ios);
+	struct vvp_io    *vio = cl2vvp_io(env, ios);
 	struct cl_io     *io  = ios->cis_io;
 	struct cl_object *obj = ios->cis_io->ci_obj;
 
@@ -275,7 +275,7 @@ void vvp_io_advance(const struct lu_env *env,
 	if (!cl_is_normalio(env, io))
 		return;
 
-	iov_iter_reexpand(cio->cui_iter, cio->cui_tot_count  -= nob);
+	iov_iter_reexpand(vio->vui_iter, vio->vui_tot_count  -= nob);
 }
 
 /**
@@ -461,13 +461,13 @@ int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
 
 again:
 	if (cl_io_init(env, io, CIT_SETATTR, io->ci_obj) == 0) {
-		struct vvp_io *cio = vvp_env_io(env);
+		struct vvp_io *vio = vvp_env_io(env);
 
 		if (attr->ia_valid & ATTR_FILE)
 			/* populate the file descriptor for ftruncate to honor
 			 * group lock - see LU-787
 			 */
-			cio->cui_fd = LUSTRE_FPRIVATE(attr->ia_file);
+			vio->vui_fd = LUSTRE_FPRIVATE(attr->ia_file);
 
 		result = cl_io_loop(env, io);
 	} else {
@@ -496,12 +496,12 @@ again:
 struct vvp_io *cl2vvp_io(const struct lu_env *env,
 			 const struct cl_io_slice *slice)
 {
-	struct vvp_io *cio;
+	struct vvp_io *vio;
 
-	cio = container_of(slice, struct vvp_io, cui_cl);
-	LASSERT(cio == vvp_env_io(env));
+	vio = container_of(slice, struct vvp_io, vui_cl);
+	LASSERT(vio == vvp_env_io(env));
 
-	return cio;
+	return vio;
 }
 
 struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice)
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 7c214f8..a7693c5 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -146,14 +146,14 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
 
 	rc = cl_io_init(env, io, CIT_FAULT, io->ci_obj);
 	if (rc == 0) {
-		struct vvp_io *cio = vvp_env_io(env);
+		struct vvp_io *vio = vvp_env_io(env);
 		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 
-		LASSERT(cio->cui_cl.cis_io == io);
+		LASSERT(vio->vui_cl.cis_io == io);
 
 		/* mmap lock must be MANDATORY it has to cache pages. */
 		io->ci_lockreq = CILR_MANDATORY;
-		cio->cui_fd = fd;
+		vio->vui_fd = fd;
 	} else {
 		LASSERT(rc < 0);
 		cl_io_fini(env, io);
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index da44107..634f0bb 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -90,7 +90,7 @@ struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
 	struct lu_env    *env;
 	struct cl_io     *io;
 	struct cl_object *clob;
-	struct vvp_io    *cio;
+	struct vvp_io    *vio;
 
 	int refcheck;
 	int result = 0;
@@ -108,8 +108,8 @@ struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
 	lcc->lcc_refcheck = refcheck;
 	lcc->lcc_cookie = current;
 
-	cio = vvp_env_io(env);
-	io = cio->cui_cl.cis_io;
+	vio = vvp_env_io(env);
+	io = vio->vui_cl.cis_io;
 	lcc->lcc_io = io;
 	if (!io) {
 		struct inode *inode = file_inode(file);
@@ -125,7 +125,7 @@ struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
 		struct cl_page   *page;
 
 		LASSERT(io->ci_state == CIS_IO_GOING);
-		LASSERT(cio->cui_fd == LUSTRE_FPRIVATE(file));
+		LASSERT(vio->vui_fd == LUSTRE_FPRIVATE(file));
 		page = cl_page_find(env, clob, vmpage->index, vmpage,
 				    CPT_CACHEABLE);
 		if (!IS_ERR(page)) {
@@ -553,10 +553,10 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	spin_lock(&ras->ras_lock);
 
 	/* Enlarge the RA window to encompass the full read */
-	if (vio->cui_ra_valid &&
+	if (vio->vui_ra_valid &&
 	    ras->ras_window_start + ras->ras_window_len <
-	    vio->cui_ra_start + vio->cui_ra_count) {
-		ras->ras_window_len = vio->cui_ra_start + vio->cui_ra_count -
+	    vio->vui_ra_start + vio->vui_ra_count) {
+		ras->ras_window_len = vio->vui_ra_start + vio->vui_ra_count -
 				      ras->ras_window_start;
 	}
 
@@ -615,15 +615,15 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	CDEBUG(D_READA, DFID ": ria: %lu/%lu, bead: %lu/%lu, hit: %d\n",
 	       PFID(lu_object_fid(&clob->co_lu)),
 	       ria->ria_start, ria->ria_end,
-	       vio->cui_ra_valid ? vio->cui_ra_start : 0,
-	       vio->cui_ra_valid ? vio->cui_ra_count : 0,
+	       vio->vui_ra_valid ? vio->vui_ra_start : 0,
+	       vio->vui_ra_valid ? vio->vui_ra_count : 0,
 	       hit);
 
 	/* at least to extend the readahead window to cover current read */
-	if (!hit && vio->cui_ra_valid &&
-	    vio->cui_ra_start + vio->cui_ra_count > ria->ria_start) {
+	if (!hit && vio->vui_ra_valid &&
+	    vio->vui_ra_start + vio->vui_ra_count > ria->ria_start) {
 		/* to the end of current read window. */
-		mlen = vio->cui_ra_start + vio->cui_ra_count - ria->ria_start;
+		mlen = vio->vui_ra_start + vio->vui_ra_count - ria->ria_start;
 		/* trim to RPC boundary */
 		start = ria->ria_start & (PTLRPC_MAX_BRW_PAGES - 1);
 		mlen = min(mlen, PTLRPC_MAX_BRW_PAGES - start);
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 2f69634..106473e 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -376,7 +376,7 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 
 	env = cl_env_get(&refcheck);
 	LASSERT(!IS_ERR(env));
-	io = vvp_env_io(env)->cui_cl.cis_io;
+	io = vvp_env_io(env)->vui_cl.cis_io;
 	LASSERT(io);
 
 	/* 0. Need locking between buffered and direct access. and race with
@@ -439,10 +439,10 @@ out:
 		inode_unlock(inode);
 
 	if (tot_bytes > 0) {
-		struct vvp_io *cio = vvp_env_io(env);
+		struct vvp_io *vio = vvp_env_io(env);
 
 		/* no commit async for direct IO */
-		cio->u.write.cui_written += tot_bytes;
+		vio->u.write.vui_written += tot_bytes;
 	}
 
 	cl_env_put(env, &refcheck);
@@ -513,8 +513,8 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	/* To avoid deadlock, try to lock page first. */
 	vmpage = grab_cache_page_nowait(mapping, index);
 	if (unlikely(!vmpage || PageDirty(vmpage) || PageWriteback(vmpage))) {
-		struct vvp_io *cio = vvp_env_io(env);
-		struct cl_page_list *plist = &cio->u.write.cui_queue;
+		struct vvp_io *vio = vvp_env_io(env);
+		struct cl_page_list *plist = &vio->u.write.vui_queue;
 
 		/* if the page is already in dirty cache, we have to commit
 		 * the pages right now; otherwise, it may cause deadlock
@@ -595,7 +595,7 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 	struct ll_cl_context *lcc = fsdata;
 	struct lu_env *env;
 	struct cl_io *io;
-	struct vvp_io *cio;
+	struct vvp_io *vio;
 	struct cl_page *page;
 	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
 	bool unplug = false;
@@ -606,21 +606,21 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 	env  = lcc->lcc_env;
 	page = lcc->lcc_page;
 	io   = lcc->lcc_io;
-	cio  = vvp_env_io(env);
+	vio  = vvp_env_io(env);
 
 	LASSERT(cl_page_is_owned(page, io));
 	if (copied > 0) {
-		struct cl_page_list *plist = &cio->u.write.cui_queue;
+		struct cl_page_list *plist = &vio->u.write.vui_queue;
 
 		lcc->lcc_page = NULL; /* page will be queued */
 
 		/* Add it into write queue */
 		cl_page_list_add(plist, page);
 		if (plist->pl_nr == 1) /* first page */
-			cio->u.write.cui_from = from;
+			vio->u.write.vui_from = from;
 		else
 			LASSERT(from == 0);
-		cio->u.write.cui_to = from + copied;
+		vio->u.write.vui_to = from + copied;
 
 		/* We may have one full RPC, commit it soon */
 		if (plist->pl_nr >= PTLRPC_MAX_BRW_PAGES)
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 443485c..e04f23e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -94,16 +94,16 @@ enum vvp_io_subtype {
  */
 struct vvp_io {
 	/** super class */
-	struct cl_io_slice     cui_cl;
-	struct cl_io_lock_link cui_link;
+	struct cl_io_slice     vui_cl;
+	struct cl_io_lock_link vui_link;
 	/**
 	 * I/O vector information to or from which read/write is going.
 	 */
-	struct iov_iter *cui_iter;
+	struct iov_iter *vui_iter;
 	/**
 	 * Total size for the left IO.
 	 */
-	size_t cui_tot_count;
+	size_t vui_tot_count;
 
 	union {
 		struct vvp_fault_io {
@@ -131,37 +131,37 @@ struct vvp_io {
 			bool		ft_flags_valid;
 		} fault;
 		struct {
-			enum ccc_setattr_lock_type cui_local_lock;
+			enum ccc_setattr_lock_type vui_local_lock;
 		} setattr;
 		struct {
-			struct pipe_inode_info	*cui_pipe;
-			unsigned int		 cui_flags;
+			struct pipe_inode_info	*vui_pipe;
+			unsigned int		 vui_flags;
 		} splice;
 		struct {
-			struct cl_page_list cui_queue;
-			unsigned long cui_written;
-			int cui_from;
-			int cui_to;
+			struct cl_page_list vui_queue;
+			unsigned long vui_written;
+			int vui_from;
+			int vui_to;
 		} write;
 	} u;
 
-	enum vvp_io_subtype	cui_io_subtype;
+	enum vvp_io_subtype	vui_io_subtype;
 
 	/**
 	 * Layout version when this IO is initialized
 	 */
-	__u32		cui_layout_gen;
+	__u32			vui_layout_gen;
 	/**
 	 * File descriptor against which IO is done.
 	 */
-	struct ll_file_data *cui_fd;
-	struct kiocb *cui_iocb;
+	struct ll_file_data	*vui_fd;
+	struct kiocb		*vui_iocb;
 
 	/* Readahead state. */
-	pgoff_t	cui_ra_start;
-	pgoff_t	cui_ra_count;
-	/* Set when cui_ra_{start,count} have been initialized. */
-	bool		cui_ra_valid;
+	pgoff_t	vui_ra_start;
+	pgoff_t	vui_ra_count;
+	/* Set when vui_ra_{start,count} have been initialized. */
+	bool		vui_ra_valid;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 1059c63..53cf2be 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -56,7 +56,7 @@ int cl_is_normalio(const struct lu_env *env, const struct cl_io *io)
 
 	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
 
-	return vio->cui_io_subtype == IO_NORMAL;
+	return vio->vui_io_subtype == IO_NORMAL;
 }
 
 /**
@@ -69,7 +69,7 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 			       struct inode *inode)
 {
 	struct ll_inode_info	*lli = ll_i2info(inode);
-	struct vvp_io		*cio = vvp_env_io(env);
+	struct vvp_io		*vio = vvp_env_io(env);
 	bool rc = true;
 
 	switch (io->ci_type) {
@@ -78,7 +78,7 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 		/* don't need lock here to check lli_layout_gen as we have held
 		 * extent lock and GROUP lock has to hold to swap layout
 		 */
-		if (ll_layout_version_get(lli) != cio->cui_layout_gen) {
+		if (ll_layout_version_get(lli) != vio->vui_layout_gen) {
 			io->ci_need_restart = 1;
 			/* this will return application a short read/write */
 			io->ci_continue = 0;
@@ -102,12 +102,12 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 static int vvp_io_write_iter_init(const struct lu_env *env,
 				  const struct cl_io_slice *ios)
 {
-	struct vvp_io *cio = cl2vvp_io(env, ios);
+	struct vvp_io *vio = cl2vvp_io(env, ios);
 
-	cl_page_list_init(&cio->u.write.cui_queue);
-	cio->u.write.cui_written = 0;
-	cio->u.write.cui_from = 0;
-	cio->u.write.cui_to = PAGE_SIZE;
+	cl_page_list_init(&vio->u.write.vui_queue);
+	vio->u.write.vui_written = 0;
+	vio->u.write.vui_from = 0;
+	vio->u.write.vui_to = PAGE_SIZE;
 
 	return 0;
 }
@@ -115,9 +115,9 @@ static int vvp_io_write_iter_init(const struct lu_env *env,
 static void vvp_io_write_iter_fini(const struct lu_env *env,
 				   const struct cl_io_slice *ios)
 {
-	struct vvp_io *cio = cl2vvp_io(env, ios);
+	struct vvp_io *vio = cl2vvp_io(env, ios);
 
-	LASSERT(cio->u.write.cui_queue.pl_nr == 0);
+	LASSERT(vio->u.write.vui_queue.pl_nr == 0);
 }
 
 static int vvp_io_fault_iter_init(const struct lu_env *env,
@@ -126,7 +126,7 @@ static int vvp_io_fault_iter_init(const struct lu_env *env,
 	struct vvp_io *vio   = cl2vvp_io(env, ios);
 	struct inode  *inode = vvp_object_inode(ios->cis_obj);
 
-	LASSERT(inode == file_inode(vio->cui_fd->fd_file));
+	LASSERT(inode == file_inode(vio->vui_fd->fd_file));
 	vio->u.fault.ft_mtime = inode->i_mtime.tv_sec;
 	return 0;
 }
@@ -135,7 +135,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	struct cl_io     *io  = ios->cis_io;
 	struct cl_object *obj = io->ci_obj;
-	struct vvp_io    *cio = cl2vvp_io(env, ios);
+	struct vvp_io    *vio = cl2vvp_io(env, ios);
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
@@ -143,7 +143,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	       " ignore/verify layout %d/%d, layout version %d restore needed %d\n",
 	       PFID(lu_object_fid(&obj->co_lu)),
 	       io->ci_ignore_layout, io->ci_verify_layout,
-	       cio->cui_layout_gen, io->ci_restore_needed);
+	       vio->vui_layout_gen, io->ci_restore_needed);
 
 	if (io->ci_restore_needed == 1) {
 		int	rc;
@@ -178,12 +178,12 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 
 		/* check layout version */
 		ll_layout_refresh(vvp_object_inode(obj), &gen);
-		io->ci_need_restart = cio->cui_layout_gen != gen;
+		io->ci_need_restart = vio->vui_layout_gen != gen;
 		if (io->ci_need_restart) {
 			CDEBUG(D_VFSTRACE,
 			       DFID" layout changed from %d to %d.\n",
 			       PFID(lu_object_fid(&obj->co_lu)),
-			       cio->cui_layout_gen, gen);
+			       vio->vui_layout_gen, gen);
 			/* today successful restore is the only possible case */
 			/* restore was done, clear restoring state */
 			ll_i2info(vvp_object_inode(obj))->lli_flags &=
@@ -239,14 +239,14 @@ static int vvp_mmap_locks(const struct lu_env *env,
 	if (!cl_is_normalio(env, io))
 		return 0;
 
-	if (!vio->cui_iter) /* nfs or loop back device write */
+	if (!vio->vui_iter) /* nfs or loop back device write */
 		return 0;
 
 	/* No MM (e.g. NFS)? No vmas too. */
 	if (!mm)
 		return 0;
 
-	iov_for_each(iov, i, *(vio->cui_iter)) {
+	iov_for_each(iov, i, *vio->vui_iter) {
 		addr = (unsigned long)iov.iov_base;
 		count = iov.iov_len;
 		if (count == 0)
@@ -306,17 +306,17 @@ static int vvp_mmap_locks(const struct lu_env *env,
 static int vvp_io_rw_lock(const struct lu_env *env, struct cl_io *io,
 			  enum cl_lock_mode mode, loff_t start, loff_t end)
 {
-	struct vvp_io *cio = vvp_env_io(env);
+	struct vvp_io *vio = vvp_env_io(env);
 	int result;
 	int ast_flags = 0;
 
 	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
 
-	vvp_io_update_iov(env, cio, io);
+	vvp_io_update_iov(env, vio, io);
 
 	if (io->u.ci_rw.crw_nonblock)
 		ast_flags |= CEF_NONBLOCK;
-	result = vvp_mmap_locks(env, cio, io);
+	result = vvp_mmap_locks(env, vio, io);
 	if (result == 0)
 		result = vvp_io_one_lock(env, io, ast_flags, mode, start, end);
 	return result;
@@ -374,14 +374,14 @@ static int vvp_io_setattr_iter_init(const struct lu_env *env,
 }
 
 /**
- * Implementation of cl_io_operations::cio_lock() method for CIT_SETATTR io.
+ * Implementation of cl_io_operations::vio_lock() method for CIT_SETATTR io.
  *
  * Handles "lockless io" mode when extent locking is done by server.
  */
 static int vvp_io_setattr_lock(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
-	struct vvp_io *cio = vvp_env_io(env);
+	struct vvp_io *vio = vvp_env_io(env);
 	struct cl_io  *io  = ios->cis_io;
 	__u64 new_size;
 	__u32 enqflags = 0;
@@ -398,7 +398,8 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 			return 0;
 		new_size = 0;
 	}
-	cio->u.setattr.cui_local_lock = SETATTR_EXTENT_LOCK;
+
+	vio->u.setattr.vui_local_lock = SETATTR_EXTENT_LOCK;
 
 	return vvp_io_one_lock(env, io, enqflags, CLM_WRITE,
 			       new_size, OBD_OBJECT_EOF);
@@ -498,12 +499,12 @@ static int vvp_io_read_start(const struct lu_env *env,
 	struct cl_io      *io    = ios->cis_io;
 	struct cl_object  *obj   = io->ci_obj;
 	struct inode      *inode = vvp_object_inode(obj);
-	struct file       *file  = vio->cui_fd->fd_file;
+	struct file       *file  = vio->vui_fd->fd_file;
 
 	int     result;
 	loff_t  pos = io->u.ci_rd.rd.crw_pos;
 	long    cnt = io->u.ci_rd.rd.crw_count;
-	long    tot = vio->cui_tot_count;
+	long    tot = vio->vui_tot_count;
 	int     exceed = 0;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
@@ -524,27 +525,27 @@ static int vvp_io_read_start(const struct lu_env *env,
 			 inode->i_ino, cnt, pos, i_size_read(inode));
 
 	/* turn off the kernel's read-ahead */
-	vio->cui_fd->fd_file->f_ra.ra_pages = 0;
+	vio->vui_fd->fd_file->f_ra.ra_pages = 0;
 
 	/* initialize read-ahead window once per syscall */
-	if (!vio->cui_ra_valid) {
-		vio->cui_ra_valid = true;
-		vio->cui_ra_start = cl_index(obj, pos);
-		vio->cui_ra_count = cl_index(obj, tot + PAGE_CACHE_SIZE - 1);
+	if (!vio->vui_ra_valid) {
+		vio->vui_ra_valid = true;
+		vio->vui_ra_start = cl_index(obj, pos);
+		vio->vui_ra_count = cl_index(obj, tot + PAGE_CACHE_SIZE - 1);
 		ll_ras_enter(file);
 	}
 
 	/* BUG: 5972 */
 	file_accessed(file);
-	switch (vio->cui_io_subtype) {
+	switch (vio->vui_io_subtype) {
 	case IO_NORMAL:
-		LASSERT(vio->cui_iocb->ki_pos == pos);
-		result = generic_file_read_iter(vio->cui_iocb, vio->cui_iter);
+		LASSERT(vio->vui_iocb->ki_pos == pos);
+		result = generic_file_read_iter(vio->vui_iocb, vio->vui_iter);
 		break;
 	case IO_SPLICE:
 		result = generic_file_splice_read(file, &pos,
-						  vio->u.splice.cui_pipe, cnt,
-						  vio->u.splice.cui_flags);
+						  vio->u.splice.vui_pipe, cnt,
+						  vio->u.splice.vui_flags);
 		/* LU-1109: do splice read stripe by stripe otherwise if it
 		 * may make nfsd stuck if this read occupied all internal pipe
 		 * buffers.
@@ -552,7 +553,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 		io->ci_continue = 0;
 		break;
 	default:
-		CERROR("Wrong IO type %u\n", vio->cui_io_subtype);
+		CERROR("Wrong IO type %u\n", vio->vui_io_subtype);
 		LBUG();
 	}
 
@@ -562,7 +563,7 @@ out:
 			io->ci_continue = 0;
 		io->ci_nob += result;
 		ll_rw_stats_tally(ll_i2sbi(inode), current->pid,
-				  vio->cui_fd, pos, result, READ);
+				  vio->vui_fd, pos, result, READ);
 		result = 0;
 	}
 	return result;
@@ -674,24 +675,24 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 {
 	struct cl_object *obj = io->ci_obj;
 	struct inode *inode = vvp_object_inode(obj);
-	struct vvp_io *cio = vvp_env_io(env);
-	struct cl_page_list *queue = &cio->u.write.cui_queue;
+	struct vvp_io *vio = vvp_env_io(env);
+	struct cl_page_list *queue = &vio->u.write.vui_queue;
 	struct cl_page *page;
 	int rc = 0;
 	int bytes = 0;
-	unsigned int npages = cio->u.write.cui_queue.pl_nr;
+	unsigned int npages = vio->u.write.vui_queue.pl_nr;
 
 	if (npages == 0)
 		return 0;
 
 	CDEBUG(D_VFSTRACE, "commit async pages: %d, from %d, to %d\n",
-	       npages, cio->u.write.cui_from, cio->u.write.cui_to);
+	       npages, vio->u.write.vui_from, vio->u.write.vui_to);
 
 	LASSERT(page_list_sanity_check(obj, queue));
 
 	/* submit IO with async write */
 	rc = cl_io_commit_async(env, io, queue,
-				cio->u.write.cui_from, cio->u.write.cui_to,
+				vio->u.write.vui_from, vio->u.write.vui_to,
 				write_commit_callback);
 	npages -= queue->pl_nr; /* already committed pages */
 	if (npages > 0) {
@@ -699,18 +700,18 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 		bytes = npages << PAGE_SHIFT;
 
 		/* first page */
-		bytes -= cio->u.write.cui_from;
+		bytes -= vio->u.write.vui_from;
 		if (queue->pl_nr == 0) /* last page */
-			bytes -= PAGE_SIZE - cio->u.write.cui_to;
+			bytes -= PAGE_SIZE - vio->u.write.vui_to;
 		LASSERTF(bytes > 0, "bytes = %d, pages = %d\n", bytes, npages);
 
-		cio->u.write.cui_written += bytes;
+		vio->u.write.vui_written += bytes;
 
 		CDEBUG(D_VFSTRACE, "Committed %d pages %d bytes, tot: %ld\n",
-		       npages, bytes, cio->u.write.cui_written);
+		       npages, bytes, vio->u.write.vui_written);
 
 		/* the first page must have been written. */
-		cio->u.write.cui_from = 0;
+		vio->u.write.vui_from = 0;
 	}
 	LASSERT(page_list_sanity_check(obj, queue));
 	LASSERT(ergo(rc == 0, queue->pl_nr == 0));
@@ -718,10 +719,10 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 	/* out of quota, try sync write */
 	if (rc == -EDQUOT && !cl_io_is_mkwrite(io)) {
 		rc = vvp_io_commit_sync(env, io, queue,
-					cio->u.write.cui_from,
-					cio->u.write.cui_to);
+					vio->u.write.vui_from,
+					vio->u.write.vui_to);
 		if (rc > 0) {
-			cio->u.write.cui_written += rc;
+			vio->u.write.vui_written += rc;
 			rc = 0;
 		}
 	}
@@ -753,7 +754,7 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 static int vvp_io_write_start(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
-	struct vvp_io      *cio   = cl2vvp_io(env, ios);
+	struct vvp_io      *vio   = cl2vvp_io(env, ios);
 	struct cl_io       *io    = ios->cis_io;
 	struct cl_object   *obj   = io->ci_obj;
 	struct inode       *inode = vvp_object_inode(obj);
@@ -771,22 +772,22 @@ static int vvp_io_write_start(const struct lu_env *env,
 		 */
 		ll_merge_attr(env, inode);
 		pos = io->u.ci_wr.wr.crw_pos = i_size_read(inode);
-		cio->cui_iocb->ki_pos = pos;
+		vio->vui_iocb->ki_pos = pos;
 	} else {
-		LASSERT(cio->cui_iocb->ki_pos == pos);
+		LASSERT(vio->vui_iocb->ki_pos == pos);
 	}
 
 	CDEBUG(D_VFSTRACE, "write: [%lli, %lli)\n", pos, pos + (long long)cnt);
 
-	if (!cio->cui_iter) /* from a temp io in ll_cl_init(). */
+	if (!vio->vui_iter) /* from a temp io in ll_cl_init(). */
 		result = 0;
 	else
-		result = generic_file_write_iter(cio->cui_iocb, cio->cui_iter);
+		result = generic_file_write_iter(vio->vui_iocb, vio->vui_iter);
 
 	if (result > 0) {
 		result = vvp_io_write_commit(env, io);
-		if (cio->u.write.cui_written > 0) {
-			result = cio->u.write.cui_written;
+		if (vio->u.write.vui_written > 0) {
+			result = vio->u.write.vui_written;
 			io->ci_nob += result;
 
 			CDEBUG(D_VFSTRACE, "write: nob %zd, result: %zd\n",
@@ -803,7 +804,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 		if (result < cnt)
 			io->ci_continue = 0;
 		ll_rw_stats_tally(ll_i2sbi(inode), current->pid,
-				  cio->cui_fd, pos, result, WRITE);
+				  vio->vui_fd, pos, result, WRITE);
 		result = 0;
 	}
 	return result;
@@ -1047,7 +1048,7 @@ static int vvp_io_read_page(const struct lu_env *env,
 	struct cl_page	    *page   = slice->cpl_page;
 	struct inode              *inode  = vvp_object_inode(slice->cpl_obj);
 	struct ll_sb_info	 *sbi    = ll_i2sbi(inode);
-	struct ll_file_data       *fd     = cl2vvp_io(env, ios)->cui_fd;
+	struct ll_file_data       *fd     = cl2vvp_io(env, ios)->vui_fd;
 	struct ll_readahead_state *ras    = &fd->fd_ras;
 	struct cl_2queue	  *queue  = &io->ci_queue;
 
@@ -1128,11 +1129,11 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 	       " ignore/verify layout %d/%d, layout version %d restore needed %d\n",
 	       PFID(lu_object_fid(&obj->co_lu)),
 	       io->ci_ignore_layout, io->ci_verify_layout,
-	       vio->cui_layout_gen, io->ci_restore_needed);
+	       vio->vui_layout_gen, io->ci_restore_needed);
 
-	CL_IO_SLICE_CLEAN(vio, cui_cl);
-	cl_io_slice_add(io, &vio->cui_cl, obj, &vvp_io_ops);
-	vio->cui_ra_valid = false;
+	CL_IO_SLICE_CLEAN(vio, vui_cl);
+	cl_io_slice_add(io, &vio->vui_cl, obj, &vvp_io_ops);
+	vio->vui_ra_valid = false;
 	result = 0;
 	if (io->ci_type == CIT_READ || io->ci_type == CIT_WRITE) {
 		size_t count;
@@ -1145,7 +1146,7 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		if (count == 0)
 			result = 1;
 		else
-			vio->cui_tot_count = count;
+			vio->vui_tot_count = count;
 
 		/* for read/write, we store the jobid in the inode, and
 		 * it'll be fetched by osc when building RPC.
@@ -1171,7 +1172,7 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 	 * because it might not grant layout lock in IT_OPEN.
 	 */
 	if (result == 0 && !io->ci_ignore_layout) {
-		result = ll_layout_refresh(inode, &vio->cui_layout_gen);
+		result = ll_layout_refresh(inode, &vio->vui_layout_gen);
 		if (result == -ENOENT)
 			/* If the inode on MDS has been removed, but the objects
 			 * on OSTs haven't been destroyed (async unlink), layout
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 4f7dfe2..69316c1 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -372,9 +372,9 @@ static int vvp_page_is_under_lock(const struct lu_env *env,
 {
 	if (io->ci_type == CIT_READ || io->ci_type == CIT_WRITE ||
 	    io->ci_type == CIT_FAULT) {
-		struct vvp_io *cio = vvp_env_io(env);
+		struct vvp_io *vio = vvp_env_io(env);
 
-		if (unlikely(cio->cui_fd->fd_flags & LL_FILE_GROUP_LOCKED))
+		if (unlikely(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED))
 			*max_index = CL_PAGE_EOF;
 	}
 	return 0;
-- 
2.1.0
