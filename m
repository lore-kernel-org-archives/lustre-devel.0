From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:05 -0400
Subject: [lustre-devel] [PATCH 006/124] staging: lustre: lmv: Do not ignore
	ENOENT in lmv_unlink
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Return correct value (rc) in lmv_unlink. In lmv_unlink,
-ENOENT might be ingored for local directory unlink.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5371
Reviewed-on: http://review.whamcloud.com/11170
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 171c260..11dcbb6 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2643,7 +2643,7 @@ try_next_stripe:
 
 	/* Not cross-ref case, just get out of here. */
 	if (likely(!(body->mbo_valid & OBD_MD_MDS)))
-		return 0;
+		return rc;
 
 	CDEBUG(D_INODE, "%s: try unlink to another MDT for "DFID"\n",
 	       exp->exp_obd->obd_name, PFID(&body->mbo_fid1));
-- 
1.7.1
