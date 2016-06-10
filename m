From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu,  9 Jun 2016 22:35:18 -0400
Subject: [lustre-devel] [PATCH 8/8] staging/lustre/lmv: Fix Multiple
	Assignments
In-Reply-To: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
References: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465526118-521053-9-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Fix all multiple assignments on lustre/lmv directory.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 9e31f6b..1d9875e 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2686,7 +2686,7 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 	struct lmv_obd      *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 	int		  rc = 0, i;
-	__u64		curspace, curinodes;
+	__u64 curspace = 0, curinodes = 0;
 
 	if (!tgt || !tgt->ltd_exp || !tgt->ltd_active ||
 	    !lmv->desc.ld_tgt_count) {
@@ -2699,7 +2699,6 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 		return rc;
 	}
 
-	curspace = curinodes = 0;
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		int err;
 
-- 
2.7.4
