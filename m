From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:00 -0400
Subject: [lustre-devel] [PATCH 04/23] lustre: mdc: create mdc_acl.c
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

This new C file contains acl related code so it can be
conditionally compiled.

Also remove conditional code around the call to mdc_unpack_acl(), as
those tests are already performed inside mdc_unpack_acl().

This removes all #ifdef of CONFIG_LUSTRE_FS_POSIX_ACL from C files in
'mdc'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 896ff00276afd ("LU-9679 mdc: create mdc_acl.c")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39292
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/Makefile       |  1 +
 fs/lustre/mdc/mdc_acl.c      | 64 ++++++++++++++++++++++++++++++++++++++++++++
 fs/lustre/mdc/mdc_internal.h | 10 +++++++
 fs/lustre/mdc/mdc_request.c  | 61 +++++------------------------------------
 4 files changed, 81 insertions(+), 55 deletions(-)
 create mode 100644 fs/lustre/mdc/mdc_acl.c

diff --git a/fs/lustre/mdc/Makefile b/fs/lustre/mdc/Makefile
index 2cbc641..1ac97ee 100644
--- a/fs/lustre/mdc/Makefile
+++ b/fs/lustre/mdc/Makefile
@@ -3,3 +3,4 @@ ccflags-y += -I$(srctree)/$(src)/../include
 obj-$(CONFIG_LUSTRE_FS) += mdc.o
 mdc-y := mdc_changelog.o mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
 mdc-y += mdc_dev.o
+mdc-$(CONFIG_LUSTRE_FS_POSIX_ACL) += mdc_acl.o
diff --git a/fs/lustre/mdc/mdc_acl.c b/fs/lustre/mdc/mdc_acl.c
new file mode 100644
index 0000000..6814045
--- /dev/null
+++ b/fs/lustre/mdc/mdc_acl.c
@@ -0,0 +1,64 @@
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
+#include <lustre_acl.h>
+
+#include "mdc_internal.h"
+
+int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
+{
+	struct req_capsule *pill = &req->rq_pill;
+	struct mdt_body	*body = md->body;
+	struct posix_acl *acl;
+	void *buf;
+	int rc;
+
+	/* for ACL, it's possible that FLACL is set but aclsize is zero.
+	 * only when aclsize != 0 there's an actual segment for ACL
+	 * in reply buffer.
+	 */
+	if (!body->mbo_aclsize) {
+		md->posix_acl = NULL;
+		return 0;
+	}
+
+	buf = req_capsule_server_sized_get(pill, &RMF_ACL, body->mbo_aclsize);
+	if (!buf)
+		return -EPROTO;
+
+	acl = posix_acl_from_xattr(&init_user_ns, buf, body->mbo_aclsize);
+	if (IS_ERR_OR_NULL(acl)) {
+		rc = acl ? PTR_ERR(acl) : 0;
+		CERROR("convert xattr to acl: %d\n", rc);
+		return rc;
+	}
+
+	rc = posix_acl_valid(&init_user_ns, acl);
+	if (rc) {
+		CERROR("validate acl: %d\n", rc);
+		posix_acl_release(acl);
+		return rc;
+	}
+
+	md->posix_acl = acl;
+	return 0;
+}
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index b7ccc58..a1fb5d9 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -156,6 +156,16 @@ static inline int mdc_prep_elc_req(struct obd_export *exp,
 				 count);
 }
 
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
+int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md);
+#else
+static inline
+int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
+{
+	return 0;
+}
+#endif
+
 static inline unsigned long hash_x_index(u64 hash, int hash64)
 {
 	if (BITS_PER_LONG == 32 && hash64)
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index cacc58b..f2bca8e 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -508,46 +508,6 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 	return rc;
 }
 
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-static int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
-{
-	struct req_capsule *pill = &req->rq_pill;
-	struct mdt_body	*body = md->body;
-	struct posix_acl *acl;
-	void *buf;
-	int rc;
-
-	if (!body->mbo_aclsize)
-		return 0;
-
-	buf = req_capsule_server_sized_get(pill, &RMF_ACL, body->mbo_aclsize);
-
-	if (!buf)
-		return -EPROTO;
-
-	acl = posix_acl_from_xattr(&init_user_ns, buf, body->mbo_aclsize);
-	if (!acl)
-		return 0;
-
-	if (IS_ERR(acl)) {
-		rc = PTR_ERR(acl);
-		CERROR("convert xattr to acl: %d\n", rc);
-		return rc;
-	}
-
-	rc = posix_acl_valid(&init_user_ns, acl);
-	if (rc) {
-		CERROR("validate acl: %d\n", rc);
-		posix_acl_release(acl);
-		return rc;
-	}
-
-	md->posix_acl = acl;
-	return 0;
-}
-#else
-#define mdc_unpack_acl(req, md) 0
-#endif
 
 static int mdc_get_lustre_md(struct obd_export *exp,
 			     struct ptlrpc_request *req,
@@ -658,21 +618,12 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 	}
 	rc = 0;
 
-	if (md->body->mbo_valid & OBD_MD_FLACL) {
-		/* for ACL, it's possible that FLACL is set but aclsize is zero.
-		 * only when aclsize != 0 there's an actual segment for ACL
-		 * in reply buffer.
-		 */
-		if (md->body->mbo_aclsize) {
-			rc = mdc_unpack_acl(req, md);
-			if (rc)
-				goto out;
-#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-		} else {
-			md->posix_acl = NULL;
-#endif
-		}
-	}
+	/* for ACL, it's possible that FLACL is set but aclsize is zero.
+	 * only when aclsize != 0 there's an actual segment for ACL
+	 * in reply buffer.
+	 */
+	if (md->body->mbo_valid & OBD_MD_FLACL)
+		rc = mdc_unpack_acl(req, md);
 
 out:
 	if (rc)
-- 
1.8.3.1
