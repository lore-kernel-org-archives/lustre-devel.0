From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:55 -0400
Subject: [lustre-devel] [PATCH 08/29] staging: lustre: libcfs: invert test
	condition for libcfs_ioctl
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

Invert the test of error returned by the handle_ioctl pointer.
This reduces the code by one indentation level.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index cce6ce3..97fc905 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -165,12 +165,13 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 		down_read(&ioctl_list_sem);
 		list_for_each_entry(hand, &ioctl_list, item) {
 			err = hand->handle_ioctl(cmd, hdr);
-			if (err != -EINVAL) {
-				if (err == 0)
-					err = libcfs_ioctl_popdata(arg,
-							hdr, hdr->ioc_len);
-				break;
-			}
+			if (err == -EINVAL)
+				continue;
+
+			if (!err)
+				err = libcfs_ioctl_popdata(arg, hdr,
+							   hdr->ioc_len);
+			break;
 		}
 		up_read(&ioctl_list_sem);
 		break; }
-- 
1.7.1
