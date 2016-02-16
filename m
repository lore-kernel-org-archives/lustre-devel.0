From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:51 -0500
Subject: [lustre-devel] [PATCH 19/45] staging/lustre/lclient: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-20-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 32 +++++++++++-----------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index 4dfeb4e..efa6e2e 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -117,7 +117,7 @@ void *ccc_key_init(const struct lu_context *ctx, struct lu_context_key *key)
 	struct ccc_thread_info *info;
 
 	info = kmem_cache_alloc(ccc_thread_kmem, GFP_NOFS | __GFP_ZERO);
-	if (info == NULL)
+	if (!info)
 		info = ERR_PTR(-ENOMEM);
 	return info;
 }
@@ -136,7 +136,7 @@ void *ccc_session_key_init(const struct lu_context *ctx,
 	struct ccc_session *session;
 
 	session = kmem_cache_alloc(ccc_session_kmem, GFP_NOFS | __GFP_ZERO);
-	if (session == NULL)
+	if (!session)
 		session = ERR_PTR(-ENOMEM);
 	return session;
 }
@@ -173,7 +173,7 @@ int ccc_device_init(const struct lu_env *env, struct lu_device *d,
 	vdv = lu2ccc_dev(d);
 	vdv->cdv_next = lu2cl_dev(next);
 
-	LASSERT(d->ld_site != NULL && next->ld_type != NULL);
+	LASSERT(d->ld_site && next->ld_type);
 	next->ld_site = d->ld_site;
 	rc = next->ld_type->ldt_ops->ldto_device_init(
 			env, next, next->ld_type->ldt_name, NULL);
@@ -211,12 +211,12 @@ struct lu_device *ccc_device_alloc(const struct lu_env *env,
 	vdv->cdv_cl.cd_ops = clops;
 
 	site = kzalloc(sizeof(*site), GFP_NOFS);
-	if (site != NULL) {
+	if (site) {
 		rc = cl_site_init(site, &vdv->cdv_cl);
 		if (rc == 0)
 			rc = lu_site_init_finish(&site->cs_lu);
 		else {
-			LASSERT(lud->ld_site == NULL);
+			LASSERT(!lud->ld_site);
 			CERROR("Cannot init lu_site, rc %d.\n", rc);
 			kfree(site);
 		}
@@ -236,7 +236,7 @@ struct lu_device *ccc_device_free(const struct lu_env *env,
 	struct cl_site    *site = lu2cl_site(d->ld_site);
 	struct lu_device  *next = cl2lu_dev(vdv->cdv_next);
 
-	if (d->ld_site != NULL) {
+	if (d->ld_site) {
 		cl_site_fini(site);
 		kfree(site);
 	}
@@ -252,7 +252,7 @@ int ccc_req_init(const struct lu_env *env, struct cl_device *dev,
 	int result;
 
 	vrq = kmem_cache_alloc(ccc_req_kmem, GFP_NOFS | __GFP_ZERO);
-	if (vrq != NULL) {
+	if (vrq) {
 		cl_req_slice_add(req, &vrq->crq_cl, dev, &ccc_req_ops);
 		result = 0;
 	} else
@@ -304,7 +304,7 @@ out_kmem:
 
 void ccc_global_fini(struct lu_device_type *device_type)
 {
-	if (ccc_inode_fini_env != NULL) {
+	if (ccc_inode_fini_env) {
 		cl_env_put(ccc_inode_fini_env, &dummy_refcheck);
 		ccc_inode_fini_env = NULL;
 	}
@@ -328,7 +328,7 @@ struct lu_object *ccc_object_alloc(const struct lu_env *env,
 	struct lu_object  *obj;
 
 	vob = kmem_cache_alloc(ccc_object_kmem, GFP_NOFS | __GFP_ZERO);
-	if (vob != NULL) {
+	if (vob) {
 		struct cl_object_header *hdr;
 
 		obj = ccc2lu(vob);
@@ -365,7 +365,7 @@ int ccc_object_init(const struct lu_env *env, struct lu_object *obj,
 
 	under = &dev->cdv_next->cd_lu_dev;
 	below = under->ld_ops->ldo_object_alloc(env, obj->lo_header, under);
-	if (below != NULL) {
+	if (below) {
 		const struct cl_object_conf *cconf;
 
 		cconf = lu2cl_conf(conf);
@@ -397,7 +397,7 @@ int ccc_lock_init(const struct lu_env *env,
 	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
 
 	clk = kmem_cache_alloc(ccc_lock_kmem, GFP_NOFS | __GFP_ZERO);
-	if (clk != NULL) {
+	if (clk) {
 		cl_lock_slice_add(lock, &clk->clk_cl, obj, lkops);
 		result = 0;
 	} else
@@ -660,7 +660,7 @@ void ccc_io_update_iov(const struct lu_env *env,
 {
 	size_t size = io->u.ci_rw.crw_count;
 
-	if (!cl_is_normalio(env, io) || cio->cui_iter == NULL)
+	if (!cl_is_normalio(env, io) || !cio->cui_iter)
 		return;
 
 	iov_iter_truncate(cio->cui_iter, size);
@@ -749,7 +749,7 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 			 */
 			ccc_object_size_unlock(obj);
 			result = cl_glimpse_lock(env, io, inode, obj, 0);
-			if (result == 0 && exceed != NULL) {
+			if (result == 0 && exceed) {
 				/* If objective page index exceed end-of-file
 				 * page index, return directly. Do not expect
 				 * kernel will check such case correctly.
@@ -1022,7 +1022,7 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 	fid  = &lli->lli_fid;
 	LASSERT(fid_is_sane(fid));
 
-	if (lli->lli_clob == NULL) {
+	if (!lli->lli_clob) {
 		/* clob is slave of inode, empty lli_clob means for new inode,
 		 * there is no clob in cache with the given fid, so it is
 		 * unnecessary to perform lookup-alloc-lookup-insert, just
@@ -1098,7 +1098,7 @@ void cl_inode_fini(struct inode *inode)
 	int refcheck;
 	int emergency;
 
-	if (clob != NULL) {
+	if (clob) {
 		void		    *cookie;
 
 		cookie = cl_env_reenter();
@@ -1106,7 +1106,7 @@ void cl_inode_fini(struct inode *inode)
 		emergency = IS_ERR(env);
 		if (emergency) {
 			mutex_lock(&ccc_inode_fini_guard);
-			LASSERT(ccc_inode_fini_env != NULL);
+			LASSERT(ccc_inode_fini_env);
 			cl_env_implant(ccc_inode_fini_env, &refcheck);
 			env = ccc_inode_fini_env;
 		}
-- 
2.1.0
