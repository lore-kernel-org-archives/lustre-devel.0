From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:57 -0500
Subject: [lustre-devel] [PATCH 29/60] staging: lustre: llite: Setting xattr
	are properly checked with and without ACLs
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Setting extended attributes permissions are properly checked with and
without ACLs. In user.* namespace, only regular files and directories
can have extended attributes. For sticky directories, only the owner
and privileged user can write attributes.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1482
Reviewed-on: http://review.whamcloud.com/21496
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 7a848eb..421cc04 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -132,6 +132,15 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 	    (!strcmp(name, "ima") || !strcmp(name, "evm")))
 		return -EOPNOTSUPP;
 
+	/*
+	 * In user.* namespace, only regular files and directories can have
+	 * extended attributes.
+	 */
+	if (handler->flags == XATTR_USER_T) {
+		if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
+			return -EPERM;
+	}
+
 	sprintf(fullname, "%s%s\n", handler->prefix, name);
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
 			 valid, fullname, pv, size, 0, flags,
-- 
1.8.3.1
