From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:55 -0400
Subject: [lustre-devel] [PATCH 15/18] lustre: llite: don't hold inode_lock
 for security notify
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <alexander.boyko@hpe.com>

With selinux enabled client has a dead lock which leads to
client eviction from MDS.
1 thread                    2 thread
do file open                do stat
inode_lock(parend dir)
                            got LDLM_PR(parent dir)
enqueue LDLM_CW(parent dir) waits on inode_lock to notify security
waits
timeout on enqueue
and client eviction because client didn't cancel a LDLM_PR lock

security_inode_notifysecctx()->selinux_inode_notifysecctx()->
selinux_inode_setsecurity()
The call of selinux_inode_setsecurity doesn't need to hold
inode_lock.

Fixes: f4d3cf7642 ("lustre: llite: set sec ctx on client's inode at create time")
Cray-bug-id: LUS-8924
WC-bug-id: https://jira.whamcloud.com/browse/LU-13617
Lustre-commit: f87359b51f61a ("LU-13617 llite: don't hold inode_lock for security notify")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/38792
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c   |  6 ++++--
 fs/lustre/llite/namei.c | 18 ++++++++++++------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 463c5d7..e3305f7 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -489,11 +489,13 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	dentry.d_inode = inode;
 
 	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
-		inode_lock(inode);
+		/* no need to protect selinux_inode_setsecurity() by
+		 * inode_lock. Taking it would lead to a client deadlock
+		 * LU-13617
+		 */
 		err = security_inode_notifysecctx(inode,
 						  op_data->op_file_secctx,
 						  op_data->op_file_secctx_size);
-		inode_unlock(inode);
 	} else {
 		err = ll_inode_init_security(&dentry, inode, parent);
 	}
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 2353a8f..251d6be 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -659,10 +659,12 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		}
 
 		if (secctx && secctxlen != 0) {
-			inode_lock(inode);
+			/* no need to protect selinux_inode_setsecurity() by
+			 * inode_lock. Taking it would lead to a client deadlock
+			 * LU-13617
+			 */
 			rc = security_inode_notifysecctx(inode, secctx,
 							 secctxlen);
-			inode_unlock(inode);
 			if (rc)
 				CWARN("cannot set security context for " DFID ": rc = %d\n",
 				      PFID(ll_inode2fid(inode)), rc);
@@ -1198,13 +1200,15 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 		return PTR_ERR(inode);
 
 	if ((ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX) && secctx) {
-		inode_lock(inode);
 		/* must be done before d_instantiate, because it calls
 		 * security_d_instantiate, which means a getxattr if security
 		 * context is not set yet
 		 */
+		/* no need to protect selinux_inode_setsecurity() by
+		 * inode_lock. Taking it would lead to a client deadlock
+		 * LU-13617
+		 */
 		rc = security_inode_notifysecctx(inode, secctx, secctxlen);
-		inode_unlock(inode);
 		if (rc)
 			return rc;
 	}
@@ -1370,15 +1374,17 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 		goto err_exit;
 
 	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
-		inode_lock(inode);
 		/* must be done before d_instantiate, because it calls
 		 * security_d_instantiate, which means a getxattr if security
 		 * context is not set yet
 		 */
+		/* no need to protect selinux_inode_setsecurity() by
+		 * inode_lock. Taking it would lead to a client deadlock
+		 * LU-13617
+		 */
 		err = security_inode_notifysecctx(inode,
 						  op_data->op_file_secctx,
 						  op_data->op_file_secctx_size);
-		inode_unlock(inode);
 		if (err)
 			goto err_exit;
 	}
-- 
1.8.3.1
