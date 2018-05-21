From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 04/30] staging: lustre: rename cfs_cpt_table
 to cfs_cpt_tab
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731250.24196.1142594072913630206.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The variable "cfs_cpt_table" has the same name as
the structure "struct cfs_cpt_table".
This makes it hard to use #define to make one disappear
on a uni-processor build, but keep the other.
So rename the variable to cfs_cpt_tab.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |    6 ++--
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |   32 ++++++++++----------
 drivers/staging/lustre/lnet/libcfs/module.c        |    4 +--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    6 ++--
 drivers/staging/lustre/lnet/selftest/framework.c   |    2 +
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    4 +--
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   10 +++---
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    6 ++--
 8 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 813ba4564bb9..552e9f5c277e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -59,9 +59,9 @@
  *   . NUMA allocators, CPU affinity threads are built over CPU partitions,
  *     instead of HW CPUs or HW nodes.
  *
- *   . By default, Lustre modules should refer to the global cfs_cpt_table,
+ *   . By default, Lustre modules should refer to the global cfs_cpt_tab,
  *     instead of accessing HW CPUs directly, so concurrency of Lustre can be
- *     configured by cpu_npartitions of the global cfs_cpt_table
+ *     configured by cpu_npartitions of the global cfs_cpt_tab
  *
  *   . If cpu_npartitions=1(all CPUs in one pool), lustre should work the
  *     same way as 2.2 or earlier versions
@@ -329,7 +329,7 @@ cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 }
 #endif /* CONFIG_SMP */
 
-extern struct cfs_cpt_table	*cfs_cpt_table;
+extern struct cfs_cpt_table	*cfs_cpt_tab;
 
 /**
  * destroy a CPU partition table
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index ac6fd11ae9d6..2133ffec49a9 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -34,8 +34,8 @@
 #include <linux/libcfs/libcfs.h>
 
 /** Global CPU partition table */
-struct cfs_cpt_table   *cfs_cpt_table __read_mostly;
-EXPORT_SYMBOL(cfs_cpt_table);
+struct cfs_cpt_table   *cfs_cpt_tab __read_mostly;
+EXPORT_SYMBOL(cfs_cpt_tab);
 #define DEBUG_SUBSYSTEM S_LNET
 
 #include <linux/cpu.h>
@@ -1037,8 +1037,8 @@ static int cfs_cpu_dead(unsigned int cpu)
 void
 cfs_cpu_fini(void)
 {
-	if (cfs_cpt_table)
-		cfs_cpt_table_free(cfs_cpt_table);
+	if (cfs_cpt_tab)
+		cfs_cpt_table_free(cfs_cpt_tab);
 
 #ifdef CONFIG_HOTPLUG_CPU
 	if (lustre_cpu_online > 0)
@@ -1053,7 +1053,7 @@ cfs_cpu_init(void)
 {
 	int ret = 0;
 
-	LASSERT(!cfs_cpt_table);
+	LASSERT(!cfs_cpt_tab);
 
 	memset(&cpt_data, 0, sizeof(cpt_data));
 
@@ -1088,17 +1088,17 @@ cfs_cpu_init(void)
 			goto failed;
 		}
 
-		cfs_cpt_table = cfs_cpt_table_create_pattern(cpu_pattern_dup);
+		cfs_cpt_tab = cfs_cpt_table_create_pattern(cpu_pattern_dup);
 		kfree(cpu_pattern_dup);
-		if (!cfs_cpt_table) {
+		if (!cfs_cpt_tab) {
 			CERROR("Failed to create cptab from pattern %s\n",
 			       cpu_pattern);
 			goto failed;
 		}
 
 	} else {
-		cfs_cpt_table = cfs_cpt_table_create(cpu_npartitions);
-		if (!cfs_cpt_table) {
+		cfs_cpt_tab = cfs_cpt_table_create(cpu_npartitions);
+		if (!cfs_cpt_tab) {
 			CERROR("Failed to create ptable with npartitions %d\n",
 			       cpu_npartitions);
 			goto failed;
@@ -1106,7 +1106,7 @@ cfs_cpu_init(void)
 	}
 
 	spin_lock(&cpt_data.cpt_lock);
-	if (cfs_cpt_table->ctb_version != cpt_data.cpt_version) {
+	if (cfs_cpt_tab->ctb_version != cpt_data.cpt_version) {
 		spin_unlock(&cpt_data.cpt_lock);
 		CERROR("CPU hotplug/unplug during setup\n");
 		goto failed;
@@ -1115,7 +1115,7 @@ cfs_cpu_init(void)
 
 	LCONSOLE(0, "HW nodes: %d, HW CPU cores: %d, npartitions: %d\n",
 		 num_online_nodes(), num_online_cpus(),
-		 cfs_cpt_number(cfs_cpt_table));
+		 cfs_cpt_number(cfs_cpt_tab));
 	return 0;
 
  failed:
@@ -1128,18 +1128,18 @@ cfs_cpu_init(void)
 void
 cfs_cpu_fini(void)
 {
-	if (cfs_cpt_table) {
-		cfs_cpt_table_free(cfs_cpt_table);
-		cfs_cpt_table = NULL;
+	if (cfs_cpt_tab) {
+		cfs_cpt_table_free(cfs_cpt_tab);
+		cfs_cpt_tab = NULL;
 	}
 }
 
 int
 cfs_cpu_init(void)
 {
-	cfs_cpt_table = cfs_cpt_table_alloc(1);
+	cfs_cpt_tab = cfs_cpt_table_alloc(1);
 
-	return cfs_cpt_table ? 0 : -1;
+	return cfs_cpt_tab ? 0 : -1;
 }
 
 #endif /* CONFIG_SMP */
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 0e3bfe4e2cb1..6d1c1ad63e16 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -461,14 +461,14 @@ static int __proc_cpt_table(void *data, int write,
 	if (write)
 		return -EPERM;
 
-	LASSERT(cfs_cpt_table);
+	LASSERT(cfs_cpt_tab);
 
 	while (1) {
 		buf = kzalloc(len, GFP_KERNEL);
 		if (!buf)
 			return -ENOMEM;
 
-		rc = cfs_cpt_table_print(cfs_cpt_table, buf, len);
+		rc = cfs_cpt_table_print(cfs_cpt_tab, buf, len);
 		if (rc >= 0)
 			break;
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 90266be0132d..f9ed6977056c 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1413,9 +1413,9 @@ int lnet_lib_init(void)
 
 	memset(&the_lnet, 0, sizeof(the_lnet));
 
-	/* refer to global cfs_cpt_table for now */
-	the_lnet.ln_cpt_table	= cfs_cpt_table;
-	the_lnet.ln_cpt_number	= cfs_cpt_number(cfs_cpt_table);
+	/* refer to global cfs_cpt_tab for now */
+	the_lnet.ln_cpt_table	= cfs_cpt_tab;
+	the_lnet.ln_cpt_number	= cfs_cpt_number(cfs_cpt_tab);
 
 	LASSERT(the_lnet.ln_cpt_number > 0);
 	if (the_lnet.ln_cpt_number > LNET_CPT_MAX) {
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 045eecd23e0a..741af10560ad 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -588,7 +588,7 @@ sfw_load_test(struct sfw_test_instance *tsi)
 
 	CDEBUG(D_NET, "Reserved %d buffers for test %s\n",
 	       nbuf * (srpc_serv_is_framework(svc) ?
-		       2 : cfs_cpt_number(cfs_cpt_table)), svc->sv_name);
+		       2 : cfs_cpt_number(cfs_cpt_tab)), svc->sv_name);
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index eeb281266413..a868ff6e720f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -938,9 +938,9 @@ struct ptlrpc_request_set *ptlrpc_prep_set(void)
 	struct ptlrpc_request_set *set;
 	int cpt;
 
-	cpt = cfs_cpt_current(cfs_cpt_table, 0);
+	cpt = cfs_cpt_current(cfs_cpt_tab, 0);
 	set = kzalloc_node(sizeof(*set), GFP_NOFS,
-			   cfs_cpt_spread_node(cfs_cpt_table, cpt));
+			   cfs_cpt_spread_node(cfs_cpt_tab, cpt));
 	if (!set)
 		return NULL;
 	atomic_set(&set->set_refcount, 1);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index c0fa13942bd8..1f7c18d1c95e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -175,7 +175,7 @@ ptlrpcd_select_pc(struct ptlrpc_request *req)
 	if (req && req->rq_send_state != LUSTRE_IMP_FULL)
 		return &ptlrpcd_rcv;
 
-	cpt = cfs_cpt_current(cfs_cpt_table, 1);
+	cpt = cfs_cpt_current(cfs_cpt_tab, 1);
 	if (!ptlrpcds_cpt_idx)
 		idx = cpt;
 	else
@@ -387,7 +387,7 @@ static int ptlrpcd(void *arg)
 	int exit = 0;
 
 	unshare_fs_struct();
-	if (cfs_cpt_bind(cfs_cpt_table, pc->pc_cpt) != 0)
+	if (cfs_cpt_bind(cfs_cpt_tab, pc->pc_cpt) != 0)
 		CWARN("Failed to bind %s on CPT %d\n", pc->pc_name, pc->pc_cpt);
 
 	/*
@@ -529,7 +529,7 @@ static int ptlrpcd_partners(struct ptlrpcd *pd, int index)
 
 	size = sizeof(struct ptlrpcd_ctl *) * pc->pc_npartners;
 	pc->pc_partners = kzalloc_node(size, GFP_NOFS,
-				       cfs_cpt_spread_node(cfs_cpt_table,
+				       cfs_cpt_spread_node(cfs_cpt_tab,
 							   pc->pc_cpt));
 	if (!pc->pc_partners) {
 		pc->pc_npartners = 0;
@@ -675,7 +675,7 @@ static int ptlrpcd_init(void)
 	/*
 	 * Determine the CPTs that ptlrpcd threads will run on.
 	 */
-	cptable = cfs_cpt_table;
+	cptable = cfs_cpt_tab;
 	ncpts = cfs_cpt_number(cptable);
 	if (ptlrpcd_cpts) {
 		struct cfs_expr_list *el;
@@ -829,7 +829,7 @@ static int ptlrpcd_init(void)
 
 		size = offsetof(struct ptlrpcd, pd_threads[nthreads]);
 		pd = kzalloc_node(size, GFP_NOFS,
-				  cfs_cpt_spread_node(cfs_cpt_table, cpt));
+				  cfs_cpt_spread_node(cfs_cpt_tab, cpt));
 		if (!pd) {
 			rc = -ENOMEM;
 			goto out;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 4265e8d00ca5..1d28139c950e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -205,7 +205,7 @@ struct ptlrpc_hr_partition {
 #define HRT_STOPPING 1
 
 struct ptlrpc_hr_service {
-	/* CPU partition table, it's just cfs_cpt_table for now */
+	/* CPU partition table, it's just cfs_cpt_tab for now */
 	struct cfs_cpt_table		*hr_cpt_table;
 	/** controller sleep waitq */
 	wait_queue_head_t			hr_waitq;
@@ -562,7 +562,7 @@ ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 
 	cptable = cconf->cc_cptable;
 	if (!cptable)
-		cptable = cfs_cpt_table;
+		cptable = cfs_cpt_tab;
 
 	if (!conf->psc_thr.tc_cpu_affinity) {
 		ncpts = 1;
@@ -2516,7 +2516,7 @@ int ptlrpc_hr_init(void)
 	int weight;
 
 	memset(&ptlrpc_hr, 0, sizeof(ptlrpc_hr));
-	ptlrpc_hr.hr_cpt_table = cfs_cpt_table;
+	ptlrpc_hr.hr_cpt_table = cfs_cpt_tab;
 
 	ptlrpc_hr.hr_partitions = cfs_percpt_alloc(ptlrpc_hr.hr_cpt_table,
 						   sizeof(*hrp));
