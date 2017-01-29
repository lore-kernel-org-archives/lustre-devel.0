From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:15 -0500
Subject: [lustre-devel] [PATCH 47/60] staging: lustre: mdc: avoid returning
	freed request
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-48-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

In mdc_close() if ptlrpc_request_pack() fails then set req to NULL so
that an already freed request is not returned in *request.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8811
Reviewed-on: https://review.whamcloud.com/23843
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 02f57d8..a12035d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -762,6 +762,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_CLOSE);
 	if (rc) {
 		ptlrpc_request_free(req);
+		req = NULL;
 		goto out;
 	}
 
-- 
1.8.3.1
