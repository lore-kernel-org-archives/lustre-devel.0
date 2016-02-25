From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:51 -0500
Subject: [lustre-devel] [PATCH v2 68/84] staging/lustre/lmv: Remove
	commented out MDS selection policies
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-69-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

The new DNE code does not use them either so they are not longer needed.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c | 45 -----------------------------
 1 file changed, 45 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 67746c9..b5fc337 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1133,51 +1133,6 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	return rc;
 }
 
-#if 0
-static int lmv_all_chars_policy(int count, const char *name,
-				int len)
-{
-	unsigned int c = 0;
-
-	while (len > 0)
-		c += name[--len];
-	c = c % count;
-	return c;
-}
-
-static int lmv_nid_policy(struct lmv_obd *lmv)
-{
-	struct obd_import *imp;
-	__u32	      id;
-
-	/*
-	 * XXX: To get nid we assume that underlying obd device is mdc.
-	 */
-	imp = class_exp2cliimp(lmv->tgts[0].ltd_exp);
-	id = imp->imp_connection->c_self ^ (imp->imp_connection->c_self >> 32);
-	return id % lmv->desc.ld_tgt_count;
-}
-
-static int lmv_choose_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
-			  enum placement_policy placement)
-{
-	switch (placement) {
-	case PLACEMENT_CHAR_POLICY:
-		return lmv_all_chars_policy(lmv->desc.ld_tgt_count,
-					    op_data->op_name,
-					    op_data->op_namelen);
-	case PLACEMENT_NID_POLICY:
-		return lmv_nid_policy(lmv);
-
-	default:
-		break;
-	}
-
-	CERROR("Unsupported placement policy %x\n", placement);
-	return -EINVAL;
-}
-#endif
-
 /**
  * This is _inode_ placement policy function (not name).
  */
-- 
2.1.0
