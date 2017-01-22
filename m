From: James Simmons <jsimmons@infradead.org>
Date: Sat, 21 Jan 2017 19:40:26 -0500
Subject: [lustre-devel] [PATCH 2/8] staging: lustre: lnet: change
	lnet_ping_info_t to proper structure
In-Reply-To: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485045632-5886-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_ping_info_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24566
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  2 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |  6 ++--
 drivers/staging/lustre/include/linux/lnet/types.h  |  4 +--
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 42 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/router.c          |  6 ++--
 5 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 363342f..8f164a9 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -664,7 +664,7 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 int lnet_router_checker_start(void);
 void lnet_router_checker_stop(void);
 void lnet_router_ni_update_locked(lnet_peer_t *gw, __u32 net);
-void lnet_swap_pinginfo(lnet_ping_info_t *info);
+void lnet_swap_pinginfo(struct lnet_ping_info *info);
 
 int lnet_parse_ip2nets(char **networksp, char *ip2nets);
 int lnet_parse_routes(char *route_str, int *im_a_router);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index b84a5bb..a1957b1 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -295,13 +295,13 @@ struct lnet_tx_queue {
 
 /* router checker data, per router */
 #define LNET_MAX_RTR_NIS   16
-#define LNET_PINGINFO_SIZE offsetof(lnet_ping_info_t, pi_ni[LNET_MAX_RTR_NIS])
+#define LNET_PINGINFO_SIZE offsetof(struct lnet_ping_info, pi_ni[LNET_MAX_RTR_NIS])
 typedef struct {
 	/* chain on the_lnet.ln_zombie_rcd or ln_deathrow_rcd */
 	struct list_head	 rcd_list;
 	lnet_handle_md_t	 rcd_mdh;	/* ping buffer MD */
 	struct lnet_peer	*rcd_gateway;	/* reference to gateway */
-	lnet_ping_info_t	*rcd_pinginfo;	/* ping buffer */
+	struct lnet_ping_info	*rcd_pinginfo;	/* ping buffer */
 } lnet_rc_data_t;
 
 typedef struct lnet_peer {
@@ -599,7 +599,7 @@ struct lnet_msg_container {
 
 	lnet_handle_md_t		  ln_ping_target_md;
 	lnet_handle_eq_t		  ln_ping_target_eq;
-	lnet_ping_info_t		 *ln_ping_info;
+	struct lnet_ping_info		 *ln_ping_info;
 
 	/* router checker startup/shutdown state */
 	int				  ln_rc_state;
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 1787089..0c5d84e 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -242,13 +242,13 @@ struct lnet_handle_wire {
 	__u32		ns_unused;
 } WIRE_ATTR lnet_ni_status_t;
 
-typedef struct {
+struct lnet_ping_info {
 	__u32			pi_magic;
 	__u32			pi_features;
 	lnet_pid_t		pi_pid;
 	__u32			pi_nnis;
 	lnet_ni_status_t	pi_ni[0];
-} WIRE_ATTR lnet_ping_info_t;
+} WIRE_ATTR;
 
 typedef struct lnet_counters {
 	__u32	msgs_alloc;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 3a7788c..ae388b2 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -822,13 +822,13 @@ static void lnet_assert_wire_constants(void)
 	return count;
 }
 
-static lnet_ping_info_t *
+static struct lnet_ping_info *
 lnet_ping_info_create(int num_ni)
 {
-	lnet_ping_info_t *ping_info;
+	struct lnet_ping_info *ping_info;
 	unsigned int infosz;
 
-	infosz = offsetof(lnet_ping_info_t, pi_ni[num_ni]);
+	infosz = offsetof(struct lnet_ping_info, pi_ni[num_ni]);
 	LIBCFS_ALLOC(ping_info, infosz);
 	if (!ping_info) {
 		CERROR("Can't allocate ping info[%d]\n", num_ni);
@@ -860,10 +860,10 @@ static void lnet_assert_wire_constants(void)
 }
 
 static inline void
-lnet_ping_info_free(lnet_ping_info_t *pinfo)
+lnet_ping_info_free(struct lnet_ping_info *pinfo)
 {
 	LIBCFS_FREE(pinfo,
-		    offsetof(lnet_ping_info_t,
+		    offsetof(struct lnet_ping_info,
 			     pi_ni[pinfo->pi_nnis]));
 }
 
@@ -889,14 +889,14 @@ static void lnet_assert_wire_constants(void)
 static void
 lnet_ping_event_handler(lnet_event_t *event)
 {
-	lnet_ping_info_t *pinfo = event->md.user_ptr;
+	struct lnet_ping_info *pinfo = event->md.user_ptr;
 
 	if (event->unlinked)
 		pinfo->pi_features = LNET_PING_FEAT_INVAL;
 }
 
 static int
-lnet_ping_info_setup(lnet_ping_info_t **ppinfo, lnet_handle_md_t *md_handle,
+lnet_ping_info_setup(struct lnet_ping_info **ppinfo, lnet_handle_md_t *md_handle,
 		     int ni_count, bool set_eq)
 {
 	lnet_process_id_t id = {LNET_NID_ANY, LNET_PID_ANY};
@@ -930,7 +930,7 @@ static void lnet_assert_wire_constants(void)
 
 	/* initialize md content */
 	md.start = *ppinfo;
-	md.length = offsetof(lnet_ping_info_t,
+	md.length = offsetof(struct lnet_ping_info,
 			     pi_ni[(*ppinfo)->pi_nnis]);
 	md.threshold = LNET_MD_THRESH_INF;
 	md.max_size = 0;
@@ -961,7 +961,7 @@ static void lnet_assert_wire_constants(void)
 }
 
 static void
-lnet_ping_md_unlink(lnet_ping_info_t *pinfo, lnet_handle_md_t *md_handle)
+lnet_ping_md_unlink(struct lnet_ping_info *pinfo, lnet_handle_md_t *md_handle)
 {
 	sigset_t blocked = cfs_block_allsigs();
 
@@ -979,7 +979,7 @@ static void lnet_assert_wire_constants(void)
 }
 
 static void
-lnet_ping_info_install_locked(lnet_ping_info_t *ping_info)
+lnet_ping_info_install_locked(struct lnet_ping_info *ping_info)
 {
 	lnet_ni_status_t *ns;
 	lnet_ni_t *ni;
@@ -1003,9 +1003,9 @@ static void lnet_assert_wire_constants(void)
 }
 
 static void
-lnet_ping_target_update(lnet_ping_info_t *pinfo, lnet_handle_md_t md_handle)
+lnet_ping_target_update(struct lnet_ping_info *pinfo, lnet_handle_md_t md_handle)
 {
-	lnet_ping_info_t *old_pinfo = NULL;
+	struct lnet_ping_info *old_pinfo = NULL;
 	lnet_handle_md_t old_md;
 
 	/* switch the NIs to point to the new ping info created */
@@ -1496,7 +1496,7 @@ void lnet_lib_exit(void)
 	int im_a_router = 0;
 	int rc;
 	int ni_count;
-	lnet_ping_info_t *pinfo;
+	struct lnet_ping_info *pinfo;
 	lnet_handle_md_t md_handle;
 	struct list_head net_head;
 
@@ -1754,7 +1754,7 @@ void lnet_lib_exit(void)
 lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
 {
 	char *nets = conf->cfg_config_u.cfg_net.net_intf;
-	lnet_ping_info_t *pinfo;
+	struct lnet_ping_info *pinfo;
 	lnet_handle_md_t md_handle;
 	struct lnet_ni *ni;
 	struct list_head net_head;
@@ -1834,7 +1834,7 @@ void lnet_lib_exit(void)
 lnet_dyn_del_ni(__u32 net)
 {
 	lnet_ni_t *ni;
-	lnet_ping_info_t *pinfo;
+	struct lnet_ping_info *pinfo;
 	lnet_handle_md_t md_handle;
 	int rc;
 
@@ -2147,7 +2147,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 	int replied = 0;
 	const int a_long_time = 60000; /* mS */
 	int infosz;
-	lnet_ping_info_t *info;
+	struct lnet_ping_info *info;
 	lnet_process_id_t tmpid;
 	int i;
 	int nob;
@@ -2155,7 +2155,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 	int rc2;
 	sigset_t blocked;
 
-	infosz = offsetof(lnet_ping_info_t, pi_ni[n_ids]);
+	infosz = offsetof(struct lnet_ping_info, pi_ni[n_ids]);
 
 	if (n_ids <= 0 ||
 	    id.nid == LNET_NID_ANY ||
@@ -2283,18 +2283,18 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 		goto out_1;
 	}
 
-	if (nob < offsetof(lnet_ping_info_t, pi_ni[0])) {
+	if (nob < offsetof(struct lnet_ping_info, pi_ni[0])) {
 		CERROR("%s: Short reply %d(%d min)\n", libcfs_id2str(id),
-		       nob, (int)offsetof(lnet_ping_info_t, pi_ni[0]));
+		       nob, (int)offsetof(struct lnet_ping_info, pi_ni[0]));
 		goto out_1;
 	}
 
 	if (info->pi_nnis < n_ids)
 		n_ids = info->pi_nnis;
 
-	if (nob < offsetof(lnet_ping_info_t, pi_ni[n_ids])) {
+	if (nob < offsetof(struct lnet_ping_info, pi_ni[n_ids])) {
 		CERROR("%s: Short reply %d(%d expected)\n", libcfs_id2str(id),
-		       nob, (int)offsetof(lnet_ping_info_t, pi_ni[n_ids]));
+		       nob, (int)offsetof(struct lnet_ping_info, pi_ni[n_ids]));
 		goto out_1;
 	}
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 8afa0ab..269b5e7 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -621,7 +621,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 void
-lnet_swap_pinginfo(lnet_ping_info_t *info)
+lnet_swap_pinginfo(struct lnet_ping_info *info)
 {
 	int i;
 	lnet_ni_status_t *stat;
@@ -644,7 +644,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 static void
 lnet_parse_rc_info(lnet_rc_data_t *rcd)
 {
-	lnet_ping_info_t *info = rcd->rcd_pinginfo;
+	struct lnet_ping_info *info = rcd->rcd_pinginfo;
 	struct lnet_peer *gw = rcd->rcd_gateway;
 	lnet_route_t *rte;
 
@@ -902,7 +902,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 lnet_create_rc_data_locked(lnet_peer_t *gateway)
 {
 	lnet_rc_data_t *rcd = NULL;
-	lnet_ping_info_t *pi;
+	struct lnet_ping_info *pi;
 	lnet_md_t md;
 	int rc;
 	int i;
-- 
1.8.3.1
