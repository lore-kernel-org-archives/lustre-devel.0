From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:04 -0400
Subject: [lustre-devel] [PATCH 27/45] lustre: ptlrpc: connect to MDT stucks
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

mdc_ioc_hsm_ct_register() is executed on
IMP_EVENT_ACTIVE event.
If HSM_CT_REGISTER request expires import becomes
disconnected but reconnect can't start because
previous connect waits for completion of
HSM_CT_REGISTER request.

Mark HSM_CT_REGISTER request as no_resend.

Cray-bug-id: LUS-8409
WC-bug-id: https://jira.whamcloud.com/browse/LU-13455
Lustre-commit: 3d58403e62b7b ("LU-13455 ptlrpc: connect to MDT stucks")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/38243
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Ben Evans <jevans@cray.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Ben Evans <beevans@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 0cbab8b..369114b 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1845,6 +1845,7 @@ static int mdc_ioc_hsm_ct_register(struct obd_import *imp, u32 archive_count,
 		*archive_array = archive_count;
 
 	ptlrpc_request_set_replen(req);
+	req->rq_no_resend = 1;
 
 	rc = mdc_queue_wait(req);
 out:
-- 
1.8.3.1
