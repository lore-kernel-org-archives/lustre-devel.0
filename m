From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:21 -0500
Subject: [lustre-devel] [PATCH 17/26] obdecho: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The obdecho code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/obdecho/echo_client.c    | 280 ++++++++++-----------
 .../staging/lustre/lustre/obdecho/echo_internal.h  |   4 +-
 2 files changed, 142 insertions(+), 142 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 4f9dbc4..1ebd985 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -52,41 +52,41 @@
  */
 
 struct echo_device {
-	struct cl_device	ed_cl;
-	struct echo_client_obd *ed_ec;
+	struct cl_device		ed_cl;
+	struct echo_client_obd	       *ed_ec;
 
-	struct cl_site	  ed_site_myself;
-	struct lu_site		*ed_site;
-	struct lu_device       *ed_next;
+	struct cl_site			ed_site_myself;
+	struct lu_site		       *ed_site;
+	struct lu_device	       *ed_next;
 };
 
 struct echo_object {
-	struct cl_object	eo_cl;
-	struct cl_object_header eo_hdr;
-
-	struct echo_device     *eo_dev;
-	struct list_head	      eo_obj_chain;
-	struct lov_oinfo       *eo_oinfo;
-	atomic_t	    eo_npages;
-	int		     eo_deleted;
+	struct cl_object		eo_cl;
+	struct cl_object_header		eo_hdr;
+
+	struct echo_device	       *eo_dev;
+	struct list_head		eo_obj_chain;
+	struct lov_oinfo	       *eo_oinfo;
+	atomic_t			eo_npages;
+	int				eo_deleted;
 };
 
 struct echo_object_conf {
-	struct cl_object_conf  eoc_cl;
-	struct lov_oinfo      **eoc_oinfo;
+	struct cl_object_conf		eoc_cl;
+	struct lov_oinfo	      **eoc_oinfo;
 };
 
 struct echo_page {
-	struct cl_page_slice   ep_cl;
-	unsigned long		ep_lock;
+	struct cl_page_slice		ep_cl;
+	unsigned long			ep_lock;
 };
 
 struct echo_lock {
-	struct cl_lock_slice   el_cl;
-	struct list_head	     el_chain;
-	struct echo_object    *el_object;
-	u64		  el_cookie;
-	atomic_t	   el_refcount;
+	struct cl_lock_slice		el_cl;
+	struct list_head		el_chain;
+	struct echo_object	       *el_object;
+	u64				el_cookie;
+	atomic_t			el_refcount;
 };
 
 static int echo_client_setup(const struct lu_env *env,
@@ -159,19 +159,19 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 			      struct page **pages, int npages, int async);
 
 struct echo_thread_info {
-	struct echo_object_conf eti_conf;
-	struct lustre_md	eti_md;
-
-	struct cl_2queue	eti_queue;
-	struct cl_io	    eti_io;
-	struct cl_lock          eti_lock;
-	struct lu_fid	   eti_fid;
-	struct lu_fid		eti_fid2;
+	struct echo_object_conf		eti_conf;
+	struct lustre_md		eti_md;
+
+	struct cl_2queue		eti_queue;
+	struct cl_io			eti_io;
+	struct cl_lock			eti_lock;
+	struct lu_fid			eti_fid;
+	struct lu_fid			eti_fid2;
 };
 
 /* No session used right now */
 struct echo_session_info {
-	unsigned long dummy;
+	unsigned long			dummy;
 };
 
 static struct kmem_cache *echo_lock_kmem;
@@ -288,20 +288,20 @@ static int echo_page_print(const struct lu_env *env,
 }
 
 static const struct cl_page_operations echo_page_ops = {
-	.cpo_own	   = echo_page_own,
-	.cpo_disown	= echo_page_disown,
-	.cpo_discard       = echo_page_discard,
-	.cpo_fini	  = echo_page_fini,
-	.cpo_print	 = echo_page_print,
-	.cpo_is_vmlocked   = echo_page_is_vmlocked,
+	.cpo_own		= echo_page_own,
+	.cpo_disown		= echo_page_disown,
+	.cpo_discard		= echo_page_discard,
+	.cpo_fini		= echo_page_fini,
+	.cpo_print		= echo_page_print,
+	.cpo_is_vmlocked	= echo_page_is_vmlocked,
 	.io = {
 		[CRT_READ] = {
 			.cpo_prep	= echo_page_prep,
-			.cpo_completion  = echo_page_completion,
+			.cpo_completion	= echo_page_completion,
 		},
 		[CRT_WRITE] = {
 			.cpo_prep	= echo_page_prep,
-			.cpo_completion  = echo_page_completion,
+			.cpo_completion	= echo_page_completion,
 		}
 	}
 };
@@ -324,7 +324,7 @@ static void echo_lock_fini(const struct lu_env *env,
 }
 
 static const struct cl_lock_operations echo_lock_ops = {
-	.clo_fini      = echo_lock_fini,
+	.clo_fini		= echo_lock_fini,
 };
 
 /** @} echo_lock */
@@ -383,10 +383,10 @@ static int echo_conf_set(const struct lu_env *env, struct cl_object *obj,
 }
 
 static const struct cl_object_operations echo_cl_obj_ops = {
-	.coo_page_init = echo_page_init,
-	.coo_lock_init = echo_lock_init,
-	.coo_io_init   = echo_io_init,
-	.coo_conf_set  = echo_conf_set
+	.coo_page_init		= echo_page_init,
+	.coo_lock_init		= echo_lock_init,
+	.coo_io_init		= echo_io_init,
+	.coo_conf_set		= echo_conf_set
 };
 
 /** @} echo_cl_ops */
@@ -400,15 +400,15 @@ static int echo_conf_set(const struct lu_env *env, struct cl_object *obj,
 static int echo_object_init(const struct lu_env *env, struct lu_object *obj,
 			    const struct lu_object_conf *conf)
 {
-	struct echo_device *ed	 = cl2echo_dev(lu2cl_dev(obj->lo_dev));
-	struct echo_client_obd *ec     = ed->ed_ec;
+	struct echo_device *ed = cl2echo_dev(lu2cl_dev(obj->lo_dev));
+	struct echo_client_obd *ec = ed->ed_ec;
 	struct echo_object *eco	= cl2echo_obj(lu2cl(obj));
 	const struct cl_object_conf *cconf;
 	struct echo_object_conf *econf;
 
 	if (ed->ed_next) {
-		struct lu_object  *below;
-		struct lu_device  *under;
+		struct lu_object *below;
+		struct lu_device *under;
 
 		under = ed->ed_next;
 		below = under->ld_ops->ldo_object_alloc(env, obj->lo_header,
@@ -442,7 +442,7 @@ static int echo_object_init(const struct lu_env *env, struct lu_object *obj,
 
 static void echo_object_free(const struct lu_env *env, struct lu_object *obj)
 {
-	struct echo_object *eco    = cl2echo_obj(lu2cl(obj));
+	struct echo_object *eco = cl2echo_obj(lu2cl(obj));
 	struct echo_client_obd *ec = eco->eo_dev->ed_ec;
 
 	LASSERT(atomic_read(&eco->eo_npages) == 0);
@@ -467,12 +467,12 @@ static int echo_object_print(const struct lu_env *env, void *cookie,
 }
 
 static const struct lu_object_operations echo_lu_obj_ops = {
-	.loo_object_init      = echo_object_init,
-	.loo_object_delete    = NULL,
-	.loo_object_release   = NULL,
-	.loo_object_free      = echo_object_free,
-	.loo_object_print     = echo_object_print,
-	.loo_object_invariant = NULL
+	.loo_object_init	= echo_object_init,
+	.loo_object_delete	= NULL,
+	.loo_object_release	= NULL,
+	.loo_object_free	= echo_object_free,
+	.loo_object_print	= echo_object_print,
+	.loo_object_invariant	= NULL
 };
 
 /** @} echo_lu_ops */
@@ -504,13 +504,13 @@ static struct lu_object *echo_object_alloc(const struct lu_env *env,
 		lu_object_add_top(&hdr->coh_lu, obj);
 
 		eco->eo_cl.co_ops = &echo_cl_obj_ops;
-		obj->lo_ops       = &echo_lu_obj_ops;
+		obj->lo_ops = &echo_lu_obj_ops;
 	}
 	return obj;
 }
 
 static const struct lu_device_operations echo_device_lu_ops = {
-	.ldo_object_alloc   = echo_object_alloc,
+	.ldo_object_alloc	= echo_object_alloc,
 };
 
 /** @} echo_lu_dev_ops */
@@ -571,9 +571,9 @@ static void echo_thread_key_fini(const struct lu_context *ctx,
 }
 
 static struct lu_context_key echo_thread_key = {
-	.lct_tags = LCT_CL_THREAD,
-	.lct_init = echo_thread_key_init,
-	.lct_fini = echo_thread_key_fini,
+	.lct_tags		= LCT_CL_THREAD,
+	.lct_init		= echo_thread_key_init,
+	.lct_fini		= echo_thread_key_fini,
 };
 
 static void *echo_session_key_init(const struct lu_context *ctx,
@@ -596,9 +596,9 @@ static void echo_session_key_fini(const struct lu_context *ctx,
 }
 
 static struct lu_context_key echo_session_key = {
-	.lct_tags = LCT_SESSION,
-	.lct_init = echo_session_key_init,
-	.lct_fini = echo_session_key_fini,
+	.lct_tags		= LCT_SESSION,
+	.lct_init		= echo_session_key_init,
+	.lct_fini		= echo_session_key_fini,
 };
 
 LU_TYPE_INIT_FINI(echo, &echo_thread_key, &echo_session_key);
@@ -607,11 +607,11 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 					   struct lu_device_type *t,
 					   struct lustre_cfg *cfg)
 {
-	struct lu_device   *next;
+	struct lu_device *next;
 	struct echo_device *ed;
-	struct cl_device   *cd;
-	struct obd_device  *obd = NULL; /* to keep compiler happy */
-	struct obd_device  *tgt;
+	struct cl_device *cd;
+	struct obd_device *obd = NULL; /* to keep compiler happy */
+	struct obd_device *tgt;
 	const char *tgt_type_name;
 	int rc, err;
 
@@ -729,10 +729,10 @@ static void echo_lock_release(const struct lu_env *env,
 static struct lu_device *echo_device_free(const struct lu_env *env,
 					  struct lu_device *d)
 {
-	struct echo_device     *ed   = cl2echo_dev(lu2cl_dev(d));
-	struct echo_client_obd *ec   = ed->ed_ec;
-	struct echo_object     *eco;
-	struct lu_device       *next = ed->ed_next;
+	struct echo_device *ed = cl2echo_dev(lu2cl_dev(d));
+	struct echo_client_obd *ec = ed->ed_ec;
+	struct echo_object *eco;
+	struct lu_device *next = ed->ed_next;
 
 	CDEBUG(D_INFO, "echo device:%p is going to be freed, next = %p\n",
 	       ed, next);
@@ -786,23 +786,23 @@ static struct lu_device *echo_device_free(const struct lu_env *env,
 }
 
 static const struct lu_device_type_operations echo_device_type_ops = {
-	.ldto_init = echo_type_init,
-	.ldto_fini = echo_type_fini,
+	.ldto_init		= echo_type_init,
+	.ldto_fini		= echo_type_fini,
 
-	.ldto_start = echo_type_start,
-	.ldto_stop  = echo_type_stop,
+	.ldto_start		= echo_type_start,
+	.ldto_stop		= echo_type_stop,
 
-	.ldto_device_alloc = echo_device_alloc,
-	.ldto_device_free  = echo_device_free,
-	.ldto_device_init  = echo_device_init,
-	.ldto_device_fini  = echo_device_fini
+	.ldto_device_alloc	= echo_device_alloc,
+	.ldto_device_free	= echo_device_free,
+	.ldto_device_init	= echo_device_init,
+	.ldto_device_fini	= echo_device_fini
 };
 
 static struct lu_device_type echo_device_type = {
-	.ldt_tags     = LU_DEVICE_CL,
-	.ldt_name     = LUSTRE_ECHO_CLIENT_NAME,
-	.ldt_ops      = &echo_device_type_ops,
-	.ldt_ctx_tags = LCT_CL_THREAD,
+	.ldt_tags		= LU_DEVICE_CL,
+	.ldt_name		= LUSTRE_ECHO_CLIENT_NAME,
+	.ldt_ops		= &echo_device_type_ops,
+	.ldt_ctx_tags		= LCT_CL_THREAD,
 };
 
 /** @} echo_init */
@@ -823,7 +823,7 @@ static struct lu_device *echo_device_free(const struct lu_env *env,
 	struct echo_object_conf *conf;
 	struct lov_oinfo *oinfo = NULL;
 	struct echo_object *eco;
-	struct cl_object   *obj;
+	struct cl_object *obj;
 	struct lu_fid *fid;
 	u16 refcheck;
 	int rc;
@@ -858,7 +858,7 @@ static struct lu_device *echo_device_free(const struct lu_env *env,
 	 */
 	conf->eoc_oinfo = &oinfo;
 
-	fid  = &info->eti_fid;
+	fid = &info->eti_fid;
 	rc = ostid_to_fid(fid, (struct ost_id *)oi, 0);
 	if (rc != 0) {
 		eco = ERR_PTR(rc);
@@ -928,10 +928,10 @@ static int __cl_echo_enqueue(struct lu_env *env, struct echo_object *eco,
 
 	memset(lck, 0, sizeof(*lck));
 	descr = &lck->cll_descr;
-	descr->cld_obj   = obj;
+	descr->cld_obj = obj;
 	descr->cld_start = cl_index(obj, start);
-	descr->cld_end   = cl_index(obj, end);
-	descr->cld_mode  = mode == LCK_PW ? CLM_WRITE : CLM_READ;
+	descr->cld_end = cl_index(obj, end);
+	descr->cld_mode = mode == LCK_PW ? CLM_WRITE : CLM_READ;
 	descr->cld_enq_flags = enqflags;
 	io->ci_obj = obj;
 
@@ -957,7 +957,7 @@ static int __cl_echo_cancel(struct lu_env *env, struct echo_device *ed,
 			    u64 cookie)
 {
 	struct echo_client_obd *ec = ed->ed_ec;
-	struct echo_lock       *ecl = NULL;
+	struct echo_lock *ecl = NULL;
 	int found = 0, still_used = 0;
 
 	spin_lock(&ec->ec_lock);
@@ -997,14 +997,14 @@ static void echo_commit_callback(const struct lu_env *env, struct cl_io *io,
 static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 			      struct page **pages, int npages, int async)
 {
-	struct lu_env	   *env;
+	struct lu_env *env;
 	struct echo_thread_info *info;
-	struct cl_object	*obj = echo_obj2cl(eco);
-	struct echo_device      *ed  = eco->eo_dev;
-	struct cl_2queue	*queue;
-	struct cl_io	    *io;
-	struct cl_page	  *clp;
-	struct lustre_handle    lh = { 0 };
+	struct cl_object *obj = echo_obj2cl(eco);
+	struct echo_device *ed  = eco->eo_dev;
+	struct cl_2queue *queue;
+	struct cl_io *io;
+	struct cl_page *clp;
+	struct lustre_handle lh = { 0 };
 	size_t page_size = cl_page_size(obj);
 	u16 refcheck;
 	int rc;
@@ -1016,9 +1016,9 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	info    = echo_env_info(env);
-	io      = &info->eti_io;
-	queue   = &info->eti_queue;
+	info = echo_env_info(env);
+	io = &info->eti_io;
+	queue = &info->eti_queue;
 
 	cl_2queue_init(queue);
 
@@ -1097,10 +1097,10 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 			      struct obdo *oa)
 {
-	struct echo_object     *eco;
+	struct echo_object *eco;
 	struct echo_client_obd *ec = ed->ed_ec;
-	int		     rc;
-	int		     created = 0;
+	int rc;
+	int created = 0;
 
 	if (!(oa->o_valid & OBD_MD_FLID) ||
 	    !(oa->o_valid & OBD_MD_FLGROUP) ||
@@ -1133,7 +1133,7 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 
 	CDEBUG(D_INFO, "oa oid " DOSTID "\n", POSTID(&oa->o_oi));
 
- failed:
+failed:
 	if (created && rc)
 		obd_destroy(env, ec->ec_exp, oa);
 	if (rc)
@@ -1144,8 +1144,8 @@ static int echo_create_object(const struct lu_env *env, struct echo_device *ed,
 static int echo_get_object(struct echo_object **ecop, struct echo_device *ed,
 			   struct obdo *oa)
 {
-	struct echo_object     *eco;
-	int		     rc;
+	struct echo_object *eco;
+	int rc;
 
 	if (!(oa->o_valid & OBD_MD_FLID) || !(oa->o_valid & OBD_MD_FLGROUP) ||
 	    !ostid_id(&oa->o_oi)) {
@@ -1176,10 +1176,10 @@ static void echo_put_object(struct echo_object *eco)
 echo_client_page_debug_setup(struct page *page, int rw, u64 id,
 			     u64 offset, u64 count)
 {
-	char    *addr;
-	u64	 stripe_off;
-	u64	 stripe_id;
-	int      delta;
+	char *addr;
+	u64 stripe_off;
+	u64 stripe_id;
+	int delta;
 
 	/* no partial pages on the client */
 	LASSERT(count == PAGE_SIZE);
@@ -1204,12 +1204,12 @@ static void echo_put_object(struct echo_object *eco)
 static int echo_client_page_debug_check(struct page *page, u64 id,
 					u64 offset, u64 count)
 {
-	u64	stripe_off;
-	u64	stripe_id;
-	char   *addr;
-	int     delta;
-	int     rc;
-	int     rc2;
+	u64 stripe_off;
+	u64 stripe_id;
+	char *addr;
+	int delta;
+	int rc;
+	int rc2;
 
 	/* no partial pages on the client */
 	LASSERT(count == PAGE_SIZE);
@@ -1237,16 +1237,16 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 			    struct echo_object *eco, u64 offset,
 			    u64 count, int async)
 {
-	u32	       npages;
+	u32 npages;
 	struct brw_page	*pga;
 	struct brw_page	*pgp;
-	struct page	    **pages;
-	u64		 off;
-	int		     i;
-	int		     rc;
-	int		     verify;
-	gfp_t		     gfp_mask;
-	int		     brw_flags = 0;
+	struct page **pages;
+	u64 off;
+	int i;
+	int rc;
+	int verify;
+	gfp_t gfp_mask;
+	int brw_flags = 0;
 
 	verify = (ostid_id(&oa->o_oi) != ECHO_PERSISTENT_OBJID &&
 		  (oa->o_valid & OBD_MD_FLFLAGS) != 0 &&
@@ -1301,7 +1301,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 	LASSERT(ed->ed_next);
 	rc = cl_echo_object_brw(eco, rw, offset, pages, npages, async);
 
- out:
+out:
 	if (rc != 0 || rw != OBD_BRW_READ)
 		verify = 0;
 
@@ -1474,16 +1474,16 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 echo_client_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		      void *karg, void __user *uarg)
 {
-	struct obd_device      *obd = exp->exp_obd;
-	struct echo_device     *ed = obd2echo_dev(obd);
+	struct obd_device *obd = exp->exp_obd;
+	struct echo_device *ed = obd2echo_dev(obd);
 	struct echo_client_obd *ec = ed->ed_ec;
-	struct echo_object     *eco;
-	struct obd_ioctl_data  *data = karg;
-	struct lu_env	  *env;
-	struct obdo	    *oa;
-	struct lu_fid	   fid;
-	int		     rw = OBD_BRW_READ;
-	int		     rc = 0;
+	struct echo_object *eco;
+	struct obd_ioctl_data *data = karg;
+	struct lu_env *env;
+	struct obdo *oa;
+	struct lu_fid fid;
+	int rw = OBD_BRW_READ;
+	int rc = 0;
 
 	oa = &data->ioc_obdo1;
 	if (!(oa->o_valid & OBD_MD_FLGROUP)) {
@@ -1652,7 +1652,7 @@ static int echo_client_connect(const struct lu_env *env,
 			       struct obd_device *src, struct obd_uuid *cluuid,
 			       struct obd_connect_data *data, void *localdata)
 {
-	int		rc;
+	int rc;
 	struct lustre_handle conn = { 0 };
 
 	rc = class_connect(&conn, src, cluuid);
@@ -1664,7 +1664,7 @@ static int echo_client_connect(const struct lu_env *env,
 
 static int echo_client_disconnect(struct obd_export *exp)
 {
-	int		     rc;
+	int rc;
 
 	if (!exp) {
 		rc = -EINVAL;
@@ -1673,15 +1673,15 @@ static int echo_client_disconnect(struct obd_export *exp)
 
 	rc = class_disconnect(exp);
 	goto out;
- out:
+out:
 	return rc;
 }
 
 static struct obd_ops echo_client_obd_ops = {
-	.owner          = THIS_MODULE,
-	.iocontrol      = echo_client_iocontrol,
-	.connect        = echo_client_connect,
-	.disconnect     = echo_client_disconnect
+	.owner			= THIS_MODULE,
+	.iocontrol		= echo_client_iocontrol,
+	.connect		= echo_client_connect,
+	.disconnect		= echo_client_disconnect
 };
 
 static int echo_client_init(void)
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_internal.h b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
index ac7a209..8094a94 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_internal.h
+++ b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
@@ -33,8 +33,8 @@
 #define _ECHO_INTERNAL_H
 
 /* The persistent object (i.e. actually stores stuff!) */
-#define ECHO_PERSISTENT_OBJID    1ULL
-#define ECHO_PERSISTENT_SIZE     ((u64)(1 << 20))
+#define ECHO_PERSISTENT_OBJID	1ULL
+#define ECHO_PERSISTENT_SIZE	((u64)(1 << 20))
 
 /* block size to use for data verification */
 #define OBD_ECHO_BLOCK_SIZE	(4 << 10)
-- 
1.8.3.1
