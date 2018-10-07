From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:38 +1100
Subject: [lustre-devel] [PATCH 21/24] lustre: lnet: add "lnetctl discover"
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437836.16383.17797958097457714365.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sonia.sharma@intel.com>

Add a "discover" subcommand to lnetctl

jt_discover() in lnetctl.c calls lustre_lnet_discover_nid()
to implement "lnetctl discover". The output is similar to
"lnetctl ping" command.
This patch also does some clean up in linlnetconfig.c
For parameters under global settings, the common code
for them is pulled in functions ioctl_set_value() and
ioctl_show_global_values().

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Sonia Sharma <sonia.sharma@intel.com>
Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25793
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |    2 
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  100 ++++++++++++++++++++
 2 files changed, 101 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
index 3d89202bd396..60bc9713923e 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -113,7 +113,7 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_DEL_PEER		   _IOWR('e', 74, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_ADD_PEER		   _IOWR('e', 75, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_GET_PEER		   _IOWR('e', 76, IOCTL_LIBCFS_TYPE)
-/* ioctl 77 is free for use */
+#define IOC_LIBCFS_DISCOVER                _IOWR('e', 77, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_ADD_INTERFACE	   _IOWR('e', 78, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_DEL_INTERFACE	   _IOWR('e', 79, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_GET_INTERFACE	   _IOWR('e', 80, IOCTL_LIBCFS_TYPE)
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 37f47bd1511f..0511c6acb9b1 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -104,6 +104,9 @@ static atomic_t lnet_dlc_seq_no = ATOMIC_INIT(0);
 static int lnet_ping(struct lnet_process_id id, signed long timeout,
 		     struct lnet_process_id __user *ids, int n_ids);
 
+static int lnet_discover(struct lnet_process_id id, __u32 force,
+			 struct lnet_process_id __user *ids, int n_ids);
+
 static int
 discovery_set(const char *val, const struct kernel_param *kp)
 {
@@ -3225,6 +3228,25 @@ LNetCtl(unsigned int cmd, void *arg)
 		return 0;
 	}
 
+	case IOC_LIBCFS_DISCOVER: {
+		struct lnet_ioctl_ping_data *discover = arg;
+		struct lnet_peer *lp;
+
+		rc = lnet_discover(discover->ping_id, discover->op_param,
+				   discover->ping_buf,
+				   discover->ping_count);
+		if (rc < 0)
+			return rc;
+		lp = lnet_find_peer(discover->ping_id.nid);
+		if (lp) {
+			discover->ping_id.nid = lp->lp_primary_nid;
+			discover->mr_info = lnet_peer_is_multi_rail(lp);
+		}
+
+		discover->ping_count = rc;
+		return 0;
+	}
+
 	default:
 		ni = lnet_net2ni_addref(data->ioc_net);
 		if (!ni)
@@ -3461,3 +3483,81 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	lnet_ping_buffer_decref(pbuf);
 	return rc;
 }
+
+static int
+lnet_discover(struct lnet_process_id id, __u32 force,
+	      struct lnet_process_id __user *ids,
+	      int n_ids)
+{
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer_ni *p;
+	struct lnet_peer *lp;
+	struct lnet_process_id *buf;
+	int cpt;
+	int i;
+	int rc;
+	int max_intf = lnet_interfaces_max;
+
+	if (n_ids <= 0 ||
+	    id.nid == LNET_NID_ANY ||
+	    n_ids > max_intf)
+		return -EINVAL;
+
+	if (id.pid == LNET_PID_ANY)
+		id.pid = LNET_PID_LUSTRE;
+
+	buf = kcalloc(n_ids, sizeof(*buf), GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	cpt = lnet_net_lock_current();
+	lpni = lnet_nid2peerni_locked(id.nid, LNET_NID_ANY, cpt);
+	if (IS_ERR(lpni)) {
+		rc = PTR_ERR(lpni);
+		goto out;
+	}
+
+	/*
+	 * Clearing the NIDS_UPTODATE flag ensures the peer will
+	 * be discovered, provided discovery has not been disabled.
+	 */
+	lp = lpni->lpni_peer_net->lpn_peer;
+	spin_lock(&lp->lp_lock);
+	lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
+	/* If the force flag is set, force a PING and PUSH as well. */
+	if (force)
+		lp->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH;
+	spin_unlock(&lp->lp_lock);
+	rc = lnet_discover_peer_locked(lpni, cpt, true);
+	if (rc)
+		goto out_decref;
+
+	/* Peer may have changed. */
+	lp = lpni->lpni_peer_net->lpn_peer;
+	if (lp->lp_nnis < n_ids)
+		n_ids = lp->lp_nnis;
+
+	i = 0;
+	p = NULL;
+	while ((p = lnet_get_next_peer_ni_locked(lp, NULL, p)) != NULL) {
+		buf[i].pid = id.pid;
+		buf[i].nid = p->lpni_nid;
+		if (++i >= n_ids)
+			break;
+	}
+
+	lnet_net_unlock(cpt);
+
+	rc = -EFAULT;
+	if (copy_to_user(ids, buf, n_ids * sizeof(*buf)))
+		goto out_relock;
+	rc = n_ids;
+out_relock:
+	lnet_net_lock(cpt);
+out_decref:
+	lnet_peer_ni_decref_locked(lpni);
+out:
+	lnet_net_unlock(cpt);
+	kfree(buf);
+	return rc;
+}
