From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:41 -0500
Subject: [lustre-devel] [PATCH 08/28] lustre: llite: rmdir releases inode on
 client
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Same as file unlink, rmdir should release inode on client, to achieve
this, ll_rmdir() update inode i_nlink after rmdir, then the last
iput() will release the inode.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13983
Lustre-commit: 4a4794364eb05f ("LU-13983 llite: rmdir releases inode on client")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40011
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index f9c10d0..da6b729 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1659,12 +1659,23 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
 	if (rc == 0) {
+		struct mdt_body *body;
+
 		ll_update_times(request, dir);
 		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_RMDIR,
 				   ktime_us_delta(ktime_get(), kstart));
+		/*
+		 * The server puts attributes in on the last unlink, use them
+		 * to update the link count so the inode can be freed
+		 * immediately.
+		 */
+		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
+		if (body->mbo_valid & OBD_MD_FLNLINK)
+			set_nlink(dchild->d_inode, body->mbo_nlink);
 	}
 
 	ptlrpc_req_finished(request);
+
 	return rc;
 }
 
-- 
1.8.3.1
