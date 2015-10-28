From: James Simmons <jsimmons@infradead.org>
Date: Wed, 28 Oct 2015 12:54:25 -0400
Subject: [lustre-devel] [PATCH 04/10] staging: lustre: change
	cfs_hash_dhead*_t to struct
In-Reply-To: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446051271-25189-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Change cfs_hash_dhead_t and cfs_head_dhead_dep_to
from typedef to true structures.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    4 +-
 drivers/staging/lustre/lustre/libcfs/hash.c        |   40 +++++++++++---------
 2 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 200b760..805f298 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -90,8 +90,8 @@ union cfs_hash_lock {
  * - array of hash-head starting from hsb_head[0], hash-head can be one of
  *   . cfs_hash_head_t
  *   . cfs_hash_head_dep_t
- *   . cfs_hash_dhead_t
- *   . cfs_hash_dhead_dep_t
+ *   . struct cfs_hash_dhead
+ *   . struct cfs_hash_dhead_dep
  *   which depends on requirement of user
  * - some extra bytes (caller can require it while creating hash)
  */
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index f8026e1..575e8a8 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -321,23 +321,23 @@ cfs_hash_hd_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
  * double links hash head without depth tracking
  * new element is always added to tail of hlist
  */
-typedef struct {
+struct cfs_hash_dhead {
 	struct hlist_head	dh_head;	/**< entries list */
 	struct hlist_node       *dh_tail;	/**< the last entry */
-} cfs_hash_dhead_t;
+};
 
 static int
 cfs_hash_dh_hhead_size(struct cfs_hash *hs)
 {
-	return sizeof(cfs_hash_dhead_t);
+	return sizeof(struct cfs_hash_dhead);
 }
 
 static struct hlist_head *
 cfs_hash_dh_hhead(struct cfs_hash *hs, struct cfs_hash_bd *bd)
 {
-	cfs_hash_dhead_t *head;
+	struct cfs_hash_dhead *head;
 
-	head = (cfs_hash_dhead_t *)&bd->bd_bucket->hsb_head[0];
+	head = (struct cfs_hash_dhead *)&bd->bd_bucket->hsb_head[0];
 	return &head[bd->bd_offset].dh_head;
 }
 
@@ -345,9 +345,10 @@ static int
 cfs_hash_dh_hnode_add(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 		      struct hlist_node *hnode)
 {
-	cfs_hash_dhead_t *dh = container_of(cfs_hash_dh_hhead(hs, bd),
-					    cfs_hash_dhead_t, dh_head);
+	struct cfs_hash_dhead *dh;
 
+	dh = container_of(cfs_hash_dh_hhead(hs, bd),
+			  struct cfs_hash_dhead, dh_head);
 	if (dh->dh_tail != NULL) /* not empty */
 		hlist_add_behind(hnode, dh->dh_tail);
 	else /* empty list */
@@ -360,9 +361,10 @@ static int
 cfs_hash_dh_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 		      struct hlist_node *hnd)
 {
-	cfs_hash_dhead_t *dh = container_of(cfs_hash_dh_hhead(hs, bd),
-					    cfs_hash_dhead_t, dh_head);
+	struct cfs_hash_dhead *dh;
 
+	dh = container_of(cfs_hash_dh_hhead(hs, bd),
+			  struct cfs_hash_dhead, dh_head);
 	if (hnd->next == NULL) { /* it's the tail */
 		dh->dh_tail = (hnd->pprev == &dh->dh_head.first) ? NULL :
 			      container_of(hnd->pprev, struct hlist_node, next);
@@ -375,24 +377,24 @@ cfs_hash_dh_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
  * double links hash head with depth tracking
  * new element is always added to tail of hlist
  */
-typedef struct {
+struct cfs_hash_dhead_dep {
 	struct hlist_head	dd_head;	/**< entries list */
 	struct hlist_node       *dd_tail;	/**< the last entry */
 	unsigned int	    dd_depth;       /**< list length */
-} cfs_hash_dhead_dep_t;
+};
 
 static int
 cfs_hash_dd_hhead_size(struct cfs_hash *hs)
 {
-	return sizeof(cfs_hash_dhead_dep_t);
+	return sizeof(struct cfs_hash_dhead_dep);
 }
 
 static struct hlist_head *
 cfs_hash_dd_hhead(struct cfs_hash *hs, struct cfs_hash_bd *bd)
 {
-	cfs_hash_dhead_dep_t *head;
+	struct cfs_hash_dhead_dep *head;
 
-	head = (cfs_hash_dhead_dep_t *)&bd->bd_bucket->hsb_head[0];
+	head = (struct cfs_hash_dhead_dep *)&bd->bd_bucket->hsb_head[0];
 	return &head[bd->bd_offset].dd_head;
 }
 
@@ -400,9 +402,10 @@ static int
 cfs_hash_dd_hnode_add(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 		      struct hlist_node *hnode)
 {
-	cfs_hash_dhead_dep_t *dh = container_of(cfs_hash_dd_hhead(hs, bd),
-						cfs_hash_dhead_dep_t, dd_head);
+	struct cfs_hash_dhead_dep *dh;
 
+	dh = container_of(cfs_hash_dd_hhead(hs, bd),
+			  struct cfs_hash_dhead_dep, dd_head);
 	if (dh->dd_tail != NULL) /* not empty */
 		hlist_add_behind(hnode, dh->dd_tail);
 	else /* empty list */
@@ -415,9 +418,10 @@ static int
 cfs_hash_dd_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 		      struct hlist_node *hnd)
 {
-	cfs_hash_dhead_dep_t *dh = container_of(cfs_hash_dd_hhead(hs, bd),
-						cfs_hash_dhead_dep_t, dd_head);
+	struct cfs_hash_dhead_dep *dh;
 
+	dh = container_of(cfs_hash_dd_hhead(hs, bd),
+			  struct cfs_hash_dhead_dep, dd_head);
 	if (hnd->next == NULL) { /* it's the tail */
 		dh->dd_tail = (hnd->pprev == &dh->dd_head.first) ? NULL :
 			      container_of(hnd->pprev, struct hlist_node, next);
-- 
1.7.1
