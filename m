From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:00 -0400
Subject: [lustre-devel] [PATCH 17/29] staging/lustre/ptlrpc: secure wrapping
	code cleanup
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-18-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Drop unused functions.

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_sec.h |  20 --
 drivers/staging/lustre/lustre/ptlrpc/sec.c         | 116 --------
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    | 329 ---------------------
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |  48 ---
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |  15 -
 5 files changed, 528 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index 871185c..1d2c572 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -295,7 +295,6 @@ enum lustre_sec_part {
 	LUSTRE_SP_ANY	   = 0xFF
 };
 
-const char *sptlrpc_part2name(enum lustre_sec_part sp);
 enum lustre_sec_part sptlrpc_target_sec_part(struct obd_device *obd);
 
 /**
@@ -339,7 +338,6 @@ int sptlrpc_rule_set_choose(struct sptlrpc_rule_set *rset,
 			    enum lustre_sec_part to,
 			    lnet_nid_t nid,
 			    struct sptlrpc_flavor *sf);
-void sptlrpc_rule_set_dump(struct sptlrpc_rule_set *set);
 
 int  sptlrpc_process_config(struct lustre_cfg *lcfg);
 void sptlrpc_conf_log_start(const char *logname);
@@ -347,10 +345,6 @@ void sptlrpc_conf_log_stop(const char *logname);
 void sptlrpc_conf_log_update_begin(const char *logname);
 void sptlrpc_conf_log_update_end(const char *logname);
 void sptlrpc_conf_client_adapt(struct obd_device *obd);
-void sptlrpc_target_choose_flavor(struct sptlrpc_rule_set *rset,
-				  enum lustre_sec_part from,
-				  lnet_nid_t nid,
-				  struct sptlrpc_flavor *flavor);
 
 /* The maximum length of security payload. 1024 is enough for Kerberos 5,
  * and should be enough for other future mechanisms but not sure.
@@ -1002,16 +996,12 @@ void sptlrpc_sec_put(struct ptlrpc_sec *sec);
  * internal apis which only used by policy implementation
  */
 int  sptlrpc_get_next_secid(void);
-void sptlrpc_sec_destroy(struct ptlrpc_sec *sec);
 
 /*
  * exported client context api
  */
 struct ptlrpc_cli_ctx *sptlrpc_cli_ctx_get(struct ptlrpc_cli_ctx *ctx);
 void sptlrpc_cli_ctx_put(struct ptlrpc_cli_ctx *ctx, int sync);
-void sptlrpc_cli_ctx_expire(struct ptlrpc_cli_ctx *ctx);
-void sptlrpc_cli_ctx_wakeup(struct ptlrpc_cli_ctx *ctx);
-int sptlrpc_cli_ctx_display(struct ptlrpc_cli_ctx *ctx, char *buf, int bufsize);
 
 /*
  * exported client context wrap/buffers
@@ -1054,7 +1044,6 @@ int sptlrpc_parse_rule(char *param, struct sptlrpc_rule *rule);
 /* gc */
 void sptlrpc_gc_add_sec(struct ptlrpc_sec *sec);
 void sptlrpc_gc_del_sec(struct ptlrpc_sec *sec);
-void sptlrpc_gc_add_ctx(struct ptlrpc_cli_ctx *ctx);
 
 /* misc */
 const char *sec2target_str(struct ptlrpc_sec *sec);
@@ -1078,25 +1067,16 @@ int  sptlrpc_svc_wrap_reply(struct ptlrpc_request *req);
 void sptlrpc_svc_free_rs(struct ptlrpc_reply_state *rs);
 void sptlrpc_svc_ctx_addref(struct ptlrpc_request *req);
 void sptlrpc_svc_ctx_decref(struct ptlrpc_request *req);
-void sptlrpc_svc_ctx_invalidate(struct ptlrpc_request *req);
 
 int  sptlrpc_target_export_check(struct obd_export *exp,
 				 struct ptlrpc_request *req);
-void sptlrpc_target_update_exp_flavor(struct obd_device *obd,
-				      struct sptlrpc_rule_set *rset);
-
 /*
  * reverse context
  */
 int sptlrpc_svc_install_rvs_ctx(struct obd_import *imp,
 				struct ptlrpc_svc_ctx *ctx);
-int sptlrpc_cli_install_rvs_ctx(struct obd_import *imp,
-				struct ptlrpc_cli_ctx *ctx);
 
 /* bulk security api */
-int sptlrpc_enc_pool_add_user(void);
-int sptlrpc_enc_pool_del_user(void);
-int  sptlrpc_enc_pool_get_pages(struct ptlrpc_bulk_desc *desc);
 void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc);
 
 int sptlrpc_cli_wrap_bulk(struct ptlrpc_request *req,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 5ee6641..67604b5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -297,46 +297,6 @@ void sptlrpc_cli_ctx_put(struct ptlrpc_cli_ctx *ctx, int sync)
 }
 EXPORT_SYMBOL(sptlrpc_cli_ctx_put);
 
-/**
- * Expire the client context immediately.
- *
- * \pre Caller must hold at least 1 reference on the \a ctx.
- */
-void sptlrpc_cli_ctx_expire(struct ptlrpc_cli_ctx *ctx)
-{
-	LASSERT(ctx->cc_ops->force_die);
-	ctx->cc_ops->force_die(ctx, 0);
-}
-EXPORT_SYMBOL(sptlrpc_cli_ctx_expire);
-
-/**
- * To wake up the threads who are waiting for this client context. Called
- * after some status change happened on \a ctx.
- */
-void sptlrpc_cli_ctx_wakeup(struct ptlrpc_cli_ctx *ctx)
-{
-	struct ptlrpc_request *req, *next;
-
-	spin_lock(&ctx->cc_lock);
-	list_for_each_entry_safe(req, next, &ctx->cc_req_list,
-				     rq_ctx_chain) {
-		list_del_init(&req->rq_ctx_chain);
-		ptlrpc_client_wake_req(req);
-	}
-	spin_unlock(&ctx->cc_lock);
-}
-EXPORT_SYMBOL(sptlrpc_cli_ctx_wakeup);
-
-int sptlrpc_cli_ctx_display(struct ptlrpc_cli_ctx *ctx, char *buf, int bufsize)
-{
-	LASSERT(ctx->cc_ops);
-
-	if (ctx->cc_ops->display == NULL)
-		return 0;
-
-	return ctx->cc_ops->display(ctx, buf, bufsize);
-}
-
 static int import_sec_check_expire(struct obd_import *imp)
 {
 	int adapt = 0;
@@ -1229,12 +1189,6 @@ static void sec_cop_destroy_sec(struct ptlrpc_sec *sec)
 	sptlrpc_policy_put(policy);
 }
 
-void sptlrpc_sec_destroy(struct ptlrpc_sec *sec)
-{
-	sec_cop_destroy_sec(sec);
-}
-EXPORT_SYMBOL(sptlrpc_sec_destroy);
-
 static void sptlrpc_sec_kill(struct ptlrpc_sec *sec)
 {
 	LASSERT_ATOMIC_POS(&sec->ps_refcount);
@@ -1507,13 +1461,6 @@ static void import_flush_ctx_common(struct obd_import *imp,
 	sptlrpc_sec_put(sec);
 }
 
-void sptlrpc_import_flush_root_ctx(struct obd_import *imp)
-{
-	/* it's important to use grace mode, see explain in
-	 * sptlrpc_req_refresh_ctx() */
-	import_flush_ctx_common(imp, 0, 1, 1);
-}
-
 void sptlrpc_import_flush_my_ctx(struct obd_import *imp)
 {
 	import_flush_ctx_common(imp, from_kuid(&init_user_ns, current_uid()),
@@ -1697,16 +1644,6 @@ void sptlrpc_cli_free_repbuf(struct ptlrpc_request *req)
 	req->rq_repmsg = NULL;
 }
 
-int sptlrpc_cli_install_rvs_ctx(struct obd_import *imp,
-				struct ptlrpc_cli_ctx *ctx)
-{
-	struct ptlrpc_sec_policy *policy = ctx->cc_sec->ps_policy;
-
-	if (!policy->sp_cops->install_rctx)
-		return 0;
-	return policy->sp_cops->install_rctx(imp, ctx->cc_sec, ctx);
-}
-
 int sptlrpc_svc_install_rvs_ctx(struct obd_import *imp,
 				struct ptlrpc_svc_ctx *ctx)
 {
@@ -1921,46 +1858,6 @@ int sptlrpc_target_export_check(struct obd_export *exp,
 }
 EXPORT_SYMBOL(sptlrpc_target_export_check);
 
-void sptlrpc_target_update_exp_flavor(struct obd_device *obd,
-				      struct sptlrpc_rule_set *rset)
-{
-	struct obd_export *exp;
-	struct sptlrpc_flavor new_flvr;
-
-	LASSERT(obd);
-
-	spin_lock(&obd->obd_dev_lock);
-
-	list_for_each_entry(exp, &obd->obd_exports, exp_obd_chain) {
-		if (exp->exp_connection == NULL)
-			continue;
-
-		/* note if this export had just been updated flavor
-		 * (exp_flvr_changed == 1), this will override the
-		 * previous one. */
-		spin_lock(&exp->exp_lock);
-		sptlrpc_target_choose_flavor(rset, exp->exp_sp_peer,
-					     exp->exp_connection->c_peer.nid,
-					     &new_flvr);
-		if (exp->exp_flvr_changed ||
-		    !flavor_equal(&new_flvr, &exp->exp_flvr)) {
-			exp->exp_flvr_old[1] = new_flvr;
-			exp->exp_flvr_expire[1] = 0;
-			exp->exp_flvr_changed = 1;
-			exp->exp_flvr_adapt = 1;
-
-			CDEBUG(D_SEC, "exp %p (%s): updated flavor %x->%x\n",
-			       exp, sptlrpc_part2name(exp->exp_sp_peer),
-			       exp->exp_flvr.sf_rpc,
-			       exp->exp_flvr_old[1].sf_rpc);
-		}
-		spin_unlock(&exp->exp_lock);
-	}
-
-	spin_unlock(&obd->obd_dev_lock);
-}
-EXPORT_SYMBOL(sptlrpc_target_update_exp_flavor);
-
 static int sptlrpc_svc_check_from(struct ptlrpc_request *req, int svc_rc)
 {
 	/* peer's claim is unreliable unless gss is being used */
@@ -2183,19 +2080,6 @@ void sptlrpc_svc_ctx_decref(struct ptlrpc_request *req)
 	req->rq_svc_ctx = NULL;
 }
 
-void sptlrpc_svc_ctx_invalidate(struct ptlrpc_request *req)
-{
-	struct ptlrpc_svc_ctx *ctx = req->rq_svc_ctx;
-
-	if (ctx == NULL)
-		return;
-
-	LASSERT_ATOMIC_POS(&ctx->sc_refcount);
-	if (ctx->sc_policy->sp_sops->invalidate_ctx)
-		ctx->sc_policy->sp_sops->invalidate_ctx(ctx);
-}
-EXPORT_SYMBOL(sptlrpc_svc_ctx_invalidate);
-
 /****************************************
  * bulk security			*
  ****************************************/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index c18b71c..c89973c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -302,150 +302,6 @@ static unsigned long enc_pools_cleanup(struct page ***pools, int npools)
 	return cleaned;
 }
 
-/*
- * merge @npools pointed by @pools which contains @npages new pages
- * into current pools.
- *
- * we have options to avoid most memory copy with some tricks. but we choose
- * the simplest way to avoid complexity. It's not frequently called.
- */
-static void enc_pools_insert(struct page ***pools, int npools, int npages)
-{
-	int freeslot;
-	int op_idx, np_idx, og_idx, ng_idx;
-	int cur_npools, end_npools;
-
-	LASSERT(npages > 0);
-	LASSERT(page_pools.epp_total_pages+npages <= page_pools.epp_max_pages);
-	LASSERT(npages_to_npools(npages) == npools);
-	LASSERT(page_pools.epp_growing);
-
-	spin_lock(&page_pools.epp_lock);
-
-	/*
-	 * (1) fill all the free slots of current pools.
-	 */
-	/* free slots are those left by rent pages, and the extra ones with
-	 * index >= total_pages, locate at the tail of last pool. */
-	freeslot = page_pools.epp_total_pages % PAGES_PER_POOL;
-	if (freeslot != 0)
-		freeslot = PAGES_PER_POOL - freeslot;
-	freeslot += page_pools.epp_total_pages - page_pools.epp_free_pages;
-
-	op_idx = page_pools.epp_free_pages / PAGES_PER_POOL;
-	og_idx = page_pools.epp_free_pages % PAGES_PER_POOL;
-	np_idx = npools - 1;
-	ng_idx = (npages - 1) % PAGES_PER_POOL;
-
-	while (freeslot) {
-		LASSERT(page_pools.epp_pools[op_idx][og_idx] == NULL);
-		LASSERT(pools[np_idx][ng_idx] != NULL);
-
-		page_pools.epp_pools[op_idx][og_idx] = pools[np_idx][ng_idx];
-		pools[np_idx][ng_idx] = NULL;
-
-		freeslot--;
-
-		if (++og_idx == PAGES_PER_POOL) {
-			op_idx++;
-			og_idx = 0;
-		}
-		if (--ng_idx < 0) {
-			if (np_idx == 0)
-				break;
-			np_idx--;
-			ng_idx = PAGES_PER_POOL - 1;
-		}
-	}
-
-	/*
-	 * (2) add pools if needed.
-	 */
-	cur_npools = (page_pools.epp_total_pages + PAGES_PER_POOL - 1) /
-		     PAGES_PER_POOL;
-	end_npools = (page_pools.epp_total_pages + npages + PAGES_PER_POOL - 1)
-		     / PAGES_PER_POOL;
-	LASSERT(end_npools <= page_pools.epp_max_pools);
-
-	np_idx = 0;
-	while (cur_npools < end_npools) {
-		LASSERT(page_pools.epp_pools[cur_npools] == NULL);
-		LASSERT(np_idx < npools);
-		LASSERT(pools[np_idx] != NULL);
-
-		page_pools.epp_pools[cur_npools++] = pools[np_idx];
-		pools[np_idx++] = NULL;
-	}
-
-	page_pools.epp_total_pages += npages;
-	page_pools.epp_free_pages += npages;
-	page_pools.epp_st_lowfree = page_pools.epp_free_pages;
-
-	if (page_pools.epp_total_pages > page_pools.epp_st_max_pages)
-		page_pools.epp_st_max_pages = page_pools.epp_total_pages;
-
-	CDEBUG(D_SEC, "add %d pages to total %lu\n", npages,
-	       page_pools.epp_total_pages);
-
-	spin_unlock(&page_pools.epp_lock);
-}
-
-static int enc_pools_add_pages(int npages)
-{
-	static DEFINE_MUTEX(add_pages_mutex);
-	struct page ***pools;
-	int npools, alloced = 0;
-	int i, j, rc = -ENOMEM;
-
-	if (npages < PTLRPC_MAX_BRW_PAGES)
-		npages = PTLRPC_MAX_BRW_PAGES;
-
-	mutex_lock(&add_pages_mutex);
-
-	if (npages + page_pools.epp_total_pages > page_pools.epp_max_pages)
-		npages = page_pools.epp_max_pages - page_pools.epp_total_pages;
-	LASSERT(npages > 0);
-
-	page_pools.epp_st_grows++;
-
-	npools = npages_to_npools(npages);
-	pools = kcalloc(npools, sizeof(*pools), GFP_NOFS);
-	if (pools == NULL)
-		goto out;
-
-	for (i = 0; i < npools; i++) {
-		pools[i] = kzalloc(PAGE_CACHE_SIZE, GFP_NOFS);
-		if (!pools[i])
-			goto out_pools;
-
-		for (j = 0; j < PAGES_PER_POOL && alloced < npages; j++) {
-			pools[i][j] = alloc_page(GFP_NOFS |
-						     __GFP_HIGHMEM);
-			if (pools[i][j] == NULL)
-				goto out_pools;
-
-			alloced++;
-		}
-	}
-	LASSERT(alloced == npages);
-
-	enc_pools_insert(pools, npools, npages);
-	CDEBUG(D_SEC, "added %d pages into pools\n", npages);
-	rc = 0;
-
-out_pools:
-	enc_pools_cleanup(pools, npools);
-	kfree(pools);
-out:
-	if (rc) {
-		page_pools.epp_st_grow_fails++;
-		CERROR("Failed to allocate %d enc pages\n", npages);
-	}
-
-	mutex_unlock(&add_pages_mutex);
-	return rc;
-}
-
 static inline void enc_pools_wakeup(void)
 {
 	assert_spin_locked(&page_pools.epp_lock);
@@ -457,156 +313,6 @@ static inline void enc_pools_wakeup(void)
 	}
 }
 
-static int enc_pools_should_grow(int page_needed, time64_t now)
-{
-	/* don't grow if someone else is growing the pools right now,
-	 * or the pools has reached its full capacity
-	 */
-	if (page_pools.epp_growing ||
-	    page_pools.epp_total_pages == page_pools.epp_max_pages)
-		return 0;
-
-	/* if total pages is not enough, we need to grow */
-	if (page_pools.epp_total_pages < page_needed)
-		return 1;
-
-	/*
-	 * we wanted to return 0 here if there was a shrink just happened
-	 * moment ago, but this may cause deadlock if both client and ost
-	 * live on single node.
-	 */
-#if 0
-	if (now - page_pools.epp_last_shrink < 2)
-		return 0;
-#endif
-
-	/*
-	 * here we perhaps need consider other factors like wait queue
-	 * length, idle index, etc. ?
-	 */
-
-	/* grow the pools in any other cases */
-	return 1;
-}
-
-/*
- * we allocate the requested pages atomically.
- */
-int sptlrpc_enc_pool_get_pages(struct ptlrpc_bulk_desc *desc)
-{
-	wait_queue_t waitlink;
-	unsigned long this_idle = -1;
-	unsigned long tick = 0;
-	long now;
-	int p_idx, g_idx;
-	int i;
-
-	LASSERT(desc->bd_iov_count > 0);
-	LASSERT(desc->bd_iov_count <= page_pools.epp_max_pages);
-
-	/* resent bulk, enc iov might have been allocated previously */
-	if (desc->bd_enc_iov != NULL)
-		return 0;
-
-	desc->bd_enc_iov = kcalloc(desc->bd_iov_count,
-				   sizeof(*desc->bd_enc_iov), GFP_NOFS);
-	if (desc->bd_enc_iov == NULL)
-		return -ENOMEM;
-
-	spin_lock(&page_pools.epp_lock);
-
-	page_pools.epp_st_access++;
-again:
-	if (unlikely(page_pools.epp_free_pages < desc->bd_iov_count)) {
-		if (tick == 0)
-			tick = cfs_time_current();
-
-		now = ktime_get_seconds();
-
-		page_pools.epp_st_missings++;
-		page_pools.epp_pages_short += desc->bd_iov_count;
-
-		if (enc_pools_should_grow(desc->bd_iov_count, now)) {
-			page_pools.epp_growing = 1;
-
-			spin_unlock(&page_pools.epp_lock);
-			enc_pools_add_pages(page_pools.epp_pages_short / 2);
-			spin_lock(&page_pools.epp_lock);
-
-			page_pools.epp_growing = 0;
-
-			enc_pools_wakeup();
-		} else {
-			if (++page_pools.epp_waitqlen >
-			    page_pools.epp_st_max_wqlen)
-				page_pools.epp_st_max_wqlen =
-						page_pools.epp_waitqlen;
-
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			init_waitqueue_entry(&waitlink, current);
-			add_wait_queue(&page_pools.epp_waitq, &waitlink);
-
-			spin_unlock(&page_pools.epp_lock);
-			schedule();
-			remove_wait_queue(&page_pools.epp_waitq, &waitlink);
-			LASSERT(page_pools.epp_waitqlen > 0);
-			spin_lock(&page_pools.epp_lock);
-			page_pools.epp_waitqlen--;
-		}
-
-		LASSERT(page_pools.epp_pages_short >= desc->bd_iov_count);
-		page_pools.epp_pages_short -= desc->bd_iov_count;
-
-		this_idle = 0;
-		goto again;
-	}
-
-	/* record max wait time */
-	if (unlikely(tick != 0)) {
-		tick = cfs_time_current() - tick;
-		if (tick > page_pools.epp_st_max_wait)
-			page_pools.epp_st_max_wait = tick;
-	}
-
-	/* proceed with rest of allocation */
-	page_pools.epp_free_pages -= desc->bd_iov_count;
-
-	p_idx = page_pools.epp_free_pages / PAGES_PER_POOL;
-	g_idx = page_pools.epp_free_pages % PAGES_PER_POOL;
-
-	for (i = 0; i < desc->bd_iov_count; i++) {
-		LASSERT(page_pools.epp_pools[p_idx][g_idx] != NULL);
-		desc->bd_enc_iov[i].kiov_page =
-					page_pools.epp_pools[p_idx][g_idx];
-		page_pools.epp_pools[p_idx][g_idx] = NULL;
-
-		if (++g_idx == PAGES_PER_POOL) {
-			p_idx++;
-			g_idx = 0;
-		}
-	}
-
-	if (page_pools.epp_free_pages < page_pools.epp_st_lowfree)
-		page_pools.epp_st_lowfree = page_pools.epp_free_pages;
-
-	/*
-	 * new idle index = (old * weight + new) / (weight + 1)
-	 */
-	if (this_idle == -1) {
-		this_idle = page_pools.epp_free_pages * IDLE_IDX_MAX /
-			    page_pools.epp_total_pages;
-	}
-	page_pools.epp_idle_idx = (page_pools.epp_idle_idx * IDLE_IDX_WEIGHT +
-				   this_idle) /
-				  (IDLE_IDX_WEIGHT + 1);
-
-	page_pools.epp_last_access = ktime_get_seconds();
-
-	spin_unlock(&page_pools.epp_lock);
-	return 0;
-}
-EXPORT_SYMBOL(sptlrpc_enc_pool_get_pages);
-
 void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 {
 	int p_idx, g_idx;
@@ -651,41 +357,6 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 }
 EXPORT_SYMBOL(sptlrpc_enc_pool_put_pages);
 
-/*
- * we don't do much stuff for add_user/del_user anymore, except adding some
- * initial pages in add_user() if current pools are empty, rest would be
- * handled by the pools's self-adaption.
- */
-int sptlrpc_enc_pool_add_user(void)
-{
-	int need_grow = 0;
-
-	spin_lock(&page_pools.epp_lock);
-	if (page_pools.epp_growing == 0 && page_pools.epp_total_pages == 0) {
-		page_pools.epp_growing = 1;
-		need_grow = 1;
-	}
-	spin_unlock(&page_pools.epp_lock);
-
-	if (need_grow) {
-		enc_pools_add_pages(PTLRPC_MAX_BRW_PAGES +
-				    PTLRPC_MAX_BRW_PAGES);
-
-		spin_lock(&page_pools.epp_lock);
-		page_pools.epp_growing = 0;
-		enc_pools_wakeup();
-		spin_unlock(&page_pools.epp_lock);
-	}
-	return 0;
-}
-EXPORT_SYMBOL(sptlrpc_enc_pool_add_user);
-
-int sptlrpc_enc_pool_del_user(void)
-{
-	return 0;
-}
-EXPORT_SYMBOL(sptlrpc_enc_pool_del_user);
-
 static inline void enc_pools_alloc(void)
 {
 	LASSERT(page_pools.epp_max_pools);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 7769ab2..0d29b87 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -48,27 +48,6 @@
 
 #include "ptlrpc_internal.h"
 
-const char *sptlrpc_part2name(enum lustre_sec_part part)
-{
-	switch (part) {
-	case LUSTRE_SP_CLI:
-		return "cli";
-	case LUSTRE_SP_MDT:
-		return "mdt";
-	case LUSTRE_SP_OST:
-		return "ost";
-	case LUSTRE_SP_MGC:
-		return "mgc";
-	case LUSTRE_SP_MGS:
-		return "mgs";
-	case LUSTRE_SP_ANY:
-		return "any";
-	default:
-		return "err";
-	}
-}
-EXPORT_SYMBOL(sptlrpc_part2name);
-
 enum lustre_sec_part sptlrpc_target_sec_part(struct obd_device *obd)
 {
 	const char *type = obd->obd_type->typ_name;
@@ -430,19 +409,6 @@ int sptlrpc_rule_set_choose(struct sptlrpc_rule_set *rset,
 }
 EXPORT_SYMBOL(sptlrpc_rule_set_choose);
 
-void sptlrpc_rule_set_dump(struct sptlrpc_rule_set *rset)
-{
-	struct sptlrpc_rule *r;
-	int n;
-
-	for (n = 0; n < rset->srs_nrule; n++) {
-		r = &rset->srs_rules[n];
-		CDEBUG(D_SEC, "<%02d> from %x to %x, net %x, rpc %x\n", n,
-		       r->sr_from, r->sr_to, r->sr_netid, r->sr_flvr.sf_rpc);
-	}
-}
-EXPORT_SYMBOL(sptlrpc_rule_set_dump);
-
 /**********************************
  * sptlrpc configuration support  *
  **********************************/
@@ -836,20 +802,6 @@ out:
 	flavor_set_flags(sf, from, to, 1);
 }
 
-/**
- * called by target devices, determine the expected flavor from
- * certain peer (from, nid).
- */
-void sptlrpc_target_choose_flavor(struct sptlrpc_rule_set *rset,
-				  enum lustre_sec_part from,
-				  lnet_nid_t nid,
-				  struct sptlrpc_flavor *sf)
-{
-	if (sptlrpc_rule_set_choose(rset, from, LUSTRE_SP_ANY, nid, sf) == 0)
-		get_default_flavor(sf);
-}
-EXPORT_SYMBOL(sptlrpc_target_choose_flavor);
-
 #define SEC_ADAPT_DELAY	 (10)
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index c3ad1da..520329f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -103,21 +103,6 @@ void sptlrpc_gc_del_sec(struct ptlrpc_sec *sec)
 }
 EXPORT_SYMBOL(sptlrpc_gc_del_sec);
 
-void sptlrpc_gc_add_ctx(struct ptlrpc_cli_ctx *ctx)
-{
-	LASSERT(list_empty(&ctx->cc_gc_chain));
-
-	CDEBUG(D_SEC, "hand over ctx %p(%u->%s)\n",
-	       ctx, ctx->cc_vcred.vc_uid, sec2target_str(ctx->cc_sec));
-	spin_lock(&sec_gc_ctx_list_lock);
-	list_add(&ctx->cc_gc_chain, &sec_gc_ctx_list);
-	spin_unlock(&sec_gc_ctx_list_lock);
-
-	thread_add_flags(&sec_gc_thread, SVC_SIGNAL);
-	wake_up(&sec_gc_thread.t_ctl_waitq);
-}
-EXPORT_SYMBOL(sptlrpc_gc_add_ctx);
-
 static void sec_process_ctx_list(void)
 {
 	struct ptlrpc_cli_ctx *ctx;
-- 
2.1.0
