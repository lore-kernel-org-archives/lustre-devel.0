From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:46 -0400
Subject: [lustre-devel] [PATCH 107/124] staging: lustre: lmv: Do not
	revalidate stripes with master lock
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-108-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Do not revalidate slave stripes while holding master lock.
Otherwise if the revalidating slaves are blocked, then the
master lock can not be released in time.

Remove some unnecesary merging in ll_revalidate_slave(), and
the attributes will be stored in each stripe, only
merging them if required.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6088
Reviewed-on: http://review.whamcloud.com/13432
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    5 +--
 drivers/staging/lustre/lustre/include/obd_class.h  |   15 +------
 drivers/staging/lustre/lustre/llite/file.c         |   19 +++------
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    7 +---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   41 ++------------------
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    4 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   28 ++++++-------
 8 files changed, 31 insertions(+), 91 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 986c6e9..c6937b2 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1000,10 +1000,7 @@ struct md_ops {
 
 	int (*merge_attr)(struct obd_export *,
 			  const struct lmv_stripe_md *lsm,
-			  struct cl_attr *attr);
-
-	int (*update_lsm_md)(struct obd_export *, struct lmv_stripe_md *lsm,
-			     struct mdt_body *, ldlm_blocking_callback);
+			  struct cl_attr *attr, ldlm_blocking_callback);
 
 	int (*set_open_replay_data)(struct obd_export *,
 				    struct obd_client_handle *,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 9836aed..16094db 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1497,23 +1497,14 @@ static inline int md_free_lustre_md(struct obd_export *exp,
 	return MDP(exp->exp_obd, free_lustre_md)(exp, md);
 }
 
-static inline int md_update_lsm_md(struct obd_export *exp,
-				   struct lmv_stripe_md *lsm,
-				   struct mdt_body *body,
-				   ldlm_blocking_callback cb)
-{
-	EXP_CHECK_MD_OP(exp, update_lsm_md);
-	EXP_MD_COUNTER_INCREMENT(exp, update_lsm_md);
-	return MDP(exp->exp_obd, update_lsm_md)(exp, lsm, body, cb);
-}
-
 static inline int md_merge_attr(struct obd_export *exp,
 				const struct lmv_stripe_md *lsm,
-				struct cl_attr *attr)
+				struct cl_attr *attr,
+				ldlm_blocking_callback cb)
 {
 	EXP_CHECK_MD_OP(exp, merge_attr);
 	EXP_MD_COUNTER_INCREMENT(exp, merge_attr);
-	return MDP(exp->exp_obd, merge_attr)(exp, lsm, attr);
+	return MDP(exp->exp_obd, merge_attr)(exp, lsm, attr, cb);
 }
 
 static inline int md_setxattr(struct obd_export *exp, const struct lu_fid *fid,
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index e8963fe..d8761b8 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3045,12 +3045,13 @@ static int ll_merge_md_attr(struct inode *inode)
 
 	LASSERT(ll_i2info(inode)->lli_lsm_md);
 	rc = md_merge_attr(ll_i2mdexp(inode), ll_i2info(inode)->lli_lsm_md,
-			   &attr);
+			   &attr, ll_md_blocking_ast);
 	if (rc)
 		return rc;
 
-	ll_i2info(inode)->lli_stripe_dir_size = attr.cat_size;
-	ll_i2info(inode)->lli_stripe_dir_nlink = attr.cat_nlink;
+	set_nlink(inode, attr.cat_nlink);
+	inode->i_blocks = attr.cat_blocks;
+	i_size_write(inode, attr.cat_size);
 
 	ll_i2info(inode)->lli_atime = attr.cat_atime;
 	ll_i2info(inode)->lli_mtime = attr.cat_mtime;
@@ -3123,16 +3124,10 @@ int ll_getattr(struct vfsmount *mnt, struct dentry *de, struct kstat *stat)
 	stat->mtime = inode->i_mtime;
 	stat->ctime = inode->i_ctime;
 	stat->blksize = 1 << inode->i_blkbits;
-	stat->blocks = inode->i_blocks;
 
-	if (S_ISDIR(inode->i_mode) &&
-	    ll_i2info(inode)->lli_lsm_md) {
-		stat->nlink = lli->lli_stripe_dir_nlink;
-		stat->size = lli->lli_stripe_dir_size;
-	} else {
-		stat->nlink = inode->i_nlink;
-		stat->size = i_size_read(inode);
-	}
+	stat->nlink = inode->i_nlink;
+	stat->size = i_size_read(inode);
+	stat->blocks = inode->i_blocks;
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index e5f1967..51bf071 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -191,9 +191,6 @@ struct ll_inode_info {
 			unsigned int			lli_sa_generation;
 			/* directory stripe information */
 			struct lmv_stripe_md	       *lli_lsm_md;
-			/* striped directory size */
-			loff_t				lli_stripe_dir_size;
-			u64				lli_stripe_dir_nlink;
 		};
 
 		/* for non-directory */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ff843e1..230868c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1117,12 +1117,7 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 		}
 	}
 
-	/*
-	 * Here is where the lsm is being initialized(fill lmo_info) after
-	 * client retrieve MD stripe information from MDT.
-	 */
-	return md_update_lsm_md(ll_i2mdexp(inode), lsm, md->body,
-				ll_md_blocking_ast);
+	return 0;
 }
 
 static inline int lli_lsm_md_eq(const struct lmv_stripe_md *lsm_md1,
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 3197b6f..fe5c60a 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -148,8 +148,8 @@ out:
 	return rc;
 }
 
-int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
-			  struct lmv_stripe_md *lsm,
+int lmv_revalidate_slaves(struct obd_export *exp,
+			  const struct lmv_stripe_md *lsm,
 			  ldlm_blocking_callback cb_blocking,
 			  int extra_lock_flags)
 {
@@ -158,11 +158,6 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 	struct ptlrpc_request *req = NULL;
 	struct mdt_body *body;
 	struct md_op_data *op_data;
-	unsigned long size = 0;
-	unsigned long nlink = 0;
-	__s64 atime = 0;
-	__s64 ctime = 0;
-	__s64 mtime = 0;
 	int rc = 0, i;
 
 	/**
@@ -243,6 +238,7 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 			}
 
 			i_size_write(inode, body->mbo_size);
+			inode->i_blocks = body->mbo_blocks;
 			set_nlink(inode, body->mbo_nlink);
 			LTIME_S(inode->i_atime) = body->mbo_atime;
 			LTIME_S(inode->i_ctime) = body->mbo_ctime;
@@ -251,41 +247,12 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 
 		md_set_lock_data(tgt->ltd_exp, lockh, inode, NULL);
 
-		if (i != 0)
-			nlink += inode->i_nlink - 2;
-		else
-			nlink += inode->i_nlink;
-
-		atime = LTIME_S(inode->i_atime) > atime ?
-				LTIME_S(inode->i_atime) : atime;
-		ctime = LTIME_S(inode->i_ctime) > ctime ?
-				LTIME_S(inode->i_ctime) : ctime;
-		mtime = LTIME_S(inode->i_mtime) > mtime ?
-				LTIME_S(inode->i_mtime) : mtime;
-
 		if (it.it_lock_mode && lockh) {
 			ldlm_lock_decref(lockh, it.it_lock_mode);
 			it.it_lock_mode = 0;
 		}
-
-		CDEBUG(D_INODE, "i %d "DFID" size %llu, nlink %u, atime %lu, mtime %lu, ctime %lu.\n",
-		       i, PFID(&fid), i_size_read(inode), inode->i_nlink,
-		       LTIME_S(inode->i_atime), LTIME_S(inode->i_mtime),
-		       LTIME_S(inode->i_ctime));
 	}
 
-	/*
-	 * update attr of master request.
-	 */
-	CDEBUG(D_INODE, "Return refreshed attrs: size = %lu nlink %lu atime %llu ctime %llu mtime %llu for " DFID"\n",
-	       size, nlink, atime, ctime, mtime,
-	       PFID(&lsm->lsm_md_oinfo[0].lmo_fid));
-
-	if (mbody) {
-		mbody->mbo_atime = atime;
-		mbody->mbo_ctime = ctime;
-		mbody->mbo_mtime = mtime;
-	}
 cleanup:
 	if (req)
 		ptlrpc_req_finished(req);
@@ -445,7 +412,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		 * during update_inode process (see ll_update_lsm_md)
 		 */
 		if (op_data->op_mea2) {
-			rc = lmv_revalidate_slaves(exp, NULL, op_data->op_mea2,
+			rc = lmv_revalidate_slaves(exp, op_data->op_mea2,
 						   cb_blocking,
 						   extra_lock_flags);
 			if (rc != 0)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 8f703ea..52b0374 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -57,8 +57,8 @@ int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 		  const union lmv_mds_md *lmm, int stripe_count);
 
-int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
-			  struct lmv_stripe_md *lsm,
+int lmv_revalidate_slaves(struct obd_export *exp,
+			  const struct lmv_stripe_md *lsm,
 			  ldlm_blocking_callback cb_blocking,
 			  int extra_lock_flags);
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 5928605..941981d 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -3242,27 +3242,25 @@ static int lmv_quotacheck(struct obd_device *unused, struct obd_export *exp,
 	return rc;
 }
 
-static int
-lmv_update_lsm_md(struct obd_export *exp, struct lmv_stripe_md *lsm,
-		  struct mdt_body *body, ldlm_blocking_callback cb_blocking)
+static int lmv_merge_attr(struct obd_export *exp,
+			  const struct lmv_stripe_md *lsm,
+			  struct cl_attr *attr,
+			  ldlm_blocking_callback cb_blocking)
 {
-	return lmv_revalidate_slaves(exp, body, lsm, cb_blocking, 0);
-}
+	int rc, i;
 
-static int
-lmv_merge_attr(struct obd_export *exp, const struct lmv_stripe_md *lsm,
-	       struct cl_attr *attr)
-{
-	int i;
+	rc = lmv_revalidate_slaves(exp, lsm, cb_blocking, 0);
+	if (rc < 0)
+		return rc;
 
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 		struct inode *inode = lsm->lsm_md_oinfo[i].lmo_root;
 
-		CDEBUG(D_INFO, ""DFID" size %llu, nlink %u, atime %lu ctime %lu, mtime %lu.\n",
+		CDEBUG(D_INFO, ""DFID" size %llu, blocks %llu nlink %u, atime %lu ctime %lu, mtime %lu.\n",
 		       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
-		       i_size_read(inode), inode->i_nlink,
-		       LTIME_S(inode->i_atime), LTIME_S(inode->i_ctime),
-		       LTIME_S(inode->i_mtime));
+		       i_size_read(inode), (unsigned long long)inode->i_blocks,
+		       inode->i_nlink, LTIME_S(inode->i_atime),
+		       LTIME_S(inode->i_ctime), LTIME_S(inode->i_mtime));
 
 		/* for slave stripe, it needs to subtract nlink for . and .. */
 		if (i)
@@ -3271,6 +3269,7 @@ lmv_merge_attr(struct obd_export *exp, const struct lmv_stripe_md *lsm,
 			attr->cat_nlink = inode->i_nlink;
 
 		attr->cat_size += i_size_read(inode);
+		attr->cat_blocks += inode->i_blocks;
 
 		if (attr->cat_atime < LTIME_S(inode->i_atime))
 			attr->cat_atime = LTIME_S(inode->i_atime);
@@ -3328,7 +3327,6 @@ static struct md_ops lmv_md_ops = {
 	.lock_match		= lmv_lock_match,
 	.get_lustre_md		= lmv_get_lustre_md,
 	.free_lustre_md		= lmv_free_lustre_md,
-	.update_lsm_md		= lmv_update_lsm_md,
 	.merge_attr		= lmv_merge_attr,
 	.set_open_replay_data	= lmv_set_open_replay_data,
 	.clear_open_replay_data	= lmv_clear_open_replay_data,
-- 
1.7.1
