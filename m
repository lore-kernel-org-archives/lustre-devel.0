From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:15 -0400
Subject: [lustre-devel] [PATCH 28/29] staging: lustre: libcfs: use BIT macro
	in linux-module.c
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Use the proper BIT macro for libcfs_ioctl_is_invalid().

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/17643
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lnet/libcfs/linux/linux-module.c        |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index d5b7d3a..cf191ef 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -51,15 +51,15 @@ static inline int libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
 
 static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 {
-	if (data->ioc_hdr.ioc_len > (1 << 30)) {
+	if (data->ioc_hdr.ioc_len > BIT(30)) {
 		CERROR("LIBCFS ioctl: ioc_len larger than 1<<30\n");
 		return true;
 	}
-	if (data->ioc_inllen1 > (1<<30)) {
+	if (data->ioc_inllen1 > BIT(30)) {
 		CERROR("LIBCFS ioctl: ioc_inllen1 larger than 1<<30\n");
 		return true;
 	}
-	if (data->ioc_inllen2 > (1<<30)) {
+	if (data->ioc_inllen2 > BIT(30)) {
 		CERROR("LIBCFS ioctl: ioc_inllen2 larger than 1<<30\n");
 		return true;
 	}
-- 
1.7.1
