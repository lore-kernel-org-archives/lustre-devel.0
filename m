From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:32 -0400
Subject: [lustre-devel] [PATCH 16/20] staging: lustre: libcfs: fix test for
	libcfs_ioctl_hdr minimum size
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

The function libcfs_ioctl_getdata() test to see if libcfs_ioctl_hdr
is smaller than struct libcfs_ioctl_data in size. This is wrong
and it breaks the ioctl that is used to collect LNet stats. The
correct size to compare against is struct libcfs_ioctl_hdr.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5935
Reviewed-on: http://review.whamcloud.com/12782
Fixes: ed2f549dc0f6 ("staging: lustre: libcfs: test if userland data is to small")
Reported-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 075826b..c6837bc 100644
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
