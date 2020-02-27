From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:08 -0500
Subject: [lustre-devel] [PATCH 440/622] lustre: llite: Mark
 lustre_inode_cache as reclaimable
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-441-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jacek Tomaka <jacek.tomaka@poczta.fm>

This is required for proper kernel memory available accounting.
Without it memory allocated to lustre_inode_cache appears as
SUnreclaim where in reality it should apper as SReclaimable.
This affect MemAvailable as well (it is lower than it should be).

WC-bug-id: https://jira.whamcloud.com/browse/LU-12313
Lustre-commit: b09e63db24e5 ("LU-12313 llite: Mark lustre_inode_cache as reclaimable")
Signed-off-by: Jacek Tomaka <jacek.tomaka@poczta.fm>
Reviewed-on: https://review.whamcloud.com/35790
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Neil Brown <neilb@suse.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/super25.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index afd51a6..38d60b0 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -211,7 +211,11 @@ static int __init lustre_init(void)
 	rc = -ENOMEM;
 	ll_inode_cachep = kmem_cache_create("lustre_inode_cache",
 					    sizeof(struct ll_inode_info), 0,
-					    SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT,
+					    SLAB_HWCACHE_ALIGN |
+					    SLAB_RECLAIM_ACCOUNT |
+					    SLAB_ACCOUNT |
+					    SLAB_MEM_SPREAD |
+					    SLAB_ACCOUNT,
 					    NULL);
 	if (!ll_inode_cachep)
 		goto out_cache;
-- 
1.8.3.1
