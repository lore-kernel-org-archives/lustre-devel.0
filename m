From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:03 -0400
Subject: [lustre-devel] [PATCH 11/31] lustre: lnet: Fix route hops print
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

The default number of hops for  a route is -1. This is
currently being printed as %u. Change that to %d to
make it print out properly.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-id: https://jira.whamcloud.com/browse/LU-9078
Reviewed-on: https://review.whamcloud.com/25250
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/router_proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 8856798..aa98ce5 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -218,7 +218,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 			int alive = lnet_is_route_alive(route);
 
 			s += snprintf(s, tmpstr + tmpsiz - s,
-				      "%-8s %4u %8u %7s %s\n",
+				      "%-8s %4d %8u %7s %s\n",
 				      libcfs_net2str(net), hops,
 				      priority,
 				      alive ? "up" : "down",
-- 
1.8.3.1
