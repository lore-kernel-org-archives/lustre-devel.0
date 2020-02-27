From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:21 -0500
Subject: [lustre-devel] [PATCH 093/622] lnet: set health value from user
 space
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-94-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Collect debugging information for ioctl setting manually health
value. Test if a peer is returned by lnet_find_peer_ni_locked()
when lnet_get_peer_info() is called. This was discovered when
the user land tools were updated for setting the health value.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: c0ad398fd716 ("LU-9120 lnet: set health value from user space")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32863
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 6 ++++++
 net/lnet/lnet/peer.c   | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 1ee24c7..82703dd 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3526,6 +3526,12 @@ u32 lnet_get_dlc_seq_locked(void)
 			value = LNET_MAX_HEALTH_VALUE;
 		else
 			value = cfg->rh_value;
+		CDEBUG(D_NET,
+		       "Manually setting healthv to %d for %s:%s. all = %d\n",
+		       value,
+		       (cfg->rh_type == LNET_HEALTH_TYPE_LOCAL_NI) ?
+		       "local" : "peer",
+		       libcfs_nid2str(cfg->rh_nid), cfg->rh_all);
 		mutex_lock(&the_lnet.ln_api_mutex);
 		if (cfg->rh_type == LNET_HEALTH_TYPE_LOCAL_NI)
 			lnet_ni_set_healthv(cfg->rh_nid, value,
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index b20230b..2fc5dfc 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3484,6 +3484,10 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	if (!all) {
 		lnet_net_lock(LNET_LOCK_EX);
 		lpni = lnet_find_peer_ni_locked(nid);
+		if (!lpni) {
+			lnet_net_unlock(LNET_LOCK_EX);
+			return;
+		}
 		atomic_set(&lpni->lpni_healthv, value);
 		lnet_peer_ni_add_to_recoveryq_locked(lpni);
 		lnet_peer_ni_decref_locked(lpni);
-- 
1.8.3.1
