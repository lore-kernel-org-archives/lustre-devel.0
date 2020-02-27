From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:08 -0500
Subject: [lustre-devel] [PATCH 500/622] lnet: eliminate uninitialized warning
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-501-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

lustre-release/net/lnet/lnet/router.c: In funciton 'lnet_del_route':
include/linux/compiler.h:177:26: error: 'lp' may be used uninitialized
in this function [-Werror=maybe-uninitialized]
  case 8: *(__u64 *)res = *(volatile __u64 *)p; break;  \

lustre-release/net/lnet/lnet/router.c:754:20: note: 'lp' was declared here
  struct lnet_peer *lp;

lustre-release/net/lnet/lnet/router.c: At top level:
cc1: error: unrecognized command line option '-Wno-stringop-overflow' [-Werror]
cc1: error: unrecognized command line option '-Wno-stringop-truncation' [-Werror]
cc1: error: unrecognized command line option '-Wno-format-truncation' [-Werror]
cc1: all warnings being treated as errors

codes logic gurantee @lpi and @lpni are inited at the same time,
but let's init @lpi to make gcc happy.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12764
Lustre-commit: a8fbaa1b998f ("LU-12764 lnet: eliminate uninitialized warning")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/36189
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index a5e4af0..447706d 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -721,7 +721,7 @@ static void lnet_shuffle_seed(void)
 	struct lnet_peer_ni *lpni;
 	struct lnet_route *route;
 	struct list_head zombies;
-	struct lnet_peer *lp;
+	struct lnet_peer *lp = NULL;
 	int i = 0;
 
 	INIT_LIST_HEAD(&rnet_zombies);
-- 
1.8.3.1
