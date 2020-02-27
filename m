From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:50 -0500
Subject: [lustre-devel] [PATCH 122/622] lustre: misc: name open file handles
 as such
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-123-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

In a number of places in the code, rename variables from "*_handle"
or "*_fh" to "*_open_handle" so that it is clear this is referencing
an open file handle rather than something else (e.g. a lock handle).

Also rename the confusingly-named mti_close_handle to mti_open_handle,
since this is referencing an open file handle, even if it is used at
close time to close the file.

   mfd_handle2mfd() -> mfd_open_handle2mfd()
   mdt_file_data.mfd_handle -> mfd_open_handle
   mdt_file_data.mfd_old_handle -> mfd_open_handle_old
   mdt_thread_info.mti_close_handle -> mti_open_handle
   mdt_body.mbo_handle -> mbo_open_handle
   mdt_io_epoch.mio_handle -> mio_open_handle
   md_op_data.op_handle -> op_open_handle
   mdt_rec_create.cr_old_handle -> cr_open_handle_old
   mdt_reint_record.rr_handle -> rr_open_handle
   obd_client_handle.och_fh -> och_open_handle

Change the resync code path to use a "lease_handle" to avoid confusion
with an open handle:

   mdt_rec_resync.rs_handle -> rs_lease_handle
   use md_op_data.op_lease_handle
   add mdt_reint_record.rr_lease_handle

WC-bug-id: https://jira.whamcloud.com/browse/LU-8174
Lustre-commit: ccb133fd2266 ("LU-8174 misc: name open file handles as such")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/26953
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                |  4 ++--
 fs/lustre/llite/file.c                 | 22 +++++++++++-----------
 fs/lustre/llite/llite_lib.c            |  2 +-
 fs/lustre/mdc/mdc_lib.c                |  4 ++--
 fs/lustre/mdc/mdc_reint.c              |  4 ++--
 fs/lustre/mdc/mdc_request.c            | 26 ++++++++++++++------------
 fs/lustre/ptlrpc/pack_generic.c        |  2 +-
 fs/lustre/ptlrpc/wiretest.c            | 24 ++++++++++++------------
 include/uapi/linux/lustre/lustre_idl.h | 12 ++++++------
 9 files changed, 51 insertions(+), 49 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 3910c10..7cf9745 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -737,7 +737,7 @@ struct md_op_data {
 	struct lu_fid		op_fid4; /* to the operation locks. */
 	u32			op_mds;  /* what mds server open will go to */
 	u32			op_mode;
-	struct lustre_handle	op_handle;
+	struct lustre_handle	op_open_handle;
 	s64			op_mod_time;
 	const char	       *op_name;
 	size_t			op_namelen;
@@ -933,7 +933,7 @@ struct md_open_data {
 };
 
 struct obd_client_handle {
-	struct lustre_handle		och_fh;
+	struct lustre_handle		och_open_handle;
 	struct lu_fid			och_fid;
 	struct md_open_data	       *och_mod;
 	struct lustre_handle		och_lease_handle; /* open lock for lease */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index fd39948..a46f5d3 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -103,7 +103,7 @@ static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
 	op_data->op_attr_flags = ll_inode_to_ext_flags(inode->i_flags);
 	if (test_bit(LLIF_PROJECT_INHERIT, &lli->lli_flags))
 		op_data->op_attr_flags |= LUSTRE_PROJINHERIT_FL;
-	op_data->op_handle = och->och_fh;
+	op_data->op_open_handle = och->och_open_handle;
 
 	/*
 	 * For HSM: if inode data has been modified, pack it so that
@@ -230,7 +230,7 @@ static int ll_close_inode_openhandle(struct inode *inode,
 
 out:
 	md_clear_open_replay_data(md_exp, och);
-	och->och_fh.cookie = DEAD_HANDLE_MAGIC;
+	och->och_open_handle.cookie = DEAD_HANDLE_MAGIC;
 	kfree(och);
 
 	ptlrpc_req_finished(req);
@@ -613,7 +613,7 @@ static int ll_och_fill(struct obd_export *md_exp, struct lookup_intent *it,
 	struct mdt_body *body;
 
 	body = req_capsule_server_get(&it->it_request->rq_pill, &RMF_MDT_BODY);
-	och->och_fh = body->mbo_handle;
+	och->och_open_handle = body->mbo_open_handle;
 	och->och_fid = body->mbo_fid1;
 	och->och_lease_handle.cookie = it->it_lock_handle;
 	och->och_magic = OBD_CLIENT_HANDLE_MAGIC;
@@ -903,7 +903,7 @@ static int ll_md_blocking_lease_ast(struct ldlm_lock *lock,
  * if it has an open lock in cache already.
  */
 static int ll_lease_och_acquire(struct inode *inode, struct file *file,
-				struct lustre_handle *old_handle)
+				struct lustre_handle *old_open_handle)
 {
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -939,7 +939,7 @@ static int ll_lease_och_acquire(struct inode *inode, struct file *file,
 		*och_p = NULL;
 	}
 
-	*old_handle = fd->fd_och->och_fh;
+	*old_open_handle = fd->fd_och->och_open_handle;
 
 out_unlock:
 	mutex_unlock(&lli->lli_och_mutex);
@@ -999,7 +999,7 @@ static int ll_lease_och_release(struct inode *inode, struct file *file)
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct md_op_data *op_data;
 	struct ptlrpc_request *req = NULL;
-	struct lustre_handle old_handle = { 0 };
+	struct lustre_handle old_open_handle = { 0 };
 	struct obd_client_handle *och = NULL;
 	int rc;
 	int rc2;
@@ -1011,7 +1011,7 @@ static int ll_lease_och_release(struct inode *inode, struct file *file)
 		if (!(fmode & file->f_mode) || (file->f_mode & FMODE_EXEC))
 			return ERR_PTR(-EPERM);
 
-		rc = ll_lease_och_acquire(inode, file, &old_handle);
+		rc = ll_lease_och_acquire(inode, file, &old_open_handle);
 		if (rc)
 			return ERR_PTR(rc);
 	}
@@ -1028,7 +1028,7 @@ static int ll_lease_och_release(struct inode *inode, struct file *file)
 	}
 
 	/* To tell the MDT this openhandle is from the same owner */
-	op_data->op_handle = old_handle;
+	op_data->op_open_handle = old_open_handle;
 
 	it.it_flags = fmode | open_flags;
 	it.it_flags |= MDS_OPEN_LOCK | MDS_OPEN_BY_FID | MDS_OPEN_LEASE;
@@ -1230,7 +1230,7 @@ static int ll_lease_file_resync(struct obd_client_handle *och,
 	if (rc)
 		goto out;
 
-	op_data->op_handle = och->och_lease_handle;
+	op_data->op_lease_handle = och->och_lease_handle;
 	rc = md_file_resync(sbi->ll_md_exp, op_data);
 	if (rc)
 		goto out;
@@ -3892,7 +3892,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 		if (rc)
 			goto out_close;
 
-		op_data->op_handle = och->och_fh;
+		op_data->op_open_handle = och->och_open_handle;
 		op_data->op_data_version = data_version;
 		op_data->op_lease_handle = och->och_lease_handle;
 		op_data->op_bias |= MDS_CLOSE_MIGRATE;
@@ -3919,7 +3919,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 			obd_mod_put(och->och_mod);
 			md_clear_open_replay_data(ll_i2sbi(parent)->ll_md_exp,
 						  och);
-			och->och_fh.cookie = DEAD_HANDLE_MAGIC;
+			och->och_open_handle.cookie = DEAD_HANDLE_MAGIC;
 			kfree(och);
 			och = NULL;
 		}
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 636ddf8..be67652 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2258,7 +2258,7 @@ void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req)
 		return;
 
 	op_data->op_fid1 = body->mbo_fid1;
-	op_data->op_handle = body->mbo_handle;
+	op_data->op_open_handle = body->mbo_open_handle;
 	op_data->op_mod_time = get_seconds();
 	md_close(exp, op_data, NULL, &close_req);
 	ptlrpc_req_finished(close_req);
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 5b1691e..00a6be4 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -254,7 +254,7 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->cr_suppgid2 = op_data->op_suppgids[1];
 	rec->cr_bias = op_data->op_bias;
 	rec->cr_umask = current_umask();
-	rec->cr_old_handle = op_data->op_handle;
+	rec->cr_open_handle_old = op_data->op_open_handle;
 
 	if (op_data->op_name) {
 		mdc_pack_name(req, &RMF_NAME, op_data->op_name,
@@ -359,7 +359,7 @@ static void mdc_setattr_pack_rec(struct mdt_rec_setattr *rec,
 static void mdc_ioepoch_pack(struct mdt_ioepoch *epoch,
 			     struct md_op_data *op_data)
 {
-	epoch->mio_handle = op_data->op_handle;
+	epoch->mio_open_handle = op_data->op_open_handle;
 	epoch->mio_unused1 = 0;
 	epoch->mio_unused2 = 0;
 	epoch->mio_padding = 0;
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 355cee1..5d82449 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -456,9 +456,9 @@ int mdc_file_resync(struct obd_export *exp, struct md_op_data *op_data)
 	rec->rs_fid	= op_data->op_fid1;
 	rec->rs_bias	= op_data->op_bias;
 
-	lock = ldlm_handle2lock(&op_data->op_handle);
+	lock = ldlm_handle2lock(&op_data->op_lease_handle);
 	if (lock) {
-		rec->rs_handle = lock->l_remote_handle;
+		rec->rs_lease_handle = lock->l_remote_handle;
 		LDLM_LOCK_PUT(lock);
 	}
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 0ee42dd..15f94ea 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -593,7 +593,7 @@ void mdc_replay_open(struct ptlrpc_request *req)
 	struct md_open_data *mod = req->rq_cb_data;
 	struct ptlrpc_request *close_req;
 	struct obd_client_handle *och;
-	struct lustre_handle old;
+	struct lustre_handle old_open_handle = { };
 	struct mdt_body *body;
 
 	if (!mod) {
@@ -606,22 +606,22 @@ void mdc_replay_open(struct ptlrpc_request *req)
 
 	spin_lock(&req->rq_lock);
 	och = mod->mod_och;
-	if (och && och->och_fh.cookie)
+	if (och && och->och_open_handle.cookie)
 		req->rq_early_free_repbuf = 1;
 	else
 		req->rq_early_free_repbuf = 0;
 	spin_unlock(&req->rq_lock);
 
 	if (req->rq_early_free_repbuf) {
-		struct lustre_handle *file_fh;
+		struct lustre_handle *file_open_handle;
 
 		LASSERT(och->och_magic == OBD_CLIENT_HANDLE_MAGIC);
 
-		file_fh = &och->och_fh;
+		file_open_handle = &och->och_open_handle;
 		CDEBUG(D_HA, "updating handle from %#llx to %#llx\n",
-		       file_fh->cookie, body->mbo_handle.cookie);
-		old = *file_fh;
-		*file_fh = body->mbo_handle;
+		       file_open_handle->cookie, body->mbo_open_handle.cookie);
+		old_open_handle = *file_open_handle;
+		*file_open_handle = body->mbo_open_handle;
 	}
 
 	close_req = mod->mod_close_req;
@@ -635,10 +635,11 @@ void mdc_replay_open(struct ptlrpc_request *req)
 		LASSERT(epoch);
 
 		if (req->rq_early_free_repbuf)
-			LASSERT(!memcmp(&old, &epoch->mio_handle, sizeof(old)));
+			LASSERT(old_open_handle.cookie ==
+				epoch->mio_open_handle.cookie);
 
 		DEBUG_REQ(D_HA, close_req, "updating close body with new fh");
-		epoch->mio_handle = body->mbo_handle;
+		epoch->mio_open_handle = body->mbo_open_handle;
 	}
 }
 
@@ -722,11 +723,12 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 	}
 
 	rec->cr_fid2 = body->mbo_fid1;
-	rec->cr_old_handle.cookie = body->mbo_handle.cookie;
+	rec->cr_open_handle_old = body->mbo_open_handle;
 	open_req->rq_replay_cb = mdc_replay_open;
 	if (!fid_is_sane(&body->mbo_fid1)) {
 		DEBUG_REQ(D_ERROR, open_req,
-			  "Saving replay request with insane fid");
+			  "saving replay request with insane FID " DFID,
+			  PFID(&body->mbo_fid1));
 		LBUG();
 	}
 
@@ -774,7 +776,7 @@ static int mdc_clear_open_replay_data(struct obd_export *exp,
 
 	spin_lock(&mod->mod_open_req->rq_lock);
 	if (mod->mod_och)
-		mod->mod_och->och_fh.cookie = 0;
+		mod->mod_och->och_open_handle.cookie = 0;
 	mod->mod_open_req->rq_early_free_repbuf = 0;
 	spin_unlock(&mod->mod_open_req->rq_lock);
 	mdc_free_open(mod);
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index e71f79d..653a8d7 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1770,7 +1770,7 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b)
 {
 	/* handle is opaque */
-	/* mio_handle is opaque */
+	/* mio_open_handle is opaque */
 	BUILD_BUG_ON(!offsetof(typeof(*b), mio_unused1));
 	BUILD_BUG_ON(!offsetof(typeof(*b), mio_unused2));
 	BUILD_BUG_ON(!offsetof(typeof(*b), mio_padding));
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 4095767..845aff4 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1961,10 +1961,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_body, mbo_fid2));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_fid2) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_fid2));
-	LASSERTF((int)offsetof(struct mdt_body, mbo_handle) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, mbo_handle));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_handle) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_handle));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_open_handle) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_open_handle));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_open_handle) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_open_handle));
 	LASSERTF((int)offsetof(struct mdt_body, mbo_valid) == 40, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_body, mbo_valid));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_valid) == 8, "found %lld\n",
@@ -2162,10 +2162,10 @@ void lustre_assert_wire_constants(void)
 	/* Checks for struct mdt_ioepoch */
 	LASSERTF((int)sizeof(struct mdt_ioepoch) == 24, "found %lld\n",
 		 (long long)(int)sizeof(struct mdt_ioepoch));
-	LASSERTF((int)offsetof(struct mdt_ioepoch, mio_handle) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_ioepoch, mio_handle));
-	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->mio_handle) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->mio_handle));
+	LASSERTF((int)offsetof(struct mdt_ioepoch, mio_open_handle) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_ioepoch, mio_open_handle));
+	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->mio_open_handle) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->mio_open_handle));
 	LASSERTF((int)offsetof(struct mdt_ioepoch, mio_unused1) == 8, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_ioepoch, mio_unused1));
 	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->mio_unused1) == 8, "found %lld\n",
@@ -2334,10 +2334,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_rec_create, cr_fid2));
 	LASSERTF((int)sizeof(((struct mdt_rec_create *)0)->cr_fid2) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_rec_create *)0)->cr_fid2));
-	LASSERTF((int)offsetof(struct mdt_rec_create, cr_old_handle) == 72, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_rec_create, cr_old_handle));
-	LASSERTF((int)sizeof(((struct mdt_rec_create *)0)->cr_old_handle) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_rec_create *)0)->cr_old_handle));
+	LASSERTF((int)offsetof(struct mdt_rec_create, cr_open_handle_old) == 72, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_create, cr_open_handle_old));
+	LASSERTF((int)sizeof(((struct mdt_rec_create *)0)->cr_open_handle_old) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_create *)0)->cr_open_handle_old));
 	LASSERTF((int)offsetof(struct mdt_rec_create, cr_time) == 80, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_rec_create, cr_time));
 	LASSERTF((int)sizeof(((struct mdt_rec_create *)0)->cr_time) == 8, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 522bd52..39f2d3b 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1574,7 +1574,7 @@ enum md_transient_state {
 struct mdt_body {
 	struct lu_fid mbo_fid1;
 	struct lu_fid mbo_fid2;
-	struct lustre_handle mbo_handle;
+	struct lustre_handle mbo_open_handle;
 	__u64	mbo_valid;
 	__u64	mbo_size;	/* Offset, in the case of MDS_READPAGE */
 	__s64	mbo_mtime;
@@ -1612,7 +1612,7 @@ struct mdt_body {
 }; /* 216 */
 
 struct mdt_ioepoch {
-	struct lustre_handle mio_handle;
+	struct lustre_handle mio_open_handle;
 	__u64 mio_unused1; /* was ioepoch */
 	__u32 mio_unused2; /* was flags */
 	__u32 mio_padding;
@@ -1719,9 +1719,9 @@ struct mdt_rec_create {
 	__u32		cr_suppgid1_h;
 	__u32		cr_suppgid2;
 	__u32		cr_suppgid2_h;
-	struct lu_fid   cr_fid1;
-	struct lu_fid   cr_fid2;
-	struct lustre_handle cr_old_handle; /* handle in case of open replay */
+	struct lu_fid	cr_fid1;
+	struct lu_fid	cr_fid2;
+	struct lustre_handle cr_open_handle_old; /* in case of open replay */
 	__s64		cr_time;
 	__u64		cr_rdev;
 	__u64		cr_ioepoch;
@@ -1864,7 +1864,7 @@ struct mdt_rec_resync {
 	__u32           rs_suppgid2_h;
 	struct lu_fid   rs_fid;
 	__u8		rs_padding0[sizeof(struct lu_fid)];
-	struct lustre_handle rs_handle;	/* rr_mtime */
+	struct lustre_handle rs_lease_handle;	/* rr_mtime */
 	__s64		rs_padding1;	/* rr_atime */
 	__s64		rs_padding2;	/* rr_ctime */
 	__u64           rs_padding3;	/* rr_size */
-- 
1.8.3.1
