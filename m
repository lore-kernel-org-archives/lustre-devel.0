From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:35 -0400
Subject: [lustre-devel] [PATCH 22/80] staging: lustre: llite: a few fixes
	for migration.
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

1. Clear the client dentry cache before migrating file/directory
   to the remote MDT.

2. Do not return stripe information to client, if it did not get
   the layout lock.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4682
Reviewed-on: http://review.whamcloud.com/9522
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          |   22 +++---------
 drivers/staging/lustre/lustre/llite/file.c         |   34 +++++++++++---------
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +
 drivers/staging/lustre/lustre/lov/lov_object.c     |    1 +
 4 files changed, 28 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index ef7322e..84bec03 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1318,11 +1318,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return 0;
 	}
 	case IOC_MDC_LOOKUP: {
-		struct ptlrpc_request *request = NULL;
 		int namelen, len = 0;
 		char *buf = NULL;
 		char *filename;
-		struct md_op_data *op_data;
 
 		rc = obd_ioctl_getdata(&buf, &len, (void __user *)arg);
 		if (rc)
@@ -1338,21 +1336,13 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto out_free;
 		}
 
-		op_data = ll_prep_md_op_data(NULL, inode, NULL, filename, namelen,
-					     0, LUSTRE_OPC_ANY, NULL);
-		if (IS_ERR(op_data)) {
-			rc = PTR_ERR(op_data);
-			goto out_free;
-		}
-
-		op_data->op_valid = OBD_MD_FLID;
-		rc = md_getattr_name(sbi->ll_md_exp, op_data, &request);
-		ll_finish_md_op_data(op_data);
+		rc = ll_get_fid_by_name(inode, filename, namelen, NULL);
 		if (rc < 0) {
-			CDEBUG(D_INFO, "md_getattr_name: %d\n", rc);
+			CERROR("%s: lookup %.*s failed: rc = %d\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0), namelen,
+			       filename, rc);
 			goto out_free;
 		}
-		ptlrpc_req_finished(request);
 out_free:
 		obd_ioctl_freedata(buf, len);
 		return rc;
@@ -1981,7 +1971,7 @@ out_quotactl:
 
 		filename = data->ioc_inlbuf1;
 		namelen = data->ioc_inllen1;
-		if (namelen < 1) {
+		if (namelen < 1 || namelen != strlen(filename) + 1) {
 			rc = -EINVAL;
 			goto migrate_free;
 		}
@@ -1992,7 +1982,7 @@ out_quotactl:
 		}
 		mdtidx = *(int *)data->ioc_inlbuf2;
 
-		rc = ll_migrate(inode, file, mdtidx, filename, namelen);
+		rc = ll_migrate(inode, file, mdtidx, filename, namelen - 1);
 migrate_free:
 		obd_ioctl_freedata(buf, len);
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 8d98db6..769b028 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2828,8 +2828,8 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	return rc;
 }
 
-static int ll_get_fid_by_name(struct inode *parent, const char *name,
-			      int namelen, struct lu_fid *fid)
+int ll_get_fid_by_name(struct inode *parent, const char *name,
+		       int namelen, struct lu_fid *fid)
 {
 	struct md_op_data *op_data = NULL;
 	struct ptlrpc_request *req;
@@ -2843,20 +2843,19 @@ static int ll_get_fid_by_name(struct inode *parent, const char *name,
 
 	op_data->op_valid = OBD_MD_FLID;
 	rc = md_getattr_name(ll_i2sbi(parent)->ll_md_exp, op_data, &req);
+	ll_finish_md_op_data(op_data);
 	if (rc < 0)
-		goto out_free;
+		return rc;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 	if (!body) {
 		rc = -EFAULT;
 		goto out_req;
 	}
-	*fid = body->fid1;
+	if (fid)
+		*fid = body->fid1;
 out_req:
 	ptlrpc_req_finished(req);
-out_free:
-	if (op_data)
-		ll_finish_md_op_data(op_data);
 	return rc;
 }
 
@@ -2864,12 +2863,13 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	       const char *name, int namelen)
 {
 	struct ptlrpc_request *request = NULL;
+	struct inode *child_inode = NULL;
 	struct dentry *dchild = NULL;
 	struct md_op_data *op_data;
 	struct qstr qstr;
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "migrate %s under"DFID" to MDT%d\n",
+	CDEBUG(D_VFSTRACE, "migrate %s under "DFID" to MDT%d\n",
 	       name, PFID(ll_inode2fid(parent)), mdtidx);
 
 	op_data = ll_prep_md_op_data(NULL, parent, NULL, name, namelen,
@@ -2884,8 +2884,13 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	dchild = d_lookup(file_dentry(file), &qstr);
 	if (dchild && dchild->d_inode) {
 		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
+		if (dchild->d_inode) {
+			child_inode = igrab(dchild->d_inode);
+			ll_invalidate_aliases(child_inode);
+		}
+		dput(dchild);
 	} else {
-		rc = ll_get_fid_by_name(parent, name, strnlen(name, namelen),
+		rc = ll_get_fid_by_name(parent, name, namelen,
 					&op_data->op_fid3);
 		if (rc)
 			goto out_free;
@@ -2895,6 +2900,7 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		CERROR("%s: migrate %s, but fid "DFID" is insane\n",
 		       ll_get_fsname(parent->i_sb, NULL, 0), name,
 		       PFID(&op_data->op_fid3));
+		rc = -EINVAL;
 		goto out_free;
 	}
 
@@ -2912,18 +2918,16 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	op_data->op_mds = mdtidx;
 	op_data->op_cli_flags = CLI_MIGRATE;
 	rc = md_rename(ll_i2sbi(parent)->ll_md_exp, op_data, name,
-		       strnlen(name, namelen), name, strnlen(name, namelen),
-		       &request);
+		       namelen, name, namelen, &request);
 	if (!rc)
 		ll_update_times(request, parent);
 
 	ptlrpc_req_finished(request);
 
 out_free:
-	if (dchild) {
-		if (dchild->d_inode)
-			ll_delete_inode(dchild->d_inode);
-		dput(dchild);
+	if (child_inode) {
+		clear_nlink(child_inode);
+		iput(child_inode);
 	}
 
 	ll_finish_md_op_data(op_data);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 69492f0..120aca3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -721,6 +721,8 @@ int ll_getattr(struct vfsmount *mnt, struct dentry *de, struct kstat *stat);
 struct posix_acl *ll_get_acl(struct inode *inode, int type);
 int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	       const char *name, int namelen);
+int ll_get_fid_by_name(struct inode *parent, const char *name,
+		       int namelen, struct lu_fid *fid);
 int ll_inode_permission(struct inode *inode, int mask);
 
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index f9621b0..2a52d0c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -224,6 +224,7 @@ static int lov_init_raid0(const struct lu_env *env,
 
 	LASSERT(!lov->lo_lsm);
 	lov->lo_lsm = lsm_addref(lsm);
+	lov->lo_layout_invalid = true;
 	r0->lo_nr  = lsm->lsm_stripe_count;
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
-- 
1.7.1
