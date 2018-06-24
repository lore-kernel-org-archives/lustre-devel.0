From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:50 -0400
Subject: [lustre-devel] [PATCH v3 26/26] staging: lustre: libcfs: restore
 UMP support
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Pieces needed for UMP platforms was removed which can currently
crash a node. The first promblem was cfs_cpt_table_alloc() and
cfs_cpt_table_free() was completely missing for UMP platforms.
Since only one valid configuration exist just report the default
static cfs_cpt_tab. Don't return NULL for cfs_cpt_cpumask() and
cfs_cpt_nodemask() but real mask instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9856
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       | 41 ++++++++++++++++++++--
 1 file changed, 38 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index df7e16b..ff1a24d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -94,7 +94,6 @@ struct cfs_cpu_partition {
 	int				cpt_node;
 };
 
-
 /** descriptor for CPU partitions */
 struct cfs_cpt_table {
 	/* spread rotor for NUMA allocator */
@@ -114,9 +113,27 @@ struct cfs_cpt_table {
 	/* all nodes in this partition table */
 	nodemask_t			*ctb_nodemask;
 };
+#else /* !CONFIG_SMP */
+
+/** UMP descriptor for CPU partitions */
+struct cfs_cpt_table {
+	cpumask_var_t			ctb_cpumask;
+	nodemask_t			ctb_nodemask;
+};
+
+#endif /* CONFIG_SMP */
 
 extern struct cfs_cpt_table	cfs_cpt_tab;
 
+#ifdef CONFIG_SMP
+/**
+ * create a cfs_cpt_table with \a ncpt number of partitions
+ */
+struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt);
+/**
+ * destroy a CPU partition table
+ */
+void cfs_cpt_table_free(struct cfs_cpt_table *cptab);
 /**
  * return cpumask of CPU partition \a cpt
  */
@@ -216,6 +233,18 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
 
 #else /* !CONFIG_SMP */
 
+static inline struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
+{
+	if (ncpt != 1)
+                return NULL;
+
+	return &cfs_cpt_tab;
+}
+
+static inline void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
+{
+}
+
 static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab,
 				      char *buf, int len)
 {
@@ -245,7 +274,7 @@ static inline int cfs_cpt_distance_print(struct cfs_cpt_table *cptab,
 static inline cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab,
 					     int cpt)
 {
-	return NULL;
+	return &cptab->ctb_cpumask;
 }
 
 static inline int cfs_cpt_number(struct cfs_cpt_table *cptab)
@@ -266,7 +295,7 @@ static inline int cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
 static inline nodemask_t *cfs_cpt_nodemask(struct cfs_cpt_table *cptab,
 					   int cpt)
 {
-	return NULL;
+	return &cptab->ctb_nodemask;
 }
 
 static inline unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab,
@@ -346,11 +375,17 @@ static inline int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 
 static inline int cfs_cpu_init(void)
 {
+	if (!zalloc_cpumask_var(&cfs_cpt_tab.ctb_cpumask, GFP_NOFS))
+		return -ENOMEM;
+
+	cpumask_set_cpu(0, cfs_cpt_tab.ctb_cpumask);
+	node_set(0, cfs_cpt_tab.ctb_nodemask);
 	return 0;
 }
 
 static inline void cfs_cpu_fini(void)
 {
+	free_cpumask_var(cfs_cpt_tab.ctb_cpumask);
 }
 
 #endif /* CONFIG_SMP */
-- 
1.8.3.1
