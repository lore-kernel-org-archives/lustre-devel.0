From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:54 -0400
Subject: [lustre-devel] [PATCH 17/45] lustre: quota: quota pools for OSTs
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sergey Cheremencev <c17829@cray.com>

Patch allows to apply quota settings
not only for the whole system, but also
for different OST pools. Since this patch
each "LOD" pool is duplicated by QMT.
Thus quota pools(QP) could be tuned by
standard lctl pool_new/add/remove/erase
commands. All QPs are subset of a global pool
that includes all data devices in a system,
including DOM. However DOM is not supported.
I don't see a lot of work to add DOM support
in future - just need to decide how MDTs
could be combined in a pool.

The main idea of QP is to find all pools
for requested ID(usr/grp/prj) and apply
minimum limit. The patch doesn't affect
qsd side, so slaves know nothing about
pools and different limits. Qunit and edquot
are calculated for each slave on master.

To apply quota on QP, the patch adds key "-o"
to lfs setquota. To get quotas for QP, it
provides long option "--pool" in lfs quota.
See examples of using in sanity-quota_1b/c/d.

Now QPs work properly only on a clean system.
Support of recalculation granted space in case
of adding/removing OSTs in a pool will be added
in the next patch together with accounting
already granted space by each ID in a POOl.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11023
Lustre-commit: 09f9fb3211cd9 ("LU-11023 quota: quota pools for OSTs")
Signed-off-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-on: https://review.whamcloud.com/35615
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h           | 11 +------
 fs/lustre/include/lustre_req_layout.h   |  1 +
 fs/lustre/include/lustre_swab.h         |  2 +-
 fs/lustre/include/obd_target.h          | 54 +++++++++++++++++++++++++++++++++
 fs/lustre/llite/dir.c                   | 30 +++++++++++++++---
 fs/lustre/mdc/mdc_request.c             | 40 ++++++++++++++++--------
 fs/lustre/ptlrpc/layout.c               |  6 ++--
 fs/lustre/ptlrpc/pack_generic.c         |  7 ++++-
 include/uapi/linux/lustre/lustre_idl.h  | 21 ++++++++-----
 include/uapi/linux/lustre/lustre_user.h | 11 +++++++
 10 files changed, 143 insertions(+), 40 deletions(-)
 create mode 100644 fs/lustre/include/obd_target.h

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 57c2573..d0a59ff 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -38,6 +38,7 @@
 #include <linux/percpu_counter.h>
 #include <linux/libcfs/libcfs.h>
 #include <linux/ctype.h>
+#include <obd_target.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lu_ref.h>
 
@@ -1399,16 +1400,6 @@ struct lu_kmem_descr {
 extern u32 lu_context_tags_default;
 extern u32 lu_session_tags_default;
 
-/* Generic subset of tgts */
-struct lu_tgt_pool {
-	u32		   *op_array;	/* array of index of
-					 * lov_obd->lov_tgts
-					 */
-	unsigned int	    op_count;	/* number of tgts in the array */
-	unsigned int	    op_size;	/* allocated size of op_array */
-	struct rw_semaphore op_rw_sem;	/* to protect lu_tgt_pool use */
-};
-
 /* round-robin QoS data for LOD/LMV */
 struct lu_qos_rr {
 	spinlock_t		 lqr_alloc;	/* protect allocation index */
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index f56dc8b..8efdf7f 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -266,6 +266,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_msg_field RMF_CAPA2;
 extern struct req_msg_field RMF_OBD_QUOTACHECK;
 extern struct req_msg_field RMF_OBD_QUOTACTL;
+extern struct req_msg_field RMF_OBD_QUOTACTL_POOL;
 extern struct req_msg_field RMF_STRING;
 extern struct req_msg_field RMF_SWAP_LAYOUTS;
 extern struct req_msg_field RMF_MDS_HSM_PROGRESS;
diff --git a/fs/lustre/include/lustre_swab.h b/fs/lustre/include/lustre_swab.h
index a4db957..bac3636 100644
--- a/fs/lustre/include/lustre_swab.h
+++ b/fs/lustre/include/lustre_swab.h
@@ -60,7 +60,7 @@
 void lustre_swab_niobuf_remote(struct niobuf_remote *nbr);
 void lustre_swab_ost_lvb_v1(struct ost_lvb_v1 *lvb);
 void lustre_swab_ost_lvb(struct ost_lvb *lvb);
-void lustre_swab_obd_quotactl(struct obd_quotactl *q);
+int lustre_swab_obd_quotactl(struct obd_quotactl *q, u32 len);
 void lustre_swab_lquota_lvb(struct lquota_lvb *lvb);
 void lustre_swab_generic_32s(u32 *val);
 void lustre_swab_mdt_body(struct mdt_body *b);
diff --git a/fs/lustre/include/obd_target.h b/fs/lustre/include/obd_target.h
new file mode 100644
index 0000000..466dd3c
--- /dev/null
+++ b/fs/lustre/include/obd_target.h
@@ -0,0 +1,54 @@
+// SPDX-License-Identifier: GPL-2.0
+/* GPL HEADER START
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
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2014, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+
+#ifndef __OBD_TARGET_H
+#define __OBD_TARGET_H
+#include <lprocfs_status.h>
+
+/* Generic subset of tgts */
+struct lu_tgt_pool {
+	__u32		   *op_array;	/* array of index of
+					 * lov_obd->lov_tgts
+					 */
+	unsigned int	    op_count;	/* number of tgts in the array */
+	unsigned int	    op_size;	/* allocated size of op_array */
+	struct rw_semaphore op_rw_sem;	/* to protect lu_tgt_pool use */
+};
+
+int tgt_pool_init(struct lu_tgt_pool *op, unsigned int count);
+int tgt_pool_add(struct lu_tgt_pool *op, __u32 idx, unsigned int min_count);
+int tgt_pool_remove(struct lu_tgt_pool *op, __u32 idx);
+int tgt_pool_free(struct lu_tgt_pool *op);
+int tgt_check_index(int idx, struct lu_tgt_pool *osts);
+int tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count);
+
+#endif /* __OBD_TARGET_H */
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 47803a1..41e399b 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1083,15 +1083,19 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 	case Q_SETQUOTA:
 	case Q_SETINFO:
 	case LUSTRE_Q_SETDEFAULT:
+	case LUSTRE_Q_SETQUOTAPOOL:
+	case LUSTRE_Q_SETINFOPOOL:
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 		break;
 	case Q_GETQUOTA:
 	case LUSTRE_Q_GETDEFAULT:
+	case LUSTRE_Q_GETQUOTAPOOL:
 		if (check_owner(type, id) && !capable(CAP_SYS_ADMIN))
 			return -EPERM;
 		break;
 	case Q_GETINFO:
+	case LUSTRE_Q_GETINFOPOOL:
 		break;
 	default:
 		CERROR("unsupported quotactl op: %#x\n", cmd);
@@ -1101,7 +1105,8 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 	if (valid != QC_GENERAL) {
 		if (cmd == Q_GETINFO)
 			qctl->qc_cmd = Q_GETOINFO;
-		else if (cmd == Q_GETQUOTA)
+		else if (cmd == Q_GETQUOTA ||
+			 cmd == LUSTRE_Q_GETQUOTAPOOL)
 			qctl->qc_cmd = Q_GETOQUOTA;
 		else
 			return -EINVAL;
@@ -1134,8 +1139,12 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 		qctl->qc_cmd = cmd;
 	} else {
 		struct obd_quotactl *oqctl;
+		int oqctl_len = sizeof(*oqctl);
 
-		oqctl = kzalloc(sizeof(*oqctl), GFP_NOFS);
+		if (LUSTRE_Q_CMD_IS_POOL(cmd))
+			oqctl_len += LOV_MAXPOOLNAME + 1;
+
+		oqctl = kzalloc(oqctl_len, GFP_NOFS);
 		if (!oqctl)
 			return -ENOMEM;
 
@@ -1148,7 +1157,7 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 		/* If QIF_SPACE is not set, client should collect the
 		 * space usage from OSSs by itself
 		 */
-		if (cmd == Q_GETQUOTA &&
+		if ((cmd == Q_GETQUOTA || cmd == LUSTRE_Q_GETQUOTAPOOL) &&
 		    !(oqctl->qc_dqblk.dqb_valid & QIF_SPACE) &&
 		    !oqctl->qc_dqblk.dqb_curspace) {
 			struct obd_quotactl *oqctl_tmp;
@@ -1807,8 +1816,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	}
 	case OBD_IOC_QUOTACTL: {
 		struct if_quotactl *qctl;
+		int qctl_len = sizeof(*qctl) + LOV_MAXPOOLNAME + 1;
 
-		qctl = kzalloc(sizeof(*qctl), GFP_NOFS);
+		qctl = kzalloc(qctl_len, GFP_NOFS);
 		if (!qctl)
 			return -ENOMEM;
 
@@ -1817,8 +1827,18 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto out_quotactl;
 		}
 
-		rc = quotactl_ioctl(sbi, qctl);
+		if (LUSTRE_Q_CMD_IS_POOL(qctl->qc_cmd)) {
+			char __user *from = (char __user *)arg +
+					    offsetof(typeof(*qctl), qc_poolname);
 
+			if (copy_from_user(qctl->qc_poolname, from,
+					   LOV_MAXPOOLNAME + 1)) {
+				rc = -EFAULT;
+				goto out_quotactl;
+			}
+		}
+
+		rc = quotactl_ioctl(sbi, qctl);
 		if (rc == 0 && copy_to_user((void __user *)arg, qctl,
 					    sizeof(*qctl)))
 			rc = -EFAULT;
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index c71b642..0cbab8b 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2073,34 +2073,50 @@ static int mdc_quotactl(struct obd_device *unused, struct obd_export *exp,
 	struct obd_quotactl *oqc;
 	int rc;
 
-	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
-					&RQF_MDS_QUOTACTL, LUSTRE_MDS_VERSION,
-					MDS_QUOTACTL);
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_QUOTACTL);
 	if (!req)
 		return -ENOMEM;
 
+	if (LUSTRE_Q_CMD_IS_POOL(oqctl->qc_cmd))
+		req_capsule_set_size(&req->rq_pill,
+				     &RMF_OBD_QUOTACTL,
+				     RCL_CLIENT,
+				     sizeof(*oqc) + LOV_MAXPOOLNAME + 1);
+
+	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION,
+				 MDS_QUOTACTL);
+	if (rc) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+
 	oqc = req_capsule_client_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
-	*oqc = *oqctl;
+	QCTL_COPY(oqc, oqctl);
 
 	ptlrpc_request_set_replen(req);
 	ptlrpc_at_set_req_timeout(req);
 
 	rc = ptlrpc_queue_wait(req);
-	if (rc)
-		CERROR("ptlrpc_queue_wait failed, rc: %d\n", rc);
+	if (rc) {
+		CERROR("%s: ptlrpc_queue_wait failed: rc = %d\n",
+		       exp->exp_obd->obd_name, rc);
+		goto out;
+	}
 
 	if (req->rq_repmsg) {
 		oqc = req_capsule_server_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
 		if (oqc) {
-			*oqctl = *oqc;
-		} else if (!rc) {
-			CERROR("Can't unpack obd_quotactl\n");
-			rc = -EPROTO;
+			QCTL_COPY(oqctl, oqc);
+			goto out;
 		}
-	} else if (!rc) {
-		CERROR("Can't unpack obd_quotactl\n");
+	}
+
+	if (!rc) {
 		rc = -EPROTO;
+		CERROR("%s: cannot unpack obd_quotactl: rc = %d\n",
+		       exp->exp_obd->obd_name, rc);
 	}
+out:
 	ptlrpc_req_finished(req);
 
 	return rc;
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index fd8676d..832c896 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -923,9 +923,9 @@ struct req_msg_field RMF_MDT_BODY =
 EXPORT_SYMBOL(RMF_MDT_BODY);
 
 struct req_msg_field RMF_OBD_QUOTACTL =
-	DEFINE_MSGF("obd_quotactl", 0,
-		    sizeof(struct obd_quotactl),
-		    lustre_swab_obd_quotactl, NULL);
+	DEFINE_MSGFL("obd_quotactl", 0,
+		     sizeof(struct obd_quotactl),
+		     lustre_swab_obd_quotactl, NULL);
 EXPORT_SYMBOL(RMF_OBD_QUOTACTL);
 
 struct req_msg_field RMF_MDT_EPOCH =
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index ec853d1..82e6c46 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1893,14 +1893,19 @@ static void lustre_swab_obd_dqblk(struct obd_dqblk *b)
 	BUILD_BUG_ON(offsetof(typeof(*b), dqb_padding) == 0);
 }
 
-void lustre_swab_obd_quotactl(struct obd_quotactl *q)
+int lustre_swab_obd_quotactl(struct obd_quotactl *q, u32 len)
 {
+	if (unlikely(len <= sizeof(struct obd_quotactl)))
+		return -EOVERFLOW;
+
 	__swab32s(&q->qc_cmd);
 	__swab32s(&q->qc_type);
 	__swab32s(&q->qc_id);
 	__swab32s(&q->qc_stat);
 	lustre_swab_obd_dqinfo(&q->qc_dqinfo);
 	lustre_swab_obd_dqblk(&q->qc_dqblk);
+
+	return len;
 }
 
 void lustre_swab_fid2path(struct getinfo_fid2path *gf)
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index fd880f3..743af77 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1363,18 +1363,23 @@ struct obd_quotactl {
 	__u32			qc_stat;
 	struct obd_dqinfo	qc_dqinfo;
 	struct obd_dqblk	qc_dqblk;
+	char			qc_poolname[0];
 };
 
 #define Q_COPY(out, in, member) (out)->member = (in)->member
 
-#define QCTL_COPY(out, in)		\
-do {					\
-	Q_COPY(out, in, qc_cmd);	\
-	Q_COPY(out, in, qc_type);	\
-	Q_COPY(out, in, qc_id);		\
-	Q_COPY(out, in, qc_stat);	\
-	Q_COPY(out, in, qc_dqinfo);	\
-	Q_COPY(out, in, qc_dqblk);	\
+#define QCTL_COPY(out, in)			\
+do {						\
+	Q_COPY(out, in, qc_cmd);		\
+	Q_COPY(out, in, qc_type);		\
+	Q_COPY(out, in, qc_id);			\
+	Q_COPY(out, in, qc_stat);		\
+	Q_COPY(out, in, qc_dqinfo);		\
+	Q_COPY(out, in, qc_dqblk);		\
+	if (LUSTRE_Q_CMD_IS_POOL(in->qc_cmd))	\
+		memcpy(out->qc_poolname,	\
+		       in->qc_poolname,		\
+		       LOV_MAXPOOLNAME + 1);	\
 } while (0)
 
 /* Data structures associated with the quota locks */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 9196357..6644b99 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -890,6 +890,10 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 #define LUSTRE_Q_FINVALIDATE	0x80000c	/* deprecated as of 2.4 */
 #define LUSTRE_Q_GETDEFAULT	0x80000d	/* get default quota */
 #define LUSTRE_Q_SETDEFAULT	0x80000e	/* set default quota */
+#define LUSTRE_Q_GETQUOTAPOOL	0x80000f	/* get user pool quota */
+#define LUSTRE_Q_SETQUOTAPOOL	0x800010	/* set user pool quota */
+#define LUSTRE_Q_GETINFOPOOL	0x800011	/* get pool quota info */
+#define LUSTRE_Q_SETINFOPOOL	0x800012	/* set pool quota info */
 
 /* In the current Lustre implementation, the grace time is either the time
  * or the timestamp to be used after some quota ID exceeds the soft limt,
@@ -911,6 +915,12 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
  */
 #define LQUOTA_FLAG_DEFAULT	0x0001
 
+#define LUSTRE_Q_CMD_IS_POOL(cmd)		\
+	(cmd == LUSTRE_Q_GETQUOTAPOOL ||	\
+	 cmd == LUSTRE_Q_SETQUOTAPOOL ||	\
+	 cmd == LUSTRE_Q_SETINFOPOOL ||		\
+	 cmd == LUSTRE_Q_GETINFOPOOL)
+
 #define ALLQUOTA 255	/* set all quota */
 
 static inline const char *qtype_name(int qtype)
@@ -1009,6 +1019,7 @@ struct if_quotactl {
 	struct obd_dqblk  qc_dqblk;
 	char		  obd_type[16];
 	struct obd_uuid	  obd_uuid;
+	char		  qc_poolname[0];
 };
 
 /* swap layout flags */
-- 
1.8.3.1
