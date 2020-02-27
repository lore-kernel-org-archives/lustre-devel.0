From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:09 -0500
Subject: [lustre-devel] [PATCH 621/622] lnet: remove lnd_query interface.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-622-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The ->lnd_query interface is completely unused, and has been since
commit 8e498d3f23ea ("LU-11300 lnet: peer aliveness")

So remove all mention of it.

Fixes: 5cdf0e31a7a9 ("lnet: peer aliveness")
WC-bug-id: https://jira.whamcloud.com/browse/LU-11300
Lustre-commit: 0d816af574b7 ("LU-11300 lnet: remove lnd_query interface.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/37337
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h      |  3 --
 net/lnet/klnds/o2iblnd/o2iblnd.c    | 32 -------------------
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  2 +-
 net/lnet/klnds/socklnd/socklnd.c    | 62 -------------------------------------
 net/lnet/lnet/api-ni.c              |  3 --
 5 files changed, 1 insertion(+), 101 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 3345940..e885131 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -298,9 +298,6 @@ struct lnet_lnd {
 	/* notification of peer down */
 	void (*lnd_notify_peer_down)(lnet_nid_t peer);
 
-	/* query of peer aliveness */
-	void (*lnd_query)(struct lnet_ni *ni, lnet_nid_t peer, time64_t *when);
-
 	/* accept a new connection */
 	int (*lnd_accept)(struct lnet_ni *ni, struct socket *sock);
 };
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 7bf2883..196ea4d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1128,37 +1128,6 @@ static int kiblnd_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg)
 	return rc;
 }
 
-static void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
-{
-	time64_t last_alive = 0;
-	time64_t now = ktime_get_seconds();
-	rwlock_t *glock = &kiblnd_data.kib_global_lock;
-	struct kib_peer_ni *peer_ni;
-	unsigned long flags;
-
-	read_lock_irqsave(glock, flags);
-
-	peer_ni = kiblnd_find_peer_locked(ni, nid);
-	if (peer_ni)
-		last_alive = peer_ni->ibp_last_alive;
-
-	read_unlock_irqrestore(glock, flags);
-
-	if (last_alive)
-		*when = last_alive;
-
-	/*
-	 * peer_ni is not persistent in hash, trigger peer_ni creation
-	 * and connection establishment with a NULL tx
-	 */
-	if (!peer_ni)
-		kiblnd_launch_tx(ni, NULL, nid);
-
-	CDEBUG(D_NET, "peer_ni %s %p, alive %lld secs ago\n",
-	       libcfs_nid2str(nid), peer_ni,
-	       last_alive ? now - last_alive : -1);
-}
-
 static void kiblnd_free_pages(struct kib_pages *p)
 {
 	int npages = p->ibp_npages;
@@ -3125,7 +3094,6 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	.lnd_startup	= kiblnd_startup,
 	.lnd_shutdown	= kiblnd_shutdown,
 	.lnd_ctl	= kiblnd_ctl,
-	.lnd_query	= kiblnd_query,
 	.lnd_send	= kiblnd_send,
 	.lnd_recv	= kiblnd_recv,
 };
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 67780d0..087657c 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2684,7 +2684,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	 * attempts (active or passive) are in progress
 	 * NB: reconnect is still needed even when ibp_tx_queue is
 	 * empty if ibp_version != version because reconnect may be
-	 * initiated by kiblnd_query()
+	 * initiated.
 	 */
 	reconnect = (!list_empty(&peer_ni->ibp_tx_queue) ||
 		     peer_ni->ibp_version != version) &&
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 7abb75a..d967958 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1789,67 +1789,6 @@ struct ksock_peer_ni *
 	 */
 }
 
-void
-ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when)
-{
-	int connect = 1;
-	time64_t last_alive = 0;
-	time64_t now = ktime_get_seconds();
-	struct ksock_peer_ni *peer_ni = NULL;
-	rwlock_t *glock = &ksocknal_data.ksnd_global_lock;
-	struct lnet_process_id id = {
-		.nid = nid,
-		.pid = LNET_PID_LUSTRE,
-	};
-
-	read_lock(glock);
-
-	peer_ni = ksocknal_find_peer_locked(ni, id);
-	if (peer_ni) {
-		struct ksock_conn *conn;
-		int bufnob;
-
-		list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
-			bufnob = conn->ksnc_sock->sk->sk_wmem_queued;
-
-			if (bufnob < conn->ksnc_tx_bufnob) {
-				/* something got ACKed */
-				conn->ksnc_tx_deadline = ktime_get_seconds() +
-							 lnet_get_lnd_timeout();
-				peer_ni->ksnp_last_alive = now;
-				conn->ksnc_tx_bufnob = bufnob;
-			}
-		}
-
-		last_alive = peer_ni->ksnp_last_alive;
-		if (!ksocknal_find_connectable_route_locked(peer_ni))
-			connect = 0;
-	}
-
-	read_unlock(glock);
-
-	if (last_alive)
-		*when = last_alive * HZ;
-
-	CDEBUG(D_NET, "peer_ni %s %p, alive %lld secs ago, connect %d\n",
-	       libcfs_nid2str(nid), peer_ni,
-	       last_alive ? now - last_alive : -1,
-	       connect);
-
-	if (!connect)
-		return;
-
-	ksocknal_add_peer(ni, id, LNET_NIDADDR(nid), lnet_acceptor_port());
-
-	write_lock_bh(glock);
-
-	peer_ni = ksocknal_find_peer_locked(ni, id);
-	if (peer_ni)
-		ksocknal_launch_all_connections_locked(peer_ni);
-
-	write_unlock_bh(glock);
-}
-
 static void
 ksocknal_push_peer(struct ksock_peer_ni *peer_ni)
 {
@@ -2775,7 +2714,6 @@ static void __exit ksocklnd_exit(void)
 	.lnd_send		= ksocknal_send,
 	.lnd_recv		= ksocknal_recv,
 	.lnd_notify_peer_down	= ksocknal_notify_gw_down,
-	.lnd_query		= ksocknal_query,
 	.lnd_accept		= ksocknal_accept,
 };
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 8f59266..ea23471 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2304,9 +2304,6 @@ static void lnet_push_target_fini(void)
 		if (rc < 0)
 			goto failed1;
 
-		LASSERT(ni->ni_net->net_tunables.lct_peer_timeout <= 0 ||
-			ni->ni_net->net_lnd->lnd_query);
-
 		lnet_ni_addref(ni);
 		list_add_tail(&ni->ni_netlist, &local_ni_list);
 
-- 
1.8.3.1
