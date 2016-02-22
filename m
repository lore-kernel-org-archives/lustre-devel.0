From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:15 -0500
Subject: [lustre-devel] [PATCH 14/24] staging: lustre: handle
	lnet_check_routes() errors
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

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
index ccd7dcd..ed121a8 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1907,8 +1907,14 @@ LNetCtl(unsigned int cmd, void *arg)
 				    config->cfg_config_u.cfg_route.rtr_hop,
 				    config->cfg_nid,
 				    config->cfg_config_u.cfg_route.rtr_priority);
+		if (!rc) {
+			rc = lnet_check_routes();
+			if (rc)
+				lnet_del_route(config->cfg_net,
+					       config->cfg_nid);
+		}
 		mutex_unlock(&the_lnet.ln_api_mutex);
-		return rc ? rc : lnet_check_routes();
+		return rc;
 
 	case IOC_LIBCFS_DEL_ROUTE:
 		config = arg;
-- 
1.7.1
