From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:15:02 -0400
Subject: [lustre-devel] [PATCH 13/22] staging: lustre: llite: remove newline
 in fullname strings
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

In creating the full name of a xattr a new line was added that
was seen by the remote MDS server which confused it. Remove the
newline.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/27240
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 42a6fb4..4b1e565 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -136,7 +136,7 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 			return -EPERM;
 	}
 
-	fullname = kasprintf(GFP_KERNEL, "%s%s\n", handler->prefix, name);
+	fullname = kasprintf(GFP_KERNEL, "%s%s", handler->prefix, name);
 	if (!fullname)
 		return -ENOMEM;
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
@@ -435,7 +435,7 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	if (handler->flags == XATTR_ACL_DEFAULT_T && !S_ISDIR(inode->i_mode))
 		return -ENODATA;
 #endif
-	fullname = kasprintf(GFP_KERNEL, "%s%s\n", handler->prefix, name);
+	fullname = kasprintf(GFP_KERNEL, "%s%s", handler->prefix, name);
 	if (!fullname)
 		return -ENOMEM;
 	rc = ll_xattr_list(inode, fullname, handler->flags, buffer, size,
-- 
1.8.3.1
