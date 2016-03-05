From: James Simmons <jsimmons@infradead.org>
Date: Fri,  4 Mar 2016 21:09:45 -0500
Subject: [lustre-devel] [PATCH 05/10] staging: lustre: fix 'data race
	condition' issue in framework.c
In-Reply-To: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
References: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457143790-19422-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>

From: Sebastien Buisson <sbuisson@ddn.com>

Fix 'data race condition' defects found by Coverity version 6.5.0:
Data race condition (MISSING_LOCK)
Accessing variable without holding lock. Elsewhere,
this variable is accessed with lock held.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2744
Reviewed-on: http://review.whamcloud.com/6568
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index dbd2c61..5c7cafa 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -981,9 +981,8 @@ sfw_run_test(swi_workitem_t *wi)
 	list_add_tail(&rpc->crpc_list, &tsi->tsi_active_rpcs);
 	spin_unlock(&tsi->tsi_lock);
 
-	rpc->crpc_timeout = rpc_timeout;
-
 	spin_lock(&rpc->crpc_lock);
+	rpc->crpc_timeout = rpc_timeout;
 	srpc_post_rpc(rpc);
 	spin_unlock(&rpc->crpc_lock);
 	return 0;
-- 
1.7.1
