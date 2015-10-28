From: James Simmons <jsimmons@infradead.org>
Date: Wed, 28 Oct 2015 12:54:23 -0400
Subject: [lustre-devel] [PATCH 02/10] staging: lustre: change
	cfs_hash_hlist_ops_t to struct
In-Reply-To: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446051271-25189-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Change cfs_hash_hlist_ops_t to struct cfs_hash_hlist_ops.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    4 ++--
 drivers/staging/lustre/lustre/libcfs/hash.c        |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 778feb6..6ac54a0 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -283,7 +283,7 @@ struct cfs_hash_lock_ops {
 	void    (*hs_bkt_unlock)(union cfs_hash_lock *lock, int exclusive);
 };
 
-typedef struct cfs_hash_hlist_ops {
+struct cfs_hash_hlist_ops {
 	/** return hlist_head of hash-head of @bd */
 	struct hlist_head *(*hop_hhead)(struct cfs_hash *hs, struct cfs_hash_bd *bd);
 	/** return hash-head size */
@@ -294,7 +294,7 @@ typedef struct cfs_hash_hlist_ops {
 	/** remove @hnode from hash-head of @bd */
 	int (*hop_hnode_del)(struct cfs_hash *hs,
 			     struct cfs_hash_bd *bd, struct hlist_node *hnode);
-} cfs_hash_hlist_ops_t;
+};
 
 typedef struct cfs_hash_ops {
 	/** return hashed value from @key */
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index b78feb0..63c4434 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -426,28 +426,28 @@ cfs_hash_dd_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 	return --dh->dd_depth;
 }
 
-static cfs_hash_hlist_ops_t cfs_hash_hh_hops = {
+static struct cfs_hash_hlist_ops cfs_hash_hh_hops = {
 	.hop_hhead      = cfs_hash_hh_hhead,
 	.hop_hhead_size = cfs_hash_hh_hhead_size,
 	.hop_hnode_add  = cfs_hash_hh_hnode_add,
 	.hop_hnode_del  = cfs_hash_hh_hnode_del,
 };
 
-static cfs_hash_hlist_ops_t cfs_hash_hd_hops = {
+static struct cfs_hash_hlist_ops cfs_hash_hd_hops = {
 	.hop_hhead      = cfs_hash_hd_hhead,
 	.hop_hhead_size = cfs_hash_hd_hhead_size,
 	.hop_hnode_add  = cfs_hash_hd_hnode_add,
 	.hop_hnode_del  = cfs_hash_hd_hnode_del,
 };
 
-static cfs_hash_hlist_ops_t cfs_hash_dh_hops = {
+static struct cfs_hash_hlist_ops cfs_hash_dh_hops = {
 	.hop_hhead      = cfs_hash_dh_hhead,
 	.hop_hhead_size = cfs_hash_dh_hhead_size,
 	.hop_hnode_add  = cfs_hash_dh_hnode_add,
 	.hop_hnode_del  = cfs_hash_dh_hnode_del,
 };
 
-static cfs_hash_hlist_ops_t cfs_hash_dd_hops = {
+static struct cfs_hash_hlist_ops cfs_hash_dd_hops = {
 	.hop_hhead      = cfs_hash_dd_hhead,
 	.hop_hhead_size = cfs_hash_dd_hhead_size,
 	.hop_hnode_add  = cfs_hash_dd_hnode_add,
-- 
1.7.1
