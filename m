From: James Simmons <jsimmons@infradead.org>
Date: Sat,  2 Mar 2019 14:12:18 -0500
Subject: [lustre-devel] [PATCH 1/7] lnet: move comments to sphinix format
In-Reply-To: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
References: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1551553944-6419-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre comments was written for DocBook which is no longer used
by the Linux kernel. Move all the DocBook handling to sphinix.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |  50 ++++----
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |  20 ++--
 .../lustre/include/uapi/linux/lnet/lnetctl.h       |   2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   2 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         |   2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |   2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |   8 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |  67 +++++------
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c  | 131 +++++++++++----------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  34 +++---
 drivers/staging/lustre/lnet/lnet/lib-eq.c          | 100 ++++++++--------
 drivers/staging/lustre/lnet/lnet/lib-md.c          |  67 +++++------
 drivers/staging/lustre/lnet/lnet/lib-me.c          |  76 ++++++------
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 113 ++++++++++--------
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  12 +-
 drivers/staging/lustre/lnet/lnet/net_fault.c       |  30 ++---
 drivers/staging/lustre/lnet/lnet/nidstrings.c      | 125 +++++++++-----------
 17 files changed, 425 insertions(+), 416 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 3e51752..84c6682 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -85,7 +85,7 @@
 extern struct cfs_cpt_table	*cfs_cpt_tab;
 
 /**
- * return cpumask of CPU partition \a cpt
+ * return cpumask of CPU partition @cpt
  */
 cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt);
 /**
@@ -97,83 +97,83 @@
  */
 int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len);
 /**
- * return total number of CPU partitions in \a cptab
+ * return total number of CPU partitions in @cptab
  */
 int cfs_cpt_number(struct cfs_cpt_table *cptab);
 /**
- * return number of HW cores or hyper-threadings in a CPU partition \a cpt
+ * return number of HW cores or hyper-threadings in a CPU partition @cpt
  */
 int cfs_cpt_weight(struct cfs_cpt_table *cptab, int cpt);
 /**
- * is there any online CPU in CPU partition \a cpt
+ * is there any online CPU in CPU partition @cpt
  */
 int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt);
 /**
- * return nodemask of CPU partition \a cpt
+ * return nodemask of CPU partition @cpt
  */
 nodemask_t *cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt);
 /**
- * shadow current HW processor ID to CPU-partition ID of \a cptab
+ * shadow current HW processor ID to CPU-partition ID of @cptab
  */
 int cfs_cpt_current(struct cfs_cpt_table *cptab, int remap);
 /**
- * shadow HW processor ID \a CPU to CPU-partition ID by \a cptab
+ * shadow HW processor ID @CPU to CPU-partition ID by @cptab
  */
 int cfs_cpt_of_cpu(struct cfs_cpt_table *cptab, int cpu);
 /**
- * shadow HW node ID \a NODE to CPU-partition ID by \a cptab
+ * shadow HW node ID @NODE to CPU-partition ID by @cptab
  */
 int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node);
 /**
- * NUMA distance between \a cpt1 and \a cpt2 in \a cptab
+ * NUMA distance between @cpt1 and @cpt2 in @cptab
  */
 unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2);
 /**
- * bind current thread on a CPU-partition \a cpt of \a cptab
+ * bind current thread on a CPU-partition @cpt of @cptab
  */
 int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt);
 /**
- * add \a cpu to CPU partition @cpt of \a cptab, return 1 for success,
+ * add @cpu to CPU partition @cpt of @cptab, return 1 for success,
  * otherwise 0 is returned
  */
 int cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu);
 /**
- * remove \a cpu from CPU partition \a cpt of \a cptab
+ * remove @cpu from CPU partition @cpt of @cptab
  */
 void cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu);
 /**
- * add all cpus in \a mask to CPU partition \a cpt
+ * add all cpus in @mask to CPU partition @cpt
  * return 1 if successfully set all CPUs, otherwise return 0
  */
 int cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab,
 			int cpt, const cpumask_t *mask);
 /**
- * remove all cpus in \a mask from CPU partition \a cpt
+ * remove all cpus in @mask from CPU partition @cpt
  */
 void cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab,
 			   int cpt, const cpumask_t *mask);
 /**
- * add all cpus in NUMA node \a node to CPU partition \a cpt
+ * add all cpus in NUMA node @node to CPU partition @cpt
  * return 1 if successfully set all CPUs, otherwise return 0
  */
 int cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node);
 /**
- * remove all cpus in NUMA node \a node from CPU partition \a cpt
+ * remove all cpus in NUMA node @node from CPU partition @cpt
  */
 void cfs_cpt_unset_node(struct cfs_cpt_table *cptab, int cpt, int node);
 /**
- * add all cpus in node mask \a mask to CPU partition \a cpt
+ * add all cpus in node mask @mask to CPU partition @cpt
  * return 1 if successfully set all CPUs, otherwise return 0
  */
 int cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab,
 			 int cpt, const nodemask_t *mask);
 /**
- * remove all cpus in node mask \a mask from CPU partition \a cpt
+ * remove all cpus in node mask @mask from CPU partition @cpt
  */
 void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
 			    int cpt, const nodemask_t *mask);
 /**
- * convert partition id \a cpt to numa node id, if there are more than one
+ * convert partition id @cpt to numa node id, if there are more than one
  * nodes in this partition, it might return a different node id each time.
  */
 int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt);
@@ -329,7 +329,7 @@ static inline void cfs_cpu_fini(void)
  */
 void cfs_cpt_table_free(struct cfs_cpt_table *cptab);
 /**
- * create a cfs_cpt_table with \a ncpt number of partitions
+ * create a cfs_cpt_table with @ncpt number of partitions
  */
 struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt);
 
@@ -383,18 +383,18 @@ struct cfs_percpt_lock {
 #define cfs_percpt_lock_num(pcl)	cfs_cpt_number(pcl->pcl_cptab)
 
 /*
- * create a cpu-partition lock based on CPU partition table \a cptab,
- * each private lock has extra \a psize bytes padding data
+ * create a cpu-partition lock based on CPU partition table @cptab,
+ * each private lock has extra @psize bytes padding data
  */
 struct cfs_percpt_lock *cfs_percpt_lock_create(struct cfs_cpt_table *cptab,
 					       struct lock_class_key *keys);
 /* destroy a cpu-partition lock */
 void cfs_percpt_lock_free(struct cfs_percpt_lock *pcl);
 
-/* lock private lock \a index of \a pcl */
+/* lock private lock @index of @pcl */
 void cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index);
 
-/* unlock private lock \a index of \a pcl */
+/* unlock private lock @index of @pcl */
 void cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index);
 
 #define CFS_PERCPT_LOCK_KEYS	256
@@ -413,7 +413,7 @@ struct cfs_percpt_lock *cfs_percpt_lock_create(struct cfs_cpt_table *cptab,
 })
 
 /**
- * iterate over all CPU partitions in \a cptab
+ * iterate over all CPU partitions in @cptab
  */
 #define cfs_cpt_for_each(i, cptab)	\
 	for (i = 0; i < cfs_cpt_number(cptab); i++)
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index ca8620b..497e24d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -119,8 +119,8 @@ enum cfs_crypto_hash_alg {
  *
  * Hash information includes algorithm name, initial seed, hash size.
  *
- * \retval	cfs_crypto_hash_type for valid ID (CFS_HASH_ALG_*)
- * \retval	NULL for unknown algorithm identifier
+ * Return:	cfs_crypto_hash_type for valid ID (CFS_HASH_ALG_*)
+ *		NULL for unknown algorithm identifier
  */
 static inline const struct cfs_crypto_hash_type *
 cfs_crypto_hash_type(enum cfs_crypto_hash_alg hash_alg)
@@ -138,10 +138,10 @@ enum cfs_crypto_hash_alg {
 /**
  * Return hash name for hash algorithm identifier
  *
- * \param[in]	hash_alg hash alrgorithm id (CFS_HASH_ALG_*)
+ * @hash_alg	hash alrgorithm id (CFS_HASH_ALG_*)
  *
- * \retval	string name of known hash algorithm
- * \retval	"unknown" if hash algorithm is unknown
+ * Return:	string name of known hash algorithm
+ *		"unknown" if hash algorithm is unknown
  */
 static inline const char *
 cfs_crypto_hash_name(enum cfs_crypto_hash_alg hash_alg)
@@ -157,10 +157,10 @@ enum cfs_crypto_hash_alg {
 /**
  * Return digest size for hash algorithm type
  *
- * \param[in]	hash_alg hash alrgorithm id (CFS_HASH_ALG_*)
+ * @hash_alg	hash alrgorithm id (CFS_HASH_ALG_*)
  *
- * \retval	hash algorithm digest size in bytes
- * \retval	0 if hash algorithm type is unknown
+ * Return:	hash algorithm digest size in bytes
+ *		0 if hash algorithm type is unknown
  */
 static inline int cfs_crypto_hash_digestsize(enum cfs_crypto_hash_alg hash_alg)
 {
@@ -175,8 +175,8 @@ static inline int cfs_crypto_hash_digestsize(enum cfs_crypto_hash_alg hash_alg)
 /**
  * Find hash algorithm ID for the specified algorithm name
  *
- * \retval	hash algorithm ID for valid ID (CFS_HASH_ALG_*)
- * \retval	CFS_HASH_ALG_UNKNOWN for unknown algorithm name
+ * Return:	hash algorithm ID for valid ID (CFS_HASH_ALG_*)
+ *		CFS_HASH_ALG_UNKNOWN for unknown algorithm name
  */
 static inline unsigned char cfs_crypto_hash_alg(const char *algname)
 {
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
index 9d53c51..e9fc57c 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
@@ -46,7 +46,7 @@ struct lnet_fault_attr {
 	 * 255.255.255.255@net is wildcard for all addresses from @net
 	 */
 	lnet_nid_t			fa_src;
-	/** destination NID of drop rule, see \a dr_src for details */
+	/** destination NID of drop rule, see @dr_src for details */
 	lnet_nid_t			fa_dst;
 	/**
 	 * Portal mask to drop, -1 means all portals, for example:
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 2bf1228..044b7b6 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -346,7 +346,7 @@ struct kib_data {
 	/* peers wait for reconnection */
 	struct list_head	kib_reconn_wait;
 	/**
-	 * The second that peers are pulled out from \a kib_reconn_wait
+	 * The second that peers are pulled out from @kib_reconn_wait
 	 * for reconnection.
 	 */
 	time64_t		kib_reconn_sec;
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index b7f0c73..5c9690e 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -335,7 +335,7 @@ static const char *libcfs_debug_dbg2str(int debug)
 /**
  * Upcall function once a Lustre log has been dumped.
  *
- * \param file  path of the dumped log
+ * @file	path of the dumped log
  */
 static void libcfs_run_debug_log_upcall(char *file)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 262469f..5f0d7a2 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -759,7 +759,7 @@ int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 EXPORT_SYMBOL(cfs_cpt_bind);
 
 /**
- * Choose max to \a number CPUs from \a node and set them in \a cpt.
+ * Choose max to @number CPUs from @node and set them in @cpt.
  * We always prefer to choose CPU in the same core/socket.
  */
 static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index 223505c..3d5157f 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -88,11 +88,11 @@ struct cfs_percpt_lock *
 /**
  * lock a CPU partition
  *
- * \a index != CFS_PERCPT_LOCK_EX
- *     hold private lock indexed by \a index
+ * @index != CFS_PERCPT_LOCK_EX
+ * hold private lock indexed by @index
  *
- * \a index == CFS_PERCPT_LOCK_EX
- *     exclusively lock @pcl and nobody can take private lock
+ * @index == CFS_PERCPT_LOCK_EX
+ * exclusively lock @pcl and nobody can take private lock
  */
 void
 cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index)
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index ae17b4d4..02814d3 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -146,12 +146,12 @@ char *cfs_firststr(char *str, size_t size)
 /**
  * Extracts tokens from strings.
  *
- * Looks for \a delim in string \a next, sets \a res to point to
- * substring before the delimiter, sets \a next right after the found
+ * Looks for @a delim in string @next, sets @res to point to
+ * substring before the delimiter, sets @next right after the found
  * delimiter.
  *
- * \retval 1 if \a res points to a string of non-whitespace characters
- * \retval 0 otherwise
+ * Return:	1 if @ res points to a string of non-whitespace characters
+ *		0 otherwise
  */
 int
 cfs_gettok(struct cfs_lstr *next, char delim, struct cfs_lstr *res)
@@ -204,9 +204,9 @@ char *cfs_firststr(char *str, size_t size)
  *
  * Accepts decimal and hexadecimal number recordings.
  *
- * \retval 1 if first \a nob chars of \a str convert to decimal or
- * hexadecimal integer in the range [\a min, \a max]
- * \retval 0 otherwise
+ * Return:	1 if first @nob chars of @str convert to decimal or
+ *		hexadecimal integer in the range [ @min, @max ]
+ *		0 otherwise
  */
 int
 cfs_str2num_check(char *str, int nob, unsigned int *num,
@@ -247,17 +247,18 @@ char *cfs_firststr(char *str, size_t size)
 EXPORT_SYMBOL(cfs_str2num_check);
 
 /**
- * Parses \<range_expr\> token of the syntax. If \a bracketed is false,
- * \a src should only have a single token which can be \<number\> or  \*
+ * Parses \<range_expr\> token of the syntax. If @bracketed is false,
+ * @src should only have a single token which can be \<number\> or  \*
  *
- * \retval pointer to allocated range_expr and initialized
- * range_expr::re_lo, range_expr::re_hi and range_expr:re_stride if \a
- `* src parses to
+ * Return:	pointer to allocated range_expr and initialized
+ * range_expr::re_lo, range_expr::re_hi and range_expr:re_stride if
+ * @src parses to
  * \<number\> |
  * \<number\> '-' \<number\> |
  * \<number\> '-' \<number\> '/' \<number\>
- * \retval 0 will be returned if it can be parsed, otherwise -EINVAL or
- * -ENOMEM will be returned.
+ *
+ * Return	0 will be returned if it can be parsed, otherwise -EINVAL or
+ *		-ENOMEM will be returned.
  */
 static int
 cfs_range_expr_parse(struct cfs_lstr *src, unsigned int min, unsigned int max,
@@ -324,11 +325,11 @@ char *cfs_firststr(char *str, size_t size)
 }
 
 /**
- * Print the range expression \a re into specified \a buffer.
- * If \a bracketed is true, expression does not need additional
+ * Print the range expression @expr into specified @buffer.
+ * If @bracketed is true, expression does not need additional
  * brackets.
  *
- * \retval number of characters written
+ * Return:	number of characters written
  */
 static int
 cfs_range_expr_print(char *buffer, int count, struct cfs_range_expr *expr,
@@ -355,11 +356,11 @@ char *cfs_firststr(char *str, size_t size)
 }
 
 /**
- * Print a list of range expressions (\a expr_list) into specified \a buffer.
+ * Print a list of range expressions (@expr_list) into specified @buffer.
  * If the list contains several expressions, separate them with comma
  * and surround the list with brackets.
  *
- * \retval number of characters written
+ * Return:	number of characters written
  */
 int
 cfs_expr_list_print(char *buffer, int count, struct cfs_expr_list *expr_list)
@@ -392,10 +393,10 @@ char *cfs_firststr(char *str, size_t size)
 EXPORT_SYMBOL(cfs_expr_list_print);
 
 /**
- * Matches value (\a value) against ranges expression list \a expr_list.
+ * Matches value (@value) against ranges expression list @expr_list.
  *
- * \retval 1 if \a value matches
- * \retval 0 otherwise
+ * Return:	1 if @value matches
+ *		0 otherwise
  */
 int
 cfs_expr_list_match(u32 value, struct cfs_expr_list *expr_list)
@@ -413,11 +414,11 @@ char *cfs_firststr(char *str, size_t size)
 EXPORT_SYMBOL(cfs_expr_list_match);
 
 /**
- * Convert express list (\a expr_list) to an array of all matched values
+ * Convert express list (@expr_list) to an array of all matched values
  *
- * \retval N N is total number of all matched values
- * \retval 0 if expression list is empty
- * \retval < 0 for failure
+ * Return:	N is total number of all matched values
+ *		0 if expression list is empty
+ *		< 0 for failure
  */
 int
 cfs_expr_list_values(struct cfs_expr_list *expr_list, int max, u32 **valpp)
@@ -461,9 +462,7 @@ char *cfs_firststr(char *str, size_t size)
 EXPORT_SYMBOL(cfs_expr_list_values);
 
 /**
- * Frees cfs_range_expr structures of \a expr_list.
- *
- * \retval none
+ * Frees cfs_range_expr structures of @expr_list.
  */
 void
 cfs_expr_list_free(struct cfs_expr_list *expr_list)
@@ -484,8 +483,8 @@ char *cfs_firststr(char *str, size_t size)
 /**
  * Parses \<cfs_expr_list\> token of the syntax.
  *
- * \retval 0 if \a str parses to \<number\> | \<expr_list\>
- * \retval -errno otherwise
+ * Return:	0 if @str parses to \<number\> | \<expr_list\>
+ *		-errno otherwise
  */
 int
 cfs_expr_list_parse(char *str, int len, unsigned int min, unsigned int max,
@@ -541,12 +540,10 @@ char *cfs_firststr(char *str, size_t size)
 EXPORT_SYMBOL(cfs_expr_list_parse);
 
 /**
- * Frees cfs_expr_list structures of \a list.
+ * Frees cfs_expr_list structures of @list.
  *
- * For each struct cfs_expr_list structure found on \a list it frees
+ * For each struct cfs_expr_list structure found on @list it frees
  * range_expr list attached to it and frees the cfs_expr_list itself.
- *
- * \retval none
  */
 void
 cfs_expr_list_free_list(struct list_head *list)
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
index a0b1377..1c96dc6 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
@@ -44,21 +44,21 @@
 /**
  * Initialize the state descriptor for the specified hash algorithm.
  *
- * An internal routine to allocate the hash-specific state in \a req for
+ * An internal routine to allocate the hash-specific state in @req for
  * use with cfs_crypto_hash_digest() to compute the hash of a single message,
  * though possibly in multiple chunks.  The descriptor internal state should
  * be freed with cfs_crypto_hash_final().
  *
- * \param[in]	  hash_alg	hash algorithm id (CFS_HASH_ALG_*)
- * \param[out]	  type		pointer to the hash description in hash_types[]
- *				array
- * \param[in,out] req		hash state descriptor to be initialized
- * \param[in]	  key		initial hash value/state, NULL to use default
- *				value
- * \param[in]	  key_len	length of \a key
+ * @hash_alg	hash algorithm id (CFS_HASH_ALG_*)
+ * @type	pointer to the hash description in hash_types[]
+ *		array
+ * @req		hash state descriptor to be initialized
+ * @key		initial hash value/state, NULL to use default
+ *		value
+ * @key_len	length of @key
  *
- * \retval			0 on success
- * \retval			negative errno on failure
+ * Return	0 on success
+ *		negative errno on failure
  */
 static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 				 const struct cfs_crypto_hash_type **type,
@@ -125,25 +125,25 @@ static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
  * This should be used when computing the hash on a single contiguous buffer.
  * It combines the hash initialization, computation, and cleanup.
  *
- * \param[in]	  hash_alg	id of hash algorithm (CFS_HASH_ALG_*)
- * \param[in]	  buf		data buffer on which to compute hash
- * \param[in]	  buf_len	length of \a buf in bytes
- * \param[in]	  key		initial value/state for algorithm,
- *				if \a key = NULL use default initial value
- * \param[in]	  key_len	length of \a key in bytes
- * \param[out]	  hash		pointer to computed hash value,
- *				if \a hash = NULL then \a hash_len is to digest
- *				size in bytes, retval -ENOSPC
- * \param[in,out] hash_len	size of \a hash buffer
- *
- * \retval -EINVAL		\a buf, \a buf_len, \a hash_len,
- *				\a hash_alg invalid
- * \retval -ENOENT		\a hash_alg is unsupported
- * \retval -ENOSPC		\a hash is NULL, or \a hash_len less than
- *				digest size
- * \retval			0 for success
- * \retval			negative errno for other errors from lower
- *				layers.
+ * @hash_alg	id of hash algorithm (CFS_HASH_ALG_*)
+ * @buf		data buffer on which to compute hash
+ * @buf_len	length of @buf in bytes
+ * @key		initial value/state for algorithm,
+ *		if @key = NULL use default initial value
+ * @key_len	length of @key in bytes
+ * @hash	pointer to computed hash value,
+ *		if @hash = NULL then @hash_len is to digest
+ *		size in bytes, returns -ENOSPC
+ * @hash_len	size of @hash buffer
+ *
+ * Return:
+ *	-EINVAL		@buf, @buf_len, @hash_len,
+ *			@hash_alg invalid
+ *	-ENOENT		@hash_alg is unsupported
+ *	-ENOSPC		@hash is NULL, or @hash_len less than
+ *			digest size
+ *	0 for success
+ *	negative errno for other errors from lower layers.
  */
 int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
 			   const void *buf, unsigned int buf_len,
@@ -188,13 +188,13 @@ int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
  *
  * The hash descriptor should be freed with cfs_crypto_hash_final().
  *
- * \param[in] hash_alg	algorithm id (CFS_HASH_ALG_*)
- * \param[in] key	initial value/state for algorithm, if \a key = NULL
- *			use default initial value
- * \param[in] key_len	length of \a key in bytes
+ * @hash_alg	algorithm id (CFS_HASH_ALG_*)
+ * @key		initial value/state for algorithm, if @key = NULL
+ *		use default initial value
+ * @key_len	length of @key in bytes
  *
- * \retval		pointer to descriptor of hash instance
- * \retval		ERR_PTR(errno) in case of error
+ * Return:	pointer to descriptor of hash instance
+ *		ERR_PTR(errno) in case of error
  */
 struct ahash_request *
 cfs_crypto_hash_init(enum cfs_crypto_hash_alg hash_alg,
@@ -212,15 +212,15 @@ struct ahash_request *
 EXPORT_SYMBOL(cfs_crypto_hash_init);
 
 /**
- * Update hash digest computed on data within the given \a page
+ * Update hash digest computed on data within the given @page
  *
- * \param[in] hreq	hash state descriptor
- * \param[in] page	data page on which to compute the hash
- * \param[in] offset	offset within \a page at which to start hash
- * \param[in] len	length of data on which to compute hash
+ * @hreq	hash state descriptor
+ * @page	data page on which to compute the hash
+ * @offset	offset within @page at which to start hash
+ * @len		length of data on which to compute hash
  *
- * \retval		0 for success
- * \retval		negative errno on failure
+ * Return:	0 for success
+ *		negative errno on failure
  */
 int cfs_crypto_hash_update_page(struct ahash_request *req,
 				struct page *page, unsigned int offset,
@@ -239,12 +239,12 @@ int cfs_crypto_hash_update_page(struct ahash_request *req,
 /**
  * Update hash digest computed on the specified data
  *
- * \param[in] req	hash state descriptor
- * \param[in] buf	data buffer on which to compute the hash
- * \param[in] buf_len	length of \buf on which to compute hash
+ * @req		hash state descriptor
+ * @buf		data buffer on which to compute the hash
+ * @buf_len	length of @buf on which to compute hash
  *
- * \retval		0 for success
- * \retval		negative errno on failure
+ * Return:	0 for success
+ *		negative errno on failure
  */
 int cfs_crypto_hash_update(struct ahash_request *req,
 			   const void *buf, unsigned int buf_len)
@@ -261,14 +261,15 @@ int cfs_crypto_hash_update(struct ahash_request *req,
 /**
  * Finish hash calculation, copy hash digest to buffer, clean up hash descriptor
  *
- * \param[in]	  req		hash descriptor
- * \param[out]	  hash		pointer to hash buffer to store hash digest
- * \param[in,out] hash_len	pointer to hash buffer size, if \a req = NULL
- *				only free \a req instead of computing the hash
+ * @req		hash descriptor
+ * @hash	pointer to hash buffer to store hash digest
+ * @hash_len	pointer to hash buffer size, if @req = NULL
+ *		only free @req instead of computing the hash
  *
- * \retval	0 for success
- * \retval	-EOVERFLOW if hash_len is too small for the hash digest
- * \retval	negative errno for other errors from lower layers
+ * Return:
+ *		0 for success
+ *		-EOVERFLOW if hash_len is too small for the hash digest
+ *		negative errno for other errors from lower layers
  */
 int cfs_crypto_hash_final(struct ahash_request *req,
 			  unsigned char *hash, unsigned int *hash_len)
@@ -306,9 +307,9 @@ int cfs_crypto_hash_final(struct ahash_request *req,
  * The speed is stored internally in the cfs_crypto_hash_speeds[] array, and
  * is available through the cfs_crypto_hash_speed() function.
  *
- * \param[in] hash_alg	hash algorithm id (CFS_HASH_ALG_*)
- * \param[in] buf	data buffer on which to compute the hash
- * \param[in] buf_len	length of \buf on which to compute hash
+ * @hash_alg	hash algorithm id (CFS_HASH_ALG_*)
+ * @buf		data buffer on which to compute the hash
+ * @buf_len	length of @buf on which to compute hash
  */
 static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 {
@@ -375,18 +376,18 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 /**
  * hash speed in Mbytes per second for valid hash algorithm
  *
- * Return the performance of the specified \a hash_alg that was
+ * Return the performance of the specified @hash_alg that was
  * computed using cfs_crypto_performance_test().  If the performance
  * has not yet been computed, do that when it is first requested.
  * That avoids computing the speed when it is not actually needed.
  * To avoid competing threads computing the checksum speed at the
  * same time, only compute a single checksum speed at one time.
  *
- * \param[in] hash_alg	hash algorithm id (CFS_HASH_ALG_*)
+ * @hash_alg	hash algorithm id (CFS_HASH_ALG_*)
  *
- * \retval		positive speed of the hash function in MB/s
- * \retval		-ENOENT if \a hash_alg is unsupported
- * \retval		negative errno if \a hash_alg speed is unavailable
+ * Return:	positive speed of the hash function in MB/s
+ *		-ENOENT if @hash_alg is unsupported
+ *		negative errno if @hash_alg speed is unavailable
  */
 int cfs_crypto_hash_speed(enum cfs_crypto_hash_alg hash_alg)
 {
@@ -420,8 +421,8 @@ int cfs_crypto_hash_speed(enum cfs_crypto_hash_alg hash_alg)
  * The actual speeds are available via cfs_crypto_hash_speed() for later
  * comparison.
  *
- * \retval	0 on success
- * \retval	-ENOMEM if no memory is available for test buffer
+ * Return:	0 on success
+ *		-ENOMEM if no memory is available for test buffer
  */
 static int cfs_crypto_test_hashes(void)
 {
@@ -438,7 +439,7 @@ static int cfs_crypto_test_hashes(void)
 /**
  * Register available hash functions
  *
- * \retval	0
+ * Return:	0
  */
 int cfs_crypto_register(void)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 671591a..12b3c44 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1950,8 +1950,8 @@ static void lnet_push_target_fini(void)
  * lnet_lib_exit() after a call to lnet_lib_init(), if and only if the
  * latter returned 0. It must be called exactly once.
  *
- * \retval 0 on success
- * \retval -ve on failures.
+ * Return:	0 on success
+ *		-ve on failures.
  */
 int lnet_lib_init(void)
 {
@@ -2031,15 +2031,15 @@ void lnet_lib_exit(void)
  *
  * Users must call this function at least once before any other functions.
  * For each successful call there must be a corresponding call to
- * LNetNIFini(). For subsequent calls to LNetNIInit(), \a requested_pid is
+ * LNetNIFini(). For subsequent calls to LNetNIInit(), @requested_pid is
  * ignored.
  *
  * The PID used by LNet may be different from the one requested.
  * See LNetGetId().
  *
- * \param requested_pid PID requested by the caller.
+ * @requested_pid	PID requested by the caller.
  *
- * \return >= 0 on success, and < 0 error code on failures.
+ * Return:		>= 0 on success, and < 0 error code on failures.
  */
 int
 LNetNIInit(lnet_pid_t requested_pid)
@@ -2185,7 +2185,7 @@ void lnet_lib_exit(void)
  * Once the LNetNIFini() operation has been started, the results of pending
  * API operations are undefined.
  *
- * \return always 0 for current implementation.
+ * Return:	always 0 for current implementation.
  */
 int
 LNetNIFini(void)
@@ -2224,9 +2224,9 @@ void lnet_lib_exit(void)
  * Grabs the ni data from the ni structure and fills the out
  * parameters
  *
- * \param[in] ni network	interface structure
- * \param[out] cfg_ni		NI config information
- * \param[out] tun		network and LND tunables
+ * @ni		network	interface structure
+ * @cfg_ni	NI config information
+ * @tun		network and LND tunables
  */
 static void
 lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_ni *cfg_ni,
@@ -2302,8 +2302,8 @@ void lnet_lib_exit(void)
  * Grabs the ni data from the ni structure and fills the out
  * parameters
  *
- * \param[in] ni network	interface structure
- * \param[out] config		config information
+ * @ni		network	interface structure
+ * @config	config information
  */
 static void
 lnet_fill_ni_info_legacy(struct lnet_ni *ni,
@@ -3308,15 +3308,15 @@ void LNetDebugPeer(struct lnet_process_id id)
 EXPORT_SYMBOL(LNetDebugPeer);
 
 /**
- * Retrieve the lnet_process_id ID of LNet interface at \a index. Note that
+ * Retrieve the lnet_process_id ID of LNet interface at @index. Note that
  * all interfaces share a same PID, as requested by LNetNIInit().
  *
- * \param index Index of the interface to look up.
- * \param id On successful return, this location will hold the
- * lnet_process_id ID of the interface.
+ * @index	Index of the interface to look up.
+ * @id		On successful return, this location will hold the
+ *		lnet_process_id ID of the interface.
  *
- * \retval 0 If an interface exists at \a index.
- * \retval -ENOENT If no interface has been found.
+ * Return:	0 If an interface exists@@index.
+ *		-ENOENT If no interface has been found.
  */
 int
 LNetGetId(unsigned int index, struct lnet_process_id *id)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index f500b49..3d99f0a 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -40,27 +40,27 @@
 #include <linux/lnet/lib-lnet.h>
 
 /**
- * Create an event queue that has room for \a count number of events.
+ * Create an event queue that has room for @count number of events.
  *
  * The event queue is circular and older events will be overwritten by new
  * ones if they are not removed in time by the user using the functions
  * LNetEQGet(), LNetEQWait(), or LNetEQPoll(). It is up to the user to
  * determine the appropriate size of the event queue to prevent this loss
- * of events. Note that when EQ handler is specified in \a callback, no
+ * of events. Note that when EQ handler is specified in @callback, no
  * event loss can happen, since the handler is run for each event deposited
  * into the EQ.
  *
- * \param count The number of events to be stored in the event queue. It
- * will be rounded up to the next power of two.
- * \param callback A handler function that runs when an event is deposited
- * into the EQ. The constant value LNET_EQ_HANDLER_NONE can be used to
- * indicate that no event handler is desired.
- * \param handle On successful return, this location will hold a handle for
- * the newly created EQ.
+ * @count	The number of events to be stored in the event queue. It
+ *		will be rounded up to the next power of two.
+ * @callback	A handler function that runs when an event is deposited
+ *		into the EQ. The constant value LNET_EQ_HANDLER_NONE can
+ *		be used to indicate that no event handler is desired.
+ * @handle	On successful return, this location will hold a handle for
+ *		the newly created EQ.
  *
- * \retval 0       On success.
- * \retval -EINVAL If an parameter is not valid.
- * \retval -ENOMEM If memory for the EQ can't be allocated.
+ * Return:	0 On success.
+ *		-EINVAL If an parameter is not valid.
+ *		-ENOMEM If memory for the EQ can't be allocated.
  *
  * \see lnet_eq_handler_t for the discussion on EQ handler semantics.
  */
@@ -147,11 +147,11 @@
  * Release the resources associated with an event queue if it's idle;
  * otherwise do nothing and it's up to the user to try again.
  *
- * \param eqh A handle for the event queue to be released.
+ * @eqh		A handle for the event queue to be released.
  *
- * \retval 0 If the EQ is not in use and freed.
- * \retval -ENOENT If \a eqh does not point to a valid EQ.
- * \retval -EBUSY  If the EQ is still in use by some MDs.
+ * Return:	0 If the EQ is not in use and freed.
+ *		-ENOENT If @eqh does not point to a valid EQ.
+ *		-EBUSY If the EQ is still in use by some MDs.
  */
 int
 LNetEQFree(struct lnet_handle_eq eqh)
@@ -278,16 +278,17 @@
  * If an event handler is associated with the EQ, the handler will run before
  * this function returns successfully. The event is removed from the queue.
  *
- * \param eventq A handle for the event queue.
- * \param event On successful return (1 or -EOVERFLOW), this location will
- * hold the next event in the EQ.
+ * @eventq	A handle for the event queue.
+ * @event	On successful return (1 or -EOVERFLOW), this location will
+ *		hold the next event in the EQ.
  *
- * \retval 0	  No pending event in the EQ.
- * \retval 1	  Indicates success.
- * \retval -ENOENT    If \a eventq does not point to a valid EQ.
- * \retval -EOVERFLOW Indicates success (i.e., an event is returned) and that
- * at least one event between this event and the last event obtained from the
- * EQ has been dropped due to limited space in the EQ.
+ * Return	0 No pending event in the EQ.
+ *		1 Indicates success.
+ *		-ENOENT If @eventq does not point to a valid EQ.
+ *		-EOVERFLOW Indicates success (i.e., an event is returned)
+ *		and that at least one event between this event and the last
+ *		event obtained from the EQ has been dropped due to limited
+ *		space in the EQ.
  */
 
 /**
@@ -296,17 +297,17 @@
  * this function returns successfully. This function returns the next event
  * in the EQ and removes it from the EQ.
  *
- * \param eventq A handle for the event queue.
- * \param event On successful return (1 or -EOVERFLOW), this location will
- * hold the next event in the EQ.
+ * @eventq	A handle for the event queue.
+ * @event	On successful return (1 or -EOVERFLOW), this location will
+ *		hold the next event in the EQ.
  *
- * \retval 1	  Indicates success.
- * \retval -ENOENT    If \a eventq does not point to a valid EQ.
- * \retval -EOVERFLOW Indicates success (i.e., an event is returned) and that
- * at least one event between this event and the last event obtained from the
- * EQ has been dropped due to limited space in the EQ.
+ * Return:	1 Indicates success.
+ *		-ENOENT If @eventq does not point to a valid EQ.
+ *		-EOVERFLOW Indicates success (i.e., an event is returned)
+ *		and that at least one event between this event and the last
+ *		event obtained from the EQ has been dropped due to limited
+ *		space in the EQ.
  */
-
 static int
 lnet_eq_wait_locked(signed long *timeout, long state)
 __must_hold(&the_lnet.ln_eq_wait_lock)
@@ -345,21 +346,24 @@
  * LNetEQPoll() provides a timeout to allow applications to poll, block for a
  * fixed period, or block indefinitely.
  *
- * \param eventqs,neq An array of EQ handles, and size of the array.
- * \param timeout Time in jiffies to wait for an event to occur on
- * one of the EQs. The constant MAX_SCHEDULE_TIMEOUT can be used to indicate an
- * infinite timeout.
- * \param interruptible, if true, use TASK_INTERRUPTIBLE, else TASK_IDLE
- * \param event,which On successful return (1 or -EOVERFLOW), \a event will
- * hold the next event in the EQs, and \a which will contain the index of the
- * EQ from which the event was taken.
+ * @eventqs,neq		An array of EQ handles, and size of the array.
+ * @timeout		Time in jiffies to wait for an event to occur on
+ *			one of the EQs. The constant MAX_SCHEDULE_TIMEOUT
+ *			can be used to indicate an infinite timeout.
+ * @interruptible	if true, use TASK_INTERRUPTIBLE, else TASK_IDLE
+ * @event,which		On successful return (1 or -EOVERFLOW), @event will
+ *			hold the next event in the EQs, and @which will
+ *			contain the index of the EQ from which the event
+ *			was taken.
  *
- * \retval 0	  No pending event in the EQs after timeout.
- * \retval 1	  Indicates success.
- * \retval -EOVERFLOW Indicates success (i.e., an event is returned) and that
- * at least one event between this event and the last event obtained from the
- * EQ indicated by \a which has been dropped due to limited space in the EQ.
- * \retval -ENOENT    If there's an invalid handle in \a eventqs.
+ * Return:		0 No pending event in the EQs after timeout.
+ *			1 Indicates success.
+ *			-EOVERFLOW Indicates success (i.e., an event is
+ *			returned) and that at least one event between
+ *			this event and the last event obtained from the
+ *			EQ indicated by @which has been dropped due to
+ *			limited space in the EQ.
+ *			-ENOENT If there's an invalid handle in @eventqs.
  */
 int
 LNetEQPoll(struct lnet_handle_eq *eventqs, int neq, signed long timeout,
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 2ab985e..33a59fb 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -333,27 +333,28 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 /**
  * Create a memory descriptor and attach it to a ME
  *
- * \param meh A handle for a ME to associate the new MD with.
- * \param umd Provides initial values for the user-visible parts of a MD.
- * Other than its use for initialization, there is no linkage between this
- * structure and the MD maintained by the LNet.
- * \param unlink A flag to indicate whether the MD is automatically unlinked
- * when it becomes inactive, either because the operation threshold drops to
- * zero or because the available memory becomes less than \a umd.max_size.
- * (Note that the check for unlinking a MD only occurs after the completion
- * of a successful operation on the MD.) The value LNET_UNLINK enables auto
- * unlinking; the value LNET_RETAIN disables it.
- * \param handle On successful returns, a handle to the newly created MD is
- * saved here. This handle can be used later in LNetMDUnlink().
+ * @meh		A handle for a ME to associate the new MD with.
+ * @umd		Provides initial values for the user-visible parts of a MD.
+ *		Other than its use for initialization, there is no linkage
+ *		between this structure and the MD maintained by the LNet.
+ * @unlink	A flag to indicate whether the MD is automatically unlinked
+ *		when it becomes inactive, either because the operation
+ *		threshold drops to zero or because the available memory
+ *		becomes less than @umd.max_size. (Note that the check for
+ *		unlinking a MD only occurs after the completion of a
+ *		successful operation on the MD.) The value LNET_UNLINK
+ *		enables auto unlinking; the value LNET_RETAIN disables it.
+ * @handle	On successful returns, a handle to the newly created MD is
+ *		saved here. This handle can be used later in LNetMDUnlink().
  *
- * \retval 0       On success.
- * \retval -EINVAL If \a umd is not valid.
- * \retval -ENOMEM If new MD cannot be allocated.
- * \retval -ENOENT Either \a meh or \a umd.eq_handle does not point to a
- * valid object. Note that it's OK to supply a NULL \a umd.eq_handle by
- * calling LNetInvalidateHandle() on it.
- * \retval -EBUSY  If the ME pointed to by \a meh is already associated with
- * a MD.
+ * Return:	0 on success.
+ *		-EINVAL If @umd is not valid.
+ *		-ENOMEM If new MD cannot be allocated.
+ *		-ENOENT Either @meh or @umd.eq_handle does not point to a
+ *		valid object. Note that it's OK to supply a NULL @umd.eq_handle
+ *		by calling LNetInvalidateHandle() on it.
+ *		-EBUSY if the ME pointed to by @meh is already associated with
+ *		a MD.
  */
 int
 LNetMDAttach(struct lnet_handle_me meh, struct lnet_md umd,
@@ -426,17 +427,17 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
  * Create a "free floating" memory descriptor - a MD that is not associated
  * with a ME. Such MDs are usually used in LNetPut() and LNetGet() operations.
  *
- * \param umd,unlink See the discussion for LNetMDAttach().
- * \param handle On successful returns, a handle to the newly created MD is
- * saved here. This handle can be used later in LNetMDUnlink(), LNetPut(),
- * and LNetGet() operations.
+ * @umd,unlink		See the discussion for LNetMDAttach().
+ * @handle		On successful returns, a handle to the newly created
+ *			MD is saved here. This handle can be used later in
+ *			LNetMDUnlink(), LNetPut(), and LNetGet() operations.
  *
- * \retval 0       On success.
- * \retval -EINVAL If \a umd is not valid.
- * \retval -ENOMEM If new MD cannot be allocated.
- * \retval -ENOENT \a umd.eq_handle does not point to a valid EQ. Note that
- * it's OK to supply a NULL \a umd.eq_handle by calling
- * LNetInvalidateHandle() on it.
+ * Return:		0 On success.
+ *			-EINVAL If @umd is not valid.
+ *			-ENOMEM If new MD cannot be allocated.
+ *			-ENOENT @umd.eq_handle does not point to a valid EQ.
+ *			Note that it's OK to supply a NULL @umd.eq_handle by
+ *			calling LNetInvalidateHandle() on it.
  */
 int
 LNetMDBind(struct lnet_md umd, enum lnet_unlink unlink,
@@ -509,10 +510,10 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
  * Note that in both cases the unlinked field of the event is always set; no
  * more event will happen on the MD after such an event is logged.
  *
- * \param mdh A handle for the MD to be unlinked.
+ * @mdh		A handle for the MD to be unlinked.
  *
- * \retval 0       On success.
- * \retval -ENOENT If \a mdh does not point to a valid MD object.
+ * Return:	0 On success.
+ *		-ENOENT If @mdh does not point to a valid MD object.
  */
 int
 LNetMDUnlink(struct lnet_handle_md mdh)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 4a5ffb1..f0365ea 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -40,34 +40,35 @@
 #include <linux/lnet/lib-lnet.h>
 
 /**
- * Create and attach a match entry to the match list of \a portal. The new
+ * Create and attach a match entry to the match list of @portal. The new
  * ME is empty, i.e. not associated with a memory descriptor. LNetMDAttach()
  * can be used to attach a MD to an empty ME.
  *
- * \param portal The portal table index where the ME should be attached.
- * \param match_id Specifies the match criteria for the process ID of
- * the requester. The constants LNET_PID_ANY and LNET_NID_ANY can be
- * used to wildcard either of the identifiers in the lnet_process_id
- * structure.
- * \param match_bits,ignore_bits Specify the match criteria to apply
- * to the match bits in the incoming request. The ignore bits are used
- * to mask out insignificant bits in the incoming match bits. The resulting
- * bits are then compared to the ME's match bits to determine if the
- * incoming request meets the match criteria.
- * \param unlink Indicates whether the ME should be unlinked when the memory
- * descriptor associated with it is unlinked (Note that the check for
- * unlinking a ME only occurs when the memory descriptor is unlinked.).
- * Valid values are LNET_RETAIN and LNET_UNLINK.
- * \param pos Indicates whether the new ME should be prepended or
- * appended to the match list. Allowed constants: LNET_INS_BEFORE,
- * LNET_INS_AFTER.
- * \param handle On successful returns, a handle to the newly created ME
- * object is saved here. This handle can be used later in LNetMEInsert(),
- * LNetMEUnlink(), or LNetMDAttach() functions.
+ * @portal	The portal table index where the ME should be attached.
+ * @match_id	Specifies the match criteria for the process ID of
+ *		the requester. The constants LNET_PID_ANY and LNET_NID_ANY
+ *		can be used to wildcard either of the identifiers in the
+ *		lnet_process_id structure.
+ * @match_bits
+ * @ignore_bits Specify the match criteria to apply to the match bits in the
+ *		incoming request. The ignore bits are used to mask out
+ *		insignificant bits in the incoming match bits. The resulting
+ *		bits are then compared to the ME's match bits to determine if
+ *		the incoming request meets the match criteria.
+ * @unlink	Indicates whether the ME should be unlinked when the memory
+ *		descriptor associated with it is unlinked (Note that the check
+ *		for unlinking a ME only occurs when the memory descriptor is
+ *		unlinked.). Valid values are LNET_RETAIN and LNET_UNLINK.
+ * @pos		Indicates whether the new ME should be prepended or
+ *		appended to the match list. Allowed constants: LNET_INS_BEFORE,
+ *		LNET_INS_AFTER.
+ * @handle	On successful returns, a handle to the newly created ME object
+ *		is saved here. This handle can be used later in LNetMEInsert(),
+ *		LNetMEUnlink(), or LNetMDAttach() functions.
  *
- * \retval 0       On success.
- * \retval -EINVAL If \a portal is invalid.
- * \retval -ENOMEM If new ME object cannot be allocated.
+ * Return:	0 On success.
+ *		-EINVAL If @portal is invalid.
+ *		-ENOMEM If new ME object cannot be allocated.
  */
 int
 LNetMEAttach(unsigned int portal,
@@ -125,20 +126,24 @@
 
 /**
  * Create and a match entry and insert it before or after the ME pointed to by
- * \a current_meh. The new ME is empty, i.e. not associated with a memory
+ * @current_meh. The new ME is empty, i.e. not associated with a memory
  * descriptor. LNetMDAttach() can be used to attach a MD to an empty ME.
  *
  * This function is identical to LNetMEAttach() except for the position
  * where the new ME is inserted.
  *
- * \param current_meh A handle for a ME. The new ME will be inserted
- * immediately before or immediately after this ME.
- * \param match_id,match_bits,ignore_bits,unlink,pos,handle See the discussion
- * for LNetMEAttach().
+ * @current_meh		A handle for a ME. The new ME will be inserted
+ *			immediately before or immediately after this ME.
+ * @match_id		See the discussion for LNetMEAttach().
+ * @match_bits
+ * @ignore_bits
+ * @unlink
+ * @pos
+ * @handle
  *
- * \retval 0       On success.
- * \retval -ENOMEM If new ME object cannot be allocated.
- * \retval -ENOENT If \a current_meh does not point to a valid match entry.
+ * Return:		0 On success.
+ *			-ENOMEM If new ME object cannot be allocated.
+ *			-ENOENT If @current_meh does not point to a valid match entry.
  */
 int
 LNetMEInsert(struct lnet_handle_me current_meh,
@@ -214,10 +219,11 @@
  * and an unlink event will be generated. It is an error to use the ME handle
  * after calling LNetMEUnlink().
  *
- * \param meh A handle for the ME to be unlinked.
+ * @meh		A handle for the ME to be unlinked.
+ *
+ * Return	0 On success.
+ *		-ENOENT If @meh does not point to a valid ME.
  *
- * \retval 0       On success.
- * \retval -ENOENT If \a meh does not point to a valid ME.
  * \see LNetMDUnlink() for the discussion on delivering unlink event.
  */
 int
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 185ea51..875d289 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -701,15 +701,16 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 /**
- * \param msg The message to be sent.
- * \param do_send True if lnet_ni_send() should be called in this function.
- *	  lnet_send() is going to lnet_net_unlock immediately after this, so
- *	  it sets do_send FALSE and I don't do the unlock/send/lock bit.
+ * @msg		The message to be sent.
+ * @do_send	True if lnet_ni_send() should be called in this function.
+ *		lnet_send() is going to lnet_net_unlock immediately after this,
+ *		so it sets do_send FALSE and I don't do the unlock/send/lock
+ *		bit.
  *
- * \retval LNET_CREDIT_OK If \a msg sent or OK to send.
- * \retval LNET_CREDIT_WAIT If \a msg blocked for credit.
- * \retval -EHOSTUNREACH If the next hop of the message appears dead.
- * \retval -ECANCELED If the MD of the message has been unlinked.
+ * Return:	LNET_CREDIT_OK If @msg sent or OK to send.
+ *		LNET_CREDIT_WAIT If @msg blocked for credit.
+ *		-EHOSTUNREACH If the next hop of the message appears dead.
+ *		-ECANCELED If the MD of the message has been unlinked.
  */
 static int
 lnet_post_send_locked(struct lnet_msg *msg, int do_send)
@@ -2239,9 +2240,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 /**
- * \retval LNET_CREDIT_OK	If \a msg is forwarded
- * \retval LNET_CREDIT_WAIT	If \a msg is blocked because w/o buffer
- * \retval -ve			error code
+ * Return:	LNET_CREDIT_OK if @msg is forwarded
+ *		LNET_CREDIT_WAIT if @msg is blocked because w/o buffer
+ *		-ve error code
  */
 int
 lnet_parse_forward_locked(struct lnet_ni *ni, struct lnet_msg *msg)
@@ -2706,7 +2707,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
  * delivery.
  *
  * The local events will be logged in the EQ associated with the MD pointed to
- * by \a mdh handle. Using a MD without an associated EQ results in these
+ * by @mdh handle. Using a MD without an associated EQ results in these
  * events being discarded. In this case, the caller must have another
  * mechanism (e.g., a higher level protocol) for determining when it is safe
  * to modify the memory region associated with the MD.
@@ -2714,28 +2715,29 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
  * Note that LNet does not guarantee the order of LNET_EVENT_SEND and
  * LNET_EVENT_ACK, though intuitively ACK should happen after SEND.
  *
- * \param self Indicates the NID of a local interface through which to send
- * the PUT request. Use LNET_NID_ANY to let LNet choose one by itself.
- * \param mdh A handle for the MD that describes the memory to be sent. The MD
- * must be "free floating" (See LNetMDBind()).
- * \param ack Controls whether an acknowledgment is requested.
- * Acknowledgments are only sent when they are requested by the initiating
- * process and the target MD enables them.
- * \param target A process identifier for the target process.
- * \param portal The index in the \a target's portal table.
- * \param match_bits The match bits to use for MD selection at the target
- * process.
- * \param offset The offset into the target MD (only used when the target
- * MD has the LNET_MD_MANAGE_REMOTE option set).
- * \param hdr_data 64 bits of user data that can be included in the message
- * header. This data is written to an event queue entry at the target if an
- * EQ is present on the matching MD.
+ * @self	Indicates the NID of a local interface through which to send
+ *		the PUT request. Use LNET_NID_ANY to let LNet choose one by
+ *		itself.
+ * @mdh		A handle for the MD that describes the memory to be sent.
+ *		The MD must be "free floating" (See LNetMDBind()).
+ * @ack		Controls whether an acknowledgment is requested.
+ *		Acknowledgments are only sent when they are requested by
+ *		the initiating process and the target MD enables them.
+ * @target	A process identifier for the target process.
+ * @portal	The index in the @target's portal table.
+ * @match_bits	The match bits to use for MD selection at the target
+ *		process.
+ * @offset	The offset into the target MD (only used when the target
+ *		MD has the LNET_MD_MANAGE_REMOTE option set).
+ * @hdr_data	64 bits of user data that can be included in the message
+ *		header. This data is written to an event queue entry at
+ *		the target if an EQ is present on the matching MD.
  *
- * \retval  0      Success, and only in this case events will be generated
- * and logged to EQ (if it exists).
- * \retval -EIO    Simulated failure.
- * \retval -ENOMEM Memory allocation failure.
- * \retval -ENOENT Invalid MD object.
+ * Return:	0 Success, and only in this case events will be generated
+ *		and logged to EQ (if it exists).
+ *		-EIO  Simulated failure.
+ *		-ENOMEM Memory allocation failure.
+ *		-ENOENT Invalid MD object.
  *
  * \see lnet_event::hdr_data and lnet_event_kind.
  */
@@ -2935,16 +2937,21 @@ struct lnet_msg *
  * On the target node, an LNET_EVENT_GET is logged when the GET request
  * arrives and is accepted into a MD.
  *
- * \param self,target,portal,match_bits,offset See the discussion in LNetPut().
- * \param mdh A handle for the MD that describes the memory into which the
- * requested data will be received. The MD must be "free floating"
- * (See LNetMDBind()).
+ * @self	See the discussion in LNetPut().
+ * @target
+ * @portal
+ * @match_bits
+ * @offset
  *
- * \retval  0      Success, and only in this case events will be generated
- * and logged to EQ (if it exists) of the MD.
- * \retval -EIO    Simulated failure.
- * \retval -ENOMEM Memory allocation failure.
- * \retval -ENOENT Invalid MD object.
+ * @mdh		A handle for the MD that describes the memory into which the
+ *		requested data will be received. The MD must be "free floating"
+ *		(See LNetMDBind()).
+ *
+ * Return:	0 Success, and only in this case events will be generated
+ *		and logged to EQ (if it exists) of the MD.
+ *		-EIO Simulated failure.
+ *		-ENOMEM Memory allocation failure.
+ *		-ENOENT Invalid MD object.
  */
 int
 LNetGet(lnet_nid_t self, struct lnet_handle_md mdh,
@@ -3024,18 +3031,20 @@ struct lnet_msg *
 EXPORT_SYMBOL(LNetGet);
 
 /**
- * Calculate distance to node at \a dstnid.
+ * Calculate distance to node at @dstnid.
+ *
+ * @dstnid	Target NID.
+ * @srcnidp	If not NULL, NID of the local interface to reach @dstnid
+ *		is saved here.
+ * @orderp	If not NULL, order of the route to reach @dstnid is saved
+ *		here.
+ *
+ * Return:	0 If @dstnid belongs to a local interface, and reserved
+ *		option local_nid_dist_zero is set, which is the default.
  *
- * \param dstnid Target NID.
- * \param srcnidp If not NULL, NID of the local interface to reach \a dstnid
- * is saved here.
- * \param orderp If not NULL, order of the route to reach \a dstnid is saved
- * here.
+ *		positives Distance to target NID, i.e. number of hops plus one.
  *
- * \retval 0 If \a dstnid belongs to a local interface, and reserved option
- * local_nid_dist_zero is set, which is the default.
- * \retval positives Distance to target NID, i.e. number of hops plus one.
- * \retval -EHOSTUNREACH If \a dstnid is not reachable.
+ *		-EHOSTUNREACH If @dstnid is not reachable.
  */
 int
 LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, u32 *orderp)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 4a12d86..ae061e8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -894,10 +894,10 @@ struct list_head *
  * especially vulnerable since the connections to its neighbor routers are
  * shared among all clients.
  *
- * \param portal Index of the portal to enable the lazy attribute on.
+ * @portal	Index of the portal to enable the lazy attribute on.
  *
- * \retval 0       On success.
- * \retval -EINVAL If \a portal is not a valid index.
+ * Return:	0 On success.
+ *		-EINVAL If @portal is not a valid index.
  */
 int
 LNetSetLazyPortal(int portal)
@@ -975,10 +975,10 @@ struct list_head *
  * Turn off the lazy portal attribute. Delayed requests on the portal,
  * if any, will be all dropped when this function returns.
  *
- * \param portal Index of the portal to disable the lazy attribute on.
+ * @portal	Index of the portal to disable the lazy attribute on.
  *
- * \retval 0       On success.
- * \retval -EINVAL If \a portal is not a valid index.
+ * Return:	0 On success.
+ *		-EINVAL If @portal is not a valid index.
  */
 int
 LNetClearLazyPortal(int portal)
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 130a7c9..76fb61d4 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -47,7 +47,7 @@ struct lnet_drop_rule {
 	struct list_head	dr_link;
 	/** attributes of this rule */
 	struct lnet_fault_attr	dr_attr;
-	/** lock to protect \a dr_drop_at and \a dr_stat */
+	/** lock to protect @dr_drop_at and @dr_stat */
 	spinlock_t		dr_lock;
 	/**
 	 * the message sequence to drop, which means message is dropped when
@@ -188,10 +188,10 @@ struct lnet_drop_rule {
 }
 
 /**
- * Remove matched drop rules from lnet, all rules that can match \a src and
- * \a dst will be removed.
- * If \a src is zero, then all rules have \a dst as destination will be remove
- * If \a dst is zero, then all rules have \a src as source will be removed
+ * Remove matched drop rules from lnet, all rules that can match @src and
+ * @dst will be removed.
+ * If @src is zero, then all rules have @dst as destination will be remove
+ * If @dst is zero, then all rules have @src as source will be removed
  * If both of them are zero, all rules will be removed
  */
 static int
@@ -233,7 +233,7 @@ struct lnet_drop_rule {
 }
 
 /**
- * List drop rule at position of \a pos
+ * List drop rule at position of @pos
  */
 static int
 lnet_drop_rule_list(int pos, struct lnet_fault_attr *attr,
@@ -349,7 +349,7 @@ struct lnet_drop_rule {
 }
 
 /**
- * Check if message from \a src to \a dst can match any existed drop rule
+ * Check if message from @src to @dst can match any existed drop rule
  */
 bool
 lnet_drop_rule_match(struct lnet_hdr *hdr)
@@ -395,7 +395,7 @@ struct lnet_delay_rule {
 	struct list_head	dl_sched_link;
 	/** attributes of this rule */
 	struct lnet_fault_attr	dl_attr;
-	/** lock to protect \a below members */
+	/** lock to protect @below members */
 	spinlock_t		dl_lock;
 	/** refcount of delay rule */
 	atomic_t		dl_refcount;
@@ -423,7 +423,7 @@ struct lnet_delay_rule {
 struct delay_daemon_data {
 	/** serialise rule add/remove */
 	struct mutex		dd_mutex;
-	/** protect rules on \a dd_sched_rules */
+	/** protect rules on @dd_sched_rules */
 	spinlock_t		dd_lock;
 	/** scheduled delay rules (by timer) */
 	struct list_head	dd_sched_rules;
@@ -520,7 +520,7 @@ struct delay_daemon_data {
 }
 
 /**
- * check if \a msg can match any Delay Rule, receiving of this message
+ * check if @msg can match any Delay Rule, receiving of this message
  * will be delayed if there is a match.
  */
 bool
@@ -792,11 +792,11 @@ struct delay_daemon_data {
 }
 
 /**
- * Remove matched Delay Rules from lnet, if \a shutdown is true or both \a src
- * and \a dst are zero, all rules will be removed, otherwise only matched rules
+ * Remove matched Delay Rules from lnet, if @shutdown is true or both @src
+ * and @dst are zero, all rules will be removed, otherwise only matched rules
  * will be removed.
- * If \a src is zero, then all rules have \a dst as destination will be remove
- * If \a dst is zero, then all rules have \a src as source will be removed
+ * If @src is zero, then all rules have @dst as destination will be remove
+ * If @dst is zero, then all rules have @src as source will be removed
  *
  * When a delay rule is removed, all delayed messages of this rule will be
  * processed immediately.
@@ -871,7 +871,7 @@ struct delay_daemon_data {
 }
 
 /**
- * List Delay Rule at position of \a pos
+ * List Delay Rule at position of @pos
  */
 int
 lnet_delay_rule_list(int pos, struct lnet_fault_attr *attr,
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 2df9ce4..892b28e 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -153,11 +153,11 @@ struct addrrange {
 /**
  * Parses \<addrrange\> token on the syntax.
  *
- * Allocates struct addrrange and links to \a nidrange via
+ * Allocates struct addrrange and links to nidrange via
  * (nidrange::nr_addrranges)
  *
- * \retval 0 if \a src parses to '*' | \<ipaddr_range\> | \<cfs_expr_list\>
- * \retval -errno otherwise
+ * Return:	0 if @src parses to '*' | \<ipaddr_range\> | \<cfs_expr_list\>
+ *		-errno otherwise
  */
 static int
 parse_addrange(const struct cfs_lstr *src, struct nidrange *nidrange)
@@ -183,12 +183,12 @@ struct addrrange {
 /**
  * Finds or creates struct nidrange.
  *
- * Checks if \a src is a valid network name, looks for corresponding
- * nidrange on the ist of nidranges (\a nidlist), creates new struct
+ * Checks if @src is a valid network name, looks for corresponding
+ * nidrange on the ist of nidranges (@nidlist), creates new struct
  * nidrange if it is not found.
  *
- * \retval pointer to struct nidrange matching network specified via \a src
- * \retval NULL if \a src does not match any network
+ * Return:	pointer to struct nidrange matching network specified via @src
+ *		NULL if @src does not match any network
  */
 static struct nidrange *
 add_nidrange(const struct cfs_lstr *src,
@@ -243,8 +243,8 @@ struct addrrange {
 /**
  * Parses \<nidrange\> token of the syntax.
  *
- * \retval 1 if \a src parses to \<addrrange\> '@' \<net\>
- * \retval 0 otherwise
+ * Return:	1 if @src parses to \<addrrange\> '@' \<net\>
+ *		0 otherwise
  */
 static int
 parse_nidrange(struct cfs_lstr *src, struct list_head *nidlist)
@@ -272,12 +272,10 @@ struct addrrange {
 }
 
 /**
- * Frees addrrange structures of \a list.
+ * Frees addrrange structures of @list.
  *
- * For each struct addrrange structure found on \a list it frees
+ * For each struct addrrange structure found on @list it frees
  * cfs_expr_list list attached to it and frees the addrrange itself.
- *
- * \retval none
  */
 static void
 free_addrranges(struct list_head *list)
@@ -295,12 +293,10 @@ struct addrrange {
 }
 
 /**
- * Frees nidrange strutures of \a list.
+ * Frees nidrange strutures of @list.
  *
- * For each struct nidrange structure found on \a list it frees
+ * For each struct nidrange structure found on @list it frees
  * addrrange list attached to it and frees the nidrange itself.
- *
- * \retval none
  */
 void
 cfs_free_nidlist(struct list_head *list)
@@ -320,15 +316,13 @@ struct addrrange {
 /**
  * Parses nid range list.
  *
- * Parses with rigorous syntax and overflow checking \a str into
- * \<nidrange\> [ ' ' \<nidrange\> ], compiles \a str into set of
- * structures and links that structure to \a nidlist. The resulting
- * list can be used to match a NID againts set of NIDS defined by \a
- * str.
- * \see cfs_match_nid
+ * Parses with rigorous syntax and overflow checking @str into
+ * \<nidrange\> [ ' ' \<nidrange\> ], compiles @str into set of
+ * structures and links that structure to @nidlist. The resulting
+ * list can be used to match a NID againts set of NIDS defined by
+ * @str. See cfs_match_nid
  *
- * \retval 1 on success
- * \retval 0 otherwise
+ * Return:	1 on success 0 otherwise
  */
 int
 cfs_parse_nidlist(char *str, int len, struct list_head *nidlist)
@@ -357,12 +351,11 @@ struct addrrange {
 EXPORT_SYMBOL(cfs_parse_nidlist);
 
 /**
- * Matches a nid (\a nid) against the compiled list of nidranges (\a nidlist).
+ * Matches a nid (@nid) against the compiled list of nidranges (@nidlist).
  *
  * \see cfs_parse_nidlist()
  *
- * \retval 1 on match
- * \retval 0  otherwises
+ * Return:	1 on match, 0 otherwises
  */
 int cfs_match_nid(lnet_nid_t nid, struct list_head *nidlist)
 {
@@ -386,9 +379,9 @@ int cfs_match_nid(lnet_nid_t nid, struct list_head *nidlist)
 EXPORT_SYMBOL(cfs_match_nid);
 
 /**
- * Print the network part of the nidrange \a nr into the specified \a buffer.
+ * Print the network part of the nidrange @nr into the specified @buffer.
  *
- * \retval number of characters written
+ * Return:	number of characters written
  */
 static int
 cfs_print_network(char *buffer, int count, struct nidrange *nr)
@@ -403,10 +396,10 @@ int cfs_match_nid(lnet_nid_t nid, struct list_head *nidlist)
 }
 
 /**
- * Print a list of addrrange (\a addrranges) into the specified \a buffer.
- * At max \a count characters can be printed into \a buffer.
+ * Print a list of addrrange (@addrranges) into the specified @buffer.
+ * At max @count characters can be printed into @buffer.
  *
- * \retval number of characters written
+ * Return:	number of characters written
  */
 static int
 cfs_print_addrranges(char *buffer, int count, struct list_head *addrranges,
@@ -427,11 +420,11 @@ int cfs_match_nid(lnet_nid_t nid, struct list_head *nidlist)
 }
 
 /**
- * Print a list of nidranges (\a nidlist) into the specified \a buffer.
- * At max \a count characters can be printed into \a buffer.
+ * Print a list of nidranges (@nidlist) into the specified @buffer.
+ * At max @count characters can be printed into @buffer.
  * Nidranges are separated by a space character.
  *
- * \retval number of characters written
+ * Return:	number of characters written
  */
 int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 {
@@ -462,9 +455,9 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
  * Determines minimum and maximum addresses for a single
  * numeric address range
  *
- * \param	ar
- * \param	min_nid
- * \param	max_nid
+ * @ar
+ * @min_nid
+ * @max_nid
  */
 static void cfs_ip_ar_min_max(struct addrrange *ar, u32 *min_nid,
 			      u32 *max_nid)
@@ -501,9 +494,9 @@ static void cfs_ip_ar_min_max(struct addrrange *ar, u32 *min_nid,
  * Determines minimum and maximum addresses for a single
  * numeric address range
  *
- * \param	ar
- * \param	min_nid
- * \param	max_nid
+ * @ar
+ * @min_nid
+ * @max_nid
  */
 static void cfs_num_ar_min_max(struct addrrange *ar, u32 *min_nid,
 			       u32 *max_nid)
@@ -532,10 +525,10 @@ static void cfs_num_ar_min_max(struct addrrange *ar, u32 *min_nid,
  * Determines whether an expression list in an nidrange contains exactly
  * one contiguous address range. Calls the correct netstrfns for the LND
  *
- * \param	*nidlist
+ * @nidlist
  *
- * \retval	true if contiguous
- * \retval	false if not contiguous
+ * Return:	true if contiguous
+ *		false if not contiguous
  */
 bool cfs_nidrange_is_contiguous(struct list_head *nidlist)
 {
@@ -570,10 +563,10 @@ bool cfs_nidrange_is_contiguous(struct list_head *nidlist)
  * Determines whether an expression list in an num nidrange contains exactly
  * one contiguous address range.
  *
- * \param	*nidlist
+ * @nidlist
  *
- * \retval	true if contiguous
- * \retval	false if not contiguous
+ * Return:	true if contiguous
+ *		false if not contiguous
  */
 static bool cfs_num_is_contiguous(struct list_head *nidlist)
 {
@@ -616,10 +609,10 @@ static bool cfs_num_is_contiguous(struct list_head *nidlist)
  * Determines whether an expression list in an ip nidrange contains exactly
  * one contiguous address range.
  *
- * \param	*nidlist
+ * @nidlist
  *
- * \retval	true if contiguous
- * \retval	false if not contiguous
+ * Return:	true if contiguous
+ *		false if not contiguous
  */
 static bool cfs_ip_is_contiguous(struct list_head *nidlist)
 {
@@ -669,9 +662,9 @@ static bool cfs_ip_is_contiguous(struct list_head *nidlist)
  * Takes a linked list of nidrange expressions, determines the minimum
  * and maximum nid and creates appropriate nid structures
  *
- * \param	*nidlist
- * \param	*min_nid
- * \param	*max_nid
+ * @nidlist
+ * @min_nid
+ * @max_nid
  */
 void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 			       char *max_nid, size_t nidstr_length)
@@ -706,9 +699,9 @@ void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 /**
  * Determines the min and max NID values for num LNDs
  *
- * \param	*nidlist
- * \param	*min_nid
- * \param	*max_nid
+ * @nidlist
+ * @min_nid
+ * @max_nid
  */
 static void cfs_num_min_max(struct list_head *nidlist, u32 *min_nid,
 			    u32 *max_nid)
@@ -738,9 +731,9 @@ static void cfs_num_min_max(struct list_head *nidlist, u32 *min_nid,
  * Takes an nidlist and determines the minimum and maximum
  * ip addresses.
  *
- * \param	*nidlist
- * \param	*min_nid
- * \param	*max_nid
+ * @nidlist
+ * @min_nid
+ * @max_nid
  */
 static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 			   u32 *max_nid)
@@ -868,10 +861,9 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 }
 
 /**
- * Matches address (\a addr) against address set encoded in \a list.
+ * Matches address (@addr) against address set encoded in @list.
  *
- * \retval 1 if \a addr matches
- * \retval 0 otherwise
+ * Return: 1 if @addr matches, 0 otherwise
  */
 int
 cfs_ip_addr_match(u32 addr, struct list_head *list)
@@ -920,8 +912,8 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
  *
  * Examples of such networks are gm and elan.
  *
- * \retval 0 if \a str parsed to numeric address
- * \retval errno otherwise
+ * Return:	0 if @str parsed to numeric address
+ *		errno otherwise
  */
 static int
 libcfs_num_parse(char *str, int len, struct list_head *list)
@@ -952,8 +944,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 /*
  * Nf_match_addr method for networks using numeric addresses
  *
- * \retval 1 on match
- * \retval 0 otherwise
+ * Return:	1 on match, 0 otherwise
  */
 static int
 libcfs_num_match(u32 addr, struct list_head *numaddr)
-- 
1.8.3.1
