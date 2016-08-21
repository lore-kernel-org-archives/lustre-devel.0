From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 Aug 2016 11:45:07 +0200
Subject: [lustre-devel] [PATCH] staging/lustre/llite: Use memdup_user()
 rather than duplicating its implementation
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Message-ID: <73da135c-be81-e915-9b7a-6773e730b4e7@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Fan Yong <fan.yong@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Oleg Drokin <oleg.drokin@intel.com>, wang di <di.wang@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Nicolas Palix <nicolas.palix@imag.fr>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 Aug 2016 11:30:57 +0200

Reuse existing functionality from memdup_user() instead of keeping
duplicate source code.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/llite/dir.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 031c9e4..8b70e42 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1676,14 +1676,9 @@ out_poll:
 	case LL_IOC_QUOTACTL: {
 		struct if_quotactl *qctl;
 
-		qctl = kzalloc(sizeof(*qctl), GFP_NOFS);
-		if (!qctl)
-			return -ENOMEM;
-
-		if (copy_from_user(qctl, (void __user *)arg, sizeof(*qctl))) {
-			rc = -EFAULT;
-			goto out_quotactl;
-		}
+		qctl = memdup_user((void __user *)arg, sizeof(*qctl));
+		if (IS_ERR(qctl))
+			return PTR_ERR(qctl);
 
 		rc = quotactl_ioctl(sbi, qctl);
 
@@ -1691,7 +1686,6 @@ out_poll:
 					    sizeof(*qctl)))
 			rc = -EFAULT;
 
-out_quotactl:
 		kfree(qctl);
 		return rc;
 	}
-- 
2.9.3
