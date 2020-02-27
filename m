From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:17 -0500
Subject: [lustre-devel] [PATCH 089/622] lnet: reset health value
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-90-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Added an IOCTL to set the local or peer ni health value.
This would be useful in debugging where we can test the selection
algorithm and recovery mechanism by reducing the health of an
interface.

If the value specified is -1 then reset the health value to maximum.
This is useful to reset the system once a network issue has been
resolved. There would be no need to wait for the interface to go to
fully healthy on its own. It might be desirable to shortcut the
process.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 2f5a6d1233ac ("LU-9120 lnet: reset health value")
Lustre-commit: b04c35874dca ("LU-11283 lnet: fix setting health value manually")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32773
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h          |  2 ++
 include/uapi/linux/lnet/libcfs_ioctl.h |  3 +-
 include/uapi/linux/lnet/lnet-dlc.h     | 14 ++++++++
 net/lnet/lnet/api-ni.c                 | 51 +++++++++++++++++++++++++++
 net/lnet/lnet/lib-msg.c                | 16 +--------
 net/lnet/lnet/peer.c                   | 64 ++++++++++++++++++++++++++++++++++
 6 files changed, 134 insertions(+), 16 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index c2191e5..bd6ea90 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -524,6 +524,8 @@ struct lnet_ni *lnet_get_next_ni_locked(struct lnet_net *mynet,
 struct lnet_ni *lnet_get_ni_idx_locked(int idx);
 int lnet_get_peer_list(u32 *countp, u32 *sizep,
 		       struct lnet_process_id __user *ids);
+extern void lnet_peer_ni_set_healthv(lnet_nid_t nid, int value, bool all);
+extern void lnet_peer_ni_add_to_recoveryq_locked(struct lnet_peer_ni *lpni);
 
 void lnet_router_debugfs_init(void);
 void lnet_router_debugfs_fini(void);
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 4396d26..458a634 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -148,6 +148,7 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_GET_NUMA_RANGE	_IOWR(IOC_LIBCFS_TYPE, 99, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_PEER_LIST	_IOWR(IOC_LIBCFS_TYPE, 100, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_LOCAL_NI_MSG_STATS  _IOWR(IOC_LIBCFS_TYPE, 101, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR		101
+#define IOC_LIBCFS_SET_HEALHV		_IOWR(IOC_LIBCFS_TYPE, 102, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR		102
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 484435d..2d3aad8 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -230,6 +230,20 @@ struct lnet_ioctl_peer_cfg {
 	void __user *prcfg_bulk;
 };
 
+
+enum lnet_health_type {
+	LNET_HEALTH_TYPE_LOCAL_NI = 0,
+	LNET_HEALTH_TYPE_PEER_NI,
+};
+
+struct lnet_ioctl_reset_health_cfg {
+	struct libcfs_ioctl_hdr rh_hdr;
+	enum lnet_health_type rh_type;
+	bool rh_all;
+	int rh_value;
+	lnet_nid_t rh_nid;
+};
+
 struct lnet_ioctl_set_value {
 	struct libcfs_ioctl_hdr sv_hdr;
 	__u32 sv_value;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 38e35bb..0cadb2a 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3163,6 +3163,35 @@ u32 lnet_get_dlc_seq_locked(void)
 	return atomic_read(&lnet_dlc_seq_no);
 }
 
+static void
+lnet_ni_set_healthv(lnet_nid_t nid, int value, bool all)
+{
+	struct lnet_net *net;
+	struct lnet_ni *ni;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
+		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+			if (ni->ni_nid == nid || all) {
+				atomic_set(&ni->ni_healthv, value);
+				if (list_empty(&ni->ni_recovery) &&
+				    value < LNET_MAX_HEALTH_VALUE) {
+					CERROR("manually adding local NI %s to recovery\n",
+					       libcfs_nid2str(ni->ni_nid));
+					list_add_tail(&ni->ni_recovery,
+						      &the_lnet.ln_mt_localNIRecovq);
+					lnet_ni_addref_locked(ni, 0);
+				}
+				if (!all) {
+					lnet_net_unlock(LNET_LOCK_EX);
+					return;
+				}
+			}
+		}
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+
 /**
  * LNet ioctl handler.
  *
@@ -3446,6 +3475,28 @@ u32 lnet_get_dlc_seq_locked(void)
 		return rc;
 	}
 
+	case IOC_LIBCFS_SET_HEALHV: {
+		struct lnet_ioctl_reset_health_cfg *cfg = arg;
+		int value;
+
+		if (cfg->rh_hdr.ioc_len < sizeof(*cfg))
+			return -EINVAL;
+		if (cfg->rh_value < 0 ||
+		    cfg->rh_value > LNET_MAX_HEALTH_VALUE)
+			value = LNET_MAX_HEALTH_VALUE;
+		else
+			value = cfg->rh_value;
+		mutex_lock(&the_lnet.ln_api_mutex);
+		if (cfg->rh_type == LNET_HEALTH_TYPE_LOCAL_NI)
+			lnet_ni_set_healthv(cfg->rh_nid, value,
+					    cfg->rh_all);
+		else
+			lnet_peer_ni_set_healthv(cfg->rh_nid, value,
+						 cfg->rh_all);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return 0;
+	}
+
 	case IOC_LIBCFS_NOTIFY_ROUTER: {
 		time64_t deadline = ktime_get_real_seconds() - data->ioc_u64[0];
 
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 5046648..32d49e9 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -530,12 +530,6 @@
 		return;
 
 	lnet_net_lock(0);
-	/* the mt could've shutdown and cleaned up the queues */
-	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
-		lnet_net_unlock(0);
-		return;
-	}
-
 	lnet_dec_healthv_locked(&lpni->lpni_healthv);
 	/* add the peer NI to the recovery queue if it's not already there
 	 * and it's health value is actually below the maximum. It's
@@ -543,15 +537,7 @@
 	 * value will not be reduced. In this case, there is no reason to
 	 * invoke recovery
 	 */
-	if (list_empty(&lpni->lpni_recovery) &&
-	    atomic_read(&lpni->lpni_healthv) < LNET_MAX_HEALTH_VALUE) {
-		CERROR("lpni %s added to recovery queue. Health = %d\n",
-		       libcfs_nid2str(lpni->lpni_nid),
-		       atomic_read(&lpni->lpni_healthv));
-		list_add_tail(&lpni->lpni_recovery,
-			      &the_lnet.ln_mt_peerNIRecovq);
-		lnet_peer_ni_addref_locked(lpni);
-	}
+	lnet_peer_ni_add_to_recoveryq_locked(lpni);
 	lnet_net_unlock(0);
 }
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index ca9b90b..9dbb3bd4 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3437,3 +3437,67 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 out:
 	return rc;
 }
+
+void
+lnet_peer_ni_add_to_recoveryq_locked(struct lnet_peer_ni *lpni)
+{
+	/* the mt could've shutdown and cleaned up the queues */
+	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING)
+		return;
+
+	if (list_empty(&lpni->lpni_recovery) &&
+	    atomic_read(&lpni->lpni_healthv) < LNET_MAX_HEALTH_VALUE) {
+		CERROR("lpni %s added to recovery queue. Health = %d\n",
+		       libcfs_nid2str(lpni->lpni_nid),
+		       atomic_read(&lpni->lpni_healthv));
+		list_add_tail(&lpni->lpni_recovery,
+			      &the_lnet.ln_mt_peerNIRecovq);
+		lnet_peer_ni_addref_locked(lpni);
+	}
+}
+
+/* Call with the ln_api_mutex held */
+void
+lnet_peer_ni_set_healthv(lnet_nid_t nid, int value, bool all)
+{
+	struct lnet_peer_table *ptable;
+	struct lnet_peer *lp;
+	struct lnet_peer_net *lpn;
+	struct lnet_peer_ni *lpni;
+	int lncpt;
+	int cpt;
+
+	if (the_lnet.ln_state != LNET_STATE_RUNNING)
+		return;
+
+	if (!all) {
+		lnet_net_lock(LNET_LOCK_EX);
+		lpni = lnet_find_peer_ni_locked(nid);
+		atomic_set(&lpni->lpni_healthv, value);
+		lnet_peer_ni_add_to_recoveryq_locked(lpni);
+		lnet_peer_ni_decref_locked(lpni);
+		lnet_net_unlock(LNET_LOCK_EX);
+		return;
+	}
+
+	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
+
+	/* Walk all the peers and reset the healhv for each one to the
+	 * maximum value.
+	 */
+	lnet_net_lock(LNET_LOCK_EX);
+	for (cpt = 0; cpt < lncpt; cpt++) {
+		ptable = the_lnet.ln_peer_tables[cpt];
+		list_for_each_entry(lp, &ptable->pt_peer_list, lp_peer_list) {
+			list_for_each_entry(lpn, &lp->lp_peer_nets,
+					    lpn_peer_nets) {
+				list_for_each_entry(lpni, &lpn->lpn_peer_nis,
+						    lpni_peer_nis) {
+					atomic_set(&lpni->lpni_healthv, value);
+					lnet_peer_ni_add_to_recoveryq_locked(lpni);
+				}
+			}
+		}
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+}
-- 
1.8.3.1
