From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:15 -0400
Subject: [lustre-devel] [PATCH 076/124] staging: lustre: ldlm: revert the
	changes for lock canceling policy
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-77-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

The changes for LRU lock policy was introduced by commit bfae5a4e,
where I was trying to revise the policy to pick locks for canceling.

However, this caused two problems as mentioned in LU-5727. The first
problem is that the lock can only be picked for canceling only if
the number of LRU locks is over preset LRU number AND it's aged; the
second problem is that mdc_cancel_weight() tends to not cancel OPEN
locks, therefore open locks can be kept forever and finally exhausts
memory on the MDT side.

The commit 7b2d26b0 ("revert changes to ldlm_cancel_aged_policy") fixed
the first problem. This patch will revert the rest of changes related
to LRU policy revise.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5727
Reviewed-on: http://review.whamcloud.com/12733
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 46842dd..582de52 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1198,9 +1198,6 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	if (slv == 0 || lv < slv)
 		return LDLM_POLICY_KEEP_LOCK;
 
-	if (ns->ns_cancel && ns->ns_cancel(lock) == 0)
-		return LDLM_POLICY_KEEP_LOCK;
-
 	return LDLM_POLICY_CANCEL_LOCK;
 }
 
@@ -1244,9 +1241,6 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 			cfs_time_add(lock->l_last_used, ns->ns_max_age)))
 		return LDLM_POLICY_KEEP_LOCK;
 
-	if (ns->ns_cancel && ns->ns_cancel(lock) == 0)
-		return LDLM_POLICY_KEEP_LOCK;
-
 	return LDLM_POLICY_CANCEL_LOCK;
 }
 
-- 
1.7.1
