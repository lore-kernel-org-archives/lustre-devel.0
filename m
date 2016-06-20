From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:25 -0400
Subject: [lustre-devel] [PATCH v2 02/29] staging/lustre/llite: correct
	request handling after ll_lookup_it()
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

In the FIFO cases of ll_atomic_open() and ll_lookup_nd() remove
spurious calls to ptlrpc_req_finished(). Explain that these cases are
unreachable in practice anyway.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/17068
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7402
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/namei.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index d7459bd..6414d52 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -622,13 +622,10 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		if (d_really_is_positive(dentry) && it_disposition(it, DISP_OPEN_OPEN)) {
 			/* Open dentry. */
 			if (S_ISFIFO(d_inode(dentry)->i_mode)) {
-				/* We cannot call open here as it would
-				 * deadlock.
+				/* We cannot call open here as it might
+				 * deadlock. This case is unreachable in
+				 * practice because of OBD_CONNECT_NODEVOH.
 				 */
-				if (it_disposition(it, DISP_ENQ_OPEN_REF))
-					ptlrpc_req_finished(
-						       (struct ptlrpc_request *)
-							  it->d.lustre.it_data);
 				rc = finish_no_open(file, de);
 			} else {
 				file->private_data = it;
-- 
2.7.4
