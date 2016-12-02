From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 2 Dec 2016 12:00:28 +0100
Subject: [lustre-devel] [PATCH 21/22 v3] staging/lustre/libcfs: Convert to
 hotplug state machine
In-Reply-To: <20161202104244.GB8736@kroah.com>
References: <20161126231350.10321-1-bigeasy@linutronix.de>
	<20161126231350.10321-22-bigeasy@linutronix.de>
	<20161202101825.mcsbw4nr4slymcvl@linutronix.de>
	<20161202104244.GB8736@kroah.com>
Message-ID: <20161202110027.htzzeervzkoc4muv@linutronix.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, rt@linutronix.de, tglx@linutronix.de, Anna-Maria Gleixner <anna-maria@linutronix.de>, lustre-devel@lists.lustre.org

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

Install the callbacks via the state machine.

Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel at lists.lustre.org
Cc: devel at driverdev.osuosl.org
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
[bigeasy: rebase to linux-next]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v2?v3: add the missing blank before the Cc: lines.
v1?v2: rebase to linux-next

Side note: Is there a reason the handle the down state very late at
CPU_DEAD time and use the counterpart of the online callback (the old
CPU_DOWN_PREPARE state).

 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   | 88 ++++++++++++----------
 include/linux/cpuhotplug.h                         |  1 +
 2 files changed, 49 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 6b9cf06e8df2..f70b7d16378c 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -75,6 +75,9 @@ struct cfs_cpt_data {
 };
 
 static struct cfs_cpt_data	cpt_data;
+#ifdef CONFIG_HOTPLUG_CPU
+static enum cpuhp_state lustre_cpu_online;
+#endif
 
 static void
 cfs_node_to_cpumask(int node, cpumask_t *mask)
@@ -967,48 +970,37 @@ cfs_cpt_table_create_pattern(char *pattern)
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
-static int
-cfs_cpu_notify(struct notifier_block *self, unsigned long action, void *hcpu)
+static void cfs_cpu_incr_cpt_version(void)
 {
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
-
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
-
-	return NOTIFY_OK;
+	spin_lock(&cpt_data.cpt_lock);
+	cpt_data.cpt_version++;
+	spin_unlock(&cpt_data.cpt_lock);
 }
 
-static struct notifier_block cfs_cpu_notifier = {
-	.notifier_call	= cfs_cpu_notify,
-	.priority	= 0
-};
+static int cfs_cpu_online(unsigned int cpu)
+{
+	cfs_cpu_incr_cpt_version();
+	return 0;
+}
 
+static int cfs_cpu_dead(unsigned int cpu)
+{
+	bool warn;
+
+	cfs_cpu_incr_cpt_version();
+
+	mutex_lock(&cpt_data.cpt_mutex);
+	/* if all HTs in a core are offline, it may break affinity */
+	cpumask_copy(cpt_data.cpt_cpumask,
+		     topology_sibling_cpumask(cpu));
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
@@ -1018,7 +1010,9 @@ cfs_cpu_fini(void)
 		cfs_cpt_table_free(cfs_cpt_table);
 
 #ifdef CONFIG_HOTPLUG_CPU
-	unregister_hotcpu_notifier(&cfs_cpu_notifier);
+	if (lustre_cpu_online)
+		cpuhp_remove_state_nocalls(lustre_cpu_online);
+	cpuhp_remove_state_nocalls(CPUHP_LUSTRE_CFS_DEAD);
 #endif
 	if (cpt_data.cpt_cpumask)
 		LIBCFS_FREE(cpt_data.cpt_cpumask, cpumask_size());
@@ -1027,6 +1021,10 @@ cfs_cpu_fini(void)
 int
 cfs_cpu_init(void)
 {
+#ifdef CONFIG_HOTPLUG_CPU
+	int ret;
+#endif
+
 	LASSERT(!cfs_cpt_table);
 
 	memset(&cpt_data, 0, sizeof(cpt_data));
@@ -1041,7 +1039,17 @@ cfs_cpu_init(void)
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
 
 	if (*cpu_pattern) {
diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 22acee76cf4c..141c3be242d1 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -41,6 +41,7 @@ enum cpuhp_state {
 	CPUHP_NET_DEV_DEAD,
 	CPUHP_PCI_XGENE_DEAD,
 	CPUHP_IOMMU_INTEL_DEAD,
+	CPUHP_LUSTRE_CFS_DEAD,
 	CPUHP_WORKQUEUE_PREP,
 	CPUHP_POWER_NUMA_PREPARE,
 	CPUHP_HRTIMERS_PREPARE,
-- 
2.10.2
