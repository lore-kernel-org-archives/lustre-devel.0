From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:01 -0400
Subject: [lustre-devel] [PATCH 14/29] staging: lustre: libcfs: remove
	libcfsutil.h in comment
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <uja.ornl@gmail.com>

From: John L. Hammond <john.hammond@intel.com>

The header libcfsutil.h has been long gone in the upstream
client. Replace libcfsutil.h reference to the current user
land header instead.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/14180
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 9c1deae..01bf8d6 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -34,7 +34,7 @@
  * libcfs/include/libcfs/libcfs_ioctl.h
  *
  * Low-level ioctl data structures. Kernel ioctl functions declared here,
- * and user space functions are in libcfsutil_ioctl.h.
+ * and user space functions are in libcfs/util/ioctl.h.
  *
  */
 
-- 
1.7.1
