From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:31 -0400
Subject: [lustre-devel] [PATCH 132/151] lustre: llite: Add exit for filedata
 allocation failed
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-133-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ben Evans <bevans@cray.com>

When the filedata allocation fails, we need to exit to
a later point than out_openerr, which calls
deauthorize_statahead and ll_file_data_put, neither of
which is valid. (This leads to a panic.)

WC-bug-id: https://jira.whamcloud.com/browse/LU-10662
Cray-bug-id: LUS-1321
Lustre-commit: d9edfa50683a ('LU-10662 llite: Add exit for filedata allocation failed")
Signed-off-by: Ben Evans <bevans@cray.com>
Reviewed-on: https://review.whamcloud.com/31296
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index da5bf86..6732b68 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -540,7 +540,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	fd = ll_file_data_get();
 	if (!fd) {
 		rc = -ENOMEM;
-		goto out_openerr;
+		goto out_nofiledata;
 	}
 
 	fd->fd_file = file;
@@ -723,6 +723,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_OPEN, 1);
 	}
 
+out_nofiledata:
 	if (it && it_disposition(it, DISP_ENQ_OPEN_REF)) {
 		ptlrpc_req_finished(it->it_request);
 		it_clear_disposition(it, DISP_ENQ_OPEN_REF);
-- 
1.8.3.1
