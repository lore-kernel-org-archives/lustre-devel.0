From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:14:55 -0400
Subject: [lustre-devel] [PATCH 06/22] staging: lustre: llite: Remove
 filtering of seclabel xattr
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Robin Humble <plaguedbypenguins@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Robin Humble <plaguedbypenguins@gmail.com>

The security.capability xattr is used to implement File
Capabilities in recent Linux versions. Capabilities are a
fine grained approach to granting executables elevated
privileges. eg. /bin/ping can have capabilities
cap_net_admin, cap_net_raw+ep instead of being setuid root.

This xattr has long been filtered out by llite, initially for
stability reasons (b15587), and later over performance
concerns as this xattr is read for every file with eg.
'ls --color'. Since LU-2869 xattr's are cached on clients,
alleviating most performance concerns.

Removing llite's filtering of the security.capability xattr
enables using Lustre as a root filesystem, which is used on
some large clusters.

Signed-off-by: Robin Humble <plaguedbypenguins@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9562
Reviewed-on: https://review.whamcloud.com/27292
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 2d78432..55a19a5 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -117,11 +117,6 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 	     (handler->flags == XATTR_LUSTRE_T && !strcmp(name, "lov"))))
 		return 0;
 
-	/* b15587: ignore security.capability xattr for now */
-	if ((handler->flags == XATTR_SECURITY_T &&
-	     !strcmp(name, "capability")))
-		return 0;
-
 	/* LU-549:  Disable security.selinux when selinux is disabled */
 	if (handler->flags == XATTR_SECURITY_T && !selinux_is_enabled() &&
 	    strcmp(name, "selinux") == 0)
@@ -383,10 +378,6 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	if (rc)
 		return rc;
 
-	/* b15587: ignore security.capability xattr for now */
-	if ((handler->flags == XATTR_SECURITY_T && !strcmp(name, "capability")))
-		return -ENODATA;
-
 	/* LU-549:  Disable security.selinux when selinux is disabled */
 	if (handler->flags == XATTR_SECURITY_T && !selinux_is_enabled() &&
 	    !strcmp(name, "selinux"))
-- 
1.8.3.1
