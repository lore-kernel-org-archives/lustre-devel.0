From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 26 Aug 2017 09:02:55 +0300
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: obdclass: return
 -EFAULT if copy_to_user() fails
Message-ID: <20170826060255.tf4vnkfd4e2rey45@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We recently changed from using obd_ioctl_popdata() to calling
copy_to_user() directly.  This if statement was supposed to be deleted
but it was over looked.  "err" is zero at this point so it means we
return success.

Fixes: b03679f6a41a ("staging: lustre: uapi: remove obd_ioctl_popdata() wrapper")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 57c84e8e1d8e..8ad3adb2ceb1 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -262,7 +262,6 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		       dev);
 
 		if (copy_to_user((void __user *)arg, data, sizeof(*data)))
-		if (err)
 			err = -EFAULT;
 		goto out;
 	}
