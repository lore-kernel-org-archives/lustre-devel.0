From: Chris Hanna <hannac@iu.edu>
Date: Fri, 22 May 2015 14:50:47 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: osc: clean up whitespace
	and align function parameters
Message-ID: <1432320647-14543-1-git-send-email-hannac@iu.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Minor changes to remove excessive whitespace and improve
readability of functions.

Signed-off-by: Chris Hanna <hannac@iu.edu>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c   |   56 +++---
 drivers/staging/lustre/lustre/osc/osc_cache.c   |  112 ++++++------
 drivers/staging/lustre/lustre/osc/osc_io.c      |  116 +++++++-------
 drivers/staging/lustre/lustre/osc/osc_lock.c    |  134 ++++++++--------
 drivers/staging/lustre/lustre/osc/osc_object.c  |   18 +-
 drivers/staging/lustre/lustre/osc/osc_page.c    |   44 +++---
 drivers/staging/lustre/lustre/osc/osc_quota.c   |   14 +-
 drivers/staging/lustre/lustre/osc/osc_request.c |  205 +++++++++++------------
 8 files changed, 349 insertions(+), 350 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 15a6620..ee4eade 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -54,8 +54,8 @@ static int osc_active_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_active_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+				    const char __user *buffer,
+				    size_t count, loff_t *off)
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	int val, rc;
@@ -89,8 +89,8 @@ static int osc_max_rpcs_in_flight_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_max_rpcs_in_flight_seq_write(struct file *file,
-			const char __user *buffer,
-			size_t count, loff_t *off)
+						const char __user *buffer,
+						size_t count, loff_t *off)
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	struct client_obd *cli = &dev->u.cli;
@@ -133,8 +133,8 @@ static int osc_max_dirty_mb_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_max_dirty_mb_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+					  const char __user *buffer,
+					  size_t count, loff_t *off)
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	struct client_obd *cli = &dev->u.cli;
@@ -236,13 +236,13 @@ static int osc_cur_grant_bytes_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_cur_grant_bytes_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+					     const char __user *buffer,
+					     size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	struct client_obd *cli = &obd->u.cli;
-	int		rc;
-	__u64	      val;
+	int rc;
+	__u64 val;
 
 	if (obd == NULL)
 		return 0;
@@ -293,8 +293,8 @@ static int osc_grant_shrink_interval_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_grant_shrink_interval_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+						   const char __user *buffer,
+						   size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	int val, rc;
@@ -327,8 +327,8 @@ static int osc_checksum_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_checksum_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+				      const char __user *buffer,
+				      size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	int val, rc;
@@ -368,8 +368,8 @@ static int osc_checksum_type_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_checksum_type_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+					   const char __user *buffer,
+					   size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	int i;
@@ -409,8 +409,8 @@ static int osc_resend_count_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_resend_count_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+					  const char __user *buffer,
+					  size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	int val, rc;
@@ -438,8 +438,8 @@ static int osc_contention_seconds_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_contention_seconds_seq_write(struct file *file,
-					const char __user *buffer,
-					size_t count, loff_t *off)
+						const char __user *buffer,
+						size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	struct osc_device *od  = obd2osc_dev(obd);
@@ -459,8 +459,8 @@ static int osc_lockless_truncate_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_lockless_truncate_seq_write(struct file *file,
-					const char __user *buffer,
-					size_t count, loff_t *off)
+					       const char __user *buffer,
+					       size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	struct osc_device *od  = obd2osc_dev(obd);
@@ -485,8 +485,8 @@ static int osc_obd_max_pages_per_rpc_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t osc_obd_max_pages_per_rpc_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+						   const char __user *buffer,
+						   size_t count, loff_t *off)
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	struct client_obd *cli = &dev->u.cli;
@@ -679,8 +679,8 @@ static int osc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 #undef pct
 
 static ssize_t osc_rpc_stats_seq_write(struct file *file,
-				const char __user *buf,
-				size_t len, loff_t *off)
+				       const char __user *buf,
+				       size_t len, loff_t *off)
 {
 	struct seq_file *seq = file->private_data;
 	struct obd_device *dev = seq->private;
@@ -718,8 +718,8 @@ static int osc_stats_seq_show(struct seq_file *seq, void *v)
 }
 
 static ssize_t osc_stats_seq_write(struct file *file,
-				const char __user *buf,
-				size_t len, loff_t *off)
+				   const char __user *buf,
+				   size_t len, loff_t *off)
 {
 	struct seq_file *seq = file->private_data;
 	struct obd_device *dev = seq->private;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d44b3d4..54a6409 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -112,8 +112,8 @@ static const char *oes_strings[] = {
 		/* ----- extent part 0 ----- */				      \
 		__ext, EXTPARA(__ext),					      \
 		/* ----- part 1 ----- */				      \
-		atomic_read(&__ext->oe_refc),			      \
-		atomic_read(&__ext->oe_users),			      \
+		atomic_read(&__ext->oe_refc),				      \
+		atomic_read(&__ext->oe_users),				      \
 		list_empty_marker(&__ext->oe_link),			      \
 		oes_strings[__ext->oe_state], ext_flags(__ext, __buf),	      \
 		__ext->oe_obj,						      \
@@ -297,12 +297,12 @@ out:
 #define sanity_check_nolock(ext) \
 	osc_extent_sanity_check0(ext, __func__, __LINE__)
 
-#define sanity_check(ext) ({						   \
-	int __res;							     \
+#define sanity_check(ext) ({						\
+	int __res;							\
 	osc_object_lock((ext)->oe_obj);					\
-	__res = sanity_check_nolock(ext);				      \
-	osc_object_unlock((ext)->oe_obj);				      \
-	__res;								 \
+	__res = sanity_check_nolock(ext);				\
+	osc_object_unlock((ext)->oe_obj);				\
+	__res;								\
 })
 
 
@@ -624,18 +624,18 @@ struct osc_extent *osc_extent_find(const struct lu_env *env,
 
 {
 	struct client_obd *cli = osc_cli(obj);
-	struct cl_lock    *lock;
+	struct cl_lock *lock;
 	struct osc_extent *cur;
 	struct osc_extent *ext;
 	struct osc_extent *conflict = NULL;
 	struct osc_extent *found = NULL;
-	pgoff_t    chunk;
-	pgoff_t    max_end;
-	int	max_pages; /* max_pages_per_rpc */
-	int	chunksize;
-	int	ppc_bits; /* pages per chunk bits */
-	int	chunk_mask;
-	int	rc;
+	pgoff_t chunk;
+	pgoff_t max_end;
+	int max_pages; /* max_pages_per_rpc */
+	int chunksize;
+	int ppc_bits; /* pages per chunk bits */
+	int chunk_mask;
+	int rc;
 
 	cur = osc_extent_alloc(obj);
 	if (cur == NULL)
@@ -943,21 +943,21 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
  * @size, then partial truncate happens.
  */
 static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
-				bool partial)
+			       bool partial)
 {
-	struct cl_env_nest     nest;
-	struct lu_env	 *env;
-	struct cl_io	  *io;
-	struct osc_object     *obj = ext->oe_obj;
-	struct client_obd     *cli = osc_cli(obj);
+	struct cl_env_nest nest;
+	struct lu_env *env;
+	struct cl_io *io;
+	struct osc_object *obj = ext->oe_obj;
+	struct client_obd *cli = osc_cli(obj);
 	struct osc_async_page *oap;
 	struct osc_async_page *tmp;
-	int		    pages_in_chunk = 0;
-	int		    ppc_bits    = cli->cl_chunkbits - PAGE_CACHE_SHIFT;
-	__u64		  trunc_chunk = trunc_index >> ppc_bits;
-	int		    grants   = 0;
-	int		    nr_pages = 0;
-	int		    rc       = 0;
+	int pages_in_chunk = 0;
+	int ppc_bits    = cli->cl_chunkbits - PAGE_CACHE_SHIFT;
+	__u64 trunc_chunk = trunc_index >> ppc_bits;
+	int grants   = 0;
+	int nr_pages = 0;
+	int rc       = 0;
 
 	LASSERT(sanity_check(ext) == 0);
 	EASSERT(ext->oe_state == OES_TRUNC, ext);
@@ -1022,7 +1022,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 		grants = ext->oe_grants;
 		ext->oe_grants = 0;
 	} else { /* calculate how many grants we can free */
-		int     chunks = (ext->oe_end >> ppc_bits) - trunc_chunk;
+		int chunks = (ext->oe_end >> ppc_bits) - trunc_chunk;
 		pgoff_t last_index;
 
 
@@ -2049,7 +2049,7 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 
 #define list_to_obj(list, item) ({					      \
 	struct list_head *__tmp = (list)->next;				      \
-	list_del_init(__tmp);					      \
+	list_del_init(__tmp);						      \
 	list_entry(__tmp, struct osc_object, oo_##item);		      \
 })
 
@@ -2224,16 +2224,16 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		       struct osc_page *ops)
 {
 	struct osc_io *oio = osc_env_io(env);
-	struct osc_extent     *ext = NULL;
+	struct osc_extent *ext = NULL;
 	struct osc_async_page *oap = &ops->ops_oap;
-	struct client_obd     *cli = oap->oap_cli;
-	struct osc_object     *osc = oap->oap_obj;
+	struct client_obd *cli = oap->oap_cli;
+	struct osc_object *osc = oap->oap_obj;
 	pgoff_t index;
-	int    grants = 0;
-	int    brw_flags = OBD_BRW_ASYNC;
-	int    cmd = OBD_BRW_WRITE;
-	int    need_release = 0;
-	int    rc = 0;
+	int grants = 0;
+	int brw_flags = OBD_BRW_ASYNC;
+	int cmd = OBD_BRW_WRITE;
+	int need_release = 0;
+	int rc = 0;
 
 	if (oap->oap_magic != OAP_MAGIC)
 		return -EINVAL;
@@ -2386,7 +2386,7 @@ int osc_teardown_async_page(const struct lu_env *env,
 			    struct osc_object *obj, struct osc_page *ops)
 {
 	struct osc_async_page *oap = &ops->ops_oap;
-	struct osc_extent     *ext = NULL;
+	struct osc_extent *ext = NULL;
 	int rc = 0;
 
 	LASSERT(oap->oap_magic == OAP_MAGIC);
@@ -2425,10 +2425,10 @@ int osc_teardown_async_page(const struct lu_env *env,
 int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 			 struct osc_page *ops)
 {
-	struct osc_extent *ext   = NULL;
-	struct osc_object *obj   = cl2osc(ops->ops_cl.cpl_obj);
-	struct cl_page    *cp    = ops->ops_cl.cpl_page;
-	pgoff_t	    index = cp->cp_index;
+	struct osc_extent *ext = NULL;
+	struct osc_object *obj = cl2osc(ops->ops_cl.cpl_obj);
+	struct cl_page *cp = ops->ops_cl.cpl_page;
+	pgoff_t	index = cp->cp_index;
 	struct osc_async_page *oap = &ops->ops_oap;
 	bool unplug = false;
 	int rc = 0;
@@ -2507,14 +2507,14 @@ out:
 int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops)
 {
 	struct osc_async_page *oap = &ops->ops_oap;
-	struct osc_object     *obj = oap->oap_obj;
-	struct client_obd     *cli = osc_cli(obj);
-	struct osc_extent     *ext;
-	struct osc_extent     *found = NULL;
-	struct list_head	    *plist;
+	struct osc_object *obj = oap->oap_obj;
+	struct client_obd *cli = osc_cli(obj);
+	struct osc_extent *ext;
+	struct osc_extent *found = NULL;
+	struct list_head *plist;
 	pgoff_t index = oap2cl_page(oap)->cp_index;
-	int     rc = -EBUSY;
-	int     cmd;
+	int rc = -EBUSY;
+	int cmd;
 
 	LASSERT(!oap->oap_interrupted);
 	oap->oap_interrupted = 1;
@@ -2564,13 +2564,13 @@ int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops)
 int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 			 struct list_head *list, int cmd, int brw_flags)
 {
-	struct client_obd     *cli = osc_cli(obj);
-	struct osc_extent     *ext;
+	struct client_obd *cli = osc_cli(obj);
+	struct osc_extent *ext;
 	struct osc_async_page *oap, *tmp;
-	int     page_count = 0;
-	int     mppr       = cli->cl_max_pages_per_rpc;
-	pgoff_t start      = CL_PAGE_EOF;
-	pgoff_t end	= 0;
+	int page_count = 0;
+	int mppr = cli->cl_max_pages_per_rpc;
+	pgoff_t start = CL_PAGE_EOF;
+	pgoff_t end = 0;
 
 	list_for_each_entry(oap, list, oap_pending_item) {
 		struct cl_page *cp = oap2cl_page(oap);
@@ -2785,7 +2785,7 @@ int osc_cache_wait_range(const struct lu_env *env, struct osc_object *obj,
 {
 	struct osc_extent *ext;
 	pgoff_t index = start;
-	int     result = 0;
+	int result = 0;
 
 again:
 	osc_object_lock(obj);
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 3c7300b..5368a91 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -100,16 +100,16 @@ static int osc_io_submit(const struct lu_env *env,
 			 const struct cl_io_slice *ios,
 			 enum cl_req_type crt, struct cl_2queue *queue)
 {
-	struct cl_page    *page;
-	struct cl_page    *tmp;
+	struct cl_page *page;
+	struct cl_page *tmp;
 	struct client_obd *cli  = NULL;
 	struct osc_object *osc  = NULL; /* to keep gcc happy */
-	struct osc_page   *opg;
-	struct cl_io      *io;
+	struct osc_page *opg;
+	struct cl_io *io;
 	LIST_HEAD(list);
 
-	struct cl_page_list *qin      = &queue->c2_qin;
-	struct cl_page_list *qout     = &queue->c2_qout;
+	struct cl_page_list *qin = &queue->c2_qin;
+	struct cl_page_list *qout = &queue->c2_qout;
 	int queued = 0;
 	int result = 0;
 	int cmd;
@@ -189,8 +189,8 @@ static int osc_io_submit(const struct lu_env *env,
 static void osc_page_touch_at(const struct lu_env *env,
 			      struct cl_object *obj, pgoff_t idx, unsigned to)
 {
-	struct lov_oinfo  *loi  = cl2osc(obj)->oo_oinfo;
-	struct cl_attr    *attr = &osc_env_info(env)->oti_attr;
+	struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
+	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	int valid;
 	__u64 kms;
 
@@ -233,8 +233,8 @@ static void osc_page_touch_at(const struct lu_env *env,
 static void osc_page_touch(const struct lu_env *env,
 			   struct osc_page *opage, unsigned to)
 {
-	struct cl_page    *page = opage->ops_cl.cpl_page;
-	struct cl_object  *obj  = opage->ops_cl.cpl_obj;
+	struct cl_page *page = opage->ops_cl.cpl_page;
+	struct cl_object *obj = opage->ops_cl.cpl_obj;
 
 	osc_page_touch_at(env, obj, page->cp_index, to);
 }
@@ -260,7 +260,7 @@ static int osc_io_prepare_write(const struct lu_env *env,
 {
 	struct osc_device *dev = lu2osc_dev(slice->cpl_obj->co_lu.lo_dev);
 	struct obd_import *imp = class_exp2cliimp(dev->od_exp);
-	struct osc_io     *oio = cl2osc_io(env, ios);
+	struct osc_io *oio = cl2osc_io(env, ios);
 	int result = 0;
 
 	/*
@@ -284,9 +284,9 @@ static int osc_io_commit_write(const struct lu_env *env,
 			       const struct cl_page_slice *slice,
 			       unsigned from, unsigned to)
 {
-	struct osc_io	 *oio = cl2osc_io(env, ios);
-	struct osc_page       *opg = cl2osc_page(slice);
-	struct osc_object     *obj = cl2osc(opg->ops_cl.cpl_obj);
+	struct osc_io *oio = cl2osc_io(env, ios);
+	struct osc_page *opg = cl2osc_page(slice);
+	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 	struct osc_async_page *oap = &opg->ops_oap;
 
 	LASSERT(to > 0);
@@ -311,7 +311,7 @@ static int osc_io_commit_write(const struct lu_env *env,
 static int osc_io_fault_start(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
-	struct cl_io       *io;
+	struct cl_io *io;
 	struct cl_fault_io *fio;
 
 	io  = ios->cis_io;
@@ -375,11 +375,11 @@ static void osc_trunc_check(const struct lu_env *env, struct cl_io *io,
 			    struct osc_io *oio, __u64 size)
 {
 	struct cl_object *clob;
-	int     partial;
+	int partial;
 	pgoff_t start;
 
-	clob    = oio->oi_cl.cis_obj;
-	start   = cl_index(clob, size);
+	clob = oio->oi_cl.cis_obj;
+	start = cl_index(clob, size);
 	partial = cl_offset(clob, start) < size;
 
 	/*
@@ -392,17 +392,17 @@ static void osc_trunc_check(const struct lu_env *env, struct cl_io *io,
 static int osc_io_setattr_start(const struct lu_env *env,
 				const struct cl_io_slice *slice)
 {
-	struct cl_io	    *io     = slice->cis_io;
-	struct osc_io	   *oio    = cl2osc_io(env, slice);
-	struct cl_object	*obj    = slice->cis_obj;
-	struct lov_oinfo	*loi    = cl2osc(obj)->oo_oinfo;
-	struct cl_attr	  *attr   = &osc_env_info(env)->oti_attr;
-	struct obdo	     *oa     = &oio->oi_oa;
+	struct cl_io *io = slice->cis_io;
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct cl_object *obj = slice->cis_obj;
+	struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
+	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
+	struct obdo *oa = &oio->oi_oa;
 	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
-	__u64		    size   = io->u.ci_setattr.sa_attr.lvb_size;
-	unsigned int	     ia_valid = io->u.ci_setattr.sa_valid;
-	int		      result = 0;
-	struct obd_info	  oinfo = { { { 0 } } };
+	__u64 size = io->u.ci_setattr.sa_attr.lvb_size;
+	unsigned int ia_valid = io->u.ci_setattr.sa_valid;
+	int result = 0;
+	struct obd_info	oinfo = { { { 0 } } };
 
 	/* truncate cache dirty pages first */
 	if (cl_io_is_trunc(io))
@@ -477,8 +477,8 @@ static int osc_io_setattr_start(const struct lu_env *env,
 static void osc_io_setattr_end(const struct lu_env *env,
 			       const struct cl_io_slice *slice)
 {
-	struct cl_io     *io  = slice->cis_io;
-	struct osc_io    *oio = cl2osc_io(env, slice);
+	struct cl_io *io = slice->cis_io;
+	struct osc_io *oio = cl2osc_io(env, slice);
 	struct cl_object *obj = slice->cis_obj;
 	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
 	int result = 0;
@@ -512,8 +512,8 @@ static void osc_io_setattr_end(const struct lu_env *env,
 static int osc_io_read_start(const struct lu_env *env,
 			     const struct cl_io_slice *slice)
 {
-	struct cl_object *obj   = slice->cis_obj;
-	struct cl_attr   *attr  = &osc_env_info(env)->oti_attr;
+	struct cl_object *obj = slice->cis_obj;
+	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	int rc = 0;
 
 	if (!slice->cis_io->ci_noatime) {
@@ -528,8 +528,8 @@ static int osc_io_read_start(const struct lu_env *env,
 static int osc_io_write_start(const struct lu_env *env,
 			      const struct cl_io_slice *slice)
 {
-	struct cl_object *obj   = slice->cis_obj;
-	struct cl_attr   *attr  = &osc_env_info(env)->oti_attr;
+	struct cl_object *obj = slice->cis_obj;
+	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	int rc = 0;
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_SETTIME, 1);
@@ -544,10 +544,10 @@ static int osc_io_write_start(const struct lu_env *env,
 static int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 			 struct cl_fsync_io *fio)
 {
-	struct osc_io    *oio   = osc_env_io(env);
-	struct obdo      *oa    = &oio->oi_oa;
-	struct obd_info  *oinfo = &oio->oi_info;
-	struct lov_oinfo *loi   = obj->oo_oinfo;
+	struct osc_io *oio = osc_env_io(env);
+	struct obdo *oa = &oio->oi_oa;
+	struct obd_info *oinfo = &oio->oi_info;
+	struct lov_oinfo *loi = obj->oo_oinfo;
 	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
 	int rc = 0;
 
@@ -575,13 +575,13 @@ static int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 static int osc_io_fsync_start(const struct lu_env *env,
 			      const struct cl_io_slice *slice)
 {
-	struct cl_io       *io  = slice->cis_io;
+	struct cl_io *io  = slice->cis_io;
 	struct cl_fsync_io *fio = &io->u.ci_fsync;
-	struct cl_object   *obj = slice->cis_obj;
-	struct osc_object  *osc = cl2osc(obj);
-	pgoff_t start  = cl_index(obj, fio->fi_start);
-	pgoff_t end    = cl_index(obj, fio->fi_end);
-	int     result = 0;
+	struct cl_object *obj = slice->cis_obj;
+	struct osc_object *osc = cl2osc(obj);
+	pgoff_t start = cl_index(obj, fio->fi_start);
+	pgoff_t end = cl_index(obj, fio->fi_end);
+	int result = 0;
 
 	if (fio->fi_end == OBD_OBJECT_EOF)
 		end = CL_PAGE_EOF;
@@ -615,15 +615,15 @@ static void osc_io_fsync_end(const struct lu_env *env,
 			     const struct cl_io_slice *slice)
 {
 	struct cl_fsync_io *fio = &slice->cis_io->u.ci_fsync;
-	struct cl_object   *obj = slice->cis_obj;
+	struct cl_object *obj = slice->cis_obj;
 	pgoff_t start = cl_index(obj, fio->fi_start);
-	pgoff_t end   = cl_index(obj, fio->fi_end);
+	pgoff_t end = cl_index(obj, fio->fi_end);
 	int result = 0;
 
 	if (fio->fi_mode == CL_FSYNC_LOCAL) {
 		result = osc_cache_wait_range(env, cl2osc(obj), start, end);
 	} else if (fio->fi_mode == CL_FSYNC_ALL) {
-		struct osc_io	   *oio    = cl2osc_io(env, slice);
+		struct osc_io *oio = cl2osc_io(env, slice);
 		struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
 
 		wait_for_completion(&cbargs->opc_sync);
@@ -717,17 +717,17 @@ static void osc_req_attr_set(const struct lu_env *env,
 			     struct cl_req_attr *attr, u64 flags)
 {
 	struct lov_oinfo *oinfo;
-	struct cl_req    *clerq;
-	struct cl_page   *apage; /* _some_ page in @clerq */
-	struct cl_lock   *lock;  /* _some_ lock protecting @apage */
-	struct osc_lock  *olck;
-	struct osc_page  *opg;
-	struct obdo      *oa;
-	struct ost_lvb   *lvb;
-
-	oinfo	= cl2osc(obj)->oo_oinfo;
-	lvb	= &oinfo->loi_lvb;
-	oa	= attr->cra_oa;
+	struct cl_req *clerq;
+	struct cl_page *apage; /* _some_ page in @clerq */
+	struct cl_lock *lock;  /* _some_ lock protecting @apage */
+	struct osc_lock *olck;
+	struct osc_page *opg;
+	struct obdo *oa;
+	struct ost_lvb *lvb;
+
+	oinfo = cl2osc(obj)->oo_oinfo;
+	lvb = &oinfo->loi_lvb;
+	oa = attr->cra_oa;
 
 	if ((flags & OBD_MD_FLMTIME) != 0) {
 		oa->o_mtime = lvb->lvb_mtime;
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 350ad49..9d851ad 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -89,9 +89,9 @@ static struct ldlm_lock *osc_handle_ptr(struct lustre_handle *handle)
  */
 static int osc_lock_invariant(struct osc_lock *ols)
 {
-	struct ldlm_lock *lock	      = osc_handle_ptr(&ols->ols_handle);
-	struct ldlm_lock *olock	      = ols->ols_lock;
-	int		  handle_used = lustre_handle_is_used(&ols->ols_handle);
+	struct ldlm_lock *lock = osc_handle_ptr(&ols->ols_handle);
+	struct ldlm_lock *olock = ols->ols_lock;
+	int handle_used = lustre_handle_is_used(&ols->ols_handle);
 
 	if (ergo(osc_lock_is_lockless(ols),
 		 ols->ols_locklessable && ols->ols_lock == NULL))
@@ -237,7 +237,7 @@ static int osc_lock_unuse(const struct lu_env *env,
 static void osc_lock_fini(const struct lu_env *env,
 			  struct cl_lock_slice *slice)
 {
-	struct osc_lock  *ols = cl2osc_lock(slice);
+	struct osc_lock *ols = cl2osc_lock(slice);
 
 	LINVRNT(osc_lock_invariant(ols));
 	/*
@@ -337,19 +337,19 @@ static void osc_ast_data_put(const struct lu_env *env, struct osc_lock *olck)
 static void osc_lock_lvb_update(const struct lu_env *env, struct osc_lock *olck,
 				int rc)
 {
-	struct ost_lvb    *lvb;
-	struct cl_object  *obj;
-	struct lov_oinfo  *oinfo;
-	struct cl_attr    *attr;
-	unsigned	   valid;
+	struct ost_lvb *lvb;
+	struct cl_object *obj;
+	struct lov_oinfo *oinfo;
+	struct cl_attr *attr;
+	unsigned valid;
 
 	if (!(olck->ols_flags & LDLM_FL_LVB_READY))
 		return;
 
-	lvb   = &olck->ols_lvb;
-	obj   = olck->ols_cl.cls_obj;
+	lvb = &olck->ols_lvb;
+	obj = olck->ols_cl.cls_obj;
 	oinfo = cl2osc(obj)->oo_oinfo;
-	attr  = &osc_env_info(env)->oti_attr;
+	attr = &osc_env_info(env)->oti_attr;
 	valid = CAT_BLOCKS | CAT_ATIME | CAT_CTIME | CAT_MTIME | CAT_SIZE;
 	cl_lvb2attr(attr, lvb);
 
@@ -401,8 +401,8 @@ static void osc_lock_lvb_update(const struct lu_env *env, struct osc_lock *olck,
 static void osc_lock_granted(const struct lu_env *env, struct osc_lock *olck,
 			     struct ldlm_lock *dlmlock, int rc)
 {
-	struct ldlm_extent   *ext;
-	struct cl_lock       *lock;
+	struct ldlm_extent *ext;
+	struct cl_lock *lock;
 	struct cl_lock_descr *descr;
 
 	LASSERT(dlmlock->l_granted_mode == dlmlock->l_req_mode);
@@ -414,10 +414,10 @@ static void osc_lock_granted(const struct lu_env *env, struct osc_lock *olck,
 		descr->cld_obj = lock->cll_descr.cld_obj;
 
 		/* XXX check that ->l_granted_mode is valid. */
-		descr->cld_mode  = osc_ldlm2cl_lock(dlmlock->l_granted_mode);
+		descr->cld_mode = osc_ldlm2cl_lock(dlmlock->l_granted_mode);
 		descr->cld_start = cl_index(descr->cld_obj, ext->start);
-		descr->cld_end   = cl_index(descr->cld_obj, ext->end);
-		descr->cld_gid   = ext->gid;
+		descr->cld_end = cl_index(descr->cld_obj, ext->end);
+		descr->cld_gid = ext->gid;
 		/*
 		 * tell upper layers the extent of the lock that was actually
 		 * granted
@@ -482,11 +482,11 @@ static void osc_lock_upcall0(const struct lu_env *env, struct osc_lock *olck)
  */
 static int osc_lock_upcall(void *cookie, int errcode)
 {
-	struct osc_lock	 *olck  = cookie;
-	struct cl_lock_slice    *slice = &olck->ols_cl;
-	struct cl_lock	  *lock  = slice->cls_lock;
-	struct lu_env	   *env;
-	struct cl_env_nest       nest;
+	struct osc_lock *olck = cookie;
+	struct cl_lock_slice *slice = &olck->ols_cl;
+	struct cl_lock *lock = slice->cls_lock;
+	struct lu_env *env;
+	struct cl_env_nest nest;
 
 	env = cl_env_nested_get(&nest);
 	if (!IS_ERR(env)) {
@@ -626,7 +626,7 @@ static int osc_dlm_blocking_ast0(const struct lu_env *env,
 				 void *data, int flag)
 {
 	struct osc_lock *olck;
-	struct cl_lock  *lock;
+	struct cl_lock *lock;
 	int result;
 	int cancel;
 
@@ -733,9 +733,9 @@ static int osc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 				 struct ldlm_lock_desc *new, void *data,
 				 int flag)
 {
-	struct lu_env     *env;
+	struct lu_env *env;
 	struct cl_env_nest nest;
-	int		result;
+	int result;
 
 	/*
 	 * This can be called in the context of outer IO, e.g.,
@@ -774,9 +774,9 @@ static int osc_ldlm_completion_ast(struct ldlm_lock *dlmlock,
 				   __u64 flags, void *data)
 {
 	struct cl_env_nest nest;
-	struct lu_env     *env;
-	struct osc_lock   *olck;
-	struct cl_lock    *lock;
+	struct lu_env *env;
+	struct osc_lock *olck;
+	struct cl_lock *lock;
 	int result;
 	int dlmrc;
 
@@ -830,15 +830,15 @@ static int osc_ldlm_completion_ast(struct ldlm_lock *dlmlock,
 
 static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 {
-	struct ptlrpc_request  *req  = data;
+	struct ptlrpc_request *req = data;
 	struct osc_lock	*olck;
-	struct cl_lock	 *lock;
-	struct cl_object       *obj;
-	struct cl_env_nest      nest;
-	struct lu_env	  *env;
-	struct ost_lvb	 *lvb;
-	struct req_capsule     *cap;
-	int		     result;
+	struct cl_lock *lock;
+	struct cl_object *obj;
+	struct cl_env_nest nest;
+	struct lu_env *env;
+	struct ost_lvb *lvb;
+	struct req_capsule *cap;
+	int result;
 
 	LASSERT(lustre_msg_get_opc(req->rq_reqmsg) == LDLM_GL_CALLBACK);
 
@@ -916,11 +916,11 @@ static void osc_lock_build_einfo(const struct lu_env *env,
 		 */
 		mode = CLM_READ;
 
-	einfo->ei_type   = LDLM_EXTENT;
-	einfo->ei_mode   = osc_cl_lock2ldlm(mode);
-	einfo->ei_cb_bl  = osc_ldlm_blocking_ast;
-	einfo->ei_cb_cp  = osc_ldlm_completion_ast;
-	einfo->ei_cb_gl  = osc_ldlm_glimpse_ast;
+	einfo->ei_type = LDLM_EXTENT;
+	einfo->ei_mode = osc_cl_lock2ldlm(mode);
+	einfo->ei_cb_bl = osc_ldlm_blocking_ast;
+	einfo->ei_cb_cp = osc_ldlm_completion_ast;
+	einfo->ei_cb_gl = osc_ldlm_glimpse_ast;
 	einfo->ei_cbdata = lock; /* value to be put into ->l_ast_data */
 }
 
@@ -948,9 +948,9 @@ static void osc_lock_to_lockless(const struct lu_env *env,
 		ols->ols_locklessable = 1;
 		slice->cls_ops = &osc_lock_lockless_ops;
 	} else {
-		struct osc_io *oio     = osc_env_io(env);
-		struct cl_io  *io      = oio->oi_cl.cis_io;
-		struct cl_object *obj  = slice->cls_obj;
+		struct osc_io *oio = osc_env_io(env);
+		struct cl_io *io = oio->oi_cl.cis_io;
+		struct cl_object *obj = slice->cls_obj;
 		struct osc_object *oob = cl2osc(obj);
 		const struct osc_device *osd = lu2osc_dev(obj->co_lu.lo_dev);
 		struct obd_connect_data *ocd;
@@ -1006,13 +1006,13 @@ static int osc_lock_compatible(const struct osc_lock *qing,
 static int osc_lock_enqueue_wait(const struct lu_env *env,
 				 const struct osc_lock *olck)
 {
-	struct cl_lock	  *lock    = olck->ols_cl.cls_lock;
-	struct cl_lock_descr    *descr   = &lock->cll_descr;
-	struct cl_object_header *hdr     = cl_object_header(descr->cld_obj);
-	struct cl_lock	  *scan;
-	struct cl_lock	  *conflict = NULL;
-	int lockless		     = osc_lock_is_lockless(olck);
-	int rc			   = 0;
+	struct cl_lock *lock = olck->ols_cl.cls_lock;
+	struct cl_lock_descr *descr = &lock->cll_descr;
+	struct cl_object_header *hdr = cl_object_header(descr->cld_obj);
+	struct cl_lock *scan;
+	struct cl_lock *conflict = NULL;
+	int lockless = osc_lock_is_lockless(olck);
+	int rc = 0;
 
 	LASSERT(cl_lock_is_mutexed(lock));
 
@@ -1102,8 +1102,8 @@ static int osc_lock_enqueue(const struct lu_env *env,
 			    const struct cl_lock_slice *slice,
 			    struct cl_io *unused, __u32 enqflags)
 {
-	struct osc_lock	  *ols     = cl2osc_lock(slice);
-	struct cl_lock	   *lock    = ols->ols_cl.cls_lock;
+	struct osc_lock	*ols = cl2osc_lock(slice);
+	struct cl_lock *lock = ols->ols_cl.cls_lock;
 	int result;
 
 	LASSERT(cl_lock_is_mutexed(lock));
@@ -1116,10 +1116,10 @@ static int osc_lock_enqueue(const struct lu_env *env,
 	result = osc_lock_enqueue_wait(env, ols);
 	if (result == 0) {
 		if (!osc_lock_is_lockless(ols)) {
-			struct osc_object	*obj = cl2osc(slice->cls_obj);
-			struct osc_thread_info   *info = osc_env_info(env);
-			struct ldlm_res_id       *resname = &info->oti_resname;
-			ldlm_policy_data_t       *policy = &info->oti_policy;
+			struct osc_object *obj = cl2osc(slice->cls_obj);
+			struct osc_thread_info *info = osc_env_info(env);
+			struct ldlm_res_id *resname = &info->oti_resname;
+			ldlm_policy_data_t *policy = &info->oti_policy;
 			struct ldlm_enqueue_info *einfo = &ols->ols_einfo;
 
 			/* lock will be passed as upcall cookie,
@@ -1164,7 +1164,7 @@ static int osc_lock_wait(const struct lu_env *env,
 			 const struct cl_lock_slice *slice)
 {
 	struct osc_lock *olck = cl2osc_lock(slice);
-	struct cl_lock  *lock = olck->ols_cl.cls_lock;
+	struct cl_lock *lock = olck->ols_cl.cls_lock;
 
 	LINVRNT(osc_lock_invariant(olck));
 
@@ -1245,14 +1245,14 @@ static int osc_lock_use(const struct lu_env *env,
 
 static int osc_lock_flush(struct osc_lock *ols, int discard)
 {
-	struct cl_lock       *lock  = ols->ols_cl.cls_lock;
-	struct cl_env_nest    nest;
-	struct lu_env	*env;
+	struct cl_lock *lock = ols->ols_cl.cls_lock;
+	struct cl_env_nest nest;
+	struct lu_env *env;
 	int result = 0;
 
 	env = cl_env_nested_get(&nest);
 	if (!IS_ERR(env)) {
-		struct osc_object    *obj   = cl2osc(ols->ols_cl.cls_obj);
+		struct osc_object *obj = cl2osc(ols->ols_cl.cls_obj);
 		struct cl_lock_descr *descr = &lock->cll_descr;
 		int rc = 0;
 
@@ -1298,11 +1298,11 @@ static int osc_lock_flush(struct osc_lock *ols, int discard)
 static void osc_lock_cancel(const struct lu_env *env,
 			    const struct cl_lock_slice *slice)
 {
-	struct cl_lock   *lock    = slice->cls_lock;
-	struct osc_lock  *olck    = cl2osc_lock(slice);
+	struct cl_lock *lock = slice->cls_lock;
+	struct osc_lock *olck = cl2osc_lock(slice);
 	struct ldlm_lock *dlmlock = olck->ols_lock;
-	int	       result  = 0;
-	int	       discard;
+	int result  = 0;
+	int discard;
 
 	LASSERT(cl_lock_is_mutexed(lock));
 	LINVRNT(osc_lock_invariant(olck));
@@ -1591,7 +1591,7 @@ int osc_lock_init(const struct lu_env *env,
 int osc_dlm_lock_pageref(struct ldlm_lock *dlm)
 {
 	struct osc_lock *olock;
-	int	      rc = 0;
+	int rc = 0;
 
 	spin_lock(&osc_ast_guard);
 	olock = dlm->l_ast_data;
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 92c202f..c628a25 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -72,7 +72,7 @@ static struct osc_object *lu2osc(const struct lu_object *obj)
 static int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 			   const struct lu_object_conf *conf)
 {
-	struct osc_object	   *osc   = lu2osc(obj);
+	struct osc_object *osc = lu2osc(obj);
 	const struct cl_object_conf *cconf = lu2cl_conf(conf);
 	int i;
 
@@ -136,9 +136,9 @@ int osc_lvb_print(const struct lu_env *env, void *cookie,
 static int osc_object_print(const struct lu_env *env, void *cookie,
 			    lu_printer_t p, const struct lu_object *obj)
 {
-	struct osc_object   *osc   = lu2osc(obj);
-	struct lov_oinfo    *oinfo = osc->oo_oinfo;
-	struct osc_async_rc *ar    = &oinfo->loi_ar;
+	struct osc_object *osc = lu2osc(obj);
+	struct lov_oinfo *oinfo = osc->oo_oinfo;
+	struct osc_async_rc *ar = &oinfo->loi_ar;
 
 	(*p)(env, cookie, "id: " DOSTID " idx: %d gen: %d kms_valid: %u kms %llu rc: %d force_sync: %d min_xid: %llu ",
 	     POSTID(&oinfo->loi_oi), oinfo->loi_ost_idx,
@@ -163,7 +163,7 @@ int osc_attr_set(const struct lu_env *env, struct cl_object *obj,
 		 const struct cl_attr *attr, unsigned valid)
 {
 	struct lov_oinfo *oinfo = cl2osc(obj)->oo_oinfo;
-	struct ost_lvb   *lvb   = &oinfo->loi_lvb;
+	struct ost_lvb *lvb = &oinfo->loi_lvb;
 
 	if (valid & CAT_SIZE)
 		lvb->lvb_size = attr->cat_size;
@@ -188,7 +188,7 @@ static int osc_object_glimpse(const struct lu_env *env,
 {
 	struct lov_oinfo *oinfo = cl2osc(obj)->oo_oinfo;
 
-	lvb->lvb_size   = oinfo->loi_kms;
+	lvb->lvb_size = oinfo->loi_kms;
 	lvb->lvb_blocks = oinfo->loi_lvb.lvb_blocks;
 	return 0;
 }
@@ -208,9 +208,9 @@ void osc_object_clear_contended(struct osc_object *obj)
 
 int osc_object_is_contended(struct osc_object *obj)
 {
-	struct osc_device *dev  = lu2osc_dev(obj->oo_cl.co_lu.lo_dev);
+	struct osc_device *dev = lu2osc_dev(obj->oo_cl.co_lu.lo_dev);
 	int osc_contention_time = dev->od_contention_time;
-	unsigned long cur_time     = cfs_time_current();
+	unsigned long cur_time = cfs_time_current();
 	unsigned long retry_time;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_OBJECT_CONTENTION))
@@ -255,7 +255,7 @@ struct lu_object *osc_object_alloc(const struct lu_env *env,
 				   struct lu_device *dev)
 {
 	struct osc_object *osc;
-	struct lu_object  *obj;
+	struct lu_object *obj;
 
 	OBD_SLAB_ALLOC_PTR_GFP(osc, osc_object_kmem, GFP_NOFS);
 	if (osc != NULL) {
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 76ba58b..4077904 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -216,7 +216,7 @@ static int osc_page_cache_add(const struct lu_env *env,
 			      const struct cl_page_slice *slice,
 			      struct cl_io *io)
 {
-	struct osc_io   *oio = osc_env_io(env);
+	struct osc_io *oio = osc_env_io(env);
 	struct osc_page *opg = cl2osc_page(slice);
 	int result;
 
@@ -255,7 +255,7 @@ static int osc_page_addref_lock(const struct lu_env *env,
 				struct cl_lock *lock)
 {
 	struct osc_lock *olock;
-	int	      rc;
+	int rc;
 
 	LASSERT(opg->ops_lock == NULL);
 
@@ -274,7 +274,7 @@ static int osc_page_addref_lock(const struct lu_env *env,
 static void osc_page_putref_lock(const struct lu_env *env,
 				 struct osc_page *opg)
 {
-	struct cl_lock  *lock = opg->ops_lock;
+	struct cl_lock *lock = opg->ops_lock;
 	struct osc_lock *olock;
 
 	LASSERT(lock != NULL);
@@ -291,7 +291,7 @@ static int osc_page_is_under_lock(const struct lu_env *env,
 				  struct cl_io *unused)
 {
 	struct cl_lock *lock;
-	int	     result = -ENODATA;
+	int result = -ENODATA;
 
 	lock = cl_lock_at_page(env, slice->cpl_obj, slice->cpl_page,
 			       NULL, 1, 0);
@@ -317,7 +317,7 @@ static void osc_page_completion_read(const struct lu_env *env,
 				     const struct cl_page_slice *slice,
 				     int ioret)
 {
-	struct osc_page   *opg = cl2osc_page(slice);
+	struct osc_page *opg = cl2osc_page(slice);
 	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 
 	if (likely(opg->ops_lock))
@@ -329,7 +329,7 @@ static void osc_page_completion_write(const struct lu_env *env,
 				      const struct cl_page_slice *slice,
 				      int ioret)
 {
-	struct osc_page   *opg = cl2osc_page(slice);
+	struct osc_page *opg = cl2osc_page(slice);
 	struct osc_object *obj = cl2osc(slice->cpl_obj);
 
 	osc_lru_add(osc_cli(obj), opg);
@@ -364,10 +364,10 @@ static int osc_page_print(const struct lu_env *env,
 			  const struct cl_page_slice *slice,
 			  void *cookie, lu_printer_t printer)
 {
-	struct osc_page       *opg = cl2osc_page(slice);
+	struct osc_page *opg = cl2osc_page(slice);
 	struct osc_async_page *oap = &opg->ops_oap;
-	struct osc_object     *obj = cl2osc(slice->cpl_obj);
-	struct client_obd     *cli = &osc_export(obj)->exp_obd->u.cli;
+	struct osc_object *obj = cl2osc(slice->cpl_obj);
+	struct client_obd *cli = &osc_export(obj)->exp_obd->u.cli;
 
 	return (*printer)(env, cookie, LUSTRE_OSC_NAME "-page@%p: 1< %#x %d %u %s %s > 2< %llu %u %u %#x %#x | %p %p %p > 3< %s %p %d %lu %d > 4< %d %d %d %lu %s | %s %s %s %s > 5< %s %s %s %s | %d %s | %d %s %s>\n",
 			  opg,
@@ -408,7 +408,7 @@ static int osc_page_print(const struct lu_env *env,
 static void osc_page_delete(const struct lu_env *env,
 			    const struct cl_page_slice *slice)
 {
-	struct osc_page   *opg = cl2osc_page(slice);
+	struct osc_page *opg = cl2osc_page(slice);
 	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 	int rc;
 
@@ -437,7 +437,7 @@ static void osc_page_delete(const struct lu_env *env,
 void osc_page_clip(const struct lu_env *env, const struct cl_page_slice *slice,
 		   int from, int to)
 {
-	struct osc_page       *opg = cl2osc_page(slice);
+	struct osc_page *opg = cl2osc_page(slice);
 	struct osc_async_page *oap = &opg->ops_oap;
 
 	LINVRNT(osc_page_protected(env, opg, CLM_READ, 0));
@@ -478,8 +478,8 @@ static int osc_page_flush(const struct lu_env *env,
 }
 
 static const struct cl_page_operations osc_page_ops = {
-	.cpo_fini	  = osc_page_fini,
-	.cpo_print	 = osc_page_print,
+	.cpo_fini	= osc_page_fini,
+	.cpo_print	= osc_page_print,
 	.cpo_delete	= osc_page_delete,
 	.cpo_is_under_lock = osc_page_is_under_lock,
 	.cpo_disown	= osc_page_disown,
@@ -493,20 +493,20 @@ static const struct cl_page_operations osc_page_ops = {
 			.cpo_completion = osc_page_completion_write
 		}
 	},
-	.cpo_clip	   = osc_page_clip,
-	.cpo_cancel	 = osc_page_cancel,
-	.cpo_flush	  = osc_page_flush
+	.cpo_clip	= osc_page_clip,
+	.cpo_cancel	= osc_page_cancel,
+	.cpo_flush	= osc_page_flush
 };
 
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_page *page, struct page *vmpage)
 {
 	struct osc_object *osc = cl2osc(obj);
-	struct osc_page   *opg = cl_object_page_slice(obj, page);
+	struct osc_page *opg = cl_object_page_slice(obj, page);
 	int result;
 
 	opg->ops_from = 0;
-	opg->ops_to   = PAGE_CACHE_SIZE;
+	opg->ops_to = PAGE_CACHE_SIZE;
 
 	result = osc_prep_async_page(osc, opg, vmpage,
 					cl_offset(obj, page->cp_index));
@@ -540,7 +540,7 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 		     enum cl_req_type crt, int brw_flags)
 {
 	struct osc_async_page *oap = &opg->ops_oap;
-	struct osc_object     *obj = oap->oap_obj;
+	struct osc_object *obj = oap->oap_obj;
 
 	LINVRNT(osc_page_protected(env, opg,
 				   crt == CRT_WRITE ? CLM_WRITE : CLM_READ, 1));
@@ -550,9 +550,9 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	LASSERT(oap->oap_async_flags & ASYNC_READY);
 	LASSERT(oap->oap_async_flags & ASYNC_COUNT_STABLE);
 
-	oap->oap_cmd       = crt == CRT_WRITE ? OBD_BRW_WRITE : OBD_BRW_READ;
-	oap->oap_page_off  = opg->ops_from;
-	oap->oap_count     = opg->ops_to - opg->ops_from;
+	oap->oap_cmd = crt == CRT_WRITE ? OBD_BRW_WRITE : OBD_BRW_READ;
+	oap->oap_page_off = opg->ops_from;
+	oap->oap_count = opg->ops_to - opg->ops_from;
 	oap->oap_brw_flags = OBD_BRW_SYNC | brw_flags;
 
 	if (!client_is_remote(osc_export(obj)) &&
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index 6690f14..2ff253f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -232,7 +232,7 @@ int osc_quota_setup(struct obd_device *obd)
 
 int osc_quota_cleanup(struct obd_device *obd)
 {
-	struct client_obd     *cli = &obd->u.cli;
+	struct client_obd *cli = &obd->u.cli;
 	int type;
 
 	for (type = 0; type < MAXQUOTAS; type++)
@@ -245,8 +245,8 @@ int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
 		 struct obd_quotactl *oqctl)
 {
 	struct ptlrpc_request *req;
-	struct obd_quotactl   *oqc;
-	int		    rc;
+	struct obd_quotactl *oqc;
+	int rc;
 
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_OST_QUOTACTL, LUSTRE_OST_VERSION,
@@ -285,10 +285,10 @@ int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
 int osc_quotacheck(struct obd_device *unused, struct obd_export *exp,
 		   struct obd_quotactl *oqctl)
 {
-	struct client_obd       *cli = &exp->exp_obd->u.cli;
-	struct ptlrpc_request   *req;
-	struct obd_quotactl     *body;
-	int		      rc;
+	struct client_obd *cli = &exp->exp_obd->u.cli;
+	struct ptlrpc_request *req;
+	struct obd_quotactl *body;
+	int rc;
 
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 					&RQF_OST_QUOTACHECK, LUSTRE_OST_VERSION,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index ded184e..f5d8b10 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -54,44 +54,44 @@
 #include "osc_cl_internal.h"
 
 struct osc_brw_async_args {
-	struct obdo       *aa_oa;
-	int		aa_requested_nob;
-	int		aa_nio_count;
-	u32		aa_page_count;
-	int		aa_resends;
-	struct brw_page  **aa_ppga;
+	struct obdo *aa_oa;
+	int aa_requested_nob;
+	int aa_nio_count;
+	u32 aa_page_count;
+	int aa_resends;
+	struct brw_page **aa_ppga;
 	struct client_obd *aa_cli;
-	struct list_head	 aa_oaps;
-	struct list_head	 aa_exts;
-	struct obd_capa   *aa_ocapa;
-	struct cl_req     *aa_clerq;
+	struct list_head aa_oaps;
+	struct list_head aa_exts;
+	struct obd_capa *aa_ocapa;
+	struct cl_req *aa_clerq;
 };
 
 struct osc_async_args {
-	struct obd_info   *aa_oi;
+	struct obd_info *aa_oi;
 };
 
 struct osc_setattr_args {
-	struct obdo	 *sa_oa;
+	struct obdo *sa_oa;
 	obd_enqueue_update_f sa_upcall;
-	void		*sa_cookie;
+	void *sa_cookie;
 };
 
 struct osc_fsync_args {
-	struct obd_info     *fa_oi;
+	struct obd_info *fa_oi;
 	obd_enqueue_update_f fa_upcall;
-	void		*fa_cookie;
+	void *fa_cookie;
 };
 
 struct osc_enqueue_args {
-	struct obd_export	*oa_exp;
-	__u64		    *oa_flags;
-	obd_enqueue_update_f      oa_upcall;
-	void		     *oa_cookie;
-	struct ost_lvb	   *oa_lvb;
-	struct lustre_handle     *oa_lockh;
+	struct obd_export *oa_exp;
+	__u64 *oa_flags;
+	obd_enqueue_update_f oa_upcall;
+	void *oa_cookie;
+	struct ost_lvb *oa_lvb;
+	struct lustre_handle *oa_lockh;
 	struct ldlm_enqueue_info *oa_ei;
-	unsigned int	      oa_agl:1;
+	unsigned int oa_agl:1;
 };
 
 static void osc_release_ppga(struct brw_page **ppga, u32 count);
@@ -403,9 +403,9 @@ int osc_setattr_async_base(struct obd_export *exp, struct obd_info *oinfo,
 			   obd_enqueue_update_f upcall, void *cookie,
 			   struct ptlrpc_request_set *rqset)
 {
-	struct ptlrpc_request   *req;
+	struct ptlrpc_request *req;
 	struct osc_setattr_args *sa;
-	int		      rc;
+	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_SETATTR);
 	if (req == NULL)
@@ -460,9 +460,9 @@ int osc_real_create(struct obd_export *exp, struct obdo *oa,
 		    struct lov_stripe_md **ea, struct obd_trans_info *oti)
 {
 	struct ptlrpc_request *req;
-	struct ost_body       *body;
+	struct ost_body *body;
 	struct lov_stripe_md  *lsm;
-	int		    rc;
+	int rc;
 
 	LASSERT(oa);
 	LASSERT(ea);
@@ -548,10 +548,10 @@ int osc_punch_base(struct obd_export *exp, struct obd_info *oinfo,
 		   obd_enqueue_update_f upcall, void *cookie,
 		   struct ptlrpc_request_set *rqset)
 {
-	struct ptlrpc_request   *req;
+	struct ptlrpc_request *req;
 	struct osc_setattr_args *sa;
-	struct ost_body	 *body;
-	int		      rc;
+	struct ost_body *body;
+	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_PUNCH);
 	if (req == NULL)
@@ -577,7 +577,7 @@ int osc_punch_base(struct obd_export *exp, struct obd_info *oinfo,
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_setattr_interpret;
 	CLASSERT (sizeof(*sa) <= sizeof(req->rq_async_args));
 	sa = ptlrpc_req_async_args(req);
-	sa->sa_oa     = oinfo->oi_oa;
+	sa->sa_oa = oinfo->oi_oa;
 	sa->sa_upcall = upcall;
 	sa->sa_cookie = cookie;
 	if (rqset == PTLRPCD_SET)
@@ -616,9 +616,9 @@ int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
 		  struct ptlrpc_request_set *rqset)
 {
 	struct ptlrpc_request *req;
-	struct ost_body       *body;
+	struct ost_body *body;
 	struct osc_fsync_args *fa;
-	int		    rc;
+	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_SYNC);
 	if (req == NULL)
@@ -757,9 +757,9 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 		       struct obd_trans_info *oti, struct obd_export *md_export,
 		       void *capa)
 {
-	struct client_obd     *cli = &exp->exp_obd->u.cli;
+	struct client_obd *cli = &exp->exp_obd->u.cli;
 	struct ptlrpc_request *req;
-	struct ost_body       *body;
+	struct ost_body *body;
 	LIST_HEAD(cancels);
 	int rc, count;
 
@@ -947,7 +947,7 @@ static int osc_shrink_grant(struct client_obd *cli)
 
 int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes)
 {
-	int			rc = 0;
+	int rc = 0;
 	struct ost_body	*body;
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
@@ -1131,8 +1131,8 @@ static int check_write_rcs(struct ptlrpc_request *req,
 			   int requested_nob, int niocount,
 			   u32 page_count, struct brw_page **pga)
 {
-	int     i;
-	__u32   *remote_rcs;
+	int i;
+	__u32 *remote_rcs;
 
 	remote_rcs = req_capsule_server_sized_get(&req->rq_pill, &RMF_RCS,
 						  sizeof(*remote_rcs) *
@@ -1185,12 +1185,12 @@ static u32 osc_checksum_bulk(int nob, u32 pg_count,
 				   struct brw_page **pga, int opc,
 				   cksum_type_t cksum_type)
 {
-	__u32				cksum;
-	int				i = 0;
-	struct cfs_crypto_hash_desc	*hdesc;
-	unsigned int			bufsize;
-	int				err;
-	unsigned char			cfs_alg = cksum_obd2cfs(cksum_type);
+	__u32 cksum;
+	int i = 0;
+	struct cfs_crypto_hash_desc *hdesc;
+	unsigned int bufsize;
+	int err;
+	unsigned char cfs_alg = cksum_obd2cfs(cksum_type);
 
 	LASSERT(pg_count > 0);
 
@@ -1250,14 +1250,14 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 				struct obd_capa *ocapa, int reserve,
 				int resend)
 {
-	struct ptlrpc_request   *req;
+	struct ptlrpc_request *req;
 	struct ptlrpc_bulk_desc *desc;
-	struct ost_body	 *body;
-	struct obd_ioobj	*ioobj;
-	struct niobuf_remote    *niobuf;
+	struct ost_body	*body;
+	struct obd_ioobj *ioobj;
+	struct niobuf_remote *niobuf;
 	int niocount, i, requested_nob, opc, rc;
 	struct osc_brw_async_args *aa;
-	struct req_capsule      *pill;
+	struct req_capsule *pill;
 	struct brw_page *pg_prev;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ))
@@ -1359,8 +1359,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			niobuf->len += pg->count;
 		} else {
 			niobuf->offset = pg->off;
-			niobuf->len    = pg->count;
-			niobuf->flags  = pg->flag;
+			niobuf->len = pg->count;
+			niobuf->flags = pg->flag;
 		}
 		pg_prev = pg;
 	}
@@ -1581,9 +1581,9 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 
 	if (body->oa.o_valid & OBD_MD_FLCKSUM) {
 		static int cksum_counter;
-		__u32      server_cksum = body->oa.o_cksum;
-		char      *via;
-		char      *router;
+		__u32 server_cksum = body->oa.o_cksum;
+		char *via;
+		char *router;
 		cksum_type_t cksum_type;
 
 		cksum_type = cksum_type_unpack(body->oa.o_valid &OBD_MD_FLFLAGS?
@@ -1758,7 +1758,7 @@ static int brw_interpret(const struct lu_env *env,
 	struct osc_brw_async_args *aa = data;
 	struct osc_extent *ext;
 	struct osc_extent *tmp;
-	struct cl_object  *obj = NULL;
+	struct cl_object *obj = NULL;
 	struct client_obd *cli = aa->aa_cli;
 
 	rc = osc_brw_fini_request(req, rc);
@@ -1862,26 +1862,25 @@ static int brw_interpret(const struct lu_env *env,
 int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct list_head *ext_list, int cmd, pdl_policy_t pol)
 {
-	struct ptlrpc_request		*req = NULL;
-	struct osc_extent		*ext;
-	struct brw_page			**pga = NULL;
-	struct osc_brw_async_args	*aa = NULL;
-	struct obdo			*oa = NULL;
-	struct osc_async_page		*oap;
-	struct osc_async_page		*tmp;
-	struct cl_req			*clerq = NULL;
-	enum cl_req_type		crt = (cmd & OBD_BRW_WRITE) ? CRT_WRITE :
-								      CRT_READ;
-	struct ldlm_lock		*lock = NULL;
-	struct cl_req_attr		*crattr = NULL;
-	u64				starting_offset = OBD_OBJECT_EOF;
-	u64				ending_offset = 0;
-	int				mpflag = 0;
-	int				mem_tight = 0;
-	int				page_count = 0;
-	int				i;
-	int				rc;
-	struct ost_body			*body;
+	struct ptlrpc_request *req = NULL;
+	struct osc_extent *ext;
+	struct brw_page **pga = NULL;
+	struct osc_brw_async_args *aa = NULL;
+	struct obdo *oa = NULL;
+	struct osc_async_page *oap;
+	struct osc_async_page *tmp;
+	struct cl_req *clerq = NULL;
+	enum cl_req_type crt = (cmd & OBD_BRW_WRITE) ? CRT_WRITE : CRT_READ;
+	struct ldlm_lock *lock = NULL;
+	struct cl_req_attr *crattr = NULL;
+	u64 starting_offset = OBD_OBJECT_EOF;
+	u64 ending_offset = 0;
+	int mpflag = 0;
+	int mem_tight = 0;
+	int page_count = 0;
+	int i;
+	int rc;
+	struct ost_body *body;
 	LIST_HEAD(rpc_list);
 
 	LASSERT(!list_empty(ext_list));
@@ -2362,12 +2361,12 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 			aa = ptlrpc_req_async_args(req);
 			aa->oa_ei = einfo;
 			aa->oa_exp = exp;
-			aa->oa_flags  = flags;
+			aa->oa_flags = flags;
 			aa->oa_upcall = upcall;
 			aa->oa_cookie = cookie;
-			aa->oa_lvb    = lvb;
-			aa->oa_lockh  = lockh;
-			aa->oa_agl    = !!agl;
+			aa->oa_lvb = lvb;
+			aa->oa_lockh = lockh;
+			aa->oa_agl = !!agl;
 
 			req->rq_interpret_reply =
 				(ptlrpc_interpterer_t)osc_enqueue_interpret;
@@ -2480,10 +2479,10 @@ static int osc_statfs_async(struct obd_export *exp,
 			    struct obd_info *oinfo, __u64 max_age,
 			    struct ptlrpc_request_set *rqset)
 {
-	struct obd_device     *obd = class_exp2obd(exp);
+	struct obd_device *obd = class_exp2obd(exp);
 	struct ptlrpc_request *req;
 	struct osc_async_args *aa;
-	int		    rc;
+	int rc;
 
 	/* We could possibly pass max_age in the request (as an absolute
 	 * timestamp or a "seconds.usec ago") so the target can avoid doing
@@ -2522,10 +2521,10 @@ static int osc_statfs_async(struct obd_export *exp,
 static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
 		      struct obd_statfs *osfs, __u64 max_age, __u32 flags)
 {
-	struct obd_device     *obd = class_exp2obd(exp);
-	struct obd_statfs     *msfs;
+	struct obd_device *obd = class_exp2obd(exp);
+	struct obd_statfs *msfs;
 	struct ptlrpc_request *req;
-	struct obd_import     *imp = NULL;
+	struct obd_import *imp = NULL;
 	int rc;
 
 	/*Since the request might also come from lprocfs, so we need
@@ -2749,9 +2748,9 @@ static int osc_get_info(const struct lu_env *env, struct obd_export *exp,
 		return 0;
 	} else if (KEY_IS(KEY_LAST_ID)) {
 		struct ptlrpc_request *req;
-		u64		*reply;
-		char		  *tmp;
-		int		    rc;
+		u64 *reply;
+		char *tmp;
+		int rc;
 
 		req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 					   &RQF_OST_GET_INFO_LAST_ID);
@@ -2788,14 +2787,14 @@ static int osc_get_info(const struct lu_env *env, struct obd_export *exp,
 	} else if (KEY_IS(KEY_FIEMAP)) {
 		struct ll_fiemap_info_key *fm_key =
 				(struct ll_fiemap_info_key *)key;
-		struct ldlm_res_id	 res_id;
-		ldlm_policy_data_t	 policy;
-		struct lustre_handle	 lockh;
-		ldlm_mode_t		 mode = 0;
-		struct ptlrpc_request	*req;
-		struct ll_user_fiemap	*reply;
-		char			*tmp;
-		int			 rc;
+		struct ldlm_res_id res_id;
+		ldlm_policy_data_t policy;
+		struct lustre_handle lockh;
+		ldlm_mode_t mode = 0;
+		struct ptlrpc_request *req;
+		struct ll_user_fiemap *reply;
+		char *tmp;
+		int rc;
 
 		if (!(fm_key->fiemap.fm_flags & FIEMAP_FLAG_SYNC))
 			goto skip_locking;
@@ -2881,10 +2880,10 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 			      void *val, struct ptlrpc_request_set *set)
 {
 	struct ptlrpc_request *req;
-	struct obd_device     *obd = exp->exp_obd;
-	struct obd_import     *imp = class_exp2cliimp(exp);
-	char		  *tmp;
-	int		    rc;
+	struct obd_device *obd = exp->exp_obd;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	char *tmp;
+	int rc;
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_SHUTDOWN, 10);
 
@@ -3071,8 +3070,8 @@ static int osc_import_event(struct obd_device *obd,
 	}
 	case IMP_EVENT_INVALIDATE: {
 		struct ldlm_namespace *ns = obd->obd_namespace;
-		struct lu_env	 *env;
-		int		    refcheck;
+		struct lu_env *env;
+		int refcheck;
 
 		env = cl_env_get(&refcheck);
 		if (!IS_ERR(env)) {
@@ -3159,9 +3158,9 @@ static int brw_queue_work(const struct lu_env *env, void *data)
 int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
 	struct lprocfs_static_vars lvars = { NULL };
-	struct client_obd	  *cli = &obd->u.cli;
-	void		       *handler;
-	int			rc;
+	struct client_obd *cli = &obd->u.cli;
+	void *handler;
+	int rc;
 
 	rc = ptlrpcd_addref();
 	if (rc)
-- 
1.7.1
