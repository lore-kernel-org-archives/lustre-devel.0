From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:15 -0400
Subject: [lustre-devel] [PATCH 116/151] lnet: Remove LASSERT on userspace
 data
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-117-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sharmaso@whamcloud.com>

If the net information is not provided while adding
NI, it results in an LBUG. Remove the LASSERT on
userspace input and handle it gracefully.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10554
Lustre-commit: 8059dbbe97a6 ("LU-10554 lnet: Remove LASSERT on userspace data")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31100
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 6e29714..fc4fe5d 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1816,8 +1816,6 @@ static void lnet_push_target_fini(void)
 	if (lnet_net_unique(net->net_id, &the_lnet.ln_nets, &net_l)) {
 		lnd_type = LNET_NETTYP(net->net_id);
 
-		LASSERT(libcfs_isknown_lnd(lnd_type));
-
 		mutex_lock(&the_lnet.ln_lnd_mutex);
 		lnd = lnet_find_lnd_by_type(lnd_type);
 
@@ -2715,7 +2713,7 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 	struct lnet_ni *ni;
 	struct lnet_ioctl_config_lnd_tunables *tun = NULL;
 	int rc, i;
-	u32 net_id;
+	u32 net_id, lnd_type;
 
 	/* get the tunables if they are available */
 	if (conf->lic_cfg_hdr.ioc_len >=
@@ -2729,6 +2727,12 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 						  tun);
 
 	net_id = LNET_NIDNET(conf->lic_nid);
+	lnd_type = LNET_NETTYP(net_id);
+
+	if (!libcfs_isknown_lnd(lnd_type)) {
+		CERROR("No valid net and lnd information provided\n");
+		return -EINVAL;
+	}
 
 	net = lnet_net_alloc(net_id, NULL);
 	if (!net)
-- 
1.8.3.1
