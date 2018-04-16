From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:15:09 -0400
Subject: [lustre-devel] [PATCH 20/22] staging: lustre: llite: use
 xattr_handler name for ACLs
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: "John L. Hammond" <john.hammond@intel.com>

If struct xattr_handler has a name member then use it (rather than
prefix) for the ACL xattrs. This avoids a bug where ACL operations
failed for some kernels.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10785
Reviewed-on: https://review.whamcloud.com/
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index d08bf1e..e835c8e 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -46,15 +46,16 @@
 
 const struct xattr_handler *get_xattr_type(const char *name)
 {
-	int i = 0;
+	int i;
 
-	while (ll_xattr_handlers[i]) {
-		size_t len = strlen(ll_xattr_handlers[i]->prefix);
+	for (i = 0; ll_xattr_handlers[i]; i++) {
+		const char *prefix = xattr_prefix(ll_xattr_handlers[i]);
+		size_t prefix_len = strlen(prefix);
 
-		if (!strncmp(ll_xattr_handlers[i]->prefix, name, len))
+		if (!strncmp(prefix, name, prefix_len))
 			return ll_xattr_handlers[i];
-		i++;
 	}
+
 	return NULL;
 }
 
@@ -627,14 +628,14 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 };
 
 static const struct xattr_handler ll_acl_access_xattr_handler = {
-	.prefix = XATTR_NAME_POSIX_ACL_ACCESS,
+	.name = XATTR_NAME_POSIX_ACL_ACCESS,
 	.flags = XATTR_ACL_ACCESS_T,
 	.get = ll_xattr_get_common,
 	.set = ll_xattr_set_common,
 };
 
 static const struct xattr_handler ll_acl_default_xattr_handler = {
-	.prefix = XATTR_NAME_POSIX_ACL_DEFAULT,
+	.name = XATTR_NAME_POSIX_ACL_DEFAULT,
 	.flags = XATTR_ACL_DEFAULT_T,
 	.get = ll_xattr_get_common,
 	.set = ll_xattr_set_common,
-- 
1.8.3.1
