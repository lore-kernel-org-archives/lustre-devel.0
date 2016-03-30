From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:50 -0400
Subject: [lustre-devel] [PATCH v2 29/46] staging/lustre:llite: remove struct
	ll_ra_read
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-30-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Ever since removal of the the unused function ll_ra_read_get(),
the struct ll_ra_read members lrr_reader and lrr_linkage and
the struct ll_readahead_state member ras_read_beads unnecessary
so remove them.
In struct vvp_io replace the struct ll_ra_read cui_bead member with
cui_ra_start and cui_ra_count.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/13347
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/llite/llite_internal.h   | 30 +++---------
 drivers/staging/lustre/lustre/llite/rw.c           | 53 ++++++----------------
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 31 ++++---------
 3 files changed, 28 insertions(+), 86 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 78b3edd..9dd4325 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -528,13 +528,6 @@ struct ll_sb_info {
 	struct completion	 ll_kobj_unregister;
 };
 
-struct ll_ra_read {
-	pgoff_t	     lrr_start;
-	pgoff_t	     lrr_count;
-	struct task_struct *lrr_reader;
-	struct list_head	  lrr_linkage;
-};
-
 /*
  * per file-descriptor read-ahead data.
  */
@@ -593,12 +586,6 @@ struct ll_readahead_state {
 	 */
 	unsigned long   ras_request_index;
 	/*
-	 * list of struct ll_ra_read's one per read(2) call current in
-	 * progress against this file descriptor. Used by read-ahead code,
-	 * protected by ->ras_lock.
-	 */
-	struct list_head      ras_read_beads;
-	/*
 	 * The following 3 items are used for detecting the stride I/O
 	 * mode.
 	 * In stride I/O mode,
@@ -666,8 +653,7 @@ static inline int ll_need_32bit_api(struct ll_sb_info *sbi)
 #endif
 }
 
-void ll_ra_read_in(struct file *f, struct ll_ra_read *rar);
-void ll_ra_read_ex(struct file *f, struct ll_ra_read *rar);
+void ll_ras_enter(struct file *f);
 
 /* llite/lproc_llite.c */
 int ldebugfs_register_mountpoint(struct dentry *parent,
@@ -876,14 +862,12 @@ struct vvp_io {
 			} fault;
 		} fault;
 	} u;
-	/**
-	 * Read-ahead state used by read and page-fault IO contexts.
-	 */
-	struct ll_ra_read    cui_bead;
-	/**
-	 * Set when cui_bead has been initialized.
-	 */
-	int		  cui_ra_window_set;
+
+	/* Readahead state. */
+	pgoff_t	cui_ra_start;
+	pgoff_t cui_ra_count;
+	/* Set when cui_ra_{start,count} have been initialized. */
+	bool	cui_ra_valid;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 2c4d4c4..f06d8be 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -258,38 +258,15 @@ static int index_in_window(unsigned long index, unsigned long point,
 	return start <= index && index <= end;
 }
 
-static struct ll_readahead_state *ll_ras_get(struct file *f)
+void ll_ras_enter(struct file *f)
 {
-	struct ll_file_data       *fd;
-
-	fd = LUSTRE_FPRIVATE(f);
-	return &fd->fd_ras;
-}
-
-void ll_ra_read_in(struct file *f, struct ll_ra_read *rar)
-{
-	struct ll_readahead_state *ras;
-
-	ras = ll_ras_get(f);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(f);
+	struct ll_readahead_state *ras = &fd->fd_ras;
 
 	spin_lock(&ras->ras_lock);
 	ras->ras_requests++;
 	ras->ras_request_index = 0;
 	ras->ras_consecutive_requests++;
-	rar->lrr_reader = current;
-
-	list_add(&rar->lrr_linkage, &ras->ras_read_beads);
-	spin_unlock(&ras->ras_lock);
-}
-
-void ll_ra_read_ex(struct file *f, struct ll_ra_read *rar)
-{
-	struct ll_readahead_state *ras;
-
-	ras = ll_ras_get(f);
-
-	spin_lock(&ras->ras_lock);
-	list_del_init(&rar->lrr_linkage);
 	spin_unlock(&ras->ras_lock);
 }
 
@@ -551,7 +528,6 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	unsigned long start = 0, end = 0, reserved;
 	unsigned long ra_end, len, mlen = 0;
 	struct inode *inode;
-	struct ll_ra_read *bead;
 	struct ra_io_arg *ria = &vti->vti_ria;
 	struct cl_object *clob;
 	int ret = 0;
@@ -575,17 +551,15 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	}
 
 	spin_lock(&ras->ras_lock);
-	if (vio->cui_ra_window_set)
-		bead = &vio->cui_bead;
-	else
-		bead = NULL;
 
 	/* Enlarge the RA window to encompass the full read */
-	if (bead && ras->ras_window_start + ras->ras_window_len <
-	    bead->lrr_start + bead->lrr_count) {
-		ras->ras_window_len = bead->lrr_start + bead->lrr_count -
+	if (vio->cui_ra_valid &&
+	    ras->ras_window_start + ras->ras_window_len <
+	    vio->cui_ra_start + vio->cui_ra_count) {
+		ras->ras_window_len = vio->cui_ra_start + vio->cui_ra_count -
 				      ras->ras_window_start;
 	}
+
 	/* Reserve a part of the read-ahead window that we'll be issuing */
 	if (ras->ras_window_len) {
 		start = ras->ras_next_readahead;
@@ -641,15 +615,15 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	CDEBUG(D_READA, DFID ": ria: %lu/%lu, bead: %lu/%lu, hit: %d\n",
 	       PFID(lu_object_fid(&clob->co_lu)),
 	       ria->ria_start, ria->ria_end,
-	       !bead ? 0 : bead->lrr_start,
-	       !bead ? 0 : bead->lrr_count,
+	       vio->cui_ra_valid ? vio->cui_ra_start : 0,
+	       vio->cui_ra_valid ? vio->cui_ra_count : 0,
 	       hit);
 
 	/* at least to extend the readahead window to cover current read */
-	if (!hit && bead &&
-	    bead->lrr_start + bead->lrr_count > ria->ria_start) {
+	if (!hit && vio->cui_ra_valid &&
+	    vio->cui_ra_start + vio->cui_ra_count > ria->ria_start) {
 		/* to the end of current read window. */
-		mlen = bead->lrr_start + bead->lrr_count - ria->ria_start;
+		mlen = vio->cui_ra_start + vio->cui_ra_count - ria->ria_start;
 		/* trim to RPC boundary */
 		start = ria->ria_start & (PTLRPC_MAX_BRW_PAGES - 1);
 		mlen = min(mlen, PTLRPC_MAX_BRW_PAGES - start);
@@ -730,7 +704,6 @@ void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras)
 	spin_lock_init(&ras->ras_lock);
 	ras_reset(inode, ras, 0);
 	ras->ras_requests = 0;
-	INIT_LIST_HEAD(&ras->ras_read_beads);
 }
 
 /*
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index eb6ce1c..86e73d5 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -500,7 +500,6 @@ static int vvp_io_read_start(const struct lu_env *env,
 	struct cl_io      *io    = ios->cis_io;
 	struct cl_object  *obj   = io->ci_obj;
 	struct inode      *inode = vvp_object_inode(obj);
-	struct ll_ra_read *bead  = &vio->cui_bead;
 	struct file       *file  = cio->cui_fd->fd_file;
 
 	int     result;
@@ -530,14 +529,11 @@ static int vvp_io_read_start(const struct lu_env *env,
 	cio->cui_fd->fd_file->f_ra.ra_pages = 0;
 
 	/* initialize read-ahead window once per syscall */
-	if (!vio->cui_ra_window_set) {
-		vio->cui_ra_window_set = 1;
-		bead->lrr_start = cl_index(obj, pos);
-		/*
-		 * XXX: explicit PAGE_CACHE_SIZE
-		 */
-		bead->lrr_count = cl_index(obj, tot + PAGE_CACHE_SIZE - 1);
-		ll_ra_read_in(file, bead);
+	if (!vio->cui_ra_valid) {
+		vio->cui_ra_valid = true;
+		vio->cui_ra_start = cl_index(obj, pos);
+		vio->cui_ra_count = cl_index(obj, tot + PAGE_CACHE_SIZE - 1);
+		ll_ras_enter(file);
 	}
 
 	/* BUG: 5972 */
@@ -574,17 +570,6 @@ out:
 	return result;
 }
 
-static void vvp_io_read_fini(const struct lu_env *env, const struct cl_io_slice *ios)
-{
-	struct vvp_io *vio = cl2vvp_io(env, ios);
-	struct ccc_io *cio = cl2ccc_io(env, ios);
-
-	if (vio->cui_ra_window_set)
-		ll_ra_read_ex(cio->cui_fd->fd_file, &vio->cui_bead);
-
-	vvp_io_fini(env, ios);
-}
-
 static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
 			      struct cl_page_list *plist, int from, int to)
 {
@@ -1092,10 +1077,10 @@ static int vvp_io_read_page(const struct lu_env *env,
 static const struct cl_io_operations vvp_io_ops = {
 	.op = {
 		[CIT_READ] = {
-			.cio_fini      = vvp_io_read_fini,
+			.cio_fini	= vvp_io_fini,
 			.cio_lock      = vvp_io_read_lock,
 			.cio_start     = vvp_io_read_start,
-			.cio_advance   = ccc_io_advance
+			.cio_advance	= ccc_io_advance,
 		},
 		[CIT_WRITE] = {
 			.cio_fini      = vvp_io_fini,
@@ -1148,7 +1133,7 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 
 	CL_IO_SLICE_CLEAN(cio, cui_cl);
 	cl_io_slice_add(io, &cio->cui_cl, obj, &vvp_io_ops);
-	vio->cui_ra_window_set = 0;
+	vio->cui_ra_valid = false;
 	result = 0;
 	if (io->ci_type == CIT_READ || io->ci_type == CIT_WRITE) {
 		size_t count;
-- 
2.1.0
