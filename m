From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 26 Aug 2017 09:04:18 +0300
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: obdclass: return
 -EFAULT if copy_from_user() fails
Message-ID: <20170826060418.quvhtwbayenb7a5j@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The copy_from_user() function returns the number of bytes which we
weren't able to copy.  We don't want to return that to the user but
instead we want to return -EFAULT.

Fixes: d7e09d0397e8 ("staging: add Lustre file system client support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 57c84e8e1d8e..545358923271 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -180,7 +180,8 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 			err = -ENOMEM;
 			goto out;
 		}
-		err = copy_from_user(lcfg, data->ioc_pbuf1, data->ioc_plen1);
+		if (copy_from_user(lcfg, data->ioc_pbuf1, data->ioc_plen1))
+			err = -EFAULT;
 		if (!err)
 			err = lustre_cfg_sanity_check(lcfg, data->ioc_plen1);
 		if (!err)
