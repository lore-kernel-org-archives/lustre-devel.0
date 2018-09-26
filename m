From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:04 -0400
Subject: [lustre-devel] [PATCH 12/25] lustre: lnet: correct locking in
 legacy add net
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Make sure to unlock the api mutex properly
in lnet_dyn_add_net()

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9729
Reviewed-on: https://review.whamcloud.com/27907
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 7c907a3..b37abde 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2435,7 +2435,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 
 	if (rc > 1) {
 		rc = -EINVAL; /* only add one network per call */
-		goto failed;
+		goto out_unlock_clean;
 	}
 
 	net = list_entry(net_head.next, struct lnet_net, net_list);
@@ -2455,14 +2455,11 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		conf->cfg_config_u.cfg_net.net_max_tx_credits;
 
 	rc = lnet_add_net_common(net, &tun);
-	if (rc != 0)
-		goto failed;
 
-	return 0;
-
-failed:
+out_unlock_clean:
 	mutex_unlock(&the_lnet.ln_api_mutex);
 	while (!list_empty(&net_head)) {
+		/* net_head list is empty in success case */
 		net = list_entry(net_head.next, struct lnet_net, net_list);
 		list_del_init(&net->net_list);
 		lnet_net_free(net);
-- 
1.8.3.1
