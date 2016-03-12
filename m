From: James Simmons <jsimmons@infradead.org>
Date: Sat, 12 Mar 2016 13:00:34 -0500
Subject: [lustre-devel] [PATCH 4/6] staging: lustre: remove excess blank
	lines in lnet selftest code
In-Reply-To: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
References: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457805636-23859-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove extra blank lines missed by checkpatch.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c |    2 --
 drivers/staging/lustre/lnet/selftest/conrpc.c   |    2 --
 drivers/staging/lustre/lnet/selftest/console.c  |    2 --
 3 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index eebc924..69812fc 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -91,7 +91,6 @@ brw_client_init(sfw_test_instance_t *tsi)
 		 * but we have to keep it for compatibility
 		 */
 		len = npg * PAGE_CACHE_SIZE;
-
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
 
@@ -279,7 +278,6 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 		flags = breq->blk_flags;
 		npg = breq->blk_npg;
 		len = npg * PAGE_CACHE_SIZE;
-
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
 
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index bcd7888..d11869a 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -531,7 +531,6 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 			continue;
 
 		error = readent(trans->tas_opc, msg, ent);
-
 		if (error)
 			return error;
 	}
@@ -841,7 +840,6 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 
 		trq->tsr_ndest = 0;
 		trq->tsr_loop = nmax * test->tes_dist * test->tes_concur;
-
 	} else {
 		bulk = &(*crpc)->crp_rpc->crpc_bulk;
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index c009ad3..17d0d13 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -977,7 +977,6 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 	if (!test) {
 		entp->u.tbe_batch.bae_ntest = bat->bat_ntest;
 		entp->u.tbe_batch.bae_state = bat->bat_state;
-
 	} else {
 		entp->u.tbe_test.tse_type = test->tes_type;
 		entp->u.tbe_test.tse_loop = test->tes_loop;
@@ -1423,7 +1422,6 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 		translist = &batch->bat_trans_list;
 		ndlist = &batch->bat_cli_list;
 		hdr = &batch->bat_hdr;
-
 	} else {
 		/* query specified test only */
 		rc = lstcon_test_find(batch, testidx, &test);
-- 
1.7.1
