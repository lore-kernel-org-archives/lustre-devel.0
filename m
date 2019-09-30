From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:30 -0400
Subject: [lustre-devel] [PATCH 071/151] lustre: flr: extend DATA_VERSION API
 to read layout version
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-72-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

The API is extended to fetch layout version from ost objects.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: cdbe35c08c66 ("LU-9771 flr: extend DATA_VERSION API to read layout version")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29092
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h           |  1 +
 fs/lustre/llite/file.c                  | 52 +++++++++++++++++++++------------
 fs/lustre/lov/lov_io.c                  |  8 +++--
 fs/lustre/osc/osc_io.c                  | 11 +++++--
 include/uapi/linux/lustre/lustre_user.h | 11 ++++---
 5 files changed, 56 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index ef7ba76..d164294 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1798,6 +1798,7 @@ struct cl_io {
 		} ci_setattr;
 		struct cl_data_version_io {
 			u64			dv_data_version;
+			u32			dv_layout_version;
 			int			dv_flags;
 		} ci_data_version;
 		struct cl_fault_io {
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 9b441ba..05a9fea 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1851,18 +1851,8 @@ int ll_fid2path(struct inode *inode, void __user *arg)
 	return rc;
 }
 
-/*
- * Read the data_version for inode.
- *
- * This value is computed using stripe object version on OST.
- * Version is computed using server side locking.
- *
- * @flags:	if do sync on the OST side;
- *		0: no sync
- *		LL_DV_RD_FLUSH: flush dirty pages, LCK_PR on OSTs
- *		LL_DV_WR_FLUSH: drop all caching pages, LCK_PW on OSTs
- */
-int ll_data_version(struct inode *inode, u64 *data_version, int flags)
+static int
+ll_ioc_data_version(struct inode *inode, struct ioc_data_version *ioc)
 {
 	struct cl_object *obj = ll_i2info(inode)->lli_clob;
 	struct lu_env *env;
@@ -1870,11 +1860,12 @@ int ll_data_version(struct inode *inode, u64 *data_version, int flags)
 	u16 refcheck;
 	int result;
 
+	ioc->idv_version = 0;
+	ioc->idv_layout_version = UINT_MAX;
+
 	/* If no file object initialized, we consider its version is 0. */
-	if (!obj) {
-		*data_version = 0;
+	if (!obj)
 		return 0;
-	}
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
@@ -1883,7 +1874,8 @@ int ll_data_version(struct inode *inode, u64 *data_version, int flags)
 	io = vvp_env_thread_io(env);
 	io->ci_obj = obj;
 	io->u.ci_data_version.dv_data_version = 0;
-	io->u.ci_data_version.dv_flags = flags;
+	io->u.ci_data_version.dv_layout_version = UINT_MAX;
+	io->u.ci_data_version.dv_flags = ioc->idv_flags;
 
 restart:
 	if (!cl_io_init(env, io, CIT_DATA_VERSION, io->ci_obj))
@@ -1891,7 +1883,8 @@ int ll_data_version(struct inode *inode, u64 *data_version, int flags)
 	else
 		result = io->ci_result;
 
-	*data_version = io->u.ci_data_version.dv_data_version;
+	ioc->idv_version = io->u.ci_data_version.dv_data_version;
+	ioc->idv_layout_version = io->u.ci_data_version.dv_layout_version;
 
 	cl_io_fini(env, io);
 
@@ -1904,6 +1897,29 @@ int ll_data_version(struct inode *inode, u64 *data_version, int flags)
 }
 
 /*
+ * Read the data_version for inode.
+ *
+ * This value is computed using stripe object version on OST.
+ * Version is computed using server side locking.
+ *
+ * @param flags if do sync on the OST side;
+ *		0: no sync
+ *		LL_DV_RD_FLUSH: flush dirty pages, LCK_PR on OSTs
+ *		LL_DV_WR_FLUSH: drop all caching pages, LCK_PW on OSTs
+ */
+int ll_data_version(struct inode *inode, u64 *data_version, int flags)
+{
+	struct ioc_data_version ioc = { .idv_flags = flags };
+	int rc;
+
+	rc = ll_ioc_data_version(inode, &ioc);
+	if (!rc)
+		*data_version = ioc.idv_version;
+
+	return rc;
+}
+
+/*
  * Trigger a HSM release request for the provided inode.
  */
 int ll_hsm_release(struct inode *inode)
@@ -2677,7 +2693,7 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 			return -EFAULT;
 
 		idv.idv_flags &= LL_DV_RD_FLUSH | LL_DV_WR_FLUSH;
-		rc = ll_data_version(inode, &idv.idv_version, idv.idv_flags);
+		rc = ll_ioc_data_version(inode, &idv);
 		if (rc == 0 && copy_to_user((char __user *)arg, &idv,
 					    sizeof(idv)))
 			return -EFAULT;
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 3d3f07f..457fa3c 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -844,13 +844,17 @@ static void lov_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct cl_io *parent = lio->lis_cl.cis_io;
+	struct cl_data_version_io *pdv = &parent->u.ci_data_version;
 	struct lov_io_sub *sub;
 
 	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
+		struct cl_data_version_io *sdv = &sub->sub_io.u.ci_data_version;
+
 		lov_io_end_wrapper(sub->sub_env, &sub->sub_io);
 
-		parent->u.ci_data_version.dv_data_version +=
-			sub->sub_io.u.ci_data_version.dv_data_version;
+		pdv->dv_data_version += sdv->dv_data_version;
+		if (pdv->dv_layout_version > sdv->dv_layout_version)
+			pdv->dv_layout_version = sdv->dv_layout_version;
 
 		if (!parent->ci_result)
 			parent->ci_result = sub->sub_io.ci_result;
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 8bdfadb..d75f725 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -714,11 +714,16 @@ static void osc_io_data_version_end(const struct lu_env *env,
 
 	if (cbargs->opc_rc) {
 		slice->cis_io->ci_result = cbargs->opc_rc;
-	} else if (!(oio->oi_oa.o_valid & OBD_MD_FLDATAVERSION)) {
-		slice->cis_io->ci_result = -EOPNOTSUPP;
 	} else {
-		dv->dv_data_version = oio->oi_oa.o_data_version;
 		slice->cis_io->ci_result = 0;
+		if (!(oio->oi_oa.o_valid &
+		      (OBD_MD_LAYOUT_VERSION | OBD_MD_FLDATAVERSION)))
+			slice->cis_io->ci_result = -ENOTSUPP;
+
+		if (oio->oi_oa.o_valid & OBD_MD_LAYOUT_VERSION)
+			dv->dv_layout_version = oio->oi_oa.o_layout_version;
+		if (oio->oi_oa.o_valid & OBD_MD_FLDATAVERSION)
+			dv->dv_data_version = oio->oi_oa.o_data_version;
 	}
 }
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 3b64f734..fe60e67 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1132,12 +1132,15 @@ enum changelog_message_type {
 /********* Misc **********/
 
 struct ioc_data_version {
-	__u64 idv_version;
-	__u64 idv_flags;	/* See LL_DV_xxx */
+	__u64	idv_version;
+	__u32	idv_layout_version; /* FLR: layout version for OST objects */
+	__u32	idv_flags;	    /* enum ioc_data_version_flags */
 };
 
-#define LL_DV_RD_FLUSH	(1 << 0) /* Flush dirty pages from clients */
-#define LL_DV_WR_FLUSH	(1 << 1) /* Flush all caching pages from clients */
+enum ioc_data_version_flags {
+	LL_DV_RD_FLUSH	= (1 << 0), /* Flush dirty pages from clients */
+	LL_DV_WR_FLUSH	= (1 << 1), /* Flush all caching pages from clients */
+};
 
 #ifndef offsetof
 # define offsetof(typ, memb)	((unsigned long)((char *)&(((typ *)0)->memb)))
-- 
1.8.3.1
