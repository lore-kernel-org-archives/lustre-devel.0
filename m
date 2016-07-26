From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 21:05:48 +0200
Subject: [lustre-devel] [PATCH 05/12] staging: lustre: Optimize error
 handling in class_register_type()
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <d1f69f4d-539b-e97d-fc0e-cb0a8754bd3a@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 14:23:23 +0200

Return a constant error code without storing it in the local variable "rc"
after a failed memory allocation at the beginning of this function.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/obdclass/genops.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index fd5e61f..4752091 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -152,10 +152,9 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 		return -EEXIST;
 	}
 
-	rc = -ENOMEM;
 	type = kzalloc(sizeof(*type), GFP_NOFS);
 	if (!type)
-		return rc;
+		return -ENOMEM;
 
 	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
 	if (!type->typ_dt_ops) {
-- 
2.9.2
