From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:29 -0400
Subject: [lustre-devel] [PATCH 19/30] lustre: llite: set sec ctx on client's
 inode at create time
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

On client side, security context must be set on the inode of
every new dir or file that is being created.

With LL_SBI_FILE_SECCTX, security context is obtained from the
dentry thanks to a call to ll_dentry_init_security(). And it is
saved to security.xxx xattr directly on MDS side when processing
the create request. So it is only necessary to call
security_inode_notifysecctx() to set the sec ctx on the client's
inode.

Without LL_SBI_FILE_SECCTX, security context can only be obtained
from the inode, ie after the file has been created on MDS side.
So use ll_inode_init_security() that will set the sec ctx on the
client's inode, and at the same time save it on disk to
security.xxx xattr, generating an additional request to the MDS.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8956
Reviewed-on: https://review.whamcloud.com/24426
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Jean-Baptiste Riaux <riaux.jb@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c   | 10 ++++-
 drivers/staging/lustre/lustre/llite/namei.c | 59 ++++++++++++++++++++++++-----
 2 files changed, 59 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 26b0c2d..aa55bfd 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -42,6 +42,7 @@
 #include <linux/buffer_head.h>   /* for wait_on_buffer */
 #include <linux/pagevec.h>
 #include <linux/prefetch.h>
+#include <linux/security.h>
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
@@ -468,8 +469,15 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 
 	dentry.d_inode = inode;
 
-	if (!(sbi->ll_flags & LL_SBI_FILE_SECCTX))
+	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
+		inode_lock(inode);
+		err = security_inode_notifysecctx(inode,
+						  op_data->op_file_secctx,
+						  op_data->op_file_secctx_size);
+		inode_unlock(inode);
+	} else {
 		err = ll_inode_init_security(&dentry, inode, parent);
+	}
 
 out_inode:
 	iput(inode);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index ca81e0c..09cdf02 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -47,7 +47,7 @@
 #include "llite_internal.h"
 
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
-			struct lookup_intent *it);
+			struct lookup_intent *it, void *secctx, u32 secctxlen);
 
 /* called from iget5_locked->find_inode() under inode_hash_lock spinlock */
 static int ll_test_inode(struct inode *inode, void *opaque)
@@ -527,7 +527,8 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 }
 
 static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
-				   struct lookup_intent *it)
+				   struct lookup_intent *it, void **secctx,
+				   u32 *secctxlen)
 {
 	struct lookup_intent lookup_it = { .it_op = IT_LOOKUP };
 	struct dentry *save = dentry, *retval;
@@ -590,6 +591,10 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 			retval = ERR_PTR(rc);
 			goto out;
 		}
+		if (secctx)
+			*secctx = op_data->op_file_secctx;
+		if (secctxlen)
+			*secctxlen = op_data->op_file_secctx_size;
 	}
 
 	rc = md_intent_lock(ll_i2mdexp(parent), op_data, it, &req,
@@ -649,8 +654,16 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	else
 		retval = dentry;
 out:
-	if (op_data && !IS_ERR(op_data))
+	if (op_data && !IS_ERR(op_data)) {
+		if (secctx && secctxlen) {
+			/* caller needs sec ctx info, so reset it in op_data to
+			 * prevent it from being freed
+			 */
+			op_data->op_file_secctx = NULL;
+			op_data->op_file_secctx_size = 0;
+		}
 		ll_finish_md_op_data(op_data);
+	}
 
 	ptlrpc_req_finished(req);
 	return retval;
@@ -677,7 +690,7 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 		itp = NULL;
 	else
 		itp = &it;
-	de = ll_lookup_it(parent, dentry, itp);
+	de = ll_lookup_it(parent, dentry, itp, NULL, NULL);
 
 	if (itp)
 		ll_intent_release(itp);
@@ -694,6 +707,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 			  umode_t mode)
 {
 	struct lookup_intent *it;
+	void *secctx = NULL;
+	u32 secctxlen = 0;
 	struct dentry *de;
 	int rc = 0;
 
@@ -730,7 +745,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	it->it_flags &= ~MDS_OPEN_FL_INTERNAL;
 
 	/* Dentry added to dcache tree in ll_lookup_it */
-	de = ll_lookup_it(dir, dentry, it);
+	de = ll_lookup_it(dir, dentry, it, &secctx, &secctxlen);
 	if (IS_ERR(de))
 		rc = PTR_ERR(de);
 	else if (de)
@@ -739,7 +754,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	if (!rc) {
 		if (it_disposition(it, DISP_OPEN_CREATE)) {
 			/* Dentry instantiated in ll_create_it. */
-			rc = ll_create_it(dir, dentry, it);
+			rc = ll_create_it(dir, dentry, it, secctx, secctxlen);
+			security_release_secctx(secctx, secctxlen);
 			if (rc) {
 				/* We dget in ll_splice_alias. */
 				if (de)
@@ -828,7 +844,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
  * with d_instantiate().
  */
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
-			struct lookup_intent *it)
+			struct lookup_intent *it, void *secctx, u32 secctxlen)
 {
 	struct inode *inode;
 	int rc = 0;
@@ -844,6 +860,18 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 	if (IS_ERR(inode))
 		return PTR_ERR(inode);
 
+	if ((ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX) && secctx) {
+		inode_lock(inode);
+		/* must be done before d_instantiate, because it calls
+		 * security_d_instantiate, which means a getxattr if security
+		 * context is not set yet
+		 */
+		rc = security_inode_notifysecctx(inode, secctx, secctxlen);
+		inode_unlock(inode);
+		if (rc)
+			return rc;
+	}
+
 	d_instantiate(dentry, inode);
 
 	if (!(ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX))
@@ -906,8 +934,6 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			current_cap(), rdev, &request);
-	ll_finish_md_op_data(op_data);
-	op_data = NULL;
 	if (err < 0 && err != -EREMOTE)
 		goto err_exit;
 
@@ -944,6 +970,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 
 		ptlrpc_req_finished(request);
 		request = NULL;
+		ll_finish_md_op_data(op_data);
 		goto again;
 	}
 
@@ -953,6 +980,20 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 	if (err)
 		goto err_exit;
 
+	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
+		inode_lock(inode);
+		/* must be done before d_instantiate, because it calls
+		 * security_d_instantiate, which means a getxattr if security
+		 * context is not set yet
+		 */
+		err = security_inode_notifysecctx(inode,
+						  op_data->op_file_secctx,
+						  op_data->op_file_secctx_size);
+		inode_unlock(inode);
+		if (err)
+			goto err_exit;
+	}
+
 	d_instantiate(dentry, inode);
 
 	if (!(sbi->ll_flags & LL_SBI_FILE_SECCTX))
-- 
1.8.3.1
