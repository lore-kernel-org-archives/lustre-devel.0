From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:56 -0400
Subject: [lustre-devel] [PATCH 09/29] staging: lustre: libcfs: update error
	messages in linux-module.c
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

The error message are for libcfs layer not LNet.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lnet/libcfs/linux/linux-module.c        |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index a326ac6..35e2fcf 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -43,7 +43,7 @@
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
 {
 	if (libcfs_ioctl_is_invalid(data)) {
-		CERROR("LNET: ioctl not correctly formatted\n");
+		CERROR("libcfs ioctl: parameter not correctly formatted\n");
 		return -EINVAL;
 	}
 
@@ -68,7 +68,7 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 
 	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION &&
 	    hdr.ioc_version != LIBCFS_IOCTL_VERSION2) {
-		CERROR("LNET: version mismatch expected %#x, got %#x\n",
+		CERROR("libcfs ioctl: version mismatch expected %#x, got %#x\n",
 		       LIBCFS_IOCTL_VERSION, hdr.ioc_version);
 		return -EINVAL;
 	}
-- 
1.7.1
