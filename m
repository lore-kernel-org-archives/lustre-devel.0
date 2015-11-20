From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:15 -0500
Subject: [lustre-devel] [PATCH 39/40] staging: lustre: Use
	lnet_is_route_alive for router aliveness
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

lctl show_route and lctl route_list will output router aliveness
information via lnet_get_route(). lnet_get_route() should use the
lnet_is_route_alive() function, introduced in e8a1124
http://review.whamcloud.com/7857, to determine route aliveness.

Signed-off-by: Chris Horn <hornc@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5733
Reviewed-on: http://review.whamcloud.com/14055
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/router.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 35cfced..83d233b 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -611,8 +611,7 @@ lnet_get_route(int idx, __u32 *net, __u32 *hops,
 					*hops     = route->lr_hops;
 					*priority = route->lr_priority;
 					*gateway  = route->lr_gateway->lp_nid;
-					*alive = route->lr_gateway->lp_alive &&
-						 !route->lr_downis;
+					*alive = lnet_is_route_alive(route);
 					lnet_net_unlock(cpt);
 					return 0;
 				}
-- 
1.7.1
