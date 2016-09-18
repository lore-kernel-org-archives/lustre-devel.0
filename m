From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:45 -0400
Subject: [lustre-devel] [PATCH 106/124] staging: lustre: client: Fix mkdir
	-i 1 from DNE2 client to DNE1 server
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-107-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Artem Blagodarenko <artem_blagodarenko@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Artem Blagodarenko <artem_blagodarenko@xyratex.com>

After DNE phase 2 has been added to client it sends
create request to slave MDT.  DNT1-only server doesn't
expect request to slave MDT from client. It expects
only cross-mdt request from master MDT. Thus if DNE2
client tries to "mkdir -i 1" on DNE1 server, then
LBUG happened.

This patch adds OBD_CONNECT_DIR_STRIPE connection
flag check on client side. If striped directories are not
supported by server, then create requrest is sent to
master MDT.

Signed-off-by: Artem Blagodarenko <artem_blagodarenko@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6071
Xyratex-bug-id: MRP-2319
Reviewed-on: http://review.whamcloud.com/13189
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: wang di <di.wang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 185169c..5928605 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1690,15 +1690,19 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc)
 		return rc;
 
-	/*
-	 * Send the create request to the MDT where the object
-	 * will be located
-	 */
-	tgt = lmv_find_target(lmv, &op_data->op_fid2);
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
+	if (exp_connect_flags(exp) & OBD_CONNECT_DIR_STRIPE) {
+		/*
+		 * Send the create request to the MDT where the object
+		 * will be located
+		 */
+		tgt = lmv_find_target(lmv, &op_data->op_fid2);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
 
-	op_data->op_mds = tgt->ltd_idx;
+		op_data->op_mds = tgt->ltd_idx;
+	} else {
+		CDEBUG(D_CONFIG, "Server doesn't support striped dirs\n");
+	}
 
 	CDEBUG(D_INODE, "CREATE obj "DFID" -> mds #%x\n",
 	       PFID(&op_data->op_fid1), op_data->op_mds);
-- 
1.7.1
