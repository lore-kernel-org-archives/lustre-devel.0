From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:59:53 +0800
Subject: [lustre-devel] [PATCH 0935/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115953.12347-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, john.hammond@intel.com, bhumirks@gmail.com, james.a.nunez@intel.com, arnd@arndb.de, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 30e4f71..3708ff5 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -46,11 +46,11 @@
 lst_sid_t LST_INVALID_SID = {LNET_NID_ANY, -1};
 
 static int session_timeout = 100;
-module_param(session_timeout, int, 0444);
+module_param(session_timeout, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(session_timeout, "test session timeout in seconds (100 by default, 0 == never)");
 
 static int rpc_timeout = 64;
-module_param(rpc_timeout, int, 0644);
+module_param(rpc_timeout, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rpc_timeout, "rpc timeout in seconds (64 by default, 0 == never)");
 
 #define sfw_unpack_id(id)		\
-- 
2.9.2
