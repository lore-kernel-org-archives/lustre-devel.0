From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:46 -0400
Subject: [lustre-devel] [PATCH 147/151] lustre: introduce
 CONFIG_LUSTRE_FS_POSIX_ACL
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-148-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

Lustre (or any file system) should not conditionally
compile code based on CONFIG_FS_POSIX_ACL.  This config
option enables library support.
A file system can define it's own config option,
which then selects CONFIG_FS_POSIX_ACL (if needed).  It should
act on its own option, not the library one.

This patch makes that change.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 19b2bc9bbc25 ("LU-6142 lustre: introduce CONFIG_LUSTRE_FS_POSIX_ACL")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36085
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/Kconfig                | 11 +++++++++++
 fs/lustre/include/lustre_acl.h   |  6 +++---
 fs/lustre/include/obd.h          |  2 +-
 fs/lustre/llite/Makefile         |  2 +-
 fs/lustre/llite/llite_internal.h |  4 ++--
 fs/lustre/llite/llite_lib.c      | 10 +++++-----
 fs/lustre/llite/xattr.c          |  4 ++--
 fs/lustre/mdc/mdc_request.c      |  6 +++---
 8 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/Kconfig b/fs/lustre/Kconfig
index ccb78a9..2ea3f24 100644
--- a/fs/lustre/Kconfig
+++ b/fs/lustre/Kconfig
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
diff --git a/fs/lustre/include/lustre_acl.h b/fs/lustre/include/lustre_acl.h
index 067ed3f..bb161ba 100644
--- a/fs/lustre/include/lustre_acl.h
+++ b/fs/lustre/include/lustre_acl.h
@@ -38,7 +38,7 @@
 
 #include <linux/fs.h>
 #include <linux/dcache.h>
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 #include <linux/posix_acl_xattr.h>
 
 #define LUSTRE_POSIX_ACL_MAX_ENTRIES	32
@@ -46,8 +46,8 @@
 	(sizeof(struct posix_acl_xattr_header) +			\
 	 LUSTRE_POSIX_ACL_MAX_ENTRIES * sizeof(struct posix_acl_xattr_entry))
 
-#else /* ! CONFIG_FS_POSIX_ACL */
+#else /* ! CONFIG_LUSTRE_FS_POSIX_ACL */
 #define LUSTRE_POSIX_ACL_MAX_SIZE_OLD 0
-#endif /* CONFIG_FS_POSIX_ACL */
+#endif /* CONFIG_LUSTRE_FS_POSIX_ACL */
 
 #endif
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 2db2596..e94774b 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -903,7 +903,7 @@ struct lustre_md {
 	struct mdt_body			*body;
 	struct lu_buf			 layout;
 	struct lmv_stripe_md		*lmv;
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	struct posix_acl		*posix_acl;
 #endif
 	struct mdt_remote_perm		*remote_perm;
diff --git a/fs/lustre/llite/Makefile b/fs/lustre/llite/Makefile
index 6d8a33b..811b9ab 100644
--- a/fs/lustre/llite/Makefile
+++ b/fs/lustre/llite/Makefile
@@ -9,4 +9,4 @@ lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    vvp_dev.o vvp_page.o vvp_io.o vvp_object.o \
 	    lproc_llite.o
 
-lustre-$(CONFIG_FS_POSIX_ACL) += acl.o
+lustre-$(CONFIG_LUSTRE_FS_POSIX_ACL) += acl.o
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index e067ba4..2cb67b0 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -825,13 +825,13 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, u64 bits,
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
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4d14ce1..a48d753 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -213,7 +213,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	data->ocd_connect_flags |= OBD_CONNECT_ACL | OBD_CONNECT_UMASK |
 				   OBD_CONNECT_LARGE_ACL;
 #endif
@@ -542,7 +542,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	ptlrpc_req_finished(request);
 
 	if (IS_ERR(root)) {
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 		if (lmd.posix_acl) {
 			posix_acl_release(lmd.posix_acl);
 			lmd.posix_acl = NULL;
@@ -1425,7 +1425,7 @@ void ll_clear_inode(struct inode *inode)
 
 	ll_xattr_cache_destroy(inode);
 
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	forget_all_cached_acls(inode);
 	if (lli->lli_posix_acl) {
 		posix_acl_release(lli->lli_posix_acl);
@@ -1857,7 +1857,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 			return rc;
 	}
 
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	if (body->mbo_valid & OBD_MD_FLACL) {
 		spin_lock(&lli->lli_lock);
 		if (lli->lli_posix_acl)
@@ -2272,7 +2272,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 						  sbi->ll_flags & LL_SBI_32BIT_API),
 				 &md);
 		if (IS_ERR(*inode)) {
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 			if (md.posix_acl) {
 				posix_acl_release(md.posix_acl);
 				md.posix_acl = NULL;
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 378c190..f25ae59 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -422,7 +422,7 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	if (rc)
 		return rc;
 
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	/* posix acl is under protection of LOOKUP lock. when calling to this,
 	 * we just have path resolution to the target inode, so we have great
 	 * chance that cached ACL is uptodate.
@@ -665,7 +665,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 	&ll_user_xattr_handler,
 	&ll_trusted_xattr_handler,
 	&ll_security_xattr_handler,
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	&ll_acl_access_xattr_handler,
 	&ll_acl_default_xattr_handler,
 #endif
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 408bf19..5718db2 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -440,7 +440,7 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 				req);
 }
 
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 static int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
 {
 	struct req_capsule *pill = &req->rq_pill;
@@ -567,7 +567,7 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 			rc = mdc_unpack_acl(req, md);
 			if (rc)
 				goto out;
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 		} else {
 			md->posix_acl = NULL;
 #endif
@@ -576,7 +576,7 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 
 out:
 	if (rc) {
-#ifdef CONFIG_FS_POSIX_ACL
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 		posix_acl_release(md->posix_acl);
 #endif
 	}
-- 
1.8.3.1
