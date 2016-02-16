From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:43 -0500
Subject: [lustre-devel] [PATCH 11/45] staging/lustre/osc: Remove commented
	out osc_page_protected()
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-12-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

The complicated version of osc_page_protected and osc_page_is_dlocked
are unsafe and were commented out for ages, so probably no point in
carrying them on.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/osc_page.c | 99 ----------------------------
 1 file changed, 99 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 8943f0a..99d5b56 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -51,111 +51,12 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
  *  @{
  */
 
-/*
- * Comment out osc_page_protected because it may sleep inside the
- * the client_obd_list_lock.
- * client_obd_list_lock -> osc_ap_completion -> osc_completion ->
- *   -> osc_page_protected -> osc_page_is_dlocked -> osc_match_base
- *   -> ldlm_lock_match -> sptlrpc_import_check_ctx -> sleep.
- */
-#if 0
-static int osc_page_is_dlocked(const struct lu_env *env,
-			       const struct osc_page *opg,
-			       enum cl_lock_mode mode, int pending, int unref)
-{
-	struct cl_page	 *page;
-	struct osc_object      *obj;
-	struct osc_thread_info *info;
-	struct ldlm_res_id     *resname;
-	struct lustre_handle   *lockh;
-	ldlm_policy_data_t     *policy;
-	ldlm_mode_t	     dlmmode;
-	__u64                   flags;
-
-	might_sleep();
-
-	info = osc_env_info(env);
-	resname = &info->oti_resname;
-	policy = &info->oti_policy;
-	lockh = &info->oti_handle;
-	page = opg->ops_cl.cpl_page;
-	obj = cl2osc(opg->ops_cl.cpl_obj);
-
-	flags = LDLM_FL_TEST_LOCK | LDLM_FL_BLOCK_GRANTED;
-	if (pending)
-		flags |= LDLM_FL_CBPENDING;
-
-	dlmmode = osc_cl_lock2ldlm(mode) | LCK_PW;
-	osc_lock_build_res(env, obj, resname);
-	osc_index2policy(policy, page->cp_obj, page->cp_index, page->cp_index);
-	return osc_match_base(osc_export(obj), resname, LDLM_EXTENT, policy,
-			      dlmmode, &flags, NULL, lockh, unref);
-}
-
-/**
- * Checks an invariant that a page in the cache is covered by a lock, as
- * needed.
- */
-static int osc_page_protected(const struct lu_env *env,
-			      const struct osc_page *opg,
-			      enum cl_lock_mode mode, int unref)
-{
-	struct cl_object_header *hdr;
-	struct cl_lock	  *scan;
-	struct cl_page	  *page;
-	struct cl_lock_descr    *descr;
-	int result;
-
-	LINVRNT(!opg->ops_temp);
-
-	page = opg->ops_cl.cpl_page;
-	if (page->cp_owner != NULL &&
-	    cl_io_top(page->cp_owner)->ci_lockreq == CILR_NEVER)
-		/*
-		 * If IO is done without locks (liblustre, or lloop), lock is
-		 * not required.
-		 */
-		result = 1;
-	else
-		/* otherwise check for a DLM lock */
-	result = osc_page_is_dlocked(env, opg, mode, 1, unref);
-	if (result == 0) {
-		/* maybe this page is a part of a lockless io? */
-		hdr = cl_object_header(opg->ops_cl.cpl_obj);
-		descr = &osc_env_info(env)->oti_descr;
-		descr->cld_mode = mode;
-		descr->cld_start = page->cp_index;
-		descr->cld_end   = page->cp_index;
-		spin_lock(&hdr->coh_lock_guard);
-		list_for_each_entry(scan, &hdr->coh_locks, cll_linkage) {
-			/*
-			 * Lock-less sub-lock has to be either in HELD state
-			 * (when io is actively going on), or in CACHED state,
-			 * when top-lock is being unlocked:
-			 * cl_io_unlock()->cl_unuse()->...->lov_lock_unuse().
-			 */
-			if ((scan->cll_state == CLS_HELD ||
-			     scan->cll_state == CLS_CACHED) &&
-			    cl_lock_ext_match(&scan->cll_descr, descr)) {
-				struct osc_lock *olck;
-
-				olck = osc_lock_at(scan);
-				result = osc_lock_is_lockless(olck);
-				break;
-			}
-		}
-		spin_unlock(&hdr->coh_lock_guard);
-	}
-	return result;
-}
-#else
 static int osc_page_protected(const struct lu_env *env,
 			      const struct osc_page *opg,
 			      enum cl_lock_mode mode, int unref)
 {
 	return 1;
 }
-#endif
 
 /*****************************************************************************
  *
-- 
2.1.0
