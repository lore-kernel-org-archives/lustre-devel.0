From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:56 -0500
Subject: [lustre-devel] [PATCH 24/45] staging/lustre/obdecho: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-25-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Also remove some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/obdecho/echo_client.c    | 61 ++++++++++------------
 1 file changed, 29 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 4ca82af..ca87cc2 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -146,7 +146,7 @@ static inline struct echo_thread_info *echo_env_info(const struct lu_env *env)
 	struct echo_thread_info *info;
 
 	info = lu_context_key_get(&env->le_ctx, &echo_thread_key);
-	LASSERT(info != NULL);
+	LASSERT(info);
 	return info;
 }
 
@@ -267,7 +267,7 @@ static void echo_page_completion(const struct lu_env *env,
 				 const struct cl_page_slice *slice,
 				 int ioret)
 {
-	LASSERT(slice->cpl_page->cp_sync_io != NULL);
+	LASSERT(slice->cpl_page->cp_sync_io);
 }
 
 static void echo_page_fini(const struct lu_env *env,
@@ -393,13 +393,13 @@ static int echo_lock_init(const struct lu_env *env,
 	struct echo_lock *el;
 
 	el = kmem_cache_alloc(echo_lock_kmem, GFP_NOFS | __GFP_ZERO);
-	if (el != NULL) {
+	if (el) {
 		cl_lock_slice_add(lock, &el->el_cl, obj, &echo_lock_ops);
 		el->el_object = cl2echo_obj(obj);
 		INIT_LIST_HEAD(&el->el_chain);
 		atomic_set(&el->el_refcount, 0);
 	}
-	return el == NULL ? -ENOMEM : 0;
+	return !el ? -ENOMEM : 0;
 }
 
 static int echo_conf_set(const struct lu_env *env, struct cl_object *obj,
@@ -439,7 +439,7 @@ static int echo_object_init(const struct lu_env *env, struct lu_object *obj,
 		under = ed->ed_next;
 		below = under->ld_ops->ldo_object_alloc(env, obj->lo_header,
 							under);
-		if (below == NULL)
+		if (!below)
 			return -ENOMEM;
 		lu_object_add(obj, below);
 	}
@@ -470,12 +470,12 @@ static int echo_alloc_memmd(struct echo_device *ed,
 	int lsm_size;
 
 	/* If export is lov/osc then use their obd method */
-	if (ed->ed_next != NULL)
+	if (ed->ed_next)
 		return obd_alloc_memmd(ed->ed_ec->ec_exp, lsmp);
 	/* OFD has no unpackmd method, do everything here */
 	lsm_size = lov_stripe_md_size(1);
 
-	LASSERT(*lsmp == NULL);
+	LASSERT(!*lsmp);
 	*lsmp = kzalloc(lsm_size, GFP_NOFS);
 	if (!*lsmp)
 		return -ENOMEM;
@@ -498,12 +498,11 @@ static int echo_free_memmd(struct echo_device *ed, struct lov_stripe_md **lsmp)
 	int lsm_size;
 
 	/* If export is lov/osc then use their obd method */
-	if (ed->ed_next != NULL)
+	if (ed->ed_next)
 		return obd_free_memmd(ed->ed_ec->ec_exp, lsmp);
 	/* OFD has no unpackmd method, do everything here */
 	lsm_size = lov_stripe_md_size(1);
 
-	LASSERT(*lsmp != NULL);
 	kfree((*lsmp)->lsm_oinfo[0]);
 	kfree(*lsmp);
 	*lsmp = NULL;
@@ -562,9 +561,9 @@ static struct lu_object *echo_object_alloc(const struct lu_env *env,
 	struct lu_object *obj = NULL;
 
 	/* we're the top dev. */
-	LASSERT(hdr == NULL);
+	LASSERT(!hdr);
 	eco = kmem_cache_alloc(echo_object_kmem, GFP_NOFS | __GFP_ZERO);
-	if (eco != NULL) {
+	if (eco) {
 		struct cl_object_header *hdr = &eco->eo_hdr;
 
 		obj = &echo_obj2cl(eco)->co_lu;
@@ -627,7 +626,7 @@ static void *echo_thread_key_init(const struct lu_context *ctx,
 	struct echo_thread_info *info;
 
 	info = kmem_cache_alloc(echo_thread_kmem, GFP_NOFS | __GFP_ZERO);
-	if (info == NULL)
+	if (!info)
 		info = ERR_PTR(-ENOMEM);
 	return info;
 }
@@ -658,7 +657,7 @@ static void *echo_session_key_init(const struct lu_context *ctx,
 	struct echo_session_info *session;
 
 	session = kmem_cache_alloc(echo_session_kmem, GFP_NOFS | __GFP_ZERO);
-	if (session == NULL)
+	if (!session)
 		session = ERR_PTR(-ENOMEM);
 	return session;
 }
@@ -715,11 +714,11 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 
 	cleanup = 2;
 	obd = class_name2obd(lustre_cfg_string(cfg, 0));
-	LASSERT(obd != NULL);
-	LASSERT(env != NULL);
+	LASSERT(obd);
+	LASSERT(env);
 
 	tgt = class_name2obd(lustre_cfg_string(cfg, 1));
-	if (tgt == NULL) {
+	if (!tgt) {
 		CERROR("Can not find tgt device %s\n",
 			lustre_cfg_string(cfg, 1));
 		rc = -ENODEV;
@@ -748,13 +747,12 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 
 	/* if echo client is to be stacked upon ost device, the next is
 	 * NULL since ost is not a clio device so far */
-	if (next != NULL && !lu_device_is_cl(next))
+	if (next && !lu_device_is_cl(next))
 		next = NULL;
 
 	tgt_type_name = tgt->obd_type->typ_name;
-	if (next != NULL) {
-		LASSERT(next != NULL);
-		if (next->ld_site != NULL) {
+	if (next) {
+		if (next->ld_site) {
 			rc = -EBUSY;
 			goto out;
 		}
@@ -1063,7 +1061,6 @@ static int cl_echo_cancel0(struct lu_env *env, struct echo_device *ed,
 	struct list_head	     *el;
 	int found = 0, still_used = 0;
 
-	LASSERT(ec != NULL);
 	spin_lock(&ec->ec_lock);
 	list_for_each(el, &ec->ec_locks) {
 		ecl = list_entry(el, struct echo_lock, el_chain);
@@ -1121,7 +1118,7 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 	int i;
 
 	LASSERT((offset & ~CFS_PAGE_MASK) == 0);
-	LASSERT(ed->ed_next != NULL);
+	LASSERT(ed->ed_next);
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
 		return PTR_ERR(env);
@@ -1393,11 +1390,11 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 		brw_flags = OBD_BRW_ASYNC;
 
 	pga = kcalloc(npages, sizeof(*pga), GFP_NOFS);
-	if (pga == NULL)
+	if (!pga)
 		return -ENOMEM;
 
 	pages = kcalloc(npages, sizeof(*pages), GFP_NOFS);
-	if (pages == NULL) {
+	if (!pages) {
 		kfree(pga);
 		return -ENOMEM;
 	}
@@ -1406,11 +1403,11 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 	     i < npages;
 	     i++, pgp++, off += PAGE_CACHE_SIZE) {
 
-		LASSERT(pgp->pg == NULL);      /* for cleanup */
+		LASSERT(!pgp->pg);      /* for cleanup */
 
 		rc = -ENOMEM;
 		pgp->pg = alloc_page(gfp_mask);
-		if (pgp->pg == NULL)
+		if (!pgp->pg)
 			goto out;
 
 		pages[i] = pgp->pg;
@@ -1425,7 +1422,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 	}
 
 	/* brw mode can only be used at client */
-	LASSERT(ed->ed_next != NULL);
+	LASSERT(ed->ed_next);
 	rc = cl_echo_object_brw(eco, rw, offset, pages, npages, async);
 
  out:
@@ -1433,7 +1430,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 		verify = 0;
 
 	for (i = 0, pgp = pga; i < npages; i++, pgp++) {
-		if (pgp->pg == NULL)
+		if (!pgp->pg)
 			continue;
 
 		if (verify) {
@@ -1475,7 +1472,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	lnb = kcalloc(npages, sizeof(struct niobuf_local), GFP_NOFS);
 	rnb = kcalloc(npages, sizeof(struct niobuf_remote), GFP_NOFS);
 
-	if (lnb == NULL || rnb == NULL) {
+	if (!lnb || !rnb) {
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -1513,7 +1510,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 			struct page *page = lnb[i].page;
 
 			/* read past eof? */
-			if (page == NULL && lnb[i].rc == 0)
+			if (!page  && lnb[i].rc == 0)
 				continue;
 
 			if (async)
@@ -1582,7 +1579,7 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 	if (test_mode == 1)
 		async = 0;
 
-	if (ed->ed_next == NULL && test_mode != 3) {
+	if (!ed->ed_next && test_mode != 3) {
 		test_mode = 3;
 		data->ioc_plen1 = data->ioc_count;
 	}
@@ -1834,7 +1831,7 @@ static int echo_client_disconnect(struct obd_export *exp)
 {
 	int		     rc;
 
-	if (exp == NULL) {
+	if (!exp) {
 		rc = -EINVAL;
 		goto out;
 	}
-- 
2.1.0
