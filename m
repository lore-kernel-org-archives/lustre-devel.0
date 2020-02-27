From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:22 -0500
Subject: [lustre-devel] [PATCH 334/622] lnet: router sensitivity
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-335-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Introduce the router_sensitivity_percentage module parameter to
control the sensitivity of routers to failures. It defaults to 100%
which means a router interface needs to be fully healthy in order
to be used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11300
Lustre-commit: 2b59dae54efc ("LU-11300 lnet: router sensitivity")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33449
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 +
 net/lnet/lnet/router.c        | 50 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 80f6f8c..eae55d5 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -505,6 +505,7 @@ struct lnet_ni *
 extern unsigned int lnet_recovery_interval;
 extern unsigned int lnet_peer_discovery_disabled;
 extern unsigned int lnet_drop_asym_route;
+extern unsigned int router_sensitivity_percentage;
 extern int portal_rotor;
 
 int lnet_lib_init(void);
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 8374ce1..40725d2 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -90,6 +90,56 @@
 module_param(router_ping_timeout, int, 0644);
 MODULE_PARM_DESC(router_ping_timeout, "Seconds to wait for the reply to a router health query");
 
+/* A value between 0 and 100. 0 meaning that even if router's interfaces
+ * have the worse health still consider the gateway usable.
+ * 100 means that at least one interface on the route's remote net is 100%
+ * healthy to consider the route alive.
+ * The default is set to 100 to ensure we maintain the original behavior.
+ */
+unsigned int router_sensitivity_percentage = 100;
+static int rtr_sensitivity_set(const char *val,
+			       const struct kernel_param *kp);
+static struct kernel_param_ops param_ops_rtr_sensitivity = {
+	.set = rtr_sensitivity_set,
+	.get = param_get_int,
+};
+
+#define param_check_rtr_sensitivity(name, p) \
+	__param_check(name, p, int)
+module_param(router_sensitivity_percentage, rtr_sensitivity, 0644);
+MODULE_PARM_DESC(router_sensitivity_percentage,
+		 "How healthy a gateway should be to be used in percent");
+
+static int
+rtr_sensitivity_set(const char *val, const struct kernel_param *kp)
+{
+	int rc;
+	unsigned int *sen = (unsigned int *)kp->arg;
+	unsigned long value;
+
+	rc = kstrtoul(val, 0, &value);
+	if (rc) {
+		CERROR("Invalid module parameter value for 'router_sensitivity_percentage'\n");
+		return rc;
+	}
+
+	if (value < 0 || value > 100) {
+		CERROR("Invalid value: %lu for 'router_sensitivity_percentage'\n", value);
+		return -EINVAL;
+	}
+
+	/* The purpose of locking the api_mutex here is to ensure that
+	 * the correct value ends up stored properly.
+	 */
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	*sen = value;
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	return 0;
+}
+
 int
 lnet_peers_start_down(void)
 {
-- 
1.8.3.1
