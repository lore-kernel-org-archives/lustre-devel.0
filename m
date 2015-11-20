From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:05 -0500
Subject: [lustre-devel] [PATCH 29/40] staging: lustre: handle
	lnet_check_routes() errors
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

After adding a route, lnet_check_routes() is called to ensure that
the route added doesn't invalidate the routing configuration.  If
lnet_check_routes() fails then the route just added, which caused the
current configuration to be invalidated is deleted, and an error
is returned to the user.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6218
Reviewed-on: http://review.whamcloud.com/13445
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index ed167c8..b119c6c 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1910,8 +1910,14 @@ LNetCtl(unsigned int cmd, void *arg)
 				    config->cfg_nid,
 				    config->cfg_config_u.cfg_route.
 					rtr_priority);
+		if (rc == 0) {
+			rc = lnet_check_routes();
+			if (rc != 0)
+				lnet_del_route(config->cfg_net,
+					       config->cfg_nid);
+		}
 		mutex_unlock(&the_lnet.ln_api_mutex);
-		return (rc != 0) ? rc : lnet_check_routes();
+		return rc;
 
 	case IOC_LIBCFS_DEL_ROUTE:
 		config = arg;
-- 
1.7.1
