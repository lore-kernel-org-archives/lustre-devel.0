From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:57 -0500
Subject: [lustre-devel] [PATCH 429/622] lnet: create existing net returns
 EEXIST
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-430-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Faaland <faaland1@llnl.gov>

When "lnetctl net add" is called for an interface/net pair that
already exists, the error returned should be EEXIST, so the
user knows that the net is already configured.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12626
Lustre-commit: 4aa71267cc03 ("LU-12626 lnet: create existing net returns EEXIST")
Signed-off-by: Olaf Faaland <faaland1@llnl.gov>
Reviewed-on: https://review.whamcloud.com/35681
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index e773839..79deaac 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2301,7 +2301,7 @@ static void lnet_push_target_fini(void)
 		 * up is actually unique. if it's not fail. */
 		if (!lnet_ni_unique_net(&net_l->net_ni_list,
 					ni->ni_interfaces[0])) {
-			rc = -EINVAL;
+			rc = -EEXIST;
 			goto failed1;
 		}
 
-- 
1.8.3.1
