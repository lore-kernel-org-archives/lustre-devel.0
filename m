From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 14 Nov 2015 13:30:34 +0100
Subject: [lustre-devel] [PATCH] lustre: constify inode_operations structures
Message-ID: <1447504234-25165-1-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The inode_operations structures are never modified, so declare them
as const, like all the other inode_operations structures.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/staging/lustre/lustre/llite/file.c           |    2 +-
 drivers/staging/lustre/lustre/llite/llite_internal.h |    4 ++--
 drivers/staging/lustre/lustre/llite/symlink.c        |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 02f2759..31cd6b3 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3139,7 +3139,7 @@ struct file_operations ll_file_operations_noflock = {
 	.lock	   = ll_file_noflock
 };
 
-struct inode_operations ll_file_inode_operations = {
+const struct inode_operations ll_file_inode_operations = {
 	.setattr	= ll_setattr,
 	.getattr	= ll_getattr,
 	.permission	= ll_inode_permission,
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 9096d31..6102b29 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -705,7 +705,7 @@ extern const struct address_space_operations ll_aops;
 extern struct file_operations ll_file_operations;
 extern struct file_operations ll_file_operations_flock;
 extern struct file_operations ll_file_operations_noflock;
-extern struct inode_operations ll_file_inode_operations;
+extern const struct inode_operations ll_file_inode_operations;
 int ll_have_md_lock(struct inode *inode, __u64 *bits,
 		    ldlm_mode_t l_req_mode);
 ldlm_mode_t ll_take_md_lock(struct inode *inode, __u64 bits,
@@ -805,7 +805,7 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 				      const struct lu_fid *fid);
 
 /* llite/symlink.c */
-extern struct inode_operations ll_fast_symlink_inode_operations;
+extern const struct inode_operations ll_fast_symlink_inode_operations;
 
 /* llite/llite_close.c */
 struct ll_close_queue {
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 69b2036..32c4cf4 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -146,7 +146,7 @@ static void ll_put_link(struct inode *unused, void *cookie)
 	ptlrpc_req_finished(cookie);
 }
 
-struct inode_operations ll_fast_symlink_inode_operations = {
+const struct inode_operations ll_fast_symlink_inode_operations = {
 	.readlink	= generic_readlink,
 	.setattr	= ll_setattr,
 	.follow_link	= ll_follow_link,
