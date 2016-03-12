From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:49 -0500
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: test for proper errno
	code in lstcon_rpc_trans_abort
In-Reply-To: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457746191-27981-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The error value returned will be -ETIMEDOUT not ETIMEDOUT. This fixes
a typo that prevents us from handling the error case.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 9401e1a..db5a0dc 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -313,7 +313,7 @@ lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error)
 
 		sfw_abort_rpc(rpc);
 
-		if (error != ETIMEDOUT)
+		if (error != -ETIMEDOUT)
 			continue;
 
 		nd = crpc->crp_node;
-- 
1.7.1
