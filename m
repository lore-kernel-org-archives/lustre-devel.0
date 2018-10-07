From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:38 +1100
Subject: [lustre-devel] [PATCH 23/24] lustre: lnet: show peer state
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437844.16383.527689917065770648.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

It is important to show the peer state when debugging.
This patch exports the peer state from the kernel to
user space, and is shown when the detail level requested
in the peer show command is >= 3

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/26130
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    4 +---
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    6 +-----
 drivers/staging/lustre/lnet/lnet/peer.c            |   21 ++++++++++----------
 3 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 91980f60a50d..fcfd844e0162 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -733,9 +733,7 @@ bool lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni, lnet_nid_t nid);
 int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
 int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
 int lnet_del_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid);
-int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nid,
-		       __u32 *nnis, bool *mr, __u32 *sizep,
-		       void __user *bulk);
+int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk);
 int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 			  char alivness[LNET_MAX_STR_LEN],
 			  __u32 *cpt_iter, __u32 *refcount,
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 0852118bf803..e2c86b8279e5 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -3166,11 +3166,7 @@ LNetCtl(unsigned int cmd, void *arg)
 			return -EINVAL;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_get_peer_info(&cfg->prcfg_prim_nid,
-					&cfg->prcfg_cfg_nid,
-					&cfg->prcfg_count,
-					&cfg->prcfg_mr,
-					&cfg->prcfg_size,
+		rc = lnet_get_peer_info(cfg,
 					(void __user *)cfg->prcfg_bulk);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 03c1c34517e4..5f61fca09f44 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -3296,9 +3296,7 @@ lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
 }
 
 /* ln_api_mutex is held, which keeps the peer list stable */
-int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nidp,
-		       __u32 *nnis, bool *mr, __u32 *sizep,
-		       void __user *bulk)
+int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 {
 	struct lnet_ioctl_element_stats *lpni_stats;
 	struct lnet_ioctl_element_msg_stats *lpni_msg_stats;
@@ -3309,7 +3307,7 @@ int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nidp,
 	__u32 size;
 	int rc;
 
-	lp = lnet_find_peer(*primary_nid);
+	lp = lnet_find_peer(cfg->prcfg_prim_nid);
 
 	if (!lp) {
 		rc = -ENOENT;
@@ -3319,17 +3317,18 @@ int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nidp,
 	size = sizeof(nid) + sizeof(*lpni_info) + sizeof(*lpni_stats)
 		+ sizeof(*lpni_msg_stats);
 	size *= lp->lp_nnis;
-	if (size > *sizep) {
-		*sizep = size;
+	if (size > cfg->prcfg_size) {
+		cfg->prcfg_size = size;
 		rc = -E2BIG;
 		goto out_lp_decref;
 	}
 
-	*primary_nid = lp->lp_primary_nid;
-	*mr = lnet_peer_is_multi_rail(lp);
-	*nidp = lp->lp_primary_nid;
-	*nnis = lp->lp_nnis;
-	*sizep = size;
+	cfg->prcfg_prim_nid = lp->lp_primary_nid;
+	cfg->prcfg_mr = lnet_peer_is_multi_rail(lp);
+	cfg->prcfg_cfg_nid = lp->lp_primary_nid;
+	cfg->prcfg_count = lp->lp_nnis;
+	cfg->prcfg_size = size;
+	cfg->prcfg_state = lp->lp_state;
 
 	/* Allocate helper buffers. */
 	rc = -ENOMEM;
