From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 16 Nov 2016 20:05:30 -0500
Subject: [lustre-devel] [PATCH 2/2] staging/lustre/ptlrpc: update
	imp_known_replied_xid on resend-replay
In-Reply-To: <1479344730-1131617-1-git-send-email-green@linuxhacker.ru>
References: <1479344730-1131617-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1479344730-1131617-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Niu Yawei <yawei.niu@intel.com>

The imp_known_replied_xid should be updated when try to resend
an already replied replay request, because the xid of this replay
request could be less than current imp_known_replied_xid.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-on: http://review.whamcloud.com/22776
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8645
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/recover.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 344aedd..c004490 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -161,8 +161,10 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	 * unreplied list.
 	 */
 	if (req && imp->imp_resend_replay &&
-	    list_empty(&req->rq_unreplied_list))
+	    list_empty(&req->rq_unreplied_list)) {
 		ptlrpc_add_unreplied(req);
+		imp->imp_known_replied_xid = ptlrpc_known_replied_xid(imp);
+	}
 
 	imp->imp_resend_replay = 0;
 	spin_unlock(&imp->imp_lock);
-- 
2.7.4
