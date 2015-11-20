From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:13 -0500
Subject: [lustre-devel] [PATCH 37/40] staging: lustre: remove unnecessary
	NULL check in IOC_LIBCFS_GET_NET
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

In LNetCtl():IOC_LIBCFS_GET_NET there is a check for config == NULL
This is not necessary as it'll never be NULL.  That's ensured before
the call to LNetCtl.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6502
Reviewed-on: http://review.whamcloud.com/15779
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 7f5e0e8..6373de0 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1931,7 +1931,7 @@ LNetCtl(unsigned int cmd, void *arg)
 
 		net_config = (struct lnet_ioctl_net_config *)
 				config->cfg_bulk;
-		if (!config || !net_config)
+		if (!net_config)
 			return -1;
 
 		return lnet_get_net_config(config->cfg_count,
-- 
1.7.1
