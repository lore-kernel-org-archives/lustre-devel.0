From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:06 -0500
Subject: [lustre-devel] [PATCH 618/622] lnet: use LIST_HEAD() for local
 lists.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-619-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

When declaring a local list head, instead of

   struct list_head list;
   INIT_LIST_HEAD(&list);

use
   LIST_HEAD(list);

which does both steps.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 135b5c0009e5 ("LU-9679 lnet: use LIST_HEAD() for local lists.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36954
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  7 ++-----
 net/lnet/klnds/socklnd/socklnd_cb.c |  3 +--
 net/lnet/lnet/api-ni.c              | 20 +++++---------------
 net/lnet/lnet/config.c              | 28 ++++++++--------------------
 net/lnet/lnet/lib-move.c            | 30 ++++++++----------------------
 net/lnet/lnet/net_fault.c           | 14 ++++----------
 net/lnet/lnet/peer.c                |  8 ++------
 net/lnet/lnet/router.c              | 15 ++++-----------
 net/lnet/selftest/console.c         |  4 +---
 9 files changed, 35 insertions(+), 94 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index f769a45..67780d0 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1384,11 +1384,9 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 {
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
 	char *reason = NULL;
-	struct list_head txs;
+	LIST_HEAD(txs);
 	unsigned long flags;
 
-	INIT_LIST_HEAD(&txs);
-
 	write_lock_irqsave(glock, flags);
 	if (!peer_ni->ibp_reconnecting) {
 		if (peer_ni->ibp_accepting)
@@ -2218,7 +2216,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 {
 	struct kib_peer_ni *peer_ni = conn->ibc_peer;
 	struct kib_tx *tx;
-	struct list_head txs;
+	LIST_HEAD(txs);
 	unsigned long flags;
 	int active;
 
@@ -2277,7 +2275,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	}
 
 	/* grab pending txs while I have the lock */
-	INIT_LIST_HEAD(&txs);
 	list_splice_init(&peer_ni->ibp_tx_queue, &txs);
 
 	if (!kiblnd_peer_active(peer_ni) ||	/* peer_ni has been deleted */
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index fb933e3..66b0ac7 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -2491,14 +2491,13 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	wait_queue_entry_t wait;
 	struct ksock_conn *conn;
 	struct ksock_sched *sched;
-	struct list_head enomem_conns;
+	LIST_HEAD(enomem_conns);
 	int nenomem_conns;
 	time64_t timeout;
 	int i;
 	int peer_index = 0;
 	time64_t deadline = ktime_get_seconds();
 
-	INIT_LIST_HEAD(&enomem_conns);
 	init_waitqueue_entry(&wait, current);
 
 	spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index b9c38f3..8f59266 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2062,11 +2062,9 @@ static void lnet_push_target_fini(void)
 lnet_shutdown_lndnets(void)
 {
 	struct lnet_net *net;
-	struct list_head resend;
+	LIST_HEAD(resend);
 	struct lnet_msg *msg, *tmp;
 
-	INIT_LIST_HEAD(&resend);
-
 	/* NB called holding the global mutex */
 
 	/* All quiet on the API front */
@@ -2202,7 +2200,7 @@ static void lnet_push_target_fini(void)
 {
 	struct lnet_ni *ni;
 	struct lnet_net *net_l = NULL;
-	struct list_head local_ni_list;
+	LIST_HEAD(local_ni_list);
 	int ni_count = 0;
 	u32 lnd_type;
 	struct lnet_lnd *lnd;
@@ -2214,8 +2212,6 @@ static void lnet_push_target_fini(void)
 	int peerrtrcredits =
 		net->net_tunables.lct_peer_rtr_credits;
 
-	INIT_LIST_HEAD(&local_ni_list);
-
 	/*
 	 * make sure that this net is unique. If it isn't then
 	 * we are adding interfaces to an already existing network, and
@@ -2509,11 +2505,9 @@ void lnet_lib_exit(void)
 	int ni_count;
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_handle_md ping_mdh;
-	struct list_head net_head;
+	LIST_HEAD(net_head);
 	struct lnet_net *net;
 
-	INIT_LIST_HEAD(&net_head);
-
 	mutex_lock(&the_lnet.ln_api_mutex);
 
 	CDEBUG(D_OTHER, "refs %d\n", the_lnet.ln_refcount);
@@ -3098,9 +3092,7 @@ static int lnet_handle_legacy_ip2nets(char *ip2nets,
 	struct lnet_net *net;
 	char *nets;
 	int rc;
-	struct list_head net_head;
-
-	INIT_LIST_HEAD(&net_head);
+	LIST_HEAD(net_head);
 
 	rc = lnet_parse_ip2nets(&nets, ip2nets);
 	if (rc < 0)
@@ -3282,13 +3274,11 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 lnet_dyn_add_net(struct lnet_ioctl_config_data *conf)
 {
 	struct lnet_net *net;
-	struct list_head net_head;
+	LIST_HEAD(net_head);
 	int rc;
 	struct lnet_ioctl_config_lnd_tunables tun;
 	char *nets = conf->cfg_config_u.cfg_net.net_intf;
 
-	INIT_LIST_HEAD(&net_head);
-
 	/* Create a net/ni structures for the network string */
 	rc = lnet_parse_networks(&net_head, nets, use_tcp_bonding);
 	if (rc <= 0)
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index f50df88..9d3813c 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -889,14 +889,12 @@ struct lnet_ni *
 static int
 lnet_str2tbs_sep(struct list_head *tbs, char *str)
 {
-	struct list_head pending;
+	LIST_HEAD(pending);
 	char *sep;
 	int nob;
 	int i;
 	struct lnet_text_buf *ltb;
 
-	INIT_LIST_HEAD(&pending);
-
 	/* Split 'str' into separate commands */
 	for (;;) {
 		/* skip leading whitespace */
@@ -973,7 +971,7 @@ struct lnet_ni *
 lnet_str2tbs_expand(struct list_head *tbs, char *str)
 {
 	char num[16];
-	struct list_head pending;
+	LIST_HEAD(pending);
 	char *sep;
 	char *sep2;
 	char *parsed;
@@ -985,8 +983,6 @@ struct lnet_ni *
 	int nob;
 	int scanned;
 
-	INIT_LIST_HEAD(&pending);
-
 	sep = strchr(str, '[');
 	if (!sep)			/* nothing to expand */
 		return 0;
@@ -1097,8 +1093,8 @@ struct lnet_ni *
 {
 	/* static scratch buffer OK (single threaded) */
 	static char cmd[LNET_SINGLE_TEXTBUF_NOB];
-	struct list_head nets;
-	struct list_head gateways;
+	LIST_HEAD(nets);
+	LIST_HEAD(gateways);
 	struct list_head *tmp1;
 	struct list_head *tmp2;
 	u32 net;
@@ -1114,9 +1110,6 @@ struct lnet_ni *
 	int got_hops = 0;
 	unsigned int priority = 0;
 
-	INIT_LIST_HEAD(&gateways);
-	INIT_LIST_HEAD(&nets);
-
 	/* save a copy of the string for error messages */
 	strncpy(cmd, str, sizeof(cmd));
 	cmd[sizeof(cmd) - 1] = '\0';
@@ -1260,13 +1253,11 @@ struct lnet_ni *
 int
 lnet_parse_routes(char *routes, int *im_a_router)
 {
-	struct list_head tbs;
+	LIST_HEAD(tbs);
 	int rc = 0;
 
 	*im_a_router = 0;
 
-	INIT_LIST_HEAD(&tbs);
-
 	if (lnet_str2tbs_sep(&tbs, routes) < 0) {
 		CERROR("Error parsing routes\n");
 		rc = -EINVAL;
@@ -1453,9 +1444,9 @@ struct lnet_ni *
 {
 	static char networks[LNET_SINGLE_TEXTBUF_NOB];
 	static char source[LNET_SINGLE_TEXTBUF_NOB];
-	struct list_head raw_entries;
-	struct list_head matched_nets;
-	struct list_head current_nets;
+	LIST_HEAD(raw_entries);
+	LIST_HEAD(matched_nets);
+	LIST_HEAD(current_nets);
 	struct list_head *t;
 	struct list_head *t2;
 	struct lnet_text_buf *tb;
@@ -1467,15 +1458,12 @@ struct lnet_ni *
 	int dup;
 	int rc;
 
-	INIT_LIST_HEAD(&raw_entries);
 	if (lnet_str2tbs_sep(&raw_entries, ip2nets) < 0) {
 		CERROR("Error parsing ip2nets\n");
 		LASSERT(!lnet_tbnob);
 		return -EINVAL;
 	}
 
-	INIT_LIST_HEAD(&matched_nets);
-	INIT_LIST_HEAD(&current_nets);
 	networks[0] = 0;
 	count = 0;
 	len = 0;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index cd36d52..cd7ac7f 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -166,7 +166,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_test_peer *tp;
 	struct list_head *el;
 	struct list_head *next;
-	struct list_head cull;
+	LIST_HEAD(cull);
 
 	/* NB: use lnet_net_lock(0) to serialize operations on test peers */
 	if (threshold) {
@@ -184,9 +184,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		return 0;
 	}
 
-	/* removing entries */
-	INIT_LIST_HEAD(&cull);
-
 	lnet_net_lock(0);
 
 	list_for_each_safe(el, next, &the_lnet.ln_test_peers) {
@@ -216,11 +213,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_test_peer *tp;
 	struct list_head *el;
 	struct list_head *next;
-	struct list_head cull;
+	LIST_HEAD(cull);
 	int fail = 0;
 
-	INIT_LIST_HEAD(&cull);
-
 	/* NB: use lnet_net_lock(0) to serialize operations on test peers */
 	lnet_net_lock(0);
 
@@ -2620,7 +2615,6 @@ struct lnet_mt_event_info {
 lnet_finalize_expired_responses(void)
 {
 	struct lnet_libmd *md;
-	struct list_head local_queue;
 	struct lnet_rsp_tracker *rspt, *tmp;
 	ktime_t now;
 	int i;
@@ -2629,7 +2623,7 @@ struct lnet_mt_event_info {
 		return;
 
 	cfs_cpt_for_each(i, lnet_cpt_table()) {
-		INIT_LIST_HEAD(&local_queue);
+		LIST_HEAD(local_queue);
 
 		lnet_net_lock(i);
 		if (!the_lnet.ln_mt_rstq[i]) {
@@ -2856,8 +2850,8 @@ struct lnet_mt_event_info {
 lnet_recover_local_nis(void)
 {
 	struct lnet_mt_event_info *ev_info;
-	struct list_head processed_list;
-	struct list_head local_queue;
+	LIST_HEAD(processed_list);
+	LIST_HEAD(local_queue);
 	struct lnet_handle_md mdh;
 	struct lnet_ni *tmp;
 	struct lnet_ni *ni;
@@ -2865,9 +2859,6 @@ struct lnet_mt_event_info {
 	int healthv;
 	int rc;
 
-	INIT_LIST_HEAD(&local_queue);
-	INIT_LIST_HEAD(&processed_list);
-
 	/* splice the recovery queue on a local queue. We will iterate
 	 * through the local queue and update it as needed. Once we're
 	 * done with the traversal, we'll splice the local queue back on
@@ -3091,11 +3082,9 @@ struct lnet_mt_event_info {
 lnet_clean_resendqs(void)
 {
 	struct lnet_msg *msg, *tmp;
-	struct list_head msgs;
+	LIST_HEAD(msgs);
 	int i;
 
-	INIT_LIST_HEAD(&msgs);
-
 	cfs_cpt_for_each(i, lnet_cpt_table()) {
 		lnet_net_lock(i);
 		list_splice_init(the_lnet.ln_mt_resendqs[i], &msgs);
@@ -3114,8 +3103,8 @@ struct lnet_mt_event_info {
 lnet_recover_peer_nis(void)
 {
 	struct lnet_mt_event_info *ev_info;
-	struct list_head processed_list;
-	struct list_head local_queue;
+	LIST_HEAD(processed_list);
+	LIST_HEAD(local_queue);
 	struct lnet_handle_md mdh;
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer_ni *tmp;
@@ -3123,9 +3112,6 @@ struct lnet_mt_event_info {
 	int healthv;
 	int rc;
 
-	INIT_LIST_HEAD(&local_queue);
-	INIT_LIST_HEAD(&processed_list);
-
 	/* Always use cpt 0 for locking across all interactions with
 	 * ln_mt_peerNIRecovq
 	 */
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index 8408e93..515aa05 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -201,11 +201,9 @@ struct lnet_drop_rule {
 {
 	struct lnet_drop_rule *rule;
 	struct lnet_drop_rule *tmp;
-	struct list_head zombies;
+	LIST_HEAD(zombies);
 	int n = 0;
 
-	INIT_LIST_HEAD(&zombies);
-
 	lnet_net_lock(LNET_LOCK_EX);
 	list_for_each_entry_safe(rule, tmp, &the_lnet.ln_drop_rules, dr_link) {
 		if (rule->dr_attr.fa_src != src && src)
@@ -725,9 +723,8 @@ struct delay_daemon_data {
 lnet_delay_rule_check(void)
 {
 	struct lnet_delay_rule *rule;
-	struct list_head msgs;
+	LIST_HEAD(msgs);
 
-	INIT_LIST_HEAD(&msgs);
 	while (1) {
 		if (list_empty(&delay_dd.dd_sched_rules))
 			break;
@@ -886,14 +883,11 @@ struct delay_daemon_data {
 {
 	struct lnet_delay_rule *rule;
 	struct lnet_delay_rule *tmp;
-	struct list_head rule_list;
-	struct list_head msg_list;
+	LIST_HEAD(rule_list);
+	LIST_HEAD(msg_list);
 	int n = 0;
 	bool cleanup;
 
-	INIT_LIST_HEAD(&rule_list);
-	INIT_LIST_HEAD(&msg_list);
-
 	if (shutdown) {
 		src = 0;
 		dst = 0;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 0d7fbd4..b76ff94 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1912,9 +1912,7 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 {
 	struct lnet_msg *msg, *tmp;
 	int rc = 0;
-	struct list_head pending_msgs;
-
-	INIT_LIST_HEAD(&pending_msgs);
+	LIST_HEAD(pending_msgs);
 
 	CDEBUG(D_NET, "Discovery complete. Dequeue peer %s\n",
 	       libcfs_nid2str(lp->lp_primary_nid));
@@ -3238,11 +3236,9 @@ static int lnet_peer_discovery_wait_for_work(void)
 static void lnet_resend_msgs(void)
 {
 	struct lnet_msg *msg, *tmp;
-	struct list_head resend;
+	LIST_HEAD(resend);
 	int rc;
 
-	INIT_LIST_HEAD(&resend);
-
 	spin_lock(&the_lnet.ln_msg_resend_lock);
 	list_splice(&the_lnet.ln_msg_resend, &resend);
 	spin_unlock(&the_lnet.ln_msg_resend_lock);
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 7ba406a..69df212 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -717,19 +717,16 @@ static void lnet_shuffle_seed(void)
 int
 lnet_del_route(u32 net, lnet_nid_t gw_nid)
 {
-	struct list_head rnet_zombies;
+	LIST_HEAD(rnet_zombies);
 	struct lnet_remotenet *rnet;
 	struct lnet_remotenet *tmp;
 	struct list_head *rn_list;
 	struct lnet_peer_ni *lpni;
 	struct lnet_route *route;
-	struct list_head zombies;
+	LIST_HEAD(zombies);
 	struct lnet_peer *lp = NULL;
 	int i = 0;
 
-	INIT_LIST_HEAD(&rnet_zombies);
-	INIT_LIST_HEAD(&zombies);
-
 	CDEBUG(D_NET, "Del route: net %s : gw %s\n",
 	       libcfs_net2str(net), libcfs_nid2str(gw_nid));
 
@@ -1152,14 +1149,12 @@ bool lnet_router_checker_active(void)
 lnet_rtrpool_free_bufs(struct lnet_rtrbufpool *rbp, int cpt)
 {
 	int npages = rbp->rbp_npages;
-	struct list_head tmp;
+	LIST_HEAD(tmp);
 	struct lnet_rtrbuf *rb;
 
 	if (!rbp->rbp_nbuffers) /* not initialized or already freed */
 		return;
 
-	INIT_LIST_HEAD(&tmp);
-
 	lnet_net_lock(cpt);
 	list_splice_init(&rbp->rbp_msgs, &tmp);
 	lnet_drop_routed_msgs_locked(&tmp, cpt);
@@ -1181,7 +1176,7 @@ bool lnet_router_checker_active(void)
 static int
 lnet_rtrpool_adjust_bufs(struct lnet_rtrbufpool *rbp, int nbufs, int cpt)
 {
-	struct list_head rb_list;
+	LIST_HEAD(rb_list);
 	struct lnet_rtrbuf *rb;
 	int num_rb;
 	int num_buffers = 0;
@@ -1213,8 +1208,6 @@ bool lnet_router_checker_active(void)
 	rbp->rbp_req_nbuffers = nbufs;
 	lnet_net_unlock(cpt);
 
-	INIT_LIST_HEAD(&rb_list);
-
 	/*
 	 * allocate the buffers on a local list first.  If all buffers are
 	 * allocated successfully then join this list to the rbp buffer
diff --git a/net/lnet/selftest/console.c b/net/lnet/selftest/console.c
index 9f32c1f..cc2c61d 100644
--- a/net/lnet/selftest/console.c
+++ b/net/lnet/selftest/console.c
@@ -1484,12 +1484,10 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 lstcon_ndlist_stat(struct list_head *ndlist,
 		   int timeout, struct list_head __user *result_up)
 {
-	struct list_head head;
+	LIST_HEAD(head);
 	struct lstcon_rpc_trans *trans;
 	int rc;
 
-	INIT_LIST_HEAD(&head);
-
 	rc = lstcon_rpc_trans_ndlist(ndlist, &head,
 				     LST_TRANS_STATQRY, NULL, NULL, &trans);
 	if (rc) {
-- 
1.8.3.1
