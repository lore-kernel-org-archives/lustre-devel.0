From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:43 -0500
Subject: [lustre-devel] [PATCH 09/10] staging: lustre: libcfs: remove zero
	comparisons in headers
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove the zero comparisions in the libcfs headers.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |    2 +-
 .../lustre/include/linux/libcfs/libcfs_fail.h      |    4 +-
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   32 ++++++++++----------
 3 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index a0865e5..8f34c5d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -137,7 +137,7 @@ static inline unsigned char cfs_crypto_hash_alg(const char *algname)
 	enum cfs_crypto_hash_alg hash_alg;
 
 	for (hash_alg = 0; hash_alg < CFS_HASH_ALG_MAX; hash_alg++)
-		if (strcmp(hash_types[hash_alg].cht_name, algname) == 0)
+		if (!strcmp(hash_types[hash_alg].cht_name, algname))
 			return hash_alg;
 
 	return CFS_HASH_ALG_UNKNOWN;
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index 73cbb47..129047e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -71,7 +71,7 @@ enum {
 
 static inline bool CFS_FAIL_PRECHECK(__u32 id)
 {
-	return cfs_fail_loc != 0 &&
+	return cfs_fail_loc &&
 	       ((cfs_fail_loc & CFS_FAIL_MASK_LOC) == (id & CFS_FAIL_MASK_LOC) ||
 		(cfs_fail_loc & id & CFS_FAULT));
 }
@@ -175,7 +175,7 @@ static inline void cfs_race(__u32 id)
 			cfs_race_state = 0;
 			CERROR("cfs_race id %x sleeping\n", id);
 			rc = wait_event_interruptible(cfs_race_waitq,
-						      cfs_race_state != 0);
+						      !!cfs_race_state);
 			CERROR("cfs_fail_race id %x awake, rc=%d\n", id, rc);
 		} else {
 			CERROR("cfs_fail_race id %x waking\n", id);
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index d0ba3e0..6231f47 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -342,34 +342,34 @@ struct cfs_hash_ops {
 cfs_hash_with_no_lock(struct cfs_hash *hs)
 {
 	/* caller will serialize all operations for this hash-table */
-	return (hs->hs_flags & CFS_HASH_NO_LOCK) != 0;
+	return hs->hs_flags & CFS_HASH_NO_LOCK;
 }
 
 static inline int
 cfs_hash_with_no_bktlock(struct cfs_hash *hs)
 {
 	/* no bucket lock, one single lock to protect the hash-table */
-	return (hs->hs_flags & CFS_HASH_NO_BKTLOCK) != 0;
+	return hs->hs_flags & CFS_HASH_NO_BKTLOCK;
 }
 
 static inline int
 cfs_hash_with_rw_bktlock(struct cfs_hash *hs)
 {
 	/* rwlock to protect hash bucket */
-	return (hs->hs_flags & CFS_HASH_RW_BKTLOCK) != 0;
+	return hs->hs_flags & CFS_HASH_RW_BKTLOCK;
 }
 
 static inline int
 cfs_hash_with_spin_bktlock(struct cfs_hash *hs)
 {
 	/* spinlock to protect hash bucket */
-	return (hs->hs_flags & CFS_HASH_SPIN_BKTLOCK) != 0;
+	return hs->hs_flags & CFS_HASH_SPIN_BKTLOCK;
 }
 
 static inline int
 cfs_hash_with_add_tail(struct cfs_hash *hs)
 {
-	return (hs->hs_flags & CFS_HASH_ADD_TAIL) != 0;
+	return hs->hs_flags & CFS_HASH_ADD_TAIL;
 }
 
 static inline int
@@ -380,55 +380,55 @@ struct cfs_hash_ops {
 	 * item can't be removed from hash unless it's
 	 * ZERO refcount
 	 */
-	return (hs->hs_flags & CFS_HASH_NO_ITEMREF) != 0;
+	return hs->hs_flags & CFS_HASH_NO_ITEMREF;
 }
 
 static inline int
 cfs_hash_with_bigname(struct cfs_hash *hs)
 {
-	return (hs->hs_flags & CFS_HASH_BIGNAME) != 0;
+	return hs->hs_flags & CFS_HASH_BIGNAME;
 }
 
 static inline int
 cfs_hash_with_counter(struct cfs_hash *hs)
 {
-	return (hs->hs_flags & CFS_HASH_COUNTER) != 0;
+	return hs->hs_flags & CFS_HASH_COUNTER;
 }
 
 static inline int
 cfs_hash_with_rehash(struct cfs_hash *hs)
 {
-	return (hs->hs_flags & CFS_HASH_REHASH) != 0;
+	return hs->hs_flags & CFS_HASH_REHASH;
 }
 
 static inline int
 cfs_hash_with_rehash_key(struct cfs_hash *hs)
 {
-	return (hs->hs_flags & CFS_HASH_REHASH_KEY) != 0;
+	return hs->hs_flags & CFS_HASH_REHASH_KEY;
 }
 
 static inline int
 cfs_hash_with_shrink(struct cfs_hash *hs)
 {
-	return (hs->hs_flags & CFS_HASH_SHRINK) != 0;
+	return hs->hs_flags & CFS_HASH_SHRINK;
 }
 
 static inline int
 cfs_hash_with_assert_empty(struct cfs_hash *hs)
 {
-	return (hs->hs_flags & CFS_HASH_ASSERT_EMPTY) != 0;
+	return hs->hs_flags & CFS_HASH_ASSERT_EMPTY;
 }
 
 static inline int
 cfs_hash_with_depth(struct cfs_hash *hs)
 {
-	return (hs->hs_flags & CFS_HASH_DEPTH) != 0;
+	return hs->hs_flags & CFS_HASH_DEPTH;
 }
 
 static inline int
 cfs_hash_with_nblk_change(struct cfs_hash *hs)
 {
-	return (hs->hs_flags & CFS_HASH_NBLK_CHANGE) != 0;
+	return hs->hs_flags & CFS_HASH_NBLK_CHANGE;
 }
 
 static inline int
@@ -442,14 +442,14 @@ struct cfs_hash_ops {
 cfs_hash_is_rehashing(struct cfs_hash *hs)
 {
 	/* rehash is launched */
-	return hs->hs_rehash_bits != 0;
+	return !!hs->hs_rehash_bits;
 }
 
 static inline int
 cfs_hash_is_iterating(struct cfs_hash *hs)
 {
 	/* someone is calling cfs_hash_for_each_* */
-	return hs->hs_iterating || hs->hs_iterators != 0;
+	return hs->hs_iterating || hs->hs_iterators;
 }
 
 static inline int
-- 
1.7.1
