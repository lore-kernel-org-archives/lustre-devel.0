From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:58 -0400
Subject: [lustre-devel] [PATCH 11/29] staging: lustre: lnet: make sure lnet
	data not greater than LIBCFS_IOC_DATA_MAX
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

Fail to compile if largest LNet user land data structures passed
to kernel are larger than LIBCFS_IOC_DATA_MAX

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 8764755..f825784 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1864,6 +1864,10 @@ LNetCtl(unsigned int cmd, void *arg)
 	int rc;
 	unsigned long secs_passed;
 
+	BUILD_BUG_ON(LIBCFS_IOC_DATA_MAX <
+		     sizeof(struct lnet_ioctl_net_config) +
+		     sizeof(struct lnet_ioctl_config_data));
+
 	switch (cmd) {
 	case IOC_LIBCFS_GET_NI:
 		rc = LNetGetId(data->ioc_count, &id);
-- 
1.7.1
