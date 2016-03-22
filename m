From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:14 -0400
Subject: [lustre-devel] [PATCH 27/29] staging: lustre: libcfs: return proper
	bool values
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Return real bool values for libcfs_ioctl_is_invalid().

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/17643
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lnet/libcfs/linux/linux-module.c        |   26 ++++++++++----------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index af19f3c..d5b7d3a 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -53,56 +53,56 @@ static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 {
 	if (data->ioc_hdr.ioc_len > (1 << 30)) {
 		CERROR("LIBCFS ioctl: ioc_len larger than 1<<30\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_inllen1 > (1<<30)) {
 		CERROR("LIBCFS ioctl: ioc_inllen1 larger than 1<<30\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_inllen2 > (1<<30)) {
 		CERROR("LIBCFS ioctl: ioc_inllen2 larger than 1<<30\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
 		CERROR("LIBCFS ioctl: inlbuf1 pointer but 0 length\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_inlbuf2 && !data->ioc_inllen2) {
 		CERROR("LIBCFS ioctl: inlbuf2 pointer but 0 length\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_pbuf1 && !data->ioc_plen1) {
 		CERROR("LIBCFS ioctl: pbuf1 pointer but 0 length\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_pbuf2 && !data->ioc_plen2) {
 		CERROR("LIBCFS ioctl: pbuf2 pointer but 0 length\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_plen1 && !data->ioc_pbuf1) {
 		CERROR("LIBCFS ioctl: plen1 nonzero but no pbuf1 pointer\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_plen2 && !data->ioc_pbuf2) {
 		CERROR("LIBCFS ioctl: plen2 nonzero but no pbuf2 pointer\n");
-		return 1;
+		return true;
 	}
 	if ((__u32)libcfs_ioctl_packlen(data) != data->ioc_hdr.ioc_len) {
 		CERROR("LIBCFS ioctl: packlen != ioc_len\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_inllen1 &&
 	    data->ioc_bulk[data->ioc_inllen1 - 1] != '\0') {
 		CERROR("LIBCFS ioctl: inlbuf1 not 0 terminated\n");
-		return 1;
+		return true;
 	}
 	if (data->ioc_inllen2 &&
 	    data->ioc_bulk[cfs_size_round(data->ioc_inllen1) +
 			   data->ioc_inllen2 - 1] != '\0') {
 		CERROR("LIBCFS ioctl: inlbuf2 not 0 terminated\n");
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
-- 
1.7.1
