From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:51 -0400
Subject: [lustre-devel] [PATCH 12/22] lustre: obdclass: bind zombie export
 cleanup workqueue
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre uses a workqueue to clear out stale exports. Bind this
workqueue to the cores used by Lustre defined by the CPT setup.

Move the code handling workqueue binding to libcfs so it can be
used by everyone.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13258
Lustre-commit: 76b602c2bfe9d ("LU-13258 obdclass: bind zombie export cleanup workqueue")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/38212
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/llite/llite_lib.c       | 21 +++++----------------
 fs/lustre/obdclass/genops.c       |  9 +++++----
 fs/lustre/ptlrpc/pinger.c         | 19 ++++---------------
 include/linux/libcfs/libcfs_cpu.h | 24 ++++++++++++++++++++++++
 net/lnet/libcfs/libcfs_cpu.c      |  2 +-
 5 files changed, 39 insertions(+), 36 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 70e839b..05d949b 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -81,8 +81,6 @@ static inline unsigned int ll_get_ra_async_max_active(void)
 
 static struct ll_sb_info *ll_init_sbi(void)
 {
-	struct workqueue_attrs attrs = { };
-	cpumask_var_t *mask;
 	struct ll_sb_info *sbi = NULL;
 	unsigned long pages;
 	unsigned long lru_page_max;
@@ -111,23 +109,14 @@ static struct ll_sb_info *ll_init_sbi(void)
 
 	sbi->ll_ra_info.ra_async_max_active = ll_get_ra_async_max_active();
 	sbi->ll_ra_info.ll_readahead_wq =
-		alloc_workqueue("ll-readahead-wq", WQ_UNBOUND,
-				sbi->ll_ra_info.ra_async_max_active);
-	if (!sbi->ll_ra_info.ll_readahead_wq) {
-		rc = -ENOMEM;
+		cfs_cpt_bind_workqueue("ll-readahead-wq", cfs_cpt_tab,
+				       0, CFS_CPT_ANY,
+				       sbi->ll_ra_info.ra_async_max_active);
+	if (IS_ERR(sbi->ll_ra_info.ll_readahead_wq)) {
+		rc = PTR_ERR(sbi->ll_ra_info.ll_readahead_wq);
 		goto out_pcc;
 	}
 
-	mask = cfs_cpt_cpumask(cfs_cpt_tab, CFS_CPT_ANY);
-	if (mask && alloc_cpumask_var(&attrs.cpumask, GFP_KERNEL)) {
-		cpumask_copy(attrs.cpumask, *mask);
-		cpus_read_lock();
-		apply_workqueue_attrs(sbi->ll_ra_info.ll_readahead_wq,
-				      &attrs);
-		cpus_read_unlock();
-		free_cpumask_var(attrs.cpumask);
-	}
-
 	sbi->ll_cache = cl_cache_init(lru_page_max);
 	if (!sbi->ll_cache) {
 		rc = -ENOMEM;
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index e4ad53c..607f0d6 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -37,6 +37,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
+#include <linux/libcfs/libcfs_cpu.h>
 #include <obd_class.h>
 #include <lustre_log.h>
 #include <lprocfs_status.h>
@@ -1207,11 +1208,11 @@ void obd_zombie_barrier(void)
  */
 int obd_zombie_impexp_init(void)
 {
-	zombie_wq = alloc_workqueue("obd_zombid", 0, 0);
-	if (!zombie_wq)
-		return -ENOMEM;
+	zombie_wq = cfs_cpt_bind_workqueue("obd_zombid", cfs_cpt_tab,
+					   0, CFS_CPT_ANY,
+					   cfs_cpt_number(cfs_cpt_tab));
 
-	return 0;
+	return IS_ERR(zombie_wq) ? PTR_ERR(zombie_wq) : 0;
 }
 
 /**
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index 63bd132..ec4c51a 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -298,25 +298,14 @@ static void ptlrpc_pinger_main(struct work_struct *ws)
 int ptlrpc_start_pinger(void)
 {
 #ifdef CONFIG_LUSTRE_FS_PINGER
-	struct workqueue_attrs attrs = { };
-	cpumask_var_t *mask;
-
 	if (pinger_wq)
 		return -EALREADY;
 
-	pinger_wq = alloc_workqueue("ptlrpc_pinger", WQ_UNBOUND, 1);
-	if (!pinger_wq) {
+	pinger_wq = cfs_cpt_bind_workqueue("ptlrpc_pinger", cfs_cpt_tab,
+					   0, CFS_CPT_ANY, 1);
+	if (IS_ERR(pinger_wq)) {
 		CERROR("cannot start pinger workqueue\n");
-		return -ENOMEM;
-	}
-
-	mask = cfs_cpt_cpumask(cfs_cpt_tab, CFS_CPT_ANY);
-	if (mask && alloc_cpumask_var(&attrs.cpumask, GFP_KERNEL)) {
-		cpumask_copy(attrs.cpumask, *mask);
-		cpus_read_lock();
-		apply_workqueue_attrs(pinger_wq, &attrs);
-		cpus_read_unlock();
-		free_cpumask_var(attrs.cpumask);
+		return PTR_ERR(pinger_wq);
 	}
 
 	queue_delayed_work(pinger_wq, &ping_work, 0);
diff --git a/include/linux/libcfs/libcfs_cpu.h b/include/linux/libcfs/libcfs_cpu.h
index 4b0604a..310b25c 100644
--- a/include/linux/libcfs/libcfs_cpu.h
+++ b/include/linux/libcfs/libcfs_cpu.h
@@ -293,6 +293,30 @@ static inline void cfs_cpu_fini(void)
 
 #endif /* CONFIG_SMP */
 
+static inline
+struct workqueue_struct *cfs_cpt_bind_workqueue(const char *wq_name,
+						struct cfs_cpt_table *tbl,
+						int flags, int cpt, int nthrs)
+{
+	cpumask_var_t *mask = cfs_cpt_cpumask(tbl, cpt);
+	struct workqueue_attrs attrs = { };
+	struct workqueue_struct *wq;
+
+	wq = alloc_workqueue(wq_name, WQ_UNBOUND | flags, nthrs);
+	if (!wq)
+		return ERR_PTR(-ENOMEM);
+
+	if (mask && alloc_cpumask_var(&attrs.cpumask, GFP_KERNEL)) {
+		cpumask_copy(attrs.cpumask, *mask);
+		cpus_read_lock();
+		apply_workqueue_attrs(wq, &attrs);
+		cpus_read_unlock();
+		free_cpumask_var(attrs.cpumask);
+	}
+
+	return wq;
+}
+
 /*
  * allocate per-cpu-partition data, returned value is an array of pointers,
  * variable can be indexed by CPU ID.
diff --git a/net/lnet/libcfs/libcfs_cpu.c b/net/lnet/libcfs/libcfs_cpu.c
index 8969e1f..8e4fdb1 100644
--- a/net/lnet/libcfs/libcfs_cpu.c
+++ b/net/lnet/libcfs/libcfs_cpu.c
@@ -36,9 +36,9 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 
-#include <linux/libcfs/libcfs_cpu.h>
 #include <linux/libcfs/libcfs_string.h>
 #include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_cpu.h>
 
 /** virtual processing unit */
 struct cfs_cpu_partition {
-- 
1.8.3.1
