From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:22 -0500
Subject: [lustre-devel] [PATCH 18/26] osc: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The osc code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  8 +--
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 61 +++++++++++-----------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  4 +-
 drivers/staging/lustre/lustre/osc/osc_dev.c        | 42 +++++++--------
 drivers/staging/lustre/lustre/osc/osc_io.c         | 32 ++++++------
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 30 +++++------
 drivers/staging/lustre/lustre/osc/osc_object.c     | 28 +++++-----
 drivers/staging/lustre/lustre/osc/osc_page.c       |  8 +--
 drivers/staging/lustre/lustre/osc/osc_request.c    | 10 ++--
 9 files changed, 111 insertions(+), 112 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 39a2a26..299a69f 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -501,7 +501,7 @@ static ssize_t contention_seconds_show(struct kobject *kobj,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct osc_device *od  = obd2osc_dev(obd);
+	struct osc_device *od = obd2osc_dev(obd);
 
 	return sprintf(buf, "%u\n", od->od_contention_time);
 }
@@ -513,7 +513,7 @@ static ssize_t contention_seconds_store(struct kobject *kobj,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct osc_device *od  = obd2osc_dev(obd);
+	struct osc_device *od = obd2osc_dev(obd);
 	unsigned int val;
 	int rc;
 
@@ -533,7 +533,7 @@ static ssize_t lockless_truncate_show(struct kobject *kobj,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct osc_device *od  = obd2osc_dev(obd);
+	struct osc_device *od = obd2osc_dev(obd);
 
 	return sprintf(buf, "%u\n", od->od_lockless_truncate);
 }
@@ -545,7 +545,7 @@ static ssize_t lockless_truncate_store(struct kobject *kobj,
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-	struct osc_device *od  = obd2osc_dev(obd);
+	struct osc_device *od = obd2osc_dev(obd);
 	bool val;
 	int rc;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index bef422c..673e139 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1304,7 +1304,7 @@ static int osc_make_ready(const struct lu_env *env, struct osc_async_page *oap,
 			  int cmd)
 {
 	struct osc_page *opg = oap2osc_page(oap);
-	struct cl_page  *page = oap2cl_page(oap);
+	struct cl_page *page = oap2cl_page(oap);
 	int result;
 
 	LASSERT(cmd == OBD_BRW_WRITE); /* no cached reads */
@@ -1323,7 +1323,6 @@ static int osc_refresh_count(const struct lu_env *env,
 	pgoff_t index = osc_index(oap2osc(oap));
 	struct cl_object *obj;
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
-
 	int result;
 	loff_t kms;
 
@@ -1395,21 +1394,21 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	return 0;
 }
 
-#define OSC_DUMP_GRANT(lvl, cli, fmt, args...) do {			      \
-	struct client_obd *__tmp = (cli);				      \
+#define OSC_DUMP_GRANT(lvl, cli, fmt, args...) do {			\
+	struct client_obd *__tmp = (cli);				\
 	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %ld/%lu "	\
 	       "dropped: %ld avail: %ld, dirty_grant: %ld, "		\
 	       "reserved: %ld, flight: %d } lru {in list: %ld, "	\
 	       "left: %ld, waiters: %d }" fmt "\n",			\
-	       cli_name(__tmp),						      \
-	       __tmp->cl_dirty_pages, __tmp->cl_dirty_max_pages,	      \
-	       atomic_long_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
-	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		      \
+	       cli_name(__tmp),						\
+	       __tmp->cl_dirty_pages, __tmp->cl_dirty_max_pages,	\
+	       atomic_long_read(&obd_dirty_pages), obd_max_dirty_pages,	\
+	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		\
 	       __tmp->cl_dirty_grant,					\
-	       __tmp->cl_reserved_grant, __tmp->cl_w_in_flight,		      \
-	       atomic_long_read(&__tmp->cl_lru_in_list),		      \
-	       atomic_long_read(&__tmp->cl_lru_busy),			      \
-	       atomic_read(&__tmp->cl_lru_shrinkers), ##args);		      \
+	       __tmp->cl_reserved_grant, __tmp->cl_w_in_flight,		\
+	       atomic_long_read(&__tmp->cl_lru_in_list),		\
+	       atomic_long_read(&__tmp->cl_lru_busy),			\
+	       atomic_read(&__tmp->cl_lru_shrinkers), ##args);		\
 } while (0)
 
 /* caller must hold loi_list_lock */
@@ -1471,7 +1470,7 @@ static void __osc_unreserve_grant(struct client_obd *cli,
 	cli->cl_reserved_grant -= reserved;
 	if (unused > reserved) {
 		cli->cl_avail_grant += reserved;
-		cli->cl_lost_grant  += unused - reserved;
+		cli->cl_lost_grant += unused - reserved;
 		cli->cl_dirty_grant -= unused - reserved;
 	} else {
 		cli->cl_avail_grant += unused;
@@ -1984,11 +1983,11 @@ static unsigned int get_write_extents(struct osc_object *obj,
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_extent *ext;
 	struct extent_rpc_data data = {
-		.erd_rpc_list = rpclist,
-		.erd_page_count = 0,
-		.erd_max_pages = cli->cl_max_pages_per_rpc,
-		.erd_max_chunks = osc_max_write_chunks(cli),
-		.erd_max_extents = 256,
+		.erd_rpc_list		= rpclist,
+		.erd_page_count		= 0,
+		.erd_max_pages		= cli->cl_max_pages_per_rpc,
+		.erd_max_chunks		= osc_max_write_chunks(cli),
+		.erd_max_extents	= 256,
 	};
 
 	assert_osc_object_is_locked(obj);
@@ -2121,11 +2120,11 @@ static unsigned int get_write_extents(struct osc_object *obj,
 	struct osc_extent *next;
 	LIST_HEAD(rpclist);
 	struct extent_rpc_data data = {
-		.erd_rpc_list = &rpclist,
-		.erd_page_count = 0,
-		.erd_max_pages = cli->cl_max_pages_per_rpc,
-		.erd_max_chunks = UINT_MAX,
-		.erd_max_extents = UINT_MAX,
+		.erd_rpc_list		= &rpclist,
+		.erd_page_count		= 0,
+		.erd_max_pages		= cli->cl_max_pages_per_rpc,
+		.erd_max_chunks		= UINT_MAX,
+		.erd_max_extents	= UINT_MAX,
 	};
 	int rc = 0;
 
@@ -2545,7 +2544,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 	struct osc_extent *ext = NULL;
 	struct osc_object *obj = cl2osc(ops->ops_cl.cpl_obj);
 	struct cl_page *cp = ops->ops_cl.cpl_page;
-	pgoff_t            index = osc_index(ops);
+	pgoff_t index = osc_index(ops);
 	struct osc_async_page *oap = &ops->ops_oap;
 	bool unplug = false;
 	int rc = 0;
@@ -3033,13 +3032,13 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 			  osc_page_gang_cbt cb, void *cbdata)
 {
 	struct osc_page *ops;
-	void            **pvec;
-	pgoff_t         idx;
-	unsigned int    nr;
-	unsigned int    i;
-	unsigned int    j;
-	bool            res = true;
-	bool            tree_lock = true;
+	void **pvec;
+	pgoff_t idx;
+	unsigned int nr;
+	unsigned int i;
+	unsigned int j;
+	bool res = true;
+	bool tree_lock = true;
 
 	idx = start;
 	pvec = osc_env_info(env)->oti_pvec;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index c89c894..8bede94 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -407,9 +407,9 @@ void osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 
 void osc_object_set_contended(struct osc_object *obj);
 void osc_object_clear_contended(struct osc_object *obj);
-int  osc_object_is_contended(struct osc_object *obj);
+int osc_object_is_contended(struct osc_object *obj);
 
-int  osc_lock_is_lockless(const struct osc_lock *olck);
+int osc_lock_is_lockless(const struct osc_lock *olck);
 
 /****************************************************************************
  *
diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
index c767a3c..997fa35 100644
--- a/drivers/staging/lustre/lustre/osc/osc_dev.c
+++ b/drivers/staging/lustre/lustre/osc/osc_dev.c
@@ -127,9 +127,9 @@ static void osc_key_fini(const struct lu_context *ctx,
 }
 
 struct lu_context_key osc_key = {
-	.lct_tags = LCT_CL_THREAD,
-	.lct_init = osc_key_init,
-	.lct_fini = osc_key_fini
+	.lct_tags		= LCT_CL_THREAD,
+	.lct_init		= osc_key_init,
+	.lct_fini		= osc_key_fini
 };
 
 static void *osc_session_init(const struct lu_context *ctx,
@@ -152,9 +152,9 @@ static void osc_session_fini(const struct lu_context *ctx,
 }
 
 struct lu_context_key osc_session_key = {
-	.lct_tags = LCT_SESSION,
-	.lct_init = osc_session_init,
-	.lct_fini = osc_session_fini
+	.lct_tags		= LCT_SESSION,
+	.lct_init		= osc_session_init,
+	.lct_fini		= osc_session_fini
 };
 
 /* type constructor/destructor: osc_type_{init,fini,start,stop}(). */
@@ -167,9 +167,9 @@ static int osc_cl_process_config(const struct lu_env *env,
 }
 
 static const struct lu_device_operations osc_lu_ops = {
-	.ldo_object_alloc      = osc_object_alloc,
-	.ldo_process_config    = osc_cl_process_config,
-	.ldo_recovery_complete = NULL
+	.ldo_object_alloc	= osc_object_alloc,
+	.ldo_process_config	= osc_cl_process_config,
+	.ldo_recovery_complete	= NULL
 };
 
 static int osc_device_init(const struct lu_env *env, struct lu_device *d,
@@ -224,24 +224,24 @@ static struct lu_device *osc_device_alloc(const struct lu_env *env,
 }
 
 static const struct lu_device_type_operations osc_device_type_ops = {
-	.ldto_init = osc_type_init,
-	.ldto_fini = osc_type_fini,
+	.ldto_init		= osc_type_init,
+	.ldto_fini		= osc_type_fini,
 
-	.ldto_start = osc_type_start,
-	.ldto_stop  = osc_type_stop,
+	.ldto_start		= osc_type_start,
+	.ldto_stop		= osc_type_stop,
 
-	.ldto_device_alloc = osc_device_alloc,
-	.ldto_device_free  = osc_device_free,
+	.ldto_device_alloc	= osc_device_alloc,
+	.ldto_device_free	= osc_device_free,
 
-	.ldto_device_init = osc_device_init,
-	.ldto_device_fini = osc_device_fini
+	.ldto_device_init	= osc_device_init,
+	.ldto_device_fini	= osc_device_fini
 };
 
 struct lu_device_type osc_device_type = {
-	.ldt_tags = LU_DEVICE_CL,
-	.ldt_name = LUSTRE_OSC_NAME,
-	.ldt_ops = &osc_device_type_ops,
-	.ldt_ctx_tags = LCT_CL_THREAD
+	.ldt_tags		= LU_DEVICE_CL,
+	.ldt_name		= LUSTRE_OSC_NAME,
+	.ldt_ops		= &osc_device_type_ops,
+	.ldt_ctx_tags		= LCT_CL_THREAD
 };
 
 /** @} osc */
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index cf5b3cc..0b9ed01 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -935,21 +935,21 @@ static void osc_io_end(const struct lu_env *env,
 		[CIT_READ] = {
 			.cio_iter_init	= osc_io_iter_init,
 			.cio_iter_fini	= osc_io_iter_fini,
-			.cio_start  = osc_io_read_start,
-			.cio_fini   = osc_io_fini
+			.cio_start	= osc_io_read_start,
+			.cio_fini	= osc_io_fini
 		},
 		[CIT_WRITE] = {
 			.cio_iter_init	= osc_io_write_iter_init,
 			.cio_iter_fini	= osc_io_write_iter_fini,
-			.cio_start  = osc_io_write_start,
-			.cio_end    = osc_io_end,
-			.cio_fini   = osc_io_fini
+			.cio_start	= osc_io_write_start,
+			.cio_end	= osc_io_end,
+			.cio_fini	= osc_io_fini
 		},
 		[CIT_SETATTR] = {
 			.cio_iter_init	= osc_io_iter_init,
 			.cio_iter_fini	= osc_io_iter_fini,
-			.cio_start  = osc_io_setattr_start,
-			.cio_end    = osc_io_setattr_end
+			.cio_start	= osc_io_setattr_start,
+			.cio_end	= osc_io_setattr_end
 		},
 		[CIT_DATA_VERSION] = {
 			.cio_start	= osc_io_data_version_start,
@@ -958,14 +958,14 @@ static void osc_io_end(const struct lu_env *env,
 		[CIT_FAULT] = {
 			.cio_iter_init	= osc_io_iter_init,
 			.cio_iter_fini	= osc_io_iter_fini,
-			.cio_start  = osc_io_fault_start,
-			.cio_end    = osc_io_end,
-			.cio_fini   = osc_io_fini
+			.cio_start	= osc_io_fault_start,
+			.cio_end	= osc_io_end,
+			.cio_fini	= osc_io_fini
 		},
 		[CIT_FSYNC] = {
-			.cio_start  = osc_io_fsync_start,
-			.cio_end    = osc_io_fsync_end,
-			.cio_fini   = osc_io_fini
+			.cio_start	= osc_io_fsync_start,
+			.cio_end	= osc_io_fsync_end,
+			.cio_fini	= osc_io_fini
 		},
 		[CIT_LADVISE] = {
 			.cio_start	= osc_io_ladvise_start,
@@ -973,12 +973,12 @@ static void osc_io_end(const struct lu_env *env,
 			.cio_fini	= osc_io_fini
 		},
 		[CIT_MISC] = {
-			.cio_fini   = osc_io_fini
+			.cio_fini	= osc_io_fini
 		}
 	},
 	.cio_read_ahead			= osc_io_read_ahead,
-	.cio_submit                 = osc_io_submit,
-	.cio_commit_async           = osc_io_commit_async
+	.cio_submit			= osc_io_submit,
+	.cio_commit_async		= osc_io_commit_async
 };
 
 /*****************************************************************************
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 06d813e..5a1717c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -676,11 +676,11 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
  */
 unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 {
-	struct lu_env           *env;
-	struct osc_object	*obj;
-	struct osc_lock		*oscl;
-	unsigned long            weight;
-	bool			 found = false;
+	struct lu_env *env;
+	struct osc_object *obj;
+	struct osc_lock	*oscl;
+	unsigned long weight;
+	bool found = false;
 	u16 refcheck;
 
 	might_sleep();
@@ -739,9 +739,9 @@ static void osc_lock_build_einfo(const struct lu_env *env,
 				 struct ldlm_enqueue_info *einfo)
 {
 	einfo->ei_type = LDLM_EXTENT;
-	einfo->ei_mode   = osc_cl_lock2ldlm(lock->cll_descr.cld_mode);
+	einfo->ei_mode = osc_cl_lock2ldlm(lock->cll_descr.cld_mode);
 	einfo->ei_cb_bl = osc_ldlm_blocking_ast;
-	einfo->ei_cb_cp  = ldlm_completion_ast;
+	einfo->ei_cb_cp = ldlm_completion_ast;
 	einfo->ei_cb_gl = osc_ldlm_glimpse_ast;
 	einfo->ei_cbdata = osc; /* value to be put into ->l_ast_data */
 }
@@ -814,9 +814,9 @@ static bool osc_lock_compatible(const struct osc_lock *qing,
 	if (qed->ols_state < OLS_GRANTED)
 		return true;
 
-	if (qed_descr->cld_mode  >= qing_descr->cld_mode &&
+	if (qed_descr->cld_mode >= qing_descr->cld_mode &&
 	    qed_descr->cld_start <= qing_descr->cld_start &&
-	    qed_descr->cld_end   >= qing_descr->cld_end)
+	    qed_descr->cld_end >= qing_descr->cld_end)
 		return true;
 
 	return false;
@@ -865,7 +865,7 @@ static int osc_lock_enqueue_wait(const struct lu_env *env,
 
 		descr = &tmp_oscl->ols_cl.cls_lock->cll_descr;
 		if (descr->cld_start > need->cld_end ||
-		    descr->cld_end   < need->cld_start)
+		    descr->cld_end < need->cld_start)
 			continue;
 
 		/* We're not supposed to give up group lock */
@@ -1053,7 +1053,7 @@ static void osc_lock_detach(const struct lu_env *env, struct osc_lock *olck)
 static void osc_lock_cancel(const struct lu_env *env,
 			    const struct cl_lock_slice *slice)
 {
-	struct osc_object *obj  = cl2osc(slice->cls_obj);
+	struct osc_object *obj = cl2osc(slice->cls_obj);
 	struct osc_lock *oscl = cl2osc_lock(slice);
 
 	LINVRNT(osc_lock_invariant(oscl));
@@ -1078,10 +1078,10 @@ static int osc_lock_print(const struct lu_env *env, void *cookie,
 }
 
 static const struct cl_lock_operations osc_lock_ops = {
-	.clo_fini    = osc_lock_fini,
-	.clo_enqueue = osc_lock_enqueue,
-	.clo_cancel  = osc_lock_cancel,
-	.clo_print   = osc_lock_print,
+	.clo_fini	= osc_lock_fini,
+	.clo_enqueue	= osc_lock_enqueue,
+	.clo_cancel	= osc_lock_cancel,
+	.clo_print	= osc_lock_print,
 };
 
 static void osc_lock_lockless_cancel(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 1097380..98a0b6c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -198,8 +198,8 @@ static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
 
 static int osc_object_prune(const struct lu_env *env, struct cl_object *obj)
 {
-	struct osc_object       *osc = cl2osc(obj);
-	struct ldlm_res_id      *resname = &osc_env_info(env)->oti_resname;
+	struct osc_object *osc = cl2osc(obj);
+	struct ldlm_res_id *resname = &osc_env_info(env)->oti_resname;
 
 	/* DLM locks don't hold a reference of osc_object so we have to
 	 * clear it before the object is being destroyed.
@@ -413,23 +413,23 @@ static void osc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 }
 
 static const struct cl_object_operations osc_ops = {
-	.coo_page_init = osc_page_init,
-	.coo_lock_init = osc_lock_init,
-	.coo_io_init   = osc_io_init,
-	.coo_attr_get  = osc_attr_get,
-	.coo_attr_update = osc_attr_update,
-	.coo_glimpse   = osc_object_glimpse,
-	.coo_prune	 = osc_object_prune,
+	.coo_page_init		= osc_page_init,
+	.coo_lock_init		= osc_lock_init,
+	.coo_io_init		= osc_io_init,
+	.coo_attr_get		= osc_attr_get,
+	.coo_attr_update	= osc_attr_update,
+	.coo_glimpse		= osc_object_glimpse,
+	.coo_prune		= osc_object_prune,
 	.coo_fiemap		= osc_object_fiemap,
 	.coo_req_attr_set	= osc_req_attr_set
 };
 
 static const struct lu_object_operations osc_lu_obj_ops = {
-	.loo_object_init      = osc_object_init,
-	.loo_object_release   = NULL,
-	.loo_object_free      = osc_object_free,
-	.loo_object_print     = osc_object_print,
-	.loo_object_invariant = NULL
+	.loo_object_init	= osc_object_init,
+	.loo_object_release	= NULL,
+	.loo_object_free	= osc_object_free,
+	.loo_object_print	= osc_object_print,
+	.loo_object_invariant	= NULL
 };
 
 struct lu_object *osc_object_alloc(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index e0187fa..71f5485 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -227,10 +227,10 @@ static int osc_page_flush(const struct lu_env *env,
 }
 
 static const struct cl_page_operations osc_page_ops = {
-	.cpo_print	 = osc_page_print,
+	.cpo_print	= osc_page_print,
 	.cpo_delete	= osc_page_delete,
-	.cpo_clip	   = osc_page_clip,
-	.cpo_flush	  = osc_page_flush
+	.cpo_clip	= osc_page_clip,
+	.cpo_flush	= osc_page_flush
 };
 
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
@@ -931,7 +931,7 @@ void osc_dec_unstable_pages(struct ptlrpc_request *req)
  */
 void osc_inc_unstable_pages(struct ptlrpc_request *req)
 {
-	struct client_obd *cli  = &req->rq_import->imp_obd->u.cli;
+	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
 	long page_count = desc->bd_iov_count;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index e92c8ac..86f9de6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -162,7 +162,7 @@ static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 	oa->o_blksize = cli_brw_size(exp->exp_obd);
 	oa->o_valid |= OBD_MD_FLBLKSZ;
 
- out:
+out:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1322,7 +1322,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 
 	return 0;
 
- out:
+out:
 	ptlrpc_req_finished(req);
 	return rc;
 }
@@ -1753,7 +1753,7 @@ static int brw_interpret(const struct lu_env *env,
 
 	if (rc == 0) {
 		struct obdo *oa = aa->aa_oa;
-		struct cl_attr *attr  = &osc_env_info(env)->oti_attr;
+		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 		unsigned long valid = 0;
 		struct cl_object *obj;
 		struct osc_async_page *last;
@@ -2260,7 +2260,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 			lustre_handle_copy(&aa->oa_lockh, &lockh);
 			aa->oa_upcall = upcall;
 			aa->oa_cookie = cookie;
-			aa->oa_agl    = !!agl;
+			aa->oa_agl = !!agl;
 			if (!agl) {
 				aa->oa_flags = flags;
 				aa->oa_lvb = lvb;
@@ -2474,7 +2474,7 @@ static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
 
 	*osfs = *msfs;
 
- out:
+out:
 	ptlrpc_req_finished(req);
 	return rc;
 }
-- 
1.8.3.1
