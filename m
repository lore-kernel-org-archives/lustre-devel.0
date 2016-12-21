From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 21 Dec 2016 19:29:03 -0000
Subject: [lustre-devel] [patch 05/10] staging/lustre/libcfs: Convert to
	hotplug state machine
References: <20161221191947.089046759@linutronix.de>
Message-ID: <20161221192111.922872524@linutronix.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Sebastian Siewior <bigeasy@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Anna-Maria Gleixner <anna-maria@linutronix.de>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, rt@linutronix.de, lustre-devel@lists.lustre.org

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

Install the callbacks via the state machine. No functional change.

Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: devel at driverdev.osuosl.org
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: rt at linutronix.de
Cc: lustre-devel at lists.lustre.org
Link: http://lkml.kernel.org/r/20161202110027.htzzeervzkoc4muv at linutronix.de
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---

 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c |   85 ++++++++++---------
 include/linux/cpuhotplug.h                           |    1 
 2 files changed, 46 insertions(+), 40 deletions(-)

--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -967,48 +967,38 @@ cfs_cpt_table_create_pattern(char *patte
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
-static int
-cfs_cpu_notify(struct notifier_block *self, unsigned long action, void *hcpu)
-{
-	unsigned int cpu = (unsigned long)hcpu;
-	bool warn;
-
-	switch (action) {
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-		spin_lock(&cpt_data.cpt_lock);
-		cpt_data.cpt_version++;
-		spin_unlock(&cpt_data.cpt_lock);
-		/* Fall through */
-	default:
-		if (action != CPU_DEAD && action != CPU_DEAD_FROZEN) {
-			CDEBUG(D_INFO, "CPU changed [cpu %u action %lx]\n",
-			       cpu, action);
-			break;
-		}
+static enum cpuhp_state lustre_cpu_online;
 
-		mutex_lock(&cpt_data.cpt_mutex);
-		/* if all HTs in a core are offline, it may break affinity */
-		cpumask_copy(cpt_data.cpt_cpumask,
-			     topology_sibling_cpumask(cpu));
-		warn = cpumask_any_and(cpt_data.cpt_cpumask,
-				       cpu_online_mask) >= nr_cpu_ids;
-		mutex_unlock(&cpt_data.cpt_mutex);
-		CDEBUG(warn ? D_WARNING : D_INFO,
-		       "Lustre: can't support CPU plug-out well now, performance and stability could be impacted [CPU %u action: %lx]\n",
-		       cpu, action);
-	}
+static void cfs_cpu_incr_cpt_version(void)
+{
+	spin_lock(&cpt_data.cpt_lock);
+	cpt_data.cpt_version++;
+	spin_unlock(&cpt_data.cpt_lock);
+}
 
-	return NOTIFY_OK;
+static int cfs_cpu_online(unsigned int cpu)
+{
+	cfs_cpu_incr_cpt_version();
+	return 0;
 }
 
-static struct notifier_block cfs_cpu_notifier = {
-	.notifier_call	= cfs_cpu_notify,
-	.priority	= 0
-};
+static int cfs_cpu_dead(unsigned int cpu)
+{
+	bool warn;
+
+	cfs_cpu_incr_cpt_version();
 
+	mutex_lock(&cpt_data.cpt_mutex);
+	/* if all HTs in a core are offline, it may break affinity */
+	cpumask_copy(cpt_data.cpt_cpumask, topology_sibling_cpumask(cpu));
+	warn = cpumask_any_and(cpt_data.cpt_cpumask,
+			       cpu_online_mask) >= nr_cpu_ids;
+	mutex_unlock(&cpt_data.cpt_mutex);
+	CDEBUG(warn ? D_WARNING : D_INFO,
+	       "Lustre: can't support CPU plug-out well now, performance and stability could be impacted [CPU %u]\n",
+	       cpu);
+	return 0;
+}
 #endif
 
 void
@@ -1018,7 +1008,9 @@ cfs_cpu_fini(void)
 		cfs_cpt_table_free(cfs_cpt_table);
 
 #ifdef CONFIG_HOTPLUG_CPU
-	unregister_hotcpu_notifier(&cfs_cpu_notifier);
+	if (lustre_cpu_online > 0)
+		cpuhp_remove_state_nocalls(lustre_cpu_online);
+	cpuhp_remove_state_nocalls(CPUHP_LUSTRE_CFS_DEAD);
 #endif
 	if (cpt_data.cpt_cpumask)
 		LIBCFS_FREE(cpt_data.cpt_cpumask, cpumask_size());
@@ -1027,6 +1019,8 @@ cfs_cpu_fini(void)
 int
 cfs_cpu_init(void)
 {
+	int ret = 0;
+
 	LASSERT(!cfs_cpt_table);
 
 	memset(&cpt_data, 0, sizeof(cpt_data));
@@ -1041,8 +1035,19 @@ cfs_cpu_init(void)
 	mutex_init(&cpt_data.cpt_mutex);
 
 #ifdef CONFIG_HOTPLUG_CPU
-	register_hotcpu_notifier(&cfs_cpu_notifier);
+	ret = cpuhp_setup_state_nocalls(CPUHP_LUSTRE_CFS_DEAD,
+					"staging/lustre/cfe:dead", NULL,
+					cfs_cpu_dead);
+	if (ret < 0)
+		goto failed;
+	ret = cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN,
+					"staging/lustre/cfe:online",
+					cfs_cpu_online, NULL);
+	if (ret < 0)
+		goto failed;
+	lustre_cpu_online = ret;
 #endif
+	ret = -EINVAL;
 
 	if (*cpu_pattern) {
 		cfs_cpt_table = cfs_cpt_table_create_pattern(cpu_pattern);
@@ -1075,7 +1080,7 @@ cfs_cpu_init(void)
 
  failed:
 	cfs_cpu_fini();
-	return -1;
+	return ret;
 }
 
 #endif
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -41,6 +41,7 @@ enum cpuhp_state {
 	CPUHP_NET_DEV_DEAD,
 	CPUHP_PCI_XGENE_DEAD,
 	CPUHP_IOMMU_INTEL_DEAD,
+	CPUHP_LUSTRE_CFS_DEAD,
 	CPUHP_SCSI_BNX2FC_DEAD,
 	CPUHP_SCSI_BNX2I_DEAD,
 	CPUHP_WORKQUEUE_PREP,
