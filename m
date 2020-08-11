From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:18 -0400
Subject: [lustre-devel] [PATCH 22/23] lnet: Have LNet routers monitor the
 ni_fatal flag
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <chris.horn@hpe.com>

Have the LNet monitor thread on LNet routers check the
ni_fatal_error_on flag to set local NI status appropriately. When
this results in a status change, perform a discovery push to all
peers. This allows peers to update their route status appropriately.

HPE-bug-id: LUS-9068
WC-bug-id: https://jira.whamcloud.com/browse/LU-13782
Lustre-commit: 7e0ec0f809ea1 ("LU-13782 lnet: Have LNet routers monitor the ni_fatal flag")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39353
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 29 +++++++++++++++++++++++++++++
 net/lnet/lnet/lib-move.c      |  6 +-----
 net/lnet/lnet/router.c        | 35 ++++++++++++++++++++++++-----------
 3 files changed, 54 insertions(+), 16 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 299ecf5..d2a39f6 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -98,6 +98,35 @@
 extern struct kmem_cache *lnet_rspt_cachep;
 extern struct kmem_cache *lnet_msg_cachep;
 
+static inline bool
+lnet_ni_set_status_locked(struct lnet_ni *ni, u32 status)
+__must_hold(&ni->ni_lock)
+{
+	bool update = false;
+
+	if (ni->ni_status && ni->ni_status->ns_status != status) {
+		CDEBUG(D_NET, "ni %s status changed from %#x to %#x\n",
+		       libcfs_nid2str(ni->ni_nid),
+		       ni->ni_status->ns_status, status);
+		ni->ni_status->ns_status = status;
+		update = true;
+	}
+
+	return update;
+}
+
+static inline bool
+lnet_ni_set_status(struct lnet_ni *ni, u32 status)
+{
+	bool update;
+
+	spin_lock(&ni->ni_lock);
+	update = lnet_ni_set_status_locked(ni, status);
+	spin_unlock(&ni->ni_lock);
+
+	return update;
+}
+
 bool lnet_is_route_alive(struct lnet_route *route);
 bool lnet_is_gateway_alive(struct lnet_peer *gw);
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 85b6453..f521817 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4012,11 +4012,7 @@ void lnet_monitor_thr_stop(void)
 		spin_lock(&ni->ni_net->net_lock);
 		ni->ni_net->net_last_alive = ktime_get_real_seconds();
 		spin_unlock(&ni->ni_net->net_lock);
-		if (ni->ni_status &&
-		    ni->ni_status->ns_status == LNET_NI_STATUS_DOWN) {
-			ni->ni_status->ns_status = LNET_NI_STATUS_UP;
-			push = true;
-		}
+		push = lnet_ni_set_status_locked(ni, LNET_NI_STATUS_UP);
 		lnet_ni_unlock(ni);
 	}
 
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index e3b3e71..1253e4c 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1014,15 +1014,9 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	struct lnet_ni *ni;
 	bool update = false;
 
-	list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-		lnet_ni_lock(ni);
-		if (ni->ni_status &&
-		    ni->ni_status->ns_status != status) {
-			ni->ni_status->ns_status = status;
+	list_for_each_entry(ni, &net->net_ni_list, ni_netlist)
+		if (lnet_ni_set_status(ni, status))
 			update = true;
-		}
-		lnet_ni_unlock(ni);
-	}
 
 	return update;
 }
@@ -1031,6 +1025,7 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 lnet_update_ni_status_locked(void)
 {
 	struct lnet_net *net;
+	struct lnet_ni *ni;
 	bool push = false;
 	time64_t now;
 	time64_t timeout;
@@ -1045,13 +1040,13 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 			continue;
 
 		if (now < net->net_last_alive + timeout)
-			continue;
+			goto check_ni_fatal;
 
 		spin_lock(&net->net_lock);
 		/* re-check with lock */
 		if (now < net->net_last_alive + timeout) {
 			spin_unlock(&net->net_lock);
-			continue;
+			goto check_ni_fatal;
 		}
 		spin_unlock(&net->net_lock);
 
@@ -1059,7 +1054,25 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 		 * timeout on any of its constituent NIs, then mark all
 		 * the NIs down.
 		 */
-		push = lnet_net_set_status_locked(net, LNET_NI_STATUS_DOWN);
+		if (lnet_net_set_status_locked(net, LNET_NI_STATUS_DOWN)) {
+			push = true;
+			continue;
+		}
+
+check_ni_fatal:
+		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+			/* lnet_ni_set_status() will perform the same check of
+			 * ni_status while holding the ni lock. We can safely
+			 * check ni_status without that lock because it is only
+			 * written to under net_lock/EX and our caller is
+			 * holding a net lock.
+			 */
+			if (atomic_read(&ni->ni_fatal_error_on) &&
+			    ni->ni_status &&
+			    ni->ni_status->ns_status != LNET_NI_STATUS_DOWN &&
+			    lnet_ni_set_status(ni, LNET_NI_STATUS_DOWN))
+				push = true;
+		}
 	}
 
 	return push;
-- 
1.8.3.1
