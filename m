From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 23/34] LU-7734 lnet: configuration fixes
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763576.32103.3176502972388297285.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Fix cpt configuration from DLC to configure the proper list
of cpts in LNet. Check in LNet that no CPTs are outside the
available CPTs in the system.

Fix peer_rtr_credits name to peer_tx_credits to reflect the
actual value.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: Ic4a3985a470ed901be6166df4079205677921817
Reviewed-on: http://review.whamcloud.com/20862
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |    4 +++-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    9 +++++++--
 drivers/staging/lustre/lnet/lnet/peer.c            |    3 ++-
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index b31b69c25ef2..a5e94619d3f1 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -169,6 +169,7 @@ struct lnet_ioctl_config_ni {
 	__u32			lic_tcp_bonding;
 	__u32			lic_idx;
 	__s32			lic_dev_cpt;
+	char			pad[4];
 	char			lic_bulk[0];
 };
 
@@ -177,9 +178,10 @@ struct lnet_peer_ni_credit_info {
 	__u32 cr_refcount;
 	__s32 cr_ni_peer_tx_credits;
 	__s32 cr_peer_tx_credits;
+	__s32 cr_peer_min_tx_credits;
+	__u32 cr_peer_tx_qnob;
 	__s32 cr_peer_rtr_credits;
 	__s32 cr_peer_min_rtr_credits;
-	__u32 cr_peer_tx_qnob;
 	__u32 cr_ncpt;
 };
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index ac6efcd746c5..60176d05d34a 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2283,7 +2283,7 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 	struct lnet_net *net;
 	struct lnet_ni *ni;
 	struct lnet_ioctl_config_lnd_tunables *tun = NULL;
-	int rc;
+	int rc, i;
 	u32 net_id;
 
 	/* get the tunables if they are available */
@@ -2303,6 +2303,11 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 	if (!net)
 		return -ENOMEM;
 
+	for (i = 0; i < conf->lic_ncpts; i++) {
+		if (conf->lic_cpts[i] >= LNET_CPT_NUMBER)
+			return -EINVAL;
+	}
+
 	ni = lnet_ni_alloc_w_cpt_array(net, conf->lic_cpts, conf->lic_ncpts,
 				       conf->lic_ni_intf[0]);
 	if (!ni)
@@ -2760,7 +2765,7 @@ LNetCtl(unsigned int cmd, void *arg)
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_ni_peer_tx_credits,
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_tx_credits,
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_rtr_credits,
-			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_min_rtr_credits,
+			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_min_tx_credits,
 			&peer_info->pr_lnd_u.pr_peer_credits.cr_peer_tx_qnob);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 11edf3632405..6f6039189456 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -1127,7 +1127,8 @@ int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
 		lpni->lpni_net->net_tunables.lct_peer_tx_credits : 0;
 	peer_ni_info->cr_peer_tx_credits = lpni->lpni_txcredits;
 	peer_ni_info->cr_peer_rtr_credits = lpni->lpni_rtrcredits;
-	peer_ni_info->cr_peer_min_rtr_credits = lpni->lpni_mintxcredits;
+	peer_ni_info->cr_peer_min_rtr_credits = lpni->lpni_minrtrcredits;
+	peer_ni_info->cr_peer_min_tx_credits = lpni->lpni_mintxcredits;
 	peer_ni_info->cr_peer_tx_qnob = lpni->lpni_txqnob;
 
 	peer_ni_stats->send_count = atomic_read(&lpni->lpni_stats.send_count);
