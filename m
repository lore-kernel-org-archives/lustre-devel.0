Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FD3CC433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4777561260
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4777561260
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AE14921F9AE;
	Sun, 25 Apr 2021 13:09:40 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4585121F7F8
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4FA4C10087D6;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4E88669A7E; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:34 -0400
Message-Id: <1619381316-7719-28-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 27/29] lustre: various: only use
 wake_up_all() on exclusive waitqs
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

wake_up_all() is not necessary of wait_queues which are not the
subject of an exclusive waiter.  When all waiters are non-exclusive,
wake_up() will wake them all up.

Use of wake_up_all() suggests to the reader that the queue is subject
to exclusive waits.  When that is not the case, the usage can cause
confusion.

So change all wake_up_all() on non-exclusive waitqueues to wake_up().

The only wait_queues on which exclusive waits are requested are:
ws_waitq         ibs_waitq        kss_waitq         ksnd_connd_waitq
blp_waitq        imp_replay_waitq cl_mod_rpcs_waitq cl_cache_waiters
cl_destroy_waitq scp_waitq

All others now only use wake_up().

WC-bug-id: https://jira.whamcloud.com/browse/LU-14352
Lustre-commit: 1f4e9f0f4f483dc9 ("LU-14352 various: only use wake_up_all() on exclusive waitqs")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41289
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lock.c       | 6 +++---
 fs/lustre/llite/pcc.c            | 2 +-
 fs/lustre/lov/lov_io.c           | 4 ++--
 fs/lustre/mdc/mdc_changelog.c    | 8 ++++----
 fs/lustre/obdclass/cl_io.c       | 2 +-
 fs/lustre/obdclass/lu_object.c   | 2 +-
 fs/lustre/osc/osc_io.c           | 2 +-
 fs/lustre/osc/osc_page.c         | 6 +++---
 fs/lustre/ptlrpc/sec_bulk.c      | 2 +-
 fs/lustre/ptlrpc/service.c       | 2 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c | 4 ++--
 net/lnet/klnds/socklnd/socklnd.c | 4 ++--
 net/lnet/lnet/peer.c             | 2 +-
 13 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index c872455..8201e28 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1217,7 +1217,7 @@ void ldlm_lock_fail_match_locked(struct ldlm_lock *lock)
 {
 	if ((lock->l_flags & LDLM_FL_FAIL_NOTIFIED) == 0) {
 		lock->l_flags |= LDLM_FL_FAIL_NOTIFIED;
-		wake_up_all(&lock->l_waitq);
+		wake_up(&lock->l_waitq);
 	}
 }
 
@@ -1231,7 +1231,7 @@ void ldlm_lock_fail_match_locked(struct ldlm_lock *lock)
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock)
 {
 	ldlm_set_lvb_ready(lock);
-	wake_up_all(&lock->l_waitq);
+	wake_up(&lock->l_waitq);
 }
 EXPORT_SYMBOL(ldlm_lock_allow_match_locked);
 
@@ -1752,7 +1752,7 @@ void ldlm_cancel_callback(struct ldlm_lock *lock)
 		}
 		/* only canceller can set bl_done bit */
 		ldlm_set_bl_done(lock);
-		wake_up_all(&lock->l_waitq);
+		wake_up(&lock->l_waitq);
 	} else if (!ldlm_is_bl_done(lock)) {
 		/*
 		 * The lock is guaranteed to have been canceled once
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 297189c9..b259fa5 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1566,7 +1566,7 @@ static void pcc_io_fini(struct inode *inode)
 
 	LASSERT(pcci && atomic_read(&pcci->pcci_active_ios) > 0);
 	if (atomic_dec_and_test(&pcci->pcci_active_ios))
-		wake_up_all(&pcci->pcci_waitq);
+		wake_up(&pcci->pcci_waitq);
 }
 
 ssize_t pcc_file_read_iter(struct kiocb *iocb,
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 7da0047..1d5ea41 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -651,7 +651,7 @@ static void lov_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 
 	LASSERT(atomic_read(&lov->lo_active_ios) > 0);
 	if (atomic_dec_and_test(&lov->lo_active_ios))
-		wake_up_all(&lov->lo_waitq);
+		wake_up(&lov->lo_waitq);
 }
 
 static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
@@ -1674,7 +1674,7 @@ static void lov_empty_io_fini(const struct lu_env *env,
 	struct lov_object *lov = cl2lov(ios->cis_obj);
 
 	if (atomic_dec_and_test(&lov->lo_active_ios))
-		wake_up_all(&lov->lo_waitq);
+		wake_up(&lov->lo_waitq);
 }
 
 static int lov_empty_io_submit(const struct lu_env *env,
diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index f671f465..ef6d4f9 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -256,7 +256,7 @@ static int chlg_read_cat_process_cb(const struct lu_env *env,
 	crs->crs_rec_count++;
 	mutex_unlock(&crs->crs_lock);
 
-	wake_up_all(&crs->crs_waitq_cons);
+	wake_up(&crs->crs_waitq_cons);
 
 	return 0;
 }
@@ -347,7 +347,7 @@ static int chlg_load(void *args)
 	if (rc < 0)
 		crs->crs_err = rc;
 
-	wake_up_all(&crs->crs_waitq_cons);
+	wake_up(&crs->crs_waitq_cons);
 
 	if (llh)
 		llog_cat_close(NULL, llh);
@@ -420,7 +420,7 @@ static ssize_t chlg_read(struct file *file, char __user *buff, size_t count,
 
 	if (written_total > 0) {
 		rc = written_total;
-		wake_up_all(&crs->crs_waitq_prod);
+		wake_up(&crs->crs_waitq_prod);
 	} else if (rc == 0) {
 		rc = crs->crs_err;
 	}
@@ -464,7 +464,7 @@ static int chlg_set_start_offset(struct chlg_reader_state *crs, u64 offset)
 	}
 
 	mutex_unlock(&crs->crs_lock);
-	wake_up_all(&crs->crs_waitq_prod);
+	wake_up(&crs->crs_waitq_prod);
 	return 0;
 }
 
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 27804d3..ca4d387 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1187,7 +1187,7 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		 * the wakeup ensures cl_sync_io_wait() doesn't complete
 		 * before the wakeup completes.
 		 */
-		wake_up_all_locked(&anchor->csi_waitq);
+		wake_up_locked(&anchor->csi_waitq);
 		if (end_io)
 			end_io(env, anchor);
 		if (anchor->csi_aio)
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index fcf0739..419cb74 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -398,7 +398,7 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 	}
 
 	if (waitqueue_active(wq))
-		wake_up_all(wq);
+		wake_up(wq);
 }
 
 /**
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 3be3cfe..ce64cf8 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -437,7 +437,7 @@ void osc_io_iter_fini(const struct lu_env *env,
 		oio->oi_is_active = 0;
 		LASSERT(atomic_read(&osc->oo_nr_ios) > 0);
 		if (atomic_dec_and_test(&osc->oo_nr_ios))
-			wake_up_all(&osc->oo_io_waitq);
+			wake_up(&osc->oo_io_waitq);
 	}
 }
 EXPORT_SYMBOL(osc_io_iter_fini);
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index c59a5ac..8b25329a 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -679,7 +679,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	atomic_dec(&cli->cl_lru_shrinkers);
 	if (count > 0) {
 		atomic_long_add(count, cli->cl_lru_left);
-		wake_up_all(&osc_lru_waitq);
+		wake_up(&osc_lru_waitq);
 	}
 	return count > 0 ? count : rc;
 }
@@ -890,7 +890,7 @@ unsigned long osc_lru_reserve(struct client_obd *cli, unsigned long npages)
 void osc_lru_unreserve(struct client_obd *cli, unsigned long npages)
 {
 	atomic_long_add(npages, cli->cl_lru_left);
-	wake_up_all(&osc_lru_waitq);
+	wake_up(&osc_lru_waitq);
 }
 
 /**
@@ -987,7 +987,7 @@ void osc_dec_unstable_pages(struct ptlrpc_request *req)
 						&cli->cl_cache->ccc_unstable_nr);
 	LASSERT(unstable_count >= 0);
 	if (!unstable_count)
-		wake_up_all(&cli->cl_cache->ccc_unstable_waitq);
+		wake_up(&cli->cl_cache->ccc_unstable_waitq);
 
 	if (waitqueue_active(&osc_lru_waitq))
 		(void)ptlrpcd_queue_work(cli->cl_lru_work);
diff --git a/fs/lustre/ptlrpc/sec_bulk.c b/fs/lustre/ptlrpc/sec_bulk.c
index 9548721..ef127b8 100644
--- a/fs/lustre/ptlrpc/sec_bulk.c
+++ b/fs/lustre/ptlrpc/sec_bulk.c
@@ -304,7 +304,7 @@ static inline void enc_pools_wakeup(void)
 
 	if (unlikely(page_pools.epp_waitqlen)) {
 		LASSERT(waitqueue_active(&page_pools.epp_waitq));
-		wake_up_all(&page_pools.epp_waitq);
+		wake_up(&page_pools.epp_waitq);
 	}
 }
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 070eecc..1057892 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -2465,7 +2465,7 @@ static void ptlrpc_stop_hr_threads(void)
 		if (!hrp->hrp_thrs)
 			continue; /* uninitialized */
 		for (j = 0; j < hrp->hrp_nthrs; j++)
-			wake_up_all(&hrp->hrp_thrs[j].hrt_waitq);
+			wake_up(&hrp->hrp_thrs[j].hrt_waitq);
 	}
 
 	cfs_percpt_for_each(hrp, i, ptlrpc_hr.hr_partitions) {
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 782e29b..0c43969 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2520,8 +2520,8 @@ static void kiblnd_base_shutdown(void)
 		cfs_percpt_for_each(sched, i, kiblnd_data.kib_scheds)
 			wake_up_all(&sched->ibs_waitq);
 
-		wake_up_all(&kiblnd_data.kib_connd_waitq);
-		wake_up_all(&kiblnd_data.kib_failover_waitq);
+		wake_up(&kiblnd_data.kib_connd_waitq);
+		wake_up(&kiblnd_data.kib_failover_waitq);
 
 		wait_var_event_warning(&kiblnd_data.kib_nthreads,
 				       !atomic_read(&kiblnd_data.kib_nthreads),
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 141da88..54c5e2c 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1799,12 +1799,12 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		/* flag threads to terminate; wake and wait for them to die */
 		ksocknal_data.ksnd_shuttingdown = 1;
 		wake_up_all(&ksocknal_data.ksnd_connd_waitq);
-		wake_up_all(&ksocknal_data.ksnd_reaper_waitq);
+		wake_up(&ksocknal_data.ksnd_reaper_waitq);
 
 		if (ksocknal_data.ksnd_schedulers) {
 			cfs_percpt_for_each(sched, i,
 					    ksocknal_data.ksnd_schedulers)
-					wake_up_all(&sched->kss_waitq);
+					    wake_up_all(&sched->kss_waitq);
 		}
 
 		wait_var_event_warning(&ksocknal_data.ksnd_nthreads,
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index c833e34..36e52df 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2131,7 +2131,7 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 	spin_lock(&lp->lp_lock);
 	list_splice_init(&lp->lp_dc_pendq, &pending_msgs);
 	spin_unlock(&lp->lp_lock);
-	wake_up_all(&lp->lp_dc_waitq);
+	wake_up(&lp->lp_dc_waitq);
 
 	if (lp->lp_rtr_refcount > 0)
 		lnet_router_discovery_complete(lp);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
