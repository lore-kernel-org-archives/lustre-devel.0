From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:36 -0500
Subject: [lustre-devel] [PATCH 02/10] staging: lustre: libcfs: remove
	header's bare unsigned use
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Fixup the libcfs headers to use the proper unsigned int
instead of raw unsigned.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   28 ++++++++++----------
 .../lustre/include/linux/libcfs/libcfs_string.h    |    6 ++--
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  |    8 +++---
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index a4ca488..28937d5 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -297,8 +297,8 @@ struct cfs_hash_hlist_ops {
 
 struct cfs_hash_ops {
 	/** return hashed value from @key */
-	unsigned (*hs_hash)(struct cfs_hash *hs, const void *key,
-			    unsigned mask);
+	unsigned int (*hs_hash)(struct cfs_hash *hs, const void *key,
+				unsigned int mask);
 	/** return key address of @hnode */
 	void *   (*hs_key)(struct hlist_node *hnode);
 	/** copy key from @hnode to @key */
@@ -461,7 +461,7 @@ struct cfs_hash_ops {
 }
 
 static inline unsigned
-cfs_hash_id(struct cfs_hash *hs, const void *key, unsigned mask)
+cfs_hash_id(struct cfs_hash *hs, const void *key, unsigned int mask)
 {
 	return hs->hs_ops->hs_hash(hs, key, mask);
 }
@@ -570,7 +570,7 @@ void cfs_hash_bd_get(struct cfs_hash *hs, const void *key,
 }
 
 static inline void
-cfs_hash_bd_index_set(struct cfs_hash *hs, unsigned index,
+cfs_hash_bd_index_set(struct cfs_hash *hs, unsigned int index,
 		      struct cfs_hash_bd *bd)
 {
 	bd->bd_bucket = hs->hs_buckets[index >> hs->hs_bkt_bits];
@@ -677,10 +677,10 @@ struct hlist_node *
 
 /* Hash init/cleanup functions */
 struct cfs_hash *
-cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
-		unsigned bkt_bits, unsigned extra_bytes,
-		unsigned min_theta, unsigned max_theta,
-		struct cfs_hash_ops *ops, unsigned flags);
+cfs_hash_create(char *name, unsigned int cur_bits, unsigned int max_bits,
+		unsigned int bkt_bits, unsigned int extra_bytes,
+		unsigned int min_theta, unsigned int max_theta,
+		struct cfs_hash_ops *ops, unsigned int flags);
 
 struct cfs_hash *cfs_hash_getref(struct cfs_hash *hs);
 void cfs_hash_putref(struct cfs_hash *hs);
@@ -725,7 +725,7 @@ typedef int (*cfs_hash_for_each_cb_t)(struct cfs_hash *hs,
 cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t, void *data);
 
 void
-cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned hindex,
+cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned int hindex,
 			cfs_hash_for_each_cb_t, void *data);
 int  cfs_hash_is_empty(struct cfs_hash *hs);
 __u64 cfs_hash_size_get(struct cfs_hash *hs);
@@ -813,9 +813,9 @@ static inline int __cfs_hash_theta(struct cfs_hash *hs)
  * Generic djb2 hash algorithm for character arrays.
  */
 static inline unsigned
-cfs_hash_djb2_hash(const void *key, size_t size, unsigned mask)
+cfs_hash_djb2_hash(const void *key, size_t size, unsigned int mask)
 {
-	unsigned i, hash = 5381;
+	unsigned int i, hash = 5381;
 
 	LASSERT(key != NULL);
 
@@ -829,7 +829,7 @@ static inline int __cfs_hash_theta(struct cfs_hash *hs)
  * Generic u32 hash algorithm.
  */
 static inline unsigned
-cfs_hash_u32_hash(const __u32 key, unsigned mask)
+cfs_hash_u32_hash(const __u32 key, unsigned int mask)
 {
 	return ((key * CFS_GOLDEN_RATIO_PRIME_32) & mask);
 }
@@ -838,9 +838,9 @@ static inline int __cfs_hash_theta(struct cfs_hash *hs)
  * Generic u64 hash algorithm.
  */
 static inline unsigned
-cfs_hash_u64_hash(const __u64 key, unsigned mask)
+cfs_hash_u64_hash(const __u64 key, unsigned int mask)
 {
-	return ((unsigned)(key * CFS_GOLDEN_RATIO_PRIME_64) & mask);
+	return ((unsigned int)(key * CFS_GOLDEN_RATIO_PRIME_64) & mask);
 }
 
 /** iterate over all buckets in @bds (array of struct cfs_hash_bd) */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index 56341d9..f5a434d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -74,8 +74,8 @@ struct cfs_expr_list {
 
 char *cfs_trimwhite(char *str);
 int cfs_gettok(struct cfs_lstr *next, char delim, struct cfs_lstr *res);
-int cfs_str2num_check(char *str, int nob, unsigned *num,
-		      unsigned min, unsigned max);
+int cfs_str2num_check(char *str, int nob, unsigned int *num,
+		      unsigned int min, unsigned int max);
 int cfs_expr_list_match(__u32 value, struct cfs_expr_list *expr_list);
 int cfs_expr_list_print(char *buffer, int count,
 			struct cfs_expr_list *expr_list);
@@ -93,7 +93,7 @@ int cfs_expr_list_values(struct cfs_expr_list *expr_list,
 }
 
 void cfs_expr_list_free(struct cfs_expr_list *expr_list);
-int cfs_expr_list_parse(char *str, int len, unsigned min, unsigned max,
+int cfs_expr_list_parse(char *str, int len, unsigned int min, unsigned int max,
 			struct cfs_expr_list **elpp);
 void cfs_expr_list_free_list(struct list_head *list);
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
index f63cb47..dd0cd04 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
@@ -52,17 +52,17 @@ struct cfs_cpu_partition {
 	/* nodes mask for this partition */
 	nodemask_t			*cpt_nodemask;
 	/* spread rotor for NUMA allocator */
-	unsigned			cpt_spread_rotor;
+	unsigned int			cpt_spread_rotor;
 };
 
 /** descriptor for CPU partitions */
 struct cfs_cpt_table {
 	/* version, reserved for hotplug */
-	unsigned			ctb_version;
+	unsigned int			ctb_version;
 	/* spread rotor for NUMA allocator */
-	unsigned			ctb_spread_rotor;
+	unsigned int			ctb_spread_rotor;
 	/* # of CPU partitions */
-	unsigned			ctb_nparts;
+	unsigned int			ctb_nparts;
 	/* partitions tables */
 	struct cfs_cpu_partition	*ctb_parts;
 	/* shadow HW CPU to CPU partition ID */
-- 
1.7.1
