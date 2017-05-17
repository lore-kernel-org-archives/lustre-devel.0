From: Robin Humble <rjh+lustre@cita.utoronto.ca>
Date: Wed, 17 May 2017 10:17:11 -0400
Subject: [lustre-devel] [PATCH] lustre: llite: Remove filtering of seclabel
	xattr
Message-ID: <20170517141711.GB1064@trinity.cita.utoronto.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Signed-off-by: Robin Humble <plaguedbypenguins@gmail.com>
---
 lustre/llite/xattr.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/lustre/llite/xattr.c b/lustre/llite/xattr.c
index 4d42956..527ee40 100644
--- a/lustre/llite/xattr.c
+++ b/lustre/llite/xattr.c
@@ -147,11 +147,6 @@ int ll_setxattr_common(struct inode *inode, const char *name,
 		 strcmp(name, "lustre.lov") == 0))
 		RETURN(0);
 
-	/* b15587: ignore security.capability xattr for now */
-	if ((xattr_type == XATTR_SECURITY_T &&
-	    strcmp(name, "security.capability") == 0))
-		RETURN(0);
-
 	/* LU-549:  Disable security.selinux when selinux is disabled */
 	if (xattr_type == XATTR_SECURITY_T && !selinux_is_enabled() &&
 	    strcmp(name, "security.selinux") == 0)
@@ -343,11 +338,6 @@ int ll_getxattr_common(struct inode *inode, const char *name,
         if (rc)
                 RETURN(rc);
 
-        /* b15587: ignore security.capability xattr for now */
-        if ((xattr_type == XATTR_SECURITY_T &&
-            strcmp(name, "security.capability") == 0))
-                RETURN(-ENODATA);
-
         /* LU-549:  Disable security.selinux when selinux is disabled */
         if (xattr_type == XATTR_SECURITY_T && !selinux_is_enabled() &&
             strcmp(name, "security.selinux") == 0)
-- 
2.9.4
