From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:43 -0500
Subject: [lustre-devel] [PATCH 415/622] lnet: Sync the start of discovery
 and monitor threads
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-416-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

The discovery thread starts up before the monitor thread so it may
issue PUTs or GETs before the monitor thread has a chance to
initialize its data structures (namely the_lnet.ln_mt_rstq). This can
result in an OOPs when we attempt to attach response trackers to MDs.

Introduce a completion to synchronize the startup of these threads.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12537
Lustre-commit: 9283e2ed6655 ("LU-12537 lnet: Sync the start of discovery and monitor threads")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35478
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  5 +++++
 net/lnet/lnet/api-ni.c         |  3 +++
 net/lnet/lnet/lib-move.c       |  1 +
 net/lnet/lnet/peer.c           | 11 ++++++++++-
 4 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index b240361..1009a69 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -1161,6 +1161,11 @@ struct lnet {
 	/* recovery eq handler */
 	struct lnet_handle_eq		ln_mt_eqh;
 
+	/*
+	 * Completed when the discovery and monitor threads can enter their
+	 * work loops
+	 */
+	struct completion		ln_started;
 };
 
 #endif
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 65f1f17..aa5ca52 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1062,6 +1062,7 @@ struct lnet_libhandle *
 	INIT_LIST_HEAD(&the_lnet.ln_mt_peerNIRecovq);
 	init_waitqueue_head(&the_lnet.ln_dc_waitq);
 	LNetInvalidateEQHandle(&the_lnet.ln_mt_eqh);
+	init_completion(&the_lnet.ln_started);
 
 	rc = lnet_descriptor_setup();
 	if (rc != 0)
@@ -2583,6 +2584,8 @@ void lnet_lib_exit(void)
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
+	complete_all(&the_lnet.ln_started);
+
 	/* wait for all routers to start */
 	lnet_wait_router_start();
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 9a4c426..413397c 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3529,6 +3529,7 @@ void lnet_monitor_thr_stop(void)
 
 	lnet_build_msg_event(msg, LNET_EVENT_PUT);
 
+	wait_for_completion(&the_lnet.ln_started);
 	/*
 	 * Must I ACK?  If so I'll grab the ack_wmd out of the header and put
 	 * it back into the ACK during lnet_finalize()
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index b0ca1de..49da7a1 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3258,6 +3258,8 @@ static int lnet_peer_discovery(void *arg)
 	struct lnet_peer *lp;
 	int rc;
 
+	wait_for_completion(&the_lnet.ln_started);
+
 	CDEBUG(D_NET, "started\n");
 
 	for (;;) {
@@ -3429,7 +3431,14 @@ void lnet_peer_discovery_stop(void)
 
 	LASSERT(the_lnet.ln_dc_state == LNET_DC_STATE_RUNNING);
 	the_lnet.ln_dc_state = LNET_DC_STATE_STOPPING;
-	wake_up(&the_lnet.ln_dc_waitq);
+
+	/* In the LNetNIInit() path we may be stopping discovery before it
+	 * entered its work loop
+	 */
+	if (!completion_done(&the_lnet.ln_started))
+		complete(&the_lnet.ln_started);
+	else
+		wake_up(&the_lnet.ln_dc_waitq);
 
 	wait_event(the_lnet.ln_dc_waitq,
 		   the_lnet.ln_dc_state == LNET_DC_STATE_SHUTDOWN);
-- 
1.8.3.1
