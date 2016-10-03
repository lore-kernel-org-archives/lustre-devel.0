From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:04 -0400
Subject: [lustre-devel] [PATCH 08/41] staging: lustre: ptlrpc: ret
	-ECONNREFUSED if not context found in req
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sebastien.buisson@bull.net>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sebastien.buisson@bull.net>

Return -ECONNREFUSED instead of -ENOMEM in sptlrpc_req_get_ctx()
if no context is found in req. It is more graceful.

Signed-off-by: Sebastien Buisson <sebastien.buisson@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6356
Reviewed-on: http://review.whamcloud.com/14043
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/sec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 5d3995d..1457a6e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -379,7 +379,7 @@ int sptlrpc_req_get_ctx(struct ptlrpc_request *req)
 
 	if (!req->rq_cli_ctx) {
 		CERROR("req %p: fail to get context\n", req);
-		return -ENOMEM;
+		return -ECONNREFUSED;
 	}
 
 	return 0;
-- 
1.7.1
