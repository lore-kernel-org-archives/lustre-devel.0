From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Thu, 08 Sep 2016 08:46:34 -0000
Subject: [lustre-devel] [PATCH] staging/lustre/obdclass: add missing header
	dependencies
Message-ID: <1473324367-9172-1-git-send-email-baoyou.xie@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, mhocko@suse.com, james.a.nunez@intel.com, uja.ornl@yahoo.com, arnd@arndb.de, kirill.shutemov@linux.intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn

We get 1 warning when building kernel with W=1:
drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c:157:5: warning: no previous prototype for 'obd_sysctl_init' [-Wmissing-prototypes]

In fact, this function is declared in ../../include/obd_class.h,
so this patch add missing header dependencies.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index 8f70dd2..2daa834 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -45,6 +45,7 @@
 
 #include "../../include/obd_support.h"
 #include "../../include/lprocfs_status.h"
+#include "../../include/obd_class.h"
 
 struct static_lustre_uintvalue_attr {
 	struct {
-- 
2.7.4
