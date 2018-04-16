From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:10:05 -0400
Subject: [lustre-devel] [PATCH 23/25] staging: lustre: libcfs: rework CPU
 pattern parsing code
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, Amir Shehata <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Currently the module param string for CPU pattern can be
modified which is wrong. Rewrite CPU pattern parsing code
to avoid the passed buffer from being changed. This change
also enables us to add real errors propogation to the caller
functions.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23306
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9715
Reviewed-on: https://review.whamcloud.com/27872
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   | 151 ++++++++++++---------
 1 file changed, 88 insertions(+), 63 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index a08816a..915cfca 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -662,11 +662,11 @@ int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 		nodemask = cptab->ctb_parts[cpt].cpt_nodemask;
 	}
 
-	if (cpumask_any_and(*cpumask, cpu_online_mask) >= nr_cpu_ids) {
+	if (!cpumask_intersects(*cpumask, cpu_online_mask)) {
 		CDEBUG(D_INFO,
 		       "No online CPU found in CPU partition %d, did someone do CPU hotplug on system? You might need to reload Lustre modules to keep system working well.\n",
 		       cpt);
-		return -EINVAL;
+		return -ENODEV;
 	}
 
 	for_each_online_cpu(cpu) {
@@ -830,11 +830,13 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 	cptab = cfs_cpt_table_alloc(ncpt);
 	if (!cptab) {
 		CERROR("Failed to allocate CPU map(%d)\n", ncpt);
+		rc = -ENOMEM;
 		goto failed;
 	}
 
 	if (!zalloc_cpumask_var(&node_mask, GFP_NOFS)) {
 		CERROR("Failed to allocate scratch cpumask\n");
+		rc = -ENOMEM;
 		goto failed;
 	}
 
@@ -849,8 +851,10 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 
 			rc = cfs_cpt_choose_ncpus(cptab, cpt, node_mask,
 						  num - ncpu);
-			if (rc < 0)
+			if (rc < 0) {
+				rc = -EINVAL;
 				goto failed_mask;
+			}
 
 			ncpu = cpumask_weight(part->cpt_cpumask);
 			if (ncpu == num + !!(rem > 0)) {
@@ -873,37 +877,51 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 	if (cptab)
 		cfs_cpt_table_free(cptab);
 
-	return NULL;
+	return ERR_PTR(rc);
 }
 
-static struct cfs_cpt_table *cfs_cpt_table_create_pattern(char *pattern)
+static struct cfs_cpt_table *cfs_cpt_table_create_pattern(const char *pattern)
 {
 	struct cfs_cpt_table *cptab;
+	char *pattern_dup;
+	char *bracket;
 	char *str;
 	int node = 0;
-	int high;
 	int ncpt = 0;
-	int cpt;
+	int cpt = 0;
+	int high;
 	int rc;
 	int c;
 	int i;
 
-	str = strim(pattern);
+	pattern_dup = kstrdup(pattern, GFP_KERNEL);
+	if (!pattern_dup) {
+		CERROR("Failed to duplicate pattern '%s'\n", pattern);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	str = strim(pattern_dup);
 	if (*str == 'n' || *str == 'N') {
-		pattern = str + 1;
-		if (*pattern != '\0') {
-			node = 1;
-		} else { /* shortcut to create CPT from NUMA & CPU topology */
+		str++; /* skip 'N' char */
+		node = 1; /* NUMA pattern */
+		if (*str == '\0') {
 			node = -1;
-			ncpt = num_online_nodes();
+			for_each_online_node(i) {
+				if (!cpumask_empty(cpumask_of_node(i)))
+					ncpt++;
+			}
+			if (ncpt == 1) { /* single NUMA node */
+				kfree(pattern_dup);
+				return cfs_cpt_table_create(cpu_npartitions);
+			}
 		}
 	}
 
 	if (!ncpt) { /* scanning bracket which is mark of partition */
-		for (str = pattern;; str++, ncpt++) {
-			str = strchr(str, '[');
-			if (!str)
-				break;
+		bracket = str;
+		while ((bracket = strchr(bracket, '['))) {
+			bracket++;
+			ncpt++;
 		}
 	}
 
@@ -911,87 +929,95 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(char *pattern)
 	    (node && ncpt > num_online_nodes()) ||
 	    (!node && ncpt > num_online_cpus())) {
 		CERROR("Invalid pattern '%s', or too many partitions %d\n",
-		       pattern, ncpt);
-		return NULL;
+		       pattern_dup, ncpt);
+		rc = -EINVAL;
+		goto err_free_str;
 	}
 
 	cptab = cfs_cpt_table_alloc(ncpt);
 	if (!cptab) {
 		CERROR("Failed to allocate CPU partition table\n");
-		return NULL;
+		rc = -ENOMEM;
+		goto err_free_str;
 	}
 
 	if (node < 0) { /* shortcut to create CPT from NUMA & CPU topology */
-		cpt = 0;
-
 		for_each_online_node(i) {
-			if (cpt >= ncpt) {
-				CERROR("CPU changed while setting CPU partition table, %d/%d\n",
-				       cpt, ncpt);
-				goto failed;
-			}
+			if (cpumask_empty(cpumask_of_node(i)))
+				continue;
 
 			rc = cfs_cpt_set_node(cptab, cpt++, i);
-			if (!rc)
-				goto failed;
+			if (!rc) {
+				rc = -EINVAL;
+				goto err_free_table;
+			}
 		}
+		kfree(pattern_dup);
 		return cptab;
 	}
 
 	high = node ? nr_node_ids - 1 : nr_cpu_ids - 1;
 
-	for (str = strim(pattern), c = 0;; c++) {
+	for (str = strim(str), c = 0; /* until break */; c++) {
 		struct cfs_range_expr *range;
 		struct cfs_expr_list *el;
-		char *bracket = strchr(str, '[');
 		int n;
 
+		bracket = strchr(str, '[');
 		if (!bracket) {
 			if (*str) {
 				CERROR("Invalid pattern '%s'\n", str);
-				goto failed;
-			}
-			if (c != ncpt) {
+				rc = -EINVAL;
+				goto err_free_table;
+			} else if (c != ncpt) {
 				CERROR("Expect %d partitions but found %d\n",
 				       ncpt, c);
-				goto failed;
+				rc = -EINVAL;
+				goto err_free_table;
 			}
 			break;
 		}
 
 		if (sscanf(str, "%d%n", &cpt, &n) < 1) {
 			CERROR("Invalid CPU pattern '%s'\n", str);
-			goto failed;
+			rc = -EINVAL;
+			goto err_free_table;
 		}
 
 		if (cpt < 0 || cpt >= ncpt) {
 			CERROR("Invalid partition id %d, total partitions %d\n",
 			       cpt, ncpt);
-			goto failed;
+			rc = -EINVAL;
+			goto err_free_table;
 		}
 
 		if (cfs_cpt_weight(cptab, cpt)) {
 			CERROR("Partition %d has already been set.\n", cpt);
-			goto failed;
+			rc = -EPERM;
+			goto err_free_table;
 		}
 
 		str = strim(str + n);
 		if (str != bracket) {
 			CERROR("Invalid pattern '%s'\n", str);
-			goto failed;
+			rc = -EINVAL;
+			goto err_free_table;
 		}
 
 		bracket = strchr(str, ']');
 		if (!bracket) {
 			CERROR("Missing right bracket for partition %d in '%s'\n",
 			       cpt, str);
-			goto failed;
+			rc = -EINVAL;
+			goto err_free_table;
 		}
 
-		if (cfs_expr_list_parse(str, (bracket - str) + 1,
-					0, high, &el)) {
+		rc = cfs_expr_list_parse(str, (bracket - str) + 1, 0, high,
+					 &el);
+		if (rc) {
 			CERROR("Can't parse number range in '%s'\n", str);
-			goto failed;
+			rc = -ERANGE;
+			goto err_free_table;
 		}
 
 		list_for_each_entry(range, &el->el_exprs, re_link) {
@@ -999,11 +1025,12 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(char *pattern)
 				if ((i - range->re_lo) % range->re_stride)
 					continue;
 
-				rc = node ? cfs_cpt_set_node(cptab, cpt, i) :
-					    cfs_cpt_set_cpu(cptab, cpt, i);
+				rc = node ? cfs_cpt_set_node(cptab, cpt, i)
+					  : cfs_cpt_set_cpu(cptab, cpt, i);
 				if (!rc) {
 					cfs_expr_list_free(el);
-					goto failed;
+					rc = -EINVAL;
+					goto err_free_table;
 				}
 			}
 		}
@@ -1012,17 +1039,21 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(char *pattern)
 
 		if (!cfs_cpt_online(cptab, cpt)) {
 			CERROR("No online CPU is found on partition %d\n", cpt);
-			goto failed;
+			rc = -ENODEV;
+			goto err_free_table;
 		}
 
 		str = strim(bracket + 1);
 	}
 
+	kfree(pattern_dup);
 	return cptab;
 
-failed:
+err_free_table:
 	cfs_cpt_table_free(cptab);
-	return NULL;
+err_free_str:
+	kfree(pattern_dup);
+	return ERR_PTR(rc);
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
@@ -1049,7 +1080,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 
 void cfs_cpu_fini(void)
 {
-	if (cfs_cpt_table)
+	if (!IS_ERR_OR_NULL(cfs_cpt_table))
 		cfs_cpt_table_free(cfs_cpt_table);
 
 #ifdef CONFIG_HOTPLUG_CPU
@@ -1082,26 +1113,20 @@ int cfs_cpu_init(void)
 
 	get_online_cpus();
 	if (*cpu_pattern) {
-		char *cpu_pattern_dup = kstrdup(cpu_pattern, GFP_KERNEL);
-
-		if (!cpu_pattern_dup) {
-			CERROR("Failed to duplicate cpu_pattern\n");
-			goto failed;
-		}
-
-		cfs_cpt_table = cfs_cpt_table_create_pattern(cpu_pattern_dup);
-		kfree(cpu_pattern_dup);
-		if (!cfs_cpt_table) {
-			CERROR("Failed to create cptab from pattern %s\n",
+		cfs_cpt_table = cfs_cpt_table_create_pattern(cpu_pattern);
+		if (IS_ERR(cfs_cpt_table)) {
+			CERROR("Failed to create cptab from pattern '%s'\n",
 			       cpu_pattern);
+			ret = PTR_ERR(cfs_cpt_table);
 			goto failed;
 		}
 
 	} else {
 		cfs_cpt_table = cfs_cpt_table_create(cpu_npartitions);
-		if (!cfs_cpt_table) {
-			CERROR("Failed to create ptable with npartitions %d\n",
+		if (IS_ERR(cfs_cpt_table)) {
+			CERROR("Failed to create cptab with npartitions %d\n",
 			       cpu_npartitions);
+			ret = PTR_ERR(cfs_cpt_table);
 			goto failed;
 		}
 	}
-- 
1.8.3.1
