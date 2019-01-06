From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:43 -0500
Subject: [lustre-devel] [PATCH 10/14] lustre: llite: user xattr_prefix() to
 create xattr full name
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Some xattrs use the prefix field and some like ACLs use the name
field. The function xattr_prefix() was created to handle these
cases. A patch was landed to properly handle this but a part of
the patch was missed in the merger. For the creation of fulname
use xattr_prefix() instead of the handler prefix field.

Fixes: ab42bc01284 ("staging: lustre: llite: use xattr_handler name for ACLs")
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 5e27c85..aeaa04a 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -140,7 +140,7 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 			return -EPERM;
 	}
 
-	fullname = kasprintf(GFP_KERNEL, "%s%s", handler->prefix, name);
+	fullname = kasprintf(GFP_KERNEL, "%s%s", xattr_prefix(handler), name);
 	if (!fullname)
 		return -ENOMEM;
 
@@ -443,7 +443,7 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	if (handler->flags == XATTR_ACL_DEFAULT_T && !S_ISDIR(inode->i_mode))
 		return -ENODATA;
 #endif
-	fullname = kasprintf(GFP_KERNEL, "%s%s", handler->prefix, name);
+	fullname = kasprintf(GFP_KERNEL, "%s%s", xattr_prefix(handler), name);
 	if (!fullname)
 		return -ENOMEM;
 
-- 
1.8.3.1
