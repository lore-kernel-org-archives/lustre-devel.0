From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:51:11 -0400
Subject: [lustre-devel] [PATCH v2 29/29] lustre: ldlm: drop
 SLAB_TYPESAFE_BY_RCU from ldlm_lock slab.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

ldlm_locks are always freed with kfree_rcu(), so there is
no need for the underlying pages to also be freed after
a grace period.  So remove this flag, it is not useful.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/ldlm/ldlm_lockd.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index ea87fd6..4a15065 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -1129,8 +1129,7 @@ int ldlm_init(void)
 
 	ldlm_lock_slab = kmem_cache_create("ldlm_locks",
 					   sizeof(struct ldlm_lock), 0,
-					   SLAB_HWCACHE_ALIGN |
-					   SLAB_TYPESAFE_BY_RCU, NULL);
+					   SLAB_HWCACHE_ALIGN, NULL);
 	if (!ldlm_lock_slab)
 		goto out_resource;
 
-- 
1.8.3.1
