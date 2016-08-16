From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:19 -0400
Subject: [lustre-devel] [PATCH 06/80] staging: lustre: mdc: don't take rpc
	lock for readdir case
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

If the operation is IT_READDIR don't need to handle the
mdc RPC lock.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/10761
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4906
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_mdc.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index fa62b95..0a8c639 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -96,7 +96,7 @@ static inline void mdc_get_rpc_lock(struct mdc_rpc_lock *lck,
 				    struct lookup_intent *it)
 {
 	if (it && (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
-		   it->it_op == IT_LAYOUT))
+		   it->it_op == IT_LAYOUT || it->it_op == IT_READDIR))
 		return;
 
 	/* This would normally block until the existing request finishes.
@@ -136,7 +136,7 @@ static inline void mdc_put_rpc_lock(struct mdc_rpc_lock *lck,
 				    struct lookup_intent *it)
 {
 	if (it && (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
-		   it->it_op == IT_LAYOUT))
+		   it->it_op == IT_LAYOUT || it->it_op == IT_READDIR))
 		return;
 
 	if (lck->rpcl_it == MDC_FAKE_RPCL_IT) { /* OBD_FAIL_MDC_RPCS_SEM */
-- 
1.7.1
