From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 Nov 2015 13:39:57 -0500
Subject: [lustre-devel] [PATCH 01/10] staging: lustre: wrong parameter to
	cfs_hash_keycpy
Message-ID: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Liang Zhen <liang.zhen@intel.com>

cfs_hash_rehash_key() passed wrong parameter to cfs_hash_keycpy,
hnode should be the second parameter not the third one.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4362
Reviewed-on: http://review.whamcloud.com/8509
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
---
 drivers/staging/lustre/lustre/libcfs/hash.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 98c19b6..8800d64 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -2005,7 +2005,7 @@ void cfs_hash_rehash_key(struct cfs_hash *hs, const void *old_key,
 	}
 	/* overwrite key inside locks, otherwise may screw up with
 	 * other operations, i.e: rehash */
-	cfs_hash_keycpy(hs, new_key, hnode);
+	cfs_hash_keycpy(hs, hnode, new_key);
 
 	cfs_hash_multi_bd_unlock(hs, bds, 3, 1);
 	cfs_hash_unlock(hs, 0);
-- 
1.7.1
