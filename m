From: Yan Li <yanli@ascar.io>
Date: Tue, 21 Mar 2017 12:43:30 -0700
Subject: [lustre-devel] [PATCH 3/6] RLQOS main data structure
In-Reply-To: <cover.1490122510.git.yanli@ascar.io>
References: <cover.1490122510.git.yanli@ascar.io>
Message-ID: <ce3d46d05f2b5c89cfcc3c4ffcfa106ac180ab09.1490122510.git.yanli@ascar.io>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Each client_obd maintains a qos data structure.

Signed-off-by: Yan Li <yanli@ascar.io>
---
 lustre/include/obd.h     |   8 +++
 lustre/include/rlqos.h   | 136 +++++++++++++++++++++++++++++++++++++++++++++++
 lustre/obdclass/genops.c |  25 +++++++++
 3 files changed, 169 insertions(+)
 create mode 100644 lustre/include/rlqos.h

diff --git a/lustre/include/obd.h b/lustre/include/obd.h
index b4ee379..726493c 100644
--- a/lustre/include/obd.h
+++ b/lustre/include/obd.h
@@ -50,6 +50,9 @@
 #include <lustre_intent.h>
 #include <lvfs.h>
 #include <lustre_quota.h>
+#ifdef ENABLE_RLQOS
+# include "rlqos.h"
+#endif
 
 #define MAX_OBD_DEVICES 8192
 
@@ -331,6 +334,11 @@ struct client_obd {
 	void			*cl_lru_work;
 	/* hash tables for osc_quota_info */
 	struct cfs_hash		*cl_quota_hash[LL_MAXQUOTAS];
+
+#ifdef ENABLE_RLQOS
+	/* rate-limiting quality of service data */
+	struct qos_data_t	qos;
+#endif
 };
 #define obd2cli_tgt(obd) ((char *)(obd)->u.cli.cl_target_uuid.uuid)
 
diff --git a/lustre/include/rlqos.h b/lustre/include/rlqos.h
new file mode 100644
index 0000000..d8e012b
--- /dev/null
+++ b/lustre/include/rlqos.h
@@ -0,0 +1,136 @@
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
+ * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ *
+ * Please contact Storage Systems Research Center, Computer Science Department,
+ * University of California, Santa Cruz (www.ssrc.ucsc.edu) if you need
+ * additional information or have any questions.
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2013-2017, University of California, Santa Cruz, CA, USA.
+ * All rights reserved.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/include/rlqos.h
+ */
+
+#ifndef _RLQOS_H
+#define _RLQOS_H
+
+/* We work with kernel only */
+#ifdef __KERNEL__
+# include <linux/types.h>
+# include <linux/time.h>
+# include <asm/param.h>
+# include <libcfs/libcfs.h>
+# include <linux/delay.h>
+#else /* __KERNEL__ */
+# define HZ 100
+# define ONE_MILLION 1000000
+# include <liblustre.h>
+#endif
+
+#define EWMA_ALPHA_INV (8)
+
+/**
+ * For tracking the exponentially-weighted moving average of a timeval. Note
+ * that we can't do float point div in kernel, so actually we are tracking
+ * ea = ewma * alpha. You should divide ea with alpha to get the real ewma.
+ */
+struct time_ewma {
+	__u64          alpha_inv;
+	__u64          ea;
+	struct timeval last_time;
+};
+/* We can't do float point div, so we are tracking
+ * ea = ewma * alpha = ewma / alpha_inv
+ */
+
+struct qos_rule_t {
+	__u64 ack_ewma_lower;
+	__u64 ack_ewma_upper;
+	__u64 send_ewma_lower;
+	__u64 send_ewma_upper;
+	unsigned int rtt_ratio100_lower;
+	unsigned int rtt_ratio100_upper;
+	int m100;
+	int b100;
+	unsigned int tau;
+	int used_times;
+
+	__u64 ack_ewma_avg;
+	__u64 send_ewma_avg;
+	unsigned int rtt_ratio100_avg;
+};
+
+struct qos_data_t {
+	spinlock_t       lock;
+        struct time_ewma ack_ewma;
+        struct time_ewma sent_ewma;
+        int              rtt_ratio100;
+        long             smallest_rtt;
+        int              max_rpc_in_flight100;
+        struct timeval   last_mrif_update_time;
+        int              min_gap_between_updating_mrif;
+        int              rule_no;
+        /* Following fields are for calculating I/O bandwidth,
+         * 0 for read, 1 for write */
+        long             last_req_sec[2];       /* second of last request we received */
+        __u64            tp_last_sec[2];        /* throughput of last sec */
+        __u64            sum_bytes_this_sec[2]; /* cumulative bytes read within this sec */
+        /* For throttling support */
+        unsigned int     min_usec_between_rpcs;
+        struct timeval   last_rpc_time;
+        struct qos_rule_t *rules;
+};
+
+static inline __u64 qos_get_ewma_usec(const struct time_ewma *ewma) {
+	return ewma->ea / ewma->alpha_inv;
+}
+
+int parse_qos_rules(const char *buf, struct qos_data_t *qos);
+
+/* Lock of qos must be held. op == 0 for read, 1 for write */
+static inline void calc_throughput(struct qos_data_t *qos, int op, int bytes_transferred)
+{
+	struct timeval now;
+
+	if (op != 0 && op != 1)
+		return;
+
+	do_gettimeofday(&now);
+	if (likely(now.tv_sec == qos->last_req_sec[op])) {
+		qos->sum_bytes_this_sec[op] += bytes_transferred;
+	} else if (likely(now.tv_sec == qos->last_req_sec[op] + 1)) {
+		qos->tp_last_sec[op] = qos->sum_bytes_this_sec[op];
+		qos->last_req_sec[op] = now.tv_sec;
+		qos->sum_bytes_this_sec[op] = bytes_transferred;
+	} else if (likely(now.tv_sec > qos->last_req_sec[op] + 1)) {
+		qos->tp_last_sec[op] = 0;
+		qos->last_req_sec[op] = now.tv_sec;
+		qos->sum_bytes_this_sec[op] = bytes_transferred;
+	}
+	/* Ignore cases when now.tv_sec < qos->last_req_sec */
+}
+
+#endif /* _RLQOS_H */
diff --git a/lustre/obdclass/genops.c b/lustre/obdclass/genops.c
index a48f887..417c612 100644
--- a/lustre/obdclass/genops.c
+++ b/lustre/obdclass/genops.c
@@ -284,6 +284,28 @@ int class_unregister_type(const char *name)
 } /* class_unregister_type */
 EXPORT_SYMBOL(class_unregister_type);
 
+#ifdef ENABLE_RLQOS
+static void init_time_ewma(struct time_ewma *ewma)
+{
+	ewma->alpha_inv = 8;
+	ewma->ea = 0;
+	ewma->last_time.tv_sec = 0;
+	ewma->last_time.tv_usec = 0;
+}
+
+static void init_qos(struct client_obd *cli)
+{
+	struct qos_data_t *qos = &cli->qos;
+
+	init_time_ewma(&qos->ack_ewma);
+	init_time_ewma(&qos->sent_ewma);
+
+	spin_lock(&cli->cl_loi_list_lock);
+	qos->max_rpc_in_flight100 = cli->cl_max_rpcs_in_flight * 100;
+	spin_unlock(&cli->cl_loi_list_lock);
+}
+#endif
+
 /**
  * Create a new obd device.
  *
@@ -349,6 +371,9 @@ struct obd_device *class_newdev(const char *type_name, const char *name)
                         result->obd_type = type;
                         strncpy(result->obd_name, name,
                                 sizeof(result->obd_name) - 1);
+#ifdef ENABLE_RLQOS
+                        init_qos(&result->u.cli);
+#endif
                         obd_devs[i] = result;
                 }
         }
-- 
1.8.3.1
