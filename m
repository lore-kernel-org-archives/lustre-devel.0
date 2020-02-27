From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:40 -0500
Subject: [lustre-devel] [PATCH 352/622] lnet: push router interface updates
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-353-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

A router can bring up/down its interfaces if it hasn't received any
messages on that interface for a configurable period
(alive_router_ping_timeout). When this even occures the router can now
push its status change to the peers it's talking to in order to inform
them of the change in its status. This will allow the router users to
handle asym router failures quicker.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11664
Lustre-commit: 0fa02a7d81e7 ("LU-11664 lnet: push router interface updates")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33651
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 18 ++++++++++++------
 net/lnet/lnet/router.c   | 13 +++++++++++--
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 0ff1d38..d6cbcd1 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3840,16 +3840,17 @@ void lnet_monitor_thr_stop(void)
 lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
 	   void *private, int rdma_req)
 {
-	int rc = 0;
-	int cpt;
-	int for_me;
+	struct lnet_peer_ni *lpni;
 	struct lnet_msg *msg;
+	u32 payload_length;
 	lnet_pid_t dest_pid;
 	lnet_nid_t dest_nid;
 	lnet_nid_t src_nid;
-	struct lnet_peer_ni *lpni;
-	u32 payload_length;
+	bool push = false;
+	int for_me;
 	u32 type;
+	int rc = 0;
+	int cpt;
 
 	LASSERT(!in_interrupt());
 
@@ -3907,11 +3908,16 @@ void lnet_monitor_thr_stop(void)
 		lnet_ni_lock(ni);
 		ni->ni_last_alive = ktime_get_real_seconds();
 		if (ni->ni_status &&
-		    ni->ni_status->ns_status == LNET_NI_STATUS_DOWN)
+		    ni->ni_status->ns_status == LNET_NI_STATUS_DOWN) {
 			ni->ni_status->ns_status = LNET_NI_STATUS_UP;
+			push = true;
+		}
 		lnet_ni_unlock(ni);
 	}
 
+	if (push)
+		lnet_push_update_to_peers(1);
+
 	/*
 	 * Regard a bad destination NID as a protocol error.  Senders should
 	 * know what they're doing; if they don't they're misconfigured, buggy
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index eb36df5..0a396d9 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -742,10 +742,11 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 }
 
-static void
+static bool
 lnet_update_ni_status_locked(void)
 {
 	struct lnet_ni *ni = NULL;
+	bool push = false;
 	time64_t now;
 	time64_t timeout;
 
@@ -778,9 +779,12 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 			 * NI status to "down"
 			 */
 			ni->ni_status->ns_status = LNET_NI_STATUS_DOWN;
+			push = true;
 		}
 		lnet_ni_unlock(ni);
 	}
+
+	return push;
 }
 
 void lnet_wait_router_start(void)
@@ -817,6 +821,7 @@ bool lnet_router_checker_active(void)
 {
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer *rtr;
+	bool push = false;
 	u64 version;
 	time64_t now;
 	int cpt;
@@ -883,9 +888,13 @@ bool lnet_router_checker_active(void)
 	}
 
 	if (the_lnet.ln_routing)
-		lnet_update_ni_status_locked();
+		push = lnet_update_ni_status_locked();
 
 	lnet_net_unlock(cpt);
+
+	/* if the status of the ni changed update the peers */
+	if (push)
+		lnet_push_update_to_peers(1);
 }
 
 void
-- 
1.8.3.1
