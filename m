From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 25/34] LU-7734 lnet: Routing fixes part 1
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763583.32103.2609293106875022233.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This is the first part of a routing fix.
- Fix crash in lnet_parse_get()
- Resolve deadlock when adding a route.
- Fix an issue with dynamically turning on routing
- Set the final destination NID properly when routing a msg

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: I68d0e4d52192aa96e37c77952a1ebe75c1b770c5
Reviewed-on: http://review.whamcloud.com/21166
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   23 +++++--
 drivers/staging/lustre/lnet/lnet/peer.c            |   62 ++++++++++++++++----
 drivers/staging/lustre/lnet/lnet/router.c          |    2 -
 4 files changed, 67 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 55bcd17cd4dc..3a53d54b711d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -649,6 +649,7 @@ struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 						  struct lnet_peer_ni *prev);
 struct lnet_peer *lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt);
 struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, int cpt);
+struct lnet_peer_ni *lnet_nid2peerni_ex(lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 void lnet_peer_net_added(struct lnet_net *net);
 lnet_nid_t lnet_peer_primary_nid(lnet_nid_t nid);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 2f30ba0d89fb..58521b014ef3 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1566,17 +1566,10 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 */
 	lnet_ni_addref_locked(msg->msg_txni, cpt);
 
-	/*
-	 * set the destination nid in the message here because it's
-	 * possible that we'd be sending to a different nid than the one
-	 * originaly given.
-	 */
-	msg->msg_hdr.dest_nid = cpu_to_le64(msg->msg_txpeer->lpni_nid);
-
 	/*
 	 * Always set the target.nid to the best peer picked. Either the
 	 * nid will be one of the preconfigured NIDs, or the same NID as
-	 * what was originaly set in the target or it will be the NID of
+	 * what was originally set in the target or it will be the NID of
 	 * a router if this message should be routed
 	 */
 	msg->msg_target.nid = msg->msg_txpeer->lpni_nid;
@@ -1599,6 +1592,19 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	if (routing) {
 		msg->msg_target_is_router = 1;
 		msg->msg_target.pid = LNET_PID_LUSTRE;
+		/*
+		 * since we're routing we want to ensure that the
+		 * msg_hdr.dest_nid is set to the final destination. When
+		 * the router receives this message it knows how to route
+		 * it.
+		 */
+		msg->msg_hdr.dest_nid = cpu_to_le64(dst_nid);
+	} else {
+		/*
+		 * if we're not routing set the dest_nid to the best peer
+		 * ni that we picked earlier in the algorithm.
+		 */
+		msg->msg_hdr.dest_nid = cpu_to_le64(msg->msg_txpeer->lpni_nid);
 	}
 
 	rc = lnet_post_send_locked(msg, 0);
@@ -1757,6 +1763,7 @@ lnet_parse_get(struct lnet_ni *ni, struct lnet_msg *msg, int rdma_get)
 	info.mi_rlength = hdr->msg.get.sink_length;
 	info.mi_roffset = hdr->msg.get.src_offset;
 	info.mi_mbits   = hdr->msg.get.match_bits;
+	info.mi_cpt	= lnet_cpt_of_nid(msg->msg_rxpeer->lpni_nid, ni);
 
 	rc = lnet_ptl_match_md(&info, msg);
 	if (rc == LNET_MATCHMD_DROP) {
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 6f6039189456..9cecfb49db87 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -954,36 +954,74 @@ lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lpni)
 	kfree(lpni);
 }
 
+struct lnet_peer_ni *
+lnet_nid2peerni_ex(lnet_nid_t nid, int cpt)
+{
+	struct lnet_peer_ni *lpni = NULL;
+	int rc;
+
+	if (the_lnet.ln_shutdown) /* it's shutting down */
+		return ERR_PTR(-ESHUTDOWN);
+
+	/*
+	 * find if a peer_ni already exists.
+	 * If so then just return that.
+	 */
+	lpni = lnet_find_peer_ni_locked(nid);
+	if (lpni)
+		return lpni;
+
+	lnet_net_unlock(cpt);
+
+	rc = lnet_peer_ni_traffic_add(nid);
+	if (rc) {
+		lpni = ERR_PTR(rc);
+		goto out_net_relock;
+	}
+
+	lpni = lnet_find_peer_ni_locked(nid);
+	LASSERT(lpni);
+
+out_net_relock:
+	lnet_net_lock(cpt);
+
+	return lpni;
+}
+
 struct lnet_peer_ni *
 lnet_nid2peerni_locked(lnet_nid_t nid, int cpt)
 {
-	struct lnet_peer_table *ptable;
 	struct lnet_peer_ni *lpni = NULL;
-	int cpt2;
 	int rc;
 
 	if (the_lnet.ln_shutdown) /* it's shutting down */
 		return ERR_PTR(-ESHUTDOWN);
 
 	/*
-	 * calculate cpt2 with the standard hash function
-	 * This cpt2 is the slot where we'll find or create the peer.
+	 * find if a peer_ni already exists.
+	 * If so then just return that.
 	 */
-	cpt2 = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
-	ptable = the_lnet.ln_peer_tables[cpt2];
-	lpni = lnet_get_peer_ni_locked(ptable, nid);
+	lpni = lnet_find_peer_ni_locked(nid);
 	if (lpni)
 		return lpni;
 
-	/* Slow path: serialized using the ln_api_mutex. */
+	/*
+	 * Slow path:
+	 * use the lnet_api_mutex to serialize the creation of the peer_ni
+	 * and the creation/deletion of the local ni/net. When a local ni is
+	 * created, if there exists a set of peer_nis on that network,
+	 * they need to be traversed and updated. When a local NI is
+	 * deleted, which could result in a network being deleted, then
+	 * all peer nis on that network need to be removed as well.
+	 *
+	 * Creation through traffic should also be serialized with
+	 * creation through DLC.
+	 */
 	lnet_net_unlock(cpt);
 	mutex_lock(&the_lnet.ln_api_mutex);
 	/*
 	 * Shutdown is only set under the ln_api_lock, so a single
 	 * check here is sufficent.
-	 *
-	 * lnet_add_nid_to_peer() also handles the case where we've
-	 * raced and a different thread added the NID.
 	 */
 	if (the_lnet.ln_shutdown) {
 		lpni = ERR_PTR(-ESHUTDOWN);
@@ -996,7 +1034,7 @@ lnet_nid2peerni_locked(lnet_nid_t nid, int cpt)
 		goto out_mutex_unlock;
 	}
 
-	lpni = lnet_get_peer_ni_locked(ptable, nid);
+	lpni = lnet_find_peer_ni_locked(nid);
 	LASSERT(lpni);
 
 out_mutex_unlock:
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 6c50e8cc7833..a0483f970bd5 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -358,7 +358,7 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 
 	lnet_net_lock(LNET_LOCK_EX);
 
-	lpni = lnet_nid2peerni_locked(gateway, LNET_LOCK_EX);
+	lpni = lnet_nid2peerni_ex(gateway, LNET_LOCK_EX);
 	if (IS_ERR(lpni)) {
 		lnet_net_unlock(LNET_LOCK_EX);
 
