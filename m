From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 22 Feb 2018 12:15:34 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: selftest: freeing an error
 pointer
Message-ID: <20180222091534.GD9883@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We should just return directly if memdup_user() fails. The current code
tries to free "param" which is an error pointer so it will Oops.

Fixes: 2baddf262e98 ("staging: lustre: use memdup_user to allocate memory and copy from user")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 3c919a536e91..51497cf9a832 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -650,10 +650,8 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
 	if (args->lstio_tes_param) {
 		param = memdup_user(args->lstio_tes_param,
 				    args->lstio_tes_param_len);
-		if (IS_ERR(param)) {
-			rc = PTR_ERR(param);
-			goto out;
-		}
+		if (IS_ERR(param))
+			return PTR_ERR(param);
 	}
 
 	rc = -EFAULT;
