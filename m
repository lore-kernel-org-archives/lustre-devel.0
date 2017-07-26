From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:36 -0400
Subject: [lustre-devel] [PATCH 20/20] staging: lustre: llite: set security
	xattr using __vfs_setxattr
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Currently ll_initxattrs() initializes the security xattrs in
a very non-standard using get_xattr_types() to get the struct
handler that lustre created to then call indirectly the function
to set the xattr. The available __vfs_setxattr() function does
the same thing and also handles the case of when size is zero
the xattr should be set to empty EA.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/27240
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/xattr_security.c   | 23 ++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr_security.c b/drivers/staging/lustre/lustre/llite/xattr_security.c
index d61d801..391fb25 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_security.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_security.c
@@ -28,7 +28,10 @@
  * lustre/llite/xattr_security.c
  * Handler for storing security labels as extended attributes.
  */
+
+#include <linux/types.h>
 #include <linux/security.h>
+#include <linux/selinux.h>
 #include <linux/xattr.h>
 #include "llite_internal.h"
 
@@ -48,19 +51,23 @@
 ll_initxattrs(struct inode *inode, const struct xattr *xattr_array,
 	      void *fs_info)
 {
-	const struct xattr_handler *handler;
 	struct dentry *dentry = fs_info;
 	const struct xattr *xattr;
 	int err = 0;
 
-	handler = get_xattr_type(XATTR_SECURITY_PREFIX);
-	if (!handler)
-		return -ENXIO;
-
 	for (xattr = xattr_array; xattr->name; xattr++) {
-		err = handler->set(handler, dentry, inode, xattr->name,
-				   xattr->value, xattr->value_len,
-				   XATTR_CREATE);
+		char *full_name;
+
+		full_name = kasprintf(GFP_KERNEL, "%s%s",
+				      XATTR_SECURITY_PREFIX, xattr->name);
+		if (!full_name) {
+			err = -ENOMEM;
+			break;
+		}
+
+		err = __vfs_setxattr(dentry, inode, full_name, xattr->value,
+				     xattr->value_len, XATTR_CREATE);
+		kfree(full_name);
 		if (err < 0)
 			break;
 	}
-- 
1.8.3.1
