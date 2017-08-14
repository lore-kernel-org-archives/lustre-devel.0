From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:21:00 -0400
Subject: [lustre-devel] [PATCH 10/14] staging: lustre: llite: cleanup posix
	acl xattr code
In-Reply-To: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502727664-29438-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Have extra ifdef makes the code harder to read. For the case of
ll_xattr_get_common() we have a variable initialized at the
start of the function but it is only used in XATTR_ACL_ACCESS_T
code block. Lets move that variable to that location since its
only used there and make the code look cleaner.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/27240
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 5728579..64fa65a 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -397,9 +397,6 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 			       const char *name, void *buffer, size_t size)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
-#ifdef CONFIG_FS_POSIX_ACL
-	struct ll_inode_info *lli = ll_i2info(inode);
-#endif
 	char *fullname;
 	int rc;
 
@@ -423,6 +420,7 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	 * chance that cached ACL is uptodate.
 	 */
 	if (handler->flags == XATTR_ACL_ACCESS_T) {
+		struct ll_inode_info *lli = ll_i2info(inode);
 		struct posix_acl *acl;
 
 		spin_lock(&lli->lli_lock);
-- 
1.8.3.1
