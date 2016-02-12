From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:05 -0500
Subject: [lustre-devel] [PATCH 07/11] staging: lustre: don't set more than
	one variable per line in LNet layer
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Cleanup all occurances of more than one variable being set per line as
reported by checkpatch.pl.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 ++-
 .../staging/lustre/include/linux/lnet/socklnd.h    |    3 ++-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   10 ++++++----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    6 ++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   17 ++++++++++-------
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   12 ++++++++----
 drivers/staging/lustre/lnet/lnet/config.c          |    3 ++-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    9 ++++++---
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    9 ++++++---
 drivers/staging/lustre/lnet/lnet/peer.c            |    6 +++---
 drivers/staging/lustre/lnet/lnet/router.c          |    3 ++-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    3 ++-
 drivers/staging/lustre/lnet/selftest/selftest.h    |    4 ++--
 13 files changed, 53 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index c3bf5e8..b8be9b6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -681,7 +681,8 @@ void lnet_debug_peer(lnet_nid_t nid);
 static inline void
 lnet_peer_set_alive(lnet_peer_t *lp)
 {
-	lp->lp_last_alive = lp->lp_last_query = jiffies;
+	lp->lp_last_query = jiffies;
+	lp->lp_last_alive = jiffies;
 	if (!lp->lp_alive)
 		lnet_notify_locked(lp, 0, 1, lp->lp_last_alive);
 }
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index 3df5065..bc32403 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -85,7 +85,8 @@ socklnd_init_msg(ksock_msg_t *msg, int type)
 {
 	msg->ksm_csum = 0;
 	msg->ksm_type = type;
-	msg->ksm_zc_cookies[0] = msg->ksm_zc_cookies[1]  = 0;
+	msg->ksm_zc_cookies[0] = 0;
+	msg->ksm_zc_cookies[1] = 0;
 }
 
 #define KSOCK_MSG_NOOP	0xC0	/* ksm_u empty */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 812d9b5..db551e4 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -500,7 +500,8 @@ static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	if (nid != LNET_NID_ANY) {
-		lo = hi = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
+		lo = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
+		hi = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
 	} else {
 		lo = 0;
 		hi = kiblnd_data.kib_peer_hash_size - 1;
@@ -979,9 +980,10 @@ static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
 
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	if (nid != LNET_NID_ANY)
-		lo = hi = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
-	else {
+	if (nid != LNET_NID_ANY) {
+		lo = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
+		hi = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
+	} else {
 		lo = 0;
 		hi = kiblnd_data.kib_peer_hash_size - 1;
 	}
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 46d1810..14938c3 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1061,8 +1061,8 @@ kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
 	struct ib_sge *sge = &tx->tx_sge[0];
 	struct ib_rdma_wr *wrq = &tx->tx_wrq[0], *next;
 	int rc  = resid;
-	int srcidx;
-	int dstidx;
+	int srcidx = 0;
+	int dstidx = 0;
 	int wrknob;
 
 	LASSERT(!in_interrupt());
@@ -1070,8 +1070,6 @@ kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
 	LASSERT(type == IBLND_MSG_GET_DONE ||
 		type == IBLND_MSG_PUT_DONE);
 
-	srcidx = dstidx = 0;
-
 	while (resid > 0) {
 		if (srcidx >= srcrd->rd_nfrags) {
 			CERROR("Src buffer exhausted: %d frags\n", srcidx);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 4ab7f29..7c9525d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -582,9 +582,10 @@ ksocknal_del_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip)
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	if (id.nid != LNET_NID_ANY)
-		lo = hi = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
-	else {
+	if (id.nid != LNET_NID_ANY) {
+		lo = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
+		hi = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
+	} else {
 		lo = 0;
 		hi = ksocknal_data.ksnd_peer_hash_size - 1;
 	}
@@ -1774,9 +1775,10 @@ ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr)
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	if (id.nid != LNET_NID_ANY)
-		lo = hi = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
-	else {
+	if (id.nid != LNET_NID_ANY) {
+		lo = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
+		hi = (int)(ksocknal_nid2peerlist(id.nid) - ksocknal_data.ksnd_peers);
+	} else {
 		lo = 0;
 		hi = ksocknal_data.ksnd_peer_hash_size - 1;
 	}
@@ -1938,7 +1940,8 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 		start = &ksocknal_data.ksnd_peers[0];
 		end = &ksocknal_data.ksnd_peers[hsize - 1];
 	} else {
-		start = end = ksocknal_nid2peerlist(id.nid);
+		start = ksocknal_nid2peerlist(id.nid);
+		end = ksocknal_nid2peerlist(id.nid);
 	}
 
 	for (tmp = start; tmp <= end; tmp++) {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 2fe23d4..c59ddc2 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -719,7 +719,8 @@ ksocknal_pack_msg_v1(ksock_tx_t *tx)
 	tx->tx_iov[0].iov_base = &tx->tx_lnetmsg->msg_hdr;
 	tx->tx_iov[0].iov_len  = sizeof(lnet_hdr_t);
 
-	tx->tx_resid = tx->tx_nob = tx->tx_lnetmsg->msg_len + sizeof(lnet_hdr_t);
+	tx->tx_nob = tx->tx_lnetmsg->msg_len + sizeof(lnet_hdr_t);
+	tx->tx_resid = tx->tx_lnetmsg->msg_len + sizeof(lnet_hdr_t);
 }
 
 static void
@@ -732,12 +733,14 @@ ksocknal_pack_msg_v2(ksock_tx_t *tx)
 
 		tx->tx_msg.ksm_u.lnetmsg.ksnm_hdr = tx->tx_lnetmsg->msg_hdr;
 		tx->tx_iov[0].iov_len = sizeof(ksock_msg_t);
-		tx->tx_resid = tx->tx_nob = sizeof(ksock_msg_t) + tx->tx_lnetmsg->msg_len;
+		tx->tx_nob = sizeof(ksock_msg_t) + tx->tx_lnetmsg->msg_len;
+		tx->tx_resid = sizeof(ksock_msg_t) + tx->tx_lnetmsg->msg_len;
 	} else {
 		LASSERT(tx->tx_msg.ksm_type == KSOCK_MSG_NOOP);
 
 		tx->tx_iov[0].iov_len = offsetof(ksock_msg_t, ksm_u.lnetmsg.ksnm_hdr);
-		tx->tx_resid = tx->tx_nob = offsetof(ksock_msg_t,  ksm_u.lnetmsg.ksnm_hdr);
+		tx->tx_nob = offsetof(ksock_msg_t,  ksm_u.lnetmsg.ksnm_hdr);
+		tx->tx_resid = offsetof(ksock_msg_t,  ksm_u.lnetmsg.ksnm_hdr);
 	}
 	/* Don't checksum before start sending, because packet can be piggybacked with ACK */
 }
@@ -747,7 +750,8 @@ ksocknal_unpack_msg_v1(ksock_msg_t *msg)
 {
 	msg->ksm_csum = 0;
 	msg->ksm_type = KSOCK_MSG_LNET;
-	msg->ksm_zc_cookies[0] = msg->ksm_zc_cookies[1]  = 0;
+	msg->ksm_zc_cookies[0] = 0;
+	msg->ksm_zc_cookies[1] = 0;
 }
 
 static void
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index e30a959..d02353d 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -202,7 +202,8 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	the_lnet.ln_network_tokens = tokens;
 	the_lnet.ln_network_tokens_nob = tokensize;
 	memcpy(tokens, networks, tokensize);
-	str = tmp = tokens;
+	tmp = tokens;
+	str = tokens;
 
 	/* Add in the loopback network */
 	ni = lnet_ni_alloc(LNET_MKNET(LOLND, 0), NULL, nilist);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 4d59bac..55bd7a1 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -109,7 +109,8 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 		if ((umd->options & LNET_MD_KIOV) != 0) /* Can't specify both */
 			return -EINVAL;
 
-		lmd->md_niov = niov = umd->length;
+		niov = umd->length;
+		lmd->md_niov = umd->length;
 		memcpy(lmd->md_iov.iov, umd->start,
 		       niov * sizeof(lmd->md_iov.iov[0]));
 
@@ -130,7 +131,8 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 			return -EINVAL;
 
 	} else if ((umd->options & LNET_MD_KIOV) != 0) {
-		lmd->md_niov = niov = umd->length;
+		niov = umd->length;
+		lmd->md_niov = umd->length;
 		memcpy(lmd->md_iov.kiov, umd->start,
 		       niov * sizeof(lmd->md_iov.kiov[0]));
 
@@ -151,7 +153,8 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 			return -EINVAL;
 	} else {   /* contiguous */
 		lmd->md_length = umd->length;
-		lmd->md_niov = niov = 1;
+		niov = 1;
+		lmd->md_niov = 1;
 		lmd->md_iov.iov[0].iov_base = umd->start;
 		lmd->md_iov.iov[0].iov_len = umd->length;
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 12bb983..b40220a 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1151,7 +1151,8 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 		return NULL;
 
 	lp_best = NULL;
-	rtr_best = rtr_last = NULL;
+	rtr_best = NULL;
+	rtr_last = NULL;
 	list_for_each_entry(rtr, &rnet->lrn_routes, lr_list) {
 		lp = rtr->lr_gateway;
 
@@ -1167,7 +1168,8 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 			return lp;
 
 		if (lp_best == NULL) {
-			rtr_best = rtr_last = rtr;
+			rtr_best = rtr;
+			rtr_last = rtr;
 			lp_best = lp;
 			continue;
 		}
@@ -1868,7 +1870,8 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 	msg->msg_type = type;
 	msg->msg_private = private;
 	msg->msg_receiving = 1;
-	msg->msg_len = msg->msg_wanted = payload_length;
+	msg->msg_wanted = payload_length;
+	msg->msg_len = payload_length;
 	msg->msg_offset = 0;
 	msg->msg_hdr = *hdr;
 	/* for building message event */
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 9c0f264..a8e25b0 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -287,9 +287,9 @@ lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt)
 		goto out;
 	}
 
-	lp->lp_txcredits     =
-	lp->lp_mintxcredits  = lp->lp_ni->ni_peertxcredits;
-	lp->lp_rtrcredits    =
+	lp->lp_txcredits = lp->lp_ni->ni_peertxcredits;
+	lp->lp_mintxcredits = lp->lp_ni->ni_peertxcredits;
+	lp->lp_rtrcredits = lnet_peer_buffer_credits(lp->lp_ni);
 	lp->lp_minrtrcredits = lnet_peer_buffer_credits(lp->lp_ni);
 
 	list_add_tail(&lp->lp_hashlist,
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 65f951c..36f3caa 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1307,7 +1307,8 @@ lnet_rtrpool_free_bufs(lnet_rtrbufpool_t *rbp)
 	LASSERT(rbp->rbp_nbuffers == nbuffers);
 	LASSERT(rbp->rbp_credits == nbuffers);
 
-	rbp->rbp_nbuffers = rbp->rbp_credits = 0;
+	rbp->rbp_nbuffers = 0;
+	rbp->rbp_credits = 0;
 }
 
 static int
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 3e702e2..817be93 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -953,7 +953,8 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
 		CNETERR("Framework features %x from %s is different with features on this transaction: %x\n",
 			reply->msg_ses_feats, libcfs_nid2str(nd->nd_id.nid),
 			trans->tas_features);
-		status = mksn_rep->mksn_status = EPROTO;
+		mksn_rep->mksn_status = EPROTO;
+		status = EPROTO;
 	}
 
 	if (status == 0) {
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 8704983..5781f77 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -546,8 +546,8 @@ srpc_init_client_rpc (srpc_client_rpc_t *rpc, lnet_process_id_t peer,
 	LNetInvalidateHandle(&rpc->crpc_bulk.bk_mdh);
 
 	/* no event is expected at this point */
-	rpc->crpc_bulkev.ev_fired  =
-	rpc->crpc_reqstev.ev_fired =
+	rpc->crpc_bulkev.ev_fired = 1;
+	rpc->crpc_reqstev.ev_fired = 1;
 	rpc->crpc_replyev.ev_fired = 1;
 
 	rpc->crpc_reqstmsg.msg_magic   = SRPC_MSG_MAGIC;
-- 
1.7.1
