From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 28 Aug 2016 23:27:06 +0200
Subject: [lustre-devel] [PATCH] staging/lustre: constify sops structure
Message-ID: <1472419626-13054-1-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: kernel-janitors@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

sops, of type struct seq_operations, is never modified, so declare it as
const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 327cf63..9bad57d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -937,7 +937,7 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 static int
 ptlrpc_lprocfs_svc_req_history_open(struct inode *inode, struct file *file)
 {
-	static struct seq_operations sops = {
+	static const struct seq_operations sops = {
 		.start = ptlrpc_lprocfs_svc_req_history_start,
 		.stop  = ptlrpc_lprocfs_svc_req_history_stop,
 		.next  = ptlrpc_lprocfs_svc_req_history_next,
