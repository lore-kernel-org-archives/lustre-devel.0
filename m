From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:41 -0400
Subject: [lustre-devel] [PATCH 48/58] staging: lustre: lmv: Ensure
	lmv_intent_lookup cleans up reqp
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-49-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, James Simmons <jsimmons@infradead.org>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Ensure there aren't invalid pointers hanging around after
ptlrpc_req_finished is called.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4826
Reviewed-on: http://review.whamcloud.com/9841
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index a38d343..d7e165f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -464,6 +464,9 @@ static int lmv_intent_lookup(struct obd_export *exp,
 			return PTR_ERR(tgt);
 
 		ptlrpc_req_finished(*reqp);
+		it->it_request = NULL;
+		*reqp = NULL;
+
 		CDEBUG(D_INODE, "For migrating dir, try target dir "DFID"\n",
 		       PFID(&lsm->lsm_md_oinfo[1].lmo_fid));
 
-- 
1.7.1
