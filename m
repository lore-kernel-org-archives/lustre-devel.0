From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:44 -0500
Subject: [lustre-devel] [PATCH 14/35] staging: lustre: nrs: serialize
	executions of nrs_policy_stop
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

Do not release nrs_lock in nrs_policy_stop0 to prevent op_policy_stop()
from being executed concurrently.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7096
Reviewed-on: http://review.whamcloud.com/16214
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/nrs.c |   16 +++-------------
 1 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index f856632..7b6ffb1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -82,16 +82,9 @@ static int nrs_policy_ctl_locked(struct ptlrpc_nrs_policy *policy,
 
 static void nrs_policy_stop0(struct ptlrpc_nrs_policy *policy)
 {
-	struct ptlrpc_nrs *nrs = policy->pol_nrs;
-
-	if (policy->pol_desc->pd_ops->op_policy_stop) {
-		spin_unlock(&nrs->nrs_lock);
-
+	if (policy->pol_desc->pd_ops->op_policy_stop)
 		policy->pol_desc->pd_ops->op_policy_stop(policy);
 
-		spin_lock(&nrs->nrs_lock);
-	}
-
 	LASSERT(list_empty(&policy->pol_list_queued));
 	LASSERT(policy->pol_req_queued == 0 &&
 		policy->pol_req_started == 0);
@@ -619,11 +612,8 @@ static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 		goto out;
 	}
 
-	/**
-	 * Wait for the policy to be fully started before attempting
-	 * to operate it.
-	 */
-	if (policy->pol_state == NRS_POL_STATE_STARTING) {
+	if (policy->pol_state != NRS_POL_STATE_STARTED &&
+	    policy->pol_state != NRS_POL_STATE_STOPPED) {
 		rc = -EAGAIN;
 		goto out;
 	}
-- 
1.7.1
