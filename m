From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:26 -0400
Subject: [lustre-devel] [PATCH 6/9] staging: lustre: libcfs: add lock-class
	for cfs_percpt_lock
In-Reply-To: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
References: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459124789-20758-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

initialise lock-class for each sublock of cfs_percpt_lock
to eliminate false alarm ""possible recursive locking detected"

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6432
Reviewed-on: http://review.whamcloud.com/14368
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |   19 +++++++++++++++++--
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |   13 ++++++++++---
 2 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 71ad93b..81d8079 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -256,8 +256,8 @@ struct cfs_percpt_lock {
  * create a cpu-partition lock based on CPU partition table \a cptab,
  * each private lock has extra \a psize bytes padding data
  */
-struct cfs_percpt_lock *cfs_percpt_lock_alloc(struct cfs_cpt_table *cptab);
-
+struct cfs_percpt_lock *cfs_percpt_lock_create(struct cfs_cpt_table *cptab,
+					       struct lock_class_key *keys);
 /* destroy a cpu-partition lock */
 void cfs_percpt_lock_free(struct cfs_percpt_lock *pcl);
 
@@ -267,6 +267,21 @@ void cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index);
 /* unlock private lock \a index of \a pcl */
 void cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index);
 
+#define CFS_PERCPT_LOCK_KEYS	256
+
+/* NB: don't allocate keys dynamically, lockdep needs them to be in ".data" */
+#define cfs_percpt_lock_alloc(cptab)					\
+({									\
+	static struct lock_class_key ___keys[CFS_PERCPT_LOCK_KEYS];	\
+	struct cfs_percpt_lock *___lk;					\
+									\
+	if (cfs_cpt_number(cptab) > CFS_PERCPT_LOCK_KEYS)		\
+		___lk = cfs_percpt_lock_create(cptab, NULL);		\
+	else								\
+		___lk = cfs_percpt_lock_create(cptab, ___keys);		\
+	___lk;								\
+})
+
 /**
  * iterate over all CPU partitions in \a cptab
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index d38954a..83543f9 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -49,7 +49,8 @@ EXPORT_SYMBOL(cfs_percpt_lock_free);
  * reason we always allocate cacheline-aligned memory block.
  */
 struct cfs_percpt_lock *
-cfs_percpt_lock_alloc(struct cfs_cpt_table *cptab)
+cfs_percpt_lock_create(struct cfs_cpt_table *cptab,
+		       struct lock_class_key *keys)
 {
 	struct cfs_percpt_lock	*pcl;
 	spinlock_t		*lock;
@@ -67,12 +68,18 @@ cfs_percpt_lock_alloc(struct cfs_cpt_table *cptab)
 		return NULL;
 	}
 
-	cfs_percpt_for_each(lock, i, pcl->pcl_locks)
+	if (!keys)
+		CWARN("Cannot setup class key for percpt lock, you may see recursive locking warnings which are actually fake.\n");
+
+	cfs_percpt_for_each(lock, i, pcl->pcl_locks) {
 		spin_lock_init(lock);
+		if (keys != NULL)
+			lockdep_set_class(lock, &keys[i]);
+	}
 
 	return pcl;
 }
-EXPORT_SYMBOL(cfs_percpt_lock_alloc);
+EXPORT_SYMBOL(cfs_percpt_lock_create);
 
 /**
  * lock a CPU partition
-- 
1.7.1
