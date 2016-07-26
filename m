From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 21:14:48 +0200
Subject: [lustre-devel] [PATCH 12/12] staging: lustre: Delete an unnecessary
 variable initialisation in mgc_process_recover_log()
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <2ea70f05-14de-7d93-83da-26e2439a7239@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 19:50:40 +0200

The variable "req" will eventually be set to an appropriate pointer
from a call of the ptlrpc_request_alloc() function.
Thus omit the explicit initialisation which became unnecessary with
a previous update step.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 8f5db79..6e8368e 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1315,7 +1315,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 static int mgc_process_recover_log(struct obd_device *obd,
 				   struct config_llog_data *cld)
 {
-	struct ptlrpc_request *req = NULL;
+	struct ptlrpc_request *req;
 	struct config_llog_instance *cfg = &cld->cld_cfg;
 	struct mgs_config_body *body;
 	struct mgs_config_res  *res;
-- 
2.9.2
