From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:47 -0500
Subject: [lustre-devel] [PATCH 419/622] lnet: Return EHOSTUNREACH for
 unreachable gateway
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-420-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Commit f1d0660a5bbe ("lnet: Do not allow gateways on remote nets")
contains a flaw in that it shouldn't be a fatal error to
encounter an unreachable gateway when parsing routes.  Parsing should
continue in case there are any valid, reachable routes that are being
added.  Returning EINAL here will cause a failure to load the LNet
module.  lnet_parse_route() explicitly allows for lnet_add_route() to
return EHOSTUNREACH for just this purpose.

Fixes: f1d0660a5bbe ("lnet: Do not allow gateways on remote nets")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12595
Lustre-commit: 7c12c24c8a10 ("LU-12595 lnet: Return EHOSTUNREACH for unreachable gateway")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35630
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 892164b..4ab587d 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -448,7 +448,7 @@ static void lnet_shuffle_seed(void)
 		CERROR("Cannot add route with gateway %s. There is no local interface configured on LNet %s\n",
 		       libcfs_nid2str(gateway),
 		       libcfs_net2str(LNET_NIDNET(gateway)));
-		return -EINVAL;
+		return -EHOSTUNREACH;
 	}
 
 	/* Assume net, route, all new */
-- 
1.8.3.1
