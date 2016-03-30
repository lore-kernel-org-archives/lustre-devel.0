From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:27 -0400
Subject: [lustre-devel] [PATCH v2 06/46] staging/lustre/osc: to drop LRU
	pages with cl_lru_work
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

This way we can drop it async.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/7891
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3321
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd.h        |  1 +
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  9 ++++-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      | 12 +++++-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  1 +
 drivers/staging/lustre/lustre/osc/osc_internal.h   |  3 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       | 45 ++++++++++++++--------
 drivers/staging/lustre/lustre/osc/osc_request.c    | 23 ++++++++++-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     | 16 ++++++--
 8 files changed, 85 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 4a0f2e8..26182ca 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -364,6 +364,7 @@ struct client_obd {
 
 	/* ptlrpc work for writeback in ptlrpcd context */
 	void		    *cl_writeback_work;
+	void			*cl_lru_work;
 	/* hash tables for osc_quota_info */
 	struct cfs_hash	      *cl_quota_hash[MAXQUOTAS];
 };
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 45941a6..9e8e61a 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -393,6 +393,8 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 	struct super_block *sb = ((struct seq_file *)file->private_data)->private;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct cl_client_cache *cache = &sbi->ll_cache;
+	struct lu_env *env;
+	int refcheck;
 	int mult, rc, pages_number;
 	int diff = 0;
 	int nrpages = 0;
@@ -430,6 +432,10 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 		goto out;
 	}
 
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return 0;
+
 	diff = -diff;
 	while (diff > 0) {
 		int tmp;
@@ -461,13 +467,14 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 
 		/* difficult - have to ask OSCs to drop LRU slots. */
 		tmp = diff << 1;
-		rc = obd_set_info_async(NULL, sbi->ll_dt_exp,
+		rc = obd_set_info_async(env, sbi->ll_dt_exp,
 					sizeof(KEY_CACHE_LRU_SHRINK),
 					KEY_CACHE_LRU_SHRINK,
 					sizeof(tmp), &tmp, NULL);
 		if (rc < 0)
 			break;
 	}
+	cl_env_put(env, &refcheck);
 
 out:
 	if (rc >= 0) {
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 3eff12c..e6e2029 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -222,8 +222,16 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 		return -ERANGE;
 
 	rc = atomic_read(&cli->cl_lru_in_list) - pages_number;
-	if (rc > 0)
-		(void)osc_lru_shrink(cli, rc, true);
+	if (rc > 0) {
+		struct lu_env *env;
+		int refcheck;
+
+		env = cl_env_get(&refcheck);
+		if (!IS_ERR(env)) {
+			(void)osc_lru_shrink(env, cli, rc, true);
+			cl_env_put(env, &refcheck);
+		}
+	}
 
 	return count;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index f516848..b6325f5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -457,6 +457,7 @@ int osc_cache_wait_range(const struct lu_env *env, struct osc_object *obj,
 			 pgoff_t start, pgoff_t end);
 void osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 		   struct osc_object *osc);
+int lru_queue_work(const struct lu_env *env, void *data);
 
 void osc_object_set_contended  (struct osc_object *obj);
 void osc_object_clear_contended(struct osc_object *obj);
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index ec12962..b3b15d4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -130,7 +130,8 @@ int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
 int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *cfg);
 int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct list_head *ext_list, int cmd);
-int osc_lru_shrink(struct client_obd *cli, int target, bool force);
+int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
+		   int target, bool force);
 int osc_lru_reclaim(struct client_obd *cli);
 
 extern spinlock_t osc_ast_guard;
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index a60b783..f0a9870 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -508,6 +508,18 @@ static int osc_cache_too_much(struct client_obd *cli)
 	return 0;
 }
 
+int lru_queue_work(const struct lu_env *env, void *data)
+{
+	struct client_obd *cli = data;
+
+	CDEBUG(D_CACHE, "Run LRU work for client obd %p.\n", cli);
+
+	if (osc_cache_too_much(cli))
+		osc_lru_shrink(env, cli, lru_shrink_max, true);
+
+	return 0;
+}
+
 void osc_lru_add_batch(struct client_obd *cli, struct list_head *plist)
 {
 	LIST_HEAD(lru);
@@ -533,7 +545,8 @@ void osc_lru_add_batch(struct client_obd *cli, struct list_head *plist)
 		client_obd_list_unlock(&cli->cl_lru_list_lock);
 
 		/* XXX: May set force to be true for better performance */
-		osc_lru_shrink(cli, osc_cache_too_much(cli), false);
+		if (osc_cache_too_much(cli))
+			(void)ptlrpcd_queue_work(cli->cl_lru_work);
 	}
 }
 
@@ -566,7 +579,7 @@ static void osc_lru_del(struct client_obd *cli, struct osc_page *opg)
 		 * stealing one of them.
 		 */
 		if (!memory_pressure_get())
-			osc_lru_shrink(cli, osc_cache_too_much(cli), false);
+			(void)ptlrpcd_queue_work(cli->cl_lru_work);
 		wake_up(&osc_lru_waitq);
 	} else {
 		LASSERT(list_empty(&opg->ops_lru));
@@ -610,10 +623,9 @@ static void discard_pagevec(const struct lu_env *env, struct cl_io *io,
 /**
  * Drop @target of pages from LRU at most.
  */
-int osc_lru_shrink(struct client_obd *cli, int target, bool force)
+int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
+		   int target, bool force)
 {
-	struct cl_env_nest nest;
-	struct lu_env *env;
 	struct cl_io *io;
 	struct cl_object *clobj = NULL;
 	struct cl_page **pvec;
@@ -640,12 +652,6 @@ int osc_lru_shrink(struct client_obd *cli, int target, bool force)
 		atomic_inc(&cli->cl_lru_shrinkers);
 	}
 
-	env = cl_env_nested_get(&nest);
-	if (IS_ERR(env)) {
-		rc = PTR_ERR(env);
-		goto out;
-	}
-
 	pvec = osc_env_info(env)->oti_pvec;
 	io = &osc_env_info(env)->oti_io;
 
@@ -735,9 +741,7 @@ int osc_lru_shrink(struct client_obd *cli, int target, bool force)
 		cl_io_fini(env, io);
 		cl_object_put(env, clobj);
 	}
-	cl_env_nested_put(&nest, env);
 
-out:
 	atomic_dec(&cli->cl_lru_shrinkers);
 	if (count > 0) {
 		atomic_add(count, cli->cl_lru_left);
@@ -753,20 +757,26 @@ static inline int max_to_shrink(struct client_obd *cli)
 
 int osc_lru_reclaim(struct client_obd *cli)
 {
+	struct cl_env_nest nest;
+	struct lu_env *env;
 	struct cl_client_cache *cache = cli->cl_cache;
 	int max_scans;
 	int rc = 0;
 
 	LASSERT(cache);
 
-	rc = osc_lru_shrink(cli, lru_shrink_min, false);
+	env = cl_env_nested_get(&nest);
+	if (IS_ERR(env))
+		return 0;
+
+	rc = osc_lru_shrink(env, cli, osc_cache_too_much(cli), false);
 	if (rc != 0) {
 		if (rc == -EBUSY)
 			rc = 0;
 
 		CDEBUG(D_CACHE, "%s: Free %d pages from own LRU: %p.\n",
 		       cli->cl_import->imp_obd->obd_name, rc, cli);
-		return rc;
+		goto out;
 	}
 
 	CDEBUG(D_CACHE, "%s: cli %p no free slots, pages: %d, busy: %d.\n",
@@ -797,7 +807,8 @@ int osc_lru_reclaim(struct client_obd *cli)
 		if (osc_cache_too_much(cli) > 0) {
 			spin_unlock(&cache->ccc_lru_lock);
 
-			rc = osc_lru_shrink(cli, osc_cache_too_much(cli), true);
+			rc = osc_lru_shrink(env, cli, osc_cache_too_much(cli),
+					    true);
 			spin_lock(&cache->ccc_lru_lock);
 			if (rc != 0)
 				break;
@@ -805,6 +816,8 @@ int osc_lru_reclaim(struct client_obd *cli)
 	}
 	spin_unlock(&cache->ccc_lru_lock);
 
+out:
+	cl_env_nested_put(&nest, env);
 	CDEBUG(D_CACHE, "%s: cli %p freed %d pages.\n",
 	       cli->cl_import->imp_obd->obd_name, cli, rc);
 	return rc;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 6dadda4..c055511b3 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2910,7 +2910,7 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		int nr = atomic_read(&cli->cl_lru_in_list) >> 1;
 		int target = *(int *)val;
 
-		nr = osc_lru_shrink(cli, min(nr, target), true);
+		nr = osc_lru_shrink(env, cli, min(nr, target), true);
 		*(int *)val -= nr;
 		return 0;
 	}
@@ -3167,6 +3167,14 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	}
 	cli->cl_writeback_work = handler;
 
+	handler = ptlrpcd_alloc_work(cli->cl_import, lru_queue_work, cli);
+	if (IS_ERR(handler)) {
+		rc = PTR_ERR(handler);
+		goto out_ptlrpcd_work;
+	}
+
+	cli->cl_lru_work = handler;
+
 	rc = osc_quota_setup(obd);
 	if (rc)
 		goto out_ptlrpcd_work;
@@ -3199,7 +3207,14 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	return rc;
 
 out_ptlrpcd_work:
-	ptlrpcd_destroy_work(handler);
+	if (cli->cl_writeback_work) {
+		ptlrpcd_destroy_work(cli->cl_writeback_work);
+		cli->cl_writeback_work = NULL;
+	}
+	if (cli->cl_lru_work) {
+		ptlrpcd_destroy_work(cli->cl_lru_work);
+		cli->cl_lru_work = NULL;
+	}
 out_client_setup:
 	client_obd_cleanup(obd);
 out_ptlrpcd:
@@ -3238,6 +3253,10 @@ static int osc_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
 			ptlrpcd_destroy_work(cli->cl_writeback_work);
 			cli->cl_writeback_work = NULL;
 		}
+		if (cli->cl_lru_work) {
+			ptlrpcd_destroy_work(cli->cl_lru_work);
+			cli->cl_lru_work = NULL;
+		}
 		obd_cleanup_client_import(obd);
 		ptlrpc_lprocfs_unregister_obd(obd);
 		lprocfs_obd_cleanup(obd);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index db003f5..dbc3376 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -387,7 +387,8 @@ static int ptlrpcd(void *arg)
 {
 	struct ptlrpcd_ctl *pc = arg;
 	struct ptlrpc_request_set *set;
-	struct lu_env env = { .le_ses = NULL };
+	struct lu_context ses = { 0 };
+	struct lu_env env = { .le_ses = &ses };
 	int rc = 0;
 	int exit = 0;
 
@@ -416,6 +417,13 @@ static int ptlrpcd(void *arg)
 	 */
 	rc = lu_context_init(&env.le_ctx,
 			     LCT_CL_THREAD|LCT_REMEMBER|LCT_NOREF);
+	if (rc == 0) {
+		rc = lu_context_init(env.le_ses,
+				     LCT_SESSION | LCT_REMEMBER | LCT_NOREF);
+		if (rc != 0)
+			lu_context_fini(&env.le_ctx);
+	}
+
 	if (rc != 0)
 		goto failed;
 
@@ -436,9 +444,10 @@ static int ptlrpcd(void *arg)
 				  ptlrpc_expired_set, set);
 
 		lu_context_enter(&env.le_ctx);
-		l_wait_event(set->set_waitq,
-			     ptlrpcd_check(&env, pc), &lwi);
+		lu_context_enter(env.le_ses);
+		l_wait_event(set->set_waitq, ptlrpcd_check(&env, pc), &lwi);
 		lu_context_exit(&env.le_ctx);
+		lu_context_exit(env.le_ses);
 
 		/*
 		 * Abort inflight rpcs for forced stop case.
@@ -461,6 +470,7 @@ static int ptlrpcd(void *arg)
 	if (!list_empty(&set->set_requests))
 		ptlrpc_set_wait(set);
 	lu_context_fini(&env.le_ctx);
+	lu_context_fini(env.le_ses);
 
 	complete(&pc->pc_finishing);
 
-- 
2.1.0
