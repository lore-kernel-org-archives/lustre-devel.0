From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 26 Aug 2017 09:04:46 +0300
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: obdclass: fix checking
 for obd_init_checks()
Message-ID: <20170826060446.ezohk7527vuphcy7@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Evans <bevans@cray.com>, Baoyou Xie <baoyou.xie@linaro.org>, Stephen Champion <schamp@sgi.com>, frank zago <fzago@cray.com>, Henri Doreau <henri.doreau@cea.fr>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

The obd_init_checks() function can either return -EOVERFLOW or -EINVAL
but we accidentally ignore -EINVAL returns.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This patch is the right thing, but it's always a bit risky turning on
new checks and I haven't tested this.

diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 545358923271..2df218b010e1 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -448,7 +448,7 @@ static int __init obdclass_init(void)
 	obd_zombie_impexp_init();
 
 	err = obd_init_checks();
-	if (err == -EOVERFLOW)
+	if (err)
 		return err;
 
 	class_init_uuidlist();
