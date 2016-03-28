From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:24 -0400
Subject: [lustre-devel] [PATCH 4/9] staging: lustre: libcfs: remove
	cfs_percpt_[current|index]
In-Reply-To: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
References: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459124789-20758-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, frank zago <fzago@cray.com>, James Simmons <uja.ornl@yahoo.com>

The functions cfs_percpt_current() and cfs_percpt_index()
are not used anywhere. Remove it.

Signed-off-by: frank zago <fzago@cray.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/15913
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    2 -
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |   28 --------------------
 2 files changed, 0 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 63e394e..a411527 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -193,8 +193,6 @@ void *cfs_percpt_alloc(struct cfs_cpt_table *cptab, unsigned int size);
  */
 void  cfs_percpt_free(void *vars);
 int   cfs_percpt_number(void *vars);
-void *cfs_percpt_current(void *vars);
-void *cfs_percpt_index(void *vars, int idx);
 
 #define cfs_percpt_for_each(var, i, vars)		\
 	for (i = 0; i < cfs_percpt_number(vars) &&	\
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
index c5a6951..d0e81bb 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
@@ -115,34 +115,6 @@ cfs_percpt_number(void *vars)
 EXPORT_SYMBOL(cfs_percpt_number);
 
 /*
- * return memory block shadowed from current CPU
- */
-void *
-cfs_percpt_current(void *vars)
-{
-	struct cfs_var_array *arr;
-	int    cpt;
-
-	arr = container_of(vars, struct cfs_var_array, va_ptrs[0]);
-	cpt = cfs_cpt_current(arr->va_cptab, 0);
-	if (cpt < 0)
-		return NULL;
-
-	return arr->va_ptrs[cpt];
-}
-
-void *
-cfs_percpt_index(void *vars, int idx)
-{
-	struct cfs_var_array *arr;
-
-	arr = container_of(vars, struct cfs_var_array, va_ptrs[0]);
-
-	LASSERT(idx >= 0 && idx < arr->va_count);
-	return arr->va_ptrs[idx];
-}
-
-/*
  * free variable array, see more detail in cfs_array_alloc
  */
 void
-- 
1.7.1
