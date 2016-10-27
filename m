From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:52 -0400
Subject: [lustre-devel] [PATCH 18/29] staging: lustre: mdt: disable IMA
	support
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Hongchao Zhang <hongchao.zhang@intel.com>, James Simmons <jsimmons@infradead.org>

From: Hongchao Zhang <hongchao.zhang@intel.com>

For IMA (Integrity Measurement Architecture), there are two xattr
"security.ima" and "security.evm" to protect the file to be modified
accidentally or maliciously, the two xattr are not compatible with
VBR, then disable it to workaround the problem currently and enable
it when the conditions are ready.

Signed-off-by: Hongchao Zhang <hongchao.zhang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6455
Reviewed-on: http://review.whamcloud.com/14928
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 3ae1a02..ea3becc 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -126,6 +126,11 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 	    strcmp(name, "selinux") == 0)
 		return -EOPNOTSUPP;
 
+	/*FIXME: enable IMA when the conditions are ready */
+	if (handler->flags == XATTR_SECURITY_T &&
+	    (!strcmp(name, "ima") || !strcmp(name, "evm")))
+		return -EOPNOTSUPP;
+
 	sprintf(fullname, "%s%s\n", handler->prefix, name);
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
 			 valid, fullname, pv, size, 0, flags,
-- 
1.7.1
