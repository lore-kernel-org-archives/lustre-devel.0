From: NeilBrown <neilb@suse.com>
Date: Thu, 29 Mar 2018 15:26:48 +1100
Subject: [lustre-devel] [PATCH 08/17] staging: lustre: add
 container_of_safe()
In-Reply-To: <152229732768.27689.4800156943561963977.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
Message-ID: <152229760847.27689.4969508646445147289.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Luster has a container_of0() function which is similar to
container_of() but passes an IS_ERR_OR_NULL() pointer through
unchanged.
This could be generally useful: bcache at last has a similar function.

Naming is hard, but the precedent set by hlist_entry_safe() suggests
a _safe suffix might be most consistent.

So add container_of_safe() to kernel.h, and replace all occurrences of
container_of0() with one of
  - list_first_entry, list_next_entry, when that is a better fit,
  - container_of(), when the pointer is used as a validpointer in
    surrounding code,
  - container_of_safe() when there is no obviously better alternative.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   11 -----------
 drivers/staging/lustre/lustre/include/cl_object.h  |   10 +++++-----
 drivers/staging/lustre/lustre/include/lu_object.h  |    6 +++---
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    8 ++++----
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    2 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   18 +++++++++---------
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    8 ++++----
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   10 +++++-----
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |    2 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |    2 +-
 include/linux/kernel.h                             |   16 ++++++++++++++++
 15 files changed, 53 insertions(+), 48 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 392793582956..3b751c436b3d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -99,17 +99,6 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
 int libcfs_ioctl(unsigned long cmd, void __user *arg);
 
-/* container_of depends on "likely" which is defined in libcfs_private.h */
-static inline void *__container_of(void *ptr, unsigned long shift)
-{
-	if (IS_ERR_OR_NULL(ptr))
-		return ptr;
-	return (char *)ptr - shift;
-}
-
-#define container_of0(ptr, type, member) \
-	((type *)__container_of((void *)(ptr), offsetof(type, member)))
-
 #define _LIBCFS_H
 
 extern struct miscdevice libcfs_dev;
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 341a145c3331..6f7b991be809 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1941,7 +1941,7 @@ static inline int lu_device_is_cl(const struct lu_device *d)
 static inline struct cl_device *lu2cl_dev(const struct lu_device *d)
 {
 	LASSERT(!d || IS_ERR(d) || lu_device_is_cl(d));
-	return container_of0(d, struct cl_device, cd_lu_dev);
+	return container_of_safe(d, struct cl_device, cd_lu_dev);
 }
 
 static inline struct lu_device *cl2lu_dev(struct cl_device *d)
@@ -1952,13 +1952,13 @@ static inline struct lu_device *cl2lu_dev(struct cl_device *d)
 static inline struct cl_object *lu2cl(const struct lu_object *o)
 {
 	LASSERT(!o || IS_ERR(o) || lu_device_is_cl(o->lo_dev));
-	return container_of0(o, struct cl_object, co_lu);
+	return container_of_safe(o, struct cl_object, co_lu);
 }
 
 static inline const struct cl_object_conf *
 lu2cl_conf(const struct lu_object_conf *conf)
 {
-	return container_of0(conf, struct cl_object_conf, coc_lu);
+	return container_of_safe(conf, struct cl_object_conf, coc_lu);
 }
 
 static inline struct cl_object *cl_object_next(const struct cl_object *obj)
@@ -1969,12 +1969,12 @@ static inline struct cl_object *cl_object_next(const struct cl_object *obj)
 static inline struct cl_device *cl_object_device(const struct cl_object *o)
 {
 	LASSERT(!o || IS_ERR(o) || lu_device_is_cl(o->co_lu.lo_dev));
-	return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
+	return container_of_safe(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
 }
 
 static inline struct cl_object_header *luh2coh(const struct lu_object_header *h)
 {
-	return container_of0(h, struct cl_object_header, coh_lu);
+	return container_of_safe(h, struct cl_object_header, coh_lu);
 }
 
 static inline struct cl_site *cl_object_site(const struct cl_object *obj)
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 35c7b582f36d..c3b0ed518819 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -745,15 +745,15 @@ struct lu_object *lu_object_find_slice(const struct lu_env *env,
 static inline struct lu_object *lu_object_top(struct lu_object_header *h)
 {
 	LASSERT(!list_empty(&h->loh_layers));
-	return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
+	return list_first_entry(&h->loh_layers, struct lu_object, lo_linkage);
 }
 
 /**
  * Next sub-object in the layering
  */
-static inline struct lu_object *lu_object_next(const struct lu_object *o)
+static inline const struct lu_object *lu_object_next(const struct lu_object *o)
 {
-	return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
+	return list_next_entry(o, lo_linkage);
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index a6a1d80c711a..14172688d55f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -223,7 +223,7 @@ static int ll_nfs_get_name_filldir(struct dir_context *ctx, const char *name,
 	/* It is hack to access lde_fid for comparison with lgd_fid.
 	 * So the input 'name' must be part of the 'lu_dirent'.
 	 */
-	struct lu_dirent *lde = container_of0(name, struct lu_dirent, lde_name);
+	struct lu_dirent *lde = container_of((void*)name, struct lu_dirent, lde_name);
 	struct ll_getname_data *lgd =
 		container_of(ctx, struct ll_getname_data, ctx);
 	struct lu_fid fid;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 02ea5161d635..7d3abb43584a 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -263,22 +263,22 @@ static inline struct lu_device *vvp2lu_dev(struct vvp_device *vdv)
 
 static inline struct vvp_device *lu2vvp_dev(const struct lu_device *d)
 {
-	return container_of0(d, struct vvp_device, vdv_cl.cd_lu_dev);
+	return container_of_safe(d, struct vvp_device, vdv_cl.cd_lu_dev);
 }
 
 static inline struct vvp_device *cl2vvp_dev(const struct cl_device *d)
 {
-	return container_of0(d, struct vvp_device, vdv_cl);
+	return container_of_safe(d, struct vvp_device, vdv_cl);
 }
 
 static inline struct vvp_object *cl2vvp(const struct cl_object *obj)
 {
-	return container_of0(obj, struct vvp_object, vob_cl);
+	return container_of_safe(obj, struct vvp_object, vob_cl);
 }
 
 static inline struct vvp_object *lu2vvp(const struct lu_object *obj)
 {
-	return container_of0(obj, struct vvp_object, vob_cl.co_lu);
+	return container_of_safe(obj, struct vvp_object, vob_cl.co_lu);
 }
 
 static inline struct inode *vvp_object_inode(const struct cl_object *obj)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index c27c3c32188d..68a99170c424 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -60,7 +60,7 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 
 static inline struct obd_device *lmv2obd_dev(struct lmv_obd *lmv)
 {
-	return container_of0(lmv, struct obd_device, u.lmv);
+	return container_of_safe(lmv, struct obd_device, u.lmv);
 }
 
 static inline struct lmv_tgt_desc *
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 1185eceaf497..2e9c75ebdda5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -496,7 +496,7 @@ static inline struct lu_device *lov2lu_dev(struct lov_device *lov)
 static inline struct lov_device *lu2lov_dev(const struct lu_device *d)
 {
 	LINVRNT(d->ld_type == &lov_device_type);
-	return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
+	return container_of(d, struct lov_device, ld_cl.cd_lu_dev);
 }
 
 static inline struct cl_device *lovsub2cl_dev(struct lovsub_device *lovsub)
@@ -512,13 +512,13 @@ static inline struct lu_device *lovsub2lu_dev(struct lovsub_device *lovsub)
 static inline struct lovsub_device *lu2lovsub_dev(const struct lu_device *d)
 {
 	LINVRNT(d->ld_type == &lovsub_device_type);
-	return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
+	return container_of(d, struct lovsub_device, acid_cl.cd_lu_dev);
 }
 
 static inline struct lovsub_device *cl2lovsub_dev(const struct cl_device *d)
 {
 	LINVRNT(d->cd_lu_dev.ld_type == &lovsub_device_type);
-	return container_of0(d, struct lovsub_device, acid_cl);
+	return container_of(d, struct lovsub_device, acid_cl);
 }
 
 static inline struct lu_object *lov2lu(struct lov_object *lov)
@@ -534,13 +534,13 @@ static inline struct cl_object *lov2cl(struct lov_object *lov)
 static inline struct lov_object *lu2lov(const struct lu_object *obj)
 {
 	LINVRNT(lov_is_object(obj));
-	return container_of0(obj, struct lov_object, lo_cl.co_lu);
+	return container_of(obj, struct lov_object, lo_cl.co_lu);
 }
 
 static inline struct lov_object *cl2lov(const struct cl_object *obj)
 {
 	LINVRNT(lov_is_object(&obj->co_lu));
-	return container_of0(obj, struct lov_object, lo_cl);
+	return container_of(obj, struct lov_object, lo_cl);
 }
 
 static inline struct lu_object *lovsub2lu(struct lovsub_object *los)
@@ -556,13 +556,13 @@ static inline struct cl_object *lovsub2cl(struct lovsub_object *los)
 static inline struct lovsub_object *cl2lovsub(const struct cl_object *obj)
 {
 	LINVRNT(lovsub_is_object(&obj->co_lu));
-	return container_of0(obj, struct lovsub_object, lso_cl);
+	return container_of(obj, struct lovsub_object, lso_cl);
 }
 
 static inline struct lovsub_object *lu2lovsub(const struct lu_object *obj)
 {
 	LINVRNT(lovsub_is_object(obj));
-	return container_of0(obj, struct lovsub_object, lso_cl.co_lu);
+	return container_of(obj, struct lovsub_object, lso_cl.co_lu);
 }
 
 static inline struct lovsub_lock *
@@ -590,14 +590,14 @@ static inline struct lov_lock *cl2lov_lock(const struct cl_lock_slice *slice)
 static inline struct lov_page *cl2lov_page(const struct cl_page_slice *slice)
 {
 	LINVRNT(lov_is_object(&slice->cpl_obj->co_lu));
-	return container_of0(slice, struct lov_page, lps_cl);
+	return container_of(slice, struct lov_page, lps_cl);
 }
 
 static inline struct lovsub_page *
 cl2lovsub_page(const struct cl_page_slice *slice)
 {
 	LINVRNT(lovsub_is_object(&slice->cpl_obj->co_lu));
-	return container_of0(slice, struct lovsub_page, lsb_cl);
+	return container_of(slice, struct lovsub_page, lsb_cl);
 }
 
 static inline struct lov_io *cl2lov_io(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index a56d71c2dda2..27f60dd7ab9a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -277,7 +277,7 @@ static inline bool lov_oinfo_is_dummy(const struct lov_oinfo *loi)
 
 static inline struct obd_device *lov2obd(const struct lov_obd *lov)
 {
-	return container_of0(lov, struct obd_device, u.lov);
+	return container_of_safe(lov, struct obd_device, u.lov);
 }
 
 #endif
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 8ddf23b82a2c..6db5d95d4b36 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -319,7 +319,7 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 		 * lives as long as possible and ->loo_object_free() methods
 		 * can look at its contents.
 		 */
-		o = container_of0(splice.prev, struct lu_object, lo_linkage);
+		o = container_of(splice.prev, struct lu_object, lo_linkage);
 		list_del_init(&o->lo_linkage);
 		o->lo_ops->loo_object_free(env, o);
 	}
@@ -404,8 +404,8 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 		 * races due to the reasons described in lu_object_put().
 		 */
 		while (!list_empty(&dispose)) {
-			h = container_of0(dispose.next,
-					  struct lu_object_header, loh_lru);
+			h = container_of(dispose.next,
+					 struct lu_object_header, loh_lru);
 			list_del_init(&h->loh_lru);
 			lu_object_free(env, lu_object_top(h));
 			lprocfs_counter_incr(s->ls_stats, LU_SS_LRU_PURGED);
@@ -579,7 +579,7 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 		return ERR_PTR(-ENOENT);
 	}
 
-	h = container_of0(hnode, struct lu_object_header, loh_hash);
+	h = container_of(hnode, struct lu_object_header, loh_hash);
 	if (likely(!lu_object_is_dying(h))) {
 		cfs_hash_get(s->ls_obj_hash, hnode);
 		lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 99a76db51ae0..767067b61109 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -99,7 +99,7 @@ static int echo_client_cleanup(struct obd_device *obddev);
  */
 static inline struct echo_device *cl2echo_dev(const struct cl_device *dev)
 {
-	return container_of0(dev, struct echo_device, ed_cl);
+	return container_of_safe(dev, struct echo_device, ed_cl);
 }
 
 static inline struct cl_device *echo_dev2cl(struct echo_device *d)
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 1449013722f6..dc25dd12d7d5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -460,7 +460,7 @@ static inline int osc_is_object(const struct lu_object *obj)
 static inline struct osc_device *lu2osc_dev(const struct lu_device *d)
 {
 	LINVRNT(d->ld_type == &osc_device_type);
-	return container_of0(d, struct osc_device, od_cl.cd_lu_dev);
+	return container_of(d, struct osc_device, od_cl.cd_lu_dev);
 }
 
 static inline struct obd_export *osc_export(const struct osc_object *obj)
@@ -476,7 +476,7 @@ static inline struct client_obd *osc_cli(const struct osc_object *obj)
 static inline struct osc_object *cl2osc(const struct cl_object *obj)
 {
 	LINVRNT(osc_is_object(&obj->co_lu));
-	return container_of0(obj, struct osc_object, oo_cl);
+	return container_of(obj, struct osc_object, oo_cl);
 }
 
 static inline struct cl_object *osc2cl(const struct osc_object *obj)
@@ -509,12 +509,12 @@ static inline enum cl_lock_mode osc_ldlm2cl_lock(enum ldlm_mode mode)
 static inline struct osc_page *cl2osc_page(const struct cl_page_slice *slice)
 {
 	LINVRNT(osc_is_object(&slice->cpl_obj->co_lu));
-	return container_of0(slice, struct osc_page, ops_cl);
+	return container_of(slice, struct osc_page, ops_cl);
 }
 
 static inline struct osc_page *oap2osc(struct osc_async_page *oap)
 {
-	return container_of0(oap, struct osc_page, ops_oap);
+	return container_of_safe(oap, struct osc_page, ops_oap);
 }
 
 static inline pgoff_t osc_index(struct osc_page *opg)
@@ -545,7 +545,7 @@ osc_cl_page_osc(struct cl_page *page, struct osc_object *osc)
 static inline struct osc_lock *cl2osc_lock(const struct cl_lock_slice *slice)
 {
 	LINVRNT(osc_is_object(&slice->cls_obj->co_lu));
-	return container_of0(slice, struct osc_lock, ols_cl);
+	return container_of(slice, struct osc_lock, ols_cl);
 }
 
 static inline struct osc_lock *osc_lock_at(const struct cl_lock *lock)
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 32db150fd42e..be8c7829b3de 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -180,7 +180,7 @@ struct osc_device {
 
 static inline struct osc_device *obd2osc_dev(const struct obd_device *d)
 {
-	return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
+	return container_of_safe(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
 }
 
 extern struct lu_kmem_descr osc_caches[];
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 76743faf3e6d..67734a8ed331 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -55,7 +55,7 @@
 static struct osc_io *cl2osc_io(const struct lu_env *env,
 				const struct cl_io_slice *slice)
 {
-	struct osc_io *oio = container_of0(slice, struct osc_io, oi_cl);
+	struct osc_io *oio = container_of_safe(slice, struct osc_io, oi_cl);
 
 	LINVRNT(oio == osc_env_io(env));
 	return oio;
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 6baa8e2e00c9..9582d5a642e2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -58,7 +58,7 @@ static struct lu_object *osc2lu(struct osc_object *osc)
 static struct osc_object *lu2osc(const struct lu_object *obj)
 {
 	LINVRNT(osc_is_object(obj));
-	return container_of0(obj, struct osc_object, oo_cl.co_lu);
+	return container_of(obj, struct osc_object, oo_cl.co_lu);
 }
 
 /*****************************************************************************
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 2da80e079d56..e5e991642d8f 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -941,6 +941,22 @@ static inline void ftrace_dump(enum ftrace_dump_mode oops_dump_mode) { }
 			 "pointer type mismatch in container_of()");	\
 	((type *)(__mptr - offsetof(type, member))); })
 
+/**
+ * container_of_safe - cast a member of a structure out to the containing structure
+ * @ptr:	the pointer to the member.
+ * @type:	the type of the container struct this is embedded in.
+ * @member:	the name of the member within the struct.
+ *
+ * If IS_ERR_OR_NULL(ptr), ptr is returned unchanged.
+ */
+#define container_of_safe(ptr, type, member) ({				\
+	void *__mptr = (void *)(ptr);					\
+	BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) &&	\
+			 !__same_type(*(ptr), void),			\
+			 "pointer type mismatch in container_of()");	\
+	IS_ERR_OR_NULL(ptr) ? ERR_CAST(ptr) :				\
+		((type *)(__mptr - offsetof(type, member))); })
+
 /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */
 #ifdef CONFIG_FTRACE_MCOUNT_RECORD
 # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
