From: Aleksei Fedotov <lexa@cfotr.com>
Date: Tue, 12 Apr 2016 14:05:49 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: libcfs: Fix libcfs_ioctl()
	prototype.
Message-ID: <1460459149-20699-1-git-send-email-lexa@cfotr.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Aleksei Fedotov <lexa@cfotr.com>

Fix libcfs_ioctl() prototype according to its definition in
libcfs/module.c.

Signed-off-by: Aleksei Fedotov <lexa@cfotr.com>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 9158c61..4141afb 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -106,7 +106,7 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 			 const struct libcfs_ioctl_hdr __user *uparam);
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
-int libcfs_ioctl(unsigned long cmd, void *arg);
+int libcfs_ioctl(unsigned long cmd, void __user *arg);
 
 /* container_of depends on "likely" which is defined in libcfs_private.h */
 static inline void *__container_of(void *ptr, unsigned long shift)
-- 
2.5.5
