From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:41 -0400
Subject: [lustre-devel] [PATCH v2 2/6] staging: lustre: llite: add support
 set_acl method in inode operations
In-Reply-To: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
References: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603705-30450-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Linux kernel v3.14 adds set_acl method to inode operations.
This patch adds support to Lustre for proper acl management.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/25965
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10541
Reviewed-on: https://review.whamcloud.com/31588
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10926
Reviewed-on: https://review.whamcloud.com/32045
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) Initial ported patch

v2) Updated patch with fixes that address issues pointed out by
   Can Carpenter

v3) Rebased to contain new code in acl.c

 drivers/staging/lustre/lustre/llite/acl.c          | 57 ++++++++++++++++++++++
 .../staging/lustre/lustre/llite/llite_internal.h   |  2 +
 2 files changed, 59 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/acl.c b/drivers/staging/lustre/lustre/llite/acl.c
index d7c3bf9..de1499b 100644
--- a/drivers/staging/lustre/lustre/llite/acl.c
+++ b/drivers/staging/lustre/lustre/llite/acl.c
@@ -49,3 +49,60 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
 
 	return acl;
 }
+
+int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct ptlrpc_request *req = NULL;
+	const char *name = NULL;
+	size_t value_size = 0;
+	char *value = NULL;
+	int rc = 0;
+
+	switch (type) {
+	case ACL_TYPE_ACCESS:
+		name = XATTR_NAME_POSIX_ACL_ACCESS;
+		if (acl)
+			rc = posix_acl_update_mode(inode, &inode->i_mode, &acl);
+		break;
+
+	case ACL_TYPE_DEFAULT:
+		name = XATTR_NAME_POSIX_ACL_DEFAULT;
+		if (!S_ISDIR(inode->i_mode))
+			rc = acl ? -EACCES : 0;
+		break;
+
+	default:
+		rc = -EINVAL;
+		break;
+	}
+	if (rc)
+		return rc;
+
+	if (acl) {
+		value_size = posix_acl_xattr_size(acl->a_count);
+		value = kmalloc(value_size, GFP_NOFS);
+		if (!value) {
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		rc = posix_acl_to_xattr(&init_user_ns, acl, value, value_size);
+		if (rc < 0)
+			goto out_value;
+	}
+
+	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
+			 value ? OBD_MD_FLXATTR : OBD_MD_FLXATTRRM,
+			 name, value, value_size, 0, 0, 0, &req);
+
+	ptlrpc_req_finished(req);
+out_value:
+	kfree(value);
+out:
+	if (rc)
+		forget_cached_acl(inode, type);
+	else
+		set_cached_acl(inode, type, acl);
+	return rc;
+}
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index bdb1564..c08a6e1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -756,8 +756,10 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 	       u32 request_mask, unsigned int flags);
 #ifdef CONFIG_FS_POSIX_ACL
 struct posix_acl *ll_get_acl(struct inode *inode, int type);
+int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type);
 #else
 #define ll_get_acl NULL
+#define ll_set_acl NULL
 #endif /* CONFIG_FS_POSIX_ACL */
 
 int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
-- 
1.8.3.1
