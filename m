From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:09:50 -0400
Subject: [lustre-devel] [PATCH 08/25] staging: lustre: libcfs: add cpu
 distance handling
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Amir Shehata <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Amir Shehata <amir.shehata@intel.com>

Add functionality to calculate the distance between two CPTs.
Expose those distance in debugfs so people deploying a setup
can debug what is being created for CPTs.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |  8 +++
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  |  4 ++
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 21 ++++++++
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   | 59 ++++++++++++++++++++++
 4 files changed, 92 insertions(+)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 839ec02..c0922fc 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -110,6 +110,10 @@ struct cfs_cpt_table {
  */
 struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt);
 /**
+ * print distance information of cpt-table
+ */
+int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len);
+/**
  * return total number of CPU partitions in \a cptab
  */
 int
@@ -143,6 +147,10 @@ struct cfs_cpt_table {
  */
 int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node);
 /**
+ * NUMA distance between \a cpt1 and \a cpt2 in \a cptab
+ */
+unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2);
+/**
  * bind current thread on a CPU-partition \a cpt of \a cptab
  */
 int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt);
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
index 1bed0ba..4ac1670 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
@@ -52,6 +52,8 @@ struct cfs_cpu_partition {
 	cpumask_var_t			cpt_cpumask;
 	/* nodes mask for this partition */
 	nodemask_t			*cpt_nodemask;
+	/* NUMA distance between CPTs */
+	unsigned int			*cpt_distance;
 	/* spread rotor for NUMA allocator */
 	unsigned int			cpt_spread_rotor;
 };
@@ -60,6 +62,8 @@ struct cfs_cpu_partition {
 struct cfs_cpt_table {
 	/* spread rotor for NUMA allocator */
 	unsigned int			ctb_spread_rotor;
+	/* maximum NUMA distance between all nodes in table */
+	unsigned int			ctb_distance;
 	/* # of CPU partitions */
 	unsigned int			ctb_nparts;
 	/* partitions tables */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index e6d1512..7ac2796 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -41,6 +41,8 @@
 
 #define CFS_CPU_VERSION_MAGIC	   0xbabecafe
 
+#define CFS_CPT_DISTANCE	1	/* Arbitrary positive value */
+
 struct cfs_cpt_table *
 cfs_cpt_table_alloc(unsigned int ncpt)
 {
@@ -90,6 +92,19 @@ struct cfs_cpt_table *
 EXPORT_SYMBOL(cfs_cpt_table_print);
 #endif /* CONFIG_SMP */
 
+int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
+{
+	int rc;
+
+	rc = snprintf(buf, len, "0\t: 0:%d\n", CFS_CPT_DISTANCE);
+	len -= rc;
+	if (len <= 0)
+		return -EFBIG;
+
+	return rc;
+}
+EXPORT_SYMBOL(cfs_cpt_distance_print);
+
 int
 cfs_cpt_number(struct cfs_cpt_table *cptab)
 {
@@ -124,6 +139,12 @@ cpumask_var_t *cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
 }
 EXPORT_SYMBOL(cfs_cpt_nodemask);
 
+unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
+{
+	return CFS_CPT_DISTANCE;
+}
+EXPORT_SYMBOL(cfs_cpt_distance);
+
 int
 cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index fd0c451..1e184b1 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -76,6 +76,7 @@
 		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
 
 		kfree(part->cpt_nodemask);
+		kfree(part->cpt_distance);
 		free_cpumask_var(part->cpt_cpumask);
 	}
 
@@ -137,6 +138,12 @@ struct cfs_cpt_table *
 		if (!zalloc_cpumask_var(&part->cpt_cpumask, GFP_NOFS) ||
 		    !part->cpt_nodemask)
 			goto failed;
+
+		part->cpt_distance = kvmalloc_array(cptab->ctb_nparts,
+						    sizeof(part->cpt_distance[0]),
+						    GFP_KERNEL);
+		if (!part->cpt_distance)
+			goto failed;
 	}
 
 	return cptab;
@@ -190,6 +197,46 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_table_print);
 
+int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
+{
+	char *tmp = buf;
+	int rc = -EFBIG;
+	int i;
+	int j;
+
+	for (i = 0; i < cptab->ctb_nparts; i++) {
+		if (len <= 0)
+			goto err;
+
+		rc = snprintf(tmp, len, "%d\t:", i);
+		len -= rc;
+
+		if (len <= 0)
+			goto err;
+
+		tmp += rc;
+		for (j = 0; j < cptab->ctb_nparts; j++) {
+			rc = snprintf(tmp, len, " %d:%d",
+				      j, cptab->ctb_parts[i].cpt_distance[j]);
+			len -= rc;
+			if (len <= 0)
+				goto err;
+			tmp += rc;
+		}
+
+		*tmp = '\n';
+		tmp++;
+		len--;
+	}
+	rc = 0;
+err:
+	if (rc < 0)
+		return rc;
+
+	return tmp - buf;
+}
+EXPORT_SYMBOL(cfs_cpt_distance_print);
+
 int
 cfs_cpt_number(struct cfs_cpt_table *cptab)
 {
@@ -241,6 +288,18 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_nodemask);
 
+unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
+{
+	LASSERT(cpt1 == CFS_CPT_ANY || (cpt1 >= 0 && cpt1 < cptab->ctb_nparts));
+	LASSERT(cpt2 == CFS_CPT_ANY || (cpt2 >= 0 && cpt2 < cptab->ctb_nparts));
+
+	if (cpt1 == CFS_CPT_ANY || cpt2 == CFS_CPT_ANY)
+		return cptab->ctb_distance;
+
+	return cptab->ctb_parts[cpt1].cpt_distance[cpt2];
+}
+EXPORT_SYMBOL(cfs_cpt_distance);
+
 int
 cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
-- 
1.8.3.1
