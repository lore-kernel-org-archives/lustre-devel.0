From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:15:00 -0400
Subject: [lustre-devel] [PATCH 11/22] staging: lustre: llite: eat -EEXIST on
 setting trusted.lov
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Bobi Jam <bobijam.xu@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Bobi Jam <bobijam.xu@intel.com>

Tools like rsync, tar, cp may copy and restore the xattrs on a file.
The client previously ignored the setting of trusted.lov/lustre.lov
if the layout had already been specified, to avoid causing these
tools to fail for no reason.

For PFL files we still need to silently eat -EEXIST on setting these
attributes to avoid problems.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9484
Reviewed-on: https://review.whamcloud.com/27126
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 56ac07e..69c5227 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -254,12 +254,20 @@ static int ll_setstripe_ea(struct dentry *dentry, struct lov_user_md *lump,
 
 		lum_size = ll_lov_user_md_size(lump);
 		if (lum_size < 0 || size < lum_size)
-			return 0; /* b=10667: ignore error */
+			return -ERANGE;
 
 		rc = ll_lov_setstripe_ea_info(inode, dentry, it_flags, lump,
 					      lum_size);
-		/* b=10667: rc always be 0 here for now */
-		rc = 0;
+		/**
+		 * b=10667: ignore -EEXIST.
+		 * Silently eat error on setting trusted.lov/lustre.lov
+		 * attribute for platforms that added the default option
+		 * to copy all attributes in 'cp' command. Both rsync and
+		 * tar --xattrs also will try to set LOVEA for existing
+		 * files.
+		 */
+		if (rc == -EEXIST)
+			rc = 0;
 	} else if (S_ISDIR(inode->i_mode)) {
 		rc = ll_dir_setstripe(inode, lump, 0);
 	}
-- 
1.8.3.1
