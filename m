From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:40 -0500
Subject: [lustre-devel] [PATCH 06/10] staging: lustre: libcfs: use bit macro
	in libcfs headers
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Use the BIT macros instead of (1 << ***) in libcfs
headers.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/curproc.h  |   18 ++++----
 .../lustre/include/linux/libcfs/libcfs_fail.h      |    4 +-
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   42 ++++++++++----------
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 4 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
index be0675d..6469a67 100644
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
@@ -65,15 +65,15 @@
 #define CFS_CAP_SYS_BOOT	       23
 #define CFS_CAP_SYS_RESOURCE	   24
 
-#define CFS_CAP_FS_MASK ((1 << CFS_CAP_CHOWN) |		 \
-			 (1 << CFS_CAP_DAC_OVERRIDE) |	  \
-			 (1 << CFS_CAP_DAC_READ_SEARCH) |       \
-			 (1 << CFS_CAP_FOWNER) |		\
-			 (1 << CFS_CAP_FSETID) |	       \
-			 (1 << CFS_CAP_LINUX_IMMUTABLE) |       \
-			 (1 << CFS_CAP_SYS_ADMIN) |	     \
-			 (1 << CFS_CAP_SYS_BOOT) |	      \
-			 (1 << CFS_CAP_SYS_RESOURCE))
+#define CFS_CAP_FS_MASK (BIT(CFS_CAP_CHOWN) |		\
+			 BIT(CFS_CAP_DAC_OVERRIDE) |	\
+			 BIT(CFS_CAP_DAC_READ_SEARCH) |	\
+			 BIT(CFS_CAP_FOWNER) |		\
+			 BIT(CFS_CAP_FSETID) |		\
+			 BIT(CFS_CAP_LINUX_IMMUTABLE) | \
+			 BIT(CFS_CAP_SYS_ADMIN) |	\
+			 BIT(CFS_CAP_SYS_BOOT) |	\
+			 BIT(CFS_CAP_SYS_RESOURCE))
 
 void cfs_cap_raise(cfs_cap_t cap);
 void cfs_cap_lower(cfs_cap_t cap);
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index f06b4aa..6f019a4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -55,11 +55,11 @@ enum {
 
 #define CFS_FAILED_BIT       30
 /* CFS_FAILED is 0x40000000 */
-#define CFS_FAILED	  (1 << CFS_FAILED_BIT)
+#define CFS_FAILED		BIT(CFS_FAILED_BIT)
 
 #define CFS_FAIL_ONCE_BIT    31
 /* CFS_FAIL_ONCE is 0x80000000 */
-#define CFS_FAIL_ONCE       (1 << CFS_FAIL_ONCE_BIT)
+#define CFS_FAIL_ONCE		BIT(CFS_FAIL_ONCE_BIT)
 
 /* The following flags aren't made to be combined */
 #define CFS_FAIL_SKIP	0x20000000 /* skip N times then fail */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 2f56707..85661b3 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -125,36 +125,36 @@ enum cfs_hash_tag {
 	 *  . Some functions will be disabled with this flag, i.e:
 	 *    cfs_hash_for_each_empty, cfs_hash_rehash
 	 */
-	CFS_HASH_NO_LOCK	= 1 << 0,
+	CFS_HASH_NO_LOCK	= BIT(0),
 	/** no bucket lock, use one spinlock to protect the whole hash */
-	CFS_HASH_NO_BKTLOCK	= 1 << 1,
+	CFS_HASH_NO_BKTLOCK	= BIT(1),
 	/** rwlock to protect bucket */
-	CFS_HASH_RW_BKTLOCK	= 1 << 2,
+	CFS_HASH_RW_BKTLOCK	= BIT(2),
 	/** spinlock to protect bucket */
-	CFS_HASH_SPIN_BKTLOCK	= 1 << 3,
+	CFS_HASH_SPIN_BKTLOCK	= BIT(3),
 	/** always add new item to tail */
-	CFS_HASH_ADD_TAIL	= 1 << 4,
+	CFS_HASH_ADD_TAIL	= BIT(4),
 	/** hash-table doesn't have refcount on item */
-	CFS_HASH_NO_ITEMREF	= 1 << 5,
+	CFS_HASH_NO_ITEMREF	= BIT(5),
 	/** big name for param-tree */
-	CFS_HASH_BIGNAME	= 1 << 6,
+	CFS_HASH_BIGNAME	= BIT(6),
 	/** track global count */
-	CFS_HASH_COUNTER	= 1 << 7,
+	CFS_HASH_COUNTER	= BIT(7),
 	/** rehash item by new key */
-	CFS_HASH_REHASH_KEY	= 1 << 8,
+	CFS_HASH_REHASH_KEY	= BIT(8),
 	/** Enable dynamic hash resizing */
-	CFS_HASH_REHASH		= 1 << 9,
+	CFS_HASH_REHASH		= BIT(9),
 	/** can shrink hash-size */
-	CFS_HASH_SHRINK		= 1 << 10,
+	CFS_HASH_SHRINK		= BIT(10),
 	/** assert hash is empty on exit */
-	CFS_HASH_ASSERT_EMPTY	= 1 << 11,
+	CFS_HASH_ASSERT_EMPTY	= BIT(11),
 	/** record hlist depth */
-	CFS_HASH_DEPTH		= 1 << 12,
+	CFS_HASH_DEPTH		= BIT(12),
 	/**
 	 * rehash is always scheduled in a different thread, so current
 	 * change on hash table is non-blocking
 	 */
-	CFS_HASH_NBLK_CHANGE	= 1 << 13,
+	CFS_HASH_NBLK_CHANGE	= BIT(13),
 	/**
 	 * NB, we typed hs_flags as  __u16, please change it
 	 * if you need to extend >=16 flags
@@ -323,20 +323,20 @@ struct cfs_hash_ops {
 
 /** total number of buckets in @hs */
 #define CFS_HASH_NBKT(hs)	\
-	(1U << ((hs)->hs_cur_bits - (hs)->hs_bkt_bits))
+	BIT((hs)->hs_cur_bits - (hs)->hs_bkt_bits)
 
 /** total number of buckets in @hs while rehashing */
 #define CFS_HASH_RH_NBKT(hs)	\
-	(1U << ((hs)->hs_rehash_bits - (hs)->hs_bkt_bits))
+	BIT((hs)->hs_rehash_bits - (hs)->hs_bkt_bits)
 
 /** number of hlist for in bucket */
-#define CFS_HASH_BKT_NHLIST(hs) (1U << (hs)->hs_bkt_bits)
+#define CFS_HASH_BKT_NHLIST(hs)	BIT((hs)->hs_bkt_bits)
 
 /** total number of hlist in @hs */
-#define CFS_HASH_NHLIST(hs)     (1U << (hs)->hs_cur_bits)
+#define CFS_HASH_NHLIST(hs)	BIT((hs)->hs_cur_bits)
 
 /** total number of hlist in @hs while rehashing */
-#define CFS_HASH_RH_NHLIST(hs)  (1U << (hs)->hs_rehash_bits)
+#define CFS_HASH_RH_NHLIST(hs)	BIT((hs)->hs_rehash_bits)
 
 static inline int
 cfs_hash_with_no_lock(struct cfs_hash *hs)
@@ -775,8 +775,8 @@ void cfs_hash_rehash_key(struct cfs_hash *hs, const void *old_key,
 #endif /* CFS_HASH_DEBUG_LEVEL */
 
 #define CFS_HASH_THETA_BITS	10
-#define CFS_HASH_MIN_THETA	(1U << (CFS_HASH_THETA_BITS - 1))
-#define CFS_HASH_MAX_THETA	(1U << (CFS_HASH_THETA_BITS + 1))
+#define CFS_HASH_MIN_THETA	BIT(CFS_HASH_THETA_BITS - 1)
+#define CFS_HASH_MAX_THETA	BIT(CFS_HASH_THETA_BITS + 1)
 
 /* Return integer component of theta */
 static inline int __cfs_hash_theta_int(int theta)
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 14ca82d..43868ed 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1981,7 +1981,7 @@ int lu_site_stats_print(const struct lu_site *s, struct seq_file *m)
 	memset(&stats, 0, sizeof(stats));
 	lu_site_stats_get(s->ls_obj_hash, &stats, 1);
 
-	seq_printf(m, "%d/%d %d/%d %d %d %d %d %d %d %d %d\n",
+	seq_printf(m, "%d/%d %d/%ld %d %d %d %d %d %d %d %d\n",
 		   stats.lss_busy,
 		   stats.lss_total,
 		   stats.lss_populated,
-- 
1.7.1
