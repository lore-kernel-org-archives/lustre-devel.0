From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:52 +1100
Subject: [lustre-devel] [PATCH 29/32] lustre: introduce
 CONFIG_LUSTRE_FS_POSIX_ACL
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231193.26912.14536836197493170469.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre (or any file system) should not conditionally
compile code based on CONFIG_FS_POSIX_ACL.  This config
option enables library support.
A file system can define it's own config option,
which then selects CONFIG_FS_POSIX_ACL (if needed).  It should
act on its own option, not the library one.

This patch makes that change.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/Kconfig              |   11 +++++++++++
 drivers/staging/lustre/lustre/include/lustre_acl.h |    6 +++---
 drivers/staging/lustre/lustre/include/obd.h        |    2 +-
 drivers/staging/lustre/lustre/llite/Makefile       |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   10 +++++-----
 drivers/staging/lustre/lustre/llite/xattr.c        |    4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    6 +++---
 8 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/Kconfig b/drivers/staging/lustre/lustre/Kconfig
index ccb78a945995..2ea3f2456b0f 100644
--- a/drivers/staging/lustre/lustre/Kconfig
+++ b/drivers/staging/lustre/lustre/Kconfig
@@ -30,6 +30,17 @@ config LUSTRE_FS
 
 	  See also http://wiki.lustre.org/
 
+config LUSTRE_FS_POSIX_ACL
+	bool "Lustre POSIX Access Control Lists"
+	depends on LUSTRE_FS
+	select FS_POSIX_ACL
+	help
+	  POSIX Access Control Lists (ACLs) support permissions for users and
+	  groups beyond the owner/group/world scheme.
+	  Lustre can support these ACLs.
+
+	  In in doubt, say Y.
+
 config LUSTRE_DEBUG_EXPENSIVE_CHECK
 	bool "Enable Lustre DEBUG checks"
 	depends on LUSTRE_FS
diff --git a/drivers/staging/lustre/lustre/include/lustre_acl.h b/drivers/staging/lustre/lustre/include/lustre_acl.h
index e7575a172b5f..e1f373d2e6cb 100644
--- a/drivers/staging/lustre/lustre/include/lustre_acl.h
+++ b/drivers/staging/lustre/lustre/include/lustre_acl.h
@@ -36,7 +36,7 @@
 
 #include <linux/fs.h>
 #include <linux/dcache.h>
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 #include <linux/posix_acl_xattr.h>
 
 #define LUSTRE_POSIX_ACL_MAX_ENTRIES	32
@@ -44,8 +44,8 @@
 	(sizeof(struct posix_acl_xattr_header) +				\
 	 LUSTRE_POSIX_ACL_MAX_ENTRIES * sizeof(struct posix_acl_xattr_entry))
 
-#else /* ! CONFIG_FS_POSIX_ACL */
+#else /* ! CONFIG_LUSTRE_FS_POSIX_ACL */
 #define LUSTRE_POSIX_ACL_MAX_SIZE_OLD 0
-#endif /* CONFIG_FS_POSIX_ACL */
+#endif /* CONFIG_LUSTRE_FS_POSIX_ACL */
 
 #endif
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index faf2ea623a09..6c984732d9c2 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -872,7 +872,7 @@ struct lustre_md {
 	struct mdt_body			*body;
 	struct lu_buf			 layout;
 	struct lmv_stripe_md		*lmv;
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	struct posix_acl		*posix_acl;
 #endif
 	struct mdt_remote_perm		*remote_perm;
diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 7d0225476362..b6698af044f6 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -10,4 +10,4 @@ lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o \
 	    lproc_llite.o
 
-lustre-$(CONFIG_FS_POSIX_ACL) += acl.o
+lustre-$(CONFIG_LUSTRE_FS_POSIX_ACL) += acl.o
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index c8860904bdd4..83053459f9c7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -814,13 +814,13 @@ int ll_release_openhandle(struct inode *inode, struct lookup_intent *it);
 int ll_md_real_close(struct inode *inode, fmode_t fmode);
 int ll_getattr(const struct path *path, struct kstat *stat,
 	       u32 request_mask, unsigned int flags);
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 struct posix_acl *ll_get_acl(struct inode *inode, int type);
 int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type);
 #else
 #define ll_get_acl NULL
 #define ll_set_acl NULL
-#endif /* CONFIG_FS_POSIX_ACL */
+#endif /* CONFIG_LUSTRE_FS_POSIX_ACL */
 
 int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	       const char *name, int namelen);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index cfe8105fe138..e55a4e0f68bf 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -209,7 +209,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	data->ocd_connect_flags |= OBD_CONNECT_ACL | OBD_CONNECT_UMASK |
 				   OBD_CONNECT_LARGE_ACL;
 #endif
@@ -512,7 +512,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	ptlrpc_req_finished(request);
 
 	if (IS_ERR(root)) {
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 		if (lmd.posix_acl) {
 			posix_acl_release(lmd.posix_acl);
 			lmd.posix_acl = NULL;
@@ -1394,7 +1394,7 @@ void ll_clear_inode(struct inode *inode)
 
 	ll_xattr_cache_destroy(inode);
 
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	forget_all_cached_acls(inode);
 	if (lli->lli_posix_acl) {
 		posix_acl_release(lli->lli_posix_acl);
@@ -1825,7 +1825,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 			return rc;
 	}
 
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	if (body->mbo_valid & OBD_MD_FLACL) {
 		spin_lock(&lli->lli_lock);
 		if (lli->lli_posix_acl)
@@ -2239,7 +2239,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 					     sbi->ll_flags & LL_SBI_32BIT_API),
 				 &md);
 		if (IS_ERR(*inode)) {
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 			if (md.posix_acl) {
 				posix_acl_release(md.posix_acl);
 				md.posix_acl = NULL;
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index a1d27061ac19..c1f6c38350d7 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -433,7 +433,7 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	    !strcmp(name, "selinux"))
 		return -EOPNOTSUPP;
 
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	/* posix acl is under protection of LOOKUP lock. when calling to this,
 	 * we just have path resolution to the target inode, so we have great
 	 * chance that cached ACL is uptodate.
@@ -676,7 +676,7 @@ const struct xattr_handler *ll_xattr_handlers[] = {
 	&ll_user_xattr_handler,
 	&ll_trusted_xattr_handler,
 	&ll_security_xattr_handler,
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	&ll_acl_access_xattr_handler,
 	&ll_acl_default_xattr_handler,
 #endif
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 451e6c94c7e8..b54c5f1418ae 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -408,7 +408,7 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 				req);
 }
 
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 static int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
 {
 	struct req_capsule *pill = &req->rq_pill;
@@ -535,7 +535,7 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 			rc = mdc_unpack_acl(req, md);
 			if (rc)
 				goto out;
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 		} else {
 			md->posix_acl = NULL;
 #endif
@@ -544,7 +544,7 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 
 out:
 	if (rc) {
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 		posix_acl_release(md->posix_acl);
 #endif
 	}
