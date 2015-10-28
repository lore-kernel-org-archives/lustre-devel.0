From: James Simmons <jsimmons@infradead.org>
Date: Wed, 28 Oct 2015 12:54:26 -0400
Subject: [lustre-devel] [PATCH 05/10] staging: lustre: change
	cfs_hash_head*_t to struct
In-Reply-To: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446051271-25189-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Change cfs_hash_head_t and cfs_head_head_dep_t
from typedef to true structures.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    4 +-
 drivers/staging/lustre/lustre/libcfs/hash.c        |   33 +++++++++++--------
 2 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 805f298..c9f550e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -88,8 +88,8 @@ union cfs_hash_lock {
  * cfs_hash_bucket is a container of:
  * - lock, counter ...
  * - array of hash-head starting from hsb_head[0], hash-head can be one of
- *   . cfs_hash_head_t
- *   . cfs_hash_head_dep_t
+ *   . struct cfs_hash_head
+ *   . struct cfs_hash_head_dep
  *   . struct cfs_hash_dhead
  *   . struct cfs_hash_dhead_dep
  *   which depends on requirement of user
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 575e8a8..c267f8a 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -239,21 +239,22 @@ cfs_hash_lock_setup(struct cfs_hash *hs)
  * Simple hash head without depth tracking
  * new element is always added to head of hlist
  */
-typedef struct {
+struct cfs_hash_head {
 	struct hlist_head	hh_head;	/**< entries list */
-} cfs_hash_head_t;
+};
 
 static int
 cfs_hash_hh_hhead_size(struct cfs_hash *hs)
 {
-	return sizeof(cfs_hash_head_t);
+	return sizeof(struct cfs_hash_head);
 }
 
 static struct hlist_head *
 cfs_hash_hh_hhead(struct cfs_hash *hs, struct cfs_hash_bd *bd)
 {
-	cfs_hash_head_t *head = (cfs_hash_head_t *)&bd->bd_bucket->hsb_head[0];
+	struct cfs_hash_head *head;
 
+	head = (struct cfs_hash_head *)&bd->bd_bucket->hsb_head[0];
 	return &head[bd->bd_offset].hh_head;
 }
 
@@ -277,23 +278,23 @@ cfs_hash_hh_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
  * Simple hash head with depth tracking
  * new element is always added to head of hlist
  */
-typedef struct {
+struct cfs_hash_head_dep {
 	struct hlist_head	hd_head;	/**< entries list */
-	unsigned int	    hd_depth;       /**< list length */
-} cfs_hash_head_dep_t;
+	unsigned int		hd_depth;       /**< list length */
+};
 
 static int
 cfs_hash_hd_hhead_size(struct cfs_hash *hs)
 {
-	return sizeof(cfs_hash_head_dep_t);
+	return sizeof(struct cfs_hash_head_dep);
 }
 
 static struct hlist_head *
 cfs_hash_hd_hhead(struct cfs_hash *hs, struct cfs_hash_bd *bd)
 {
-	cfs_hash_head_dep_t   *head;
+	struct cfs_hash_head_dep   *head;
 
-	head = (cfs_hash_head_dep_t *)&bd->bd_bucket->hsb_head[0];
+	head = (struct cfs_hash_head_dep *)&bd->bd_bucket->hsb_head[0];
 	return &head[bd->bd_offset].hd_head;
 }
 
@@ -301,8 +302,10 @@ static int
 cfs_hash_hd_hnode_add(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 		      struct hlist_node *hnode)
 {
-	cfs_hash_head_dep_t *hh = container_of(cfs_hash_hd_hhead(hs, bd),
-					       cfs_hash_head_dep_t, hd_head);
+	struct cfs_hash_head_dep *hh;
+
+	hh = container_of(cfs_hash_hd_hhead(hs, bd),
+			  struct cfs_hash_head_dep, hd_head);
 	hlist_add_head(hnode, &hh->hd_head);
 	return ++hh->hd_depth;
 }
@@ -311,8 +314,10 @@ static int
 cfs_hash_hd_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 		      struct hlist_node *hnode)
 {
-	cfs_hash_head_dep_t *hh = container_of(cfs_hash_hd_hhead(hs, bd),
-					       cfs_hash_head_dep_t, hd_head);
+	struct cfs_hash_head_dep *hh;
+
+	hh = container_of(cfs_hash_hd_hhead(hs, bd),
+			  struct cfs_hash_head_dep, hd_head);
 	hlist_del_init(hnode);
 	return --hh->hd_depth;
 }
-- 
1.7.1
