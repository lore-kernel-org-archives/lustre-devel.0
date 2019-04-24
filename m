From: NeilBrown <neilb@suse.com>
Date: Wed, 24 Apr 2019 12:17:26 +1000
Subject: [lustre-devel] [PATCH 3/4] lustre: remove use of
 selinux_is_enabled().
In-Reply-To: <155607223991.16863.3231709121984405156.stgit@noble.brown>
References: <155607223991.16863.3231709121984405156.stgit@noble.brown>
Message-ID: <155607224621.16863.13502209812654413995.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

selinux_is_enabled() no longer exists.  Instead we depend on
relevant functions returning -EOPNOTSUPP.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/xattr.c        |   11 -----------
 .../staging/lustre/lustre/llite/xattr_security.c   |   16 +++++++++-------
 2 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index a1d27061ac19..d604c5bc1abe 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -35,7 +35,6 @@
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <linux/xattr.h>
-#include <linux/selinux.h>
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
@@ -121,11 +120,6 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	     (handler->flags == XATTR_LUSTRE_T && !strcmp(name, "lov"))))
 		return 0;
 
-	/* LU-549:  Disable security.selinux when selinux is disabled */
-	if (handler->flags == XATTR_SECURITY_T && !selinux_is_enabled() &&
-	    strcmp(name, "selinux") == 0)
-		return -EOPNOTSUPP;
-
 	/*FIXME: enable IMA when the conditions are ready */
 	if (handler->flags == XATTR_SECURITY_T &&
 	    (!strcmp(name, "ima") || !strcmp(name, "evm")))
@@ -428,11 +422,6 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	if (rc)
 		return rc;
 
-	/* LU-549:  Disable security.selinux when selinux is disabled */
-	if (handler->flags == XATTR_SECURITY_T && !selinux_is_enabled() &&
-	    !strcmp(name, "selinux"))
-		return -EOPNOTSUPP;
-
 #ifdef CONFIG_FS_POSIX_ACL
 	/* posix acl is under protection of LOOKUP lock. when calling to this,
 	 * we just have path resolution to the target inode, so we have great
diff --git a/drivers/staging/lustre/lustre/llite/xattr_security.c b/drivers/staging/lustre/lustre/llite/xattr_security.c
index f1c011eb5613..e5a52d96643b 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_security.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_security.c
@@ -32,7 +32,6 @@
 
 #include <linux/types.h>
 #include <linux/security.h>
-#include <linux/selinux.h>
 #include <linux/xattr.h>
 #include "llite_internal.h"
 
@@ -58,11 +57,11 @@ int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
 	 * calls it and assumes that if anything is returned then it must come
 	 * from SELinux.
 	 */
-	if (!selinux_is_enabled())
-		return 0;
 
 	rc = security_dentry_init_security(dentry, mode, name, secctx,
 					   secctx_size);
+	if (rc == -EOPNOTSUPP)
+		return 0;
 	if (rc < 0)
 		return rc;
 
@@ -124,9 +123,12 @@ int
 ll_inode_init_security(struct dentry *dentry, struct inode *inode,
 		       struct inode *dir)
 {
-	if (!selinux_is_enabled())
-		return 0;
+	int err;
 
-	return security_inode_init_security(inode, dir, NULL,
-					    &ll_initxattrs, dentry);
+	err = security_inode_init_security(inode, dir, NULL,
+					   &ll_initxattrs, dentry);
+
+	if (err == -EOPNOTSUPP)
+		return 0;
+	return err;
 }
