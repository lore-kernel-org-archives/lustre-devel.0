From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:49 -0400
Subject: [lustre-devel] [PATCH v2 09/25] staging: lustre: libcfs: add cpu
 distance handling
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <jsimmons@infradead.org>

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
Changelog:

v1) Initial patch
v2) Rebased patch to handle recent libcfs changes

 .../lustre/include/linux/libcfs/libcfs_cpu.h       | 31 +++++++++++
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 61 ++++++++++++++++++++++
 2 files changed, 92 insertions(+)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 487625d..d5237d0 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -87,6 +87,8 @@ struct cfs_cpu_partition {
 	cpumask_var_t			cpt_cpumask;
 	/* nodes mask for this partition */
 	nodemask_t			*cpt_nodemask;
+	/* NUMA distance between CPTs */
+	unsigned int			*cpt_distance;
 	/* spread rotor for NUMA allocator */
 	unsigned int			cpt_spread_rotor;
 };
@@ -97,6 +99,8 @@ struct cfs_cpt_table {
 #ifdef CONFIG_SMP
 	/* spread rotor for NUMA allocator */
 	unsigned int			ctb_spread_rotor;
+	/* maximum NUMA distance between all nodes in table */
+	unsigned int			ctb_distance;
 	/* # of CPU partitions */
 	unsigned int			ctb_nparts;
 	/* partitions tables */
@@ -134,6 +138,10 @@ struct cfs_cpt_table {
  */
 int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len);
 /**
+ * print distance information of cpt-table
+ */
+int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len);
+/**
  * return total number of CPU partitions in \a cptab
  */
 int
@@ -163,6 +171,10 @@ struct cfs_cpt_table {
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
@@ -257,6 +269,19 @@ static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab,
 	return rc;
 }
 
+static inline int cfs_cpt_distance_print(struct cfs_cpt_table *cptab,
+					 char *buf, int len)
+{
+	int rc;
+
+	rc = snprintf(buf, len, "0\t: 0:1\n");
+	len -= rc;
+	if (len <= 0)
+		return -EFBIG;
+
+	return rc;
+}
+
 static inline cpumask_var_t *
 cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
 {
@@ -287,6 +312,12 @@ static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab,
 	return &cptab->ctb_nodemask;
 }
 
+static inline unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab,
+					    int cpt1, int cpt2)
+{
+	return 1;
+}
+
 static inline int
 cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index f616073..2a74e51 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -124,6 +124,15 @@ struct cfs_cpt_table *
 					     GFP_NOFS);
 		if (!part->cpt_nodemask)
 			goto failed_setting_ctb_parts;
+
+		part->cpt_distance = kvmalloc_array(cptab->ctb_nparts,
+						    sizeof(part->cpt_distance[0]),
+						    GFP_KERNEL);
+		if (!part->cpt_distance)
+			goto failed_setting_ctb_parts;
+
+		memset(part->cpt_distance, -1,
+		       cptab->ctb_nparts * sizeof(part->cpt_distance[0]));
 	}
 
 	return cptab;
@@ -134,6 +143,7 @@ struct cfs_cpt_table *
 
 		kfree(part->cpt_nodemask);
 		free_cpumask_var(part->cpt_cpumask);
+		kvfree(part->cpt_distance);
 	}
 
 	kvfree(cptab->ctb_parts);
@@ -164,6 +174,7 @@ struct cfs_cpt_table *
 
 		kfree(part->cpt_nodemask);
 		free_cpumask_var(part->cpt_cpumask);
+		kvfree(part->cpt_distance);
 	}
 
 	kvfree(cptab->ctb_parts);
@@ -218,6 +229,44 @@ struct cfs_cpt_table *
 }
 EXPORT_SYMBOL(cfs_cpt_table_print);
 
+int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
+{
+	char *tmp = buf;
+	int rc;
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
+			rc = snprintf(tmp, len, " %d:%d", j,
+				      cptab->ctb_parts[i].cpt_distance[j]);
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
+
+	return tmp - buf;
+err:
+	return -E2BIG;
+}
+EXPORT_SYMBOL(cfs_cpt_distance_print);
+
 int
 cfs_cpt_number(struct cfs_cpt_table *cptab)
 {
@@ -269,6 +318,18 @@ struct cfs_cpt_table *
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
