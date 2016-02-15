From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Feb 2016 10:25:54 -0500
Subject: [lustre-devel] [PATCH 10/10] staging: lustre: DLC Feature dynamic
	net config
In-Reply-To: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
References: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455549954-29532-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

This is the third patch of a set of patches that enables DLC.

This patch adds the following features to LNET.  Currently these
features are not driven by user space.
- Adding/Deleting Networks dynamically
Two new functions were added:
 - lnet_dyn_add_ni()
    add an NI. if the NI is already added then fail with
    appropriate error code
 - lnet_dyn_del_ni()
    delete an existing NI.  If NI doesn't exist fail with
    appropriate failure code.
These functions shall be called from IOCTL.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2456
Reviewed-on: http://review.whamcloud.com/9832
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    4 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  804 +++++++++++++-------
 drivers/staging/lustre/lnet/lnet/config.c          |    2 +-
 3 files changed, 518 insertions(+), 292 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 3a1cf61..0592e30 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -681,12 +681,10 @@ void lnet_router_checker_stop(void);
 void lnet_router_ni_update_locked(lnet_peer_t *gw, __u32 net);
 void lnet_swap_pinginfo(lnet_ping_info_t *info);
 
-int lnet_ping_target_init(void);
-void lnet_ping_target_fini(void);
-
 int lnet_parse_ip2nets(char **networksp, char *ip2nets);
 int lnet_parse_routes(char *route_str, int *im_a_router);
 int lnet_parse_networks(struct list_head *nilist, char *networks);
+int lnet_net_unique(__u32 net, struct list_head *nilist);
 
 int lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt);
 lnet_peer_t *lnet_find_peer_locked(struct lnet_peer_table *ptable,
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 06046b2..933f345 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -533,6 +533,11 @@ lnet_prepare(lnet_pid_t requested_pid)
 	struct lnet_res_container **recs;
 	int rc = 0;
 
+	if (requested_pid == LNET_PID_ANY) {
+		/* Don't instantiate LNET just for me */
+		return -ENETDOWN;
+	}
+
 	LASSERT(!the_lnet.ln_refcount);
 
 	the_lnet.ln_routing = 0;
@@ -819,6 +824,229 @@ lnet_count_acceptor_nis(void)
 	return count;
 }
 
+static lnet_ping_info_t *
+lnet_ping_info_create(int num_ni)
+{
+	lnet_ping_info_t *ping_info;
+	unsigned int infosz;
+
+	infosz = offsetof(lnet_ping_info_t, pi_ni[num_ni]);
+	LIBCFS_ALLOC(ping_info, infosz);
+	if (!ping_info) {
+		CERROR("Can't allocate ping info[%d]\n", num_ni);
+		return NULL;
+	}
+
+	ping_info->pi_nnis = num_ni;
+	ping_info->pi_pid = the_lnet.ln_pid;
+	ping_info->pi_magic = LNET_PROTO_PING_MAGIC;
+	ping_info->pi_features = LNET_PING_FEAT_NI_STATUS;
+
+	return ping_info;
+}
+
+static inline int
+lnet_get_ni_count(void)
+{
+	struct lnet_ni *ni;
+	int count = 0;
+
+	lnet_net_lock(0);
+
+	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list)
+		count++;
+
+	lnet_net_unlock(0);
+
+	return count;
+}
+
+static inline void
+lnet_ping_info_free(lnet_ping_info_t *pinfo)
+{
+	LIBCFS_FREE(pinfo,
+		    offsetof(lnet_ping_info_t,
+			     pi_ni[pinfo->pi_nnis]));
+}
+
+static void
+lnet_ping_info_destroy(void)
+{
+	struct lnet_ni *ni;
+
+	lnet_net_lock(LNET_LOCK_EX);
+
+	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
+		lnet_ni_lock(ni);
+		ni->ni_status = NULL;
+		lnet_ni_unlock(ni);
+	}
+
+	lnet_ping_info_free(the_lnet.ln_ping_info);
+	the_lnet.ln_ping_info = NULL;
+
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+
+static void
+lnet_ping_event_handler(lnet_event_t *event)
+{
+	lnet_ping_info_t *pinfo = event->md.user_ptr;
+
+	if (event->unlinked)
+		pinfo->pi_features = LNET_PING_FEAT_INVAL;
+}
+
+static int
+lnet_ping_info_setup(lnet_ping_info_t **ppinfo, lnet_handle_md_t *md_handle,
+		     int ni_count, bool set_eq)
+{
+	lnet_process_id_t id = {LNET_NID_ANY, LNET_PID_ANY};
+	lnet_handle_me_t me_handle;
+	lnet_md_t md = {0};
+	int rc, rc2;
+
+	if (set_eq) {
+		rc = LNetEQAlloc(0, lnet_ping_event_handler,
+				 &the_lnet.ln_ping_target_eq);
+		if (rc) {
+			CERROR("Can't allocate ping EQ: %d\n", rc);
+			return rc;
+		}
+	}
+
+	*ppinfo = lnet_ping_info_create(ni_count);
+	if (!*ppinfo) {
+		rc = -ENOMEM;
+		goto failed_0;
+	}
+
+	rc = LNetMEAttach(LNET_RESERVED_PORTAL, id,
+			  LNET_PROTO_PING_MATCHBITS, 0,
+			  LNET_UNLINK, LNET_INS_AFTER,
+			  &me_handle);
+	if (rc) {
+		CERROR("Can't create ping ME: %d\n", rc);
+		goto failed_1;
+	}
+
+	/* initialize md content */
+	md.start = *ppinfo;
+	md.length = offsetof(lnet_ping_info_t,
+			     pi_ni[(*ppinfo)->pi_nnis]);
+	md.threshold = LNET_MD_THRESH_INF;
+	md.max_size = 0;
+	md.options = LNET_MD_OP_GET | LNET_MD_TRUNCATE |
+		     LNET_MD_MANAGE_REMOTE;
+	md.user_ptr  = NULL;
+	md.eq_handle = the_lnet.ln_ping_target_eq;
+	md.user_ptr = *ppinfo;
+
+	rc = LNetMDAttach(me_handle, md, LNET_RETAIN, md_handle);
+	if (rc) {
+		CERROR("Can't attach ping MD: %d\n", rc);
+		goto failed_2;
+	}
+
+	return 0;
+
+failed_2:
+	rc2 = LNetMEUnlink(me_handle);
+	LASSERT(!rc2);
+failed_1:
+	lnet_ping_info_free(*ppinfo);
+	*ppinfo = NULL;
+failed_0:
+	if (set_eq)
+		LNetEQFree(the_lnet.ln_ping_target_eq);
+	return rc;
+}
+
+static void
+lnet_ping_md_unlink(lnet_ping_info_t *pinfo, lnet_handle_md_t *md_handle)
+{
+	sigset_t blocked = cfs_block_allsigs();
+
+	LNetMDUnlink(*md_handle);
+	LNetInvalidateHandle(md_handle);
+
+	/* NB md could be busy; this just starts the unlink */
+	while (pinfo->pi_features != LNET_PING_FEAT_INVAL) {
+		CDEBUG(D_NET, "Still waiting for ping MD to unlink\n");
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(cfs_time_seconds(1));
+	}
+
+	cfs_restore_sigs(blocked);
+}
+
+static void
+lnet_ping_info_install_locked(lnet_ping_info_t *ping_info)
+{
+	lnet_ni_status_t *ns;
+	lnet_ni_t *ni;
+	int i = 0;
+
+	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
+		LASSERT(i < ping_info->pi_nnis);
+
+		ns = &ping_info->pi_ni[i];
+
+		ns->ns_nid = ni->ni_nid;
+
+		lnet_ni_lock(ni);
+		ns->ns_status = (ni->ni_status) ?
+				 ni->ni_status->ns_status : LNET_NI_STATUS_UP;
+		ni->ni_status = ns;
+		lnet_ni_unlock(ni);
+
+		i++;
+	}
+}
+
+static void
+lnet_ping_target_update(lnet_ping_info_t *pinfo, lnet_handle_md_t md_handle)
+{
+	lnet_ping_info_t *old_pinfo = NULL;
+	lnet_handle_md_t old_md;
+
+	/* switch the NIs to point to the new ping info created */
+	lnet_net_lock(LNET_LOCK_EX);
+
+	if (!the_lnet.ln_routing)
+		pinfo->pi_features |= LNET_PING_FEAT_RTE_DISABLED;
+	lnet_ping_info_install_locked(pinfo);
+
+	if (the_lnet.ln_ping_info) {
+		old_pinfo = the_lnet.ln_ping_info;
+		old_md = the_lnet.ln_ping_target_md;
+	}
+	the_lnet.ln_ping_target_md = md_handle;
+	the_lnet.ln_ping_info = pinfo;
+
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	if (old_pinfo) {
+		/* unlink the old ping info */
+		lnet_ping_md_unlink(old_pinfo, &old_md);
+		lnet_ping_info_free(old_pinfo);
+	}
+}
+
+static void
+lnet_ping_target_fini(void)
+{
+	int rc;
+
+	lnet_ping_md_unlink(the_lnet.ln_ping_info,
+			    &the_lnet.ln_ping_target_md);
+
+	rc = LNetEQFree(the_lnet.ln_ping_target_eq);
+	LASSERT(!rc);
+
+	lnet_ping_info_destroy();
+}
+
 static int
 lnet_ni_tq_credits(lnet_ni_t *ni)
 {
@@ -837,12 +1065,74 @@ lnet_ni_tq_credits(lnet_ni_t *ni)
 }
 
 static void
-lnet_shutdown_lndnis(void)
+lnet_clear_zombies_nis_locked(void)
 {
 	int i;
 	int islo;
 	lnet_ni_t *ni;
 
+	/*
+	 * Now wait for the NI's I just nuked to show up on ln_zombie_nis
+	 * and shut them down in guaranteed thread context
+	 */
+	i = 2;
+	while (!list_empty(&the_lnet.ln_nis_zombie)) {
+		int *ref;
+		int j;
+
+		ni = list_entry(the_lnet.ln_nis_zombie.next,
+				lnet_ni_t, ni_list);
+		list_del_init(&ni->ni_list);
+		cfs_percpt_for_each(ref, j, ni->ni_refs) {
+			if (!*ref)
+				continue;
+			/* still busy, add it back to zombie list */
+			list_add(&ni->ni_list, &the_lnet.ln_nis_zombie);
+			break;
+		}
+
+		if (!list_empty(&ni->ni_list)) {
+			lnet_net_unlock(LNET_LOCK_EX);
+			++i;
+			if ((i & (-i)) == i) {
+				CDEBUG(D_WARNING, "Waiting for zombie LNI %s\n",
+				       libcfs_nid2str(ni->ni_nid));
+			}
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			schedule_timeout(cfs_time_seconds(1));
+			lnet_net_lock(LNET_LOCK_EX);
+			continue;
+		}
+
+		ni->ni_lnd->lnd_refcount--;
+		lnet_net_unlock(LNET_LOCK_EX);
+
+		islo = ni->ni_lnd->lnd_type == LOLND;
+
+		LASSERT(!in_interrupt());
+		ni->ni_lnd->lnd_shutdown(ni);
+
+		/*
+		 * can't deref lnd anymore now; it might have unregistered
+		 * itself...
+		 */
+		if (!islo)
+			CDEBUG(D_LNI, "Removed LNI %s\n",
+			       libcfs_nid2str(ni->ni_nid));
+
+		lnet_ni_free(ni);
+		i = 2;
+
+		lnet_net_lock(LNET_LOCK_EX);
+	}
+}
+
+static void
+lnet_shutdown_lndnis(void)
+{
+	lnet_ni_t *ni;
+	int i;
+
 	/* NB called holding the global mutex */
 
 	/* All quiet on the API front */
@@ -895,92 +1185,90 @@ lnet_shutdown_lndnis(void)
 	lnet_peer_tables_cleanup(NULL);
 
 	lnet_net_lock(LNET_LOCK_EX);
-	/*
-	 * Now wait for the NI's I just nuked to show up on ln_zombie_nis
-	 * and shut them down in guaranteed thread context
-	 */
-	i = 2;
-	while (!list_empty(&the_lnet.ln_nis_zombie)) {
-		int *ref;
-		int j;
 
-		ni = list_entry(the_lnet.ln_nis_zombie.next,
-				lnet_ni_t, ni_list);
-		list_del_init(&ni->ni_list);
-		cfs_percpt_for_each(ref, j, ni->ni_refs) {
-			if (!*ref)
-				continue;
-			/* still busy, add it back to zombie list */
-			list_add(&ni->ni_list, &the_lnet.ln_nis_zombie);
-			break;
-		}
+	lnet_clear_zombies_nis_locked();
+	the_lnet.ln_shutdown = 0;
+	lnet_net_unlock(LNET_LOCK_EX);
+}
 
-		if (!list_empty(&ni->ni_list)) {
-			lnet_net_unlock(LNET_LOCK_EX);
-			++i;
-			if ((i & (-i)) == i) {
-				CDEBUG(D_WARNING, "Waiting for zombie LNI %s\n",
-				       libcfs_nid2str(ni->ni_nid));
-			}
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(cfs_time_seconds(1));
-			lnet_net_lock(LNET_LOCK_EX);
-			continue;
-		}
+int
+lnet_shutdown_lndni(__u32 net)
+{
+	lnet_ping_info_t *pinfo;
+	lnet_handle_md_t md_handle;
+	lnet_ni_t *found_ni = NULL;
+	int ni_count;
+	int rc;
 
-		ni->ni_lnd->lnd_refcount--;
-		lnet_net_unlock(LNET_LOCK_EX);
+	if (LNET_NETTYP(net) == LOLND)
+		return -EINVAL;
 
-		islo = ni->ni_lnd->lnd_type == LOLND;
+	ni_count = lnet_get_ni_count();
 
-		LASSERT(!in_interrupt());
-		ni->ni_lnd->lnd_shutdown(ni);
+	/* create and link a new ping info, before removing the old one */
+	rc = lnet_ping_info_setup(&pinfo, &md_handle, ni_count - 1, false);
+	if (rc)
+		return rc;
 
-		/*
-		 * can't deref lnd anymore now; it might have unregistered
-		 * itself...
-		 */
-		if (!islo)
-			CDEBUG(D_LNI, "Removed LNI %s\n",
-			       libcfs_nid2str(ni->ni_nid));
+	/* proceed with shutting down the NI */
+	lnet_net_lock(LNET_LOCK_EX);
 
-		lnet_ni_free(ni);
-		i = 2;
+	found_ni = lnet_net2ni_locked(net, 0);
+	if (!found_ni) {
+		lnet_net_unlock(LNET_LOCK_EX);
+		lnet_ping_md_unlink(pinfo, &md_handle);
+		lnet_ping_info_free(pinfo);
+		return -EINVAL;
+	}
 
-		lnet_net_lock(LNET_LOCK_EX);
+	/*
+	 * decrement the reference counter on found_ni which was
+	 * incremented when we called lnet_net2ni_locked()
+	 */
+	lnet_ni_decref_locked(found_ni, 0);
+	/* Move ni to zombie list so nobody can find it anymore */
+	list_move(&found_ni->ni_list, &the_lnet.ln_nis_zombie);
+
+	/* Drop the lock reference for the ln_nis ref. */
+	lnet_ni_decref_locked(found_ni, 0);
+
+	if (!list_empty(&found_ni->ni_cptlist)) {
+		list_del_init(&found_ni->ni_cptlist);
+		lnet_ni_decref_locked(found_ni, 0);
 	}
 
-	the_lnet.ln_shutdown = 0;
 	lnet_net_unlock(LNET_LOCK_EX);
+
+	/* Do peer table cleanup for this ni */
+	lnet_peer_tables_cleanup(found_ni);
+
+	lnet_net_lock(LNET_LOCK_EX);
+	lnet_clear_zombies_nis_locked();
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	lnet_ping_target_update(pinfo, md_handle);
+
+	return 0;
 }
 
 static int
-lnet_startup_lndnis(void)
+lnet_startup_lndnis(struct list_head *nilist, __s32 peer_timeout,
+		    __s32 peer_cr, __s32 peer_buf_cr, __s32 credits,
+		    int *ni_count)
 {
 	lnd_t *lnd;
 	struct lnet_ni *ni;
 	struct lnet_tx_queue *tq;
-	struct list_head nilist;
 	int i;
 	int rc = 0;
 	__u32 lnd_type;
-	int nicount = 0;
-	char *nets = lnet_get_networks();
-
-	INIT_LIST_HEAD(&nilist);
-
-	if (!nets)
-		goto failed;
-
-	rc = lnet_parse_networks(&nilist, nets);
-	if (rc)
-		goto failed;
 
-	while (!list_empty(&nilist)) {
-		ni = list_entry(nilist.next, lnet_ni_t, ni_list);
+	while (!list_empty(nilist)) {
+		ni = list_entry(nilist->next, lnet_ni_t, ni_list);
 		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
 
-		LASSERT(libcfs_isknown_lnd(lnd_type));
+		if (!libcfs_isknown_lnd(lnd_type))
+			goto failed;
 
 		if (lnd_type == CIBLND    ||
 		    lnd_type == OPENIBLND ||
@@ -991,6 +1279,24 @@ lnet_startup_lndnis(void)
 			goto failed;
 		}
 
+		/* Make sure this new NI is unique. */
+		lnet_net_lock(LNET_LOCK_EX);
+		if (!lnet_net_unique(LNET_NIDNET(ni->ni_nid),
+				     &the_lnet.ln_nis)) {
+			if (lnd_type == LOLND) {
+				lnet_net_unlock(LNET_LOCK_EX);
+				list_del(&ni->ni_list);
+				lnet_ni_free(ni);
+				continue;
+			}
+
+			CERROR("Net %s is not unique\n",
+			       libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
+			lnet_net_unlock(LNET_LOCK_EX);
+			goto failed;
+		}
+		lnet_net_unlock(LNET_LOCK_EX);
+
 		mutex_lock(&the_lnet.ln_lnd_mutex);
 		lnd = lnet_find_lnd_by_type(lnd_type);
 
@@ -1029,6 +1335,25 @@ lnet_startup_lndnis(void)
 			goto failed;
 		}
 
+		/*
+		 * If given some LND tunable parameters, parse those now to
+		 * override the values in the NI structure.
+		 */
+		if (peer_buf_cr >= 0)
+			ni->ni_peerrtrcredits = peer_buf_cr;
+		if (peer_timeout >= 0)
+			ni->ni_peertimeout = peer_timeout;
+		/*
+		 * TODO
+		 * Note: For now, don't allow the user to change
+		 * peertxcredits as this number is used in the
+		 * IB LND to control queue depth.
+		 * if (peer_cr != -1)
+		 *	ni->ni_peertxcredits = peer_cr;
+		 */
+		if (credits >= 0)
+			ni->ni_maxtxcredits = credits;
+
 		LASSERT(ni->ni_peertimeout <= 0 || lnd->lnd_query);
 
 		list_del(&ni->ni_list);
@@ -1045,6 +1370,14 @@ lnet_startup_lndnis(void)
 
 		lnet_net_unlock(LNET_LOCK_EX);
 
+		/* increment the ni_count here to account for the LOLND as
+		 * well.  If we increment past this point then the number
+		 * of count will be missing the LOLND, and then ping and
+		 * will not report the LOLND
+		 */
+		if (ni_count)
+			(*ni_count)++;
+
 		if (lnd->lnd_type == LOLND) {
 			lnet_ni_addref(ni);
 			LASSERT(!the_lnet.ln_loni);
@@ -1070,29 +1403,16 @@ lnet_startup_lndnis(void)
 		       libcfs_nid2str(ni->ni_nid), ni->ni_peertxcredits,
 		       lnet_ni_tq_credits(ni) * LNET_CPT_NUMBER,
 		       ni->ni_peerrtrcredits, ni->ni_peertimeout);
-
-		nicount++;
-	}
-
-	if (the_lnet.ln_eq_waitni && nicount > 1) {
-		lnd_type = the_lnet.ln_eq_waitni->ni_lnd->lnd_type;
-		LCONSOLE_ERROR_MSG(0x109, "LND %s can only run single-network\n",
-				   libcfs_lnd2str(lnd_type));
-		goto failed;
 	}
 
 	return 0;
-
- failed:
-	lnet_shutdown_lndnis();
-
-	while (!list_empty(&nilist)) {
-		ni = list_entry(nilist.next, lnet_ni_t, ni_list);
+failed:
+	while (!list_empty(nilist)) {
+		ni = list_entry(nilist->next, lnet_ni_t, ni_list);
 		list_del(&ni->ni_list);
 		lnet_ni_free(ni);
 	}
-
-	return -ENETDOWN;
+	return -EINVAL;
 }
 
 /**
@@ -1208,6 +1528,15 @@ LNetNIInit(lnet_pid_t requested_pid)
 {
 	int im_a_router = 0;
 	int rc;
+	int ni_count = 0;
+	int lnd_type;
+	struct lnet_ni *ni;
+	lnet_ping_info_t *pinfo;
+	lnet_handle_md_t md_handle;
+	struct list_head net_head;
+	char *nets;
+
+	INIT_LIST_HEAD(&net_head);
 
 	mutex_lock(&the_lnet.ln_api_mutex);
 
@@ -1216,23 +1545,31 @@ LNetNIInit(lnet_pid_t requested_pid)
 
 	if (the_lnet.ln_refcount > 0) {
 		rc = the_lnet.ln_refcount++;
-		goto out;
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 	}
 
-	if (requested_pid == LNET_PID_ANY) {
-		/* Don't instantiate LNET just for me */
-		rc = -ENETDOWN;
-		goto failed0;
-	}
+	nets = lnet_get_networks();
 
 	rc = lnet_prepare(requested_pid);
 	if (rc)
 		goto failed0;
 
-	rc = lnet_startup_lndnis();
+	rc = lnet_parse_networks(&net_head, nets);
+	if (rc < 0)
+		goto failed1;
+
+	rc = lnet_startup_lndnis(&net_head, -1, -1, -1, -1, &ni_count);
 	if (rc)
 		goto failed1;
 
+	if (the_lnet.ln_eq_waitni && ni_count > 1) {
+		lnd_type = the_lnet.ln_eq_waitni->ni_lnd->lnd_type;
+		LCONSOLE_ERROR_MSG(0x109, "LND %s can only run single-network\n",
+				   libcfs_lnd2str(lnd_type));
+		goto failed2;
+	}
+
 	rc = lnet_parse_routes(lnet_get_routes(), &im_a_router);
 	if (rc)
 		goto failed2;
@@ -1252,26 +1589,30 @@ LNetNIInit(lnet_pid_t requested_pid)
 	the_lnet.ln_refcount = 1;
 	/* Now I may use my own API functions... */
 
-	/*
-	 * NB router checker needs the_lnet.ln_ping_info in
-	 * lnet_router_checker -> lnet_update_ni_status_locked
-	  */
-	rc = lnet_ping_target_init();
+	rc = lnet_ping_info_setup(&pinfo, &md_handle, ni_count, true);
 	if (rc)
 		goto failed3;
 
+	lnet_ping_target_update(pinfo, md_handle);
+
 	rc = lnet_router_checker_start();
 	if (rc)
 		goto failed4;
 
 	lnet_router_debugfs_init();
-	goto out;
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return 0;
 
  failed4:
-	lnet_ping_target_fini();
- failed3:
 	the_lnet.ln_refcount = 0;
+	lnet_ping_md_unlink(pinfo, &md_handle);
+	lnet_ping_info_free(pinfo);
+ failed3:
 	lnet_acceptor_stop();
+	rc = LNetEQFree(the_lnet.ln_ping_target_eq);
+	LASSERT(!rc);
  failed2:
 	lnet_destroy_routes();
 	lnet_shutdown_lndnis();
@@ -1279,8 +1620,12 @@ LNetNIInit(lnet_pid_t requested_pid)
 	lnet_unprepare();
  failed0:
 	LASSERT(rc < 0);
- out:
 	mutex_unlock(&the_lnet.ln_api_mutex);
+	while (!list_empty(&net_head)) {
+		ni = list_entry(net_head.next, struct lnet_ni, ni_list);
+		list_del_init(&ni->ni_list);
+		lnet_ni_free(ni);
+	}
 	return rc;
 }
 EXPORT_SYMBOL(LNetNIInit);
@@ -1325,6 +1670,71 @@ LNetNIFini(void)
 }
 EXPORT_SYMBOL(LNetNIFini);
 
+int
+lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
+		__s32 peer_timeout, __s32 peer_cr, __s32 peer_buf_cr,
+		__s32 credits)
+{
+	lnet_ping_info_t *pinfo;
+	lnet_handle_md_t md_handle;
+	struct lnet_ni *ni;
+	struct list_head net_head;
+	int rc;
+
+	INIT_LIST_HEAD(&net_head);
+
+	/* Create a ni structure for the network string */
+	rc = lnet_parse_networks(&net_head, nets);
+	if (rc < 0)
+		return rc;
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	if (rc > 1) {
+		rc = -EINVAL; /* only add one interface per call */
+		goto failed0;
+	}
+
+	rc = lnet_ping_info_setup(&pinfo, &md_handle, 1 + lnet_get_ni_count(),
+				  false);
+	if (rc)
+		goto failed0;
+
+	rc = lnet_startup_lndnis(&net_head, peer_timeout, peer_cr,
+				 peer_buf_cr, credits, NULL);
+	if (rc)
+		goto failed1;
+
+	lnet_ping_target_update(pinfo, md_handle);
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return 0;
+
+failed1:
+	lnet_ping_md_unlink(pinfo, &md_handle);
+	lnet_ping_info_free(pinfo);
+failed0:
+	mutex_unlock(&the_lnet.ln_api_mutex);
+	while (!list_empty(&net_head)) {
+		ni = list_entry(net_head.next, struct lnet_ni, ni_list);
+		list_del_init(&ni->ni_list);
+		lnet_ni_free(ni);
+	}
+	return rc;
+}
+
+int
+lnet_dyn_del_ni(__u32 net)
+{
+	int rc;
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+	rc = lnet_shutdown_lndni(net);
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return rc;
+}
+
 /**
  * LNet ioctl handler.
  *
@@ -1339,7 +1749,6 @@ LNetCtl(unsigned int cmd, void *arg)
 	unsigned long secs_passed;
 
 	LASSERT(the_lnet.ln_init);
-	LASSERT(the_lnet.ln_refcount > 0);
 
 	switch (cmd) {
 	case IOC_LIBCFS_GET_NI:
@@ -1351,12 +1760,17 @@ LNetCtl(unsigned int cmd, void *arg)
 		return lnet_fail_nid(data->ioc_nid, data->ioc_count);
 
 	case IOC_LIBCFS_ADD_ROUTE:
+		mutex_lock(&the_lnet.ln_api_mutex);
 		rc = lnet_add_route(data->ioc_net, data->ioc_count,
 				    data->ioc_nid, data->ioc_priority);
-		return (rc) ? rc : lnet_check_routes();
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc ? rc : lnet_check_routes();
 
 	case IOC_LIBCFS_DEL_ROUTE:
-		return lnet_del_route(data->ioc_net, data->ioc_nid);
+		mutex_lock(&the_lnet.ln_api_mutex);
+		rc = lnet_del_route(data->ioc_net, data->ioc_nid);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
 
 	case IOC_LIBCFS_GET_ROUTE:
 		return lnet_get_route(data->ioc_count,
@@ -1471,194 +1885,6 @@ LNetSnprintHandle(char *str, int len, lnet_handle_any_t h)
 }
 EXPORT_SYMBOL(LNetSnprintHandle);
 
-static int
-lnet_create_ping_info(void)
-{
-	int i;
-	int n;
-	int rc;
-	unsigned int infosz;
-	lnet_ni_t *ni;
-	lnet_process_id_t id;
-	lnet_ping_info_t *pinfo;
-
-	for (n = 0; ; n++) {
-		rc = LNetGetId(n, &id);
-		if (rc == -ENOENT)
-			break;
-
-		LASSERT(!rc);
-	}
-
-	infosz = offsetof(lnet_ping_info_t, pi_ni[n]);
-	LIBCFS_ALLOC(pinfo, infosz);
-	if (!pinfo) {
-		CERROR("Can't allocate ping info[%d]\n", n);
-		return -ENOMEM;
-	}
-
-	pinfo->pi_nnis    = n;
-	pinfo->pi_pid     = the_lnet.ln_pid;
-	pinfo->pi_magic   = LNET_PROTO_PING_MAGIC;
-	pinfo->pi_features = LNET_PING_FEAT_NI_STATUS;
-	if (!the_lnet.ln_routing)
-		pinfo->pi_features |= LNET_PING_FEAT_RTE_DISABLED;
-
-	for (i = 0; i < n; i++) {
-		lnet_ni_status_t *ns = &pinfo->pi_ni[i];
-
-		rc = LNetGetId(i, &id);
-		LASSERT(!rc);
-
-		ns->ns_nid    = id.nid;
-		ns->ns_status = LNET_NI_STATUS_UP;
-
-		lnet_net_lock(0);
-
-		ni = lnet_nid2ni_locked(id.nid, 0);
-		LASSERT(ni);
-
-		lnet_ni_lock(ni);
-		LASSERT(!ni->ni_status);
-		ni->ni_status = ns;
-		lnet_ni_unlock(ni);
-
-		lnet_ni_decref_locked(ni, 0);
-		lnet_net_unlock(0);
-	}
-
-	the_lnet.ln_ping_info = pinfo;
-	return 0;
-}
-
-static void
-lnet_destroy_ping_info(void)
-{
-	struct lnet_ni *ni;
-
-	lnet_net_lock(0);
-
-	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
-		lnet_ni_lock(ni);
-		ni->ni_status = NULL;
-		lnet_ni_unlock(ni);
-	}
-
-	lnet_net_unlock(0);
-
-	LIBCFS_FREE(the_lnet.ln_ping_info,
-		    offsetof(lnet_ping_info_t,
-			     pi_ni[the_lnet.ln_ping_info->pi_nnis]));
-	the_lnet.ln_ping_info = NULL;
-}
-
-int
-lnet_ping_target_init(void)
-{
-	lnet_md_t md = { NULL };
-	lnet_handle_me_t meh;
-	lnet_process_id_t id;
-	int rc;
-	int rc2;
-	int infosz;
-
-	rc = lnet_create_ping_info();
-	if (rc)
-		return rc;
-
-	/*
-	 * We can have a tiny EQ since we only need to see the unlink event on
-	 * teardown, which by definition is the last one!
-	 */
-	rc = LNetEQAlloc(2, LNET_EQ_HANDLER_NONE, &the_lnet.ln_ping_target_eq);
-	if (rc) {
-		CERROR("Can't allocate ping EQ: %d\n", rc);
-		goto failed_0;
-	}
-
-	memset(&id, 0, sizeof(lnet_process_id_t));
-	id.nid = LNET_NID_ANY;
-	id.pid = LNET_PID_ANY;
-
-	rc = LNetMEAttach(LNET_RESERVED_PORTAL, id,
-			  LNET_PROTO_PING_MATCHBITS, 0,
-			  LNET_UNLINK, LNET_INS_AFTER,
-			  &meh);
-	if (rc) {
-		CERROR("Can't create ping ME: %d\n", rc);
-		goto failed_1;
-	}
-
-	/* initialize md content */
-	infosz = offsetof(lnet_ping_info_t,
-			  pi_ni[the_lnet.ln_ping_info->pi_nnis]);
-	md.start     = the_lnet.ln_ping_info;
-	md.length    = infosz;
-	md.threshold = LNET_MD_THRESH_INF;
-	md.max_size  = 0;
-	md.options   = LNET_MD_OP_GET | LNET_MD_TRUNCATE |
-		       LNET_MD_MANAGE_REMOTE;
-	md.user_ptr  = NULL;
-	md.eq_handle = the_lnet.ln_ping_target_eq;
-
-	rc = LNetMDAttach(meh, md,
-			  LNET_RETAIN,
-			  &the_lnet.ln_ping_target_md);
-	if (rc) {
-		CERROR("Can't attach ping MD: %d\n", rc);
-		goto failed_2;
-	}
-
-	return 0;
-
- failed_2:
-	rc2 = LNetMEUnlink(meh);
-	LASSERT(!rc2);
- failed_1:
-	rc2 = LNetEQFree(the_lnet.ln_ping_target_eq);
-	LASSERT(!rc2);
- failed_0:
-	lnet_destroy_ping_info();
-	return rc;
-}
-
-void
-lnet_ping_target_fini(void)
-{
-	lnet_event_t event;
-	int rc;
-	int which;
-	int timeout_ms = 1000;
-	sigset_t blocked = cfs_block_allsigs();
-
-	LNetMDUnlink(the_lnet.ln_ping_target_md);
-	/* NB md could be busy; this just starts the unlink */
-
-	for (;;) {
-		rc = LNetEQPoll(&the_lnet.ln_ping_target_eq, 1,
-				timeout_ms, &event, &which);
-
-		/* I expect overflow... */
-		LASSERT(rc >= 0 || rc == -EOVERFLOW);
-
-		if (!rc) {
-			/* timed out: provide a diagnostic */
-			CWARN("Still waiting for ping MD to unlink\n");
-			timeout_ms *= 2;
-			continue;
-		}
-
-		/* Got a valid event */
-		if (event.unlinked)
-			break;
-	}
-
-	rc = LNetEQFree(the_lnet.ln_ping_target_eq);
-	LASSERT(!rc);
-	lnet_destroy_ping_info();
-	cfs_restore_sigs(blocked);
-}
-
 static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 		     lnet_process_id_t __user *ids, int n_ids)
 {
@@ -1670,7 +1896,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 	int unlinked = 0;
 	int replied = 0;
 	const int a_long_time = 60000; /* mS */
-	int infosz = offsetof(lnet_ping_info_t, pi_ni[n_ids]);
+	int infosz;
 	lnet_ping_info_t *info;
 	lnet_process_id_t tmpid;
 	int i;
@@ -1679,6 +1905,8 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 	int rc2;
 	sigset_t blocked;
 
+	infosz = offsetof(lnet_ping_info_t, pi_ni[n_ids]);
+
 	if (n_ids <= 0 ||
 	    id.nid == LNET_NID_ANY ||
 	    timeout_ms > 500000 ||	      /* arbitrary limit! */
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index bcc97b4..1ef07cd 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -77,7 +77,7 @@ lnet_issep(char c)
 	}
 }
 
-static int
+int
 lnet_net_unique(__u32 net, struct list_head *nilist)
 {
 	struct list_head *tmp;
-- 
1.7.1
