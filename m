From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:15 -0500
Subject: [lustre-devel] [PATCH 267/622] lustre: osd: Set max ea size to
 XATTR_SIZE_MAX
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-268-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Lustre currently limits EA size to either ~1 MiB (ldiskfs)
or 32K (ZFS).  VFS has its own limit, XATTR_SIZE_MAX,
which we must respect to interoperate correctly with
userspace tools like tar, getattr, and the getxattr()
syscall.

Set this as the new max EA size for both ldiskfs and ZFS.

(The current 32K on ZFS is too small for
LOV_MAX_STRIPE_COUNT [2000] files, so needs to be raised
regardless.)

In order to use this correctly, we have to use the real ea
size on the client.  The previous code for maximum ea size
on the client (KEY_MAX_EASIZE, llite.max_easize) used a
calculated value based on number of targets.

With one exception, the mdc code already uses the default
ea size rather than the max.  Default ea size adjusts
automatically to the largest size sent by the server.

The exception is the open code, which uses the max so it
never has to resend a layout request.  This patch changes
it to use default, which means that the first time a very
widely striped file is opened, the open will be resent.

Add limit checks on client & server so the xattr size limit
is honored.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11868
Lustre-commit: 3ec712bd183a ("LU-11868 osd: Set max ea size to XATTR_SIZE_MAX")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34058
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h     |  7 +++++++
 fs/lustre/llite/llite_lib.c |  4 ++++
 fs/lustre/lov/lov_obd.c     |  5 +----
 fs/lustre/mdc/mdc_locks.c   | 12 ++++++------
 4 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 2195f85..687b54b 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -154,6 +154,13 @@ enum obd_cl_sem_lock_class {
  */
 #define OBD_MAX_DEFAULT_EA_SIZE		4096
 
+/*
+ * Lustre can handle larger xattrs internally, but we must respect the Linux
+ * VFS limitation or tools like tar cannot interact with Lustre volumes
+ * correctly.
+ */
+#define OBD_MAX_EA_SIZE		XATTR_SIZE_MAX
+
 struct mdc_rpc_lock;
 struct obd_import;
 struct client_obd {
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 347bdd6..aadde3f 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -663,12 +663,16 @@ int ll_get_max_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 		return rc;
 	}
 
+	CDEBUG(D_INFO, "max LOV ea size: %d\n", *lmmsize);
+
 	size = sizeof(int);
 	rc = obd_get_info(NULL, sbi->ll_md_exp, sizeof(KEY_MAX_EASIZE),
 			  KEY_MAX_EASIZE, &size, lmmsize);
 	if (rc)
 		CERROR("Get max mdsize error rc %d\n", rc);
 
+	CDEBUG(D_INFO, "max LMV ea size: %d\n", *lmmsize);
+
 	return rc;
 }
 
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 240cc6f9..3a90e7e 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -1162,10 +1162,7 @@ static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
 	lov_tgts_getref(obddev);
 
 	if (KEY_IS(KEY_MAX_EASIZE)) {
-		u32 max_stripe_count = min_t(u32, ld->ld_active_tgt_count,
-					     LOV_MAX_STRIPE_COUNT);
-
-		*((u32 *)val) = lov_mds_md_size(max_stripe_count, LOV_MAGIC_V3);
+		*((u32 *)val) = exp->exp_connect_data.ocd_max_easize;
 	} else if (KEY_IS(KEY_DEFAULT_EASIZE)) {
 		u32 def_stripe_count = min_t(u32, ld->ld_default_stripe_count,
 					     LOV_MAX_STRIPE_COUNT);
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 019eb35..f6273ef 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -256,12 +256,15 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	struct ldlm_intent *lit;
 	const void *lmm = op_data->op_data;
 	u32 lmmsize = op_data->op_data_size;
+	u32 mdt_md_capsule_size;
 	LIST_HEAD(cancels);
 	int count = 0;
 	enum ldlm_mode mode;
 	int rc;
 	int repsize, repsize_estimate;
 
+	mdt_md_capsule_size = obddev->u.cli.cl_default_mds_easize;
+
 	it->it_create_mode = (it->it_create_mode & ~S_IFMT) | S_IFREG;
 
 	/* XXX: openlock is not cancelled for cross-refs. */
@@ -348,7 +351,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 		      lmmsize);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
-			     obddev->u.cli.cl_max_mds_easize);
+			     mdt_md_capsule_size);
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 
 	if (!(it->it_op & IT_CREAT) && it->it_op & IT_OPEN &&
@@ -387,7 +390,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 				      lustre_msg_early_size());
 	/* Estimate free space for DoM files in repbuf */
 	repsize_estimate = repsize - (req->rq_replen -
-			   obddev->u.cli.cl_max_mds_easize +
+			   mdt_md_capsule_size +
 			   sizeof(struct lov_comp_md_v1) +
 			   sizeof(struct lov_comp_md_entry_v1) +
 			   lov_mds_md_size(0, LOV_MAGIC_V3));
@@ -539,10 +542,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
 	lit->opc = (u64)it->it_op;
 
-	if (obddev->u.cli.cl_default_mds_easize > 0)
-		easize = obddev->u.cli.cl_default_mds_easize;
-	else
-		easize = obddev->u.cli.cl_max_mds_easize;
+	easize = obddev->u.cli.cl_default_mds_easize;
 
 	/* pack the intended request */
 	mdc_getattr_pack(req, valid, it->it_flags, op_data, easize);
-- 
1.8.3.1
