From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:50:05 -0500
Subject: [lustre-devel] [PATCH 17/25] staging/lustre/lov: Fix style vs open
	parenthesis alignment
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-18-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/lov/lov_cl_internal.h    | 87 +++++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  2 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  6 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |  2 +-
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  7 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 35 ++++-----
 drivers/staging/lustre/lustre/lov/lov_object.c     | 40 +++++-----
 drivers/staging/lustre/lustre/lov/lov_offset.c     |  3 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  7 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |  3 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  4 +-
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |  2 +-
 drivers/staging/lustre/lustre/lov/lovsub_page.c    |  2 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      | 16 ++--
 14 files changed, 106 insertions(+), 110 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index b5fc159..7dd3162 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -579,51 +579,49 @@ extern struct kmem_cache *lovsub_req_kmem;
 
 extern struct kmem_cache *lov_lock_link_kmem;
 
-int   lov_object_init(const struct lu_env *env, struct lu_object *obj,
-			   const struct lu_object_conf *conf);
-int   lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
-			   const struct lu_object_conf *conf);
-int   lov_lock_init(const struct lu_env *env, struct cl_object *obj,
-			   struct cl_lock *lock, const struct cl_io *io);
-int   lov_io_init(const struct lu_env *env, struct cl_object *obj,
-			   struct cl_io *io);
-int   lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
-			   struct cl_lock *lock, const struct cl_io *io);
-
-int   lov_lock_init_raid0(const struct lu_env *env, struct cl_object *obj,
-			   struct cl_lock *lock, const struct cl_io *io);
-int   lov_lock_init_empty(const struct lu_env *env, struct cl_object *obj,
-			   struct cl_lock *lock, const struct cl_io *io);
-int   lov_io_init_raid0(const struct lu_env *env, struct cl_object *obj,
-			   struct cl_io *io);
-int   lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
-			   struct cl_io *io);
-int   lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
-			   struct cl_io *io);
-void  lov_lock_unlink(const struct lu_env *env, struct lov_lock_link *link,
-			   struct lovsub_lock *sub);
+int lov_object_init(const struct lu_env *env, struct lu_object *obj,
+		    const struct lu_object_conf *conf);
+int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
+		       const struct lu_object_conf *conf);
+int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
+		  struct cl_lock *lock, const struct cl_io *io);
+int lov_io_init(const struct lu_env *env, struct cl_object *obj,
+		struct cl_io *io);
+int lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
+		     struct cl_lock *lock, const struct cl_io *io);
+
+int lov_lock_init_raid0(const struct lu_env *env, struct cl_object *obj,
+			struct cl_lock *lock, const struct cl_io *io);
+int lov_lock_init_empty(const struct lu_env *env, struct cl_object *obj,
+			struct cl_lock *lock, const struct cl_io *io);
+int lov_io_init_raid0(const struct lu_env *env, struct cl_object *obj,
+		      struct cl_io *io);
+int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
+		      struct cl_io *io);
+int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
+			 struct cl_io *io);
+void lov_lock_unlink(const struct lu_env *env, struct lov_lock_link *link,
+		     struct lovsub_lock *sub);
 
 struct lov_io_sub *lov_sub_get(const struct lu_env *env, struct lov_io *lio,
 			       int stripe);
-void  lov_sub_put(struct lov_io_sub *sub);
-int   lov_sublock_modify(const struct lu_env *env, struct lov_lock *lov,
-			   struct lovsub_lock *sublock,
-			   const struct cl_lock_descr *d, int idx);
-
-int   lov_page_init(const struct lu_env *env, struct cl_object *ob,
-			   struct cl_page *page, struct page *vmpage);
-int   lovsub_page_init(const struct lu_env *env, struct cl_object *ob,
-			   struct cl_page *page, struct page *vmpage);
-
-int   lov_page_init_empty(const struct lu_env *env,
-			   struct cl_object *obj,
-			   struct cl_page *page, struct page *vmpage);
-int   lov_page_init_raid0(const struct lu_env *env,
-			   struct cl_object *obj,
-			   struct cl_page *page, struct page *vmpage);
+void lov_sub_put(struct lov_io_sub *sub);
+int lov_sublock_modify(const struct lu_env *env, struct lov_lock *lov,
+		       struct lovsub_lock *sublock,
+		       const struct cl_lock_descr *d, int idx);
+
+int lov_page_init(const struct lu_env *env, struct cl_object *ob,
+		  struct cl_page *page, struct page *vmpage);
+int lovsub_page_init(const struct lu_env *env, struct cl_object *ob,
+		     struct cl_page *page, struct page *vmpage);
+
+int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
+			struct cl_page *page, struct page *vmpage);
+int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
+			struct cl_page *page, struct page *vmpage);
 struct lu_object *lov_object_alloc(const struct lu_env *env,
-				      const struct lu_object_header *hdr,
-				      struct lu_device *dev);
+				   const struct lu_object_header *hdr,
+				   struct lu_device *dev);
 struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 				      const struct lu_object_header *hdr,
 				      struct lu_device *dev);
@@ -631,9 +629,8 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 struct lov_lock_link *lov_lock_link_find(const struct lu_env *env,
 					 struct lov_lock *lck,
 					 struct lovsub_lock *sub);
-struct lov_io_sub    *lov_page_subio(const struct lu_env *env,
-					 struct lov_io *lio,
-					 const struct cl_page_slice *slice);
+struct lov_io_sub *lov_page_subio(const struct lu_env *env, struct lov_io *lio,
+				  const struct cl_page_slice *slice);
 
 #define lov_foreach_target(lov, var)		    \
 	for (var = 0; var < lov_targets_nr(lov); ++var)
@@ -798,7 +795,7 @@ static inline struct cl_page *lov_sub_page(const struct cl_page_slice *slice)
 }
 
 static inline struct lov_io *cl2lov_io(const struct lu_env *env,
-				const struct cl_io_slice *ios)
+				       const struct cl_io_slice *ios)
 {
 	struct lov_io *lio;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index c27b884..cdf4e8e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -141,7 +141,7 @@ static void lsm_unpackmd_common(struct lov_stripe_md *lsm,
 
 static void
 lsm_stripe_by_index_plain(struct lov_stripe_md *lsm, int *stripeno,
-			   u64 *lov_off, u64 *swidth)
+			  u64 *lov_off, u64 *swidth)
 {
 	if (swidth)
 		*swidth = (u64)lsm->lsm_stripe_size * lsm->lsm_stripe_count;
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 725ebf9..590f932 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -138,12 +138,10 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 		      struct ost_lvb *lvb, __u64 *kms_place);
 
 /* lov_offset.c */
-u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size,
-			 int stripeno);
+u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size, int stripeno);
 int lov_stripe_offset(struct lov_stripe_md *lsm, u64 lov_off,
 		      int stripeno, u64 *u64);
-u64 lov_size_to_stripe(struct lov_stripe_md *lsm, u64 file_size,
-			   int stripeno);
+u64 lov_size_to_stripe(struct lov_stripe_md *lsm, u64 file_size, int stripeno);
 int lov_stripe_intersects(struct lov_stripe_md *lsm, int stripeno,
 			  u64 start, u64 end,
 			  u64 *obd_start, u64 *obd_end);
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 50954ce..4296aac 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -947,7 +947,7 @@ int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
 }
 
 int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
-			struct cl_io *io)
+			 struct cl_io *io)
 {
 	struct lov_object *lov = cl2lov(obj);
 	struct lov_io *lio = lov_env_io(env);
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index e0a6438..455dad2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -683,7 +683,7 @@ static int lov_lock_unuse(const struct lu_env *env,
 }
 
 static void lov_lock_cancel(const struct lu_env *env,
-			   const struct cl_lock_slice *slice)
+			    const struct cl_lock_slice *slice)
 {
 	struct lov_lock	*lck     = cl2lov_lock(slice);
 	struct cl_lock_closure *closure = lov_closure_get(env, slice->cls_lock);
@@ -1125,7 +1125,8 @@ static void lov_empty_lock_fini(const struct lu_env *env,
 }
 
 static int lov_empty_lock_print(const struct lu_env *env, void *cookie,
-			lu_printer_t p, const struct cl_lock_slice *slice)
+				lu_printer_t p,
+				const struct cl_lock_slice *slice)
 {
 	(*p)(env, cookie, "empty\n");
 	return 0;
@@ -1138,7 +1139,7 @@ static const struct cl_lock_operations lov_empty_lock_ops = {
 };
 
 int lov_lock_init_empty(const struct lu_env *env, struct cl_object *obj,
-		struct cl_lock *lock, const struct cl_io *io)
+			struct cl_lock *lock, const struct cl_io *io)
 {
 	struct lov_lock *lck;
 	int result = -ENOMEM;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 7ba670a..a466b32 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -265,7 +265,7 @@ static int lov_disconnect_obd(struct obd_device *obd, struct lov_tgt_desc *tgt)
 
 	osc_obd = class_exp2obd(tgt->ltd_exp);
 	CDEBUG(D_CONFIG, "%s: disconnecting target %s\n",
-		obd->obd_name, osc_obd ? osc_obd->obd_name : "NULL");
+	       obd->obd_name, osc_obd ? osc_obd->obd_name : "NULL");
 
 	if (tgt->ltd_active) {
 		tgt->ltd_active = 0;
@@ -594,7 +594,7 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 	mutex_unlock(&lov->lov_lock);
 
 	CDEBUG(D_CONFIG, "idx=%d ltd_gen=%d ld_tgt_count=%d\n",
-		index, tgt->ltd_gen, lov->desc.ld_tgt_count);
+	       index, tgt->ltd_gen, lov->desc.ld_tgt_count);
 
 	rc = obd_notify(obd, tgt_obd, OBD_NOTIFY_CREATE, &index);
 
@@ -620,9 +620,9 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 
 	if (lov->lov_cache) {
 		rc = obd_set_info_async(NULL, tgt->ltd_exp,
-				sizeof(KEY_CACHE_SET), KEY_CACHE_SET,
-				sizeof(struct cl_client_cache), lov->lov_cache,
-				NULL);
+					sizeof(KEY_CACHE_SET), KEY_CACHE_SET,
+					sizeof(struct cl_client_cache),
+					lov->lov_cache, NULL);
 		if (rc < 0)
 			goto out;
 	}
@@ -1133,7 +1133,7 @@ static int lov_getattr_interpret(struct ptlrpc_request_set *rqset,
 }
 
 static int lov_getattr_async(struct obd_export *exp, struct obd_info *oinfo,
-			      struct ptlrpc_request_set *rqset)
+			     struct ptlrpc_request_set *rqset)
 {
 	struct lov_request_set *lovset;
 	struct lov_obd *lov;
@@ -1414,8 +1414,8 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 		/* copy UUID */
 		if (copy_to_user(data->ioc_pbuf2, obd2cli_tgt(osc_obd),
-				     min((int) data->ioc_plen2,
-					 (int) sizeof(struct obd_uuid))))
+				 min((int)data->ioc_plen2,
+				     (int)sizeof(struct obd_uuid))))
 			return -EFAULT;
 
 		memcpy(&flags, data->ioc_inlbuf1, sizeof(__u32));
@@ -1428,8 +1428,8 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		if (rc)
 			return rc;
 		if (copy_to_user(data->ioc_pbuf1, &stat_buf,
-				     min((int) data->ioc_plen1,
-					 (int) sizeof(stat_buf))))
+				 min((int)data->ioc_plen1,
+				     (int)sizeof(stat_buf))))
 			return -EFAULT;
 		break;
 	}
@@ -1762,7 +1762,8 @@ static int lov_fiemap(struct lov_obd *lov, __u32 keylen, void *key,
 		fm_end = fm_key->oa.o_size;
 
 	last_stripe = fiemap_calc_last_stripe(lsm, fm_start, fm_end,
-					    actual_start_stripe, &stripe_count);
+					      actual_start_stripe,
+					      &stripe_count);
 
 	fm_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, fm_start,
 						  fm_end, &start_stripe);
@@ -2130,12 +2131,12 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 
 			/* Only want a specific OSC */
 			if (mgi->uuid && !obd_uuid_equals(mgi->uuid,
-						&tgt->ltd_uuid))
+							  &tgt->ltd_uuid))
 				continue;
 
 			err = obd_set_info_async(env, tgt->ltd_exp,
-					 keylen, key, sizeof(int),
-					 &mgi->group, set);
+						 keylen, key, sizeof(int),
+						 &mgi->group, set);
 		} else if (next_id) {
 			err = obd_set_info_async(env, tgt->ltd_exp,
 					 keylen, key, vallen,
@@ -2147,7 +2148,7 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 				continue;
 
 			err = obd_set_info_async(env, tgt->ltd_exp,
-					 keylen, key, vallen, val, set);
+						 keylen, key, vallen, val, set);
 		}
 
 		if (!rc)
@@ -2337,8 +2338,8 @@ static int __init lov_init(void)
 		return rc;
 
 	lov_oinfo_slab = kmem_cache_create("lov_oinfo",
-					      sizeof(struct lov_oinfo),
-					      0, SLAB_HWCACHE_ALIGN, NULL);
+					   sizeof(struct lov_oinfo),
+					   0, SLAB_HWCACHE_ALIGN, NULL);
 	if (!lov_oinfo_slab) {
 		lu_kmem_fini(lov_caches);
 		return -ENOMEM;
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 4101696..9cea9dc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -59,7 +59,7 @@ struct lov_layout_operations {
 			const struct cl_object_conf *conf,
 			union lov_layout_state *state);
 	int (*llo_delete)(const struct lu_env *env, struct lov_object *lov,
-			   union lov_layout_state *state);
+			  union lov_layout_state *state);
 	void (*llo_fini)(const struct lu_env *env, struct lov_object *lov,
 			 union lov_layout_state *state);
 	void (*llo_install)(const struct lu_env *env, struct lov_object *lov,
@@ -67,7 +67,7 @@ struct lov_layout_operations {
 	int  (*llo_print)(const struct lu_env *env, void *cookie,
 			  lu_printer_t p, const struct lu_object *o);
 	int  (*llo_page_init)(const struct lu_env *env, struct cl_object *obj,
-				struct cl_page *page, struct page *vmpage);
+			      struct cl_page *page, struct page *vmpage);
 	int  (*llo_lock_init)(const struct lu_env *env,
 			      struct cl_object *obj, struct cl_lock *lock,
 			      const struct cl_io *io);
@@ -266,9 +266,9 @@ out:
 }
 
 static int lov_init_released(const struct lu_env *env,
-			struct lov_device *dev, struct lov_object *lov,
-			const struct cl_object_conf *conf,
-			union  lov_layout_state *state)
+			     struct lov_device *dev, struct lov_object *lov,
+			     const struct cl_object_conf *conf,
+			     union  lov_layout_state *state)
 {
 	struct lov_stripe_md *lsm = conf->u.coc_md->lsm;
 
@@ -389,7 +389,7 @@ static void lov_fini_raid0(const struct lu_env *env, struct lov_object *lov,
 }
 
 static void lov_fini_released(const struct lu_env *env, struct lov_object *lov,
-				union lov_layout_state *state)
+			      union lov_layout_state *state)
 {
 	dump_lsm(D_INODE, lov->lo_lsm);
 	lov_free_memmd(&lov->lo_lsm);
@@ -411,9 +411,9 @@ static int lov_print_raid0(const struct lu_env *env, void *cookie,
 	int			 i;
 
 	(*p)(env, cookie, "stripes: %d, %s, lsm{%p 0x%08X %d %u %u}:\n",
-		r0->lo_nr, lov->lo_layout_invalid ? "invalid" : "valid", lsm,
-		lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
-		lsm->lsm_stripe_count, lsm->lsm_layout_gen);
+	     r0->lo_nr, lov->lo_layout_invalid ? "invalid" : "valid", lsm,
+	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
+	     lsm->lsm_stripe_count, lsm->lsm_layout_gen);
 	for (i = 0; i < r0->lo_nr; ++i) {
 		struct lu_object *sub;
 
@@ -428,16 +428,16 @@ static int lov_print_raid0(const struct lu_env *env, void *cookie,
 }
 
 static int lov_print_released(const struct lu_env *env, void *cookie,
-				lu_printer_t p, const struct lu_object *o)
+			      lu_printer_t p, const struct lu_object *o)
 {
 	struct lov_object	*lov = lu2lov(o);
 	struct lov_stripe_md	*lsm = lov->lo_lsm;
 
 	(*p)(env, cookie,
-		"released: %s, lsm{%p 0x%08X %d %u %u}:\n",
-		lov->lo_layout_invalid ? "invalid" : "valid", lsm,
-		lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
-		lsm->lsm_stripe_count, lsm->lsm_layout_gen);
+	     "released: %s, lsm{%p 0x%08X %d %u %u}:\n",
+	     lov->lo_layout_invalid ? "invalid" : "valid", lsm,
+	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
+	     lsm->lsm_stripe_count, lsm->lsm_layout_gen);
 	return 0;
 }
 
@@ -646,9 +646,9 @@ static int lov_layout_wait(const struct lu_env *env, struct lov_object *lov)
 	struct l_wait_info lwi = { 0 };
 
 	while (atomic_read(&lov->lo_active_ios) > 0) {
-		CDEBUG(D_INODE, "file:"DFID" wait for active IO, now: %d.\n",
-			PFID(lu_object_fid(lov2lu(lov))),
-			atomic_read(&lov->lo_active_ios));
+		CDEBUG(D_INODE, "file:" DFID " wait for active IO, now: %d.\n",
+		       PFID(lu_object_fid(lov2lu(lov))),
+		       atomic_read(&lov->lo_active_ios));
 
 		l_wait_event(lov->lo_waitq,
 			     atomic_read(&lov->lo_active_ios) == 0, &lwi);
@@ -825,7 +825,7 @@ static int lov_object_print(const struct lu_env *env, void *cookie,
 }
 
 int lov_page_init(const struct lu_env *env, struct cl_object *obj,
-		struct cl_page *page, struct page *vmpage)
+		  struct cl_page *page, struct page *vmpage)
 {
 	return LOV_2DISPATCH_NOLOCK(cl2lov(obj),
 				    llo_page_init, env, obj, page, vmpage);
@@ -924,8 +924,8 @@ static struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
 	if (lov->lo_lsm) {
 		lsm = lsm_addref(lov->lo_lsm);
 		CDEBUG(D_INODE, "lsm %p addref %d/%d by %p.\n",
-			lsm, atomic_read(&lsm->lsm_refc),
-			lov->lo_layout_invalid, current);
+		       lsm, atomic_read(&lsm->lsm_refc),
+		       lov->lo_layout_invalid, current);
 	}
 	lov_conf_thaw(lov);
 	return lsm;
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index 1ceea3d..ae83eb0 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -43,8 +43,7 @@
 #include "lov_internal.h"
 
 /* compute object size given "stripeno" and the ost size */
-u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size,
-			 int stripeno)
+u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size, int stripeno)
 {
 	unsigned long ssize = lsm->lsm_stripe_size;
 	unsigned long stripe_size;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 9235d7d..3925633 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -134,7 +134,7 @@ int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 	if ((lmm_magic != LOV_MAGIC_V1) &&
 	    (lmm_magic != LOV_MAGIC_V3)) {
 		CERROR("bad mem LOV MAGIC: 0x%08X != 0x%08X nor 0x%08X\n",
-			lmm_magic, LOV_MAGIC_V1, LOV_MAGIC_V3);
+		       lmm_magic, LOV_MAGIC_V1, LOV_MAGIC_V3);
 		return -EINVAL;
 
 	}
@@ -145,7 +145,7 @@ int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 		 */
 		if (!lmmp) {
 			stripe_count = lov_get_stripecnt(lov, lmm_magic,
-							lsm->lsm_stripe_count);
+							 lsm->lsm_stripe_count);
 			lsm->lsm_stripe_count = stripe_count;
 		} else if (!lsm_is_released(lsm)) {
 			stripe_count = lsm->lsm_stripe_count;
@@ -267,7 +267,8 @@ static int lov_verify_lmm(void *lmm, int lmm_bytes, __u16 *stripe_count)
 		return -EINVAL;
 	}
 	rc = lsm_op_find(le32_to_cpu(*(__u32 *)lmm))->lsm_lmm_verify(lmm,
-				     lmm_bytes, stripe_count);
+								     lmm_bytes,
+								  stripe_count);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 17ae450..fdcaf80 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -172,8 +172,7 @@ int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
 	offset = cl_offset(obj, page->cp_index);
 	stripe = lov_stripe_number(loo->lo_lsm, offset);
 	LASSERT(stripe < r0->lo_nr);
-	rc = lov_stripe_offset(loo->lo_lsm, offset, stripe,
-				   &suboff);
+	rc = lov_stripe_offset(loo->lo_lsm, offset, stripe, &suboff);
 	LASSERT(rc == 0);
 
 	lpg->lps_invalid = 1;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 8608b09..be95dd7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -444,7 +444,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 		lov_pool_putref(new_pool);
 	}
 	CDEBUG(D_INFO, "pool %p - proc %p\n",
-		new_pool, new_pool->pool_debugfs_entry);
+	       new_pool, new_pool->pool_debugfs_entry);
 
 	spin_lock(&obd->obd_dev_lock);
 	list_add_tail(&new_pool->pool_list, &lov->lov_pool_list);
@@ -638,7 +638,7 @@ struct pool_desc *lov_find_pool(struct lov_obd *lov, char *poolname)
 			      poolname);
 		if (pool && (pool_tgt_count(pool) == 0)) {
 			CWARN("Request for an empty pool ("LOV_POOLNAMEF")\n",
-			       poolname);
+			      poolname);
 			/* pool is ignored, so we remove ref on it */
 			lov_pool_putref(pool);
 			pool = NULL;
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
index 0046812..b041739 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
@@ -404,7 +404,7 @@ static void lovsub_lock_delete(const struct lu_env *env,
 
 		restart = 0;
 		list_for_each_entry_safe(scan, temp,
-					     &sub->lss_parents, lll_list) {
+					 &sub->lss_parents, lll_list) {
 			lov     = scan->lll_super;
 			subdata = &lov->lls_sub[scan->lll_idx];
 			lovsub_parent_lock(env, lov);
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_page.c b/drivers/staging/lustre/lustre/lov/lovsub_page.c
index 3f00ce9..2d94553 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_page.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_page.c
@@ -60,7 +60,7 @@ static const struct cl_page_operations lovsub_page_ops = {
 };
 
 int lovsub_page_init(const struct lu_env *env, struct cl_object *obj,
-			struct cl_page *page, struct page *unused)
+		     struct cl_page *page, struct page *unused)
 {
 	struct lovsub_page *lsb = cl_object_page_slice(obj, page);
 
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index bb81d04..0dcb6b6 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -53,8 +53,8 @@ static int lov_stripesize_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t lov_stripesize_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+					const char __user *buffer,
+					size_t count, loff_t *off)
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	struct lov_desc *desc;
@@ -86,8 +86,8 @@ static int lov_stripeoffset_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t lov_stripeoffset_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+					  const char __user *buffer,
+					  size_t count, loff_t *off)
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	struct lov_desc *desc;
@@ -118,8 +118,8 @@ static int lov_stripetype_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t lov_stripetype_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+					const char __user *buffer,
+					size_t count, loff_t *off)
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	struct lov_desc *desc;
@@ -150,8 +150,8 @@ static int lov_stripecount_seq_show(struct seq_file *m, void *v)
 }
 
 static ssize_t lov_stripecount_seq_write(struct file *file,
-				const char __user *buffer,
-				size_t count, loff_t *off)
+					 const char __user *buffer,
+					 size_t count, loff_t *off)
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	struct lov_desc *desc;
-- 
2.1.0
