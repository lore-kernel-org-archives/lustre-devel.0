From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:28:58 -0400
Subject: [lustre-devel] [PATCH 7/9] staging: lustre: ptlrpc: fix nrs cleanup
In-Reply-To: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462372140-27880-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

When service start failed due to short of memory, the cleanup code
could operate on uninitialized structure and cause crash at the end.

This patch fix the nrs_svcpt_cleanup_locked() to perform cleanup only
on the nrs which has been properly initialized.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3772
Reviewed-on: http://review.whamcloud.com/7410
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/nrs.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index 99ff6e8..c444f51 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -975,7 +975,11 @@ static void nrs_svcpt_cleanup_locked(struct ptlrpc_service_part *svcpt)
 	LASSERT(mutex_is_locked(&nrs_core.nrs_mutex));
 
 again:
-	nrs = nrs_svcpt2nrs(svcpt, hp);
+	/* scp_nrs_hp could be NULL due to short of memory. */
+	nrs = hp ? svcpt->scp_nrs_hp : &svcpt->scp_nrs_reg;
+	/* check the nrs_svcpt to see if nrs is initialized. */
+	if (!nrs || !nrs->nrs_svcpt)
+		return;
 	nrs->nrs_stopping = 1;
 
 	list_for_each_entry_safe(policy, tmp, &nrs->nrs_policy_list, pol_list) {
-- 
2.7.4
