From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 14:56:43 +0100
Subject: [lustre-devel] [PATCH 4/7] staging: lustre: Delete an unnecessary
 variable initialisation in mgc_process_recover_log()
In-Reply-To: <566D7733.1030102@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
Message-ID: <566D791B.7010604@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 12:00:32 +0100

The variable "mne_swab" will eventually be set to an appropriate value
from a call of the ptlrpc_rep_need_swab() function.
Thus let us omit the explicit initialisation at the beginning.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 2c48847..da130f4 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1293,7 +1293,7 @@ static int mgc_process_recover_log(struct obd_device *obd,
 	struct page **pages;
 	int nrpages;
 	bool eof = true;
-	bool mne_swab = false;
+	bool mne_swab;
 	int i;
 	int ealen;
 	int rc;
-- 
2.6.3
