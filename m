From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:09:45 -0400
Subject: [lustre-devel] [PATCH 03/25] staging: lustre: libcfs: implement
 cfs_cpt_cpumask for UMP case
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Amir Shehata <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Amir Shehata <amir.shehata@intel.com>

The function cfs_cpt_cpumask() exist for SMP systems but when
CONFIG_SMP is disabled it only returns NULL. Fill in this missing
function. Also properly initialize ctb_mask for the UMP
case.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h | 16 +++++-----------
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c          |  9 +++++++++
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 1f2cd78..070f8fe 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -77,10 +77,6 @@
 
 #ifdef CONFIG_SMP
 /**
- * return cpumask of CPU partition \a cpt
- */
-cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt);
-/**
  * print string information of cpt-table
  */
 int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len);
@@ -89,19 +85,13 @@ struct cfs_cpt_table {
 	/* # of CPU partitions */
 	int			ctb_nparts;
 	/* cpu mask */
-	cpumask_t		ctb_mask;
+	cpumask_var_t		ctb_mask;
 	/* node mask */
 	nodemask_t		ctb_nodemask;
 	/* version */
 	u64			ctb_version;
 };
 
-static inline cpumask_var_t *
-cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
-{
-	return NULL;
-}
-
 static inline int
 cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
@@ -133,6 +123,10 @@ struct cfs_cpt_table {
  */
 int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt);
 /**
+ * return cpumask of CPU partition \a cpt
+ */
+cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt);
+/**
  * return nodemask of CPU partition \a cpt
  */
 nodemask_t *cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt);
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 705abf2..5ea294f 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -54,6 +54,9 @@ struct cfs_cpt_table *
 	cptab = kzalloc(sizeof(*cptab), GFP_NOFS);
 	if (cptab) {
 		cptab->ctb_version = CFS_CPU_VERSION_MAGIC;
+		if (!zalloc_cpumask_var(&cptab->ctb_mask, GFP_NOFS))
+			return NULL;
+		cpumask_set_cpu(0, cptab->ctb_mask);
 		node_set(0, cptab->ctb_nodemask);
 		cptab->ctb_nparts  = ncpt;
 	}
@@ -108,6 +111,12 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_online);
 
+cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
+{
+	return &cptab->ctb_mask;
+}
+EXPORT_SYMBOL(cfs_cpt_cpumask);
+
 nodemask_t *
 cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
 {
-- 
1.8.3.1
