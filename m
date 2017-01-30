From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 30 Jan 2017 13:51:49 +0300
Subject: [lustre-devel] [patch] staging: lustre: libcfs: double copy bug
Message-ID: <20170130105149.GA14399@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The problem is that we copy hdr.ioc_len, we verify it, then we copy it
again without checking to see if it has changed in between the two
copies.

This could result in an information leak.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 3f5d58babc2f..075826bd3a2a 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -122,7 +122,7 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 			 const struct libcfs_ioctl_hdr __user *uhdr)
 {
 	struct libcfs_ioctl_hdr hdr;
-	int err = 0;
+	int err;
 
 	if (copy_from_user(&hdr, uhdr, sizeof(hdr)))
 		return -EFAULT;
@@ -150,9 +150,20 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 		return -ENOMEM;
 
 	if (copy_from_user(*hdr_pp, uhdr, hdr.ioc_len)) {
-		LIBCFS_FREE(*hdr_pp, hdr.ioc_len);
 		err = -EFAULT;
+		goto free;
 	}
+
+	if ((*hdr_pp)->ioc_version != hdr.ioc_version ||
+	    (*hdr_pp)->ioc_len != hdr.ioc_len) {
+		err = -EINVAL;
+		goto free;
+	}
+
+	return 0;
+
+free:
+	LIBCFS_FREE(*hdr_pp, hdr.ioc_len);
 	return err;
 }
 
