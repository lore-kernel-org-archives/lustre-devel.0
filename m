From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:54 -0400
Subject: [lustre-devel] [PATCH 07/29] staging: lustre: libcfs: test if data
	is NULL
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

Make sure data is not NULL otherwise we get an oops
when using the IOC_LIBCFS_MARK_DEBUG ioctl.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 4c3fe87..cce6ce3 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -150,7 +150,7 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 	 * Handled in arch/cfs_module.c
 	 */
 	case IOC_LIBCFS_MARK_DEBUG:
-		if (!data->ioc_inlbuf1 ||
+		if (!data || !data->ioc_inlbuf1 ||
 		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0') {
 			err = -EINVAL;
 			goto out;
-- 
1.7.1
