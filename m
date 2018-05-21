From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 05/30] staging: lustre: remove conditional
 compilation from libcfs_cpu.c
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731254.24196.9201761132495755343.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

libcfs_cpu.c manages CPU partitions.  In the !CONFIG_SMP case, most
of this disappears and 'static inline's from libcfs_cpu.h are used.
However we still allocate a 'struct cfs_cpt_table' and keep some
dummy data in it.  This is a bit pointless.

This patch removes all the !CONFIG_SMP code from libcfs_cpu.c and
conditionally compiles the whole file only when CONFIG_SMP.
We no longer allocate a 'struct cfs_cpt_table' on !CONFIG_SMP,
and don't even declare a structure.  The name "cfs_cpt_tab"
becomes always "NULL", which allows some code to be optimized away.

This means that cfs_cpt_tab can sometimes be NULL, so we need to
discard the assertion that it isn't.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |   35 ++++++-----
 drivers/staging/lustre/lnet/libcfs/Makefile        |    2 -
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |   62 --------------------
 drivers/staging/lustre/lnet/libcfs/module.c        |    2 -
 4 files changed, 20 insertions(+), 81 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 552e9f5c277e..61641c41c492 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -109,6 +109,8 @@ struct cfs_cpt_table {
 	nodemask_t			*ctb_nodemask;
 };
 
+extern struct cfs_cpt_table	*cfs_cpt_tab;
+
 /**
  * return cpumask of CPU partition \a cpt
  */
@@ -202,17 +204,12 @@ int cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt);
  */
 int cfs_cpu_ht_nsiblings(int cpu);
 
+int  cfs_cpu_init(void);
+void cfs_cpu_fini(void);
+
 #else /* !CONFIG_SMP */
-struct cfs_cpt_table {
-	/* # of CPU partitions */
-	int			ctb_nparts;
-	/* cpu mask */
-	cpumask_t		ctb_mask;
-	/* node mask */
-	nodemask_t		ctb_nodemask;
-	/* version */
-	u64			ctb_version;
-};
+struct cfs_cpt_table;
+#define cfs_cpt_tab ((struct cfs_cpt_table *)NULL)
 
 static inline cpumask_var_t *
 cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
@@ -246,7 +243,7 @@ cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
 static inline nodemask_t *
 cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
 {
-	return &cptab->ctb_nodemask;
+	return NULL;
 }
 
 static inline int
@@ -327,9 +324,18 @@ cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
 	return 0;
 }
-#endif /* CONFIG_SMP */
 
-extern struct cfs_cpt_table	*cfs_cpt_tab;
+static inline int
+cfs_cpu_init(void)
+{
+	return 0;
+}
+
+static inline void cfs_cpu_fini(void)
+{
+}
+
+#endif /* CONFIG_SMP */
 
 /**
  * destroy a CPU partition table
@@ -425,7 +431,4 @@ void cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index);
 #define cfs_cpt_for_each(i, cptab)	\
 	for (i = 0; i < cfs_cpt_number(cptab); i++)
 
-int  cfs_cpu_init(void);
-void cfs_cpu_fini(void);
-
 #endif /* __LIBCFS_CPU_H__ */
diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index 6335f909d22b..6a1b232da495 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -10,7 +10,7 @@ libcfs-obj-y += linux-crypto-adler.o
 
 libcfs-obj-y += debug.o fail.o module.o tracefile.o
 libcfs-obj-y += libcfs_string.o hash.o
-libcfs-obj-y += libcfs_cpu.o
+libcfs-obj-$(CONFIG_SMP) += libcfs_cpu.o
 libcfs-obj-y += libcfs_mem.o libcfs_lock.o
 
 libcfs-objs := $(libcfs-obj-y)
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 2133ffec49a9..40509b2acfb3 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -42,7 +42,6 @@ EXPORT_SYMBOL(cfs_cpt_tab);
 #include <linux/sched.h>
 #include <linux/libcfs/libcfs.h>
 
-#ifdef CONFIG_SMP
 /**
  * modparam for setting number of partitions
  *
@@ -81,11 +80,9 @@ static struct cfs_cpt_data {
 	/* scratch buffer for set/unset_node */
 	cpumask_var_t		cpt_cpumask;
 } cpt_data;
-#endif
 
 #define CFS_CPU_VERSION_MAGIC	   0xbabecafe
 
-#ifdef CONFIG_SMP
 struct cfs_cpt_table *
 cfs_cpt_table_alloc(unsigned int ncpt)
 {
@@ -139,30 +136,8 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 	cfs_cpt_table_free(cptab);
 	return NULL;
 }
-#else /* ! CONFIG_SMP */
-struct cfs_cpt_table *
-cfs_cpt_table_alloc(unsigned int ncpt)
-{
-	struct cfs_cpt_table *cptab;
-
-	if (ncpt != 1) {
-		CERROR("Can't support cpu partition number %d\n", ncpt);
-		return NULL;
-	}
-
-	cptab = kzalloc(sizeof(*cptab), GFP_NOFS);
-	if (cptab) {
-		cptab->ctb_version = CFS_CPU_VERSION_MAGIC;
-		node_set(0, cptab->ctb_nodemask);
-		cptab->ctb_nparts  = ncpt;
-	}
-
-	return cptab;
-}
-#endif /* CONFIG_SMP */
 EXPORT_SYMBOL(cfs_cpt_table_alloc);
 
-#ifdef CONFIG_SMP
 void
 cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
@@ -184,18 +159,8 @@ cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 
 	kfree(cptab);
 }
-#else /* ! CONFIG_SMP */
-void
-cfs_cpt_table_free(struct cfs_cpt_table *cptab)
-{
-	LASSERT(cptab->ctb_version == CFS_CPU_VERSION_MAGIC);
-
-	kfree(cptab);
-}
-#endif /* CONFIG_SMP */
 EXPORT_SYMBOL(cfs_cpt_table_free);
 
-#ifdef CONFIG_SMP
 int
 cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
@@ -238,9 +203,7 @@ cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 	return tmp - buf;
 }
 EXPORT_SYMBOL(cfs_cpt_table_print);
-#endif /* CONFIG_SMP */
 
-#ifdef CONFIG_SMP
 static void
 cfs_node_to_cpumask(int node, cpumask_t *mask)
 {
@@ -624,10 +587,6 @@ cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 }
 EXPORT_SYMBOL(cfs_cpt_bind);
 
-#endif
-
-#ifdef CONFIG_SMP
-
 /**
  * Choose max to \a number CPUs from \a node and set them in \a cpt.
  * We always prefer to choose CPU in the same core/socket.
@@ -1122,24 +1081,3 @@ cfs_cpu_init(void)
 	cfs_cpu_fini();
 	return ret;
 }
-
-#else /* ! CONFIG_SMP */
-
-void
-cfs_cpu_fini(void)
-{
-	if (cfs_cpt_tab) {
-		cfs_cpt_table_free(cfs_cpt_tab);
-		cfs_cpt_tab = NULL;
-	}
-}
-
-int
-cfs_cpu_init(void)
-{
-	cfs_cpt_tab = cfs_cpt_table_alloc(1);
-
-	return cfs_cpt_tab ? 0 : -1;
-}
-
-#endif /* CONFIG_SMP */
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 6d1c1ad63e16..3e51aae751c5 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -461,8 +461,6 @@ static int __proc_cpt_table(void *data, int write,
 	if (write)
 		return -EPERM;
 
-	LASSERT(cfs_cpt_tab);
-
 	while (1) {
 		buf = kzalloc(len, GFP_KERNEL);
 		if (!buf)
