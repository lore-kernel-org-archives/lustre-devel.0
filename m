From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:28 -0500
Subject: [lustre-devel] [PATCH 60/60] staging: lustre: libcfs: fix minimum
	size check for libcfs ioctl
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-61-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The check for the smallest ioctl data in libcfs_ioctl_getdata()
is incorrect. Instead of checking against struct libcfs_ioctl_data
compare the size to struct libcfs_ioctl_hdr.

Reported-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 3f5d58b..bda6c16 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -134,7 +134,7 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 		return -EINVAL;
 	}
 
-	if (hdr.ioc_len < sizeof(struct libcfs_ioctl_data)) {
+	if (hdr.ioc_len < sizeof(hdr)) {
 		CERROR("libcfs ioctl: user buffer too small for ioctl\n");
 		return -EINVAL;
 	}
-- 
1.8.3.1
