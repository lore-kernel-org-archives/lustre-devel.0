From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:26 -0500
Subject: [lustre-devel] [PATCH 10/12] lustre: clio: Introduce parallel tasks
 framework
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Dmitry Eremin <dmitry.eremin@intel.com>

In this patch new API for parallel tasks execution is introduced.
This API based on Linux kernel padata API which is used to perform
encryption and decryption on large numbers of packets without
reordering those packets.

It was adopted for general use in Lustre for parallelization of
various functionality. The first place of its usage is parallel I/O
implementation.

The first step in using it is to set up a cl_ptask structure to
control of how this task are to be run:

    #include <cl_ptask.h>

    int cl_ptask_init(struct cl_ptask *ptask, cl_ptask_cb_t cbfunc,
                      void *cbdata, unsigned int flags, int cpu);

The cbfunc function with cbdata argument will be called in the process
of getting the task done. The cpu specifies which CPU will be used for
the final callback when the task is done.

The submission of task is done with:

    int cl_ptask_submit(struct cl_ptask *ptask,
                        struct cl_ptask_engine *engine);

The task is submitted to the engine for execution.

In order to wait for result of task execution you should call:

   int cl_ptask_wait_for(struct cl_ptask *ptask);

The tasks with flag PTF_ORDERED are executed in parallel but complete
into submission order. So, waiting for last ordered task you can be sure
that all previous tasks were done before this task complete.

This patch differs from the OpenSFS tree by adding this functional
to the clio layer instead of libcfs.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8964
Reviewed-on: https://review.whamcloud.com/24474
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_ptask.h  | 145 +++++++
 drivers/staging/lustre/lustre/obdclass/Makefile   |   3 +-
 drivers/staging/lustre/lustre/obdclass/cl_ptask.c | 501 ++++++++++++++++++++++
 3 files changed, 648 insertions(+), 1 deletion(-)
 create mode 100644 drivers/staging/lustre/lustre/include/cl_ptask.h
 create mode 100644 drivers/staging/lustre/lustre/obdclass/cl_ptask.c

diff --git a/drivers/staging/lustre/lustre/include/cl_ptask.h b/drivers/staging/lustre/lustre/include/cl_ptask.h
new file mode 100644
index 0000000..02abd69
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/cl_ptask.h
@@ -0,0 +1,145 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2017, Intel Corporation.
+ * Use is subject to license terms.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ *
+ * parallel task interface
+ */
+#ifndef __CL_LUSTRE_PTASK_H__
+#define __CL_LUSTRE_PTASK_H__
+
+#include <linux/types.h>
+#include <linux/bitops.h>
+#include <linux/kernel.h>
+#include <linux/cpumask.h>
+#include <linux/uaccess.h>
+#include <linux/notifier.h>
+#include <linux/workqueue.h>
+#include <linux/completion.h>
+#ifdef CONFIG_PADATA
+#include <linux/padata.h>
+#else
+struct padata_priv {};
+struct padata_instance {};
+#endif
+
+#define PTF_COMPLETE	BIT(0)
+#define PTF_AUTOFREE	BIT(1)
+#define PTF_ORDERED	BIT(2)
+#define PTF_USER_MM	BIT(3)
+#define PTF_ATOMIC	BIT(4)
+#define PTF_RETRY	BIT(5)
+
+struct cl_ptask_engine {
+	struct padata_instance	*pte_pinst;
+	struct workqueue_struct	*pte_wq;
+	struct notifier_block	 pte_notifier;
+	int			 pte_weight;
+};
+
+struct cl_ptask;
+typedef int (*cl_ptask_cb_t)(struct cl_ptask *);
+
+struct cl_ptask {
+	struct padata_priv	 pt_padata;
+	struct completion	 pt_completion;
+	mm_segment_t		 pt_fs;
+	struct mm_struct	*pt_mm;
+	unsigned int		 pt_flags;
+	int			 pt_cbcpu;
+	cl_ptask_cb_t		 pt_cbfunc;
+	void			*pt_cbdata;
+	int			 pt_result;
+};
+
+static inline
+struct padata_priv *cl_ptask2padata(struct cl_ptask *ptask)
+{
+	return &ptask->pt_padata;
+}
+
+static inline
+struct cl_ptask *cl_padata2ptask(struct padata_priv *padata)
+{
+	return container_of(padata, struct cl_ptask, pt_padata);
+}
+
+static inline
+bool cl_ptask_need_complete(struct cl_ptask *ptask)
+{
+	return ptask->pt_flags & PTF_COMPLETE;
+}
+
+static inline
+bool cl_ptask_is_autofree(struct cl_ptask *ptask)
+{
+	return ptask->pt_flags & PTF_AUTOFREE;
+}
+
+static inline
+bool cl_ptask_is_ordered(struct cl_ptask *ptask)
+{
+	return ptask->pt_flags & PTF_ORDERED;
+}
+
+static inline
+bool cl_ptask_use_user_mm(struct cl_ptask *ptask)
+{
+	return ptask->pt_flags & PTF_USER_MM;
+}
+
+static inline
+bool cl_ptask_is_atomic(struct cl_ptask *ptask)
+{
+	return ptask->pt_flags & PTF_ATOMIC;
+}
+
+static inline
+bool cl_ptask_is_retry(struct cl_ptask *ptask)
+{
+	return ptask->pt_flags & PTF_RETRY;
+}
+
+static inline
+int cl_ptask_result(struct cl_ptask *ptask)
+{
+	return ptask->pt_result;
+}
+
+struct cl_ptask_engine *cl_ptengine_init(const char *name,
+					 const struct cpumask *cpumask);
+void cl_ptengine_fini(struct cl_ptask_engine *engine);
+int cl_ptengine_set_cpumask(struct cl_ptask_engine *engine,
+			    const struct cpumask *cpumask);
+int cl_ptengine_weight(struct cl_ptask_engine *engine);
+
+int cl_ptask_submit(struct cl_ptask *ptask,  struct cl_ptask_engine *engine);
+int cl_ptask_wait_for(struct cl_ptask *ptask);
+int cl_ptask_init(struct cl_ptask *ptask, cl_ptask_cb_t cbfunc, void *cbdata,
+		  unsigned int flags, int cpu);
+
+#endif /* __CL_LUSTRE_PTASK_H__ */
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index b1fac48..a705aa0 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -8,4 +8,5 @@ obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
 	      genops.o obd_sysfs.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
-	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o
+	      cl_object.o cl_page.o cl_lock.o cl_io.o cl_ptask.o \
+	      kernelcomm.o
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_ptask.c b/drivers/staging/lustre/lustre/obdclass/cl_ptask.c
new file mode 100644
index 0000000..b0df3c4
--- /dev/null
+++ b/drivers/staging/lustre/lustre/obdclass/cl_ptask.c
@@ -0,0 +1,501 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2017, Intel Corporation.
+ * Use is subject to license terms.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ *
+ * parallel task interface
+ */
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/cpumask.h>
+#include <linux/cpu.h>
+#include <linux/slab.h>
+#include <linux/sched.h>
+#include <linux/sched/signal.h>
+#include <linux/sched/mm.h>
+#include <linux/moduleparam.h>
+#include <linux/mmu_context.h>
+
+#define DEBUG_SUBSYSTEM S_UNDEFINED
+
+#include <linux/libcfs/libcfs.h>
+#include <cl_ptask.h>
+
+/**
+ * This API based on Linux kernel padada API which is used to perform
+ * encryption and decryption on large numbers of packets without
+ * reordering those packets.
+ *
+ * It was adopted for general use in Lustre for parallelization of
+ * various functionality.
+ *
+ * The first step in using it is to set up a cl_ptask structure to
+ * control of how this task are to be run:
+ *
+ * #include <cl_ptask.h>
+ *
+ * int cl_ptask_init(struct cl_ptask *ptask, cl_ptask_cb_t cbfunc,
+ *                    void *cbdata, unsigned int flags, int cpu);
+ *
+ * The cbfunc function with cbdata argument will be called in the process
+ * of getting the task done. The cpu specifies which CPU will be used for
+ * the final callback when the task is done.
+ *
+ * The submission of task is done with:
+ *
+ * int cl_ptask_submit(struct cl_ptask *ptask, struct cl_ptask_engine *engine);
+ *
+ * The task is submitted to the engine for execution.
+ *
+ * In order to wait for result of task execution you should call:
+ *
+ * int cl_ptask_wait_for(struct cl_ptask *ptask);
+ *
+ * The tasks with flag PTF_ORDERED are executed in parallel but complete
+ * into submission order. So, waiting for last ordered task you can be sure
+ * that all previous tasks were done before this task complete.
+ */
+#ifdef CONFIG_PADATA
+static void cl_ptask_complete(struct padata_priv *padata)
+{
+	struct cl_ptask *ptask = cl_padata2ptask(padata);
+
+	if (cl_ptask_need_complete(ptask)) {
+		if (cl_ptask_is_ordered(ptask))
+			complete(&ptask->pt_completion);
+	} else if (cl_ptask_is_autofree(ptask)) {
+		kfree(ptask);
+	}
+}
+
+static void cl_ptask_execute(struct padata_priv *padata)
+{
+	struct cl_ptask *ptask = cl_padata2ptask(padata);
+	mm_segment_t old_fs = get_fs();
+	bool bh_enabled = false;
+
+	if (!cl_ptask_is_atomic(ptask)) {
+		local_bh_enable();
+		bh_enabled = true;
+	}
+
+	if (cl_ptask_use_user_mm(ptask) && ptask->pt_mm) {
+		use_mm(ptask->pt_mm);
+		set_fs(ptask->pt_fs);
+	}
+
+	if (ptask->pt_cbfunc)
+		ptask->pt_result = ptask->pt_cbfunc(ptask);
+	else
+		ptask->pt_result = -ENXIO;
+
+	if (cl_ptask_use_user_mm(ptask) && ptask->pt_mm) {
+		set_fs(old_fs);
+		unuse_mm(ptask->pt_mm);
+		mmput(ptask->pt_mm);
+		ptask->pt_mm = NULL;
+	}
+
+	if (cl_ptask_need_complete(ptask) && !cl_ptask_is_ordered(ptask))
+		complete(&ptask->pt_completion);
+
+	if (bh_enabled)
+		local_bh_disable();
+
+	padata_do_serial(padata);
+}
+
+static int cl_do_parallel(struct cl_ptask_engine *engine,
+			  struct padata_priv *padata)
+{
+	struct cl_ptask *ptask = cl_padata2ptask(padata);
+	int rc;
+
+	if (cl_ptask_need_complete(ptask))
+		reinit_completion(&ptask->pt_completion);
+
+	if (cl_ptask_use_user_mm(ptask)) {
+		ptask->pt_mm = get_task_mm(current);
+		ptask->pt_fs = get_fs();
+	}
+	ptask->pt_result = -EINPROGRESS;
+
+retry:
+	rc = padata_do_parallel(engine->pte_pinst, padata, ptask->pt_cbcpu);
+	if (rc == -EBUSY && cl_ptask_is_retry(ptask)) {
+		/* too many tasks already in queue */
+		schedule_timeout_uninterruptible(1);
+		goto retry;
+	}
+
+	if (rc) {
+		if (cl_ptask_use_user_mm(ptask) && ptask->pt_mm) {
+			mmput(ptask->pt_mm);
+			ptask->pt_mm = NULL;
+		}
+		ptask->pt_result = rc;
+	}
+
+	return rc;
+}
+
+/**
+ * This function submit initialized task for async execution
+ * in engine with specified id.
+ */
+int cl_ptask_submit(struct cl_ptask *ptask, struct cl_ptask_engine *engine)
+{
+	struct padata_priv *padata = cl_ptask2padata(ptask);
+
+	if (IS_ERR_OR_NULL(engine))
+		return -EINVAL;
+
+	memset(padata, 0, sizeof(*padata));
+
+	padata->parallel = cl_ptask_execute;
+	padata->serial   = cl_ptask_complete;
+
+	return cl_do_parallel(engine, padata);
+}
+
+#else  /* !CONFIG_PADATA */
+
+/**
+ * If CONFIG_PADATA is not defined this function just execute
+ * the initialized task in current thread. (emulate async execution)
+ */
+int cl_ptask_submit(struct cl_ptask *ptask, struct cl_ptask_engine *engine)
+{
+	if (IS_ERR_OR_NULL(engine))
+		return -EINVAL;
+
+	if (ptask->pt_cbfunc)
+		ptask->pt_result = ptask->pt_cbfunc(ptask);
+	else
+		ptask->pt_result = -ENXIO;
+
+	if (cl_ptask_need_complete(ptask))
+		complete(&ptask->pt_completion);
+	else if (cl_ptask_is_autofree(ptask))
+		kfree(ptask);
+
+	return 0;
+}
+#endif /* CONFIG_PADATA */
+EXPORT_SYMBOL(cl_ptask_submit);
+
+/**
+ * This function waits when task complete async execution.
+ * The tasks with flag PTF_ORDERED are executed in parallel but completes
+ * into submission order. So, waiting for last ordered task you can be sure
+ * that all previous tasks were done before this task complete.
+ */
+int cl_ptask_wait_for(struct cl_ptask *ptask)
+{
+	if (!cl_ptask_need_complete(ptask))
+		return -EINVAL;
+
+	wait_for_completion(&ptask->pt_completion);
+
+	return 0;
+}
+EXPORT_SYMBOL(cl_ptask_wait_for);
+
+/**
+ * This function initialize internal members of task and prepare it for
+ * async execution.
+ */
+int cl_ptask_init(struct cl_ptask *ptask, cl_ptask_cb_t cbfunc, void *cbdata,
+		  unsigned int flags, int cpu)
+{
+	memset(ptask, 0, sizeof(*ptask));
+
+	ptask->pt_flags  = flags;
+	ptask->pt_cbcpu  = cpu;
+	ptask->pt_mm     = NULL; /* will be set in cl_do_parallel() */
+	ptask->pt_fs     = get_fs();
+	ptask->pt_cbfunc = cbfunc;
+	ptask->pt_cbdata = cbdata;
+	ptask->pt_result = -EAGAIN;
+
+	if (cl_ptask_need_complete(ptask)) {
+		if (cl_ptask_is_autofree(ptask))
+			return -EINVAL;
+
+		init_completion(&ptask->pt_completion);
+	}
+
+	if (cl_ptask_is_atomic(ptask) && cl_ptask_use_user_mm(ptask))
+		return -EINVAL;
+
+	return 0;
+}
+EXPORT_SYMBOL(cl_ptask_init);
+
+/**
+ * This function set the mask of allowed CPUs for parallel execution
+ * for engine with specified id.
+ */
+int cl_ptengine_set_cpumask(struct cl_ptask_engine *engine,
+			    const struct cpumask *cpumask)
+{
+	int rc = 0;
+
+#ifdef CONFIG_PADATA
+	cpumask_var_t serial_mask;
+	cpumask_var_t parallel_mask;
+
+	if (IS_ERR_OR_NULL(engine))
+		return -EINVAL;
+
+	if (!alloc_cpumask_var(&serial_mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	if (!alloc_cpumask_var(&parallel_mask, GFP_KERNEL)) {
+		free_cpumask_var(serial_mask);
+		return -ENOMEM;
+	}
+
+	cpumask_copy(parallel_mask, cpumask);
+	cpumask_copy(serial_mask, cpu_online_mask);
+
+	rc = padata_set_cpumask(engine->pte_pinst, PADATA_CPU_PARALLEL,
+				parallel_mask);
+	free_cpumask_var(parallel_mask);
+	if (rc)
+		goto out_failed_mask;
+
+	rc = padata_set_cpumask(engine->pte_pinst, PADATA_CPU_SERIAL,
+				serial_mask);
+out_failed_mask:
+	free_cpumask_var(serial_mask);
+#endif /* CONFIG_PADATA */
+
+	return rc;
+}
+EXPORT_SYMBOL(cl_ptengine_set_cpumask);
+
+/**
+ * This function returns the count of allowed CPUs for parallel execution
+ * for engine with specified id.
+ */
+int cl_ptengine_weight(struct cl_ptask_engine *engine)
+{
+	if (IS_ERR_OR_NULL(engine))
+		return -EINVAL;
+
+	return engine->pte_weight;
+}
+EXPORT_SYMBOL(cl_ptengine_weight);
+
+#ifdef CONFIG_PADATA
+static int cl_ptask_cpumask_change_notify(struct notifier_block *self,
+					  unsigned long val, void *data)
+{
+	struct padata_cpumask *padata_cpumask = data;
+	struct cl_ptask_engine *engine;
+
+	engine = container_of(self, struct cl_ptask_engine, pte_notifier);
+
+	if (val & PADATA_CPU_PARALLEL)
+		engine->pte_weight = cpumask_weight(padata_cpumask->pcpu);
+
+	return 0;
+}
+
+static int cl_ptengine_padata_init(struct cl_ptask_engine *engine,
+				   const char *name,
+				   const struct cpumask *cpumask)
+{
+	unsigned int wq_flags = WQ_MEM_RECLAIM | WQ_CPU_INTENSIVE;
+	char *pa_mask_buff, *cb_mask_buff;
+	cpumask_var_t all_mask;
+	cpumask_var_t par_mask;
+	int rc;
+
+	get_online_cpus();
+
+	engine->pte_wq = alloc_workqueue(name, wq_flags, 1);
+	if (!engine->pte_wq) {
+		rc = -ENOMEM;
+		goto err;
+	}
+
+	if (!alloc_cpumask_var(&all_mask, GFP_KERNEL)) {
+		rc = -ENOMEM;
+		goto err_destroy_workqueue;
+	}
+
+	if (!alloc_cpumask_var(&par_mask, GFP_KERNEL)) {
+		rc = -ENOMEM;
+		goto err_free_all_mask;
+	}
+
+	cpumask_copy(par_mask, cpumask);
+	if (cpumask_empty(par_mask) ||
+	    cpumask_equal(par_mask, cpu_online_mask)) {
+		cpumask_copy(all_mask, cpu_online_mask);
+		cpumask_clear(par_mask);
+		while (!cpumask_empty(all_mask)) {
+			int cpu = cpumask_first(all_mask);
+
+			cpumask_set_cpu(cpu, par_mask);
+			cpumask_andnot(all_mask, all_mask,
+				       topology_sibling_cpumask(cpu));
+		}
+	}
+
+	cpumask_copy(all_mask, cpu_online_mask);
+
+	pa_mask_buff = (char *)__get_free_page(GFP_KERNEL);
+	if (!pa_mask_buff) {
+		rc = -ENOMEM;
+		goto err_free_par_mask;
+	}
+
+	cb_mask_buff = (char *)__get_free_page(GFP_KERNEL);
+	if (!cb_mask_buff) {
+		free_page((unsigned long)pa_mask_buff);
+		rc = -ENOMEM;
+		goto err_free_par_mask;
+	}
+
+	cpumap_print_to_pagebuf(true, pa_mask_buff, par_mask);
+	pa_mask_buff[PAGE_SIZE - 1] = '\0';
+	cpumap_print_to_pagebuf(true, cb_mask_buff, all_mask);
+	cb_mask_buff[PAGE_SIZE - 1] = '\0';
+
+	CDEBUG(D_INFO, "%s weight=%u plist='%s' cblist='%s'\n",
+	       name, cpumask_weight(par_mask),
+	       pa_mask_buff, cb_mask_buff);
+
+	free_page((unsigned long)cb_mask_buff);
+	free_page((unsigned long)pa_mask_buff);
+
+	engine->pte_weight = cpumask_weight(par_mask);
+	engine->pte_pinst  = padata_alloc_possible(engine->pte_wq);
+	if (!engine->pte_pinst) {
+		rc = -ENOMEM;
+		goto err_free_par_mask;
+	}
+
+	engine->pte_notifier.notifier_call = cl_ptask_cpumask_change_notify;
+	rc = padata_register_cpumask_notifier(engine->pte_pinst,
+					      &engine->pte_notifier);
+	if (rc)
+		goto err_free_padata;
+
+	rc = cl_ptengine_set_cpumask(engine, par_mask);
+	if (rc)
+		goto err_unregister;
+
+	rc = padata_start(engine->pte_pinst);
+	if (rc)
+		goto err_unregister;
+
+	free_cpumask_var(par_mask);
+	free_cpumask_var(all_mask);
+
+	put_online_cpus();
+	return 0;
+
+err_unregister:
+	padata_unregister_cpumask_notifier(engine->pte_pinst,
+					   &engine->pte_notifier);
+err_free_padata:
+	padata_free(engine->pte_pinst);
+err_free_par_mask:
+	free_cpumask_var(par_mask);
+err_free_all_mask:
+	free_cpumask_var(all_mask);
+err_destroy_workqueue:
+	destroy_workqueue(engine->pte_wq);
+err:
+	put_online_cpus();
+	return rc;
+}
+
+static void cl_ptengine_padata_fini(struct cl_ptask_engine *engine)
+{
+	padata_stop(engine->pte_pinst);
+	padata_unregister_cpumask_notifier(engine->pte_pinst,
+					   &engine->pte_notifier);
+	padata_free(engine->pte_pinst);
+	destroy_workqueue(engine->pte_wq);
+}
+
+#else  /* !CONFIG_PADATA */
+
+static int cl_ptengine_padata_init(struct cl_ptask_engine *engine,
+				   const char *name,
+				   const struct cpumask *cpumask)
+{
+	engine->pte_weight = 1;
+
+	return 0;
+}
+
+static void cl_ptengine_padata_fini(struct cl_ptask_engine *engine)
+{
+}
+#endif /* CONFIG_PADATA */
+
+struct cl_ptask_engine *cl_ptengine_init(const char *name,
+					 const struct cpumask *cpumask)
+{
+	struct cl_ptask_engine *engine;
+	int rc;
+
+	engine = kzalloc(sizeof(*engine), GFP_KERNEL);
+	if (!engine) {
+		rc = -ENOMEM;
+		goto err;
+	}
+
+	rc = cl_ptengine_padata_init(engine, name, cpumask);
+	if (rc)
+		goto err_free_engine;
+
+	return engine;
+
+err_free_engine:
+	kfree(engine);
+err:
+	return ERR_PTR(rc);
+}
+EXPORT_SYMBOL(cl_ptengine_init);
+
+void cl_ptengine_fini(struct cl_ptask_engine *engine)
+{
+	if (IS_ERR_OR_NULL(engine))
+		return;
+
+	cl_ptengine_padata_fini(engine);
+	kfree(engine);
+}
+EXPORT_SYMBOL(cl_ptengine_fini);
-- 
1.8.3.1
