From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:27 -0500
Subject: [lustre-devel] [PATCH v2 44/84] staging/lustre/fid: Adjust comments
	to better conform to coding style
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-45-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fid/fid_request.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 7ca65df..70400aa 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -95,7 +95,8 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 		 * precreating objects on this OST), and it will send the
 		 * request to MDT0 here, so we can not keep resending the
 		 * request here, otherwise if MDT0 is failed(umounted),
-		 * it can not release the export of MDT0 */
+		 * it can not release the export of MDT0
+		 */
 		if (seq->lcs_type == LUSTRE_SEQ_DATA)
 			req->rq_no_delay = req->rq_no_resend = 1;
 		debug_mask = D_CONSOLE;
@@ -152,7 +153,8 @@ static int seq_client_alloc_meta(const struct lu_env *env,
 		/* If meta server return -EINPROGRESS or EAGAIN,
 		 * it means meta server might not be ready to
 		 * allocate super sequence from sequence controller
-		 * (MDT0)yet */
+		 * (MDT0)yet
+		 */
 		rc = seq_client_rpc(seq, &seq->lcs_space,
 				    SEQ_ALLOC_META, "meta");
 	} while (rc == -EINPROGRESS || rc == -EAGAIN);
-- 
2.1.0
