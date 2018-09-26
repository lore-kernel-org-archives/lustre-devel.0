From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:10 -0400
Subject: [lustre-devel] [PATCH 18/25] lustre: lnd: Turn on 2 sges by default
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Doug Oucharek <dougso@me.com>

Currently, the fix in LU-5718 which allows for multiple sges
to deal with RDMA fragmentation is turned off by default
(set to 1). This patch changes the default to 2 so
RDMA fragmentation is fixed by default.

Signed-off-by: Doug Oucharek <dougso@me.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9425
Reviewed-on: https://review.whamcloud.com/26911
Reviewed-by: Ned Bass <bass6@llnl.gov>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 891708e..3bb537e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -147,7 +147,7 @@
 module_param(use_privileged_port, int, 0644);
 MODULE_PARM_DESC(use_privileged_port, "use privileged port when initiating connection");
 
-static unsigned int wrq_sge = 1;
+static unsigned int wrq_sge = 2;
 module_param(wrq_sge, uint, 0444);
 MODULE_PARM_DESC(wrq_sge, "# scatter/gather element per work request");
 
-- 
1.8.3.1
