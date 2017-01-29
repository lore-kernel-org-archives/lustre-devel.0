From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:18 -0500
Subject: [lustre-devel] [PATCH 50/60] staging: lustre: ptlrpc: remove unused
	pc->pc_env
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-51-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Environment for request interpreters is not used any more.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8887
Reviewed-on: https://review.whamcloud.com/24061
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |  4 ----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     | 13 -------------
 2 files changed, 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 411eb0d..a73f168 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1661,10 +1661,6 @@ struct ptlrpcd_ctl {
 	 */
 	char			pc_name[16];
 	/**
-	 * Environment for request interpreters to run in.
-	 */
-	struct lu_env	       pc_env;
-	/**
 	 * CPT the thread is bound on.
 	 */
 	int				pc_cpt;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 1f55d64..84c5551 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -562,15 +562,6 @@ int ptlrpcd_start(struct ptlrpcd_ctl *pc)
 		return 0;
 	}
 
-	/*
-	 * So far only "client" ptlrpcd uses an environment. In the future,
-	 * ptlrpcd thread (or a thread-set) has to be given an argument,
-	 * describing its "scope".
-	 */
-	rc = lu_context_init(&pc->pc_env.le_ctx, LCT_CL_THREAD | LCT_REMEMBER);
-	if (rc != 0)
-		goto out;
-
 	task = kthread_run(ptlrpcd, pc, "%s", pc->pc_name);
 	if (IS_ERR(task)) {
 		rc = PTR_ERR(task);
@@ -593,9 +584,6 @@ int ptlrpcd_start(struct ptlrpcd_ctl *pc)
 		spin_unlock(&pc->pc_lock);
 		ptlrpc_set_destroy(set);
 	}
-	lu_context_fini(&pc->pc_env.le_ctx);
-
-out:
 	clear_bit(LIOD_START, &pc->pc_flags);
 	return rc;
 }
@@ -623,7 +611,6 @@ void ptlrpcd_free(struct ptlrpcd_ctl *pc)
 	}
 
 	wait_for_completion(&pc->pc_finishing);
-	lu_context_fini(&pc->pc_env.le_ctx);
 
 	spin_lock(&pc->pc_lock);
 	pc->pc_set = NULL;
-- 
1.8.3.1
