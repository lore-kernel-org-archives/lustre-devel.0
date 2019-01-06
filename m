From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:47 -0500
Subject: [lustre-devel] [PATCH 14/14] lustre: libcfs: hide struct
 cfs_cpt_table internals
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Exposing the internals of struct cfs_cpt_table in the libcfs
header used by lustre makes it too tempting to use but those
fields are not available for UP systems. Make cfs_cpt_table
abstract so the lustre and LNet code will never use the
internals and instead use the functions provided in
libcfs_cpu.h.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       | 39 ++--------------------
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 34 +++++++++++++++++++
 2 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 50eb484..3e51752 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -79,42 +79,9 @@
 /* any CPU partition */
 #define CFS_CPT_ANY		(-1)
 
-#ifdef CONFIG_SMP
-/** virtual processing unit */
-struct cfs_cpu_partition {
-	/* CPUs mask for this partition */
-	cpumask_var_t			cpt_cpumask;
-	/* nodes mask for this partition */
-	nodemask_t			*cpt_nodemask;
-	/* NUMA distance between CPTs */
-	unsigned int			*cpt_distance;
-	/* spread rotor for NUMA allocator */
-	unsigned int			cpt_spread_rotor;
-	/* NUMA node if cpt_nodemask is empty */
-	int				cpt_node;
-};
-
-
-/** descriptor for CPU partitions */
-struct cfs_cpt_table {
-	/* spread rotor for NUMA allocator */
-	unsigned int			ctb_spread_rotor;
-	/* maximum NUMA distance between all nodes in table */
-	unsigned int			ctb_distance;
-	/* # of CPU partitions */
-	unsigned int			ctb_nparts;
-	/* partitions tables */
-	struct cfs_cpu_partition	*ctb_parts;
-	/* shadow HW CPU to CPU partition ID */
-	int				*ctb_cpu2cpt;
-	/* all cpus in this partition table */
-	cpumask_var_t			ctb_cpumask;
-	/* shadow HW node to CPU partition ID */
-	int				*ctb_node2cpt;
-	/* all nodes in this partition table */
-	nodemask_t			*ctb_nodemask;
-};
+struct cfs_cpt_table;
 
+#ifdef CONFIG_SMP
 extern struct cfs_cpt_table	*cfs_cpt_tab;
 
 /**
@@ -215,7 +182,7 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
 void cfs_cpu_fini(void);
 
 #else /* !CONFIG_SMP */
-struct cfs_cpt_table;
+
 #define cfs_cpt_tab ((struct cfs_cpt_table *)NULL)
 
 static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab,
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index a9b59cc..a384a73 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -41,6 +41,40 @@
 #include <linux/libcfs/libcfs_string.h>
 #include <linux/libcfs/libcfs.h>
 
+/** virtual processing unit */
+struct cfs_cpu_partition {
+	/* CPUs mask for this partition */
+	cpumask_var_t			cpt_cpumask;
+	/* nodes mask for this partition */
+	nodemask_t			*cpt_nodemask;
+	/* NUMA distance between CPTs */
+	unsigned int			*cpt_distance;
+	/* spread rotor for NUMA allocator */
+	unsigned int			cpt_spread_rotor;
+	/* NUMA node if cpt_nodemask is empty */
+	int				cpt_node;
+};
+
+/** descriptor for CPU partitions */
+struct cfs_cpt_table {
+	/* spread rotor for NUMA allocator */
+	unsigned int			ctb_spread_rotor;
+	/* maximum NUMA distance between all nodes in table */
+	unsigned int			ctb_distance;
+	/* # of CPU partitions */
+	unsigned int			ctb_nparts;
+	/* partitions tables */
+	struct cfs_cpu_partition	*ctb_parts;
+	/* shadow HW CPU to CPU partition ID */
+	int				*ctb_cpu2cpt;
+	/* all cpus in this partition table */
+	cpumask_var_t			ctb_cpumask;
+	/* shadow HW node to CPU partition ID */
+	int				*ctb_node2cpt;
+	/* all nodes in this partition table */
+	nodemask_t			*ctb_nodemask;
+};
+
 /** Global CPU partition table */
 struct cfs_cpt_table   *cfs_cpt_tab __read_mostly;
 EXPORT_SYMBOL(cfs_cpt_tab);
-- 
1.8.3.1
