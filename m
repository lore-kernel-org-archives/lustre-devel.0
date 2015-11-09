From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 00:24:17 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: acl: Remove
	lustre_posix_acl_xattr_free wrapper
Message-ID: <1447095257-21165-1-git-send-email-shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the wrapper function lustre_posix_acl_xattr_free() and replace its
call in the file xattr with the function kfree() that it wrapped. Also,
its prototype from the header lustre_eacl is removed as it is no longer
of any use.

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
 drivers/staging/lustre/lustre/include/lustre_eacl.h | 2 --
 drivers/staging/lustre/lustre/llite/xattr.c         | 5 ++++-
 drivers/staging/lustre/lustre/obdclass/acl.c        | 9 ---------
 3 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_eacl.h b/drivers/staging/lustre/lustre/include/lustre_eacl.h
index fee4d2c..0b66593 100644
--- a/drivers/staging/lustre/lustre/include/lustre_eacl.h
+++ b/drivers/staging/lustre/lustre/include/lustre_eacl.h
@@ -76,8 +76,6 @@ extern int
 lustre_posix_acl_xattr_filter(posix_acl_xattr_header *header, size_t size,
 			      posix_acl_xattr_header **out);
 extern void
-lustre_posix_acl_xattr_free(posix_acl_xattr_header *header, int size);
-extern void
 lustre_ext_acl_xattr_free(ext_acl_xattr_header *header);
 extern ext_acl_xattr_header *
 lustre_acl_xattr_merge2ext(posix_acl_xattr_header *posix_header, int size,
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 4b7eb33..f9b1dee 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -193,7 +193,10 @@ int ll_setxattr_common(struct inode *inode, const char *name,
 			 ll_i2suppgid(inode), &req);
 #ifdef CONFIG_FS_POSIX_ACL
 	if (new_value != NULL)
-		lustre_posix_acl_xattr_free(new_value, size);
+		/*
+		 * Release the posix ACL space.
+		 */
+		kfree(new_value);
 	if (acl != NULL)
 		lustre_ext_acl_xattr_free(acl);
 #endif
diff --git a/drivers/staging/lustre/lustre/obdclass/acl.c b/drivers/staging/lustre/lustre/obdclass/acl.c
index 2e20cf6..49ba885 100644
--- a/drivers/staging/lustre/lustre/obdclass/acl.c
+++ b/drivers/staging/lustre/lustre/obdclass/acl.c
@@ -236,15 +236,6 @@ _out:
 EXPORT_SYMBOL(lustre_posix_acl_xattr_filter);
 
 /*
- * Release the posix ACL space.
- */
-void lustre_posix_acl_xattr_free(posix_acl_xattr_header *header, int size)
-{
-	kfree(header);
-}
-EXPORT_SYMBOL(lustre_posix_acl_xattr_free);
-
-/*
  * Release the extended ACL space.
  */
 void lustre_ext_acl_xattr_free(ext_acl_xattr_header *header)
-- 
2.1.0
