From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:19 -0500
Subject: [lustre-devel] [PATCH 571/622] lnet: Avoid comparing route to itself
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-572-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

The first iteration of the route selection loop compares the first
route in the list with itself.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12756
Lustre-commit: 2b8d9d12d182 ("LU-12756 lnet: Avoid comparing route to itself")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36535
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index c8266f0..45975d6 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1354,6 +1354,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			best_route = route;
 			last_route = route;
 			lp_best = lp;
+			best_gw_ni = lnet_find_best_lpni_on_net(NULL,
+								LNET_NID_ANY,
+								route->lr_gateway,
+								route->lr_lnet);
+			LASSERT(best_gw_ni);
+			continue;
 		}
 
 		/* no protection on below fields, but it's harmless */
-- 
1.8.3.1
