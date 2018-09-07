From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:31 +1000
Subject: [lustre-devel] [PATCH 03/34] lnet: struct lnet_ni: move ni_lnd to
 lnet_net
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137133.8267.15885218437939976879.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Also make some other minor changes to the structures.

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |   13 ++++++++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    2 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    4 ++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   16 ++++++++--------
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   16 ++++++++--------
 drivers/staging/lustre/lnet/lnet/lo.c              |    2 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   10 +++++-----
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +-
 9 files changed, 35 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index ead8a4e1125a..e170eb07a5bf 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -262,12 +262,17 @@ struct lnet_net {
 	 * shouldn't be reset
 	 */
 	bool			  net_tunables_set;
+	/* procedural interface */
+	struct lnet_lnd		*net_lnd;
 };
 
 struct lnet_ni {
-	spinlock_t		  ni_lock;
-	struct list_head	  ni_list;	/* chain on ln_nis */
-	struct list_head	  ni_cptlist;	/* chain on ln_nis_cpt */
+	/* chain on ln_nis */
+	struct list_head	  ni_list;
+	/* chain on ln_nis_cpt */
+	struct list_head	ni_cptlist;
+
+	spinlock_t		ni_lock;
 
 	/* number of CPTs */
 	int			ni_ncpts;
@@ -281,8 +286,6 @@ struct lnet_ni {
 	/* instance-specific data */
 	void			*ni_data;
 
-	struct lnet_lnd		 *ni_lnd;	/* procedural interface */
-
 	/* percpt TX queues */
 	struct lnet_tx_queue	**ni_tx_queues;
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 0d17e22c4401..5e1592b398c1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2830,7 +2830,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	int rc;
 	int newdev;
 
-	LASSERT(ni->ni_lnd == &the_o2iblnd);
+	LASSERT(ni->ni_net->net_lnd == &the_o2iblnd);
 
 	if (kiblnd_data.kib_init == IBLND_INIT_NOTHING) {
 		rc = kiblnd_base_startup();
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 4ad885f10235..2036a0ae5917 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2726,7 +2726,7 @@ ksocknal_startup(struct lnet_ni *ni)
 	int rc;
 	int i;
 
-	LASSERT(ni->ni_lnd == &the_ksocklnd);
+	LASSERT(ni->ni_net->net_lnd == &the_ksocklnd);
 
 	if (ksocknal_data.ksnd_init == SOCKNAL_INIT_NOTHING) {
 		rc = ksocknal_base_startup();
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 3ae3ca1311a1..f8c921f0221c 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -306,7 +306,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 		return -EPERM;
 	}
 
-	if (!ni->ni_lnd->lnd_accept) {
+	if (!ni->ni_net->net_lnd->lnd_accept) {
 		/* This catches a request for the loopback LND */
 		lnet_ni_decref(ni);
 		LCONSOLE_ERROR_MSG(0x121, "Refusing connection from %pI4h for %s: NI doesn not accept IP connections\n",
@@ -317,7 +317,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 	CDEBUG(D_NET, "Accept %s from %pI4h\n",
 	       libcfs_nid2str(cr.acr_nid), &peer_ip);
 
-	rc = ni->ni_lnd->lnd_accept(ni, sock);
+	rc = ni->ni_net->net_lnd->lnd_accept(ni, sock);
 
 	lnet_ni_decref(ni);
 	return rc;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index cd4189fa7acb..0896e75bc3d7 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -799,7 +799,7 @@ lnet_count_acceptor_nis(void)
 
 	cpt = lnet_net_lock_current();
 	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
-		if (ni->ni_lnd->lnd_accept)
+		if (ni->ni_net->net_lnd->lnd_accept)
 			count++;
 	}
 
@@ -1098,13 +1098,13 @@ lnet_clear_zombies_nis_locked(void)
 			continue;
 		}
 
-		ni->ni_lnd->lnd_refcount--;
+		ni->ni_net->net_lnd->lnd_refcount--;
 		lnet_net_unlock(LNET_LOCK_EX);
 
-		islo = ni->ni_lnd->lnd_type == LOLND;
+		islo = ni->ni_net->net_lnd->lnd_type == LOLND;
 
 		LASSERT(!in_interrupt());
-		ni->ni_lnd->lnd_shutdown(ni);
+		ni->ni_net->net_lnd->lnd_shutdown(ni);
 
 		/*
 		 * can't deref lnd anymore now; it might have unregistered
@@ -1248,7 +1248,7 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 	lnd->lnd_refcount++;
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	ni->ni_lnd = lnd;
+	ni->ni_net->net_lnd = lnd;
 
 	if (conf && conf->cfg_hdr.ioc_len > sizeof(*conf))
 		lnd_tunables = (struct lnet_ioctl_config_lnd_tunables *)conf->cfg_bulk;
@@ -1794,7 +1794,7 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
 	if (rc)
 		goto failed1;
 
-	if (ni->ni_lnd->lnd_accept) {
+	if (ni->ni_net->net_lnd->lnd_accept) {
 		rc = lnet_acceptor_start();
 		if (rc < 0) {
 			/* shutdown the ni that we just started */
@@ -2074,10 +2074,10 @@ LNetCtl(unsigned int cmd, void *arg)
 		if (!ni)
 			return -EINVAL;
 
-		if (!ni->ni_lnd->lnd_ctl)
+		if (!ni->ni_net->net_lnd->lnd_ctl)
 			rc = -EINVAL;
 		else
-			rc = ni->ni_lnd->lnd_ctl(ni, cmd, arg);
+			rc = ni->ni_net->net_lnd->lnd_ctl(ni, cmd, arg);
 
 		lnet_ni_decref(ni);
 		return rc;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index f186e6a16d34..1bf12af87a20 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -406,7 +406,7 @@ lnet_ni_recv(struct lnet_ni *ni, void *private, struct lnet_msg *msg,
 		iov_iter_bvec(&to, ITER_BVEC | READ, kiov, niov, mlen + offset);
 		iov_iter_advance(&to, offset);
 	}
-	rc = ni->ni_lnd->lnd_recv(ni, private, msg, delayed, &to, rlen);
+	rc = ni->ni_net->net_lnd->lnd_recv(ni, private, msg, delayed, &to, rlen);
 	if (rc < 0)
 		lnet_finalize(ni, msg, rc);
 }
@@ -461,7 +461,7 @@ lnet_ni_send(struct lnet_ni *ni, struct lnet_msg *msg)
 	LASSERT(LNET_NETTYP(LNET_NIDNET(ni->ni_nid)) == LOLND ||
 		(msg->msg_txcredit && msg->msg_peertxcredit));
 
-	rc = ni->ni_lnd->lnd_send(ni, priv, msg);
+	rc = ni->ni_net->net_lnd->lnd_send(ni, priv, msg);
 	if (rc < 0)
 		lnet_finalize(ni, msg, rc);
 }
@@ -474,10 +474,10 @@ lnet_ni_eager_recv(struct lnet_ni *ni, struct lnet_msg *msg)
 	LASSERT(!msg->msg_sending);
 	LASSERT(msg->msg_receiving);
 	LASSERT(!msg->msg_rx_ready_delay);
-	LASSERT(ni->ni_lnd->lnd_eager_recv);
+	LASSERT(ni->ni_net->net_lnd->lnd_eager_recv);
 
 	msg->msg_rx_ready_delay = 1;
-	rc = ni->ni_lnd->lnd_eager_recv(ni, msg->msg_private, msg,
+	rc = ni->ni_net->net_lnd->lnd_eager_recv(ni, msg->msg_private, msg,
 					&msg->msg_private);
 	if (rc) {
 		CERROR("recv from %s / send to %s aborted: eager_recv failed %d\n",
@@ -496,10 +496,10 @@ lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer *lp)
 	time64_t last_alive = 0;
 
 	LASSERT(lnet_peer_aliveness_enabled(lp));
-	LASSERT(ni->ni_lnd->lnd_query);
+	LASSERT(ni->ni_net->net_lnd->lnd_query);
 
 	lnet_net_unlock(lp->lp_cpt);
-	ni->ni_lnd->lnd_query(ni, lp->lp_nid, &last_alive);
+	ni->ni_net->net_lnd->lnd_query(ni, lp->lp_nid, &last_alive);
 	lnet_net_lock(lp->lp_cpt);
 
 	lp->lp_last_query = ktime_get_seconds();
@@ -1287,7 +1287,7 @@ lnet_parse_put(struct lnet_ni *ni, struct lnet_msg *msg)
 	info.mi_roffset	= hdr->msg.put.offset;
 	info.mi_mbits	= hdr->msg.put.match_bits;
 
-	msg->msg_rx_ready_delay = !ni->ni_lnd->lnd_eager_recv;
+	msg->msg_rx_ready_delay = !ni->ni_net->net_lnd->lnd_eager_recv;
 	ready_delay = msg->msg_rx_ready_delay;
 
  again:
@@ -1518,7 +1518,7 @@ lnet_parse_forward_locked(struct lnet_ni *ni, struct lnet_msg *msg)
 
 	if (msg->msg_rxpeer->lp_rtrcredits <= 0 ||
 	    lnet_msg2bufpool(msg)->rbp_credits <= 0) {
-		if (!ni->ni_lnd->lnd_eager_recv) {
+		if (!ni->ni_net->net_lnd->lnd_eager_recv) {
 			msg->msg_rx_ready_delay = 1;
 		} else {
 			lnet_net_unlock(msg->msg_rx_cpt);
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index eb14146bd879..8167980c2323 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -83,7 +83,7 @@ lolnd_shutdown(struct lnet_ni *ni)
 static int
 lolnd_startup(struct lnet_ni *ni)
 {
-	LASSERT(ni->ni_lnd == &the_lolnd);
+	LASSERT(ni->ni_net->net_lnd == &the_lolnd);
 	LASSERT(!lolnd_instanced);
 	lolnd_instanced = 1;
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 7d61c5d71426..0c0ec0b27982 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -154,14 +154,14 @@ lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer *lp)
 		lp->lp_notifylnd = 0;
 		lp->lp_notify    = 0;
 
-		if (notifylnd && ni->ni_lnd->lnd_notify) {
+		if (notifylnd && ni->ni_net->net_lnd->lnd_notify) {
 			lnet_net_unlock(lp->lp_cpt);
 
 			/*
 			 * A new notification could happen now; I'll handle it
 			 * when control returns to me
 			 */
-			ni->ni_lnd->lnd_notify(ni, lp->lp_nid, alive);
+			ni->ni_net->net_lnd->lnd_notify(ni, lp->lp_nid, alive);
 
 			lnet_net_lock(lp->lp_cpt);
 		}
@@ -380,8 +380,8 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 		lnet_net_unlock(LNET_LOCK_EX);
 
 		/* XXX Assume alive */
-		if (ni->ni_lnd->lnd_notify)
-			ni->ni_lnd->lnd_notify(ni, gateway, 1);
+		if (ni->ni_net->net_lnd->lnd_notify)
+			ni->ni_net->net_lnd->lnd_notify(ni, gateway, 1);
 
 		lnet_net_lock(LNET_LOCK_EX);
 	}
@@ -818,7 +818,7 @@ lnet_update_ni_status_locked(void)
 
 	now = ktime_get_real_seconds();
 	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
-		if (ni->ni_lnd->lnd_type == LOLND)
+		if (ni->ni_net->net_lnd->lnd_type == LOLND)
 			continue;
 
 		if (now < ni->ni_last_alive + timeout)
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 19cea7076057..f3ccd6a2b70e 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -674,7 +674,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 				last_alive = now - ni->ni_last_alive;
 
 			/* @lo forever alive */
-			if (ni->ni_lnd->lnd_type == LOLND)
+			if (ni->ni_net->net_lnd->lnd_type == LOLND)
 				last_alive = 0;
 
 			lnet_ni_lock(ni);
