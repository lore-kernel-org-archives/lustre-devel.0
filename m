From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:38 +1100
Subject: [lustre-devel] [PATCH 18/24] lustre: lnet: implement Peer Discovery
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437824.16383.8664465506271547759.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

Implement Peer Discovery.

A peer is queued for discovery by lnet_peer_queue_for_discovery().
This set LNET_PEER_DISCOVERING, to indicate that discovery is in
progress.

The discovery thread lnet_peer_discovery() checks the peer and
updates its state as appropriate.

If LNET_PEER_DATA_PRESENT is set, then a valid Push message or
Ping reply has been received. The peer is updated in accordance
with the data, and LNET_PEER_NIDS_UPTODATE is set.

If LNET_PEER_PING_FAILED is set, then an attempt to send a Ping
message failed, and peer state is updated accordingly. The discovery
thread can do some cleanup like unlinking an MD that cannot be done
from the message event handler.

If LNET_PEER_PUSH_FAILED is set, then an attempt to send a Push
message failed, and peer state is updated accordingly. The discovery
thread can do some cleanup like unlinking an MD that cannot be done
from the message event handler.

If LNET_PEER_PING_REQUIRED is set, we must Ping the peer in order to
correctly update our knowledge of it. This is set, for example, if
we receive a Push message for a peer, but cannot handle it because
the Push target was too small. In such a case we know that the
state of the peer is incorrect, but need to do extra work to obtain
the required information.

If discovery is not enabled, then the discovery process stops here
and the peer is marked with LNET_PEER_UNDISCOVERED. This tells the
discovery process that it doesn't need to revisit the peer while
discovery remains disabled.

If LNET_PEER_NIDS_UPTODATE is not set, then we have reason to think
the lnet_peer is not up to date, and will Ping it.

The peer needs a Push if it is multi-rail and the ping buffer
sequence number for this node is newer than the sequence number it
has acknowledged receiving by sending an Ack of a Push.

If none of the above is true, then discovery has completed its work
on the peer.

Discovery signals that it is done with a peer by clearing the
LNET_PEER_DISCOVERING flag, and setting LNET_PEER_DISCOVERED or
LNET_PEER_UNDISCOVERED as appropriate. It then dequeues the peer
and clears the LNET_PEER_QUEUED flag.

When the local node is discovered via the loopback network, the
peer structure that is created will have an lnet_peer_ni for the
local loopback interface. Subsequent traffic from this node to
itself will use the loopback net.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25789
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   20 
 .../staging/lustre/include/linux/lnet/lib-types.h  |   39 +
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   59 +
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   18 
 drivers/staging/lustre/lnet/lnet/peer.c            | 1499 +++++++++++++++++++-
 5 files changed, 1543 insertions(+), 92 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 5632e5aadf41..f82a699371f2 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -76,6 +76,9 @@ extern struct lnet the_lnet;	/* THE network */
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
 
+/* Discovery timeout - same as default peer_timeout */
+#define DISCOVERY_TIMEOUT	180
+
 static inline int lnet_is_route_alive(struct lnet_route *route)
 {
 	/* gateway is down */
@@ -713,9 +716,10 @@ struct lnet_peer_ni *lnet_nid2peerni_ex(lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 void lnet_peer_net_added(struct lnet_net *net);
 lnet_nid_t lnet_peer_primary_nid_locked(lnet_nid_t nid);
-int lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt);
+int lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt, bool block);
 int lnet_peer_discovery_start(void);
 void lnet_peer_discovery_stop(void);
+void lnet_push_update_to_peers(int force);
 void lnet_peer_tables_cleanup(struct lnet_net *net);
 void lnet_peer_uninit(void);
 int lnet_peer_tables_create(void);
@@ -805,4 +809,18 @@ lnet_peer_ni_is_primary(struct lnet_peer_ni *lpni)
 
 bool lnet_peer_is_uptodate(struct lnet_peer *lp);
 
+static inline bool
+lnet_peer_needs_push(struct lnet_peer *lp)
+{
+	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL))
+		return false;
+	if (lp->lp_state & LNET_PEER_FORCE_PUSH)
+		return true;
+	if (lp->lp_state & LNET_PEER_NO_DISCOVERY)
+		return false;
+	if (lp->lp_node_seqno < atomic_read(&the_lnet.ln_ping_target_seqno))
+		return true;
+	return false;
+}
+
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index e00c13355d43..07baa86e61ab 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -67,6 +67,13 @@ struct lnet_msg {
 	lnet_nid_t		msg_from;
 	__u32			msg_type;
 
+	/*
+	 * hold parameters in case message is with held due
+	 * to discovery
+	 */
+	lnet_nid_t		msg_src_nid_param;
+	lnet_nid_t		msg_rtr_nid_param;
+
 	/* committed for sending */
 	unsigned int		msg_tx_committed:1;
 	/* CPT # this message committed for sending */
@@ -395,6 +402,8 @@ struct lnet_ping_buffer {
 #define LNET_PING_BUFFER_LONI(PBUF)	((PBUF)->pb_info.pi_ni[0].ns_nid)
 #define LNET_PING_BUFFER_SEQNO(PBUF)	((PBUF)->pb_info.pi_ni[0].ns_status)
 
+#define LNET_PING_INFO_TO_BUFFER(PINFO)	\
+	container_of((PINFO), struct lnet_ping_buffer, pb_info)
 
 /* router checker data, per router */
 struct lnet_rc_data {
@@ -503,6 +512,9 @@ struct lnet_peer {
 	/* list of peer nets */
 	struct list_head	lp_peer_nets;
 
+	/* list of messages pending discovery*/
+	struct list_head	lp_dc_pendq;
+
 	/* primary NID of the peer */
 	lnet_nid_t		lp_primary_nid;
 
@@ -524,15 +536,36 @@ struct lnet_peer {
 	/* buffer for data pushed by peer */
 	struct lnet_ping_buffer	*lp_data;
 
+	/* MD handle for ping in progress */
+	struct lnet_handle_md	lp_ping_mdh;
+
+	/* MD handle for push in progress */
+	struct lnet_handle_md	lp_push_mdh;
+
 	/* number of NIDs for sizing push data */
 	int			lp_data_nnis;
 
 	/* NI config sequence number of peer */
 	__u32			lp_peer_seqno;
 
-	/* Local NI config sequence number peer knows */
+	/* Local NI config sequence number acked by peer */
 	__u32			lp_node_seqno;
 
+	/* Local NI config sequence number sent to peer */
+	__u32			lp_node_seqno_sent;
+
+	/* Ping error encountered during discovery. */
+	int			lp_ping_error;
+
+	/* Push error encountered during discovery. */
+	int			lp_push_error;
+
+	/* Error encountered during discovery. */
+	int			lp_dc_error;
+
+	/* time it was put on the ln_dc_working queue */
+	time64_t		lp_last_queued;
+
 	/* link on discovery-related lists */
 	struct list_head	lp_dc_list;
 
@@ -691,6 +724,8 @@ struct lnet_remotenet {
 #define LNET_CREDIT_OK		0
 /** lnet message is waiting for credit */
 #define LNET_CREDIT_WAIT	1
+/** lnet message is waiting for discovery */
+#define LNET_DC_WAIT		2
 
 struct lnet_rtrbufpool {
 	struct list_head	rbp_bufs;	/* my free buffer pool */
@@ -943,6 +978,8 @@ struct lnet {
 	struct list_head		ln_dc_request;
 	/* discovery working list */
 	struct list_head		ln_dc_working;
+	/* discovery expired list */
+	struct list_head		ln_dc_expired;
 	/* discovery thread wait queue */
 	wait_queue_head_t		ln_dc_waitq;
 	/* discovery startup/shutdown state */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index e6bc54e9de71..955d1711eda4 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -41,7 +41,14 @@
 
 #define D_LNI D_CONSOLE
 
-struct lnet the_lnet;		/* THE state of the network */
+/*
+ * initialize ln_api_mutex statically, since it needs to be used in
+ * discovery_set callback. That module parameter callback can be called
+ * before module init completes. The mutex needs to be ready for use then.
+ */
+struct lnet the_lnet = {
+	.ln_api_mutex = __MUTEX_INITIALIZER(the_lnet.ln_api_mutex),
+};		/* THE state of the network */
 EXPORT_SYMBOL(the_lnet);
 
 static char *ip2nets = "";
@@ -101,7 +108,9 @@ static int
 discovery_set(const char *val, const struct kernel_param *kp)
 {
 	int rc;
+	unsigned int *discovery = (unsigned int *)kp->arg;
 	unsigned long value;
+	struct lnet_ping_buffer *pbuf;
 
 	rc = kstrtoul(val, 0, &value);
 	if (rc) {
@@ -109,7 +118,38 @@ discovery_set(const char *val, const struct kernel_param *kp)
 		return rc;
 	}
 
-	*(unsigned int *)kp->arg = !!value;
+	value = !!value;
+
+	/*
+	 * The purpose of locking the api_mutex here is to ensure that
+	 * the correct value ends up stored properly.
+	 */
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	if (value == *discovery) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
+	*discovery = value;
+
+	if (the_lnet.ln_state == LNET_STATE_SHUTDOWN) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
+	/* tell peers that discovery setting has changed */
+	lnet_net_lock(LNET_LOCK_EX);
+	pbuf = the_lnet.ln_ping_target;
+	if (value)
+		pbuf->pb_info.pi_features &= ~LNET_PING_FEAT_DISCOVERY;
+	else
+		pbuf->pb_info.pi_features |= LNET_PING_FEAT_DISCOVERY;
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	lnet_push_update_to_peers(1);
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
 
 	return 0;
 }
@@ -171,7 +211,6 @@ lnet_init_locks(void)
 	init_waitqueue_head(&the_lnet.ln_eq_waitq);
 	init_waitqueue_head(&the_lnet.ln_rc_waitq);
 	mutex_init(&the_lnet.ln_lnd_mutex);
-	mutex_init(&the_lnet.ln_api_mutex);
 }
 
 static int
@@ -654,6 +693,10 @@ lnet_prepare(lnet_pid_t requested_pid)
 	INIT_LIST_HEAD(&the_lnet.ln_routers);
 	INIT_LIST_HEAD(&the_lnet.ln_drop_rules);
 	INIT_LIST_HEAD(&the_lnet.ln_delay_rules);
+	INIT_LIST_HEAD(&the_lnet.ln_dc_request);
+	INIT_LIST_HEAD(&the_lnet.ln_dc_working);
+	INIT_LIST_HEAD(&the_lnet.ln_dc_expired);
+	init_waitqueue_head(&the_lnet.ln_dc_waitq);
 
 	rc = lnet_create_remote_nets_table();
 	if (rc)
@@ -998,7 +1041,8 @@ lnet_ping_target_create(int nnis)
 	pbuf->pb_info.pi_nnis = nnis;
 	pbuf->pb_info.pi_pid = the_lnet.ln_pid;
 	pbuf->pb_info.pi_magic = LNET_PROTO_PING_MAGIC;
-	pbuf->pb_info.pi_features = LNET_PING_FEAT_NI_STATUS;
+	pbuf->pb_info.pi_features =
+		LNET_PING_FEAT_NI_STATUS | LNET_PING_FEAT_MULTI_RAIL;
 
 	return pbuf;
 }
@@ -1231,6 +1275,8 @@ lnet_ping_target_update(struct lnet_ping_buffer *pbuf,
 
 	if (!the_lnet.ln_routing)
 		pbuf->pb_info.pi_features |= LNET_PING_FEAT_RTE_DISABLED;
+	if (!lnet_peer_discovery_disabled)
+		pbuf->pb_info.pi_features |= LNET_PING_FEAT_DISCOVERY;
 
 	/* Ensure only known feature bits have been set. */
 	LASSERT(pbuf->pb_info.pi_features & LNET_PING_FEAT_BITS);
@@ -1252,6 +1298,8 @@ lnet_ping_target_update(struct lnet_ping_buffer *pbuf,
 		lnet_ping_md_unlink(old_pbuf, &old_ping_md);
 		lnet_ping_buffer_decref(old_pbuf);
 	}
+
+	lnet_push_update_to_peers(0);
 }
 
 static void
@@ -1353,6 +1401,7 @@ static void lnet_push_target_event_handler(struct lnet_event *ev)
 	if (pbuf->pb_info.pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
 		lnet_swap_pinginfo(pbuf);
 
+	lnet_peer_push_event(ev);
 	if (ev->unlinked)
 		lnet_ping_buffer_decref(pbuf);
 }
@@ -1910,8 +1959,6 @@ int lnet_lib_init(void)
 
 	lnet_assert_wire_constants();
 
-	memset(&the_lnet, 0, sizeof(the_lnet));
-
 	/* refer to global cfs_cpt_tab for now */
 	the_lnet.ln_cpt_table	= cfs_cpt_tab;
 	the_lnet.ln_cpt_number	= cfs_cpt_number(cfs_cpt_tab);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 4773180cc7b3..2ff329bf91ba 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -444,6 +444,8 @@ lnet_prep_send(struct lnet_msg *msg, int type, struct lnet_process_id target,
 
 	memset(&msg->msg_hdr, 0, sizeof(msg->msg_hdr));
 	msg->msg_hdr.type	   = cpu_to_le32(type);
+	/* dest_nid will be overwritten by lnet_select_pathway() */
+	msg->msg_hdr.dest_nid       = cpu_to_le64(target.nid);
 	msg->msg_hdr.dest_pid       = cpu_to_le32(target.pid);
 	/* src_nid will be set later */
 	msg->msg_hdr.src_pid	= cpu_to_le32(the_lnet.ln_pid);
@@ -1292,7 +1294,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 */
 	peer = lpni->lpni_peer_net->lpn_peer;
 	if (lnet_msg_discovery(msg) && !lnet_peer_is_uptodate(peer)) {
-		rc = lnet_discover_peer_locked(lpni, cpt);
+		rc = lnet_discover_peer_locked(lpni, cpt, false);
 		if (rc) {
 			lnet_peer_ni_decref_locked(lpni);
 			lnet_net_unlock(cpt);
@@ -1300,6 +1302,18 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		}
 		/* The peer may have changed. */
 		peer = lpni->lpni_peer_net->lpn_peer;
+		/* queue message and return */
+		msg->msg_src_nid_param = src_nid;
+		msg->msg_rtr_nid_param = rtr_nid;
+		msg->msg_sending = 0;
+		list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
+		lnet_peer_ni_decref_locked(lpni);
+		lnet_net_unlock(cpt);
+
+		CDEBUG(D_NET, "%s pending discovery\n",
+		       libcfs_nid2str(peer->lp_primary_nid));
+
+		return LNET_DC_WAIT;
 	}
 	lnet_peer_ni_decref_locked(lpni);
 
@@ -1840,7 +1854,7 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 	if (rc == LNET_CREDIT_OK)
 		lnet_ni_send(msg->msg_txni, msg);
 
-	/* rc == LNET_CREDIT_OK or LNET_CREDIT_WAIT */
+	/* rc == LNET_CREDIT_OK or LNET_CREDIT_WAIT or LNET_DC_WAIT */
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index b78f99c354de..1ef4a44e752e 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -38,6 +38,11 @@
 #include <linux/lnet/lib-lnet.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
 
+/* Value indicating that recovery needs to re-check a peer immediately. */
+#define LNET_REDISCOVER_PEER	(1)
+
+static int lnet_peer_queue_for_discovery(struct lnet_peer *lp);
+
 static void
 lnet_peer_remove_from_remote_list(struct lnet_peer_ni *lpni)
 {
@@ -202,6 +207,7 @@ lnet_peer_alloc(lnet_nid_t nid)
 	INIT_LIST_HEAD(&lp->lp_peer_list);
 	INIT_LIST_HEAD(&lp->lp_peer_nets);
 	INIT_LIST_HEAD(&lp->lp_dc_list);
+	INIT_LIST_HEAD(&lp->lp_dc_pendq);
 	init_waitqueue_head(&lp->lp_dc_waitq);
 	spin_lock_init(&lp->lp_lock);
 	lp->lp_primary_nid = nid;
@@ -220,6 +226,10 @@ lnet_destroy_peer_locked(struct lnet_peer *lp)
 	LASSERT(atomic_read(&lp->lp_refcount) == 0);
 	LASSERT(list_empty(&lp->lp_peer_nets));
 	LASSERT(list_empty(&lp->lp_peer_list));
+	LASSERT(list_empty(&lp->lp_dc_list));
+
+	if (lp->lp_data)
+		lnet_ping_buffer_decref(lp->lp_data);
 
 	kfree(lp);
 }
@@ -260,10 +270,19 @@ lnet_peer_detach_peer_ni_locked(struct lnet_peer_ni *lpni)
 	/*
 	 * If there are no more peer nets, make the peer unfindable
 	 * via the peer_tables.
+	 *
+	 * Otherwise, if the peer is DISCOVERED, tell discovery to
+	 * take another look at it. This is a no-op if discovery for
+	 * this peer did the detaching.
 	 */
 	if (list_empty(&lp->lp_peer_nets)) {
 		list_del_init(&lp->lp_peer_list);
 		ptable->pt_peers--;
+	} else if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING) {
+		/* Discovery isn't running, nothing to do here. */
+	} else if (lp->lp_state & LNET_PEER_DISCOVERED) {
+		lnet_peer_queue_for_discovery(lp);
+		wake_up(&the_lnet.ln_dc_waitq);
 	}
 	CDEBUG(D_NET, "peer %s NID %s\n",
 	       libcfs_nid2str(lp->lp_primary_nid),
@@ -599,6 +618,25 @@ lnet_find_peer_ni_locked(lnet_nid_t nid)
 	return lpni;
 }
 
+struct lnet_peer *
+lnet_find_peer(lnet_nid_t nid)
+{
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer *lp = NULL;
+	int cpt;
+
+	cpt = lnet_net_lock_current();
+	lpni = lnet_find_peer_ni_locked(nid);
+	if (lpni) {
+		lp = lpni->lpni_peer_net->lpn_peer;
+		lnet_peer_addref_locked(lp);
+		lnet_peer_ni_decref_locked(lpni);
+	}
+	lnet_net_unlock(cpt);
+
+	return lp;
+}
+
 struct lnet_peer_ni *
 lnet_get_peer_ni_idx_locked(int idx, struct lnet_peer_net **lpn,
 			    struct lnet_peer **lp)
@@ -696,6 +734,37 @@ lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 	return lpni;
 }
 
+/*
+ * Start pushes to peers that need to be updated for a configuration
+ * change on this node.
+ */
+void
+lnet_push_update_to_peers(int force)
+{
+	struct lnet_peer_table *ptable;
+	struct lnet_peer *lp;
+	int lncpt;
+	int cpt;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
+	for (cpt = 0; cpt < lncpt; cpt++) {
+		ptable = the_lnet.ln_peer_tables[cpt];
+		list_for_each_entry(lp, &ptable->pt_peer_list, lp_peer_list) {
+			if (force) {
+				spin_lock(&lp->lp_lock);
+				if (lp->lp_state & LNET_PEER_MULTI_RAIL)
+					lp->lp_state |= LNET_PEER_FORCE_PUSH;
+				spin_unlock(&lp->lp_lock);
+			}
+			if (lnet_peer_needs_push(lp))
+				lnet_peer_queue_for_discovery(lp);
+		}
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+	wake_up(&the_lnet.ln_dc_waitq);
+}
+
 /*
  * Test whether a ni is a preferred ni for this peer_ni, e.g, whether
  * this is a preferred point-to-point path. Call with lnet_net_lock in
@@ -941,6 +1010,7 @@ lnet_peer_primary_nid_locked(lnet_nid_t nid)
 lnet_nid_t
 LNetPrimaryNID(lnet_nid_t nid)
 {
+	struct lnet_peer *lp;
 	struct lnet_peer_ni *lpni;
 	lnet_nid_t primary_nid = nid;
 	int rc = 0;
@@ -952,7 +1022,15 @@ LNetPrimaryNID(lnet_nid_t nid)
 		rc = PTR_ERR(lpni);
 		goto out_unlock;
 	}
-	primary_nid = lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
+	lp = lpni->lpni_peer_net->lpn_peer;
+	while (!lnet_peer_is_uptodate(lp)) {
+		rc = lnet_discover_peer_locked(lpni, cpt, true);
+		if (rc)
+			goto out_decref;
+		lp = lpni->lpni_peer_net->lpn_peer;
+	}
+	primary_nid = lp->lp_primary_nid;
+out_decref:
 	lnet_peer_ni_decref_locked(lpni);
 out_unlock:
 	lnet_net_unlock(cpt);
@@ -1229,6 +1307,30 @@ lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid, unsigned int flags)
 	return rc;
 }
 
+/*
+ * Update the primary NID of a peer, if possible.
+ *
+ * Call with the lnet_api_mutex held.
+ */
+static int
+lnet_peer_set_primary_nid(struct lnet_peer *lp, lnet_nid_t nid,
+			  unsigned int flags)
+{
+	lnet_nid_t old = lp->lp_primary_nid;
+	int rc = 0;
+
+	if (lp->lp_primary_nid == nid)
+		goto out;
+	rc = lnet_peer_add_nid(lp, nid, flags);
+	if (rc)
+		goto out;
+	lp->lp_primary_nid = nid;
+out:
+	CDEBUG(D_NET, "peer %s NID %s: %d\n",
+	       libcfs_nid2str(old), libcfs_nid2str(nid), rc);
+	return rc;
+}
+
 /*
  * lpni creation initiated due to traffic either sending or receiving.
  */
@@ -1548,11 +1650,15 @@ lnet_peer_is_uptodate(struct lnet_peer *lp)
 			    LNET_PEER_FORCE_PING |
 			    LNET_PEER_FORCE_PUSH)) {
 		rc = false;
+	} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
+		rc = true;
 	} else if (lp->lp_state & LNET_PEER_REDISCOVER) {
 		if (lnet_peer_discovery_disabled)
 			rc = true;
 		else
 			rc = false;
+	} else if (lnet_peer_needs_push(lp)) {
+		rc = false;
 	} else if (lp->lp_state & LNET_PEER_DISCOVERED) {
 		if (lp->lp_state & LNET_PEER_NIDS_UPTODATE)
 			rc = true;
@@ -1588,6 +1694,9 @@ static int lnet_peer_queue_for_discovery(struct lnet_peer *lp)
 		rc = -EALREADY;
 	}
 
+	CDEBUG(D_NET, "Queue peer %s: %d\n",
+	       libcfs_nid2str(lp->lp_primary_nid), rc);
+
 	return rc;
 }
 
@@ -1597,9 +1706,252 @@ static int lnet_peer_queue_for_discovery(struct lnet_peer *lp)
  */
 static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 {
+	struct lnet_msg *msg = NULL;
+	int rc = 0;
+	struct list_head pending_msgs;
+
+	INIT_LIST_HEAD(&pending_msgs);
+
+	CDEBUG(D_NET, "Discovery complete. Dequeue peer %s\n",
+	       libcfs_nid2str(lp->lp_primary_nid));
+
 	list_del_init(&lp->lp_dc_list);
+	list_splice_init(&lp->lp_dc_pendq, &pending_msgs);
 	wake_up_all(&lp->lp_dc_waitq);
+
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	/* iterate through all pending messages and send them again */
+	list_for_each_entry(msg, &pending_msgs, msg_list) {
+		if (lp->lp_dc_error) {
+			lnet_finalize(msg, lp->lp_dc_error);
+			continue;
+		}
+
+		CDEBUG(D_NET, "sending pending message %s to target %s\n",
+		       lnet_msgtyp2str(msg->msg_type),
+		       libcfs_id2str(msg->msg_target));
+		rc = lnet_send(msg->msg_src_nid_param, msg,
+			       msg->msg_rtr_nid_param);
+		if (rc < 0) {
+			CNETERR("Error sending %s to %s: %d\n",
+				lnet_msgtyp2str(msg->msg_type),
+				libcfs_id2str(msg->msg_target), rc);
+			lnet_finalize(msg, rc);
+		}
+	}
+	lnet_net_lock(LNET_LOCK_EX);
+	lnet_peer_decref_locked(lp);
+}
+
+/*
+ * Handle inbound push.
+ * Like any event handler, called with lnet_res_lock/CPT held.
+ */
+void lnet_peer_push_event(struct lnet_event *ev)
+{
+	struct lnet_ping_buffer *pbuf = ev->md.user_ptr;
+	struct lnet_peer *lp;
+
+	/* lnet_find_peer() adds a refcount */
+	lp = lnet_find_peer(ev->source.nid);
+	if (!lp) {
+		CERROR("Push Put from unknown %s (source %s)\n",
+		       libcfs_nid2str(ev->initiator.nid),
+		       libcfs_nid2str(ev->source.nid));
+		return;
+	}
+
+	/* Ensure peer state remains consistent while we modify it. */
+	spin_lock(&lp->lp_lock);
+
+	/*
+	 * If some kind of error happened the contents of the message
+	 * cannot be used. Clear the NIDS_UPTODATE and set the
+	 * FORCE_PING flag to trigger a ping.
+	 */
+	if (ev->status) {
+		lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
+		lp->lp_state |= LNET_PEER_FORCE_PING;
+		CDEBUG(D_NET, "Push Put error %d from %s (source %s)\n",
+		       ev->status,
+		       libcfs_nid2str(lp->lp_primary_nid),
+		       libcfs_nid2str(ev->source.nid));
+		goto out;
+	}
+
+	/*
+	 * A push with invalid or corrupted info. Clear the UPTODATE
+	 * flag to trigger a ping.
+	 */
+	if (lnet_ping_info_validate(&pbuf->pb_info)) {
+		lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
+		lp->lp_state |= LNET_PEER_FORCE_PING;
+		CDEBUG(D_NET, "Corrupted Push from %s\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		goto out;
+	}
+
+	/*
+	 * Make sure we'll allocate the correct size ping buffer when
+	 * pinging the peer.
+	 */
+	if (lp->lp_data_nnis < pbuf->pb_info.pi_nnis)
+		lp->lp_data_nnis = pbuf->pb_info.pi_nnis;
+
+	/*
+	 * A non-Multi-Rail peer is not supposed to be capable of
+	 * sending a push.
+	 */
+	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL)) {
+		CERROR("Push from non-Multi-Rail peer %s dropped\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		goto out;
+	}
+
+	/*
+	 * Check the MULTIRAIL flag. Complain if the peer was DLC
+	 * configured without it.
+	 */
+	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
+		if (lp->lp_state & LNET_PEER_CONFIGURED) {
+			CERROR("Push says %s is Multi-Rail, DLC says not\n",
+			       libcfs_nid2str(lp->lp_primary_nid));
+		} else {
+			lp->lp_state |= LNET_PEER_MULTI_RAIL;
+			lnet_peer_clr_non_mr_pref_nids(lp);
+		}
+	}
+
+	/*
+	 * The peer may have discovery disabled at its end. Set
+	 * NO_DISCOVERY as appropriate.
+	 */
+	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY)) {
+		CDEBUG(D_NET, "Peer %s has discovery disabled\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		lp->lp_state |= LNET_PEER_NO_DISCOVERY;
+	} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
+		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
+	}
+
+	/*
+	 * Check for truncation of the Put message. Clear the
+	 * NIDS_UPTODATE flag and set FORCE_PING to trigger a ping,
+	 * and tell discovery to allocate a bigger buffer.
+	 */
+	if (pbuf->pb_nnis < pbuf->pb_info.pi_nnis) {
+		if (the_lnet.ln_push_target_nnis < pbuf->pb_info.pi_nnis)
+			the_lnet.ln_push_target_nnis = pbuf->pb_info.pi_nnis;
+		lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
+		lp->lp_state |= LNET_PEER_FORCE_PING;
+		CDEBUG(D_NET, "Truncated Push from %s (%d nids)\n",
+		       libcfs_nid2str(lp->lp_primary_nid),
+		       pbuf->pb_info.pi_nnis);
+		goto out;
+	}
+
+	/*
+	 * Check whether the Put data is stale. Stale data can just be
+	 * dropped.
+	 */
+	if (pbuf->pb_info.pi_nnis > 1 &&
+	    lp->lp_primary_nid == pbuf->pb_info.pi_ni[1].ns_nid &&
+	    LNET_PING_BUFFER_SEQNO(pbuf) < lp->lp_peer_seqno) {
+		CDEBUG(D_NET, "Stale Push from %s: got %u have %u\n",
+		       libcfs_nid2str(lp->lp_primary_nid),
+		       LNET_PING_BUFFER_SEQNO(pbuf),
+		       lp->lp_peer_seqno);
+		goto out;
+	}
+
+	/*
+	 * Check whether the Put data is new, in which case we clear
+	 * the UPTODATE flag and prepare to process it.
+	 *
+	 * If the Put data is current, and the peer is UPTODATE then
+	 * we assome everything is all right and drop the data as
+	 * stale.
+	 */
+	if (LNET_PING_BUFFER_SEQNO(pbuf) > lp->lp_peer_seqno) {
+		lp->lp_peer_seqno = LNET_PING_BUFFER_SEQNO(pbuf);
+		lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
+	} else if (lp->lp_state & LNET_PEER_NIDS_UPTODATE) {
+		CDEBUG(D_NET, "Stale Push from %s: got %u have %u\n",
+		       libcfs_nid2str(lp->lp_primary_nid),
+		       LNET_PING_BUFFER_SEQNO(pbuf),
+		       lp->lp_peer_seqno);
+		goto out;
+	}
+
+	/*
+	 * If there is data present that hasn't been processed yet,
+	 * we'll replace it if the Put contained newer data and it
+	 * fits. We're racing with a Ping or earlier Push in this
+	 * case.
+	 */
+	if (lp->lp_state & LNET_PEER_DATA_PRESENT) {
+		if (LNET_PING_BUFFER_SEQNO(pbuf) >
+			LNET_PING_BUFFER_SEQNO(lp->lp_data) &&
+		    pbuf->pb_info.pi_nnis <= lp->lp_data->pb_nnis) {
+			memcpy(&lp->lp_data->pb_info, &pbuf->pb_info,
+			       LNET_PING_INFO_SIZE(pbuf->pb_info.pi_nnis));
+			CDEBUG(D_NET, "Ping/Push race from %s: %u vs %u\n",
+			       libcfs_nid2str(lp->lp_primary_nid),
+			       LNET_PING_BUFFER_SEQNO(pbuf),
+			       LNET_PING_BUFFER_SEQNO(lp->lp_data));
+		}
+		goto out;
+	}
+
+	/*
+	 * Allocate a buffer to copy the data. On a failure we drop
+	 * the Push and set FORCE_PING to force the discovery
+	 * thread to fix the problem by pinging the peer.
+	 */
+	lp->lp_data = lnet_ping_buffer_alloc(lp->lp_data_nnis, GFP_ATOMIC);
+	if (!lp->lp_data) {
+		lp->lp_state |= LNET_PEER_FORCE_PING;
+		CDEBUG(D_NET, "Cannot allocate Push buffer for %s %u\n",
+		       libcfs_nid2str(lp->lp_primary_nid),
+		       LNET_PING_BUFFER_SEQNO(pbuf));
+		goto out;
+	}
+
+	/* Success */
+	memcpy(&lp->lp_data->pb_info, &pbuf->pb_info,
+	       LNET_PING_INFO_SIZE(pbuf->pb_info.pi_nnis));
+	lp->lp_state |= LNET_PEER_DATA_PRESENT;
+	CDEBUG(D_NET, "Received Push %s %u\n",
+	       libcfs_nid2str(lp->lp_primary_nid),
+	       LNET_PING_BUFFER_SEQNO(pbuf));
+
+out:
+	/*
+	 * Queue the peer for discovery, and wake the discovery thread
+	 * if the peer was already queued, because its status changed.
+	 */
+	spin_unlock(&lp->lp_lock);
+	lnet_net_lock(LNET_LOCK_EX);
+	if (lnet_peer_queue_for_discovery(lp))
+		wake_up(&the_lnet.ln_dc_waitq);
+	/* Drop refcount from lookup */
 	lnet_peer_decref_locked(lp);
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+
+/*
+ * Clear the discovery error state, unless we're already discovering
+ * this peer, in which case the error is current.
+ */
+static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
+{
+	spin_lock(&lp->lp_lock);
+	if (!(lp->lp_state & LNET_PEER_DISCOVERING))
+		lp->lp_dc_error = 0;
+	spin_unlock(&lp->lp_lock);
 }
 
 /*
@@ -1608,7 +1960,7 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
  * because discovery could tear down an lnet_peer.
  */
 int
-lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt)
+lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt, bool block)
 {
 	DEFINE_WAIT(wait);
 	struct lnet_peer *lp;
@@ -1617,25 +1969,40 @@ lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt)
 again:
 	lnet_net_unlock(cpt);
 	lnet_net_lock(LNET_LOCK_EX);
+	lp = lpni->lpni_peer_net->lpn_peer;
+	lnet_peer_clear_discovery_error(lp);
 
-	/* We're willing to be interrupted. */
+	/*
+	 * We're willing to be interrupted. The lpni can become a
+	 * zombie if we race with DLC, so we must check for that.
+	 */
 	for (;;) {
-		lp = lpni->lpni_peer_net->lpn_peer;
 		prepare_to_wait(&lp->lp_dc_waitq, &wait, TASK_INTERRUPTIBLE);
 		if (signal_pending(current))
 			break;
 		if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING)
 			break;
+		if (lp->lp_dc_error)
+			break;
 		if (lnet_peer_is_uptodate(lp))
 			break;
 		lnet_peer_queue_for_discovery(lp);
 		lnet_peer_addref_locked(lp);
+		/*
+		 * if caller requested a non-blocking operation then
+		 * return immediately. Once discovery is complete then the
+		 * peer ref will be decremented and any pending messages
+		 * that were stopped due to discovery will be transmitted.
+		 */
+		if (!block)
+			break;
 		lnet_net_unlock(LNET_LOCK_EX);
 		schedule();
 		finish_wait(&lp->lp_dc_waitq, &wait);
 		lnet_net_lock(LNET_LOCK_EX);
 		lnet_peer_decref_locked(lp);
-		/* Do not use lp beyond this point. */
+		/* Peer may have changed */
+		lp = lpni->lpni_peer_net->lpn_peer;
 	}
 	finish_wait(&lp->lp_dc_waitq, &wait);
 
@@ -1646,71 +2013,969 @@ lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt)
 		rc = -EINTR;
 	else if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING)
 		rc = -ESHUTDOWN;
+	else if (lp->lp_dc_error)
+		rc = lp->lp_dc_error;
+	else if (!block)
+		CDEBUG(D_NET, "non-blocking discovery\n");
 	else if (!lnet_peer_is_uptodate(lp))
 		goto again;
 
+	CDEBUG(D_NET, "peer %s NID %s: %d. %s\n",
+	       (lp ? libcfs_nid2str(lp->lp_primary_nid) : "(none)"),
+	       libcfs_nid2str(lpni->lpni_nid), rc,
+	       (!block) ? "pending discovery" : "discovery complete");
+
 	return rc;
 }
 
-/*
- * Event handler for the discovery EQ.
- *
- * Called with lnet_res_lock(cpt) held. The cpt is the
- * lnet_cpt_of_cookie() of the md handle cookie.
- */
-static void lnet_discovery_event_handler(struct lnet_event *event)
+/* Handle an incoming ack for a push. */
+static void
+lnet_discovery_event_ack(struct lnet_peer *lp, struct lnet_event *ev)
 {
-	wake_up(&the_lnet.ln_dc_waitq);
+	struct lnet_ping_buffer *pbuf;
+
+	pbuf = LNET_PING_INFO_TO_BUFFER(ev->md.start);
+	spin_lock(&lp->lp_lock);
+	lp->lp_state &= ~LNET_PEER_PUSH_SENT;
+	lp->lp_push_error = ev->status;
+	if (ev->status)
+		lp->lp_state |= LNET_PEER_PUSH_FAILED;
+	else
+		lp->lp_node_seqno = LNET_PING_BUFFER_SEQNO(pbuf);
+	spin_unlock(&lp->lp_lock);
+
+	CDEBUG(D_NET, "peer %s ev->status %d\n",
+	       libcfs_nid2str(lp->lp_primary_nid), ev->status);
 }
 
-/*
- * Wait for work to be queued or some other change that must be
- * attended to. Returns non-zero if the discovery thread should shut
- * down.
- */
-static int lnet_peer_discovery_wait_for_work(void)
+/* Handle a Reply message. This is the reply to a Ping message. */
+static void
+lnet_discovery_event_reply(struct lnet_peer *lp, struct lnet_event *ev)
 {
-	int cpt;
-	int rc = 0;
+	struct lnet_ping_buffer *pbuf;
+	int rc;
 
-	DEFINE_WAIT(wait);
+	spin_lock(&lp->lp_lock);
 
-	cpt = lnet_net_lock_current();
-	for (;;) {
-		prepare_to_wait(&the_lnet.ln_dc_waitq, &wait,
-				TASK_IDLE);
-		if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
-			break;
-		if (lnet_push_target_resize_needed())
-			break;
-		if (!list_empty(&the_lnet.ln_dc_request))
-			break;
-		lnet_net_unlock(cpt);
-		schedule();
-		finish_wait(&the_lnet.ln_dc_waitq, &wait);
-		cpt = lnet_net_lock_current();
+	/*
+	 * If some kind of error happened the contents of message
+	 * cannot be used. Set PING_FAILED to trigger a retry.
+	 */
+	if (ev->status) {
+		lp->lp_state |= LNET_PEER_PING_FAILED;
+		lp->lp_ping_error = ev->status;
+		CDEBUG(D_NET, "Ping Reply error %d from %s (source %s)\n",
+		       ev->status,
+		       libcfs_nid2str(lp->lp_primary_nid),
+		       libcfs_nid2str(ev->source.nid));
+		goto out;
 	}
-	finish_wait(&the_lnet.ln_dc_waitq, &wait);
-
-	if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
-		rc = -ESHUTDOWN;
 
-	lnet_net_unlock(cpt);
+	pbuf = LNET_PING_INFO_TO_BUFFER(ev->md.start);
+	if (pbuf->pb_info.pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
+		lnet_swap_pinginfo(pbuf);
 
-	CDEBUG(D_NET, "woken: %d\n", rc);
+	/*
+	 * A reply with invalid or corrupted info. Set PING_FAILED to
+	 * trigger a retry.
+	 */
+	rc = lnet_ping_info_validate(&pbuf->pb_info);
+	if (rc) {
+		lp->lp_state |= LNET_PEER_PING_FAILED;
+		lp->lp_ping_error = 0;
+		CDEBUG(D_NET, "Corrupted Ping Reply from %s: %d\n",
+		       libcfs_nid2str(lp->lp_primary_nid), rc);
+		goto out;
+	}
 
-	return rc;
-}
+	/*
+	 * Update the MULTI_RAIL flag based on the reply. If the peer
+	 * was configured with DLC then the setting should match what
+	 * DLC put in.
+	 */
+	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL) {
+		if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
+			/* Everything's fine */
+		} else if (lp->lp_state & LNET_PEER_CONFIGURED) {
+			CWARN("Reply says %s is Multi-Rail, DLC says not\n",
+			      libcfs_nid2str(lp->lp_primary_nid));
+		} else {
+			lp->lp_state |= LNET_PEER_MULTI_RAIL;
+			lnet_peer_clr_non_mr_pref_nids(lp);
+		}
+	} else if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
+		if (lp->lp_state & LNET_PEER_CONFIGURED) {
+			CWARN("DLC says %s is Multi-Rail, Reply says not\n",
+			      libcfs_nid2str(lp->lp_primary_nid));
+		} else {
+			CERROR("Multi-Rail state vanished from %s\n",
+			       libcfs_nid2str(lp->lp_primary_nid));
+			lp->lp_state &= ~LNET_PEER_MULTI_RAIL;
+		}
+	}
 
-/* The discovery thread. */
-static int lnet_peer_discovery(void *arg)
-{
-	struct lnet_peer *lp;
+	/*
+	 * Make sure we'll allocate the correct size ping buffer when
+	 * pinging the peer.
+	 */
+	if (lp->lp_data_nnis < pbuf->pb_info.pi_nnis)
+		lp->lp_data_nnis = pbuf->pb_info.pi_nnis;
 
-	CDEBUG(D_NET, "started\n");
+	/*
+	 * The peer may have discovery disabled at its end. Set
+	 * NO_DISCOVERY as appropriate.
+	 */
+	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY)) {
+		CDEBUG(D_NET, "Peer %s has discovery disabled\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		lp->lp_state |= LNET_PEER_NO_DISCOVERY;
+	} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
+		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
+	}
 
-	for (;;) {
-		if (lnet_peer_discovery_wait_for_work())
+	/*
+	 * Check for truncation of the Reply. Clear PING_SENT and set
+	 * PING_FAILED to trigger a retry.
+	 */
+	if (pbuf->pb_nnis < pbuf->pb_info.pi_nnis) {
+		if (the_lnet.ln_push_target_nnis < pbuf->pb_info.pi_nnis)
+			the_lnet.ln_push_target_nnis = pbuf->pb_info.pi_nnis;
+		lp->lp_state |= LNET_PEER_PING_FAILED;
+		lp->lp_ping_error = 0;
+		CDEBUG(D_NET, "Truncated Reply from %s (%d nids)\n",
+		       libcfs_nid2str(lp->lp_primary_nid),
+		       pbuf->pb_info.pi_nnis);
+		goto out;
+	}
+
+	/*
+	 * Check the sequence numbers in the reply. These are only
+	 * available if the reply came from a Multi-Rail peer.
+	 */
+	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL &&
+	    pbuf->pb_info.pi_nnis > 1 &&
+	    lp->lp_primary_nid == pbuf->pb_info.pi_ni[1].ns_nid) {
+		if (LNET_PING_BUFFER_SEQNO(pbuf) < lp->lp_peer_seqno) {
+			CDEBUG(D_NET, "Stale Reply from %s: got %u have %u\n",
+			       libcfs_nid2str(lp->lp_primary_nid),
+			       LNET_PING_BUFFER_SEQNO(pbuf),
+			       lp->lp_peer_seqno);
+			goto out;
+		}
+
+		if (LNET_PING_BUFFER_SEQNO(pbuf) > lp->lp_peer_seqno)
+			lp->lp_peer_seqno = LNET_PING_BUFFER_SEQNO(pbuf);
+	}
+
+	/* We're happy with the state of the data in the buffer. */
+	CDEBUG(D_NET, "peer %s data present %u\n",
+	       libcfs_nid2str(lp->lp_primary_nid), lp->lp_peer_seqno);
+	if (lp->lp_state & LNET_PEER_DATA_PRESENT)
+		lnet_ping_buffer_decref(lp->lp_data);
+	else
+		lp->lp_state |= LNET_PEER_DATA_PRESENT;
+	lnet_ping_buffer_addref(pbuf);
+	lp->lp_data = pbuf;
+out:
+	lp->lp_state &= ~LNET_PEER_PING_SENT;
+	spin_unlock(&lp->lp_lock);
+}
+
+/*
+ * Send event handling. Only matters for error cases, where we clean
+ * up state on the peer and peer_ni that would otherwise be updated in
+ * the REPLY event handler for a successful Ping, and the ACK event
+ * handler for a successful Push.
+ */
+static int
+lnet_discovery_event_send(struct lnet_peer *lp, struct lnet_event *ev)
+{
+	int rc = 0;
+
+	if (!ev->status)
+		goto out;
+
+	spin_lock(&lp->lp_lock);
+	if (ev->msg_type == LNET_MSG_GET) {
+		lp->lp_state &= ~LNET_PEER_PING_SENT;
+		lp->lp_state |= LNET_PEER_PING_FAILED;
+		lp->lp_ping_error = ev->status;
+	} else { /* ev->msg_type == LNET_MSG_PUT */
+		lp->lp_state &= ~LNET_PEER_PUSH_SENT;
+		lp->lp_state |= LNET_PEER_PUSH_FAILED;
+		lp->lp_push_error = ev->status;
+	}
+	spin_unlock(&lp->lp_lock);
+	rc = LNET_REDISCOVER_PEER;
+out:
+	CDEBUG(D_NET, "%s Send to %s: %d\n",
+	       (ev->msg_type == LNET_MSG_GET ? "Ping" : "Push"),
+	       libcfs_nid2str(ev->target.nid), rc);
+	return rc;
+}
+
+/*
+ * Unlink event handling. This event is only seen if a call to
+ * LNetMDUnlink() caused the event to be unlinked. If this call was
+ * made after the event was set up in LNetGet() or LNetPut() then we
+ * assume the Ping or Push timed out.
+ */
+static void
+lnet_discovery_event_unlink(struct lnet_peer *lp, struct lnet_event *ev)
+{
+	spin_lock(&lp->lp_lock);
+	/* We've passed through LNetGet() */
+	if (lp->lp_state & LNET_PEER_PING_SENT) {
+		lp->lp_state &= ~LNET_PEER_PING_SENT;
+		lp->lp_state |= LNET_PEER_PING_FAILED;
+		lp->lp_ping_error = -ETIMEDOUT;
+		CDEBUG(D_NET, "Ping Unlink for message to peer %s\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+	}
+	/* We've passed through LNetPut() */
+	if (lp->lp_state & LNET_PEER_PUSH_SENT) {
+		lp->lp_state &= ~LNET_PEER_PUSH_SENT;
+		lp->lp_state |= LNET_PEER_PUSH_FAILED;
+		lp->lp_push_error = -ETIMEDOUT;
+		CDEBUG(D_NET, "Push Unlink for message to peer %s\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+	}
+	spin_unlock(&lp->lp_lock);
+}
+
+/*
+ * Event handler for the discovery EQ.
+ *
+ * Called with lnet_res_lock(cpt) held. The cpt is the
+ * lnet_cpt_of_cookie() of the md handle cookie.
+ */
+static void lnet_discovery_event_handler(struct lnet_event *event)
+{
+	struct lnet_peer *lp = event->md.user_ptr;
+	struct lnet_ping_buffer *pbuf;
+	int rc;
+
+	/* discovery needs to take another look */
+	rc = LNET_REDISCOVER_PEER;
+
+	CDEBUG(D_NET, "Received event: %d\n", event->type);
+
+	switch (event->type) {
+	case LNET_EVENT_ACK:
+		lnet_discovery_event_ack(lp, event);
+		break;
+	case LNET_EVENT_REPLY:
+		lnet_discovery_event_reply(lp, event);
+		break;
+	case LNET_EVENT_SEND:
+		/* Only send failure triggers a retry. */
+		rc = lnet_discovery_event_send(lp, event);
+		break;
+	case LNET_EVENT_UNLINK:
+		/* LNetMDUnlink() was called */
+		lnet_discovery_event_unlink(lp, event);
+		break;
+	default:
+		/* Invalid events. */
+		LBUG();
+	}
+	lnet_net_lock(LNET_LOCK_EX);
+	if (event->unlinked) {
+		pbuf = LNET_PING_INFO_TO_BUFFER(event->md.start);
+		lnet_ping_buffer_decref(pbuf);
+		lnet_peer_decref_locked(lp);
+	}
+	if (rc == LNET_REDISCOVER_PEER) {
+		list_move_tail(&lp->lp_dc_list, &the_lnet.ln_dc_request);
+		wake_up(&the_lnet.ln_dc_waitq);
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+
+/*
+ * Build a peer from incoming data.
+ *
+ * The NIDs in the incoming data are supposed to be structured as follows:
+ *  - loopback
+ *  - primary NID
+ *  - other NIDs in same net
+ *  - NIDs in second net
+ *  - NIDs in third net
+ *  - ...
+ * This due to the way the list of NIDs in the data is created.
+ *
+ * Note that this function will mark the peer uptodate unless an
+ * ENOMEM is encontered. All other errors are due to a conflict
+ * between the DLC configuration and what discovery sees. We treat DLC
+ * as binding, and therefore set the NIDS_UPTODATE flag to prevent the
+ * peer from becoming stuck in discovery.
+ */
+static int lnet_peer_merge_data(struct lnet_peer *lp,
+				struct lnet_ping_buffer *pbuf)
+{
+	struct lnet_peer_ni *lpni;
+	lnet_nid_t *curnis = NULL;
+	lnet_nid_t *addnis = NULL;
+	lnet_nid_t *delnis = NULL;
+	unsigned int flags;
+	int ncurnis;
+	int naddnis;
+	int ndelnis;
+	int nnis = 0;
+	int i;
+	int j;
+	int rc;
+
+	flags = LNET_PEER_DISCOVERED;
+	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL)
+		flags |= LNET_PEER_MULTI_RAIL;
+
+	nnis = max_t(int, lp->lp_nnis, pbuf->pb_info.pi_nnis);
+	curnis = kmalloc_array(nnis, sizeof(lnet_nid_t), GFP_NOFS);
+	addnis = kmalloc_array(nnis, sizeof(lnet_nid_t), GFP_NOFS);
+	delnis = kmalloc_array(nnis, sizeof(lnet_nid_t), GFP_NOFS);
+	if (!curnis || !addnis || !delnis) {
+		rc = -ENOMEM;
+		goto out;
+	}
+	ncurnis = 0;
+	naddnis = 0;
+	ndelnis = 0;
+
+	/* Construct the list of NIDs present in peer. */
+	lpni = NULL;
+	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL)
+		curnis[ncurnis++] = lpni->lpni_nid;
+
+	/*
+	 * Check for NIDs in pbuf not present in curnis[].
+	 * The loop starts at 1 to skip the loopback NID.
+	 */
+	for (i = 1; i < pbuf->pb_info.pi_nnis; i++) {
+		for (j = 0; j < ncurnis; j++)
+			if (pbuf->pb_info.pi_ni[i].ns_nid == curnis[j])
+				break;
+		if (j == ncurnis)
+			addnis[naddnis++] = pbuf->pb_info.pi_ni[i].ns_nid;
+	}
+	/*
+	 * Check for NIDs in curnis[] not present in pbuf.
+	 * The nested loop starts at 1 to skip the loopback NID.
+	 *
+	 * But never add the loopback NID to delnis[]: if it is
+	 * present in curnis[] then this peer is for this node.
+	 */
+	for (i = 0; i < ncurnis; i++) {
+		if (LNET_NETTYP(LNET_NIDNET(curnis[i])) == LOLND)
+			continue;
+		for (j = 1; j < pbuf->pb_info.pi_nnis; j++)
+			if (curnis[i] == pbuf->pb_info.pi_ni[j].ns_nid)
+				break;
+		if (j == pbuf->pb_info.pi_nnis)
+			delnis[ndelnis++] = curnis[i];
+	}
+
+	for (i = 0; i < naddnis; i++) {
+		rc = lnet_peer_add_nid(lp, addnis[i], flags);
+		if (rc) {
+			CERROR("Error adding NID %s to peer %s: %d\n",
+			       libcfs_nid2str(addnis[i]),
+			       libcfs_nid2str(lp->lp_primary_nid), rc);
+			if (rc == -ENOMEM)
+				goto out;
+		}
+	}
+	for (i = 0; i < ndelnis; i++) {
+		rc = lnet_peer_del_nid(lp, delnis[i], flags);
+		if (rc) {
+			CERROR("Error deleting NID %s from peer %s: %d\n",
+			       libcfs_nid2str(delnis[i]),
+			       libcfs_nid2str(lp->lp_primary_nid), rc);
+			if (rc == -ENOMEM)
+				goto out;
+		}
+	}
+	/*
+	 * Errors other than -ENOMEM are due to peers having been
+	 * configured with DLC. Ignore these because DLC overrides
+	 * Discovery.
+	 */
+	rc = 0;
+out:
+	kfree(curnis);
+	kfree(addnis);
+	kfree(delnis);
+	lnet_ping_buffer_decref(pbuf);
+	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(lp->lp_primary_nid), rc);
+
+	if (rc) {
+		spin_lock(&lp->lp_lock);
+		lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
+		lp->lp_state |= LNET_PEER_FORCE_PING;
+		spin_unlock(&lp->lp_lock);
+	}
+	return rc;
+}
+
+/*
+ * The data in pbuf says lp is its primary peer, but the data was
+ * received by a different peer. Try to update lp with the data.
+ */
+static int
+lnet_peer_set_primary_data(struct lnet_peer *lp, struct lnet_ping_buffer *pbuf)
+{
+	struct lnet_handle_md mdh;
+
+	/* Queue lp for discovery, and force it on the request queue. */
+	lnet_net_lock(LNET_LOCK_EX);
+	if (lnet_peer_queue_for_discovery(lp))
+		list_move(&lp->lp_dc_list, &the_lnet.ln_dc_request);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	LNetInvalidateMDHandle(&mdh);
+
+	/*
+	 * Decide whether we can move the peer to the DATA_PRESENT state.
+	 *
+	 * We replace stale data for a multi-rail peer, repair PING_FAILED
+	 * status, and preempt FORCE_PING.
+	 *
+	 * If after that we have DATA_PRESENT, we merge it into this peer.
+	 */
+	spin_lock(&lp->lp_lock);
+	if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
+		if (lp->lp_peer_seqno < LNET_PING_BUFFER_SEQNO(pbuf)) {
+			lp->lp_peer_seqno = LNET_PING_BUFFER_SEQNO(pbuf);
+		} else if (lp->lp_state & LNET_PEER_DATA_PRESENT) {
+			lp->lp_state &= ~LNET_PEER_DATA_PRESENT;
+			lnet_ping_buffer_decref(pbuf);
+			pbuf = lp->lp_data;
+			lp->lp_data = NULL;
+		}
+	}
+	if (lp->lp_state & LNET_PEER_DATA_PRESENT) {
+		lnet_ping_buffer_decref(lp->lp_data);
+		lp->lp_data = NULL;
+		lp->lp_state &= ~LNET_PEER_DATA_PRESENT;
+	}
+	if (lp->lp_state & LNET_PEER_PING_FAILED) {
+		mdh = lp->lp_ping_mdh;
+		LNetInvalidateMDHandle(&lp->lp_ping_mdh);
+		lp->lp_state &= ~LNET_PEER_PING_FAILED;
+		lp->lp_ping_error = 0;
+	}
+	if (lp->lp_state & LNET_PEER_FORCE_PING)
+		lp->lp_state &= ~LNET_PEER_FORCE_PING;
+	lp->lp_state |= LNET_PEER_NIDS_UPTODATE;
+	spin_unlock(&lp->lp_lock);
+
+	if (!LNetMDHandleIsInvalid(mdh))
+		LNetMDUnlink(mdh);
+
+	if (pbuf)
+		return lnet_peer_merge_data(lp, pbuf);
+
+	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+	return 0;
+}
+
+/*
+ * Update a peer using the data received.
+ */
+static int lnet_peer_data_present(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
+{
+	struct lnet_ping_buffer *pbuf;
+	struct lnet_peer_ni *lpni;
+	lnet_nid_t nid = LNET_NID_ANY;
+	unsigned int flags;
+	int rc = 0;
+
+	pbuf = lp->lp_data;
+	lp->lp_data = NULL;
+	lp->lp_state &= ~LNET_PEER_DATA_PRESENT;
+	lp->lp_state |= LNET_PEER_NIDS_UPTODATE;
+	spin_unlock(&lp->lp_lock);
+
+	/*
+	 * Modifications of peer structures are done while holding the
+	 * ln_api_mutex. A global lock is required because we may be
+	 * modifying multiple peer structures, and a mutex greatly
+	 * simplifies memory management.
+	 *
+	 * The actual changes to the data structures must also protect
+	 * against concurrent lookups, for which the lnet_net_lock in
+	 * LNET_LOCK_EX mode is used.
+	 */
+	mutex_lock(&the_lnet.ln_api_mutex);
+	if (the_lnet.ln_state == LNET_STATE_SHUTDOWN) {
+		rc = -ESHUTDOWN;
+		goto out;
+	}
+
+	/*
+	 * If this peer is not on the peer list then it is being torn
+	 * down, and our reference count may be all that is keeping it
+	 * alive. Don't do any work on it.
+	 */
+	if (list_empty(&lp->lp_peer_list))
+		goto out;
+
+	flags = LNET_PEER_DISCOVERED;
+	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL)
+		flags |= LNET_PEER_MULTI_RAIL;
+
+	/*
+	 * Check whether the primary NID in the message matches the
+	 * primary NID of the peer. If it does, update the peer, if
+	 * it it does not, check whether there is already a peer with
+	 * that primary NID. If no such peer exists, try to update
+	 * the primary NID of the current peer (allowed if it was
+	 * created due to message traffic) and complete the update.
+	 * If the peer did exist, hand off the data to it.
+	 *
+	 * The peer for the loopback interface is a special case: this
+	 * is the peer for the local node, and we want to set its
+	 * primary NID to the correct value here.
+	 */
+	if (pbuf->pb_info.pi_nnis > 1)
+		nid = pbuf->pb_info.pi_ni[1].ns_nid;
+	if (LNET_NETTYP(LNET_NIDNET(lp->lp_primary_nid)) == LOLND) {
+		rc = lnet_peer_set_primary_nid(lp, nid, flags);
+		if (!rc)
+			rc = lnet_peer_merge_data(lp, pbuf);
+	} else if (lp->lp_primary_nid == nid) {
+		rc = lnet_peer_merge_data(lp, pbuf);
+	} else {
+		lpni = lnet_find_peer_ni_locked(nid);
+		if (!lpni) {
+			rc = lnet_peer_set_primary_nid(lp, nid, flags);
+			if (rc) {
+				CERROR("Primary NID error %s versus %s: %d\n",
+				       libcfs_nid2str(lp->lp_primary_nid),
+				       libcfs_nid2str(nid), rc);
+			} else {
+				rc = lnet_peer_merge_data(lp, pbuf);
+			}
+		} else {
+			rc = lnet_peer_set_primary_data(
+				lpni->lpni_peer_net->lpn_peer, pbuf);
+			lnet_peer_ni_decref_locked(lpni);
+		}
+	}
+out:
+	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(lp->lp_primary_nid), rc);
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	spin_lock(&lp->lp_lock);
+	/* Tell discovery to re-check the peer immediately. */
+	if (!rc)
+		rc = LNET_REDISCOVER_PEER;
+	return rc;
+}
+
+/*
+ * A ping failed. Clear the PING_FAILED state and set the
+ * FORCE_PING state, to ensure a retry even if discovery is
+ * disabled. This avoids being left with incorrect state.
+ */
+static int lnet_peer_ping_failed(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
+{
+	struct lnet_handle_md mdh;
+	int rc;
+
+	mdh = lp->lp_ping_mdh;
+	LNetInvalidateMDHandle(&lp->lp_ping_mdh);
+	lp->lp_state &= ~LNET_PEER_PING_FAILED;
+	lp->lp_state |= LNET_PEER_FORCE_PING;
+	rc = lp->lp_ping_error;
+	lp->lp_ping_error = 0;
+	spin_unlock(&lp->lp_lock);
+
+	if (!LNetMDHandleIsInvalid(mdh))
+		LNetMDUnlink(mdh);
+
+	CDEBUG(D_NET, "peer %s:%d\n",
+	       libcfs_nid2str(lp->lp_primary_nid), rc);
+
+	spin_lock(&lp->lp_lock);
+	return rc ? rc : LNET_REDISCOVER_PEER;
+}
+
+/*
+ * Select NID to send a Ping or Push to.
+ */
+static lnet_nid_t lnet_peer_select_nid(struct lnet_peer *lp)
+{
+	struct lnet_peer_ni *lpni;
+
+	/* Look for a direct-connected NID for this peer. */
+	lpni = NULL;
+	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
+		if (!lnet_is_peer_ni_healthy_locked(lpni))
+			continue;
+		if (!lnet_get_net_locked(lpni->lpni_peer_net->lpn_net_id))
+			continue;
+		break;
+	}
+	if (lpni)
+		return lpni->lpni_nid;
+
+	/* Look for a routed-connected NID for this peer. */
+	lpni = NULL;
+	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
+		if (!lnet_is_peer_ni_healthy_locked(lpni))
+			continue;
+		if (!lnet_find_rnet_locked(lpni->lpni_peer_net->lpn_net_id))
+			continue;
+		break;
+	}
+	if (lpni)
+		return lpni->lpni_nid;
+
+	return LNET_NID_ANY;
+}
+
+/* Active side of ping. */
+static int lnet_peer_send_ping(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
+{
+	struct lnet_md md = { NULL };
+	struct lnet_process_id id;
+	struct lnet_ping_buffer *pbuf;
+	int nnis;
+	int rc;
+	int cpt;
+
+	lp->lp_state |= LNET_PEER_PING_SENT;
+	lp->lp_state &= ~LNET_PEER_FORCE_PING;
+	spin_unlock(&lp->lp_lock);
+
+	nnis = max_t(int, lp->lp_data_nnis, LNET_INTERFACES_MIN);
+	pbuf = lnet_ping_buffer_alloc(nnis, GFP_NOFS);
+	if (!pbuf) {
+		rc = -ENOMEM;
+		goto fail_error;
+	}
+
+	/* initialize md content */
+	md.start     = &pbuf->pb_info;
+	md.length    = LNET_PING_INFO_SIZE(nnis);
+	md.threshold = 2; /* GET/REPLY */
+	md.max_size  = 0;
+	md.options   = LNET_MD_TRUNCATE;
+	md.user_ptr  = lp;
+	md.eq_handle = the_lnet.ln_dc_eqh;
+
+	rc = LNetMDBind(md, LNET_UNLINK, &lp->lp_ping_mdh);
+	if (rc != 0) {
+		lnet_ping_buffer_decref(pbuf);
+		CERROR("Can't bind MD: %d\n", rc);
+		goto fail_error;
+	}
+	cpt = lnet_net_lock_current();
+	/* Refcount for MD. */
+	lnet_peer_addref_locked(lp);
+	id.pid = LNET_PID_LUSTRE;
+	id.nid = lnet_peer_select_nid(lp);
+	lnet_net_unlock(cpt);
+
+	if (id.nid == LNET_NID_ANY) {
+		rc = -EHOSTUNREACH;
+		goto fail_unlink_md;
+	}
+
+	rc = LNetGet(LNET_NID_ANY, lp->lp_ping_mdh, id,
+		     LNET_RESERVED_PORTAL,
+		     LNET_PROTO_PING_MATCHBITS, 0);
+
+	if (rc)
+		goto fail_unlink_md;
+
+	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+
+	spin_lock(&lp->lp_lock);
+	return 0;
+
+fail_unlink_md:
+	LNetMDUnlink(lp->lp_ping_mdh);
+	LNetInvalidateMDHandle(&lp->lp_ping_mdh);
+fail_error:
+	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(lp->lp_primary_nid), rc);
+	/*
+	 * The errors that get us here are considered hard errors and
+	 * cause Discovery to terminate. So we clear PING_SENT, but do
+	 * not set either PING_FAILED or FORCE_PING. In fact we need
+	 * to clear PING_FAILED, because the unlink event handler will
+	 * have set it if we called LNetMDUnlink() above.
+	 */
+	spin_lock(&lp->lp_lock);
+	lp->lp_state &= ~(LNET_PEER_PING_SENT | LNET_PEER_PING_FAILED);
+	return rc;
+}
+
+/*
+ * This function exists because you cannot call LNetMDUnlink() from an
+ * event handler.
+ */
+static int lnet_peer_push_failed(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
+{
+	struct lnet_handle_md mdh;
+	int rc;
+
+	mdh = lp->lp_push_mdh;
+	LNetInvalidateMDHandle(&lp->lp_push_mdh);
+	lp->lp_state &= ~LNET_PEER_PUSH_FAILED;
+	rc = lp->lp_push_error;
+	lp->lp_push_error = 0;
+	spin_unlock(&lp->lp_lock);
+
+	if (!LNetMDHandleIsInvalid(mdh))
+		LNetMDUnlink(mdh);
+
+	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+	spin_lock(&lp->lp_lock);
+	return rc ? rc : LNET_REDISCOVER_PEER;
+}
+
+/* Active side of push. */
+static int lnet_peer_send_push(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
+{
+	struct lnet_ping_buffer *pbuf;
+	struct lnet_process_id id;
+	struct lnet_md md;
+	int cpt;
+	int rc;
+
+	/* Don't push to a non-multi-rail peer. */
+	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
+		lp->lp_state &= ~LNET_PEER_FORCE_PUSH;
+		return 0;
+	}
+
+	lp->lp_state |= LNET_PEER_PUSH_SENT;
+	lp->lp_state &= ~LNET_PEER_FORCE_PUSH;
+	spin_unlock(&lp->lp_lock);
+
+	cpt = lnet_net_lock_current();
+	pbuf = the_lnet.ln_ping_target;
+	lnet_ping_buffer_addref(pbuf);
+	lnet_net_unlock(cpt);
+
+	/* Push source MD */
+	md.start     = &pbuf->pb_info;
+	md.length    = LNET_PING_INFO_SIZE(pbuf->pb_nnis);
+	md.threshold = 2; /* Put/Ack */
+	md.max_size  = 0;
+	md.options   = 0;
+	md.eq_handle = the_lnet.ln_dc_eqh;
+	md.user_ptr  = lp;
+
+	rc = LNetMDBind(md, LNET_UNLINK, &lp->lp_push_mdh);
+	if (rc) {
+		lnet_ping_buffer_decref(pbuf);
+		CERROR("Can't bind push source MD: %d\n", rc);
+		goto fail_error;
+	}
+	cpt = lnet_net_lock_current();
+	/* Refcount for MD. */
+	lnet_peer_addref_locked(lp);
+	id.pid = LNET_PID_LUSTRE;
+	id.nid = lnet_peer_select_nid(lp);
+	lnet_net_unlock(cpt);
+
+	if (id.nid == LNET_NID_ANY) {
+		rc = -EHOSTUNREACH;
+		goto fail_unlink;
+	}
+
+	rc = LNetPut(LNET_NID_ANY, lp->lp_push_mdh,
+		     LNET_ACK_REQ, id, LNET_RESERVED_PORTAL,
+		     LNET_PROTO_PING_MATCHBITS, 0, 0);
+
+	if (rc)
+		goto fail_unlink;
+
+	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+
+	spin_lock(&lp->lp_lock);
+	return 0;
+
+fail_unlink:
+	LNetMDUnlink(lp->lp_push_mdh);
+	LNetInvalidateMDHandle(&lp->lp_push_mdh);
+fail_error:
+	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(lp->lp_primary_nid), rc);
+	/*
+	 * The errors that get us here are considered hard errors and
+	 * cause Discovery to terminate. So we clear PUSH_SENT, but do
+	 * not set PUSH_FAILED. In fact we need to clear PUSH_FAILED,
+	 * because the unlink event handler will have set it if we
+	 * called LNetMDUnlink() above.
+	 */
+	spin_lock(&lp->lp_lock);
+	lp->lp_state &= ~(LNET_PEER_PUSH_SENT | LNET_PEER_PUSH_FAILED);
+	return rc;
+}
+
+/*
+ * An unrecoverable error was encountered during discovery.
+ * Set error status in peer and abort discovery.
+ */
+static void lnet_peer_discovery_error(struct lnet_peer *lp, int error)
+{
+	CDEBUG(D_NET, "Discovery error %s: %d\n",
+	       libcfs_nid2str(lp->lp_primary_nid), error);
+
+	spin_lock(&lp->lp_lock);
+	lp->lp_dc_error = error;
+	lp->lp_state &= ~LNET_PEER_DISCOVERING;
+	lp->lp_state |= LNET_PEER_REDISCOVER;
+	spin_unlock(&lp->lp_lock);
+}
+
+/*
+ * Mark the peer as discovered.
+ */
+static int lnet_peer_discovered(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
+{
+	lp->lp_state |= LNET_PEER_DISCOVERED;
+	lp->lp_state &= ~(LNET_PEER_DISCOVERING |
+			  LNET_PEER_REDISCOVER);
+
+	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+
+	return 0;
+}
+
+/*
+ * Mark the peer as to be rediscovered.
+ */
+static int lnet_peer_rediscover(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
+{
+	lp->lp_state |= LNET_PEER_REDISCOVER;
+	lp->lp_state &= ~LNET_PEER_DISCOVERING;
+
+	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+
+	return 0;
+}
+
+/*
+ * Returns the first peer on the ln_dc_working queue if its timeout
+ * has expired. Takes the current time as an argument so as to not
+ * obsessively re-check the clock. The oldest discovery request will
+ * be at the head of the queue.
+ */
+static struct lnet_peer *lnet_peer_dc_timed_out(time64_t now)
+{
+	struct lnet_peer *lp;
+
+	if (list_empty(&the_lnet.ln_dc_working))
+		return NULL;
+	lp = list_first_entry(&the_lnet.ln_dc_working,
+			      struct lnet_peer, lp_dc_list);
+	if (now < lp->lp_last_queued + DISCOVERY_TIMEOUT)
+		return NULL;
+	return lp;
+}
+
+/*
+ * Discovering this peer is taking too long. Cancel any Ping or Push
+ * that discovery is waiting on by unlinking the relevant MDs. The
+ * lnet_discovery_event_handler() will proceed from here and complete
+ * the cleanup.
+ */
+static void lnet_peer_discovery_timeout(struct lnet_peer *lp)
+{
+	struct lnet_handle_md ping_mdh;
+	struct lnet_handle_md push_mdh;
+
+	LNetInvalidateMDHandle(&ping_mdh);
+	LNetInvalidateMDHandle(&push_mdh);
+
+	spin_lock(&lp->lp_lock);
+	if (lp->lp_state & LNET_PEER_PING_SENT) {
+		ping_mdh = lp->lp_ping_mdh;
+		LNetInvalidateMDHandle(&lp->lp_ping_mdh);
+	}
+	if (lp->lp_state & LNET_PEER_PUSH_SENT) {
+		push_mdh = lp->lp_push_mdh;
+		LNetInvalidateMDHandle(&lp->lp_push_mdh);
+	}
+	spin_unlock(&lp->lp_lock);
+
+	if (!LNetMDHandleIsInvalid(ping_mdh))
+		LNetMDUnlink(ping_mdh);
+	if (!LNetMDHandleIsInvalid(push_mdh))
+		LNetMDUnlink(push_mdh);
+}
+
+/*
+ * Wait for work to be queued or some other change that must be
+ * attended to. Returns non-zero if the discovery thread should shut
+ * down.
+ */
+static int lnet_peer_discovery_wait_for_work(void)
+{
+	int cpt;
+	int rc = 0;
+
+	DEFINE_WAIT(wait);
+
+	cpt = lnet_net_lock_current();
+	for (;;) {
+		prepare_to_wait(&the_lnet.ln_dc_waitq, &wait,
+				TASK_IDLE);
+		if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
+			break;
+		if (lnet_push_target_resize_needed())
+			break;
+		if (!list_empty(&the_lnet.ln_dc_request))
+			break;
+		if (lnet_peer_dc_timed_out(ktime_get_real_seconds()))
+			break;
+		lnet_net_unlock(cpt);
+
+		/*
+		 * wakeup max every second to check if there are peers that
+		 * have been stuck on the working queue for greater than
+		 * the peer timeout.
+		 */
+		schedule_timeout(HZ);
+		finish_wait(&the_lnet.ln_dc_waitq, &wait);
+		cpt = lnet_net_lock_current();
+	}
+	finish_wait(&the_lnet.ln_dc_waitq, &wait);
+
+	if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
+		rc = -ESHUTDOWN;
+
+	lnet_net_unlock(cpt);
+
+	CDEBUG(D_NET, "woken: %d\n", rc);
+
+	return rc;
+}
+
+/* The discovery thread. */
+static int lnet_peer_discovery(void *arg)
+{
+	struct lnet_peer *lp;
+	time64_t now;
+	int rc;
+
+	CDEBUG(D_NET, "started\n");
+
+	for (;;) {
+		if (lnet_peer_discovery_wait_for_work())
 			break;
 
 		if (lnet_push_target_resize_needed())
@@ -1719,33 +2984,97 @@ static int lnet_peer_discovery(void *arg)
 		lnet_net_lock(LNET_LOCK_EX);
 		if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
 			break;
+
+		/*
+		 * Process all incoming discovery work requests.  When
+		 * discovery must wait on a peer to change state, it
+		 * is added to the tail of the ln_dc_working queue. A
+		 * timestamp keeps track of when the peer was added,
+		 * so we can time out discovery requests that take too
+		 * long.
+		 */
 		while (!list_empty(&the_lnet.ln_dc_request)) {
 			lp = list_first_entry(&the_lnet.ln_dc_request,
 					      struct lnet_peer, lp_dc_list);
 			list_move(&lp->lp_dc_list, &the_lnet.ln_dc_working);
+			/*
+			 * set the time the peer was put on the dc_working
+			 * queue. It shouldn't remain on the queue
+			 * forever, in case the GET message (for ping)
+			 * doesn't get a REPLY or the PUT message (for
+			 * push) doesn't get an ACK.
+			 *
+			 * TODO: LNet Health will deal with this scenario
+			 * in a generic way.
+			 */
+			lp->lp_last_queued = ktime_get_real_seconds();
 			lnet_net_unlock(LNET_LOCK_EX);
 
-			/* Just tag and release for now. */
+			/*
+			 * Select an action depending on the state of
+			 * the peer and whether discovery is disabled.
+			 * The check whether discovery is disabled is
+			 * done after the code that handles processing
+			 * for arrived data, cleanup for failures, and
+			 * forcing a Ping or Push.
+			 */
 			spin_lock(&lp->lp_lock);
-			if (lnet_peer_discovery_disabled) {
-				lp->lp_state |= LNET_PEER_REDISCOVER;
-				lp->lp_state &= ~(LNET_PEER_DISCOVERED |
-						  LNET_PEER_NIDS_UPTODATE |
-						  LNET_PEER_DISCOVERING);
-			} else {
-				lp->lp_state |= (LNET_PEER_DISCOVERED |
-						 LNET_PEER_NIDS_UPTODATE);
-				lp->lp_state &= ~(LNET_PEER_REDISCOVER |
-						  LNET_PEER_DISCOVERING);
-			}
+			CDEBUG(D_NET, "peer %s state %#x\n",
+			       libcfs_nid2str(lp->lp_primary_nid),
+			       lp->lp_state);
+			if (lp->lp_state & LNET_PEER_DATA_PRESENT)
+				rc = lnet_peer_data_present(lp);
+			else if (lp->lp_state & LNET_PEER_PING_FAILED)
+				rc = lnet_peer_ping_failed(lp);
+			else if (lp->lp_state & LNET_PEER_PUSH_FAILED)
+				rc = lnet_peer_push_failed(lp);
+			else if (lp->lp_state & LNET_PEER_FORCE_PING)
+				rc = lnet_peer_send_ping(lp);
+			else if (lp->lp_state & LNET_PEER_FORCE_PUSH)
+				rc = lnet_peer_send_push(lp);
+			else if (lnet_peer_discovery_disabled)
+				rc = lnet_peer_rediscover(lp);
+			else if (!(lp->lp_state & LNET_PEER_NIDS_UPTODATE))
+				rc = lnet_peer_send_ping(lp);
+			else if (lnet_peer_needs_push(lp))
+				rc = lnet_peer_send_push(lp);
+			else
+				rc = lnet_peer_discovered(lp);
+			CDEBUG(D_NET, "peer %s state %#x rc %d\n",
+			       libcfs_nid2str(lp->lp_primary_nid),
+			       lp->lp_state, rc);
 			spin_unlock(&lp->lp_lock);
 
 			lnet_net_lock(LNET_LOCK_EX);
+			if (rc == LNET_REDISCOVER_PEER) {
+				list_move(&lp->lp_dc_list,
+					  &the_lnet.ln_dc_request);
+			} else if (rc) {
+				lnet_peer_discovery_error(lp, rc);
+			}
 			if (!(lp->lp_state & LNET_PEER_DISCOVERING))
 				lnet_peer_discovery_complete(lp);
 			if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
 				break;
 		}
+
+		/*
+		 * Now that the ln_dc_request queue has been emptied
+		 * check the ln_dc_working queue for peers that are
+		 * taking too long. Move all that are found to the
+		 * ln_dc_expired queue and time out any pending
+		 * Ping or Push. We have to drop the lnet_net_lock
+		 * in the loop because lnet_peer_discovery_timeout()
+		 * calls LNetMDUnlink().
+		 */
+		now = ktime_get_real_seconds();
+		while ((lp = lnet_peer_dc_timed_out(now)) != NULL) {
+			list_move(&lp->lp_dc_list, &the_lnet.ln_dc_expired);
+			lnet_net_unlock(LNET_LOCK_EX);
+			lnet_peer_discovery_timeout(lp);
+			lnet_net_lock(LNET_LOCK_EX);
+		}
+
 		lnet_net_unlock(LNET_LOCK_EX);
 	}
 
@@ -1759,23 +3088,28 @@ static int lnet_peer_discovery(void *arg)
 	LNetEQFree(the_lnet.ln_dc_eqh);
 	LNetInvalidateEQHandle(&the_lnet.ln_dc_eqh);
 
+	/* Queue cleanup 1: stop all pending pings and pushes. */
 	lnet_net_lock(LNET_LOCK_EX);
-	list_for_each_entry(lp, &the_lnet.ln_dc_request, lp_dc_list) {
-		spin_lock(&lp->lp_lock);
-		lp->lp_state |= LNET_PEER_REDISCOVER;
-		lp->lp_state &= ~(LNET_PEER_DISCOVERED |
-				  LNET_PEER_DISCOVERING |
-				  LNET_PEER_NIDS_UPTODATE);
-		spin_unlock(&lp->lp_lock);
-		lnet_peer_discovery_complete(lp);
+	while (!list_empty(&the_lnet.ln_dc_working)) {
+		lp = list_first_entry(&the_lnet.ln_dc_working,
+				      struct lnet_peer, lp_dc_list);
+		list_move(&lp->lp_dc_list, &the_lnet.ln_dc_expired);
+		lnet_net_unlock(LNET_LOCK_EX);
+		lnet_peer_discovery_timeout(lp);
+		lnet_net_lock(LNET_LOCK_EX);
 	}
-	list_for_each_entry(lp, &the_lnet.ln_dc_working, lp_dc_list) {
-		spin_lock(&lp->lp_lock);
-		lp->lp_state |= LNET_PEER_REDISCOVER;
-		lp->lp_state &= ~(LNET_PEER_DISCOVERED |
-				  LNET_PEER_DISCOVERING |
-				  LNET_PEER_NIDS_UPTODATE);
-		spin_unlock(&lp->lp_lock);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	/* Queue cleanup 2: wait for the expired queue to clear. */
+	while (!list_empty(&the_lnet.ln_dc_expired))
+		schedule_timeout_uninterruptible(HZ);
+
+	/* Queue cleanup 3: clear the request queue. */
+	lnet_net_lock(LNET_LOCK_EX);
+	while (!list_empty(&the_lnet.ln_dc_request)) {
+		lp = list_first_entry(&the_lnet.ln_dc_request,
+				      struct lnet_peer, lp_dc_list);
+		lnet_peer_discovery_error(lp, -ESHUTDOWN);
 		lnet_peer_discovery_complete(lp);
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
@@ -1797,10 +3131,6 @@ int lnet_peer_discovery_start(void)
 	if (the_lnet.ln_dc_state != LNET_DC_STATE_SHUTDOWN)
 		return -EALREADY;
 
-	INIT_LIST_HEAD(&the_lnet.ln_dc_request);
-	INIT_LIST_HEAD(&the_lnet.ln_dc_working);
-	init_waitqueue_head(&the_lnet.ln_dc_waitq);
-
 	rc = LNetEQAlloc(0, lnet_discovery_event_handler, &the_lnet.ln_dc_eqh);
 	if (rc != 0) {
 		CERROR("Can't allocate discovery EQ: %d\n", rc);
@@ -1819,6 +3149,8 @@ int lnet_peer_discovery_start(void)
 		the_lnet.ln_dc_state = LNET_DC_STATE_SHUTDOWN;
 	}
 
+	CDEBUG(D_NET, "discovery start: %d\n", rc);
+
 	return rc;
 }
 
@@ -1837,6 +3169,9 @@ void lnet_peer_discovery_stop(void)
 
 	LASSERT(list_empty(&the_lnet.ln_dc_request));
 	LASSERT(list_empty(&the_lnet.ln_dc_working));
+	LASSERT(list_empty(&the_lnet.ln_dc_expired));
+
+	CDEBUG(D_NET, "discovery stopped\n");
 }
 
 /* Debugging */
