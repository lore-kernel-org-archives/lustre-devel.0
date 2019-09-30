From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:41 -0400
Subject: [lustre-devel] [PATCH 142/151] lustre: ldlm: Remove use of
 SLAB_DESTROY_BY_RCU for ldlm lock slab
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-143-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

ldlm_locks are always freed with kfree_rcu(), so there is
no need for the underlying pages to also be freed after
a grace period.  So remove this flag, it is not useful.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11568
Lustre-commit: 82d014e71e14 ("LU-11568 ldlm: Remove use of SLAB_DESTROY_BY_RCU for ldlm lock slab")
Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34147
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lockd.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 7e1ae0c..6ad2c1a 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -1115,8 +1115,7 @@ int ldlm_init(void)
 
 	ldlm_lock_slab = kmem_cache_create("ldlm_locks",
 					   sizeof(struct ldlm_lock), 0,
-					   SLAB_HWCACHE_ALIGN |
-					   SLAB_TYPESAFE_BY_RCU, NULL);
+					   SLAB_HWCACHE_ALIGN, NULL);
 	if (!ldlm_lock_slab)
 		goto out_resource;
 
-- 
1.8.3.1
