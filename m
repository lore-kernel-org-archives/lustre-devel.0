From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu,  9 Jun 2016 22:35:12 -0400
Subject: [lustre-devel] [PATCH 2/8] staging/lustre/fid: Fix Multiple
	Assignments
In-Reply-To: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
References: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465526118-521053-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Fix all multiple assignments on lustre/fid directory.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fid/fid_request.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 3a4df62..9db21ba 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -98,8 +98,10 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 		 * request here, otherwise if MDT0 is failed(umounted),
 		 * it can not release the export of MDT0
 		 */
-		if (seq->lcs_type == LUSTRE_SEQ_DATA)
-			req->rq_no_delay = req->rq_no_resend = 1;
+		if (seq->lcs_type == LUSTRE_SEQ_DATA) {
+			req->rq_no_delay = 1;
+			req->rq_no_resend = 1;
+		}
 		debug_mask = D_CONSOLE;
 	} else {
 		if (seq->lcs_type == LUSTRE_SEQ_METADATA) {
-- 
2.7.4
