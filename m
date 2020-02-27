From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:14 -0500
Subject: [lustre-devel] [PATCH 026/622] lustre: ptlrpc: fix
 test_req_buffer_pressure behavior
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

In 2nd patch for LU-9372, to allow limiting number of rqbd-buffers,
a wrong and unnecessary test had been added to enhance
test_req_buffer_pressure feature.
This patch fixes this issue by removing such test.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10826
Lustre-commit: 040eca67f8d5 ("LU-10826 ptlrpc: fix test_req_buffer_pressure behavior")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: https://review.whamcloud.com/31690
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 3c61e83..8dae21a 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -150,8 +150,7 @@
 		/* NB: another thread might have recycled enough rqbds, we
 		 * need to make sure it wouldn't over-allocate, see LU-1212.
 		 */
-		if (test_req_buffer_pressure ||
-		    svcpt->scp_nrqbds_posted >= svc->srv_nbuf_per_group ||
+		if (svcpt->scp_nrqbds_posted >= svc->srv_nbuf_per_group ||
 		    (svc->srv_nrqbds_max != 0 &&
 		     svcpt->scp_nrqbds_total > svc->srv_nrqbds_max))
 			break;
-- 
1.8.3.1
