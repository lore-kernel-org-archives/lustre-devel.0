From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:03 -0500
Subject: [lustre-devel] [PATCH 555/622] lnet: discard ksnn_lock
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-556-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

This lock in 'struct ksock_net' is being taken in places where it
isn't needed, so it is worth cleaning up.

It isn't needed when checking if ksnn_npeers has reached
0 yet, as at that point in the code, the value can only
decrement to zero and then stay there.

It is only needed:
 - to ensure concurrent updates to ksnn_npeers don't race, and
 - to ensure that no more peers are added after the net is shutdown.

The first is best achieved using atomic_t.
The second is more easily achieved by replacing the ksnn_shutdown
flag with a large negative bias on ksnn_npeers, and using
atomic_inc_unless_negative().

So change ksnn_npeers to atomic_t and discard ksnn_lock
and ksnn_shutdown.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: fb983bbebf81 ("LU-12678 lnet: discard ksnn_lock")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36834
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 46 +++++++++++++---------------------------
 net/lnet/klnds/socklnd/socklnd.h |  9 +++++---
 2 files changed, 21 insertions(+), 34 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 3e69d9c..1d0bedb 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -109,9 +109,16 @@
 	LASSERT(id.pid != LNET_PID_ANY);
 	LASSERT(!in_interrupt());
 
+	if (!atomic_inc_unless_negative(&net->ksnn_npeers)) {
+		CERROR("Can't create peer_ni: network shutdown\n");
+		return ERR_PTR(-ESHUTDOWN);
+	}
+
 	peer_ni = kzalloc_cpt(sizeof(*peer_ni), GFP_NOFS, cpt);
-	if (!peer_ni)
+	if (!peer_ni) {
+		atomic_dec(&net->ksnn_npeers);
 		return ERR_PTR(-ENOMEM);
+	}
 
 	peer_ni->ksnp_ni = ni;
 	peer_ni->ksnp_id = id;
@@ -128,20 +135,6 @@
 	INIT_LIST_HEAD(&peer_ni->ksnp_zc_req_list);
 	spin_lock_init(&peer_ni->ksnp_lock);
 
-	spin_lock_bh(&net->ksnn_lock);
-
-	if (net->ksnn_shutdown) {
-		spin_unlock_bh(&net->ksnn_lock);
-
-		kfree(peer_ni);
-		CERROR("Can't create peer_ni: network shutdown\n");
-		return ERR_PTR(-ESHUTDOWN);
-	}
-
-	net->ksnn_npeers++;
-
-	spin_unlock_bh(&net->ksnn_lock);
-
 	return peer_ni;
 }
 
@@ -168,9 +161,7 @@
 	 * do with this peer_ni has been cleaned up when its refcount drops to
 	 * zero.
 	 */
-	spin_lock_bh(&net->ksnn_lock);
-	net->ksnn_npeers--;
-	spin_unlock_bh(&net->ksnn_lock);
+	atomic_dec(&net->ksnn_npeers);
 }
 
 struct ksock_peer_ni *
@@ -464,7 +455,7 @@ struct ksock_peer_ni *
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	/* always called with a ref on ni, so shutdown can't have started */
-	LASSERT(!((struct ksock_net *)ni->ni_data)->ksnn_shutdown);
+	LASSERT(atomic_read(&((struct ksock_net *)ni->ni_data)->ksnn_npeers) >= 0);
 
 	peer2 = ksocknal_find_peer_locked(ni, id);
 	if (peer2) {
@@ -1120,7 +1111,7 @@ struct ksock_peer_ni *
 		write_lock_bh(global_lock);
 
 		/* called with a ref on ni, so shutdown can't have started */
-		LASSERT(!((struct ksock_net *)ni->ni_data)->ksnn_shutdown);
+		LASSERT(atomic_read(&((struct ksock_net *)ni->ni_data)->ksnn_npeers) >= 0);
 
 		peer2 = ksocknal_find_peer_locked(ni, peerid);
 		if (!peer2) {
@@ -2516,30 +2507,24 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	LASSERT(ksocknal_data.ksnd_init == SOCKNAL_INIT_ALL);
 	LASSERT(ksocknal_data.ksnd_nnets > 0);
 
-	spin_lock_bh(&net->ksnn_lock);
-	net->ksnn_shutdown = 1;		/* prevent new peers */
-	spin_unlock_bh(&net->ksnn_lock);
+	/* prevent new peers */
+	atomic_add(SOCKNAL_SHUTDOWN_BIAS, &net->ksnn_npeers);
 
 	/* Delete all peers */
 	ksocknal_del_peer(ni, anyid, 0);
 
 	/* Wait for all peer_ni state to clean up */
 	i = 2;
-	spin_lock_bh(&net->ksnn_lock);
-	while (net->ksnn_npeers) {
-		spin_unlock_bh(&net->ksnn_lock);
-
+	while (atomic_read(&net->ksnn_npeers) > SOCKNAL_SHUTDOWN_BIAS) {
 		i++;
 		CDEBUG(((i & (-i)) == i) ? D_WARNING : D_NET, /* power of 2? */
 		       "waiting for %d peers to disconnect\n",
-		       net->ksnn_npeers);
+		       atomic_read(&net->ksnn_npeers) - SOCKNAL_SHUTDOWN_BIAS);
 		schedule_timeout_uninterruptible(HZ);
 
 		ksocknal_debug_peerhash(ni);
 
-		spin_lock_bh(&net->ksnn_lock);
 	}
-	spin_unlock_bh(&net->ksnn_lock);
 
 	for (i = 0; i < net->ksnn_ninterfaces; i++) {
 		LASSERT(!net->ksnn_interfaces[i].ksni_npeers);
@@ -2691,7 +2676,6 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	if (!net)
 		goto fail_0;
 
-	spin_lock_init(&net->ksnn_lock);
 	net->ksnn_incarnation = ktime_get_real_ns();
 	ni->ni_data = net;
 	net_tunables = &ni->ni_net->net_tunables;
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 1e10663..832bc08 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -166,14 +166,17 @@ struct ksock_tunables {
 
 struct ksock_net {
 	u64			ksnn_incarnation;	/* my epoch */
-	spinlock_t		ksnn_lock;		/* serialise */
 	struct list_head	ksnn_list;		/* chain on global list */
-	int			ksnn_npeers;		/* # peers */
-	int			ksnn_shutdown;		/* shutting down? */
+	atomic_t		ksnn_npeers;		/* # peers */
 	int			ksnn_ninterfaces;	/* IP interfaces */
 	struct ksock_interface	ksnn_interfaces[LNET_INTERFACES_NUM];
 };
 
+/* When the ksock_net is shut down, this bias is added to
+ * ksnn_npeers, which prevents new pears from being added.
+ */
+#define SOCKNAL_SHUTDOWN_BIAS	(INT_MIN + 1)
+
 /** connd timeout */
 #define SOCKNAL_CONND_TIMEOUT	120
 /** reserved thread for accepting & creating new connd */
-- 
1.8.3.1
