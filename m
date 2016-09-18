From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:59 -0400
Subject: [lustre-devel] [PATCH 120/124] staging: lustre: lnet: check if ni
	is in current net namespace
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-121-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sbuisson@ddn.com>

Add new 'ni_net_ns' field to struct lnet_ni to hold a reference
to original net namespace in which ni is created.
In LNetDist(), check if ni was created in same net namespace as
current's one. If not, assign order above 0xffff0000, to make
this ni not a priority.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7845
Reviewed-on: http://review.whamcloud.com/21884
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 ++
 drivers/staging/lustre/lnet/lnet/config.c          |   14 ++++++++++++++
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   11 +++++++++++
 3 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 640ff72..b84a5bb 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -275,6 +275,8 @@ typedef struct lnet_ni {
 	struct lnet_ioctl_config_lnd_tunables *ni_lnd_tunables;
 	/* equivalent interfaces to use */
 	char			 *ni_interfaces[LNET_MAX_INTERFACES];
+	/* original net namespace */
+	struct net		 *ni_net_ns;
 } lnet_ni_t;
 
 #define LNET_PROTO_PING_MATCHBITS	0x8000000000000000LL
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index a72afdf..9e2183f 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -31,6 +31,8 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
 #include "../../include/linux/lnet/lib-lnet.h"
 
 struct lnet_text_buf {	    /* tmp struct for parsing routes */
@@ -110,6 +112,11 @@ lnet_ni_free(struct lnet_ni *ni)
 		LIBCFS_FREE(ni->ni_interfaces[i],
 			    strlen(ni->ni_interfaces[i]) + 1);
 	}
+
+	/* release reference to net namespace */
+	if (ni->ni_net_ns)
+		put_net(ni->ni_net_ns);
+
 	LIBCFS_FREE(ni, sizeof(*ni));
 }
 
@@ -171,6 +178,13 @@ lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
 
 	/* LND will fill in the address part of the NID */
 	ni->ni_nid = LNET_MKNID(net, 0);
+
+	/* Store net namespace in which current ni is being created */
+	if (current->nsproxy->net_ns)
+		ni->ni_net_ns = get_net(current->nsproxy->net_ns);
+	else
+		ni->ni_net_ns = NULL;
+
 	ni->ni_last_alive = ktime_get_real_seconds();
 	list_add_tail(&ni->ni_list, nilist);
 	return ni;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index f89c9fe..48e6f8f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -37,6 +37,8 @@
 #define DEBUG_SUBSYSTEM S_LNET
 
 #include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
 
 static int local_nid_dist_zero = 1;
 module_param(local_nid_dist_zero, int, 0444);
@@ -2320,6 +2322,15 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
 		}
 
 		if (LNET_NIDNET(ni->ni_nid) == dstnet) {
+			/*
+			 * Check if ni was originally created in
+			 * current net namespace.
+			 * If not, assign order above 0xffff0000,
+			 * to make this ni not a priority.
+			 */
+			if (!net_eq(ni->ni_net_ns, current->nsproxy->net_ns))
+				order += 0xffff0000;
+
 			if (srcnidp)
 				*srcnidp = ni->ni_nid;
 			if (orderp)
-- 
1.7.1
