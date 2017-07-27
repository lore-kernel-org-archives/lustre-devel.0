From: Robin Humble <rjh+lustre@cita.utoronto.ca>
Date: Thu, 27 Jul 2017 13:14:31 -0400
Subject: [lustre-devel] [PATCH 18/20] staging: lustre: llite: Remove
 filtering of seclabel xattr
In-Reply-To: <1501082556-17962-19-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
	<1501082556-17962-19-git-send-email-jsimmons@infradead.org>
Message-ID: <20170727171431.GA14966@trinity.cita.utoronto.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi James,

sorry, but this isn't my patch.
I deleted a couple of lines from xattr.c, not the below.

I think you might have got the wrong commit comment somehow?

I took lkml etc. out of the CC 'cos I'm not subscribed there.

cheers,
robin

On Wed, Jul 26, 2017 at 11:22:34AM -0400, James Simmons wrote:
>From: Robin Humble <plaguedbypenguins@gmail.com>
>
>The security.capability xattr is used to implement File
>Capabilities in recent Linux versions. Capabilities are a
>fine grained approach to granting executables elevated
>privileges. eg. /bin/ping can have capabilities
>cap_net_admin, cap_net_raw+ep instead of being setuid root.
>
>This xattr has long been filtered out by llite, initially for
>stability reasons (b15587), and later over performance
>concerns as this xattr is read for every file with eg.
>'ls --color'. Since LU-2869 xattr's are cached on clients,
>alleviating most performance concerns.
>
>Removing llite's filtering of the security.capability xattr
>enables using Lustre as a root filesystem, which is used on
>some large clusters.
>
>Signed-off-by: Robin Humble <plaguedbypenguins@gmail.com>
>Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9562
>Reviewed-on: https://review.whamcloud.com/27292
>Reviewed-by: John L. Hammond <john.hammond@intel.com>
>Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
>Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
>Signed-off-by: James Simmons <jsimmons@infradead.org>
>---
> drivers/staging/lustre/lustre/llite/file.c         | 58 ++++++++++++++++++++++
> .../staging/lustre/lustre/llite/llite_internal.h   |  4 ++
> drivers/staging/lustre/lustre/llite/namei.c        |  6 +++
> 3 files changed, 68 insertions(+)
>
>diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
>index 215479a..a324580 100644
>--- a/drivers/staging/lustre/lustre/llite/file.c
>+++ b/drivers/staging/lustre/lustre/llite/file.c
>@@ -3040,6 +3040,61 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
> 	return acl;
> }
> 
>+#ifdef CONFIG_FS_POSIX_ACL
>+int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type)
>+{
>+	const char *name = NULL;
>+	char *value = NULL;
>+	size_t size = 0;
>+	int rc = 0;
>+
>+	switch (type) {
>+	case ACL_TYPE_ACCESS:
>+		if (acl) {
>+			rc = posix_acl_update_mode(inode, &inode->i_mode, &acl);
>+			if (rc)
>+				goto out;
>+		}
>+		name = XATTR_NAME_POSIX_ACL_ACCESS;
>+		break;
>+	case ACL_TYPE_DEFAULT:
>+		if (!S_ISDIR(inode->i_mode)) {
>+			rc = acl ? -EACCES : 0;
>+			goto out;
>+		}
>+		name = XATTR_NAME_POSIX_ACL_DEFAULT;
>+		break;
>+	default:
>+		rc = -EINVAL;
>+		goto out;
>+	}
>+
>+	if (acl) {
>+		size = posix_acl_xattr_size(acl->a_count);
>+		value = kmalloc(size, GFP_NOFS);
>+		if (!value) {
>+			rc = -ENOMEM;
>+			goto out;
>+		}
>+
>+		rc = posix_acl_to_xattr(&init_user_ns, acl, value, size);
>+		if (rc < 0)
>+			goto out_free;
>+	}
>+
>+	/* dentry is only used for *.lov attributes so it's safe to be NULL */
>+	rc = __vfs_setxattr(NULL, inode, name, value, size, XATTR_CREATE);
>+out_free:
>+	kfree(value);
>+out:
>+	if (!rc)
>+		set_cached_acl(inode, type, acl);
>+	else
>+		forget_cached_acl(inode, type);
>+	return rc;
>+}
>+#endif /* CONFIG_FS_POSIX_ACL */
>+
> int ll_inode_permission(struct inode *inode, int mask)
> {
> 	struct ll_sb_info *sbi;
>@@ -3162,6 +3217,9 @@ int ll_inode_permission(struct inode *inode, int mask)
> 	.listxattr	= ll_listxattr,
> 	.fiemap		= ll_fiemap,
> 	.get_acl	= ll_get_acl,
>+#ifdef CONFIG_FS_POSIX_ACL
>+	.set_acl	= ll_set_acl,
>+#endif
> };
> 
> /* dynamic ioctl number support routines */
>diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
>index cd3311a..b3374bc 100644
>--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
>+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
>@@ -752,6 +752,10 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
> int ll_getattr(const struct path *path, struct kstat *stat,
> 	       u32 request_mask, unsigned int flags);
> struct posix_acl *ll_get_acl(struct inode *inode, int type);
>+#ifdef CONFIG_FS_POSIX_ACL
>+int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type);
>+#endif /* CONFIG_FS_POSIX_ACL */
>+
> int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
> 	       const char *name, int namelen);
> int ll_get_fid_by_name(struct inode *parent, const char *name,
>diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
>index a208a8b..14dccbe 100644
>--- a/drivers/staging/lustre/lustre/llite/namei.c
>+++ b/drivers/staging/lustre/lustre/llite/namei.c
>@@ -1187,6 +1187,9 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
> 	.permission	 = ll_inode_permission,
> 	.listxattr	  = ll_listxattr,
> 	.get_acl	    = ll_get_acl,
>+#ifdef CONFIG_FS_POSIX_ACL
>+	.set_acl	= ll_set_acl,
>+#endif
> };
> 
> const struct inode_operations ll_special_inode_operations = {
>@@ -1195,4 +1198,7 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
> 	.permission     = ll_inode_permission,
> 	.listxattr      = ll_listxattr,
> 	.get_acl	    = ll_get_acl,
>+#ifdef CONFIG_FS_POSIX_ACL
>+	.set_acl	= ll_set_acl,
>+#endif
> };
>-- 
>1.8.3.1
>
>_______________________________________________
>lustre-devel mailing list
>lustre-devel at lists.lustre.org
>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
