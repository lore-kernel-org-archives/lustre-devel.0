From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:57 -0500
Subject: [lustre-devel] [PATCH 14/27] staging: lustre: fix conctl.c issues
	found by Klocwork Insight tool
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>

From: Dmitry Eremin <dmitry.eremin@intel.com>

The function lst_test_add_ioctl is always copying lstio_tes_param
from userland even if the user doesn't send this data to LNet
selftest. Only consider lstio_tes_param data if lstio_tes_param_len
is not zero.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4629
Reviewed-on: http://review.whamcloud.com/9386
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/selftest/conctl.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 90b7771..714d14b 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -761,6 +761,11 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		LIBCFS_ALLOC(param, args->lstio_tes_param_len);
 		if (!param)
 			goto out;
+		if (copy_from_user(param, args->lstio_tes_param,
+				   args->lstio_tes_param_len)) {
+			rc = -EFAULT;
+			goto out;
+		}
 	}
 
 	rc = -EFAULT;
@@ -769,9 +774,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	    copy_from_user(src_name, args->lstio_tes_sgrp_name,
 			   args->lstio_tes_sgrp_nmlen) ||
 	    copy_from_user(dst_name, args->lstio_tes_dgrp_name,
-			   args->lstio_tes_dgrp_nmlen) ||
-	    copy_from_user(param, args->lstio_tes_param,
-			   args->lstio_tes_param_len))
+			   args->lstio_tes_dgrp_nmlen))
 		goto out;
 
 	rc = lstcon_test_add(batch_name, args->lstio_tes_type,
-- 
1.7.1
