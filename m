From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:13 -0400
Subject: [lustre-devel] [PATCH 36/45] lnet: use kmem_cache_zalloc as
 appropriate.
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Rather than passing __GFP_ZERO to kmem_cache_alloc(), or calling
memset(0) after the allocation, use kmem_cache_zalloc().

kmem_cache_zalloc() has been part of Linux since 2.6.17.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 3ceed00b0458d ("LU-6142 kernel: use kmem_cache_zalloc as appropriate.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38439
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-me.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/lnet/lib-me.c b/net/lnet/lnet/lib-me.c
index 8a47405..14ab21f 100644
--- a/net/lnet/lnet/lib-me.c
+++ b/net/lnet/lnet/lib-me.c
@@ -87,7 +87,7 @@ struct lnet_me *
 	if (!mtable) /* can't match portal type */
 		return ERR_PTR(-EPERM);
 
-	me = kmem_cache_alloc(lnet_mes_cachep, GFP_NOFS | __GFP_ZERO);
+	me = kmem_cache_zalloc(lnet_mes_cachep, GFP_NOFS);
 	if (!me)
 		return ERR_PTR(-ENOMEM);
 
-- 
1.8.3.1
