From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:45 -0500
Subject: [lustre-devel] [PATCH 417/622] lnet: Deprecate live and dead router
 check params
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-418-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Rather than delete these params let's deprecate them for one release
and print a warning to console if the user is setting them.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12492
Lustre-commit: fca1a999899a ("LU-12492 lnet: Deprecate live and dead router check params")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35387
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 2 ++
 net/lnet/lnet/module.c        | 4 ++++
 net/lnet/lnet/router.c        | 8 ++++++++
 3 files changed, 14 insertions(+)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 3dd56a2..dd0075b 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -501,6 +501,8 @@ struct lnet_ni *
 extern unsigned int lnet_drop_asym_route;
 extern unsigned int router_sensitivity_percentage;
 extern int alive_router_check_interval;
+extern int live_router_check_interval;
+extern int dead_router_check_interval;
 extern int portal_rotor;
 
 int lnet_lib_init(void);
diff --git a/net/lnet/lnet/module.c b/net/lnet/lnet/module.c
index 5905f38..939c255 100644
--- a/net/lnet/lnet/module.c
+++ b/net/lnet/lnet/module.c
@@ -245,6 +245,10 @@ static int __init lnet_init(void)
 		return rc;
 	}
 
+	if (live_router_check_interval != INT_MIN ||
+	    dead_router_check_interval != INT_MIN)
+		LCONSOLE_WARN("live_router_check_interval and dead_router_check_interval have been deprecated. Use alive_router_check_interval instead. Ignoring these deprecated parameters.\n");
+
 	rc = blocking_notifier_chain_register(&libcfs_ioctl_list,
 					      &lnet_ioctl_handler);
 	LASSERT(!rc);
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index eb76c72..892164b 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -78,6 +78,14 @@
 module_param(avoid_asym_router_failure, int, 0644);
 MODULE_PARM_DESC(avoid_asym_router_failure, "Avoid asymmetrical router failures (0 to disable)");
 
+int dead_router_check_interval = INT_MIN;
+module_param(dead_router_check_interval, int, 0444);
+MODULE_PARM_DESC(dead_router_check_interval, "(DEPRECATED - Use alive_router_check_interval)");
+
+int live_router_check_interval = INT_MIN;
+module_param(live_router_check_interval, int, 0444);
+MODULE_PARM_DESC(live_router_check_interval, "(DEPRECATED - Use alive_router_check_interval)");
+
 int alive_router_check_interval = 60;
 module_param(alive_router_check_interval, int, 0644);
 MODULE_PARM_DESC(alive_router_check_interval, "Seconds between live router health checks (<= 0 to disable)");
-- 
1.8.3.1
