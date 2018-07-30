From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:49:32 +1000
Subject: [lustre-devel] [PATCH 2/7] lustre/libcfs: fix freeing after kmalloc
 failure.
In-Reply-To: <153292249340.26496.13985174182824912332.stgit@noble>
References: <153292249340.26496.13985174182824912332.stgit@noble>
Message-ID: <153292257285.26496.5271671024215297861.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The new_bkts array is *not* zeroed (any more) so when
freeing recently allocated buckets on failure, we
must no free beyond the last bucket successfully
allocated.

Fixes: 12e46c461cb9 ("staging: lustre: change some LIBCFS_ALLOC calls to k?alloc(GFP_KERNEL)")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/hash.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 48be66f0d654..f452c4540ca1 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -904,7 +904,7 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
 		new_bkts[i] = kzalloc(cfs_hash_bkt_size(hs), GFP_KERNEL);
 		if (!new_bkts[i]) {
 			cfs_hash_buckets_free(new_bkts, cfs_hash_bkt_size(hs),
-					      old_size, new_size);
+					      old_size, i);
 			return NULL;
 		}
 
