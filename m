From: James Simmons <jsimmons@infradead.org>
Date: Mon,  7 Nov 2016 21:47:20 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: pl_recalc time
	handling is wrong
Message-ID: <1478573240-12850-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The ldlm_pool field pl_recalc_time is set to the current
monotonic clock value but the interval period is calculated
with the wall clock. This means the interval period will
always be far larger than the pl_recalc_period, which is
just a small interval time period. The correct thing to
do is to use monotomic clock current value instead of the
wall clocks value when calculating recalc_interval_sec.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 19831c5..30d4f80 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -256,7 +256,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	time64_t recalc_interval_sec;
 	int ret;
 
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
 	if (recalc_interval_sec < pl->pl_recalc_period)
 		return 0;
 
@@ -264,7 +264,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	/*
 	 * Check if we need to recalc lists now.
 	 */
-	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
 	if (recalc_interval_sec < pl->pl_recalc_period) {
 		spin_unlock(&pl->pl_lock);
 		return 0;
@@ -301,7 +301,7 @@ static int ldlm_cli_pool_recalc(struct ldlm_pool *pl)
 	 * Time of LRU resizing might be longer than period,
 	 * so update after LRU resizing rather than before it.
 	 */
-	pl->pl_recalc_time = ktime_get_real_seconds();
+	pl->pl_recalc_time = ktime_get_seconds();
 	lprocfs_counter_add(pl->pl_stats, LDLM_POOL_TIMING_STAT,
 			    recalc_interval_sec);
 	spin_unlock(&pl->pl_lock);
-- 
1.7.1
