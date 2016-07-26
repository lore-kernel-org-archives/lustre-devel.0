From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 21:13:23 +0200
Subject: [lustre-devel] [PATCH 11/12] staging: lustre: Move an assignment
 for the variable "eof" in mgc_process_recover_log()
In-Reply-To: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
Message-ID: <83a0671d-5c02-0bd4-2a97-47dea50585c3@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 19:40:28 +0200

Move the assignment for the local variable "eof" behind the source code
for memory allocations by this function.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index ff60b9b..8f5db79 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1322,7 +1322,7 @@ static int mgc_process_recover_log(struct obd_device *obd,
 	struct ptlrpc_bulk_desc *desc;
 	struct page **pages;
 	int nrpages;
-	bool eof = true;
+	bool eof;
 	bool mne_swab;
 	int i;
 	int ealen;
@@ -1350,6 +1350,7 @@ static int mgc_process_recover_log(struct obd_device *obd,
 		}
 	}
 
+	eof = true;
 again:
 	LASSERT(cld_is_recover(cld));
 	LASSERT(mutex_is_locked(&cld->cld_lock));
-- 
2.9.2
