From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:49 -0400
Subject: [lustre-devel] [PATCH v3 25/26] staging: lustre: libcfs: make
 cfs_cpt_tab a static structure
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Only one cfs_cpt_tab exist and its created only at libcfs modules
loading and removal. Instead of dynamically allocating it lets
statically allocate it. This will help to reenable UMP support.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9856
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |   4 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 111 ++++++++++-----------
 drivers/staging/lustre/lnet/libcfs/module.c        |  10 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   4 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  10 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   4 +-
 8 files changed, 73 insertions(+), 76 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 32776d2..df7e16b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -115,7 +115,7 @@ struct cfs_cpt_table {
 	nodemask_t			*ctb_nodemask;
 };
 
-extern struct cfs_cpt_table	*cfs_cpt_tab;
+extern struct cfs_cpt_table	cfs_cpt_tab;
 
 /**
  * return cpumask of CPU partition \a cpt
@@ -215,8 +215,6 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
 void cfs_cpu_fini(void);
 
 #else /* !CONFIG_SMP */
-struct cfs_cpt_table;
-#define cfs_cpt_tab ((struct cfs_cpt_table *)NULL)
 
 static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab,
 				      char *buf, int len)
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 3f4a7c7..9fd324d 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -41,10 +41,6 @@
 #include <linux/libcfs/libcfs_string.h>
 #include <linux/libcfs/libcfs.h>
 
-/** Global CPU partition table */
-struct cfs_cpt_table   *cfs_cpt_tab __read_mostly;
-EXPORT_SYMBOL(cfs_cpt_tab);
-
 /**
  * modparam for setting number of partitions
  *
@@ -73,15 +69,10 @@
 module_param(cpu_pattern, charp, 0444);
 MODULE_PARM_DESC(cpu_pattern, "CPU partitions pattern");
 
-struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
+static int cfs_cpt_table_setup(struct cfs_cpt_table *cptab, int ncpt)
 {
-	struct cfs_cpt_table *cptab;
 	int i;
 
-	cptab = kzalloc(sizeof(*cptab), GFP_NOFS);
-	if (!cptab)
-		return NULL;
-
 	cptab->ctb_nparts = ncpt;
 
 	if (!zalloc_cpumask_var(&cptab->ctb_cpumask, GFP_NOFS))
@@ -138,7 +129,7 @@ struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
 		       cptab->ctb_nparts * sizeof(part->cpt_distance[0]));
 	}
 
-	return cptab;
+	return 0;
 
 failed_setting_ctb_parts:
 	while (i-- >= 0) {
@@ -159,8 +150,24 @@ struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
 failed_alloc_nodemask:
 	free_cpumask_var(cptab->ctb_cpumask);
 failed_alloc_cpumask:
-	kfree(cptab);
-	return NULL;
+	return -ENOMEM;
+}
+
+struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
+{
+	struct cfs_cpt_table *cptab;
+	int rc;
+
+	cptab = kzalloc(sizeof(*cptab), GFP_NOFS);
+	if (!cptab)
+		return NULL;
+
+	rc = cfs_cpt_table_setup(cptab, ncpt);
+	if (rc) {
+		kfree(cptab);
+		cptab = NULL;
+	}
+	return cptab;
 }
 EXPORT_SYMBOL(cfs_cpt_table_alloc);
 
@@ -183,8 +190,6 @@ void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 
 	kfree(cptab->ctb_nodemask);
 	free_cpumask_var(cptab->ctb_cpumask);
-
-	kfree(cptab);
 }
 EXPORT_SYMBOL(cfs_cpt_table_free);
 
@@ -822,9 +827,8 @@ static int cfs_cpt_num_estimate(void)
 	return ncpt;
 }
 
-static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
+static int cfs_cpt_table_create(int ncpt)
 {
-	struct cfs_cpt_table *cptab = NULL;
 	cpumask_var_t node_mask;
 	int cpt = 0;
 	int node;
@@ -841,10 +845,9 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 		      ncpt, num);
 	}
 
-	cptab = cfs_cpt_table_alloc(ncpt);
-	if (!cptab) {
-		CERROR("Failed to allocate CPU map(%d)\n", ncpt);
-		rc = -ENOMEM;
+	rc = cfs_cpt_table_setup(&cfs_cpt_tab, ncpt);
+	if (rc) {
+		CERROR("Failed to setup CPU map(%d)\n", ncpt);
 		goto failed;
 	}
 
@@ -860,10 +863,13 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 		cpumask_copy(node_mask, cpumask_of_node(node));
 
 		while (cpt < ncpt && !cpumask_empty(node_mask)) {
-			struct cfs_cpu_partition *part = &cptab->ctb_parts[cpt];
-			int ncpu = cpumask_weight(part->cpt_cpumask);
+			struct cfs_cpu_partition *part;
+			int ncpu;
+
+			part = &cfs_cpt_tab.ctb_parts[cpt];
+			ncpu = cpumask_weight(part->cpt_cpumask);
 
-			rc = cfs_cpt_choose_ncpus(cptab, cpt, node_mask,
+			rc = cfs_cpt_choose_ncpus(&cfs_cpt_tab, cpt, node_mask,
 						  num - ncpu);
 			if (rc < 0) {
 				rc = -EINVAL;
@@ -880,7 +886,7 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 
 	free_cpumask_var(node_mask);
 
-	return cptab;
+	return 0;
 
 failed_mask:
 	free_cpumask_var(node_mask);
@@ -888,15 +894,13 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 	CERROR("Failed (rc = %d) to setup CPU partition table with %d partitions, online HW NUMA nodes: %d, HW CPU cores: %d.\n",
 	       rc, ncpt, num_online_nodes(), num_online_cpus());
 
-	if (cptab)
-		cfs_cpt_table_free(cptab);
+	cfs_cpt_table_free(&cfs_cpt_tab);
 
-	return ERR_PTR(rc);
+	return rc;
 }
 
-static struct cfs_cpt_table *cfs_cpt_table_create_pattern(const char *pattern)
+static int cfs_cpt_table_create_pattern(const char *pattern)
 {
-	struct cfs_cpt_table *cptab;
 	char *pattern_dup;
 	char *bracket;
 	char *str;
@@ -911,7 +915,7 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(const char *pattern)
 	pattern_dup = kstrdup(pattern, GFP_KERNEL);
 	if (!pattern_dup) {
 		CERROR("Failed to duplicate pattern '%s'\n", pattern);
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 	}
 
 	str = strim(pattern_dup);
@@ -948,10 +952,9 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(const char *pattern)
 		goto err_free_str;
 	}
 
-	cptab = cfs_cpt_table_alloc(ncpt);
-	if (!cptab) {
-		CERROR("Failed to allocate CPU partition table\n");
-		rc = -ENOMEM;
+	rc = cfs_cpt_table_setup(&cfs_cpt_tab, ncpt);
+	if (rc) {
+		CERROR("Failed to setup CPU partition table\n");
 		goto err_free_str;
 	}
 
@@ -960,14 +963,14 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(const char *pattern)
 			if (cpumask_empty(cpumask_of_node(i)))
 				continue;
 
-			rc = cfs_cpt_set_node(cptab, cpt++, i);
+			rc = cfs_cpt_set_node(&cfs_cpt_tab, cpt++, i);
 			if (!rc) {
 				rc = -EINVAL;
 				goto err_free_table;
 			}
 		}
 		kfree(pattern_dup);
-		return cptab;
+		return 0;
 	}
 
 	high = node ? nr_node_ids - 1 : nr_cpu_ids - 1;
@@ -1006,7 +1009,7 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(const char *pattern)
 			goto err_free_table;
 		}
 
-		if (cfs_cpt_weight(cptab, cpt)) {
+		if (cfs_cpt_weight(&cfs_cpt_tab, cpt)) {
 			CERROR("Partition %d has already been set.\n", cpt);
 			rc = -EPERM;
 			goto err_free_table;
@@ -1040,8 +1043,8 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(const char *pattern)
 				if ((i - range->re_lo) % range->re_stride)
 					continue;
 
-				rc = node ? cfs_cpt_set_node(cptab, cpt, i) :
-					    cfs_cpt_set_cpu(cptab, cpt, i);
+				rc = node ? cfs_cpt_set_node(&cfs_cpt_tab, cpt, i) :
+					    cfs_cpt_set_cpu(&cfs_cpt_tab, cpt, i);
 				if (!rc) {
 					cfs_expr_list_free(el);
 					rc = -EINVAL;
@@ -1052,7 +1055,7 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(const char *pattern)
 
 		cfs_expr_list_free(el);
 
-		if (!cfs_cpt_online(cptab, cpt)) {
+		if (!cfs_cpt_online(&cfs_cpt_tab, cpt)) {
 			CERROR("No online CPU is found on partition %d\n", cpt);
 			rc = -ENODEV;
 			goto err_free_table;
@@ -1062,13 +1065,13 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(const char *pattern)
 	}
 
 	kfree(pattern_dup);
-	return cptab;
+	return 0;
 
 err_free_table:
-	cfs_cpt_table_free(cptab);
+	cfs_cpt_table_free(&cfs_cpt_tab);
 err_free_str:
 	kfree(pattern_dup);
-	return ERR_PTR(rc);
+	return rc;
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
@@ -1095,8 +1098,7 @@ static int cfs_cpu_dead(unsigned int cpu)
 
 void cfs_cpu_fini(void)
 {
-	if (!IS_ERR_OR_NULL(cfs_cpt_tab))
-		cfs_cpt_table_free(cfs_cpt_tab);
+	cfs_cpt_table_free(&cfs_cpt_tab);
 
 #ifdef CONFIG_HOTPLUG_CPU
 	if (lustre_cpu_online > 0)
@@ -1109,8 +1111,6 @@ int cfs_cpu_init(void)
 {
 	int ret;
 
-	LASSERT(!cfs_cpt_tab);
-
 #ifdef CONFIG_HOTPLUG_CPU
 	ret = cpuhp_setup_state_nocalls(CPUHP_LUSTRE_CFS_DEAD,
 					"staging/lustre/cfe:dead", NULL,
@@ -1128,20 +1128,18 @@ int cfs_cpu_init(void)
 #endif
 	get_online_cpus();
 	if (*cpu_pattern) {
-		cfs_cpt_tab = cfs_cpt_table_create_pattern(cpu_pattern);
-		if (IS_ERR(cfs_cpt_tab)) {
+		ret = cfs_cpt_table_create_pattern(cpu_pattern);
+		if (ret) {
 			CERROR("Failed to create cptab from pattern '%s'\n",
 			       cpu_pattern);
-			ret = PTR_ERR(cfs_cpt_tab);
 			goto failed_alloc_table;
 		}
 
 	} else {
-		cfs_cpt_tab = cfs_cpt_table_create(cpu_npartitions);
-		if (IS_ERR(cfs_cpt_tab)) {
+		ret = cfs_cpt_table_create(cpu_npartitions);
+		if (ret) {
 			CERROR("Failed to create cptab with npartitions %d\n",
 			       cpu_npartitions);
-			ret = PTR_ERR(cfs_cpt_tab);
 			goto failed_alloc_table;
 		}
 	}
@@ -1150,14 +1148,13 @@ int cfs_cpu_init(void)
 
 	LCONSOLE(0, "HW NUMA nodes: %d, HW CPU cores: %d, npartitions: %d\n",
 		 num_online_nodes(), num_online_cpus(),
-		 cfs_cpt_number(cfs_cpt_tab));
+		 cfs_cpt_number(&cfs_cpt_tab));
 	return 0;
 
 failed_alloc_table:
 	put_online_cpus();
 
-	if (!IS_ERR_OR_NULL(cfs_cpt_tab))
-		cfs_cpt_table_free(cfs_cpt_tab);
+	cfs_cpt_table_free(&cfs_cpt_tab);
 
 	ret = -EINVAL;
 #ifdef CONFIG_HOTPLUG_CPU
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 2281f08..35c3959 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -66,6 +66,10 @@ struct lnet_debugfs_symlink_def {
 
 static struct dentry *lnet_debugfs_root;
 
+/** Global CPU partition table */
+struct cfs_cpt_table cfs_cpt_tab __read_mostly;
+EXPORT_SYMBOL(cfs_cpt_tab);
+
 BLOCKING_NOTIFIER_HEAD(libcfs_ioctl_list);
 EXPORT_SYMBOL(libcfs_ioctl_list);
 
@@ -402,7 +406,7 @@ static int proc_cpt_table(struct ctl_table *table, int write,
 		if (!buf)
 			return -ENOMEM;
 
-		rc = cfs_cpt_table_print(cfs_cpt_tab, buf, len);
+		rc = cfs_cpt_table_print(&cfs_cpt_tab, buf, len);
 		if (rc >= 0)
 			break;
 
@@ -437,14 +441,12 @@ static int proc_cpt_distance(struct ctl_table *table, int write,
 	if (write)
 		return -EPERM;
 
-	LASSERT(cfs_cpt_tab);
-
 	while (1) {
 		buf = kzalloc(len, GFP_KERNEL);
 		if (!buf)
 			return -ENOMEM;
 
-		rc = cfs_cpt_distance_print(cfs_cpt_tab, buf, len);
+		rc = cfs_cpt_distance_print(&cfs_cpt_tab, buf, len);
 		if (rc >= 0)
 			break;
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index f9ed697..98a4942 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1414,8 +1414,8 @@ int lnet_lib_init(void)
 	memset(&the_lnet, 0, sizeof(the_lnet));
 
 	/* refer to global cfs_cpt_tab for now */
-	the_lnet.ln_cpt_table	= cfs_cpt_tab;
-	the_lnet.ln_cpt_number	= cfs_cpt_number(cfs_cpt_tab);
+	the_lnet.ln_cpt_table = &cfs_cpt_tab;
+	the_lnet.ln_cpt_number = cfs_cpt_number(&cfs_cpt_tab);
 
 	LASSERT(the_lnet.ln_cpt_number > 0);
 	if (the_lnet.ln_cpt_number > LNET_CPT_MAX) {
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 741af10..939b7ec 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -588,7 +588,7 @@
 
 	CDEBUG(D_NET, "Reserved %d buffers for test %s\n",
 	       nbuf * (srpc_serv_is_framework(svc) ?
-		       2 : cfs_cpt_number(cfs_cpt_tab)), svc->sv_name);
+		       2 : cfs_cpt_number(&cfs_cpt_tab)), svc->sv_name);
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index c1b82bf..c569a8b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -940,9 +940,9 @@ struct ptlrpc_request_set *ptlrpc_prep_set(void)
 	struct ptlrpc_request_set *set;
 	int cpt;
 
-	cpt = cfs_cpt_current(cfs_cpt_tab, 0);
+	cpt = cfs_cpt_current(&cfs_cpt_tab, 0);
 	set = kzalloc_node(sizeof(*set), GFP_NOFS,
-			   cfs_cpt_spread_node(cfs_cpt_tab, cpt));
+			   cfs_cpt_spread_node(&cfs_cpt_tab, cpt));
 	if (!set)
 		return NULL;
 	atomic_set(&set->set_refcount, 1);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 5310054..d496521 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -177,7 +177,7 @@ void ptlrpcd_wake(struct ptlrpc_request *req)
 	if (req && req->rq_send_state != LUSTRE_IMP_FULL)
 		return &ptlrpcd_rcv;
 
-	cpt = cfs_cpt_current(cfs_cpt_tab, 1);
+	cpt = cfs_cpt_current(&cfs_cpt_tab, 1);
 	if (!ptlrpcds_cpt_idx)
 		idx = cpt;
 	else
@@ -389,7 +389,7 @@ static int ptlrpcd(void *arg)
 	int exit = 0;
 
 	unshare_fs_struct();
-	if (cfs_cpt_bind(cfs_cpt_tab, pc->pc_cpt) != 0)
+	if (cfs_cpt_bind(&cfs_cpt_tab, pc->pc_cpt) != 0)
 		CWARN("Failed to bind %s on CPT %d\n", pc->pc_name, pc->pc_cpt);
 
 	/*
@@ -531,7 +531,7 @@ static int ptlrpcd_partners(struct ptlrpcd *pd, int index)
 
 	size = sizeof(struct ptlrpcd_ctl *) * pc->pc_npartners;
 	pc->pc_partners = kzalloc_node(size, GFP_NOFS,
-				       cfs_cpt_spread_node(cfs_cpt_tab,
+				       cfs_cpt_spread_node(&cfs_cpt_tab,
 							   pc->pc_cpt));
 	if (!pc->pc_partners) {
 		pc->pc_npartners = 0;
@@ -677,7 +677,7 @@ static int ptlrpcd_init(void)
 	/*
 	 * Determine the CPTs that ptlrpcd threads will run on.
 	 */
-	cptable = cfs_cpt_tab;
+	cptable = &cfs_cpt_tab;
 	ncpts = cfs_cpt_number(cptable);
 	if (ptlrpcd_cpts) {
 		struct cfs_expr_list *el;
@@ -831,7 +831,7 @@ static int ptlrpcd_init(void)
 
 		size = offsetof(struct ptlrpcd, pd_threads[nthreads]);
 		pd = kzalloc_node(size, GFP_NOFS,
-				  cfs_cpt_spread_node(cfs_cpt_tab, cpt));
+				  cfs_cpt_spread_node(&cfs_cpt_tab, cpt));
 		if (!pd) {
 			rc = -ENOMEM;
 			goto out;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 8e74a45..853676f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -565,7 +565,7 @@ struct ptlrpc_service *
 
 	cptable = cconf->cc_cptable;
 	if (!cptable)
-		cptable = cfs_cpt_tab;
+		cptable = &cfs_cpt_tab;
 
 	if (!conf->psc_thr.tc_cpu_affinity) {
 		ncpts = 1;
@@ -2520,7 +2520,7 @@ int ptlrpc_hr_init(void)
 	int weight;
 
 	memset(&ptlrpc_hr, 0, sizeof(ptlrpc_hr));
-	ptlrpc_hr.hr_cpt_table = cfs_cpt_tab;
+	ptlrpc_hr.hr_cpt_table = &cfs_cpt_tab;
 
 	ptlrpc_hr.hr_partitions = cfs_percpt_alloc(ptlrpc_hr.hr_cpt_table,
 						   sizeof(*hrp));
-- 
1.8.3.1
