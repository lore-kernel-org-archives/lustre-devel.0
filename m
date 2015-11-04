From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 Nov 2015 13:40:06 -0500
Subject: [lustre-devel] [PATCH 10/10] staging: lustre: fix 'error handling'
	issues for libcfs workitem.c
In-Reply-To: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
References: <1446662406-4590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446662406-4590-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sebastien.buisson@bull.net>

Fix 'error handling' issues found by Coverity version 6.5.1:
Unchecked return value (CHECKED_RETURN)
Calling function without checking return value.

Signed-off-by: Sebastien Buisson <sebastien.buisson@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3427
Reviewed-on: http://review.whamcloud.com/7103
Reviewed-by: Bobbie Lind <bobbie.j.lind@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/libcfs/workitem.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index f6cc434..e405fc2 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -225,7 +225,9 @@ cfs_wi_scheduler (void *arg)
 
 	/* CPT affinity scheduler? */
 	if (sched->ws_cptab != NULL)
-		cfs_cpt_bind(sched->ws_cptab, sched->ws_cpt);
+		if (cfs_cpt_bind(sched->ws_cptab, sched->ws_cpt) != 0)
+			CWARN("Failed to bind %s on CPT %d\n",
+			      sched->ws_name, sched->ws_cpt);
 
 	spin_lock(&cfs_wi_data.wi_glock);
 
-- 
1.7.1
