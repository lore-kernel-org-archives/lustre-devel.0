From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:05 -0500
Subject: [lustre-devel] [PATCH 317/622] lnet: clean mt_eqh properly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-318-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

There is a scenario where you have a peer on your recovery queue
that's down. So you keep pinging it, but every ping times out
after 10 seconds. In the middle of these 10 seconds you perform a
shutdown. First you try to do the rsp_tracker_clean. It goes through
and calls MDUnlink on the MD related to that ping. But because the
message has a ref count on the MD, it doesn't go away. The MD gets
zombied. And just waits for lnet_md_unlink to be called in
lnet_finalize(). Then you hit clean_peer_ni_recovery. We see the peer
on the queue, we try to call Unlink on it, but when we lookup the
MD using lnet_handle2md() we can't find it. Afterwards we try to clean
up the EQ and it asserts. Even if we remove the assert we end up with
a resource leak since the EQ is not actually freed since we won't call
LNetEQFree() again.

The solution is to pull the EQ create in the LNetNIInit() and deletion
happens in lnet_unprepare. By this point all the remaining messages
would've been finalized and all references on the EQ are gone,
allowing us to clean it up properly

WC-bug-id: https://jira.whamcloud.com/browse/LU-12080
Lustre-commit: 1065c8888e96 ("LU-12080 lnet: clean mt_eqh properly")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34477
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  2 ++
 net/lnet/lnet/api-ni.c        | 15 +++++++++++++++
 net/lnet/lnet/lib-eq.c        |  2 --
 net/lnet/lnet/lib-move.c      | 13 +------------
 4 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index a6e64f6..10922ae 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -513,6 +513,8 @@ struct lnet_ni *
 int lnet_lib_init(void);
 void lnet_lib_exit(void);
 
+void lnet_mt_event_handler(struct lnet_event *event);
+
 int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, int alive,
 		time64_t when);
 void lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index e5f5c6c..1388bd4 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1059,6 +1059,7 @@ struct lnet_libhandle *
 	INIT_LIST_HEAD(&the_lnet.ln_mt_localNIRecovq);
 	INIT_LIST_HEAD(&the_lnet.ln_mt_peerNIRecovq);
 	init_waitqueue_head(&the_lnet.ln_dc_waitq);
+	LNetInvalidateEQHandle(&the_lnet.ln_mt_eqh);
 
 	rc = lnet_descriptor_setup();
 	if (rc != 0)
@@ -1126,6 +1127,8 @@ struct lnet_libhandle *
 static int
 lnet_unprepare(void)
 {
+	int rc;
+
 	/*
 	 * NB no LNET_LOCK since this is the last reference.  All LND instances
 	 * have shut down already, so it is safe to unlink and free all
@@ -1138,6 +1141,12 @@ struct lnet_libhandle *
 	LASSERT(list_empty(&the_lnet.ln_test_peers));
 	LASSERT(list_empty(&the_lnet.ln_nets));
 
+	if (!LNetEQHandleIsInvalid(the_lnet.ln_mt_eqh)) {
+		rc = LNetEQFree(the_lnet.ln_mt_eqh);
+		LNetInvalidateEQHandle(&the_lnet.ln_mt_eqh);
+		LASSERT(rc == 0);
+	}
+
 	lnet_portals_destroy();
 
 	if (the_lnet.ln_md_containers) {
@@ -2503,6 +2512,12 @@ void lnet_lib_exit(void)
 
 	lnet_ping_target_update(pbuf, ping_mdh);
 
+	rc = LNetEQAlloc(0, lnet_mt_event_handler, &the_lnet.ln_mt_eqh);
+	if (rc != 0) {
+		CERROR("Can't allocate monitor thread EQ: %d\n", rc);
+		goto err_stop_ping;
+	}
+
 	rc = lnet_monitor_thr_start();
 	if (rc)
 		goto err_stop_ping;
diff --git a/net/lnet/lnet/lib-eq.c b/net/lnet/lnet/lib-eq.c
index 3d99f0a..01b8ee3 100644
--- a/net/lnet/lnet/lib-eq.c
+++ b/net/lnet/lnet/lib-eq.c
@@ -164,8 +164,6 @@
 	int size = 0;
 	int i;
 
-	LASSERT(the_lnet.ln_refcount > 0);
-
 	lnet_res_lock(LNET_LOCK_EX);
 	/*
 	 * NB: hold lnet_eq_wait_lock for EQ link/unlink, so we can do
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index a6df9ba..7c135c4 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3254,7 +3254,7 @@ struct lnet_mt_event_info {
 	}
 }
 
-static void
+void
 lnet_mt_event_handler(struct lnet_event *event)
 {
 	struct lnet_mt_event_info *ev_info = event->md.user_ptr;
@@ -3333,12 +3333,6 @@ int lnet_monitor_thr_start(void)
 	if (rc)
 		goto clean_queues;
 
-	rc = LNetEQAlloc(0, lnet_mt_event_handler, &the_lnet.ln_mt_eqh);
-	if (rc != 0) {
-		CERROR("Can't allocate monitor thread EQ: %d\n", rc);
-		goto clean_queues;
-	}
-
 	/* Pre monitor thread start processing */
 	rc = lnet_router_pre_mt_start();
 	if (rc)
@@ -3371,7 +3365,6 @@ int lnet_monitor_thr_start(void)
 	lnet_clean_local_ni_recoveryq();
 	lnet_clean_peer_ni_recoveryq();
 	lnet_clean_resendqs();
-	LNetEQFree(the_lnet.ln_mt_eqh);
 	LNetInvalidateEQHandle(&the_lnet.ln_mt_eqh);
 	return rc;
 clean_queues:
@@ -3384,8 +3377,6 @@ int lnet_monitor_thr_start(void)
 
 void lnet_monitor_thr_stop(void)
 {
-	int rc;
-
 	if (the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN)
 		return;
 
@@ -3405,8 +3396,6 @@ void lnet_monitor_thr_stop(void)
 	lnet_clean_local_ni_recoveryq();
 	lnet_clean_peer_ni_recoveryq();
 	lnet_clean_resendqs();
-	rc = LNetEQFree(the_lnet.ln_mt_eqh);
-	LASSERT(rc == 0);
 }
 
 void
-- 
1.8.3.1
