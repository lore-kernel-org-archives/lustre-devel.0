From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:57 -0400
Subject: [lustre-devel] [PATCH 25/43] staging/lustre/llite: rename
	ccc_device to vvp_device
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-26-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Rename struct ccc_device to struct vvp_device and merge the CCC device
methods into the VVP device methods.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/13075
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   2 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 104 +--------------------
 .../staging/lustre/lustre/llite/llite_internal.h   |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  84 ++++++++++++++++-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  38 ++++----
 5 files changed, 102 insertions(+), 128 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index f2bb8f8..f2a242b 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -149,7 +149,7 @@ struct cl_device_operations {
 /**
  * Device in the client stack.
  *
- * \see ccc_device, lov_device, lovsub_device, osc_device
+ * \see vvp_device, lov_device, lovsub_device, osc_device
  */
 struct cl_device {
 	/** Super-class. */
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 79cdf83..b0d4a3d 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -159,91 +159,6 @@ struct lu_context_key ccc_session_key = {
 	.lct_fini = ccc_session_key_fini
 };
 
-/* type constructor/destructor: ccc_type_{init,fini,start,stop}(). */
-/* LU_TYPE_INIT_FINI(ccc, &ccc_key, &ccc_session_key); */
-
-int ccc_device_init(const struct lu_env *env, struct lu_device *d,
-		    const char *name, struct lu_device *next)
-{
-	struct ccc_device  *vdv;
-	int rc;
-
-	vdv = lu2ccc_dev(d);
-	vdv->cdv_next = lu2cl_dev(next);
-
-	LASSERT(d->ld_site && next->ld_type);
-	next->ld_site = d->ld_site;
-	rc = next->ld_type->ldt_ops->ldto_device_init(
-			env, next, next->ld_type->ldt_name, NULL);
-	if (rc == 0) {
-		lu_device_get(next);
-		lu_ref_add(&next->ld_reference, "lu-stack", &lu_site_init);
-	}
-	return rc;
-}
-
-struct lu_device *ccc_device_fini(const struct lu_env *env,
-				  struct lu_device *d)
-{
-	return cl2lu_dev(lu2ccc_dev(d)->cdv_next);
-}
-
-struct lu_device *ccc_device_alloc(const struct lu_env *env,
-				   struct lu_device_type *t,
-				   struct lustre_cfg *cfg,
-				   const struct lu_device_operations *luops,
-				   const struct cl_device_operations *clops)
-{
-	struct ccc_device *vdv;
-	struct lu_device  *lud;
-	struct cl_site    *site;
-	int rc;
-
-	vdv = kzalloc(sizeof(*vdv), GFP_NOFS);
-	if (!vdv)
-		return ERR_PTR(-ENOMEM);
-
-	lud = &vdv->cdv_cl.cd_lu_dev;
-	cl_device_init(&vdv->cdv_cl, t);
-	ccc2lu_dev(vdv)->ld_ops = luops;
-	vdv->cdv_cl.cd_ops = clops;
-
-	site = kzalloc(sizeof(*site), GFP_NOFS);
-	if (site) {
-		rc = cl_site_init(site, &vdv->cdv_cl);
-		if (rc == 0) {
-			rc = lu_site_init_finish(&site->cs_lu);
-		} else {
-			LASSERT(!lud->ld_site);
-			CERROR("Cannot init lu_site, rc %d.\n", rc);
-			kfree(site);
-		}
-	} else {
-		rc = -ENOMEM;
-	}
-	if (rc != 0) {
-		ccc_device_free(env, lud);
-		lud = ERR_PTR(rc);
-	}
-	return lud;
-}
-
-struct lu_device *ccc_device_free(const struct lu_env *env,
-				  struct lu_device *d)
-{
-	struct ccc_device *vdv  = lu2ccc_dev(d);
-	struct cl_site    *site = lu2cl_site(d->ld_site);
-	struct lu_device  *next = cl2lu_dev(vdv->cdv_next);
-
-	if (d->ld_site) {
-		cl_site_fini(site);
-		kfree(site);
-	}
-	cl_device_fini(lu2cl_dev(d));
-	kfree(vdv);
-	return next;
-}
-
 int ccc_req_init(const struct lu_env *env, struct cl_device *dev,
 		 struct cl_req *req)
 {
@@ -360,13 +275,13 @@ int ccc_object_init0(const struct lu_env *env,
 int ccc_object_init(const struct lu_env *env, struct lu_object *obj,
 		    const struct lu_object_conf *conf)
 {
-	struct ccc_device *dev = lu2ccc_dev(obj->lo_dev);
+	struct vvp_device *dev = lu2vvp_dev(obj->lo_dev);
 	struct ccc_object *vob = lu2ccc(obj);
 	struct lu_object  *below;
 	struct lu_device  *under;
 	int result;
 
-	under = &dev->cdv_next->cd_lu_dev;
+	under = &dev->vdv_next->cd_lu_dev;
 	below = under->ld_ops->ldo_object_alloc(env, obj->lo_header, under);
 	if (below) {
 		const struct cl_object_conf *cconf;
@@ -779,21 +694,6 @@ again:
  *
  */
 
-struct lu_device *ccc2lu_dev(struct ccc_device *vdv)
-{
-	return &vdv->cdv_cl.cd_lu_dev;
-}
-
-struct ccc_device *lu2ccc_dev(const struct lu_device *d)
-{
-	return container_of0(d, struct ccc_device, cdv_cl.cd_lu_dev);
-}
-
-struct ccc_device *cl2ccc_dev(const struct cl_device *d)
-{
-	return container_of0(d, struct ccc_device, cdv_cl);
-}
-
 struct lu_object *ccc2lu(struct ccc_object *vob)
 {
 	return &vob->cob_cl.co_lu;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 5686b94..1e9e41b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1321,7 +1321,7 @@ static inline void cl_stats_tally(struct cl_device *dev, enum cl_req_type crt,
 	int opc = (crt == CRT_READ) ? LPROC_LL_OSC_READ :
 				      LPROC_LL_OSC_WRITE;
 
-	ll_stats_ops_tally(ll_s2sbi(cl2ccc_dev(dev)->cdv_sb), opc, rc);
+	ll_stats_ops_tally(ll_s2sbi(cl2vvp_dev(dev)->vdv_sb), opc, rc);
 }
 
 ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 29d24c9..e934ec8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -136,11 +136,85 @@ static const struct cl_device_operations vvp_cl_ops = {
 	.cdo_req_init = ccc_req_init
 };
 
+static struct lu_device *vvp_device_free(const struct lu_env *env,
+					 struct lu_device *d)
+{
+	struct vvp_device *vdv  = lu2vvp_dev(d);
+	struct cl_site    *site = lu2cl_site(d->ld_site);
+	struct lu_device  *next = cl2lu_dev(vdv->vdv_next);
+
+	if (d->ld_site) {
+		cl_site_fini(site);
+		kfree(site);
+	}
+	cl_device_fini(lu2cl_dev(d));
+	kfree(vdv);
+	return next;
+}
+
 static struct lu_device *vvp_device_alloc(const struct lu_env *env,
 					  struct lu_device_type *t,
 					  struct lustre_cfg *cfg)
 {
-	return ccc_device_alloc(env, t, cfg, &vvp_lu_ops, &vvp_cl_ops);
+	struct vvp_device *vdv;
+	struct lu_device  *lud;
+	struct cl_site    *site;
+	int rc;
+
+	vdv = kzalloc(sizeof(*vdv), GFP_NOFS);
+	if (!vdv)
+		return ERR_PTR(-ENOMEM);
+
+	lud = &vdv->vdv_cl.cd_lu_dev;
+	cl_device_init(&vdv->vdv_cl, t);
+	vvp2lu_dev(vdv)->ld_ops = &vvp_lu_ops;
+	vdv->vdv_cl.cd_ops = &vvp_cl_ops;
+
+	site = kzalloc(sizeof(*site), GFP_NOFS);
+	if (site) {
+		rc = cl_site_init(site, &vdv->vdv_cl);
+		if (rc == 0) {
+			rc = lu_site_init_finish(&site->cs_lu);
+		} else {
+			LASSERT(!lud->ld_site);
+			CERROR("Cannot init lu_site, rc %d.\n", rc);
+			kfree(site);
+		}
+	} else {
+		rc = -ENOMEM;
+	}
+	if (rc != 0) {
+		vvp_device_free(env, lud);
+		lud = ERR_PTR(rc);
+	}
+	return lud;
+}
+
+static int vvp_device_init(const struct lu_env *env, struct lu_device *d,
+			   const char *name, struct lu_device *next)
+{
+	struct vvp_device  *vdv;
+	int rc;
+
+	vdv = lu2vvp_dev(d);
+	vdv->vdv_next = lu2cl_dev(next);
+
+	LASSERT(d->ld_site && next->ld_type);
+	next->ld_site = d->ld_site;
+	rc = next->ld_type->ldt_ops->ldto_device_init(env, next,
+						      next->ld_type->ldt_name,
+						      NULL);
+	if (rc == 0) {
+		lu_device_get(next);
+		lu_ref_add(&next->ld_reference, "lu-stack", &lu_site_init);
+	}
+	return rc;
+}
+
+static struct lu_device *vvp_device_fini(const struct lu_env *env,
+					 struct lu_device *d)
+{
+	return cl2lu_dev(lu2vvp_dev(d)->vdv_next);
 }
 
 static const struct lu_device_type_operations vvp_device_type_ops = {
@@ -151,9 +225,9 @@ static const struct lu_device_type_operations vvp_device_type_ops = {
 	.ldto_stop  = vvp_type_stop,
 
 	.ldto_device_alloc = vvp_device_alloc,
-	.ldto_device_free  = ccc_device_free,
-	.ldto_device_init  = ccc_device_init,
-	.ldto_device_fini  = ccc_device_fini
+	.ldto_device_free	= vvp_device_free,
+	.ldto_device_init	= vvp_device_init,
+	.ldto_device_fini	= vvp_device_fini,
 };
 
 struct lu_device_type vvp_device_type = {
@@ -206,7 +280,7 @@ int cl_sb_init(struct super_block *sb)
 		cl = cl_type_setup(env, NULL, &vvp_device_type,
 				   sbi->ll_dt_exp->exp_obd->obd_lu_dev);
 		if (!IS_ERR(cl)) {
-			cl2ccc_dev(cl)->cdv_sb = sb;
+			cl2vvp_dev(cl)->vdv_sb = sb;
 			sbi->ll_cl = cl;
 			sbi->ll_site = cl2lu_dev(cl)->ld_site;
 		}
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index d4fe611..34509f9 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -264,10 +264,10 @@ static inline pgoff_t ccc_index(struct ccc_page *ccc)
 
 struct cl_page *ccc_vmpage_page_transient(struct page *vmpage);
 
-struct ccc_device {
-	struct cl_device    cdv_cl;
-	struct super_block *cdv_sb;
-	struct cl_device   *cdv_next;
+struct vvp_device {
+	struct cl_device    vdv_cl;
+	struct super_block *vdv_sb;
+	struct cl_device   *vdv_next;
 };
 
 struct ccc_lock {
@@ -287,18 +287,6 @@ void *ccc_session_key_init(const struct lu_context *ctx,
 void  ccc_session_key_fini(const struct lu_context *ctx,
 			   struct lu_context_key *key, void *data);
 
-int ccc_device_init(const struct lu_env *env,
-		    struct lu_device *d,
-		    const char *name, struct lu_device *next);
-struct lu_device *ccc_device_fini(const struct lu_env *env,
-				  struct lu_device *d);
-struct lu_device *ccc_device_alloc(const struct lu_env *env,
-				   struct lu_device_type *t,
-				   struct lustre_cfg *cfg,
-				   const struct lu_device_operations *luops,
-				   const struct cl_device_operations *clops);
-struct lu_device *ccc_device_free(const struct lu_env *env,
-				  struct lu_device *d);
 struct lu_object *ccc_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev,
@@ -351,10 +339,22 @@ void ccc_req_attr_set(const struct lu_env *env,
 		      const struct cl_object *obj,
 		      struct cl_req_attr *oa, u64 flags);
 
-struct lu_device *ccc2lu_dev(struct ccc_device *vdv);
+static inline struct lu_device *vvp2lu_dev(struct vvp_device *vdv)
+{
+	return &vdv->vdv_cl.cd_lu_dev;
+}
+
+static inline struct vvp_device *lu2vvp_dev(const struct lu_device *d)
+{
+	return container_of0(d, struct vvp_device, vdv_cl.cd_lu_dev);
+}
+
+static inline struct vvp_device *cl2vvp_dev(const struct cl_device *d)
+{
+	return container_of0(d, struct vvp_device, vdv_cl);
+}
+
 struct lu_object *ccc2lu(struct ccc_object *vob);
-struct ccc_device *lu2ccc_dev(const struct lu_device *d);
-struct ccc_device *cl2ccc_dev(const struct cl_device *d);
 struct ccc_object *lu2ccc(const struct lu_object *obj);
 struct ccc_object *cl2ccc(const struct cl_object *obj);
 struct ccc_lock *cl2ccc_lock(const struct cl_lock_slice *slice);
-- 
2.1.0
