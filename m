From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:45 -0500
Subject: [lustre-devel] [PATCH 12/14] lustre: llite: fix file migration
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Several small bugs have appeared over the years that broke file
migration. The first bug is that the hash was created using the
parent inode instead of using file_dentry(file). The second
problem occured with op_fid3 being set when the child dentry
was found. The last problem was rn_opcode was always being set
to REINT_RENAME in mdc_rename_pack(). Remove that extra
nr_opcode setting.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c  | 3 +--
 drivers/staging/lustre/lustre/mdc/mdc_lib.c | 1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 3647618..c018c5f 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3003,12 +3003,11 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		return PTR_ERR(op_data);
 
 	/* Get child FID first */
-	qstr.hash = full_name_hash(parent, name, namelen);
+	qstr.hash = full_name_hash(file_dentry(file), name, namelen);
 	qstr.name = name;
 	qstr.len = namelen;
 	dchild = d_lookup(file_dentry(file), &qstr);
 	if (dchild) {
-		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
 		if (dchild->d_inode)
 			child_inode = igrab(dchild->d_inode);
 		dput(dchild);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 415127f..a1b1e75 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -457,7 +457,6 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	/* XXX do something about time, uid, gid */
 	rec->rn_opcode	 = op_data->op_cli_flags & CLI_MIGRATE ?
 				REINT_MIGRATE : REINT_RENAME;
-	rec->rn_opcode   = REINT_RENAME;
 	rec->rn_fsuid    = op_data->op_fsuid;
 	rec->rn_fsgid    = op_data->op_fsgid;
 	rec->rn_cap      = op_data->op_cap.cap[0];
-- 
1.8.3.1
