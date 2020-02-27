From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:02 -0500
Subject: [lustre-devel] [PATCH 074/622] lustre: llite: handle zero length
 xattr values correctly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-75-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In mdt_getxattr(), set OBD_MD_FLXATTR in mbo_valid of the reply's MDT
body so that the client can distinguish between nonexistent extended
attributes and zero length values. In ll_xattr_list() and
ll_getxattr_common() test for OBD_MD_FLXATTR and return 0 rather than
-ENODATA in the appropriate cases. Add sanity test_102t() to test that
zero length values are handled correctly.

Lustre-commit: 1e4164a1254d ("LU-11109 mdt: handle zero length xattr values correctly")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32755
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/xattr.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index f25ae59..636334e 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -363,6 +363,11 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 
 		/* only detect the xattr size */
 		if (size == 0) {
+			/* LU-11109: Older MDTs do not distinguish
+			 * between nonexistent xattrs and zero length
+			 * values in this case. Newer MDTs will return
+			 * -ENODATA or set OBD_MD_FLXATTR.
+			 */
 			rc = body->mbo_eadatasize;
 			goto out;
 		}
@@ -375,7 +380,22 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 		}
 
 		if (body->mbo_eadatasize == 0) {
-			rc = -ENODATA;
+			/* LU-11109: Newer MDTs set OBD_MD_FLXATTR on
+			 * success so that we can distinguish between
+			 * zero length value and nonexistent xattr.
+			 *
+			 * If OBD_MD_FLXATTR is not set then we keep
+			 * the old behavior and return -ENODATA for
+			 * getxattr() when mbo_eadatasize is 0. But
+			 * -ENODATA only makes sense for getxattr()
+			 * and not for listxattr().
+			 */
+			if (body->mbo_valid & OBD_MD_FLXATTR)
+				rc = 0;
+			else if (valid == OBD_MD_FLXATTR)
+				rc = -ENODATA;
+			else
+				rc = 0;
 			goto out;
 		}
 
-- 
1.8.3.1
