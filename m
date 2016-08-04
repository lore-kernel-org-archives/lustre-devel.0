From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:54 -0400
Subject: [lustre-devel] [PATCH 18/32] staging: lustre: mdc: always use
	D_INFO for debug info when mdc_put_rpc_lock fails
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Also use D_INFO no matter what the error returned from
mdc_put_rpc_lock.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4973
Reviewed-on: http://review.whamcloud.com/10150
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 551f3d9..3291201 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -841,9 +841,8 @@ resend:
 	mdc_put_rpc_lock(obddev->u.cli.cl_rpc_lock, it);
 
 	if (rc < 0) {
-		CDEBUG_LIMIT((rc == -EACCES || rc == -EIDRM) ? D_INFO : D_ERROR,
-			     "%s: ldlm_cli_enqueue failed: rc = %d\n",
-			     obddev->obd_name, rc);
+		CDEBUG(D_INFO, "%s: ldlm_cli_enqueue failed: rc = %d\n",
+		       obddev->obd_name, rc);
 
 		mdc_clear_replay_flag(req, rc);
 		ptlrpc_req_finished(req);
-- 
1.7.1
