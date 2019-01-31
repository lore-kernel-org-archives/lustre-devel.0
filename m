From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:20 -0500
Subject: [lustre-devel] [PATCH 16/26] obdclass: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The obdclass code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/obdclass/cl_internal.h   |   2 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  28 ++---
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |   2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  40 +++---
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  62 ++++-----
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   6 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  16 +--
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |   8 +-
 drivers/staging/lustre/lustre/obdclass/linkea.c    |   6 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |  40 +++---
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |   6 +-
 .../staging/lustre/lustre/obdclass/llog_internal.h |  24 ++--
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |  16 +--
 .../lustre/lustre/obdclass/lprocfs_counters.c      |  16 +--
 .../lustre/lustre/obdclass/lprocfs_status.c        | 140 ++++++++++-----------
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  98 +++++++--------
 .../lustre/lustre/obdclass/lustre_handles.c        |   2 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |   8 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  35 +++---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  15 ++-
 20 files changed, 283 insertions(+), 287 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_internal.h b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
index 8770e32..dc6bf10 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
@@ -44,7 +44,7 @@ struct cl_thread_info {
 	/**
 	 * Used for submitting a sync I/O.
 	 */
-	struct cl_sync_io    clt_anchor;
+	struct cl_sync_io	clt_anchor;
 };
 
 struct cl_thread_info *cl_env_info(const struct lu_env *env);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index d3f2455..09fd45d 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -86,7 +86,7 @@ static int cl_io_invariant(const struct cl_io *io)
  */
 void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 {
-	struct cl_io_slice    *slice;
+	struct cl_io_slice *slice;
 
 	LINVRNT(cl_io_type_is_valid(io->ci_type));
 	LINVRNT(cl_io_invariant(io));
@@ -207,8 +207,8 @@ int cl_io_rw_init(const struct lu_env *env, struct cl_io *io,
 			 "io range: %u [%llu, %llu) %u %u\n",
 			 iot, (u64)pos, (u64)pos + count,
 			 io->u.ci_rw.crw_nonblock, io->u.ci_wr.wr_append);
-	io->u.ci_rw.crw_pos    = pos;
-	io->u.ci_rw.crw_count  = count;
+	io->u.ci_rw.crw_pos = pos;
+	io->u.ci_rw.crw_count = count;
 	return cl_io_init(env, io, iot, io->ci_obj);
 }
 EXPORT_SYMBOL(cl_io_rw_init);
@@ -363,9 +363,9 @@ int cl_io_lock(const struct lu_env *env, struct cl_io *io)
  */
 void cl_io_unlock(const struct lu_env *env, struct cl_io *io)
 {
-	struct cl_lockset	*set;
-	struct cl_io_lock_link   *link;
-	struct cl_io_lock_link   *temp;
+	struct cl_lockset *set;
+	struct cl_io_lock_link *link;
+	struct cl_io_lock_link *temp;
 	const struct cl_io_slice *scan;
 
 	LASSERT(cl_io_is_loopable(io));
@@ -460,7 +460,7 @@ static void cl_io_rw_advance(const struct lu_env *env, struct cl_io *io,
 	LINVRNT(cl_io_is_loopable(io));
 	LINVRNT(cl_io_invariant(io));
 
-	io->u.ci_rw.crw_pos   += nob;
+	io->u.ci_rw.crw_pos += nob;
 	io->u.ci_rw.crw_count -= nob;
 
 	/* layers have to be notified. */
@@ -506,8 +506,8 @@ int cl_io_lock_alloc_add(const struct lu_env *env, struct cl_io *io,
 
 	link = kzalloc(sizeof(*link), GFP_NOFS);
 	if (link) {
-		link->cill_descr     = *descr;
-		link->cill_fini      = cl_free_io_lock_link;
+		link->cill_descr = *descr;
+		link->cill_fini = cl_free_io_lock_link;
 		result = cl_io_lock_add(env, io, link);
 		if (result) /* lock match */
 			link->cill_fini(env, link);
@@ -575,7 +575,7 @@ int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 		     pgoff_t start, struct cl_read_ahead *ra)
 {
 	const struct cl_io_slice *scan;
-	int		       result = 0;
+	int result = 0;
 
 	LINVRNT(io->ci_type == CIT_READ || io->ci_type == CIT_FAULT);
 	LINVRNT(cl_io_invariant(io));
@@ -715,7 +715,7 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
  */
 int cl_io_loop(const struct lu_env *env, struct cl_io *io)
 {
-	int result   = 0;
+	int result = 0;
 
 	LINVRNT(cl_io_is_loopable(io));
 
@@ -725,7 +725,7 @@ int cl_io_loop(const struct lu_env *env, struct cl_io *io)
 		io->ci_continue = 0;
 		result = cl_io_iter_init(env, io);
 		if (result == 0) {
-			nob    = io->ci_nob;
+			nob = io->ci_nob;
 			result = cl_io_lock(env, io);
 			if (result == 0) {
 				/*
@@ -774,7 +774,7 @@ void cl_io_slice_add(struct cl_io *io, struct cl_io_slice *slice,
 		list_empty(linkage));
 
 	list_add_tail(linkage, &io->ci_layers);
-	slice->cis_io  = io;
+	slice->cis_io = io;
 	slice->cis_obj = obj;
 	slice->cis_iop = ops;
 }
@@ -879,7 +879,6 @@ void cl_page_list_splice(struct cl_page_list *list, struct cl_page_list *head)
 }
 EXPORT_SYMBOL(cl_page_list_splice);
 
-
 /**
  * Disowns pages in a queue.
  */
@@ -1102,7 +1101,6 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 	while (unlikely(atomic_read(&anchor->csi_barrier) != 0))
 		cpu_relax();
 
-
 	return rc;
 }
 EXPORT_SYMBOL(cl_sync_io_wait);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 425ca9c..d7bcb8c 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -243,7 +243,7 @@ void cl_lock_descr_print(const struct lu_env *env, void *cookie,
 			 lu_printer_t printer,
 			 const struct cl_lock_descr *descr)
 {
-	const struct lu_fid  *fid;
+	const struct lu_fid *fid;
 
 	fid = lu_object_fid(&descr->cld_obj->co_lu);
 	(*printer)(env, cookie, DDESCR "@" DFID, PDESCR(descr), PFID(fid));
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 5b59a71..05d784a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -483,8 +483,8 @@ void cl_site_fini(struct cl_site *s)
 EXPORT_SYMBOL(cl_site_fini);
 
 static struct cache_stats cl_env_stats = {
-	.cs_name    = "envs",
-	.cs_stats = { ATOMIC_INIT(0), }
+	.cs_name	= "envs",
+	.cs_stats	= { ATOMIC_INIT(0), }
 };
 
 /**
@@ -495,11 +495,11 @@ int cl_site_stats_print(const struct cl_site *site, struct seq_file *m)
 {
 	size_t i;
 	static const char * const pstate[] = {
-		[CPS_CACHED]  = "c",
-		[CPS_OWNED]   = "o",
-		[CPS_PAGEOUT] = "w",
-		[CPS_PAGEIN]  = "r",
-		[CPS_FREEING] = "f"
+		[CPS_CACHED]	= "c",
+		[CPS_OWNED]	= "o",
+		[CPS_PAGEOUT]	= "w",
+		[CPS_PAGEIN]	= "r",
+		[CPS_FREEING]	= "f"
 	};
 /*
        lookup    hit  total   busy create
@@ -553,9 +553,9 @@ int cl_site_stats_print(const struct cl_site *site, struct seq_file *m)
 } *cl_envs = NULL;
 
 struct cl_env {
-	void	     *ce_magic;
-	struct lu_env     ce_lu;
-	struct lu_context ce_ses;
+	void		       *ce_magic;
+	struct lu_env		ce_lu;
+	struct lu_context	ce_ses;
 
 	/*
 	 * Linkage into global list of all client environments. Used for
@@ -565,12 +565,12 @@ struct cl_env {
 	/*
 	 *
 	 */
-	int	       ce_ref;
+	int			ce_ref;
 	/*
 	 * Debugging field: address of the caller who made original
 	 * allocation.
 	 */
-	void	     *ce_debug;
+	void		       *ce_debug;
 };
 
 static void cl_env_inc(enum cache_stats_item item)
@@ -818,10 +818,10 @@ void cl_env_put(struct lu_env *env, u16 *refcheck)
  */
 void cl_lvb2attr(struct cl_attr *attr, const struct ost_lvb *lvb)
 {
-	attr->cat_size   = lvb->lvb_size;
-	attr->cat_mtime  = lvb->lvb_mtime;
-	attr->cat_atime  = lvb->lvb_atime;
-	attr->cat_ctime  = lvb->lvb_ctime;
+	attr->cat_size = lvb->lvb_size;
+	attr->cat_mtime = lvb->lvb_mtime;
+	attr->cat_atime = lvb->lvb_atime;
+	attr->cat_ctime = lvb->lvb_ctime;
 	attr->cat_blocks = lvb->lvb_blocks;
 }
 EXPORT_SYMBOL(cl_lvb2attr);
@@ -936,7 +936,7 @@ struct cl_device *cl_type_setup(const struct lu_env *env, struct lu_site *site,
 				struct lu_device_type *ldt,
 				struct lu_device *next)
 {
-	const char       *typename;
+	const char *typename;
 	struct lu_device *d;
 
 	typename = ldt->ldt_name;
@@ -983,9 +983,9 @@ struct cl_thread_info *cl_env_info(const struct lu_env *env)
 LU_KEY_INIT_FINI(cl, struct cl_thread_info);
 
 static struct lu_context_key cl_key = {
-	.lct_tags = LCT_CL_THREAD,
-	.lct_init = cl_key_init,
-	.lct_fini = cl_key_fini,
+	.lct_tags	= LCT_CL_THREAD,
+	.lct_init	= cl_key_init,
+	.lct_fini	= cl_key_fini,
 };
 
 static struct lu_kmem_descr cl_object_caches[] = {
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index a560af1..b1b4dc7 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -95,7 +95,7 @@ static void cl_page_get_trust(struct cl_page *page)
 
 static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 {
-	struct cl_object *obj  = page->cp_obj;
+	struct cl_object *obj = page->cp_obj;
 
 	PASSERT(env, page, list_empty(&page->cp_batch));
 	PASSERT(env, page, !page->cp_owner);
@@ -132,7 +132,7 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 			      struct page *vmpage,
 			      enum cl_page_type type)
 {
-	struct cl_page	  *page;
+	struct cl_page *page;
 	struct lu_object_header *head;
 
 	page = kzalloc(cl_object_header(o)->coh_page_bufsize, GFP_NOFS);
@@ -185,7 +185,7 @@ struct cl_page *cl_page_find(const struct lu_env *env,
 			     pgoff_t idx, struct page *vmpage,
 			     enum cl_page_type type)
 {
-	struct cl_page	  *page = NULL;
+	struct cl_page *page = NULL;
 	struct cl_object_header *hdr;
 
 	LASSERT(type == CPT_CACHEABLE || type == CPT_TRANSIENT);
@@ -239,39 +239,39 @@ static void __cl_page_state_set(const struct lu_env *env,
 	 */
 	static const int allowed_transitions[CPS_NR][CPS_NR] = {
 		[CPS_CACHED] = {
-			[CPS_CACHED]  = 0,
-			[CPS_OWNED]   = 1, /* io finds existing cached page */
-			[CPS_PAGEIN]  = 0,
-			[CPS_PAGEOUT] = 1, /* write-out from the cache */
-			[CPS_FREEING] = 1, /* eviction on the memory pressure */
+			[CPS_CACHED]	= 0,
+			[CPS_OWNED]	= 1, /* io finds existing cached page */
+			[CPS_PAGEIN]	= 0,
+			[CPS_PAGEOUT]	= 1, /* write-out from the cache */
+			[CPS_FREEING]	= 1, /* eviction on the memory pressure */
 		},
 		[CPS_OWNED] = {
-			[CPS_CACHED]  = 1, /* release to the cache */
-			[CPS_OWNED]   = 0,
-			[CPS_PAGEIN]  = 1, /* start read immediately */
-			[CPS_PAGEOUT] = 1, /* start write immediately */
-			[CPS_FREEING] = 1, /* lock invalidation or truncate */
+			[CPS_CACHED]	= 1, /* release to the cache */
+			[CPS_OWNED]	= 0,
+			[CPS_PAGEIN]	= 1, /* start read immediately */
+			[CPS_PAGEOUT]	= 1, /* start write immediately */
+			[CPS_FREEING]	= 1, /* lock invalidation or truncate */
 		},
 		[CPS_PAGEIN] = {
-			[CPS_CACHED]  = 1, /* io completion */
-			[CPS_OWNED]   = 0,
-			[CPS_PAGEIN]  = 0,
-			[CPS_PAGEOUT] = 0,
-			[CPS_FREEING] = 0,
+			[CPS_CACHED]	= 1, /* io completion */
+			[CPS_OWNED]	= 0,
+			[CPS_PAGEIN]	= 0,
+			[CPS_PAGEOUT]	= 0,
+			[CPS_FREEING]	= 0,
 		},
 		[CPS_PAGEOUT] = {
-			[CPS_CACHED]  = 1, /* io completion */
-			[CPS_OWNED]   = 0,
-			[CPS_PAGEIN]  = 0,
-			[CPS_PAGEOUT] = 0,
-			[CPS_FREEING] = 0,
+			[CPS_CACHED]	= 1, /* io completion */
+			[CPS_OWNED]	= 0,
+			[CPS_PAGEIN]	= 0,
+			[CPS_PAGEOUT]	= 0,
+			[CPS_FREEING]	= 0,
 		},
 		[CPS_FREEING] = {
-			[CPS_CACHED]  = 0,
-			[CPS_OWNED]   = 0,
-			[CPS_PAGEIN]  = 0,
-			[CPS_PAGEOUT] = 0,
-			[CPS_FREEING] = 0,
+			[CPS_CACHED]	= 0,
+			[CPS_OWNED]	= 0,
+			[CPS_PAGEIN]	= 0,
+			[CPS_PAGEOUT]	= 0,
+			[CPS_FREEING]	= 0,
 		}
 	};
 
@@ -976,9 +976,9 @@ void cl_page_slice_add(struct cl_page *page, struct cl_page_slice *slice,
 		       const struct cl_page_operations *ops)
 {
 	list_add_tail(&slice->cpl_linkage, &page->cp_layers);
-	slice->cpl_obj  = obj;
+	slice->cpl_obj = obj;
 	slice->cpl_index = index;
-	slice->cpl_ops  = ops;
+	slice->cpl_ops = ops;
 	slice->cpl_page = page;
 }
 EXPORT_SYMBOL(cl_page_slice_add);
@@ -988,7 +988,7 @@ void cl_page_slice_add(struct cl_page *page, struct cl_page_slice *slice,
  */
 struct cl_client_cache *cl_cache_init(unsigned long lru_page_max)
 {
-	struct cl_client_cache	*cache = NULL;
+	struct cl_client_cache *cache = NULL;
 
 	cache = kzalloc(sizeof(*cache), GFP_KERNEL);
 	if (!cache)
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index e130cf7..b859ab19 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -587,9 +587,9 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 
 /* modules setup */
 static struct miscdevice obd_psdev = {
-	.minor	= MISC_DYNAMIC_MINOR,
-	.name	= OBD_DEV_NAME,
-	.fops	= &obd_psdev_fops,
+	.minor		= MISC_DYNAMIC_MINOR,
+	.name		= OBD_DEV_NAME,
+	.fops		= &obd_psdev_fops,
 };
 
 static int obd_init_checks(void)
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 3d4d6e1..cee144c 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -622,9 +622,9 @@ struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid, int *next)
  */
 int class_notify_sptlrpc_conf(const char *fsname, int namelen)
 {
-	struct obd_device  *obd;
-	const char	 *type;
-	int		 i, rc = 0, rc2;
+	struct obd_device *obd;
+	const char *type;
+	int i, rc = 0, rc2;
 
 	LASSERT(namelen > 0);
 
@@ -693,7 +693,7 @@ int obd_init_caches(void)
 		goto out;
 
 	return 0;
- out:
+out:
 	obd_cleanup_caches();
 	return -ENOMEM;
 }
@@ -772,8 +772,8 @@ static void export_handle_addref(void *export)
 }
 
 static struct portals_handle_ops export_handle_ops = {
-	.hop_addref = export_handle_addref,
-	.hop_free   = NULL,
+	.hop_addref	= export_handle_addref,
+	.hop_free	= NULL,
 };
 
 struct obd_export *class_export_get(struct obd_export *exp)
@@ -967,8 +967,8 @@ static void import_handle_addref(void *import)
 }
 
 static struct portals_handle_ops import_handle_ops = {
-	.hop_addref = import_handle_addref,
-	.hop_free   = NULL,
+	.hop_addref	= import_handle_addref,
+	.hop_free	= NULL,
 };
 
 struct obd_import *class_import_get(struct obd_import *import)
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 5d81996..925ba52 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -89,10 +89,10 @@ int libcfs_kkuc_msg_put(struct file *filp, void *payload)
  */
 /** A single group registration has a uid and a file pointer */
 struct kkuc_reg {
-	struct list_head kr_chain;
-	int		 kr_uid;
-	struct file	*kr_fp;
-	char		 kr_data[0];
+	struct list_head	kr_chain;
+	int			kr_uid;
+	struct file	       *kr_fp;
+	char			kr_data[0];
 };
 
 static struct list_head kkuc_groups[KUC_GRP_MAX + 1];
diff --git a/drivers/staging/lustre/lustre/obdclass/linkea.c b/drivers/staging/lustre/lustre/obdclass/linkea.c
index 74c99ee..33594bd 100644
--- a/drivers/staging/lustre/lustre/obdclass/linkea.c
+++ b/drivers/staging/lustre/lustre/obdclass/linkea.c
@@ -95,8 +95,8 @@ int linkea_init_with_rec(struct linkea_data *ldata)
 int linkea_entry_pack(struct link_ea_entry *lee, const struct lu_name *lname,
 		      const struct lu_fid *pfid)
 {
-	struct lu_fid   tmpfid;
-	int             reclen;
+	struct lu_fid tmpfid;
+	int reclen;
 
 	tmpfid = *pfid;
 	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_LINKEA_CRASH))
@@ -216,7 +216,7 @@ int linkea_links_find(struct linkea_data *ldata, const struct lu_name *lname,
 		      const struct lu_fid  *pfid)
 {
 	struct lu_name tmpname;
-	struct lu_fid  tmpfid;
+	struct lu_fid tmpfid;
 	int count;
 
 	LASSERT(ldata->ld_leh);
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 8644d34..7aa459b 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -151,8 +151,8 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 {
 	int chunk_size = handle->lgh_ctxt->loc_chunk_size;
 	enum llog_flag fmt = flags & LLOG_F_EXT_MASK;
-	struct llog_log_hdr	*llh;
-	int			 rc;
+	struct llog_log_hdr *llh;
+	int rc;
 
 	LASSERT(!handle->lgh_hdr);
 
@@ -223,16 +223,16 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 
 static int llog_process_thread(void *arg)
 {
-	struct llog_process_info	*lpi = arg;
-	struct llog_handle		*loghandle = lpi->lpi_loghandle;
-	struct llog_log_hdr		*llh = loghandle->lgh_hdr;
-	struct llog_process_cat_data	*cd  = lpi->lpi_catdata;
-	char				*buf;
+	struct llog_process_info *lpi = arg;
+	struct llog_handle *loghandle = lpi->lpi_loghandle;
+	struct llog_log_hdr *llh = loghandle->lgh_hdr;
+	struct llog_process_cat_data *cd  = lpi->lpi_catdata;
+	char *buf;
 	u64 cur_offset, tmp_offset;
 	int chunk_size;
-	int				 rc = 0, index = 1, last_index;
-	int				 saved_index = 0;
-	int				 last_called_index = 0;
+	int rc = 0, index = 1, last_index;
+	int saved_index = 0;
+	int last_called_index = 0;
 
 	if (!llh)
 		return -EINVAL;
@@ -394,9 +394,9 @@ static int llog_process_thread(void *arg)
 
 static int llog_process_thread_daemonize(void *arg)
 {
-	struct llog_process_info	*lpi = arg;
-	struct lu_env			 env;
-	int				 rc;
+	struct llog_process_info *lpi = arg;
+	struct lu_env env;
+	int rc;
 
 	unshare_fs_struct();
 
@@ -419,15 +419,15 @@ int llog_process_or_fork(const struct lu_env *env,
 			 llog_cb_t cb, void *data, void *catdata, bool fork)
 {
 	struct llog_process_info *lpi;
-	int		      rc;
+	int rc;
 
 	lpi = kzalloc(sizeof(*lpi), GFP_KERNEL);
 	if (!lpi)
 		return -ENOMEM;
 	lpi->lpi_loghandle = loghandle;
-	lpi->lpi_cb	= cb;
-	lpi->lpi_cbdata    = data;
-	lpi->lpi_catdata   = catdata;
+	lpi->lpi_cb = cb;
+	lpi->lpi_cbdata = data;
+	lpi->lpi_catdata = catdata;
 
 	if (fork) {
 		struct task_struct *task;
@@ -469,7 +469,7 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 	      char *name, enum llog_open_param open_param)
 {
 	const struct cred *old_cred = NULL;
-	int	 rc;
+	int rc;
 
 	LASSERT(ctxt);
 	LASSERT(ctxt->loc_logops);
@@ -507,8 +507,8 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 
 int llog_close(const struct lu_env *env, struct llog_handle *loghandle)
 {
-	struct llog_operations	*lop;
-	int			 rc;
+	struct llog_operations *lop;
+	int rc;
 
 	rc = llog_handle2ops(loghandle, &lop);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index 172a368..b61c858 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -63,9 +63,9 @@ static int llog_cat_id2handle(const struct lu_env *env,
 			      struct llog_handle **res,
 			      struct llog_logid *logid)
 {
-	struct llog_handle	*loghandle;
+	struct llog_handle *loghandle;
 	enum llog_flag fmt;
-	int			 rc = 0;
+	int rc = 0;
 
 	if (!cathandle)
 		return -EBADF;
@@ -125,7 +125,7 @@ static int llog_cat_id2handle(const struct lu_env *env,
 
 int llog_cat_close(const struct lu_env *env, struct llog_handle *cathandle)
 {
-	struct llog_handle	*loghandle, *n;
+	struct llog_handle *loghandle, *n;
 
 	list_for_each_entry_safe(loghandle, n, &cathandle->u.chd.chd_head,
 				 u.phd.phd_entry) {
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_internal.h b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
index 4991d4e..545119e 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
@@ -37,23 +37,23 @@
 #include <lustre_log.h>
 
 struct llog_process_info {
-	struct llog_handle *lpi_loghandle;
-	llog_cb_t	   lpi_cb;
-	void	       *lpi_cbdata;
-	void	       *lpi_catdata;
-	int		 lpi_rc;
+	struct llog_handle     *lpi_loghandle;
+	llog_cb_t		lpi_cb;
+	void		       *lpi_cbdata;
+	void		       *lpi_catdata;
+	int			lpi_rc;
 	struct completion	lpi_completion;
-	const struct lu_env	*lpi_env;
+	const struct lu_env    *lpi_env;
 
 };
 
 struct llog_thread_info {
-	struct lu_attr			 lgi_attr;
-	struct lu_fid			 lgi_fid;
-	struct lu_buf			 lgi_buf;
-	loff_t				 lgi_off;
-	struct llog_rec_hdr		 lgi_lrh;
-	struct llog_rec_tail		 lgi_tail;
+	struct lu_attr		lgi_attr;
+	struct lu_fid		lgi_fid;
+	struct lu_buf		lgi_buf;
+	loff_t			lgi_off;
+	struct llog_rec_hdr	lgi_lrh;
+	struct llog_rec_tail	lgi_tail;
 };
 
 extern struct lu_context_key llog_thread_key;
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index fddc1ea..57dadec 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -358,14 +358,14 @@ void lustre_swab_lustre_cfg(struct lustre_cfg *lcfg)
 
 /* used only for compatibility with old on-disk cfg_marker data */
 struct cfg_marker32 {
-	u32   cm_step;
-	u32   cm_flags;
-	u32   cm_vers;
-	u32   padding;
-	u32   cm_createtime;
-	u32   cm_canceltime;
-	char    cm_tgtname[MTI_NAME_MAXLEN];
-	char    cm_comment[MTI_NAME_MAXLEN];
+	u32	cm_step;
+	u32	cm_flags;
+	u32	cm_vers;
+	u32	padding;
+	u32	cm_createtime;
+	u32	cm_canceltime;
+	char	cm_tgtname[MTI_NAME_MAXLEN];
+	char	cm_comment[MTI_NAME_MAXLEN];
 };
 
 #define MTI_NAMELEN32    (MTI_NAME_MAXLEN - \
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
index 77bc66f..c7bf1ee 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
@@ -45,10 +45,10 @@
 
 void lprocfs_counter_add(struct lprocfs_stats *stats, int idx, long amount)
 {
-	struct lprocfs_counter		*percpu_cntr;
-	struct lprocfs_counter_header	*header;
-	int				smp_id;
-	unsigned long			flags = 0;
+	struct lprocfs_counter *percpu_cntr;
+	struct lprocfs_counter_header *header;
+	int smp_id;
+	unsigned long flags = 0;
 
 	if (!stats)
 		return;
@@ -94,10 +94,10 @@ void lprocfs_counter_add(struct lprocfs_stats *stats, int idx, long amount)
 
 void lprocfs_counter_sub(struct lprocfs_stats *stats, int idx, long amount)
 {
-	struct lprocfs_counter		*percpu_cntr;
-	struct lprocfs_counter_header	*header;
-	int				smp_id;
-	unsigned long			flags = 0;
+	struct lprocfs_counter *percpu_cntr;
+	struct lprocfs_counter_header *header;
+	int smp_id;
+	unsigned long flags = 0;
 
 	if (!stats)
 		return;
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index cc70402..e1ac610 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -364,7 +364,7 @@ static ssize_t blocksize_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct obd_statfs  osfs;
+	struct obd_statfs osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 			    OBD_STATFS_NODELAY);
@@ -380,7 +380,7 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct obd_statfs  osfs;
+	struct obd_statfs osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 			    OBD_STATFS_NODELAY);
@@ -403,7 +403,7 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct obd_statfs  osfs;
+	struct obd_statfs osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 			    OBD_STATFS_NODELAY);
@@ -426,7 +426,7 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct obd_statfs  osfs;
+	struct obd_statfs osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 			    OBD_STATFS_NODELAY);
@@ -449,7 +449,7 @@ static ssize_t filestotal_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct obd_statfs  osfs;
+	struct obd_statfs osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 			    OBD_STATFS_NODELAY);
@@ -465,7 +465,7 @@ static ssize_t filesfree_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct obd_statfs  osfs;
+	struct obd_statfs osfs;
 	int rc = obd_statfs(NULL, obd->obd_self_export, &osfs,
 			    get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
 			    OBD_STATFS_NODELAY);
@@ -638,10 +638,10 @@ void lprocfs_stats_unlock(struct lprocfs_stats *stats,
 void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 			   struct lprocfs_counter *cnt)
 {
-	unsigned int			num_entry;
-	struct lprocfs_counter		*percpu_cntr;
-	int				i;
-	unsigned long			flags = 0;
+	unsigned int num_entry;
+	struct lprocfs_counter *percpu_cntr;
+	int i;
+	unsigned long flags = 0;
 
 	memset(cnt, 0, sizeof(*cnt));
 
@@ -740,17 +740,17 @@ static void obd_connect_seq_flags2str(struct seq_file *m, u64 flags,
 
 int lprocfs_rd_import(struct seq_file *m, void *data)
 {
-	char				nidstr[LNET_NIDSTR_SIZE];
-	struct lprocfs_counter		ret;
-	struct lprocfs_counter_header	*header;
-	struct obd_device		*obd	= data;
-	struct obd_import		*imp;
-	struct obd_import_conn		*conn;
+	char nidstr[LNET_NIDSTR_SIZE];
+	struct lprocfs_counter ret;
+	struct lprocfs_counter_header *header;
+	struct obd_device *obd = data;
+	struct obd_import *imp;
+	struct obd_import_conn *conn;
 	struct obd_connect_data *ocd;
-	int				j;
-	int				k;
-	int				rw	= 0;
-	int				rc;
+	int j;
+	int k;
+	int rw = 0;
+	int rc;
 
 	LASSERT(obd);
 	rc = lprocfs_climp_check(obd);
@@ -1101,11 +1101,11 @@ int lprocfs_obd_cleanup(struct obd_device *obd)
 
 int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid)
 {
-	struct lprocfs_counter  *cntr;
-	unsigned int            percpusize;
-	int                     rc = -ENOMEM;
-	unsigned long           flags = 0;
-	int                     i;
+	struct lprocfs_counter *cntr;
+	unsigned int percpusize;
+	int rc = -ENOMEM;
+	unsigned long flags = 0;
+	int i;
 
 	LASSERT(!stats->ls_percpu[cpuid]);
 	LASSERT((stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) == 0);
@@ -1138,10 +1138,10 @@ int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid)
 struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 					  enum lprocfs_stats_flags flags)
 {
-	struct lprocfs_stats	*stats;
-	unsigned int		num_entry;
-	unsigned int		percpusize = 0;
-	int			i;
+	struct lprocfs_stats *stats;
+	unsigned int num_entry;
+	unsigned int percpusize = 0;
+	int i;
 
 	if (num == 0)
 		return NULL;
@@ -1221,9 +1221,9 @@ u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
 			      enum lprocfs_fields_flags field)
 {
 	unsigned int i;
-	unsigned int  num_cpu;
-	unsigned long flags     = 0;
-	u64         ret       = 0;
+	unsigned int num_cpu;
+	unsigned long flags = 0;
+	u64 ret = 0;
 
 	LASSERT(stats);
 
@@ -1243,11 +1243,11 @@ u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
 
 void lprocfs_clear_stats(struct lprocfs_stats *stats)
 {
-	struct lprocfs_counter		*percpu_cntr;
-	int				i;
-	int				j;
-	unsigned int			num_entry;
-	unsigned long			flags = 0;
+	struct lprocfs_counter *percpu_cntr;
+	int i;
+	int j;
+	unsigned int num_entry;
+	unsigned long flags = 0;
 
 	num_entry = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
 
@@ -1256,11 +1256,11 @@ void lprocfs_clear_stats(struct lprocfs_stats *stats)
 			continue;
 		for (j = 0; j < stats->ls_num; j++) {
 			percpu_cntr = lprocfs_stats_counter_get(stats, i, j);
-			percpu_cntr->lc_count		= 0;
-			percpu_cntr->lc_min		= LC_MIN_INIT;
-			percpu_cntr->lc_max		= 0;
-			percpu_cntr->lc_sumsquare	= 0;
-			percpu_cntr->lc_sum		= 0;
+			percpu_cntr->lc_count = 0;
+			percpu_cntr->lc_min = LC_MIN_INIT;
+			percpu_cntr->lc_max = 0;
+			percpu_cntr->lc_sumsquare = 0;
+			percpu_cntr->lc_sum = 0;
 			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
 				percpu_cntr->lc_sum_irq	= 0;
 		}
@@ -1302,10 +1302,10 @@ static void *lprocfs_stats_seq_next(struct seq_file *p, void *v, loff_t *pos)
 /* seq file export of one lprocfs counter */
 static int lprocfs_stats_seq_show(struct seq_file *p, void *v)
 {
-	struct lprocfs_stats		*stats	= p->private;
-	struct lprocfs_counter_header   *hdr;
-	struct lprocfs_counter           ctr;
-	int                              idx    = *(loff_t *)v;
+	struct lprocfs_stats *stats = p->private;
+	struct lprocfs_counter_header *hdr;
+	struct lprocfs_counter ctr;
+	int idx = *(loff_t *)v;
 
 	if (idx == 0) {
 		struct timespec64 now;
@@ -1337,10 +1337,10 @@ static int lprocfs_stats_seq_show(struct seq_file *p, void *v)
 }
 
 static const struct seq_operations lprocfs_stats_seq_sops = {
-	.start	= lprocfs_stats_seq_start,
-	.stop	= lprocfs_stats_seq_stop,
-	.next	= lprocfs_stats_seq_next,
-	.show	= lprocfs_stats_seq_show,
+	.start		= lprocfs_stats_seq_start,
+	.stop		= lprocfs_stats_seq_stop,
+	.next		= lprocfs_stats_seq_next,
+	.show		= lprocfs_stats_seq_show,
 };
 
 static int lprocfs_stats_seq_open(struct inode *inode, struct file *file)
@@ -1359,12 +1359,12 @@ static int lprocfs_stats_seq_open(struct inode *inode, struct file *file)
 }
 
 const struct file_operations lprocfs_stats_seq_fops = {
-	.owner   = THIS_MODULE,
-	.open    = lprocfs_stats_seq_open,
-	.read    = seq_read,
-	.write   = lprocfs_stats_seq_write,
-	.llseek  = seq_lseek,
-	.release = lprocfs_seq_release,
+	.owner		= THIS_MODULE,
+	.open		= lprocfs_stats_seq_open,
+	.read		= seq_read,
+	.write		= lprocfs_stats_seq_write,
+	.llseek		= seq_lseek,
+	.release	= lprocfs_seq_release,
 };
 EXPORT_SYMBOL_GPL(lprocfs_stats_seq_fops);
 
@@ -1372,30 +1372,30 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 			  unsigned int conf, const char *name,
 			  const char *units)
 {
-	struct lprocfs_counter_header	*header;
-	struct lprocfs_counter		*percpu_cntr;
-	unsigned long			flags = 0;
-	unsigned int			i;
-	unsigned int			num_cpu;
+	struct lprocfs_counter_header *header;
+	struct lprocfs_counter *percpu_cntr;
+	unsigned long flags = 0;
+	unsigned int i;
+	unsigned int num_cpu;
 
 	header = &stats->ls_cnt_header[index];
 	LASSERTF(header, "Failed to allocate stats header:[%d]%s/%s\n",
 		 index, name, units);
 
 	header->lc_config = conf;
-	header->lc_name   = name;
-	header->lc_units  = units;
+	header->lc_name = name;
+	header->lc_units = units;
 
 	num_cpu = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
 	for (i = 0; i < num_cpu; ++i) {
 		if (!stats->ls_percpu[i])
 			continue;
 		percpu_cntr = lprocfs_stats_counter_get(stats, i, index);
-		percpu_cntr->lc_count		= 0;
-		percpu_cntr->lc_min		= LC_MIN_INIT;
-		percpu_cntr->lc_max		= 0;
-		percpu_cntr->lc_sumsquare	= 0;
-		percpu_cntr->lc_sum		= 0;
+		percpu_cntr->lc_count = 0;
+		percpu_cntr->lc_min = LC_MIN_INIT;
+		percpu_cntr->lc_max = 0;
+		percpu_cntr->lc_sumsquare = 0;
+		percpu_cntr->lc_sum = 0;
 		if ((stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE) != 0)
 			percpu_cntr->lc_sum_irq	= 0;
 	}
@@ -1843,8 +1843,8 @@ ssize_t lustre_attr_store(struct kobject *kobj, struct attribute *attr,
 EXPORT_SYMBOL_GPL(lustre_attr_store);
 
 const struct sysfs_ops lustre_sysfs_ops = {
-	.show  = lustre_attr_show,
-	.store = lustre_attr_store,
+	.show		= lustre_attr_show,
+	.store		= lustre_attr_store,
 };
 EXPORT_SYMBOL_GPL(lustre_sysfs_ops);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index a132d87..3bd4874 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -87,15 +87,15 @@ enum {
 #define LU_CACHE_NR_LDISKFS_LIMIT	LU_CACHE_NR_UNLIMITED
 #define LU_CACHE_NR_ZFS_LIMIT		256
 
-#define LU_SITE_BITS_MIN	12
-#define LU_SITE_BITS_MAX	24
-#define LU_SITE_BITS_MAX_CL	19
+#define LU_SITE_BITS_MIN		12
+#define LU_SITE_BITS_MAX		24
+#define LU_SITE_BITS_MAX_CL		19
 /**
  * total 256 buckets, we don't want too many buckets because:
  * - consume too much memory
  * - avoid unbalanced LRU list
  */
-#define LU_SITE_BKT_BITS	8
+#define LU_SITE_BKT_BITS		8
 
 static unsigned int lu_cache_percent = LU_CACHE_PERCENT_DEFAULT;
 module_param(lu_cache_percent, int, 0644);
@@ -129,10 +129,10 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 {
 	struct lu_site_bkt_data *bkt;
 	struct lu_object_header *top;
-	struct lu_site	  *site;
-	struct lu_object	*orig;
-	struct cfs_hash_bd	    bd;
-	const struct lu_fid     *fid;
+	struct lu_site *site;
+	struct lu_object *orig;
+	struct cfs_hash_bd bd;
+	const struct lu_fid *fid;
 
 	top  = o->lo_header;
 	site = o->lo_dev->ld_site;
@@ -319,14 +319,14 @@ static struct lu_object *lu_object_alloc(const struct lu_env *env,
 static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 {
 	wait_queue_head_t *wq;
-	struct lu_site	  *site;
-	struct lu_object	*scan;
-	struct list_head	      *layers;
-	struct list_head	       splice;
+	struct lu_site *site;
+	struct lu_object *scan;
+	struct list_head *layers;
+	struct list_head splice;
 
-	site   = o->lo_dev->ld_site;
+	site = o->lo_dev->ld_site;
 	layers = &o->lo_header->loh_layers;
-	wq     = lu_site_wq_from_fid(site, &o->lo_header->loh_fid);
+	wq = lu_site_wq_from_fid(site, &o->lo_header->loh_fid);
 	/*
 	 * First call ->loo_object_delete() method to release all resources.
 	 */
@@ -369,13 +369,13 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 	struct lu_object_header *h;
 	struct lu_object_header *temp;
 	struct lu_site_bkt_data *bkt;
-	struct cfs_hash_bd	    bd;
-	struct cfs_hash_bd	    bd2;
-	struct list_head	       dispose;
-	int		      did_sth;
+	struct cfs_hash_bd bd;
+	struct cfs_hash_bd bd2;
+	struct list_head dispose;
+	int did_sth;
 	unsigned int start = 0;
-	int		      count;
-	int		      bnr;
+	int count;
+	int bnr;
 	unsigned int i;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_OBD_NO_LRU))
@@ -389,7 +389,7 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 	if (nr != ~0)
 		start = s->ls_purge_start;
 	bnr = (nr == ~0) ? -1 : nr / (int)CFS_HASH_NBKT(s->ls_obj_hash) + 1;
- again:
+again:
 	/*
 	 * It doesn't make any sense to make purge threads parallel, that can
 	 * only bring troubles to us. See LU-5331.
@@ -496,10 +496,10 @@ struct lu_cdebug_data {
  * lu_global_init().
  */
 static struct lu_context_key lu_global_key = {
-	.lct_tags = LCT_MD_THREAD | LCT_DT_THREAD |
-		    LCT_MG_THREAD | LCT_CL_THREAD | LCT_LOCAL,
-	.lct_init = lu_global_key_init,
-	.lct_fini = lu_global_key_fini
+	.lct_tags	= LCT_MD_THREAD | LCT_DT_THREAD |
+			  LCT_MG_THREAD | LCT_CL_THREAD | LCT_LOCAL,
+	.lct_init	= lu_global_key_init,
+	.lct_fini	= lu_global_key_fini
 };
 
 /**
@@ -509,7 +509,7 @@ int lu_cdebug_printer(const struct lu_env *env,
 		      void *cookie, const char *format, ...)
 {
 	struct libcfs_debug_msg_data *msgdata = cookie;
-	struct lu_cdebug_data	*key;
+	struct lu_cdebug_data *key;
 	int used;
 	int complete;
 	va_list args;
@@ -594,7 +594,7 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 {
 	struct lu_site_bkt_data *bkt;
 	struct lu_object_header *h;
-	struct hlist_node	*hnode;
+	struct hlist_node *hnode;
 	u64 ver = cfs_hash_bd_version_get(bd);
 
 	if (*version == ver)
@@ -670,12 +670,12 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 				    const struct lu_fid *f,
 				    const struct lu_object_conf *conf)
 {
-	struct lu_object      *o;
-	struct lu_object      *shadow;
-	struct lu_site	*s;
-	struct cfs_hash	    *hs;
-	struct cfs_hash_bd	  bd;
-	u64		  version = 0;
+	struct lu_object *o;
+	struct lu_object *shadow;
+	struct lu_site *s;
+	struct cfs_hash	*hs;
+	struct cfs_hash_bd bd;
+	u64 version = 0;
 
 	/*
 	 * This uses standard index maintenance protocol:
@@ -795,9 +795,9 @@ void lu_device_type_fini(struct lu_device_type *ldt)
 static struct lu_env lu_shrink_env;
 
 struct lu_site_print_arg {
-	struct lu_env   *lsp_env;
-	void	    *lsp_cookie;
-	lu_printer_t     lsp_printer;
+	struct lu_env		*lsp_env;
+	void			*lsp_cookie;
+	lu_printer_t		 lsp_printer;
 };
 
 static int
@@ -805,7 +805,7 @@ struct lu_site_print_arg {
 		  struct hlist_node *hnode, void *data)
 {
 	struct lu_site_print_arg *arg = (struct lu_site_print_arg *)data;
-	struct lu_object_header  *h;
+	struct lu_object_header *h;
 
 	h = hlist_entry(hnode, struct lu_object_header, loh_hash);
 	if (!list_empty(&h->loh_layers)) {
@@ -828,9 +828,9 @@ void lu_site_print(const struct lu_env *env, struct lu_site *s, void *cookie,
 		   lu_printer_t printer)
 {
 	struct lu_site_print_arg arg = {
-		.lsp_env     = (struct lu_env *)env,
-		.lsp_cookie  = cookie,
-		.lsp_printer = printer,
+		.lsp_env	= (struct lu_env *)env,
+		.lsp_cookie	= cookie,
+		.lsp_printer	= printer,
 	};
 
 	cfs_hash_for_each(s->ls_obj_hash, lu_site_obj_print, &arg);
@@ -883,8 +883,8 @@ static unsigned long lu_htable_order(struct lu_device *top)
 static unsigned int lu_obj_hop_hash(struct cfs_hash *hs,
 				    const void *key, unsigned int mask)
 {
-	struct lu_fid  *fid = (struct lu_fid *)key;
-	u32	   hash;
+	struct lu_fid *fid = (struct lu_fid *)key;
+	u32 hash;
 
 	hash = fid_flatten32(fid);
 	hash += (hash >> 4) + (hash << 12); /* mixing oid and seq */
@@ -1247,7 +1247,7 @@ struct lu_object *lu_object_locate(struct lu_object_header *h,
  */
 void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
 {
-	struct lu_site   *site = top->ld_site;
+	struct lu_site *site = top->ld_site;
 	struct lu_device *scan;
 	struct lu_device *next;
 
@@ -1263,7 +1263,7 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
 
 	for (scan = top; scan; scan = next) {
 		const struct lu_device_type *ldt = scan->ld_type;
-		struct obd_type	     *type;
+		struct obd_type *type;
 
 		next = ldt->ldt_ops->ldto_device_free(env, scan);
 		type = ldt->ldt_obd_type;
@@ -1595,7 +1595,7 @@ static int keys_init(struct lu_context *ctx)
  */
 int lu_context_init(struct lu_context *ctx, u32 tags)
 {
-	int	rc;
+	int rc;
 
 	memset(ctx, 0, sizeof(*ctx));
 	ctx->lc_state = LCS_INITIALIZED;
@@ -1761,7 +1761,7 @@ static void lu_site_stats_get(const struct lu_site *s,
 	stats->lss_busy += cfs_hash_size_get(hs) -
 		percpu_counter_sum_positive(&s2->ls_lru_len_counter);
 	cfs_hash_for_each_bucket(hs, &bd, i) {
-		struct hlist_head	*hhead;
+		struct hlist_head *hhead;
 
 		cfs_hash_bd_lock(hs, &bd, 1);
 		stats->lss_total += cfs_hash_bd_count_get(&bd);
@@ -1860,9 +1860,9 @@ static unsigned long lu_cache_shrink_scan(struct shrinker *sk,
  * Debugging printer function using printk().
  */
 static struct shrinker lu_site_shrinker = {
-	.count_objects	= lu_cache_shrink_count,
-	.scan_objects	= lu_cache_shrink_scan,
-	.seeks 		= DEFAULT_SEEKS,
+	.count_objects		= lu_cache_shrink_count,
+	.scan_objects		= lu_cache_shrink_scan,
+	.seeks			= DEFAULT_SEEKS,
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index b296877..0674afb 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -47,7 +47,7 @@
 static spinlock_t handle_base_lock;
 
 static struct handle_bucket {
-	spinlock_t	lock;
+	spinlock_t		lock;
 	struct list_head	head;
 } *handle_hash;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index 8e7f3a8..0c3e0ca 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -44,10 +44,10 @@
 #define NIDS_MAX	32
 
 struct uuid_nid_data {
-	struct list_head       un_list;
-	struct obd_uuid  un_uuid;
-	int	      un_nid_count;
-	lnet_nid_t       un_nids[NIDS_MAX];
+	struct list_head	un_list;
+	struct obd_uuid		un_uuid;
+	int			un_nid_count;
+	lnet_nid_t		un_nids[NIDS_MAX];
 };
 
 /* FIXME: This should probably become more elegant than a global linked list */
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 887afda..0cdadea4 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -189,8 +189,8 @@ static int class_parse_value(char *buf, int opc, void *value, char **endh,
 			     int quiet)
 {
 	char *endp;
-	char  tmp;
-	int   rc = 0;
+	char tmp;
+	int rc = 0;
 
 	if (!buf)
 		return 1;
@@ -249,7 +249,7 @@ char *lustre_cfg_string(struct lustre_cfg *lcfg, u32 index)
 
 	/*
 	 * make sure it's NULL terminated, even if this kills a char
-	 * of data.  Try to use the padding first though.
+	 * of data. Try to use the padding first though.
 	 */
 	if (s[lcfg->lcfg_buflens[index] - 1] != '\0') {
 		size_t last = ALIGN(lcfg->lcfg_buflens[index], 8) - 1;
@@ -388,7 +388,6 @@ static int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	/* create an uuid-export lustre hash */
 	err = rhashtable_init(&obd->obd_uuid_hash, &uuid_hash_params);
-
 	if (err)
 		goto err_hash;
 
@@ -1407,7 +1406,7 @@ int class_config_llog_handler(const struct lu_env *env,
 		}
 
 		lustre_cfg_init(lcfg_new, lcfg->lcfg_command, &bufs);
-		lcfg_new->lcfg_num   = lcfg->lcfg_num;
+		lcfg_new->lcfg_num = lcfg->lcfg_num;
 		lcfg_new->lcfg_flags = lcfg->lcfg_flags;
 
 		/* XXX Hack to try to remain binary compatible with
@@ -1454,9 +1453,9 @@ int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
 	struct llog_process_cat_data cd = {
 		.lpcd_first_idx = 0,
 	};
-	struct llog_handle		*llh;
-	llog_cb_t			 callback;
-	int				 rc;
+	struct llog_handle *llh;
+	llog_cb_t callback;
+	int rc;
 
 	CDEBUG(D_INFO, "looking up llog %s\n", name);
 	rc = llog_open(env, ctxt, &llh, NULL, name, LLOG_OPEN_EXISTS);
@@ -1499,10 +1498,10 @@ int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
 static int class_config_parse_rec(struct llog_rec_hdr *rec, char *buf,
 				  int size)
 {
-	struct lustre_cfg	*lcfg = (struct lustre_cfg *)(rec + 1);
-	char			*ptr = buf;
-	char			*end = buf + size;
-	int			 rc = 0;
+	struct lustre_cfg *lcfg = (struct lustre_cfg *)(rec + 1);
+	char *ptr = buf;
+	char *end = buf + size;
+	int rc = 0;
 
 	LASSERT(rec->lrh_type == OBD_CFG_REC);
 	rc = lustre_cfg_sanity_check(lcfg, rec->lrh_len);
@@ -1549,8 +1548,8 @@ int class_config_dump_handler(const struct lu_env *env,
 			      struct llog_handle *handle,
 			      struct llog_rec_hdr *rec, void *data)
 {
-	char	*outstr;
-	int	 rc = 0;
+	char *outstr;
+	int rc = 0;
 
 	outstr = kzalloc(256, GFP_NOFS);
 	if (!outstr)
@@ -1573,10 +1572,10 @@ int class_config_dump_handler(const struct lu_env *env,
  */
 int class_manual_cleanup(struct obd_device *obd)
 {
-	char		    flags[3] = "";
-	struct lustre_cfg      *lcfg;
-	struct lustre_cfg_bufs  bufs;
-	int		     rc;
+	char flags[3] = "";
+	struct lustre_cfg *lcfg;
+	struct lustre_cfg_bufs bufs;
+	int rc;
 
 	if (!obd) {
 		CERROR("empty cleanup\n");
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index eab3216..33aa790 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -150,7 +150,7 @@ static int do_lcfg(char *cfgname, lnet_nid_t nid, int cmd,
 		   char *s1, char *s2, char *s3, char *s4)
 {
 	struct lustre_cfg_bufs bufs;
-	struct lustre_cfg     *lcfg = NULL;
+	struct lustre_cfg *lcfg = NULL;
 	int rc;
 
 	CDEBUG(D_TRACE, "lcfg %s %#x %s %s %s %s\n", cfgname,
@@ -801,8 +801,8 @@ static int lmd_make_exclusion(struct lustre_mount_data *lmd, const char *ptr)
 
 static int lmd_parse_mgssec(struct lustre_mount_data *lmd, char *ptr)
 {
-	char   *tail;
-	int     length;
+	char *tail;
+	int length;
 
 	kfree(lmd->lmd_mgssec);
 	lmd->lmd_mgssec = NULL;
@@ -845,8 +845,8 @@ static int lmd_parse_network(struct lustre_mount_data *lmd, char *ptr)
 
 static int lmd_parse_string(char **handle, char *ptr)
 {
-	char   *tail;
-	int     length;
+	char *tail;
+	int length;
 
 	if (!handle || !ptr)
 		return -EINVAL;
@@ -876,8 +876,8 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
 	lnet_nid_t nid;
 	char *tail = *ptr;
 	char *mgsnid;
-	int   length;
-	int   oldlen = 0;
+	int length;
+	int oldlen = 0;
 
 	/* Find end of nidlist */
 	while (class_parse_nid_quiet(tail, &nid, &tail) == 0)
@@ -1252,4 +1252,3 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 	return -EINVAL;
 }
 EXPORT_SYMBOL(lmd_parse);
-
-- 
1.8.3.1
