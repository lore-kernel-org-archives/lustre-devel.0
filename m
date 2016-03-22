From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:53 -0400
Subject: [lustre-devel] [PATCH 06/29] staging: lustre: libcfs: move comment
	in libcfs_ioctl
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

Move the comment about libcfs_ioctl_data_adjust to the
section where libcfs_ioctl_data_adjust is actually called.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index b7575af..4c3fe87 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -127,13 +127,13 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 		return err;
 	}
 
-	/*
-	 * The libcfs_ioctl_data_adjust() function performs adjustment
-	 * operations on the libcfs_ioctl_data structure to make
-	 * it usable by the code.  This doesn't need to be called
-	 * for new data structures added.
-	 */
 	if (hdr->ioc_version == LIBCFS_IOCTL_VERSION) {
+		/*
+		 * The libcfs_ioctl_data_adjust() function performs adjustment
+		 * operations on the libcfs_ioctl_data structure to make
+		 * it usable by the code.  This doesn't need to be called
+		 * for new data structures added.
+		 */
 		data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
 		err = libcfs_ioctl_data_adjust(data);
 		if (err)
-- 
1.7.1
