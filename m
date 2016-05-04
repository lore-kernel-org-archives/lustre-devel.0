From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:28:59 -0400
Subject: [lustre-devel] [PATCH 8/9] staging: lustre: fid: init FID client
	for OSP on MDT.
In-Reply-To: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462372140-27880-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Initialize FID client for OSP on MDT.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3529
Reviewed-on: http://review.whamcloud.com/7158
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_request.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 32e4d95..3a4df62 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -102,10 +102,13 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 			req->rq_no_delay = req->rq_no_resend = 1;
 		debug_mask = D_CONSOLE;
 	} else {
-		if (seq->lcs_type == LUSTRE_SEQ_METADATA)
+		if (seq->lcs_type == LUSTRE_SEQ_METADATA) {
+			req->rq_reply_portal = MDC_REPLY_PORTAL;
 			req->rq_request_portal = SEQ_METADATA_PORTAL;
-		else
+		} else {
+			req->rq_reply_portal = OSC_REPLY_PORTAL;
 			req->rq_request_portal = SEQ_DATA_PORTAL;
+		}
 		debug_mask = D_INFO;
 	}
 
-- 
2.7.4
