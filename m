From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed,  2 Mar 2016 08:25:39 -0500
Subject: [lustre-devel] [PATCH] staging/lustre: Unbreak ll_prep_inode iget
	result check
Message-ID: <1456925139-1058929-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>, Amitoj Kaur Chawla <amitoj1606@gmail.com>

From: Oleg Drokin <green@linuxhacker.ru>

commit 020ecc6f3229 ("staging: lustre: llite: Remove IS_ERR tests")
managed to break one of the converted checks by losing a dereference
causing the condition to be wrong and hence leading
to a crash later on in case of actual error.
IS_ERR_OR_NULL(*inode) got converted into !inode.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
CC: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
I am not sure where did that patch came from as I cannot see
it in either my inbox or in any public mailinglists via google.

 drivers/staging/lustre/lustre/llite/llite_lib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b2e8475..acdae25 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1972,7 +1972,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 		*inode = ll_iget(sb, cl_fid_build_ino(&md.body->fid1,
 					     sbi->ll_flags & LL_SBI_32BIT_API),
 				 &md);
-		if (!inode) {
+		if (!*inode) {
 #ifdef CONFIG_FS_POSIX_ACL
 			if (md.posix_acl) {
 				posix_acl_release(md.posix_acl);
-- 
2.1.0
