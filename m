From: Colin King <colin.king@canonical.com>
Date: Fri, 11 May 2018 14:38:59 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: fix spelling mistake:
 "req_ulinked" -> "req_unlinked"
Message-ID: <20180511133859.18733-1-colin.king@canonical.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in DEBUG_REQ message text

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index eeb281266413..a51feaeb7734 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2514,7 +2514,7 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 		}
 
 		DEBUG_REQ(D_WARNING, request,
-			  "Unexpectedly long timeout receiving_reply=%d req_ulinked=%d reply_unlinked=%d",
+			  "Unexpectedly long timeout receiving_reply=%d req_unlinked=%d reply_unlinked=%d",
 			  request->rq_receiving_reply,
 			  request->rq_req_unlinked,
 			  request->rq_reply_unlinked);
-- 
2.17.0
