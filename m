From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:24 -0400
Subject: [lustre-devel] [PATCH 14/30] lustre: ldlm: cond_resched in
 ldlm_bl_thread_main
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

When clearing all of the ldlm LRUs (as Cray does at the end of
a job), a ldlm_bl_work_item is generated for each namespace
and then they are placed on a list for the ldlm_bl threads to
iterate over.

If the number of namespaces greatly exceeds the number of
ldlm_bl threads, a given thread will iterate over many
namespaces without sleeping looking for work.  This can go
on for an extremely long time and result in an RCU stall.

This patch adds a cond_resched() between completing one
work item and looking for the next.  This is a fairly cheap
operation, as it will only schedule if there is an
interrupt waiting, and it will not be called too much -
Even the largest file systems have < 100 namespaces per
ldlm_bl_thread currently.

Signed-off-by: Patrick Farrell <paf@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8307
Reviewed-on: https://review.whamcloud.com/20888
Reviewed-by: Ned Bass <bass6@llnl.gov>
Reviewed-by: Ann Koehler <amk@cray.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index adc96b6..a8de3d9 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -856,6 +856,12 @@ static int ldlm_bl_thread_main(void *arg)
 
 		if (rc == LDLM_ITER_STOP)
 			break;
+
+		/* If there are many namespaces, we will not sleep waiting for
+		 * work, and must do a cond_resched to avoid holding the CPU
+		 * for too long
+		 */
+		cond_resched();
 	}
 
 	atomic_dec(&blp->blp_num_threads);
-- 
1.8.3.1
