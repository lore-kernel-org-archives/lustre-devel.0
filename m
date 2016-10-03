From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:05 -0400
Subject: [lustre-devel] [PATCH 09/41] staging: lustre: llite: default dir
	stripe index only for mkdir
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Default dir stripe index should only work during mkdir,
otherwise it will cause other open/create request being
sent to the wrong MDT.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6373
Reviewed-on: http://review.whamcloud.com/14096
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index e75ab2f..c7aab3f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2269,8 +2269,9 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	op_data->op_default_stripe_offset = -1;
 	if (S_ISDIR(i1->i_mode)) {
 		op_data->op_mea1 = ll_i2info(i1)->lli_lsm_md;
-		op_data->op_default_stripe_offset =
-			ll_i2info(i1)->lli_def_stripe_offset;
+		if (opc == LUSTRE_OPC_MKDIR)
+			op_data->op_default_stripe_offset =
+				ll_i2info(i1)->lli_def_stripe_offset;
 	}
 
 	if (i2) {
-- 
1.7.1
