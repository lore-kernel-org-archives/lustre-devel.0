From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:37 +1100
Subject: [lustre-devel] [PATCH 03/24] lustre: lnet: add struct
 lnet_ping_buffer
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437765.16383.7644707942018591818.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

The Multi-Rail code will use the ping target buffer also as the
source of data to push to other nodes. This means that there
will be multiple MDs referencing the same buffer, and care must
be taken to ensure that the buffer is not freed while any such
reference remains.

Encapsulate the struct lnet_ping_info (aka lnet_ping_info_t) in
a struct lnet_ping_buffer. This adds a reference count, and the
number of NIDs for the encapsulated lnet_ping_info has been
sized.

For sizing the buffer the constant LNET_PINGINFO_SIZE is replaced
with LNET_PING_INFO_SIZE(NNIS).

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25773
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   22 +
 .../staging/lustre/include/linux/lnet/lib-types.h  |   40 ++
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  345 +++++++++++---------
 drivers/staging/lustre/lnet/lnet/router.c          |   94 +++--
 4 files changed, 301 insertions(+), 200 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 16e64d83840d..2e2b5ed27116 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -634,7 +634,27 @@ int lnet_peer_buffer_credits(struct lnet_net *net);
 int lnet_router_checker_start(void);
 void lnet_router_checker_stop(void);
 void lnet_router_ni_update_locked(struct lnet_peer_ni *gw, __u32 net);
-void lnet_swap_pinginfo(struct lnet_ping_info *info);
+void lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf);
+
+int lnet_ping_info_validate(struct lnet_ping_info *pinfo);
+struct lnet_ping_buffer *lnet_ping_buffer_alloc(int nnis, gfp_t gfp);
+void lnet_ping_buffer_free(struct lnet_ping_buffer *pbuf);
+
+static inline void lnet_ping_buffer_addref(struct lnet_ping_buffer *pbuf)
+{
+	atomic_inc(&pbuf->pb_refcnt);
+}
+
+static inline void lnet_ping_buffer_decref(struct lnet_ping_buffer *pbuf)
+{
+	if (atomic_dec_and_test(&pbuf->pb_refcnt))
+		lnet_ping_buffer_free(pbuf);
+}
+
+static inline int lnet_ping_buffer_numref(struct lnet_ping_buffer *pbuf)
+{
+	return atomic_read(&pbuf->pb_refcnt);
+}
 
 int lnet_parse_ip2nets(char **networksp, char *ip2nets);
 int lnet_parse_routes(char *route_str, int *im_a_router);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 7b11c31f0029..ab8c6d66cdbf 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -387,12 +387,32 @@ struct lnet_ni {
 #define LNET_PING_FEAT_NI_STATUS	BIT(1)	/* return NI status */
 #define LNET_PING_FEAT_RTE_DISABLED	BIT(2)	/* Routing enabled */
 
-#define LNET_PING_FEAT_MASK		(LNET_PING_FEAT_BASE | \
-					 LNET_PING_FEAT_NI_STATUS)
+#define LNET_PING_INFO_SIZE(NNIDS) \
+	offsetof(struct lnet_ping_info, pi_ni[NNIDS])
+#define LNET_PING_INFO_LONI(PINFO)	((PINFO)->pi_ni[0].ns_nid)
+#define LNET_PING_INFO_SEQNO(PINFO)	((PINFO)->pi_ni[0].ns_status)
+
+/*
+ * Descriptor of a ping info buffer: keep a separate indicator of the
+ * size and a reference count. The type is used both as a source and
+ * sink of data, so we need to keep some information outside of the
+ * area that may be overwritten by network data.
+ */
+struct lnet_ping_buffer {
+	int			pb_nnis;
+	atomic_t		pb_refcnt;
+	struct lnet_ping_info	pb_info;
+};
+
+#define LNET_PING_BUFFER_SIZE(NNIDS) \
+	offsetof(struct lnet_ping_buffer, pb_info.pi_ni[NNIDS])
+#define LNET_PING_BUFFER_LONI(PBUF)	((PBUF)->pb_info.pi_ni[0].ns_nid)
+#define LNET_PING_BUFFER_SEQNO(PBUF)	((PBUF)->pb_info.pi_ni[0].ns_status)
+
 
 /* router checker data, per router */
-#define LNET_MAX_RTR_NIS   16
-#define LNET_PINGINFO_SIZE offsetof(struct lnet_ping_info, pi_ni[LNET_MAX_RTR_NIS])
+#define LNET_MAX_RTR_NIS   LNET_INTERFACES_MIN
+#define LNET_RTR_PINGINFO_SIZE	LNET_PING_INFO_SIZE(LNET_MAX_RTR_NIS)
 struct lnet_rc_data {
 	/* chain on the_lnet.ln_zombie_rcd or ln_deathrow_rcd */
 	struct list_head	rcd_list;
@@ -401,7 +421,7 @@ struct lnet_rc_data {
 	/* reference to gateway */
 	struct lnet_peer_ni	*rcd_gateway;
 	/* ping buffer */
-	struct lnet_ping_info	*rcd_pinginfo;
+	struct lnet_ping_buffer	*rcd_pingbuffer;
 };
 
 struct lnet_peer_ni {
@@ -792,9 +812,17 @@ struct lnet {
 	/* percpt router buffer pools */
 	struct lnet_rtrbufpool		**ln_rtrpools;
 
+	/*
+	 * Ping target / Push source
+	 *
+	 * The ping target and push source share a single buffer. The
+	 * ln_ping_target is protected against concurrent updates by
+	 * ln_api_mutex.
+	 */
 	struct lnet_handle_md		  ln_ping_target_md;
 	struct lnet_handle_eq		  ln_ping_target_eq;
-	struct lnet_ping_info		 *ln_ping_info;
+	struct lnet_ping_buffer		 *ln_ping_target;
+	atomic_t			ln_ping_target_seqno;
 
 	/* router checker startup/shutdown state */
 	enum lnet_rc_state		  ln_rc_state;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 8b6400da2836..ca28ad75fe2b 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -902,25 +902,44 @@ lnet_count_acceptor_nets(void)
 	return count;
 }
 
-static struct lnet_ping_info *
-lnet_ping_info_create(int num_ni)
+struct lnet_ping_buffer *
+lnet_ping_buffer_alloc(int nnis, gfp_t gfp)
 {
-	struct lnet_ping_info *ping_info;
-	unsigned int infosz;
+	struct lnet_ping_buffer *pbuf;
 
-	infosz = offsetof(struct lnet_ping_info, pi_ni[num_ni]);
-	ping_info = kvzalloc(infosz, GFP_KERNEL);
-	if (!ping_info) {
-		CERROR("Can't allocate ping info[%d]\n", num_ni);
+	pbuf = kmalloc(LNET_PING_BUFFER_SIZE(nnis), gfp);
+	if (pbuf) {
+		pbuf->pb_nnis = nnis;
+		atomic_set(&pbuf->pb_refcnt, 1);
+	}
+
+	return pbuf;
+}
+
+void
+lnet_ping_buffer_free(struct lnet_ping_buffer *pbuf)
+{
+	LASSERT(lnet_ping_buffer_numref(pbuf) == 0);
+	kfree(pbuf);
+}
+
+static struct lnet_ping_buffer *
+lnet_ping_target_create(int nnis)
+{
+	struct lnet_ping_buffer *pbuf;
+
+	pbuf = lnet_ping_buffer_alloc(nnis, GFP_KERNEL);
+	if (!pbuf) {
+		CERROR("Can't allocate ping source [%d]\n", nnis);
 		return NULL;
 	}
 
-	ping_info->pi_nnis = num_ni;
-	ping_info->pi_pid = the_lnet.ln_pid;
-	ping_info->pi_magic = LNET_PROTO_PING_MAGIC;
-	ping_info->pi_features = LNET_PING_FEAT_NI_STATUS;
+	pbuf->pb_info.pi_nnis = nnis;
+	pbuf->pb_info.pi_pid = the_lnet.ln_pid;
+	pbuf->pb_info.pi_magic = LNET_PROTO_PING_MAGIC;
+	pbuf->pb_info.pi_features = LNET_PING_FEAT_NI_STATUS;
 
-	return ping_info;
+	return pbuf;
 }
 
 static inline int
@@ -966,14 +985,25 @@ lnet_get_ni_count(void)
 	return count;
 }
 
-static inline void
-lnet_ping_info_free(struct lnet_ping_info *pinfo)
+int
+lnet_ping_info_validate(struct lnet_ping_info *pinfo)
 {
-	kvfree(pinfo);
+	if (!pinfo)
+		return -EINVAL;
+	if (pinfo->pi_magic != LNET_PROTO_PING_MAGIC)
+		return -EPROTO;
+	if (!(pinfo->pi_features & LNET_PING_FEAT_NI_STATUS))
+		return -EPROTO;
+	/* Loopback is guaranteed to be present */
+	if (pinfo->pi_nnis < 1 || pinfo->pi_nnis > lnet_interfaces_max)
+		return -ERANGE;
+	if (LNET_NETTYP(LNET_NIDNET(LNET_PING_INFO_LONI(pinfo))) != LOLND)
+		return -EPROTO;
+	return 0;
 }
 
 static void
-lnet_ping_info_destroy(void)
+lnet_ping_target_destroy(void)
 {
 	struct lnet_net *net;
 	struct lnet_ni *ni;
@@ -988,25 +1018,25 @@ lnet_ping_info_destroy(void)
 		}
 	}
 
-	lnet_ping_info_free(the_lnet.ln_ping_info);
-	the_lnet.ln_ping_info = NULL;
+	lnet_ping_buffer_decref(the_lnet.ln_ping_target);
+	the_lnet.ln_ping_target = NULL;
 
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 
 static void
-lnet_ping_event_handler(struct lnet_event *event)
+lnet_ping_target_event_handler(struct lnet_event *event)
 {
-	struct lnet_ping_info *pinfo = event->md.user_ptr;
+	struct lnet_ping_buffer *pbuf = event->md.user_ptr;
 
 	if (event->unlinked)
-		pinfo->pi_features = LNET_PING_FEAT_INVAL;
+		lnet_ping_buffer_decref(pbuf);
 }
 
 static int
-lnet_ping_info_setup(struct lnet_ping_info **ppinfo,
-		     struct lnet_handle_md *md_handle,
-		     int ni_count, bool set_eq)
+lnet_ping_target_setup(struct lnet_ping_buffer **ppbuf,
+		       struct lnet_handle_md *ping_mdh,
+		       int ni_count, bool set_eq)
 {
 	struct lnet_process_id id = { .nid = LNET_NID_ANY,
 				      .pid = LNET_PID_ANY };
@@ -1015,94 +1045,98 @@ lnet_ping_info_setup(struct lnet_ping_info **ppinfo,
 	int rc, rc2;
 
 	if (set_eq) {
-		rc = LNetEQAlloc(0, lnet_ping_event_handler,
+		rc = LNetEQAlloc(0, lnet_ping_target_event_handler,
 				 &the_lnet.ln_ping_target_eq);
 		if (rc) {
-			CERROR("Can't allocate ping EQ: %d\n", rc);
+			CERROR("Can't allocate ping buffer EQ: %d\n", rc);
 			return rc;
 		}
 	}
 
-	*ppinfo = lnet_ping_info_create(ni_count);
-	if (!*ppinfo) {
+	*ppbuf = lnet_ping_target_create(ni_count);
+	if (!*ppbuf) {
 		rc = -ENOMEM;
-		goto failed_0;
+		goto fail_free_eq;
 	}
 
+	/* Ping target ME/MD */
 	rc = LNetMEAttach(LNET_RESERVED_PORTAL, id,
 			  LNET_PROTO_PING_MATCHBITS, 0,
 			  LNET_UNLINK, LNET_INS_AFTER,
 			  &me_handle);
 	if (rc) {
-		CERROR("Can't create ping ME: %d\n", rc);
-		goto failed_1;
+		CERROR("Can't create ping target ME: %d\n", rc);
+		goto fail_decref_ping_buffer;
 	}
 
 	/* initialize md content */
-	md.start = *ppinfo;
-	md.length = offsetof(struct lnet_ping_info,
-			     pi_ni[(*ppinfo)->pi_nnis]);
+	md.start = &(*ppbuf)->pb_info;
+	md.length = LNET_PING_INFO_SIZE((*ppbuf)->pb_nnis);
 	md.threshold = LNET_MD_THRESH_INF;
 	md.max_size = 0;
 	md.options = LNET_MD_OP_GET | LNET_MD_TRUNCATE |
 		     LNET_MD_MANAGE_REMOTE;
-	md.user_ptr  = NULL;
 	md.eq_handle = the_lnet.ln_ping_target_eq;
-	md.user_ptr = *ppinfo;
+	md.user_ptr = *ppbuf;
 
-	rc = LNetMDAttach(me_handle, md, LNET_RETAIN, md_handle);
+	rc = LNetMDAttach(me_handle, md, LNET_RETAIN, ping_mdh);
 	if (rc) {
-		CERROR("Can't attach ping MD: %d\n", rc);
-		goto failed_2;
+		CERROR("Can't attach ping target MD: %d\n", rc);
+		goto fail_unlink_ping_me;
 	}
+	lnet_ping_buffer_addref(*ppbuf);
 
 	return 0;
 
-failed_2:
+fail_unlink_ping_me:
 	rc2 = LNetMEUnlink(me_handle);
 	LASSERT(!rc2);
-failed_1:
-	lnet_ping_info_free(*ppinfo);
-	*ppinfo = NULL;
-failed_0:
-	if (set_eq)
-		LNetEQFree(the_lnet.ln_ping_target_eq);
+fail_decref_ping_buffer:
+	LASSERT(lnet_ping_buffer_numref(*ppbuf) == 1);
+	lnet_ping_buffer_decref(*ppbuf);
+	*ppbuf = NULL;
+fail_free_eq:
+	if (set_eq) {
+		rc2 = LNetEQFree(the_lnet.ln_ping_target_eq);
+		LASSERT(rc2 == 0);
+	}
 	return rc;
 }
 
 static void
-lnet_ping_md_unlink(struct lnet_ping_info *pinfo,
-		    struct lnet_handle_md *md_handle)
+lnet_ping_md_unlink(struct lnet_ping_buffer *pbuf,
+		    struct lnet_handle_md *ping_mdh)
 {
-	LNetMDUnlink(*md_handle);
-	LNetInvalidateMDHandle(md_handle);
+	LNetMDUnlink(*ping_mdh);
+	LNetInvalidateMDHandle(ping_mdh);
 
-	/* NB md could be busy; this just starts the unlink */
-	while (pinfo->pi_features != LNET_PING_FEAT_INVAL) {
-		CDEBUG(D_NET, "Still waiting for ping MD to unlink\n");
+	/* NB the MD could be busy; this just starts the unlink */
+	while (lnet_ping_buffer_numref(pbuf) > 1) {
+		CDEBUG(D_NET, "Still waiting for ping data MD to unlink\n");
 		schedule_timeout_idle(HZ);
 	}
 }
 
 static void
-lnet_ping_info_install_locked(struct lnet_ping_info *ping_info)
+lnet_ping_target_install_locked(struct lnet_ping_buffer *pbuf)
 {
 	struct lnet_ni_status *ns;
 	struct lnet_ni *ni;
 	struct lnet_net *net;
 	int i = 0;
+	int rc;
 
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			LASSERT(i < ping_info->pi_nnis);
+			LASSERT(i < pbuf->pb_nnis);
 
-			ns = &ping_info->pi_ni[i];
+			ns = &pbuf->pb_info.pi_ni[i];
 
 			ns->ns_nid = ni->ni_nid;
 
 			lnet_ni_lock(ni);
 			ns->ns_status = ni->ni_status ?
-					ni->ni_status->ns_status :
+					 ni->ni_status->ns_status :
 						LNET_NI_STATUS_UP;
 			ni->ni_status = ns;
 			lnet_ni_unlock(ni);
@@ -1110,35 +1144,47 @@ lnet_ping_info_install_locked(struct lnet_ping_info *ping_info)
 			i++;
 		}
 	}
+	/*
+	 * We (ab)use the ns_status of the loopback interface to
+	 * transmit the sequence number. The first interface listed
+	 * must be the loopback interface.
+	 */
+	rc = lnet_ping_info_validate(&pbuf->pb_info);
+	if (rc) {
+		LCONSOLE_EMERG("Invalid ping target: %d\n", rc);
+		LBUG();
+	}
+	LNET_PING_BUFFER_SEQNO(pbuf) =
+		atomic_inc_return(&the_lnet.ln_ping_target_seqno);
 }
 
 static void
-lnet_ping_target_update(struct lnet_ping_info *pinfo,
-			struct lnet_handle_md md_handle)
+lnet_ping_target_update(struct lnet_ping_buffer *pbuf,
+			struct lnet_handle_md ping_mdh)
 {
-	struct lnet_ping_info *old_pinfo = NULL;
-	struct lnet_handle_md old_md;
+	struct lnet_ping_buffer *old_pbuf = NULL;
+	struct lnet_handle_md old_ping_md;
 
 	/* switch the NIs to point to the new ping info created */
 	lnet_net_lock(LNET_LOCK_EX);
 
 	if (!the_lnet.ln_routing)
-		pinfo->pi_features |= LNET_PING_FEAT_RTE_DISABLED;
-	lnet_ping_info_install_locked(pinfo);
+		pbuf->pb_info.pi_features |= LNET_PING_FEAT_RTE_DISABLED;
+	lnet_ping_target_install_locked(pbuf);
 
-	if (the_lnet.ln_ping_info) {
-		old_pinfo = the_lnet.ln_ping_info;
-		old_md = the_lnet.ln_ping_target_md;
+	if (the_lnet.ln_ping_target) {
+		old_pbuf = the_lnet.ln_ping_target;
+		old_ping_md = the_lnet.ln_ping_target_md;
 	}
-	the_lnet.ln_ping_target_md = md_handle;
-	the_lnet.ln_ping_info = pinfo;
+	the_lnet.ln_ping_target_md = ping_mdh;
+	the_lnet.ln_ping_target = pbuf;
 
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	if (old_pinfo) {
-		/* unlink the old ping info */
-		lnet_ping_md_unlink(old_pinfo, &old_md);
-		lnet_ping_info_free(old_pinfo);
+	if (old_pbuf) {
+		/* unlink and free the old ping info */
+		lnet_ping_md_unlink(old_pbuf, &old_ping_md);
+		lnet_ping_buffer_decref(old_pbuf);
 	}
 }
 
@@ -1147,13 +1193,13 @@ lnet_ping_target_fini(void)
 {
 	int rc;
 
-	lnet_ping_md_unlink(the_lnet.ln_ping_info,
+	lnet_ping_md_unlink(the_lnet.ln_ping_target,
 			    &the_lnet.ln_ping_target_md);
 
 	rc = LNetEQFree(the_lnet.ln_ping_target_eq);
 	LASSERT(!rc);
 
-	lnet_ping_info_destroy();
+	lnet_ping_target_destroy();
 }
 
 static int
@@ -1745,8 +1791,8 @@ LNetNIInit(lnet_pid_t requested_pid)
 	int im_a_router = 0;
 	int rc;
 	int ni_count;
-	struct lnet_ping_info *pinfo;
-	struct lnet_handle_md md_handle;
+	struct lnet_ping_buffer *pbuf;
+	struct lnet_handle_md ping_mdh;
 	struct list_head net_head;
 	struct lnet_net *net;
 
@@ -1823,11 +1869,11 @@ LNetNIInit(lnet_pid_t requested_pid)
 	the_lnet.ln_refcount = 1;
 	/* Now I may use my own API functions... */
 
-	rc = lnet_ping_info_setup(&pinfo, &md_handle, ni_count, true);
+	rc = lnet_ping_target_setup(&pbuf, &ping_mdh, ni_count, true);
 	if (rc)
 		goto err_acceptor_stop;
 
-	lnet_ping_target_update(pinfo, md_handle);
+	lnet_ping_target_update(pbuf, ping_mdh);
 
 	rc = lnet_router_checker_start();
 	if (rc)
@@ -1936,7 +1982,10 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_ni *cfg_ni,
 	}
 
 	cfg_ni->lic_nid = ni->ni_nid;
-	cfg_ni->lic_status = ni->ni_status->ns_status;
+	if (LNET_NETTYP(LNET_NIDNET(ni->ni_nid)) == LOLND)
+		cfg_ni->lic_status = LNET_NI_STATUS_UP;
+	else
+		cfg_ni->lic_status = ni->ni_status->ns_status;
 	cfg_ni->lic_tcp_bonding = use_tcp_bonding;
 	cfg_ni->lic_dev_cpt = ni->ni_dev_cpt;
 
@@ -2021,7 +2070,10 @@ lnet_fill_ni_info_legacy(struct lnet_ni *ni,
 	config->cfg_config_u.cfg_net.net_peer_rtr_credits =
 		ni->ni_net->net_tunables.lct_peer_rtr_credits;
 
-	net_config->ni_status = ni->ni_status->ns_status;
+	if (LNET_NETTYP(LNET_NIDNET(ni->ni_nid)) == LOLND)
+		net_config->ni_status = LNET_NI_STATUS_UP;
+	else
+		net_config->ni_status = ni->ni_status->ns_status;
 
 	if (ni->ni_cpts) {
 		int num_cpts = min(ni->ni_ncpts, LNET_MAX_SHOW_NUM_CPT);
@@ -2172,8 +2224,8 @@ static int lnet_add_net_common(struct lnet_net *net,
 			       struct lnet_ioctl_config_lnd_tunables *tun)
 {
 	u32 net_id;
-	struct lnet_ping_info *pinfo;
-	struct lnet_handle_md md_handle;
+	struct lnet_ping_buffer *pbuf;
+	struct lnet_handle_md ping_mdh;
 	int rc;
 	struct lnet_remotenet *rnet;
 	int net_ni_count;
@@ -2195,7 +2247,7 @@ static int lnet_add_net_common(struct lnet_net *net,
 
 	/*
 	 * make sure you calculate the correct number of slots in the ping
-	 * info. Since the ping info is a flattened list of all the NIs,
+	 * buffer. Since the ping info is a flattened list of all the NIs,
 	 * we should allocate enough slots to accomodate the number of NIs
 	 * which will be added.
 	 *
@@ -2204,9 +2256,9 @@ static int lnet_add_net_common(struct lnet_net *net,
 	 */
 	net_ni_count = lnet_get_net_ni_count_pre(net);
 
-	rc = lnet_ping_info_setup(&pinfo, &md_handle,
-				  net_ni_count + lnet_get_ni_count(),
-				  false);
+	rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
+				    net_ni_count + lnet_get_ni_count(),
+				    false);
 	if (rc < 0) {
 		lnet_net_free(net);
 		return rc;
@@ -2257,13 +2309,13 @@ static int lnet_add_net_common(struct lnet_net *net,
 	lnet_peer_net_added(net);
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	lnet_ping_target_update(pinfo, md_handle);
+	lnet_ping_target_update(pbuf, ping_mdh);
 
 	return 0;
 
 failed:
-	lnet_ping_md_unlink(pinfo, &md_handle);
-	lnet_ping_info_free(pinfo);
+	lnet_ping_md_unlink(pbuf, &ping_mdh);
+	lnet_ping_buffer_decref(pbuf);
 	return rc;
 }
 
@@ -2354,8 +2406,8 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 	struct lnet_net *net;
 	struct lnet_ni *ni;
 	u32 net_id = LNET_NIDNET(conf->lic_nid);
-	struct lnet_ping_info *pinfo;
-	struct lnet_handle_md md_handle;
+	struct lnet_ping_buffer *pbuf;
+	struct lnet_handle_md  ping_mdh;
 	int rc;
 	int net_count;
 	u32 addr;
@@ -2373,7 +2425,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		CERROR("net %s not found\n",
 		       libcfs_net2str(net_id));
 		rc = -ENOENT;
-		goto net_unlock;
+		goto unlock_net;
 	}
 
 	addr = LNET_NIDADDR(conf->lic_nid);
@@ -2384,20 +2436,20 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		lnet_net_unlock(0);
 
 		/* create and link a new ping info, before removing the old one */
-		rc = lnet_ping_info_setup(&pinfo, &md_handle,
-					  lnet_get_ni_count() - net_count,
-					  false);
+		rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
+					    lnet_get_ni_count() - net_count,
+					    false);
 		if (rc != 0)
-			goto out;
+			goto unlock_api_mutex;
 
 		lnet_shutdown_lndnet(net);
 
 		if (lnet_count_acceptor_nets() == 0)
 			lnet_acceptor_stop();
 
-		lnet_ping_target_update(pinfo, md_handle);
+		lnet_ping_target_update(pbuf, ping_mdh);
 
-		goto out;
+		goto unlock_api_mutex;
 	}
 
 	ni = lnet_nid2ni_locked(conf->lic_nid, 0);
@@ -2405,7 +2457,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		CERROR("nid %s not found\n",
 		       libcfs_nid2str(conf->lic_nid));
 		rc = -ENOENT;
-		goto net_unlock;
+		goto unlock_net;
 	}
 
 	net_count = lnet_get_net_ni_count_locked(net);
@@ -2413,27 +2465,27 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 	lnet_net_unlock(0);
 
 	/* create and link a new ping info, before removing the old one */
-	rc = lnet_ping_info_setup(&pinfo, &md_handle,
-				  lnet_get_ni_count() - 1, false);
+	rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
+				    lnet_get_ni_count() - 1, false);
 	if (rc != 0)
-		goto out;
+		goto unlock_api_mutex;
 
 	lnet_shutdown_lndni(ni);
 
 	if (lnet_count_acceptor_nets() == 0)
 		lnet_acceptor_stop();
 
-	lnet_ping_target_update(pinfo, md_handle);
+	lnet_ping_target_update(pbuf, ping_mdh);
 
 	/* check if the net is empty and remove it if it is */
 	if (net_count == 1)
 		lnet_shutdown_lndnet(net);
 
-	goto out;
+	goto unlock_api_mutex;
 
-net_unlock:
+unlock_net:
 	lnet_net_unlock(0);
-out:
+unlock_api_mutex:
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
 	return rc;
@@ -2501,8 +2553,8 @@ int
 lnet_dyn_del_net(__u32 net_id)
 {
 	struct lnet_net *net;
-	struct lnet_ping_info *pinfo;
-	struct lnet_handle_md md_handle;
+	struct lnet_ping_buffer *pbuf;
+	struct lnet_handle_md ping_mdh;
 	int rc;
 	int net_ni_count;
 
@@ -2525,8 +2577,8 @@ lnet_dyn_del_net(__u32 net_id)
 	lnet_net_unlock(0);
 
 	/* create and link a new ping info, before removing the old one */
-	rc = lnet_ping_info_setup(&pinfo, &md_handle,
-				  lnet_get_ni_count() - net_ni_count, false);
+	rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
+				    lnet_get_ni_count() - net_ni_count, false);
 	if (rc)
 		goto out;
 
@@ -2535,7 +2587,7 @@ lnet_dyn_del_net(__u32 net_id)
 	if (!lnet_count_acceptor_nets())
 		lnet_acceptor_stop();
 
-	lnet_ping_target_update(pinfo, md_handle);
+	lnet_ping_target_update(pbuf, ping_mdh);
 
 out:
 	mutex_unlock(&the_lnet.ln_api_mutex);
@@ -2943,16 +2995,13 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	int unlinked = 0;
 	int replied = 0;
 	const signed long a_long_time = 60*HZ;
-	int infosz;
-	struct lnet_ping_info *info;
+	struct lnet_ping_buffer *pbuf;
 	struct lnet_process_id tmpid;
 	int i;
 	int nob;
 	int rc;
 	int rc2;
 
-	infosz = offsetof(struct lnet_ping_info, pi_ni[n_ids]);
-
 	/* n_ids limit is arbitrary */
 	if (n_ids <= 0 || n_ids > lnet_interfaces_max || id.nid == LNET_NID_ANY)
 		return -EINVAL;
@@ -2960,20 +3009,20 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	if (id.pid == LNET_PID_ANY)
 		id.pid = LNET_PID_LUSTRE;
 
-	info = kzalloc(infosz, GFP_KERNEL);
-	if (!info)
+	pbuf = lnet_ping_buffer_alloc(n_ids, GFP_NOFS);
+	if (!pbuf)
 		return -ENOMEM;
 
 	/* NB 2 events max (including any unlink event) */
 	rc = LNetEQAlloc(2, LNET_EQ_HANDLER_NONE, &eqh);
 	if (rc) {
 		CERROR("Can't allocate EQ: %d\n", rc);
-		goto out_0;
+		goto fail_ping_buffer_decref;
 	}
 
 	/* initialize md content */
-	md.start     = info;
-	md.length    = infosz;
+	md.start     = &pbuf->pb_info;
+	md.length    = LNET_PING_INFO_SIZE(n_ids);
 	md.threshold = 2; /*GET/REPLY*/
 	md.max_size  = 0;
 	md.options   = LNET_MD_TRUNCATE;
@@ -2983,7 +3032,7 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	rc = LNetMDBind(md, LNET_UNLINK, &mdh);
 	if (rc) {
 		CERROR("Can't bind MD: %d\n", rc);
-		goto out_1;
+		goto fail_free_eq;
 	}
 
 	rc = LNetGet(LNET_NID_ANY, mdh, id,
@@ -3044,11 +3093,11 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 			CWARN("%s: Unexpected rc >= 0 but no reply!\n",
 			      libcfs_id2str(id));
 		rc = -EIO;
-		goto out_1;
+		goto fail_free_eq;
 	}
 
 	nob = rc;
-	LASSERT(nob >= 0 && nob <= infosz);
+	LASSERT(nob >= 0 && nob <= LNET_PING_INFO_SIZE(n_ids));
 
 	rc = -EPROTO;			   /* if I can't parse... */
 
@@ -3056,56 +3105,56 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 		/* can't check magic/version */
 		CERROR("%s: ping info too short %d\n",
 		       libcfs_id2str(id), nob);
-		goto out_1;
+		goto fail_free_eq;
 	}
 
-	if (info->pi_magic == __swab32(LNET_PROTO_PING_MAGIC)) {
-		lnet_swap_pinginfo(info);
-	} else if (info->pi_magic != LNET_PROTO_PING_MAGIC) {
+	if (pbuf->pb_info.pi_magic == __swab32(LNET_PROTO_PING_MAGIC)) {
+		lnet_swap_pinginfo(pbuf);
+	} else if (pbuf->pb_info.pi_magic != LNET_PROTO_PING_MAGIC) {
 		CERROR("%s: Unexpected magic %08x\n",
-		       libcfs_id2str(id), info->pi_magic);
-		goto out_1;
+		       libcfs_id2str(id), pbuf->pb_info.pi_magic);
+		goto fail_free_eq;
 	}
 
-	if (!(info->pi_features & LNET_PING_FEAT_NI_STATUS)) {
+	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_NI_STATUS)) {
 		CERROR("%s: ping w/o NI status: 0x%x\n",
-		       libcfs_id2str(id), info->pi_features);
-		goto out_1;
+		       libcfs_id2str(id), pbuf->pb_info.pi_features);
+		goto fail_free_eq;
 	}
 
-	if (nob < offsetof(struct lnet_ping_info, pi_ni[0])) {
+	if (nob < LNET_PING_INFO_SIZE(0)) {
 		CERROR("%s: Short reply %d(%d min)\n", libcfs_id2str(id),
-		       nob, (int)offsetof(struct lnet_ping_info, pi_ni[0]));
-		goto out_1;
+		       nob, (int)LNET_PING_INFO_SIZE(0));
+		goto fail_free_eq;
 	}
 
-	if (info->pi_nnis < n_ids)
-		n_ids = info->pi_nnis;
+	if (pbuf->pb_info.pi_nnis < n_ids)
+		n_ids = pbuf->pb_info.pi_nnis;
 
-	if (nob < offsetof(struct lnet_ping_info, pi_ni[n_ids])) {
+	if (nob < LNET_PING_INFO_SIZE(n_ids)) {
 		CERROR("%s: Short reply %d(%d expected)\n", libcfs_id2str(id),
-		       nob, (int)offsetof(struct lnet_ping_info, pi_ni[n_ids]));
-		goto out_1;
+		       nob, (int)LNET_PING_INFO_SIZE(n_ids));
+		goto fail_free_eq;
 	}
 
 	rc = -EFAULT;			   /* If I SEGV... */
 
 	memset(&tmpid, 0, sizeof(tmpid));
 	for (i = 0; i < n_ids; i++) {
-		tmpid.pid = info->pi_pid;
-		tmpid.nid = info->pi_ni[i].ns_nid;
+		tmpid.pid = pbuf->pb_info.pi_pid;
+		tmpid.nid = pbuf->pb_info.pi_ni[i].ns_nid;
 		if (copy_to_user(&ids[i], &tmpid, sizeof(tmpid)))
-			goto out_1;
+			goto fail_free_eq;
 	}
-	rc = info->pi_nnis;
+	rc = pbuf->pb_info.pi_nnis;
 
- out_1:
+ fail_free_eq:
 	rc2 = LNetEQFree(eqh);
 	if (rc2)
 		CERROR("rc2 %d\n", rc2);
 	LASSERT(!rc2);
 
- out_0:
-	kfree(info);
+ fail_ping_buffer_decref:
+	lnet_ping_buffer_decref(pbuf);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index b31a383fe974..e97957ce9252 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -618,17 +618,21 @@ lnet_get_route(int idx, __u32 *net, __u32 *hops,
 }
 
 void
-lnet_swap_pinginfo(struct lnet_ping_info *info)
+lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf)
 {
-	int i;
 	struct lnet_ni_status *stat;
+	int nnis;
+	int i;
 
-	__swab32s(&info->pi_magic);
-	__swab32s(&info->pi_features);
-	__swab32s(&info->pi_pid);
-	__swab32s(&info->pi_nnis);
-	for (i = 0; i < info->pi_nnis && i < LNET_MAX_RTR_NIS; i++) {
-		stat = &info->pi_ni[i];
+	__swab32s(&pbuf->pb_info.pi_magic);
+	__swab32s(&pbuf->pb_info.pi_features);
+	__swab32s(&pbuf->pb_info.pi_pid);
+	__swab32s(&pbuf->pb_info.pi_nnis);
+	nnis = pbuf->pb_info.pi_nnis;
+	if (nnis > pbuf->pb_nnis)
+		nnis = pbuf->pb_nnis;
+	for (i = 0; i < nnis; i++) {
+		stat = &pbuf->pb_info.pi_ni[i];
 		__swab64s(&stat->ns_nid);
 		__swab32s(&stat->ns_status);
 	}
@@ -641,11 +645,12 @@ lnet_swap_pinginfo(struct lnet_ping_info *info)
 static void
 lnet_parse_rc_info(struct lnet_rc_data *rcd)
 {
-	struct lnet_ping_info *info = rcd->rcd_pinginfo;
+	struct lnet_ping_buffer *pbuf = rcd->rcd_pingbuffer;
 	struct lnet_peer_ni *gw = rcd->rcd_gateway;
 	struct lnet_route *rte;
+	int			nnis;
 
-	if (!gw->lpni_alive)
+	if (!gw->lpni_alive || !pbuf)
 		return;
 
 	/*
@@ -654,51 +659,48 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 	 */
 	spin_lock(&gw->lpni_lock);
 
-	if (info->pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
-		lnet_swap_pinginfo(info);
+	if (pbuf->pb_info.pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
+		lnet_swap_pinginfo(pbuf);
 
 	/* NB always racing with network! */
-	if (info->pi_magic != LNET_PROTO_PING_MAGIC) {
+	if (pbuf->pb_info.pi_magic != LNET_PROTO_PING_MAGIC) {
 		CDEBUG(D_NET, "%s: Unexpected magic %08x\n",
-		       libcfs_nid2str(gw->lpni_nid), info->pi_magic);
+		       libcfs_nid2str(gw->lpni_nid), pbuf->pb_info.pi_magic);
 		gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-		spin_unlock(&gw->lpni_lock);
-		return;
+		goto out;
 	}
 
-	gw->lpni_ping_feats = info->pi_features;
-	if (!(gw->lpni_ping_feats & LNET_PING_FEAT_MASK)) {
-		CDEBUG(D_NET, "%s: Unexpected features 0x%x\n",
-		       libcfs_nid2str(gw->lpni_nid), gw->lpni_ping_feats);
-		spin_unlock(&gw->lpni_lock);
-		return; /* nothing I can understand */
-	}
+	gw->lpni_ping_feats = pbuf->pb_info.pi_features;
 
-	if (!(gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS)) {
-		spin_unlock(&gw->lpni_lock);
-		return; /* can't carry NI status info */
-	}
+	/* Without NI status info there's nothing more to do. */
+	if (!(gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS))
+		goto out;
+
+	/* Determine the number of NIs for which there is data. */
+	nnis = pbuf->pb_info.pi_nnis;
+	if (pbuf->pb_nnis < nnis)
+		nnis = pbuf->pb_nnis;
 
 	list_for_each_entry(rte, &gw->lpni_routes, lr_gwlist) {
 		int down = 0;
 		int up = 0;
 		int i;
 
+		/* If routing disabled then the route is down. */
 		if (gw->lpni_ping_feats & LNET_PING_FEAT_RTE_DISABLED) {
 			rte->lr_downis = 1;
 			continue;
 		}
 
-		for (i = 0; i < info->pi_nnis && i < LNET_MAX_RTR_NIS; i++) {
-			struct lnet_ni_status *stat = &info->pi_ni[i];
+		for (i = 0; i < nnis; i++) {
+			struct lnet_ni_status *stat = &pbuf->pb_info.pi_ni[i];
 			lnet_nid_t nid = stat->ns_nid;
 
 			if (nid == LNET_NID_ANY) {
 				CDEBUG(D_NET, "%s: unexpected LNET_NID_ANY\n",
 				       libcfs_nid2str(gw->lpni_nid));
 				gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-				spin_unlock(&gw->lpni_lock);
-				return;
+				goto out;
 			}
 
 			if (LNET_NETTYP(LNET_NIDNET(nid)) == LOLND)
@@ -720,8 +722,7 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 			CDEBUG(D_NET, "%s: Unexpected status 0x%x\n",
 			       libcfs_nid2str(gw->lpni_nid), stat->ns_status);
 			gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-			spin_unlock(&gw->lpni_lock);
-			return;
+			goto out;
 		}
 
 		if (up) { /* ignore downed NIs if NI for dest network is up */
@@ -737,7 +738,7 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 
 		rte->lr_downis = down;
 	}
-
+out:
 	spin_unlock(&gw->lpni_lock);
 }
 
@@ -903,7 +904,8 @@ lnet_destroy_rc_data(struct lnet_rc_data *rcd)
 		lnet_net_unlock(cpt);
 	}
 
-	kfree(rcd->rcd_pinginfo);
+	if (rcd->rcd_pingbuffer)
+		lnet_ping_buffer_decref(rcd->rcd_pingbuffer);
 
 	kfree(rcd);
 }
@@ -912,7 +914,7 @@ static struct lnet_rc_data *
 lnet_create_rc_data_locked(struct lnet_peer_ni *gateway)
 {
 	struct lnet_rc_data *rcd = NULL;
-	struct lnet_ping_info *pi;
+	struct lnet_ping_buffer *pbuf;
 	struct lnet_md md;
 	int rc;
 	int i;
@@ -926,19 +928,19 @@ lnet_create_rc_data_locked(struct lnet_peer_ni *gateway)
 	LNetInvalidateMDHandle(&rcd->rcd_mdh);
 	INIT_LIST_HEAD(&rcd->rcd_list);
 
-	pi = kzalloc(LNET_PINGINFO_SIZE, GFP_NOFS);
-	if (!pi)
+	pbuf = lnet_ping_buffer_alloc(LNET_MAX_RTR_NIS, GFP_NOFS);
+	if (!pbuf)
 		goto out;
 
 	for (i = 0; i < LNET_MAX_RTR_NIS; i++) {
-		pi->pi_ni[i].ns_nid = LNET_NID_ANY;
-		pi->pi_ni[i].ns_status = LNET_NI_STATUS_INVALID;
+		pbuf->pb_info.pi_ni[i].ns_nid = LNET_NID_ANY;
+		pbuf->pb_info.pi_ni[i].ns_status = LNET_NI_STATUS_INVALID;
 	}
-	rcd->rcd_pinginfo = pi;
+	rcd->rcd_pingbuffer = pbuf;
 
-	md.start = pi;
+	md.start = &pbuf->pb_info;
 	md.user_ptr = rcd;
-	md.length = LNET_PINGINFO_SIZE;
+	md.length = LNET_RTR_PINGINFO_SIZE;
 	md.threshold = LNET_MD_THRESH_INF;
 	md.options = LNET_MD_TRUNCATE;
 	md.eq_handle = the_lnet.ln_rc_eqh;
@@ -1714,7 +1716,8 @@ lnet_rtrpools_enable(void)
 	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_routing = 1;
 
-	the_lnet.ln_ping_info->pi_features &= ~LNET_PING_FEAT_RTE_DISABLED;
+	the_lnet.ln_ping_target->pb_info.pi_features &=
+		~LNET_PING_FEAT_RTE_DISABLED;
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	return rc;
@@ -1728,7 +1731,8 @@ lnet_rtrpools_disable(void)
 
 	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_routing = 0;
-	the_lnet.ln_ping_info->pi_features |= LNET_PING_FEAT_RTE_DISABLED;
+	the_lnet.ln_ping_target->pb_info.pi_features |=
+		LNET_PING_FEAT_RTE_DISABLED;
 
 	tiny_router_buffers = 0;
 	small_router_buffers = 0;
