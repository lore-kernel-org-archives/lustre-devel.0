From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:15:06 -0400
Subject: [lustre-devel] [PATCH 17/22] staging: lustre: llite: cleanup xattr
 code comments
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Add proper punctuation to the comments. Change buf_size to size
for comment in ll_listxattr() since buf_size doesn't exit which
will confuse someone reading the code.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/27240
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index d6cee3b..835d00f 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -564,7 +564,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 		return rc;
 	/*
 	 * If we're being called to get the size of the xattr list
-	 * (buf_size == 0) then just assume that a lustre.lov xattr
+	 * (size == 0) then just assume that a lustre.lov xattr
 	 * exists.
 	 */
 	if (!size)
@@ -577,14 +577,14 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 		len = strnlen(xattr_name, rem - 1) + 1;
 		rem -= len;
 		if (!xattr_type_filter(sbi, get_xattr_type(xattr_name))) {
-			/* Skip OK xattr type leave it in buffer */
+			/* Skip OK xattr type, leave it in buffer. */
 			xattr_name += len;
 			continue;
 		}
 
 		/*
 		 * Move up remaining xattrs in buffer
-		 * removing the xattr that is not OK
+		 * removing the xattr that is not OK.
 		 */
 		memmove(xattr_name, xattr_name + len, rem);
 		rc -= len;
-- 
1.8.3.1
