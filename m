From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:24 -0500
Subject: [lustre-devel] [PATCH 23/24] staging: lustre: Use
	lnet_is_route_alive for router aliveness
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Chris Horn <hornc@cray.com>

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
index 198ff03..5a6086b 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -607,8 +607,7 @@ lnet_get_route(int idx, __u32 *net, __u32 *hops,
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
