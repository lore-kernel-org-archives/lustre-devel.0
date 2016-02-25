From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:22 -0500
Subject: [lustre-devel] [PATCH v2 39/84] staging/lustre: MAY_NOT_BLOCK is
	always defined, don't check for it.
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-40-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index bbe6ebf..ba65fc0 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3071,10 +3071,8 @@ int ll_inode_permission(struct inode *inode, int mask)
 {
 	int rc = 0;
 
-#ifdef MAY_NOT_BLOCK
 	if (mask & MAY_NOT_BLOCK)
 		return -ECHILD;
-#endif
 
        /* as root inode are NOT getting validated in lookup operation,
 	* need to do it before permission check. */
-- 
2.1.0
