From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:44 -0400
Subject: [lustre-devel] [PATCH v2 04/25] staging: lustre: libcfs: properly
 handle failure cases in SMP code
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

While pushing the SMP work some bugs were pointed out by Dan
Carpenter in the code. Due to single err label in cfs_cpu_init()
and cfs_cpt_table_alloc() a few items were being cleaned up that
were never initialized. This can lead to crashed and other problems.
In those initialization function introduce individual labels to
jump to only the thing initialized get freed on failure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10932
Reviewed-on: https://review.whamcloud.com/32085
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) New patch to make libcfs SMP code handle failure paths correctly.

 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 72 ++++++++++++++++++-------
 1 file changed, 52 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 34df7ed..b67a60c 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -81,17 +81,19 @@ struct cfs_cpt_table *
 
 	cptab->ctb_nparts = ncpt;
 
+	if (!zalloc_cpumask_var(&cptab->ctb_cpumask, GFP_NOFS))
+		goto failed_alloc_cpumask;
+
 	cptab->ctb_nodemask = kzalloc(sizeof(*cptab->ctb_nodemask),
 				      GFP_NOFS);
-	if (!zalloc_cpumask_var(&cptab->ctb_cpumask, GFP_NOFS) ||
-	    !cptab->ctb_nodemask)
-		goto failed;
+	if (!cptab->ctb_nodemask)
+		goto failed_alloc_nodemask;
 
 	cptab->ctb_cpu2cpt = kvmalloc_array(num_possible_cpus(),
 					    sizeof(cptab->ctb_cpu2cpt[0]),
 					    GFP_KERNEL);
 	if (!cptab->ctb_cpu2cpt)
-		goto failed;
+		goto failed_alloc_cpu2cpt;
 
 	memset(cptab->ctb_cpu2cpt, -1,
 	       num_possible_cpus() * sizeof(cptab->ctb_cpu2cpt[0]));
@@ -99,22 +101,41 @@ struct cfs_cpt_table *
 	cptab->ctb_parts = kvmalloc_array(ncpt, sizeof(cptab->ctb_parts[0]),
 					  GFP_KERNEL);
 	if (!cptab->ctb_parts)
-		goto failed;
+		goto failed_alloc_ctb_parts;
+
+	memset(cptab->ctb_parts, -1, ncpt * sizeof(cptab->ctb_parts[0]));
 
 	for (i = 0; i < ncpt; i++) {
 		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
 
+		if (!zalloc_cpumask_var(&part->cpt_cpumask, GFP_NOFS))
+			goto failed_setting_ctb_parts;
+
 		part->cpt_nodemask = kzalloc(sizeof(*part->cpt_nodemask),
 					     GFP_NOFS);
-		if (!zalloc_cpumask_var(&part->cpt_cpumask, GFP_NOFS) ||
-		    !part->cpt_nodemask)
-			goto failed;
+		if (!part->cpt_nodemask)
+			goto failed_setting_ctb_parts;
 	}
 
 	return cptab;
 
- failed:
-	cfs_cpt_table_free(cptab);
+failed_setting_ctb_parts:
+	while (i-- >= 0) {
+		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
+
+		kfree(part->cpt_nodemask);
+		free_cpumask_var(part->cpt_cpumask);
+	}
+
+	kvfree(cptab->ctb_parts);
+failed_alloc_ctb_parts:
+	kvfree(cptab->ctb_cpu2cpt);
+failed_alloc_cpu2cpt:
+	kfree(cptab->ctb_nodemask);
+failed_alloc_nodemask:
+	free_cpumask_var(cptab->ctb_cpumask);
+failed_alloc_cpumask:
+	kfree(cptab);
 	return NULL;
 }
 EXPORT_SYMBOL(cfs_cpt_table_alloc);
@@ -940,7 +961,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 int
 cfs_cpu_init(void)
 {
-	int ret = 0;
+	int ret;
 
 	LASSERT(!cfs_cpt_tab);
 
@@ -949,23 +970,23 @@ static int cfs_cpu_dead(unsigned int cpu)
 					"staging/lustre/cfe:dead", NULL,
 					cfs_cpu_dead);
 	if (ret < 0)
-		goto failed;
+		goto failed_cpu_dead;
+
 	ret = cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN,
 					"staging/lustre/cfe:online",
 					cfs_cpu_online, NULL);
 	if (ret < 0)
-		goto failed;
+		goto failed_cpu_online;
+
 	lustre_cpu_online = ret;
 #endif
-	ret = -EINVAL;
-
 	get_online_cpus();
 	if (*cpu_pattern) {
 		char *cpu_pattern_dup = kstrdup(cpu_pattern, GFP_KERNEL);
 
 		if (!cpu_pattern_dup) {
 			CERROR("Failed to duplicate cpu_pattern\n");
-			goto failed;
+			goto failed_alloc_table;
 		}
 
 		cfs_cpt_tab = cfs_cpt_table_create_pattern(cpu_pattern_dup);
@@ -973,7 +994,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 		if (!cfs_cpt_tab) {
 			CERROR("Failed to create cptab from pattern %s\n",
 			       cpu_pattern);
-			goto failed;
+			goto failed_alloc_table;
 		}
 
 	} else {
@@ -981,7 +1002,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 		if (!cfs_cpt_tab) {
 			CERROR("Failed to create ptable with npartitions %d\n",
 			       cpu_npartitions);
-			goto failed;
+			goto failed_alloc_table;
 		}
 	}
 
@@ -992,8 +1013,19 @@ static int cfs_cpu_dead(unsigned int cpu)
 		 cfs_cpt_number(cfs_cpt_tab));
 	return 0;
 
- failed:
+failed_alloc_table:
 	put_online_cpus();
-	cfs_cpu_fini();
+
+	if (cfs_cpt_tab)
+		cfs_cpt_table_free(cfs_cpt_tab);
+
+	ret = -EINVAL;
+#ifdef CONFIG_HOTPLUG_CPU
+	if (lustre_cpu_online > 0)
+		cpuhp_remove_state_nocalls(lustre_cpu_online);
+failed_cpu_online:
+	cpuhp_remove_state_nocalls(CPUHP_LUSTRE_CFS_DEAD);
+failed_cpu_dead:
+#endif
 	return ret;
 }
-- 
1.8.3.1
