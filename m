From: James Simmons <jsimmons@infradead.org>
Date: Fri,  4 Mar 2016 21:09:47 -0500
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: add last missing
	sparse annotation __user
In-Reply-To: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
References: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457143790-19422-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Frank Zago <fzago@cray.com>

From: Frank Zago <fzago@cray.com>

One of the __user was missed in being applied to upstream
client. This is broken out of patch 11819.

Signed-off-by: Frank Zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
Reviewed-on: http://review.whamcloud.com/11819
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index a666d49..7395985 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2041,7 +2041,7 @@ LNetCtl(unsigned int cmd, void *arg)
 		id.nid = data->ioc_nid;
 		id.pid = data->ioc_u32[0];
 		rc = lnet_ping(id, data->ioc_u32[1], /* timeout */
-			       data->ioc_pbuf1,
+			       (lnet_process_id_t __user *)data->ioc_pbuf1,
 			       data->ioc_plen1 / sizeof(lnet_process_id_t));
 		if (rc < 0)
 			return rc;
-- 
1.7.1
