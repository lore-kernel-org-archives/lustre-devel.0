From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:38 +1100
Subject: [lustre-devel] [PATCH 17/24] lustre: lnet: add the Push target
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437820.16383.6069246179655761617.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

Peer Discovery will send a Push message (same format as an
LNet Ping) to Multi-Rail capable peers to give the peer the
list of local interfaces.

Set up a target buffer for these pushes in the_lnet. The
size of this buffer defaults to LNET_MIN_INTERFACES, but it
is resized if required.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25788
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    8 +
 .../staging/lustre/include/linux/lnet/lib-types.h  |   25 +++
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  150 ++++++++++++++++++++
 drivers/staging/lustre/lnet/lnet/peer.c            |    5 +
 4 files changed, 187 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 848d622911a4..5632e5aadf41 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -686,6 +686,14 @@ static inline int lnet_ping_buffer_numref(struct lnet_ping_buffer *pbuf)
 	return atomic_read(&pbuf->pb_refcnt);
 }
 
+static inline int lnet_push_target_resize_needed(void)
+{
+	return the_lnet.ln_push_target->pb_nnis < the_lnet.ln_push_target_nnis;
+}
+
+int lnet_push_target_resize(void);
+void lnet_peer_push_event(struct lnet_event *ev);
+
 int lnet_parse_ip2nets(char **networksp, char *ip2nets);
 int lnet_parse_routes(char *route_str, int *im_a_router);
 int lnet_parse_networks(struct list_head *nilist, char *networks,
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 6394a3af50b7..e00c13355d43 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -521,6 +521,18 @@ struct lnet_peer {
 	/* peer state flags */
 	unsigned int		lp_state;
 
+	/* buffer for data pushed by peer */
+	struct lnet_ping_buffer	*lp_data;
+
+	/* number of NIDs for sizing push data */
+	int			lp_data_nnis;
+
+	/* NI config sequence number of peer */
+	__u32			lp_peer_seqno;
+
+	/* Local NI config sequence number peer knows */
+	__u32			lp_node_seqno;
+
 	/* link on discovery-related lists */
 	struct list_head	lp_dc_list;
 
@@ -912,6 +924,19 @@ struct lnet {
 	struct lnet_ping_buffer		 *ln_ping_target;
 	atomic_t			ln_ping_target_seqno;
 
+	/*
+	 * Push Target
+	 *
+	 * ln_push_nnis contains the desired size of the push target.
+	 * The lnet_net_lock is used to handle update races. The old
+	 * buffer may linger a while after it has been unlinked, in
+	 * which case the event handler cleans up.
+	 */
+	struct lnet_handle_eq		ln_push_target_eq;
+	struct lnet_handle_md		ln_push_target_md;
+	struct lnet_ping_buffer		*ln_push_target;
+	int				ln_push_target_nnis;
+
 	/* discovery event queue handle */
 	struct lnet_handle_eq		ln_dc_eqh;
 	/* discovery requests */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index dccfd5bcc459..e6bc54e9de71 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1268,6 +1268,147 @@ lnet_ping_target_fini(void)
 	lnet_ping_target_destroy();
 }
 
+/* Resize the push target. */
+int lnet_push_target_resize(void)
+{
+	struct lnet_process_id id = { LNET_NID_ANY, LNET_PID_ANY };
+	struct lnet_md md = { NULL };
+	struct lnet_handle_me meh;
+	struct lnet_handle_md mdh;
+	struct lnet_handle_md old_mdh;
+	struct lnet_ping_buffer *pbuf;
+	struct lnet_ping_buffer *old_pbuf;
+	int nnis = the_lnet.ln_push_target_nnis;
+	int rc;
+
+	if (nnis <= 0) {
+		rc = -EINVAL;
+		goto fail_return;
+	}
+again:
+	pbuf = lnet_ping_buffer_alloc(nnis, GFP_NOFS);
+	if (!pbuf) {
+		rc = -ENOMEM;
+		goto fail_return;
+	}
+
+	rc = LNetMEAttach(LNET_RESERVED_PORTAL, id,
+			  LNET_PROTO_PING_MATCHBITS, 0,
+			  LNET_UNLINK, LNET_INS_AFTER,
+			  &meh);
+	if (rc) {
+		CERROR("Can't create push target ME: %d\n", rc);
+		goto fail_decref_pbuf;
+	}
+
+	/* initialize md content */
+	md.start     = &pbuf->pb_info;
+	md.length    = LNET_PING_INFO_SIZE(nnis);
+	md.threshold = LNET_MD_THRESH_INF;
+	md.max_size  = 0;
+	md.options   = LNET_MD_OP_PUT | LNET_MD_TRUNCATE |
+		       LNET_MD_MANAGE_REMOTE;
+	md.user_ptr  = pbuf;
+	md.eq_handle = the_lnet.ln_push_target_eq;
+
+	rc = LNetMDAttach(meh, md, LNET_RETAIN, &mdh);
+	if (rc) {
+		CERROR("Can't attach push MD: %d\n", rc);
+		goto fail_unlink_meh;
+	}
+	lnet_ping_buffer_addref(pbuf);
+
+	lnet_net_lock(LNET_LOCK_EX);
+	old_pbuf = the_lnet.ln_push_target;
+	old_mdh = the_lnet.ln_push_target_md;
+	the_lnet.ln_push_target = pbuf;
+	the_lnet.ln_push_target_md = mdh;
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	if (old_pbuf) {
+		LNetMDUnlink(old_mdh);
+		lnet_ping_buffer_decref(old_pbuf);
+	}
+
+	if (nnis < the_lnet.ln_push_target_nnis)
+		goto again;
+
+	CDEBUG(D_NET, "nnis %d success\n", nnis);
+
+	return 0;
+
+fail_unlink_meh:
+	LNetMEUnlink(meh);
+fail_decref_pbuf:
+	lnet_ping_buffer_decref(pbuf);
+fail_return:
+	CDEBUG(D_NET, "nnis %d error %d\n", nnis, rc);
+	return rc;
+}
+
+static void lnet_push_target_event_handler(struct lnet_event *ev)
+{
+	struct lnet_ping_buffer *pbuf = ev->md.user_ptr;
+
+	if (pbuf->pb_info.pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
+		lnet_swap_pinginfo(pbuf);
+
+	if (ev->unlinked)
+		lnet_ping_buffer_decref(pbuf);
+}
+
+/* Initialize the push target. */
+static int lnet_push_target_init(void)
+{
+	int rc;
+
+	if (the_lnet.ln_push_target)
+		return -EALREADY;
+
+	rc = LNetEQAlloc(0, lnet_push_target_event_handler,
+			 &the_lnet.ln_push_target_eq);
+	if (rc) {
+		CERROR("Can't allocated push target EQ: %d\n", rc);
+		return rc;
+	}
+
+	/* Start at the required minimum, we'll enlarge if required. */
+	the_lnet.ln_push_target_nnis = LNET_INTERFACES_MIN;
+
+	rc = lnet_push_target_resize();
+
+	if (rc) {
+		LNetEQFree(the_lnet.ln_push_target_eq);
+		LNetInvalidateEQHandle(&the_lnet.ln_push_target_eq);
+	}
+
+	return rc;
+}
+
+/* Clean up the push target. */
+static void lnet_push_target_fini(void)
+{
+	if (!the_lnet.ln_push_target)
+		return;
+
+	/* Unlink and invalidate to prevent new references. */
+	LNetMDUnlink(the_lnet.ln_push_target_md);
+	LNetInvalidateMDHandle(&the_lnet.ln_push_target_md);
+
+	/* Wait for the unlink to complete. */
+	while (lnet_ping_buffer_numref(the_lnet.ln_push_target) > 1) {
+		CDEBUG(D_NET, "Still waiting for ping data MD to unlink\n");
+		schedule_timeout_uninterruptible(HZ);
+	}
+
+	lnet_ping_buffer_decref(the_lnet.ln_push_target);
+	the_lnet.ln_push_target = NULL;
+	the_lnet.ln_push_target_nnis = 0;
+
+	LNetEQFree(the_lnet.ln_push_target_eq);
+	LNetInvalidateEQHandle(&the_lnet.ln_push_target_eq);
+}
+
 static int
 lnet_ni_tq_credits(struct lnet_ni *ni)
 {
@@ -1945,10 +2086,14 @@ LNetNIInit(lnet_pid_t requested_pid)
 	if (rc)
 		goto err_stop_ping;
 
-	rc = lnet_peer_discovery_start();
+	rc = lnet_push_target_init();
 	if (rc != 0)
 		goto err_stop_router_checker;
 
+	rc = lnet_peer_discovery_start();
+	if (rc != 0)
+		goto err_destroy_push_target;
+
 	lnet_fault_init();
 	lnet_router_debugfs_init();
 
@@ -1956,6 +2101,8 @@ LNetNIInit(lnet_pid_t requested_pid)
 
 	return 0;
 
+err_destroy_push_target:
+	lnet_push_target_fini();
 err_stop_router_checker:
 	lnet_router_checker_stop();
 err_stop_ping:
@@ -2007,6 +2154,7 @@ LNetNIFini(void)
 		lnet_fault_fini();
 		lnet_router_debugfs_fini();
 		lnet_peer_discovery_stop();
+		lnet_push_target_fini();
 		lnet_router_checker_stop();
 		lnet_ping_target_fini();
 
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 038b58414ce0..b78f99c354de 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -1681,6 +1681,8 @@ static int lnet_peer_discovery_wait_for_work(void)
 				TASK_IDLE);
 		if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
 			break;
+		if (lnet_push_target_resize_needed())
+			break;
 		if (!list_empty(&the_lnet.ln_dc_request))
 			break;
 		lnet_net_unlock(cpt);
@@ -1711,6 +1713,9 @@ static int lnet_peer_discovery(void *arg)
 		if (lnet_peer_discovery_wait_for_work())
 			break;
 
+		if (lnet_push_target_resize_needed())
+			lnet_push_target_resize();
+
 		lnet_net_lock(LNET_LOCK_EX);
 		if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
 			break;
