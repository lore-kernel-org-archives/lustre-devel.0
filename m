From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:14:52 -0400
Subject: [lustre-devel] [PATCH 03/22] staging: lustre: obd: change debug
 reporting in lmv_enqueue()
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vitaly Fertman <vitaly.fertman@seagate.com>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Vitaly Fertman <vitaly.fertman@seagate.com>

Remove LL_IT2STR(it) from debug macros in lmv_enqueue(). The
removal makes it possible to simplify the md_enqueue() functions.

Signed-off-by: Vitaly Fertman <vitaly.fertman@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7433
Seagate-bug-id: MRP-3072 MRP-3137
Reviewed-on: http://review.whamcloud.com/17220
Reviewed-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Tested-by: Elena V. Gryaznova <elena.gryaznova@seagate.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 7be9310..e1c93cd 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1660,15 +1660,14 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_obd	   *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc      *tgt;
 
-	CDEBUG(D_INODE, "ENQUEUE '%s' on " DFID "\n",
-	       LL_IT2STR(it), PFID(&op_data->op_fid1));
+	CDEBUG(D_INODE, "ENQUEUE on " DFID "\n", PFID(&op_data->op_fid1));
 
 	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	CDEBUG(D_INODE, "ENQUEUE '%s' on " DFID " -> mds #%u\n",
-	       LL_IT2STR(it), PFID(&op_data->op_fid1), tgt->ltd_idx);
+	CDEBUG(D_INODE, "ENQUEUE on " DFID " -> mds #%u\n",
+	       PFID(&op_data->op_fid1), tgt->ltd_idx);
 
 	return md_enqueue(tgt->ltd_exp, einfo, policy, it, op_data, lockh,
 			extra_lock_flags);
-- 
1.8.3.1
