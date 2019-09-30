From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:43 -0400
Subject: [lustre-devel] [PATCH 024/151] lnet: Fix lost lock
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

Unlock lnet_net_lock in case of error in function lnet_dyn_del_net().

WC-bug-id: https://jira.whamcloud.com/browse/LU-9769
Lustre-commit: 9761b5c63103 ("LU-9769 lnet: Fix lost lock")
Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-on: https://review.whamcloud.com/28039
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index c33cd1f..47f4f2a 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2906,6 +2906,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 
 	net = lnet_get_net_locked(net_id);
 	if (!net) {
+		lnet_net_unlock(0);
 		rc = -EINVAL;
 		goto out;
 	}
-- 
1.8.3.1
