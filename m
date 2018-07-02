From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:20 -0400
Subject: [lustre-devel] [PATCH 03/18] lustre: fileset: add fileset mount
 support
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lsiyao@whamcloud.com>

This patch enables client to mount subdirectory as fileset.

usage: mount -t lustre mgsname:/fsname/subdir /mount/point

 * mdt lookup fileset fid and return to client during mount.
 * `fid2path` support for fileset.

Signed-off-by: Lai Siyao <lsiyao@whamcloud.com>
Signed-off-by: Kit Westneat <kwestneat@ddn.com>
Signed-off-by: Wang Shilong <wshilong@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-28
Reviewed-on: http://review.whamcloud.com/5007
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  7 ++-
 .../staging/lustre/lustre/include/lustre_disk.h    |  2 +
 .../lustre/lustre/include/lustre_req_layout.h      |  2 +-
 drivers/staging/lustre/lustre/include/obd.h        |  3 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  5 ++-
 .../staging/lustre/lustre/include/obd_support.h    |  4 +-
 drivers/staging/lustre/lustre/llite/file.c         | 18 ++++++++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  6 ++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 30 +++++++------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 50 ++++++++++++++++++----
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 23 +++++++++-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 14 ++++--
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 12 +++---
 14 files changed, 135 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 5fab107..6defc6d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -1244,7 +1244,7 @@ enum mds_cmd {
 	MDS_READPAGE		= 37,
 	MDS_CONNECT		= 38,
 	MDS_DISCONNECT		= 39,
-	MDS_GETSTATUS		= 40,
+	MDS_GET_ROOT		= 40,
 	MDS_STATFS		= 41,
 	MDS_PIN			= 42, /* obsolete, never used in a release */
 	MDS_UNPIN		= 43, /* obsolete, never used in a release */
@@ -2626,7 +2626,10 @@ struct getinfo_fid2path {
 	__u64	   gf_recno;
 	__u32	   gf_linkno;
 	__u32	   gf_pathlen;
-	char	    gf_path[0];
+	union {
+		char		gf_path[0];
+		struct lu_fid	gf_root_fid[0];
+	} gf_u;
 } __packed;
 
 /** path2parent request/reply structures */
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 886e817..bd8fa71 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -78,6 +78,7 @@ struct lustre_mount_data {
 	int	lmd_recovery_time_hard;
 	char      *lmd_dev;	   /* device name */
 	char      *lmd_profile;    /* client only */
+	char	*lmd_fileset;	/* mount fileset */
 	char      *lmd_mgssec;	/* sptlrpc flavor to mgs */
 	char      *lmd_opts;	/* lustre mount options (as opposed to
 				 * _device_ mount options)
@@ -134,6 +135,7 @@ struct lustre_sb_info {
 #define     s2lsi_nocast(sb) ((sb)->s_fs_info)
 
 #define     get_profile_name(sb)   (s2lsi(sb)->lsi_lmd->lmd_profile)
+#define     get_mount_fileset(sb)  (s2lsi(sb)->lsi_lmd->lmd_fileset)
 
 /****************** prototypes *********************/
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index db6d8ed..9d718b7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -133,7 +133,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_MDS_CONNECT;
 extern struct req_format RQF_MDS_DISCONNECT;
 extern struct req_format RQF_MDS_STATFS;
-extern struct req_format RQF_MDS_GETSTATUS;
+extern struct req_format RQF_MDS_GET_ROOT;
 extern struct req_format RQF_MDS_SYNC;
 extern struct req_format RQF_MDS_GETXATTR;
 extern struct req_format RQF_MDS_GETATTR;
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index d6fd1ea..cd2a2d0 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -920,7 +920,8 @@ struct obd_client_handle {
 struct cl_attr;
 
 struct md_ops {
-	int (*getstatus)(struct obd_export *, struct lu_fid *);
+	int (*getstatus)(struct obd_export *exp, const char *fileset,
+			 struct lu_fid *fid);
 	int (*null_inode)(struct obd_export *, const struct lu_fid *);
 	int (*close)(struct obd_export *, struct md_op_data *,
 		     struct md_open_data *, struct ptlrpc_request **);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index fc9c772..797986b 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1180,13 +1180,14 @@ static inline int obd_register_observer(struct obd_device *obd,
 }
 
 /* metadata helpers */
-static inline int md_getstatus(struct obd_export *exp, struct lu_fid *fid)
+static inline int md_get_root(struct obd_export *exp, const char *fileset,
+			      struct lu_fid *fid)
 {
 	int rc;
 
 	EXP_CHECK_MD_OP(exp, getstatus);
 	EXP_MD_COUNTER_INCREMENT(exp, getstatus);
-	rc = MDP(exp->exp_obd, getstatus)(exp, fid);
+	rc = MDP(exp->exp_obd, getstatus)(exp, fileset, fid);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index ca28caf..87806e8 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -135,8 +135,8 @@
 #define OBD_FAIL_MDS_CONNECT_PACK	0x118
 #define OBD_FAIL_MDS_REINT_NET_REP       0x119
 #define OBD_FAIL_MDS_DISCONNECT_NET      0x11a
-#define OBD_FAIL_MDS_GETSTATUS_NET       0x11b
-#define OBD_FAIL_MDS_GETSTATUS_PACK      0x11c
+#define OBD_FAIL_MDS_GET_ROOT_NET	0x11b
+#define OBD_FAIL_MDS_GET_ROOT_PACK	0x11c
 #define OBD_FAIL_MDS_STATFS_PACK	 0x11d
 #define OBD_FAIL_MDS_STATFS_NET	  0x11e
 #define OBD_FAIL_MDS_GETATTR_NAME_NET    0x11f
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 44bec1d..5f944ca 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1594,6 +1594,13 @@ int ll_fid2path(struct inode *inode, void __user *arg)
 		goto gf_free;
 	}
 
+	/*
+	 * append root FID after gfout to let MDT know the root FID so that it
+	 * can lookup the correct path, this is mainly for fileset.
+	 * old server without fileset mount support will ignore this.
+	 */
+	*gfout->gf_u.gf_root_fid = *ll_inode2fid(inode);
+
 	/* Call mdc_iocontrol */
 	rc = obd_iocontrol(OBD_IOC_FID2PATH, exp, outsize, gfout, NULL);
 	if (rc != 0)
@@ -2725,6 +2732,16 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		goto out_free;
 	}
 
+	/*
+	 * lfs migrate command needs to be blocked on the client
+	 * by checking the migrate FID against the FID of the
+	 * filesystem root.
+	 */
+	if (child_inode == parent->i_sb->s_root->d_inode) {
+		rc = -EINVAL;
+		goto out_iput;
+	}
+
 	inode_lock(child_inode);
 	op_data->op_fid3 = *ll_inode2fid(child_inode);
 	if (!fid_is_sane(&op_data->op_fid3)) {
@@ -2807,6 +2824,7 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		clear_nlink(child_inode);
 out_unlock:
 	inode_unlock(child_inode);
+out_iput:
 	iput(child_inode);
 out_free:
 	ll_finish_md_op_data(op_data);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index df5bc0a..90dff0a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -201,7 +201,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_DISP_STRIPE | OBD_CONNECT_LFSCK |
 				  OBD_CONNECT_OPEN_BY_FID |
 				  OBD_CONNECT_DIR_STRIPE |
-				  OBD_CONNECT_BULK_MBITS;
+				  OBD_CONNECT_BULK_MBITS |
+				  OBD_CONNECT_SUBTREE;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
@@ -436,7 +437,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	mutex_unlock(&sbi->ll_lco.lco_lock);
 
 	fid_zero(&sbi->ll_root_fid);
-	err = md_getstatus(sbi->ll_md_exp, &sbi->ll_root_fid);
+	err = md_get_root(sbi->ll_md_exp, get_mount_fileset(sb),
+			  &sbi->ll_root_fid);
 	if (err) {
 		CERROR("cannot mds_connect: rc = %d\n", err);
 		goto out_lock_cn_cb;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index d4e8ba8..44fbaa6 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -613,17 +613,20 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 {
 	struct obd_device	*obddev = class_exp2obd(exp);
 	struct lmv_obd		*lmv = &obddev->u.lmv;
-	struct getinfo_fid2path *gf;
+	struct getinfo_fid2path *gf = karg;
 	struct lmv_tgt_desc     *tgt;
 	struct getinfo_fid2path *remote_gf = NULL;
+	struct lu_fid root_fid;
 	int			remote_gf_size = 0;
 	int			rc;
 
-	gf = karg;
 	tgt = lmv_find_target(lmv, &gf->gf_fid);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
+	root_fid = *gf->gf_u.gf_root_fid;
+	LASSERT(fid_is_sane(&root_fid));
+
 repeat_fid2path:
 	rc = obd_iocontrol(OBD_IOC_FID2PATH, tgt->ltd_exp, len, gf, uarg);
 	if (rc != 0 && rc != -EREMOTE)
@@ -637,25 +640,25 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 		char *ptr;
 
 		ori_gf = karg;
-		if (strlen(ori_gf->gf_path) + 1 +
-		    strlen(gf->gf_path) + 1 > ori_gf->gf_pathlen) {
+		if (strlen(ori_gf->gf_u.gf_path) + 1 +
+		    strlen(gf->gf_u.gf_path) + 1 > ori_gf->gf_pathlen) {
 			rc = -EOVERFLOW;
 			goto out_fid2path;
 		}
 
-		ptr = ori_gf->gf_path;
+		ptr = ori_gf->gf_u.gf_path;
 
-		memmove(ptr + strlen(gf->gf_path) + 1, ptr,
-			strlen(ori_gf->gf_path));
+		memmove(ptr + strlen(gf->gf_u.gf_path) + 1, ptr,
+			strlen(ori_gf->gf_u.gf_path));
 
-		strncpy(ptr, gf->gf_path, strlen(gf->gf_path));
-		ptr += strlen(gf->gf_path);
+		strncpy(ptr, gf->gf_u.gf_path, strlen(gf->gf_u.gf_path));
+		ptr += strlen(gf->gf_u.gf_path);
 		*ptr = '/';
 	}
 
 	CDEBUG(D_INFO, "%s: get path %s " DFID " rec: %llu ln: %u\n",
 	       tgt->ltd_exp->exp_obd->obd_name,
-	       gf->gf_path, PFID(&gf->gf_fid), gf->gf_recno,
+	       gf->gf_u.gf_path, PFID(&gf->gf_fid), gf->gf_recno,
 	       gf->gf_linkno);
 
 	if (rc == 0)
@@ -689,7 +692,8 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 	remote_gf->gf_fid = gf->gf_fid;
 	remote_gf->gf_recno = -1;
 	remote_gf->gf_linkno = -1;
-	memset(remote_gf->gf_path, 0, remote_gf->gf_pathlen);
+	memset(remote_gf->gf_u.gf_path, 0, remote_gf->gf_pathlen);
+	*remote_gf->gf_u.gf_root_fid = root_fid;
 	gf = remote_gf;
 	goto repeat_fid2path;
 
@@ -1387,13 +1391,13 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 	return rc;
 }
 
-static int lmv_getstatus(struct obd_export *exp,
+static int lmv_getstatus(struct obd_export *exp, const char *fileset,
 			 struct lu_fid *fid)
 {
 	struct obd_device    *obd = exp->exp_obd;
 	struct lmv_obd       *lmv = &obd->u.lmv;
 
-	return md_getstatus(lmv->tgts[0]->ltd_exp, fid);
+	return md_get_root(lmv->tgts[0]->ltd_exp, fileset, fid);
 }
 
 static int lmv_getxattr(struct obd_export *exp, const struct lu_fid *fid,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 827ed0c..2e01f57 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -81,19 +81,50 @@ static inline int mdc_queue_wait(struct ptlrpc_request *req)
 	return rc;
 }
 
-static int mdc_getstatus(struct obd_export *exp, struct lu_fid *rootfid)
+/*
+ * Send MDS_GET_ROOT RPC to fetch root FID.
+ *
+ * If \a fileset is not NULL it should contain a subdirectory off
+ * the ROOT/ directory to be mounted on the client. Return the FID
+ * of the subdirectory to the client to mount onto its mountpoint.
+ *
+ * \param[in]  imp	MDC import
+ * \param[in]  fileset	fileset name, which could be NULL
+ * \param[out] rootfid	root FID of this mountpoint
+ * \param[out] pc	root capa will be unpacked and saved in this pointer
+ *
+ * \retval     0 on success, negative errno on failure
+ */
+static int mdc_get_root(struct obd_export *exp, const char *fileset,
+			struct lu_fid *rootfid)
 {
 	struct ptlrpc_request *req;
 	struct mdt_body       *body;
 	int		    rc;
 
-	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
-					&RQF_MDS_GETSTATUS,
-					LUSTRE_MDS_VERSION, MDS_GETSTATUS);
+	if (fileset && !(exp_connect_flags(exp) & OBD_CONNECT_SUBTREE))
+		return -ENOTSUPP;
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
+				   &RQF_MDS_GET_ROOT);
 	if (!req)
 		return -ENOMEM;
 
+	if (fileset)
+		req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
+				     strlen(fileset) + 1);
+	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_GET_ROOT);
+	if (rc) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
 	mdc_pack_body(req, NULL, 0, 0, -1, 0);
+	if (fileset) {
+		char *name = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
+
+		memcpy(name, fileset, strlen(fileset));
+	}
+	lustre_msg_add_flags(req->rq_reqmsg, LUSTRE_IMP_FULL);
 	req->rq_send_state = LUSTRE_IMP_FULL;
 
 	ptlrpc_request_set_replen(req);
@@ -1440,13 +1471,16 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 		return -EOVERFLOW;
 
 	/* Key is KEY_FID2PATH + getinfo_fid2path description */
-	keylen = cfs_size_round(sizeof(KEY_FID2PATH)) + sizeof(*gf);
+	keylen = cfs_size_round(sizeof(KEY_FID2PATH)) + sizeof(*gf) +
+		 sizeof(struct lu_fid);
 	key = kzalloc(keylen, GFP_NOFS);
 	if (!key)
 		return -ENOMEM;
 	memcpy(key, KEY_FID2PATH, sizeof(KEY_FID2PATH));
 	memcpy(key + cfs_size_round(sizeof(KEY_FID2PATH)), gf, sizeof(*gf));
 
+	memcpy(key + cfs_size_round(sizeof(KEY_FID2PATH)) + sizeof(*gf),
+	       gf->gf_u.gf_root_fid, sizeof(struct lu_fid));
 	CDEBUG(D_IOCTL, "path get " DFID " from %llu #%d\n",
 	       PFID(&gf->gf_fid), gf->gf_recno, gf->gf_linkno);
 
@@ -1472,9 +1506,9 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 
 	CDEBUG(D_IOCTL, "path got " DFID " from %llu #%d: %s\n",
 	       PFID(&gf->gf_fid), gf->gf_recno, gf->gf_linkno,
-	       gf->gf_pathlen < 512 ? gf->gf_path :
+	       gf->gf_pathlen < 512 ? gf->gf_u.gf_path :
 	       /* only log the last 512 characters of the path */
-	       gf->gf_path + gf->gf_pathlen - 512);
+	       gf->gf_u.gf_path + gf->gf_pathlen - 512);
 
 out:
 	kfree(key);
@@ -2713,7 +2747,7 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 };
 
 static struct md_ops mdc_md_ops = {
-	.getstatus		= mdc_getstatus,
+	.getstatus		= mdc_get_root,
 	.null_inode		= mdc_null_inode,
 	.close			= mdc_close,
 	.create			= mdc_create,
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 232bbfa..6e9803b 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -545,6 +545,7 @@ static int lustre_free_lsi(struct super_block *sb)
 	if (lsi->lsi_lmd) {
 		kfree(lsi->lsi_lmd->lmd_dev);
 		kfree(lsi->lsi_lmd->lmd_profile);
+		kfree(lsi->lsi_lmd->lmd_fileset);
 		kfree(lsi->lsi_lmd->lmd_mgssec);
 		kfree(lsi->lsi_lmd->lmd_opts);
 		if (lsi->lsi_lmd->lmd_exclude_count)
@@ -1073,10 +1074,30 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 		/* Remove leading /s from fsname */
 		while (*++s1 == '/')
 			;
+		s2 = s1;
+		while (*s2 != '/' && *s2 != '\0')
+			s2++;
 		/* Freed in lustre_free_lsi */
-		lmd->lmd_profile = kasprintf(GFP_NOFS, "%s-client", s1);
+		lmd->lmd_profile = kzalloc(s2 - s1 + 8, GFP_NOFS);
 		if (!lmd->lmd_profile)
 			return -ENOMEM;
+
+		strncat(lmd->lmd_profile, s1, s2 - s1);
+		strncat(lmd->lmd_profile, "-client", 7);
+
+		s1 = s2;
+		s2 = s1 + strlen(s1) - 1;
+		/* Remove padding /s from fileset */
+		while (*s2 == '/')
+			s2--;
+		if (s2 > s1) {
+			lmd->lmd_fileset = kzalloc(s2 - s1 + 2, GFP_NOFS);
+			if (!lmd->lmd_fileset) {
+				kfree(lmd->lmd_profile);
+				return -ENOMEM;
+			}
+			strncat(lmd->lmd_fileset, s1, s2 - s1 + 1);
+		}
 	}
 
 	/* Freed in lustre_free_lsi */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 6ef8789..0b3ac14 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -477,6 +477,12 @@
 	&RMF_EAVALS_LENS
 };
 
+static const struct req_msg_field *mds_get_root_client[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_MDT_BODY,
+	&RMF_NAME
+};
+
 static const struct req_msg_field *mds_getxattr_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_MDT_BODY,
@@ -674,7 +680,7 @@
 	&RQF_MDS_CONNECT,
 	&RQF_MDS_DISCONNECT,
 	&RQF_MDS_GET_INFO,
-	&RQF_MDS_GETSTATUS,
+	&RQF_MDS_GET_ROOT,
 	&RQF_MDS_STATFS,
 	&RQF_MDS_GETATTR,
 	&RQF_MDS_GETATTR_NAME,
@@ -1228,9 +1234,9 @@ struct req_format RQF_OST_QUOTACTL =
 	DEFINE_REQ_FMT0("OST_QUOTACTL", quotactl_only, quotactl_only);
 EXPORT_SYMBOL(RQF_OST_QUOTACTL);
 
-struct req_format RQF_MDS_GETSTATUS =
-	DEFINE_REQ_FMT0("MDS_GETSTATUS", mdt_body_only, mdt_body_capa);
-EXPORT_SYMBOL(RQF_MDS_GETSTATUS);
+struct req_format RQF_MDS_GET_ROOT =
+	DEFINE_REQ_FMT0("MDS_GET_ROOT", mds_get_root_client, mdt_body_capa);
+EXPORT_SYMBOL(RQF_MDS_GET_ROOT);
 
 struct req_format RQF_MDS_STATFS =
 	DEFINE_REQ_FMT0("MDS_STATFS", empty, obd_statfs_server);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 52b980c..35120e7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -74,7 +74,7 @@
 	{ MDS_READPAGE,     "mds_readpage" },
 	{ MDS_CONNECT,      "mds_connect" },
 	{ MDS_DISCONNECT,   "mds_disconnect" },
-	{ MDS_GETSTATUS,    "mds_getstatus" },
+	{ MDS_GET_ROOT,			"mds_get_root" },
 	{ MDS_STATFS,       "mds_statfs" },
 	{ MDS_PIN,	  "mds_pin" },
 	{ MDS_UNPIN,	"mds_unpin" },
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 5a68de5..43931dd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -131,8 +131,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_CONNECT);
 	LASSERTF(MDS_DISCONNECT == 39, "found %lld\n",
 		 (long long)MDS_DISCONNECT);
-	LASSERTF(MDS_GETSTATUS == 40, "found %lld\n",
-		 (long long)MDS_GETSTATUS);
+	LASSERTF(MDS_GET_ROOT == 40, "found %lld\n",
+		 (long long)MDS_GET_ROOT);
 	LASSERTF(MDS_STATFS == 41, "found %lld\n",
 		 (long long)MDS_STATFS);
 	LASSERTF(MDS_PIN == 42, "found %lld\n",
@@ -3708,10 +3708,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct getinfo_fid2path, gf_pathlen));
 	LASSERTF((int)sizeof(((struct getinfo_fid2path *)0)->gf_pathlen) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct getinfo_fid2path *)0)->gf_pathlen));
-	LASSERTF((int)offsetof(struct getinfo_fid2path, gf_path[0]) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct getinfo_fid2path, gf_path[0]));
-	LASSERTF((int)sizeof(((struct getinfo_fid2path *)0)->gf_path[0]) == 1, "found %lld\n",
-		 (long long)(int)sizeof(((struct getinfo_fid2path *)0)->gf_path[0]));
+	LASSERTF((int)offsetof(struct getinfo_fid2path, gf_u.gf_path[0]) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct getinfo_fid2path, gf_u.gf_path[0]));
+	LASSERTF((int)sizeof(((struct getinfo_fid2path *)0)->gf_u.gf_path[0]) == 1, "found %lld\n",
+		 (long long)(int)sizeof(((struct getinfo_fid2path *)0)->gf_u.gf_path[0]));
 
 	/* Checks for struct fiemap */
 	LASSERTF((int)sizeof(struct fiemap) == 32, "found %lld\n",
-- 
1.8.3.1
