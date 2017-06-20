From: simran singhal <singhalsimran0@gmail.com>
Date: Tue, 20 Jun 2017 14:36:37 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: selftest: Change the
 type of variable to bool
Message-ID: <20170620090637.GA15837@singhal-Inspiron-5558>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patch changes the type of variable done from int to boolean. As it
is been used as a boolean in the function sfw_test_rpc_done(). It also
makes the code more readable and bool data type also requires less
memory in comparison to int data type.

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index ef27bff..3789df6 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -869,7 +869,7 @@ sfw_test_rpc_done(struct srpc_client_rpc *rpc)
 {
 	struct sfw_test_unit *tsu = rpc->crpc_priv;
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
-	int done = 0;
+	bool done = false;
 
 	tsi->tsi_ops->tso_done_rpc(tsu, rpc);
 
@@ -883,7 +883,7 @@ sfw_test_rpc_done(struct srpc_client_rpc *rpc)
 	/* batch is stopping or loop is done or get error */
 	if (tsi->tsi_stopping || !tsu->tsu_loop ||
 	    (rpc->crpc_status && tsi->tsi_stoptsu_onerr))
-		done = 1;
+		done = true;
 
 	/* dec ref for poster */
 	srpc_client_rpc_decref(rpc);
-- 
2.7.4
