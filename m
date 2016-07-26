From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 21:07:02 +0200
Subject: [lustre-devel] [PATCH 06/12] staging: lustre: Return directly after
 a failed kcalloc() in mgc_process_recover_log()
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <8484b472-20b6-e8ca-b18e-a3d2976d4c28@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 16:32:31 +0200

Return directly after a memory allocation failed at the beginning.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 9d0bd47..d716bb2 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1339,10 +1339,8 @@ static int mgc_process_recover_log(struct obd_device *obd,
 		nrpages = CONFIG_READ_NRPAGES_INIT;
 
 	pages = kcalloc(nrpages, sizeof(*pages), GFP_KERNEL);
-	if (!pages) {
-		rc = -ENOMEM;
-		goto out;
-	}
+	if (!pages)
+		return -ENOMEM;
 
 	for (i = 0; i < nrpages; i++) {
 		pages[i] = alloc_page(GFP_KERNEL);
-- 
2.9.2
