From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:57 -0400
Subject: [lustre-devel] [PATCH 10/29] staging: lustre: libcfs: test if
	userland data is to small
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

Ensure that user land data is at least the smallest size.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lnet/libcfs/linux/linux-module.c        |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 35e2fcf..ae05895 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -73,6 +73,11 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 		return -EINVAL;
 	}
 
+	if (hdr.ioc_len < sizeof(struct libcfs_ioctl_data)) {
+		CERROR("libcfs ioctl: user buffer too small for ioctl\n");
+		return -EINVAL;
+	}
+
 	if (hdr.ioc_len > LIBCFS_IOC_DATA_MAX) {
 		CERROR("libcfs ioctl: user buffer is too large %d/%d\n",
 		       hdr.ioc_len, LIBCFS_IOC_DATA_MAX);
-- 
1.7.1
