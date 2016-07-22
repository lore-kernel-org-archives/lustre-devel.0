From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:43:58 -0400
Subject: [lustre-devel] [PATCH 05/58] staging: lustre: lmv: add new lmv
	structures
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Newer lustre version on metadata servers support different
version of lmv magic. This add the new data structures
to handle these new lmv magic versions.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   81 +++++++++++++++++---
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   66 ++++++++++++++++
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    1 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    1 +
 5 files changed, 140 insertions(+), 10 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_lmv.h

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 051864c..32471a6 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2482,16 +2482,6 @@ struct lmv_desc {
 	struct obd_uuid ld_uuid;
 };
 
-/* TODO: lmv_stripe_md should contain mds capabilities for all slave fids */
-struct lmv_stripe_md {
-	__u32	 mea_magic;
-	__u32	 mea_count;
-	__u32	 mea_master;
-	__u32	 mea_padding;
-	char	  mea_pool_name[LOV_MAXPOOLNAME];
-	struct lu_fid mea_ids[0];
-};
-
 #define MEA_MAGIC_LAST_CHAR      0xb2221ca1
 #define MEA_MAGIC_ALL_CHARS      0xb222a11c
 #define MEA_MAGIC_HASH_SEGMENT   0xb222a11b
@@ -2500,6 +2490,77 @@ struct lmv_stripe_md {
 #define MAX_HASH_SIZE	    0x7fffffffffffffffULL
 #define MAX_HASH_HIGHEST_BIT     0x1000000000000000ULL
 
+/* lmv structures */
+#define LMV_MAGIC_V1	0x0CD10CD0	/* normal stripe lmv magic */
+#define LMV_USER_MAGIC	0x0CD20CD0	/* default lmv magic*/
+#define LMV_MAGIC	LMV_MAGIC_V1
+struct lmv_mds_md_v1 {
+	__u32 lmv_magic;
+	__u32 lmv_stripe_count;		/* stripe count */
+	__u32 lmv_master_mdt_index;	/* master MDT index */
+	__u32 lmv_hash_type;		/* dir stripe policy, i.e. indicate
+					 * which hash function to be used
+					 */
+	__u32 lmv_layout_version;	/* Used for directory restriping */
+	__u32 lmv_padding;
+	char lmv_pool_name[LOV_MAXPOOLNAME];	/* pool name */
+	struct lu_fid lmv_stripe_fids[0];	/* FIDs for each stripe */
+};
+
+union lmv_mds_md {
+	__u32			lmv_magic;
+	struct lmv_mds_md_v1	lmv_md_v1;
+	struct lmv_user_md	lmv_user_md;
+};
+
+static inline ssize_t lmv_mds_md_size(int stripe_count, unsigned int lmm_magic)
+{
+	ssize_t len = -EINVAL;
+
+	switch (lmm_magic) {
+	case LMV_MAGIC_V1: {
+		struct lmv_mds_md_v1 *lmm1;
+
+		len = sizeof(*lmm1);
+		len += stripe_count * sizeof(lmm1->lmv_stripe_fids[0]);
+		break; }
+	default:
+		break;
+	}
+	return len;
+}
+
+static inline int lmv_mds_md_stripe_count_get(const union lmv_mds_md *lmm)
+{
+	switch (le32_to_cpu(lmm->lmv_magic)) {
+	case LMV_MAGIC_V1:
+		return le32_to_cpu(lmm->lmv_md_v1.lmv_stripe_count);
+	case LMV_USER_MAGIC:
+		return le32_to_cpu(lmm->lmv_user_md.lum_stripe_count);
+	default:
+		return -EINVAL;
+	}
+}
+
+static inline int lmv_mds_md_stripe_count_set(union lmv_mds_md *lmm,
+					      unsigned int stripe_count)
+{
+	int rc = 0;
+
+	switch (le32_to_cpu(lmm->lmv_magic)) {
+	case LMV_MAGIC_V1:
+		lmm->lmv_md_v1.lmv_stripe_count = cpu_to_le32(stripe_count);
+		break;
+	case LMV_USER_MAGIC:
+		lmm->lmv_user_md.lum_stripe_count = cpu_to_le32(stripe_count);
+		break;
+	default:
+		rc = -EINVAL;
+		break;
+	}
+	return rc;
+}
+
 enum fld_rpc_opc {
 	FLD_QUERY	= 900,
 	FLD_READ	= 901,
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
new file mode 100644
index 0000000..0620c8c
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -0,0 +1,66 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2 for more details.  A copy is
+ * included in the COPYING file that accompanied this code.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2013, Intel Corporation.
+ */
+/*
+ * lustre/include/lustre_lmv.h
+ *
+ * Lustre LMV structures and functions.
+ *
+ * Author: Di Wang <di.wang@intel.com>
+ */
+
+#ifndef _LUSTRE_LMV_H
+#define _LUSTRE_LMV_H
+#include "lustre/lustre_idl.h"
+
+struct lmv_oinfo {
+	struct lu_fid	lmo_fid;
+	u32		lmo_mds;
+	struct inode	*lmo_root;
+};
+
+struct lmv_stripe_md {
+	__u32	mea_magic;
+	__u32	mea_count;
+	__u32	mea_master;
+	__u32	mea_padding;
+	char	mea_pool_name[LOV_MAXPOOLNAME];
+	struct lu_fid mea_ids[0];
+};
+
+union lmv_mds_md;
+
+int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
+		  const union lmv_mds_md *lmm, int stripe_count);
+
+static inline int lmv_alloc_memmd(struct lmv_stripe_md **lsmp, int stripe_count)
+{
+	return lmv_unpack_md(NULL, lsmp, NULL, stripe_count);
+}
+
+static inline void lmv_free_memmd(struct lmv_stripe_md *lsm)
+{
+	lmv_unpack_md(NULL, &lsm, NULL, 0);
+}
+#endif
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 0beafc4..471470b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -35,6 +35,7 @@
 
 #include "../include/lustre/lustre_idl.h"
 #include "../include/obd.h"
+#include "../include/lustre_lmv.h"
 
 #define LMV_MAX_TGT_COUNT 128
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index fac04f0..8e83263 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -46,6 +46,7 @@
 #include "../include/lustre_lib.h"
 #include "../include/lustre_net.h"
 #include "../include/obd_class.h"
+#include "../include/lustre_lmv.h"
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_lite.h"
 #include "../include/lustre_fid.h"
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 4fc3f9b..ab78754 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -40,6 +40,7 @@
 
 #include "../include/lustre_acl.h"
 #include "../include/obd_class.h"
+#include "../include/lustre_lmv.h"
 #include "../include/lustre_fid.h"
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_param.h"
-- 
1.7.1
