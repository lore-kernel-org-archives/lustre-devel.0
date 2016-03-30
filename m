From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:29 -0400
Subject: [lustre-devel] [PATCH v2 08/46] staging/lustre/obdclass: Add a
	preallocated percpu cl_env
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-9-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Prakash Surya <surya1@llnl.gov>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

This change adds support for a single preallocated cl_env per CPU
which can be used in circumstances where reschedule is not possible.
Currently this interface is only used by the ll_releasepage function.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Prakash Surya <surya1@llnl.gov>
Reviewed-on: http://review.whamcloud.com/8174
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3321
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  12 +++
 drivers/staging/lustre/lustre/llite/rw26.c         |  54 +++++++----
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |   1 -
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 107 +++++++++++++++++++++
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   1 -
 5 files changed, 152 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 5daf688..e8455dc 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2773,6 +2773,16 @@ static inline void *cl_object_page_slice(struct cl_object *clob,
 	return (void *)((char *)page + clob->co_slice_off);
 }
 
+/**
+ * Return refcount of cl_object.
+ */
+static inline int cl_object_refc(struct cl_object *clob)
+{
+	struct lu_object_header *header = clob->co_lu.lo_header;
+
+	return atomic_read(&header->loh_ref);
+}
+
 /** @} cl_object */
 
 /** \defgroup cl_page cl_page
@@ -3226,6 +3236,8 @@ void cl_env_reexit(void *cookie);
 void cl_env_implant(struct lu_env *env, int *refcheck);
 void cl_env_unplant(struct lu_env *env, int *refcheck);
 unsigned int cl_env_cache_purge(unsigned int nr);
+struct lu_env *cl_env_percpu_get(void);
+void cl_env_percpu_put(struct lu_env *env);
 
 /** @} cl_env */
 
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index b5335de..cc49c21 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -107,12 +107,12 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 
 static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 {
-	struct cl_env_nest nest;
 	struct lu_env     *env;
+	void			*cookie;
 	struct cl_object  *obj;
 	struct cl_page    *page;
 	struct address_space *mapping;
-	int result;
+	int result = 0;
 
 	LASSERT(PageLocked(vmpage));
 	if (PageWriteback(vmpage) || PageDirty(vmpage))
@@ -126,30 +126,42 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 	if (!obj)
 		return 1;
 
-	/* 1 for page allocator, 1 for cl_page and 1 for page cache */
+	/* 1 for caller, 1 for cl_page and 1 for page cache */
 	if (page_count(vmpage) > 3)
 		return 0;
 
-	/* TODO: determine what gfp should be used by @gfp_mask. */
-	env = cl_env_nested_get(&nest);
-	if (IS_ERR(env))
-		/* If we can't allocate an env we won't call cl_page_put()
-		 * later on which further means it's impossible to drop
-		 * page refcount by cl_page, so ask kernel to not free
-		 * this page.
-		 */
-		return 0;
-
 	page = cl_vmpage_page(vmpage, obj);
-	result = !page;
-	if (page) {
-		if (!cl_page_in_use(page)) {
-			result = 1;
-			cl_page_delete(env, page);
-		}
-		cl_page_put(env, page);
+	if (!page)
+		return 1;
+
+	cookie = cl_env_reenter();
+	env = cl_env_percpu_get();
+	LASSERT(!IS_ERR(env));
+
+	if (!cl_page_in_use(page)) {
+		result = 1;
+		cl_page_delete(env, page);
 	}
-	cl_env_nested_put(&nest, env);
+
+	/* To use percpu env array, the call path can not be rescheduled;
+	 * otherwise percpu array will be messed if ll_releaspage() called
+	 * again on the same CPU.
+	 *
+	 * If this page holds the last refc of cl_object, the following
+	 * call path may cause reschedule:
+	 *   cl_page_put -> cl_page_free -> cl_object_put ->
+	 *     lu_object_put -> lu_object_free -> lov_delete_raid0 ->
+	 *     cl_locks_prune.
+	 *
+	 * However, the kernel can't get rid of this inode until all pages have
+	 * been cleaned up. Now that we hold page lock here, it's pretty safe
+	 * that we won't get into object delete path.
+	 */
+	LASSERT(cl_object_refc(obj) > 1);
+	cl_page_put(env, page);
+
+	cl_env_percpu_put(env);
+	cl_env_reexit(cookie);
 	return result;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 32ecc5a..fe8059a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -255,7 +255,6 @@ static void cl_lock_free(const struct lu_env *env, struct cl_lock *lock)
 	LINVRNT(!cl_lock_is_mutexed(lock));
 
 	cl_lock_trace(D_DLMTRACE, env, "free lock", lock);
-	might_sleep();
 	while (!list_empty(&lock->cll_layers)) {
 		struct cl_lock_slice *slice;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 65b6402..fa9b083 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -390,6 +390,8 @@ static int cache_stats_print(const struct cache_stats *cs,
 	return 0;
 }
 
+static void cl_env_percpu_refill(void);
+
 /**
  * Initialize client site.
  *
@@ -409,6 +411,7 @@ int cl_site_init(struct cl_site *s, struct cl_device *d)
 			atomic_set(&s->cs_pages_state[0], 0);
 		for (i = 0; i < ARRAY_SIZE(s->cs_locks_state); ++i)
 			atomic_set(&s->cs_locks_state[i], 0);
+		cl_env_percpu_refill();
 	}
 	return result;
 }
@@ -1001,6 +1004,104 @@ void cl_lvb2attr(struct cl_attr *attr, const struct ost_lvb *lvb)
 }
 EXPORT_SYMBOL(cl_lvb2attr);
 
+static struct cl_env cl_env_percpu[NR_CPUS];
+
+static int cl_env_percpu_init(void)
+{
+	struct cl_env *cle;
+	int tags = LCT_REMEMBER | LCT_NOREF;
+	int i, j;
+	int rc = 0;
+
+	for_each_possible_cpu(i) {
+		struct lu_env *env;
+
+		cle = &cl_env_percpu[i];
+		env = &cle->ce_lu;
+
+		INIT_LIST_HEAD(&cle->ce_linkage);
+		cle->ce_magic = &cl_env_init0;
+		rc = lu_env_init(env, LCT_CL_THREAD | tags);
+		if (rc == 0) {
+			rc = lu_context_init(&cle->ce_ses, LCT_SESSION | tags);
+			if (rc == 0) {
+				lu_context_enter(&cle->ce_ses);
+				env->le_ses = &cle->ce_ses;
+			} else {
+				lu_env_fini(env);
+			}
+		}
+		if (rc != 0)
+			break;
+	}
+	if (rc != 0) {
+		/* Indices 0 to i (excluding i) were correctly initialized,
+		 * thus we must uninitialize up to i, the rest are undefined.
+		 */
+		for (j = 0; j < i; j++) {
+			cle = &cl_env_percpu[i];
+			lu_context_exit(&cle->ce_ses);
+			lu_context_fini(&cle->ce_ses);
+			lu_env_fini(&cle->ce_lu);
+		}
+	}
+
+	return rc;
+}
+
+static void cl_env_percpu_fini(void)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct cl_env *cle = &cl_env_percpu[i];
+
+		lu_context_exit(&cle->ce_ses);
+		lu_context_fini(&cle->ce_ses);
+		lu_env_fini(&cle->ce_lu);
+	}
+}
+
+static void cl_env_percpu_refill(void)
+{
+	int i;
+
+	for_each_possible_cpu(i)
+		lu_env_refill(&cl_env_percpu[i].ce_lu);
+}
+
+void cl_env_percpu_put(struct lu_env *env)
+{
+	struct cl_env *cle;
+	int cpu;
+
+	cpu = smp_processor_id();
+	cle = cl_env_container(env);
+	LASSERT(cle == &cl_env_percpu[cpu]);
+
+	cle->ce_ref--;
+	LASSERT(cle->ce_ref == 0);
+
+	CL_ENV_DEC(busy);
+	cl_env_detach(cle);
+	cle->ce_debug = NULL;
+
+	put_cpu();
+}
+EXPORT_SYMBOL(cl_env_percpu_put);
+
+struct lu_env *cl_env_percpu_get()
+{
+	struct cl_env *cle;
+
+	cle = &cl_env_percpu[get_cpu()];
+	cl_env_init0(cle, __builtin_return_address(0));
+
+	cl_env_attach(cle);
+	return &cle->ce_lu;
+}
+EXPORT_SYMBOL(cl_env_percpu_get);
+
 /*****************************************************************************
  *
  * Temporary prototype thing: mirror obd-devices into cl devices.
@@ -1154,6 +1255,11 @@ int cl_global_init(void)
 	if (result)
 		goto out_lock;
 
+	result = cl_env_percpu_init();
+	if (result)
+		/* no cl_env_percpu_fini on error */
+		goto out_lock;
+
 	return 0;
 out_lock:
 	cl_lock_fini();
@@ -1171,6 +1277,7 @@ out_store:
  */
 void cl_global_fini(void)
 {
+	cl_env_percpu_fini();
 	cl_lock_fini();
 	cl_page_fini();
 	lu_context_key_degister(&cl_key);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 8169836..bab8a74 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -123,7 +123,6 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 	PASSERT(env, page, !page->cp_parent);
 	PASSERT(env, page, page->cp_state == CPS_FREEING);
 
-	might_sleep();
 	while (!list_empty(&page->cp_layers)) {
 		struct cl_page_slice *slice;
 
-- 
2.1.0
