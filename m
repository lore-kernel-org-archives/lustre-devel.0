From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:16 -0400
Subject: [lustre-devel] [PATCH 20/23] lustre: llite: pack parent FID in
 getattr
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Pack parent FID in getattr request if OBD_CONNECT2_GETATTR_PFID is
enabled, otherwise fill it with target FID for backward compatibility.

Fixes: e11fdb90 ("lustre: mdt: don't fetch LOOKUP lock for remot...")

WC-bug-id: https://jira.whamcloud.com/browse/LU-13437
Lustre-commit:  5f2c44bf626b ("U-13437 llite: pack parent FID in getattr")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39290
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c      | 10 ++++++++--
 fs/lustre/llite/llite_lib.c |  3 ++-
 fs/lustre/lmv/lmv_intent.c  |  5 ++++-
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 7d00728..17c2d88 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4533,6 +4533,7 @@ static int ll_inode_revalidate_fini(struct inode *inode, int rc)
 
 static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 {
+	struct inode *parent;
 	struct inode *inode = d_inode(dentry);
 	struct obd_export *exp = ll_i2mdexp(inode);
 	struct lookup_intent oit = {
@@ -4545,9 +4546,14 @@ static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p),name=%pd\n",
 	       PFID(ll_inode2fid(inode)), inode, dentry);
 
+	if (exp_connect_flags2(exp) & OBD_CONNECT2_GETATTR_PFID)
+		parent = dentry->d_parent->d_inode;
+	else
+		parent = inode;
+
 	/* Call getattr by fid, so do not provide name at all. */
-	op_data = ll_prep_md_op_data(NULL, dentry->d_parent->d_inode, inode,
-				     NULL, 0, 0, LUSTRE_OPC_ANY, NULL);
+	op_data = ll_prep_md_op_data(NULL, parent, inode, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4773fc1..e732a82 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -261,7 +261,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_LSOM |
 				   OBD_CONNECT2_ASYNC_DISCARD |
 				   OBD_CONNECT2_PCC |
-				   OBD_CONNECT2_CRUSH;
+				   OBD_CONNECT2_CRUSH |
+				   OBD_CONNECT2_GETATTR_PFID;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 4af449e..3960b93 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -197,7 +197,10 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 		 * which is not needed here.
 		 */
 		memset(op_data, 0, sizeof(*op_data));
-		op_data->op_fid1 = *pfid;
+		if (exp_connect_flags2(exp) & OBD_CONNECT2_GETATTR_PFID)
+			op_data->op_fid1 = *pfid;
+		else
+			op_data->op_fid1 = fid;
 		op_data->op_fid2 = fid;
 
 		tgt = lmv_tgt(lmv, lsm->lsm_md_oinfo[i].lmo_mds);
-- 
1.8.3.1
