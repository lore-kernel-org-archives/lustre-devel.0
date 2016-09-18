From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:54 -0400
Subject: [lustre-devel] [PATCH 115/124] staging: lustre: mdt: add indexing
	option to default dir stripe
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-116-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Add indexing option to default dirstripe EA. If MDT find
out the client send the create req to the wrong MDT because
of default stripeEA, it will return -EREMOTE, then client
will retrieve default stripeEA through xattr cache, and
re-create the object.

Also merged patch for LU-6341 to resolve the following problem.
Use ll_dir_getstripe to get default stripeEA in ll_new_node(),
Because ll_getxattr_common requires admin rights for retrieving
default LMVEA (because of trusted- prefix), which might cause
mkdir (from normal user) failure.

If parent does not have default stripeEA, then child should always
be in the same MDT for mkdir. Otherwise MDT should return -EREMOTE,
then client will refresh the default stripe index, and recreate
the object.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5523
Reviewed-on: http://review.whamcloud.com/13360
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6341
Reviewed-on: http://review.whamcloud.com/13990
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    3 +
 .../staging/lustre/lustre/llite/llite_internal.h   |    7 +++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    7 +++-
 drivers/staging/lustre/lustre/llite/namei.c        |   45 ++++++++++++++++++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    5 ++
 5 files changed, 63 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index c6937b2..ef11534 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -773,6 +773,9 @@ struct md_op_data {
 	/* File object data version for HSM release, on client */
 	__u64			op_data_version;
 	struct lustre_handle	op_lease_handle;
+
+	/* default stripe offset */
+	__u32			op_default_stripe_offset;
 };
 
 struct md_callback {
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 51bf071..70ca3e1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -191,6 +191,13 @@ struct ll_inode_info {
 			unsigned int			lli_sa_generation;
 			/* directory stripe information */
 			struct lmv_stripe_md	       *lli_lsm_md;
+			/* default directory stripe offset.  This is extracted
+			 * from the "dmv" xattr in order to decide which MDT to
+			 * create a subdirectory on.  The MDS itself fetches
+			 * "dmv" and gets the rest of the default layout itself
+			 * (count, hash, etc).
+			 */
+			__u32				lli_def_stripe_offset;
 		};
 
 		/* for non-directory */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 230868c..465b315 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -802,6 +802,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		spin_lock_init(&lli->lli_sa_lock);
 		lli->lli_opendir_pid = 0;
 		lli->lli_sa_enabled = 0;
+		lli->lli_def_stripe_offset = -1;
 	} else {
 		mutex_init(&lli->lli_size_mutex);
 		lli->lli_symlink_name = NULL;
@@ -2342,8 +2343,12 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 
 	ll_i2gids(op_data->op_suppgids, i1, i2);
 	op_data->op_fid1 = *ll_inode2fid(i1);
-	if (S_ISDIR(i1->i_mode))
+	op_data->op_default_stripe_offset = -1;
+	if (S_ISDIR(i1->i_mode)) {
 		op_data->op_mea1 = ll_i2info(i1)->lli_lsm_md;
+		op_data->op_default_stripe_offset =
+			ll_i2info(i1)->lli_def_stripe_offset;
+	}
 
 	if (i2) {
 		op_data->op_fid2 = *ll_inode2fid(i2);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 3960893..624966d 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -204,6 +204,8 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		}
 
 		if (bits & MDS_INODELOCK_XATTR) {
+			if (S_ISDIR(inode->i_mode))
+				ll_i2info(inode)->lli_def_stripe_offset = -1;
 			ll_xattr_cache_destroy(inode);
 			bits &= ~MDS_INODELOCK_XATTR;
 		}
@@ -833,7 +835,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 
 	if (unlikely(tgt))
 		tgt_len = strlen(tgt) + 1;
-
+again:
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
 				     dentry->d_name.name,
 				     dentry->d_name.len,
@@ -848,9 +850,45 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 			from_kgid(&init_user_ns, current_fsgid()),
 			cfs_curproc_cap_pack(), rdev, &request);
 	ll_finish_md_op_data(op_data);
-	if (err)
+	if (err < 0 && err != -EREMOTE)
 		goto err_exit;
 
+	/*
+	 * If the client doesn't know where to create a subdirectory (or
+	 * in case of a race that sends the RPC to the wrong MDS), the
+	 * MDS will return -EREMOTE and the client will fetch the layout
+	 * of the directory, then create the directory on the right MDT.
+	 */
+	if (unlikely(err == -EREMOTE)) {
+		struct ll_inode_info *lli = ll_i2info(dir);
+		struct lmv_user_md *lum;
+		int lumsize, err2;
+
+		ptlrpc_req_finished(request);
+		request = NULL;
+
+		err2 = ll_dir_getstripe(dir, (void **)&lum, &lumsize, &request,
+					OBD_MD_DEFAULT_MEA);
+		if (!err2) {
+			/* Update stripe_offset and retry */
+			lli->lli_def_stripe_offset = lum->lum_stripe_offset;
+		} else if (err2 == -ENODATA &&
+			   lli->lli_def_stripe_offset != -1) {
+			/*
+			 * If there are no default stripe EA on the MDT, but the
+			 * client has default stripe, then it probably means
+			 * default stripe EA has just been deleted.
+			 */
+			lli->lli_def_stripe_offset = -1;
+		} else {
+			goto err_exit;
+		}
+
+		ptlrpc_req_finished(request);
+		request = NULL;
+		goto again;
+	}
+
 	ll_update_times(request, dir);
 
 	err = ll_prep_inode(&inode, request, dir->i_sb, NULL);
@@ -859,7 +897,8 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 
 	d_instantiate(dentry, inode);
 err_exit:
-	ptlrpc_req_finished(request);
+	if (request)
+		ptlrpc_req_finished(request);
 
 	return err;
 }
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index cccb645..d67d0e0 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1164,6 +1164,11 @@ static int lmv_placement_policy(struct obd_device *obd,
 		return 0;
 	}
 
+	if (op_data->op_default_stripe_offset != -1) {
+		*mds = op_data->op_default_stripe_offset;
+		return 0;
+	}
+
 	/**
 	 * If stripe_offset is provided during setdirstripe
 	 * (setdirstripe -i xx), xx MDS will be chosen.
-- 
1.7.1
