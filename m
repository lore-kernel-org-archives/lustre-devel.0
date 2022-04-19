Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 02DF6C433F5
	for <lustre-devel@archiver.kernel.org>; Tue, 19 Apr 2022 00:31:37 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8211A427620;
	Mon, 18 Apr 2022 17:31:18 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 00706423F77
 for <lustre-devel@lists.lustre.org>; Mon, 18 Apr 2022 17:31:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 325241005C94;
 Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2B58EDB14A; Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 18 Apr 2022 20:31:03 -0400
Message-Id: <1650328264-8763-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
References: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 6/7] lnet: ln_api_mutex deadlocks
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

LNetNIFini() acquires the ln_api_mutex and holds onto it throughout
various shutdown routines. Meanwhile, LND threads (via
lnet_nid2peerni_locked()) or the discovery thread (via
lnet_peer_data_present()) may need to acquire this mutex in order to
progress.

Address these potential deadlocks by setting the_lnet.ln_state to
LNET_STATE_STOPPING earlier in LNetNIFini(), and release the mutex
prior to any call into LND module or before any wait.

LNetNIInit() is modified to return -ESHUTDOWN if it finds that there
is a concurrent shutdown in progress.

HPE-bug-id: LUS-10681
WC-bug-id: https://jira.whamcloud.com/browse/LU-15616
Lustre-commit: 22de0bd145b649768 ("LU-15616 lnet: ln_api_mutex deadlocks")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/46727
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c   | 40 +++++++++++++++++++++++++++++++++++-----
 net/lnet/lnet/lib-move.c |  2 ++
 net/lnet/lnet/peer.c     | 11 ++++++++---
 3 files changed, 45 insertions(+), 8 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 1978905..44d5014 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2244,14 +2244,16 @@ static void lnet_push_target_fini(void)
 		islo = ni->ni_net->net_lnd->lnd_type == LOLND;
 
 		LASSERT(!in_interrupt());
-		/* Holding the mutex makes it safe for lnd_shutdown
+		/* Holding the LND mutex makes it safe for lnd_shutdown
 		 * to call module_put(). Module unload cannot finish
 		 * until lnet_unregister_lnd() completes, and that
-		 * requires the mutex.
+		 * requires the LND mutex.
 		 */
+		mutex_unlock(&the_lnet.ln_api_mutex);
 		mutex_lock(&the_lnet.ln_lnd_mutex);
 		net->net_lnd->lnd_shutdown(ni);
 		mutex_unlock(&the_lnet.ln_lnd_mutex);
+		mutex_lock(&the_lnet.ln_api_mutex);
 
 		if (!islo)
 			CDEBUG(D_LNI, "Removed LNI %s\n",
@@ -2323,7 +2325,8 @@ static void lnet_push_target_fini(void)
 	/* NB called holding the global mutex */
 
 	/* All quiet on the API front */
-	LASSERT(the_lnet.ln_state == LNET_STATE_RUNNING);
+	LASSERT(the_lnet.ln_state == LNET_STATE_RUNNING ||
+		the_lnet.ln_state == LNET_STATE_STOPPING);
 	LASSERT(!the_lnet.ln_refcount);
 
 	lnet_net_lock(LNET_LOCK_EX);
@@ -2823,6 +2826,11 @@ void lnet_lib_exit(void)
 
 	CDEBUG(D_OTHER, "refs %d\n", the_lnet.ln_refcount);
 
+	if (the_lnet.ln_state == LNET_STATE_STOPPING) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return -ESHUTDOWN;
+	}
+
 	if (the_lnet.ln_refcount > 0) {
 		rc = the_lnet.ln_refcount++;
 		mutex_unlock(&the_lnet.ln_api_mutex);
@@ -2968,6 +2976,10 @@ void lnet_lib_exit(void)
 	} else {
 		LASSERT(!the_lnet.ln_niinit_self);
 
+		lnet_net_lock(LNET_LOCK_EX);
+		the_lnet.ln_state = LNET_STATE_STOPPING;
+		lnet_net_unlock(LNET_LOCK_EX);
+
 		lnet_fault_fini();
 		lnet_router_debugfs_fini();
 		lnet_monitor_thr_stop();
@@ -3433,6 +3445,10 @@ static int lnet_handle_legacy_ip2nets(char *ip2nets,
 	lnet_set_tune_defaults(tun);
 
 	mutex_lock(&the_lnet.ln_api_mutex);
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
+		rc = -ESHUTDOWN;
+		goto out;
+	}
 	while ((net = list_first_entry_or_null(&net_head,
 					       struct lnet_net,
 					       net_list)) != NULL) {
@@ -3498,8 +3514,10 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 	lnet_set_tune_defaults(tun);
 
 	mutex_lock(&the_lnet.ln_api_mutex);
-
-	rc = lnet_add_net_common(net, tun);
+	if (the_lnet.ln_state != LNET_STATE_RUNNING)
+		rc = -ESHUTDOWN;
+	else
+		rc = lnet_add_net_common(net, tun);
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
@@ -3522,6 +3540,10 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		return -EINVAL;
 
 	mutex_lock(&the_lnet.ln_api_mutex);
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
+		rc = -ESHUTDOWN;
+		goto unlock_api_mutex;
+	}
 
 	lnet_net_lock(0);
 
@@ -3615,6 +3637,10 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		return rc == 0 ? -EINVAL : rc;
 
 	mutex_lock(&the_lnet.ln_api_mutex);
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
+		rc = -ESHUTDOWN;
+		goto out_unlock_clean;
+	}
 
 	if (rc > 1) {
 		rc = -EINVAL; /* only add one network per call */
@@ -3668,6 +3694,10 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		return -EINVAL;
 
 	mutex_lock(&the_lnet.ln_api_mutex);
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
+		rc = -ESHUTDOWN;
+		goto out;
+	}
 
 	lnet_net_lock(0);
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 0b3986e..0496bf5 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3872,7 +3872,9 @@ void lnet_monitor_thr_stop(void)
 	complete(&the_lnet.ln_mt_wait_complete);
 
 	/* block until monitor thread signals that it's done */
+	mutex_unlock(&the_lnet.ln_api_mutex);
 	wait_for_completion(&the_lnet.ln_mt_signal);
+	mutex_lock(&the_lnet.ln_api_mutex);
 	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN);
 
 	/* perform cleanup tasks */
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 98f71dd..714326a 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3244,12 +3244,15 @@ static int lnet_peer_deletion(struct lnet_peer *lp)
 	if (lp->lp_state & LNET_PEER_MARK_DELETED)
 		return 0;
 
-	if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING)
-		return -ESHUTDOWN;
-
 	spin_unlock(&lp->lp_lock);
 
 	mutex_lock(&the_lnet.ln_api_mutex);
+	if (the_lnet.ln_state != LNET_STATE_RUNNING ||
+	    the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		spin_lock(&lp->lp_lock);
+		return -ESHUTDOWN;
+	}
 
 	lnet_net_lock(LNET_LOCK_EX);
 	/* remove the peer from the discovery work
@@ -3929,8 +3932,10 @@ void lnet_peer_discovery_stop(void)
 	else
 		wake_up(&the_lnet.ln_dc_waitq);
 
+	mutex_unlock(&the_lnet.ln_api_mutex);
 	wait_event(the_lnet.ln_dc_waitq,
 		   the_lnet.ln_dc_state == LNET_DC_STATE_SHUTDOWN);
+	mutex_lock(&the_lnet.ln_api_mutex);
 
 	LASSERT(list_empty(&the_lnet.ln_dc_request));
 	LASSERT(list_empty(&the_lnet.ln_dc_working));
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
