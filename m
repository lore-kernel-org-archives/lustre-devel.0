From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:03 -0500
Subject: [lustre-devel] [PATCH 05/11] staging: lustre: remove unnecessary
	blank lines reported by checkpatch.pl
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove any useless blank lines reported by checkpatch.pl
for LNet layer.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/nidstr.h |    3 +++
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    6 ------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 --
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    6 ------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    4 ----
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 --
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    1 -
 drivers/staging/lustre/lnet/lnet/config.c          |    6 ------
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    1 -
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    2 --
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    1 -
 drivers/staging/lustre/lnet/lnet/router.c          |    1 -
 drivers/staging/lustre/lnet/selftest/brw_test.c    |    1 -
 drivers/staging/lustre/lnet/selftest/console.c     |    1 -
 14 files changed, 3 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index 9a705e1..937fcc9 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -69,6 +69,7 @@ static inline char *libcfs_lnd2str(__u32 lnd)
 	return libcfs_lnd2str_r(lnd, libcfs_next_nidstring(),
 				LNET_NIDSTR_SIZE);
 }
+
 int libcfs_str2lnd(const char *str);
 char *libcfs_net2str_r(__u32 net, char *buf, size_t buf_size);
 static inline char *libcfs_net2str(__u32 net)
@@ -76,12 +77,14 @@ static inline char *libcfs_net2str(__u32 net)
 	return libcfs_net2str_r(net, libcfs_next_nidstring(),
 				LNET_NIDSTR_SIZE);
 }
+
 char *libcfs_nid2str_r(lnet_nid_t nid, char *buf, size_t buf_size);
 static inline char *libcfs_nid2str(lnet_nid_t nid)
 {
 	return libcfs_nid2str_r(nid, libcfs_next_nidstring(),
 				LNET_NIDSTR_SIZE);
 }
+
 __u32 libcfs_str2net(const char *str);
 lnet_nid_t libcfs_str2nid(const char *str);
 int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 8ad128c..09eaecd 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -399,7 +399,6 @@ kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid)
 	kib_peer_t *peer;
 
 	list_for_each(tmp, peer_list) {
-
 		peer = list_entry(tmp, kib_peer_t, ibp_list);
 
 		LASSERT(peer->ibp_connecting > 0 || /* creating conns */
@@ -439,9 +438,7 @@ static int kiblnd_get_peer_info(lnet_ni_t *ni, int index,
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
-
 		list_for_each(ptmp, &kiblnd_data.kib_peers[i]) {
-
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
 			LASSERT(peer->ibp_connecting > 0 ||
 				peer->ibp_accepting > 0 ||
@@ -554,7 +551,6 @@ static kib_conn_t *kiblnd_get_conn_by_idx(lnet_ni_t *ni, int index)
 
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
 		list_for_each(ptmp, &kiblnd_data.kib_peers[i]) {
-
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
 			LASSERT(peer->ibp_connecting > 0 ||
 				peer->ibp_accepting > 0 ||
@@ -992,7 +988,6 @@ static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
 
 	for (i = lo; i <= hi; i++) {
 		list_for_each_safe(ptmp, pnxt, &kiblnd_data.kib_peers[i]) {
-
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
 			LASSERT(peer->ibp_connecting > 0 ||
 				peer->ibp_accepting > 0 ||
@@ -1584,7 +1579,6 @@ int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
 		CDEBUG(D_NET, "Another thread is allocating new FMR pool, waiting for her to complete\n");
 		schedule();
 		goto again;
-
 	}
 
 	if (time_before(cfs_time_current(), fps->fps_next_retry)) {
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index cbf5d0a..6b5a0b3 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2287,7 +2287,6 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 			rej.ibr_why = IBLND_REJECT_RDMA_FRAGS;
 
 		goto failed;
-
 	}
 
 	if (reqmsg->ibm_u.connparams.ibcp_max_msg_size > IBLND_MSG_SIZE) {
@@ -3128,7 +3127,6 @@ kiblnd_connd(void *arg)
 	spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);
 
 	while (!kiblnd_data.kib_shutdown) {
-
 		dropped_lock = 0;
 
 		if (!list_empty(&kiblnd_data.kib_connd_zombies)) {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 6bf92fd..c428684 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -182,7 +182,6 @@ ksocknal_find_peer_locked(lnet_ni_t *ni, lnet_process_id_t id)
 	ksock_peer_t *peer;
 
 	list_for_each(tmp, peer_list) {
-
 		peer = list_entry(tmp, ksock_peer_t, ksnp_list);
 
 		LASSERT(!peer->ksnp_closing);
@@ -264,7 +263,6 @@ ksocknal_get_peer_info(lnet_ni_t *ni, int index,
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
-
 		list_for_each(ptmp, &ksocknal_data.ksnd_peers[i]) {
 			peer = list_entry(ptmp, ksock_peer_t, ksnp_list);
 
@@ -1015,7 +1013,6 @@ ksocknal_connecting(ksock_peer_t *peer, __u32 ipaddr)
 	ksock_route_t *route;
 
 	list_for_each_entry(route, &peer->ksnp_routes, ksnr_list) {
-
 		if (route->ksnr_ipaddr == ipaddr)
 			return route->ksnr_connecting;
 	}
@@ -1787,7 +1784,6 @@ ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr)
 	for (i = lo; i <= hi; i++) {
 		list_for_each_safe(ptmp, pnxt,
 				   &ksocknal_data.ksnd_peers[i]) {
-
 			peer = list_entry(ptmp, ksock_peer_t, ksnp_list);
 
 			if (!((id.nid == LNET_NID_ANY || id.nid == peer->ksnp_id.nid) &&
@@ -2330,7 +2326,6 @@ ksocknal_base_shutdown(void)
 					continue;
 
 				for (j = 0; j < info->ksi_nthreads_max; j++) {
-
 					sched = &info->ksi_scheds[j];
 					LASSERT(list_empty(
 						&sched->kss_tx_conns));
@@ -2387,7 +2382,6 @@ ksocknal_base_shutdown(void)
 static __u64
 ksocknal_new_incarnation(void)
 {
-
 	/* The incarnation number is the time this module loaded and it
 	 * identifies this particular instance of the socknal.
 	 */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 1243f92..c82ed27 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -589,7 +589,6 @@ ksocknal_process_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
 static void
 ksocknal_launch_connection_locked (ksock_route_t *route)
 {
-
 	/* called holding write lock on ksnd_global_lock */
 
 	LASSERT(!route->ksnr_scheduled);
@@ -2147,7 +2146,6 @@ ksocknal_connd_get_route_locked(signed long *timeout_p)
 	/* connd_routes can contain both pending and ordinary routes */
 	list_for_each_entry(route, &ksocknal_data.ksnd_connd_routes,
 			    ksnr_connd_list) {
-
 		if (route->ksnr_retry_interval == 0 ||
 		    cfs_time_aftereq(now, route->ksnr_timeout))
 			return route;
@@ -2495,7 +2493,6 @@ ksocknal_check_peer_timeouts (int idx)
 
 			if (cfs_time_aftereq(cfs_time_current(),
 					     tx->tx_deadline)) {
-
 				ksocknal_peer_addref(peer);
 				read_unlock(&ksocknal_data.ksnd_global_lock);
 
@@ -2569,7 +2566,6 @@ ksocknal_reaper (void *arg)
 	spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
 
 	while (!ksocknal_data.ksnd_shuttingdown) {
-
 		if (!list_empty (&ksocknal_data.ksnd_deathrow_conns)) {
 			conn = list_entry (ksocknal_data. \
 					       ksnd_deathrow_conns.next,
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index b330f64..8c95cc5 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -223,7 +223,6 @@ lnet_accept(struct socket *sock, __u32 magic)
 	LASSERT(rc == 0);		      /* we succeeded before */
 
 	if (!lnet_accept_magic(magic, LNET_PROTO_ACCEPTOR_MAGIC)) {
-
 		if (lnet_accept_magic(magic, LNET_PROTO_MAGIC)) {
 			/*
 			 * future version compatibility!
@@ -363,7 +362,6 @@ lnet_acceptor(void *arg)
 		return rc;
 
 	while (!lnet_acceptor_state.pta_shutdown) {
-
 		rc = lnet_sock_accept(&newsock, lnet_acceptor_state.pta_sock);
 		if (rc != 0) {
 			if (rc != -EAGAIN) {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index e59fbfb..78188a9 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -340,7 +340,6 @@ lnet_counters_get(lnet_counters_t *counters)
 		counters->recv_length  += ctr->recv_length;
 		counters->route_length += ctr->route_length;
 		counters->drop_length  += ctr->drop_length;
-
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
 }
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 5339dee..695db24 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -221,7 +221,6 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		 * NB we don't check interface conflicts here; it's the LNDs
 		 * responsibility (if it cares at all)
 		 */
-
 		if (square != NULL && (comma == NULL || square < comma)) {
 			/*
 			 * i.e: o2ib0(ib0)[1,2], number between square
@@ -251,7 +250,6 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 
 		if (bracket == NULL ||
 		    (comma != NULL && comma < bracket)) {
-
 			/* no interface list specified */
 
 			if (comma != NULL)
@@ -528,7 +526,6 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 		goto failed;
 
 	for (parsed = sep; parsed < sep2; parsed = enditem) {
-
 		enditem = ++parsed;
 		while (enditem < sep2 && *enditem != ',')
 			enditem++;
@@ -538,9 +535,7 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 
 		if (sscanf(parsed, "%d-%d/%d%n", &lo, &hi,
 			   &stride, &scanned) < 3) {
-
 			if (sscanf(parsed, "%d-%d%n", &lo, &hi, &scanned) < 2) {
-
 				/* simple string enumeration */
 				if (lnet_expand1tb(&pending, str, sep, sep2,
 						   parsed,
@@ -564,7 +559,6 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 			goto failed;
 
 		for (i = lo; i <= hi; i += stride) {
-
 			snprintf(num, sizeof(num), "%d", i);
 			nob = strlen(num);
 			if (nob + 1 == sizeof(num))
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index fef517d..4d59bac 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -106,7 +106,6 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 	lmd->md_flags = (unlink == LNET_UNLINK) ? LNET_MD_FLAG_AUTO_UNLINK : 0;
 
 	if ((umd->options & LNET_MD_IOVEC) != 0) {
-
 		if ((umd->options & LNET_MD_KIOV) != 0) /* Can't specify both */
 			return -EINVAL;
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index afc4522..12bb983 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1726,7 +1726,6 @@ lnet_print_hdr(lnet_hdr_t *hdr)
 		      hdr->msg.reply.dst_wmd.wh_object_cookie,
 		      hdr->payload_length);
 	}
-
 }
 
 int
@@ -1866,7 +1865,6 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 	/* msg zeroed in lnet_msg_alloc;
 	 * i.e. flags all clear, pointers NULL etc
 	 */
-
 	msg->msg_type = type;
 	msg->msg_private = private;
 	msg->msg_receiving = 1;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index a680e68..eb4aa34 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -74,7 +74,6 @@ lnet_build_msg_event(lnet_msg_t *msg, lnet_event_kind_t ev_type)
 		ev->initiator.nid = LNET_NID_ANY;
 		ev->initiator.pid = the_lnet.ln_pid;
 		ev->sender        = LNET_NID_ANY;
-
 	} else {
 		/* event for passive message */
 		ev->target.pid    = hdr->dest_pid;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index e447b1a..65f951c 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -353,7 +353,6 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 		CERROR("Error %d creating route %s %d %s\n", rc,
 		       libcfs_net2str(net), hops,
 		       libcfs_nid2str(gateway));
-
 		return rc;
 	}
 
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 88fb54d..4af91cb 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -505,7 +505,6 @@ void brw_init_test_client(void)
 srpc_service_t brw_test_service;
 void brw_init_test_service(void)
 {
-
 	brw_test_service.sv_id         = SRPC_SERVICE_BRW;
 	brw_test_service.sv_name       = "brw_test";
 	brw_test_service.sv_handler    = brw_server_handle;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 64d58d1..ab0a3f7 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -967,7 +967,6 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 		entp->u.tbe_batch.bae_state = bat->bat_state;
 
 	} else {
-
 		entp->u.tbe_test.tse_type   = test->tes_type;
 		entp->u.tbe_test.tse_loop   = test->tes_loop;
 		entp->u.tbe_test.tse_concur = test->tes_concur;
-- 
1.7.1
