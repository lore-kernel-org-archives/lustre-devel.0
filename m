From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:27 -0400
Subject: [lustre-devel] [PATCH 088/124] staging: lustre: ldlm: Recalculate
	interval in ldlm_pool_recalc()
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-89-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, James Simmons <jsimmons@infradead.org>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Instead of rechecking a static value, recalculate to see if pool stats
need to be updated.
Add newline so message will print instead of warning about missing
newline.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4536
Reviewed-on: http://review.whamcloud.com/12547
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c |   38 ++++++++++++++----------
 1 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 44c3abf..9a1136e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -357,33 +357,39 @@ static int ldlm_pool_recalc(struct ldlm_pool *pl)
 	int count;
 
 	recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
-	if (recalc_interval_sec <= 0)
-		goto recalc;
-
-	spin_lock(&pl->pl_lock);
 	if (recalc_interval_sec > 0) {
-		/*
-		 * Update pool statistics every 1s.
-		 */
-		ldlm_pool_recalc_stats(pl);
-
-		/*
-		 * Zero out all rates and speed for the last period.
-		 */
-		atomic_set(&pl->pl_grant_rate, 0);
-		atomic_set(&pl->pl_cancel_rate, 0);
+		spin_lock(&pl->pl_lock);
+		recalc_interval_sec = ktime_get_seconds() - pl->pl_recalc_time;
+
+		if (recalc_interval_sec > 0) {
+			/*
+			 * Update pool statistics every 1s.
+			 */
+			ldlm_pool_recalc_stats(pl);
+
+			/*
+			 * Zero out all rates and speed for the last period.
+			 */
+			atomic_set(&pl->pl_grant_rate, 0);
+			atomic_set(&pl->pl_cancel_rate, 0);
+		}
+		spin_unlock(&pl->pl_lock);
 	}
-	spin_unlock(&pl->pl_lock);
 
- recalc:
 	if (pl->pl_ops->po_recalc) {
 		count = pl->pl_ops->po_recalc(pl);
 		lprocfs_counter_add(pl->pl_stats, LDLM_POOL_RECALC_STAT,
 				    count);
 	}
+
 	recalc_interval_sec = pl->pl_recalc_time - ktime_get_seconds() +
 			      pl->pl_recalc_period;
 	if (recalc_interval_sec <= 0) {
+		/* DEBUG: should be re-removed after LU-4536 is fixed */
+		CDEBUG(D_DLMTRACE, "%s: Negative interval(%ld), too short period(%ld)\n",
+		       pl->pl_name, (long)recalc_interval_sec,
+		       (long)pl->pl_recalc_period);
+
 		/* Prevent too frequent recalculation. */
 		recalc_interval_sec = 1;
 	}
-- 
1.7.1
