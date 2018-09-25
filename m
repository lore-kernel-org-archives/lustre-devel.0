From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 11/34] LU-7734 lnet: configure local NI from
 DLC
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763527.32103.6166409833321456335.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This patch adds the ability to configure multiple network interfaces
on the same network. This can be done via the lnetctl CLI interface
or through a YAML configuration. Refer to the multi-rail HLD for
more details on the syntax.

It also deprecates ip2nets kernel parsing. All string parsing and
network maching now happens in the DLC userspace library.

New IOCTLs are added for adding/deleting local NIs, to keep backwards
compatibility with older version of the DLC and lnetctl.

The changes also include parsing and matching ip2nets syntax at the
user level and then passing down the network interfaces down to the
kernel to be configured.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: I19ee7dc76514beb6f34de6517d19654d6468bcec
Reviewed-on: http://review.whamcloud.com/18886
Tested-by: Maloo <hpdd-maloo@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_string.h    |   12 -
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   13 -
 .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |    6 
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |   57 ++
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    3 
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  479 +++++++++++++++++---
 drivers/staging/lustre/lnet/lnet/config.c          |  107 +++-
 drivers/staging/lustre/lnet/lnet/module.c          |   70 ++-
 drivers/staging/lustre/lnet/lnet/peer.c            |   21 +
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    2 
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    4 
 11 files changed, 650 insertions(+), 124 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index cd7c3ccb2dc0..3117708b9ebb 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -83,20 +83,10 @@ int cfs_expr_list_print(char *buffer, int count,
 			struct cfs_expr_list *expr_list);
 int cfs_expr_list_values(struct cfs_expr_list *expr_list,
 			 int max, u32 **values);
-static inline void
-cfs_expr_list_values_free(u32 *values, int num)
-{
-	/*
-	 * This array is allocated by kvalloc(), so it shouldn't be freed
-	 * by OBD_FREE() if it's called by module other than libcfs & LNet,
-	 * otherwise we will see fake memory leak
-	 */
-	kvfree(values);
-}
-
 void cfs_expr_list_free(struct cfs_expr_list *expr_list);
 int cfs_expr_list_parse(char *str, int len, unsigned int min, unsigned int max,
 			struct cfs_expr_list **elpp);
+void cfs_expr_list_free(struct cfs_expr_list *expr_list);
 void cfs_expr_list_free_list(struct list_head *list);
 
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 11642f8aee90..a7cff6426ad8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -377,6 +377,9 @@ lnet_net_alloc(__u32 net_type, struct list_head *netlist);
 struct lnet_ni *
 lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el,
 	      char *iface);
+struct lnet_ni *
+lnet_ni_alloc_w_cpt_array(struct lnet_net *net, __u32 *cpts, __u32 ncpts,
+			  char *iface);
 
 static inline int
 lnet_nid2peerhash(lnet_nid_t nid)
@@ -401,7 +404,7 @@ int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
 struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
 struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
 struct lnet_ni *lnet_net2ni_locked(__u32 net, int cpt);
-struct lnet_ni *lnet_net2ni(__u32 net);
+struct lnet_ni *lnet_net2ni_addref(__u32 net);
 bool lnet_is_ni_healthy_locked(struct lnet_ni *ni);
 struct lnet_net *lnet_get_net_locked(u32 net_id);
 
@@ -435,9 +438,10 @@ int lnet_rtrpools_enable(void);
 void lnet_rtrpools_disable(void);
 void lnet_rtrpools_free(int keep_pools);
 struct lnet_remotenet *lnet_find_rnet_locked(__u32 net);
-int lnet_dyn_add_ni(lnet_pid_t requested_pid,
-		    struct lnet_ioctl_config_data *conf);
-int lnet_dyn_del_ni(__u32 net);
+int lnet_dyn_add_net(struct lnet_ioctl_config_data *conf);
+int lnet_dyn_del_net(__u32 net);
+int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf);
+int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf);
 int lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason);
 struct lnet_net *lnet_get_net_locked(__u32 net_id);
 
@@ -646,6 +650,7 @@ int lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt,
 				    struct lnet_peer **peer);
 int lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
+void lnet_peer_net_added(struct lnet_net *net);
 void lnet_peer_tables_cleanup(struct lnet_ni *ni);
 void lnet_peer_uninit(void);
 int lnet_peer_tables_create(void);
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
index d5a3e7c85aa4..fa58aaf6ad9d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -139,6 +139,10 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_ADD_PEER_NI		_IOWR(IOC_LIBCFS_TYPE, 92, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_DEL_PEER_NI		_IOWR(IOC_LIBCFS_TYPE, 93, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_PEER_NI		_IOWR(IOC_LIBCFS_TYPE, 94, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR		94
+#define IOC_LIBCFS_ADD_LOCAL_NI		_IOWR(IOC_LIBCFS_TYPE, 95, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_DEL_LOCAL_NI		_IOWR(IOC_LIBCFS_TYPE, 96, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_GET_LOCAL_NI		_IOWR(IOC_LIBCFS_TYPE, 97, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_DBG			_IOWR(IOC_LIBCFS_TYPE, 98, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR		98
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index 9c4e05e1b683..bfd9fc6bc4df 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -37,6 +37,18 @@
 #define LNET_MAX_SHOW_NUM_CPT	128
 #define LNET_UNDEFINED_HOPS	((__u32)(-1))
 
+/*
+ * To allow for future enhancements to extend the tunables
+ * add a hdr to this structure, so that the version can be set
+ * and checked for backwards compatibility. Newer versions of LNet
+ * can still work with older versions of lnetctl. The restriction is
+ * that the structure can be added to and not removed from in order
+ * to not invalidate older lnetctl utilities. Moreover, the order of
+ * fields must remain the same, and new fields appended to the structure
+ *
+ * That said all existing LND tunables will be added in this structure
+ * to avoid future changes.
+ */
 struct lnet_ioctl_config_lnd_cmn_tunables {
 	__u32 lct_version;
 	__s32 lct_peer_timeout;
@@ -82,6 +94,10 @@ struct lnet_ioctl_net_config {
 /* # different router buffer pools */
 #define LNET_NRBPOOLS		(LNET_LARGE_BUF_IDX + 1)
 
+enum lnet_dbg_task {
+	LNET_DBG_INCR_DLC_SEQ = 0
+};
+
 struct lnet_ioctl_pool_cfg {
 	struct {
 		__u32 pl_npages;
@@ -126,6 +142,29 @@ struct lnet_ioctl_config_data {
 	char cfg_bulk[0];
 };
 
+/*
+ * lnet_ioctl_config_ni
+ *  This structure describes an NI configuration. There are multiple components
+ *  when configuring an NI: Net, Interfaces, CPT list and LND tunables
+ *  A network is passed as a string to the DLC and translated using
+ *  libcfs_str2net()
+ *  An interface is the name of the system configured interface
+ *  (ex eth0, ib1)
+ *  CPT is the list of CPTS LND tunables are passed in the lic_bulk area
+ */
+struct lnet_ioctl_config_ni {
+	struct libcfs_ioctl_hdr lic_cfg_hdr;
+	lnet_nid_t		lic_nid;
+	char			lic_ni_intf[LNET_MAX_INTERFACES][LNET_MAX_STR_LEN];
+	char			lic_legacy_ip2nets[LNET_MAX_STR_LEN];
+	__u32			lic_cpts[LNET_MAX_SHOW_NUM_CPT];
+	__u32			lic_ncpts;
+	__u32			lic_status;
+	__u32			lic_tcp_bonding;
+	__u32			lic_idx;
+	char			lic_bulk[0];
+};
+
 struct lnet_peer_ni_credit_info {
 	char cr_aliveness[LNET_MAX_STR_LEN];
 	__u32 cr_refcount;
@@ -148,6 +187,24 @@ struct lnet_ioctl_peer {
 	} pr_lnd_u;
 };
 
+struct lnet_dbg_task_info {
+	/*
+	 * TODO: a union can be added if the task requires more
+	 * information from user space to be carried out in kernel space.
+	 */
+};
+
+/*
+ * This structure is intended to allow execution of debugging tasks. This
+ * is not intended to be backwards compatible. Extra tasks can be added in
+ * the future
+ */
+struct lnet_ioctl_dbg {
+	struct libcfs_ioctl_hdr dbg_hdr;
+	enum lnet_dbg_task dbg_task;
+	char dbg_bulk[0];
+};
+
 struct lnet_ioctl_peer_cfg {
 	struct libcfs_ioctl_hdr prcfg_hdr;
 	lnet_nid_t prcfg_key_nid;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 766f0d525661..9df66c6d160f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2700,7 +2700,8 @@ ksocknal_net_start_threads(struct ksock_net *net, __u32 *cpts, int ncpts)
 	int rc;
 	int i;
 
-	LASSERT(ncpts > 0 && ncpts <= cfs_cpt_number(lnet_cpt_table()));
+	if (ncpts > 0 && ncpts > cfs_cpt_number(lnet_cpt_table()))
+		return -EINVAL;
 
 	for (i = 0; i < ncpts; i++) {
 		struct ksock_sched_info *info;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 710f8a0be934..1ef9a39b517d 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -679,17 +679,19 @@ lnet_net2ni_locked(__u32 net_id, int cpt)
 }
 
 struct lnet_ni *
-lnet_net2ni(__u32 net)
+lnet_net2ni_addref(__u32 net)
 {
 	struct lnet_ni *ni;
 
 	lnet_net_lock(0);
 	ni = lnet_net2ni_locked(net, 0);
+	if (ni)
+		lnet_ni_addref_locked(ni, 0);
 	lnet_net_unlock(0);
 
 	return ni;
 }
-EXPORT_SYMBOL(lnet_net2ni);
+EXPORT_SYMBOL(lnet_net2ni_addref);
 
 struct lnet_net *
 lnet_get_net_locked(__u32 net_id)
@@ -897,6 +899,18 @@ lnet_get_net_ni_count_locked(struct lnet_net *net)
 	return count;
 }
 
+static inline int
+lnet_get_net_ni_count_pre(struct lnet_net *net)
+{
+	struct lnet_ni *ni;
+	int count = 0;
+
+	list_for_each_entry(ni, &net->net_ni_added, ni_netlist)
+		count++;
+
+	return count;
+}
+
 static inline int
 lnet_get_ni_count(void)
 {
@@ -1839,15 +1853,91 @@ LNetNIFini(void)
 }
 EXPORT_SYMBOL(LNetNIFini);
 
+static int lnet_handle_dbg_task(struct lnet_ioctl_dbg *dbg,
+				struct lnet_dbg_task_info *dbg_info)
+{
+	switch (dbg->dbg_task) {
+	case LNET_DBG_INCR_DLC_SEQ:
+		lnet_incr_dlc_seq();
+	}
+
+	return 0;
+}
+
 /**
  * Grabs the ni data from the ni structure and fills the out
  * parameters
  *
- * \param[in] ni network       interface structure
- * \param[out] config	       NI configuration
+ * \param[in] ni network	interface structure
+ * \param[out] cfg_ni		NI config information
+ * \param[out] tun		network and LND tunables
  */
 static void
-lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_data *config)
+lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_ni *cfg_ni,
+		  struct lnet_ioctl_config_lnd_tunables *tun,
+		  __u32 tun_size)
+{
+	size_t min_size = 0;
+	int i;
+
+	if (!ni || !cfg_ni || !tun)
+		return;
+
+	if (ni->ni_interfaces[0]) {
+		for (i = 0; i < ARRAY_SIZE(ni->ni_interfaces); i++) {
+			if (ni->ni_interfaces[i]) {
+				strncpy(cfg_ni->lic_ni_intf[i],
+					ni->ni_interfaces[i],
+					sizeof(cfg_ni->lic_ni_intf[i]));
+			}
+		}
+	}
+
+	cfg_ni->lic_nid = ni->ni_nid;
+	cfg_ni->lic_status = ni->ni_status->ns_status;
+	cfg_ni->lic_tcp_bonding = use_tcp_bonding;
+
+	memcpy(&tun->lt_cmn, &ni->ni_net->net_tunables, sizeof(tun->lt_cmn));
+
+	/*
+	 * tun->lt_tun will always be present, but in order to be
+	 * backwards compatible, we need to deal with the cases when
+	 * tun->lt_tun is smaller than what the kernel has, because it
+	 * comes from an older version of a userspace program, then we'll
+	 * need to copy as much information as we have available space.
+	 */
+	min_size = tun_size - sizeof(tun->lt_cmn);
+	memcpy(&tun->lt_tun, &ni->ni_lnd_tunables, min_size);
+
+	/* copy over the cpts */
+	if (ni->ni_ncpts == LNET_CPT_NUMBER &&
+	    !ni->ni_cpts) {
+		for (i = 0; i < ni->ni_ncpts; i++)
+			cfg_ni->lic_cpts[i] = i;
+	} else {
+		for (i = 0;
+		     ni->ni_cpts && i < ni->ni_ncpts &&
+		     i < LNET_MAX_SHOW_NUM_CPT;
+		     i++)
+			cfg_ni->lic_cpts[i] = ni->ni_cpts[i];
+	}
+	cfg_ni->lic_ncpts = ni->ni_ncpts;
+}
+
+/**
+ * NOTE: This is a legacy function left in the code to be backwards
+ * compatible with older userspace programs. It should eventually be
+ * removed.
+ *
+ * Grabs the ni data from the ni structure and fills the out
+ * parameters
+ *
+ * \param[in] ni network	interface structure
+ * \param[out] config		config information
+ */
+static void
+lnet_fill_ni_info_legacy(struct lnet_ni *ni,
+			 struct lnet_ioctl_config_data *config)
 {
 	struct lnet_ioctl_config_lnd_tunables *lnd_cfg = NULL;
 	struct lnet_ioctl_net_config *net_config;
@@ -1994,7 +2084,7 @@ lnet_get_net_config(struct lnet_ioctl_config_data *config)
 	if (ni) {
 		rc = 0;
 		lnet_ni_lock(ni);
-		lnet_fill_ni_info(ni, config);
+		lnet_fill_ni_info_legacy(ni, config);
 		lnet_ni_unlock(ni);
 	}
 
@@ -2003,38 +2093,43 @@ lnet_get_net_config(struct lnet_ioctl_config_data *config)
 }
 
 int
-lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
+lnet_get_ni_config(struct lnet_ioctl_config_ni *cfg_ni,
+		   struct lnet_ioctl_config_lnd_tunables *tun,
+		   __u32 tun_size)
 {
-	char *nets = conf->cfg_config_u.cfg_net.net_intf;
-	struct lnet_ping_info *pinfo;
-	struct lnet_handle_md md_handle;
-	struct lnet_net *net;
-	struct list_head net_head;
-	struct lnet_remotenet *rnet;
-	int rc;
-	int net_ni_count;
-	int num_acceptor_nets;
-	u32 net_type;
-	struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
-
-	INIT_LIST_HEAD(&net_head);
+	struct lnet_ni *ni;
+	int cpt;
+	int rc = -ENOENT;
 
-	if (conf && conf->cfg_hdr.ioc_len > sizeof(*conf))
-		lnd_tunables = (struct lnet_ioctl_config_lnd_tunables *)conf->cfg_bulk;
+	if (!cfg_ni || !tun)
+		return -EINVAL;
 
-	/* Create a net/ni structures for the network string */
-	rc = lnet_parse_networks(&net_head, nets, use_tcp_bonding);
-	if (rc <= 0)
-		return !rc ? -EINVAL : rc;
+	cpt = lnet_net_lock_current();
 
-	mutex_lock(&the_lnet.ln_api_mutex);
+	ni = lnet_get_ni_idx_locked(cfg_ni->lic_idx);
 
-	if (rc > 1) {
-		rc = -EINVAL; /* only add one network per call */
-		goto failed0;
+	if (ni) {
+		rc = 0;
+		lnet_ni_lock(ni);
+		lnet_fill_ni_info(ni, cfg_ni, tun, tun_size);
+		lnet_ni_unlock(ni);
 	}
 
-	net = list_entry(net_head.next, struct lnet_net, net_list);
+	lnet_net_unlock(cpt);
+	return rc;
+}
+
+static int lnet_add_net_common(struct lnet_net *net,
+			       struct lnet_ioctl_config_lnd_tunables *tun)
+{
+	struct lnet_net *netl = NULL;
+	u32 net_id;
+	struct lnet_ping_info *pinfo;
+	struct lnet_handle_md md_handle;
+	int rc;
+	struct lnet_remotenet *rnet;
+	int net_ni_count;
+	int num_acceptor_nets;
 
 	lnet_net_lock(LNET_LOCK_EX);
 	rnet = lnet_find_rnet_locked(net->net_id);
@@ -2045,9 +2140,9 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
 	 */
 	if (rnet) {
 		CERROR("Adding net %s will invalidate routing configuration\n",
-		       nets);
+		       libcfs_net2str(net->net_id));
 		rc = -EUSERS;
-		goto failed0;
+		goto failed1;
 	}
 
 	/*
@@ -2056,21 +2151,21 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
 	 * we should allocate enough slots to accomodate the number of NIs
 	 * which will be added.
 	 *
-	 * We can use lnet_get_net_ni_count_locked() since the net is not
-	 * on a public list yet, so locking is not a problem
+	 * since ni hasn't been configured yet, use
+	 * lnet_get_net_ni_count_pre() which checks the net_ni_added list
 	 */
-	net_ni_count = lnet_get_net_ni_count_locked(net);
+	net_ni_count = lnet_get_net_ni_count_pre(net);
 
 	rc = lnet_ping_info_setup(&pinfo, &md_handle,
 				  net_ni_count + lnet_get_ni_count(),
 				  false);
-	if (rc)
-		goto failed0;
-
-	list_del_init(&net->net_list);
-	if (lnd_tunables)
+	if (rc < 0)
+		goto failed1;
+	if (tun)
 		memcpy(&net->net_tunables,
-		       &lnd_tunables->lt_cmn, sizeof(lnd_tunables->lt_cmn));
+		       &tun->lt_cmn, sizeof(net->net_tunables));
+	else
+		memset(&net->net_tunables, -1, sizeof(net->net_tunables));
 
 	/*
 	 * before starting this network get a count of the current TCP
@@ -2080,47 +2175,269 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
 	 */
 	num_acceptor_nets = lnet_count_acceptor_nets();
 
-	/*
-	 * lnd_startup_lndnet() can deallocate 'net' even if it it returns
-	 * success, because we endded up adding interfaces to an existing
-	 * network. So grab the net_type now
-	 */
-	net_type = LNET_NETTYP(net->net_id);
+	net_id = net->net_id;
 
-	rc = lnet_startup_lndnet(net, (lnd_tunables ?
-				     &lnd_tunables->lt_tun : NULL));
+	rc = lnet_startup_lndnet(net, (tun ?
+				     &tun->lt_tun : NULL));
 	if (rc < 0)
-		goto failed1;
+		goto failed;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	netl = lnet_get_net_locked(net_id);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	LASSERT(netl);
 
 	/*
 	 * Start the acceptor thread if this is the first network
 	 * being added that requires the thread.
 	 */
-	if (net_type == SOCKLND && num_acceptor_nets == 0) {
+	if (netl->net_lnd->lnd_accept &&
+	    num_acceptor_nets == 0) {
 		rc = lnet_acceptor_start();
 		if (rc < 0) {
 			/* shutdown the net that we just started */
 			CERROR("Failed to start up acceptor thread\n");
-			/*
-			 * Note that if we needed to start the acceptor
-			 * thread, then 'net' must have been the first TCP
-			 * network, therefore was unique, and therefore
-			 * wasn't deallocated by lnet_startup_lndnet()
-			 */
 			lnet_shutdown_lndnet(net);
-			goto failed1;
+			goto failed;
 		}
 	}
 
+	lnet_net_lock(LNET_LOCK_EX);
+	lnet_peer_net_added(netl);
+	lnet_net_unlock(LNET_LOCK_EX);
+
 	lnet_ping_target_update(pinfo, md_handle);
-	mutex_unlock(&the_lnet.ln_api_mutex);
 
 	return 0;
 
-failed1:
+failed:
 	lnet_ping_md_unlink(pinfo, &md_handle);
 	lnet_ping_info_free(pinfo);
-failed0:
+failed1:
+	lnet_net_free(net);
+	return rc;
+}
+
+static int lnet_handle_legacy_ip2nets(char *ip2nets,
+				      struct lnet_ioctl_config_lnd_tunables *tun)
+{
+	struct lnet_net *net;
+	char *nets;
+	int rc;
+	struct list_head net_head;
+
+	INIT_LIST_HEAD(&net_head);
+
+	rc = lnet_parse_ip2nets(&nets, ip2nets);
+	if (rc < 0)
+		return rc;
+
+	rc = lnet_parse_networks(&net_head, nets, use_tcp_bonding);
+	if (rc < 0)
+		return rc;
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+	while (!list_empty(&net_head)) {
+		net = list_entry(net_head.next, struct lnet_net, net_list);
+		list_del_init(&net->net_list);
+		rc = lnet_add_net_common(net, tun);
+		if (rc < 0)
+			goto out;
+	}
+
+out:
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	while (!list_empty(&net_head)) {
+		net = list_entry(net_head.next, struct lnet_net, net_list);
+		list_del_init(&net->net_list);
+		lnet_net_free(net);
+	}
+	return rc;
+}
+
+int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
+{
+	struct lnet_net *net;
+	struct lnet_ni *ni;
+	struct lnet_ioctl_config_lnd_tunables *tun = NULL;
+	int rc;
+	u32 net_id;
+
+	/* get the tunables if they are available */
+	if (conf->lic_cfg_hdr.ioc_len >=
+	    sizeof(*conf) + sizeof(*tun))
+		tun = (struct lnet_ioctl_config_lnd_tunables *)
+			conf->lic_bulk;
+
+	/* handle legacy ip2nets from DLC */
+	if (conf->lic_legacy_ip2nets[0] != '\0')
+		return lnet_handle_legacy_ip2nets(conf->lic_legacy_ip2nets,
+						  tun);
+
+	net_id = LNET_NIDNET(conf->lic_nid);
+
+	net = lnet_net_alloc(net_id, NULL);
+	if (!net)
+		return -ENOMEM;
+
+	ni = lnet_ni_alloc_w_cpt_array(net, conf->lic_cpts, conf->lic_ncpts,
+				       conf->lic_ni_intf[0]);
+	if (!ni)
+		return -ENOMEM;
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	rc = lnet_add_net_common(net, tun);
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return rc;
+}
+
+int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
+{
+	struct lnet_net *net;
+	struct lnet_ni *ni;
+	u32 net_id = LNET_NIDNET(conf->lic_nid);
+	struct lnet_ping_info *pinfo;
+	struct lnet_handle_md md_handle;
+	int rc;
+	int net_count;
+	u32 addr;
+
+	/* don't allow userspace to shutdown the LOLND */
+	if (LNET_NETTYP(net_id) == LOLND)
+		return -EINVAL;
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	lnet_net_lock(0);
+
+	net = lnet_get_net_locked(net_id);
+	if (!net) {
+		CERROR("net %s not found\n",
+		       libcfs_net2str(net_id));
+		rc = -ENOENT;
+		goto net_unlock;
+	}
+
+	addr = LNET_NIDADDR(conf->lic_nid);
+	if (addr == 0) {
+		/* remove the entire net */
+		net_count = lnet_get_net_ni_count_locked(net);
+
+		lnet_net_unlock(0);
+
+		/* create and link a new ping info, before removing the old one */
+		rc = lnet_ping_info_setup(&pinfo, &md_handle,
+					  lnet_get_ni_count() - net_count,
+					  false);
+		if (rc != 0)
+			goto out;
+
+		lnet_shutdown_lndnet(net);
+
+		if (lnet_count_acceptor_nets() == 0)
+			lnet_acceptor_stop();
+
+		lnet_ping_target_update(pinfo, md_handle);
+
+		goto out;
+	}
+
+	ni = lnet_nid2ni_locked(conf->lic_nid, 0);
+	if (!ni) {
+		CERROR("nid %s not found\n",
+		       libcfs_nid2str(conf->lic_nid));
+		rc = -ENOENT;
+		goto net_unlock;
+	}
+
+	net_count = lnet_get_net_ni_count_locked(net);
+
+	lnet_net_unlock(0);
+
+	/* create and link a new ping info, before removing the old one */
+	rc = lnet_ping_info_setup(&pinfo, &md_handle,
+				  lnet_get_ni_count() - 1, false);
+	if (rc != 0)
+		goto out;
+
+	lnet_shutdown_lndni(ni);
+
+	if (lnet_count_acceptor_nets() == 0)
+		lnet_acceptor_stop();
+
+	lnet_ping_target_update(pinfo, md_handle);
+
+	/* check if the net is empty and remove it if it is */
+	if (net_count == 1)
+		lnet_shutdown_lndnet(net);
+
+	goto out;
+
+net_unlock:
+	lnet_net_unlock(0);
+out:
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return rc;
+}
+
+/*
+ * lnet_dyn_add_net and lnet_dyn_del_net are now deprecated.
+ * They are only expected to be called for unique networks.
+ * That can be as a result of older DLC library
+ * calls. Multi-Rail DLC and beyond no longer uses these APIs.
+ */
+int
+lnet_dyn_add_net(struct lnet_ioctl_config_data *conf)
+{
+	struct lnet_net *net;
+	struct list_head net_head;
+	int rc;
+	struct lnet_ioctl_config_lnd_tunables tun;
+	char *nets = conf->cfg_config_u.cfg_net.net_intf;
+
+	INIT_LIST_HEAD(&net_head);
+
+	/* Create a net/ni structures for the network string */
+	rc = lnet_parse_networks(&net_head, nets, use_tcp_bonding);
+	if (rc <= 0)
+		return rc == 0 ? -EINVAL : rc;
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	if (rc > 1) {
+		rc = -EINVAL; /* only add one network per call */
+		goto failed;
+	}
+
+	net = list_entry(net_head.next, struct lnet_net, net_list);
+	list_del_init(&net->net_list);
+
+	LASSERT(lnet_net_unique(net->net_id, &the_lnet.ln_nets, NULL));
+
+	memset(&tun, 0, sizeof(tun));
+
+	tun.lt_cmn.lct_peer_timeout =
+		conf->cfg_config_u.cfg_net.net_peer_timeout;
+	tun.lt_cmn.lct_peer_tx_credits =
+		conf->cfg_config_u.cfg_net.net_peer_tx_credits;
+	tun.lt_cmn.lct_peer_rtr_credits =
+		conf->cfg_config_u.cfg_net.net_peer_rtr_credits;
+	tun.lt_cmn.lct_max_tx_credits =
+		conf->cfg_config_u.cfg_net.net_max_tx_credits;
+
+	rc = lnet_add_net_common(net, &tun);
+	if (rc != 0)
+		goto failed;
+
+	return 0;
+
+failed:
 	mutex_unlock(&the_lnet.ln_api_mutex);
 	while (!list_empty(&net_head)) {
 		net = list_entry(net_head.next, struct lnet_net, net_list);
@@ -2131,7 +2448,7 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
 }
 
 int
-lnet_dyn_del_ni(__u32 net_id)
+lnet_dyn_del_net(__u32 net_id)
 {
 	struct lnet_net *net;
 	struct lnet_ping_info *pinfo;
@@ -2256,6 +2573,25 @@ LNetCtl(unsigned int cmd, void *arg)
 				      &config->cfg_config_u.cfg_route.rtr_flags,
 				      &config->cfg_config_u.cfg_route.rtr_priority);
 
+	case IOC_LIBCFS_GET_LOCAL_NI: {
+		struct lnet_ioctl_config_ni *cfg_ni;
+		struct lnet_ioctl_config_lnd_tunables *tun = NULL;
+		__u32 tun_size;
+
+		cfg_ni = arg;
+		/* get the tunables if they are available */
+		if (cfg_ni->lic_cfg_hdr.ioc_len <
+		    sizeof(*cfg_ni) + sizeof(*tun))
+			return -EINVAL;
+
+		tun = (struct lnet_ioctl_config_lnd_tunables *)
+				cfg_ni->lic_bulk;
+
+		tun_size = cfg_ni->lic_cfg_hdr.ioc_len - sizeof(*cfg_ni);
+
+		return lnet_get_ni_config(cfg_ni, tun, tun_size);
+	}
+
 	case IOC_LIBCFS_GET_NET: {
 		size_t total = sizeof(*config) +
 			       sizeof(struct lnet_ioctl_net_config);
@@ -2423,8 +2759,22 @@ LNetCtl(unsigned int cmd, void *arg)
 		data->ioc_count = rc;
 		return 0;
 	}
+
+	case IOC_LIBCFS_DBG: {
+		struct lnet_ioctl_dbg *dbg = arg;
+		struct lnet_dbg_task_info *dbg_info;
+		size_t total = sizeof(*dbg) + sizeof(*dbg_info);
+
+		if (dbg->dbg_hdr.ioc_len < total)
+			return -EINVAL;
+
+		dbg_info = (struct lnet_dbg_task_info *)dbg->dbg_bulk;
+
+		return lnet_handle_dbg_task(dbg, dbg_info);
+	}
+
 	default:
-		ni = lnet_net2ni(data->ioc_net);
+		ni = lnet_net2ni_addref(data->ioc_net);
 		if (!ni)
 			return -EINVAL;
 
@@ -2433,6 +2783,7 @@ LNetCtl(unsigned int cmd, void *arg)
 		else
 			rc = ni->ni_net->net_lnd->lnd_ctl(ni, cmd, arg);
 
+		lnet_ni_decref(ni);
 		return rc;
 	}
 	/* not reached */
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 9539ce07ae05..c11821a5838c 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -87,6 +87,9 @@ lnet_net_unique(__u32 net_id, struct list_head *netlist,
 {
 	struct lnet_net *net_l;
 
+	if (!netlist)
+		return true;
+
 	list_for_each_entry(net_l, netlist, net_list) {
 		if (net_l->net_id == net_id) {
 			if (net)
@@ -172,6 +175,7 @@ lnet_net_append_cpts(__u32 *cpts, __u32 ncpts, struct lnet_net *net)
 		if (!net->net_cpts)
 			return -ENOMEM;
 		memcpy(net->net_cpts, cpts, ncpts);
+		net->net_ncpts = ncpts;
 		return 0;
 	}
 
@@ -298,8 +302,7 @@ lnet_ni_free(struct lnet_ni *ni)
 	if (ni->ni_tx_queues)
 		cfs_percpt_free(ni->ni_tx_queues);
 
-	if (ni->ni_cpts)
-		cfs_expr_list_values_free(ni->ni_cpts, ni->ni_ncpts);
+	kfree(ni->ni_cpts);
 
 	for (i = 0; i < LNET_MAX_INTERFACES && ni->ni_interfaces[i]; i++)
 		kfree(ni->ni_interfaces[i]);
@@ -371,7 +374,8 @@ lnet_net_alloc(__u32 net_id, struct list_head *net_list)
 	net->net_tunables.lct_peer_tx_credits = -1;
 	net->net_tunables.lct_peer_rtr_credits = -1;
 
-	list_add_tail(&net->net_list, net_list);
+	if (net_list)
+		list_add_tail(&net->net_list, net_list);
 
 	return net;
 }
@@ -414,13 +418,11 @@ lnet_ni_add_interface(struct lnet_ni *ni, char *iface)
 	return 0;
 }
 
-/* allocate and add to the provided network */
-struct lnet_ni *
-lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
+static struct lnet_ni *
+lnet_ni_alloc_common(struct lnet_net *net, char *iface)
 {
 	struct lnet_tx_queue *tq;
 	struct lnet_ni *ni;
-	int rc;
 	int i;
 
 	if (iface)
@@ -452,6 +454,45 @@ lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
 	cfs_percpt_for_each(tq, i, ni->ni_tx_queues)
 		INIT_LIST_HEAD(&tq->tq_delayed);
 
+	ni->ni_net = net;
+	/* LND will fill in the address part of the NID */
+	ni->ni_nid = LNET_MKNID(net->net_id, 0);
+
+	/* Store net namespace in which current ni is being created */
+	if (current->nsproxy->net_ns)
+		ni->ni_net_ns = get_net(current->nsproxy->net_ns);
+	else
+		ni->ni_net_ns = NULL;
+
+	ni->ni_last_alive = ktime_get_real_seconds();
+	ni->ni_state = LNET_NI_STATE_INIT;
+	list_add_tail(&ni->ni_netlist, &net->net_ni_added);
+
+	/*
+	 * if an interface name is provided then make sure to add in that
+	 * interface name in NI
+	 */
+	if (iface)
+		if (lnet_ni_add_interface(ni, iface) != 0)
+			goto failed;
+
+	return ni;
+failed:
+	lnet_ni_free(ni);
+	return NULL;
+}
+
+/* allocate and add to the provided network */
+struct lnet_ni *
+lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
+{
+	struct lnet_ni *ni;
+	int rc;
+
+	ni = lnet_ni_alloc_common(net, iface);
+	if (!ni)
+		return NULL;
+
 	if (!el) {
 		ni->ni_cpts  = NULL;
 		ni->ni_ncpts = LNET_CPT_NUMBER;
@@ -466,35 +507,51 @@ lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
 
 		LASSERT(rc <= LNET_CPT_NUMBER);
 		if (rc == LNET_CPT_NUMBER) {
-			cfs_expr_list_values_free(ni->ni_cpts, LNET_CPT_NUMBER);
+			kfree(ni->ni_cpts);
 			ni->ni_cpts = NULL;
 		}
 
 		ni->ni_ncpts = rc;
 	}
 
-	ni->ni_net = net;
-	/* LND will fill in the address part of the NID */
-	ni->ni_nid = LNET_MKNID(net->net_id, 0);
-
-	/* Store net namespace in which current ni is being created */
-	if (current->nsproxy->net_ns)
-		ni->ni_net_ns = get_net(current->nsproxy->net_ns);
-	else
-		ni->ni_net_ns = NULL;
-
-	ni->ni_last_alive = ktime_get_real_seconds();
-	ni->ni_state = LNET_NI_STATE_INIT;
 	rc = lnet_net_append_cpts(ni->ni_cpts, ni->ni_ncpts, net);
 	if (rc != 0)
 		goto failed;
-	list_add_tail(&ni->ni_netlist, &net->net_ni_added);
 
-	/* if an interface name is provided then make sure to add in that
-	 * interface name in NI */
-	if (iface)
-		if (lnet_ni_add_interface(ni, iface) != 0)
+	return ni;
+failed:
+	lnet_ni_free(ni);
+	return NULL;
+}
+
+struct lnet_ni *
+lnet_ni_alloc_w_cpt_array(struct lnet_net *net, __u32 *cpts, __u32 ncpts,
+			  char *iface)
+{
+	struct lnet_ni *ni;
+	int rc;
+
+	ni = lnet_ni_alloc_common(net, iface);
+	if (!ni)
+		return NULL;
+
+	if (ncpts == 0) {
+		ni->ni_cpts  = NULL;
+		ni->ni_ncpts = LNET_CPT_NUMBER;
+	} else {
+		size_t array_size = ncpts * sizeof(ni->ni_cpts[0]);
+
+		ni->ni_cpts = kmalloc_array(ncpts, sizeof(ni->ni_cpts[0]),
+					    GFP_KERNEL);
+		if (!ni->ni_cpts)
 			goto failed;
+		memcpy(ni->ni_cpts, cpts, array_size);
+		ni->ni_ncpts = ncpts;
+	}
+
+	rc = lnet_net_append_cpts(ni->ni_cpts, ni->ni_ncpts, net);
+	if (rc != 0)
+		goto failed;
 
 	return ni;
  failed:
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 9d06664f0c17..c82d27592391 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -92,7 +92,7 @@ lnet_unconfigure(void)
 }
 
 static int
-lnet_dyn_configure(struct libcfs_ioctl_hdr *hdr)
+lnet_dyn_configure_net(struct libcfs_ioctl_hdr *hdr)
 {
 	struct lnet_ioctl_config_data *conf =
 		(struct lnet_ioctl_config_data *)hdr;
@@ -102,19 +102,17 @@ lnet_dyn_configure(struct libcfs_ioctl_hdr *hdr)
 		return -EINVAL;
 
 	mutex_lock(&lnet_config_mutex);
-	if (!the_lnet.ln_niinit_self) {
+	if (the_lnet.ln_niinit_self)
+		rc = lnet_dyn_add_net(conf);
+	else
 		rc = -EINVAL;
-		goto out_unlock;
-	}
-	rc = lnet_dyn_add_ni(LNET_PID_LUSTRE, conf);
-out_unlock:
 	mutex_unlock(&lnet_config_mutex);
 
 	return rc;
 }
 
 static int
-lnet_dyn_unconfigure(struct libcfs_ioctl_hdr *hdr)
+lnet_dyn_unconfigure_net(struct libcfs_ioctl_hdr *hdr)
 {
 	struct lnet_ioctl_config_data *conf =
 		(struct lnet_ioctl_config_data *)hdr;
@@ -124,12 +122,50 @@ lnet_dyn_unconfigure(struct libcfs_ioctl_hdr *hdr)
 		return -EINVAL;
 
 	mutex_lock(&lnet_config_mutex);
-	if (!the_lnet.ln_niinit_self) {
+	if (the_lnet.ln_niinit_self)
+		rc = lnet_dyn_del_net(conf->cfg_net);
+	else
+		rc = -EINVAL;
+	mutex_unlock(&lnet_config_mutex);
+
+	return rc;
+}
+
+static int
+lnet_dyn_configure_ni(struct libcfs_ioctl_hdr *hdr)
+{
+	struct lnet_ioctl_config_ni *conf =
+		(struct lnet_ioctl_config_ni *)hdr;
+	int rc;
+
+	if (conf->lic_cfg_hdr.ioc_len < sizeof(*conf))
+		return -EINVAL;
+
+	mutex_lock(&lnet_config_mutex);
+	if (the_lnet.ln_niinit_self)
+		rc = lnet_dyn_add_ni(conf);
+	else
+		rc = -EINVAL;
+	mutex_unlock(&lnet_config_mutex);
+
+	return rc;
+}
+
+static int
+lnet_dyn_unconfigure_ni(struct libcfs_ioctl_hdr *hdr)
+{
+	struct lnet_ioctl_config_ni *conf =
+		(struct lnet_ioctl_config_ni *)hdr;
+	int rc;
+
+	if (conf->lic_cfg_hdr.ioc_len < sizeof(*conf))
+		return -EINVAL;
+
+	mutex_lock(&lnet_config_mutex);
+	if (the_lnet.ln_niinit_self)
+		rc = lnet_dyn_del_ni(conf);
+	else
 		rc = -EINVAL;
-		goto out_unlock;
-	}
-	rc = lnet_dyn_del_ni(conf->cfg_net);
-out_unlock:
 	mutex_unlock(&lnet_config_mutex);
 
 	return rc;
@@ -161,11 +197,17 @@ lnet_ioctl(struct notifier_block *nb,
 		break;
 
 	case IOC_LIBCFS_ADD_NET:
-		rc = lnet_dyn_configure(hdr);
+		rc = lnet_dyn_configure_net(hdr);
 		break;
 
 	case IOC_LIBCFS_DEL_NET:
-		rc = lnet_dyn_unconfigure(hdr);
+		rc = lnet_dyn_unconfigure_net(hdr);
+
+	case IOC_LIBCFS_ADD_LOCAL_NI:
+		return lnet_dyn_configure_ni(hdr);
+
+	case IOC_LIBCFS_DEL_LOCAL_NI:
+		return lnet_dyn_unconfigure_ni(hdr);
 		break;
 
 	default:
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index d081440579e0..a760e43bcf7e 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -47,6 +47,27 @@ lnet_peer_remove_from_remote_list(struct lnet_peer_ni *lpni)
 	}
 }
 
+void
+lnet_peer_net_added(struct lnet_net *net)
+{
+	struct lnet_peer_ni *lpni, *tmp;
+
+	list_for_each_entry_safe(lpni, tmp, &the_lnet.ln_remote_peer_ni_list,
+				 lpni_on_remote_peer_ni_list) {
+		if (LNET_NIDNET(lpni->lpni_nid) == net->net_id) {
+			lpni->lpni_net = net;
+			lpni->lpni_txcredits =
+				lpni->lpni_mintxcredits =
+				lpni->lpni_net->net_tunables.lct_peer_tx_credits;
+			lpni->lpni_rtrcredits =
+				lpni->lpni_minrtrcredits =
+				lnet_peer_buffer_credits(lpni->lpni_net);
+
+			lnet_peer_remove_from_remote_list(lpni);
+		}
+	}
+}
+
 void
 lnet_peer_tables_destroy(void)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 66295b4fcdab..c201a8871943 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -726,7 +726,7 @@ static int ptlrpcd_init(void)
 			ptlrpcds_cpt_idx[cpt] = i;
 		}
 
-		cfs_expr_list_values_free(cpts, rc);
+		kfree(cpts);
 		ncpts = rc;
 	}
 	ptlrpcds_num = ncpts;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 55f68b9b3818..79baadc0d09f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2780,9 +2780,7 @@ ptlrpc_service_free(struct ptlrpc_service *svc)
 	ptlrpc_service_for_each_part(svcpt, i, svc)
 		kfree(svcpt);
 
-	if (svc->srv_cpts)
-		cfs_expr_list_values_free(svc->srv_cpts, svc->srv_ncpts);
-
+	kfree(svc->srv_cpts);
 	kfree(svc);
 }
 
