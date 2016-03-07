From: James Simmons <jsimmons@infradead.org>
Date: Mon,  7 Mar 2016 18:10:18 -0500
Subject: [lustre-devel] [PATCH v2 3/9] staging: lustre: fix 'data race
	condition' issue in conrpc.c
In-Reply-To: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
References: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457392224-2592-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>

From: Sebastien Buisson <sbuisson@ddn.com>

Fix 'data race condition' defects found by Coverity version 6.5.0:
Data race condition (MISSING_LOCK)
Accessing variable without holding lock. Elsewhere,
this variable is accessed with lock held.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2744
Reviewed-on: http://review.whamcloud.com/6567
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index e6376a0..8a67f89 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -945,8 +945,12 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
 		return status;
 
 	if (!trans->tas_feats_updated) {
-		trans->tas_feats_updated = 1;
-		trans->tas_features = reply->msg_ses_feats;
+		spin_lock(&console_session.ses_rpc_lock);
+		if (!trans->tas_feats_updated) { /* recheck with lock */
+			trans->tas_feats_updated = 1;
+			trans->tas_features = reply->msg_ses_feats;
+		}
+		spin_unlock(&console_session.ses_rpc_lock);
 	}
 
 	if (reply->msg_ses_feats != trans->tas_features) {
-- 
1.7.1
