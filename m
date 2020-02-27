From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:33 -0500
Subject: [lustre-devel] [PATCH 405/622] lustre: llite: improve
 ll_dom_lock_cancel
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-406-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <c17830@cray.com>

ll_dom_lock_cancel() should zero kms attribute similar to
mdc_ldlm_blocking_ast0().

In order to avoid code duplication between mdc_ldlm_blocking_ast0()
and ll_dom_lock_cancel() - add cl_object_operations method to be able
to reach mdc's blocking ast from llite level.

Test illustrating the issue is added.

Cray-bug-id: LUS-7118
WC-bug-id: https://jira.whamcloud.com/browse/LU-12296
Lustre-commit: 707bab62f5d6 ("LU-12296 llite: improve ll_dom_lock_cancel")
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-on: https://review.whamcloud.com/34858
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  | 10 ++++++++++
 fs/lustre/llite/namei.c        | 25 +++++--------------------
 fs/lustre/lov/lov_object.c     | 26 +++++++++++++++++++++++++-
 fs/lustre/mdc/mdc_dev.c        | 11 +++++++++--
 fs/lustre/obdclass/cl_object.c | 17 +++++++++++++++++
 5 files changed, 66 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 5096025..7ac0dd2 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -417,6 +417,13 @@ struct cl_object_operations {
 	void (*coo_req_attr_set)(const struct lu_env *env,
 				 struct cl_object *obj,
 				 struct cl_req_attr *attr);
+	/**
+	 * Flush \a obj data corresponding to \a lock. Used for DoM
+	 * locks in llite's cancelling blocking ast callback.
+	 */
+	int (*coo_object_flush)(const struct lu_env *env,
+				struct cl_object *obj,
+				struct ldlm_lock *lock);
 };
 
 /**
@@ -2108,6 +2115,9 @@ int cl_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 int cl_object_layout_get(const struct lu_env *env, struct cl_object *obj,
 			 struct cl_layout *cl);
 loff_t cl_object_maxbytes(struct cl_object *obj);
+int cl_object_flush(const struct lu_env *env, struct cl_object *obj,
+		    struct ldlm_lock *lock);
+
 
 /**
  * Returns true, iff @o0 and @o1 are slices of the same object.
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 49433c9..71e757a 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -177,13 +177,12 @@ int ll_test_inode_by_fid(struct inode *inode, void *opaque)
 	return lu_fid_eq(&ll_i2info(inode)->lli_fid, opaque);
 }
 
-int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
+static int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 {
 	struct lu_env *env;
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct cl_layout clt = { .cl_layout_gen = 0, };
-	int rc;
 	u16 refcheck;
+	int rc;
 
 	if (!lli->lli_clob) {
 		/* Due to DoM read on open, there may exist pages for Lustre
@@ -197,28 +196,14 @@ int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	rc = cl_object_layout_get(env, lli->lli_clob, &clt);
-	if (rc) {
-		CDEBUG(D_INODE, "Cannot get layout for "DFID"\n",
-		       PFID(ll_inode2fid(inode)));
-		rc = -ENODATA;
-	} else if (clt.cl_size == 0 || clt.cl_dom_comp_size == 0) {
-		CDEBUG(D_INODE, "DOM lock without DOM layout for "DFID"\n",
-		       PFID(ll_inode2fid(inode)));
-	} else {
-		enum cl_fsync_mode mode;
-		loff_t end = clt.cl_dom_comp_size - 1;
+	/* reach MDC layer to flush data under  the DoM ldlm lock */
+	rc = cl_object_flush(env, lli->lli_clob, lock);
 
-		mode = ldlm_is_discard_data(lock) ?
-					CL_FSYNC_DISCARD : CL_FSYNC_LOCAL;
-		rc = cl_sync_file_range(inode, 0, end, mode, 1);
-		truncate_inode_pages_range(inode->i_mapping, 0, end);
-	}
 	cl_env_put(env, &refcheck);
 	return rc;
 }
 
-void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
+static void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 {
 	struct inode *inode = ll_inode_from_resource_lock(lock);
 	struct ll_inode_info *lli;
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 792d946..52d8c30 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -75,6 +75,8 @@ struct lov_layout_operations {
 			    struct cl_object *obj, struct cl_io *io);
 	int  (*llo_getattr)(const struct lu_env *env, struct cl_object *obj,
 			    struct cl_attr *attr);
+	int  (*llo_flush)(const struct lu_env *env, struct cl_object *obj,
+			  struct ldlm_lock *lock);
 };
 
 static int lov_layout_wait(const struct lu_env *env, struct lov_object *lov);
@@ -1021,7 +1023,21 @@ static int lov_attr_get_composite(const struct lu_env *env,
 	return 0;
 }
 
-static const struct lov_layout_operations lov_dispatch[] = {
+static int lov_flush_composite(const struct lu_env *env,
+			       struct cl_object *obj,
+			       struct ldlm_lock *lock)
+{
+	struct lov_object *lov = cl2lov(obj);
+	struct lovsub_object *lovsub;
+
+	if (!lsme_is_dom(lov->lo_lsm->lsm_entries[0]))
+		return -EINVAL;
+
+	lovsub = lov->u.composite.lo_entries[0].lle_dom.lo_dom;
+	return cl_object_flush(env, lovsub2cl(lovsub), lock);
+}
+
+const static struct lov_layout_operations lov_dispatch[] = {
 	[LLT_EMPTY] = {
 		.llo_init	= lov_init_empty,
 		.llo_delete	= lov_delete_empty,
@@ -1051,6 +1067,7 @@ static int lov_attr_get_composite(const struct lu_env *env,
 		.llo_lock_init	= lov_lock_init_composite,
 		.llo_io_init	= lov_io_init_composite,
 		.llo_getattr	= lov_attr_get_composite,
+		.llo_flush	= lov_flush_composite,
 	},
 	[LLT_FOREIGN] = {
 		.llo_init      = lov_init_foreign,
@@ -2083,6 +2100,12 @@ static loff_t lov_object_maxbytes(struct cl_object *obj)
 	return maxbytes;
 }
 
+static int lov_object_flush(const struct lu_env *env, struct cl_object *obj,
+			    struct ldlm_lock *lock)
+{
+	return LOV_2DISPATCH_NOLOCK(cl2lov(obj), llo_flush, env, obj, lock);
+}
+
 static const struct cl_object_operations lov_ops = {
 	.coo_page_init		= lov_page_init,
 	.coo_lock_init		= lov_lock_init,
@@ -2094,6 +2117,7 @@ static loff_t lov_object_maxbytes(struct cl_object *obj)
 	.coo_layout_get		= lov_object_layout_get,
 	.coo_maxbytes		= lov_object_maxbytes,
 	.coo_fiemap		= lov_object_fiemap,
+	.coo_object_flush	= lov_object_flush
 };
 
 static const struct lu_object_operations lov_lu_obj_ops = {
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 14cece1..df8bb33 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -286,7 +286,7 @@ void mdc_lock_lockless_cancel(const struct lu_env *env,
  */
 static int mdc_dlm_blocking_ast0(const struct lu_env *env,
 				 struct ldlm_lock *dlmlock,
-				 void *data, int flag)
+				 int flag)
 {
 	struct cl_object *obj = NULL;
 	int result = 0;
@@ -375,7 +375,7 @@ int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 			break;
 		}
 
-		rc = mdc_dlm_blocking_ast0(env, dlmlock, data, flag);
+		rc = mdc_dlm_blocking_ast0(env, dlmlock, flag);
 		cl_env_put(env, &refcheck);
 		break;
 	}
@@ -1382,6 +1382,12 @@ int mdc_object_prune(const struct lu_env *env, struct cl_object *obj)
 	return 0;
 }
 
+static int mdc_object_flush(const struct lu_env *env, struct cl_object *obj,
+			    struct ldlm_lock *lock)
+{
+	return mdc_dlm_blocking_ast0(env, lock, LDLM_CB_CANCELING);
+}
+
 static const struct cl_object_operations mdc_ops = {
 	.coo_page_init		= osc_page_init,
 	.coo_lock_init		= mdc_lock_init,
@@ -1391,6 +1397,7 @@ int mdc_object_prune(const struct lu_env *env, struct cl_object *obj)
 	.coo_glimpse		= osc_object_glimpse,
 	.coo_req_attr_set	= mdc_req_attr_set,
 	.coo_prune		= mdc_object_prune,
+	.coo_object_flush	= mdc_object_flush
 };
 
 static const struct osc_object_operations mdc_object_ops = {
diff --git a/fs/lustre/obdclass/cl_object.c b/fs/lustre/obdclass/cl_object.c
index f0ae34f..b323eb4 100644
--- a/fs/lustre/obdclass/cl_object.c
+++ b/fs/lustre/obdclass/cl_object.c
@@ -389,6 +389,23 @@ loff_t cl_object_maxbytes(struct cl_object *obj)
 }
 EXPORT_SYMBOL(cl_object_maxbytes);
 
+int cl_object_flush(const struct lu_env *env, struct cl_object *obj,
+			 struct ldlm_lock *lock)
+{
+	struct lu_object_header *top = obj->co_lu.lo_header;
+	int rc = 0;
+
+	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
+		if (obj->co_ops->coo_object_flush) {
+			rc = obj->co_ops->coo_object_flush(env, obj, lock);
+			if (rc)
+				break;
+		}
+	}
+	return rc;
+}
+EXPORT_SYMBOL(cl_object_flush);
+
 /**
  * Helper function removing all object locks, and marking object for
  * deletion. All object pages must have been deleted at this point.
-- 
1.8.3.1
