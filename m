From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 21:08:16 +0200
Subject: [lustre-devel] [PATCH 07/12] staging: lustre: Less checks after a
 failed alloc_page() in mgc_process_recover_log()
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <8b1f7027-7831-a7b3-f902-6e8053b46771@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 17:12:51 +0200

Release memory directly after a page allocation failed at the beginning.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index d716bb2..b064bd3 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1346,7 +1346,7 @@ static int mgc_process_recover_log(struct obd_device *obd,
 		pages[i] = alloc_page(GFP_KERNEL);
 		if (!pages[i]) {
 			rc = -ENOMEM;
-			goto out;
+			goto free_pages;
 		}
 	}
 
@@ -1461,14 +1461,13 @@ out:
 	if (rc == 0 && !eof)
 		goto again;
 
-	if (pages) {
-		for (i = 0; i < nrpages; i++) {
-			if (!pages[i])
-				break;
-			__free_page(pages[i]);
-		}
-		kfree(pages);
+free_pages:
+	for (i = 0; i < nrpages; i++) {
+		if (!pages[i])
+			break;
+		__free_page(pages[i]);
 	}
+	kfree(pages);
 	return rc;
 }
 
-- 
2.9.2
