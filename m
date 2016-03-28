From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:23 -0400
Subject: [lustre-devel] [PATCH 3/9] staging: lustre: libcfs: remove atomic
	cpt allocations
In-Reply-To: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
References: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459124789-20758-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, frank zago <fzago@cray.com>, James Simmons <uja.ornl@yahoo.com>

libcfs contains functions to perform atomic memory
operations. These functions have never been used
so remove them.

Signed-off-by: frank zago <fzago@cray.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/15913
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    6 ---
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |   41 --------------------
 2 files changed, 0 insertions(+), 47 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index dab4862..63e394e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -351,12 +351,6 @@ void cfs_percpt_lock_free(struct cfs_percpt_lock *pcl);
 void cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index);
 /* unlock private lock \a index of \a pcl */
 void cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index);
-/* create percpt (atomic) refcount based on @cptab */
-atomic_t **cfs_percpt_atomic_alloc(struct cfs_cpt_table *cptab, int val);
-/* destroy percpt refcount */
-void cfs_percpt_atomic_free(atomic_t **refs);
-/* return sum of all percpu refs */
-int cfs_percpt_atomic_summary(atomic_t **refs);
 
 /** Compile-time assertion.
 
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index 2de9eea..d38954a 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -142,44 +142,3 @@ cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index)
 	}
 }
 EXPORT_SYMBOL(cfs_percpt_unlock);
-
-/** free cpu-partition refcount */
-void
-cfs_percpt_atomic_free(atomic_t **refs)
-{
-	cfs_percpt_free(refs);
-}
-EXPORT_SYMBOL(cfs_percpt_atomic_free);
-
-/** allocate cpu-partition refcount with initial value @init_val */
-atomic_t **
-cfs_percpt_atomic_alloc(struct cfs_cpt_table *cptab, int init_val)
-{
-	atomic_t	**refs;
-	atomic_t	*ref;
-	int		i;
-
-	refs = cfs_percpt_alloc(cptab, sizeof(*ref));
-	if (!refs)
-		return NULL;
-
-	cfs_percpt_for_each(ref, i, refs)
-		atomic_set(ref, init_val);
-	return refs;
-}
-EXPORT_SYMBOL(cfs_percpt_atomic_alloc);
-
-/** return sum of cpu-partition refs */
-int
-cfs_percpt_atomic_summary(atomic_t **refs)
-{
-	atomic_t	*ref;
-	int		i;
-	int		val = 0;
-
-	cfs_percpt_for_each(ref, i, refs)
-		val += atomic_read(ref);
-
-	return val;
-}
-EXPORT_SYMBOL(cfs_percpt_atomic_summary);
-- 
1.7.1
