From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:44 -0500
Subject: [lustre-devel] [PATCH 10/10] staging: lustre: libcfs: use uXX
	instead of __uXX types in headers
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The types __[u|s]XX is only used for UAPI headers and userspace.
Only keep these types for the libcfs headers that are UAPI
headers. The rest convert to the standard uXX types.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/curproc.h  |    2 +-
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |    2 +-
 .../lustre/include/linux/libcfs/libcfs_fail.h      |   12 +++---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   46 ++++++++++----------
 .../lustre/include/linux/libcfs/libcfs_string.h    |   12 +++---
 .../lustre/include/linux/libcfs/linux/linux-time.h |    8 ++--
 6 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
index 6469a67..1ea27c9 100644
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
@@ -53,7 +53,7 @@
 #define current_pid()		(current->pid)
 #define current_comm()		(current->comm)
 
-typedef __u32 cfs_cap_t;
+typedef u32 cfs_cap_t;
 
 #define CFS_CAP_CHOWN		   0
 #define CFS_CAP_DAC_OVERRIDE	    1
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 61bd951..6d8752a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -92,7 +92,7 @@ struct cfs_cpt_table {
 	/* node mask */
 	nodemask_t		ctb_nodemask;
 	/* version */
-	__u64			ctb_version;
+	u64			ctb_version;
 };
 
 static inline cpumask_t *
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index 129047e..fedb46d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -39,8 +39,8 @@
 extern wait_queue_head_t cfs_race_waitq;
 extern int cfs_race_state;
 
-int __cfs_fail_check_set(__u32 id, __u32 value, int set);
-int __cfs_fail_timeout_set(__u32 id, __u32 value, int ms, int set);
+int __cfs_fail_check_set(u32 id, u32 value, int set);
+int __cfs_fail_timeout_set(u32 id, u32 value, int ms, int set);
 
 enum {
 	CFS_FAIL_LOC_NOSET      = 0,
@@ -69,14 +69,14 @@ enum {
 
 #define CFS_FAULT	0x02000000 /* match any CFS_FAULT_CHECK */
 
-static inline bool CFS_FAIL_PRECHECK(__u32 id)
+static inline bool CFS_FAIL_PRECHECK(u32 id)
 {
 	return cfs_fail_loc &&
 	       ((cfs_fail_loc & CFS_FAIL_MASK_LOC) == (id & CFS_FAIL_MASK_LOC) ||
 		(cfs_fail_loc & id & CFS_FAULT));
 }
 
-static inline int cfs_fail_check_set(__u32 id, __u32 value,
+static inline int cfs_fail_check_set(u32 id, u32 value,
 				     int set, int quiet)
 {
 	int ret = 0;
@@ -130,7 +130,7 @@ static inline int cfs_fail_check_set(__u32 id, __u32 value,
 #define CFS_FAIL_CHECK_RESET_QUIET(id, value) \
 	cfs_fail_check_set(id, value, CFS_FAIL_LOC_RESET, 1)
 
-static inline int cfs_fail_timeout_set(__u32 id, __u32 value, int ms, int set)
+static inline int cfs_fail_timeout_set(u32 id, u32 value, int ms, int set)
 {
 	if (unlikely(CFS_FAIL_PRECHECK(id)))
 		return __cfs_fail_timeout_set(id, value, ms, set);
@@ -166,7 +166,7 @@ static inline int cfs_fail_timeout_set(__u32 id, __u32 value, int ms, int set)
  * sleep. The next thread that calls with the same fail_loc wakes up
  * the first and continues.
  */
-static inline void cfs_race(__u32 id)
+static inline void cfs_race(u32 id)
 {
 	if (CFS_FAIL_PRECHECK(id)) {
 		if (unlikely(__cfs_fail_check_set(id, 0, CFS_FAIL_LOC_NOSET))) {
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 6231f47..0cc2fc4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -89,8 +89,8 @@
  */
 struct cfs_hash_bucket {
 	union cfs_hash_lock	hsb_lock;	/**< bucket lock */
-	__u32			hsb_count;	/**< current entries */
-	__u32			hsb_version;	/**< change version */
+	u32			hsb_count;	/**< current entries */
+	u32			hsb_version;	/**< change version */
 	unsigned int		hsb_index;	/**< index of bucket */
 	int			hsb_depmax;	/**< max depth on bucket */
 	long			hsb_head[0];	/**< hash-head array */
@@ -156,7 +156,7 @@ enum cfs_hash_tag {
 	 */
 	CFS_HASH_NBLK_CHANGE	= BIT(13),
 	/**
-	 * NB, we typed hs_flags as  __u16, please change it
+	 * NB, we typed hs_flags as  u16, please change it
 	 * if you need to extend >=16 flags
 	 */
 };
@@ -221,31 +221,31 @@ struct cfs_hash {
 	/** total number of items on this hash-table */
 	atomic_t			hs_count;
 	/** hash flags, see cfs_hash_tag for detail */
-	__u16				hs_flags;
+	u16				hs_flags;
 	/** # of extra-bytes for bucket, for user saving extended attributes */
-	__u16				hs_extra_bytes;
+	u16				hs_extra_bytes;
 	/** wants to iterate */
-	__u8				hs_iterating;
+	u8				hs_iterating;
 	/** hash-table is dying */
-	__u8				hs_exiting;
+	u8				hs_exiting;
 	/** current hash bits */
-	__u8				hs_cur_bits;
+	u8				hs_cur_bits;
 	/** min hash bits */
-	__u8				hs_min_bits;
+	u8				hs_min_bits;
 	/** max hash bits */
-	__u8				hs_max_bits;
+	u8				hs_max_bits;
 	/** bits for rehash */
-	__u8				hs_rehash_bits;
+	u8				hs_rehash_bits;
 	/** bits for each bucket */
-	__u8				hs_bkt_bits;
+	u8				hs_bkt_bits;
 	/** resize min threshold */
-	__u16				hs_min_theta;
+	u16				hs_min_theta;
 	/** resize max threshold */
-	__u16				hs_max_theta;
+	u16				hs_max_theta;
 	/** resize count */
-	__u32				hs_rehash_count;
+	u32				hs_rehash_count;
 	/** # of iterators (caller of cfs_hash_for_each_*) */
-	__u32				hs_iterators;
+	u32				hs_iterators;
 	/** rehash workitem */
 	struct cfs_workitem		hs_rehash_wi;
 	/** refcount on this hash table */
@@ -584,14 +584,14 @@ void cfs_hash_bd_get(struct cfs_hash *hs, const void *key,
 	       cfs_hash_bkt_size(hs) - hs->hs_extra_bytes;
 }
 
-static inline __u32
+static inline u32
 cfs_hash_bd_version_get(struct cfs_hash_bd *bd)
 {
 	/* need hold cfs_hash_bd_lock */
 	return bd->bd_bucket->hsb_version;
 }
 
-static inline __u32
+static inline u32
 cfs_hash_bd_count_get(struct cfs_hash_bd *bd)
 {
 	/* need hold cfs_hash_bd_lock */
@@ -729,7 +729,7 @@ typedef int (*cfs_hash_for_each_cb_t)(struct cfs_hash *hs,
 cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned int hindex,
 			cfs_hash_for_each_cb_t cb, void *data);
 int  cfs_hash_is_empty(struct cfs_hash *hs);
-__u64 cfs_hash_size_get(struct cfs_hash *hs);
+u64 cfs_hash_size_get(struct cfs_hash *hs);
 
 /*
  * Rehash - Theta is calculated to be the average chained
@@ -801,8 +801,8 @@ static inline int __cfs_hash_theta(struct cfs_hash *hs)
 __cfs_hash_set_theta(struct cfs_hash *hs, int min, int max)
 {
 	LASSERT(min < max);
-	hs->hs_min_theta = (__u16)min;
-	hs->hs_max_theta = (__u16)max;
+	hs->hs_min_theta = (u16)min;
+	hs->hs_max_theta = (u16)max;
 }
 
 /* Generic debug formatting routines mainly for proc handler */
@@ -830,7 +830,7 @@ static inline int __cfs_hash_theta(struct cfs_hash *hs)
  * Generic u32 hash algorithm.
  */
 static inline unsigned
-cfs_hash_u32_hash(const __u32 key, unsigned int mask)
+cfs_hash_u32_hash(const u32 key, unsigned int mask)
 {
 	return ((key * CFS_GOLDEN_RATIO_PRIME_32) & mask);
 }
@@ -839,7 +839,7 @@ static inline int __cfs_hash_theta(struct cfs_hash *hs)
  * Generic u64 hash algorithm.
  */
 static inline unsigned
-cfs_hash_u64_hash(const __u64 key, unsigned int mask)
+cfs_hash_u64_hash(const u64 key, unsigned int mask)
 {
 	return ((unsigned int)(key * CFS_GOLDEN_RATIO_PRIME_64) & mask);
 }
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index f5a434d..41795d9 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -62,9 +62,9 @@ struct cfs_range_expr {
 	 * Link to cfs_expr_list::el_exprs.
 	 */
 	struct list_head	re_link;
-	__u32		re_lo;
-	__u32		re_hi;
-	__u32		re_stride;
+	u32		re_lo;
+	u32		re_hi;
+	u32		re_stride;
 };
 
 struct cfs_expr_list {
@@ -76,13 +76,13 @@ struct cfs_expr_list {
 int cfs_gettok(struct cfs_lstr *next, char delim, struct cfs_lstr *res);
 int cfs_str2num_check(char *str, int nob, unsigned int *num,
 		      unsigned int min, unsigned int max);
-int cfs_expr_list_match(__u32 value, struct cfs_expr_list *expr_list);
+int cfs_expr_list_match(u32 value, struct cfs_expr_list *expr_list);
 int cfs_expr_list_print(char *buffer, int count,
 			struct cfs_expr_list *expr_list);
 int cfs_expr_list_values(struct cfs_expr_list *expr_list,
-			 int max, __u32 **values);
+			 int max, u32 **values);
 static inline void
-cfs_expr_list_values_free(__u32 *values, int num)
+cfs_expr_list_values_free(u32 *values, int num)
 {
 	/*
 	 * This array is allocated by LIBCFS_ALLOC(), so it shouldn't be freed
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
index b646acd..709e1ce 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
@@ -76,23 +76,23 @@ static inline long cfs_duration_sec(long d)
 
 #define cfs_time_current_64 get_jiffies_64
 
-static inline __u64 cfs_time_add_64(__u64 t, __u64 d)
+static inline u64 cfs_time_add_64(u64 t, u64 d)
 {
 	return t + d;
 }
 
-static inline __u64 cfs_time_shift_64(int seconds)
+static inline u64 cfs_time_shift_64(int seconds)
 {
 	return cfs_time_add_64(cfs_time_current_64(),
 			       cfs_time_seconds(seconds));
 }
 
-static inline int cfs_time_before_64(__u64 t1, __u64 t2)
+static inline int cfs_time_before_64(u64 t1, u64 t2)
 {
 	return (__s64)t2 - (__s64)t1 > 0;
 }
 
-static inline int cfs_time_beforeq_64(__u64 t1, __u64 t2)
+static inline int cfs_time_beforeq_64(u64 t1, u64 t2)
 {
 	return (__s64)t2 - (__s64)t1 >= 0;
 }
-- 
1.7.1
