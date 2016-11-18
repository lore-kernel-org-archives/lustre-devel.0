From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:35 -0500
Subject: [lustre-devel] [PATCH 01/10] staging: lustre: libcfs: fixup all
	header block comments
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Properly format the incorrect comments sections
that were reported by checkpatch.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |   10 ++++--
 .../lustre/include/linux/libcfs/libcfs_fail.h      |   30 +++++++++++++------
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   24 ++++++++++-----
 .../lustre/include/linux/libcfs/libcfs_private.h   |    5 ++-
 .../lustre/include/linux/libcfs/libcfs_string.h    |    6 ++-
 5 files changed, 49 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index 02be7d7..a0865e5 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -29,10 +29,12 @@
 #define _LIBCFS_CRYPTO_H
 
 struct cfs_crypto_hash_type {
-	char		*cht_name;      /**< hash algorithm name, equal to
-					 * format name for crypto api */
-	unsigned int    cht_key;	/**< init key by default (valid for
-					 * 4 bytes context like crc32, adler */
+	char		*cht_name;      /*< hash algorithm name, equal to
+					 * format name for crypto api
+					 */
+	unsigned int    cht_key;	/*< init key by default (valid for
+					 * 4 bytes context like crc32, adler
+					 */
 	unsigned int    cht_size;       /**< hash digest size */
 };
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index bdbbe93..b1658c8 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -103,22 +103,28 @@ static inline int cfs_fail_check_set(__u32 id, __u32 value,
 #define CFS_FAIL_CHECK_QUIET(id) \
 	cfs_fail_check_set(id, 0, CFS_FAIL_LOC_NOSET, 1)
 
-/* If id hit cfs_fail_loc and cfs_fail_val == (-1 or value) return 1,
- * otherwise return 0 */
+/*
+ * If id hit cfs_fail_loc and cfs_fail_val == (-1 or value) return 1,
+ * otherwise return 0
+ */
 #define CFS_FAIL_CHECK_VALUE(id, value) \
 	cfs_fail_check_set(id, value, CFS_FAIL_LOC_VALUE, 0)
 #define CFS_FAIL_CHECK_VALUE_QUIET(id, value) \
 	cfs_fail_check_set(id, value, CFS_FAIL_LOC_VALUE, 1)
 
-/* If id hit cfs_fail_loc, cfs_fail_loc |= value and return 1,
- * otherwise return 0 */
+/*
+ * If id hit cfs_fail_loc, cfs_fail_loc |= value and return 1,
+ * otherwise return 0
+ */
 #define CFS_FAIL_CHECK_ORSET(id, value) \
 	cfs_fail_check_set(id, value, CFS_FAIL_LOC_ORSET, 0)
 #define CFS_FAIL_CHECK_ORSET_QUIET(id, value) \
 	cfs_fail_check_set(id, value, CFS_FAIL_LOC_ORSET, 1)
 
-/* If id hit cfs_fail_loc, cfs_fail_loc = value and return 1,
- * otherwise return 0 */
+/*
+ * If id hit cfs_fail_loc, cfs_fail_loc = value and return 1,
+ * otherwise return 0
+ */
 #define CFS_FAIL_CHECK_RESET(id, value) \
 	cfs_fail_check_set(id, value, CFS_FAIL_LOC_RESET, 0)
 #define CFS_FAIL_CHECK_RESET_QUIET(id, value) \
@@ -138,8 +144,10 @@ static inline int cfs_fail_timeout_set(__u32 id, __u32 value, int ms, int set)
 #define CFS_FAIL_TIMEOUT_MS(id, ms) \
 	cfs_fail_timeout_set(id, 0, ms, CFS_FAIL_LOC_NOSET)
 
-/* If id hit cfs_fail_loc, cfs_fail_loc |= value and
- * sleep seconds or milliseconds */
+/*
+ * If id hit cfs_fail_loc, cfs_fail_loc |= value and
+ * sleep seconds or milliseconds
+ */
 #define CFS_FAIL_TIMEOUT_ORSET(id, value, secs) \
 	cfs_fail_timeout_set(id, value, secs * 1000, CFS_FAIL_LOC_ORSET)
 
@@ -152,10 +160,12 @@ static inline int cfs_fail_timeout_set(__u32 id, __u32 value, int ms, int set)
 #define CFS_FAULT_CHECK(id)			\
 	CFS_FAIL_CHECK(CFS_FAULT | (id))
 
-/* The idea here is to synchronise two threads to force a race. The
+/*
+ * The idea here is to synchronise two threads to force a race. The
  * first thread that calls this with a matching fail_loc is put to
  * sleep. The next thread that calls with the same fail_loc wakes up
- * the first and continues. */
+ * the first and continues.
+ */
 static inline void cfs_race(__u32 id)
 {
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index f2b4399..a4ca488 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -57,8 +57,10 @@
 
 /** disable debug */
 #define CFS_HASH_DEBUG_NONE	0
-/** record hash depth and output to console when it's too deep,
- *  computing overhead is low but consume more memory */
+/*
+ * record hash depth and output to console when it's too deep,
+ * computing overhead is low but consume more memory
+ */
 #define CFS_HASH_DEBUG_1	1
 /** expensive, check key validation */
 #define CFS_HASH_DEBUG_2	2
@@ -153,8 +155,10 @@ enum cfs_hash_tag {
 	 * change on hash table is non-blocking
 	 */
 	CFS_HASH_NBLK_CHANGE	= 1 << 13,
-	/** NB, we typed hs_flags as  __u16, please change it
-	 * if you need to extend >=16 flags */
+	/**
+	 * NB, we typed hs_flags as  __u16, please change it
+	 * if you need to extend >=16 flags
+	 */
 };
 
 /** most used attributes */
@@ -201,8 +205,10 @@ enum cfs_hash_tag {
  */
 
 struct cfs_hash {
-	/** serialize with rehash, or serialize all operations if
-	 * the hash-table has CFS_HASH_NO_BKTLOCK */
+	/**
+	 * serialize with rehash, or serialize all operations if
+	 * the hash-table has CFS_HASH_NO_BKTLOCK
+	 */
 	union cfs_hash_lock		hs_lock;
 	/** hash operations */
 	struct cfs_hash_ops		*hs_ops;
@@ -369,9 +375,11 @@ struct cfs_hash_ops {
 static inline int
 cfs_hash_with_no_itemref(struct cfs_hash *hs)
 {
-	/* hash-table doesn't keep refcount on item,
+	/*
+	 * hash-table doesn't keep refcount on item,
 	 * item can't be removed from hash unless it's
-	 * ZERO refcount */
+	 * ZERO refcount
+	 */
 	return (hs->hs_flags & CFS_HASH_NO_ITEMREF) != 0;
 }
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index e0e1a5d..523e8f4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -280,7 +280,7 @@
 #define CFS_FREE_PTR(ptr)       LIBCFS_FREE(ptr, sizeof(*(ptr)))
 
 /** Compile-time assertion.
-
+ *
  * Check an invariant described by a constant expression at compile time by
  * forcing a compiler error if it does not hold.  \a cond must be a constant
  * expression as defined by the ISO C Standard:
@@ -306,7 +306,8 @@
 /* --------------------------------------------------------------------
  * Light-weight trace
  * Support for temporary event tracing with minimal Heisenberg effect.
- * -------------------------------------------------------------------- */
+ * --------------------------------------------------------------------
+ */
 
 #define MKSTR(ptr) ((ptr)) ? (ptr) : ""
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index 0ee60ff..56341d9 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -84,9 +84,11 @@ int cfs_expr_list_values(struct cfs_expr_list *expr_list,
 static inline void
 cfs_expr_list_values_free(__u32 *values, int num)
 {
-	/* This array is allocated by LIBCFS_ALLOC(), so it shouldn't be freed
+	/*
+	 * This array is allocated by LIBCFS_ALLOC(), so it shouldn't be freed
 	 * by OBD_FREE() if it's called by module other than libcfs & LNet,
-	 * otherwise we will see fake memory leak */
+	 * otherwise we will see fake memory leak
+	 */
 	LIBCFS_FREE(values, num * sizeof(values[0]));
 }
 
-- 
1.7.1
