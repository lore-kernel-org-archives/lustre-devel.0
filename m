From: James Simmons <jsimmons@infradead.org>
Date: Wed, 28 Oct 2015 12:54:27 -0400
Subject: [lustre-devel] [PATCH 06/10] staging: lustre: convert last typedef
	data types in hash.c
In-Reply-To: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446051271-25189-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Change the last typedef data types cfs_hash_lookup_intent_t
to enum and cfs_hash_cond_arg_t to a structure.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/libcfs/hash.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index c267f8a..0308744 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -606,7 +606,7 @@ enum {
 	CFS_HS_LOOKUP_MASK_DEL      = BIT(3),
 };
 
-typedef enum cfs_hash_lookup_intent {
+enum cfs_hash_lookup_intent {
 	/** return item w/o refcount */
 	CFS_HS_LOOKUP_IT_PEEK       = CFS_HS_LOOKUP_MASK_FIND,
 	/** return item with refcount */
@@ -621,12 +621,12 @@ typedef enum cfs_hash_lookup_intent {
 	/** delete if existed */
 	CFS_HS_LOOKUP_IT_FINDDEL    = (CFS_HS_LOOKUP_MASK_FIND |
 				       CFS_HS_LOOKUP_MASK_DEL)
-} cfs_hash_lookup_intent_t;
+};
 
 static struct hlist_node *
 cfs_hash_bd_lookup_intent(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			  const void *key, struct hlist_node *hnode,
-			  cfs_hash_lookup_intent_t intent)
+			  enum cfs_hash_lookup_intent intent)
 
 {
 	struct hlist_head  *hhead = cfs_hash_bd_hhead(hs, bd);
@@ -1489,16 +1489,16 @@ cfs_hash_for_each_tight(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 	return count;
 }
 
-typedef struct {
-	cfs_hash_cond_opt_cb_t  func;
-	void		   *arg;
-} cfs_hash_cond_arg_t;
+struct cfs_hash_cond_arg {
+	cfs_hash_cond_opt_cb_t	func;
+	void			*arg;
+};
 
 static int
 cfs_hash_cond_del_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			 struct hlist_node *hnode, void *data)
 {
-	cfs_hash_cond_arg_t *cond = data;
+	struct cfs_hash_cond_arg *cond = data;
 
 	if (cond->func(cfs_hash_object(hs, hnode), cond->arg))
 		cfs_hash_bd_del_locked(hs, bd, hnode);
@@ -1513,7 +1513,7 @@ cfs_hash_cond_del_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 void
 cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t func, void *data)
 {
-	cfs_hash_cond_arg_t arg = {
+	struct cfs_hash_cond_arg arg = {
 		.func   = func,
 		.arg    = data,
 	};
-- 
1.7.1
