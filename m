From: James Simmons <jsimmons@infradead.org>
Date: Sat, 11 Feb 2017 12:12:39 -0500
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: llite: check reply
	status in ll_migrate()
In-Reply-To: <1486833159-16251-1-git-send-email-jsimmons@infradead.org>
References: <1486833159-16251-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1486833159-16251-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

ll_migrate() should check reply status before trying to read
reply buffer, checking if request is NULL doesn't make sense.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8807
Reviewed-on: https://review.whamcloud.com/23666
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 271608d..10adfcd 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2664,15 +2664,12 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	op_data->op_cli_flags = CLI_MIGRATE;
 	rc = md_rename(ll_i2sbi(parent)->ll_md_exp, op_data, name,
 		       namelen, name, namelen, &request);
-	if (!rc)
+	if (!rc) {
+		LASSERT(request);
 		ll_update_times(request, parent);
 
-	if (request) {
 		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
-		if (!body) {
-			rc = -EPROTO;
-			goto out_close;
-		}
+		LASSERT(body);
 
 		/*
 		 * If the server does release layout lock, then we cleanup
@@ -2686,14 +2683,17 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 			kfree(och);
 			och = NULL;
 		}
+	}
 
+	if (request) {
 		ptlrpc_req_finished(request);
+		request = NULL;
 	}
+
 	/* Try again if the file layout has changed. */
-	if (rc == -EAGAIN && S_ISREG(child_inode->i_mode)) {
-		request = NULL;
+	if (rc == -EAGAIN && S_ISREG(child_inode->i_mode))
 		goto again;
-	}
+
 out_close:
 	if (och) /* close the file */
 		ll_lease_close(och, child_inode, NULL);
-- 
1.8.3.1
