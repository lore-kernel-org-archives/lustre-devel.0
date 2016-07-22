From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:40 -0400
Subject: [lustre-devel] [PATCH 47/58] staging: lustre: lmv: lookup remote
	migrating object in LMV
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-48-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

If remote object is being found in a migrating directory,
it should continue to lookup the object in remote MDT,
instead of return.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4805
Reviewed-on: http://review.whamcloud.com/9806
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 51b7048..a38d343 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -471,7 +471,6 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		it->it_disposition &= ~DISP_ENQ_COMPLETE;
 		rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
 				    flags, reqp, cb_blocking, extra_lock_flags);
-		return rc;
 	}
 
 	/*
-- 
1.7.1
