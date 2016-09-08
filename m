From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Thu, 08 Sep 2016 08:48:48 -0000
Subject: [lustre-devel] [PATCH] staging/lustre/lov: add missing header
	dependencies
Message-ID: <1473324508-9294-1-git-send-email-baoyou.xie@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, bobijam.xu@intel.com, jinshan.xiong@intel.com, lai.siyao@intel.com, mike.rapoport@gmail.com, amitoj1606@gmail.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn

We get 1 warning when building kernel with W=1:
drivers/staging/lustre/lustre/lov/lov_object.c:956:23: warning: no previous prototype for 'lov_lsm_get' [-Wmissing-prototypes]
drivers/staging/lustre/lustre/lov/lov_object.c:972:6: warning: no previous prototype for 'lov_lsm_put' [-Wmissing-prototypes]
drivers/staging/lustre/lustre/lov/lov_object.c:979:5: warning: no previous prototype for 'lov_read_and_clear_async_rc' [-Wmissing-prototypes]

In fact, these functions are declared in ../llite/vvp_internal.h,
so this patch add missing header dependencies.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/staging/lustre/lustre/lov/lov_object.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index f9621b0..912c416 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -38,6 +38,7 @@
 #define DEBUG_SUBSYSTEM S_LOV
 
 #include "lov_cl_internal.h"
+#include "../llite/vvp_internal.h"
 
 /** \addtogroup lov
  *  @{
-- 
2.7.4
