From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:10 -0500
Subject: [lustre-devel] [PATCH 03/22] staging: lustre: mdt: race between
	open and migrate
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

During intent open, it was found that if the parent has
been migrated to another MDT, it should retry the open
request with the new object, so it needs to keep the
old object in the orphan list, which will be cleanup
during next recovery. Note: if the client still using
the old FID after next recovery, it will return -ENOENT
for the application. Also enqueue the lease lock of
the migrating file, then compare the lease before
migration to make sure no other clients open the file
at the same time.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6475
Reviewed-on: http://review.whamcloud.com/14497
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre_req_layout.h      |    1 +
 drivers/staging/lustre/lustre/llite/dir.c          |    2 +-
 drivers/staging/lustre/lustre/llite/file.c         |   76 ++++++++++++++++---
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   59 +++++++++-------
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   20 +++++-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   18 +++++
 7 files changed, 138 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index 7657132..fbcd395 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -167,6 +167,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_MDS_REINT_SETXATTR;
 extern struct req_format RQF_MDS_QUOTACTL;
 extern struct req_format RQF_MDS_SWAP_LAYOUTS;
+extern struct req_format RQF_MDS_REINT_MIGRATE;
 /* MDS hsm formats */
 extern struct req_format RQF_MDS_HSM_STATE_GET;
 extern struct req_format RQF_MDS_HSM_STATE_SET;
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index ce05493..351e900 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1083,7 +1083,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto out_free;
 		}
 
-		rc = ll_get_fid_by_name(inode, filename, namelen, NULL);
+		rc = ll_get_fid_by_name(inode, filename, namelen, NULL, NULL);
 		if (rc < 0) {
 			CERROR("%s: lookup %.*s failed: rc = %d\n",
 			       ll_get_fsname(inode->i_sb, NULL, 0), namelen,
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index ea21e19..aa29583 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2531,7 +2531,8 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 }
 
 int ll_get_fid_by_name(struct inode *parent, const char *name,
-		       int namelen, struct lu_fid *fid)
+		       int namelen, struct lu_fid *fid,
+		       struct inode **inode)
 {
 	struct md_op_data *op_data = NULL;
 	struct ptlrpc_request *req;
@@ -2543,7 +2544,7 @@ int ll_get_fid_by_name(struct inode *parent, const char *name,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	op_data->op_valid = OBD_MD_FLID;
+	op_data->op_valid = OBD_MD_FLID | OBD_MD_FLTYPE;
 	rc = md_getattr_name(ll_i2sbi(parent)->ll_md_exp, op_data, &req);
 	ll_finish_md_op_data(op_data);
 	if (rc < 0)
@@ -2556,6 +2557,9 @@ int ll_get_fid_by_name(struct inode *parent, const char *name,
 	}
 	if (fid)
 		*fid = body->mbo_fid1;
+
+	if (inode)
+		rc = ll_prep_inode(inode, req, parent->i_sb, NULL);
 out_req:
 	ptlrpc_req_finished(req);
 	return rc;
@@ -2565,9 +2569,12 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	       const char *name, int namelen)
 {
 	struct ptlrpc_request *request = NULL;
+	struct obd_client_handle *och = NULL;
 	struct inode *child_inode = NULL;
 	struct dentry *dchild = NULL;
 	struct md_op_data *op_data;
+	struct mdt_body *body;
+	u64 data_version = 0;
 	struct qstr qstr;
 	int rc;
 
@@ -2586,22 +2593,25 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	dchild = d_lookup(file_dentry(file), &qstr);
 	if (dchild) {
 		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
-		if (dchild->d_inode) {
+		if (dchild->d_inode)
 			child_inode = igrab(dchild->d_inode);
-			if (child_inode) {
-				inode_lock(child_inode);
-				op_data->op_fid3 = *ll_inode2fid(child_inode);
-				ll_invalidate_aliases(child_inode);
-			}
-		}
 		dput(dchild);
-	} else {
+	}
+
+	if (!child_inode) {
 		rc = ll_get_fid_by_name(parent, name, namelen,
-					&op_data->op_fid3);
+					&op_data->op_fid3, &child_inode);
 		if (rc)
 			goto out_free;
 	}
 
+	if (!child_inode) {
+		rc = -EINVAL;
+		goto out_free;
+	}
+
+	inode_lock(child_inode);
+	op_data->op_fid3 = *ll_inode2fid(child_inode);
 	if (!fid_is_sane(&op_data->op_fid3)) {
 		CERROR("%s: migrate %s, but fid "DFID" is insane\n",
 		       ll_get_fsname(parent->i_sb, NULL, 0), name,
@@ -2620,6 +2630,26 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		rc = 0;
 		goto out_free;
 	}
+again:
+	if (S_ISREG(child_inode->i_mode)) {
+		och = ll_lease_open(child_inode, NULL, FMODE_WRITE, 0);
+		if (IS_ERR(och)) {
+			rc = PTR_ERR(och);
+			och = NULL;
+			goto out_free;
+		}
+
+		rc = ll_data_version(child_inode, &data_version,
+				     LL_DV_WR_FLUSH);
+		if (rc)
+			goto out_free;
+
+		op_data->op_handle = och->och_fh;
+		op_data->op_data = och->och_mod;
+		op_data->op_data_version = data_version;
+		op_data->op_lease_handle = och->och_lease_handle;
+		op_data->op_bias |= MDS_RENAME_MIGRATE;
+	}
 
 	op_data->op_mds = mdtidx;
 	op_data->op_cli_flags = CLI_MIGRATE;
@@ -2628,10 +2658,32 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	if (!rc)
 		ll_update_times(request, parent);
 
-	ptlrpc_req_finished(request);
+	body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
+	if (!body) {
+		rc = -EPROTO;
+		goto out_free;
+	}
+
+	/*
+	 * If the server does release layout lock, then we cleanup
+	 * the client och here, otherwise release it in out_free:
+	 */
+	if (och && body->mbo_valid & OBD_MD_CLOSE_INTENT_EXECED) {
+		obd_mod_put(och->och_mod);
+		md_clear_open_replay_data(ll_i2sbi(parent)->ll_md_exp, och);
+		och->och_fh.cookie = DEAD_HANDLE_MAGIC;
+		kfree(och);
+		och = NULL;
+	}
 
+	ptlrpc_req_finished(request);
+	/* Try again if the file layout has changed. */
+	if (rc == -EAGAIN && S_ISREG(child_inode->i_mode))
+		goto again;
 out_free:
 	if (child_inode) {
+		if (och) /* close the file */
+			ll_lease_close(och, child_inode, NULL);
 		clear_nlink(child_inode);
 		inode_unlock(child_inode);
 		iput(child_inode);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index ac4ce05..ae0bb09 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -745,7 +745,7 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
 int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	       const char *name, int namelen);
 int ll_get_fid_by_name(struct inode *parent, const char *name,
-		       int namelen, struct lu_fid *fid);
+		       int namelen, struct lu_fid *fid, struct inode **inode);
 int ll_inode_permission(struct inode *inode, int mask);
 
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index c1990f0..f35e1f9 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -376,6 +376,31 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
 }
 
+static void mdc_intent_close_pack(struct ptlrpc_request *req,
+				  struct md_op_data *op_data)
+{
+	enum mds_op_bias bias = op_data->op_bias;
+	struct close_data *data;
+	struct ldlm_lock *lock;
+
+	if (!(bias & (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |
+		      MDS_RENAME_MIGRATE)))
+		return;
+
+	data = req_capsule_client_get(&req->rq_pill, &RMF_CLOSE_DATA);
+	LASSERT(data);
+
+	lock = ldlm_handle2lock(&op_data->op_lease_handle);
+	if (lock) {
+		data->cd_handle = lock->l_remote_handle;
+		LDLM_LOCK_PUT(lock);
+	}
+	ldlm_cli_cancel(&op_data->op_lease_handle, LCF_LOCAL);
+
+	data->cd_data_version = op_data->op_data_version;
+	data->cd_fid = op_data->op_fid2;
+}
+
 void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const char *old, size_t oldlen,
 		     const char *new, size_t newlen)
@@ -404,6 +429,15 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 	if (new)
 		mdc_pack_name(req, &RMF_SYMTGT, new, newlen);
+
+	if (op_data->op_cli_flags & CLI_MIGRATE &&
+	    op_data->op_bias & MDS_RENAME_MIGRATE) {
+		struct mdt_ioepoch *epoch;
+
+		mdc_intent_close_pack(req, op_data);
+		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
+		mdc_ioepoch_pack(epoch, op_data);
+	}
 }
 
 void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, u32 flags,
@@ -430,31 +464,6 @@ void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, u32 flags,
 			      op_data->op_namelen);
 }
 
-static void mdc_intent_close_pack(struct ptlrpc_request *req,
-				  struct md_op_data *op_data)
-{
-	enum mds_op_bias bias = op_data->op_bias;
-	struct close_data *data;
-	struct ldlm_lock *lock;
-
-	if (!(bias & (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |
-		      MDS_RENAME_MIGRATE)))
-		return;
-
-	data = req_capsule_client_get(&req->rq_pill, &RMF_CLOSE_DATA);
-	LASSERT(data);
-
-	lock = ldlm_handle2lock(&op_data->op_lease_handle);
-	if (lock) {
-		data->cd_handle = lock->l_remote_handle;
-		LDLM_LOCK_PUT(lock);
-	}
-	ldlm_cli_cancel(&op_data->op_lease_handle, LCF_LOCAL);
-
-	data->cd_data_version = op_data->op_data_version;
-	data->cd_fid = op_data->op_fid2;
-}
-
 void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 {
 	struct mdt_ioepoch *epoch;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 5119588..07b1684 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -366,7 +366,8 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 						 MDS_INODELOCK_FULL);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
-				   &RQF_MDS_REINT_RENAME);
+				   op_data->op_cli_flags & CLI_MIGRATE ?
+				   &RQF_MDS_REINT_MIGRATE : &RQF_MDS_REINT_RENAME);
 	if (!req) {
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return -ENOMEM;
@@ -382,6 +383,23 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 	}
 
+	if (op_data->op_cli_flags & CLI_MIGRATE && op_data->op_data) {
+		struct md_open_data *mod = op_data->op_data;
+
+		LASSERTF(mod->mod_open_req &&
+			 mod->mod_open_req->rq_type != LI_POISON,
+			 "POISONED open %p!\n", mod->mod_open_req);
+
+		DEBUG_REQ(D_HA, mod->mod_open_req, "matched open");
+		/*
+		 * We no longer want to preserve this open for replay even
+		 * though the open was committed. b=3632, b=3633
+		 */
+		spin_lock(&mod->mod_open_req->rq_lock);
+		mod->mod_open_req->rq_replay = 0;
+		spin_unlock(&mod->mod_open_req->rq_lock);
+	}
+
 	if (exp_connect_cancelset(exp) && req)
 		ldlm_cli_cancel_list(&cancels, count, req, 0);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 31aa58e..fd976f9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -257,6 +257,18 @@
 	&RMF_DLM_REQ
 };
 
+static const struct req_msg_field *mds_reint_migrate_client[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_REC_REINT,
+	&RMF_CAPA1,
+	&RMF_CAPA2,
+	&RMF_NAME,
+	&RMF_SYMTGT,
+	&RMF_DLM_REQ,
+	&RMF_MDT_EPOCH,
+	&RMF_CLOSE_DATA
+};
+
 static const struct req_msg_field *mds_last_unlink_server[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_MDT_BODY,
@@ -678,6 +690,7 @@
 	&RQF_MDS_REINT_UNLINK,
 	&RQF_MDS_REINT_LINK,
 	&RQF_MDS_REINT_RENAME,
+	&RQF_MDS_REINT_MIGRATE,
 	&RQF_MDS_REINT_SETATTR,
 	&RQF_MDS_REINT_SETXATTR,
 	&RQF_MDS_QUOTACTL,
@@ -1254,6 +1267,11 @@ struct req_format RQF_MDS_REINT_RENAME =
 			mds_last_unlink_server);
 EXPORT_SYMBOL(RQF_MDS_REINT_RENAME);
 
+struct req_format RQF_MDS_REINT_MIGRATE =
+	DEFINE_REQ_FMT0("MDS_REINT_MIGRATE", mds_reint_migrate_client,
+			mds_last_unlink_server);
+EXPORT_SYMBOL(RQF_MDS_REINT_MIGRATE);
+
 struct req_format RQF_MDS_REINT_SETATTR =
 	DEFINE_REQ_FMT0("MDS_REINT_SETATTR",
 			mds_reint_setattr_client, mds_setattr_server);
-- 
1.7.1
