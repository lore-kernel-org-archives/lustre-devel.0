From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:50 -0400
Subject: [lustre-devel] [PATCH 13/45] lnet: Introduce constant for the lolnd
 NID
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

This patch adds a new constant, LNET_NID_LO_0, to represent the lolnd
NID 0 at lo.

HPE-bug-id: LUS-8457
WC-bug-id: https://jira.whamcloud.com/browse/LU-12222
Lustre-commit: 56203e4ba0a6 ("LU-12222 lnet: Introduce constant for the lolnd NID")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38312
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c          | 2 +-
 fs/lustre/lmv/lmv_obd.c              | 4 ++--
 fs/lustre/ptlrpc/events.c            | 2 +-
 include/uapi/linux/lnet/lnet-types.h | 3 +++
 net/lnet/lnet/api-ni.c               | 6 +++---
 net/lnet/lnet/config.c               | 3 +--
 net/lnet/lnet/lib-move.c             | 6 +++---
 net/lnet/lnet/lib-msg.c              | 5 ++---
 net/lnet/lnet/peer.c                 | 6 +++---
 net/lnet/lnet/router.c               | 2 +-
 10 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 84ec734..83b95ce 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2817,7 +2817,7 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 		i = 0;
 
 		while (LNetGetId(i++, &id) != -ENOENT) {
-			if (LNET_NETTYP(LNET_NIDNET(id.nid)) == LOLND)
+			if (id.nid == LNET_NID_LO_0)
 				continue;
 			if (cfs_match_nid(id.nid, &squash->rsi_nosquash_nids)) {
 				matched = true;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 83e38bf..f241269 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1114,7 +1114,7 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	 * can distribute subdirs evenly from the beginning.
 	 */
 	while (LNetGetId(i++, &lnet_id) != -ENOENT) {
-		if (LNET_NETTYP(LNET_NIDNET(lnet_id.nid)) != LOLND) {
+		if (lnet_id.nid != LNET_NID_LO_0) {
 			lmv->lmv_qos_rr_index = (u32)lnet_id.nid;
 			break;
 		}
@@ -1208,7 +1208,7 @@ static int lmv_select_statfs_mdt(struct lmv_obd *lmv, u32 flags)
 		if (LNetGetId(i, &lnet_id) == -ENOENT)
 			break;
 
-		if (LNET_NETTYP(LNET_NIDNET(lnet_id.nid)) != LOLND) {
+		if (lnet_id.nid != LNET_NID_LO_0) {
 			/* We dont need a full 64-bit modulus, just enough
 			 * to distribute the requests across MDTs evenly.
 			 */
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index bc2af35..5e3787c 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -478,7 +478,7 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 			continue;
 
 		if (dist == 0) {		/* local! use loopback LND */
-			peer->nid = *self = LNET_MKNID(LNET_MKNET(LOLND, 0), 0);
+			peer->nid = *self = LNET_NID_LO_0;
 			rc = 0;
 			break;
 		}
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 1ef1e98..947ed7f 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -109,6 +109,9 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 	return (type << 16) | num;
 }
 
+/** The lolnd NID (i.e. myself) */
+#define LNET_NID_LO_0 LNET_MKNID(LNET_MKNET(LOLND, 0), 0)
+
 /* Packed version of lnet_process_id to transfer via network */
 struct lnet_process_id_packed {
 	/* node id / process id */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index b3e1fe9..b0f2a62 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1567,7 +1567,7 @@ struct lnet_ping_buffer *
 	/* Loopback is guaranteed to be present */
 	if (pinfo->pi_nnis < 1 || pinfo->pi_nnis > lnet_interfaces_max)
 		return -ERANGE;
-	if (LNET_NETTYP(LNET_NIDNET(LNET_PING_INFO_LONI(pinfo))) != LOLND)
+	if (LNET_PING_INFO_LONI(pinfo) != LNET_NID_LO_0)
 		return -EPROTO;
 	return 0;
 }
@@ -2732,7 +2732,7 @@ void lnet_lib_exit(void)
 	}
 
 	cfg_ni->lic_nid = ni->ni_nid;
-	if (LNET_NETTYP(LNET_NIDNET(ni->ni_nid)) == LOLND)
+	if (ni->ni_nid == LNET_NID_LO_0)
 		cfg_ni->lic_status = LNET_NI_STATUS_UP;
 	else
 		cfg_ni->lic_status = ni->ni_status->ns_status;
@@ -2824,7 +2824,7 @@ void lnet_lib_exit(void)
 	config->cfg_config_u.cfg_net.net_peer_rtr_credits =
 		ni->ni_net->net_tunables.lct_peer_rtr_credits;
 
-	if (LNET_NETTYP(LNET_NIDNET(ni->ni_nid)) == LOLND)
+	if (ni->ni_nid == LNET_NID_LO_0)
 		net_config->ni_status = LNET_NI_STATUS_UP;
 	else
 		net_config->ni_status = ni->ni_status->ns_status;
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 9d3813c..d120dab 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1179,8 +1179,7 @@ struct lnet_ni *
 					goto token_error;
 
 				nid = libcfs_str2nid(ltb->ltb_text);
-				if (nid == LNET_NID_ANY ||
-				    LNET_NETTYP(LNET_NIDNET(nid)) == LOLND)
+				if (nid == LNET_NID_ANY || nid == LNET_NID_LO_0)
 					goto token_error;
 			}
 		}
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 6ef9978..4eaaa5f 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -563,7 +563,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	int rc;
 
 	LASSERT(!in_interrupt());
-	LASSERT(LNET_NETTYP(LNET_NIDNET(ni->ni_nid)) == LOLND ||
+	LASSERT(ni->ni_nid == LNET_NID_LO_0 ||
 		(msg->msg_txcredit && msg->msg_peertxcredit));
 
 	rc = ni->ni_net->net_lnd->lnd_send(ni, priv, msg);
@@ -2407,7 +2407,7 @@ struct lnet_ni *
 	 */
 	send_data.sd_msg = msg;
 	send_data.sd_cpt = cpt;
-	if (LNET_NETTYP(LNET_NIDNET(dst_nid)) == LOLND) {
+	if (dst_nid == LNET_NID_LO_0) {
 		rc = lnet_handle_lo_send(&send_data);
 		lnet_net_unlock(cpt);
 		return rc;
@@ -4793,7 +4793,7 @@ struct lnet_msg *
 			if (srcnidp)
 				*srcnidp = dstnid;
 			if (orderp) {
-				if (LNET_NETTYP(LNET_NIDNET(dstnid)) == LOLND)
+				if (dstnid == LNET_NID_LO_0)
 					*orderp = 0;
 				else
 					*orderp = 1;
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index dbb218d..7ce9c47 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -784,11 +784,10 @@
 	/* if we're sending to the LOLND then the msg_txpeer will not be
 	 * set. So no need to sanity check it.
 	 */
-	if (msg->msg_tx_committed &&
-	    LNET_NETTYP(LNET_NIDNET(msg->msg_txni->ni_nid)) != LOLND)
+	if (msg->msg_tx_committed && msg->msg_txni->ni_nid != LNET_NID_LO_0)
 		LASSERT(msg->msg_txpeer);
 	else if (msg->msg_tx_committed &&
-		 LNET_NETTYP(LNET_NIDNET(msg->msg_txni->ni_nid)) == LOLND)
+		 msg->msg_txni->ni_nid == LNET_NID_LO_0)
 		lo = true;
 
 	if (hstatus != LNET_MSG_STATUS_OK &&
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 1605c24..1b9190b 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -233,7 +233,7 @@
 	 * to ever use a different interface when sending messages to
 	 * myself.
 	 */
-	if (LNET_NETTYP(LNET_NIDNET(nid)) == LOLND)
+	if (nid == LNET_NID_LO_0)
 		lp->lp_state = LNET_PEER_NO_DISCOVERY;
 	lp->lp_cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
 
@@ -2615,7 +2615,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	 * present in curnis[] then this peer is for this node.
 	 */
 	for (i = 0; i < ncurnis; i++) {
-		if (LNET_NETTYP(LNET_NIDNET(curnis[i])) == LOLND)
+		if (curnis[i] == LNET_NID_LO_0)
 			continue;
 		for (j = 1; j < pbuf->pb_info.pi_nnis; j++) {
 			if (curnis[i] == pbuf->pb_info.pi_ni[j].ns_nid) {
@@ -2838,7 +2838,7 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	if (pbuf->pb_info.pi_nnis <= 1)
 		goto out;
 	nid = pbuf->pb_info.pi_ni[1].ns_nid;
-	if (LNET_NETTYP(LNET_NIDNET(lp->lp_primary_nid)) == LOLND) {
+	if (lp->lp_primary_nid == LNET_NID_LO_0) {
 		rc = lnet_peer_set_primary_nid(lp, nid, flags);
 		if (!rc)
 			rc = lnet_peer_merge_data(lp, pbuf);
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index ff0a665..af50e51 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -661,7 +661,7 @@ static void lnet_shuffle_seed(void)
 	       libcfs_net2str(net), hops, priority, libcfs_nid2str(gateway));
 
 	if (gateway == LNET_NID_ANY ||
-	    LNET_NETTYP(LNET_NIDNET(gateway)) == LOLND ||
+	    gateway == LNET_NID_LO_0 ||
 	    net == LNET_NIDNET(LNET_NID_ANY) ||
 	    LNET_NETTYP(net) == LOLND ||
 	    LNET_NIDNET(gateway) == net ||
-- 
1.8.3.1
