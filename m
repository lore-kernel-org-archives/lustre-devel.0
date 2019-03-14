From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:52 +1100
Subject: [lustre-devel] [PATCH 31/32] lustre: mdc: create mdc_acl.c
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231217.26912.1851699923338684554.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This new C file contains acl related code so it can be
conditionally compiled.

The only use of CONFIG_LUSTRE_FS_POSIX_ACL in a C file is
now in xattr.c which is not convenient to avoid.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/mdc/Makefile       |    1 
 drivers/staging/lustre/lustre/mdc/mdc_acl.c      |   48 +++++++++++++++++++
 drivers/staging/lustre/lustre/mdc/mdc_internal.h |   10 ++++
 drivers/staging/lustre/lustre/mdc/mdc_request.c  |   57 +---------------------
 4 files changed, 61 insertions(+), 55 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/mdc/mdc_acl.c

diff --git a/drivers/staging/lustre/lustre/mdc/Makefile b/drivers/staging/lustre/lustre/mdc/Makefile
index 5f48e91b9839..137a4413c268 100644
--- a/drivers/staging/lustre/lustre/mdc/Makefile
+++ b/drivers/staging/lustre/lustre/mdc/Makefile
@@ -3,3 +3,4 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += mdc.o
 mdc-y := mdc_changelog.o mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
+mdc-$(CONFIG_LUSTRE_FS_POSIX_ACL) += mdc_acl.o
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_acl.c b/drivers/staging/lustre/lustre/mdc/mdc_acl.c
new file mode 100644
index 000000000000..045235ad703a
--- /dev/null
+++ b/drivers/staging/lustre/lustre/mdc/mdc_acl.c
@@ -0,0 +1,48 @@
+// SPDX-License-Identifier: GPL-2.0
+
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
+
+	if (!buf)
+		return -EPROTO;
+
+	acl = posix_acl_from_xattr(&init_user_ns, buf, body->mbo_aclsize);
+	if (!acl)
+		return 0;
+
+	if (IS_ERR(acl)) {
+		rc = PTR_ERR(acl);
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
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 2b849e8166b2..20beff384add 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -141,6 +141,16 @@ static inline int mdc_prep_elc_req(struct obd_export *exp,
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
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index a0b74244f295..7d4450ef8740 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -408,46 +408,6 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 				req);
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
@@ -526,21 +486,8 @@ static int mdc_get_lustre_md(struct obd_export *exp,
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
+	if (md->body->mbo_valid & OBD_MD_FLACL)
+		rc = mdc_unpack_acl(req, md);
 
 out:
 	if (rc)
