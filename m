From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:09 -0400
Subject: [lustre-devel] [PATCH 22/29] staging: lustre: libcfs: removal all
	userland only macros from libcfs_ioctl.h
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

All the macros in libcfs_ioctl.h that is needed by user
land have been moved into the lustre utilities software
stack.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/17643
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 2e4e31b..e109a4b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -76,21 +76,12 @@ struct libcfs_ioctl_data {
 	char ioc_bulk[0];
 };
 
-#define ioc_priority ioc_u32[0]
-
 struct libcfs_debug_ioctl_data {
 	struct libcfs_ioctl_hdr hdr;
 	unsigned int subs;
 	unsigned int debug;
 };
 
-#define LIBCFS_IOC_INIT(data)			   \
-do {						    \
-	memset(&data, 0, sizeof(data));		 \
-	data.ioc_version = LIBCFS_IOCTL_VERSION;	\
-	data.ioc_len = sizeof(data);		    \
-} while (0)
-
 /* FIXME check conflict with lustre_lib.h */
 #define LIBCFS_IOC_DEBUG_MASK	     _IOWR('f', 250, long)
 
-- 
1.7.1
