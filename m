From: Yan Li <yanli@ascar.io>
Date: Tue, 21 Mar 2017 12:43:31 -0700
Subject: [lustre-devel] [PATCH 4/6] lprocfs interfaces for showing, parsing,
	and controlling rules
In-Reply-To: <cover.1490122510.git.yanli@ascar.io>
References: <cover.1490122510.git.yanli@ascar.io>
Message-ID: <bf79f12bbcef66bcf9eebdcb553487a912be0c27.1490122510.git.yanli@ascar.io>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Signed-off-by: Yan Li <yanli@ascar.io>
---
 lustre/obdclass/lprocfs_status.c |  32 ++++++++
 lustre/osc/Makefile.in           |   2 +-
 lustre/osc/lproc_osc.c           | 157 ++++++++++++++++++++++++++++++++++-----
 lustre/osc/qos_rules.c           | 125 +++++++++++++++++++++++++++++++
 4 files changed, 295 insertions(+), 21 deletions(-)
 create mode 100644 lustre/osc/qos_rules.c

diff --git a/lustre/obdclass/lprocfs_status.c b/lustre/obdclass/lprocfs_status.c
index 08db676..841a3da 100644
--- a/lustre/obdclass/lprocfs_status.c
+++ b/lustre/obdclass/lprocfs_status.c
@@ -814,6 +814,14 @@ int lprocfs_import_seq_show(struct seq_file *m, void *data)
 	int                             j;
 	int                             k;
 	int                             rw      = 0;
+#ifdef ENABLE_RLQOS
+	struct qos_data_t		*qos;
+	__u64				ack_ewma;
+	__u64				sent_ewma;
+	int				rtt_ratio100;
+	__u64				read_tp;
+	__u64				write_tp;
+#endif
 
 	LASSERT(obd != NULL);
 	LPROCFS_CLIMP_CHECK(obd);
@@ -884,6 +892,26 @@ int lprocfs_import_seq_show(struct seq_file *m, void *data)
 		   atomic_read(&imp->imp_unregistering),
 		   atomic_read(&imp->imp_timeouts),
 		   ret.lc_sum, header->lc_units);
+#ifdef ENABLE_RLQOS
+	qos = &obd->u.cli.qos;
+	spin_lock(&qos->lock);
+	ack_ewma  = qos_get_ewma_usec(&qos->ack_ewma);
+	sent_ewma = qos_get_ewma_usec(&qos->sent_ewma);
+	rtt_ratio100 = qos->rtt_ratio100;
+
+	/* Refresh throughput. If a long time has passed since we
+           received last req, throughput data is stale. */
+	calc_throughput(qos, OST_READ-OST_READ, 0);
+	calc_throughput(qos, OST_WRITE-OST_READ, 0);
+
+	read_tp   = qos->tp_last_sec[0];
+	write_tp  = qos->tp_last_sec[1];
+	spin_unlock(&qos->lock);
+	seq_printf(m, "       ack_ewma: %llu usec\n"
+		   "       sent_ewma: %llu usec\n"
+		   "       rtt_ratio100: %d\n",
+		   ack_ewma, sent_ewma, rtt_ratio100);
+#endif
 
 	k = 0;
 	for(j = 0; j < IMP_AT_MAX_PORTALS; j++) {
@@ -938,6 +966,10 @@ int lprocfs_import_seq_show(struct seq_file *m, void *data)
 					   k / j, (100 * k / j) % 100);
 		}
 	}
+#ifdef ENABLE_RLQOS
+	seq_printf(m, "    read_throughput: %llu\n", read_tp);
+	seq_printf(m, "    write_throughput: %llu\n", write_tp);
+#endif
 
 out_climp:
 	LPROCFS_CLIMP_EXIT(obd);
diff --git a/lustre/osc/Makefile.in b/lustre/osc/Makefile.in
index b1128bc..d6edab2 100644
--- a/lustre/osc/Makefile.in
+++ b/lustre/osc/Makefile.in
@@ -1,5 +1,5 @@
 MODULES := osc
-osc-objs := osc_request.o lproc_osc.o osc_dev.o osc_object.o osc_page.o osc_lock.o osc_io.o osc_quota.o osc_cache.o
+osc-objs := osc_request.o lproc_osc.o osc_dev.o osc_object.o osc_page.o osc_lock.o osc_io.o osc_quota.o osc_cache.o qos_rules.o
 
 EXTRA_DIST = $(osc-objs:%.o=%.c) osc_internal.h osc_cl_internal.h
 
diff --git a/lustre/osc/lproc_osc.c b/lustre/osc/lproc_osc.c
index de5a29c..653afc4 100644
--- a/lustre/osc/lproc_osc.c
+++ b/lustre/osc/lproc_osc.c
@@ -1,3 +1,4 @@
+
 /*
  * GPL HEADER START
  *
@@ -38,6 +39,9 @@
 #include <lprocfs_status.h>
 #include <linux/seq_file.h>
 #include "osc_internal.h"
+#ifdef ENABLE_RLQOS
+# include "../include/rlqos.h"
+#endif
 
 #ifdef CONFIG_PROC_FS
 static int osc_active_seq_show(struct seq_file *m, void *v)
@@ -92,8 +96,10 @@ static ssize_t osc_max_rpcs_in_flight_seq_write(struct file *file,
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	struct client_obd *cli = &dev->u.cli;
+#ifdef ENABLE_RLQOS
+	struct qos_data_t *qos = &cli->qos;
+#endif
 	int rc;
-	int adding, added, req_count;
 	__s64 val;
 
 	rc = lprocfs_str_to_s64(buffer, count, &val);
@@ -103,31 +109,57 @@ static ssize_t osc_max_rpcs_in_flight_seq_write(struct file *file,
 		return -ERANGE;
 
 	LPROCFS_CLIMP_CHECK(dev);
+	set_max_rpcs_in_flight((int)val, cli);
+	LPROCFS_CLIMP_EXIT(dev);
 
-	adding = (int)val - cli->cl_max_rpcs_in_flight;
-	req_count = atomic_read(&osc_pool_req_count);
-	if (adding > 0 && req_count < osc_reqpool_maxreqcount) {
-		/*
-		 * There might be some race which will cause over-limit
-		 * allocation, but it is fine.
-		 */
-		if (req_count + adding > osc_reqpool_maxreqcount)
-			adding = osc_reqpool_maxreqcount - req_count;
-
-		added = osc_rq_pool->prp_populate(osc_rq_pool, adding);
-		atomic_add(added, &osc_pool_req_count);
-	}
-
-	spin_lock(&cli->cl_loi_list_lock);
-	cli->cl_max_rpcs_in_flight = val;
-	client_adjust_max_dirty(cli);
-	spin_unlock(&cli->cl_loi_list_lock);
+#ifdef ENABLE_RLQOS
+	/* Update the value tracked by QoS routines too */
+	spin_lock(&qos->lock);
+	qos->max_rpc_in_flight100 = val * 100;
+	spin_unlock(&qos->lock);
+#endif
 
-	LPROCFS_CLIMP_EXIT(dev);
 	return count;
 }
 LPROC_SEQ_FOPS(osc_max_rpcs_in_flight);
 
+#ifdef ENABLE_RLQOS
+static int osc_min_brw_rpc_gap_seq_show(struct seq_file *m, void *v)
+{
+	struct obd_device *dev = m->private;
+	struct client_obd *cli = &dev->u.cli;
+	struct qos_data_t *qos = &cli->qos;
+
+	spin_lock(&qos->lock);
+	seq_printf(m, "%u\n", qos->min_usec_between_rpcs);
+	spin_unlock(&qos->lock);
+	return 0;
+}
+
+static ssize_t osc_min_brw_rpc_gap_seq_write(struct file *file,
+					     const char __user *buffer,
+					     size_t count, loff_t *off)
+{
+	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
+	struct client_obd *cli = &dev->u.cli;
+	int rc;
+	__s64 val;
+	struct qos_data_t *qos = &cli->qos;
+
+	rc = lprocfs_str_to_s64(buffer, count, &val);
+	if (rc)
+		return rc;
+	if (val < 0)
+		return -ERANGE;
+
+	spin_lock(&qos->lock);
+	qos->min_usec_between_rpcs = val;
+	spin_unlock(&qos->lock);
+	return count;
+}
+LPROC_SEQ_FOPS(osc_min_brw_rpc_gap);
+#endif
+
 static int osc_max_dirty_mb_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *dev = m->private;
@@ -599,6 +631,83 @@ static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 }
 LPROC_SEQ_FOPS_RO(osc_unstable_stats);
 
+#ifdef ENABLE_RLQOS
+static int osc_qos_rules_seq_show(struct seq_file *m, void *data)
+{
+	struct obd_device *dev = m->private;
+	struct client_obd *cli = &dev->u.cli;
+	struct qos_data_t *qos = &cli->qos;
+	int i;
+	struct qos_rule_t *r;
+
+	spin_lock(&qos->lock);
+	if (0 == qos->rule_no || NULL == qos->rules || 0 == qos->min_gap_between_updating_mrif) {
+		seq_printf(m, "0\n");
+		/* Make sure the upcoming for loop doesn't run */
+		qos->rule_no = 0;
+	} else {
+		seq_printf(m, "%d,%d\n", qos->rule_no, 1000000 / qos->min_gap_between_updating_mrif);
+	}
+	for (i = 0; i < qos->rule_no; ++i) {
+		r = &qos->rules[i];
+		seq_printf(m, "%llu,%llu,%llu,%llu,%u,%u,%d,%d,%u,%d,%llu,%llu,%u\n",
+			      r->ack_ewma_lower,  r->ack_ewma_upper,
+			      r->send_ewma_lower, r->send_ewma_upper,
+			      r->rtt_ratio100_lower, r->rtt_ratio100_upper,
+			      r->m100, r->b100, r->tau,
+			      r->used_times,
+			      r->ack_ewma_avg, r->send_ewma_avg, r->rtt_ratio100_avg);
+	}
+	spin_unlock(&qos->lock);
+	return 0;
+}
+
+static ssize_t osc_qos_rules_seq_write(struct file *file,
+				       const char __user *buffer,
+				       size_t count, loff_t *off)
+{
+	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
+	struct client_obd *cli = &dev->u.cli;
+	struct qos_data_t *qos = &cli->qos;
+	int rc;
+	char *kernbuf = NULL;
+
+	OBD_ALLOC(kernbuf, count + 1);
+	if (NULL == kernbuf) {
+		return -ENOMEM;
+	}
+	if (copy_from_user(kernbuf, buffer, count)) {
+		rc = -EFAULT;
+		goto out_free_kernbuf;
+	}
+	/* Make sure the buf ends with a null so that sscanf won't overread */
+	kernbuf[count] = '\0';
+
+	spin_lock(&qos->lock);
+	/* parse_qos_rules() will free existing rules in qos before starting parsing */
+	rc = parse_qos_rules(kernbuf, qos);
+	if (0 == rc) {
+		/* return the number of chars processed on a success parsing */
+		rc = count;
+	}
+	qos->ack_ewma.ea = 0;
+	qos->ack_ewma.last_time.tv_sec = 0;
+	qos->ack_ewma.last_time.tv_usec = 0;
+	qos->sent_ewma.ea = 0;
+	qos->sent_ewma.last_time.tv_sec = 0;
+	qos->sent_ewma.last_time.tv_usec = 0;
+	qos->rtt_ratio100 = 0;
+	qos->smallest_rtt = 0;
+	qos->min_usec_between_rpcs = 0;
+	spin_unlock(&qos->lock);
+out_free_kernbuf:
+	OBD_FREE(kernbuf, count + 1);
+	return rc;
+
+}
+LPROC_SEQ_FOPS(osc_qos_rules);
+#endif
+
 LPROC_SEQ_FOPS_RO_TYPE(osc, uuid);
 LPROC_SEQ_FOPS_RO_TYPE(osc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(osc, blksize);
@@ -647,6 +756,10 @@ struct lprocfs_vars lprocfs_osc_obd_vars[] = {
 	  .fops	=	&osc_obd_max_pages_per_rpc_fops	},
 	{ .name	=	"max_rpcs_in_flight",
 	  .fops	=	&osc_max_rpcs_in_flight_fops	},
+#ifdef ENABLE_RLQOS
+	{ .name	=	"min_brw_rpc_gap",
+	  .fops	=	&osc_min_brw_rpc_gap_fops	},
+#endif
 	{ .name	=	"destroys_in_flight",
 	  .fops	=	&osc_destroys_in_flight_fops	},
 	{ .name	=	"max_dirty_mb",
@@ -683,6 +796,10 @@ struct lprocfs_vars lprocfs_osc_obd_vars[] = {
 	  .fops	=	&osc_pinger_recov_fops		},
 	{ .name	=	"unstable_stats",
 	  .fops	=	&osc_unstable_stats_fops	},
+#ifdef ENABLE_RLQOS
+	{ .name	=	"qos_rules",
+	  .fops	=	&osc_qos_rules_fops		},
+#endif
 	{ NULL }
 };
 
diff --git a/lustre/osc/qos_rules.c b/lustre/osc/qos_rules.c
new file mode 100644
index 0000000..8db24bd
--- /dev/null
+++ b/lustre/osc/qos_rules.c
@@ -0,0 +1,125 @@
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
+ * qos_rules.c
+ */
+#ifndef __KERNEL__
+  #include <stdio.h>
+  #include "kernel-test-primitives.h"
+  #include <string.h>
+#endif
+#include "../include/rlqos.h"
+
+/* Parse qos_rules in buf and store the result to qos.
+ *
+ * Pre-condition:
+ *   1. qos must be initialized and qos->lock MUST be held before calling this function!
+ *   2. exisiting rules in qos->rules will be freed
+ *   3. buf must be NULL-terminated or sscanf may overread it.
+ *
+ * Return value:
+ *  0: success
+ *  other value: error code. On error, qos->rules is NULL and qos->rule_no is 0.
+ */
+int parse_qos_rules(const char *buf, struct qos_data_t *qos)
+{
+	int new_rule_no = 0;
+	int rules_per_sec = 0;
+	int rc;
+	int i;
+	const char *p = buf;
+	int n;
+	const size_t rule_size = sizeof(*(qos->rules));
+	struct qos_rule_t *r;
+
+	/* handle "0\n" and "0" */
+	if (strlen(p) <= 2 && '0' == *p) {
+		if (qos->rules) {
+			LIBCFS_FREE(qos->rules, qos->rule_no * rule_size);
+		}
+		qos->rule_no = 0;
+		qos->rules = NULL;
+		return 0;
+	}
+
+	rc = sscanf(p, "%d,%d\n%n", &new_rule_no, &rules_per_sec, &n);
+	if (2 != rc) {
+		CWARN("Input data error, can't read new_rule_no\n");
+		return -EINVAL;
+	}
+	if (0 == new_rule_no || 0 == rules_per_sec) {
+		if (qos->rules) {
+			LIBCFS_FREE(qos->rules, qos->rule_no * rule_size);
+		}
+		qos->rule_no = 0;
+		qos->rules = NULL;
+		return 0;
+	}
+	p += n;
+	if (qos->rules) {
+		LIBCFS_FREE(qos->rules, qos->rule_no * rule_size);
+	}
+	qos->rule_no = new_rule_no;
+	qos->min_gap_between_updating_mrif = 1000000 / rules_per_sec;
+	LIBCFS_ALLOC_ATOMIC(qos->rules, new_rule_no * rule_size);
+	if (!qos->rules) {
+		CWARN("Can't allocate enough mem for %d rules\n", new_rule_no);
+		return -ENOMEM;
+	}
+	memset(qos->rules, 0, new_rule_no * rule_size);
+
+	for (i = 0; i < new_rule_no; i++) {
+		r = &qos->rules[i];
+		/* Don't put \n at the end of sscanf format str
+		   because there may be other unknown fields there,
+		   which will be discarded later */
+		rc = sscanf(p, "%llu,%llu,%llu,%llu,%u,%u,%d,%d,%u%n",
+		                &r->ack_ewma_lower,  &r->ack_ewma_upper,
+		                &r->send_ewma_lower, &r->send_ewma_upper,
+		                &r->rtt_ratio100_lower, &r->rtt_ratio100_upper,
+		                &r->m100, &r->b100, &r->tau, &n);
+		p += n;
+		if (rc != 9) {
+			CWARN("QoS rule parsing error, rc = %d\n", rc);
+			LIBCFS_FREE(qos->rules, qos->rule_no * rule_size);
+			qos->rules = NULL;
+			qos->rule_no = 0;
+			return -EINVAL;
+		}
+		/* consume all other chars till \n or end-of-buffer */
+		while (*p != '\0' && *(p++) != '\n')
+			;
+	}
+
+	return 0;
+}
-- 
1.8.3.1
