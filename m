From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:54 -0400
Subject: [lustre-devel] [PATCH 035/151] lustre: jobstats: move jobstats code
 into separate file.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ben Evans <bevans@cray.com>

We'll be enhancing jobstats in future patches. To make that
easier, move the jobstats code into a separate file.

Note: the OpenSFS version of this patch added a hash table to
cache content read from the environment, but we don't use
environment values in this branch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9221
Lustre-commit: 08479b74ec35 ("LU-9221 jobstats: Create a pid-based hash for jobid values")
Signed-off-by: Ben Evans <bevans@cray.com>
Reviewed-on: https://review.whamcloud.com/25208
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/Makefile    |  3 +-
 fs/lustre/obdclass/class_obd.c | 43 ---------------------
 fs/lustre/obdclass/jobid.c     | 86 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 88 insertions(+), 44 deletions(-)
 create mode 100644 fs/lustre/obdclass/jobid.c

diff --git a/fs/lustre/obdclass/Makefile b/fs/lustre/obdclass/Makefile
index a8f30ee..96fce1b 100644
--- a/fs/lustre/obdclass/Makefile
+++ b/fs/lustre/obdclass/Makefile
@@ -7,4 +7,5 @@ obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      genops.o obd_sysfs.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
-	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o
+	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o \
+	      jobid.o
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index d8fc0db..8b6032a 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -76,49 +76,6 @@
 int at_extra = 30;
 EXPORT_SYMBOL(at_extra);
 
-char obd_jobid_var[JOBSTATS_JOBID_VAR_MAX_LEN + 1] = JOBSTATS_DISABLE;
-char obd_jobid_node[LUSTRE_JOBID_SIZE + 1];
-
-/* Get jobid of current process from stored variable or calculate
- * it from pid and user_id.
- *
- * Historically this was also done by reading the environment variable
- * stored in between the "env_start" & "env_end" of task struct.
- * This is now deprecated.
- */
-int lustre_get_jobid(char *jobid)
-{
-	char tmp_jobid[LUSTRE_JOBID_SIZE] = { 0 };
-
-	/* Jobstats isn't enabled */
-	if (strcmp(obd_jobid_var, JOBSTATS_DISABLE) == 0)
-		goto out_cache_jobid;
-
-	/* Use process name + fsuid as jobid */
-	if (strcmp(obd_jobid_var, JOBSTATS_PROCNAME_UID) == 0) {
-		snprintf(tmp_jobid, LUSTRE_JOBID_SIZE, "%s.%u",
-			 current->comm,
-			 from_kuid(&init_user_ns, current_fsuid()));
-		goto out_cache_jobid;
-	}
-
-	/* Whole node dedicated to single job */
-	if (strcmp(obd_jobid_var, JOBSTATS_NODELOCAL) == 0) {
-		strcpy(tmp_jobid, obd_jobid_node);
-		goto out_cache_jobid;
-	}
-
-	return -ENOENT;
-
-out_cache_jobid:
-	/* Only replace the job ID if it changed. */
-	if (strcmp(jobid, tmp_jobid) != 0)
-		strcpy(jobid, tmp_jobid);
-
-	return 0;
-}
-EXPORT_SYMBOL(lustre_get_jobid);
-
 static int class_resolve_dev_name(u32 len, const char *name)
 {
 	int rc;
diff --git a/fs/lustre/obdclass/jobid.c b/fs/lustre/obdclass/jobid.c
new file mode 100644
index 0000000..3655a2e
--- /dev/null
+++ b/fs/lustre/obdclass/jobid.c
@@ -0,0 +1,86 @@
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
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2014, Intel Corporation.
+ *
+ * Copyright 2017 Cray Inc, all rights reserved.
+ * Author: Ben Evans.
+ *
+ */
+
+#define DEBUG_SUBSYSTEM S_RPC
+#include <linux/user_namespace.h>
+#ifdef HAVE_UIDGID_HEADER
+#include <linux/uidgid.h>
+#endif
+
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_net.h>
+
+char obd_jobid_var[JOBSTATS_JOBID_VAR_MAX_LEN + 1] = JOBSTATS_DISABLE;
+char obd_jobid_node[LUSTRE_JOBID_SIZE + 1];
+
+/* Get jobid of current process from stored variable or calculate
+ * it from pid and user_id.
+ *
+ * Historically this was also done by reading the environment variable
+ * stored in between the "env_start" & "env_end" of task struct.
+ * This is now deprecated.
+ */
+
+int lustre_get_jobid(char *jobid)
+{
+	char tmp_jobid[LUSTRE_JOBID_SIZE] = { 0 };
+
+	/* Jobstats isn't enabled */
+	if (strcmp(obd_jobid_var, JOBSTATS_DISABLE) == 0)
+		goto out_cache_jobid;
+
+	/* Use process name + fsuid as jobid */
+	if (strcmp(obd_jobid_var, JOBSTATS_PROCNAME_UID) == 0) {
+		snprintf(tmp_jobid, LUSTRE_JOBID_SIZE, "%s.%u",
+			 current->comm,
+			 from_kuid(&init_user_ns, current_fsuid()));
+		goto out_cache_jobid;
+	}
+
+	/* Whole node dedicated to single job */
+	if (strcmp(obd_jobid_var, JOBSTATS_NODELOCAL) == 0) {
+		strcpy(tmp_jobid, obd_jobid_node);
+		goto out_cache_jobid;
+	}
+
+	return -ENOENT;
+
+out_cache_jobid:
+	/* Only replace the job ID if it changed. */
+	if (strcmp(jobid, tmp_jobid) != 0)
+		strcpy(jobid, tmp_jobid);
+
+	return 0;
+}
+EXPORT_SYMBOL(lustre_get_jobid);
-- 
1.8.3.1
