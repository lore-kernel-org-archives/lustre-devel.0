From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:22 -0400
Subject: [lustre-devel] [PATCH 01/10] staging: lustre: lnet: use struct
	lnet_ioctl_config_data for NI bring up
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

The LNet layer passes around the individual fields of struct
lnet_ioctl_config_data for the case of NI bring up. To simplify
the code lets just pass struct lnet_ioctl_config directly.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    5 +--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   37 +++++++++++--------
 drivers/staging/lustre/lnet/lnet/module.c          |    7 +---
 3 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index dfc0208..1865c85 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -478,9 +478,8 @@ int lnet_rtrpools_enable(void);
 void lnet_rtrpools_disable(void);
 void lnet_rtrpools_free(int keep_pools);
 lnet_remotenet_t *lnet_find_net_locked(__u32 net);
-int lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
-		    __s32 peer_timeout, __s32 peer_cr, __s32 peer_buf_cr,
-		    __s32 credits);
+int lnet_dyn_add_ni(lnet_pid_t requested_pid,
+		    struct lnet_ioctl_config_data *conf);
 int lnet_dyn_del_ni(__u32 net);
 int lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason);
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index f825784..6340ad1 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1215,8 +1215,7 @@ lnet_shutdown_lndni(struct lnet_ni *ni)
 }
 
 static int
-lnet_startup_lndni(struct lnet_ni *ni, __s32 peer_timeout,
-		   __s32 peer_cr, __s32 peer_buf_cr, __s32 credits)
+lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 {
 	int rc = -EINVAL;
 	int lnd_type;
@@ -1292,20 +1291,28 @@ lnet_startup_lndni(struct lnet_ni *ni, __s32 peer_timeout,
 	 * If given some LND tunable parameters, parse those now to
 	 * override the values in the NI structure.
 	 */
-	if (peer_buf_cr >= 0)
-		ni->ni_peerrtrcredits = peer_buf_cr;
-	if (peer_timeout >= 0)
-		ni->ni_peertimeout = peer_timeout;
+	if (conf && conf->cfg_config_u.cfg_net.net_peer_rtr_credits >= 0) {
+		ni->ni_peerrtrcredits =
+			conf->cfg_config_u.cfg_net.net_peer_rtr_credits;
+	}
+	if (conf && conf->cfg_config_u.cfg_net.net_peer_timeout >= 0) {
+		ni->ni_peertimeout =
+			conf->cfg_config_u.cfg_net.net_peer_timeout;
+	}
 	/*
 	 * TODO
 	 * Note: For now, don't allow the user to change
 	 * peertxcredits as this number is used in the
 	 * IB LND to control queue depth.
-	 * if (peer_cr != -1)
-	 *	ni->ni_peertxcredits = peer_cr;
+	 *
+	 * if (conf && conf->cfg_config_u.cfg_net.net_peer_tx_credits != -1)
+	 *	ni->ni_peertxcredits =
+	 *		conf->cfg_config_u.cfg_net.net_peer_tx_credits;
 	 */
-	if (credits >= 0)
-		ni->ni_maxtxcredits = credits;
+	if (conf && conf->cfg_config_u.cfg_net.net_max_tx_credits >= 0) {
+		ni->ni_maxtxcredits =
+			conf->cfg_config_u.cfg_net.net_max_tx_credits;
+	}
 
 	LASSERT(ni->ni_peertimeout <= 0 || lnd->lnd_query);
 
@@ -1367,7 +1374,7 @@ lnet_startup_lndnis(struct list_head *nilist)
 	while (!list_empty(nilist)) {
 		ni = list_entry(nilist->next, lnet_ni_t, ni_list);
 		list_del(&ni->ni_list);
-		rc = lnet_startup_lndni(ni, -1, -1, -1, -1);
+		rc = lnet_startup_lndni(ni, NULL);
 
 		if (rc < 0)
 			goto failed;
@@ -1725,10 +1732,9 @@ lnet_get_net_config(int idx, __u32 *cpt_count, __u64 *nid, int *peer_timeout,
 }
 
 int
-lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
-		__s32 peer_timeout, __s32 peer_cr, __s32 peer_buf_cr,
-		__s32 credits)
+lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
 {
+	char *nets = conf->cfg_config_u.cfg_net.net_intf;
 	lnet_ping_info_t *pinfo;
 	lnet_handle_md_t md_handle;
 	struct lnet_ni *ni;
@@ -1773,8 +1779,7 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
 
 	list_del_init(&ni->ni_list);
 
-	rc = lnet_startup_lndni(ni, peer_timeout, peer_cr,
-				peer_buf_cr, credits);
+	rc = lnet_startup_lndni(ni, conf);
 	if (rc)
 		goto failed1;
 
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 93037c1..246b5c1 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -108,12 +108,7 @@ lnet_dyn_configure(struct libcfs_ioctl_hdr *hdr)
 		rc = -EINVAL;
 		goto out_unlock;
 	}
-	rc = lnet_dyn_add_ni(LNET_PID_LUSTRE,
-			     conf->cfg_config_u.cfg_net.net_intf,
-			     conf->cfg_config_u.cfg_net.net_peer_timeout,
-			     conf->cfg_config_u.cfg_net.net_peer_tx_credits,
-			     conf->cfg_config_u.cfg_net.net_peer_rtr_credits,
-			     conf->cfg_config_u.cfg_net.net_max_tx_credits);
+	rc = lnet_dyn_add_ni(LNET_PID_LUSTRE, conf);
 out_unlock:
 	mutex_unlock(&lnet_config_mutex);
 
-- 
1.7.1
