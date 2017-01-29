From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:55 -0500
Subject: [lustre-devel] [PATCH 27/60] staging: lustre: mgc: handle
	config_llog_data::cld_refcount properly
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

Originally, the logic of handling config_llog_data::cld_refcount
is some confusing, it may cause the cld_refcount to be leaked or
trigger "LASSERT(atomic_read(&cld->cld_refcount) > 0);" when put
the reference. This patch clean related logic as following:

1) When the 'cld' is created, its reference is set as 1.

2) No need additional reference when add the 'cld' into the list
   'config_llog_list'.

3) Inrease 'cld_refcount' when set lock data after mgc_enqueue()
   done successfully by mgc_process_log().

4) When mgc_requeue_thread() traversals the 'config_llog_list',
   it needs to take additional reference on each 'cld' to avoid
   being freed during subsequent processing. The reference also
   prevents the 'cld' to be dropped from the 'config_llog_list',
   then the mgc_requeue_thread() can safely locate next 'cld',
   and then decrease the 'cld_refcount' for previous one.

5) mgc_blocking_ast() will drop the reference of 'cld_refcount'
   that is taken in mgc_process_log().

6) The others need to call config_log_find() to find the 'cld'
   if want to access related config log data. That will increase
   the 'cld_refcount' to avoid being freed during accessing. The
   sponsor needs to call config_log_put() after using the 'cld'.

7) Other confused or redundant logic are dropped.

   On the other hand, the patch also enhances the protection for
   'config_llog_data' flags, such as 'cld_stopping'/'cld_lostlock'
   as following.

a) Use 'config_list_lock' (spinlock) to handle the possible
   parallel accessing of these flags among mgc_requeue_thread()
   and others config llog data visitors, such as mount/umount,
   blocking_ast, and so on.

b) Use 'config_llog_data::cld_lock' (mutex) to pretect other
   parallel accessing of these flags among kinds of blockable
   operations, such as mount, umount, and blocking ast.

The 'config_llog_data::cld_lock' is also used for protecting
the sub-cld members, such as 'cld_sptlrpc'/'cld_params', and
so on.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8408
Reviewed-on: http://review.whamcloud.com/21616
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Hongchao Zhang <hongchao.zhang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 183 ++++++++++++------------
 1 file changed, 94 insertions(+), 89 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index b9c522a..6a76605 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -142,10 +142,10 @@ static void config_log_put(struct config_llog_data *cld)
 
 		if (cld->cld_recover)
 			config_log_put(cld->cld_recover);
-		if (cld->cld_sptlrpc)
-			config_log_put(cld->cld_sptlrpc);
 		if (cld->cld_params)
 			config_log_put(cld->cld_params);
+		if (cld->cld_sptlrpc)
+			config_log_put(cld->cld_sptlrpc);
 		if (cld_is_sptlrpc(cld))
 			sptlrpc_conf_log_stop(cld->cld_logname);
 
@@ -175,13 +175,10 @@ struct config_llog_data *config_log_find(char *logname,
 		/* instance may be NULL, should check name */
 		if (strcmp(logname, cld->cld_logname) == 0) {
 			found = cld;
+			config_log_get(found);
 			break;
 		}
 	}
-	if (found) {
-		atomic_inc(&found->cld_refcount);
-		LASSERT(found->cld_stopping == 0 || cld_is_sptlrpc(found) == 0);
-	}
 	spin_unlock(&config_list_lock);
 	return found;
 }
@@ -203,6 +200,12 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	if (!cld)
 		return ERR_PTR(-ENOMEM);
 
+	rc = mgc_logname2resid(logname, &cld->cld_resid, type);
+	if (rc) {
+		kfree(cld);
+		return ERR_PTR(rc);
+	}
+
 	strcpy(cld->cld_logname, logname);
 	if (cfg)
 		cld->cld_cfg = *cfg;
@@ -223,17 +226,10 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 		cld->cld_cfg.cfg_obdname = obd->obd_name;
 	}
 
-	rc = mgc_logname2resid(logname, &cld->cld_resid, type);
-
 	spin_lock(&config_list_lock);
 	list_add(&cld->cld_list_chain, &config_llog_list);
 	spin_unlock(&config_list_lock);
 
-	if (rc) {
-		config_log_put(cld);
-		return ERR_PTR(rc);
-	}
-
 	if (cld_is_sptlrpc(cld)) {
 		rc = mgc_process_log(obd, cld);
 		if (rc && rc != -ENOENT)
@@ -284,14 +280,15 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
  * We have one active log per "mount" - client instance or servername.
  * Each instance may be at a different point in the log.
  */
-static int config_log_add(struct obd_device *obd, char *logname,
-			  struct config_llog_instance *cfg,
-			  struct super_block *sb)
+static struct config_llog_data *
+config_log_add(struct obd_device *obd, char *logname,
+	       struct config_llog_instance *cfg, struct super_block *sb)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct config_llog_data *cld;
 	struct config_llog_data *sptlrpc_cld;
 	struct config_llog_data *params_cld;
+	bool locked = false;
 	char			seclogname[32];
 	char			*ptr;
 	int			rc;
@@ -305,7 +302,7 @@ static int config_log_add(struct obd_device *obd, char *logname,
 	ptr = strrchr(logname, '-');
 	if (!ptr || ptr - logname > 8) {
 		CERROR("logname %s is too long\n", logname);
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 	}
 
 	memcpy(seclogname, logname, ptr - logname);
@@ -326,14 +323,14 @@ static int config_log_add(struct obd_device *obd, char *logname,
 		rc = PTR_ERR(params_cld);
 		CERROR("%s: can't create params log: rc = %d\n",
 		       obd->obd_name, rc);
-		goto out_err1;
+		goto out_sptlrpc;
 	}
 
 	cld = do_config_log_add(obd, logname, CONFIG_T_CONFIG, cfg, sb);
 	if (IS_ERR(cld)) {
 		CERROR("can't create log: %s\n", logname);
 		rc = PTR_ERR(cld);
-		goto out_err2;
+		goto out_params;
 	}
 
 	cld->cld_sptlrpc = sptlrpc_cld;
@@ -350,33 +347,52 @@ static int config_log_add(struct obd_device *obd, char *logname,
 			CERROR("%s: sptlrpc log name not correct, %s: rc = %d\n",
 			       obd->obd_name, seclogname, -EINVAL);
 			config_log_put(cld);
-			return -EINVAL;
+			rc = -EINVAL;
+			goto out_cld;
 		}
 		recover_cld = config_recover_log_add(obd, seclogname, cfg, sb);
 		if (IS_ERR(recover_cld)) {
 			rc = PTR_ERR(recover_cld);
-			goto out_err3;
+			goto out_cld;
 		}
+
+		mutex_lock(&cld->cld_lock);
+		locked = true;
 		cld->cld_recover = recover_cld;
 	}
 
-	return 0;
+	if (!locked)
+		mutex_lock(&cld->cld_lock);
+	cld->cld_params = params_cld;
+	cld->cld_sptlrpc = sptlrpc_cld;
+	mutex_unlock(&cld->cld_lock);
+
+	return cld;
 
-out_err3:
+out_cld:
 	config_log_put(cld);
 
-out_err2:
+out_params:
 	config_log_put(params_cld);
 
-out_err1:
+out_sptlrpc:
 	config_log_put(sptlrpc_cld);
 
 out_err:
-	return rc;
+	return ERR_PTR(rc);
 }
 
 static DEFINE_MUTEX(llog_process_lock);
 
+static inline void config_mark_cld_stop(struct config_llog_data *cld)
+{
+	mutex_lock(&cld->cld_lock);
+	spin_lock(&config_list_lock);
+	cld->cld_stopping = 1;
+	spin_unlock(&config_list_lock);
+	mutex_unlock(&cld->cld_lock);
+}
+
 /** Stop watching for updates on this log.
  */
 static int config_log_end(char *logname, struct config_llog_instance *cfg)
@@ -406,36 +422,32 @@ static int config_log_end(char *logname, struct config_llog_instance *cfg)
 		return rc;
 	}
 
+	spin_lock(&config_list_lock);
 	cld->cld_stopping = 1;
+	spin_unlock(&config_list_lock);
 
 	cld_recover = cld->cld_recover;
 	cld->cld_recover = NULL;
+
+	cld_params = cld->cld_params;
+	cld->cld_params = NULL;
+	cld_sptlrpc = cld->cld_sptlrpc;
+	cld->cld_sptlrpc = NULL;
 	mutex_unlock(&cld->cld_lock);
 
 	if (cld_recover) {
-		mutex_lock(&cld_recover->cld_lock);
-		cld_recover->cld_stopping = 1;
-		mutex_unlock(&cld_recover->cld_lock);
+		config_mark_cld_stop(cld_recover);
 		config_log_put(cld_recover);
 	}
 
-	spin_lock(&config_list_lock);
-	cld_sptlrpc = cld->cld_sptlrpc;
-	cld->cld_sptlrpc = NULL;
-	cld_params = cld->cld_params;
-	cld->cld_params = NULL;
-	spin_unlock(&config_list_lock);
-
-	if (cld_sptlrpc)
-		config_log_put(cld_sptlrpc);
-
 	if (cld_params) {
-		mutex_lock(&cld_params->cld_lock);
-		cld_params->cld_stopping = 1;
-		mutex_unlock(&cld_params->cld_lock);
+		config_mark_cld_stop(cld_params);
 		config_log_put(cld_params);
 	}
 
+	if (cld_sptlrpc)
+		config_log_put(cld_sptlrpc);
+
 	/* drop the ref from the find */
 	config_log_put(cld);
 	/* drop the start ref */
@@ -531,11 +543,10 @@ static int mgc_requeue_thread(void *data)
 	/* Keep trying failed locks periodically */
 	spin_lock(&config_list_lock);
 	rq_state |= RQ_RUNNING;
-	while (1) {
+	while (!(rq_state & RQ_STOP)) {
 		struct l_wait_info lwi;
 		struct config_llog_data *cld, *cld_prev;
 		int rand = cfs_rand() & MGC_TIMEOUT_RAND_CENTISEC;
-		int stopped = !!(rq_state & RQ_STOP);
 		int to;
 
 		/* Any new or requeued lostlocks will change the state */
@@ -571,44 +582,40 @@ static int mgc_requeue_thread(void *data)
 		spin_lock(&config_list_lock);
 		rq_state &= ~RQ_PRECLEANUP;
 		list_for_each_entry(cld, &config_llog_list, cld_list_chain) {
-			if (!cld->cld_lostlock)
+			if (!cld->cld_lostlock || cld->cld_stopping)
 				continue;
 
+			/*
+			 * hold reference to avoid being freed during
+			 * subsequent processing.
+			 */
+			config_log_get(cld);
+			cld->cld_lostlock = 0;
 			spin_unlock(&config_list_lock);
 
-			LASSERT(atomic_read(&cld->cld_refcount) > 0);
-
-			/* Whether we enqueued again or not in mgc_process_log,
-			 * we're done with the ref from the old enqueue
-			 */
 			if (cld_prev)
 				config_log_put(cld_prev);
 			cld_prev = cld;
 
-			cld->cld_lostlock = 0;
-			if (likely(!stopped))
+			if (likely(!(rq_state & RQ_STOP))) {
 				do_requeue(cld);
-
-			spin_lock(&config_list_lock);
+				spin_lock(&config_list_lock);
+			} else {
+				spin_lock(&config_list_lock);
+				break;
+			}
 		}
 		spin_unlock(&config_list_lock);
 		if (cld_prev)
 			config_log_put(cld_prev);
 
-		/* break after scanning the list so that we can drop
-		 * refcount to losing lock clds
-		 */
-		if (unlikely(stopped)) {
-			spin_lock(&config_list_lock);
-			break;
-		}
-
 		/* Wait a bit to see if anyone else needs a requeue */
 		lwi = (struct l_wait_info) { 0 };
 		l_wait_event(rq_waitq, rq_state & (RQ_NOW | RQ_STOP),
 			     &lwi);
 		spin_lock(&config_list_lock);
 	}
+
 	/* spinlock and while guarantee RQ_NOW and RQ_LATER are not set */
 	rq_state &= ~RQ_RUNNING;
 	spin_unlock(&config_list_lock);
@@ -624,32 +631,24 @@ static int mgc_requeue_thread(void *data)
  */
 static void mgc_requeue_add(struct config_llog_data *cld)
 {
+	bool wakeup = false;
+
 	CDEBUG(D_INFO, "log %s: requeue (r=%d sp=%d st=%x)\n",
 	       cld->cld_logname, atomic_read(&cld->cld_refcount),
 	       cld->cld_stopping, rq_state);
 	LASSERT(atomic_read(&cld->cld_refcount) > 0);
 
 	mutex_lock(&cld->cld_lock);
-	if (cld->cld_stopping || cld->cld_lostlock) {
-		mutex_unlock(&cld->cld_lock);
-		return;
-	}
-	/* this refcount will be released in mgc_requeue_thread. */
-	config_log_get(cld);
-	cld->cld_lostlock = 1;
-	mutex_unlock(&cld->cld_lock);
-
-	/* Hold lock for rq_state */
 	spin_lock(&config_list_lock);
-	if (rq_state & RQ_STOP) {
-		spin_unlock(&config_list_lock);
-		cld->cld_lostlock = 0;
-		config_log_put(cld);
-	} else {
+	if (!(rq_state & RQ_STOP) && !cld->cld_stopping && !cld->cld_lostlock) {
+		cld->cld_lostlock = 1;
 		rq_state |= RQ_NOW;
-		spin_unlock(&config_list_lock);
-		wake_up(&rq_waitq);
+		wakeup = true;
 	}
+	spin_unlock(&config_list_lock);
+	mutex_unlock(&cld->cld_lock);
+	if (wakeup)
+		wake_up(&rq_waitq);
 }
 
 static int mgc_llog_init(const struct lu_env *env, struct obd_device *obd)
@@ -812,6 +811,8 @@ static int mgc_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 
 		/* held at mgc_process_log(). */
 		LASSERT(atomic_read(&cld->cld_refcount) > 0);
+
+		lock->l_ast_data = NULL;
 		/* Are we done with this log? */
 		if (cld->cld_stopping) {
 			CDEBUG(D_MGC, "log %s: stopping, won't requeue\n",
@@ -1661,16 +1662,18 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 				goto restart;
 			} else {
 				mutex_lock(&cld->cld_lock);
+				spin_lock(&config_list_lock);
 				cld->cld_lostlock = 1;
+				spin_unlock(&config_list_lock);
 			}
 		} else {
 			/* mark cld_lostlock so that it will requeue
 			 * after MGC becomes available.
 			 */
+			spin_lock(&config_list_lock);
 			cld->cld_lostlock = 1;
+			spin_unlock(&config_list_lock);
 		}
-		/* Get extra reference, it will be put in requeue thread */
-		config_log_get(cld);
 	}
 
 	if (cld_is_recover(cld)) {
@@ -1681,7 +1684,9 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 				CERROR("%s: recover log %s failed: rc = %d not fatal.\n",
 				       mgc->obd_name, cld->cld_logname, rc);
 				rc = 0;
+				spin_lock(&config_list_lock);
 				cld->cld_lostlock = 1;
+				spin_unlock(&config_list_lock);
 			}
 		}
 	} else {
@@ -1749,12 +1754,9 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 		       cfg->cfg_last_idx);
 
 		/* We're only called through here on the initial mount */
-		rc = config_log_add(obd, logname, cfg, sb);
-		if (rc)
-			break;
-		cld = config_log_find(logname, cfg);
-		if (!cld) {
-			rc = -ENOENT;
+		cld = config_log_add(obd, logname, cfg, sb);
+		if (IS_ERR(cld)) {
+			rc = PTR_ERR(cld);
 			break;
 		}
 
@@ -1770,11 +1772,15 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 					 imp_connect_data, IMP_RECOV)) {
 				rc = mgc_process_log(obd, cld->cld_recover);
 			} else {
-				struct config_llog_data *cir = cld->cld_recover;
+				struct config_llog_data *cir;
 
+				mutex_lock(&cld->cld_lock);
+				cir = cld->cld_recover;
 				cld->cld_recover = NULL;
+				mutex_unlock(&cld->cld_lock);
 				config_log_put(cir);
 			}
+
 			if (rc)
 				CERROR("Cannot process recover llog %d\n", rc);
 		}
@@ -1792,7 +1798,6 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 				       "%s: can't process params llog: rc = %d\n",
 				       obd->obd_name, rc);
 		}
-		config_log_put(cld);
 
 		break;
 	}
-- 
1.8.3.1
