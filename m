From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:39 +1100
Subject: [lustre-devel] [PATCH 26/28] lustre: ldlm: drop
 SLAB_TYPESAFE_BY_RCU from ldlm_lock slab.
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109902.31333.10192605039046886496.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

ldlm_locks are always freed with kfree_rcu(), so there is
no need for the underlying pages to also be freed after
a grace period.  So remove this flag, it is not useful.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index a9ca9a5e49be..bf2c3531b39b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -1128,8 +1128,7 @@ int ldlm_init(void)
 
 	ldlm_lock_slab = kmem_cache_create("ldlm_locks",
 					   sizeof(struct ldlm_lock), 0,
-					   SLAB_HWCACHE_ALIGN |
-					   SLAB_TYPESAFE_BY_RCU, NULL);
+					   SLAB_HWCACHE_ALIGN, NULL);
 	if (!ldlm_lock_slab)
 		goto out_resource;
 
