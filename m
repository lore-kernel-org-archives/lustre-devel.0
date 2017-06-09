From: Roman Storozhenko <romeusmeister@gmail.com>
Date: Fri, 9 Jun 2017 15:04:17 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: llite: Make structure
 describing various file operations 'const'
Message-ID: <20170609120417.GA19650@home>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Use 'const' in declarations of various 'file_operations' structures.

Signed-off-by: Roman Storozhenko <romeusmeister@gmail.com>
---
 drivers/staging/lustre/lustre/llite/file.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 67c4b9c..4072240 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3114,7 +3114,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 }
 
 /* -o localflock - only provides locally consistent flock locks */
-struct file_operations ll_file_operations = {
+struct const file_operations ll_file_operations = {
 	.read_iter = ll_file_read_iter,
 	.write_iter = ll_file_write_iter,
 	.unlocked_ioctl = ll_file_ioctl,
@@ -3127,7 +3127,7 @@ struct file_operations ll_file_operations = {
 	.flush	  = ll_flush
 };
 
-struct file_operations ll_file_operations_flock = {
+struct const file_operations ll_file_operations_flock = {
 	.read_iter    = ll_file_read_iter,
 	.write_iter   = ll_file_write_iter,
 	.unlocked_ioctl = ll_file_ioctl,
@@ -3143,7 +3143,7 @@ struct file_operations ll_file_operations_flock = {
 };
 
 /* These are for -o noflock - to return ENOSYS on flock calls */
-struct file_operations ll_file_operations_noflock = {
+struct const file_operations ll_file_operations_noflock = {
 	.read_iter    = ll_file_read_iter,
 	.write_iter   = ll_file_write_iter,
 	.unlocked_ioctl = ll_file_ioctl,
-- 
2.7.4
