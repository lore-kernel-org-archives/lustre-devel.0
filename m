From: James Simmons <jsimmons@infradead.org>
Date: Sat, 11 Feb 2017 12:12:37 -0500
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: llite: check request !=
	NULL in ll_migrate
In-Reply-To: <1486833159-16251-1-git-send-email-jsimmons@infradead.org>
References: <1486833159-16251-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1486833159-16251-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Check if the request is NULL, before retrieve reply body
from the request.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7396
Reviewed-on: http://review.whamcloud.com/17079
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 41 +++++++++++++++++-------------
 1 file changed, 23 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 9870901..0c83bd7 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2667,28 +2667,33 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	if (!rc)
 		ll_update_times(request, parent);
 
-	body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
-	if (!body) {
-		rc = -EPROTO;
-		goto out_free;
-	}
+	if (request) {
+		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
+		if (!body) {
+			rc = -EPROTO;
+			goto out_free;
+		}
 
-	/*
-	 * If the server does release layout lock, then we cleanup
-	 * the client och here, otherwise release it in out_free:
-	 */
-	if (och && body->mbo_valid & OBD_MD_CLOSE_INTENT_EXECED) {
-		obd_mod_put(och->och_mod);
-		md_clear_open_replay_data(ll_i2sbi(parent)->ll_md_exp, och);
-		och->och_fh.cookie = DEAD_HANDLE_MAGIC;
-		kfree(och);
-		och = NULL;
-	}
+		/*
+		 * If the server does release layout lock, then we cleanup
+		 * the client och here, otherwise release it in out_free:
+		 */
+		if (och && body->mbo_valid & OBD_MD_CLOSE_INTENT_EXECED) {
+			obd_mod_put(och->och_mod);
+			md_clear_open_replay_data(ll_i2sbi(parent)->ll_md_exp,
+						  och);
+			och->och_fh.cookie = DEAD_HANDLE_MAGIC;
+			kfree(och);
+			och = NULL;
+		}
 
-	ptlrpc_req_finished(request);
+		ptlrpc_req_finished(request);
+	}
 	/* Try again if the file layout has changed. */
-	if (rc == -EAGAIN && S_ISREG(child_inode->i_mode))
+	if (rc == -EAGAIN && S_ISREG(child_inode->i_mode)) {
+		request = NULL;
 		goto again;
+	}
 out_free:
 	if (child_inode) {
 		if (och) /* close the file */
-- 
1.8.3.1
